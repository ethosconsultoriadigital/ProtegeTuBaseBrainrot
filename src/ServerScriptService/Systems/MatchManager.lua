-- MatchManager
-- Orquestador principal: conecta todos los managers, RemoteEvents, win/lose
-- Ubicación: ServerScriptService > Systems > MatchManager (ModuleScript)
--
-- Responsabilidades:
--   - Iniciar partida cuando entra un jugador
--   - Conectar callbacks entre managers (wiring)
--   - Manejar condiciones de victoria/derrota
--   - Conectar RemoteEvents del cliente
--   - Llamar Update() de todos los subsistemas cada frame
--
-- Sistemas esta tanda: BrainrotManager, WaveManager, BaseManager,
--                       EconomyManager, CaptureManager
-- Hooks preparados para: DefenseManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig    = require(ReplicatedStorage.Modules.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.EconomyConfig)

local MatchManager = {}

-----------------------------------------------------------------------
-- DEPENDENCIAS (inyectadas en Init)
-----------------------------------------------------------------------
local BrainrotManager = nil
local WaveManager     = nil
local BaseManager     = nil
local EconomyManager  = nil
local CaptureManager  = nil
-- FUTURO: DefenseManager
local Events = nil

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local matchState = "WAITING"  -- WAITING | PLAYING | VICTORY | DEFEAT
local stats = {
	totalKills     = 0,
	totalEscaped   = 0,
	totalCaptures  = 0,
	wavesCompleted = 0,
	perfectWaves   = 0,
	vaultValue     = 0,
}

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function MatchManager.Init(sys)
	BrainrotManager = sys.BrainrotManager
	WaveManager     = sys.WaveManager
	BaseManager     = sys.BaseManager
	EconomyManager  = sys.EconomyManager
	CaptureManager  = sys.CaptureManager
	-- FUTURO: sys.DefenseManager
	Events = ReplicatedStorage:FindFirstChild("Events")

	-------------------------------------------------------------------
	-- WIRING: brainrot muerto por daño
	-------------------------------------------------------------------
	BrainrotManager.OnBrainrotDied(function(_id, brData, killedByDamage)
		if not killedByDamage then return end
		stats.totalKills += 1

		-- Recompensa económica por kill
		EconomyManager.RewardKill(brData)

		-- Auto-captura (probabilidad base de la rareza)
		-- Se reemplazará por CaptureModule cuando exista DefenseManager
		local captured = CaptureManager.TryAutoCapture(brData)
		if captured then
			stats.totalCaptures += 1
		end
	end)

	-------------------------------------------------------------------
	-- WIRING: brainrot llego al final del camino → BaseManager
	-------------------------------------------------------------------
	BrainrotManager.OnBrainrotReachedEnd(function(_id, brData)
		stats.totalEscaped += 1
		BaseManager.HandleBrainrotArrival(brData)
	end)

	-------------------------------------------------------------------
	-- WIRING: game over por destrucción del núcleo
	-------------------------------------------------------------------
	BaseManager.OnGameOver(function(reason)
		MatchManager._End("DEFEAT", reason)
	end)

	-------------------------------------------------------------------
	-- WIRING: brainrot robado de la bóveda
	-------------------------------------------------------------------
	BaseManager.OnBrainrotStolen(function(stolen)
		print("[Match] Robo en bóveda: " .. stolen.className .. " " .. stolen.rarityName
			.. " (valor: " .. stolen.vaultValue .. ")")
	end)

	-------------------------------------------------------------------
	-- WIRING: oleada completada
	-------------------------------------------------------------------
	WaveManager.OnWaveComplete(function(waveNum, perfect)
		stats.wavesCompleted = waveNum

		-- Bonus por completar oleada
		EconomyManager.RewardWaveClear()

		if perfect then
			stats.perfectWaves += 1
			EconomyManager.RewardPerfectWave()
			print("[Match] Oleada " .. waveNum .. " PERFECTA! (+$"
				.. EconomyConfig.PERFECT_WAVE_BONUS + EconomyConfig.WAVE_CLEAR_BONUS .. ")")
		else
			print("[Match] Oleada " .. waveNum .. " completada (+$"
				.. EconomyConfig.WAVE_CLEAR_BONUS .. ")")
		end
	end)

	-------------------------------------------------------------------
	-- WIRING: todas las oleadas completadas → victoria
	-------------------------------------------------------------------
	WaveManager.OnAllWavesComplete(function()
		task.delay(3, function()
			if matchState == "PLAYING" then
				MatchManager._End("VICTORY", "all_waves_complete")
			end
		end)
	end)

	MatchManager._ConnectRemotes()
	print("[MatchManager] Init OK — todos los sistemas conectados")
end

