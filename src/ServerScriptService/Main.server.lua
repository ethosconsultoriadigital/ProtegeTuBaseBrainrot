-- Main.server.lua
-- Entry point del servidor: inicializa todos los sistemas
-- Ubicación: ServerScriptService/Main (Script, no ModuleScript)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== PROTEGE TU BASE: BRAINROT SIEGE ===")
print("Inicializando servidor...")

-- Crear estructura de Events si no existe
local function CreateEvents()
	local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
	if not eventsFolder then
		eventsFolder = Instance.new("Folder")
		eventsFolder.Name = "Events"
		eventsFolder.Parent = ReplicatedStorage
	end

	local remoteEvents = {
		"WaveStarted", "WaveEnded",
		"BrainrotSpawned", "BrainrotDied", "BrainrotCaptured",
		"BarrierUpdate", "BreachStarted", "BreachEnded", "BrainrotStolen",
		"CellsUpdate", "GameOver",
		"RequestPlaceDefense", "RequestSellDefense",
		"RequestRepairBarrier", "RequestSkipTimer",
		"DefensePlaced",
	}

	for _, name in ipairs(remoteEvents) do
		if not eventsFolder:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = eventsFolder
		end
	end

	-- RemoteFunctions
	local remoteFunctions = {"GetGameState"}
	for _, name in ipairs(remoteFunctions) do
		if not eventsFolder:FindFirstChild(name) then
			local func = Instance.new("RemoteFunction")
			func.Name = name
			func.Parent = eventsFolder
		end
	end

	print("[Main] Events creados")
end

-- Crear Modules folder si no existe
local function EnsureModulesFolder()
	local modules = ReplicatedStorage:FindFirstChild("Modules")
	if not modules then
		modules = Instance.new("Folder")
		modules.Name = "Modules"
		modules.Parent = ReplicatedStorage
	end
end

-- Inicialización
CreateEvents()
EnsureModulesFolder()

-- Cargar sistemas
local BrainrotManager = require(script.Parent.Systems.BrainrotManager)
local DefenseManager = require(script.Parent.Systems.DefenseManager)
local BaseManager = require(script.Parent.Systems.BaseManager)
local CaptureManager = require(script.Parent.Systems.CaptureManager)
local EconomyManager = require(script.Parent.Systems.EconomyManager)
local WaveManager = require(script.Parent.Systems.WaveManager)
local MatchManager = require(script.Parent.Systems.MatchManager)

-- Inicializar en orden
BrainrotManager.Init()
BaseManager.Init()
EconomyManager.Init(BaseManager)
CaptureManager.Init(BrainrotManager, BaseManager, EconomyManager)
DefenseManager.Init(BrainrotManager, CaptureManager)
WaveManager.Init(BrainrotManager)
MatchManager.Init({
	BrainrotManager = BrainrotManager,
	DefenseManager = DefenseManager,
	BaseManager = BaseManager,
	CaptureManager = CaptureManager,
	EconomyManager = EconomyManager,
	WaveManager = WaveManager,
})

print("[Main] Todos los sistemas inicializados")

-- Game loop principal (Heartbeat = cada frame)
RunService.Heartbeat:Connect(function(dt)
	MatchManager.Update(dt)
end)

-- Esperar a que al menos 1 jugador entre, luego iniciar partida
-- En MVP: auto-start cuando entra el primer jugador
local Players = game:GetService("Players")

local function StartWhenReady()
	if #Players:GetPlayers() > 0 then
		task.wait(3) -- Dar tiempo a que el cliente cargue
		MatchManager.StartMatch()
	end
end

Players.PlayerAdded:Connect(function(player)
	if MatchManager.GetState() == "WAITING" then
		task.wait(3)
		MatchManager.StartMatch()
	end
end)

-- Si ya hay jugadores (Play Solo en Studio)
if #Players:GetPlayers() > 0 then
	task.spawn(StartWhenReady)
end

print("[Main] Servidor listo, esperando jugadores...")
