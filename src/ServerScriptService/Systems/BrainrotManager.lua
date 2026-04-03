-- BrainrotManager
-- Spawning, movimiento, daño, muerte y visuals de brainrots
-- Ubicación: ServerScriptService > Systems > BrainrotManager (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BrainrotConfig = require(ReplicatedStorage.Modules.BrainrotConfig)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local PathFollower = require(script.Parent.Parent.AI.PathFollower)

local BrainrotManager = {}

local active: {[string]: any} = {}
local models: {[string]: BasePart} = {}
local nextId = 1
local folder: Folder = nil
local Events = nil

-- Callbacks externos
local onDied = nil
local onReachedEnd = nil

function BrainrotManager.Init()
	folder = workspace:FindFirstChild("ActiveBrainrots")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "ActiveBrainrots"
		folder.Parent = workspace
	end
	Events = ReplicatedStorage:FindFirstChild("Events")
	PathFollower.LoadWaypoints()
end

function BrainrotManager.OnBrainrotDied(cb) onDied = cb end
function BrainrotManager.OnBrainrotReachedEnd(cb) onReachedEnd = cb end

-----------------------------------------------------------------------
-- SPAWN
-----------------------------------------------------------------------
function BrainrotManager.Spawn(className: string, rarityName: string, hpOverride: number?, isBoss: boolean?): string?
	local stats = BrainrotConfig.GetStats(className, rarityName)
	if not stats then return nil end

	local id = "br_" .. nextId
	nextId += 1

	local spawnPos = PathFollower.GetSpawnPosition()
	local hp = stats.maxHP * (hpOverride or 1.0)

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
		position      = spawnPos,
		pathIndex     = 1,
		slowAmount    = 0,
		slowTimer     = 0,
		alive         = true,
		isBoss        = isBoss or false,
	}
	active[id] = br

	-- Crear visual
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
	part.Position = spawnPos
	part.Parent = folder

	-- Barra HP (Gold+ y bosses)
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

	-- Trail para Gold/Diamond
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

	if Events then
		Events.BrainrotSpawned:FireAllClients({
			id = id, class = className, rarity = rarityName, isBoss = br.isBoss,
		})
	end
	return id
end

-----------------------------------------------------------------------
-- DAMAGE
-----------------------------------------------------------------------
function BrainrotManager.Damage(id: string, amount: number): boolean
	local br = active[id]
	if not br or not br.alive then return false end

	br.hp = br.hp - amount

	-- Actualizar HP bar
	local model = models[id]
	if model then
		local bb = model:FindFirstChild("HPBar")
		if bb then
			local bg = bb:FindFirstChild("BG")
			local fill = bg and bg:FindFirstChild("Fill")
			if fill then
				local ratio = math.clamp(br.hp / br.maxHP, 0, 1)
				fill.Size = UDim2.new(ratio, 0, 1, 0)
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
		BrainrotManager._Remove(id)
		if onDied then onDied(id, br, true) end
		return true
	end
	return false
end

-----------------------------------------------------------------------
-- SLOW
-----------------------------------------------------------------------
function BrainrotManager.ApplySlow(id: string, factor: number, duration: number)
	local br = active[id]
	if not br or not br.alive then return end
	if factor > br.slowAmount then br.slowAmount = factor end
	if duration > br.slowTimer then br.slowTimer = duration end
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function BrainrotManager.Get(id: string) return active[id] end
function BrainrotManager.GetAllActive() return active end

function BrainrotManager.GetActiveCount(): number
	local c = 0
	for _, br in pairs(active) do
		if br.alive then c += 1 end
	end
	return c
end

-----------------------------------------------------------------------
-- REMOVE
-----------------------------------------------------------------------
function BrainrotManager.Remove(id: string) BrainrotManager._Remove(id) end

function BrainrotManager._Remove(id: string)
	active[id] = nil
	local m = models[id]
	if m then m:Destroy(); models[id] = nil end
	if Events then Events.BrainrotDied:FireAllClients({ id = id }) end
end

function BrainrotManager.ClearAll()
	for id in pairs(active) do BrainrotManager._Remove(id) end
	active = {}
	models = {}
end

-----------------------------------------------------------------------
-- UPDATE (llamar desde Heartbeat)
-----------------------------------------------------------------------
function BrainrotManager.Update(dt: number)
	for id, br in pairs(active) do
		if not br.alive then continue end

		-- Slow timer
		if br.slowTimer > 0 then
			br.slowTimer -= dt
			if br.slowTimer <= 0 then
				br.slowAmount = 0
				br.slowTimer = 0
			end
		end

		-- Path
		local reachedEnd = PathFollower.Update(br, dt)

		-- Sync visual
		local m = models[id]
		if m then m.Position = br.position end

		if reachedEnd then
			br.alive = false
			if onReachedEnd then onReachedEnd(id, br) end
			BrainrotManager._Remove(id)
		end
	end
end

return BrainrotManager
