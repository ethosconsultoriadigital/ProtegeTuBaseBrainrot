-- MapSetup.server.lua
-- Auto-genera el mapa si no existe (para facilitar testing en Play Solo)
-- Ubicación: ServerScriptService/MapSetup (Script)
-- NOTA: Este script es solo para desarrollo. En producción, el mapa se crea en el editor.

local function CreateMap()
	-- Si ya existe un mapa con waypoints, no generar
	if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Path") then
		local wp = workspace.Map.Path:FindFirstChild("Waypoints")
		if wp and #wp:GetChildren() > 0 then
			print("[MapSetup] Mapa existente detectado, saltando generación")
			return
		end
	end

	print("[MapSetup] Generando mapa automático para desarrollo...")

	-- Crear estructura
	local map = Instance.new("Folder")
	map.Name = "Map"
	map.Parent = workspace

	-- Suelo
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(200, 1, 200)
	ground.Position = Vector3.new(0, -0.5, 0)
	ground.Anchored = true
	ground.Material = Enum.Material.Slate
	ground.Color = Color3.fromRGB(35, 25, 45) -- Púrpura oscuro
	ground.Parent = map

	-- Path
	local pathFolder = Instance.new("Folder")
	pathFolder.Name = "Path"
	pathFolder.Parent = map

	local waypointsFolder = Instance.new("Folder")
	waypointsFolder.Name = "Waypoints"
	waypointsFolder.Parent = pathFolder

	-- Waypoints (camino en forma de S)
	local waypointPositions = {
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

	for i, pos in ipairs(waypointPositions) do
		local wp = Instance.new("Part")
		wp.Name = tostring(i)
		wp.Size = Vector3.new(2, 1, 2)
		wp.Position = pos
		wp.Anchored = true
		wp.CanCollide = false
		wp.Transparency = 0.7
		wp.Color = Color3.fromRGB(213, 0, 249) -- Magenta
		wp.Material = Enum.Material.Neon
		wp.Shape = Enum.PartType.Cylinder
		wp.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
		wp.Parent = waypointsFolder
	end

	-- Crear visual del camino (parts conectando waypoints)
	for i = 1, #waypointPositions - 1 do
		local p1 = waypointPositions[i]
		local p2 = waypointPositions[i + 1]
		local mid = (p1 + p2) / 2
		local dist = (p2 - p1).Magnitude

		local pathPart = Instance.new("Part")
		pathPart.Name = "PathSegment_" .. i
		pathPart.Size = Vector3.new(dist, 0.2, 4)
		pathPart.CFrame = CFrame.lookAt(mid, p2) * CFrame.new(0, 0, 0)
		pathPart.Position = Vector3.new(mid.X, 0.1, mid.Z)
		pathPart.Anchored = true
		pathPart.CanCollide = false
		pathPart.Color = Color3.fromRGB(49, 27, 146) -- Púrpura oscuro
		pathPart.Material = Enum.Material.Cobblestone
		pathPart.Transparency = 0.3

		-- Orientar correctamente
		local dir = (p2 - p1)
		if dir.Magnitude > 0.1 then
			pathPart.CFrame = CFrame.lookAt(Vector3.new(mid.X, 0.1, mid.Z), Vector3.new(p2.X, 0.1, p2.Z))
			pathPart.Size = Vector3.new(4, 0.2, dist)
		end

		pathPart.Parent = pathFolder
	end

	-- Build Zones (junto a los waypoints, offset perpendicular al camino)
	local buildZonesFolder = Instance.new("Folder")
	buildZonesFolder.Name = "BuildZones"
	buildZonesFolder.Parent = map

	-- Posiciones de build zones (manualmente para buen gameplay)
	local buildZonePositions = {
		Vector3.new(-60, 0.1, 8),    -- Junto a WP 2
		Vector3.new(-40, 0.1, -8),   -- Junto a WP 3
		Vector3.new(-12, 0.1, 10),   -- Junto a WP 4-5
		Vector3.new(-28, 0.1, 30),   -- Junto a WP 5
		Vector3.new(-12, 0.1, 40),   -- Junto a WP 6-7
		Vector3.new(10, 0.1, 48),    -- Junto a WP 7-8
		Vector3.new(30, 0.1, 32),    -- Junto a WP 8-9
		Vector3.new(48, 0.1, 30),    -- Junto a WP 9-10
		Vector3.new(48, 0.1, 8),     -- Junto a WP 10-11
		Vector3.new(50, 0.1, -8),    -- Junto a WP 11-12
	}

	for i, pos in ipairs(buildZonePositions) do
		local zone = Instance.new("Part")
		zone.Name = "Zone_" .. string.format("%02d", i)
		zone.Size = Vector3.new(6, 0.2, 6)
		zone.Position = pos
		zone.Anchored = true
		zone.CanCollide = false
		zone.Transparency = 0.5
		zone.Color = Color3.fromRGB(0, 229, 255) -- Cyan
		zone.Material = Enum.Material.Neon
		zone.Parent = buildZonesFolder
	end

	-- Base
	local baseFolder = Instance.new("Folder")
	baseFolder.Name = "Base"
	baseFolder.Parent = map

	-- Barrera
	local barrier = Instance.new("Part")
	barrier.Name = "Barrier"
	barrier.Size = Vector3.new(2, 12, 20)
	barrier.Position = Vector3.new(66, 6, 0)
	barrier.Anchored = true
	barrier.CanCollide = false
	barrier.Transparency = 0.5
	barrier.Color = Color3.fromRGB(0, 229, 255)
	barrier.Material = Enum.Material.ForceField
	barrier.Parent = baseFolder

	-- Vault floor
	local vault = Instance.new("Part")
	vault.Name = "Vault"
	vault.Size = Vector3.new(16, 0.5, 16)
	vault.Position = Vector3.new(78, 0.25, 0)
	vault.Anchored = true
	vault.Color = Color3.fromRGB(0, 77, 64) -- Teal
	vault.Material = Enum.Material.DiamondPlate
	vault.Parent = baseFolder

	-- Core
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = Vector3.new(4, 4, 4)
	core.Position = Vector3.new(78, 3, 0)
	core.Anchored = true
	core.Shape = Enum.PartType.Ball
	core.Color = Color3.new(1, 1, 1)
	core.Material = Enum.Material.Neon
	core.Parent = baseFolder

	local coreLight = Instance.new("PointLight")
	coreLight.Color = Color3.fromRGB(0, 229, 255)
	coreLight.Brightness = 3
	coreLight.Range = 20
	coreLight.Parent = core

	-- Crear folders para entidades activas
	if not workspace:FindFirstChild("ActiveBrainrots") then
		local f = Instance.new("Folder")
		f.Name = "ActiveBrainrots"
		f.Parent = workspace
	end
	if not workspace:FindFirstChild("ActiveDefenses") then
		local f = Instance.new("Folder")
		f.Name = "ActiveDefenses"
		f.Parent = workspace
	end

	-- Iluminación
	local lighting = game:GetService("Lighting")
	lighting.Ambient = Color3.fromRGB(30, 20, 50)
	lighting.OutdoorAmbient = Color3.fromRGB(40, 30, 60)
	lighting.Brightness = 1
	lighting.ClockTime = 22 -- Noche
	lighting.FogEnd = 300
	lighting.FogColor = Color3.fromRGB(10, 5, 20)

	-- Skybox oscuro (si no hay)
	local sky = lighting:FindFirstChildOfClass("Sky")
	if not sky then
		sky = Instance.new("Sky")
		sky.SkyboxBk = ""
		sky.SkyboxDn = ""
		sky.SkyboxFt = ""
		sky.SkyboxLf = ""
		sky.SkyboxRt = ""
		sky.SkyboxUp = ""
		sky.StarCount = 3000
		sky.CelestialBodiesShown = false
		sky.Parent = lighting
	end

	-- Bloom para look premium
	local bloom = lighting:FindFirstChildOfClass("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Intensity = 0.5
		bloom.Size = 24
		bloom.Threshold = 1.5
		bloom.Parent = lighting
	end

	-- Color correction
	local cc = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.TintColor = Color3.fromRGB(220, 210, 255)
		cc.Contrast = 0.1
		cc.Saturation = 0.2
		cc.Parent = lighting
	end

	print("[MapSetup] Mapa generado exitosamente")
	print("  - 12 waypoints")
	print("  - 10 zonas de construcción")
	print("  - Base con barrera + bóveda + núcleo")
end

CreateMap()
