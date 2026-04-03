-- GameConfig
-- Constantes globales del juego — fuente de verdad para todos los managers
-- Ubicación: ReplicatedStorage > Modules > GameConfig (ModuleScript)

local GameConfig = {}

-----------------------------------------------------------------------
-- ECONOMIA DE PARTIDA
-----------------------------------------------------------------------
GameConfig.STARTING_CELLS = 500

-----------------------------------------------------------------------
-- BARRERA
-----------------------------------------------------------------------
GameConfig.BARRIER_MAX_HP          = 1000
GameConfig.BARRIER_REPAIR_COST     = 80    -- Cells base por reparacion
GameConfig.BARRIER_REPAIR_AMOUNT   = 100   -- HP restaurado por reparacion
GameConfig.BARRIER_REPAIR_ESCALATION = 20  -- +Cells por cada reparacion previa

-----------------------------------------------------------------------
-- NUCLEO (solo atacable si boveda esta vacia y barrera caida)
-----------------------------------------------------------------------
GameConfig.CORE_MAX_HP = 500

-----------------------------------------------------------------------
-- BOVEDA
-----------------------------------------------------------------------
GameConfig.VAULT_MAX_SLOTS     = 6
GameConfig.VAULT_INCOME_INTERVAL = 8   -- segundos entre ticks de ingreso pasivo

-----------------------------------------------------------------------
-- DEFENSAS
-----------------------------------------------------------------------
GameConfig.MAX_DEFENSES      = 15   -- maximo de defensas en campo
GameConfig.SELL_REFUND_RATE  = 0.5  -- 50% de reembolso al vender

-----------------------------------------------------------------------
-- OLEADAS
-----------------------------------------------------------------------
GameConfig.TOTAL_WAVES          = 8
GameConfig.BUILD_PHASE_DURATION = 18   -- segundos de fase de construccion
GameConfig.WAVE_CLEAR_DELAY     = 2.5  -- segundos entre oleada completada y siguiente build phase

-----------------------------------------------------------------------
-- INFILTRACION (cuando la barrera cae)
-----------------------------------------------------------------------
GameConfig.INFILTRATOR_TRAVEL_TIME = 4    -- segundos para llegar a la boveda
GameConfig.INFILTRATOR_STEAL_TIME  = 2.5  -- segundos para robar 1 brainrot

-----------------------------------------------------------------------
-- PLACEMENT
-----------------------------------------------------------------------
GameConfig.BUILD_ZONE_SNAP_RADIUS = 8  -- studs de distancia maxima para snap a zona

return GameConfig
