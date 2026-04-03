-- BrainrotConfig.lua
-- Stats de clases y rarezas de Brainrots
-- Ubicación: ReplicatedStorage/Modules/BrainrotConfig

local BrainrotConfig = {}

-- Clases base (stats a rareza Normal)
BrainrotConfig.Classes = {
	Swarmer = {
		baseHP = 50,
		baseSpeed = 16,
		baseBarrierDamage = 8,
		size = Vector3.new(1.5, 1.5, 1.5),
		shape = Enum.PartType.Ball,
		description = "Rápido y frágil, viaja en grupo",
	},
	Tank = {
		baseHP = 180,
		baseSpeed = 7,
		baseBarrierDamage = 25,
		size = Vector3.new(3, 3, 3),
		shape = Enum.PartType.Block,
		description = "Lento pero muy resistente",
	},
	Speedster = {
		baseHP = 35,
		baseSpeed = 22,
		baseBarrierDamage = 5,
		size = Vector3.new(1.2, 1.2, 2.4),
		shape = Enum.PartType.Block,
		description = "Extremadamente rápido, bajo HP",
	},
}

-- Rarezas con multiplicadores
BrainrotConfig.Rarities = {
	Normal = {
		order = 1,
		hpMult = 1.0,
		speedMult = 1.0,
		damageMult = 1.0,
		killReward = 10,
		captureReward = 5,
		captureRate = 0.40,    -- 40% probabilidad base
		vaultValue = 5,
		vaultIncome = 1,       -- Cells por intervalo de income
		color = Color3.fromRGB(158, 158, 158),    -- Gris
		trailEnabled = false,
	},
	Rare = {
		order = 2,
		hpMult = 1.5,
		speedMult = 1.1,
		damageMult = 1.3,
		killReward = 25,
		captureReward = 15,
		captureRate = 0.28,    -- 28%
		vaultValue = 15,
		vaultIncome = 3,
		color = Color3.fromRGB(76, 175, 80),      -- Verde
		trailEnabled = true,
	},
	Elite = {
		order = 3,
		hpMult = 2.5,
		speedMult = 1.2,
		damageMult = 1.8,
		killReward = 60,
		captureReward = 40,
		captureRate = 0.18,    -- 18%
		vaultValue = 40,
		vaultIncome = 6,
		color = Color3.fromRGB(33, 150, 243),      -- Azul
		trailEnabled = true,
	},
}

-- Lista ordenada de rarezas para prioridad de robo (mayor valor primero)
BrainrotConfig.RarityOrder = {"Elite", "Rare", "Normal"}

-- Obtener stats finales de un brainrot dado clase + rareza
function BrainrotConfig.GetStats(className: string, rarityName: string)
	local class = BrainrotConfig.Classes[className]
	local rarity = BrainrotConfig.Rarities[rarityName]
	if not class or not rarity then
		warn("[BrainrotConfig] Clase o rareza inválida:", className, rarityName)
		return nil
	end

	return {
		className = className,
		rarityName = rarityName,
		maxHP = math.floor(class.baseHP * rarity.hpMult),
		speed = class.baseSpeed * rarity.speedMult,
		barrierDamage = math.floor(class.baseBarrierDamage * rarity.damageMult),
		size = class.size,
		shape = class.shape,
		killReward = rarity.killReward,
		captureReward = rarity.captureReward,
		captureRate = rarity.captureRate,
		vaultValue = rarity.vaultValue,
		vaultIncome = rarity.vaultIncome,
		color = rarity.color,
		trailEnabled = rarity.trailEnabled,
	}
end

return BrainrotConfig
