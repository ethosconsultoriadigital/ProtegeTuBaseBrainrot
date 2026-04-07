-- EconomyManager
-- Cells por jugador, rewards por kill/captura/oleada, ingreso pasivo de bóveda
-- Ubicación: ServerScriptService > Systems > EconomyManager (ModuleScript)
--
-- Responsabilidades:
--   - Cells iniciales (500) por jugador
--   - Recompensa por kill (killReward × KILL_REWARD_MULTIPLIER)
--   - Recompensa por captura (captureBonus × CAPTURE_BONUS_MULTIPLIER)
--   - Bonus por oleada completada, perfecta
--   - Ingreso pasivo de bóveda cada VAULT_INCOME_INTERVAL segundos
--   - Validación de gasto (CanAfford, SpendCells)
--
-- NO maneja: qué se compra ni cuánto cuesta. Solo flujo de Cells.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig    = require(ReplicatedStorage.Modules.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.EconomyConfig)

local EconomyManager = {}

-----------------------------------------------------------------------
-- DEPENDENCIAS (inyectadas)
-----------------------------------------------------------------------
local BaseManager = nil
local Events = nil

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local playerCells: {[number]: number} = {}  -- UserId → Cells
local vaultTimer = 0

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function EconomyManager.Init(baseMgr)
	BaseManager = baseMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
	if not Events then
		warn("[EconomyManager] ReplicatedStorage.Events no encontrado — sin notificacion de cells")
	end
	if not BaseManager then
		warn("[EconomyManager] BaseManager nil — ingreso pasivo deshabilitado")
	end
	vaultTimer = 0
	print("[EconomyManager] Init OK")
end

-----------------------------------------------------------------------
-- PLAYER LIFECYCLE
-----------------------------------------------------------------------
function EconomyManager.InitPlayer(player: Player)
	playerCells[player.UserId] = GameConfig.STARTING_CELLS
	EconomyManager._Notify(player)
	print("[Economy] " .. player.Name .. " inicia con " .. GameConfig.STARTING_CELLS .. " Cells")
end

function EconomyManager.CleanupPlayer(player: Player)
	playerCells[player.UserId] = nil
end

-----------------------------------------------------------------------
-- CELLS: GET / ADD / SPEND / CHECK
-----------------------------------------------------------------------
function EconomyManager.GetCells(player: Player): number
	return playerCells[player.UserId] or 0
end

function EconomyManager.AddCells(player: Player, amount: number)
	local uid = player.UserId
	playerCells[uid] = (playerCells[uid] or 0) + math.floor(amount)
	EconomyManager._Notify(player)
end

function EconomyManager.SpendCells(player: Player, amount: number): boolean
	local uid = player.UserId
	local current = playerCells[uid] or 0
	if current < amount then return false end
	playerCells[uid] = current - amount
	EconomyManager._Notify(player)
	return true
end

function EconomyManager.CanAfford(player: Player, amount: number): boolean
	return (playerCells[player.UserId] or 0) >= amount
end

-----------------------------------------------------------------------
-- REWARDS
-----------------------------------------------------------------------

-- Recompensa por matar un brainrot (todos los jugadores)
function EconomyManager.RewardKill(brData: any)
	local reward = math.floor(brData.killReward * EconomyConfig.KILL_REWARD_MULTIPLIER)
	if reward <= 0 then return end
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(p, reward)
	end
end

-- Recompensa por capturar un brainrot (todos los jugadores)
function EconomyManager.RewardCapture(brData: any)
	local reward = math.floor(brData.captureBonus * EconomyConfig.CAPTURE_BONUS_MULTIPLIER)
	if reward <= 0 then return end
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(p, reward)
	end
end

-- Bonus por completar cualquier oleada
function EconomyManager.RewardWaveClear()
	local reward = EconomyConfig.WAVE_CLEAR_BONUS
	if reward <= 0 then return end
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(p, reward)
	end
end

-- Bonus por oleada perfecta (barrera sin daño)
function EconomyManager.RewardPerfectWave()
	local reward = EconomyConfig.PERFECT_WAVE_BONUS
	if reward <= 0 then return end
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(p, reward)
	end
end

-----------------------------------------------------------------------
-- PASSIVE INCOME (bóveda)
-- Cada VAULT_INCOME_INTERVAL segundos, sumar vaultIncome de cada captura
-----------------------------------------------------------------------
function EconomyManager.Update(dt: number)
	if not BaseManager then return end

	vaultTimer += dt
	if vaultTimer >= GameConfig.VAULT_INCOME_INTERVAL then
		vaultTimer -= GameConfig.VAULT_INCOME_INTERVAL

		local baseIncome = BaseManager.GetVaultPassiveIncome()
		if baseIncome <= 0 then return end

		local income = math.floor(baseIncome * EconomyConfig.VAULT_INCOME_MULTIPLIER)
		if income <= 0 then return end

		for _, p in ipairs(Players:GetPlayers()) do
			EconomyManager.AddCells(p, income)
		end
		print("[Economy] Ingreso pasivo de bóveda: +" .. income .. " Cells")
	end
end

-----------------------------------------------------------------------
-- NOTIFY CLIENT
-----------------------------------------------------------------------
function EconomyManager._Notify(player: Player)
	if Events then
		Events.CellsUpdate:FireClient(player, {
			cells = playerCells[player.UserId] or 0,
		})
	end
end

return EconomyManager
