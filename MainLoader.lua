-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local LocalPlayer = Players.LocalPlayer

-- Global Identifier untuk Script 1
_G.Script1Active = _G.Script1Active or false
_G.Script1Gui = _G.Script1Gui or nil

-- GUI Setup untuk Script 2
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Script2Gui"
ScreenGui.Parent = LocalPlayer.PlayerGui
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Parent = ScreenGui

-- Draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
MinimizeButton.Text = "-"
MinimizeButton.Parent = MainFrame
MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Scrolling Frame untuk Tabs
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 60)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingFrame.Parent = MainFrame

-- Switch Script Button
local SwitchButton = Instance.new("TextButton")
SwitchButton.Size = UDim2.new(1, -10, 0, 30)
SwitchButton.Position = UDim2.new(0, 5, 0, 30)
SwitchButton.Text = "Disable Script 1"
SwitchButton.Parent = MainFrame
SwitchButton.MouseButton1Click:Connect(function()
    if _G.Script1Active and _G.Script1Gui then
        _G.Script1Active = false
        _G.Script1Gui.Visible = false
        SwitchButton.Text = "Enable Script 1"
    elseif _G.Script1Gui then
        _G.Script1Active = true
        _G.Script1Gui.Visible = true
        SwitchButton.Text = "Disable Script 1"
    end
end)

-- Item Spawner Functions
local function ScanServerForModels()
    local models = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("PrimaryPart") then
            table.insert(models, obj.Name)
        end
    end
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("PrimaryPart") then
            table.insert(models, obj.Name)
        end
    end
    return models
end

local PredefinedModels = {
    {Name = "Modern House", AssetId = 123456789},
    {Name = "Castle", AssetId = 987654321},
    {Name = "Skyscraper", AssetId = 456789123}
}

local function SpawnModel(modelName, isPredefined, position)
    if isPredefined then
        for _, model in pairs(PredefinedModels) do
            if model.Name == modelName then
                local asset = InsertService:LoadAsset(model.AssetId)
                asset.Parent = Workspace
                asset:MoveTo(position or LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 10))
                break
            end
        end
    else
        local model = Workspace:FindFirstChild(modelName) or ReplicatedStorage:FindFirstChild(modelName)
        if model then
            local clonedModel = model:Clone()
            clonedModel.Parent = Workspace
            clonedModel:MoveTo(position or LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 10))
        end
    end
end

-- Copy Avatar
local function CopyAvatar(targetPlayer)
    local targetDesc = Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
    LocalPlayer.Character.Humanoid:ApplyDescription(targetDesc)
end

-- Teleport Functions
local function TeleportPlayerToMe(targetPlayer)
    if targetPlayer.Character then
        targetPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end

local function TeleportToPlayer(targetPlayer)
    if targetPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
    end
end

local function TeleportPlayerToPlayer(sourcePlayer, targetPlayer)
    if sourcePlayer.Character and targetPlayer.Character then
        sourcePlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
    end
end

