-- BaseManager.lua
-- Gestiona barrera HP, bóveda, brecha e infiltración
-- Ubicación: ServerScriptService/Systems/BaseManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local BaseManager = {}

-- Estado
local barrierHP = 0
local barrierMaxHP = 0
local coreHP = 0
local coreMaxHP = 0
local breached = false
local repairCount = 0

-- Bóveda: lista de brainrots capturados {className, rarityName, vaultValue, vaultIncome}
local vault: {any} = {}

-- Callbacks
local onGameOver = nil  -- function(reason)
local onBrainrotStolen = nil -- function(stolenBrainrot)

-- Refs visuales
local barrierPart: BasePart? = nil
local corePart: BasePart? = nil
local Events = nil

function BaseManager.Init()
	barrierMaxHP = GameConfig.BARRIER_MAX_HP
	barrierHP = barrierMaxHP
	coreMaxHP = GameConfig.CORE_MAX_HP
	coreHP = coreMaxHP
	breached = false
	repairCount = 0
	vault = {}

	Events = ReplicatedStorage:FindFirstChild("Events")

	-- Encontrar parts visuales
	local base = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Base")
	if base then
		barrierPart = base:FindFirstChild("Barrier")
		corePart = base:FindFirstChild("Core")
	end

	BaseManager._UpdateBarrierVisual()
end

function BaseManager.OnGameOver(callback)
	onGameOver = callback
end

function BaseManager.OnBrainrotStolen(callback)
	onBrainrotStolen = callback
end

-- Dañar barrera
function BaseManager.DamageBarrier(amount: number)
	if breached then return end -- Ya breached, daño va al núcleo o al robo

	barrierHP = math.max(0, barrierHP - amount)
	BaseManager._UpdateBarrierVisual()

	-- Notificar clientes
	if Events then
		Events.BarrierUpdate:FireAllClients({
			currentHP = barrierHP,
			maxHP = barrierMaxHP,
			percentage = barrierHP / barrierMaxHP,
		})
	end

	-- Detectar brecha
	if barrierHP <= 0 and not breached then
		BaseManager._TriggerBreach()
	end
end

-- Trigger de brecha
function BaseManager._TriggerBreach()
	breached = true
	print("[BaseManager] ¡BRECHA EN LA BASE!")

	if Events then
		Events.BreachStarted:FireAllClients()
	end
end

-- Un brainrot llegó al final del camino
function BaseManager.HandleBrainrotArrival(brainrotData: any)
	if not breached then
		-- Dañar barrera
		BaseManager.DamageBarrier(brainrotData.barrierDamage)
	else
		-- Brecha activa: infiltrar
		BaseManager._HandleInfiltrator(brainrotData)
	end
end

-- Lógica de infiltración
function BaseManager._HandleInfiltrator(brainrotData: any)
	-- Simular viaje a la bóveda (instantáneo en MVP, con delay via coroutine)
	task.spawn(function()
		task.wait(GameConfig.INFILTRATOR_TRAVEL_TIME)

		-- Si la barrera fue reparada mientras viajaba, cancelar
		if not breached then return end

		-- Intentar robar el brainrot más valioso
		if #vault > 0 then
			task.wait(GameConfig.INFILTRATOR_STEAL_TIME)
			if not breached then return end

			-- Ordenar bóveda por valor (mayor primero) y robar el top
			table.sort(vault, function(a, b) return a.vaultValue > b.vaultValue end)
			local stolen = table.remove(vault, 1)

			if stolen then
				print("[BaseManager] ¡Brainrot robado! " .. stolen.className .. " " .. stolen.rarityName)

				if Events then
					Events.BrainrotStolen:FireAllClients({
						className = stolen.className,
						rarity = stolen.rarityName,
						vaultValue = stolen.vaultValue,
						remainingInVault = #vault,
					})
				end

				if onBrainrotStolen then
					onBrainrotStolen(stolen)
				end
			end
		else
			-- Bóveda vacía: atacar núcleo
			coreHP = math.max(0, coreHP - brainrotData.barrierDamage)
			print("[BaseManager] Núcleo dañado:", coreHP, "/", coreMaxHP)

			if coreHP <= 0 then
				if onGameOver then
					onGameOver("core_destroyed")
				end
			end
		end
	end)
