-- BRAINROT BAY -- WaveManager (server ModuleScript).
-- The second threat: on a timer, a wall of water sweeps the map. A player
-- caught outside their plot's safe radius when the wall passes is knocked
-- back to spawn and drops a little cash. The wave is a big translucent
-- blue wall part that moves across the bay; the HUD counts it down and
-- flashes a warning while it approaches.
--
-- The lighthouse reads the wave before it comes: at the start of the
-- warning window the manager picks the wave's approach axis -- north to
-- south along Z, or west to east along X -- and swings the lighthouse
-- beam to point at it, recording the heading in WaveManager.beamAngleDeg
-- and in the BeamAngle NumberValue in ReplicatedStorage, so the HUD can
-- show a wave-direction arrow. The wall then sweeps along the picked axis.
--
-- The manager owns the timer and the wall part, and calls back into the
-- main server script for the consequences (who is caught, what they lose).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)

local WaveManager = {}

WaveManager.nextWaveAt = os.clock() + Config.WAVE_INTERVAL
WaveManager.waveActive = false
WaveManager.waveAxis = "Z" -- "Z" sweeps north -> south, "X" sweeps west -> east
WaveManager.beamAngleDeg = 0 -- compass heading the beam points: 0 N, 90 E, 180 S, 270 W

local rng = Random.new()

-- A NumberValue in ReplicatedStorage so the HUD can read the beam heading
-- without a remote round-trip. Main also sends it in the WaveCountdown
-- broadcast; this value is the live one the beam itself writes.
local beamValue = Instance.new("NumberValue")
beamValue.Name = "BeamAngle"
beamValue.Value = 0
beamValue.Parent = ReplicatedStorage

local wall: Part? = nil

-- Build the wall part once, parked out of sight above the map.
function WaveManager.buildWall(parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = "WaveWall"
	part.Size = Vector3.new(Config.MAP_SIZE, 40, 4)
	part.Position = Vector3.new(0, 20, -Config.MAP_SIZE)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.45
	part.Color = Color3.fromRGB(40, 140, 255)
	part.Material = Enum.Material.Neon
	part.Parent = parent
	wall = part
	return part
end

-- Seconds until the next wave starts. The HUD polls this through a remote.
function WaveManager.secondsUntilWave(): number
	return math.max(0, WaveManager.nextWaveAt - os.clock())
end

-- Is the warning window open? (The last 20 seconds before the wave.)
function WaveManager.isWarning(): boolean
	return WaveManager.secondsUntilWave() <= Config.WAVE_WARNING_SECONDS
		and not WaveManager.waveActive
end

-- Point the lighthouse beam at a compass heading, pivoting around the
-- lamp room. Heading 0 is north (-Z, the beam's rest pose); a west
-- approach is heading 270. The beam part is a long bar whose centre sits
-- LIGHTHOUSE_BEAM_OFFSET studs out from the pivot along the beam.
local function pointBeam(headingDeg: number)
	WaveManager.beamAngleDeg = headingDeg
	beamValue.Value = headingDeg
	local beam = Workspace:FindFirstChild("LighthouseBeam")
	if beam then
		local pivot = Vector3.new(
			Config.LIGHTHOUSE_PIVOT[1],
			Config.LIGHTHOUSE_PIVOT[2],
			Config.LIGHTHOUSE_PIVOT[3]
		)
		beam.CFrame = CFrame.new(pivot)
			* CFrame.Angles(0, -math.rad(headingDeg), 0)
			* CFrame.new(0, 0, -Config.LIGHTHOUSE_BEAM_OFFSET)
	end
end

-- Choose the next wave's approach axis at the start of the warning
-- window, and swing the beam to match. Called once per wave cycle.
function WaveManager.pickApproach()
	if rng:NextInteger(1, 2) == 1 then
		WaveManager.waveAxis = "Z"
		pointBeam(0) -- the wave rolls in from the north
	else
		WaveManager.waveAxis = "X"
		pointBeam(270) -- the wave rolls in from the west
	end
end

-- Run one wave: sweep the wall along the picked axis, then reset the timer.
-- `world` callbacks: world.onWaveStart(), world.onWavePass(coord, axis),
-- world.onWaveEnd().
function WaveManager.runWave(world)
	if WaveManager.waveActive then
		return
	end
	WaveManager.waveActive = true
	if world.onWaveStart then
		world.onWaveStart()
	end
	if wall then
		local axis = WaveManager.waveAxis
		local startCoord = -Config.MAP_SIZE / 2 - 10
		local endCoord = Config.MAP_SIZE / 2 + 10
		local steps = 50
		for i = 0, steps do
			local coord = startCoord + (endCoord - startCoord) * (i / steps)
			if axis == "X" then
				-- West -> east: the wall is a long bar across Z, moving in X.
				wall.Size = Vector3.new(4, 40, Config.MAP_SIZE)
				wall.Position = Vector3.new(coord, 20, 0)
			else
				-- North -> south: the wall is a long bar across X, moving in Z.
				wall.Size = Vector3.new(Config.MAP_SIZE, 40, 4)
				wall.Position = Vector3.new(0, 20, coord)
			end
			-- Anyone the wall is passing over, who is not safe at home,
			-- gets caught exactly once per wave.
			if world.onWavePass then
				world.onWavePass(coord, axis)
			end
			task.wait(Config.WAVE_SWEEP_SECONDS / steps)
		end
		wall.Position = Vector3.new(0, 20, -Config.MAP_SIZE)
	end
	WaveManager.waveActive = false
	WaveManager.nextWaveAt = os.clock() + Config.WAVE_INTERVAL
	if world.onWaveEnd then
		world.onWaveEnd()
	end
end

-- The wave timer loop: wait for the countdown, then run the wave, forever.
-- The approach is picked when the warning window opens, so the beam
-- points at the incoming wave for the whole warning, not just the sweep.
function WaveManager.startLoop(world)
	task.spawn(function()
		while true do
			local waitFor = WaveManager.secondsUntilWave()
			if waitFor > Config.WAVE_WARNING_SECONDS then
				task.wait(waitFor - Config.WAVE_WARNING_SECONDS)
			end
			WaveManager.pickApproach()
			local remain = WaveManager.secondsUntilWave()
			if remain > 0 then
				task.wait(remain)
			end
			WaveManager.runWave(world)
		end
	end)
end

return WaveManager
