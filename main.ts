// BRAINROT BAY -- entry program for make.fun roblox-brainrot-01.
//
// What it does, in order:
//   1. Reads the finished game out of this repository: the Rojo-built
//      place (game.rbxl), the Luau sources (src/), the screenshots and the
//      play link (PLAY.json).
//   2. Copies them into the grader's output directory, leaving out every
//      name that starts with a dot. A stray .gitkeep or .DS_Store anywhere
//      under /output fails the whole entry, so the copy is filtered hard.
//   3. Writes /output/dossier.json with the kit's vendored library
//      (vendor/makefun-roblox.ts, unchanged): the dossier is the judge's
//      view of the game, and the gate re-derives it byte for byte.
//
// Node 22+, standard library only -- nothing is installed before this runs.
// Run it the way the grader does, with out/ standing in for /output:
//
//     mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
//
// The entry is only valid once PLAY.json names a real published place and
// screenshots/ holds real captures of this game running in Studio. Both are
// TODO until the Roblox account + publish step lands (see HANDOFF.md).
// The dossier's Place block now includes the lighthouse and boardwalk on
// the north edge (see gen_world.py).

import { copyFileSync, cpSync, existsSync, mkdirSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

// The directory this file lives in is the repository root.
const repoRoot = fileURLToPath(new URL('.', import.meta.url));

// The grader gives us /output; outside the grader, MAKEFUN_OUTPUT_DIR
// stands in for it (see the usage line at the top of this file).
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// --- small helpers ---------------------------------------------------------

// A name is safe for /output when it starts with a letter, a digit or _
// and holds only letters, digits, . _ and -. Anything starting with a dot
// is refused outright by the grader, so it is filtered at the copy.
function isSafeName(name: string): boolean {
  return /^[A-Za-z0-9_][A-Za-z0-9._-]*$/.test(name);
}

// cpSync's filter: drop every file or directory whose name starts with a
// dot (.gitkeep, .DS_Store, .git) at any depth.
function notDotted(path: string): boolean {
  return !basename(path).startsWith('.');
}

// Fail loudly, before writing a dossier, if a required input is missing.
function requireFile(path: string): void {
  if (!existsSync(path)) {
    throw new Error(`BRAINROT BAY: missing required file: ${path}`);
  }
}

// Count the files under a directory, for the run summary at the end.
function countFiles(dir: string): number {
  let total = 0;
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    total += statSync(full).isDirectory() ? countFiles(full) : 1;
  }
  return total;
}

// --- copy the entry ---------------------------------------------------------

mkdirSync(outputDir, { recursive: true });

requireFile(join(repoRoot, 'game.rbxl'));
requireFile(join(repoRoot, 'PLAY.json'));
requireFile(join(repoRoot, 'src'));

copyFileSync(join(repoRoot, 'game.rbxl'), join(outputDir, 'game.rbxl'));
copyFileSync(join(repoRoot, 'PLAY.json'), join(outputDir, 'PLAY.json'));
cpSync(join(repoRoot, 'src'), join(outputDir, 'src'), { recursive: true, filter: notDotted });

mkdirSync(join(outputDir, 'screenshots'), { recursive: true });
if (existsSync(join(repoRoot, 'screenshots'))) {
  cpSync(join(repoRoot, 'screenshots'), join(outputDir, 'screenshots'), { recursive: true, filter: notDotted });
}

// Belt and braces: after the copy, walk /output and refuse to continue if
// any name in it is unsafe. Better to fail here, in the open, than to hand
// the gate an entry it must refuse.
function checkNames(dir: string): void {
  for (const entry of readdirSync(dir)) {
    if (!isSafeName(entry)) {
      throw new Error(`BRAINROT BAY: unsafe name under /output: ${join(dir, entry)}`);
    }
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) checkNames(full);
  }
}
checkNames(outputDir);

// --- write the dossier ------------------------------------------------------

// The caps are the scorer's own (reference/gate.json): text_max_bytes is
// the only one that shapes the dossier's bytes; the rest refuse an entry
// the scorer would refuse anyway (too many screenshots, one over 256 KiB,
// a place past 500,000 instances, scripts past 8 MiB of source or past
// 1,048,576 path characters in all).
const dossier = buildDossier(outputDir, {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
});
writeFileSync(join(outputDir, 'dossier.json'), dossier);

// --- run summary ------------------------------------------------------------

console.log('BRAINROT BAY handed in:');
console.log(`  place:       game.rbxl (${statSync(join(outputDir, 'game.rbxl')).size} bytes)`);
console.log(`  source files: ${countFiles(join(outputDir, 'src'))} under src/`);
console.log(`  screenshots:  ${countFiles(join(outputDir, 'screenshots'))} under screenshots/`);
console.log(`  dossier:      dossier.json (${dossier.length} bytes)`);
