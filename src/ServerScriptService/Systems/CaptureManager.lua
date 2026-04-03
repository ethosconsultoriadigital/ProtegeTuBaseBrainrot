-- CaptureManager.lua
-- Lógica de captura de brainrots
-- Ubicación: ServerScriptService/Systems/CaptureManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CaptureManager = {}

local BrainrotManager = nil
local BaseManager = nil
local EconomyManager = nil
local Events = nil

function CaptureManager.Init(brainrotMgr, baseMgr, economyMgr)
	BrainrotManager = brainrotMgr
	BaseManager = baseMgr
	EconomyManager = economyMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
end

-- Intentar capturar un brainrot (llamado por DefenseManager desde módulo de captura)
function CaptureManager.TryCapture(brainrotId: string, captureMultiplier: number): boolean
	local br = BrainrotManager.GetBrainrot(brainrotId)
	if not br or not br.alive then return false end

	-- Roll de probabilidad
	local finalRate = br.captureRate * captureMultiplier
	local roll = math.random()

	if roll > finalRate then
		-- Falló la captura
		return false
	end

	-- Intentar añadir a la bóveda
	local added = BaseManager.AddToVault(br)
	if not added then
		-- Bóveda llena
		return false
	end

	-- Captura exitosa: remover brainrot del campo
	BrainrotManager.Remove(brainrotId)

	-- Dar recompensa de captura
	if EconomyManager then
		-- Dar cells a todos los jugadores (en MVP solo hay 1)
		for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
			EconomyManager.AddCells(player, br.captureReward)
		end
	end

	-- Notificar clientes
	if Events then
		Events.BrainrotCaptured:FireAllClients({
			id = brainrotId,
			className = br.className,
			rarity = br.rarityName,
			vaultValue = br.vaultValue,
			vaultCount = BaseManager.GetVaultCount(),
			vaultMax = require(ReplicatedStorage.Modules.GameConfig).VAULT_MAX_SLOTS,
		})
	end

	print("[CaptureManager] ¡Captura exitosa! " .. br.className .. " " .. br.rarityName)
	return true
end

return CaptureManager
