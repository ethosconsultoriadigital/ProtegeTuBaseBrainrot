-- CameraController
-- Cámara top-down con WASD pan y scroll zoom
-- Ubicación: StarterPlayerScripts > Controllers > CameraController (ModuleScript)
--
-- Controles:
--   WASD / flechas: pan
--   Scroll: zoom in/out
--   Límites: camera no sale del mapa

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CameraController = {}

local camera = workspace.CurrentCamera

local PAN_SPEED = 55
local ZOOM_SPEED = 6
local MIN_ZOOM = 20
local MAX_ZOOM = 110
local ANGLE_DEG = 55

-- Límites del mapa (basados en MapSetup ground 220×160 centrado en 0,0,20)
local MIN_X, MAX_X = -110, 110
local MIN_Z, MAX_Z = -60, 100

local target = Vector3.new(0, 0, 20)  -- centro del mapa
local zoom = 55
local enabled = false
local renderConn = nil
local scrollConn = nil

function CameraController.Init()
	-- noop, todo se hace en Enable
end

function CameraController.Enable()
	if enabled then return end
	enabled = true
	camera.CameraType = Enum.CameraType.Scriptable

	-- Scroll zoom
	scrollConn = UserInputService.InputChanged:Connect(function(input)
		if not enabled then return end
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			zoom = math.clamp(zoom - input.Position.Z * ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM)
		end
	end)

	-- Render loop
	renderConn = RunService.RenderStepped:Connect(function(dt)
		if not enabled then return end

		-- WASD input
		local dir = Vector3.zero
		local isDown = UserInputService.IsKeyDown
		if isDown(UserInputService, Enum.KeyCode.W) or isDown(UserInputService, Enum.KeyCode.Up) then
			dir += Vector3.new(0, 0, -1)
		end
		if isDown(UserInputService, Enum.KeyCode.S) or isDown(UserInputService, Enum.KeyCode.Down) then
			dir += Vector3.new(0, 0, 1)
		end
		if isDown(UserInputService, Enum.KeyCode.A) or isDown(UserInputService, Enum.KeyCode.Left) then
			dir += Vector3.new(-1, 0, 0)
		end
		if isDown(UserInputService, Enum.KeyCode.D) or isDown(UserInputService, Enum.KeyCode.Right) then
			dir += Vector3.new(1, 0, 0)
		end

		if dir.Magnitude > 0 then
			target += dir.Unit * PAN_SPEED * dt
		end

		-- Clamp al área del mapa
		target = Vector3.new(
			math.clamp(target.X, MIN_X, MAX_X),
			0,
			math.clamp(target.Z, MIN_Z, MAX_Z)
		)

		-- Posicionar cámara con ángulo fijo
		local rad = math.rad(ANGLE_DEG)
		local offsetY = math.sin(rad) * zoom
		local offsetZ = math.cos(rad) * zoom
		camera.CFrame = CFrame.lookAt(target + Vector3.new(0, offsetY, offsetZ), target)
	end)
end

function CameraController.Disable()
	enabled = false
	camera.CameraType = Enum.CameraType.Custom
	if renderConn then renderConn:Disconnect(); renderConn = nil end
	if scrollConn then scrollConn:Disconnect(); scrollConn = nil end
end

function CameraController.GetTarget(): Vector3
	return target
end

return CameraController
