-- WaveManager.lua
-- State machine de oleadas: BUILD -> SPAWN -> COMBAT -> COMPLETE
-- Ubicación: ServerScriptService/Systems/WaveManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local WaveConfig = require(ReplicatedStorage.Modules.WaveConfig)

local WaveManager = {}

-- Dependencias (inyectadas en Init)
local BrainrotManager = nil
local Events = nil

-- Estado
local currentWave = 0
local state = "IDLE"  -- IDLE, BUILD, SPAWNING, COMBAT, WAVE_COMPLETE, FINISHED
local buildTimer = 0
local spawnQueue: {any} = {}
local spawnTimer = 0
local spawnInterval = 1.4
local totalSpawned = 0
local waveBarrierHP = 0  -- HP de barrera al inicio de oleada (para detectar perfecta)

-- Callbacks
local onWaveComplete = nil      -- function(waveNumber, wasPerfect)
local onAllWavesComplete = nil  -- function()
local onBuildPhaseStart = nil   -- function(waveNumber, duration)

function WaveManager.Init(brainrotMgr)
	BrainrotManager = brainrotMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
end

function WaveManager.OnWaveComplete(callback) onWaveComplete = callback end
function WaveManager.OnAllWavesComplete(callback) onAllWavesComplete = callback end
function WaveManager.OnBuildPhaseStart(callback) onBuildPhaseStart = callback end

-- Iniciar primera oleada (o reiniciar)
function WaveManager.Start()
	currentWave = 0
	state = "IDLE"
	WaveManager._NextWave()
end

-- Saltar timer de build phase
function WaveManager.SkipBuildTimer()
	if state == "BUILD" then
		buildTimer = 0
	end
end

-- Avanzar a la siguiente oleada
function WaveManager._NextWave()
	currentWave = currentWave + 1

	if currentWave > #WaveConfig.Waves then
		state = "FINISHED"
		if onAllWavesComplete then
			onAllWavesComplete()
		end
		return
	end

	-- Build phase
	state = "BUILD"
	buildTimer = GameConfig.BUILD_PHASE_DURATION

	print("[WaveManager] Fase de construcción — Oleada " .. currentWave .. " en " .. buildTimer .. "s")

	if onBuildPhaseStart then
		onBuildPhaseStart(currentWave, buildTimer)
	end

	if Events then
		Events.WaveStarted:FireAllClients({
			waveNumber = currentWave,
			totalWaves = #WaveConfig.Waves,
			waveName = WaveConfig.GetWaveName(currentWave),
			isBoss = WaveConfig.IsBossWave(currentWave),
			buildDuration = buildTimer,
			phase = "BUILD",
		})
	end
end

-- Comenzar spawning
function WaveManager._StartSpawning()
	state = "SPAWNING"
	spawnQueue = WaveConfig.GetSpawnList(currentWave) or {}
	spawnInterval = WaveConfig.GetSpawnInterval(currentWave)
	spawnTimer = 0
	totalSpawned = 0

	print("[WaveManager] Spawning oleada " .. currentWave .. " — " .. #spawnQueue .. " brainrots")

	if Events then
		Events.WaveStarted:FireAllClients({
			waveNumber = currentWave,
			totalWaves = #WaveConfig.Waves,
			waveName = WaveConfig.GetWaveName(currentWave),
			isBoss = WaveConfig.IsBossWave(currentWave),
			phase = "COMBAT",
		})
	end
end

-- Update principal (llamado desde Heartbeat)
function WaveManager.Update(dt: number, currentBarrierHP: number)
	if state == "BUILD" then
		buildTimer = buildTimer - dt
		if buildTimer <= 0 then
			waveBarrierHP = currentBarrierHP
			WaveManager._StartSpawning()
		end

	elseif state == "SPAWNING" then
		spawnTimer = spawnTimer - dt
		if spawnTimer <= 0 and #spawnQueue > 0 then
			local spawnData = table.remove(spawnQueue, 1)
			BrainrotManager.Spawn(
				spawnData.class,
				spawnData.rarity,
				spawnData.hpOverride,
				spawnData.isBoss
			)
			totalSpawned = totalSpawned + 1
			spawnTimer = spawnInterval
		end

		-- Si terminó de spawnear, cambiar a COMBAT
		if #spawnQueue == 0 then
			state = "COMBAT"
		end

	elseif state == "COMBAT" then
		-- Checar si todos los brainrots fueron eliminados
		if BrainrotManager.GetActiveCount() == 0 then
			WaveManager._OnWaveCleared(currentBarrierHP)
		end
	end
end

-- Oleada completada
function WaveManager._OnWaveCleared(currentBarrierHP: number)
	state = "WAVE_COMPLETE"

	local wasPerfect = currentBarrierHP >= waveBarrierHP
	print("[WaveManager] Oleada " .. currentWave .. " completada" .. (wasPerfect and " (PERFECTA!)" or ""))

	if Events then
		Events.WaveEnded:FireAllClients({
			waveNumber = currentWave,
			totalWaves = #WaveConfig.Waves,
			wasPerfect = wasPerfect,
		})
	end

	if onWaveComplete then
		onWaveComplete(currentWave, wasPerfect)
	end

	-- Delay breve antes de siguiente oleada
	task.delay(2.5, function()
		if state == "WAVE_COMPLETE" then
			WaveManager._NextWave()
		end
	end)
end

-- Getters
function WaveManager.GetCurrentWave(): number return currentWave end
function WaveManager.GetState(): string return state end
function WaveManager.GetBuildTimer(): number return buildTimer end
function WaveManager.GetTotalWaves(): number return #WaveConfig.Waves end

-- Forzar fin (para game over)
function WaveManager.ForceStop()
	state = "FINISHED"
end

return WaveManager
