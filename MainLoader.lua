-- Server-Side Mobile Admin GUI Script
-- Requires admin privileges or FE disabled server for full functionality

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Global untuk Script 1
_G.Script1Active = _G.Script1Active or false
_G.Script1Gui = _G.Script1Gui or nil

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
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(150, 150, 150)
}

-- GUI utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerSideAdminGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Colors.Dark
MainFrame.BorderSizePixel = 0
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
Title.Text = "🛡️ Server Admin Panel"
Title.TextColor3 = Colors.White
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

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

-- Tab system - 6 tabs untuk server-side
local TabFrame = Instance.new("ScrollingFrame")
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 65)
TabFrame.BackgroundTransparency = 1
TabFrame.ScrollBarThickness = 0
TabFrame.ScrollingDirection = Enum.ScrollingDirection.X
TabFrame.CanvasSize = UDim2.new(0, 600, 0, 40)
TabFrame.Parent = Content

local tabs = {"Spawn", "Player", "Teleport", "Server", "Fun", "Utility"}
local tabButtons = {}
local currentTab = 1

for i, tabName in pairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 90, 1, 0)
    tabBtn.Position = UDim2.new(0, (i-1) * 95, 0, 0)
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

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 5)
Layout.Parent = ScrollFrame

-- Update tabs function
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
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
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

-- Server-Side Functions
local function SpawnAsset(assetId, position)
    pcall(function()
        local asset = InsertService:LoadAsset(assetId)
        if asset then
            asset.Parent = Workspace
            if position and asset.PrimaryPart then
                asset:SetPrimaryPartCFrame(CFrame.new(position))
            elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                asset:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 10))
            end
            print("✅ Spawned asset: " .. assetId)
        end
    end)
end

