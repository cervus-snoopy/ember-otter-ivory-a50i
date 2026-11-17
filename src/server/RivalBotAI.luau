-- BRAINROT BAY -- RivalBotAI (server ModuleScript).
-- The threat that makes the bay tense: rival bots prowl the plots, pick a
-- brainrot that is not locked down, channel a steal, and carry it home to
-- their own plot. The owner sees the warning, can chase the bot down, and
-- can steal the brainrot back while the bot is carrying it.
--
-- A bot is a simple rig: a dark torso, a red head, and a name tag that says
-- RIVAL. It walks with TweenService-free stepping (plain CFrame moves on a
-- loop) so the logic stays readable and deterministic.
-- Bots den in the south (z = 95); the lighthouse beam marks the wave, never
-- a bot -- it does not track steals.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)

local RivalBotAI = {}

local rng = Random.new()

local BOT_NAMES = { "Sneaky Sal", "Greedy Gus", "Looty Lou" }
local BOT_COLORS = {
	{ 180, 40, 40 },
	{ 200, 90, 30 },
	{ 140, 40, 140 },
}

-- Build one bot rig at a position. The bot is a Model with a Humanoid so it
-- can walk with MoveTo, plus a StringValue "BotName" for the HUD.
function RivalBotAI.buildBot(index: number, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = BOT_NAMES[index] or ("Rival " .. tostring(index))

	local color = BOT_COLORS[index] or { 180, 40, 40 }
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(3, 3.5, 2)
	torso.Position = position + Vector3.new(0, 3, 0)
	torso.Anchored = false
	torso.Color = Color3.fromRGB(color[1], color[2], color[3])
	torso.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 2, 2)
	head.Position = position + Vector3.new(0, 5.5, 0)
	head.Anchored = false
	head.Color = Color3.fromRGB(230, 60, 60)
	head.Parent = model
	model.PrimaryPart = torso

	-- Weld the head to the torso so the rig holds together.
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = head
	weld.Parent = torso

	local humanoid = Instance.new("Humanoid")
	humanoid.WalkSpeed = Config.RIVAL_WALK_SPEED
	humanoid.Parent = model

	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(120, 30)
	tag.StudsOffset = Vector3.new(0, 4, 0)
	tag.Parent = torso
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.4
	label.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
	label.TextColor3 = Color3.fromRGB(255, 120, 120)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = "RIVAL: " .. model.Name
	label.Parent = tag

	local nameValue = Instance.new("StringValue")
	nameValue.Name = "BotName"
	nameValue.Value = model.Name
	nameValue.Parent = model

	return model
end

-- Pick a victim plot: the richest unlocked plot that actually has a
-- brainrot on it. Returns the plot index, or nil when nothing is stealable.
function RivalBotAI.pickVictimPlot(plots): number?
	local bestPlot = nil
	local bestValue = 0
	for i, plot in ipairs(plots) do
		if not plot.lockedUntil or plot.lockedUntil < os.clock() then
			local value = 0
			for _, slot in ipairs(plot.slots) do
				if slot.brainrot then
					value += slot.brainrot.income
				end
			end
			if value > bestValue then
				bestValue = value
				bestPlot = i
			end
		end
	end
	return bestPlot
end

-- Pick the richest brainrot on a plot. Returns its slot index, or nil.
function RivalBotAI.pickVictimSlot(plot): number?
	local bestSlot = nil
	local bestIncome = 0
	for i, slot in ipairs(plot.slots) do
		if slot.brainrot and slot.brainrot.income > bestIncome then
			bestIncome = slot.brainrot.income
			bestSlot = i
		end
	end
	return bestSlot
end

-- One bot's behaviour loop. It waits, picks a victim, walks to the plot,
-- channels the steal (the owner gets a warning the whole time), grabs the
-- brainrot, and walks it home to the rival den. If the brainrot is taken
-- back mid-carry, the bot gives up and prowls again.
-- `world` is the table of callbacks the main server script hands in:
--   world.plots, world.onStealStart(plot, slot, botName),
--   world.onStealDone(plot, slot, botName), world.rivalDen (Vector3).
function RivalBotAI.runBot(botModel: Model, world)
	local humanoid = botModel:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	while botModel.Parent do
		task.wait(Config.RIVAL_STEAL_DELAY + rng:NextInteger(0, 15))
		if not botModel.Parent then
			break
		end
		local plotIndex = RivalBotAI.pickVictimPlot(world.plots)
		if not plotIndex then
			continue
		end
		local plot = world.plots[plotIndex]
		local slotIndex = RivalBotAI.pickVictimSlot(plot)
		if not slotIndex then
			continue
		end
		local slot = plot.slots[slotIndex]
		if not slot or not slot.brainrot then
			continue
		end
		-- Walk to the victim's plot.
		humanoid:MoveTo(slot.position)
		local arrived = humanoid.MoveToFinished:Wait()
		if not arrived or not slot.brainrot then
			continue
		end
		-- Channel the steal: the warning is live for the whole channel.
		world.onStealStart(plotIndex, slotIndex, botModel.Name)
		local channelled = true
		for _ = 1, Config.STEAL_CHANNEL_SECONDS * 2 do
			task.wait(0.5)
			if not slot.brainrot or not botModel.Parent then
				channelled = false
				break
			end
		end
		if channelled and slot.brainrot then
			world.onStealDone(plotIndex, slotIndex, botModel.Name)
			-- Carry it home: walk to the rival den, then vanish with it.
			humanoid:MoveTo(world.rivalDen)
			humanoid.MoveToFinished:Wait()
		end
	end
end

return RivalBotAI
