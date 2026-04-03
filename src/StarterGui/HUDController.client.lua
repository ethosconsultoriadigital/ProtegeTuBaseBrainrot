-- HUDController.client.lua
-- Crea y gestiona toda la UI del juego
-- Ubicación: StarterGui > GameHUD (ScreenGui) > HUDController (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events  = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DefenseConfig  = require(Modules:WaitForChild("DefenseConfig"))
local GameConfig     = require(Modules:WaitForChild("GameConfig"))
local BrainrotConfig = require(Modules:WaitForChild("BrainrotConfig"))

local player = Players.LocalPlayer
local gui = script.Parent -- ScreenGui

-----------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------
local function Corner(parent, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = parent end
local function Pad(parent, t, b, l, r)
	local p = Instance.new("UIPadding"); p.PaddingTop = UDim.new(0,t or 4); p.PaddingBottom = UDim.new(0,b or 4)
	p.PaddingLeft = UDim.new(0,l or 8); p.PaddingRight = UDim.new(0,r or 8); p.Parent = parent
end

-----------------------------------------------------------------------
-- TOP BAR
-----------------------------------------------------------------------
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
topBar.BackgroundTransparency = 0.15
topBar.BorderSizePixel = 0
topBar.Parent = gui

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Padding = UDim.new(0, 30)
topLayout.Parent = topBar

local waveLabel = Instance.new("TextLabel")
waveLabel.Size = UDim2.new(0, 260, 0, 38)
waveLabel.BackgroundTransparency = 1
waveLabel.Text = "ESPERANDO..."
waveLabel.TextColor3 = Color3.fromRGB(0, 229, 255)
waveLabel.TextSize = 20
waveLabel.Font = Enum.Font.GothamBold
waveLabel.Parent = topBar

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0, 120, 0, 38)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = ""
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.TextSize = 17
timerLabel.Font = Enum.Font.GothamMedium
timerLabel.Parent = topBar

local cellsLabel = Instance.new("TextLabel")
cellsLabel.Size = UDim2.new(0, 200, 0, 38)
cellsLabel.BackgroundTransparency = 1
cellsLabel.Text = "CELLS: " .. GameConfig.STARTING_CELLS
cellsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
cellsLabel.TextSize = 22
cellsLabel.Font = Enum.Font.GothamBold
cellsLabel.Parent = topBar

-----------------------------------------------------------------------
-- STATUS BAR (Barrera + Boveda + Repair hint)
-----------------------------------------------------------------------
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 38)
statusBar.Position = UDim2.new(0, 0, 0, 50)
statusBar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
statusBar.BackgroundTransparency = 0.25
statusBar.BorderSizePixel = 0
statusBar.Parent = gui

-- Barrier bar
local barrierFrame = Instance.new("Frame")
barrierFrame.Size = UDim2.new(0.42, 0, 0, 26)
barrierFrame.Position = UDim2.new(0.02, 0, 0, 6)
barrierFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
barrierFrame.BorderSizePixel = 0
barrierFrame.Parent = statusBar
Corner(barrierFrame, 6)

local barrierFill = Instance.new("Frame")
barrierFill.Name = "Fill"
barrierFill.Size = UDim2.new(1, 0, 1, 0)
barrierFill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
barrierFill.BorderSizePixel = 0
barrierFill.Parent = barrierFrame
Corner(barrierFill, 6)

local barrierText = Instance.new("TextLabel")
barrierText.Size = UDim2.new(1, 0, 1, 0)
barrierText.BackgroundTransparency = 1
barrierText.Text = "BARRERA: 100%"
barrierText.TextColor3 = Color3.new(1, 1, 1)
barrierText.TextSize = 13
barrierText.Font = Enum.Font.GothamBold
barrierText.ZIndex = 2
barrierText.Parent = barrierFrame

-- Vault
local vaultLabel = Instance.new("TextLabel")
vaultLabel.Size = UDim2.new(0.22, 0, 0, 26)
vaultLabel.Position = UDim2.new(0.46, 0, 0, 6)
vaultLabel.BackgroundColor3 = Color3.fromRGB(0, 60, 50)
vaultLabel.BorderSizePixel = 0
vaultLabel.Text = "BOVEDA: 0/" .. GameConfig.VAULT_MAX_SLOTS
vaultLabel.TextColor3 = Color3.fromRGB(0, 191, 165)
vaultLabel.TextSize = 13
vaultLabel.Font = Enum.Font.GothamBold
vaultLabel.Parent = statusBar
Corner(vaultLabel, 6)

