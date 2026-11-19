-- LIGHTHOUSE BAY
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)
local RivalBotAI = {}
local rng = Random.new()
local BOT_NAMES = { "Sneaky Sal", "Greedy Gus", "Looty Lou" }
local BOT_COLORS = {
	{ 180, 40, 40 },
	{ 200, 90, 30 },
	{ 140, 40, 140 },
}
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
		humanoid:MoveTo(slot.position)
		local arrived = humanoid.MoveToFinished:Wait()
		if not arrived or not slot.brainrot then
			continue
		end
		world.onStealStart(plotIndex, slotIndex, botModel.Name)
		local channelled = true
		for _ = 1, Config.STEAL_CHANNEL_SECONDS * 2 do
			task.wait(0.5)
			if not slot.brainrot or not botModel.Parent then
				channelled = false
				break
			end
			if world.isChannelInterrupted and world.isChannelInterrupted(botModel.Name) then
				channelled = false
				break
			end
		end
		if channelled and slot.brainrot then
			world.onStealDone(plotIndex, slotIndex, botModel.Name)
			humanoid:MoveTo(world.rivalDen)
			humanoid.MoveToFinished:Wait()
		elseif not channelled then
			if world.onStealAbort then
				world.onStealAbort(botModel.Name)
			end
			humanoid:MoveTo(world.rivalDen)
			humanoid.MoveToFinished:Wait()
		end
	end
end
return RivalBotAI
