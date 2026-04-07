-- BaseManager
-- Barrera HP, bóveda, brecha, infiltración, robo, núcleo
-- Ubicación: ServerScriptService > Systems > BaseManager (ModuleScript)
--
-- Responsabilidades:
--   - Barrera con HP, daño, reparación con costo escalante
--   - Estado de brecha cuando barrera cae a 0
--   - Bóveda de capturas (max 6 slots)
--   - Infiltración: brainrots que pasan la barrera roban de la bóveda
--   - Thief roba más rápido (stealTimeMult = 0.5)
--   - Si bóveda vacía + barrera caída → daño al núcleo
--   - Núcleo a 0 HP → game over
--
-- NO maneja: economía, defensas, UI. Solo estado de la base.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig    = require(ReplicatedStorage.Modules.GameConfig)
local BrainrotConfig = require(ReplicatedStorage.Modules.BrainrotConfig)

local BaseManager = {}

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local barrierHP    = 0
local barrierMaxHP = 0
local coreHP       = 0
local coreMaxHP    = 0
local breached     = false
local repairCount  = 0
local vault: {any} = {}   -- array de {className, rarityName, vaultValue, vaultIncome}

local barrierPart: BasePart? = nil
local Events = nil

-- Callbacks (arrays para permitir multiples listeners)
local onGameOverCallbacks: {(reason: string) -> ()} = {}
local onBrainrotStolenCallbacks: {(stolen: any) -> ()} = {}

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function BaseManager.Init()
	barrierMaxHP = GameConfig.BARRIER_MAX_HP
	barrierHP    = barrierMaxHP
	coreMaxHP    = GameConfig.CORE_MAX_HP
	coreHP       = coreMaxHP
	breached     = false
	repairCount  = 0
	vault        = {}

	Events = ReplicatedStorage:FindFirstChild("Events")
	if not Events then
		warn("[BaseManager] ReplicatedStorage.Events no encontrado — sin replicacion al cliente")
	end

	-- Buscar la Part de la barrera en el mapa para visual feedback
	local base = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Base")
	if base then barrierPart = base:FindFirstChild("Barrier") end
	if not barrierPart then
		warn("[BaseManager] Map.Base.Barrier no encontrado — sin feedback visual de la barrera")
	end
	BaseManager._UpdateBarrierVisual()

	print("[BaseManager] Init OK — Barrera: " .. barrierHP .. " HP, Core: " .. coreHP .. " HP")
end

-----------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------
function BaseManager.OnGameOver(cb)
	table.insert(onGameOverCallbacks, cb)
end

function BaseManager.OnBrainrotStolen(cb)
	table.insert(onBrainrotStolenCallbacks, cb)
end

-----------------------------------------------------------------------
-- BARRIER DAMAGE
-----------------------------------------------------------------------
function BaseManager.DamageBarrier(amount: number)
	if breached then return end

	barrierHP = math.max(0, barrierHP - amount)
	BaseManager._UpdateBarrierVisual()
	BaseManager._FireBarrierUpdate()

	if barrierHP <= 0 and not breached then
		BaseManager._TriggerBreach()
	end
end

function BaseManager._TriggerBreach()
	breached = true
	print("[BaseManager] === BRECHA! La barrera ha caido ===")
	if Events then Events.BreachStarted:FireAllClients({}) end
end

-----------------------------------------------------------------------
-- BRAINROT ARRIVAL (llamado cuando un brainrot llega al final del path)
-----------------------------------------------------------------------
function BaseManager.HandleBrainrotArrival(brData: any)
	if not breached then
		-- Barrera activa: dañarla
		BaseManager.DamageBarrier(brData.barrierDamage)
		print("[Base] Barrera golpeada por " .. brData.className .. " " .. brData.rarityName
			.. " (-" .. brData.barrierDamage .. " HP) → " .. barrierHP .. "/" .. barrierMaxHP)
	else
		-- Barrera caída: infiltración
		BaseManager._Infiltrate(brData)
	end
end

