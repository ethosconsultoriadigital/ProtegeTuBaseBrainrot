-- MapSetup.server.lua
-- Graybox procedural O mapa desde Creator Store (GameConfig.IMPORTED_MAP_ASSET_ID).
-- Ubicación: ServerScriptService > MapSetup (Script)
--
-- Contrato para el juego: Workspace.Map.Path.Waypoints (Parts "1","2",...)
-- BaseManager: Map.Base.Barrier | DefenseManager: Map.BuildZones

local Lighting = game:GetService("Lighting")
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))

-----------------------------------------------------------------------
-- Posiciones por defecto (graybox + fallback si el import no trae zonas)
-----------------------------------------------------------------------
local DEFAULT_BUILD_ZONE_POSITIONS = {
	Vector3.new(-60, 0.1, 9),
	Vector3.new(-40, 0.1, -9),
	Vector3.new(-28, 0.1, 10),
	Vector3.new(-28, 0.1, 32),
	Vector3.new(-10, 0.1, 48),
	Vector3.new(10, 0.1, 48),
	Vector3.new(30, 0.1, 32),
	Vector3.new(48, 0.1, 30),
	Vector3.new(48, 0.1, 9),
	Vector3.new(52, 0.1, -9),
}

local function skyTexturesAllEmpty(sky: Sky): boolean
	return sky.SkyboxBk == "" and sky.SkyboxDn == "" and sky.SkyboxFt == ""
		and sky.SkyboxLf == "" and sky.SkyboxRt == "" and sky.SkyboxUp == ""
end

local function ApplyPlayableLighting()
	Lighting.Ambient = Color3.fromRGB(105, 102, 120)
	Lighting.OutdoorAmbient = Color3.fromRGB(135, 132, 152)
	Lighting.Brightness = 2
	Lighting.ClockTime = 15.5
	Lighting.GeographicLatitude = 15
	Lighting.FogEnd = 950
	Lighting.FogStart = 180
	Lighting.FogColor = Color3.fromRGB(175, 180, 205)

	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("Sky") and skyTexturesAllEmpty(child) then
			child:Destroy()
		end
	end

	local atm = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atm then
		atm = Instance.new("Atmosphere")
		atm.Parent = Lighting
	end
	atm.Density = 0.28
	atm.Offset = 0.15
	atm.Color = Color3.fromRGB(198, 205, 230)
	atm.Decay = Color3.fromRGB(128, 132, 148)
	atm.Glare = 0
	atm.Haze = 0.15

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.22
	bloom.Size = 18
	bloom.Threshold = 1.15

	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Parent = Lighting
	end
	cc.TintColor = Color3.fromRGB(252, 250, 255)
	cc.Contrast = 0.04
	cc.Saturation = 0.06
end

local function countNumericWaypointParts(wpFolder: Folder): number
	local n = 0
	for _, c in ipairs(wpFolder:GetChildren()) do
		if c:IsA("BasePart") and tonumber(c.Name) then
			n += 1
		end
	end
	return n
end

local function findWaypointsFolder(root: Instance): Folder?
	local path = root:FindFirstChild("Path")
	if path then
		local w = path:FindFirstChild("Waypoints")
		if w and w:IsA("Folder") and countNumericWaypointParts(w) >= 2 then
			return w
		end
	end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("Folder") and d.Name == "Waypoints" and countNumericWaypointParts(d) >= 2 then
			return d
		end
	end
	return nil
end

-- Deja Map.Path.Waypoints como espera BrainrotManager.
local function normalizePathWaypoints(root: Instance): boolean
	local wpFolder = findWaypointsFolder(root)
	if not wpFolder then
		return false
	end
	local pathFolder = root:FindFirstChild("Path")
	if not pathFolder then
		pathFolder = Instance.new("Folder")
		pathFolder.Name = "Path"
		pathFolder.Parent = root
	end
	if wpFolder.Parent ~= pathFolder then
		wpFolder.Parent = pathFolder
	end
	wpFolder.Name = "Waypoints"
	return countNumericWaypointParts(wpFolder) >= 2
