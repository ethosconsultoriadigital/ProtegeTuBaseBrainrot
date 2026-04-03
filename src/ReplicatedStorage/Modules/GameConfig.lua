-- GameConfig.lua
-- Constantes globales del juego
-- Ubicación: ReplicatedStorage/Modules/GameConfig

local GameConfig = {
	-- Economía de partida
	STARTING_CELLS = 500,

	-- Barrera
	BARRIER_MAX_HP = 1000,
	BARRIER_REPAIR_COST = 80,       -- Costo base de reparación
	BARRIER_REPAIR_AMOUNT = 100,    -- HP restaurado por reparación
	BARRIER_REPAIR_ESCALATION = 20, -- Costo adicional por cada reparación

	-- Núcleo
	CORE_MAX_HP = 500,

	-- Bóveda
	VAULT_MAX_SLOTS = 6,

	-- Defensas
	MAX_DEFENSES = 15,
	SELL_REFUND_RATE = 0.5,         -- 50% de reembolso al vender

	-- Oleadas
	TOTAL_WAVES = 7,
	BUILD_PHASE_DURATION = 18,      -- Segundos de fase de construcción
	SPAWN_INTERVAL = 1.4,           -- Segundos entre spawns de brainrots

	-- Infiltración
	INFILTRATOR_TRAVEL_TIME = 4,    -- Segundos para llegar a la bóveda
	INFILTRATOR_STEAL_TIME = 2.5,   -- Segundos para robar 1 brainrot

	-- Passive income
	VAULT_INCOME_INTERVAL = 8,      -- Cada X segundos genera income

	-- Build zone detection
	BUILD_ZONE_RADIUS = 4,          -- Radio de snap para colocación
}

return GameConfig
