-- DefenseManager.lua
-- Gestiona colocación, targeting, daño y venta de defensas
-- Ubicación: ServerScriptService/Systems/DefenseManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefenseConfig = require(ReplicatedStorage.Modules.DefenseConfig)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local BrainrotManager = nil -- Se inyecta en Init para evitar circular
local CaptureManager = nil  -- Se inyecta en Init

local DefenseManager = {}

-- Estado
local activeDefenses: {[string]: any} = {}  -- id -> defense data
local defenseModels: {[string]: BasePart} = {}
local occupiedZones: {[string]: boolean} = {} -- zoneName -> true
local nextDefenseId = 1
local activeFolder: Folder = nil
local Events = nil

-- Callbacks
local onDefenseSold = nil

function DefenseManager.Init(brainrotMgr, captureMgr)
	BrainrotManager = brainrotMgr
	CaptureManager = captureMgr

	activeFolder = workspace:FindFirstChild("ActiveDefenses")
	if not activeFolder then
		activeFolder = Instance.new("Folder")
		activeFolder.Name = "ActiveDefenses"
		activeFolder.Parent = workspace
	end

	Events = ReplicatedStorage:FindFirstChild("Events")
end

function DefenseManager.OnDefenseSold(callback)
	onDefenseSold = callback
end

