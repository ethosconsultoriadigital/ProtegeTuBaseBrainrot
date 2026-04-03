-- MapSetup.server.lua
-- Auto-genera mapa completo para desarrollo (waypoints, build zones, base, iluminacion)
-- Ubicación: ServerScriptService > MapSetup (Script)
-- Si ya existe Workspace.Map con waypoints, no regenera.

local Lighting = game:GetService("Lighting")

local function CreateMap()
	-- Guard: no regenerar si ya existe
	if workspace:FindFirstChild("Map") then
		local wp = workspace.Map:FindFirstChild("Path")
			and workspace.Map.Path:FindFirstChild("Waypoints")
		if wp and #wp:GetChildren() > 0 then
			print("[MapSetup] Mapa existente, saltando")
			return
		end
	end

	print("[MapSetup] Generando mapa...")

	local map = Instance.new("Folder"); map.Name = "Map"; map.Parent = workspace

	-- Suelo
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(220, 1, 160)
	ground.Position = Vector3.new(0, -0.5, 20)
	ground.Anchored = true
	ground.Color = Color3.fromRGB(30, 20, 40)
	ground.Material = Enum.Material.Slate
	ground.Parent = map

	-- Path folder
	local pathFolder = Instance.new("Folder"); pathFolder.Name = "Path"; pathFolder.Parent = map
	local wpFolder = Instance.new("Folder"); wpFolder.Name = "Waypoints"; wpFolder.Parent = pathFolder

	-- 12 waypoints (camino en S)
	local positions = {
		Vector3.new(-80, 1, 0),   -- 1: spawn
		Vector3.new(-60, 1, 0),   -- 2
		Vector3.new(-40, 1, 0),   -- 3
		Vector3.new(-20, 1, 0),   -- 4: curva
		Vector3.new(-20, 1, 20),  -- 5
		Vector3.new(-20, 1, 40),  -- 6
		Vector3.new(0,   1, 40),  -- 7: curva
		Vector3.new(20,  1, 40),  -- 8
		Vector3.new(40,  1, 40),  -- 9
		Vector3.new(40,  1, 20),  -- 10: curva
		Vector3.new(40,  1, 0),   -- 11
		Vector3.new(60,  1, 0),   -- 12: final -> barrera
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

	-- Segmentos visuales del camino
	for i = 1, #positions - 1 do
		local p1, p2 = positions[i], positions[i + 1]
		local mid = (p1 + p2) / 2
		local seg = Instance.new("Part")
		seg.Name = "Seg_" .. i
		seg.Anchored = true
		seg.CanCollide = false
		seg.Color = Color3.fromRGB(45, 25, 70)
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

	-- Build zones (10)
	local bzFolder = Instance.new("Folder"); bzFolder.Name = "BuildZones"; bzFolder.Parent = map

	local bzPositions = {
		Vector3.new(-60, 0.1,  9),
		Vector3.new(-40, 0.1, -9),
		Vector3.new(-28, 0.1, 10),
		Vector3.new(-28, 0.1, 32),
		Vector3.new(-10, 0.1, 48),
		Vector3.new(10,  0.1, 48),
		Vector3.new(30,  0.1, 32),
		Vector3.new(48,  0.1, 30),
		Vector3.new(48,  0.1,  9),
		Vector3.new(52,  0.1, -9),
	}

	for i, pos in ipairs(bzPositions) do
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

	-- Base
	local baseFolder = Instance.new("Folder"); baseFolder.Name = "Base"; baseFolder.Parent = map

	-- Barrera
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

	-- Vault floor
	local vault = Instance.new("Part")
	vault.Name = "Vault"
	vault.Size = Vector3.new(18, 0.4, 18)
	vault.Position = Vector3.new(80, 0.2, 0)
	vault.Anchored = true
	vault.Color = Color3.fromRGB(0, 60, 50)
	vault.Material = Enum.Material.DiamondPlate
	vault.Parent = baseFolder

	-- Core
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

	-- Entity folders
	for _, name in ipairs({"ActiveBrainrots", "ActiveDefenses"}) do
		if not workspace:FindFirstChild(name) then
			local f = Instance.new("Folder"); f.Name = name; f.Parent = workspace
		end
	end

	-----------------------------------------------------------------------
	-- ILUMINACION
	-----------------------------------------------------------------------
	Lighting.Ambient = Color3.fromRGB(25, 15, 45)
	Lighting.OutdoorAmbient = Color3.fromRGB(35, 25, 55)
	Lighting.Brightness = 0.8
	Lighting.ClockTime = 22
	Lighting.FogEnd = 350
	Lighting.FogColor = Color3.fromRGB(8, 4, 18)

	-- Skybox
	if not Lighting:FindFirstChildOfClass("Sky") then
		local sky = Instance.new("Sky")
		sky.SkyboxBk = ""; sky.SkyboxDn = ""; sky.SkyboxFt = ""
		sky.SkyboxLf = ""; sky.SkyboxRt = ""; sky.SkyboxUp = ""
		sky.StarCount = 3000
		sky.CelestialBodiesShown = false
		sky.Parent = Lighting
	end

	-- Post-processing
	if not Lighting:FindFirstChildOfClass("BloomEffect") then
		local bloom = Instance.new("BloomEffect")
		bloom.Intensity = 0.4; bloom.Size = 24; bloom.Threshold = 1.5
		bloom.Parent = Lighting
	end

	if not Lighting:FindFirstChildOfClass("ColorCorrectionEffect") then
		local cc = Instance.new("ColorCorrectionEffect")
		cc.TintColor = Color3.fromRGB(215, 205, 255)
		cc.Contrast = 0.1; cc.Saturation = 0.15
		cc.Parent = Lighting
	end

	print("[MapSetup] Mapa generado: 12 wp, 10 zones, base completa")
end

CreateMap()