-----------------------------------------------------------------------
-- INFILTRACION
-- El brainrot viaja a la bóveda, luego intenta robar.
-- Thief roba al 50% del tiempo normal (stealTimeMult = 0.5)
-----------------------------------------------------------------------
function BaseManager._Infiltrate(brData: any)
	task.spawn(function()
		-- Tiempo de viaje hasta la bóveda
		task.wait(GameConfig.INFILTRATOR_TRAVEL_TIME)
		-- Si la barrera fue reparada durante el viaje, cancelar
		if not breached then return end

		if #vault > 0 then
			-- Robar de la bóveda (Thief roba más rápido)
			local stealTime = GameConfig.INFILTRATOR_STEAL_TIME * (brData.stealTimeMult or 1.0)
			print("[Base] " .. brData.className .. " infiltrando bóveda... ("
				.. string.format("%.1f", stealTime) .. "s)")
			task.wait(stealTime)

			-- Verificar de nuevo (la barrera pudo repararse o la bóveda vaciarse)
			if not breached or #vault == 0 then return end

			-- Robar el más valioso (ordenar por vaultValue descendente)
			table.sort(vault, function(a, b) return a.vaultValue > b.vaultValue end)
			local stolen = table.remove(vault, 1)

			if stolen then
				print("[Base] ROBADO: " .. stolen.className .. " " .. stolen.rarityName
					.. " (valor: " .. stolen.vaultValue .. ") — Quedan: " .. #vault)

				if Events then
					Events.BrainrotStolen:FireAllClients({
						className = stolen.className,
						rarity = stolen.rarityName,
						vaultValue = stolen.vaultValue,
						remainingInVault = #vault,
					})
				end

				for _, cb in ipairs(onBrainrotStolenCallbacks) do cb(stolen) end
			end
		else
			-- Bóveda vacía → atacar el núcleo directamente
			coreHP = math.max(0, coreHP - brData.barrierDamage)
			print("[Base] Nucleo golpeado! " .. coreHP .. "/" .. coreMaxHP)

			if coreHP <= 0 then
				for _, cb in ipairs(onGameOverCallbacks) do cb("core_destroyed") end
			end
		end
	end)
end

-----------------------------------------------------------------------
-- REPAIR (punto de integración para EconomyManager)
-- Retorna (success, costPaid)
-----------------------------------------------------------------------
function BaseManager.GetRepairCost(): number
	return GameConfig.BARRIER_REPAIR_COST + (repairCount * GameConfig.BARRIER_REPAIR_ESCALATION)
end

function BaseManager.TryRepairBarrier(): (boolean, number)
	if barrierHP >= barrierMaxHP then return false, 0 end

	local cost = BaseManager.GetRepairCost()
	repairCount += 1
	barrierHP = math.min(barrierMaxHP, barrierHP + GameConfig.BARRIER_REPAIR_AMOUNT)

	-- Si la barrera se repara estando breached → cerrar brecha
	if breached and barrierHP > 0 then
		breached = false
		print("[BaseManager] Barrera reparada — brecha cerrada")
		if Events then Events.BreachEnded:FireAllClients({}) end
	end

	BaseManager._UpdateBarrierVisual()
	BaseManager._FireBarrierUpdate()
	print("[Base] Reparacion #" .. repairCount .. " → " .. barrierHP .. "/" .. barrierMaxHP)
	return true, cost
end

-----------------------------------------------------------------------
-- VAULT
-----------------------------------------------------------------------
function BaseManager.AddToVault(brData: any): boolean
	if #vault >= GameConfig.VAULT_MAX_SLOTS then
		print("[Base] Bóveda llena! (" .. #vault .. "/" .. GameConfig.VAULT_MAX_SLOTS .. ")")
		return false
	end
	table.insert(vault, {
		className   = brData.className,
		rarityName  = brData.rarityName,
		vaultValue  = brData.vaultValue,
		vaultIncome = brData.vaultIncome,
	})
	print("[Base] Captura guardada en bóveda: " .. brData.className .. " " .. brData.rarityName
		.. " (" .. #vault .. "/" .. GameConfig.VAULT_MAX_SLOTS .. ")")
	return true
end

function BaseManager.GetVault()
	return vault
end

function BaseManager.GetVaultCount(): number
	return #vault
end

function BaseManager.GetVaultTotalValue(): number
	local total = 0
	for _, v in ipairs(vault) do total += v.vaultValue end
	return total
end

function BaseManager.GetVaultPassiveIncome(): number
	local total = 0
	for _, v in ipairs(vault) do total += v.vaultIncome end
	return total
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function BaseManager.GetBarrierHP(): number return barrierHP end
function BaseManager.GetBarrierMaxHP(): number return barrierMaxHP end
function BaseManager.GetBarrierPct(): number
	if barrierMaxHP == 0 then return 0 end
	return barrierHP / barrierMaxHP
end
function BaseManager.IsBreached(): boolean return breached end
function BaseManager.GetCoreHP(): number return coreHP end
function BaseManager.GetCoreMaxHP(): number return coreMaxHP end

-----------------------------------------------------------------------
-- VISUAL (feedback en la Part de la barrera)
-----------------------------------------------------------------------
function BaseManager._UpdateBarrierVisual()
	if not barrierPart then return end
	local ratio = barrierHP / barrierMaxHP

	if ratio > 0.6 then
		barrierPart.Color = Color3.fromRGB(0, 229, 255)       -- cyan (sano)
	elseif ratio > 0.3 then
		barrierPart.Color = Color3.fromRGB(255, 193, 7)       -- amarillo (dañado)
	elseif ratio > 0 then
		barrierPart.Color = Color3.fromRGB(244, 67, 54)       -- rojo (crítico)
	else
		barrierPart.Color = Color3.fromRGB(80, 0, 0)          -- oscuro (caída)
	end
	barrierPart.Transparency = 0.3 + (1 - ratio) * 0.5
end

function BaseManager._FireBarrierUpdate()
	if Events then
		Events.BarrierUpdate:FireAllClients({
			currentHP  = barrierHP,
			maxHP      = barrierMaxHP,
			percentage = barrierHP / barrierMaxHP,
		})
	end
end

return BaseManager
