-- WaveManager
-- Maquina de estados de oleadas: BUILD → SPAWNING → COMBAT → WAVE_COMPLETE → (next)
-- Ubicación: ServerScriptService > Systems > WaveManager (ModuleScript)
--
-- Responsabilidades:
--   - Controlar fases build/combat
--   - Expandir WaveConfig en spawn queue
--   - Delegar spawn a BrainrotManager
--   - Detectar cuando la oleada se limpio
--   - Callbacks para MatchManager
--
-- NO maneja: economia, barrera, UI. Solo flujo de oleadas.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig  = require(ReplicatedStorage.Modules.GameConfig)
local WaveConfig  = require(ReplicatedStorage.Modules.WaveConfig)

local WaveManager = {}

-----------------------------------------------------------------------
-- DEPENDENCIAS (inyectadas en Init)
-----------------------------------------------------------------------
local BrainrotManager = nil
local Events = nil

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local currentWave   = 0
local state         = "IDLE"  -- IDLE | BUILD | SPAWNING | COMBAT | WAVE_COMPLETE | FINISHED
local buildTimer    = 0
local clearDelayTimer = 0
local spawnQueue: {any} = {}
local spawnTimer    = 0
local spawnInterval = 1.4
local totalSpawned  = 0       -- cuantos se spawnearon en la oleada actual

-- Para detectar perfect wave (barrera no recibio dano)
local waveStartBarrierHP = 0

-----------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------
local onWaveCompleteCallbacks: {(waveNum: number, perfect: boolean) -> ()} = {}
local onAllWavesCompleteCallbacks: {() -> ()} = {}
local onBuildPhaseCallbacks: {(waveNum: number, duration: number) -> ()} = {}

function WaveManager.OnWaveComplete(cb)
	table.insert(onWaveCompleteCallbacks, cb)
end

function WaveManager.OnAllWavesComplete(cb)
	table.insert(onAllWavesCompleteCallbacks, cb)
end

function WaveManager.OnBuildPhaseStart(cb)
	table.insert(onBuildPhaseCallbacks, cb)
end

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function WaveManager.Init(brMgr)
	BrainrotManager = brMgr
	if not BrainrotManager then
		warn("[WaveManager] BrainrotManager nil — Spawn fallara")
	end
	Events = ReplicatedStorage:FindFirstChild("Events")
	if not Events then
		warn("[WaveManager] ReplicatedStorage.Events no encontrado — sin notificacion de oleadas al cliente")
	end
	print("[WaveManager] Init OK")
end

-----------------------------------------------------------------------
-- START / SKIP
-----------------------------------------------------------------------
function WaveManager.Start()
	currentWave = 0
	state = "IDLE"
	WaveManager._NextWave()
end

function WaveManager.SkipBuildTimer()
	if state == "BUILD" then
		buildTimer = 0
	end
end

-----------------------------------------------------------------------
-- WAVE TRANSITIONS
-----------------------------------------------------------------------
function WaveManager._NextWave()
	currentWave += 1
	local total = WaveConfig.GetTotalWaves()

	if currentWave > total then
		state = "FINISHED"
		print("[Wave] Todas las oleadas completadas!")
		for _, cb in ipairs(onAllWavesCompleteCallbacks) do cb() end
		return
	end

	state = "BUILD"
	buildTimer = GameConfig.BUILD_PHASE_DURATION

	local waveName = WaveConfig.GetWaveName(currentWave)
	local isBoss = WaveConfig.IsBossWave(currentWave)

	print("[Wave] Build phase — Oleada " .. currentWave .. "/" .. total .. ": " .. waveName)

	for _, cb in ipairs(onBuildPhaseCallbacks) do cb(currentWave, buildTimer) end

	if Events then
		Events.WaveStarted:FireAllClients({
			waveNumber = currentWave,
			totalWaves = total,
			waveName = waveName,
			isBoss = isBoss,
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
	totalSpawned = 0

	local total = WaveConfig.GetTotalWaves()
	print("[Wave] Spawning oleada " .. currentWave .. " — " .. #spawnQueue .. " brainrots")

	if Events then
		Events.WaveStarted:FireAllClients({
			waveNumber = currentWave,
			totalWaves = total,
			waveName = WaveConfig.GetWaveName(currentWave),
			isBoss = WaveConfig.IsBossWave(currentWave),
			phase = "COMBAT",
		})
	end
end

function WaveManager._WaveCleared(currentBarrierHP: number)
	state = "WAVE_COMPLETE"
	local perfect = currentBarrierHP >= waveStartBarrierHP

	print("[Wave] Oleada " .. currentWave .. " completada" .. (perfect and " — PERFECTA!" or ""))

	if Events then
		Events.WaveEnded:FireAllClients({
			waveNumber = currentWave,
			totalWaves = WaveConfig.GetTotalWaves(),
			wasPerfect = perfect,
		})
	end

	for _, cb in ipairs(onWaveCompleteCallbacks) do cb(currentWave, perfect) end

	-- Delay antes de la siguiente oleada
	clearDelayTimer = GameConfig.WAVE_CLEAR_DELAY
end

-----------------------------------------------------------------------
-- UPDATE (llamar cada frame)
-- currentBarrierHP: se pasa desde MatchManager para detectar perfect wave
-- Si no hay BaseManager aun, pasar un valor alto (ej. 9999)
-----------------------------------------------------------------------
function WaveManager.Update(dt: number, currentBarrierHP: number)
	if state == "IDLE" or state == "FINISHED" then return end

	if state == "BUILD" then
		buildTimer -= dt
		if buildTimer <= 0 then
			waveStartBarrierHP = currentBarrierHP
			WaveManager._StartSpawning()
		end

	elseif state == "SPAWNING" then
		spawnTimer -= dt
		if spawnTimer <= 0 and #spawnQueue > 0 then
			local s = table.remove(spawnQueue, 1)
			BrainrotManager.Spawn(s.class, s.rarity, s.hpOverride, s.isBoss)
			totalSpawned += 1
			spawnTimer = spawnInterval
		end
		-- Cuando la queue se vacia, pasar a combat
		if #spawnQueue == 0 then
			state = "COMBAT"
		end

	elseif state == "COMBAT" then
		if BrainrotManager.GetActiveCount() == 0 then
			WaveManager._WaveCleared(currentBarrierHP)
		end

	elseif state == "WAVE_COMPLETE" then
		clearDelayTimer -= dt
		if clearDelayTimer <= 0 then
			WaveManager._NextWave()
		end
	end
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function WaveManager.GetCurrentWave(): number
	return currentWave
end

function WaveManager.GetState(): string
	return state
end

function WaveManager.GetBuildTimer(): number
	return math.max(0, buildTimer)
end

function WaveManager.GetTotalSpawnedThisWave(): number
	return totalSpawned
end

function WaveManager.ForceStop()
	state = "FINISHED"
end

return WaveManager
