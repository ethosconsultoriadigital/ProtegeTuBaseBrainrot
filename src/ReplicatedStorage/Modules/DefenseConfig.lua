-- DefenseConfig
-- LaserTurret / IceTrap / CaptureModule — 2 niveles cada una
-- Ubicación: ReplicatedStorage > Modules > DefenseConfig (ModuleScript)
--
-- Balance notes (vs BrainrotConfig):
--   LaserTurret Lv1: 18 DPS, range 14 → mata Runner Normal (45 HP) en 2.5s
--   IceTrap Lv1: 35% slow, range 10 → Runner baja de 18 a 11.7 speed
--   CaptureModule Lv1: captura <30% HP, cooldown 4s → necesita que laser baje primero

local DefenseConfig = {}

DefenseConfig.Defenses = {
	LaserTurret = {
		displayName = "Torreta Laser",
		family      = "Damage",
		description = "Dano continuo al enemigo mas cercano",
		hotkey      = "1",
		targeting   = "Nearest",
		size        = Vector3.new(2, 3, 2),
		color       = Color3.fromRGB(255, 60, 60),
		material    = Enum.Material.Metal,
		levels = {
			[1] = {
				cost       = 100,
				damage     = 18,    -- DPS (dano por segundo)
				range      = 14,    -- studs
				attackRate = 0.2,   -- segundos entre ticks de dano
			},
			[2] = {
				cost       = 85,    -- costo de upgrade (no incluye nivel anterior)
				damage     = 32,
				range      = 17,
				attackRate = 0.18,
			},
		},
	},

	IceTrap = {
		displayName = "Trampa de Hielo",
		family      = "Slow",
		description = "Ralentiza enemigos en area",
		hotkey      = "2",
		targeting   = "Area",
		size        = Vector3.new(3, 0.5, 3),
		color       = Color3.fromRGB(100, 200, 255),
		material    = Enum.Material.Ice,
		levels = {
			[1] = {
				cost         = 80,
				slowFactor   = 0.35,  -- reduce velocidad un 35%
				range        = 10,
				slowDuration = 3,     -- segundos que dura el slow tras salir del area
			},
			[2] = {
				cost         = 65,
				slowFactor   = 0.55,
				range        = 13,
				slowDuration = 4,
			},
		},
	},

	CaptureModule = {
		displayName = "Modulo Captura",
		family      = "Capture",
		description = "Captura brainrots debilitados para la boveda",
		hotkey      = "3",
		targeting   = "LowestHP",
		size        = Vector3.new(2.5, 2, 2.5),
		color       = Color3.fromRGB(0, 229, 255),
		material    = Enum.Material.Neon,
		levels = {
			[1] = {
				cost        = 150,
				hpThreshold = 0.30,  -- captura si HP < 30%
				captureMult = 1.0,   -- multiplicador sobre captureRate de la rareza
				range       = 10,
				cooldown    = 4,     -- segundos entre intentos
			},
			[2] = {
				cost        = 120,
				hpThreshold = 0.40,
				captureMult = 1.5,
				range       = 13,
				cooldown    = 3,
			},
		},
	},
}

-- Orden de la hotbar (indice = tecla numerica)
DefenseConfig.HotbarOrder = { "LaserTurret", "IceTrap", "CaptureModule" }

-----------------------------------------------------------------------
-- HELPERS (solo acceso a datos, sin logica de juego)
-----------------------------------------------------------------------

function DefenseConfig.GetStats(defenseType: string, level: number)
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return nil end
	return def.levels[level]
end

-- Costo acumulado de compra + upgrades hasta el nivel indicado
function DefenseConfig.GetTotalCost(defenseType: string, upToLevel: number): number
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return 0 end
	local total = 0
	for i = 1, upToLevel do
		if def.levels[i] then
			total = total + def.levels[i].cost
		end
	end
	return total
end

function DefenseConfig.GetMaxLevel(defenseType: string): number
	local def = DefenseConfig.Defenses[defenseType]
	if not def then return 0 end
	local mx = 0
	for k in pairs(def.levels) do
		if k > mx then mx = k end
	end
	return mx
end

return DefenseConfig
