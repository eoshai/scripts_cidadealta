local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
end)

local ENABLED = false
local PANIC_MODE = false
local SCAN_INTERVAL = 0.15
local MAX_DISTANCE = 12
local CAIXAS_FOLDER = Workspace:WaitForChild("Mercado_Caixas")

local gui = Instance.new("ScreenGui")
gui.Name = "MercadoSecurityTest"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromScale(0.2, 0.07)
toggle.Position = UDim2.fromScale(0.02, 0.85)
toggle.Text = "AUTO CAIXA: OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Parent = gui

local function getNearestSacola()
	local nearest
	local shortest = math.huge

	for _, caixa in ipairs(CAIXAS_FOLDER:GetChildren()) do
		if caixa:IsA("Model") then
			local sacola = caixa:FindFirstChild("SacolaCaixa")
			if sacola and sacola:IsA("BasePart") then
				local dist = (sacola.Position - hrp.Position).Magnitude
				if dist < shortest and dist <= MAX_DISTANCE then
					shortest = dist
					nearest = sacola
				end
			end
		end
	end

	return nearest
end

task.spawn(function()
	while true do
		if ENABLED and not PANIC_MODE then
			local sacola = getNearestSacola()
			if sacola then
				local prompt = sacola:FindFirstChildOfClass("ProximityPrompt")
				if prompt and prompt.Enabled then
					fireproximityprompt(prompt)
				end
			end
		end
		task.wait(SCAN_INTERVAL)
	end
end)

toggle.MouseButton1Click:Connect(function()
	if PANIC_MODE then return end

	ENABLED = not ENABLED

	if ENABLED then
		toggle.Text = "AUTO CAIXA: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		toggle.Text = "AUTO CAIXA: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

local function setPanicMode(state)
	PANIC_MODE = state

	if PANIC_MODE then
		ENABLED = false
		gui.Enabled = false
		toggle.Text = "AUTO CAIXA: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	else
		gui.Enabled = true
	end
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		setPanicMode(not PANIC_MODE)
	end
end)
