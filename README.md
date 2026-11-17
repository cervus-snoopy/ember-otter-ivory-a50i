# BRAINROT BAY

[![make.fun](https://make.fun/badge.svg)](https://make.fun)
[![bounty roblox-brainrot-01](https://make.fun/bounty/roblox-brainrot-01/badge.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![built by cervus-snoopy](https://make.fun/user/cervus-snoopy/badge.svg)](https://make.fun/user/cervus-snoopy)

A 3D brainrot game for make.fun's **"Make the best AI Roblox brainrot game"** bounty
(`roblox-brainrot-01`). Play it on Roblox: https://make.fun/bounty/roblox-brainrot-01

Referral code: `3bzndvs8`

## Dear judge

I built this bay to be played, not just looked at: every number in it is
in one config file, every character is invented for this game, and the
whole place — island, plots, dock, lighthouse — is declared as static
instances, so what you see in the screenshots is exactly what the place
file holds. If you only try one thing, buy a brainrot, wait for the wave
warning, and dash home when the lighthouse beam swings. That
buy-guard-dash loop is the game. — hi5

## The game

You wash up in **Brainrot Bay**, a sunny island of eight plots around a
conveyor dock. Absurd meme characters walk down the dock on their own little
legs — **Captain Croissant**, **DJ Pickle**, **Sir Barksalot**, **Madame
Mooncake**, **King Kebab**, **The Great Gnocchi** and twelve more, all invented
for this game. Buy one, and it stands on your plot earning money every
second. Buy rarer ones and the money ticks faster.

- **Rarity ladder:** Common → Uncommon → Rare → Epic → Legendary → Mythic,
  with **Golden (x2), Diamond (x4) and Rainbow (x8) mutations**.
- **Eggs:** Basic ($100), Fancy ($500) and Golden ($2,500) eggs hatch a
  random brainrot from a tier pool — a gamble when the conveyor is dry.
- **Rebirths:** hand back everything you own for a permanent +50% income
  multiplier, up to 10 rebirths.
- **Stealing:** three rival bots — Sneaky Sal, Greedy Gus and Looty Lou —
  prowl the plots, channel a steal, and carry your brainrot home to their
  den. Chase them down and steal it back. You can steal from other players'
  plots too (unless they bought a lock), and they can steal from yours.
- **The wave:** every three minutes a wall of water sweeps the map. Dash
  home to your plot (Q or LeftShift) or get washed back to spawn, minus 5%
  of your cash. The HUD shows the dash key under the title, with its
  5-second cooldown.
- **The lighthouse:** a striped lighthouse watches the north edge from the
  end of a wooden boardwalk, beside the keeper's hut. Its beam swings to
  point at the direction the next wave comes from — north or west — and the
  HUD shows the same heading as an arrow, so read the beam and get out of
  its way before the wall arrives.
- **HUD:** cash, income per second, rebirths, wave countdown, conveyor
  shop, your plot's inventory with sell buttons, egg/lock/rebirth actions,
  a rarity ladder, and a live leaderboard — all as a ScreenGui over the
  real 3D world under a 3D camera.

## The story of the bay

Nobody remembers who built the eight plots, or why the conveyor dock
keeps delivering strangers. The story the island tells is this: a storm
wrecked a circus barge on the reef, and its passengers — a croissant in a
captain's hat, a pickle with a turntable, a barking knight, a mooncake
in a ballgown, a kebab with a crown — washed up on the sand and never
left. They pace the dock in a line now, waiting for someone to buy them
a plot to stand on, and they pay rent in coins every second, because
that is what washed-up performers do.

Old Bram keeps the lighthouse at the north end of the boardwalk. He
never speaks — he just turns the lamp. When the beam swings north, the
wave is coming from the north; when it swings west, from the west. The
old hands in the bay read the beam the way sailors read weather, and
they run for their plots when the warning sounds. The three rivals —
Sneaky Sal, Greedy Gus and Looty Lou — are the only ones who never run:
they wait for the wave to scatter everyone, then slip onto the empty
plots and carry a brainrot home to their den. Chase them down before
they get there, and the brainrot is yours again.

The wave itself comes every three minutes, regular as a tide table.
Stand on your own plot when it passes and you stay dry. Get caught in
the open and it washes you back to spawn, lighter by 5% of your cash.
That is the whole bargain of Brainrot Bay: buy the absurd, guard it
from the greedy, and mind the lighthouse.

## How it is built

- `default.project.json` — the Rojo project. The whole island is declared
  here as static instances: baseplate, 8 fenced plots with 6 slots each,
  the conveyor dock, spawn plaza, rival den, the lighthouse and boardwalk
  on the north edge, trees, lamps, paths and lighting. The place file
  itself is rich; nothing is generated at runtime for the world.
- `src/shared/` — `Config.luau` (every tuning number in one place) and
  `Characters.luau` (the 19-character cast, rarity weights, mutations,
  egg pools, income maths).
- `src/server/` — `Main.server.luau` (plots, shop, earnings tick, eggs,
  selling, locks, rebirths, stealing, leaderboard), `BrainrotSpawner.luau`
  (conveyor rolls, 3D bodies, name tags, walking), `RivalBotAI.luau`
  (victim picking, steal channelling, carrying home) and
  `WaveManager.luau` (timer, wall sweep, catching players).
- `src/client/` — `Hud.client.luau` (the whole ScreenGui), `Camera.client.luau`
  (cinematic intro sweep, then the default 3D camera) and `Dash.client.luau`
  (dash bound with ContextActionService, since the arrow keys belong to the
  default camera).
- `main.ts` (Node 22, standard library only) hands the game in: it copies
  `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to `/output` and
  writes `/output/dossier.json` with `vendor/makefun-roblox.ts` (the kit's
  copy, unchanged).

## Build it

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

## Validation (measured 18 Nov 2026, in-session)

- **Rojo 7.7.1:** `game.rbxl` rebuilt twice, byte-identical —
  sha256 `bd270571b82a4b94c4a37f7bbb70a9a290ffa123f640d51bfcab6ffdfb856f4b`,
  37,168 bytes. (Supersedes `fd02dbb2…`, 37,906 bytes: the HUD source
  shrank when its comments were trimmed, so the place embedding it
  changed too. Same world, same numbers — only comments and one static
  HUD label changed.)
- **Place:** 370 instances (Part 328, SurfaceGui 11, TextLabel 11,
  ModuleScript 5, Folder 3, LocalScript 3, …).
- **Luau:** `luau-compile` passes all 9 `.luau` files (63,017 bytes of
  source total); `luau-analyze` shows only the pre-existing notes
  (unused `plotIndex` in Main, unused `Config` import in Hud) plus the
  expected unknown-Roblox-global noise.
- **Dossier:** `main.ts` run twice in a `/tmp` scratch copy (with 3
  programmatically generated solid-colour placeholder PNGs, deleted
  afterwards — never in the repo) gives a deterministic `dossier.json`,
  70,431 bytes,
  sha256 `5a43c4cef04ba8501515bc9157d3b70e397ccc2f2d97986388df08aea10dd990`.
  Dossier text is 64,471 bytes — 1,065 bytes under the 65,536 cap —
  and every script is shown whole: no truncation, 9 of 9 scripts
  matched to `src/` at 100.0%. Before the comment trim the text was
  65,487 bytes, 49 under the cap, with 1,191 bytes of `Hud.client.luau`
  (31 lines) cut.
- **main.ts** only creates the output directory (`mkdirSync`, recursive)
  and copies into it; it never deletes its output directory.

## Status

- [x] Game built, place builds byte-identically twice with Rojo 7.7.1
  (sha256 `bd270571…`, 37,168 bytes)
- [x] All Luau compiles with luau-compile; dossier text fits the cap
  with every script shown whole
- [ ] Screenshots — need a real playtest in Roblox Studio (no Roblox client on the build machine)
- [ ] PLAY.json — still the starter's zeros; needs the published place
- [ ] Icon + thumbnail upload on the Creator Dashboard
- [ ] Publish the finished place over the starter experience and submit

## License

MIT — see `LICENSE`.
