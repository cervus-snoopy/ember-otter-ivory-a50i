-- BRAINROT BAY -- shared tuning knobs.
-- One table holds every number the server and the client both need to agree
-- on, so a balance change is a one-line edit instead of a hunt through code.
-- Nothing here touches the network or the DataStore: the demo loop is
-- session-based, and every value below is deliberately boring and static.

local Config = {}

-- The island the game is played on. Plots sit in two rows of four.
Config.MAP_SIZE = 220
Config.PLOT_COUNT = 8
Config.PLOTS_PER_ROW = 4
Config.PLOT_SPACING_X = 34
Config.PLOT_SPACING_Z = 46
Config.PLOT_WIDTH = 22
Config.PLOT_DEPTH = 16
Config.SLOTS_PER_PLOT = 6

-- Money. A brainrot pays its income every second while it stands on a plot.
Config.START_CASH = 150
Config.TICK_SECONDS = 1
Config.SELL_REFUND = 0.5 -- selling a brainrot returns half its buy price.

-- Conveyor: brainrots walk from the spawn dock to the shop window.
Config.CONVEYOR_LENGTH = 96
Config.WALK_SPEED = 7
Config.SPAWN_INTERVAL = 6 -- seconds between spawn rolls
Config.SHOP_WINDOW_SECONDS = 45 -- a brainrot waits this long before it wanders off

-- Stealing. A steal takes time, and the victim gets a warning first.
Config.STEAL_CHANNEL_SECONDS = 4
Config.STEAL_COOLDOWN_SECONDS = 20
Config.LOCK_COST = 250 -- one lock, one plot, lasts one wave cycle
Config.LOCK_DURATION = 120

-- Rival bots: how many prowl the bay, and how bold they are.
Config.RIVAL_COUNT = 3
Config.RIVAL_STEAL_DELAY = 25 -- seconds between a bot's steal attempts
Config.RIVAL_WALK_SPEED = 11

-- The wave: a wall of water sweeps the map on a timer.
Config.WAVE_INTERVAL = 180 -- seconds between waves
Config.WAVE_WARNING_SECONDS = 20
Config.WAVE_SWEEP_SECONDS = 25
Config.WAVE_SAFE_RADIUS = 14 -- standing this close to your plot is safe

-- The lighthouse on the north edge: its beam points at the direction the
-- next wave comes from while the warning window is open (see WaveManager).
Config.LIGHTHOUSE_PIVOT = { 0, 26, -104 } -- x, y, z of the lamp room
Config.LIGHTHOUSE_BEAM_OFFSET = 16 -- beam centre sits this far from the pivot

-- Rebirth: hand back everything, keep a permanent income multiplier.
Config.REBIRTH_MIN_CASH_EARNED = 25000
Config.REBIRTH_MULTIPLIER_PER = 0.5 -- +50% income per rebirth
Config.REBIRTH_MAX = 10

-- Eggs: a gamble box. The egg's tier decides which rarity pool it draws from.
Config.EGG_PRICES = { Basic = 100, Fancy = 500, Golden = 2500 }

-- Dash: a short burst of speed on a cooldown, bound with ContextActionService.
Config.DASH_SPEED = 52
Config.DASH_SECONDS = 0.6
Config.DASH_COOLDOWN = 5

return Config
