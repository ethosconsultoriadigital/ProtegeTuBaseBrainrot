-- CameraController
-- Camara top-down con WASD pan y scroll zoom
-- Ubicación: StarterPlayerScripts > Controllers > CameraController (ModuleScript)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CameraController = {}

local camera = workspace.CurrentCamera

local PAN_SPEED = 55
local ZOOM_SPEED = 6
local MIN_ZOOM = 25
local MAX_ZOOM = 100
local ANGLE_DEG = 55

local target = Vector3.new(0, 0, 20)
local zoom = 55
local enabled = false
local conn = nil

function CameraController.Init() end

function CameraController.Enable()
	if enabled then return end
	enabled = true
	camera.CameraType = Enum.CameraType.Scriptable

	-- Zoom
	UserInputService.InputChanged:Connect(function(input)
		if not enabled then return end
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			zoom = math.clamp(zoom - input.Position.Z * ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM)
		end
	end)

	conn = RunService.RenderStepped:Connect(function(dt)
		if not enabled then return end

		local dir = Vector3.zero
		local keys = UserInputService.IsKeyDown
		if keys(UserInputService, Enum.KeyCode.W) or keys(UserInputService, Enum.KeyCode.Up) then
			dir += Vector3.new(0, 0, -1)
		end
		if keys(UserInputService, Enum.KeyCode.S) or keys(UserInputService, Enum.KeyCode.Down) then
			dir += Vector3.new(0, 0, 1)
		end
		if keys(UserInputService, Enum.KeyCode.A) or keys(UserInputService, Enum.KeyCode.Left) then
			dir += Vector3.new(-1, 0, 0)
		end
		if keys(UserInputService, Enum.KeyCode.D) or keys(UserInputService, Enum.KeyCode.Right) then
			dir += Vector3.new(1, 0, 0)
		end
		if dir.Magnitude > 0 then
			target += dir.Unit * PAN_SPEED * dt
		end

		local rad = math.rad(ANGLE_DEG)
		local oY = math.sin(rad) * zoom
		local oZ = math.cos(rad) * zoom
		camera.CFrame = CFrame.lookAt(target + Vector3.new(0, oY, oZ), target)
	end)
end

function CameraController.Disable()
	enabled = false
	camera.CameraType = Enum.CameraType.Custom
	if conn then conn:Disconnect(); conn = nil end
end

return CameraController
