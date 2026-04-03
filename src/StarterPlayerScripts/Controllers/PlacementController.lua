-- PlacementController
-- Preview fantasma, snap a build zones, request al server
-- Ubicación: StarterPlayerScripts > Controllers > PlacementController (ModuleScript)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefenseConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DefenseConfig"))
local GameConfig = require(ReplicatedStorage.Modules:WaitForChild("GameConfig"))

local PlacementController = {}

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local isPlacing = false
local selectedType: string? = nil
local ghost: BasePart? = nil
local rangeRing: BasePart? = nil
local currentZone: BasePart? = nil
local Events = nil
local conn = nil

function PlacementController.Init()
	Events = ReplicatedStorage:WaitForChild("Events")
end

function PlacementController.StartPlacing(defenseType: string)
	if isPlacing then PlacementController.CancelPlacing() end

	local cfg = DefenseConfig.Defenses[defenseType]
	if not cfg then return end

	isPlacing = true
	selectedType = defenseType

	-- Ghost
	ghost = Instance.new("Part")
	ghost.Name = "Ghost"
	ghost.Size = cfg.size
	ghost.Anchored = true
	ghost.CanCollide = false
	ghost.Color = cfg.color
	ghost.Material = Enum.Material.ForceField
	ghost.Transparency = 0.45
	ghost.Parent = workspace

	-- Range ring
	local stats = DefenseConfig.GetStats(defenseType, 1)
	if stats then
		local r = stats.range or 10
		rangeRing = Instance.new("Part")
		rangeRing.Name = "RangeRing"
		rangeRing.Shape = Enum.PartType.Cylinder
		rangeRing.Size = Vector3.new(0.08, r * 2, r * 2)
		rangeRing.Anchored = true
		rangeRing.CanCollide = false
		rangeRing.Color = cfg.color
		rangeRing.Transparency = 0.9
		rangeRing.Material = Enum.Material.Neon
		rangeRing.Parent = workspace
	end

	conn = RunService.RenderStepped:Connect(function()
		PlacementController._UpdateGhost()
	end)
end

function PlacementController.CancelPlacing()
	isPlacing = false
	selectedType = nil
	currentZone = nil
	if ghost then ghost:Destroy(); ghost = nil end
	if rangeRing then rangeRing:Destroy(); rangeRing = nil end
	if conn then conn:Disconnect(); conn = nil end
end

function PlacementController.ConfirmPlacement()
	if not isPlacing or not currentZone then return end
	Events.RequestPlaceDefense:FireServer({
		defenseType = selectedType,
		position = currentZone.Position,
	})
	PlacementController.CancelPlacing()
end

function PlacementController._UpdateGhost()
	if not ghost then return end

	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { workspace:FindFirstChild("Map") }

	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	if not result then
		ghost.Transparency = 1
		if rangeRing then rangeRing.Transparency = 1 end
		currentZone = nil
		return
	end

	local hitPos = result.Position
	local buildZones = workspace.Map and workspace.Map:FindFirstChild("BuildZones")
	if not buildZones then return end

	local best: BasePart? = nil
	local bestDist = GameConfig.BUILD_ZONE_SNAP_RADIUS * 2

	for _, z in ipairs(buildZones:GetChildren()) do
		if z:IsA("BasePart") then
			local d = (z.Position - hitPos).Magnitude
			if d < bestDist then bestDist = d; best = z end
		end
	end

	if best then
		currentZone = best
		local cfg = DefenseConfig.Defenses[selectedType]
		local yOff = cfg and cfg.size.Y / 2 + 0.1 or 1.5
		ghost.Position = best.Position + Vector3.new(0, yOff, 0)
		ghost.Transparency = 0.4
		ghost.Color = cfg and cfg.color or Color3.new(1,1,1)

		if rangeRing then
			rangeRing.CFrame = CFrame.new(best.Position.X, 0.12, best.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
			rangeRing.Transparency = 0.88
		end
	else
		currentZone = nil
		ghost.Transparency = 0.8
		ghost.Color = Color3.fromRGB(255, 0, 0)
		if rangeRing then rangeRing.Transparency = 1 end
	end
end

function PlacementController.IsPlacing(): boolean return isPlacing end
function PlacementController.GetSelectedType(): string? return selectedType end

return PlacementController
