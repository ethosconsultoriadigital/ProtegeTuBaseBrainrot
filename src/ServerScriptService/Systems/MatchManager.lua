-- MatchManager.lua
-- Orquestador principal: conecta todos los sistemas y maneja el flujo de la partida
-- Ubicación: ServerScriptService/Systems/MatchManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.EconomyConfig)

local MatchManager = {}

-- Sistemas (se inyectan desde Main)
local BrainrotManager = nil
local DefenseManager = nil
local BaseManager = nil
local CaptureManager = nil
local EconomyManager = nil
local WaveManager = nil
local Events = nil

-- Estado de partida
local matchState = "WAITING" -- WAITING, PLAYING, VICTORY, DEFEAT
local matchStats = {
	totalKills = 0,
	totalCaptures = 0,
	wavesCompleted = 0,
	perfectWaves = 0,
	vaultValue = 0,
}

function MatchManager.Init(systems)
	BrainrotManager = systems.BrainrotManager
	DefenseManager = systems.DefenseManager
	BaseManager = systems.BaseManager
	CaptureManager = systems.CaptureManager
	EconomyManager = systems.EconomyManager
	WaveManager = systems.WaveManager
	Events = ReplicatedStorage:FindFirstChild("Events")

	-- Configurar callbacks

	-- Cuando un brainrot muere por defensa
	BrainrotManager.OnBrainrotDied(function(id, brainrotData, killedByDefense)
		if killedByDefense then
			matchStats.totalKills = matchStats.totalKills + 1
			EconomyManager.RewardKill(brainrotData)
		end
	end)

	-- Cuando un brainrot llega al final del camino
	BrainrotManager.OnBrainrotReachedEnd(function(id, brainrotData)
		BaseManager.HandleBrainrotArrival(brainrotData)
	end)

	-- Cuando el núcleo es destruido
	BaseManager.OnGameOver(function(reason)
		MatchManager._EndMatch("DEFEAT", reason)
	end)

	-- Cuando se completa una oleada
	WaveManager.OnWaveComplete(function(waveNumber, wasPerfect)
		matchStats.wavesCompleted = waveNumber
		if wasPerfect then
			matchStats.perfectWaves = matchStats.perfectWaves + 1
			EconomyManager.RewardPerfectWave()
		end
	end)

	-- Cuando se completan todas las oleadas
	WaveManager.OnAllWavesComplete(function()
		-- Esperar a que se vacíe el campo
		task.delay(3, function()
			if matchState == "PLAYING" then
				MatchManager._EndMatch("VICTORY", "all_waves_complete")
			end
		end)
	end)

	-- Conectar RemoteEvents
	MatchManager._ConnectRemotes()
end

-- Conectar eventos del cliente
function MatchManager._ConnectRemotes()
	-- Colocar defensa
	Events.RequestPlaceDefense.OnServerEvent:Connect(function(player, data)
		if matchState ~= "PLAYING" then return end
		if not data or not data.defenseType or not data.position then return end

		-- Validar costo
		local cost = DefenseManager.GetPlacementCost(data.defenseType)
		if not EconomyManager.CanAfford(player, cost) then
			-- No puede pagar — el cliente debería ya saber esto, pero validamos
			return
		end

		local success, err = DefenseManager.TryPlace(player, data.defenseType, data.position)
		if success then
			EconomyManager.SpendCells(player, cost)
		else
			warn("[MatchManager] Placement falló:", err)
		end
	end)

	-- Vender defensa
	Events.RequestSellDefense.OnServerEvent:Connect(function(player, data)
		if matchState ~= "PLAYING" then return end
		if not data or not data.defenseId then return end

		local success, refund = DefenseManager.TrySell(player, data.defenseId)
		if success then
			EconomyManager.AddCells(player, refund)
		end
	end)

	-- Reparar barrera
	Events.RequestRepairBarrier.OnServerEvent:Connect(function(player)
		if matchState ~= "PLAYING" then return end

		local cost = BaseManager.GetRepairCost()
		if not EconomyManager.CanAfford(player, cost) then return end

		local success, actualCost = BaseManager.TryRepairBarrier()
		if success then
			EconomyManager.SpendCells(player, cost)
		end
	end)

	-- Saltar timer
	Events.RequestSkipTimer.OnServerEvent:Connect(function(player)
		if matchState ~= "PLAYING" then return end
		WaveManager.SkipBuildTimer()
	end)

	-- GetGameState (RemoteFunction)
	Events.GetGameState.OnServerInvoke = function(player)
		return {
			matchState = matchState,
			wave = WaveManager.GetCurrentWave(),
			totalWaves = WaveManager.GetTotalWaves(),
			cells = EconomyManager.GetCells(player),
			barrierHP = BaseManager.GetBarrierHP(),
			barrierMaxHP = BaseManager.GetBarrierMaxHP(),
			breached = BaseManager.IsBreached(),
			vaultCount = BaseManager.GetVaultCount(),
			vaultMax = GameConfig.VAULT_MAX_SLOTS,
			vault = BaseManager.GetVault(),
		}
	end
end

-- Iniciar partida
function MatchManager.StartMatch()
	matchState = "PLAYING"
	matchStats = {
		totalKills = 0,
		totalCaptures = 0,
		wavesCompleted = 0,
		perfectWaves = 0,
		vaultValue = 0,
	}

	-- Inicializar economía de cada jugador
	for _, player in ipairs(Players:GetPlayers()) do
		EconomyManager.InitPlayer(player)
	end

	-- Manejar jugadores que entran tarde
	Players.PlayerAdded:Connect(function(player)
		if matchState == "PLAYING" then
			EconomyManager.InitPlayer(player)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		EconomyManager.CleanupPlayer(player)
	end)

	-- Iniciar oleadas
	WaveManager.Start()

	print("[MatchManager] ¡Partida iniciada!")
end

-- Terminar partida
function MatchManager._EndMatch(result: string, reason: string)
	if matchState ~= "PLAYING" then return end

	matchState = result
	WaveManager.ForceStop()

	matchStats.vaultValue = BaseManager.GetVaultTotalValue()

	print("[MatchManager] Partida terminada:", result, "-", reason)
	print("  Kills:", matchStats.totalKills)
	print("  Oleadas:", matchStats.wavesCompleted)
	print("  Perfectas:", matchStats.perfectWaves)
	print("  Valor bóveda:", matchStats.vaultValue)

	-- Notificar clientes
	if Events then
		Events.GameOver:FireAllClients({
			result = result,
			reason = reason,
			stats = matchStats,
		})
	end

	-- Cleanup después de mostrar resultados
	task.delay(10, function()
		BrainrotManager.ClearAll()
		DefenseManager.ClearAll()
	end)
end

-- Update loop principal
function MatchManager.Update(dt: number)
	if matchState ~= "PLAYING" then return end

	-- Update sistemas
	BrainrotManager.Update(dt)
	DefenseManager.Update(dt)
	EconomyManager.Update(dt)
	WaveManager.Update(dt, BaseManager.GetBarrierHP())
end

-- Getters
function MatchManager.GetState(): string return matchState end
function MatchManager.GetStats() return matchStats end

return MatchManager