end

-- Reparar barrera
function BaseManager.TryRepairBarrier(): (boolean, number)
	if barrierHP >= barrierMaxHP then return false, 0 end

	local cost = GameConfig.BARRIER_REPAIR_COST + (repairCount * GameConfig.BARRIER_REPAIR_ESCALATION)
	repairCount = repairCount + 1

	barrierHP = math.min(barrierMaxHP, barrierHP + GameConfig.BARRIER_REPAIR_AMOUNT)

	-- Si estaba breached y ahora hay barrera, terminar brecha
	if breached and barrierHP > 0 then
		breached = false
		print("[BaseManager] Barrera reparada, brecha terminada")
		if Events then
			Events.BreachEnded:FireAllClients()
		end
	end

	BaseManager._UpdateBarrierVisual()

	if Events then
		Events.BarrierUpdate:FireAllClients({
			currentHP = barrierHP,
			maxHP = barrierMaxHP,
			percentage = barrierHP / barrierMaxHP,
		})
	end

	return true, cost
end

-- Obtener costo actual de reparación
function BaseManager.GetRepairCost(): number
	return GameConfig.BARRIER_REPAIR_COST + (repairCount * GameConfig.BARRIER_REPAIR_ESCALATION)
end

-- Añadir brainrot a la bóveda
function BaseManager.AddToVault(brainrotData: any): boolean
	if #vault >= GameConfig.VAULT_MAX_SLOTS then
		return false -- Bóveda llena
	end

	table.insert(vault, {
		className = brainrotData.className,
		rarityName = brainrotData.rarityName,
		vaultValue = brainrotData.vaultValue,
		vaultIncome = brainrotData.vaultIncome,
	})

	return true
end

-- Obtener contenido de la bóveda
function BaseManager.GetVault(): {any}
	return vault
end

-- Obtener valor total de la bóveda
function BaseManager.GetVaultTotalValue(): number
	local total = 0
	for _, item in ipairs(vault) do
		total = total + item.vaultValue
	end
	return total
end

-- Obtener ingreso pasivo total de la bóveda (cells por tick)
function BaseManager.GetVaultPassiveIncome(): number
	local total = 0
	for _, item in ipairs(vault) do
		total = total + item.vaultIncome
	end
	return total
end

-- Getters
function BaseManager.GetBarrierHP(): number return barrierHP end
function BaseManager.GetBarrierMaxHP(): number return barrierMaxHP end
function BaseManager.GetBarrierPercentage(): number return barrierHP / barrierMaxHP end
function BaseManager.IsBreached(): boolean return breached end
function BaseManager.GetCoreHP(): number return coreHP end
function BaseManager.GetVaultCount(): number return #vault end

-- Visual de barrera
function BaseManager._UpdateBarrierVisual()
	if not barrierPart then return end

	local ratio = barrierHP / barrierMaxHP

	-- Color: Cyan → Amarillo → Rojo
	if ratio > 0.6 then
		barrierPart.Color = Color3.fromRGB(0, 229, 255) -- Cyan
	elseif ratio > 0.3 then
		barrierPart.Color = Color3.fromRGB(255, 193, 7) -- Amarillo
	elseif ratio > 0 then
		barrierPart.Color = Color3.fromRGB(244, 67, 54) -- Rojo
	else
		barrierPart.Color = Color3.fromRGB(80, 0, 0)    -- Rojo oscuro (destruida)
	end

	-- Transparencia: más dañada = más transparente
	barrierPart.Transparency = 0.3 + (1 - ratio) * 0.5
end

return BaseManager