-- GUI Population
local function PopulateGUI()
    local yOffset = 0

    -- Item Spawner: Auto-Detect
    local ItemAutoLabel = Instance.new("TextLabel")
    ItemAutoLabel.Size = UDim2.new(1, -10, 0, 30)
    ItemAutoLabel.Position = UDim2.new(0, 5, 0, yOffset)
    ItemAutoLabel.Text = "Item Spawner: Auto-Detect"
    ItemAutoLabel.Parent = ScrollingFrame
    yOffset = yOffset + 35

    for _, model in pairs(ScanServerForModels()) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Position = UDim2.new(0, 5, 0, yOffset)
        button.Text = "Spawn " .. model
        button.Parent = ScrollingFrame
        button.MouseButton1Click:Connect(function()
            SpawnModel(model, false)
        end)
        yOffset = yOffset + 35
    end

    -- Item Spawner: Predefined
    local ItemPredefinedLabel = Instance.new("TextLabel")
    ItemPredefinedLabel.Size = UDim2.new(1, -10, 0, 30)
    ItemPredefinedLabel.Position = UDim2.new(0, 5, 0, yOffset)
    ItemPredefinedLabel.Text = "Item Spawner: Predefined"
    ItemPredefinedLabel.Parent = ScrollingFrame
    yOffset = yOffset + 35

    for _, model in pairs(PredefinedModels) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Position = UDim2.new(0, 5, 0, yOffset)
        button.Text = "Spawn " .. model.Name
        button.Parent = ScrollingFrame
        button.MouseButton1Click:Connect(function()
            SpawnModel(model.Name, true)
        end)
        yOffset = yOffset + 35
    end

    -- Copy Avatar
    local AvatarLabel = Instance.new("TextLabel")
    AvatarLabel.Size = UDim2.new(1, -10, 0, 30)
    AvatarLabel.Position = UDim2.new(0, 5, 0, yOffset)
    AvatarLabel.Text = "Copy Avatar"
    AvatarLabel.Parent = ScrollingFrame
    yOffset = yOffset + 35

    for _, player in pairs(Players:GetPlayers()) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Position = UDim2.new(0, 5, 0, yOffset)
        button.Text = "Copy " .. player.Name
        button.Parent = ScrollingFrame
        button.MouseButton1Click:Connect(function()
            CopyAvatar(player)
        end)
        yOffset = yOffset + 35
    end

    -- Teleport: To Me
    local TeleportToMeLabel = Instance.new("TextLabel")
    TeleportToMeLabel.Size = UDim2.new(1, -10, 0, 30)
    TeleportToMeLabel.Position = UDim2.new(0, 5, 0, yOffset)
    TeleportToMeLabel.Text = "Teleport Player to Me"
    TeleportToMeLabel.Parent = ScrollingFrame
    yOffset = yOffset + 35

    for _, player in pairs(Players:GetPlayers()) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Position = UDim2.new(0, 5, 0, yOffset)
        button.Text = "Teleport " .. player.Name .. " to Me"
        button.Parent = ScrollingFrame
        button.MouseButton1Click:Connect(function()
            TeleportPlayerToMe(player)
        end)
        yOffset = yOffset + 35
    end

    -- Teleport: To Other
    local TeleportToOtherLabel = Instance.new("TextLabel")
    TeleportToOtherLabel.Size = UDim2.new(1, -10, 0, 30)
    TeleportToOtherLabel.Position = UDim2.new(0, 5, 0, yOffset)
    TeleportToOtherLabel.Text = "Teleport to Other Player"
    TeleportToOtherLabel.Parent = ScrollingFrame
    yOffset = yOffset + 35

    for _, player in pairs(Players:GetPlayers()) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Position = UDim2.new(0, 5, 0, yOffset)
        button.Text = "Teleport to " .. player.Name
        button.Parent = ScrollingFrame
        button.MouseButton1Click:Connect(function()
            TeleportToPlayer(player)
        end)
        yOffset = yOffset + 35
    end

    -- Teleport: Player to Player
    local TeleportPlayerToPlayerLabel = Instance.new("TextLabel")
    TeleportPlayerToPlayerLabel.Size = UDim2.new(1, -10, 0, 30)
    TeleportPlayerToPlayerLabel.Position = UDim2.new(0, 5, 0, yOffset)
    TeleportPlayerToPlayerLabel.Text = "Teleport Player to Player"
    TeleportPlayerToPlayerLabel.Parent = ScrollingFrame
    yOffset = yOffset + 35

    for _, sourcePlayer in pairs(Players:GetPlayers()) do
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if sourcePlayer ~= targetPlayer then
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, -10, 0, 30)
                button.Position = UDim2.new(0, 5, 0, yOffset)
                button.Text = "Teleport " .. sourcePlayer.Name .. " to " .. targetPlayer.Name
                button.Parent = ScrollingFrame
                button.MouseButton1Click:Connect(function()
                    TeleportPlayerToPlayer(sourcePlayer, targetPlayer)
                end)
                yOffset = yOffset + 35
            end
        end
    end

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
PopulateGUI()

-- Check for Script 1 and Disable if Active
if _G.Script1Active and _G.Script1Gui then
    _G.Script1Active = false
    _G.Script1Gui.Visible = false
end