-- LIGHTHOUSE BAY
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
while not camera do
	task.wait(0.1)
	camera = Workspace.CurrentCamera
end
player.CameraMinZoomDistance = 6
player.CameraMaxZoomDistance = 90
local card = Instance.new("ScreenGui")
card.Name = "IntroCard"
card.Parent = player:WaitForChild("PlayerGui")
local function cardLabel(y, height, text, textSize, color)
	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0.5, -300, 0, y)
	label.Size = UDim2.new(0, 600, 0, height)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.Text = text
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.Parent = card
	return label
end
local cardTitle = cardLabel(120, 64, "LIGHTHOUSE BAY", 44, Color3.fromRGB(255, 220, 100))
local cardLine1 = cardLabel(196, 28, "Old Bram keeps the lamp.", 16, Color3.fromRGB(255, 255, 255))
local cardLine2 = cardLabel(224, 28, "When the beam swings, the Surge follows.", 16, Color3.fromRGB(255, 255, 255))
local cardLine3 = cardLabel(252, 28, "A circus barge wrecked on the reef. Its passengers never left.", 16, Color3.fromRGB(200, 220, 255))
local function fadeCard()
	for i = 1, 16 do
		local a = i / 16
		cardTitle.TextTransparency = a
		cardLine1.TextTransparency = a
		cardLine2.TextTransparency = a
		cardLine3.TextTransparency = a
		task.wait(0.05)
	end
	card:Destroy()
end
local SHOT_TIMES = { 1.8, 1.8, 1.4 }
local SHOT_POS = {
	Vector3.new(0, 55, -140),
	Vector3.new(0, 30, -95),
	Vector3.new(0, 14, -40),
	Vector3.new(0, 12, 34),
}
local SHOT_LOOK = {
	Vector3.new(0, 20, -104),
	Vector3.new(0, 4, -70),
	Vector3.new(0, 2, -58),
	Vector3.new(0, 2, -20),
}
local INTRO_SECONDS = 5
local introStart = os.clock()
local introDone = false
RunService.RenderStepped:Connect(function()
	if introDone then
		return
	end
	local elapsed = os.clock() - introStart
	if elapsed >= INTRO_SECONDS then
		introDone = true
		camera.CameraType = Enum.CameraType.Custom
		task.spawn(fadeCard)
		return
	end
	local t = elapsed
	local seg = 1
	while t > SHOT_TIMES[seg] do
		t -= SHOT_TIMES[seg]
		seg += 1
	end
	local u = t / SHOT_TIMES[seg]
	local smooth = u * u * (3 - 2 * u)
	local pos = SHOT_POS[seg]:Lerp(SHOT_POS[seg + 1], smooth)
	local look = SHOT_LOOK[seg]:Lerp(SHOT_LOOK[seg + 1], smooth)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(pos, look)
end)
print("LIGHTHOUSE BAY camera intro rolling.")
