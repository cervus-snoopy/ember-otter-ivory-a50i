-- BRAINROT BAY -- Dash (client LocalScript).
-- A short burst of speed for the dash home when the wave comes, or for
-- chasing a rival bot that stole your brainrot. Bound with
-- ContextActionService (not InputBegan with gameProcessedEvent), because
-- Roblox's default camera scripts claim the arrow keys and an InputBegan
-- handler that returns on gameProcessedEvent never sees them.
-- Q (or LeftShift) dashes; the humanoid's WalkSpeed jumps for 0.6 seconds,
-- then returns to normal, and the action cools down for 5 seconds.
-- Dashing home from the boardwalk is the same dash: the wave only cares
-- how close you are to your own plot when the wall passes.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config)

local player = Players.LocalPlayer

local BASE_SPEED = 16
local dashReadyAt = 0

local function getHumanoid()
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

local function dash(_actionName, inputState: Enum.UserInputState, _inputObject)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if os.clock() < dashReadyAt then
		return Enum.ContextActionResult.Pass
	end
	local humanoid = getHumanoid()
	if not humanoid then
		return Enum.ContextActionResult.Pass
	end
	dashReadyAt = os.clock() + Config.DASH_COOLDOWN
	humanoid.WalkSpeed = Config.DASH_SPEED
	task.delay(Config.DASH_SECONDS, function()
		local again = getHumanoid()
		if again then
			again.WalkSpeed = BASE_SPEED
		end
	end)
	return Enum.ContextActionResult.Sink
end

-- Q is the dash; LeftShift is the same action on a second key.
ContextActionService:BindAction("BrainrotBayDash", dash, false, Enum.KeyCode.Q, Enum.KeyCode.LeftShift)

-- Keep the base speed honest on every respawn.
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = BASE_SPEED
end)

print("BRAINROT BAY dash ready: Q or LeftShift to dash.")
