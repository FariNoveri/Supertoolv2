-- FE BYPASS ADMIN GUI - FIXED VERSION
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Wait for character to load
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Global untuk Script 1
_G.Script1Active = _G.Script1Active or false
_G.Script1Gui = _G.Script1Gui or nil

-- FE Bypass Variables
local FEBypass = {
    Enabled = false,
    OldCharacter = nil,
    FakeCharacter = nil,
    Connections = {}
}

-- Warna tema
local Colors = {
    Primary = Color3.fromRGB(33, 150, 243),
    Dark = Color3.fromRGB(25, 25, 30),
    Surface = Color3.fromRGB(40, 40, 45),
    Green = Color3.fromRGB(76, 175, 80),
    Orange = Color3.fromRGB(255, 152, 0),
    Red = Color3.fromRGB(244, 67, 54),
    Purple = Color3.fromRGB(156, 39, 176),
    Pink = Color3.fromRGB(233, 30, 99),
    Cyan = Color3.fromRGB(0, 188, 212),
    Yellow = Color3.fromRGB(255, 235, 59),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(150, 150, 150)
}

-- Destroy existing GUI if it exists
if LocalPlayer.PlayerGui:FindFirstChild("FEBypassAdminGui") then
    LocalPlayer.PlayerGui:FindFirstChild("FEBypassAdminGui"):Destroy()
end

-- GUI utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FEBypassAdminGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Colors.Dark
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Colors.Primary
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 15)
HeaderFix.Position = UDim2.new(0, 0, 1, -15)
HeaderFix.BackgroundColor3 = Colors.Primary
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 FE Bypass Admin"
Title.TextColor3 = Colors.White
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

-- Status indicator
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 60, 0, 20)
Status.Position = UDim2.new(1, -140, 0, 5)
Status.BackgroundColor3 = Colors.Red
Status.Text = "FE ON"
Status.TextColor3 = Colors.White
Status.TextSize = 10
Status.Font = Enum.Font.Gotham
Status.Parent = Header

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = Status

-- Tombol kontrol
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0.5, -15)
MinBtn.BackgroundColor3 = Colors.Orange
MinBtn.BorderSizePixel = 0
MinBtn.Text = "−"
MinBtn.TextColor3 = Colors.White
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -15)
CloseBtn.BackgroundColor3 = Colors.Red
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.White
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Container
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -50)
Content.Position = UDim2.new(0, 0, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Script 1 kontrol + FE Bypass toggle
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(1, -20, 0, 90)
ControlFrame.Position = UDim2.new(0, 10, 0, 10)
ControlFrame.BackgroundColor3 = Colors.Surface
ControlFrame.BorderSizePixel = 0
ControlFrame.Parent = Content

local ControlCorner = Instance.new("UICorner")
ControlCorner.CornerRadius = UDim.new(0, 10)
ControlCorner.Parent = ControlFrame

local SwitchBtn = Instance.new("TextButton")
SwitchBtn.Size = UDim2.new(1, -10, 0, 35)
SwitchBtn.Position = UDim2.new(0, 5, 0, 5)
SwitchBtn.BackgroundColor3 = Colors.Primary
SwitchBtn.BorderSizePixel = 0
SwitchBtn.Text = "🔄 Matikan Script 1"
SwitchBtn.TextColor3 = Colors.White
SwitchBtn.TextSize = 13
SwitchBtn.Font = Enum.Font.Gotham
SwitchBtn.Parent = ControlFrame

local SwitchCorner = Instance.new("UICorner")
SwitchCorner.CornerRadius = UDim.new(0, 8)
SwitchCorner.Parent = SwitchBtn

-- FE Bypass Toggle Button
local BypassBtn = Instance.new("TextButton")
BypassBtn.Size = UDim2.new(1, -10, 0, 35)
BypassBtn.Position = UDim2.new(0, 5, 0, 45)
BypassBtn.BackgroundColor3 = Colors.Red
BypassBtn.BorderSizePixel = 0
BypassBtn.Text = "🛡️ Enable FE Bypass"
BypassBtn.TextColor3 = Colors.White
BypassBtn.TextSize = 13
BypassBtn.Font = Enum.Font.Gotham
BypassBtn.Parent = ControlFrame

local BypassCorner = Instance.new("UICorner")
BypassCorner.CornerRadius = UDim.new(0, 8)
BypassCorner.Parent = BypassBtn

-- Tab system
local TabFrame = Instance.new("ScrollingFrame")
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 110)
TabFrame.BackgroundTransparency = 1
TabFrame.ScrollBarThickness = 6
TabFrame.ScrollBarImageColor3 = Colors.Primary
TabFrame.ScrollingDirection = Enum.ScrollingDirection.X
TabFrame.CanvasSize = UDim2.new(0, 700, 0, 40)
TabFrame.Parent = Content

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabFrame

-- Update canvas size for tabs
local function updateTabCanvas()
    TabFrame.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 10, 0, 40)
end

TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)

local tabs = {"Spawn", "Player", "Teleport", "Server", "Fun", "Utility", "Bypass"}
local tabButtons = {}
local currentTab = 1

for i, tabName in pairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 90, 1, 0)
    tabBtn.BackgroundColor3 = Colors.Surface
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Colors.Gray
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.Parent = TabFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabBtn
    
    tabButtons[i] = tabBtn
end

-- Scrolling frame untuk konten
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -160)
ScrollFrame.Position = UDim2.new(0, 10, 0, 160)
ScrollFrame.BackgroundColor3 = Colors.Surface
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.ScrollBarImageColor3 = Colors.Primary
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = Content

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 10)
ScrollCorner.Parent = ScrollFrame

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 5)
Layout.Parent = ScrollFrame

-- Update canvas size automatically
local function updateScrollCanvas()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollCanvas)

-- FE Bypass Functions
local function EnableFEBypass()
    if FEBypass.Enabled then return end
    
    FEBypass.Enabled = true
    Status.Text = "BYPASS"
    Status.BackgroundColor3 = Colors.Green
    BypassBtn.Text = "🛡️ Disable FE Bypass"
    BypassBtn.BackgroundColor3 = Colors.Green
    
    pcall(function()
        if LocalPlayer.Character then
            FEBypass.OldCharacter = LocalPlayer.Character
            
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    if part.Name == "Head" then
                        for _, child in pairs(part:GetChildren()) do
                            if child:IsA("Decal") then
                                child.Transparency = 1
                            end
                        end
                    end
                end
                if part:IsA("Accessory") then
                    for _, accessoryPart in pairs(part:GetChildren()) do
                        if accessoryPart:IsA("BasePart") then
                            accessoryPart.Transparency = 1
                        end
                    end
                end
            end
        end
    end)
    
    print("🛡️ FE Bypass enabled!")
end

local function DisableFEBypass()
    if not FEBypass.Enabled then return end
    
    FEBypass.Enabled = false
    Status.Text = "FE ON"
    Status.BackgroundColor3 = Colors.Red
    BypassBtn.Text = "🛡️ Enable FE Bypass"
    BypassBtn.BackgroundColor3 = Colors.Red
    
    pcall(function()
        if FEBypass.OldCharacter then
            for _, part in pairs(FEBypass.OldCharacter:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    if part.Name == "Head" then
                        for _, child in pairs(part:GetChildren()) do
                            if child:IsA("Decal") then
                                child.Transparency = 0
                            end
                        end
                    end
                end
                if part:IsA("Accessory") then
                    for _, accessoryPart in pairs(part:GetChildren()) do
                        if accessoryPart:IsA("BasePart") then
                            accessoryPart.Transparency = 0
                        end
                    end
                end
            end
        end
        
        if FEBypass.FakeCharacter then
            FEBypass.FakeCharacter:Destroy()
            FEBypass.FakeCharacter = nil
        end
    end)
    
    print("🔒 FE Bypass disabled!")
end

-- Update tabs function
local function UpdateTabs()
    for i, btn in pairs(tabButtons) do
        if i == currentTab then
            btn.BackgroundColor3 = Colors.Primary
            btn.TextColor3 = Colors.White
        else
            btn.BackgroundColor3 = Colors.Surface
            btn.TextColor3 = Colors.Gray
        end
    end
end

-- Fungsi buat tombol
local function CreateButton(text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = color or Colors.Primary
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Colors.White
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextWrapped = true
    btn.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundTransparency = 0.3
    end)
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundTransparency = 0
    end)
    
    return btn
end

