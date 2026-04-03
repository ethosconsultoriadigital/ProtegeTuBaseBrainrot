-- Main.server.lua
-- Entry point del servidor: crea remotes, inicializa sistemas, game loop
-- Ubicación: ServerScriptService > Main (Script)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("=== PROTEGE TU BASE: BRAINROT SIEGE ===")
print("[Main] Inicializando servidor...")

-----------------------------------------------------------------------
-- 1. Crear estructura de Modules/Events si no existe
-----------------------------------------------------------------------
local function EnsureFolder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

EnsureFolder(ReplicatedStorage, "Modules")
local eventsFolder = EnsureFolder(ReplicatedStorage, "Events")

local remoteNames = {
	"WaveStarted", "WaveEnded",
	"BrainrotSpawned", "BrainrotDied", "BrainrotCaptured",
	"BarrierUpdate", "BreachStarted", "BreachEnded", "BrainrotStolen",
	"CellsUpdate", "GameOver",
	"RequestPlaceDefense", "RequestSellDefense",
	"RequestRepairBarrier", "RequestSkipTimer",
	"DefensePlaced",
}

for _, name in ipairs(remoteNames) do
	if not eventsFolder:FindFirstChild(name) then
		local e = Instance.new("RemoteEvent")
		e.Name = name
		e.Parent = eventsFolder
	end
end

if not eventsFolder:FindFirstChild("GetGameState") then
	local f = Instance.new("RemoteFunction")
	f.Name = "GetGameState"
	f.Parent = eventsFolder
end

print("[Main] Remotes creados")

-----------------------------------------------------------------------
-- 2. Cargar sistemas
-----------------------------------------------------------------------
local Systems = script.Parent.Systems

local BrainrotManager = require(Systems.BrainrotManager)
local DefenseManager  = require(Systems.DefenseManager)
local BaseManager     = require(Systems.BaseManager)
local CaptureManager  = require(Systems.CaptureManager)
local EconomyManager  = require(Systems.EconomyManager)
local WaveManager     = require(Systems.WaveManager)
local MatchManager    = require(Systems.MatchManager)

-----------------------------------------------------------------------
-- 3. Inicializar en orden
-----------------------------------------------------------------------
BrainrotManager.Init()
BaseManager.Init()
EconomyManager.Init(BaseManager)
CaptureManager.Init(BrainrotManager, BaseManager, EconomyManager)
DefenseManager.Init(BrainrotManager, CaptureManager)
WaveManager.Init(BrainrotManager)
MatchManager.Init({
	BrainrotManager = BrainrotManager,
	DefenseManager  = DefenseManager,
	BaseManager     = BaseManager,
	CaptureManager  = CaptureManager,
	EconomyManager  = EconomyManager,
	WaveManager     = WaveManager,
})

print("[Main] Sistemas inicializados")

-----------------------------------------------------------------------
-- 4. Game loop
-----------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	MatchManager.Update(dt)
end)

-----------------------------------------------------------------------
-- 5. Auto-start cuando entra un jugador
-----------------------------------------------------------------------
local started = false

local function TryStart()
	if started then return end
	if #Players:GetPlayers() == 0 then return end
	started = true
	task.wait(3) -- dar tiempo al cliente para cargar
	MatchManager.StartMatch()
end

Players.PlayerAdded:Connect(function()
	if not started then task.spawn(TryStart) end
end)

-- Para Play Solo (jugador ya existe al iniciar)
if #Players:GetPlayers() > 0 then
	task.spawn(TryStart)
end

print("[Main] Servidor listo, esperando jugadores...")
