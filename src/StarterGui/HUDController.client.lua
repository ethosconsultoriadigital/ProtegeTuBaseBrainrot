-- HUDController.client.lua
-- Crea y gestiona toda la UI del HUD en tiempo real
-- Ubicación: StarterGui/GameHUD/HUDController (LocalScript dentro de ScreenGui)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DefenseConfig = require(Modules:WaitForChild("DefenseConfig"))
local GameConfig = require(Modules:WaitForChild("GameConfig"))
local BrainrotConfig = require(Modules:WaitForChild("BrainrotConfig"))

local player = Players.LocalPlayer
local screenGui = script.Parent -- ScreenGui

-- ================================
-- CREAR UI PROGRAMÁTICAMENTE
-- ================================

local function CreateUICorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function CreateUIPadding(parent, t, b, l, r)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, t or 4)
	padding.PaddingBottom = UDim.new(0, b or 4)
	padding.PaddingLeft = UDim.new(0, l or 8)
	padding.PaddingRight = UDim.new(0, r or 8)
	padding.Parent = parent
	return padding
end

-- ================================
-- TOP BAR: Oleada, Timer, Cells
-- ================================

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
topBar.BackgroundTransparency = 0.2
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local topBarLayout = Instance.new("UIListLayout")
topBarLayout.FillDirection = Enum.FillDirection.Horizontal
topBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topBarLayout.Padding = UDim.new(0, 20)
topBarLayout.Parent = topBar

-- Wave label
local waveLabel = Instance.new("TextLabel")
waveLabel.Name = "WaveLabel"
waveLabel.Size = UDim2.new(0, 250, 0, 40)
waveLabel.BackgroundTransparency = 1
waveLabel.Text = "ESPERANDO..."
waveLabel.TextColor3 = Color3.fromRGB(0, 229, 255)
waveLabel.TextSize = 20
waveLabel.Font = Enum.Font.GothamBold
waveLabel.Parent = topBar

-- Timer label
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0, 120, 0, 40)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = ""
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 18
timerLabel.Font = Enum.Font.GothamMedium
timerLabel.Parent = topBar

-- Cells label
local cellsLabel = Instance.new("TextLabel")
cellsLabel.Name = "CellsLabel"
cellsLabel.Size = UDim2.new(0, 200, 0, 40)
cellsLabel.BackgroundTransparency = 1
cellsLabel.Text = "Cells: 500"
cellsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
cellsLabel.TextSize = 22
cellsLabel.Font = Enum.Font.GothamBold
cellsLabel.Parent = topBar

-- ================================
-- STATUS BAR: Barrera + Bóveda
-- ================================

local statusBar = Instance.new("Frame")
statusBar.Name = "StatusBar"
statusBar.Size = UDim2.new(1, 0, 0, 40)
statusBar.Position = UDim2.new(0, 0, 0, 52)
statusBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
statusBar.BackgroundTransparency = 0.3
statusBar.BorderSizePixel = 0
statusBar.Parent = screenGui

-- Barrier section
local barrierFrame = Instance.new("Frame")
barrierFrame.Name = "BarrierFrame"
barrierFrame.Size = UDim2.new(0.45, 0, 0, 28)
barrierFrame.Position = UDim2.new(0.025, 0, 0, 6)
barrierFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
barrierFrame.BorderSizePixel = 0
barrierFrame.Parent = statusBar
CreateUICorner(barrierFrame, 6)

local barrierFill = Instance.new("Frame")
barrierFill.Name = "Fill"
barrierFill.Size = UDim2.new(1, 0, 1, 0)
barrierFill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
barrierFill.BorderSizePixel = 0
barrierFill.Parent = barrierFrame
CreateUICorner(barrierFill, 6)

