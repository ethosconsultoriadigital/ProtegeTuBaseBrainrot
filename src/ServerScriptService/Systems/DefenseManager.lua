-- DefenseManager
-- Colocación, targeting, comportamiento de LaserTurret/IceTrap/CaptureModule, venta
-- Ubicación: ServerScriptService > Systems > DefenseManager (ModuleScript)
--
-- Responsabilidades:
--   - Validar y ejecutar colocación en build zones
--   - Snap a zona más cercana dentro de BUILD_ZONE_SNAP_RADIUS
--   - Una defensa por zona, máximo MAX_DEFENSES en total
--   - LaserTurret: DPS continuo al brainrot más cercano en rango
--   - IceTrap: slow de área a todos los brainrots en rango
--   - CaptureModule: intenta capturar brainrots con HP < threshold en rango
--   - Venta con reembolso del 50%
--   - Visual simple: Part + label + indicador de rango
--
-- NO maneja: upgrades (futuro), UI, economía (solo reporta costos).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefenseConfig = require(ReplicatedStorage.Modules.DefenseConfig)
local GameConfig    = require(ReplicatedStorage.Modules.GameConfig)

local DefenseManager = {}

-----------------------------------------------------------------------
-- DEPENDENCIAS (inyectadas en Init)
-----------------------------------------------------------------------
local BrainrotManager = nil
local CaptureManager  = nil
local Events = nil

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local activeDefenses: {[string]: any} = {}
local defenseModels: {[string]: BasePart} = {}
local occupiedZones: {[string]: boolean} = {}
local nextId = 1
local folder: Folder = nil

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function DefenseManager.Init(brainrotMgr, captureMgr)
	BrainrotManager = brainrotMgr
	CaptureManager  = captureMgr

	if not BrainrotManager then
		warn("[DefenseManager] BrainrotManager nil — targeting deshabilitado")
	end
	if not CaptureManager then
		warn("[DefenseManager] CaptureManager nil — CaptureModule no podra capturar")
	end

	folder = workspace:FindFirstChild("ActiveDefenses")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "ActiveDefenses"
		folder.Parent = workspace
	end
	Events = ReplicatedStorage:FindFirstChild("Events")
	if not Events then
		warn("[DefenseManager] ReplicatedStorage.Events no encontrado — sin notificacion de placement")
	end

	-- Verificar que existan BuildZones (sin esto, TryPlace siempre fallara)
	local buildZones = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BuildZones")
	if not buildZones or #buildZones:GetChildren() == 0 then
		warn("[DefenseManager] Map.BuildZones no encontrado o vacio — no se podran colocar defensas")
	end

	print("[DefenseManager] Init OK")
end

-----------------------------------------------------------------------
-- ZONE FINDING
-- Busca la build zone más cercana que no esté ocupada.
-----------------------------------------------------------------------
function DefenseManager.FindValidZone(position: Vector3): (BasePart?, string?)
	local buildZones = workspace:FindFirstChild("Map")
		and workspace.Map:FindFirstChild("BuildZones")
	if not buildZones then return nil, "No hay BuildZones en el mapa" end

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

	if not best then return nil, "No hay zona libre cerca" end
	return best, nil
end

-----------------------------------------------------------------------
-- PLACEMENT COST (para que MatchManager/EconomyManager validen)
-----------------------------------------------------------------------
function DefenseManager.GetPlacementCost(defenseType: string): number
	local stats = DefenseConfig.GetStats(defenseType, 1)
	return stats and stats.cost or 999999
end