-----------------------------------------------------------------------
-- REMOTE EVENTS
-----------------------------------------------------------------------
function MatchManager._ConnectRemotes()
	if not Events then return end

	-- Skip build timer
	Events.RequestSkipTimer.OnServerEvent:Connect(function(_player)
		if matchState ~= "PLAYING" then return end
		WaveManager.SkipBuildTimer()
	end)

	-- Repair barrier
	Events.RequestRepairBarrier.OnServerEvent:Connect(function(player)
		if matchState ~= "PLAYING" then return end
		local cost = BaseManager.GetRepairCost()
		if not EconomyManager.CanAfford(player, cost) then return end
		local ok, _actualCost = BaseManager.TryRepairBarrier()
		if ok then
			EconomyManager.SpendCells(player, cost)
		end
	end)

	-- FUTURO: RequestPlaceDefense, RequestSellDefense
	-- Se conectarán cuando exista DefenseManager

	-- GetGameState (RemoteFunction)
	Events.GetGameState.OnServerInvoke = function(player)
		return {
			matchState = matchState,
			wave       = WaveManager.GetCurrentWave(),
			waveState  = WaveManager.GetState(),
			totalWaves = GameConfig.TOTAL_WAVES,
			buildTimer = WaveManager.GetBuildTimer(),
			barrierHP  = BaseManager.GetBarrierHP(),
			barrierMax = BaseManager.GetBarrierMaxHP(),
			breached   = BaseManager.IsBreached(),
			coreHP     = BaseManager.GetCoreHP(),
			coreMax    = BaseManager.GetCoreMaxHP(),
			cells      = EconomyManager.GetCells(player),
			vaultCount = BaseManager.GetVaultCount(),
			vaultMax   = GameConfig.VAULT_MAX_SLOTS,
			vault      = BaseManager.GetVault(),
			stats      = stats,
		}
	end
end

-----------------------------------------------------------------------
-- START
-----------------------------------------------------------------------
function MatchManager.StartMatch()
	if matchState == "PLAYING" then return end

	matchState = "PLAYING"
	stats = {
		totalKills = 0, totalEscaped = 0, totalCaptures = 0,
		wavesCompleted = 0, perfectWaves = 0, vaultValue = 0,
	}

	-- Inicializar economía de cada jugador
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.InitPlayer(p)
	end

	-- Limpiar jugadores que se van
	Players.PlayerRemoving:Connect(function(player)
		EconomyManager.CleanupPlayer(player)
	end)

	print("[Match] === PARTIDA INICIADA ===")
	print("[Match] Barrera: " .. BaseManager.GetBarrierHP() .. "/" .. BaseManager.GetBarrierMaxHP())
	print("[Match] Core: " .. BaseManager.GetCoreHP() .. "/" .. BaseManager.GetCoreMaxHP())
	print("[Match] Cells: " .. GameConfig.STARTING_CELLS)
	print("[Match] Oleadas: " .. GameConfig.TOTAL_WAVES)
	print("[Match] Bóveda: " .. BaseManager.GetVaultCount() .. "/" .. GameConfig.VAULT_MAX_SLOTS)

	WaveManager.Start()
end

-----------------------------------------------------------------------
-- END
-----------------------------------------------------------------------
function MatchManager._End(result: string, reason: string)
	if matchState ~= "PLAYING" then return end
	matchState = result

	WaveManager.ForceStop()
	stats.vaultValue = BaseManager.GetVaultTotalValue()

	print("")
	print("[Match] ========================================")
	print("[Match] " .. result .. " — " .. reason)
	print("[Match] ----------------------------------------")
	print("[Match] Kills:      " .. stats.totalKills)
	print("[Match] Capturas:   " .. stats.totalCaptures)
	print("[Match] Escaparon:  " .. stats.totalEscaped)
	print("[Match] Oleadas:    " .. stats.wavesCompleted .. "/" .. GameConfig.TOTAL_WAVES)
	print("[Match] Perfectas:  " .. stats.perfectWaves)
	print("[Match] Barrera:    " .. BaseManager.GetBarrierHP() .. "/" .. BaseManager.GetBarrierMaxHP())
	print("[Match] Core:       " .. BaseManager.GetCoreHP() .. "/" .. BaseManager.GetCoreMaxHP())
	print("[Match] Bóveda:     " .. BaseManager.GetVaultCount() .. " capturas (valor: " .. stats.vaultValue .. ")")
	print("[Match] ========================================")
	print("")

	if Events then
		Events.GameOver:FireAllClients({
			result = result,
			reason = reason,
			stats  = stats,
		})
	end

	-- Cleanup después de un delay
	task.delay(10, function()
		BrainrotManager.ClearAll()
		-- FUTURO: DefenseManager.ClearAll()
	end)
end

-----------------------------------------------------------------------
-- UPDATE (llamar cada frame desde Heartbeat)
-----------------------------------------------------------------------
function MatchManager.Update(dt: number)
	if matchState ~= "PLAYING" then return end

	BrainrotManager.Update(dt)
	-- FUTURO: DefenseManager.Update(dt)
	EconomyManager.Update(dt)
	WaveManager.Update(dt, BaseManager.GetBarrierHP())
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function MatchManager.GetState(): string
	return matchState
end

function MatchManager.GetStats()
	return stats
end

return MatchManager
