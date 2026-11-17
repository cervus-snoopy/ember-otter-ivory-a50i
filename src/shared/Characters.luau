-- BRAINROT BAY -- the cast.
-- Every character here is invented for this game: a pastry captain, a pickle
-- DJ, a barking knight and friends. None of them is borrowed from any other
-- brainrot game. Each one has a rarity tier, a base income per second, a buy
-- price, a body colour for its in-world model, and a one-line joke that the
-- HUD shows when you inspect it. The cast is 19 strong: Professor Pickle
-- joined as the fourth Legendary, a briny academic priced between Admiral
-- Avocado and the Mythics, and he spawns through the same rarity roll as
-- everyone else -- no special pool, no special case.
--
-- Rarity ladder (income and price roughly double each step, so the climb
-- always feels one tier away):
--   Common -> Uncommon -> Rare -> Epic -> Legendary -> Mythic
-- Mutations multiply income: Golden x2, Diamond x4, Rainbow x8.
-- A rebirth multiplies everything again (see Config).

local Characters = {}

Characters.RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }

Characters.RARITY_ORDER = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
}

-- Display colour per rarity, used by the HUD labels and the name tags.
Characters.RARITY_COLORS = {
	Common = { 200, 200, 200 },
	Uncommon = { 120, 220, 120 },
	Rare = { 90, 160, 255 },
	Epic = { 190, 110, 255 },
	Legendary = { 255, 190, 40 },
	Mythic = { 255, 70, 160 },
}

-- Spawn weights: common faces show up constantly, mythics almost never.
Characters.RARITY_WEIGHTS = {
	Common = 42,
	Uncommon = 26,
	Rare = 16,
	Epic = 9,
	Legendary = 5,
	Mythic = 2,
}

Characters.MUTATIONS = {
	None = { multiplier = 1, color = nil, chance = 0 },
	Golden = { multiplier = 2, color = { 255, 215, 0 }, chance = 12 },
	Diamond = { multiplier = 4, color = { 170, 230, 255 }, chance = 4 },
	Rainbow = { multiplier = 8, color = { 255, 120, 220 }, chance = 1 },
}

-- name, rarity, income per second, buy price, body colour (RGB), joke.
Characters.CAST = {
	{ name = "Captain Croissant", rarity = "Common", income = 2, price = 50, color = { 232, 190, 110 }, joke = "Sails the butter seas. Flakes everywhere." },
	{ name = "Sir Barksalot", rarity = "Common", income = 3, price = 75, color = { 170, 120, 70 }, joke = "Knighted for barking at the mailman." },
	{ name = "DJ Pickle", rarity = "Common", income = 4, price = 100, color = { 90, 180, 80 }, joke = "Drops beats. Brine not included." },
	{ name = "Madame Mooncake", rarity = "Uncommon", income = 8, price = 220, color = { 240, 220, 160 }, joke = "Predicts your fortune. It is cake." },
	{ name = "Professor Pancake", rarity = "Uncommon", income = 11, price = 300, color = { 220, 170, 90 }, joke = "Flips first, asks questions never." },
	{ name = "Baron Broccoli", rarity = "Uncommon", income = 14, price = 380, color = { 60, 160, 70 }, joke = "Rules the veggie court with an iron floret." },
	{ name = "Queen Quokka", rarity = "Rare", income = 25, price = 700, color = { 200, 150, 100 }, joke = "Happiest monarch in the bay. By decree." },
	{ name = "Lord Llama Latte", rarity = "Rare", income = 32, price = 900, color = { 230, 210, 190 }, joke = "Spits foam art at his enemies." },
	{ name = "Duchess Donut", rarity = "Rare", income = 40, price = 1100, color = { 255, 170, 200 }, joke = "Sprinkles are her royal guard." },
	{ name = "Emperor Eggplant", rarity = "Epic", income = 70, price = 2000, color = { 120, 60, 160 }, joke = "Purple reign. No, really, all of it." },
	{ name = "Wizard Waffle", rarity = "Epic", income = 90, price = 2600, color = { 210, 160, 80 }, joke = "Casts Syrup Storm. Sticky situation." },
	{ name = "General Guacamole", rarity = "Epic", income = 110, price = 3200, color = { 120, 190, 60 }, joke = "Extra. Always extra." },
	{ name = "King Kebab", rarity = "Legendary", income = 180, price = 5500, color = { 190, 120, 60 }, joke = "Skewered three kingdoms before lunch." },
	{ name = "Countess Cupcake", rarity = "Legendary", income = 220, price = 6800, color = { 255, 150, 180 }, joke = "Her frosting hides a secret army." },
	{ name = "Admiral Avocado", rarity = "Legendary", income = 260, price = 8000, color = { 80, 160, 80 }, joke = "Commands the toast fleet. Ripe for battle." },
	{ name = "Professor Pickle", rarity = "Legendary", income = 300, price = 9500, color = { 110, 200, 90 }, joke = "Tenured in brine. Publishes in pickle." },
	{ name = "Sir Spaghetti", rarity = "Mythic", income = 450, price = 15000, color = { 240, 210, 130 }, joke = "A noodle knight. Al dente, never defeated." },
	{ name = "The Great Gnocchi", rarity = "Mythic", income = 550, price = 18000, color = { 220, 200, 170 }, joke = "Ancient. Dumpling-shaped. Unstoppable." },
	{ name = "Moonlight Muffin", rarity = "Mythic", income = 700, price = 24000, color = { 180, 160, 255 }, joke = "Bakes only at midnight. Worth the wait." },
}