-- Validar si una posición está en una zona de construcción válida y disponible
function DefenseManager.FindValidZone(position: Vector3): (BasePart?, string?)
	local buildZones = workspace.Map:FindFirstChild("BuildZones")
	if not buildZones then return nil, "No hay zonas de construcción" end

	local closestZone = nil
	local closestDist = GameConfig.BUILD_ZONE_RADIUS

	for _, zone in ipairs(buildZones:GetChildren()) do
		if zone:IsA("BasePart") and not occupiedZones[zone.Name] then
			local dist = (zone.Position - position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestZone = zone
			end
		end
	end

	if not closestZone then
		return nil, "No hay zona válida cercana o está ocupada"
	end

	return closestZone, nil
end

-- Intentar colocar una defensa (llamado desde RemoteEvent)
function DefenseManager.TryPlace(player: Player, defenseType: string, position: Vector3): (boolean, string?)
	-- Validar tipo
	local defConfig = DefenseConfig.Defenses[defenseType]
	if not defConfig then
		return false, "Tipo de defensa inválido"
	end

	-- Validar costo
	local stats = DefenseConfig.GetStats(defenseType, 1)
	if not stats then return false, "Config inválida" end

	-- Verificar que EconomyManager tiene fondos (se checa externamente)
	-- Aquí solo validamos placement

	-- Validar límite de defensas
	local count = 0
	for _ in pairs(activeDefenses) do count = count + 1 end
	if count >= GameConfig.MAX_DEFENSES then
		return false, "Límite de defensas alcanzado"
	end

	-- Encontrar zona válida
	local zone, err = DefenseManager.FindValidZone(position)
	if not zone then
		return false, err
	end

	-- Colocar defensa
	local id = "def_" .. nextDefenseId
	nextDefenseId = nextDefenseId + 1

	local defense = {
		id = id,
		defenseType = defenseType,
		level = 1,
		position = zone.Position + Vector3.new(0, defConfig.size.Y / 2 + 0.1, 0),
		zoneName = zone.Name,
		owner = player.UserId,
		cooldownTimer = 0,
		stats = stats,
	}

	activeDefenses[id] = defense
	occupiedZones[zone.Name] = true

	-- Crear visual
	local part = Instance.new("Part")
	part.Name = id
	part.Size = defConfig.size
	part.Anchored = true
	part.CanCollide = false
	part.Color = defConfig.color
	part.Material = defConfig.material
	part.Position = defense.position
	part.Parent = activeFolder

	-- Label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(4, 0, 0.6, 0)
	billboard.StudsOffset = Vector3.new(0, defConfig.size.Y / 2 + 1, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = defConfig.displayName .. " Lv." .. defense.level
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	-- Indicador de rango (circle en el suelo)
	local rangeIndicator = Instance.new("Part")
	rangeIndicator.Name = "RangeIndicator"
	rangeIndicator.Shape = Enum.PartType.Cylinder
	rangeIndicator.Size = Vector3.new(0.1, stats.range * 2, stats.range * 2)
	rangeIndicator.CFrame = CFrame.new(defense.position.X, 0.15, defense.position.Z)
		* CFrame.Angles(0, 0, math.rad(90))
	rangeIndicator.Anchored = true
	rangeIndicator.CanCollide = false
	rangeIndicator.Color = defConfig.color
	rangeIndicator.Transparency = 0.85
	rangeIndicator.Material = Enum.Material.Neon
	rangeIndicator.Parent = part

	defenseModels[id] = part

	-- Notificar
	if Events then
		Events.DefensePlaced:FireAllClients({
			id = id,
			defenseType = defenseType,
			position = defense.position,
			level = 1,
		})
	end

	return true, nil
end

-- Vender defensa
function DefenseManager.TrySell(player: Player, defenseId: string): (boolean, number)
	local defense = activeDefenses[defenseId]
	if not defense then return false, 0 end
	if defense.owner ~= player.UserId then return false, 0 end

	local totalCost = DefenseConfig.GetTotalCost(defense.defenseType, defense.level)
	local refund = math.floor(totalCost * GameConfig.SELL_REFUND_RATE)

	-- Liberar zona
	occupiedZones[defense.zoneName] = nil

	-- Remover visual
	local model = defenseModels[defenseId]
	if model then
		model:Destroy()
		defenseModels[defenseId] = nil
	end

	activeDefenses[defenseId] = nil

	if onDefenseSold then
		onDefenseSold(defenseId, refund, player)
	end

	return true, refund
end

-- Obtener costo de la defensa
function DefenseManager.GetPlacementCost(defenseType: string): number
	local stats = DefenseConfig.GetStats(defenseType, 1)
	if not stats then return 999999 end
	return stats.cost
end

-- Update loop: targeting y daño (llamado desde Heartbeat)
function DefenseManager.Update(dt: number)
	local allBrainrots = BrainrotManager.GetAllActive()

	for id, defense in pairs(activeDefenses) do
		local defConfig = DefenseConfig.Defenses[defense.defenseType]
		if not defConfig then continue end

		local stats = defense.stats
		local pos = defense.position

		-- Update cooldown
		if defense.cooldownTimer > 0 then
			defense.cooldownTimer = defense.cooldownTimer - dt
		end

		-- Buscar targets en rango
		if defense.defenseType == "LaserTurret" then
			DefenseManager._UpdateLaserTurret(defense, pos, stats, allBrainrots, dt)
		elseif defense.defenseType == "IceTrap" then
			DefenseManager._UpdateIceTrap(defense, pos, stats, allBrainrots, dt)
		elseif defense.defenseType == "CaptureModule" then
			DefenseManager._UpdateCaptureModule(defense, pos, stats, allBrainrots, dt)
		end
	end
end

-- Torreta Láser: daño continuo al más cercano
function DefenseManager._UpdateLaserTurret(defense, pos, stats, allBrainrots, dt)
	local closestId = nil
	local closestDist = stats.range

	for brId, br in pairs(allBrainrots) do
		if br.alive then
			local dist = (br.position - pos).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestId = brId
			end
		end
	end

	-- Actualizar visual del beam
	local model = defenseModels[defense.id]
	if model then
		local beam = model:FindFirstChild("LaserBeam")
		if closestId then
			local target = allBrainrots[closestId]
			if not beam then
				-- Crear beam visual
				local att0 = model:FindFirstChild("Att0")
				if not att0 then
					att0 = Instance.new("Attachment")
					att0.Name = "Att0"
					att0.Parent = model
				end

				local att1Part = Instance.new("Part")
				att1Part.Name = "BeamTarget"
				att1Part.Size = Vector3.new(0.1, 0.1, 0.1)
				att1Part.Transparency = 1
				att1Part.Anchored = true
				att1Part.CanCollide = false
				att1Part.Position = target.position
				att1Part.Parent = model

				local att1 = Instance.new("Attachment")
				att1.Name = "Att1"
				att1.Parent = att1Part

				beam = Instance.new("Beam")
				beam.Name = "LaserBeam"
				beam.Attachment0 = att0
				beam.Attachment1 = att1
				beam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
				beam.Width0 = 0.3
				beam.Width1 = 0.15
				beam.FaceCamera = true
				beam.LightEmission = 1
				beam.Parent = model
			else
				-- Mover target del beam
				local beamTarget = model:FindFirstChild("BeamTarget")
				if beamTarget then
					beamTarget.Position = target.position
				end
			end

			-- Aplicar daño
			local dps = stats.damage
			BrainrotManager.Damage(closestId, dps * dt)
		else
			-- Sin target: remover beam
			if beam then beam:Destroy() end
			local beamTarget = model:FindFirstChild("BeamTarget")
			if beamTarget then beamTarget:Destroy() end
		end
	end
end

-- Trampa de Hielo: slow en área
function DefenseManager._UpdateIceTrap(defense, pos, stats, allBrainrots, dt)
	for brId, br in pairs(allBrainrots) do
		if br.alive then
			local dist = (br.position - pos).Magnitude
			if dist <= stats.range then
				BrainrotManager.ApplySlow(brId, stats.slowFactor, stats.duration)
			end
		end
	end
end

-- Módulo de Captura: intenta capturar brainrots debilitados
function DefenseManager._UpdateCaptureModule(defense, pos, stats, allBrainrots, dt)
	if defense.cooldownTimer > 0 then return end

	-- Buscar brainrot con menor HP% en rango
	local bestId = nil
	local bestHPRatio = 1.0

	for brId, br in pairs(allBrainrots) do
		if br.alive then
			local dist = (br.position - pos).Magnitude
			if dist <= stats.range then
				local hpRatio = br.hp / br.maxHP
				if hpRatio <= stats.hpThreshold and hpRatio < bestHPRatio then
					bestHPRatio = hpRatio
					bestId = brId
				end
			end
		end
	end

	if bestId and CaptureManager then
		local success = CaptureManager.TryCapture(bestId, stats.captureMultiplier)
		if success then
			defense.cooldownTimer = stats.cooldown
		else
			defense.cooldownTimer = stats.cooldown * 0.5 -- Cooldown menor si falló
		end
	end
end

-- Limpiar todo
function DefenseManager.ClearAll()
	for id, _ in pairs(activeDefenses) do
		local model = defenseModels[id]
		if model then model:Destroy() end
	end
	activeDefenses = {}
	defenseModels = {}
	occupiedZones = {}
end

-- Obtener defensa por ID
function DefenseManager.GetDefense(id: string): any?
	return activeDefenses[id]
end

return DefenseManager
