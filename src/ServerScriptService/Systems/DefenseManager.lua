-- DefenseManager
-- Colocacion, targeting, laser/ice/capture, venta
-- Ubicación: ServerScriptService > Systems > DefenseManager (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefenseConfig = require(ReplicatedStorage.Modules.DefenseConfig)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

-- Inyectados en Init
local BrainrotManager = nil
local CaptureManager = nil

local DefenseManager = {}

local activeDefenses: {[string]: any} = {}
local defenseModels: {[string]: BasePart} = {}
local occupiedZones: {[string]: boolean} = {}
local nextId = 1
local folder: Folder = nil
local Events = nil

function DefenseManager.Init(brainrotMgr, captureMgr)
	BrainrotManager = brainrotMgr
	CaptureManager  = captureMgr

	folder = workspace:FindFirstChild("ActiveDefenses")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "ActiveDefenses"
		folder.Parent = workspace
	end
	Events = ReplicatedStorage:FindFirstChild("Events")
end

-----------------------------------------------------------------------
-- ZONE FINDING
-----------------------------------------------------------------------
function DefenseManager.FindValidZone(position: Vector3): (BasePart?, string?)
	local buildZones = workspace.Map and workspace.Map:FindFirstChild("BuildZones")
	if not buildZones then return nil, "No BuildZones" end

	local best: BasePart? = nil
	local bestDist = GameConfig.BUILD_ZONE_SNAP_RADIUS

	for _, zone in ipairs(buildZones:GetChildren()) do
		if zone:IsA("BasePart") and not occupiedZones[zone.Name] then
			local d = (zone.Position - position).Magnitude
			if d < bestDist then
				bestDist = d
				best = zone
			end
		end
	end

	if not best then return nil, "Zona ocupada o lejana" end
	return best, nil
end

-----------------------------------------------------------------------
-- PLACEMENT
-----------------------------------------------------------------------
function DefenseManager.GetPlacementCost(defenseType: string): number
	local s = DefenseConfig.GetStats(defenseType, 1)
	return s and s.cost or 999999
end

function DefenseManager.TryPlace(player: Player, defenseType: string, position: Vector3): (boolean, string?)
	local defCfg = DefenseConfig.Defenses[defenseType]
	if not defCfg then return false, "Tipo invalido" end

	-- Limite
	local count = 0
	for _ in pairs(activeDefenses) do count += 1 end
	if count >= GameConfig.MAX_DEFENSES then return false, "Limite de defensas" end

	-- Zona
	local zone, err = DefenseManager.FindValidZone(position)
	if not zone then return false, err end

	local stats = DefenseConfig.GetStats(defenseType, 1)
	if not stats then return false, "Stats invalidos" end

	local id = "def_" .. nextId
	nextId += 1

	local pos = zone.Position + Vector3.new(0, defCfg.size.Y / 2 + 0.1, 0)

	activeDefenses[id] = {
		id           = id,
		defenseType  = defenseType,
		level        = 1,
		position     = pos,
		zoneName     = zone.Name,
		owner        = player.UserId,
		cooldownTimer = 0,
		stats        = stats,
	}
	occupiedZones[zone.Name] = true

	-- Visual
	local part = Instance.new("Part")
	part.Name = id
	part.Size = defCfg.size
	part.Anchored = true
	part.CanCollide = false
	part.Color = defCfg.color
	part.Material = defCfg.material
	part.Position = pos
	part.Parent = folder

	-- Label
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(4, 0, 0.6, 0)
	bb.StudsOffset = Vector3.new(0, defCfg.size.Y / 2 + 1, 0)
	bb.AlwaysOnTop = false
	bb.Parent = part

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = defCfg.displayName
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency = 0.4
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = bb

	-- Indicador de rango
	local rangeVal = stats.range or 10
	local ring = Instance.new("Part")
	ring.Name = "Range"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.08, rangeVal * 2, rangeVal * 2)
	ring.CFrame = CFrame.new(pos.X, 0.12, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.CanCollide = false
	ring.Color = defCfg.color
	ring.Transparency = 0.88
	ring.Material = Enum.Material.Neon
	ring.Parent = part

	defenseModels[id] = part

	if Events then
		Events.DefensePlaced:FireAllClients({
			id = id, defenseType = defenseType, position = pos, level = 1,
		})
	end
	return true, nil
end

-----------------------------------------------------------------------
-- SELL
-----------------------------------------------------------------------
function DefenseManager.TrySell(player: Player, defenseId: string): (boolean, number)
	local def = activeDefenses[defenseId]
	if not def then return false, 0 end
	if def.owner ~= player.UserId then return false, 0 end

	local totalCost = DefenseConfig.GetTotalCost(def.defenseType, def.level)
	local refund = math.floor(totalCost * GameConfig.SELL_REFUND_RATE)

	occupiedZones[def.zoneName] = nil
	local m = defenseModels[defenseId]
	if m then m:Destroy(); defenseModels[defenseId] = nil end
	activeDefenses[defenseId] = nil

	return true, refund
end

-----------------------------------------------------------------------
-- UPDATE (cada frame)
-----------------------------------------------------------------------
function DefenseManager.Update(dt: number)
	local allBR = BrainrotManager.GetAllActive()

	for _, def in pairs(activeDefenses) do
		if def.cooldownTimer > 0 then def.cooldownTimer -= dt end

		local t = def.defenseType
		if t == "LaserTurret" then
			DefenseManager._TickLaser(def, allBR, dt)
		elseif t == "IceTrap" then
			DefenseManager._TickIce(def, allBR, dt)
		elseif t == "CaptureModule" then
			DefenseManager._TickCapture(def, allBR, dt)
		end
	end
end

-----------------------------------------------------------------------
-- LASER: daño continuo al mas cercano
-----------------------------------------------------------------------
function DefenseManager._TickLaser(def, allBR, dt)
	local stats = def.stats
	local pos = def.position
	local closestId, closestDist = nil, stats.range

	for brId, br in pairs(allBR) do
		if br.alive then
			local d = (br.position - pos).Magnitude
			if d < closestDist then closestDist = d; closestId = brId end
		end
	end

	local model = defenseModels[def.id]
	if not model then return end

	if closestId then
		local target = allBR[closestId]

		-- Beam visual
		local beam = model:FindFirstChild("LaserBeam")
		if not beam then
			local a0 = model:FindFirstChild("A0")
			if not a0 then
				a0 = Instance.new("Attachment"); a0.Name = "A0"; a0.Parent = model
			end
			local tp = Instance.new("Part")
			tp.Name = "BT"; tp.Size = Vector3.new(0.1,0.1,0.1)
			tp.Transparency = 1; tp.Anchored = true; tp.CanCollide = false
			tp.Position = target.position; tp.Parent = model
			local a1 = Instance.new("Attachment"); a1.Name = "A1"; a1.Parent = tp

			beam = Instance.new("Beam")
			beam.Name = "LaserBeam"
			beam.Attachment0 = a0; beam.Attachment1 = a1
			beam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
			beam.Width0 = 0.3; beam.Width1 = 0.12
			beam.FaceCamera = true; beam.LightEmission = 1
			beam.Parent = model
		else
			local bt = model:FindFirstChild("BT")
			if bt then bt.Position = target.position end
		end

		BrainrotManager.Damage(closestId, stats.damage * dt)
	else
		-- Sin target
		local beam = model:FindFirstChild("LaserBeam")
		if beam then beam:Destroy() end
		local bt = model:FindFirstChild("BT")
		if bt then bt:Destroy() end
	end
end

-----------------------------------------------------------------------
-- ICE: slow en area
-----------------------------------------------------------------------
function DefenseManager._TickIce(def, allBR, _dt)
	local stats = def.stats
	local pos = def.position
	for brId, br in pairs(allBR) do
		if br.alive and (br.position - pos).Magnitude <= stats.range then
			BrainrotManager.ApplySlow(brId, stats.slowFactor, stats.slowDuration)
		end
	end
end

-----------------------------------------------------------------------
-- CAPTURE: intenta capturar debilitados
-----------------------------------------------------------------------
function DefenseManager._TickCapture(def, allBR, _dt)
	if def.cooldownTimer > 0 then return end

	local stats = def.stats
	local pos = def.position
	local bestId, bestRatio = nil, 1.0

	for brId, br in pairs(allBR) do
		if br.alive then
			local d = (br.position - pos).Magnitude
			if d <= stats.range then
				local ratio = br.hp / br.maxHP
				if ratio <= stats.hpThreshold and ratio < bestRatio then
					bestRatio = ratio; bestId = brId
				end
			end
		end
	end

	if bestId and CaptureManager then
		local ok = CaptureManager.TryCapture(bestId, stats.captureMult)
		def.cooldownTimer = ok and stats.cooldown or (stats.cooldown * 0.4)
	end
end

-----------------------------------------------------------------------
-- CLEAR
-----------------------------------------------------------------------
function DefenseManager.ClearAll()
	for id in pairs(activeDefenses) do
		local m = defenseModels[id]
		if m then m:Destroy() end
	end
	activeDefenses = {}
	defenseModels = {}
	occupiedZones = {}
end

function DefenseManager.GetDefense(id: string) return activeDefenses[id] end

return DefenseManager