-- Repair hint
local repairHint = Instance.new("TextLabel")
repairHint.Size = UDim2.new(0.28, 0, 0, 26)
repairHint.Position = UDim2.new(0.70, 0, 0, 6)
repairHint.BackgroundTransparency = 1
repairHint.Text = "[R] Reparar barrera | [F] Saltar timer"
repairHint.TextColor3 = Color3.fromRGB(150, 150, 170)
repairHint.TextSize = 11
repairHint.Font = Enum.Font.Gotham
repairHint.Parent = statusBar

-----------------------------------------------------------------------
-- HOTBAR (Bottom)
-----------------------------------------------------------------------
local hotbar = Instance.new("Frame")
hotbar.Size = UDim2.new(0, 380, 0, 75)
hotbar.Position = UDim2.new(0.5, -190, 1, -88)
hotbar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
hotbar.BackgroundTransparency = 0.1
hotbar.BorderSizePixel = 0
hotbar.Parent = gui
Corner(hotbar, 10)

local hbLayout = Instance.new("UIListLayout")
hbLayout.FillDirection = Enum.FillDirection.Horizontal
hbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
hbLayout.Padding = UDim.new(0, 10)
hbLayout.Parent = hotbar
Pad(hotbar, 6, 6, 10, 10)

for i, defType in ipairs(DefenseConfig.HotbarOrder) do
	local def = DefenseConfig.Defenses[defType]
	local stats = DefenseConfig.GetStats(defType, 1)

	local btn = Instance.new("TextButton")
	btn.Name = defType
	btn.Size = UDim2.new(0, 108, 0, 58)
	btn.BackgroundColor3 = def.color
	btn.BackgroundTransparency = 0.35
	btn.BorderSizePixel = 0
	btn.Text = "[" .. i .. "] " .. def.displayName .. "\n$" .. (stats and stats.cost or "?")
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.TextWrapped = true
	btn.Parent = hotbar
	Corner(btn, 8)

	btn.MouseButton1Click:Connect(function()
		local PC = require(player.PlayerScripts:WaitForChild("Controllers"):WaitForChild("PlacementController"))
		if PC.IsPlacing() and PC.GetSelectedType() == defType then
			PC.CancelPlacing()
		else
			PC.StartPlacing(defType)
		end
	end)
end

-- Controls hint
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(0, 350, 0, 16)
hint.Position = UDim2.new(0.5, -175, 1, -14)
hint.BackgroundTransparency = 1
hint.Text = "WASD: Camara | Scroll: Zoom | Click: Colocar | ESC: Cancelar"
hint.TextColor3 = Color3.fromRGB(110, 110, 130)
hint.TextSize = 10
hint.Font = Enum.Font.Gotham
hint.Parent = gui

-----------------------------------------------------------------------
-- CENTER NOTIFICATION
-----------------------------------------------------------------------
local notif = Instance.new("TextLabel")
notif.Name = "CenterNotif"
notif.Size = UDim2.new(0.6, 0, 0, 50)
notif.Position = UDim2.new(0.2, 0, 0.14, 0)
notif.BackgroundTransparency = 1
notif.Text = ""
notif.TextColor3 = Color3.new(1, 1, 1)
notif.TextSize = 28
notif.Font = Enum.Font.GothamBold
notif.TextStrokeTransparency = 0.4
notif.TextTransparency = 1
notif.Parent = gui

local function Notify(text: string, color: Color3?, dur: number?)
	notif.Text = text
	notif.TextColor3 = color or Color3.new(1, 1, 1)
	notif.TextTransparency = 0
	notif.TextStrokeTransparency = 0.2
	task.delay(dur or 2.5, function()
		TweenService:Create(notif, TweenInfo.new(0.6), {
			TextTransparency = 1, TextStrokeTransparency = 1,
		}):Play()
	end)
end

-----------------------------------------------------------------------
-- BREACH OVERLAY
-----------------------------------------------------------------------
local breachOverlay = Instance.new("Frame")
breachOverlay.Name = "BreachOverlay"
breachOverlay.Size = UDim2.new(1, 0, 1, 0)
breachOverlay.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
breachOverlay.BackgroundTransparency = 1
breachOverlay.BorderSizePixel = 0
breachOverlay.ZIndex = 0
breachOverlay.Parent = gui

local breachPulsing = false

