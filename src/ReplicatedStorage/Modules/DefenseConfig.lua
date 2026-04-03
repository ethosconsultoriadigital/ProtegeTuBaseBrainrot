-- DefenseConfig.lua
-- Stats de defensas por tipo y nivel
-- Ubicación: ReplicatedStorage/Modules/DefenseConfig

local DefenseConfig = {}

DefenseConfig.Defenses = {
	LaserTurret = {
		displayName = "Torreta Láser",
		family = "Damage",
		description = "Daño continuo al enemigo más cercano",
		hotkey = "1",
		levels = {
			[1] = {
				cost = 100,
				damage = 15,          -- DPS (daño por segundo)
				range = 14,           -- Studs
				attackRate = 0.2,     -- Segundos entre ticks de daño
				targeting = "Nearest",
			},
			[2] = {
				cost = 80,            -- Costo de upgrade
				damage = 28,
				range = 16,
				attackRate = 0.2,
				targeting = "Nearest",
			},
		},
		size = Vector3.new(2, 3, 2),
		color = Color3.fromRGB(255, 60, 60),
		material = Enum.Material.Metal,
	},

	IceTrap = {
		displayName = "Trampa de Hielo",
		family = "Slow",
		description = "Ralentiza enemigos en área",
		hotkey = "2",
		levels = {
			[1] = {
				cost = 80,
				slowFactor = 0.35,    -- Reduce velocidad un 35%
				range = 10,
				duration = 3,         -- Duración del slow tras salir del área
				targeting = "Area",   -- Afecta a todos en rango
			},
			[2] = {
				cost = 65,
				slowFactor = 0.50,
				range = 12,
				duration = 4,
				targeting = "Area",
			},
		},
		size = Vector3.new(3, 0.5, 3),
		color = Color3.fromRGB(100, 200, 255),
		material = Enum.Material.Ice,
	},

	CaptureModule = {
		displayName = "Módulo de Captura",
		family = "Capture",
		description = "Captura brainrots debilitados",
		hotkey = "3",
		levels = {
			[1] = {
				cost = 150,
				hpThreshold = 0.25,   -- Captura con <25% HP
				captureMultiplier = 1.0,
				range = 10,
				cooldown = 4,         -- Segundos entre intentos
				targeting = "LowestHP",
			},
			[2] = {
				cost = 120,
				hpThreshold = 0.35,
				captureMultiplier = 1.4,
				range = 12,
				cooldown = 3,
				targeting = "LowestHP",
			},
		},
		size = Vector3.new(2.5, 2, 2.5),
		color = Color3.fromRGB(0, 229, 255),
		material = Enum.Material.Neon,
	},
}

-- Lista ordenada para UI hotbar
DefenseConfig.HotbarOrder = {"LaserTurret", "IceTrap", "CaptureModule"}

-- Obtener stats de una defensa a nivel específico
function DefenseConfig.GetStats(defenseType: string, level: number)
	local def = DefenseConfig.Defenses[defenseType]
	if not def then
		warn("[DefenseConfig] Tipo inválido:", defenseType)
		return nil
	end
	local stats = def.levels[level]
	if not stats then
		warn("[DefenseConfig] Nivel inválido:", defenseType, level)
		return nil
	end
	return stats
end

-- Obtener costo total de una defensa (compra + upgrades aplicados)
function DefenseConfig.GetTotalCost(defenseType: string, level: number): number
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return 0 end
	local total = 0
	for i = 1, level do
		if def.levels[i] then
			total = total + def.levels[i].cost
		end
	end
	return total
end

-- Obtener el nivel máximo de una defensa
function DefenseConfig.GetMaxLevel(defenseType: string): number
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return 0 end
	local max = 0
	for k, _ in pairs(def.levels) do
		if k > max then max = k end
	end
	return max
end

return DefenseConfig
