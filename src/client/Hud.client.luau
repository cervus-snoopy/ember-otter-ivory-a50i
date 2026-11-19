-- LIGHTHOUSE BAY
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Characters = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Characters)
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BrainrotBayRemotes")
local serverEvent = remotes:WaitForChild("ServerEvent")
local clientEvent = remotes:WaitForChild("ClientEvent")
local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")
local function makeLabel(parent, name, position, size, text, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 0.35
	label.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.Text = text
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.TextScaled = false
	label.Parent = parent
	return label
end
local function makeButton(parent, name, position, size, text, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color or Color3.fromRGB(40, 120, 60)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Text = text
	button.TextSize = 16
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	return button
end
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.AnchorPoint = Vector2.new(1, 0)
topBar.Position = UDim2.new(1, -10, 0, 10)
topBar.Size = UDim2.new(0, 880, 0, 44)
topBar.BackgroundTransparency = 0.3
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
topBar.Parent = gui
local cashLabel = makeLabel(topBar, "Cash", UDim2.new(0, 8, 0, 6), UDim2.new(0, 170, 0, 32), "Cash: $150", 20, Color3.fromRGB(120, 255, 120))
local incomeLabel = makeLabel(topBar, "Income", UDim2.new(0, 186, 0, 6), UDim2.new(0, 150, 0, 32), "+$0/s", 18, Color3.fromRGB(255, 220, 100))
local rebirthLabel = makeLabel(topBar, "Rebirths", UDim2.new(0, 344, 0, 6), UDim2.new(0, 90, 0, 32), "Rebirth x0", 16)
local waveLabel = makeLabel(topBar, "Wave", UDim2.new(0, 442, 0, 6), UDim2.new(0, 110, 0, 32), "Surge: 180s", 16, Color3.fromRGB(120, 200, 255))
local beamLabel = makeLabel(topBar, "Beam", UDim2.new(0, 560, 0, 6), UDim2.new(0, 150, 0, 32), "Beam: ▲ NORTH", 16, Color3.fromRGB(255, 240, 150))
local lockLabel = makeLabel(topBar, "Lock", UDim2.new(0, 718, 0, 6), UDim2.new(0, 150, 0, 32), "UNLOCKED", 16, Color3.fromRGB(200, 200, 200))
local title = makeLabel(gui, "Title", UDim2.new(0.5, -140, 0, 10), UDim2.new(0, 280, 0, 36), "LIGHTHOUSE BAY", 26, Color3.fromRGB(255, 220, 100))
title.BackgroundTransparency = 0.5
makeLabel(gui, "Subtitle", UDim2.new(0.5, -220, 0, 52), UDim2.new(0, 440, 0, 20), "36 BRAINROTS · 7 RARITIES · 6 MUTATIONS · 10 REBIRTHS", 13, Color3.fromRGB(200, 220, 255))
makeLabel(gui, "DashHint", UDim2.new(0.5, -140, 0, 76), UDim2.new(0, 280, 0, 24), "Q / SHIFT - DASH home (5s cooldown)", 14, Color3.fromRGB(200, 220, 255))
local notice = makeLabel(gui, "Notice", UDim2.new(0.5, -300, 1, -64), UDim2.new(0, 600, 0, 44), "Welcome to LIGHTHOUSE BAY!", 18)
notice.BackgroundTransparency = 0.4
notice.TextWrapped = true
local warning = makeLabel(gui, "StealWarning", UDim2.new(0.5, -220, 0, 120), UDim2.new(0, 440, 0, 52), "", 20, Color3.fromRGB(255, 90, 90))
warning.Visible = false
local stealBar = Instance.new("Frame")
stealBar.Name = "StealBar"
stealBar.Position = UDim2.new(0.5, -220, 0, 176)
stealBar.Size = UDim2.new(0, 440, 0, 10)
stealBar.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
stealBar.Visible = false
stealBar.Parent = gui
local stealFill = Instance.new("Frame")
stealFill.Name = "StealFill"
stealFill.Size = UDim2.new(1, 0, 1, 0)
stealFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
stealFill.BorderSizePixel = 0
stealFill.Parent = stealBar
local stealGen = 0
local surgeBanner = makeLabel(gui, "SurgeBanner", UDim2.new(0.5, -320, 0, 250), UDim2.new(0, 640, 0, 56), "THE LIGHTHOUSE SURGE IS COMING", 30, Color3.fromRGB(255, 90, 90))
surgeBanner.Visible = false
surgeBanner.TextTransparency = 1
surgeBanner.BackgroundTransparency = 1
local bannerGen = 0
local function fadeBanner(show)
	bannerGen += 1
	local gen = bannerGen
	surgeBanner.Visible = true
	task.spawn(function()
		for i = 1, 10 do
			if gen ~= bannerGen then
				return
			end
			local a = show and (1 - i / 10) or (i / 10)
			surgeBanner.TextTransparency = a
			surgeBanner.BackgroundTransparency = 0.35 + a * 0.65
			task.wait(0.05)
		end
		if not show then
			surgeBanner.Visible = false
		end
	end)
end
local whackBtn = makeButton(gui, "Whack", UDim2.new(0.5, -220, 0, 196), UDim2.new(0, 440, 0, 40), "WHACK!", Color3.fromRGB(200, 60, 40))
whackBtn.TextSize = 20
whackBtn.Visible = false
whackBtn.MouseButton1Click:Connect(function()
	serverEvent:FireServer("Whack")
end)
ContextActionService:BindAction("WhackBot", function(_, inputState: EnumItem)
	if inputState == Enum.UserInputState.Begin then
		serverEvent:FireServer("Whack")
	end
end, false, Enum.KeyCode.F)
local shopFrame = Instance.new("Frame")
shopFrame.Name = "Shop"
shopFrame.Position = UDim2.new(0, 10, 0, 64)
shopFrame.Size = UDim2.new(0, 300, 0, 320)
shopFrame.BackgroundTransparency = 0.3
shopFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
shopFrame.Parent = gui
makeLabel(shopFrame, "ShopTitle", UDim2.new(0, 8, 0, 6), UDim2.new(0, 284, 0, 28), "CONVEYOR SHOP - click to buy", 16, Color3.fromRGB(255, 220, 100))
local shopList = Instance.new("Frame")
shopList.Name = "ShopList"
shopList.Position = UDim2.new(0, 8, 0, 40)
shopList.Size = UDim2.new(0, 284, 0, 272)
shopList.BackgroundTransparency = 1
shopList.Parent = shopFrame
local function rarityColor(rarity: string): Color3
	local c = Characters.RARITY_COLORS[rarity] or { 200, 200, 200 }
	return Color3.fromRGB(c[1], c[2], c[3])
end
local function renderShop(entries)
	for _, child in ipairs(shopList:GetChildren()) do
		child:Destroy()
	end
	for i, entry in ipairs(entries) do
		local row = Instance.new("TextButton")
		row.Name = "ShopRow" .. tostring(i)
		row.Position = UDim2.new(0, 0, 0, (i - 1) * 44)
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
		row.TextColor3 = Color3.fromRGB(255, 255, 255)
		row.TextSize = 14
		row.Font = Enum.Font.Gotham
		row.TextXAlignment = Enum.TextXAlignment.Left
		local mut = entry.mutation ~= "None" and (" [" .. entry.mutation .. "]") or ""
		row.Text = string.format(
			"  %s%s\n  %s  $%d/s  -  $%d",
			entry.name,
			mut,
			entry.rarity,
			entry.income,
			entry.price
		)
		row.Parent = shopList
		local stripe = Instance.new("Frame")
		stripe.Size = UDim2.new(0, 6, 1, 0)
		stripe.BackgroundColor3 = rarityColor(entry.rarity)
		stripe.BorderSizePixel = 0
		stripe.Parent = row
		row.MouseButton1Click:Connect(function()
			serverEvent:FireServer("Buy", entry.id)
		end)
	end
	if #entries == 0 then
		makeLabel(shopList, "Empty", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 40), "Conveyor empty - more coming!", 14)
	end
end
local invFrame = Instance.new("Frame")
invFrame.Name = "Inventory"
invFrame.AnchorPoint = Vector2.new(1, 0)
invFrame.Position = UDim2.new(1, -10, 0, 64)
invFrame.Size = UDim2.new(0, 300, 0, 320)
invFrame.BackgroundTransparency = 0.3
invFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
invFrame.Parent = gui
makeLabel(invFrame, "InvTitle", UDim2.new(0, 8, 0, 6), UDim2.new(0, 284, 0, 28), "MY PLOT - click SELL to sell", 16, Color3.fromRGB(120, 255, 120))
local invList = Instance.new("Frame")
invList.Name = "InvList"
invList.Position = UDim2.new(0, 8, 0, 40)
invList.Size = UDim2.new(0, 284, 0, 272)
invList.BackgroundTransparency = 1
invList.Parent = invFrame
local function renderInventory(owned)
	for _, child in ipairs(invList:GetChildren()) do
		child:Destroy()
	end
	for i, b in ipairs(owned) do
		local row = Instance.new("Frame")
		row.Name = "InvRow" .. tostring(i)
		row.Position = UDim2.new(0, 0, 0, (i - 1) * 44)
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
		row.BorderSizePixel = 0
		row.Parent = invList
		local label = makeLabel(row, "Label", UDim2.new(0, 10, 0, 0), UDim2.new(0, 200, 1, 0), "", 14)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		local mut = b.mutation ~= "None" and (" [" .. b.mutation .. "]") or ""
		label.Text = string.format("%s%s\n%s  $%d/s", b.name, mut, b.rarity, b.income)
		label.TextColor3 = rarityColor(b.rarity)
		local sell = makeButton(row, "Sell", UDim2.new(1, -64, 0, 6), UDim2.new(0, 56, 0, 28), "SELL", Color3.fromRGB(150, 50, 50))
		sell.MouseButton1Click:Connect(function()
			serverEvent:FireServer("Sell", b.slot)
		end)
	end
	if #owned == 0 then
		makeLabel(invList, "Empty", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 40), "No brainrots yet - buy one!", 14)
	end
