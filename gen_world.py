#!/usr/bin/env python3
"""BRAINROT BAY -- world generator.

Writes default.project.json for the Rojo project. The whole island is
declared here as static instances (baseplate, 8 fenced plots with 6 slots
each, conveyor dock, spawn plaza, rival den, trees, lamps, paths, lighting)
so the place file itself is rich: the dossier's Place block is built from
the place file, and runtime-generated instances do NOT appear in it.

Layout (must match src/server/Main.server.luau exactly):
  plots: x in {-51, -17, 17, 51}, z in {-23, 23}; slots at dx {-7, 0, 7},
  dz {-4, 4} inside each plot; conveyor dock along z = -58, x -48..48;
  spawn plaza at (0, 60); rival den at (0, 95); lighthouse at (0, -104)
  with a boardwalk along z = -86 and the keeper's hut at (-24, -104).
  The beam (LighthouseBeam) is swung by WaveManager to point at the
  direction the next wave comes from; its rest pose points north (-Z).

Run: python3 gen_world.py   (writes default.project.json next to itself)
Deterministic: same output every run, no randomness, no timestamps.
"""
import json

def c(r, g, b):
    """RGB 0-255 -> Rojo Color3 floats."""
    return [round(r / 255, 5), round(g / 255, 5), round(b / 255, 5)]

def part(name, pos, size, color, shape=None, material=None,
         transparency=None, can_collide=True):
    props = {
        "Anchored": True,
        "CanCollide": can_collide,
        "Color": color,
        "Position": list(pos),
        "Size": list(size),
    }
    if shape:
        props["Shape"] = shape
    if material:
        props["Material"] = material
    if transparency is not None:
        props["Transparency"] = transparency
    return {"$className": "Part", "$properties": props}

def sign(name, pos, text, color):
    """A sign post + panel + SurfaceGui + TextLabel, named `name`."""
    post = part(name + "Post", (pos[0], 2, pos[1]), (0.6, 4, 0.6), c(120, 85, 50))
    panel = part(name + "Panel", (pos[0], 4.5, pos[1]), (6, 2.4, 0.4), color)
    label = {
        "$className": "TextLabel",
        "$properties": {
            "Text": text, "TextSize": 28, "Font": "GothamBold",
            "TextColor3": c(255, 255, 255),
            "BackgroundTransparency": 1, "Size": {"UDim2": [[1, 0], [1, 0]]},
        },
    }
    gui = {"$className": "SurfaceGui", "$properties": {"Face": "Front"}, "Label": label}
    panel["Label"] = gui
    return [post, panel]

def tree(x, z, trunk_h=6):
    trunk = part("TreeTrunk", (x, trunk_h / 2, z), (1.2, trunk_h, 1.2), c(120, 85, 50))
    leaves = part("TreeTop", (x, trunk_h + 2, z), (5, 4, 5), c(60, 170, 70),
                  shape="Ball", material="SmoothPlastic")
    return [trunk, leaves]

def lamp(x, z):
    pole = part("LampPole", (x, 3, z), (0.5, 6, 0.5), c(60, 60, 70))
    bulb = part("LampBulb", (x, 6.2, z), (1.2, 1.2, 1.2), c(255, 240, 150),
                shape="Ball", material="Neon")
    return [pole, bulb]

def point_light(color, brightness=2, range_=40):
    """A PointLight child, for a lamp part that should actually glow."""
    return {"$className": "PointLight", "$properties": {
        "Color": color, "Brightness": brightness, "Range": range_}}

workspace = {}
count = [0]

def add(name, node):
    """Add one instance to Workspace under a unique name."""
    count[0] += 1
    workspace[name] = node

# --- ground -----------------------------------------------------------------
add("Baseplate", part("Baseplate", (0, -10, 0), (260, 20, 260), c(120, 200, 110),
                       material="Grass"))
# Sandy beach ring on the north and south edges.
for i, z in enumerate((-108, 108)):
    add(f"Beach{i}", part(f"Beach{i}", (0, 0.4, z), (260, 1, 28), c(240, 220, 160),
                          material="Sand"))
