-- BRAINROT BAY -- Camera (client LocalScript).
-- A short cinematic sweep when the player spawns (the camera glides over
-- the bay, the conveyor and the plots), then hands control back to Roblox's
-- default 3D camera so the player can orbit and zoom freely. The game is
-- played in the 3D world under a 3D camera; this script only frames the
-- first look at it.
-- Zoom limits are widened a little so a player can pull back and see their
-- whole plot at once. North-edge landmark: the lighthouse (see
-- default.project.json) is the tallest static part in the bay.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
while not camera do
	task.wait(0.1)
	camera = Workspace.CurrentCamera
end

-- Let the player zoom out far enough to see a whole plot.
player.CameraMinZoomDistance = 6
player.CameraMaxZoomDistance = 90

local INTRO_SECONDS = 4
local introStart = os.clock()
local introDone = false

-- The sweep: start high over the conveyor dock, glide down toward the
-- spawn plaza. A smoothstep eases the motion so it never snaps.
local fromPos = Vector3.new(0, 55, -95)
local toPos = Vector3.new(0, 22, 30)
local lookTarget = Vector3.new(0, 2, -20)

RunService.RenderStepped:Connect(function()
	if introDone then
		return
	end
	local t = (os.clock() - introStart) / INTRO_SECONDS
	if t >= 1 then
		introDone = true
		camera.CameraType = Enum.CameraType.Custom
		return
	end
	local smooth = t * t * (3 - 2 * t)
	local pos = fromPos:Lerp(toPos, smooth)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(pos, lookTarget)
end)

print("BRAINROT BAY camera intro rolling.")