end
local actions = Instance.new("Frame")
actions.Name = "Actions"
actions.Position = UDim2.new(0, 10, 1, -188)
actions.Size = UDim2.new(0, 340, 0, 122)
actions.BackgroundTransparency = 0.3
actions.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
actions.Parent = gui
local eggBasic = makeButton(actions, "EggBasic", UDim2.new(0, 8, 0, 8), UDim2.new(0, 88, 0, 32), "Egg $100", Color3.fromRGB(120, 80, 30))
local eggFancy = makeButton(actions, "EggFancy", UDim2.new(0, 104, 0, 8), UDim2.new(0, 88, 0, 32), "Egg $500", Color3.fromRGB(90, 60, 140))
local eggGolden = makeButton(actions, "EggGolden", UDim2.new(0, 200, 0, 8), UDim2.new(0, 88, 0, 32), "Egg $2500", Color3.fromRGB(180, 140, 20))
local lockBtn = makeButton(actions, "Lock", UDim2.new(0, 8, 0, 46), UDim2.new(0, 160, 0, 30), "LOCK PLOT $" .. tostring(Config.LOCK_COST) .. " · " .. tostring(Config.LOCK_DURATION) .. "s", Color3.fromRGB(60, 90, 160))
lockBtn.TextSize = 13
local rebirthBtn = makeButton(actions, "Rebirth", UDim2.new(0, 176, 0, 46), UDim2.new(0, 156, 0, 30), "REBIRTH", Color3.fromRGB(160, 40, 120))
rebirthBtn.TextSize = 11
rebirthBtn.TextWrapped = true
local indexBtn = makeButton(actions, "Index", UDim2.new(0, 8, 0, 84), UDim2.new(0, 324, 0, 30), "INDEX 0/36", Color3.fromRGB(40, 90, 140))
eggBasic.MouseButton1Click:Connect(function() serverEvent:FireServer("BuyEgg", "Basic") end)
eggFancy.MouseButton1Click:Connect(function() serverEvent:FireServer("BuyEgg", "Fancy") end)
eggGolden.MouseButton1Click:Connect(function() serverEvent:FireServer("BuyEgg", "Golden") end)
lockBtn.MouseButton1Click:Connect(function() serverEvent:FireServer("Lock") end)
rebirthBtn.MouseButton1Click:Connect(function() serverEvent:FireServer("Rebirth") end)
local collectedNames = {}
local indexOpen = false
local indexPanel = Instance.new("Frame")
indexPanel.Name = "BrainrotIndex"
indexPanel.AnchorPoint = Vector2.new(0.5, 0.5)
indexPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
indexPanel.Size = UDim2.new(0, 360, 0, 440)
indexPanel.BackgroundTransparency = 0.15
indexPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
indexPanel.Visible = false
indexPanel.Parent = gui
local indexTitle = makeLabel(indexPanel, "IndexTitle", UDim2.new(0, 8, 0, 6), UDim2.new(0, 344, 0, 28), "BRAINROT INDEX  0/36", 16, Color3.fromRGB(255, 220, 100))
makeLabel(indexPanel, "IndexSub", UDim2.new(0, 8, 0, 34), UDim2.new(0, 344, 0, 20), "Old Bram keeps the lamp. Mind the beam.", 12, Color3.fromRGB(200, 220, 255))
local indexScroll = Instance.new("ScrollingFrame")
indexScroll.Name = "IndexList"
indexScroll.Position = UDim2.new(0, 8, 0, 58)
indexScroll.Size = UDim2.new(0, 344, 0, 374)
indexScroll.BackgroundTransparency = 1
indexScroll.ScrollBarThickness = 6
indexScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
indexScroll.Parent = indexPanel
local indexLayout = Instance.new("UIListLayout")
indexLayout.Padding = UDim.new(0, 2)
indexLayout.Parent = indexScroll
local function renderIndexGrid()
	for _, child in ipairs(indexScroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	local count = 0
	for _, entry in ipairs(Characters.CAST) do
		local label = Instance.new("TextLabel")
		label.Name = "IndexRow"
		label.Size = UDim2.new(1, 0, 0, 22)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		if collectedNames[entry.name] then
			count += 1
			label.Text = string.format("  %s  -  %s  $%d/s", entry.name, entry.rarity, entry.income)
			label.TextColor3 = rarityColor(entry.rarity)
		else
			label.Text = string.format("  ???  -  %s  $--/s", entry.rarity)
			label.TextColor3 = Color3.fromRGB(120, 120, 120)
		end
		label.Parent = indexScroll
	end
	indexTitle.Text = "BRAINROT INDEX  " .. tostring(count) .. "/" .. tostring(#Characters.CAST)
	return count
end
local function updateIndexButton()
	local count = 0
	for _ in pairs(collectedNames) do
		count += 1
	end
	indexBtn.Text = "INDEX " .. tostring(count) .. "/" .. tostring(#Characters.CAST)
end
local function toggleIndexPanel()
	indexOpen = not indexOpen
	if indexOpen then
		renderIndexGrid()
	end
	indexPanel.Visible = indexOpen
end
indexBtn.MouseButton1Click:Connect(toggleIndexPanel)
local boardFrame = Instance.new("Frame")
boardFrame.Name = "Leaderboard"
boardFrame.AnchorPoint = Vector2.new(1, 0)
boardFrame.Position = UDim2.new(1, -10, 1, -220)
boardFrame.Size = UDim2.new(0, 260, 0, 150)
boardFrame.BackgroundTransparency = 0.3
boardFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
boardFrame.Parent = gui
makeLabel(boardFrame, "BoardTitle", UDim2.new(0, 8, 0, 6), UDim2.new(0, 244, 0, 26), "RICHEST IN THE BAY", 16, Color3.fromRGB(255, 220, 100))
local boardList = Instance.new("Frame")
boardList.Name = "BoardList"
boardList.Position = UDim2.new(0, 8, 0, 36)
boardList.Size = UDim2.new(0, 244, 0, 106)
boardList.BackgroundTransparency = 1
boardList.Parent = boardFrame
local function renderLeaderboard(rows)
	for _, child in ipairs(boardList:GetChildren()) do
		child:Destroy()
	end
	for i, row in ipairs(rows) do
		if i > 5 then
			break
		end
		local label = makeLabel(boardList, "Row" .. tostring(i), UDim2.new(0, 0, 0, (i - 1) * 20), UDim2.new(1, 0, 0, 18), "", 14)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = string.format("%d. %s  $%d  (+$%d/s)", i, row.name, row.cash, row.income)
		if row.name == player.Name then
			label.TextColor3 = Color3.fromRGB(120, 255, 120)
		end
	end
end
local indexFrame = Instance.new("Frame")
indexFrame.Name = "RarityIndex"
indexFrame.Position = UDim2.new(0, 10, 0, 394)
indexFrame.Size = UDim2.new(0, 300, 0, 164)
indexFrame.BackgroundTransparency = 0.3
indexFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
indexFrame.Parent = gui
makeLabel(indexFrame, "IndexTitle", UDim2.new(0, 8, 0, 6), UDim2.new(0, 284, 0, 26), "RARITY LADDER", 16, Color3.fromRGB(255, 220, 100))
local indexText = "Common $2-7/s  >  Uncommon $8-16/s\nRare $25-44/s  >  Epic $70-120/s\nLegendary $180-300/s  >  Mythic $450-650/s\nBeacon $850-1000/s\nMutations: Golden x2 - Diamond x4 - Rainbow x8\nStorm x12 - Aurora x16 - Solar x25\nRebirth: +50% income each, up to 10x"
makeLabel(indexFrame, "IndexBody", UDim2.new(0, 8, 0, 36), UDim2.new(0, 284, 0, 120), indexText, 13)
clientEvent.OnClientEvent:Connect(function(action: string, payload)
	if action == "State" then
		cashLabel.Text = "Cash: $" .. tostring(payload.cash)
		incomeLabel.Text = "+$" .. tostring(payload.incomePerSecond) .. "/s"
		rebirthLabel.Text = "Rebirth x" .. tostring(payload.rebirths)
		if payload.rebirths >= Config.REBIRTH_MAX then
			rebirthBtn.Text = "REBIRTH MAX 10/10"
		else
			local need = Config.REBIRTH_MIN_CASH_EARNED * (payload.rebirths + 1)
			rebirthBtn.Text = "REBIRTH " .. tostring(payload.rebirths) .. "/10 — $" .. tostring(payload.totalEarned) .. "/$" .. tostring(need)
		end
		renderInventory(payload.owned)
		local lockLeft = payload.lockSecondsLeft or 0
		if lockLeft > 0 then
			lockBtn.Text = "LOCKED " .. tostring(lockLeft) .. "s"
			lockBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
			lockLabel.Text = "LOCKED " .. tostring(lockLeft) .. "s"
			lockLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
		else
			lockBtn.Text = "LOCK PLOT $" .. tostring(Config.LOCK_COST) .. " · " .. tostring(Config.LOCK_DURATION) .. "s"
			lockBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 160)
			lockLabel.Text = "UNLOCKED"
			lockLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		collectedNames = {}
		for _, name in ipairs(payload.collected or {}) do
			collectedNames[name] = true
		end
		updateIndexButton()
		if indexOpen then
			renderIndexGrid()
		end
	elseif action == "Shop" then
		renderShop(payload)
	elseif action == "Notice" then
		notice.Text = payload
	elseif action == "StealWarning" then
		warning.Text = "WARNING! " .. payload.bot .. " is stealing from your plot! Chase them off!"
		warning.Visible = true
		stealBar.Visible = true
		stealFill.Size = UDim2.new(1, 0, 1, 0)
		stealGen += 1
		local gen = stealGen
		local secs = payload.seconds or 4
		task.spawn(function()
			for i = 1, 20 do
				task.wait(secs / 20)
				if gen ~= stealGen then
					return
				end
				stealFill.Size = UDim2.new(1 - i / 20, 0, 1, 0)
			end
			stealBar.Visible = false
		end)
		whackBtn.Text = "WHACK! " .. payload.bot .. " is stealing! [F]"
		whackBtn.Visible = true
		task.delay(6, function()
			warning.Visible = false
			stealBar.Visible = false
			whackBtn.Visible = false
		end)
	elseif action == "StealEnd" then
		warning.Visible = false
		stealBar.Visible = false
		whackBtn.Visible = false
	elseif action == "WaveWarning" then
		if payload.phase == "start" then
			notice.Text = "THE LIGHTHOUSE SURGE IS COMING — the same storm that wrecked the circus barge. Dash home!"
			fadeBanner(true)
		elseif payload.phase == "end" then
			notice.Text = "The Surge passed. The bay is calm... for now. Old Bram turns the lamp back."
			fadeBanner(false)
		end
	elseif action == "WaveCountdown" then
		waveLabel.Text = "Surge: " .. tostring(payload.seconds) .. "s"
		if payload.warning then
			waveLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		else
			waveLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
		end
		local headings = { [0] = "▲ NORTH", [90] = "► EAST", [180] = "▼ SOUTH", [270] = "◄ WEST" }
		beamLabel.Text = "Beam: " .. (headings[payload.beamAngle or 0] or "▲ NORTH")
	elseif action == "Leaderboard" then
		renderLeaderboard(payload)
	end
end)
serverEvent:FireServer("RequestState")
print("LIGHTHOUSE BAY HUD ready.")
