-- LIGHTHOUSE BAY
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)
local WaveManager = {}
WaveManager.nextWaveAt = os.clock() + Config.WAVE_INTERVAL
WaveManager.waveActive = false
WaveManager.waveAxis = "Z"
WaveManager.beamAngleDeg = 0
local rng = Random.new()
local beamValue = Instance.new("NumberValue")
beamValue.Name = "BeamAngle"
beamValue.Value = 0
beamValue.Parent = ReplicatedStorage
local wall: Part? = nil
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
function WaveManager.secondsUntilWave(): number
	return math.max(0, WaveManager.nextWaveAt - os.clock())
end
function WaveManager.isWarning(): boolean
	return WaveManager.secondsUntilWave() <= Config.WAVE_WARNING_SECONDS
		and not WaveManager.waveActive
end
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
function WaveManager.pickApproach()
	if rng:NextInteger(1, 2) == 1 then
		WaveManager.waveAxis = "Z"
		pointBeam(0)
	else
		WaveManager.waveAxis = "X"
		pointBeam(270)
	end
end
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
				wall.Size = Vector3.new(4, 40, Config.MAP_SIZE)
				wall.Position = Vector3.new(coord, 20, 0)
			else
				wall.Size = Vector3.new(Config.MAP_SIZE, 40, 4)
				wall.Position = Vector3.new(0, 20, coord)
			end
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
