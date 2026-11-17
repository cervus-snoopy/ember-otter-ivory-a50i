-- BRAINROT BAY -- BrainrotSpawner (server ModuleScript).
-- Owns the conveyor: rolls a new brainrot on a timer, builds its little
-- 3D body out of parts, and walks it down the dock to the shop window.
-- A brainrot that nobody buys before its window ends wanders off the dock
-- and is cleaned up, so the conveyor never jams.
--
-- The walking body is a simple model: a coloured torso block, a head block,
-- two stubby legs and a floating name tag (a BillboardGui with the name,
-- rarity and $/s, so a player can read the offer from across the map).
-- The dock runs along z = -58, south of the lighthouse boardwalk at z = -86.

local Characters = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Characters)
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)

local Spawner = {}

-- Where the conveyor starts and ends, in world space. The dock runs along
-- the north edge of the bay, from x = -48 to x = +48 at z = -58.
Spawner.DOCK_Z = -58
Spawner.DOCK_START_X = -48
Spawner.DOCK_END_X = 48

local rng = Random.new()

-- Build the visible body for one cast member. Returns a Model anchored at
-- the given position, with a StringValue "BrainrotId" the server uses to
-- match the model back to its shop entry.
function Spawner.buildModel(entry, mutation: string, id: string, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = entry.name

	local color = entry.color
	local mut = Characters.MUTATIONS[mutation]
	if mut and mut.color then
		color = mut.color
	end
	local bodyColor = Color3.fromRGB(color[1], color[2], color[3])

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(3, 3, 2)
	torso.Position = position + Vector3.new(0, 2.5, 0)
	torso.Anchored = true
	torso.Color = bodyColor
	torso.Material = Enum.Material.SmoothPlastic
	torso.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 2, 2)
	head.Position = position + Vector3.new(0, 5, 0)
	head.Anchored = true
	head.Color = Color3.fromRGB(255, 220, 180)
	head.Material = Enum.Material.SmoothPlastic
	head.Parent = model
	model.PrimaryPart = torso

	-- Two stubby legs, so the walk bob reads as walking.
	for _, side in ipairs({ -0.8, 0.8 }) do
		local leg = Instance.new("Part")
		leg.Name = "Leg"
		leg.Size = Vector3.new(0.8, 1.5, 0.8)
		leg.Position = position + Vector3.new(side, 0.75, 0)
		leg.Anchored = true
		leg.Color = Color3.fromRGB(60, 60, 70)
		leg.Parent = model
	end

	-- A golden crown for mutated brainrots: the flex must be visible.
	if mutation ~= "None" then
		local crown = Instance.new("Part")
		crown.Name = "Crown"
		crown.Size = Vector3.new(2.2, 0.6, 2.2)
		crown.Position = position + Vector3.new(0, 6.3, 0)
		crown.Anchored = true
		crown.Color = Color3.fromRGB(255, 215, 0)
		crown.Material = Enum.Material.Neon
		crown.Parent = model
	end

	-- Floating name tag: name, rarity, income. Readable from across the bay.
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(140, 54)
	tag.StudsOffset = Vector3.new(0, 4, 0)
	tag.AlwaysOnTop = false
	tag.Parent = torso

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.35
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	local rarityColor = Characters.RARITY_COLORS[entry.rarity]
	label.Text = string.format(
		"%s\n%s  $%d/s  $%d",
		entry.name,
		entry.rarity,
		Characters.incomeFor(entry, mutation, 0),
		entry.price
	)
	label.Parent = tag

	local idValue = Instance.new("StringValue")
	idValue.Name = "BrainrotId"
	idValue.Value = id
	idValue.Parent = model

	return model
end

-- Roll one shop entry: rarity, then a cast member of that rarity, then a
-- mutation. Returns a plain table the server keeps in its shop list.
function Spawner.rollEntry(id: string)
	local rarity = Characters.rollRarity(rng)
	local entry = Characters.randomOfRarity(rarity, rng)
	if not entry then
		entry = Characters.CAST[1]
	end
	local mutation = Characters.rollMutation(rng)
	return {
		id = id,
		name = entry.name,
		rarity = entry.rarity,
		mutation = mutation,
		income = Characters.incomeFor(entry, mutation, 0),
		price = entry.price,
		joke = entry.joke,
		spawnedAt = os.clock(),
	}
end

-- Walk a model along the dock from the spawn point to the shop window.
-- Runs on its own thread; the caller keeps the model reference.
function Spawner.walkToWindow(model: Model, onArrived: () -> ())
	task.spawn(function()
		local startX = Spawner.DOCK_START_X
		local endX = Spawner.DOCK_END_X
		local steps = math.floor((endX - startX) / (Config.WALK_SPEED * 0.1))
		for i = 0, steps do
			if not model.Parent then
				return
			end
			local x = startX + (endX - startX) * (i / steps)
			-- A little bob so the walk reads as a walk, not a slide.
			local bob = math.sin(i * 0.9) * 0.25
			local primary = model.PrimaryPart
			if primary then
				local y = primary.Position.Y
				model:PivotTo(CFrame.new(x, y + bob * 0.1, Spawner.DOCK_Z))
			end
			task.wait(0.1)
		end
		if onArrived then
			onArrived()
		end
	end)
end

return Spawner