end

local function getFirstWaypointWorldPosition(wpFolder: Folder): Vector3?
	local bestN = math.huge
	local best: Vector3? = nil
	for _, c in ipairs(wpFolder:GetChildren()) do
		if c:IsA("BasePart") then
			local n = tonumber(c.Name)
			if n and n < bestN then
				bestN = n
				best = c.Position
			end
		end
	end
	return best
end

-- Base, BuildZones y SpawnPoint si el mapa importado no los trae (luego puedes mover en Studio).
local function ensureGameplayVolumesForMap(map: Instance, spawnCenter: Vector3)
	local base = map:FindFirstChild("Base")
	local hasBarrier = base and base:FindFirstChild("Barrier")
	if not hasBarrier then
		if base then
			base:Destroy()
		end
		local baseFolder = Instance.new("Folder")
		baseFolder.Name = "Base"
		baseFolder.Parent = map

		local barrier = Instance.new("Part")
		barrier.Name = "Barrier"
		barrier.Size = Vector3.new(2, 12, 22)
		barrier.Position = Vector3.new(66, 6, 0)
		barrier.Anchored = true
		barrier.CanCollide = false
		barrier.Transparency = 0.5
		barrier.Color = Color3.fromRGB(0, 229, 255)
		barrier.Material = Enum.Material.ForceField
		barrier.Parent = baseFolder

		local vault = Instance.new("Part")
		vault.Name = "Vault"
		vault.Size = Vector3.new(18, 0.4, 18)
		vault.Position = Vector3.new(80, 0.2, 0)
		vault.Anchored = true
		vault.Color = Color3.fromRGB(0, 60, 50)
		vault.Material = Enum.Material.DiamondPlate
		vault.Parent = baseFolder

		local core = Instance.new("Part")
		core.Name = "Core"
		core.Size = Vector3.new(4, 4, 4)
		core.Position = Vector3.new(80, 3, 0)
		core.Anchored = true
		core.Shape = Enum.PartType.Ball
		core.Color = Color3.new(1, 1, 1)
		core.Material = Enum.Material.Neon
		core.Parent = baseFolder

		local coreLight = Instance.new("PointLight")
		coreLight.Color = Color3.fromRGB(0, 229, 255)
		coreLight.Brightness = 3
		coreLight.Range = 25
		coreLight.Parent = core
	end

	local bz = map:FindFirstChild("BuildZones")
	if not bz or #bz:GetChildren() == 0 then
		if bz then
			bz:Destroy()
		end
		local bzFolder = Instance.new("Folder")
		bzFolder.Name = "BuildZones"
		bzFolder.Parent = map
		for i, pos in ipairs(DEFAULT_BUILD_ZONE_POSITIONS) do
			local zone = Instance.new("Part")
			zone.Name = "Zone_" .. string.format("%02d", i)
			zone.Size = Vector3.new(6, 0.15, 6)
			zone.Position = pos
			zone.Anchored = true
			zone.CanCollide = false
			zone.Transparency = 0.5
			zone.Color = Color3.fromRGB(0, 200, 220)
			zone.Material = Enum.Material.Neon
			zone.Parent = bzFolder
		end
	end

	if not map:FindFirstChild("SpawnPoint") then
		local spawnPoint = Instance.new("Part")
		spawnPoint.Name = "SpawnPoint"
		spawnPoint.Size = Vector3.new(6, 0.2, 6)
		spawnPoint.Position = spawnCenter + Vector3.new(0, -0.8, 0)
		spawnPoint.Anchored = true
		spawnPoint.CanCollide = false
		spawnPoint.Transparency = 0.6
		spawnPoint.Color = Color3.fromRGB(255, 0, 80)
		spawnPoint.Material = Enum.Material.Neon
		spawnPoint.Parent = map
	end
end

local function mapHasUsableWaypoints(): boolean
	local m = workspace:FindFirstChild("Map")
	if not m then
		return false
	end
	local wp = m:FindFirstChild("Path") and m.Path:FindFirstChild("Waypoints")
	return wp ~= nil and #wp:GetChildren() > 0