local barrierText = Instance.new("TextLabel")
barrierText.Name = "Text"
barrierText.Size = UDim2.new(1, 0, 1, 0)
barrierText.BackgroundTransparency = 1
barrierText.Text = "BARRERA: 100%"
barrierText.TextColor3 = Color3.new(1, 1, 1)
barrierText.TextSize = 14
barrierText.Font = Enum.Font.GothamBold
barrierText.ZIndex = 2
barrierText.Parent = barrierFrame

-- Vault section
local vaultLabel = Instance.new("TextLabel")
vaultLabel.Name = "VaultLabel"
vaultLabel.Size = UDim2.new(0.25, 0, 0, 28)
vaultLabel.Position = UDim2.new(0.5, 0, 0, 6)
vaultLabel.BackgroundColor3 = Color3.fromRGB(0, 77, 64)
vaultLabel.BorderSizePixel = 0
vaultLabel.Text = "BOVEDA: 0/" .. GameConfig.VAULT_MAX_SLOTS
vaultLabel.TextColor3 = Color3.fromRGB(0, 191, 165)
vaultLabel.TextSize = 14
vaultLabel.Font = Enum.Font.GothamBold
vaultLabel.Parent = statusBar
CreateUICorner(vaultLabel, 6)

-- Repair button hint
local repairHint = Instance.new("TextLabel")
repairHint.Name = "RepairHint"
repairHint.Size = UDim2.new(0.2, 0, 0, 28)
repairHint.Position = UDim2.new(0.775, 0, 0, 6)
repairHint.BackgroundTransparency = 1
repairHint.Text = "[R] Reparar"
repairHint.TextColor3 = Color3.fromRGB(180, 180, 180)
repairHint.TextSize = 13
repairHint.Font = Enum.Font.GothamMedium
repairHint.Parent = statusBar

-- ================================
-- HOTBAR: Defensas
-- ================================

local hotbar = Instance.new("Frame")
hotbar.Name = "Hotbar"
hotbar.Size = UDim2.new(0, 360, 0, 80)
hotbar.Position = UDim2.new(0.5, -180, 1, -90)
hotbar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
hotbar.BackgroundTransparency = 0.15
hotbar.BorderSizePixel = 0
hotbar.Parent = screenGui
CreateUICorner(hotbar, 10)

local hotbarLayout = Instance.new("UIListLayout")
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
hotbarLayout.Padding = UDim.new(0, 10)
hotbarLayout.Parent = hotbar
CreateUIPadding(hotbar, 8, 8, 10, 10)

-- Crear botones de defensa
for i, defType in ipairs(DefenseConfig.HotbarOrder) do
	local def = DefenseConfig.Defenses[defType]
	local stats = DefenseConfig.GetStats(defType, 1)

	local btn = Instance.new("TextButton")
	btn.Name = defType
	btn.Size = UDim2.new(0, 100, 0, 60)
	btn.BackgroundColor3 = def.color
	btn.BackgroundTransparency = 0.4
	btn.BorderSizePixel = 0
	btn.Text = "[" .. i .. "] " .. def.displayName .. "\n$" .. stats.cost
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.TextWrapped = true
	btn.Parent = hotbar
	CreateUICorner(btn, 8)

	btn.MouseButton1Click:Connect(function()
		local PlacementController = require(
			player.PlayerScripts:WaitForChild("Controllers"):WaitForChild("PlacementController")
		)
		if PlacementController.IsPlacing() and PlacementController.GetSelectedType() == defType then
			PlacementController.CancelPlacing()
		else
			PlacementController.StartPlacing(defType)
		end
	end)
end

-- ================================
-- CONTROLES HINT
-- ================================

local controlsHint = Instance.new("TextLabel")
controlsHint.Name = "ControlsHint"
controlsHint.Size = UDim2.new(0, 300, 0, 20)
controlsHint.Position = UDim2.new(0.5, -150, 1, -18)
controlsHint.BackgroundTransparency = 1
controlsHint.Text = "WASD: Cámara | Scroll: Zoom | F: Saltar timer | ESC: Cancelar"
controlsHint.TextColor3 = Color3.fromRGB(130, 130, 150)
controlsHint.TextSize = 10
controlsHint.Font = Enum.Font.Gotham
controlsHint.Parent = screenGui