local function KillPlayer(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0
        print("💀 Killed: " .. player.Name)
    end
end

local function BringPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
       LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
        print("✅ Brought: " .. player.Name)
    end
end

local function FreezePlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Anchored = true
        print("🧊 Frozen: " .. player.Name)
    end
end

local function UnfreezePlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Anchored = false
        print("🔥 Unfrozen: " .. player.Name)
    end
end

local function KickPlayer(player)
    pcall(function()
        player:Kick("Kicked by admin")
        print("👢 Kicked: " .. player.Name)
    end)
end

local function ChangeServerSetting(property, value)
    pcall(function()
        if property == "TimeOfDay" then
            Lighting.TimeOfDay = value
        elseif property == "Brightness" then
            Lighting.Brightness = value
        elseif property == "Ambient" then
            Lighting.Ambient = value
        elseif property == "FogEnd" then
            Lighting.FogEnd = value
        end
        print("🌍 Server setting changed: " .. property .. " = " .. tostring(value))
    end)
end

local function PlayServerSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Volume = 0.5
        sound.Parent = SoundService
        sound:Play()
        print("🔊 Playing server sound: " .. soundId)
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

local function CreateExplosion(position, size)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = size or 50
    explosion.BlastPressure = 500000
    explosion.Parent = Workspace
    print("💥 Explosion created at: " .. tostring(position))
end

-- Update content function
function UpdateContent()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local contentHeight = 0
    
    if currentTab == 1 then -- Spawn Tab
        CreateButton("🏠 Spawn House", function() SpawnAsset(185191046) end, Colors.Green)
        CreateButton("🚗 Spawn Car", function() SpawnAsset(193503613) end, Colors.Green)
        CreateButton("✈️ Spawn Plane", function() SpawnAsset(136022555) end, Colors.Green)
        CreateButton("🚁 Spawn Helicopter", function() SpawnAsset(146477872) end, Colors.Green)
        CreateButton("🛥️ Spawn Boat", function() SpawnAsset(137735709) end, Colors.Green)
        CreateButton("🎸 Spawn Guitar", function() SpawnAsset(142314093) end, Colors.Green)
        CreateButton("⚔️ Spawn Sword", function() SpawnAsset(125013769) end, Colors.Red)
        CreateButton("🔫 Spawn Gun", function() SpawnAsset(130113146) end, Colors.Red)
        contentHeight = 8 * 45
        
    elseif currentTab == 2 then -- Player Tab
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("👤 " .. player.Name, function() end, Colors.Gray)
                CreateButton("💀 Kill " .. player.Name, function() KillPlayer(player) end, Colors.Red)
                CreateButton("📞 Bring " .. player.Name, function() BringPlayer(player) end, Colors.Orange)
                CreateButton("🧊 Freeze " .. player.Name, function() FreezePlayer(player) end, Colors.Primary)
                CreateButton("🔥 Unfreeze " .. player.Name, function() UnfreezePlayer(player) end, Colors.Green)
                CreateButton("👢 Kick " .. player.Name, function() KickPlayer(player) end, Colors.Red)
                contentHeight = contentHeight + 6 * 45
            end
        end
        
    elseif currentTab == 3 then -- Teleport Tab
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("🚀 TP to " .. player.Name, function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                       player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
                    end
                end, Colors.Primary)
                contentHeight = contentHeight + 45
            end
        end
        
        CreateButton("🌍 TP to Spawn", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            end
        end, Colors.Green)
        contentHeight = contentHeight + 45
        
    elseif currentTab == 4 then -- Server Tab
        CreateButton("☀️ Day Time", function() ChangeServerSetting("TimeOfDay", "12:00:00") end, Colors.Orange)
        CreateButton("🌙 Night Time", function() ChangeServerSetting("TimeOfDay", "00:00:00") end, Colors.Purple)
        CreateButton("🌅 Sunrise", function() ChangeServerSetting("TimeOfDay", "06:00:00") end, Colors.Pink)
        CreateButton("🌆 Sunset", function() ChangeServerSetting("TimeOfDay", "18:00:00") end, Colors.Red)
        CreateButton("💡 Max Brightness", function() ChangeServerSetting("Brightness", 3) end, Colors.Orange)
        CreateButton("🌑 No Brightness", function() ChangeServerSetting("Brightness", 0) end, Colors.Gray)
        CreateButton("🌫️ Add Fog", function() ChangeServerSetting("FogEnd", 50) end, Colors.Gray)
        CreateButton("🌤️ Clear Fog", function() ChangeServerSetting("FogEnd", 100000) end, Colors.Primary)
        contentHeight = 8 * 45
        
    elseif currentTab == 5 then -- Fun Tab
        CreateButton("🎵 Play Music 1", function() PlayServerSound("142376088") end, Colors.Pink)
        CreateButton("🎵 Play Music 2", function() PlayServerSound("131961136") end, Colors.Pink)
        CreateButton("📢 Loud Sound", function() PlayServerSound("138081500") end, Colors.Red)
        CreateButton("💥 Explosion at Me", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                CreateExplosion(LocalPlayer.Character.HumanoidRootPart.Position, 30)
            end
        end, Colors.Red)
        CreateButton("💥💥 Big Explosion", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                CreateExplosion(LocalPlayer.Character.HumanoidRootPart.Position, 100)
            end
        end, Colors.Red)
        CreateButton("🌈 Rainbow Lighting", function()
            spawn(function()
                for i = 1, 10 do
                    Lighting.Ambient = Color3.fromHSV(i/10, 1, 1)
                    wait(0.5)
                end
                Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            end)
        end, Colors.Purple)
        contentHeight = 6 * 45
        
    elseif currentTab == 6 then -- Utility Tab
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
            end
        end, Colors.Green)
        
        CreateButton("🐌 Normal Speed", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end, Colors.Gray)
        
        CreateButton("🦘 Super Jump", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 100
            end
        end, Colors.Green)
        
        CreateButton("👤 Normal Jump", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end, Colors.Gray)
        
        contentHeight = 6 * 45
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
    local targetSize = isMinimized and UDim2.new(0, 340, 0, 50) or UDim2.new(0, 340, 0, 480)
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

-- Auto refresh
spawn(function()
    while ScreenGui.Parent do
        wait(15)
        if currentTab == 2 or currentTab == 3 then
            UpdateContent()
        end
    end
end)

-- Initialize
UpdateTabs()
UpdateContent()

if _G.Script1Active and _G.Script1Gui then
    _G.Script1Active = false
    _G.Script1Gui.Visible = false
end

print("🛡️ Server-Side Admin Panel loaded! Full server control features enabled.")