-- BRAINROT BAY -- Main server script.
-- The single source of truth for the game state. It owns:
--   * one plot per player (8 plots, first come first served)
--   * the conveyor shop (BrainrotSpawner rolls, this script sells)
--   * the earnings tick (every second, every owned brainrot pays)
--   * eggs, selling, plot locks and rebirths
--   * player stealing (proximity-checked) and the rival-bot threat
--   * the wave event (WaveManager sweeps, this script catches players)
--   * the leaderboard broadcast
-- All client talk goes through two remotes in ReplicatedStorage:
--   ServerEvent (client -> server, action + arguments) and
--   ClientEvent (server -> client, action + payload).
-- No DataStore, no persistence: the demo loop is session-based, so a fresh
-- join starts at START_CASH with an empty plot.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Characters = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Characters)
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)
local Spawner = require(script.Parent.BrainrotSpawner)
local RivalBotAI = require(script.Parent.RivalBotAI)
local WaveManager = require(script.Parent.WaveManager)

local rng = Random.new()

-- ---------------------------------------------------------------------------
-- Remotes
-- ---------------------------------------------------------------------------
local remotes = Instance.new("Folder")
remotes.Name = "BrainrotBayRemotes"
remotes.Parent = ReplicatedStorage

local serverEvent = Instance.new("RemoteEvent")
serverEvent.Name = "ServerEvent"
serverEvent.Parent = remotes

local clientEvent = Instance.new("RemoteEvent")
clientEvent.Name = "ClientEvent"
clientEvent.Parent = remotes

local function send(player: Player, action: string, payload)
	clientEvent:FireClient(player, action, payload)
end

local function broadcast(action: string, payload)
	clientEvent:FireAllClients(action, payload)
end

-- ---------------------------------------------------------------------------
-- Plots: 8 plots, two rows of four. Centres match the static world in
-- default.project.json, so the fences and pads the player sees are the
-- plots the server owns.
-- ---------------------------------------------------------------------------
local plots = {}
do
	local xs = { -51, -17, 17, 51 }
	local zs = { -23, 23 }
	local index = 0
	for _, z in ipairs(zs) do
		for _, x in ipairs(xs) do
			index += 1
			local slots = {}
			for _, dz in ipairs({ -4, 4 }) do
				for _, dx in ipairs({ -7, 0, 7 }) do
					table.insert(slots, {
						position = Vector3.new(x + dx, 1.5, z + dz),
						brainrot = nil,
						model = nil,
					})
				end
			end
			plots[index] = {
				center = Vector3.new(x, 1, z),
				owner = nil, -- Player or nil
				slots = slots,
				lockedUntil = 0,
			}
		end
	end
end

local function plotOf(player: Player)
	for i, plot in ipairs(plots) do
		if plot.owner == player then
			return i, plot
		end
	end
	return nil, nil
end

local function firstFreeSlot(plot)
	for i, slot in ipairs(plot.slots) do
		if not slot.brainrot then
			return i, slot
		end
	end
	return nil, nil
end

-- ---------------------------------------------------------------------------
-- Player state (session only)
-- ---------------------------------------------------------------------------
local state = {} -- [Player] = { cash, rebirths, totalEarned, stealCooldownUntil }

local function newState(player: Player)
	state[player] = {
		cash = Config.START_CASH,
		rebirths = 0,
		totalEarned = 0,
		stealCooldownUntil = 0,
	}
end

local function incomePerSecond(player: Player): number
	local _, plot = plotOf(player)
	if not plot then
		return 0
	end
	local total = 0
	for _, slot in ipairs(plot.slots) do
		if slot.brainrot then
			total += slot.brainrot.income
		end
	end
	return total
end

local function ownedList(player: Player)
	local _, plot = plotOf(player)
	local out = {}
	if plot then
		for i, slot in ipairs(plot.slots) do
			if slot.brainrot then
				local b = slot.brainrot
				table.insert(out, {
					slot = i,
					name = b.name,
					rarity = b.rarity,
					mutation = b.mutation,
					income = b.income,
					price = b.price,
				})
			end
		end
	end
	return out
end

