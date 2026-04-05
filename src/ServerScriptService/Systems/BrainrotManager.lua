-- BrainrotManager
-- Spawn, movimiento, daño, muerte y visuals de brainrots
-- Ubicación: ServerScriptService > Systems > BrainrotManager (ModuleScript)
--
-- Responsabilidades:
--   - Cargar waypoints del mapa una vez
--   - Crear brainrots con stats de BrainrotConfig
--   - Mover cada uno con PathFollower individual
--   - Gestionar ciclo de vida (spawn → move → die/reachEnd)
--   - Exponer hooks para daño externo, slow, captura
--
-- NO maneja: economia, barrera, captura, UI. Solo la entidad.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotConfig = require(ReplicatedStorage.Modules.BrainrotConfig)
local PathFollower   = require(script.Parent.Parent.AI.PathFollower)

local BrainrotManager = {}

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local active: {[string]: any} = {}     -- id → brainrot data
local models: {[string]: BasePart} = {} -- id → Part visual
local followers: {[string]: any} = {}   -- id → PathFollower instance
local nextId = 1
local folder: Folder = nil
local Events = nil

-- Waypoints (cargados una vez del mapa)
local waypoints: {Vector3} = {}
local waypointsLoaded = false

-- Callbacks (se registran desde MatchManager)
local onDiedCallbacks: {(id: string, brData: any, killedByDamage: boolean) -> ()} = {}
local onReachedEndCallbacks: {(id: string, brData: any) -> ()} = {}

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function BrainrotManager.Init()
	folder = workspace:FindFirstChild("ActiveBrainrots")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "ActiveBrainrots"
		folder.Parent = workspace
	end
	Events = ReplicatedStorage:FindFirstChild("Events")
	BrainrotManager._LoadWaypoints()
	print("[BrainrotManager] Init OK — " .. #waypoints .. " waypoints")
end

function BrainrotManager._LoadWaypoints()
	if waypointsLoaded then return end

	local wpFolder = workspace:FindFirstChild("Map")
		and workspace.Map:FindFirstChild("Path")
		and workspace.Map.Path:FindFirstChild("Waypoints")

	if not wpFolder then
		warn("[BrainrotManager] Map.Path.Waypoints no encontrado")
		return
	end

	-- Leer waypoints en orden numerico
	local parts = {}
	for _, child in ipairs(wpFolder:GetChildren()) do
		if child:IsA("BasePart") then
			local n = tonumber(child.Name)
			if n then parts[n] = child.Position end
		end
	end

	waypoints = {}
	local i = 1
	while parts[i] do
		table.insert(waypoints, parts[i])
		i += 1
	end

	waypointsLoaded = true
end

-----------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------
function BrainrotManager.OnBrainrotDied(cb)
	table.insert(onDiedCallbacks, cb)
end

function BrainrotManager.OnBrainrotReachedEnd(cb)
	table.insert(onReachedEndCallbacks, cb)
end

-----------------------------------------------------------------------
-- SPAWN
-----------------------------------------------------------------------
function BrainrotManager.Spawn(className: string, rarityName: string, hpOverride: number?, isBoss: boolean?): string?
	local stats = BrainrotConfig.GetStats(className, rarityName)
	if not stats then
		warn("[BrainrotManager] Stats invalidos para", className, rarityName)
		return nil
	end
	if #waypoints < 2 then
		warn("[BrainrotManager] No hay waypoints suficientes")
		return nil
	end

	local id = "br_" .. nextId
	nextId += 1

	local hp = math.floor(stats.maxHP * (hpOverride or 1.0))

	-- Data de la entidad (server-authoritative)
	local br = {
		id            = id,
		className     = className,
		rarityName    = rarityName,
		maxHP         = hp,
		hp            = hp,
		speed         = stats.speed,
		barrierDamage = stats.barrierDamage,
		killReward    = stats.killReward,
		captureBonus  = stats.captureBonus,
		captureRate   = stats.captureRate,
		vaultValue    = stats.vaultValue,
		vaultIncome   = stats.vaultIncome,
		stealTimeMult = stats.stealTimeMult,
		alive         = true,
		isBoss        = isBoss or false,
	}
	active[id] = br

	-- Visual
	local size = stats.size
	if isBoss then size = size * 1.8 end

	local part = Instance.new("Part")
	part.Name = id
	part.Size = size
	part.Shape = stats.shape
	part.Anchored = true
	part.CanCollide = false
	part.Color = stats.color
	part.Material = isBoss and Enum.Material.Neon or Enum.Material.SmoothPlastic
	part.Parent = folder

	-- HP bar (Gold+, bosses)
	if rarityName ~= "Normal" or isBoss then
		local bb = Instance.new("BillboardGui")
		bb.Name = "HPBar"
		bb.Size = UDim2.new(3, 0, 0.4, 0)
		bb.StudsOffset = Vector3.new(0, size.Y / 2 + 1.2, 0)
		bb.AlwaysOnTop = true
		bb.Parent = part

		local bg = Instance.new("Frame")
		bg.Name = "BG"
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		bg.BorderSizePixel = 0
		bg.Parent = bb
		Instance.new("UICorner", bg).CornerRadius = UDim.new(0.3, 0)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(1, 0, 1, 0)
		fill.BackgroundColor3 = stats.color
		fill.BorderSizePixel = 0
		fill.Parent = bg
		Instance.new("UICorner", fill).CornerRadius = UDim.new(0.3, 0)
	end

	-- Trail (Gold/Diamond)
	if stats.trailEnabled then
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, 0, -size.Z / 2)
		a0.Parent = part
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, 0, size.Z / 2)
		a1.Parent = part
		local trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Color = ColorSequence.new(stats.color)
		trail.Lifetime = 0.5
		trail.MinLength = 0.1
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		})
		trail.Parent = part
	end

	-- Glow
	if stats.glowEnabled or isBoss then
		local light = Instance.new("PointLight")
		light.Color = stats.color
		light.Brightness = isBoss and 3 or 1.5
		light.Range = isBoss and 16 or 8
		light.Parent = part
	end

	models[id] = part

	-- PathFollower individual
	local pf = PathFollower.new(part, waypoints, stats.speed)
	followers[id] = pf

	-- Notify clients
	if Events then
		Events.BrainrotSpawned:FireAllClients({
			id = id, class = className, rarity = rarityName, isBoss = br.isBoss,
		})
	end

	return id