end

local function TryLoadImportedMap(): boolean
	local assetId = GameConfig.IMPORTED_MAP_ASSET_ID
	if type(assetId) ~= "number" or assetId <= 0 then
		return false
	end

	local stale = workspace:FindFirstChild("Map")
	if stale then
		stale:Destroy()
	end

	local ok, holder = pcall(function()
		return InsertService:LoadAsset(assetId)
	end)
	if not ok or not holder then
		warn("[MapSetup] LoadAsset falló (" .. tostring(assetId) .. "): " .. tostring(holder))
		return false
	end

	holder.Name = "_MapImportHolder"
	holder.Parent = workspace

	local root: Instance = holder
	local kids = holder:GetChildren()
	if #kids == 0 then
		holder:Destroy()
		return false
	end
	if #kids == 1 then
		root = kids[1]
		root.Parent = workspace
		holder:Destroy()
	end

	if root:FindFirstChild("Map") and root.Map:IsA("Folder") then
		local inner = root.Map
		inner.Parent = workspace
		if root.Parent == workspace then
			root:Destroy()
		end
		root = inner
	end

	if root.Name ~= "Map" then
		root.Name = "Map"
	end
	if root.Parent ~= workspace then
		root.Parent = workspace
	end

	if not normalizePathWaypoints(root) then
		warn("[MapSetup] El asset no tiene Waypoints jugables (≥2 Parts numeradas). Revisa la jerarquía.")
		root:Destroy()
		return false
	end

	local mapFolder = workspace.Map
	local wpFolder = mapFolder.Path.Waypoints
	local spawnPos = getFirstWaypointWorldPosition(wpFolder)
	if not spawnPos then
		warn("[MapSetup] No se pudo obtener posición del waypoint 1.")
		mapFolder:Destroy()
		return false
	end

	ensureGameplayVolumesForMap(mapFolder, spawnPos)
	ApplyPlayableLighting()
	print("[MapSetup] Mapa importado (asset " .. tostring(assetId) .. "). Path normalizado a Map.Path.Waypoints.")
	return true
end

