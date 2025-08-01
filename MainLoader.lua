-- Mobile-Friendly Roblox GUI Script
-- Optimized untuk Android/Touch devices

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Global untuk Script 1
_G.Script1Active = _G.Script1Active or false
_G.Script1Gui = _G.Script1Gui or nil

-- Warna tema mobile-friendly
local Colors = {
    Primary = Color3.fromRGB(33, 150, 243),
    Dark = Color3.fromRGB(25, 25, 30),
    Surface = Color3.fromRGB(40, 40, 45),
    Green = Color3.fromRGB(76, 175, 80),
    Orange = Color3.fromRGB(255, 152, 0),
    Red = Color3.fromRGB(244, 67, 54),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(150, 150, 150)
}

-- GUI utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAdminGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Frame utama - ukuran mobile friendly
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Colors.Dark
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Corner rounded
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Header dengan tombol kontrol
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Colors.Primary
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = Header

-- Fix header bottom corners
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
Title.Text = "📱 Mobile Admin"
Title.TextColor3 = Colors.White
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

-- Tombol minimize (ukuran besar untuk mobile)
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

-- Tombol close
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

-- Container untuk konten
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -50)
Content.Position = UDim2.new(0, 0, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Script 1 kontrol
local Script1Frame = Instance.new("Frame")
Script1Frame.Size = UDim2.new(1, -20, 0, 45)
Script1Frame.Position = UDim2.new(0, 10, 0, 10)
Script1Frame.BackgroundColor3 = Colors.Surface
Script1Frame.BorderSizePixel = 0
Script1Frame.Parent = Content

local S1Corner = Instance.new("UICorner")
S1Corner.CornerRadius = UDim.new(0, 10)
S1Corner.Parent = Script1Frame

local SwitchBtn = Instance.new("TextButton")
SwitchBtn.Size = UDim2.new(1, -10, 1, -10)
SwitchBtn.Position = UDim2.new(0, 5, 0, 5)
SwitchBtn.BackgroundColor3 = Colors.Primary
SwitchBtn.BorderSizePixel = 0
SwitchBtn.Text = "🔄 Matikan Script 1"
SwitchBtn.TextColor3 = Colors.White
SwitchBtn.TextSize = 14
SwitchBtn.Font = Enum.Font.Gotham
SwitchBtn.Parent = Script1Frame

local SwitchCorner = Instance.new("UICorner")
SwitchCorner.CornerRadius = UDim.new(0, 8)
SwitchCorner.Parent = SwitchBtn

-- Tab buttons (horizontal layout)
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 65)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Content

-- Tab system sederhana untuk mobile
local tabs = {"Spawn", "Player", "Teleport", "Utility"}
local tabButtons = {}
local currentTab = 1

for i, tabName in pairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.25, -3, 1, 0)
    tabBtn.Position = UDim2.new((i-1) * 0.25, (i-1) * 2, 0, 0)
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
    
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = i
        UpdateTabs()
        UpdateContent()
    end)
end

-- Scrolling frame untuk konten
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -115)
ScrollFrame.Position = UDim2.new(0, 10, 0, 115)
ScrollFrame.BackgroundColor3 = Colors.Surface
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.ScrollBarImageColor3 = Colors.Primary
ScrollFrame.Parent = Content

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 10)
ScrollCorner.Parent = ScrollFrame

-- Layout untuk scroll frame
local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 5)
Layout.Parent = ScrollFrame

-- Fungsi update tabs
function UpdateTabs()
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
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    -- Touch feedback
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundTransparency = 0.3
    end)
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundTransparency = 0
    end)
    
    return btn
end

-- Fungsi spawn item (mobile-friendly)
local function SpawnItem(itemName)
    local part = Instance.new("Part")
    part.Name = itemName
    part.Size = Vector3.new(3, 3, 3)
    part.Material = Enum.Material.ForceField
    part.BrickColor = BrickColor.Random()
    part.Parent = workspace
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 8, 5)
    end
    
    print("✅ Spawned: " .. itemName)
end

-- Fungsi copy avatar
local function CopyAvatar(player)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and player ~= LocalPlayer then
            local desc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
            LocalPlayer.Character.Humanoid:ApplyDescription(desc)
            print("✅ Copied " .. player.Name .. "'s avatar")
        end
    end)
end

-- Fungsi teleport
local function TeleportTo(player)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
            print("✅ Teleported to " .. player.Name)
        end
    end
end

-- Update konten berdasarkan tab
function UpdateContent()
    -- Clear existing buttons
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local contentHeight = 0
    
    if currentTab == 1 then -- Spawn
        CreateButton("📦 Spawn Neon Block", function() SpawnItem("Neon Block") end, Colors.Green)
        CreateButton("🔮 Spawn Glass Ball", function() SpawnItem("Glass Ball") end, Colors.Green)
        CreateButton("⚡ Spawn Lightning Part", function() SpawnItem("Lightning") end, Colors.Green)
        CreateButton("🏠 Spawn House Block", function() SpawnItem("House") end, Colors.Green)
        contentHeight = 4 * 45
        
    elseif currentTab == 2 then -- Player
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("👤 Copy " .. player.Name, function() CopyAvatar(player) end, Colors.Orange)
                contentHeight = contentHeight + 45
            end
        end
        
    elseif currentTab == 3 then -- Teleport
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("🚀 TP to " .. player.Name, function() TeleportTo(player) end, Colors.Primary)
                contentHeight = contentHeight + 45
            end
        end
        
    elseif currentTab == 4 then -- Utility
        CreateButton("🔄 Rejoin Server", function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end, Colors.Orange)
        
        CreateButton("💀 Reset Character", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end, Colors.Red)
        
        CreateButton("⚡ Super Speed", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 100
                print("✅ Super speed activated!")
            end
        end, Colors.Green)
        
        CreateButton("🐌 Normal Speed", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
                print("✅ Normal speed restored")
            end
        end, Colors.Gray)
        
        contentHeight = 4 * 45
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
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
    local targetSize = isMinimized and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 450)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    wait(0.1)
    Content.Visible = not isMinimized
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
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

-- Auto refresh player lists setiap 10 detik
spawn(function()
    while ScreenGui.Parent do
        wait(10)
        if currentTab == 2 or currentTab == 3 then
            UpdateContent()
        end
    end
end)

-- Initialize
UpdateTabs()
UpdateContent()

-- Handle Script 1
if _G.Script1Active and _G.Script1Gui then
    _G.Script1Active = false
    _G.Script1Gui.Visible = false
end

print("📱 Mobile Admin GUI loaded! Touch-friendly & optimized for Android")