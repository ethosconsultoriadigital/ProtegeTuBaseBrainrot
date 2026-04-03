-- ClientMain.client.lua
-- Entry point del cliente: conecta inputs, events y controllers
-- Ubicación: StarterPlayerScripts/ClientMain (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Esperar a que los módulos existan
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Events = ReplicatedStorage:WaitForChild("Events")

local DefenseConfig = require(Modules:WaitForChild("DefenseConfig"))
local GameConfig = require(Modules:WaitForChild("GameConfig"))

-- Controllers
local PlacementController = require(script.Parent:WaitForChild("Controllers"):WaitForChild("PlacementController"))
local CameraController = require(script.Parent.Controllers:WaitForChild("CameraController"))

print("[ClientMain] Inicializando cliente...")

-- Init
PlacementController.Init()
CameraController.Init()
CameraController.Enable()

-- Estado del cliente
local currentCells = 0
local currentWave = 0
local matchActive = false

-- ================================
-- INPUT HANDLING
-- ================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- Hotkeys de defensas (1, 2, 3)
	local keyMap = {
		[Enum.KeyCode.One] = "LaserTurret",
		[Enum.KeyCode.Two] = "IceTrap",
		[Enum.KeyCode.Three] = "CaptureModule",
	}

	local defenseType = keyMap[input.KeyCode]
	if defenseType then
		if PlacementController.IsPlacing() and PlacementController.GetSelectedType() == defenseType then
			-- Ya estaba seleccionado: cancelar
			PlacementController.CancelPlacing()
		else
			PlacementController.StartPlacing(defenseType)
		end
		return
	end

	-- Click para confirmar colocación
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if PlacementController.IsPlacing() then
			PlacementController.ConfirmPlacement()
			return
		end
	end

	-- ESC para cancelar
	if input.KeyCode == Enum.KeyCode.Escape then
		if PlacementController.IsPlacing() then
			PlacementController.CancelPlacing()
			return
		end
	end

	-- R para reparar barrera
	if input.KeyCode == Enum.KeyCode.R then
		Events.RequestRepairBarrier:FireServer()
		return
	end

	-- F para saltar timer de build
	if input.KeyCode == Enum.KeyCode.F then
		Events.RequestSkipTimer:FireServer()
		return
	end
end)

-- ================================
-- EVENT LISTENERS
-- ================================

-- Actualizar cells
Events.CellsUpdate.OnClientEvent:Connect(function(data)
	currentCells = data.cells
end)

-- Oleada iniciada
Events.WaveStarted.OnClientEvent:Connect(function(data)
	currentWave = data.waveNumber
	matchActive = true
end)

-- Game over
Events.GameOver.OnClientEvent:Connect(function(data)
	matchActive = false
	-- La UI maneja el display
end)

-- Captura exitosa
Events.BrainrotCaptured.OnClientEvent:Connect(function(data)
	print("[Client] ¡CAPTURA! " .. data.className .. " " .. data.rarity .. " (" .. data.vaultCount .. "/" .. data.vaultMax .. ")")
end)

-- Brecha
Events.BreachStarted.OnClientEvent:Connect(function()
	print("[Client] ¡¡BRECHA EN LA BASE!! Presiona R para reparar")
end)

Events.BreachEnded.OnClientEvent:Connect(function()
	print("[Client] Barrera reparada, brecha terminada")
end)

-- Robo
Events.BrainrotStolen.OnClientEvent:Connect(function(data)
	print("[Client] ¡Te robaron un " .. data.className .. " " .. data.rarity .. "!")
end)

print("[ClientMain] Cliente listo")
print("Controles:")
print("  1 - Torreta Láser | 2 - Trampa de Hielo | 3 - Módulo de Captura")
print("  Click - Colocar defensa | ESC - Cancelar")
print("  R - Reparar barrera | F - Saltar timer")
print("  WASD - Mover cámara | Scroll - Zoom")