-- Egg tiers draw from a rarity pool: a Golden egg can hatch anything, a
-- Basic egg almost never hatches above Rare.
Characters.EGG_POOLS = {
	Basic = { "Common", "Common", "Uncommon", "Uncommon", "Rare" },
	Fancy = { "Uncommon", "Rare", "Rare", "Epic", "Epic", "Legendary" },
	Golden = { "Rare", "Epic", "Legendary", "Legendary", "Mythic", "Mythic" },
}

function Characters.byName(name: string)
	for _, entry in ipairs(Characters.CAST) do
		if entry.name == name then
			return entry
		end
	end
	return nil
end

function Characters.ofRarity(rarity: string)
	local out = {}
	for _, entry in ipairs(Characters.CAST) do
		if entry.rarity == rarity then
			table.insert(out, entry)
		end
	end
	return out
end

-- Weighted roll over the rarity ladder. Returns a rarity name.
function Characters.rollRarity(rng: Random): string
	local total = 0
	for _, rarity in ipairs(Characters.RARITIES) do
		total += Characters.RARITY_WEIGHTS[rarity]
	end
	local roll = rng:NextNumber(0, total)
	local running = 0
	for _, rarity in ipairs(Characters.RARITIES) do
		running += Characters.RARITY_WEIGHTS[rarity]
		if roll <= running then
			return rarity
		end
	end
	return "Common"
end

-- Roll a mutation. Most brainrots are plain; a lucky few shine.
function Characters.rollMutation(rng: Random): string
	local roll = rng:NextNumber(0, 100)
	if roll <= 1 then
		return "Rainbow"
	elseif roll <= 5 then
		return "Diamond"
	elseif roll <= 17 then
		return "Golden"
	end
	return "None"
end

-- A random cast member of the given rarity, or nil if the tier is empty.
function Characters.randomOfRarity(rarity: string, rng: Random)
	local pool = Characters.ofRarity(rarity)
	if #pool == 0 then
		return nil
	end
	return pool[rng:NextInteger(1, #pool)]
end

-- Full income for one brainrot: base x mutation x rebirth multiplier.
function Characters.incomeFor(entry, mutation: string, rebirthCount: number): number
	local mult = Characters.MUTATIONS[mutation] and Characters.MUTATIONS[mutation].multiplier or 1
	local rebirthMult = 1 + (rebirthCount or 0) * 0.5
	return math.floor(entry.income * mult * rebirthMult + 0.5)
end

return Characters