-----------------------------------------------------------------------
-- RESULTS SCREEN
-----------------------------------------------------------------------
local resultsFrame = Instance.new("Frame")
resultsFrame.Name = "Results"
resultsFrame.Size = UDim2.new(0.45, 0, 0.48, 0)
resultsFrame.Position = UDim2.new(0.275, 0, 0.26, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
resultsFrame.BackgroundTransparency = 0.05
resultsFrame.BorderSizePixel = 0
resultsFrame.Visible = false
resultsFrame.ZIndex = 10
resultsFrame.Parent = gui
Corner(resultsFrame, 14)

local resultsTitle = Instance.new("TextLabel")
resultsTitle.Size = UDim2.new(1, 0, 0, 55)
resultsTitle.BackgroundTransparency = 1
resultsTitle.Text = ""
resultsTitle.TextColor3 = Color3.new(1, 1, 1)
resultsTitle.TextSize = 34
resultsTitle.Font = Enum.Font.GothamBold
resultsTitle.ZIndex = 11
resultsTitle.Parent = resultsFrame

local resultsBody = Instance.new("TextLabel")
resultsBody.Size = UDim2.new(0.85, 0, 0.65, 0)
resultsBody.Position = UDim2.new(0.075, 0, 0.22, 0)
resultsBody.BackgroundTransparency = 1
resultsBody.Text = ""
resultsBody.TextColor3 = Color3.fromRGB(200, 200, 220)
resultsBody.TextSize = 17
resultsBody.Font = Enum.Font.GothamMedium
resultsBody.TextXAlignment = Enum.TextXAlignment.Left
resultsBody.TextYAlignment = Enum.TextYAlignment.Top
resultsBody.TextWrapped = true
resultsBody.ZIndex = 11
resultsBody.Parent = resultsFrame

-----------------------------------------------------------------------
-- EVENT HANDLERS
-----------------------------------------------------------------------

-- Cells
Events.CellsUpdate.OnClientEvent:Connect(function(data)
	cellsLabel.Text = "CELLS: " .. tostring(data.cells)
end)

-- Wave started
Events.WaveStarted.OnClientEvent:Connect(function(data)
	local txt = "OLEADA " .. data.waveNumber .. "/" .. data.totalWaves
	if data.isBoss then txt = "!! BOSS !!" end
	waveLabel.Text = txt

	if data.phase == "BUILD" then
		Notify(data.waveName or txt, Color3.fromRGB(0, 229, 255), 2)
		timerLabel.Text = "Construye!"
	elseif data.phase == "COMBAT" then
		timerLabel.Text = "COMBATE"
		if data.isBoss then
			Notify("!! BOSS WAVE !!", Color3.fromRGB(255, 60, 60), 3)
		end
	end
end)

-- Wave ended
Events.WaveEnded.OnClientEvent:Connect(function(data)
	if data.wasPerfect then
		Notify("OLEADA PERFECTA!", Color3.fromRGB(255, 215, 0), 2)
	else
		Notify("Oleada completada", Color3.fromRGB(100, 255, 100), 1.5)
	end
end)

-- Barrier update
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
	Notify("!! BRECHA EN LA BASE !!", Color3.fromRGB(255, 0, 0), 4)
	breachPulsing = true
	task.spawn(function()
		while breachPulsing do
			breachOverlay.BackgroundTransparency = 0.85
			task.wait(0.4)
			if not breachPulsing then break end
			breachOverlay.BackgroundTransparency = 0.95
			task.wait(0.4)
		end
		breachOverlay.BackgroundTransparency = 1
	end)
end)

Events.BreachEnded.OnClientEvent:Connect(function()
	breachPulsing = false
	breachOverlay.BackgroundTransparency = 1
	Notify("Barrera reparada", Color3.fromRGB(0, 229, 255), 2)
end)

-- Capture
Events.BrainrotCaptured.OnClientEvent:Connect(function(data)
	local r = BrainrotConfig.Rarities[data.rarity]
	local col = r and r.color or Color3.new(1, 1, 1)
	Notify("CAPTURA: " .. data.className .. " " .. data.rarity .. "!", col, 2.5)
	vaultLabel.Text = "BOVEDA: " .. data.vaultCount .. "/" .. data.vaultMax
end)

-- Stolen
Events.BrainrotStolen.OnClientEvent:Connect(function(data)
	Notify("ROBADO: " .. data.className .. " " .. data.rarity .. "!", Color3.fromRGB(255, 0, 0), 3)
	vaultLabel.Text = "BOVEDA: " .. data.remainingInVault .. "/" .. GameConfig.VAULT_MAX_SLOTS
end)

-- Game Over
Events.GameOver.OnClientEvent:Connect(function(data)
	resultsFrame.Visible = true
	breachPulsing = false
	breachOverlay.BackgroundTransparency = 1

	if data.result == "VICTORY" then
		resultsTitle.Text = "VICTORIA!"
		resultsTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
	else
		resultsTitle.Text = "DERROTA"
		resultsTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
	end

	local s = data.stats
	resultsBody.Text = string.format(
		"Oleadas completadas: %d\n" ..
		"Oleadas perfectas: %d\n" ..
		"Kills totales: %d\n" ..
		"Valor de boveda: %d pts\n\n" ..
		"Razon: %s",
		s.wavesCompleted, s.perfectWaves, s.totalKills,
		s.vaultValue, data.reason or "---"
	)
end)

print("[HUD] UI lista")
