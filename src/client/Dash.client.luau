-- LIGHTHOUSE BAY
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
		if not again then
			return
		end
		for i = 1, 6 do
			again.WalkSpeed = Config.DASH_SPEED + (BASE_SPEED - Config.DASH_SPEED) * (i / 6)
			task.wait(0.05)
		end
		again.WalkSpeed = BASE_SPEED
	end)
	return Enum.ContextActionResult.Sink
end
ContextActionService:BindAction("BrainrotBayDash", dash, false, Enum.KeyCode.Q, Enum.KeyCode.LeftShift)
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = BASE_SPEED
end)
print("LIGHTHOUSE BAY dash ready: Q or LeftShift to dash.")