# A little pond on the west edge.
add("Pond", part("Pond", (-105, 0.5, 40), (26, 1, 30), c(60, 160, 230),
                  material="SmoothPlastic", transparency=0.25, can_collide=False))

# --- plots ------------------------------------------------------------------
PLOT_COLORS = [
    c(255, 220, 130), c(170, 220, 255), c(255, 180, 200), c(180, 255, 170),
    c(220, 190, 255), c(255, 200, 150), c(170, 255, 230), c(255, 255, 170),
]
plot_no = 0
for z in (-23, 23):
    for x in (-51, -17, 17, 51):
        plot_no += 1
        pad_color = PLOT_COLORS[plot_no - 1]
        add(f"Plot{plot_no}Pad", part(f"Plot{plot_no}Pad", (x, 0.5, z), (22, 1, 16),
                                       pad_color, material="SmoothPlastic"))
        # Fence: 4 corner posts + 4 rails around the pad.
        for sx, sz in ((-11, -8), (11, -8), (-11, 8), (11, 8)):
            add(f"Plot{plot_no}Post{sx}{sz}",
                part("FencePost", (x + sx, 1.5, z + sz), (0.8, 3, 0.8), c(255, 255, 255)))
        add(f"Plot{plot_no}RailN", part("FenceRail", (x, 2.5, z - 8), (22, 0.5, 0.5), c(255, 255, 255)))
        add(f"Plot{plot_no}RailS", part("FenceRail", (x, 2.5, z + 8), (22, 0.5, 0.5), c(255, 255, 255)))
        add(f"Plot{plot_no}RailW", part("FenceRail", (x - 11, 2.5, z), (0.5, 0.5, 16), c(255, 255, 255)))
        add(f"Plot{plot_no}RailE", part("FenceRail", (x + 11, 2.5, z), (0.5, 0.5, 16), c(255, 255, 255)))
        # 6 slot pads, matching the server's slot positions exactly.
        slot_no = 0
        for dz in (-4, 4):
            for dx in (-7, 0, 7):
                slot_no += 1
                add(f"Plot{plot_no}Slot{slot_no}",
                    part(f"Plot{plot_no}Slot{slot_no}", (x + dx, 1.1, z + dz),
                         (4.5, 0.3, 4.5), c(255, 255, 255), material="SmoothPlastic"))
        # Sign at the plot's north corner.
        for node in sign(f"Plot{plot_no}Sign", (x - 9, z - 11), f"PLOT {plot_no}", pad_color):
            add(f"Plot{plot_no}Sign{node['$properties']['Position'][1]:.0f}", node)

# --- conveyor dock ----------------------------------------------------------
add("ConveyorBelt", part("ConveyorBelt", (0, 0.5, -58), (104, 1, 6), c(80, 80, 95),
                         material="Metal"))
add("ConveyorRailN", part("ConveyorRailN", (0, 1.5, -61.5), (104, 1, 0.6), c(255, 215, 0)))
add("ConveyorRailS", part("ConveyorRailS", (0, 1.5, -54.5), (104, 1, 0.6), c(255, 215, 0)))
# Spawn arch where brainrots walk out.
add("ArchPostW", part("ArchPostW", (-52, 4, -58), (1.5, 8, 1.5), c(255, 120, 120)))
add("ArchPostE", part("ArchPostE", (52, 4, -58), (1.5, 8, 1.5), c(255, 120, 120)))
add("ArchTop", part("ArchTop", (0, 8.5, -58), (106, 1.5, 2), c(255, 120, 120)))
# 6 shop-window pads along the dock.
for i in range(6):
    wx = -40 + i * 16
    add(f"ShopWindow{i+1}", part(f"ShopWindow{i+1}", (wx, 1.1, -58), (8, 0.3, 5),
                                  c(255, 255, 255), material="Neon", transparency=0.5))
for node in sign("ConveyorSign", (-60, -66), "CONVEYOR - BRAINROTS THIS WAY", c(255, 215, 0)):
    add("ConveyorSign" + str(node["$properties"]["Position"][1]), node)

