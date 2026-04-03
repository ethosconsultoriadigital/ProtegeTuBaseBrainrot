-- BaseManager
-- Barrera HP, boveda, brecha, infiltracion, robo, nucleo
-- Ubicación: ServerScriptService > Systems > BaseManager (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local BrainrotConfig = require(ReplicatedStorage.Modules.BrainrotConfig)

local BaseManager = {}

local barrierHP     = 0
local barrierMaxHP  = 0
local coreHP        = 0
local coreMaxHP     = 0
local breached      = false
local repairCount   = 0
local vault: {any}  = {}

local barrierPart: BasePart? = nil
local Events = nil

-- Callbacks
local onGameOver       = nil
local onBrainrotStolen = nil

function BaseManager.Init()
	barrierMaxHP = GameConfig.BARRIER_MAX_HP
	barrierHP    = barrierMaxHP
	coreMaxHP    = GameConfig.CORE_MAX_HP
	coreHP       = coreMaxHP
	breached     = false
	repairCount  = 0
	vault        = {}

	Events = ReplicatedStorage:FindFirstChild("Events")

	local base = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Base")
	if base then barrierPart = base:FindFirstChild("Barrier") end
	BaseManager._UpdateVisual()
end

function BaseManager.OnGameOver(cb) onGameOver = cb end
function BaseManager.OnBrainrotStolen(cb) onBrainrotStolen = cb end

-----------------------------------------------------------------------
-- BARRIER DAMAGE
-----------------------------------------------------------------------
function BaseManager.DamageBarrier(amount: number)
	if breached then return end
	barrierHP = math.max(0, barrierHP - amount)
	BaseManager._UpdateVisual()
	BaseManager._FireBarrierUpdate()
	if barrierHP <= 0 and not breached then BaseManager._TriggerBreach() end
end

function BaseManager._TriggerBreach()
	breached = true
	print("[BaseManager] BRECHA!")
	if Events then Events.BreachStarted:FireAllClients() end
end

-----------------------------------------------------------------------
-- BRAINROT ARRIVAL
-----------------------------------------------------------------------
function BaseManager.HandleBrainrotArrival(brData: any)
	if not breached then
		BaseManager.DamageBarrier(brData.barrierDamage)
	else
		BaseManager._Infiltrate(brData)
	end
end

function BaseManager._Infiltrate(brData: any)
	task.spawn(function()
		task.wait(GameConfig.INFILTRATOR_TRAVEL_TIME)
		if not breached then return end

		if #vault > 0 then
			-- Thief roba mas rapido
			local stealTime = GameConfig.INFILTRATOR_STEAL_TIME * (brData.stealTimeMult or 1)
			task.wait(stealTime)
			if not breached then return end

			table.sort(vault, function(a, b) return a.vaultValue > b.vaultValue end)
			local stolen = table.remove(vault, 1)
			if stolen then
				print("[BaseManager] Robado: " .. stolen.className .. " " .. stolen.rarityName)
				if Events then
					Events.BrainrotStolen:FireAllClients({
						className = stolen.className,
						rarity = stolen.rarityName,
						vaultValue = stolen.vaultValue,
						remainingInVault = #vault,
					})
				end
				if onBrainrotStolen then onBrainrotStolen(stolen) end
			end
		else
			-- Boveda vacia -> atacar nucleo
			coreHP = math.max(0, coreHP - brData.barrierDamage)
			print("[BaseManager] Nucleo: " .. coreHP .. "/" .. coreMaxHP)
			if coreHP <= 0 and onGameOver then
				onGameOver("core_destroyed")
			end
		end
	end)
end

-----------------------------------------------------------------------
-- REPAIR
-----------------------------------------------------------------------
function BaseManager.GetRepairCost(): number
	return GameConfig.BARRIER_REPAIR_COST + (repairCount * GameConfig.BARRIER_REPAIR_ESCALATION)
end

function BaseManager.TryRepairBarrier(): (boolean, number)
	if barrierHP >= barrierMaxHP then return false, 0 end
	local cost = BaseManager.GetRepairCost()
	repairCount += 1
	barrierHP = math.min(barrierMaxHP, barrierHP + GameConfig.BARRIER_REPAIR_AMOUNT)

	if breached and barrierHP > 0 then
		breached = false
		print("[BaseManager] Barrera reparada")
		if Events then Events.BreachEnded:FireAllClients() end
	end

	BaseManager._UpdateVisual()
	BaseManager._FireBarrierUpdate()
	return true, cost
end

-----------------------------------------------------------------------
-- VAULT
-----------------------------------------------------------------------
function BaseManager.AddToVault(brData: any): boolean
	if #vault >= GameConfig.VAULT_MAX_SLOTS then return false end
	table.insert(vault, {
		className  = brData.className,
		rarityName = brData.rarityName,
		vaultValue = brData.vaultValue,
		vaultIncome = brData.vaultIncome,
	})
	return true
end

function BaseManager.GetVault() return vault end

function BaseManager.GetVaultTotalValue(): number
	local t = 0
	for _, v in ipairs(vault) do t += v.vaultValue end
	return t
end

function BaseManager.GetVaultPassiveIncome(): number
	local t = 0
	for _, v in ipairs(vault) do t += v.vaultIncome end
	return t
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function BaseManager.GetBarrierHP() return barrierHP end
function BaseManager.GetBarrierMaxHP() return barrierMaxHP end
function BaseManager.GetBarrierPct() return barrierHP / barrierMaxHP end
function BaseManager.IsBreached() return breached end
function BaseManager.GetCoreHP() return coreHP end
function BaseManager.GetVaultCount() return #vault end

-----------------------------------------------------------------------
-- VISUAL
-----------------------------------------------------------------------
function BaseManager._UpdateVisual()
	if not barrierPart then return end
	local r = barrierHP / barrierMaxHP
	if r > 0.6 then
		barrierPart.Color = Color3.fromRGB(0, 229, 255)
	elseif r > 0.3 then
		barrierPart.Color = Color3.fromRGB(255, 193, 7)
	elseif r > 0 then
		barrierPart.Color = Color3.fromRGB(244, 67, 54)
	else
		barrierPart.Color = Color3.fromRGB(80, 0, 0)
	end
	barrierPart.Transparency = 0.3 + (1 - r) * 0.5
end

function BaseManager._FireBarrierUpdate()
	if Events then
		Events.BarrierUpdate:FireAllClients({
			currentHP = barrierHP, maxHP = barrierMaxHP,
			percentage = barrierHP / barrierMaxHP,
		})
	end
end

return BaseManager
