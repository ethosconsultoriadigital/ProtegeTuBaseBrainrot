-- BrainrotManager.lua
-- Gestiona spawning, movimiento, daño y muerte de brainrots
-- Ubicación: ServerScriptService/Systems/BrainrotManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BrainrotConfig = require(ReplicatedStorage.Modules.BrainrotConfig)
local PathFollower = require(script.Parent.Parent.AI.PathFollower)

local BrainrotManager = {}

-- Pool y tracking
local activeBrainrots: {[string]: any} = {}   -- id -> brainrot data
local brainrotModels: {[string]: BasePart} = {} -- id -> part visual
local nextId = 1
local activeFolder: Folder = nil

-- Callbacks que otros sistemas registran
local onBrainrotDied = nil       -- function(id, brainrotData, killedByDefense)
local onBrainrotReachedEnd = nil -- function(id, brainrotData)

-- Eventos
local Events = nil

function BrainrotManager.Init()
	activeFolder = workspace:FindFirstChild("ActiveBrainrots")
	if not activeFolder then
		activeFolder = Instance.new("Folder")
		activeFolder.Name = "ActiveBrainrots"
		activeFolder.Parent = workspace
	end

	Events = ReplicatedStorage:FindFirstChild("Events")
	PathFollower.LoadWaypoints()
end

-- Registrar callbacks
function BrainrotManager.OnBrainrotDied(callback)
	onBrainrotDied = callback
end

function BrainrotManager.OnBrainrotReachedEnd(callback)
	onBrainrotReachedEnd = callback
end

-- Crear un brainrot y añadirlo al campo
function BrainrotManager.Spawn(className: string, rarityName: string, hpOverride: number?, isBoss: boolean?): string?
	local stats = BrainrotConfig.GetStats(className, rarityName)
	if not stats then return nil end

	local id = "br_" .. nextId
	nextId = nextId + 1

	local spawnPos = PathFollower.GetSpawnPosition()
	local finalHP = stats.maxHP * (hpOverride or 1.0)

	-- Datos internos del brainrot (server-side)
	local brainrot = {
		id = id,
		className = className,
		rarityName = rarityName,
		maxHP = finalHP,
		hp = finalHP,
		speed = stats.speed,
		barrierDamage = stats.barrierDamage,
		killReward = stats.killReward,
		captureReward = stats.captureReward,
		captureRate = stats.captureRate,
		vaultValue = stats.vaultValue,
		vaultIncome = stats.vaultIncome,
		position = spawnPos,
		pathIndex = 1,
		slowAmount = 0,        -- 0 a 1, porcentaje de slow
		slowTimer = 0,         -- Segundos restantes de slow
		alive = true,
		isBoss = isBoss or false,
	}

	activeBrainrots[id] = brainrot

	-- Crear visual (part simple con color de rareza)
	local part = Instance.new("Part")
	part.Name = id
	part.Size = stats.size
	part.Shape = stats.shape
	part.Anchored = true
	part.CanCollide = false
	part.Color = stats.color
	part.Material = Enum.Material.SmoothPlastic
	part.Position = spawnPos
	part.Parent = activeFolder

	-- Billboard para HP (solo para Raros+)
	if rarityName ~= "Normal" or isBoss then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "HPBar"
		billboard.Size = UDim2.new(3, 0, 0.4, 0)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = part

		local bg = Instance.new("Frame")
		bg.Name = "Background"
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		bg.BorderSizePixel = 0
		bg.Parent = billboard

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(1, 0, 1, 0)
		fill.BackgroundColor3 = stats.color
		fill.BorderSizePixel = 0
		fill.Parent = bg

		local corner1 = Instance.new("UICorner")
		corner1.CornerRadius = UDim.new(0.3, 0)
		corner1.Parent = bg
		local corner2 = Instance.new("UICorner")
		corner2.CornerRadius = UDim.new(0.3, 0)
		corner2.Parent = fill
	end

	-- Trail para Raros+
	if stats.trailEnabled then
		local attachment0 = Instance.new("Attachment")
		attachment0.Position = Vector3.new(0, 0, -stats.size.Z / 2)
		attachment0.Parent = part
		local attachment1 = Instance.new("Attachment")
		attachment1.Position = Vector3.new(0, 0, stats.size.Z / 2)
		attachment1.Parent = part
		local trail = Instance.new("Trail")
		trail.Attachment0 = attachment0
		trail.Attachment1 = attachment1
		trail.Color = ColorSequence.new(stats.color)
		trail.Lifetime = 0.4
		trail.MinLength = 0.1
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		})
		trail.Parent = part
	end

	-- Indicador de boss
	if isBoss then
		part.Material = Enum.Material.Neon
		part.Size = stats.size * 1.8

		local light = Instance.new("PointLight")
		light.Color = stats.color
		light.Brightness = 2
		light.Range = 12
		light.Parent = part
	end

	brainrotModels[id] = part

	-- Notificar clientes
	if Events then
		Events.BrainrotSpawned:FireAllClients({
			id = id,
			class = className,
			rarity = rarityName,
			isBoss = brainrot.isBoss,
		})
	end

	return id
