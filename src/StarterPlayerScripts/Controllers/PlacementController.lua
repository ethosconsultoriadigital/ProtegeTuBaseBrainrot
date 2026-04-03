-- PlacementController.lua
-- Controla la colocación de defensas desde el cliente (preview, snap, request)
-- Ubicación: StarterPlayerScripts/Controllers/PlacementController

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefenseConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DefenseConfig"))
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local PlacementController = {}

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Estado
local isPlacing = false
local selectedDefenseType = nil
local ghostPart: BasePart? = nil
local rangeIndicator: BasePart? = nil
local currentZone: BasePart? = nil
local Events = nil

-- Conexiones
local renderConn = nil

function PlacementController.Init()
	Events = ReplicatedStorage:WaitForChild("Events")
end

-- Activar modo de colocación
function PlacementController.StartPlacing(defenseType: string)
	if isPlacing then
		PlacementController.CancelPlacing()
	end

	local defConfig = DefenseConfig.Defenses[defenseType]
	if not defConfig then return end

	isPlacing = true
	selectedDefenseType = defenseType

	-- Crear ghost (preview)
	ghostPart = Instance.new("Part")
	ghostPart.Name = "PlacementGhost"
	ghostPart.Size = defConfig.size
	ghostPart.Anchored = true
	ghostPart.CanCollide = false
	ghostPart.Color = defConfig.color
	ghostPart.Material = Enum.Material.ForceField
	ghostPart.Transparency = 0.5
	ghostPart.Parent = workspace

	-- Range indicator
	local stats = DefenseConfig.GetStats(defenseType, 1)
	if stats and stats.range then
		rangeIndicator = Instance.new("Part")
		rangeIndicator.Name = "RangePreview"
		rangeIndicator.Shape = Enum.PartType.Cylinder
		rangeIndicator.Size = Vector3.new(0.1, stats.range * 2, stats.range * 2)
		rangeIndicator.Anchored = true
		rangeIndicator.CanCollide = false
		rangeIndicator.Color = defConfig.color
		rangeIndicator.Transparency = 0.9
		rangeIndicator.Material = Enum.Material.Neon
		rangeIndicator.Parent = workspace
	end

	-- Update loop para seguir el mouse
	renderConn = RunService.RenderStepped:Connect(function()
		PlacementController._UpdateGhost()
	end)
end

-- Cancelar colocación
function PlacementController.CancelPlacing()
	isPlacing = false
	selectedDefenseType = nil
	currentZone = nil

	if ghostPart then
		ghostPart:Destroy()
		ghostPart = nil
	end
	if rangeIndicator then
		rangeIndicator:Destroy()
		rangeIndicator = nil
	end
	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end
end

-- Confirmar colocación
function PlacementController.ConfirmPlacement()
	if not isPlacing or not currentZone then return end

	-- Enviar request al servidor
	Events.RequestPlaceDefense:FireServer({
		defenseType = selectedDefenseType,
		position = currentZone.Position,
	})

	PlacementController.CancelPlacing()
end

-- Update de preview
function PlacementController._UpdateGhost()
	if not ghostPart then return end

	-- Raycast desde mouse
	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {workspace.Map}

	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	if not result then
		ghostPart.Transparency = 1
		if rangeIndicator then rangeIndicator.Transparency = 1 end
		return
	end

	local hitPos = result.Position

	-- Buscar zona de construcción más cercana
	local buildZones = workspace.Map:FindFirstChild("BuildZones")
	if not buildZones then return end

	local closestZone = nil
	local closestDist = GameConfig.BUILD_ZONE_RADIUS * 2

	for _, zone in ipairs(buildZones:GetChildren()) do
		if zone:IsA("BasePart") then
			local dist = (zone.Position - hitPos).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestZone = zone
			end
		end
	end

	if closestZone and closestDist <= GameConfig.BUILD_ZONE_RADIUS * 2 then
		currentZone = closestZone
		local defConfig = DefenseConfig.Defenses[selectedDefenseType]
		local yOffset = defConfig and defConfig.size.Y / 2 + 0.1 or 1.5

		ghostPart.Position = closestZone.Position + Vector3.new(0, yOffset, 0)
		ghostPart.Transparency = 0.4
		ghostPart.Color = DefenseConfig.Defenses[selectedDefenseType].color

		if rangeIndicator then
			rangeIndicator.CFrame = CFrame.new(closestZone.Position.X, 0.15, closestZone.Position.Z)
				* CFrame.Angles(0, 0, math.rad(90))
			rangeIndicator.Transparency = 0.88
		end
	else
		currentZone = nil
		ghostPart.Transparency = 0.8
		ghostPart.Color = Color3.fromRGB(255, 0, 0) -- Rojo = inválido

		if rangeIndicator then
			rangeIndicator.Transparency = 1
		end
	end
end

-- Getters
function PlacementController.IsPlacing(): boolean return isPlacing end
function PlacementController.GetSelectedType(): string? return selectedDefenseType end

return PlacementController
