-- WaveConfig.lua
-- Composición de oleadas
-- Ubicación: ReplicatedStorage/Modules/WaveConfig

local WaveConfig = {}

-- Cada oleada define qué brainrots aparecen
-- {class, rarity, count}
WaveConfig.Waves = {
	[1] = {
		name = "Primera Oleada",
		spawns = {
			{class = "Swarmer", rarity = "Normal", count = 5},
		},
		spawnInterval = 1.6,
	},
	[2] = {
		name = "Los Lentos",
		spawns = {
			{class = "Swarmer", rarity = "Normal", count = 4},
			{class = "Tank", rarity = "Normal", count = 2},
		},
		spawnInterval = 1.5,
	},
	[3] = {
		name = "Velocistas",
		spawns = {
			{class = "Speedster", rarity = "Normal", count = 4},
			{class = "Swarmer", rarity = "Normal", count = 3},
		},
		spawnInterval = 1.3,
	},
	[4] = {
		name = "Primer Desafío",
		spawns = {
			{class = "Tank", rarity = "Normal", count = 3},
			{class = "Swarmer", rarity = "Rare", count = 3},
			{class = "Speedster", rarity = "Normal", count = 3},
		},
		spawnInterval = 1.2,
	},
	[5] = {
		name = "Horda Mixta",
		spawns = {
			{class = "Swarmer", rarity = "Normal", count = 6},
			{class = "Swarmer", rarity = "Rare", count = 3},
			{class = "Tank", rarity = "Rare", count = 2},
			{class = "Speedster", rarity = "Rare", count = 2},
		},
		spawnInterval = 1.1,
	},
	[6] = {
		name = "Élite Entrante",
		spawns = {
			{class = "Swarmer", rarity = "Rare", count = 5},
			{class = "Tank", rarity = "Rare", count = 3},
			{class = "Speedster", rarity = "Rare", count = 3},
			{class = "Swarmer", rarity = "Elite", count = 2},
		},
		spawnInterval = 1.0,
	},
	[7] = {
		name = "Oleada Final",
		spawns = {
			{class = "Swarmer", rarity = "Rare", count = 6},
			{class = "Tank", rarity = "Elite", count = 2},
			{class = "Speedster", rarity = "Elite", count = 3},
			{class = "Swarmer", rarity = "Elite", count = 3},
		},
		spawnInterval = 0.9,
	},
	-- Oleada 8: Mini-boss
	[8] = {
		name = "BOSS: Tanque Élite Supremo",
		isBoss = true,
		spawns = {
			{class = "Swarmer", rarity = "Rare", count = 4},
			{class = "Tank", rarity = "Elite", count = 1, isBoss = true, hpOverride = 5.0},
			-- hpOverride multiplica el HP final por este factor
			{class = "Speedster", rarity = "Rare", count = 3},
		},
		spawnInterval = 1.2,
	},
}

-- Expandir oleada a lista plana de spawns en orden
function WaveConfig.GetSpawnList(waveNumber: number): {any}?
	local wave = WaveConfig.Waves[waveNumber]
	if not wave then return nil end

	local list = {}
	for _, group in ipairs(wave.spawns) do
		for i = 1, group.count do
			table.insert(list, {
				class = group.class,
				rarity = group.rarity,
				isBoss = group.isBoss or false,
				hpOverride = group.hpOverride or 1.0,
			})
		end
	end

	-- Mezclar orden para variedad (Fisher-Yates shuffle)
	for i = #list, 2, -1 do
		local j = math.random(1, i)
		list[i], list[j] = list[j], list[i]
	end

	return list
end

-- Obtener intervalo de spawn de la oleada
function WaveConfig.GetSpawnInterval(waveNumber: number): number
	local wave = WaveConfig.Waves[waveNumber]
	if not wave then return 1.4 end
	return wave.spawnInterval
end

-- Obtener nombre de la oleada
function WaveConfig.GetWaveName(waveNumber: number): string
	local wave = WaveConfig.Waves[waveNumber]
	if not wave then return "Oleada " .. waveNumber end
	return wave.name
end

-- Es oleada de boss?
function WaveConfig.IsBossWave(waveNumber: number): boolean
	local wave = WaveConfig.Waves[waveNumber]
	if not wave then return false end
	return wave.isBoss == true
end

return WaveConfig
