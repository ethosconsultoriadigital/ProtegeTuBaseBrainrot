-- ClientMain.client.lua
-- Entry point cliente: input, hotkeys, event listeners
-- Ubicación: StarterPlayerScripts > ClientMain (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")

require(Modules:WaitForChild("DefenseConfig")) -- precarga
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

	-- Defense hotkeys
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

	-- R repair
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
-- EVENT LISTENERS (logs en consola, la UI los maneja en HUDController)
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

print("[Client] Listo")
print("  1/2/3 = Defensas | Click = Colocar | ESC = Cancelar")
print("  R = Reparar | F = Saltar timer | WASD = Camara | Scroll = Zoom")