# --- spawn plaza ------------------------------------------------------------
add("SpawnPlaza", part("SpawnPlaza", (0, 0.5, 60), (24, 1, 20), c(200, 200, 210),
                       material="SmoothPlastic"))
add("SpawnMarker", part("SpawnMarker", (0, 1.1, 60), (6, 0.3, 6), c(120, 255, 120),
                        material="Neon", transparency=0.3))
for i, (lx, lz) in enumerate(((-11, 51), (11, 51), (-11, 69), (11, 69))):
    for j, node in enumerate(lamp(lx, lz)):
        add(f"SpawnLamp{i}Part{j}", node)

# --- rival den (south edge) -------------------------------------------------
add("RivalDenPad", part("RivalDenPad", (0, 0.5, 95), (30, 1, 14), c(90, 40, 40),
                        material="SmoothPlastic"))
for i, (cx, cz) in enumerate(((-10, 95), (0, 97), (10, 95))):
    add(f"DenCrate{i}", part(f"DenCrate{i}", (cx, 2, cz), (4, 4, 4), c(150, 110, 60),
                             material="Wood"))
for node in sign("DenSign", (-16, 88), "RIVAL DEN - KEEP OUT!", c(200, 60, 60)):
    add("DenSign" + str(node["$properties"]["Position"][1]), node)

# --- paths ------------------------------------------------------------------
for i, (px, pz, w, d) in enumerate((
        (0, 18, 6, 60), (-34, 0, 6, 40), (34, 0, 6, 40),
        (-68, 0, 6, 40), (68, 0, 6, 40), (0, -40, 6, 30))):
    add(f"Path{i}", part(f"Path{i}", (px, 0.6, pz), (w, 0.3, d), c(210, 200, 180),
                         material="Slate"))

# --- decoration: trees, rocks, lamps, clouds, fountain, beach set --------
tree_spots = [(-80, -80), (-80, -40), (-80, 0), (-80, 80), (80, -80), (80, -40),
              (80, 0), (80, 80), (-40, -85), (40, -85), (-95, 60), (95, 60),
              (-60, 85), (60, 85), (-100, -20), (100, -20), (-30, 100), (30, 100),
              (-95, -60), (95, -60)]
for i, (tx, tz) in enumerate(tree_spots):
    for j, node in enumerate(tree(tx, tz)):
        add(f"Tree{i}Part{j}", node)

rock_spots = [(-70, -70), (-70, 70), (70, -70), (70, 70), (-25, -75), (25, -75),
              (-90, 20), (90, 20), (-45, 40), (45, 40), (-15, 90), (15, 90),
              (-105, -85), (105, -85)]
for i, (rx, rz) in enumerate(rock_spots):
    add(f"Rock{i}", part(f"Rock{i}", (rx, 1, rz), (3, 2, 3), c(140, 140, 150),
                         shape="Ball", material="Slate"))

for i, (lx, lz) in enumerate(((-34, -40), (34, -40), (-34, 40), (34, 40),
                              (-68, -40), (68, -40))):
    for j, node in enumerate(lamp(lx, lz)):
        add(f"PathLamp{i}Part{j}", node)

# Clouds drifting high over the bay.
for i, (cx, cz) in enumerate(((-60, -40), (0, -70), (60, -30), (-40, 50), (50, 60), (0, 0))):
    add(f"Cloud{i}", part(f"Cloud{i}", (cx, 45, cz), (14, 4, 8), c(255, 255, 255),
                         shape="Ball", transparency=0.15, can_collide=False))

# Central fountain between the plot rows.
add("FountainBase", part("FountainBase", (0, 1, 0), (10, 2, 10), c(180, 180, 190),
                         shape="Cylinder", material="Slate"))
add("FountainWater", part("FountainWater", (0, 2, 0), (8, 1, 8), c(60, 160, 230),
                          shape="Cylinder", transparency=0.3, can_collide=False))
add("FountainTop", part("FountainTop", (0, 3.5, 0), (2, 3, 2), c(220, 220, 230),
                        shape="Ball"))