end

-----------------------------------------------------------------------
-- DAMAGE (punto de integracion para DefenseManager y CaptureManager)
-----------------------------------------------------------------------
function BrainrotManager.Damage(id: string, amount: number): boolean
	local br = active[id]
	if not br or not br.alive then return false end

	br.hp = math.max(0, br.hp - amount)

	-- Actualizar HP bar visual
	local model = models[id]
	if model then
		local bb = model:FindFirstChild("HPBar")
		if bb then
			local bg = bb:FindFirstChild("BG")
			local fill = bg and bg:FindFirstChild("Fill")
			if fill then
				local ratio = br.hp / br.maxHP
				fill.Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0)
				if ratio > 0.5 then
					fill.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
				elseif ratio > 0.25 then
					fill.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
				else
					fill.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
				end
			end
		end
	end

	if br.hp <= 0 then
		br.alive = false
		for _, cb in ipairs(onDiedCallbacks) do cb(id, br, true) end
		BrainrotManager._Remove(id)
		return true -- murio
	end
	return false
end

-----------------------------------------------------------------------
-- SLOW (punto de integracion para IceTrap)
-----------------------------------------------------------------------
function BrainrotManager.ApplySlow(id: string, factor: number, duration: number)
	local br = active[id]
	if not br or not br.alive then return end

	local pf = followers[id]
	if pf then
		-- factor = 0.35 significa 35% de reduccion → mult = 0.65
		local newMult = math.max(0.1, 1.0 - factor)
		if newMult < pf:GetSpeedMultiplier() then
			pf:SetSpeedMultiplier(newMult)
		end
	end

	-- Registrar timer de slow en la entidad
	if not br._slowTimer or duration > br._slowTimer then
		br._slowTimer = duration
	end
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function BrainrotManager.Get(id: string)
	return active[id]
end

function BrainrotManager.GetAllActive(): {[string]: any}
	return active
end

function BrainrotManager.GetActiveCount(): number
	local c = 0
	for _, br in pairs(active) do
		if br.alive then c += 1 end
	end
	return c
end

function BrainrotManager.GetModel(id: string): BasePart?
	return models[id]
end

function BrainrotManager.GetPosition(id: string): Vector3?
	local m = models[id]
	return m and m.Position or nil
end

function BrainrotManager.GetFollower(id: string)
	return followers[id]
end

-----------------------------------------------------------------------
-- REMOVE / CLEAR
-----------------------------------------------------------------------
function BrainrotManager.Remove(id: string)
	BrainrotManager._Remove(id)
end

function BrainrotManager._Remove(id: string)
	-- Cleanup PathFollower
	local pf = followers[id]
	if pf then pf:Destroy() end
	followers[id] = nil

	-- Cleanup visual
	local m = models[id]
	if m then m:Destroy() end
	models[id] = nil

	-- Cleanup data
	active[id] = nil

	-- Notify clients
	if Events then
		Events.BrainrotDied:FireAllClients({ id = id })
	end
end

function BrainrotManager.ClearAll()
	for id in pairs(active) do
		local pf = followers[id]
		if pf then pf:Destroy() end
		local m = models[id]
		if m then m:Destroy() end
	end
	active = {}
	models = {}
	followers = {}
end

-----------------------------------------------------------------------
-- UPDATE (llamar cada frame desde MatchManager)
-----------------------------------------------------------------------
function BrainrotManager.Update(dt: number)
	for id, br in pairs(active) do
		if not br.alive then continue end

		-- Slow timer
		if br._slowTimer and br._slowTimer > 0 then
			br._slowTimer -= dt
			if br._slowTimer <= 0 then
				br._slowTimer = nil
				local pf = followers[id]
				if pf then pf:SetSpeedMultiplier(1.0) end
			end
		end

		-- Mover
		local pf = followers[id]
		if pf then
			pf:Update(dt)

			-- Sync position al data table (para que otros sistemas lean br.position)
			local m = models[id]
			if m then br.position = m.Position end

			if pf:IsFinished() then
				br.alive = false
				for _, cb in ipairs(onReachedEndCallbacks) do cb(id, br) end
				BrainrotManager._Remove(id)
			end
		end
	end
end

return BrainrotManager
