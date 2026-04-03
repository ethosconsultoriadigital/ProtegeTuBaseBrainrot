-- EconomyManager
-- Cells por jugador, rewards, passive income, validacion de gasto
-- Ubicación: ServerScriptService > Systems > EconomyManager (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig   = require(ReplicatedStorage.Modules.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.EconomyConfig)

local EconomyManager = {}

local playerCells: {[number]: number} = {}
local Events = nil
local BaseManager = nil
local vaultTimer = 0

function EconomyManager.Init(baseMgr)
	BaseManager = baseMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
end

function EconomyManager.InitPlayer(player: Player)
	playerCells[player.UserId] = GameConfig.STARTING_CELLS
	EconomyManager._Notify(player)
end

function EconomyManager.CleanupPlayer(player: Player)
	playerCells[player.UserId] = nil
end

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
	local cur = playerCells[uid] or 0
	if cur < amount then return false end
	playerCells[uid] = cur - amount
	EconomyManager._Notify(player)
	return true
end

function EconomyManager.CanAfford(player: Player, amount: number): boolean
	return (playerCells[player.UserId] or 0) >= amount
end

function EconomyManager.RewardKill(brData: any)
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(p, brData.killReward)
	end
end

function EconomyManager.RewardPerfectWave()
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.AddCells(p, EconomyConfig.PERFECT_WAVE_BONUS)
	end
end

-- Passive income de boveda
function EconomyManager.Update(dt: number)
	if not BaseManager then return end
	vaultTimer += dt
	if vaultTimer >= GameConfig.VAULT_INCOME_INTERVAL then
		vaultTimer = 0
		local income = BaseManager.GetVaultPassiveIncome()
		if income > 0 then
			income = math.floor(income * EconomyConfig.VAULT_INCOME_MULTIPLIER)
			for _, p in ipairs(Players:GetPlayers()) do
				EconomyManager.AddCells(p, income)
			end
		end
	end
end

function EconomyManager._Notify(player: Player)
	if Events then
		Events.CellsUpdate:FireClient(player, { cells = playerCells[player.UserId] or 0 })
	end
end

return EconomyManager