local function pushState(player: Player)
	local s = state[player]
	if not s then
		return
	end
	local plotIndex = plotOf(player)
	send(player, "State", {
		cash = s.cash,
		rebirths = s.rebirths,
		totalEarned = s.totalEarned,
		incomePerSecond = incomePerSecond(player),
		plot = plotIndex,
		owned = ownedList(player),
		waveIn = WaveManager.secondsUntilWave(),
	})
end

-- ---------------------------------------------------------------------------
-- The conveyor shop
-- ---------------------------------------------------------------------------
local shop = {} -- list of entries, each with .model in Workspace.Conveyor
local shopFolder = Instance.new("Folder")
shopFolder.Name = "Conveyor"
shopFolder.Parent = Workspace

local shopCounter = 0

local function spawnShopBrainrot()
	shopCounter += 1
	local entry = Spawner.rollEntry("shop-" .. tostring(shopCounter))
	local castEntry = Characters.byName(entry.name)
	local model = Spawner.buildModel(
		castEntry,
		entry.mutation,
		entry.id,
		Vector3.new(Spawner.DOCK_START_X, 1, Spawner.DOCK_Z)
	)
	model.Parent = shopFolder
	entry.model = model
	table.insert(shop, entry)
	Spawner.walkToWindow(model, function()
		-- The window timer starts when it arrives at the shop end.
		entry.arrivedAt = os.clock()
	end)
	broadcast("Shop", shopPublic())
end

function shopPublic()
	local out = {}
	for _, entry in ipairs(shop) do
		table.insert(out, {
			id = entry.id,
			name = entry.name,
			rarity = entry.rarity,
			mutation = entry.mutation,
			income = entry.income,
			price = entry.price,
			joke = entry.joke,
		})
	end
	return out
end

-- Prune shop entries whose window expired: the model wanders off (is
-- destroyed) and the listing disappears from every HUD.
task.spawn(function()
	while true do
		task.wait(2)
		local now = os.clock()
		for i = #shop, 1, -1 do
			local entry = shop[i]
			if entry.arrivedAt and now - entry.arrivedAt > Config.SHOP_WINDOW_SECONDS then
				if entry.model then
					entry.model:Destroy()
				end
				table.remove(shop, i)
				broadcast("Shop", shopPublic())
			end
		end
	end
end)

-- Spawn loop: a fresh brainrot rolls onto the dock every few seconds.
task.spawn(function()
	while true do
		task.wait(Config.SPAWN_INTERVAL)
		if #shop < 6 then
			spawnShopBrainrot()
		end
	end
end)

-- ---------------------------------------------------------------------------
-- Buying, selling, eggs, locks, rebirths
-- ---------------------------------------------------------------------------
local function placeOnPlot(player: Player, brainrot): boolean
	local _, plot = plotOf(player)
	if not plot then
		return false
	end
	local _, slot = firstFreeSlot(plot)
	if not slot then
		return false
	end
	slot.brainrot = brainrot
	local castEntry = Characters.byName(brainrot.name)
	slot.model = Spawner.buildModel(castEntry, brainrot.mutation, brainrot.id, slot.position)
	slot.model.Parent = Workspace
	return true
end

local function buyBrainrot(player: Player, shopId: string)
	local s = state[player]
	if not s then
		return
	end
	for i, entry in ipairs(shop) do
		if entry.id == shopId then
			if s.cash < entry.price then
				send(player, "Notice", "Not enough cash for " .. entry.name .. "!")
				return
			end
			local _, plot = plotOf(player)
			if not plot then
				send(player, "Notice", "You have no plot yet!")
				return
			end
			local _, slot = firstFreeSlot(plot)
			if not slot then
				send(player, "Notice", "Your plot is full! Sell one first.")
				return
			end
			s.cash -= entry.price
			if entry.model then
				entry.model:Destroy()
			end
			table.remove(shop, i)
			local brainrot = {
				id = entry.id,
				name = entry.name,
				rarity = entry.rarity,
				mutation = entry.mutation,
				income = entry.income,
				price = entry.price,
			}
			placeOnPlot(player, brainrot)
			send(player, "Notice", "You bought " .. entry.name .. " (" .. entry.rarity .. ")!")
			broadcast("Shop", shopPublic())
			pushState(player)
			return
		end
	end
	send(player, "Notice", "That brainrot already wandered off.")
