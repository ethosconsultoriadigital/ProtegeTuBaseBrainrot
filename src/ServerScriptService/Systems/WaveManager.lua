-- WaveManager
-- State machine: BUILD -> SPAWN -> COMBAT -> COMPLETE -> (next wave)
-- Ubicación: ServerScriptService > Systems > WaveManager (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local WaveConfig = require(ReplicatedStorage.Modules.WaveConfig)

local WaveManager = {}

local BrainrotManager = nil
local Events = nil

-- State
local currentWave  = 0
local state        = "IDLE" -- IDLE, BUILD, SPAWNING, COMBAT, WAVE_COMPLETE, FINISHED
local buildTimer   = 0
local spawnQueue   = {}
local spawnTimer   = 0
local spawnInterval = 1.4
local waveBarrierHP = 0

-- Callbacks
local onWaveComplete     = nil
local onAllWavesComplete = nil
local onBuildPhaseStart  = nil

function WaveManager.Init(brMgr)
	BrainrotManager = brMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
end

function WaveManager.OnWaveComplete(cb) onWaveComplete = cb end
function WaveManager.OnAllWavesComplete(cb) onAllWavesComplete = cb end
function WaveManager.OnBuildPhaseStart(cb) onBuildPhaseStart = cb end

function WaveManager.Start()
	currentWave = 0
	state = "IDLE"
	WaveManager._NextWave()
end

function WaveManager.SkipBuildTimer()
	if state == "BUILD" then buildTimer = 0 end
end

function WaveManager._NextWave()
	currentWave += 1
	local total = WaveConfig.GetTotalWaves()

	if currentWave > total then
		state = "FINISHED"
		if onAllWavesComplete then onAllWavesComplete() end
		return
	end

	state = "BUILD"
	buildTimer = GameConfig.BUILD_PHASE_DURATION

	print("[Wave] Build phase - Oleada " .. currentWave)
	if onBuildPhaseStart then onBuildPhaseStart(currentWave, buildTimer) end

	if Events then
		Events.WaveStarted:FireAllClients({
			waveNumber = currentWave,
			totalWaves = total,
			waveName = WaveConfig.GetWaveName(currentWave),
			isBoss = WaveConfig.IsBossWave(currentWave),
			buildDuration = buildTimer,
			phase = "BUILD",
		})
	end
end

function WaveManager._StartSpawning()
	state = "SPAWNING"
	spawnQueue = WaveConfig.GetSpawnList(currentWave) or {}
	spawnInterval = WaveConfig.GetSpawnInterval(currentWave)
	spawnTimer = 0

	print("[Wave] Spawning oleada " .. currentWave .. " (" .. #spawnQueue .. " brainrots)")
	if Events then
		Events.WaveStarted:FireAllClients({
			waveNumber = currentWave,
			totalWaves = WaveConfig.GetTotalWaves(),
			waveName = WaveConfig.GetWaveName(currentWave),
			isBoss = WaveConfig.IsBossWave(currentWave),
			phase = "COMBAT",
		})
	end
end

function WaveManager.Update(dt: number, currentBarrierHP: number)
	if state == "BUILD" then
		buildTimer -= dt
		if buildTimer <= 0 then
			waveBarrierHP = currentBarrierHP
			WaveManager._StartSpawning()
		end

	elseif state == "SPAWNING" then
		spawnTimer -= dt
		if spawnTimer <= 0 and #spawnQueue > 0 then
			local s = table.remove(spawnQueue, 1)
			BrainrotManager.Spawn(s.class, s.rarity, s.hpOverride, s.isBoss)
			spawnTimer = spawnInterval
		end
		if #spawnQueue == 0 then state = "COMBAT" end

	elseif state == "COMBAT" then
		if BrainrotManager.GetActiveCount() == 0 then
			WaveManager._WaveCleared(currentBarrierHP)
		end
	end
end

function WaveManager._WaveCleared(currentBarrierHP: number)
	state = "WAVE_COMPLETE"
	local perfect = currentBarrierHP >= waveBarrierHP

	print("[Wave] Oleada " .. currentWave .. " completada" .. (perfect and " PERFECTA!" or ""))
	if Events then
		Events.WaveEnded:FireAllClients({
			waveNumber = currentWave,
			totalWaves = WaveConfig.GetTotalWaves(),
			wasPerfect = perfect,
		})
	end
	if onWaveComplete then onWaveComplete(currentWave, perfect) end

	task.delay(2.5, function()
		if state == "WAVE_COMPLETE" then WaveManager._NextWave() end
	end)
end

-- Getters
function WaveManager.GetCurrentWave() return currentWave end
function WaveManager.GetState() return state end
function WaveManager.GetBuildTimer() return buildTimer end
function WaveManager.ForceStop() state = "FINISHED" end

return WaveManager
