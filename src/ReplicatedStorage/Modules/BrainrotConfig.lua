-- BrainrotConfig
-- Clases: Runner, Tank, Thief  |  Rarezas: Normal, Gold, Diamond
-- Ubicación: ReplicatedStorage > Modules > BrainrotConfig (ModuleScript)
--
-- Balance notes (stats finales = base × mult):
--   Runner Normal:  HP  45, Spd 18, Dmg  8  → muere en ~2.5s con 1 laser
--   Tank   Normal:  HP 200, Spd  7, Dmg 30  → muere en ~11s  con 1 laser
--   Tank   Diamond: HP 700, Spd  8, Dmg 66  → necesita varias defensas
--   Boss (Tank Diamond ×5): HP 3500          → necesita todo el setup

local BrainrotConfig = {}

-----------------------------------------------------------------------
-- CLASES (stats base, asumiendo rareza Normal)
-----------------------------------------------------------------------
BrainrotConfig.Classes = {
	Runner = {
		baseHP        = 45,
		baseSpeed     = 18,
		baseDamage    = 8,
		size          = Vector3.new(1.6, 1.6, 1.6),
		shape         = Enum.PartType.Ball,
		description   = "Rapido y fragil, llega antes que nadie",
		stealTimeMult = 1.0,
	},
	Tank = {
		baseHP        = 200,
		baseSpeed     = 7,
		baseDamage    = 30,
		size          = Vector3.new(3.2, 3.2, 3.2),
		shape         = Enum.PartType.Block,
		description   = "Lento, absorbe mucho dano",
		stealTimeMult = 1.0,
	},
	Thief = {
		baseHP        = 70,
		baseSpeed     = 14,
		baseDamage    = 12,
		size          = Vector3.new(1.8, 1.8, 1.8),
		shape         = Enum.PartType.Block,
		description   = "Si infiltra la base, roba capturas extra rapido",
		stealTimeMult = 0.5,  -- roba al 50% del tiempo normal
	},
}

-- Orden para iteracion en UI y spawn
BrainrotConfig.ClassOrder = { "Runner", "Tank", "Thief" }

-----------------------------------------------------------------------
-- RAREZAS
-----------------------------------------------------------------------
BrainrotConfig.Rarities = {
	Normal = {
		order        = 1,
		hpMult       = 1.0,
		speedMult    = 1.0,
		damageMult   = 1.0,
		killReward   = 10,
		captureBonus = 5,
		captureRate  = 0.40,
		vaultValue   = 5,
		vaultIncome  = 1,
		color        = Color3.fromRGB(170, 170, 170),
		trailEnabled = false,
		glowEnabled  = false,
	},
	Gold = {
		order        = 2,
		hpMult       = 2.0,
		speedMult    = 1.05,
		damageMult   = 1.6,
		killReward   = 40,
		captureBonus = 25,
		captureRate  = 0.20,
		vaultValue   = 30,
		vaultIncome  = 4,
		color        = Color3.fromRGB(255, 193, 7),
		trailEnabled = true,
		glowEnabled  = true,
	},
	Diamond = {
		order        = 3,
		hpMult       = 3.5,
		speedMult    = 1.15,
		damageMult   = 2.2,
		killReward   = 100,
		captureBonus = 60,
		captureRate  = 0.10,
		vaultValue   = 80,
		vaultIncome  = 10,
		color        = Color3.fromRGB(0, 229, 255),
		trailEnabled = true,
		glowEnabled  = true,
	},
}

-- Orden de robo: la boveda se roba empezando por el mas valioso
BrainrotConfig.RarityOrder = { "Diamond", "Gold", "Normal" }

-----------------------------------------------------------------------
-- HELPER: componer stats finales de clase × rareza
-- Solo combina datos, no contiene logica de juego.
-----------------------------------------------------------------------
function BrainrotConfig.GetStats(className: string, rarityName: string)
	local class  = BrainrotConfig.Classes[className]
	local rarity = BrainrotConfig.Rarities[rarityName]
	if not class or not rarity then
		warn("[BrainrotConfig] Clase o rareza invalida:", className, rarityName)
		return nil
	end
	return {
		className     = className,
		rarityName    = rarityName,
		maxHP         = math.floor(class.baseHP * rarity.hpMult),
		speed         = class.baseSpeed * rarity.speedMult,
		barrierDamage = math.floor(class.baseDamage * rarity.damageMult),
		size          = class.size,
		shape         = class.shape,
		killReward    = rarity.killReward,
		captureBonus  = rarity.captureBonus,
		captureRate   = rarity.captureRate,
		vaultValue    = rarity.vaultValue,
		vaultIncome   = rarity.vaultIncome,
		color         = rarity.color,
		trailEnabled  = rarity.trailEnabled,
		glowEnabled   = rarity.glowEnabled,
		stealTimeMult = class.stealTimeMult,
	}
end

return BrainrotConfig
