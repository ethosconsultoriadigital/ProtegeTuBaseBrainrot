-- DefenseConfig
-- LaserTurret / IceTrap / CaptureModule con 2 niveles
-- Ubicación: ReplicatedStorage > Modules > DefenseConfig (ModuleScript)

local DefenseConfig = {}

DefenseConfig.Defenses = {
	LaserTurret = {
		displayName = "Torreta Laser",
		family      = "Damage",
		description = "Daño continuo al enemigo mas cercano",
		hotkey      = "1",
		levels = {
			[1] = { cost = 100, damage = 18,  range = 14, attackRate = 0.2 },
			[2] = { cost = 85,  damage = 32,  range = 17, attackRate = 0.18 },
		},
		targeting = "Nearest",
		size     = Vector3.new(2, 3, 2),
		color    = Color3.fromRGB(255, 60, 60),
		material = Enum.Material.Metal,
	},

	IceTrap = {
		displayName = "Trampa de Hielo",
		family      = "Slow",
		description = "Ralentiza enemigos en area",
		hotkey      = "2",
		levels = {
			[1] = { cost = 80, slowFactor = 0.35, range = 10, slowDuration = 3 },
			[2] = { cost = 65, slowFactor = 0.55, range = 13, slowDuration = 4 },
		},
		targeting = "Area",
		size     = Vector3.new(3, 0.5, 3),
		color    = Color3.fromRGB(100, 200, 255),
		material = Enum.Material.Ice,
	},

	CaptureModule = {
		displayName = "Modulo Captura",
		family      = "Capture",
		description = "Captura brainrots debilitados",
		hotkey      = "3",
		levels = {
			[1] = { cost = 150, hpThreshold = 0.30, captureMult = 1.0, range = 10, cooldown = 4 },
			[2] = { cost = 120, hpThreshold = 0.40, captureMult = 1.5, range = 13, cooldown = 3 },
		},
		targeting = "LowestHP",
		size     = Vector3.new(2.5, 2, 2.5),
		color    = Color3.fromRGB(0, 229, 255),
		material = Enum.Material.Neon,
	},
}

DefenseConfig.HotbarOrder = { "LaserTurret", "IceTrap", "CaptureModule" }

function DefenseConfig.GetStats(defenseType: string, level: number)
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return nil end
	return def.levels[level]
end

function DefenseConfig.GetTotalCost(defenseType: string, level: number): number
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return 0 end
	local total = 0
	for i = 1, level do
		if def.levels[i] then total = total + def.levels[i].cost end
	end
	return total
end

function DefenseConfig.GetMaxLevel(defenseType: string): number
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return 0 end
	local mx = 0
	for k in pairs(def.levels) do if k > mx then mx = k end end
	return mx
end

return DefenseConfig
