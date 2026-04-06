-- HUDController.client.lua
-- Crea y gestiona toda la UI del juego
-- Ubicación: StarterGui > HUDController (LocalScript)
--
-- Crea un ScreenGui con:
--   TopBar:     oleada, timer, cells, defensas
--   StatusBar:  barra HP barrera, bóveda, hints
--   Hotbar:     3 botones de defensas con highlight de selección
--   Notifs:     notificaciones centrales con fade
--   Breach:     overlay rojo pulsante durante brecha
--   Results:    pantalla de victoria/derrota

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events  = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DefenseConfig  = require(Modules:WaitForChild("DefenseConfig"))
local GameConfig     = require(Modules:WaitForChild("GameConfig"))
local BrainrotConfig = require(Modules:WaitForChild("BrainrotConfig"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-----------------------------------------------------------------------
-- SCREEN GUI
-----------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "GameHUD"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-----------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------
local function Corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
end

local function MakeLabel(props)
	local lbl = Instance.new("TextLabel")
	lbl.Size = props.Size or UDim2.new(0, 100, 0, 30)
	lbl.Position = props.Position or UDim2.new(0, 0, 0, 0)
	lbl.BackgroundTransparency = props.BgTransparency or 1
	lbl.BackgroundColor3 = props.BgColor or Color3.new(0, 0, 0)
	lbl.BorderSizePixel = 0
	lbl.Text = props.Text or ""
	lbl.TextColor3 = props.TextColor or Color3.new(1, 1, 1)
	lbl.TextSize = props.TextSize or 14
	lbl.Font = props.Font or Enum.Font.GothamBold
	lbl.TextXAlignment = props.XAlign or Enum.TextXAlignment.Center
	lbl.TextWrapped = true
	lbl.Parent = props.Parent
	if props.Corner then Corner(lbl, props.Corner) end
	if props.ZIndex then lbl.ZIndex = props.ZIndex end
	return lbl
end

-----------------------------------------------------------------------
-- TOP BAR (oleada, timer, cells, defensas)
-----------------------------------------------------------------------
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
topBar.BackgroundTransparency = 0.15
topBar.BorderSizePixel = 0
topBar.Parent = gui

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Padding = UDim.new(0, 24)
topLayout.Parent = topBar

local waveLabel = MakeLabel({
	Size = UDim2.new(0, 260, 0, 38), Text = "ESPERANDO...",
	TextColor = Color3.fromRGB(0, 229, 255), TextSize = 20, Parent = topBar,
})

local timerLabel = MakeLabel({
	Size = UDim2.new(0, 120, 0, 38), Text = "",
	TextColor = Color3.new(1, 1, 1), TextSize = 17,
	Font = Enum.Font.GothamMedium, Parent = topBar,
})

local cellsLabel = MakeLabel({
	Size = UDim2.new(0, 180, 0, 38),
	Text = "CELLS: " .. GameConfig.STARTING_CELLS,
	TextColor = Color3.fromRGB(255, 215, 0), TextSize = 22, Parent = topBar,
})

local defCountLabel = MakeLabel({
	Size = UDim2.new(0, 130, 0, 38),
	Text = "DEF: 0/" .. GameConfig.MAX_DEFENSES,
	TextColor = Color3.fromRGB(180, 180, 200), TextSize = 15, Parent = topBar,
})

-----------------------------------------------------------------------
-- STATUS BAR (barrera HP + bóveda + hints)
-----------------------------------------------------------------------
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 38)
statusBar.Position = UDim2.new(0, 0, 0, 50)
statusBar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
statusBar.BackgroundTransparency = 0.25
statusBar.BorderSizePixel = 0
statusBar.Parent = gui

-- Barrier HP bar
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

local barrierText = MakeLabel({
	Size = UDim2.new(1, 0, 1, 0), Text = "BARRERA: 100%",
	TextSize = 13, ZIndex = 2, Parent = barrierFrame,
})

-- Vault
local vaultLabel = MakeLabel({
	Size = UDim2.new(0.22, 0, 0, 26),
	Position = UDim2.new(0.46, 0, 0, 6),
	Text = "BOVEDA: 0/" .. GameConfig.VAULT_MAX_SLOTS,
	TextColor = Color3.fromRGB(0, 191, 165), TextSize = 13,
	BgTransparency = 0, BgColor = Color3.fromRGB(0, 60, 50),
	Corner = 6, Parent = statusBar,
})

-- Hints
MakeLabel({
	Size = UDim2.new(0.28, 0, 0, 26),
	Position = UDim2.new(0.70, 0, 0, 6),
	Text = "[R] Reparar  |  [F] Saltar timer",
	TextColor = Color3.fromRGB(150, 150, 170), TextSize = 11,
	Font = Enum.Font.Gotham, Parent = statusBar,
})

-----------------------------------------------------------------------
-- HOTBAR (3 defensas, bottom center)
-----------------------------------------------------------------------
local hotbar = Instance.new("Frame")
hotbar.Name = "Hotbar"
hotbar.Size = UDim2.new(0, 400, 0, 80)
hotbar.Position = UDim2.new(0.5, -200, 1, -94)
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

local hbPad = Instance.new("UIPadding")
hbPad.PaddingTop = UDim.new(0, 6)
hbPad.PaddingBottom = UDim.new(0, 6)
hbPad.PaddingLeft = UDim.new(0, 10)
hbPad.PaddingRight = UDim.new(0, 10)
hbPad.Parent = hotbar

-- Track hotbar buttons for selection highlight
local hotbarButtons: {[string]: TextButton} = {}

for i, defType in ipairs(DefenseConfig.HotbarOrder) do
	local def = DefenseConfig.Defenses[defType]
	local stats = DefenseConfig.GetStats(defType, 1)

	local btn = Instance.new("TextButton")
	btn.Name = defType
	btn.Size = UDim2.new(0, 115, 0, 62)
	btn.BackgroundColor3 = def.color
	btn.BackgroundTransparency = 0.4
	btn.BorderSizePixel = 0
	btn.Text = "[" .. i .. "] " .. def.displayName .. "\n$" .. (stats and stats.cost or "?")
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.TextWrapped = true
	btn.Parent = hotbar
	Corner(btn, 8)

	hotbarButtons[defType] = btn

	-- Click handler (usa el PlacementController del jugador)
	btn.MouseButton1Click:Connect(function()
		local PC = require(
			player.PlayerScripts:WaitForChild("Controllers"):WaitForChild("PlacementController")
		)
		if PC.IsPlacing() and PC.GetSelectedType() == defType then
			PC.CancelPlacing()
		else
			PC.StartPlacing(defType)
		end
	end)
end

-- Selection highlight: listen to PlacementController
task.spawn(function()
	local PC = require(
		player.PlayerScripts:WaitForChild("Controllers"):WaitForChild("PlacementController")
	)
	PC.OnSelectionChanged(function(selectedType)
		for defType, btn in pairs(hotbarButtons) do
			if defType == selectedType then
				btn.BackgroundTransparency = 0.05
				btn.BorderSizePixel = 3
				btn.BorderColor3 = Color3.new(1, 1, 1)
			else
				btn.BackgroundTransparency = 0.4
				btn.BorderSizePixel = 0
			end
		end
	end)
end)

-- Selected defense label
local selectedLabel = MakeLabel({
	Size = UDim2.new(0, 300, 0, 18),
	Position = UDim2.new(0.5, -150, 1, -100),
	Text = "", TextColor = Color3.fromRGB(200, 200, 220),
	TextSize = 12, Font = Enum.Font.GothamMedium, Parent = gui,
})

-- Controls hint
MakeLabel({
	Size = UDim2.new(0, 380, 0, 16),
	Position = UDim2.new(0.5, -190, 1, -14),
	Text = "WASD: Camara | Scroll: Zoom | Click: Colocar | ESC: Cancelar",
	TextColor = Color3.fromRGB(110, 110, 130), TextSize = 10,
	Font = Enum.Font.Gotham, Parent = gui,
})

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
-- BREACH OVERLAY (pantalla roja pulsante)
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
resultsFrame.Size = UDim2.new(0.45, 0, 0.5, 0)
resultsFrame.Position = UDim2.new(0.275, 0, 0.25, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
resultsFrame.BackgroundTransparency = 0.05
resultsFrame.BorderSizePixel = 0
resultsFrame.Visible = false
resultsFrame.ZIndex = 10
resultsFrame.Parent = gui
Corner(resultsFrame, 14)

local resultsTitle = MakeLabel({
	Size = UDim2.new(1, 0, 0, 55), Text = "",
	TextSize = 34, ZIndex = 11, Parent = resultsFrame,
})

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

-- Cells update
Events.CellsUpdate.OnClientEvent:Connect(function(data)
	cellsLabel.Text = "CELLS: " .. tostring(data.cells)
end)

-- Wave started
Events.WaveStarted.OnClientEvent:Connect(function(data)
	local txt = "OLEADA " .. data.waveNumber .. "/" .. data.totalWaves
	if data.isBoss then txt = "!! BOSS !! " .. (data.waveName or "") end
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
	barrierText.Text = "BARRERA: " .. data.currentHP .. "/" .. data.maxHP .. " (" .. pct .. "%)"
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

-- Defense placed (update counter)
Events.DefensePlaced.OnClientEvent:Connect(function(data)
	-- Pedir estado actualizado para tener count correcto
	task.spawn(function()
		local state = Events.GetGameState:InvokeServer()
		if state then
			defCountLabel.Text = "DEF: " .. (state.defenseCount or 0) .. "/" .. GameConfig.MAX_DEFENSES
		end
	end)
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

	local s = data.stats or {}
	resultsBody.Text = string.format(
		"Oleadas: %d/%d\n" ..
		"Perfectas: %d\n" ..
		"Kills: %d\n" ..
		"Capturas: %d\n" ..
		"Escaparon: %d\n" ..
		"Valor boveda: %d pts\n\n" ..
		"Razon: %s",
		s.wavesCompleted or 0, GameConfig.TOTAL_WAVES,
		s.perfectWaves or 0,
		s.totalKills or 0,
		s.totalCaptures or 0,
		s.totalEscaped or 0,
		s.vaultValue or 0,
		data.reason or "---"
	)
end)

-----------------------------------------------------------------------
-- SELECTION LABEL UPDATE
-----------------------------------------------------------------------
task.spawn(function()
	local PC = require(
		player.PlayerScripts:WaitForChild("Controllers"):WaitForChild("PlacementController")
	)
	PC.OnSelectionChanged(function(selectedType)
		if selectedType then
			local def = DefenseConfig.Defenses[selectedType]
			local stats = DefenseConfig.GetStats(selectedType, 1)
			selectedLabel.Text = "Colocando: " .. (def and def.displayName or selectedType)
				.. "  |  Rango: " .. (stats and stats.range or "?")
				.. "  |  Costo: $" .. (stats and stats.cost or "?")
		else
			selectedLabel.Text = ""
		end
	end)
end)

-----------------------------------------------------------------------
-- INITIAL SYNC (pedir estado al conectar)
-----------------------------------------------------------------------
task.spawn(function()
	task.wait(1)
	local ok, state = pcall(function()
		return Events.GetGameState:InvokeServer()
	end)
	if ok and state then
		cellsLabel.Text = "CELLS: " .. (state.cells or 0)
		defCountLabel.Text = "DEF: " .. (state.defenseCount or 0) .. "/" .. GameConfig.MAX_DEFENSES
		vaultLabel.Text = "BOVEDA: " .. (state.vaultCount or 0) .. "/" .. GameConfig.VAULT_MAX_SLOTS
		if state.barrierHP and state.barrierMax and state.barrierMax > 0 then
			local pct = state.barrierHP / state.barrierMax
			barrierFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
			barrierText.Text = "BARRERA: " .. state.barrierHP .. "/" .. state.barrierMax
		end
	end
end)

print("[HUD] UI lista")
