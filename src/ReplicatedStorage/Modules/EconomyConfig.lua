-- EconomyConfig
-- Constantes economicas: bonuses, multiplicadores, costos derivados
-- Ubicación: ReplicatedStorage > Modules > EconomyConfig (ModuleScript)
--
-- Las recompensas base por kill/captura estan en BrainrotConfig (por rareza).
-- Aqui van los multiplicadores globales y bonuses de partida.

local EconomyConfig = {}

-----------------------------------------------------------------------
-- BONUSES DE OLEADA
-----------------------------------------------------------------------
EconomyConfig.PERFECT_WAVE_BONUS = 30   -- Cells extra si la barrera no recibio dano en la oleada
EconomyConfig.WAVE_CLEAR_BONUS   = 10   -- Cells extra por completar cualquier oleada

-----------------------------------------------------------------------
-- FIN DE PARTIDA
-----------------------------------------------------------------------
EconomyConfig.VICTORY_BONUS = 200  -- Cells extra al ganar (no se gasta, es para scoring)

-----------------------------------------------------------------------
-- BOVEDA (ingreso pasivo)
-----------------------------------------------------------------------
-- El income real por tick viene de BrainrotConfig.Rarities[x].vaultIncome
-- Este multiplicador se aplica al total por tick
EconomyConfig.VAULT_INCOME_MULTIPLIER = 1.0

-----------------------------------------------------------------------
-- MULTIPLICADORES GLOBALES
-- Estos se aplican sobre los valores base de BrainrotConfig.
-- Cambiarlos afecta toda la economia sin tocar stats individuales.
-----------------------------------------------------------------------
EconomyConfig.KILL_REWARD_MULTIPLIER    = 1.0  -- sobre killReward de la rareza
EconomyConfig.CAPTURE_BONUS_MULTIPLIER  = 1.0  -- sobre captureBonus de la rareza

return EconomyConfig
