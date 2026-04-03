-- CaptureManager
-- Roll de captura, transfer a boveda, recompensas
-- Ubicación: ServerScriptService > Systems > CaptureManager (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local CaptureManager = {}

local BrainrotManager = nil
local BaseManager     = nil
local EconomyManager  = nil
local Events          = nil

function CaptureManager.Init(brMgr, baseMgr, ecoMgr)
	BrainrotManager = brMgr
	BaseManager     = baseMgr
	EconomyManager  = ecoMgr
	Events = ReplicatedStorage:FindFirstChild("Events")
end

function CaptureManager.TryCapture(brainrotId: string, captureMult: number): boolean
	local br = BrainrotManager.Get(brainrotId)
	if not br or not br.alive then return false end

	-- Roll
	local prob = br.captureRate * captureMult
	if math.random() > prob then return false end

	-- Boveda llena?
	if not BaseManager.AddToVault(br) then return false end

	-- Exito
	BrainrotManager.Remove(brainrotId)

	-- Recompensa
	if EconomyManager then
		for _, player in ipairs(Players:GetPlayers()) do
			EconomyManager.AddCells(player, br.captureBonus)
		end
	end

	-- Notificar
	if Events then
		Events.BrainrotCaptured:FireAllClients({
			id        = brainrotId,
			className = br.className,
			rarity    = br.rarityName,
			vaultValue = br.vaultValue,
			vaultCount = BaseManager.GetVaultCount(),
			vaultMax   = GameConfig.VAULT_MAX_SLOTS,
		})
	end

	print("[Capture] " .. br.className .. " " .. br.rarityName .. " capturado!")
	return true
end

return CaptureManager
