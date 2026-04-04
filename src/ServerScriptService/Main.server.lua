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
-- 4. STUB: MANAGERS
-- Los sistemas se agregaran aqui en tandas posteriores.
-- El patron sera:
--
--   local BrainrotManager = require(script.Parent.Systems.BrainrotManager)
--   local DefenseManager  = require(script.Parent.Systems.DefenseManager)
--   ...
--   BrainrotManager.Init()
--   ...
--   RunService.Heartbeat:Connect(function(dt)
--       MatchManager.Update(dt)
--   end)
-----------------------------------------------------------------------

print("[Main] Bootstrap completo. Esperando managers...")
print("[Main] Servidor listo")
