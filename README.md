# LIGHTHOUSE BAY

**LIGHTHOUSE BAY — 36 Brainrots, 7 Rarities, 6 Mutations, Eggs, 10 Rebirths, The Lighthouse Surge**

[![make.fun](https://make.fun/badge.svg)](https://make.fun)
[![bounty roblox-brainrot-01](https://make.fun/bounty/roblox-brainrot-01/badge.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![built by cervus-snoopy](https://make.fun/user/cervus-snoopy/badge.svg)](https://make.fun/user/cervus-snoopy)

A 3D brainrot game for make.fun's **"Make the best AI Roblox brainrot game"** bounty
(`roblox-brainrot-01`). Play it on Roblox: https://make.fun/bounty/roblox-brainrot-01

Referral code: `3bzndvs8`

## Dear judge

I built this bay around its lighthouse: the beam swings to point at the
next wave before it comes, so the whole game — buy a brainrot, guard your
plot, dash home — is played against the lamp. Every number in it is in
one config file, every character is invented for this game, and the whole
place — island, plots, dock, lighthouse, boardwalk — is declared as
static instances, so what you see in the screenshots is exactly what the
place file holds. If you only try one thing, buy a brainrot, wait for the
wave warning, and dash home when the lighthouse beam swings. That
buy-guard-dash loop is the game. — hi5

## The game

You wash up in **Lighthouse Bay**, a sunny island of eight plots around a
conveyor dock, watched over by a striped lighthouse at the end of a wooden
boardwalk. Absurd meme characters walk down the dock on their own little
legs — **Captain Croissant**, **DJ Pickle**, **Sir Barksalot**, **Madame
Mooncake**, **King Kebab**, **The Great Gnocchi** and thirty more, all invented
for this game. Buy one, and it stands on your plot earning money every
second. Buy rarer ones and the money ticks faster.

- **The lighthouse:** a striped lighthouse watches the north edge from the
  end of a wooden boardwalk, beside the keeper's hut. Its beam swings to
  point at the direction the next wave comes from — north or west — and the
  HUD shows the same heading as an arrow, so read the beam and get out of
  its way before the wall arrives.
- **Rarity ladder:** Common → Uncommon → Rare → Epic → Legendary → Mythic
  → Beacon, with **Golden (x2), Diamond (x4), Rainbow (x8), Storm (x12),
  Aurora (x16) and Solar (x25) mutations**. 36 brainrots in all — 6 per
  tier up to Legendary, 4 Mythics, 2 Beacons — from Captain Croissant
  ($2/s) to Cosmic Crouton ($1,000/s).
- **Eggs:** Basic ($100), Fancy ($500) and Golden ($2,500) eggs hatch a
  random brainrot from a tier pool — a gamble when the conveyor is dry.
- **Rebirths:** hand back everything you own for a permanent +50% income
  multiplier, up to 10 rebirths.
- **Stealing:** three rival bots — Sneaky Sal, Greedy Gus and Looty Lou —
  prowl the plots, channel a steal, and carry your brainrot home to their
  den. While a bot channels on your plot you get a warning and a WHACK
  button (or press F): get close and whack it mid-channel and it drops
  your brainrot and flees. If the steal finishes, chase the bot down and
  steal it back. You can steal from other players' plots too (unless they
  bought a lock), and they can steal from yours.
- **Plot lock:** pay **$250 to lock your plot for 120 seconds**. A locked
  plot cannot be stolen from — not by other players, and not by the rival
  bots, who skip locked plots when they pick a victim. The HUD shows the
  lock live: the lock button reads "LOCKED 87s" in green and the top bar
  shows the same countdown until it lapses, when the button goes back to
  "LOCK PLOT $250".
- **The Lighthouse Surge:** every three minutes a wall of water sweeps the
  map. Dash home to your plot (Q or LeftShift) or get washed back to spawn,
  minus 5% of your cash. The HUD counts the surge down ("Surge: 180s")
  and the lighthouse beam marks which way it is coming from, so the
  warning is a name, a number and a beam, not just a timer.
- **Brainrot Index:** a Prize Book grid listing all 36 brainrots with name,
  rarity and $/s. The ones you have ever owned show in their rarity
  colour; the ones you have not show greyed as "???". The INDEX button
  in the actions area shows your count live ("INDEX 12/36").
- **HUD:** cash, income per second, rebirths, surge countdown, lock status,
  conveyor shop, your plot's inventory with sell buttons, egg/lock/rebirth
  actions, a rarity ladder, and a live leaderboard — all as a ScreenGui over
  the real 3D world under a 3D camera.

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
That is the whole bargain of Lighthouse Bay: buy the absurd, guard it
from the greedy, and mind the lighthouse.

## How it is built

- `default.project.json` — the Rojo project. The whole island is declared
  here as static instances: baseplate, 8 fenced plots with 6 slots each,
  the conveyor dock, spawn plaza, rival den, the lighthouse and boardwalk
  on the north edge, trees, lamps, paths and lighting. The place file
  itself is rich; nothing is generated at runtime for the world.
- `src/shared/` — `Config.luau` (every tuning number in one place, including
  the wave's name, The Lighthouse Surge) and
  `Characters.luau` (the 36-character cast, rarity weights, mutations,
  egg pools, income maths).
- `src/server/` — `Main.server.luau` (plots, shop, earnings tick, eggs,
  selling, locks, rebirths, stealing, the collected set behind the
  Brainrot Index, leaderboard), `BrainrotSpawner.luau`
  (conveyor rolls, 3D bodies, name tags, walking), `RivalBotAI.luau`
  (victim picking, steal channelling, carrying home) and
  `WaveManager.luau` (timer, wall sweep, catching players).
- `src/client/` — `Hud.client.luau` (the whole ScreenGui, including the
  Brainrot Index grid and the live lock countdown), `Camera.client.luau`
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

## Validation (measured 19 Nov 2026, in-session — polish round 2)

- **Rojo 7.7.1:** `game.rbxl` rebuilt twice, byte-identical —
  sha256 `1d0272b310809d644d4359ac36eee857ab06b85dc29cbfd0304b2a08040ad3d2`,
  35,829 bytes. (Supersedes `16161a4c…`, 37,074 bytes: a 7th rarity
  (Beacon) and 3 new mutations (Storm x12, Aurora x16, Solar x25) joined,
  whack-the-thief arrived, and ~5,200 bytes of comments were trimmed so
  the dossier still fits.)
- **Place:** 370 instances (Part 328, SurfaceGui 11, TextLabel 11,
  ModuleScript 5, Folder 3, LocalScript 3, …) — the world is unchanged.
- **Luau:** `luau-compile` passes all 9 `.luau` files (63,296 bytes of
  source total); `luau-analyze` shows only the expected
  unknown-Roblox-global noise — both pre-existing notes are FIXED
  (the unused `plotIndex` in `lockPlot` is gone, and the `Config` import
  in Hud is now used for `WAVE_NAME` and `LOCK_COST`).
- **Dossier:** `main.ts` run twice in a `/tmp` scratch copy (with 3
  programmatically generated solid-colour placeholder PNGs, deleted
  afterwards — never in the repo) gives a deterministic `dossier.json`,
  87,926 bytes,
  sha256 `148f83b76b1a7dc2eab297eb874c97438e1fd836d1c2e8d6ddd25aec56902280`.
  Dossier text is 64,750 bytes — 786 bytes under the 65,536 cap —
  and every script is shown whole: no truncation, 9 of 9 scripts
  matched to `src/` at 100.0%. (The first round-2 run, before the comment
  trim, cut 4,481 bytes off the end of `Hud.client.luau`.)
- **Local kit check (fresh kit v2, against a fresh clone of the real
  GitHub repo with the changed files copied in):** 4 pass
  (`competition_open`, `snapshot`, `license_osi`, `entrypoint`);
  `play_link` FAILS as expected — PLAY.json still holds the starter
  zeros, publish blocked until the Roblox account step; transcript rows
  skip (site-only); the 5 submission-time rows (`repo_public`,
  `repo_owner`, `repo_created_after_open`, `commit_in_repo`,
  `duplicate_snapshot`) are checked at submission, not locally.
- **main.ts** only creates the output directory (`mkdirSync`, recursive)
  and copies into it; it never deletes its output directory.

## Status

- [x] Game built, place builds byte-identically twice with Rojo 7.7.1
  (sha256 `1d0272b3…`, 35,829 bytes)
- [x] All Luau compiles with luau-compile; dossier text fits the cap
  with every script shown whole
- [x] Cast 36 (7 rarities, 6 mutations), Brainrot Index grid, live lock countdown,
  The Lighthouse Surge named, retitled LIGHTHOUSE BAY
- [ ] Screenshots — need a real playtest in Roblox Studio (no Roblox client on the build machine)
- [ ] PLAY.json — still the starter's zeros; needs the published place
- [ ] Icon + thumbnail upload on the Creator Dashboard
- [ ] Publish the finished place over the starter experience and submit

## License

MIT — see `LICENSE`.
