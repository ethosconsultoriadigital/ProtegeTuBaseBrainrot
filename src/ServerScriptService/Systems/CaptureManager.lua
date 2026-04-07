-- CaptureManager
-- Roll de captura, transferencia a bóveda, recompensas
-- Ubicación: ServerScriptService > Systems > CaptureManager (ModuleScript)
--
-- Responsabilidades:
--   - TryCapture(brainrotId, captureMult): usado por DefenseManager (CaptureModule)
--   - TryAutoCapture(brData): captura automática al kill con probabilidad base
--     (para testear sin DefenseManager; en producción se desactiva)
--   - Roll de probabilidad basado en captureRate × captureMult
--   - Transferencia a bóveda via BaseManager
--   - Recompensa via EconomyManager
--   - Notificación de captura a clientes
--
-- NO maneja: lógica de defensas, UI. Solo el roll y transfer.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local CaptureManager = {}

-----------------------------------------------------------------------
-- DEPENDENCIAS (inyectadas)
-----------------------------------------------------------------------
local BrainrotManager = nil
local BaseManager     = nil
local EconomyManager  = nil
local Events          = nil

-----------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------
local totalCaptures = 0

-----------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------
function CaptureManager.Init(brMgr, baseMgr, ecoMgr)
	BrainrotManager = brMgr
	BaseManager     = baseMgr
	EconomyManager  = ecoMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
	if not Events then
		warn("[CaptureManager] ReplicatedStorage.Events no encontrado — sin notificacion de capturas")
	end
	if not BrainrotManager or not BaseManager then
		warn("[CaptureManager] Dependencias faltantes (BrainrotManager o BaseManager)")
	end
	totalCaptures = 0
	print("[CaptureManager] Init OK")
end

-----------------------------------------------------------------------
-- TRY CAPTURE (para DefenseManager / CaptureModule)
-- captureMult: multiplicador de la defensa (1.0 por defecto)
-- HP threshold check lo hace DefenseManager (solo intenta si HP < 30%)
-----------------------------------------------------------------------
function CaptureManager.TryCapture(brainrotId: string, captureMult: number): boolean
	local br = BrainrotManager.Get(brainrotId)
	if not br or not br.alive then return false end

	-- Roll de probabilidad: captureRate (de la rareza) × captureMult (de la defensa)
	local prob = br.captureRate * (captureMult or 1.0)
	if math.random() > prob then return false end

	-- Intentar meter en bóveda
	if not BaseManager.AddToVault(br) then return false end

	-- Captura exitosa → remover brainrot (sin trigger onDied)
	BrainrotManager.Remove(brainrotId)

	-- Recompensa económica
	if EconomyManager then
		EconomyManager.RewardCapture(br)
	end

	totalCaptures += 1

	-- Notificar clientes
	if Events then
		Events.BrainrotCaptured:FireAllClients({
			id         = brainrotId,
			className  = br.className,
			rarity     = br.rarityName,
			vaultValue = br.vaultValue,
			vaultCount = BaseManager.GetVaultCount(),
			vaultMax   = GameConfig.VAULT_MAX_SLOTS,
		})
	end

	print("[Capture] " .. br.className .. " " .. br.rarityName .. " capturado!"
		.. " (prob: " .. string.format("%.0f%%", prob * 100) .. ")"
		.. " — Bóveda: " .. BaseManager.GetVaultCount() .. "/" .. GameConfig.VAULT_MAX_SLOTS)
	return true
end

-----------------------------------------------------------------------
-- AUTO-CAPTURE ON KILL (para testeo sin DefenseManager)
-- Se llama cuando un brainrot muere por daño.
-- Usa la captureRate base de la rareza sin multiplicador de defensa.
-- En producción, esto se reemplaza por CaptureModule targeting.
-----------------------------------------------------------------------
function CaptureManager.TryAutoCapture(brData: any): boolean
	-- No intentar si bóveda llena
	if BaseManager.GetVaultCount() >= GameConfig.VAULT_MAX_SLOTS then return false end

	-- Roll con captureRate base (Normal=40%, Gold=20%, Diamond=10%)
	local prob = brData.captureRate or 0
	if math.random() > prob then return false end

	-- Meter en bóveda
	if not BaseManager.AddToVault(brData) then return false end

	-- Recompensa
	if EconomyManager then
		EconomyManager.RewardCapture(brData)
	end

	totalCaptures += 1

	-- Notificar
	if Events then
		Events.BrainrotCaptured:FireAllClients({
			id         = brData.id or "unknown",
			className  = brData.className,
			rarity     = brData.rarityName,
			vaultValue = brData.vaultValue,
			vaultCount = BaseManager.GetVaultCount(),
			vaultMax   = GameConfig.VAULT_MAX_SLOTS,
		})
	end

	print("[Capture] Auto-captura: " .. brData.className .. " " .. brData.rarityName
		.. " (prob: " .. string.format("%.0f%%", prob * 100) .. ")"
		.. " — Bóveda: " .. BaseManager.GetVaultCount() .. "/" .. GameConfig.VAULT_MAX_SLOTS)
	return true
end

-----------------------------------------------------------------------
-- GETTERS
-----------------------------------------------------------------------
function CaptureManager.GetTotalCaptures(): number
	return totalCaptures
end

return CaptureManager
