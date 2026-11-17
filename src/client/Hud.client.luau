-- BRAINROT BAY -- HUD (client LocalScript): the whole ScreenGui, built in code.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Characters = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Characters)
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BrainrotBayRemotes")
local serverEvent = remotes:WaitForChild("ServerEvent")
local clientEvent = remotes:WaitForChild("ClientEvent")

-- Gui skeleton
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

-- Top bar, pushed right of Roblox's menu buttons.
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.AnchorPoint = Vector2.new(1, 0)
topBar.Position = UDim2.new(1, -10, 0, 10)
topBar.Size = UDim2.new(0, 720, 0, 44)
topBar.BackgroundTransparency = 0.3
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
topBar.Parent = gui

local cashLabel = makeLabel(topBar, "Cash", UDim2.new(0, 8, 0, 6), UDim2.new(0, 170, 0, 32), "Cash: $150", 20, Color3.fromRGB(120, 255, 120))
local incomeLabel = makeLabel(topBar, "Income", UDim2.new(0, 186, 0, 6), UDim2.new(0, 150, 0, 32), "+$0/s", 18, Color3.fromRGB(255, 220, 100))
local rebirthLabel = makeLabel(topBar, "Rebirths", UDim2.new(0, 344, 0, 6), UDim2.new(0, 90, 0, 32), "Rebirth x0", 16)
local waveLabel = makeLabel(topBar, "Wave", UDim2.new(0, 442, 0, 6), UDim2.new(0, 110, 0, 32), "Wave: 180s", 16, Color3.fromRGB(120, 200, 255))
-- Beam heading: 0 north, 270 west (sent with WaveCountdown).
local beamLabel = makeLabel(topBar, "Beam", UDim2.new(0, 560, 0, 6), UDim2.new(0, 150, 0, 32), "Beam: ▲ NORTH", 16, Color3.fromRGB(255, 240, 150))

local title = makeLabel(gui, "Title", UDim2.new(0.5, -140, 0, 10), UDim2.new(0, 280, 0, 36), "BRAINROT BAY", 26, Color3.fromRGB(255, 220, 100))
title.BackgroundTransparency = 0.5
makeLabel(gui, "DashHint", UDim2.new(0.5, -140, 0, 52), UDim2.new(0, 280, 0, 24), "Q / SHIFT - DASH home (5s cooldown)", 14, Color3.fromRGB(200, 220, 255))

local notice = makeLabel(gui, "Notice", UDim2.new(0.5, -300, 1, -56), UDim2.new(0, 600, 0, 36), "Welcome to BRAINROT BAY!", 18)
notice.BackgroundTransparency = 0.4

local warning = makeLabel(gui, "StealWarning", UDim2.new(0.5, -220, 0, 120), UDim2.new(0, 440, 0, 52), "", 20, Color3.fromRGB(255, 90, 90))
warning.Visible = false

-- Shop panel (left): one row per brainrot, click to buy.
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

-- Inventory panel (right): your brainrots, each with SELL.
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

-- Action buttons (bottom left): eggs, lock, rebirth.
local actions = Instance.new("Frame")
actions.Name = "Actions"
actions.Position = UDim2.new(0, 10, 1, -150)
actions.Size = UDim2.new(0, 300, 0, 84)
actions.BackgroundTransparency = 0.3
actions.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
actions.Parent = gui

local eggBasic = makeButton(actions, "EggBasic", UDim2.new(0, 8, 0, 8), UDim2.new(0, 88, 0, 32), "Egg $100", Color3.fromRGB(120, 80, 30))
local eggFancy = makeButton(actions, "EggFancy", UDim2.new(0, 104, 0, 8), UDim2.new(0, 88, 0, 32), "Egg $500", Color3.fromRGB(90, 60, 140))
local eggGolden = makeButton(actions, "EggGolden", UDim2.new(0, 200, 0, 8), UDim2.new(0, 88, 0, 32), "Egg $2500", Color3.fromRGB(180, 140, 20))
local lockBtn = makeButton(actions, "Lock", UDim2.new(0, 8, 0, 46), UDim2.new(0, 136, 0, 30), "LOCK PLOT $250", Color3.fromRGB(60, 90, 160))
local rebirthBtn = makeButton(actions, "Rebirth", UDim2.new(0, 152, 0, 46), UDim2.new(0, 136, 0, 30), "REBIRTH", Color3.fromRGB(160, 40, 120))

eggBasic.MouseButton1Click:Connect(function() serverEvent:FireServer("BuyEgg", "Basic") end)
eggFancy.MouseButton1Click:Connect(function() serverEvent:FireServer("BuyEgg", "Fancy") end)
eggGolden.MouseButton1Click:Connect(function() serverEvent:FireServer("BuyEgg", "Golden") end)
lockBtn.MouseButton1Click:Connect(function() serverEvent:FireServer("Lock") end)
rebirthBtn.MouseButton1Click:Connect(function() serverEvent:FireServer("Rebirth") end)

-- Leaderboard (bottom right) + rarity index.
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
indexFrame.Size = UDim2.new(0, 300, 0, 132)
indexFrame.BackgroundTransparency = 0.3
indexFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
indexFrame.Parent = gui
makeLabel(indexFrame, "IndexTitle", UDim2.new(0, 8, 0, 6), UDim2.new(0, 284, 0, 26), "RARITY LADDER", 16, Color3.fromRGB(255, 220, 100))
local indexText = "Common $2-4/s  >  Uncommon $8-14/s\nRare $25-40/s  >  Epic $70-110/s\nLegendary $180-260/s  >  Mythic $450-700/s\nMutations: Golden x2 - Diamond x4 - Rainbow x8\nRebirth: +50% income each, up to 10x"
makeLabel(indexFrame, "IndexBody", UDim2.new(0, 8, 0, 36), UDim2.new(0, 284, 0, 88), indexText, 13)

-- Server messages
clientEvent.OnClientEvent:Connect(function(action: string, payload)
	if action == "State" then
		cashLabel.Text = "Cash: $" .. tostring(payload.cash)
		incomeLabel.Text = "+$" .. tostring(payload.incomePerSecond) .. "/s"
		rebirthLabel.Text = "Rebirth x" .. tostring(payload.rebirths)
		renderInventory(payload.owned)
	elseif action == "Shop" then
		renderShop(payload)
	elseif action == "Notice" then
		notice.Text = payload
	elseif action == "StealWarning" then
		warning.Text = "WARNING! " .. payload.bot .. " is stealing from your plot! Chase them off!"
		warning.Visible = true
		task.delay(6, function()
			warning.Visible = false
		end)
	elseif action == "WaveWarning" then
		if payload.phase == "start" then
			notice.Text = "THE WAVE IS COMING! Dash home to your plot!"
		elseif payload.phase == "end" then
			notice.Text = "The wave passed. The bay is calm... for now."
		end
	elseif action == "WaveCountdown" then
		waveLabel.Text = "Wave: " .. tostring(payload.seconds) .. "s"
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

print("BRAINROT BAY HUD ready.")