-- ================================
-- NOTIFICACIÓN CENTRAL (Oleadas, capturas, brecha)
-- ================================

local notifLabel = Instance.new("TextLabel")
notifLabel.Name = "CenterNotif"
notifLabel.Size = UDim2.new(0.6, 0, 0, 50)
notifLabel.Position = UDim2.new(0.2, 0, 0.15, 0)
notifLabel.BackgroundTransparency = 1
notifLabel.Text = ""
notifLabel.TextColor3 = Color3.new(1, 1, 1)
notifLabel.TextSize = 28
notifLabel.Font = Enum.Font.GothamBold
notifLabel.TextStrokeTransparency = 0.5
notifLabel.TextTransparency = 1
notifLabel.Parent = screenGui

local function ShowNotification(text: string, color: Color3?, duration: number?)
	notifLabel.Text = text
	notifLabel.TextColor3 = color or Color3.new(1, 1, 1)
	notifLabel.TextTransparency = 0
	notifLabel.TextStrokeTransparency = 0.3

	local dur = duration or 2.5
	task.delay(dur, function()
		local tween = TweenService:Create(notifLabel, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1})
		tween:Play()
	end)
end

-- ================================
-- BREACH OVERLAY
-- ================================

local breachOverlay = Instance.new("Frame")
breachOverlay.Name = "BreachOverlay"
breachOverlay.Size = UDim2.new(1, 0, 1, 0)
breachOverlay.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
breachOverlay.BackgroundTransparency = 1
breachOverlay.BorderSizePixel = 0
breachOverlay.ZIndex = 0
breachOverlay.Parent = screenGui

-- ================================
-- RESULTS SCREEN
-- ================================

local resultsFrame = Instance.new("Frame")
resultsFrame.Name = "ResultsScreen"
resultsFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
resultsFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
resultsFrame.BackgroundTransparency = 0.1
resultsFrame.BorderSizePixel = 0
resultsFrame.Visible = false
resultsFrame.ZIndex = 10
resultsFrame.Parent = screenGui
CreateUICorner(resultsFrame, 12)

local resultsTitle = Instance.new("TextLabel")
resultsTitle.Name = "Title"
resultsTitle.Size = UDim2.new(1, 0, 0, 60)
resultsTitle.BackgroundTransparency = 1
resultsTitle.Text = "RESULTADOS"
resultsTitle.TextColor3 = Color3.new(1, 1, 1)
resultsTitle.TextSize = 32
resultsTitle.Font = Enum.Font.GothamBold
resultsTitle.ZIndex = 11
resultsTitle.Parent = resultsFrame

local resultsBody = Instance.new("TextLabel")
resultsBody.Name = "Body"
resultsBody.Size = UDim2.new(0.9, 0, 0.7, 0)
resultsBody.Position = UDim2.new(0.05, 0, 0.2, 0)
resultsBody.BackgroundTransparency = 1
resultsBody.Text = ""
resultsBody.TextColor3 = Color3.fromRGB(200, 200, 220)
resultsBody.TextSize = 18
resultsBody.Font = Enum.Font.GothamMedium
resultsBody.TextXAlignment = Enum.TextXAlignment.Left
resultsBody.TextYAlignment = Enum.TextYAlignment.Top
resultsBody.TextWrapped = true
resultsBody.ZIndex = 11
resultsBody.Parent = resultsFrame

-- ================================
-- EVENT HANDLERS (actualizar UI)
-- ================================

-- Cells
Events.CellsUpdate.OnClientEvent:Connect(function(data)
	cellsLabel.Text = "Cells: " .. tostring(data.cells)
end)

