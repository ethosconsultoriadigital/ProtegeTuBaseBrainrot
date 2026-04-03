-- CameraController.lua
-- Cámara top-down/isométrica con zoom y pan
-- Ubicación: StarterPlayerScripts/Controllers/CameraController

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CameraController = {}

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuración
local CAMERA_HEIGHT = 60
local CAMERA_ANGLE = 55       -- Grados desde la horizontal
local CAMERA_DISTANCE = 50
local PAN_SPEED = 50
local ZOOM_SPEED = 5
local MIN_ZOOM = 25
local MAX_ZOOM = 90

-- Estado
local cameraTarget = Vector3.new(0, 0, 20) -- Centro del mapa
local currentZoom = CAMERA_DISTANCE
local enabled = false
local renderConn = nil

function CameraController.Init()
	-- Nada por ahora
end

function CameraController.Enable()
	if enabled then return end
	enabled = true

	camera.CameraType = Enum.CameraType.Scriptable

	-- Zoom con scroll
	UserInputService.InputChanged:Connect(function(input)
		if not enabled then return end
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			currentZoom = math.clamp(currentZoom - input.Position.Z * ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM)
		end
	end)

	-- Update loop
	renderConn = RunService.RenderStepped:Connect(function(dt)
		if not enabled then return end

		-- Pan con WASD o flechas
		local moveDir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
			moveDir = moveDir + Vector3.new(0, 0, -1)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
			moveDir = moveDir + Vector3.new(0, 0, 1)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
			moveDir = moveDir + Vector3.new(-1, 0, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
			moveDir = moveDir + Vector3.new(1, 0, 0)
		end

		if moveDir.Magnitude > 0 then
			cameraTarget = cameraTarget + moveDir.Unit * PAN_SPEED * dt
		end

		-- Calcular posición de cámara
		local angleRad = math.rad(CAMERA_ANGLE)
		local offsetY = math.sin(angleRad) * currentZoom
		local offsetZ = math.cos(angleRad) * currentZoom

		local cameraPos = cameraTarget + Vector3.new(0, offsetY, offsetZ)
		camera.CFrame = CFrame.lookAt(cameraPos, cameraTarget)
	end)
end

function CameraController.Disable()
	enabled = false
	camera.CameraType = Enum.CameraType.Custom
	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end
end

function CameraController.SetTarget(pos: Vector3)
	cameraTarget = pos
end

return CameraController