end

local function sellBrainrot(player: Player, slotIndex: number)
	local s = state[player]
	local _, plot = plotOf(player)
	if not s or not plot then
		return
	end
	local slot = plot.slots[slotIndex]
	if not slot or not slot.brainrot then
		return
	end
	local refund = math.floor(slot.brainrot.price * Config.SELL_REFUND)
	s.cash += refund
	send(player, "Notice", "Sold " .. slot.brainrot.name .. " for $" .. tostring(refund) .. ".")
	if slot.model then
		slot.model:Destroy()
	end
	slot.model = nil
	slot.brainrot = nil
	pushState(player)
end

local function buyEgg(player: Player, tier: string)
	local s = state[player]
	local price = Config.EGG_PRICES[tier]
	if not s or not price then
		return
	end
	if s.cash < price then
		send(player, "Notice", "Not enough cash for a " .. tier .. " egg!")
		return
	end
	local _, plot = plotOf(player)
	if not plot or not firstFreeSlot(plot) then
		send(player, "Notice", "Your plot is full! Sell one first.")
		return
	end
	s.cash -= price
	local pool = Characters.EGG_POOLS[tier]
	local rarity = pool[rng:NextInteger(1, #pool)]
	local castEntry = Characters.randomOfRarity(rarity, rng)
	local mutation = Characters.rollMutation(rng)
	local brainrot = {
		id = "egg-" .. tostring(os.clock()),
		name = castEntry.name,
		rarity = castEntry.rarity,
		mutation = mutation,
		income = Characters.incomeFor(castEntry, mutation, s.rebirths),
		price = castEntry.price,
	}
	placeOnPlot(player, brainrot)
	send(player, "Notice", "Your " .. tier .. " egg hatched " .. brainrot.name .. " (" .. brainrot.rarity .. ")!")
	pushState(player)
end

local function lockPlot(player: Player)
	local s = state[player]
	local plotIndex, plot = plotOf(player)
	if not s or not plot then
		return
	end
	if s.cash < Config.LOCK_COST then
		send(player, "Notice", "A lock costs $" .. tostring(Config.LOCK_COST) .. ".")
		return
	end
	s.cash -= Config.LOCK_COST
	plot.lockedUntil = os.clock() + Config.LOCK_DURATION
	send(player, "Notice", "Plot locked for " .. tostring(Config.LOCK_DURATION) .. " seconds!")
	pushState(player)
end

local function rebirth(player: Player)
	local s = state[player]
	local _, plot = plotOf(player)
	if not s or not plot then
		return
	end
	if s.rebirths >= Config.REBIRTH_MAX then
		send(player, "Notice", "You are at max rebirths!")
		return
	end
	local needed = Config.REBIRTH_MIN_CASH_EARNED * (s.rebirths + 1)
	if s.totalEarned < needed then
		send(player, "Notice", "Rebirth needs $" .. tostring(needed) .. " earned in total.")
		return
	end
	for _, slot in ipairs(plot.slots) do
		if slot.model then
			slot.model:Destroy()
		end
		slot.model = nil
		slot.brainrot = nil
	end
	s.rebirths += 1
	s.cash = Config.START_CASH
	s.totalEarned = 0
	send(player, "Notice", "REBIRTH " .. tostring(s.rebirths) .. "! All income x" .. tostring(1 + s.rebirths * 0.5) .. " forever.")
	pushState(player)
end

-- ---------------------------------------------------------------------------
-- Stealing (player vs player plot, and stealing back from a rival bot)
-- ---------------------------------------------------------------------------
local stolenByBot = {} -- [botName] = brainrot table

local function characterNear(player: Player, position: Vector3, radius: number): boolean
	local character = player.Character
	if not character then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	return (root.Position - position).Magnitude <= radius
end

local function stealFromPlot(player: Player, targetPlotIndex: number, slotIndex: number)
	local s = state[player]
	if not s then
		return
	end
	if os.clock() < s.stealCooldownUntil then
		send(player, "Notice", "Steal is on cooldown. Wait a moment.")
		return
	end
	local target = plots[targetPlotIndex]
	if not target or target.owner == player or not target.owner then
		return
	end
	if target.lockedUntil > os.clock() then
		send(player, "Notice", "That plot is locked! Come back later.")
		return
	end
	local slot = target.slots[slotIndex]
	if not slot or not slot.brainrot then
		return
	end
	if not characterNear(player, slot.position, 14) then
		send(player, "Notice", "Get closer to steal it!")
		return
	end
	local _, myPlot = plotOf(player)
	if not myPlot or not firstFreeSlot(myPlot) then
		send(player, "Notice", "Your plot is full! Sell one first.")
		return
	end
	local brainrot = slot.brainrot
	if slot.model then
		slot.model:Destroy()
	end
	slot.model = nil
	slot.brainrot = nil
	placeOnPlot(player, brainrot)
	s.stealCooldownUntil = os.clock() + Config.STEAL_COOLDOWN_SECONDS
	send(player, "Notice", "You stole " .. brainrot.name .. " from " .. target.owner.Name .. "!")
	if target.owner then
		send(target.owner, "Notice", player.Name .. " stole your " .. brainrot.name .. "!")
	end
	pushState(player)
	pushState(target.owner)
end

local function stealBackFromBot(player: Player, botName: string, botModel: Model)
	local s = state[player]
	local brainrot = stolenByBot[botName]
	if not s or not brainrot then
		return
	end
	local root = botModel.PrimaryPart
	if not root or not characterNear(player, root.Position, 15) then
		send(player, "Notice", "Chase the bot down first!")
		return
	end
	local _, myPlot = plotOf(player)
	if not myPlot or not firstFreeSlot(myPlot) then
		send(player, "Notice", "Your plot is full! Sell one first.")
		return
	end
	stolenByBot[botName] = nil
	placeOnPlot(player, brainrot)
	send(player, "Notice", "You stole back " .. brainrot.name .. " from " .. botName .. "!")
	pushState(player)
end

-- ---------------------------------------------------------------------------
-- Rival bots
-- ---------------------------------------------------------------------------
local rivalFolder = Instance.new("Folder")
rivalFolder.Name = "Rivals"
rivalFolder.Parent = Workspace

local rivalDen = Vector3.new(0, 2, 95)
local botModels = {}

local world = {
	plots = plots,
	rivalDen = rivalDen,
	onStealStart = function(plotIndex: number, slotIndex: number, botName: string)
		local plot = plots[plotIndex]
		if plot and plot.owner then
			send(plot.owner, "StealWarning", {
				bot = botName,
				slot = slotIndex,
				seconds = Config.STEAL_CHANNEL_SECONDS,
			})
		end
	end,
	onStealDone = function(plotIndex: number, slotIndex: number, botName: string)
		local plot = plots[plotIndex]
		if not plot then
			return
		end
		local slot = plot.slots[slotIndex]
		if not slot or not slot.brainrot then
			return
		end
		local brainrot = slot.brainrot
		stolenByBot[botName] = brainrot
		if slot.model then
			slot.model:Destroy()
		end
		slot.model = nil
		slot.brainrot = nil
		if plot.owner then
			send(plot.owner, "Notice", botName .. " stole your " .. brainrot.name .. "! Chase them and steal it back!")
			pushState(plot.owner)
		end
	end,
}

for i = 1, Config.RIVAL_COUNT do
	local spawnPos = Vector3.new(-40 + (i - 1) * 40, 2, 95)
	local bot = RivalBotAI.buildBot(i, spawnPos)
	bot.Parent = rivalFolder
	botModels[bot.Name] = bot
	task.spawn(function()
		RivalBotAI.runBot(bot, world)
	end)
end

-- ---------------------------------------------------------------------------
-- The wave
-- ---------------------------------------------------------------------------
local waveWorld = {
	onWaveStart = function()
		broadcast("WaveWarning", { seconds = 0, phase = "start" })
	end,
	onWaveEnd = function()
		broadcast("WaveWarning", { seconds = 0, phase = "end" })
	end,
	onWavePass = function(coord: number, axis: string)
		-- Anyone the wall is sweeping over, who is not safe at home, is
		-- caught once: knocked back to spawn, loses 5% of their cash.
		-- The wall moves along one axis per wave (see WaveManager); the
		-- catch check reads the player's coordinate on that same axis.
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root then
					local along = root.Position.Z
					if axis == "X" then
						along = root.Position.X
					end
					if math.abs(along - coord) < 6 then
						local _, plot = plotOf(player)
						local safe = false
						if plot and (root.Position - plot.center).Magnitude <= Config.WAVE_SAFE_RADIUS then
							safe = true
						end
						if not safe then
							local s = state[player]
							if s then
								local lost = math.floor(s.cash * 0.05)
								s.cash -= lost
								send(player, "Notice", "The wave caught you! You lost $" .. tostring(lost) .. " and were washed home.")
								pushState(player)
							end
							character:PivotTo(CFrame.new(0, 5, 60))
						end
					end
				end
			end
		end
	end,
}
WaveManager.buildWall(Workspace)
WaveManager.startLoop(waveWorld)

-- Wave countdown broadcast, so every HUD counts down in sync. The beam
-- heading rides along, so the HUD can show which way the next wave comes
-- from without polling ReplicatedStorage.
task.spawn(function()
	while true do
		task.wait(1)
		broadcast("WaveCountdown", {
			seconds = math.floor(WaveManager.secondsUntilWave()),
			warning = WaveManager.isWarning(),
			beamAngle = WaveManager.beamAngleDeg,
		})
	end
end)

-- ---------------------------------------------------------------------------
-- Earnings tick + leaderboard
-- ---------------------------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(Config.TICK_SECONDS)
		for _, player in ipairs(Players:GetPlayers()) do
			local s = state[player]
			if s then
				local earned = incomePerSecond(player)
				if earned > 0 then
					s.cash += earned
					s.totalEarned += earned
				end
				pushState(player)
			end
		end
	end
end)

local function leaderboard()
	local rows = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local s = state[player]
		if s then
			table.insert(rows, { name = player.Name, cash = s.cash, income = incomePerSecond(player) })
		end
	end
	table.sort(rows, function(a, b)
		return a.cash > b.cash
	end)
	return rows
end

task.spawn(function()
	while true do
		task.wait(5)
		broadcast("Leaderboard", leaderboard())
	end
end)

-- ---------------------------------------------------------------------------
-- Client requests
-- ---------------------------------------------------------------------------
serverEvent.OnServerEvent:Connect(function(player: Player, action: string, arg1, arg2)
	if action == "Buy" then
		buyBrainrot(player, arg1)
	elseif action == "Sell" then
		sellBrainrot(player, arg1)
	elseif action == "BuyEgg" then
		buyEgg(player, arg1)
	elseif action == "Lock" then
		lockPlot(player)
	elseif action == "Rebirth" then
		rebirth(player)
	elseif action == "Steal" then
		stealFromPlot(player, arg1, arg2)
	elseif action == "StealBack" then
		local bot = botModels[arg1]
		if bot then
			stealBackFromBot(player, arg1, bot)
		end
	elseif action == "RequestState" then
		pushState(player)
		send(player, "Shop", shopPublic())
		send(player, "Leaderboard", leaderboard())
	end
end)

-- ---------------------------------------------------------------------------
-- Join / leave
-- ---------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player: Player)
	newState(player)
	-- First free plot is yours. If all 8 are taken, you spectate.
	for _, plot in ipairs(plots) do
		if not plot.owner then
			plot.owner = player
			break
		end
	end
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		character:PivotTo(CFrame.new(0, 5, 60))
	end)
	task.wait(1)
	pushState(player)
	send(player, "Shop", shopPublic())
	send(player, "Leaderboard", leaderboard())
	send(player, "Notice", "Welcome to BRAINROT BAY! Buy a brainrot from the conveyor, guard your plot!")
end)

Players.PlayerRemoving:Connect(function(player: Player)
	local _, plot = plotOf(player)
	if plot then
		plot.owner = nil
		for _, slot in ipairs(plot.slots) do
			if slot.model then
				slot.model:Destroy()
			end
			slot.model = nil
			slot.brainrot = nil
		end
	end
	state[player] = nil
end)

-- Seed the shop so the first player sees brainrots waiting.
for _ = 1, 3 do
	spawnShopBrainrot()
end

print("BRAINROT BAY server ready: 8 plots, conveyor live, rivals prowling, lighthouse watching.")