-----------------------------------------------------------------------
-- PLACEMENT
-- Validaciones server-side:
--   1. Tipo de defensa válido
--   2. Límite global de defensas no excedido
--   3. Zona de build válida y no ocupada
-- Retorna (success, errorMsg)
-----------------------------------------------------------------------
function DefenseManager.TryPlace(_player: Player, defenseType: string, position: Vector3): (boolean, string?)
	local defCfg = DefenseConfig.Defenses[defenseType]
	if not defCfg then return false, "Tipo de defensa invalido: " .. tostring(defenseType) end

	-- Límite global
	local count = 0
	for _ in pairs(activeDefenses) do count += 1 end
	if count >= GameConfig.MAX_DEFENSES then return false, "Limite de defensas alcanzado (" .. GameConfig.MAX_DEFENSES .. ")" end

	-- Buscar zona válida
	local zone, err = DefenseManager.FindValidZone(position)
	if not zone then return false, err end

	local stats = DefenseConfig.GetStats(defenseType, 1)
	if not stats then return false, "Stats no encontrados" end

	-- Crear defensa
	local id = "def_" .. nextId
	nextId += 1

	local pos = zone.Position + Vector3.new(0, defCfg.size.Y / 2 + 0.1, 0)

	activeDefenses[id] = {
		id            = id,
		defenseType   = defenseType,
		level         = 1,
		position      = pos,
		zoneName      = zone.Name,
		owner         = _player.UserId,
		cooldownTimer = 0,
		stats         = stats,
	}
	occupiedZones[zone.Name] = true

	-- Visual: Part principal
	local part = Instance.new("Part")
	part.Name = id
	part.Size = defCfg.size
	part.Anchored = true
	part.CanCollide = false
	part.Color = defCfg.color
	part.Material = defCfg.material
	part.Position = pos
	part.Parent = folder

	-- Label con nombre
	local bb = Instance.new("BillboardGui")
	bb.Name = "Label"
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

	-- Indicador de rango (cilindro plano en el suelo)
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

	-- Notificar clientes
	if Events then
		Events.DefensePlaced:FireAllClients({
			id = id, defenseType = defenseType, position = pos, level = 1,
		})
	end

	print("[Defense] " .. defCfg.displayName .. " colocada en " .. zone.Name
		.. " (" .. count + 1 .. "/" .. GameConfig.MAX_DEFENSES .. ")")
	return true, nil
end

-----------------------------------------------------------------------
-- SELL
-- Retorna (success, refundAmount)
-----------------------------------------------------------------------
function DefenseManager.TrySell(player: Player, defenseId: string): (boolean, number)
	local def = activeDefenses[defenseId]
	if not def then return false, 0 end
	if def.owner ~= player.UserId then return false, 0 end

	local totalCost = DefenseConfig.GetTotalCost(def.defenseType, def.level)
	local refund = math.floor(totalCost * GameConfig.SELL_REFUND_RATE)

	-- Liberar zona
	occupiedZones[def.zoneName] = nil

	-- Limpiar visual
	local m = defenseModels[defenseId]
	if m then m:Destroy() end
	defenseModels[defenseId] = nil

	-- Limpiar data
	activeDefenses[defenseId] = nil

	print("[Defense] Vendida: " .. defenseId .. " — reembolso: $" .. refund)
	return true, refund
end

-----------------------------------------------------------------------
-- UPDATE (llamar cada frame desde MatchManager)
-----------------------------------------------------------------------
function DefenseManager.Update(dt: number)
	local allBR = BrainrotManager.GetAllActive()

	for _, def in pairs(activeDefenses) do
		-- Cooldown global por defensa
		if def.cooldownTimer > 0 then
			def.cooldownTimer -= dt
		end

		local t = def.defenseType
		if t == "LaserTurret" then
			DefenseManager._TickLaser(def, allBR, dt)
		elseif t == "IceTrap" then
			DefenseManager._TickIce(def, allBR)
		elseif t == "CaptureModule" then
			DefenseManager._TickCapture(def, allBR)
		end
	end
end

