local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PainelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Header (área draggable)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTOFARM CDA || SHAI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local tabs = {"Teleport", "Comprar", "Lavar", "Player", "Cooldowns"}
local currentTab = "Teleport"

local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(1, 0, 0, 35)
tabButtons.BackgroundTransparency = 1
tabButtons.Parent = contentFrame

local tabContent = Instance.new("Frame")
tabContent.Size = UDim2.new(1, 0, 1, -45)
tabContent.Position = UDim2.new(0, 0, 0, 45)
tabContent.BackgroundTransparency = 1
tabContent.Parent = contentFrame

for i, tabName in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName
    tabBtn.Size = UDim2.new(1/5, -5, 1, 0)
    tabBtn.Position = UDim2.new((i-1)/5, (i-1)*2.5, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.TextSize = 14
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.Parent = tabButtons
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = tabName
        for _, child in pairs(tabContent:GetChildren()) do
            child.Visible = (child.Name == tabName)
        end
        for _, btn in pairs(tabButtons:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn.Name == tabName) and Color3.fromRGB(75, 75, 75) or Color3.fromRGB(55, 55, 55)
            end
        end
    end)
end

local function createButton(parent, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

local teleportTab = Instance.new("Frame")
teleportTab.Name = "Teleport"
teleportTab.Size = UDim2.new(1, 0, 1, 0)
teleportTab.BackgroundTransparency = 1
teleportTab.Parent = tabContent

createButton(teleportTab, "Banco", 0, function()
    local target = workspace:FindFirstChild("Caixinhas")
    if target then
        target = target:FindFirstChild("CaixaRegistradoraB")
        if target then
            target = target:FindFirstChild("Roubo")
            if target and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = target.CFrame
            end
        end
    end
end)

createButton(teleportTab, "Caixinha", 50, function()
    local caixinhas = workspace:FindFirstChild("Caixinhas")
    if caixinhas then
        local caixas = {}
        for _, model in pairs(caixinhas:GetChildren()) do
            if model:IsA("Model") and model.Name == "CaixaRegistradora" then
                for _, part in pairs(model:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(caixas, part)
                    end
                end
            end
        end
        
        if #caixas > 0 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local randomCaixa = caixas[math.random(1, #caixas)]
            player.Character.HumanoidRootPart.CFrame = randomCaixa.CFrame
        end
    end
end)

createButton(teleportTab, "Hangar", 100, function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(678.047424, 2.1033268, -114.150482, -0.939700961, 0, -0.341998369, 0, 1, 0, 0.341998369, 0, -0.939700961)
    end
end)

createButton(teleportTab, "Praça", 150, function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(1.00848293, 0.803622782, 362.317841, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    end
end)

local comprarTab = Instance.new("Frame")
comprarTab.Name = "Comprar"
comprarTab.Size = UDim2.new(1, 0, 1, 0)
comprarTab.BackgroundTransparency = 1
comprarTab.Visible = false
comprarTab.Parent = tabContent

createButton(comprarTab, "Ilegal", 0, function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-217.687836, 48.3354149, 986.577454, 0, 1, 0, 1, 0, 0, 0, 0, -1)
    end
end)

local lavarTab = Instance.new("Frame")
lavarTab.Name = "Lavar"
lavarTab.Size = UDim2.new(1, 0, 1, 0)
lavarTab.BackgroundTransparency = 1
lavarTab.Visible = false
lavarTab.Parent = tabContent

createButton(lavarTab, "Lavar Dinheiro", 0, function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-284.028046, 67.0644913, 937.683105, 0.917031527, 0, 0.398814708, 0, 1, 0, -0.398814708, 0, 0.917031527)
    end
end)

local personagemTab = Instance.new("Frame")
personagemTab.Name = "Personagem"
personagemTab.Size = UDim2.new(1, 0, 1, 0)
personagemTab.BackgroundTransparency = 1
personagemTab.Visible = false
personagemTab.Parent = tabContent

local lavagemBypassEnabled = false
local lavagemGui = nil

local lavagemBypassBtn = createButton(personagemTab, "Lavar Bypass {EM DESENVOLVIMENTO}", 0, function()
end)

tabButtons.Teleport.BackgroundColor3 = Color3.fromRGB(75, 75, 75)

local cooldownsTab = Instance.new("Frame")
cooldownsTab.Name = "Cooldowns"
cooldownsTab.Size = UDim2.new(1, 0, 1, 0)
cooldownsTab.BackgroundTransparency = 1
cooldownsTab.Visible = false
cooldownsTab.Parent = tabContent

createButton(cooldownsTab, "Bypass Cooldowns", 0, function()
    local caixinhas = workspace:FindFirstChild("Caixinhas")
    if caixinhas then
        local promptsModified = 0
        
        local function searchPrompts(parent)
            for _, obj in pairs(parent:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                    obj.Enabled = true
                    promptsModified = promptsModified + 1
                end
            end
        end
        
        searchPrompts(caixinhas)
    else
    end
end)