-- Update content function
local function UpdateContent()
    -- Clear existing buttons
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if currentTab == 1 then -- Spawn Tab
        CreateButton("📦 Neon Box", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            pcall(function()
                local part = Instance.new("Part")
                part.Name = "NeonBox"
                part.Size = Vector3.new(4, 4, 4)
                part.Material = Enum.Material.ForceField
                part.BrickColor = BrickColor.Random()
                part.CanCollide = false
                part.Parent = workspace
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 8, 5)
                end
                print("✨ Spawned: Neon Box")
            end)
        end, Colors.Green)
        
        CreateButton("💥 Spawn Explosion", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local explosion = Instance.new("Explosion")
                explosion.Position = LocalPlayer.Character.HumanoidRootPart.Position
                explosion.BlastRadius = 20
                explosion.BlastPressure = 50000
                explosion.Parent = workspace
                print("💥 Explosion spawned!")
            end
        end, Colors.Red)
        
    elseif currentTab == 2 then -- Player Tab
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("👤 " .. player.Name, function() end, Colors.Gray)
            end
        end
        
    elseif currentTab == 3 then -- Teleport Tab
        CreateButton("🌍 TP to Spawn", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                    print("🌍 Teleported to Spawn")
                end
            end)
        end, Colors.Green)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("🚀 TP to " .. player.Name, function()
                    if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                           player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
                            print("🚀 Teleported to: " .. player.Name)
                        end
                    end)
                end, Colors.Primary)
            end
        end
        
    elseif currentTab == 4 then -- Server Tab
        CreateButton("☀️ Day Time", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            Lighting.TimeOfDay = "12:00:00"
            print("☀️ Set to Day Time")
        end, Colors.Orange)
        
        CreateButton("🌙 Night Time", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            Lighting.TimeOfDay = "00:00:00"
            print("🌙 Set to Night Time")
        end, Colors.Purple)
        
    elseif currentTab == 5 then -- Fun Tab
        CreateButton("🎵 Play Music", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            pcall(function()
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://142376088"
                sound.Volume = 0.5
                sound.Looped = true
                sound.Parent = workspace
                sound:Play()
                print("🎵 Music playing")
            end)
        end, Colors.Pink)
        
    elseif currentTab == 6 then -- Utility Tab
        CreateButton("⚡ Super Speed", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 150
                    print("⚡ Super speed: 150")
                end
            end)
        end, Colors.Green)
        
        CreateButton("🐌 Normal Speed", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 16
                    print("🐌 Normal speed: 16")
                end
            end)
        end, Colors.Gray)
        
    elseif currentTab == 7 then -- Bypass Tab
        CreateButton("🛡️ Toggle FE Bypass", function()
            if FEBypass.Enabled then
                DisableFEBypass()
            else
                EnableFEBypass()
            end
        end, FEBypass.Enabled and Colors.Green or Colors.Red)
        
        CreateButton("👻 Invisible Mode", function()
            if not FEBypass.Enabled then print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Transparency = part.Transparency == 0 and 1 or 0
                        end
                    end
                    print("👻 Invisibility toggled!")
                end
            end)
        end, Colors.Purple)
    end
    
    -- Update canvas size after adding buttons
    wait(0.1)
    updateScrollCanvas()
end

-- Tab click events
for i, tabBtn in pairs(tabButtons) do
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = i
        UpdateTabs()
        UpdateContent()
    end)
end

-- Touch-friendly dragging
local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Control buttons
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 350, 0, 50) or UDim2.new(0, 350, 0, 500)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    Content.Visible = not isMinimized
end)

CloseBtn.MouseButton1Click:Connect(function()
    if FEBypass.Enabled then
        DisableFEBypass()
    end
    ScreenGui:Destroy()
end)

-- FE Bypass toggle
BypassBtn.MouseButton1Click:Connect(function()
    if FEBypass.Enabled then
        DisableFEBypass()
    else
        EnableFEBypass()
    end
end)

-- Script 1 control
SwitchBtn.MouseButton1Click:Connect(function()
    if _G.Script1Active and _G.Script1Gui then
        _G.Script1Active = false
        _G.Script1Gui.Visible = false
        SwitchBtn.Text = "🔄 Nyalakan Script 1"
        SwitchBtn.BackgroundColor3 = Colors.Green
    elseif _G.Script1Gui then
        _G.Script1Active = true
        _G.Script1Gui.Visible = true
        SwitchBtn.Text = "🔄 Matikan Script 1"
        SwitchBtn.BackgroundColor3 = Colors.Primary
    end
end)

-- Initialize GUI
UpdateTabs()
UpdateContent()

-- Success message
print("🔥 FE Bypass Admin Panel loaded successfully!")
print("📱 Mobile optimized interface ready")
print("🛡️ Enable FE Bypass for enhanced features")

-- Make sure GUI is visible
ScreenGui.Enabled = true
MainFrame.Visible = true