-----------------------------------------------------------------------
-- LASER TURRET: DPS continuo al brainrot más cercano en rango
-- Targeting: Nearest
-- Daño: stats.damage × dt (DPS continuo)
-- Visual: Beam rojo entre torreta y target
-----------------------------------------------------------------------
function DefenseManager._TickLaser(def, allBR, dt)
	local stats = def.stats
	local pos = def.position
	local closestId, closestDist = nil, stats.range

	for brId, br in pairs(allBR) do
		if br.alive and br.position then
			local d = (br.position - pos).Magnitude
			if d < closestDist then
				closestDist = d
				closestId = brId
			end
		end
	end

	local model = defenseModels[def.id]
	if not model then return end

	if closestId then
		local target = allBR[closestId]

		-- Crear o actualizar beam visual
		local beam = model:FindFirstChild("LaserBeam")
		if not beam then
			-- Attachment en la torreta
			local a0 = model:FindFirstChild("A0")
			if not a0 then
				a0 = Instance.new("Attachment")
				a0.Name = "A0"
				a0.Parent = model
			end

			-- Part invisible como target del beam
			local bt = Instance.new("Part")
			bt.Name = "BeamTarget"
			bt.Size = Vector3.new(0.1, 0.1, 0.1)
			bt.Transparency = 1
			bt.Anchored = true
			bt.CanCollide = false
			bt.Position = target.position
			bt.Parent = model

			local a1 = Instance.new("Attachment")
			a1.Name = "A1"
			a1.Parent = bt

			beam = Instance.new("Beam")
			beam.Name = "LaserBeam"
			beam.Attachment0 = a0
			beam.Attachment1 = a1
			beam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
			beam.Width0 = 0.3
			beam.Width1 = 0.12
			beam.FaceCamera = true
			beam.LightEmission = 1
			beam.Parent = model
		else
			-- Mover el target del beam
			local bt = model:FindFirstChild("BeamTarget")
			if bt then bt.Position = target.position end
		end

		-- Aplicar daño continuo (DPS × dt)
		BrainrotManager.Damage(closestId, stats.damage * dt)
	else
		-- Sin target → limpiar beam
		local beam = model:FindFirstChild("LaserBeam")
		if beam then beam:Destroy() end
		local bt = model:FindFirstChild("BeamTarget")
		if bt then bt:Destroy() end
	end
end

-----------------------------------------------------------------------
-- ICE TRAP: slow de área a todos en rango
-- Targeting: Area (todos los brainrots en rango)
-- Efecto: aplica slowFactor durante slowDuration
-----------------------------------------------------------------------
function DefenseManager._TickIce(def, allBR)
	local stats = def.stats
	local pos = def.position

	for brId, br in pairs(allBR) do
		if br.alive and br.position then
			if (br.position - pos).Magnitude <= stats.range then
				BrainrotManager.ApplySlow(brId, stats.slowFactor, stats.slowDuration)
			end
		end
	end
end

-----------------------------------------------------------------------
-- CAPTURE MODULE: intenta capturar el brainrot con menos HP en rango
-- Targeting: LowestHP (prioriza el más débil)
-- Condición: HP < hpThreshold (30% Lv1)
-- Cooldown: 4s entre intentos
-- Delega el roll de probabilidad a CaptureManager.TryCapture()
-----------------------------------------------------------------------
function DefenseManager._TickCapture(def, allBR)
	if def.cooldownTimer > 0 then return end

	local stats = def.stats
	local pos = def.position
	local bestId: string? = nil
	local bestRatio = 1.0

	for brId, br in pairs(allBR) do
		if br.alive and br.position then
			local d = (br.position - pos).Magnitude
			if d <= stats.range then
				local ratio = br.hp / br.maxHP
				if ratio <= stats.hpThreshold and ratio < bestRatio then
					bestRatio = ratio
					bestId = brId
				end
			end
		end
	end

	if bestId and CaptureManager then
		local ok = CaptureManager.TryCapture(bestId, stats.captureMult)
		-- Cooldown: full si capturó, parcial si falló el roll
		def.cooldownTimer = ok and stats.cooldown or (stats.cooldown * 0.4)
	end
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function DefenseManager.GetDefense(id: string)
	return activeDefenses[id]
end

function DefenseManager.GetAllDefenses()
	return activeDefenses
end

function DefenseManager.GetDefenseCount(): number
	local c = 0
	for _ in pairs(activeDefenses) do c += 1 end
	return c
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

return DefenseManager
