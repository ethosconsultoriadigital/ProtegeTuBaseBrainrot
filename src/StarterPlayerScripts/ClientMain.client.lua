-- ClientMain.client.lua
-- Entry point del cliente: input, hotkeys, inicialización de controllers
-- Ubicación: StarterPlayerScripts > ClientMain (LocalScript)
--
-- Controles:
--   1/2/3     = Seleccionar defensa (toggle)
--   Click     = Colocar defensa
--   ESC       = Cancelar placement
--   R         = Reparar barrera
--   F         = Saltar build timer
--   WASD      = Mover cámara
--   Scroll    = Zoom

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")

-- Precarga de configs
require(Modules:WaitForChild("DefenseConfig"))
require(Modules:WaitForChild("GameConfig"))

local PlacementController = require(
	script.Parent:WaitForChild("Controllers"):WaitForChild("PlacementController")
)
local CameraController = require(
	script.Parent.Controllers:WaitForChild("CameraController")
)

print("[Client] Inicializando...")

PlacementController.Init()
CameraController.Init()
CameraController.Enable()

-----------------------------------------------------------------------
-- INPUT
-----------------------------------------------------------------------
local hotkeys = {
	[Enum.KeyCode.One]   = "LaserTurret",
	[Enum.KeyCode.Two]   = "IceTrap",
	[Enum.KeyCode.Three] = "CaptureModule",
}

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	-- Defense hotkeys (toggle)
	local defType = hotkeys[input.KeyCode]
	if defType then
		if PlacementController.IsPlacing() and PlacementController.GetSelectedType() == defType then
			PlacementController.CancelPlacing()
		else
			PlacementController.StartPlacing(defType)
		end
		return
	end

	-- Click to place
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if PlacementController.IsPlacing() then
			PlacementController.ConfirmPlacement()
			return
		end
	end

	-- ESC cancel
	if input.KeyCode == Enum.KeyCode.Escape then
		if PlacementController.IsPlacing() then
			PlacementController.CancelPlacing()
		end
		return
	end

	-- R repair barrier
	if input.KeyCode == Enum.KeyCode.R then
		Events.RequestRepairBarrier:FireServer()
		return
	end

	-- F skip build timer
	if input.KeyCode == Enum.KeyCode.F then
		Events.RequestSkipTimer:FireServer()
		return
	end
end)

-----------------------------------------------------------------------
-- EVENT LISTENERS (logs de consola — HUDController maneja la UI)
-----------------------------------------------------------------------
Events.BrainrotCaptured.OnClientEvent:Connect(function(data)
	print("[Client] CAPTURA: " .. data.className .. " " .. data.rarity)
end)

Events.BreachStarted.OnClientEvent:Connect(function()
	print("[Client] !! BRECHA !! Presiona R para reparar")
end)

Events.BreachEnded.OnClientEvent:Connect(function()
	print("[Client] Barrera reparada")
end)

Events.BrainrotStolen.OnClientEvent:Connect(function(data)
	print("[Client] ROBADO: " .. data.className .. " " .. data.rarity)
end)

Events.GameOver.OnClientEvent:Connect(function(data)
	print("[Client] " .. data.result .. " — " .. data.reason)
end)

Events.DefensePlaced.OnClientEvent:Connect(function(data)
	print("[Client] Defensa colocada: " .. data.defenseType .. " en " .. tostring(data.position))
end)

print("[Client] Listo")
print("  1/2/3 = Defensas | Click = Colocar | ESC = Cancelar")
print("  R = Reparar | F = Saltar timer | WASD = Camara | Scroll = Zoom")