# South beach, redesigned: three umbrellas in different colours, towels
# laid out beside them, and two sand buckets.
for i, (ux, uz, top_color) in enumerate((
        (-70, 101, c(255, 200, 60)), (-10, 103, c(90, 180, 255)),
        (50, 101, c(255, 120, 160)))):
    add(f"BeachUmbrella{i}Pole", part(f"BeachUmbrella{i}Pole", (ux, 3, uz), (0.5, 6, 0.5),
                                      c(255, 255, 255)))
    add(f"BeachUmbrella{i}Top", part(f"BeachUmbrella{i}Top", (ux, 6.5, uz), (8, 1, 8),
                                     top_color, shape="Ball", material="SmoothPlastic"))
for i, (tx, tz, towel_color) in enumerate((
        (-66, 105, c(255, 220, 90)), (-6, 107, c(120, 220, 255)),
        (54, 105, c(255, 150, 200)))):
    add(f"BeachTowel{i}", part(f"BeachTowel{i}", (tx, 1, tz), (3, 0.2, 6), towel_color,
                               material="SmoothPlastic"))
for i, (bx, bz, bucket_color) in enumerate((
        (-62, 107, c(220, 60, 60)), (46, 107, c(90, 160, 255)))):
    add(f"SandBucket{i}", part(f"SandBucket{i}", (bx, 1.9, bz), (2, 2, 2), bucket_color,
                               material="SmoothPlastic"))

# Low border walls so the island reads as an island.
for i, (wx, wz, w, d) in enumerate(((0, -118, 260, 2), (0, 118, 260, 2),
                                    (-118, 0, 2, 260), (118, 0, 2, 260))):
    add(f"Border{i}", part(f"Border{i}", (wx, 2, wz), (w, 4, d), c(200, 170, 120),
                           material="Wood"))

# --- lighthouse + boardwalk (north edge) ------------------------------------
# A striped lighthouse on the north sand, a wooden boardwalk along the
# north edge with a spur to the lighthouse pad, and the keeper's hut.
# Gameplay: the beam (LighthouseBeam) is swung by WaveManager to point at
# the direction the next wave comes from; see src/server/WaveManager.luau.
add("LighthousePad", part("LighthousePad", (0, 0.5, -104), (16, 1, 16), c(170, 170, 180),
                          material="SmoothPlastic"))
# Tower: four stacked tiers, white / red / white / red.
for i, (ty, ts, tier_color) in enumerate((
        (4.5, 7, c(245, 245, 240)), (11, 6, c(220, 60, 60)),
        (16.5, 5, c(245, 245, 240)), (21, 4, c(220, 60, 60)))):
    add(f"LighthouseTier{i}", part(f"LighthouseTier{i}", (0, ty, -104), (ts, ts, ts),
                                   tier_color))
add("LighthouseGallery", part("LighthouseGallery", (0, 23.5, -104), (6, 1, 6), c(60, 60, 70)))
lamp_glass = part("LighthouseLamp", (0, 26, -104), (4, 3, 4), c(255, 240, 150),
                  material="Neon", transparency=0.35, can_collide=False)
lamp_glass["LampLight"] = point_light(c(255, 240, 150))
add("LighthouseLamp", lamp_glass)
add("LighthouseRoof", part("LighthouseRoof", (0, 28, -104), (5, 1, 5), c(60, 60, 70)))
add("LighthouseDome", part("LighthouseDome", (0, 29, -104), (3, 2, 3), c(220, 60, 60),
                           shape="Ball"))
# The beam: a long thin neon bar pointing north (-Z) at rest. WaveManager
# swings it around the lamp-room pivot (0, 26, -104) by CFrame.
add("LighthouseBeam", part("LighthouseBeam", (0, 26, -120), (2, 0.8, 28), c(255, 240, 150),
                           material="Neon", transparency=0.4, can_collide=False))

# Keeper's hut, west of the lighthouse on the north sand.
add("HutFloor", part("HutFloor", (-24, 0.5, -104), (10, 1, 8), c(150, 110, 60),
                     material="Wood"))
