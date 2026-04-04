-- MatchManager
-- Orquestador principal: conecta BrainrotManager + WaveManager, win/lose, remotes
-- Ubicación: ServerScriptService > Systems > MatchManager (ModuleScript)
--
-- Responsabilidades:
--   - Iniciar partida cuando entra un jugador
--   - Conectar callbacks entre managers
--   - Manejar condicion basica de victoria/derrota
--   - Conectar RemoteEvents del cliente
--   - Llamar Update() de todos los subsistemas cada frame
--
-- Sistemas disponibles esta tanda: BrainrotManager, WaveManager
-- Hooks preparados para: BaseManager, DefenseManager, EconomyManager, CaptureManager
--
-- NOTA: sin BaseManager, la condicion de derrota es "un brainrot llega al final".
-- Con BaseManager se cambiara a "core destruido".

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig    = require(ReplicatedStorage.Modules.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.EconomyConfig)

local MatchManager = {}

-----------------------------------------------------------------------
-- DEPENDENCIAS (inyectadas)
-----------------------------------------------------------------------
local BrainrotManager = nil
local WaveManager     = nil
-- FUTURO: DefenseManager, BaseManager, CaptureManager, EconomyManager
local Events = nil

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local matchState = "WAITING"  -- WAITING | PLAYING | VICTORY | DEFEAT
local barrierHP = 9999        -- placeholder hasta que exista BaseManager
local stats = {
	totalKills     = 0,
	totalEscaped   = 0,
	wavesCompleted = 0,
	perfectWaves   = 0,
}

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function MatchManager.Init(sys: {BrainrotManager: any, WaveManager: any})
	BrainrotManager = sys.BrainrotManager
	WaveManager     = sys.WaveManager
	-- FUTURO: sys.DefenseManager, sys.BaseManager, etc.
	Events = ReplicatedStorage:FindFirstChild("Events")

	-------------------------------------------------------------------
	-- CALLBACK: brainrot muerto por daño
	-------------------------------------------------------------------
	BrainrotManager.OnBrainrotDied(function(_id, brData, killedByDamage)
		if killedByDamage then
			stats.totalKills += 1
			-- FUTURO: EconomyManager.RewardKill(brData)
			print("[Match] Kill: " .. brData.className .. " " .. brData.rarityName
				.. " (+$" .. brData.killReward .. ")")
		end
	end)

	-------------------------------------------------------------------
	-- CALLBACK: brainrot llego al final del camino
	-------------------------------------------------------------------
	BrainrotManager.OnBrainrotReachedEnd(function(_id, brData)
		stats.totalEscaped += 1
		-- FUTURO: BaseManager.HandleBrainrotArrival(brData)
		-- Por ahora, simular dano a la barrera
		barrierHP -= brData.barrierDamage
		print("[Match] Brainrot llego al final! " .. brData.className .. " " .. brData.rarityName
			.. " — Barrera: " .. barrierHP)

		if barrierHP <= 0 and matchState == "PLAYING" then
			MatchManager._End("DEFEAT", "barrier_destroyed")
		end
	end)

	-------------------------------------------------------------------
	-- CALLBACK: oleada completada
	-------------------------------------------------------------------
	WaveManager.OnWaveComplete(function(waveNum, perfect)
		stats.wavesCompleted = waveNum
		if perfect then
			stats.perfectWaves += 1
			print("[Match] Oleada " .. waveNum .. " PERFECTA! (+$" .. EconomyConfig.PERFECT_WAVE_BONUS .. ")")
			-- FUTURO: EconomyManager.RewardPerfectWave()
		end
		-- FUTURO: EconomyManager.RewardWaveClear()
	end)

	-------------------------------------------------------------------
	-- CALLBACK: todas las oleadas completadas
	-------------------------------------------------------------------
	WaveManager.OnAllWavesComplete(function()
		task.delay(3, function()
			if matchState == "PLAYING" then
				MatchManager._End("VICTORY", "all_waves_complete")
			end
		end)
	end)

	MatchManager._ConnectRemotes()
	print("[MatchManager] Init OK")
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

	-- FUTURO: RequestPlaceDefense, RequestSellDefense, RequestRepairBarrier
	-- Se conectaran cuando existan DefenseManager y BaseManager

	-- GetGameState
	Events.GetGameState.OnServerInvoke = function(_player)
		return {
			matchState = matchState,
			wave       = WaveManager.GetCurrentWave(),
			waveState  = WaveManager.GetState(),
			totalWaves = GameConfig.TOTAL_WAVES,
			buildTimer = WaveManager.GetBuildTimer(),
			barrierHP  = barrierHP,
			barrierMax = GameConfig.BARRIER_MAX_HP,
			stats      = stats,
			-- FUTURO: cells, vaultCount, vaultMax, breached, defenses
		}
	end
end

-----------------------------------------------------------------------
-- START
-----------------------------------------------------------------------
function MatchManager.StartMatch()
	if matchState == "PLAYING" then return end

	matchState = "PLAYING"
	barrierHP = GameConfig.BARRIER_MAX_HP
	stats = {
		totalKills = 0, totalEscaped = 0,
		wavesCompleted = 0, perfectWaves = 0,
	}

	print("[Match] === PARTIDA INICIADA ===")
	print("[Match] Barrera: " .. barrierHP .. " HP")
	print("[Match] Oleadas: " .. GameConfig.TOTAL_WAVES)

	WaveManager.Start()
end

-----------------------------------------------------------------------
-- END
-----------------------------------------------------------------------
function MatchManager._End(result: string, reason: string)
	if matchState ~= "PLAYING" then return end
	matchState = result

	WaveManager.ForceStop()

	print("")
	print("[Match] ============================")
	print("[Match] " .. result .. " — " .. reason)
	print("[Match] Kills: " .. stats.totalKills)
	print("[Match] Escaparon: " .. stats.totalEscaped)
	print("[Match] Oleadas: " .. stats.wavesCompleted .. "/" .. GameConfig.TOTAL_WAVES)
	print("[Match] Perfectas: " .. stats.perfectWaves)
	print("[Match] Barrera final: " .. math.max(0, barrierHP))
	print("[Match] ============================")
	print("")

	if Events then
		Events.GameOver:FireAllClients({
			result = result,
			reason = reason,
			stats  = stats,
		})
	end

	-- Cleanup despues de un delay
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
	-- FUTURO: EconomyManager.Update(dt)
	WaveManager.Update(dt, barrierHP)
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function MatchManager.GetState(): string
	return matchState
end

function MatchManager.GetBarrierHP(): number
	return barrierHP
end

function MatchManager.GetStats()
	return stats
end

return MatchManager
