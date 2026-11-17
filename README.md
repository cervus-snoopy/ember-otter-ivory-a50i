# BRAINROT BAY

[![make.fun](https://make.fun/badge.svg)](https://make.fun)
[![bounty roblox-brainrot-01](https://make.fun/bounty/roblox-brainrot-01/badge.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![built by cervus-snoopy](https://make.fun/user/cervus-snoopy/badge.svg)](https://make.fun/user/cervus-snoopy)

A 3D brainrot game for make.fun's **"Make the best AI Roblox brainrot game"** bounty
(`roblox-brainrot-01`). Play it on Roblox: https://make.fun/bounty/roblox-brainrot-01

Referral code: `3bzndvs8`

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
  of your cash.
- **The lighthouse:** a striped lighthouse watches the north edge from the
  end of a wooden boardwalk, beside the keeper's hut. Its beam swings to
  point at the direction the next wave comes from — north or west — and the
  HUD shows the same heading as an arrow, so read the beam and get out of
  its way before the wall arrives.
- **HUD:** cash, income per second, rebirths, wave countdown, conveyor
  shop, your plot's inventory with sell buttons, egg/lock/rebirth actions,
  a rarity ladder, and a live leaderboard — all as a ScreenGui over the
  real 3D world under a 3D camera.

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

## Status

- [x] Game built, place builds byte-identically twice with Rojo 7.7.1
- [x] All Luau compiles with luau-compile
- [ ] Screenshots — need a real playtest in Roblox Studio (no Roblox client on the build machine)
- [ ] PLAY.json — still the starter's zeros; needs the published place
- [ ] Icon + thumbnail upload on the Creator Dashboard
- [ ] Publish the finished place over the starter experience and submit

## License

MIT — see `LICENSE`.
