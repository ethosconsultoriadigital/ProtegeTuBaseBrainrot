-- MatchManager
-- Orquestador principal: conecta sistemas, RemoteEvents, win/lose
-- Ubicación: ServerScriptService > Systems > MatchManager (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig    = require(ReplicatedStorage.Modules.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.EconomyConfig)

local MatchManager = {}

-- Sistemas (inyectados)
local BrainrotManager, DefenseManager, BaseManager = nil, nil, nil
local CaptureManager, EconomyManager, WaveManager = nil, nil, nil
local Events = nil

local matchState = "WAITING" -- WAITING, PLAYING, VICTORY, DEFEAT
local stats = {
	totalKills   = 0,
	totalCaptures = 0,
	wavesCompleted = 0,
	perfectWaves = 0,
	vaultValue   = 0,
}

function MatchManager.Init(sys)
	BrainrotManager = sys.BrainrotManager
	DefenseManager  = sys.DefenseManager
	BaseManager     = sys.BaseManager
	CaptureManager  = sys.CaptureManager
	EconomyManager  = sys.EconomyManager
	WaveManager     = sys.WaveManager
	Events = ReplicatedStorage:FindFirstChild("Events")

	-- Callbacks
	BrainrotManager.OnBrainrotDied(function(_id, brData, killedByDefense)
		if killedByDefense then
			stats.totalKills += 1
			EconomyManager.RewardKill(brData)
		end
	end)

	BrainrotManager.OnBrainrotReachedEnd(function(_id, brData)
		BaseManager.HandleBrainrotArrival(brData)
	end)

	BaseManager.OnGameOver(function(reason)
		MatchManager._End("DEFEAT", reason)
	end)

	WaveManager.OnWaveComplete(function(waveNum, perfect)
		stats.wavesCompleted = waveNum
		if perfect then
			stats.perfectWaves += 1
			EconomyManager.RewardPerfectWave()
		end
	end)

	WaveManager.OnAllWavesComplete(function()
		task.delay(3, function()
			if matchState == "PLAYING" then
				MatchManager._End("VICTORY", "all_waves_complete")
			end
		end)
	end)

	MatchManager._ConnectRemotes()
end

-----------------------------------------------------------------------
-- REMOTE EVENTS
-----------------------------------------------------------------------
function MatchManager._ConnectRemotes()
	-- Place defense
	Events.RequestPlaceDefense.OnServerEvent:Connect(function(player, data)
		if matchState ~= "PLAYING" then return end
		if type(data) ~= "table" or not data.defenseType or not data.position then return end

		local cost = DefenseManager.GetPlacementCost(data.defenseType)
		if not EconomyManager.CanAfford(player, cost) then return end

		local ok, err = DefenseManager.TryPlace(player, data.defenseType, data.position)
		if ok then
			EconomyManager.SpendCells(player, cost)
		end
	end)

	-- Sell defense
	Events.RequestSellDefense.OnServerEvent:Connect(function(player, data)
		if matchState ~= "PLAYING" then return end
		if type(data) ~= "table" or not data.defenseId then return end

		local ok, refund = DefenseManager.TrySell(player, data.defenseId)
		if ok then EconomyManager.AddCells(player, refund) end
	end)

	-- Repair barrier
	Events.RequestRepairBarrier.OnServerEvent:Connect(function(player)
		if matchState ~= "PLAYING" then return end
		local cost = BaseManager.GetRepairCost()
		if not EconomyManager.CanAfford(player, cost) then return end
		local ok = BaseManager.TryRepairBarrier()
		if ok then EconomyManager.SpendCells(player, cost) end
	end)

	-- Skip timer
	Events.RequestSkipTimer.OnServerEvent:Connect(function(_player)
		if matchState ~= "PLAYING" then return end
		WaveManager.SkipBuildTimer()
	end)

	-- Get game state
	Events.GetGameState.OnServerInvoke = function(player)
		return {
			matchState = matchState,
			wave       = WaveManager.GetCurrentWave(),
			totalWaves = WaveConfig and 8 or 8,
			cells      = EconomyManager.GetCells(player),
			barrierHP  = BaseManager.GetBarrierHP(),
			barrierMax = BaseManager.GetBarrierMaxHP(),
			breached   = BaseManager.IsBreached(),
			vaultCount = BaseManager.GetVaultCount(),
			vaultMax   = GameConfig.VAULT_MAX_SLOTS,
			vault      = BaseManager.GetVault(),
		}
	end
end

-----------------------------------------------------------------------
-- START / END
-----------------------------------------------------------------------
function MatchManager.StartMatch()
	matchState = "PLAYING"
	stats = { totalKills = 0, totalCaptures = 0, wavesCompleted = 0, perfectWaves = 0, vaultValue = 0 }

	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.InitPlayer(p)
	end

	WaveManager.Start()
	print("[Match] Partida iniciada!")
end

function MatchManager._End(result: string, reason: string)
	if matchState ~= "PLAYING" then return end
	matchState = result
	WaveManager.ForceStop()
	stats.vaultValue = BaseManager.GetVaultTotalValue()

	print("[Match] " .. result .. " - " .. reason)
	print("  Kills: " .. stats.totalKills)
	print("  Oleadas: " .. stats.wavesCompleted)
	print("  Perfectas: " .. stats.perfectWaves)
	print("  Boveda: " .. stats.vaultValue .. " pts")

	if Events then
		Events.GameOver:FireAllClients({
			result = result, reason = reason, stats = stats,
		})
	end

	task.delay(10, function()
		BrainrotManager.ClearAll()
		DefenseManager.ClearAll()
	end)
end

-----------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------
function MatchManager.Update(dt: number)
	if matchState ~= "PLAYING" then return end
	BrainrotManager.Update(dt)
	DefenseManager.Update(dt)
	EconomyManager.Update(dt)
	WaveManager.Update(dt, BaseManager.GetBarrierHP())
end

function MatchManager.GetState() return matchState end

return MatchManager