add("HutWallN", part("HutWallN", (-24, 3, -108), (10, 5, 0.6), c(240, 220, 180)))
add("HutWallS", part("HutWallS", (-24, 3, -100), (10, 5, 0.6), c(240, 220, 180)))
add("HutWallW", part("HutWallW", (-29, 3, -104), (0.6, 5, 8), c(240, 220, 180)))
add("HutWallE", part("HutWallE", (-19, 3, -104), (0.6, 5, 8), c(240, 220, 180)))
add("HutRoof", part("HutRoof", (-24, 6, -104), (12, 1, 10), c(200, 60, 60)))
add("HutDoor", part("HutDoor", (-24, 2.5, -99.6), (2, 4, 0.4), c(120, 85, 50)))
add("HutWindow", part("HutWindow", (-24, 3.5, -108.4), (3, 2, 0.3), c(150, 210, 255),
                      material="SmoothPlastic", transparency=0.4, can_collide=False))

# Boardwalk: planks along the north edge, with rails on both sides.
for i, bx in enumerate(range(-70, 71, 10)):
    plank_color = c(170, 130, 80) if i % 2 == 0 else c(150, 110, 60)
    add(f"BoardwalkPlank{i}", part(f"BoardwalkPlank{i}", (bx, 0.8, -86), (9, 0.6, 5),
                                   plank_color, material="Wood"))
for i, px in enumerate((-70, -50, -30, -10, 10, 30, 50, 70)):
    for j, pz in enumerate((-88.8, -83.2)):
        add(f"BoardwalkPost{i}Side{j}", part(f"BoardwalkPost{i}Side{j}", (px, 2, pz),
                                             (0.6, 2.5, 0.6), c(120, 85, 50)))
add("BoardwalkRailN", part("BoardwalkRailN", (0, 3, -88.8), (142, 0.4, 0.4), c(120, 85, 50)))
add("BoardwalkRailS", part("BoardwalkRailS", (0, 3, -83.2), (142, 0.4, 0.4), c(120, 85, 50)))
# Spur from the boardwalk to the lighthouse pad.
for i, sz in enumerate((-90, -94, -98)):
    add(f"BoardwalkSpur{i}", part(f"BoardwalkSpur{i}", (0, 0.8, sz), (5, 0.6, 4),
                                  c(170, 130, 80), material="Wood"))
for node in sign("LighthouseSign", (8, -90), "LIGHTHOUSE - FOLLOW THE BEAM", c(255, 215, 0)):
    add("LighthouseSign" + str(node["$properties"]["Position"][1]), node)
for i, (lx, lz) in enumerate(((-72, -86), (72, -86))):
    for j, node in enumerate(lamp(lx, lz)):
        add(f"BoardwalkLamp{i}Part{j}", node)
for i, (rx, rz) in enumerate(((-12, -113), (11, -112))):
    add(f"LighthouseRock{i}", part(f"LighthouseRock{i}", (rx, 1, rz), (3, 2, 3),
                                   c(140, 140, 150), shape="Ball", material="Slate"))

project = {
    "name": "brainrot-bay",
    "tree": {
        "$className": "DataModel",
        "ReplicatedStorage": {
            "Shared": {"$path": "src/shared"},
        },
        "ServerScriptService": {
            "Server": {"$path": "src/server"},
        },
        "StarterPlayer": {
            "StarterPlayerScripts": {
                "Client": {"$path": "src/client"},
            },
        },
        "Workspace": {
            "$properties": {"FilteringEnabled": True},
            **workspace,
        },
        "Lighting": {
            "$properties": {
                "Ambient": [0.3, 0.3, 0.35],
                "Brightness": 2,
                "GlobalShadows": True,
                "Outlines": False,
                "Technology": "Voxel",
                "ClockTime": 10,
                "GeographicLatitude": 20,
            },
        },
        "SoundService": {
            "$properties": {"RespectFilteringEnabled": True},
        },
    },
}

with open("default.project.json", "w") as f:
    json.dump(project, f, indent=2)
    f.write("\n")

print(f"wrote default.project.json with {count[0]} static Workspace instances")