-- Wave
Events.WaveStarted.OnClientEvent:Connect(function(data)
	local waveText = "OLEADA " .. data.waveNumber .. "/" .. data.totalWaves
	if data.isBoss then
		waveText = "!! BOSS !!"
	end
	waveLabel.Text = waveText

	if data.phase == "BUILD" then
		ShowNotification(data.waveName or waveText, Color3.fromRGB(0, 229, 255), 2)
		timerLabel.Text = "Construye!"
	elseif data.phase == "COMBAT" then
		timerLabel.Text = "COMBATE"
		if data.isBoss then
			ShowNotification("!! BOSS WAVE !!", Color3.fromRGB(255, 60, 60), 3)
		end
	end
end)

Events.WaveEnded.OnClientEvent:Connect(function(data)
	if data.wasPerfect then
		ShowNotification("OLEADA PERFECTA!", Color3.fromRGB(255, 215, 0), 2)
	else
		ShowNotification("Oleada completada", Color3.fromRGB(100, 255, 100), 1.5)
	end
end)

-- Barrier
Events.BarrierUpdate.OnClientEvent:Connect(function(data)
	local pct = math.floor(data.percentage * 100)
	barrierText.Text = "BARRERA: " .. pct .. "%"
	barrierFill.Size = UDim2.new(math.clamp(data.percentage, 0, 1), 0, 1, 0)

	if data.percentage > 0.6 then
		barrierFill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
	elseif data.percentage > 0.3 then
		barrierFill.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
	else
		barrierFill.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
	end
end)

-- Breach
Events.BreachStarted.OnClientEvent:Connect(function()
	ShowNotification("!! BRECHA EN LA BASE !!", Color3.fromRGB(255, 0, 0), 4)
	-- Pulso rojo
	task.spawn(function()
		while breachOverlay do
			breachOverlay.BackgroundTransparency = 0.85
			task.wait(0.5)
			if not breachOverlay or not breachOverlay.Parent then break end
			breachOverlay.BackgroundTransparency = 0.95
			task.wait(0.5)
		end
	end)
end)

Events.BreachEnded.OnClientEvent:Connect(function()
	breachOverlay.BackgroundTransparency = 1
	ShowNotification("Barrera reparada", Color3.fromRGB(0, 229, 255), 2)
end)

-- Capture
Events.BrainrotCaptured.OnClientEvent:Connect(function(data)
	local rarityColor = BrainrotConfig.Rarities[data.rarity] and BrainrotConfig.Rarities[data.rarity].color or Color3.new(1,1,1)
	ShowNotification("CAPTURA: " .. data.className .. " " .. data.rarity .. "!", rarityColor, 2)
	vaultLabel.Text = "BOVEDA: " .. data.vaultCount .. "/" .. data.vaultMax
end)

-- Stolen
Events.BrainrotStolen.OnClientEvent:Connect(function(data)
	ShowNotification("ROBADO: " .. data.className .. " " .. data.rarity .. "!", Color3.fromRGB(255, 0, 0), 3)
	vaultLabel.Text = "BOVEDA: " .. data.remainingInVault .. "/" .. GameConfig.VAULT_MAX_SLOTS
end)

-- Game Over
Events.GameOver.OnClientEvent:Connect(function(data)
	resultsFrame.Visible = true

	if data.result == "VICTORY" then
		resultsTitle.Text = "VICTORIA!"
		resultsTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
	else
		resultsTitle.Text = "DERROTA"
		resultsTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
	end

	local stats = data.stats
	resultsBody.Text = string.format(
		"Oleadas completadas: %d\n"
		.. "Oleadas perfectas: %d\n"
		.. "Kills totales: %d\n"
		.. "Valor de boveda: %d pts\n"
		.. "\nRazon: %s",
		stats.wavesCompleted,
		stats.perfectWaves,
		stats.totalKills,
		stats.vaultValue,
		data.reason or "---"
	)
end)

print("[HUDController] UI inicializada")
