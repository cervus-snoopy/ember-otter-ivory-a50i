-- LIGHTHOUSE BAY
local Characters = {}
Characters.RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Beacon" }
Characters.RARITY_ORDER = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
	Beacon = 7,
}
Characters.RARITY_COLORS = {
	Common = { 200, 200, 200 },
	Uncommon = { 120, 220, 120 },
	Rare = { 90, 160, 255 },
	Epic = { 190, 110, 255 },
	Legendary = { 255, 190, 40 },
	Mythic = { 255, 70, 160 },
	Beacon = { 255, 255, 255 },
}
Characters.RARITY_WEIGHTS = {
	Common = 42,
	Uncommon = 26,
	Rare = 16,
	Epic = 9,
	Legendary = 5,
	Mythic = 2,
	Beacon = 1,
}
Characters.MUTATIONS = {
	None = { multiplier = 1, color = nil, chance = 0 },
	Golden = { multiplier = 2, color = { 255, 215, 0 }, chance = 12 },
	Diamond = { multiplier = 4, color = { 170, 230, 255 }, chance = 4 },
	Rainbow = { multiplier = 8, color = { 255, 120, 220 }, chance = 1 },
	Storm = { multiplier = 12, color = { 100, 150, 255 }, chance = 0.5 },
	Aurora = { multiplier = 16, color = { 90, 255, 190 }, chance = 0.25 },
	Solar = { multiplier = 25, color = { 255, 120, 40 }, chance = 0.1 },
}
Characters.CAST = {
	{ name = "Captain Croissant", rarity = "Common", income = 2, price = 50, color = { 232, 190, 110 }, joke = "Sails the butter seas. Flakes everywhere." },
	{ name = "Sir Barksalot", rarity = "Common", income = 3, price = 75, color = { 170, 120, 70 }, joke = "Knighted for barking at the mailman." },
	{ name = "DJ Pickle", rarity = "Common", income = 4, price = 100, color = { 90, 180, 80 }, joke = "Drops beats. Brine not included." },
	{ name = "Baron Bagel", rarity = "Common", income = 5, price = 125, color = { 200, 160, 90 }, joke = "Holes in his plans. Fills them with cream cheese." },
	{ name = "Captain Ketchup", rarity = "Common", income = 6, price = 150, color = { 200, 50, 40 }, joke = "Squeezes into every battle. Slowly." },
	{ name = "Sir Soggy Toast", rarity = "Common", income = 7, price = 175, color = { 210, 170, 120 }, joke = "Knighted twice. Dropped both times." },
	{ name = "Madame Mooncake", rarity = "Uncommon", income = 8, price = 220, color = { 240, 220, 160 }, joke = "Predicts your fortune. It is cake." },
	{ name = "Lady Lemonade", rarity = "Uncommon", income = 10, price = 270, color = { 240, 230, 110 }, joke = "Squeezed dockside. Still owes the barge fare." },
	{ name = "Professor Pancake", rarity = "Uncommon", income = 11, price = 300, color = { 220, 170, 90 }, joke = "Flips first, asks questions never." },
	{ name = "Duke Dumpling", rarity = "Uncommon", income = 13, price = 340, color = { 230, 210, 170 }, joke = "Steamed aboard the barge. Never got off." },
	{ name = "Baron Broccoli", rarity = "Uncommon", income = 14, price = 380, color = { 60, 160, 70 }, joke = "Rules the veggie court with an iron floret." },
	{ name = "Mayor Meatball", rarity = "Uncommon", income = 16, price = 420, color = { 170, 90, 50 }, joke = "Rolled off the wrecked barge. Never left." },
	{ name = "Queen Quokka", rarity = "Rare", income = 25, price = 700, color = { 200, 150, 100 }, joke = "Smiles at the lighthouse. It never blinks." },
	{ name = "Count Cracker", rarity = "Rare", income = 28, price = 780, color = { 220, 190, 120 }, joke = "Cracked on the reef. Still holds the crumbs." },
	{ name = "Lord Llama Latte", rarity = "Rare", income = 32, price = 900, color = { 230, 210, 190 }, joke = "Spits foam art at his enemies." },
	{ name = "Princess Pretzel", rarity = "Rare", income = 36, price = 1000, color = { 190, 130, 70 }, joke = "Twists every plot. Salty about it." },
	{ name = "Duchess Donut", rarity = "Rare", income = 40, price = 1100, color = { 255, 170, 200 }, joke = "Sprinkles are her royal guard." },
	{ name = "Sheriff Salsa", rarity = "Rare", income = 44, price = 1200, color = { 200, 60, 40 }, joke = "Keeps the boardwalk peaceful. Spicily." },
	{ name = "Emperor Eggplant", rarity = "Epic", income = 70, price = 2000, color = { 120, 60, 160 }, joke = "Claims the reef. The lighthouse disagrees." },
	{ name = "Wizard Wasabi", rarity = "Epic", income = 80, price = 2300, color = { 90, 180, 90 }, joke = "One sniff clears the whole boardwalk." },
	{ name = "Wizard Waffle", rarity = "Epic", income = 90, price = 2600, color = { 210, 160, 80 }, joke = "Casts Syrup Storm. Sticky situation." },
	{ name = "Queen Quiche", rarity = "Epic", income = 100, price = 2900, color = { 240, 210, 140 }, joke = "Her crust is law. Her filling, legend." },
	{ name = "General Guacamole", rarity = "Epic", income = 110, price = 3200, color = { 120, 190, 60 }, joke = "Charges extra. The barge manifest says so." },
	{ name = "Baroness Boba", rarity = "Epic", income = 120, price = 3500, color = { 200, 150, 90 }, joke = "Chews pearls from the wreck. Sells them back." },
	{ name = "King Kebab", rarity = "Legendary", income = 180, price = 5500, color = { 190, 120, 60 }, joke = "Skewered three kingdoms before lunch." },
	{ name = "General Garlic", rarity = "Legendary", income = 200, price = 6200, color = { 230, 230, 200 }, joke = "Wards off the Surge. Garlic versus the sea." },
	{ name = "Countess Cupcake", rarity = "Legendary", income = 220, price = 6800, color = { 255, 150, 180 }, joke = "Her frosting hides a secret army." },
	{ name = "Empress Espresso", rarity = "Legendary", income = 240, price = 7400, color = { 90, 60, 40 }, joke = "One sip and the kingdom wakes up." },
	{ name = "Admiral Avocado", rarity = "Legendary", income = 260, price = 8000, color = { 80, 160, 80 }, joke = "Commands the toast fleet. Ripe for battle." },
	{ name = "Professor Pickle", rarity = "Legendary", income = 300, price = 9500, color = { 110, 200, 90 }, joke = "Tenured in brine. Publishes in pickle." },
	{ name = "Sir Spaghetti", rarity = "Mythic", income = 450, price = 15000, color = { 240, 210, 130 }, joke = "A noodle knight. Al dente, never defeated." },
	{ name = "Sultan Saffron", rarity = "Mythic", income = 500, price = 16500, color = { 220, 160, 40 }, joke = "Bought the reef with a single pinch." },
	{ name = "The Great Gnocchi", rarity = "Mythic", income = 550, price = 18000, color = { 220, 200, 170 }, joke = "Ancient. Dumpling-shaped. Unstoppable." },
	{ name = "The Phantom Fondue", rarity = "Mythic", income = 650, price = 21000, color = { 240, 220, 120 }, joke = "Melts away. Returns for the cheese." },
	{ name = "Moonlight Muffin", rarity = "Beacon", income = 850, price = 30000, color = { 180, 160, 255 }, joke = "Bakes by lamplight. Bram never tastes it." },
	{ name = "Cosmic Crouton", rarity = "Beacon", income = 1000, price = 35000, color = { 255, 200, 90 }, joke = "Fell from the stars. Still crunchy." },
}
Characters.EGG_POOLS = {
	Basic = { "Common", "Common", "Uncommon", "Uncommon", "Rare" },
	Fancy = { "Uncommon", "Rare", "Rare", "Epic", "Epic", "Legendary" },
	Golden = { "Rare", "Epic", "Legendary", "Legendary", "Mythic", "Beacon" },
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
function Characters.rollMutation(rng: Random): string
	local roll = rng:NextNumber(0, 100)
	if roll <= 0.1 then
		return "Solar"
	elseif roll <= 0.35 then
		return "Aurora"
	elseif roll <= 0.85 then
		return "Storm"
	elseif roll <= 1.85 then
		return "Rainbow"
	elseif roll <= 5.85 then
		return "Diamond"
	elseif roll <= 17.85 then
		return "Golden"
	end
	return "None"
end
function Characters.randomOfRarity(rarity: string, rng: Random)
	local pool = Characters.ofRarity(rarity)
	if #pool == 0 then
		return nil
	end
	return pool[rng:NextInteger(1, #pool)]
end
function Characters.incomeFor(entry, mutation: string, rebirthCount: number): number
	local mult = Characters.MUTATIONS[mutation] and Characters.MUTATIONS[mutation].multiplier or 1
	local rebirthMult = 1 + (rebirthCount or 0) * 0.5
	return math.floor(entry.income * mult * rebirthMult + 0.5)
end
return Characters
