-- Main.server.lua
-- Bootstrap del servidor: crea remotes, asegura folders, prepara para managers
-- Ubicación: ServerScriptService > Main (Script)
--
-- Esta es la primera capa. Solo hace:
--   1. Crear folder de Events con todos los RemoteEvents/RemoteFunctions
--   2. Asegurar que existan folders de runtime en Workspace
--   3. Dejar stubs claros para donde se conectaran los managers
--
-- Los managers (WaveManager, BrainrotManager, etc.) se agregan en tandas posteriores.
-- Este archivo se ira extendiendo a medida que se agreguen sistemas.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== PROTEGE TU BASE: BRAINROT SIEGE ===")
print("[Main] Inicializando servidor...")

-----------------------------------------------------------------------
-- UTILIDAD
-----------------------------------------------------------------------
local function EnsureFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

-----------------------------------------------------------------------
-- 1. ESTRUCTURA DE FOLDERS EN REPLICATEDSTORAGE
-----------------------------------------------------------------------
EnsureFolder(ReplicatedStorage, "Modules")

local eventsFolder = EnsureFolder(ReplicatedStorage, "Events")

-----------------------------------------------------------------------
-- 2. REMOTE EVENTS
-- Organizados por direccion y proposito.
-- Server→Client: notificaciones de estado
-- Client→Server: requests del jugador
-----------------------------------------------------------------------

-- Server → Client (notificaciones)
local serverToClientEvents = {
	"WaveStarted",       -- {waveNumber, totalWaves, waveName, isBoss, phase, buildDuration}
	"WaveEnded",         -- {waveNumber, totalWaves, wasPerfect}
	"BrainrotSpawned",   -- {id, class, rarity, isBoss}
	"BrainrotDied",      -- {id}
	"BrainrotCaptured",  -- {id, className, rarity, vaultValue, vaultCount, vaultMax}
	"BarrierUpdate",     -- {currentHP, maxHP, percentage}
	"BreachStarted",     -- {}
	"BreachEnded",       -- {}
	"BrainrotStolen",    -- {className, rarity, vaultValue, remainingInVault}
	"CellsUpdate",       -- {cells}
	"GameOver",          -- {result, reason, stats}
	"DefensePlaced",     -- {id, defenseType, position, level}
}

-- Client → Server (requests)
local clientToServerEvents = {
	"RequestPlaceDefense",   -- {defenseType, position}
	"RequestSellDefense",    -- {defenseId}
	"RequestRepairBarrier",  -- {}
	"RequestSkipTimer",      -- {}
}

for _, name in ipairs(serverToClientEvents) do
	if not eventsFolder:FindFirstChild(name) then
		local e = Instance.new("RemoteEvent")
		e.Name = name
		e.Parent = eventsFolder
	end
end

for _, name in ipairs(clientToServerEvents) do
	if not eventsFolder:FindFirstChild(name) then
		local e = Instance.new("RemoteEvent")
		e.Name = name
		e.Parent = eventsFolder
	end
end

-- RemoteFunctions (client pide, server responde)
if not eventsFolder:FindFirstChild("GetGameState") then
	local f = Instance.new("RemoteFunction")
	f.Name = "GetGameState"
	f.Parent = eventsFolder
end

print("[Main] " .. #eventsFolder:GetChildren() .. " remotes creados en ReplicatedStorage.Events")

-----------------------------------------------------------------------
-- 3. FOLDERS DE RUNTIME EN WORKSPACE
-- Los managers usaran estos folders para instanciar entidades.
-----------------------------------------------------------------------
EnsureFolder(workspace, "ActiveBrainrots")
EnsureFolder(workspace, "ActiveDefenses")

print("[Main] Folders de runtime verificados")

-----------------------------------------------------------------------
-- 4. MANAGERS
-- Cargar e inicializar sistemas en orden de dependencia.
-- Tanda 3: BrainrotManager, WaveManager, MatchManager
-- Tanda 4: BaseManager, EconomyManager, CaptureManager
-- Tanda 5: DefenseManager
-----------------------------------------------------------------------
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")

local Systems = script.Parent.Systems

local BrainrotManager = require(Systems.BrainrotManager)
local WaveManager     = require(Systems.WaveManager)
local BaseManager     = require(Systems.BaseManager)
local EconomyManager  = require(Systems.EconomyManager)
local CaptureManager  = require(Systems.CaptureManager)
local DefenseManager  = require(Systems.DefenseManager)
local MatchManager    = require(Systems.MatchManager)

-- Init en orden de dependencia
BrainrotManager.Init()
BaseManager.Init()
EconomyManager.Init(BaseManager)
CaptureManager.Init(BrainrotManager, BaseManager, EconomyManager)
DefenseManager.Init(BrainrotManager, CaptureManager)
WaveManager.Init(BrainrotManager)
MatchManager.Init({
	BrainrotManager = BrainrotManager,
	WaveManager     = WaveManager,
	BaseManager     = BaseManager,
	EconomyManager  = EconomyManager,
	CaptureManager  = CaptureManager,
	DefenseManager  = DefenseManager,
})

print("[Main] Managers inicializados")

-----------------------------------------------------------------------
-- 5. GAME LOOP
-----------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	MatchManager.Update(dt)
end)

-----------------------------------------------------------------------
-- 6. AUTO-START cuando entra un jugador
-----------------------------------------------------------------------
local matchStarted = false

local function TryStartMatch()
	if matchStarted then return end
	if #Players:GetPlayers() == 0 then return end
	matchStarted = true
	task.wait(2) -- dar tiempo al cliente para cargar
	MatchManager.StartMatch()
end

Players.PlayerAdded:Connect(function()
	if not matchStarted then task.spawn(TryStartMatch) end
end)

-- Play Solo: el jugador ya existe al iniciar el script
if #Players:GetPlayers() > 0 then
	task.spawn(TryStartMatch)
end

print("[Main] Servidor listo, esperando jugadores...")
