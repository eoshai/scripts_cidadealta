local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.fromScale(0.15, 0.06)
ToggleButton.Position = UDim2.fromScale(0.02, 0.9)
ToggleButton.Text = "ESP: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Parent = ScreenGui

local ESP_ENABLED = false
local PANIC_MODE = false
local ESP_OBJECTS = {}
local UPDATE_INTERVAL = 0.5

local function getTeamColor(player)
	if player.Team and player.Team.TeamColor then
		return player.Team.TeamColor.Color
	end
	return Color3.fromRGB(255,255,255)
end

local function getDistance(character)
	local myChar = LocalPlayer.Character
	if not myChar then return 0 end

	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	local targetRoot = character:FindFirstChild("HumanoidRootPart")

	if not myRoot or not targetRoot then return 0 end
	return math.floor((myRoot.Position - targetRoot.Position).Magnitude)
end

local function removeESP(player)
	local data = ESP_OBJECTS[player]
	if data then
		if data.Highlight then data.Highlight:Destroy() end
		if data.Billboard then data.Billboard:Destroy() end
		if data.Beam then data.Beam:Destroy() end
		if data.Attachment0 then data.Attachment0:Destroy() end
		if data.Attachment1 then data.Attachment1:Destroy() end
		ESP_OBJECTS[player] = nil
	end
end

local function createESP(player, character)
	if player == LocalPlayer then return end
	if ESP_OBJECTS[player] then return end
	if not ESP_ENABLED or PANIC_MODE then return end

	local hum = character:FindFirstChildOfClass("Humanoid")
	local head = character:FindFirstChild("Head")
	local targetRoot = character:FindFirstChild("HumanoidRootPart")
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not hum or not head or not targetRoot or not myRoot then return end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = character

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromScale(5, 2)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.TextColor3 = Color3.new(1,1,1)
	label.Parent = billboard

	local att0 = Instance.new("Attachment")
	att0.Parent = myRoot

	local att1 = Instance.new("Attachment")
	att1.Parent = targetRoot

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.FaceCamera = true
	beam.Width0 = 0.1
	beam.Width1 = 0.1
	beam.Transparency = NumberSequence.new(0)
	beam.Color = ColorSequence.new(getTeamColor(player))
	beam.Parent = myRoot

	ESP_OBJECTS[player] = {
		Highlight = highlight,
		Billboard = billboard,
		Label = label,
		Humanoid = hum,
		Beam = beam,
		Attachment0 = att0,
		Attachment1 = att1,
		Character = character
	}
end

local function updateESP(player)
	if PANIC_MODE then return end
	local data = ESP_OBJECTS[player]
	if not data then return end

	data.Highlight.FillColor = getTeamColor(player)

	if data.Beam then
		data.Beam.Color = ColorSequence.new(getTeamColor(player))
	end

	local teamName = player.Team and player.Team.Name or "Sem Team"
	local distance = getDistance(data.Character)

	data.Label.Text = string.format(
		"%s\nVida: %d\nDistância: %dm\nTeam: %s",
		player.Name,
		math.floor(data.Humanoid.Health),
		distance,
		teamName
	)
end

local function setPanicMode(state)
	PANIC_MODE = state

	if PANIC_MODE then
		ScreenGui.Enabled = false
		ESP_ENABLED = false
		ToggleButton.Text = "ESP: OFF"

		for p in pairs(ESP_OBJECTS) do
			removeESP(p)
		end
	else
		ScreenGui.Enabled = true
	end
end

ToggleButton.MouseButton1Click:Connect(function()
	if PANIC_MODE then return end

	ESP_ENABLED = not ESP_ENABLED
	ToggleButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"

	if not ESP_ENABLED then
		for p in pairs(ESP_OBJECTS) do
			removeESP(p)
		end
	else
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				createESP(player, player.Character)
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		setPanicMode(not PANIC_MODE)
	end
end)

task.spawn(function()
	while true do
		if ESP_ENABLED and not PANIC_MODE then
			for player in pairs(ESP_OBJECTS) do
				updateESP(player)
			end
		end
		task.wait(UPDATE_INTERVAL)
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if ESP_ENABLED and not PANIC_MODE then
			task.wait(0.2)
			createESP(player, character)
		end
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function(character)
			removeESP(player)
			if ESP_ENABLED and not PANIC_MODE then
				task.wait(0.2)
				createESP(player, character)
			end
		end)
	end
end

Players.PlayerRemoving:Connect(removeESP)
