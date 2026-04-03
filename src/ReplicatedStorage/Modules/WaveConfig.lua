-- WaveConfig
-- 8 oleadas con Runner/Tank/Thief × Normal/Gold/Diamond
-- Ubicación: ReplicatedStorage > Modules > WaveConfig (ModuleScript)

local WaveConfig = {}

WaveConfig.Waves = {
	[1] = {
		name = "Exploradores",
		spawns = {
			{ class = "Runner", rarity = "Normal", count = 5 },
		},
		spawnInterval = 1.6,
	},
	[2] = {
		name = "Muro de Carne",
		spawns = {
			{ class = "Runner", rarity = "Normal", count = 4 },
			{ class = "Tank",   rarity = "Normal", count = 2 },
		},
		spawnInterval = 1.5,
	},
	[3] = {
		name = "Ladrones al Acecho",
		spawns = {
			{ class = "Runner", rarity = "Normal", count = 3 },
			{ class = "Thief",  rarity = "Normal", count = 3 },
		},
		spawnInterval = 1.4,
	},
	[4] = {
		name = "Primer Desafio",
		spawns = {
			{ class = "Tank",   rarity = "Normal", count = 3 },
			{ class = "Runner", rarity = "Gold",   count = 2 },
			{ class = "Thief",  rarity = "Normal", count = 3 },
		},
		spawnInterval = 1.3,
	},
	[5] = {
		name = "Horda Dorada",
		spawns = {
			{ class = "Runner", rarity = "Normal", count = 5 },
			{ class = "Runner", rarity = "Gold",   count = 3 },
			{ class = "Tank",   rarity = "Gold",   count = 2 },
			{ class = "Thief",  rarity = "Gold",   count = 2 },
		},
		spawnInterval = 1.1,
	},
	[6] = {
		name = "Infiltracion Masiva",
		spawns = {
			{ class = "Thief",  rarity = "Gold",   count = 5 },
			{ class = "Runner", rarity = "Gold",   count = 3 },
			{ class = "Tank",   rarity = "Normal", count = 3 },
		},
		spawnInterval = 1.0,
	},
	[7] = {
		name = "Diamantes en Bruto",
		spawns = {
			{ class = "Runner", rarity = "Gold",    count = 4 },
			{ class = "Tank",   rarity = "Gold",    count = 2 },
			{ class = "Thief",  rarity = "Gold",    count = 3 },
			{ class = "Runner", rarity = "Diamond", count = 2 },
		},
		spawnInterval = 0.9,
	},
	[8] = {
		name = "BOSS: Tanque Diamante",
		isBoss = true,
		spawns = {
			{ class = "Runner", rarity = "Gold",    count = 4 },
			{ class = "Thief",  rarity = "Gold",    count = 3 },
			{ class = "Tank",   rarity = "Diamond", count = 1, isBoss = true, hpOverride = 5.0 },
			{ class = "Thief",  rarity = "Diamond", count = 1 },
		},
		spawnInterval = 1.0,
	},
}

-- Expandir oleada a lista plana mezclada
function WaveConfig.GetSpawnList(waveNumber: number)
	local wave = WaveConfig.Waves[waveNumber]
	if not wave then return nil end

	local list = {}
	for _, group in ipairs(wave.spawns) do
		for _ = 1, group.count do
			table.insert(list, {
				class      = group.class,
				rarity     = group.rarity,
				isBoss     = group.isBoss or false,
				hpOverride = group.hpOverride or 1.0,
			})
		end
	end

	-- Shuffle
	for i = #list, 2, -1 do
		local j = math.random(1, i)
		list[i], list[j] = list[j], list[i]
	end
	return list
end

function WaveConfig.GetSpawnInterval(waveNumber: number): number
	local wave = WaveConfig.Waves[waveNumber]
	return wave and wave.spawnInterval or 1.4
end

function WaveConfig.GetWaveName(waveNumber: number): string
	local wave = WaveConfig.Waves[waveNumber]
	return wave and wave.name or ("Oleada " .. waveNumber)
end

function WaveConfig.IsBossWave(waveNumber: number): boolean
	local wave = WaveConfig.Waves[waveNumber]
	return wave and wave.isBoss == true or false
end

function WaveConfig.GetTotalWaves(): number
	return #WaveConfig.Waves
end

return WaveConfig
