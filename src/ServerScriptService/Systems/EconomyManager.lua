-- EconomyManager.lua
-- Tracking de Cells por jugador y recompensas
-- Ubicación: ServerScriptService/Systems/EconomyManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.EconomyConfig)

local EconomyManager = {}

local playerCells: {[number]: number} = {} -- UserId -> Cells
local Events = nil
local BaseManager = nil

-- Timer de ingreso pasivo
local vaultIncomeTimer = 0

function EconomyManager.Init(baseMgr)
	BaseManager = baseMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
end

-- Inicializar jugador
function EconomyManager.InitPlayer(player: Player)
	playerCells[player.UserId] = GameConfig.STARTING_CELLS
	EconomyManager._NotifyCells(player)
end

-- Limpiar jugador
function EconomyManager.CleanupPlayer(player: Player)
	playerCells[player.UserId] = nil
end

-- Obtener cells de un jugador
function EconomyManager.GetCells(player: Player): number
	return playerCells[player.UserId] or 0
end

-- Añadir cells
function EconomyManager.AddCells(player: Player, amount: number)
	local userId = player.UserId
	playerCells[userId] = (playerCells[userId] or 0) + amount
	EconomyManager._NotifyCells(player)
end

-- Gastar cells (retorna true si pudo)
function EconomyManager.SpendCells(player: Player, amount: number): boolean
	local userId = player.UserId
	local current = playerCells[userId] or 0

	if current < amount then
		return false
	end

	playerCells[userId] = current - amount
	EconomyManager._NotifyCells(player)
	return true
end

-- Puede pagar?
function EconomyManager.CanAfford(player: Player, amount: number): boolean
	return (playerCells[player.UserId] or 0) >= amount
end

-- Recompensar kill
function EconomyManager.RewardKill(brainrotData: any)
	for _, player in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(player, brainrotData.killReward)
	end
end

-- Bonus de oleada perfecta (sin daño a barrera)
function EconomyManager.RewardPerfectWave()
	for _, player in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(player, EconomyConfig.PERFECT_WAVE_BONUS)
	end
end

-- Update de ingreso pasivo (llamado desde Heartbeat)
function EconomyManager.Update(dt: number)
	if not BaseManager then return end

	vaultIncomeTimer = vaultIncomeTimer + dt
	if vaultIncomeTimer >= GameConfig.VAULT_INCOME_INTERVAL then
		vaultIncomeTimer = 0

		local income = BaseManager.GetVaultPassiveIncome()
		if income > 0 then
			income = math.floor(income * EconomyConfig.VAULT_INCOME_MULTIPLIER)
			for _, player in ipairs(Players:GetPlayers()) do
				EconomyManager.AddCells(player, income)
			end
		end
	end
end

-- Notificar al cliente
function EconomyManager._NotifyCells(player: Player)
	if Events then
		Events.CellsUpdate:FireClient(player, {
			cells = playerCells[player.UserId] or 0,
		})
	end
end

return EconomyManager