local function CreateMap()
	if mapHasUsableWaypoints() then
		local wpFolder = workspace.Map.Path.Waypoints
		local spawnPos = getFirstWaypointWorldPosition(wpFolder) or Vector3.new(0, 1, 0)
		ensureGameplayVolumesForMap(workspace.Map, spawnPos)
		ApplyPlayableLighting()
		print("[MapSetup] Mapa existente, saltando generación de geometría")
		return
	end

	if TryLoadImportedMap() then
		return
	end

	print("[MapSetup] Generando mapa graybox...")

	local map = Instance.new("Folder")
	map.Name = "Map"
	map.Parent = workspace

	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(220, 1, 160)
	ground.Position = Vector3.new(0, -0.5, 20)
	ground.Anchored = true
	ground.Color = Color3.fromRGB(58, 52, 78)
	ground.Material = Enum.Material.Slate
	ground.Parent = map

	local pathFolder = Instance.new("Folder")
	pathFolder.Name = "Path"
	pathFolder.Parent = map
	local wpFolder = Instance.new("Folder")
	wpFolder.Name = "Waypoints"
	wpFolder.Parent = pathFolder

	local positions = {
		Vector3.new(-80, 1, 0),
		Vector3.new(-60, 1, 0),
		Vector3.new(-40, 1, 0),
		Vector3.new(-20, 1, 0),
		Vector3.new(-20, 1, 20),
		Vector3.new(-20, 1, 40),
		Vector3.new(0, 1, 40),
		Vector3.new(20, 1, 40),
		Vector3.new(40, 1, 40),
		Vector3.new(40, 1, 20),
		Vector3.new(40, 1, 0),
		Vector3.new(60, 1, 0),
	}

	for i, pos in ipairs(positions) do
		local wp = Instance.new("Part")
		wp.Name = tostring(i)
		wp.Size = Vector3.new(2, 0.3, 2)
		wp.Position = pos
		wp.Anchored = true
		wp.CanCollide = false
		wp.Transparency = 0.7
		wp.Color = Color3.fromRGB(180, 0, 220)
		wp.Material = Enum.Material.Neon
		wp.Parent = wpFolder
	end

	for i = 1, #positions - 1 do
		local p1, p2 = positions[i], positions[i + 1]
		local mid = (p1 + p2) / 2
		local seg = Instance.new("Part")
		seg.Name = "Seg_" .. i
		seg.Anchored = true
		seg.CanCollide = false
		seg.Color = Color3.fromRGB(88, 72, 108)
		seg.Material = Enum.Material.Cobblestone
		seg.Transparency = 0.15
		local delta = p2 - p1
		if math.abs(delta.X) > math.abs(delta.Z) then
			seg.Size = Vector3.new(math.abs(delta.X), 0.15, 5)
		else
			seg.Size = Vector3.new(5, 0.15, math.abs(delta.Z))
		end
		seg.Position = Vector3.new(mid.X, 0.08, mid.Z)
		seg.Parent = pathFolder
	end

	local bzFolder = Instance.new("Folder")
	bzFolder.Name = "BuildZones"
	bzFolder.Parent = map
	for i, pos in ipairs(DEFAULT_BUILD_ZONE_POSITIONS) do
		local zone = Instance.new("Part")
		zone.Name = "Zone_" .. string.format("%02d", i)
		zone.Size = Vector3.new(6, 0.15, 6)
		zone.Position = pos
		zone.Anchored = true
		zone.CanCollide = false
		zone.Transparency = 0.5
		zone.Color = Color3.fromRGB(0, 200, 220)
		zone.Material = Enum.Material.Neon
		zone.Parent = bzFolder
	end

	local baseFolder = Instance.new("Folder")
	baseFolder.Name = "Base"
	baseFolder.Parent = map

	local barrier = Instance.new("Part")
	barrier.Name = "Barrier"
	barrier.Size = Vector3.new(2, 12, 22)
	barrier.Position = Vector3.new(66, 6, 0)
	barrier.Anchored = true
	barrier.CanCollide = false
	barrier.Transparency = 0.5
	barrier.Color = Color3.fromRGB(0, 229, 255)
	barrier.Material = Enum.Material.ForceField
	barrier.Parent = baseFolder

	local vault = Instance.new("Part")
	vault.Name = "Vault"
	vault.Size = Vector3.new(18, 0.4, 18)
	vault.Position = Vector3.new(80, 0.2, 0)
	vault.Anchored = true
	vault.Color = Color3.fromRGB(0, 60, 50)
	vault.Material = Enum.Material.DiamondPlate
	vault.Parent = baseFolder

	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = Vector3.new(4, 4, 4)
	core.Position = Vector3.new(80, 3, 0)
	core.Anchored = true
	core.Shape = Enum.PartType.Ball
	core.Color = Color3.new(1, 1, 1)
	core.Material = Enum.Material.Neon
	core.Parent = baseFolder

	local coreLight = Instance.new("PointLight")
	coreLight.Color = Color3.fromRGB(0, 229, 255)
	coreLight.Brightness = 3
	coreLight.Range = 25
	coreLight.Parent = core

	local spawnPoint = Instance.new("Part")
	spawnPoint.Name = "SpawnPoint"
	spawnPoint.Size = Vector3.new(6, 0.2, 6)
	spawnPoint.Position = positions[1] + Vector3.new(0, -0.8, 0)
	spawnPoint.Anchored = true
	spawnPoint.CanCollide = false
	spawnPoint.Transparency = 0.6
	spawnPoint.Color = Color3.fromRGB(255, 0, 80)
	spawnPoint.Material = Enum.Material.Neon
	spawnPoint.Parent = map

	ApplyPlayableLighting()
	print("[MapSetup] Mapa generado: 12 wp, 10 zones, base completa, spawn point listo")
end

CreateMap()
