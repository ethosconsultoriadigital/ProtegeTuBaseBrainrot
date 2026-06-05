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

-----------------------------------------------------------------------
-- MAPA (Creator Store)
-- MapSetup inserta este modelo al iniciar si el ID es > 0. Pon 0 para solo graybox.
-- IDs: copia del recurso en tu inventario / Creator Store.
-----------------------------------------------------------------------
GameConfig.IMPORTED_MAP_ASSET_ID = 101491434169003 -- Mapa principal

-----------------------------------------------------------------------
-- TIENDA (modelo Shop — insertar manual en mapa o vía código cuando exista el manager)
-----------------------------------------------------------------------
GameConfig.ASSET_SHOP = 95566802299515

-----------------------------------------------------------------------
-- LUCKY BLOCKS (varios modelos; spawn / loot usará esta lista)
-----------------------------------------------------------------------
GameConfig.ASSET_LUCKY_BLOCK_PRIMARY = 136901876139141
GameConfig.ASSET_LUCKY_BLOCK_SECONDARY = 93073400961159

-- Lista para elegir al azar (ej. LuckyBlockManager)
GameConfig.LUCKY_BLOCK_ASSET_IDS = {
	136901876139141,
	93073400961159,
}

-----------------------------------------------------------------------
-- PACKS DE BRAINROTS (pool para drops / catálogo visual)
-----------------------------------------------------------------------
GameConfig.ASSET_PACK_BRAINROTS_1 = 98891498207178
GameConfig.ASSET_PACK_BRAINROTS_2 = 72466520546640
GameConfig.ASSET_PACK_BRAINROTS_3 = 84968460904245

GameConfig.BRAINROT_PACK_ASSET_IDS = {
	98891498207178,
	72466520546640,
	84968460904245,
}

return GameConfig
