-- EconomyConfig.lua
-- Configuración económica del juego
-- Ubicación: ReplicatedStorage/Modules/EconomyConfig

local EconomyConfig = {}

-- Bonus por oleada perfecta (sin daño a barrera)
EconomyConfig.PERFECT_WAVE_BONUS = 30

-- Bonus al completar la partida (victoria)
EconomyConfig.VICTORY_BONUS = 200

-- Bonus por captura durante oleada
EconomyConfig.CAPTURE_CELL_MULTIPLIER = 1.0

-- Ingreso pasivo de la bóveda (multiplicador global)
EconomyConfig.VAULT_INCOME_MULTIPLIER = 1.0

return EconomyConfig
