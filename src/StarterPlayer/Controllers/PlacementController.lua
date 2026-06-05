-- PlacementController
-- Preview fantasma, snap a build zones, request al server
-- Ubicación: StarterPlayerScripts > Controllers > PlacementController (ModuleScript)
--
-- Flujo:
--   1. Jugador presiona 1/2/3 → StartPlacing(defenseType)
--   2. Ghost sigue al mouse, snap a zona más cercana
--   3. Click → ConfirmPlacement → FireServer(RequestPlaceDefense)
--   4. ESC → CancelPlacing
--
-- Toda validación real ocurre en el servidor. El cliente solo muestra feedback.

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
local renderConn = nil

-- Callbacks para notificar al HUD qué defensa está seleccionada
local selectionCallbacks: {(defenseType: string?) -> ()} = {}

function PlacementController.Init()
	Events = ReplicatedStorage:WaitForChild("Events", 10)
	if not Events then
		warn("[PlacementController] ReplicatedStorage.Events no encontrado tras 10s")
	end
end

function PlacementController.OnSelectionChanged(cb)
	table.insert(selectionCallbacks, cb)
end

function PlacementController.StartPlacing(defenseType: string)
	if isPlacing then PlacementController.CancelPlacing() end

	local cfg = DefenseConfig.Defenses[defenseType]
	if not cfg then return end

	isPlacing = true
	selectedType = defenseType

	-- Ghost preview
	ghost = Instance.new("Part")
	ghost.Name = "PlacementGhost"
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
		rangeRing.Name = "RangePreview"
		rangeRing.Shape = Enum.PartType.Cylinder
		rangeRing.Size = Vector3.new(0.08, r * 2, r * 2)
		rangeRing.Anchored = true
		rangeRing.CanCollide = false
		rangeRing.Color = cfg.color
		rangeRing.Transparency = 0.88
		rangeRing.Material = Enum.Material.Neon
		rangeRing.Parent = workspace
	end

	-- Render loop para mover ghost
	renderConn = RunService.RenderStepped:Connect(function()
		PlacementController._UpdateGhost()
	end)

	for _, cb in ipairs(selectionCallbacks) do cb(defenseType) end
end

function PlacementController.CancelPlacing()
	isPlacing = false
	selectedType = nil
	currentZone = nil
	if ghost then ghost:Destroy(); ghost = nil end
	if rangeRing then rangeRing:Destroy(); rangeRing = nil end
	if renderConn then renderConn:Disconnect(); renderConn = nil end
	for _, cb in ipairs(selectionCallbacks) do cb(nil) end
end

function PlacementController.ConfirmPlacement()
	if not isPlacing or not currentZone then return end
	if not Events or not Events:FindFirstChild("RequestPlaceDefense") then
		warn("[PlacementController] RequestPlaceDefense no disponible")
		PlacementController.CancelPlacing()
		return
	end

	-- Fire al servidor — validación real ocurre allá
	Events.RequestPlaceDefense:FireServer({
		defenseType = selectedType,
		position = currentZone.Position,
	})

	PlacementController.CancelPlacing()
end

function PlacementController._UpdateGhost()
	if not ghost then return end

	-- Raycast desde la cámara al mouse
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

	-- Buscar zona más cercana
	local buildZones = workspace.Map and workspace.Map:FindFirstChild("BuildZones")
	if not buildZones then return end

	local best: BasePart? = nil
	local bestDist = GameConfig.BUILD_ZONE_SNAP_RADIUS * 2

	for _, zone in ipairs(buildZones:GetChildren()) do
		if zone:IsA("BasePart") then
			local d = (zone.Position - hitPos).Magnitude
			if d < bestDist then
				bestDist = d
				best = zone
			end
		end
	end

	if best then
		currentZone = best
		local cfg = DefenseConfig.Defenses[selectedType]
		local yOff = cfg and cfg.size.Y / 2 + 0.1 or 1.5

		ghost.Position = best.Position + Vector3.new(0, yOff, 0)
		ghost.Transparency = 0.4
		ghost.Color = cfg and cfg.color or Color3.new(1, 1, 1)

		if rangeRing then
			rangeRing.CFrame = CFrame.new(best.Position.X, 0.12, best.Position.Z)
				* CFrame.Angles(0, 0, math.rad(90))
			rangeRing.Transparency = 0.88
		end
	else
		-- Fuera de rango de zona
		currentZone = nil
		ghost.Transparency = 0.75
		ghost.Color = Color3.fromRGB(255, 50, 50)
		if rangeRing then rangeRing.Transparency = 1 end
	end
end

function PlacementController.IsPlacing(): boolean
	return isPlacing
end

function PlacementController.GetSelectedType(): string?
	return selectedType
end

return PlacementController