end

-- Aplicar daño a un brainrot
function BrainrotManager.Damage(id: string, amount: number): boolean
	local brainrot = activeBrainrots[id]
	if not brainrot or not brainrot.alive then return false end

	brainrot.hp = brainrot.hp - amount

	-- Actualizar barra de HP visual
	local model = brainrotModels[id]
	if model then
		local billboard = model:FindFirstChild("HPBar")
		if billboard then
			local bg = billboard:FindFirstChild("Background")
			if bg then
				local fill = bg:FindFirstChild("Fill")
				if fill then
					local ratio = math.clamp(brainrot.hp / brainrot.maxHP, 0, 1)
					fill.Size = UDim2.new(ratio, 0, 1, 0)

					-- Color: verde > amarillo > rojo según HP
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
	end

	if brainrot.hp <= 0 then
		brainrot.alive = false
		BrainrotManager._Remove(id)
		if onBrainrotDied then
			onBrainrotDied(id, brainrot, true)
		end
		return true -- Murió
	end

	return false
end

-- Aplicar slow a un brainrot
function BrainrotManager.ApplySlow(id: string, slowFactor: number, duration: number)
	local brainrot = activeBrainrots[id]
	if not brainrot or not brainrot.alive then return end

	-- Tomar el slow más fuerte
	if slowFactor > brainrot.slowAmount then
		brainrot.slowAmount = slowFactor
	end
	-- Extender duración si es mayor
	if duration > brainrot.slowTimer then
		brainrot.slowTimer = duration
	end
end

-- Obtener datos de un brainrot
function BrainrotManager.GetBrainrot(id: string): any?
	return activeBrainrots[id]
end

-- Obtener todos los brainrots activos
function BrainrotManager.GetAllActive(): {[string]: any}
	return activeBrainrots
end

-- Contar brainrots activos
function BrainrotManager.GetActiveCount(): number
	local count = 0
	for _, br in pairs(activeBrainrots) do
		if br.alive then count = count + 1 end
	end
	return count
end

-- Eliminar un brainrot del campo (captura o muerte)
function BrainrotManager.Remove(id: string)
	BrainrotManager._Remove(id)
end

function BrainrotManager._Remove(id: string)
	activeBrainrots[id] = nil

	local model = brainrotModels[id]
	if model then
		model:Destroy()
		brainrotModels[id] = nil
	end

	-- Notificar muerte a clientes
	if Events then
		Events.BrainrotDied:FireAllClients({id = id})
	end
end

-- Limpiar todos los brainrots (fin de partida)
function BrainrotManager.ClearAll()
	for id, _ in pairs(activeBrainrots) do
		BrainrotManager._Remove(id)
	end
	activeBrainrots = {}
	brainrotModels = {}
end

-- Update loop: mover todos los brainrots (llamado desde Heartbeat)
function BrainrotManager.Update(dt: number)
	for id, brainrot in pairs(activeBrainrots) do
		if brainrot.alive then
			-- Actualizar slow timer
			if brainrot.slowTimer > 0 then
				brainrot.slowTimer = brainrot.slowTimer - dt
				if brainrot.slowTimer <= 0 then
					brainrot.slowAmount = 0
					brainrot.slowTimer = 0
				end
			end

			-- Mover por path
			local reachedEnd = PathFollower.Update(brainrot, dt)

			-- Actualizar posición visual
			local model = brainrotModels[id]
			if model then
				model.Position = brainrot.position
			end

			-- Si llegó al final
			if reachedEnd then
				brainrot.alive = false
				if onBrainrotReachedEnd then
					onBrainrotReachedEnd(id, brainrot)
				end
				BrainrotManager._Remove(id)
			end
		end
	end
end

return BrainrotManager
