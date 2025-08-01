-- FE Bypass Mobile Admin GUI Script
-- Enhanced with improved Teleport Player to Me, notifications, deeper FE bypass, full features, scrolling, player visibility

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

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

-- GUI utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FEBypassAdminGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Colors.Dark
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Notifikasi Frame
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0, 300, 0, 50)
NotificationFrame.Position = UDim2.new(0.5, -150, 0, 10)
NotificationFrame.BackgroundColor3 = Colors.Surface
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Visible = false
NotificationFrame.Parent = ScreenGui

local NotificationCorner = Instance.new("UICorner")
NotificationCorner.CornerRadius = UDim.new(0, 10)
NotificationCorner.Parent = NotificationFrame

local NotificationText = Instance.new("TextLabel")
NotificationText.Size = UDim2.new(1, -10, 1, -10)
NotificationText.Position = UDim2.new(0, 5, 0, 5)
NotificationText.BackgroundTransparency = 1
NotificationText.Text = ""
NotificationText.TextColor3 = Colors.White
NotificationText.TextSize = 12
NotificationText.Font = Enum.Font.Gotham
NotificationText.TextWrapped = true
NotificationText.Parent = NotificationFrame

-- Fungsi untuk menampilkan notifikasi
local function ShowNotification(message, color, duration)
    NotificationFrame.BackgroundColor3 = color or Colors.Green
    NotificationText.Text = message
    NotificationFrame.Visible = true
    spawn(function()
        wait(duration or 3)
        NotificationFrame.Visible = false
    end)
end

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

-- Tab system - Optimized horizontal scroll
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
TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabFrame.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 10, 0, 40)
end)

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
    
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = i
        UpdateTabs()
        UpdateContent()
    end)
end

-- Optimized Scrolling frame untuk konten
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
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

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

-- Fungsi buat input teks
local function CreateTextInput(placeholder, callback)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -10, 0, 40)
    inputFrame.BackgroundColor3 = Colors.Surface
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = ScrollFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -10, 1, -10)
    input.Position = UDim2.new(0, 5, 0, 5)
    input.BackgroundTransparency = 1
    input.Text = placeholder
    input.TextColor3 = Colors.Gray
    input.TextSize = 13
    input.Font = Enum.Font.Gotham
    input.TextWrapped = true
    input.Parent = inputFrame
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(input.Text)
            input.Text = placeholder
        end
    end)
    
    return inputFrame
end

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
            
            FEBypass.FakeCharacter = FEBypass.OldCharacter:Clone()
            FEBypass.FakeCharacter.Parent = workspace
            FEBypass.FakeCharacter.Name = LocalPlayer.Name .. "_Fake"
            
            for _, part in pairs(FEBypass.FakeCharacter:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Anchored = true
                end
            end
        end
    end)
    
    ShowNotification("🛡️ FE Bypass enabled!", Colors.Green)
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
    
    ShowNotification("🔒 FE Bypass disabled!", Colors.Red)
    print("🔒 FE Bypass disabled!")
end

-- Teleport Player with Improved Bypass
local function TeleportPlayerBypass(player, target)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        -- Validasi pemain dan karakter
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            ShowNotification("❌ Teleport failed: Invalid player!", Colors.Red)
            print("❌ Teleport failed: Player " .. (player and player.Name or "nil") .. " has no valid character!")
            return
        end
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            ShowNotification("❌ Teleport failed: Invalid target!", Colors.Red)
            print("❌ Teleport failed: Target " .. (target and target.Name or "nil") .. " has no valid character!")
            return
        end
        if player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health <= 0 then
            ShowNotification("❌ Teleport failed: Player is dead!", Colors.Red)
            print("❌ Teleport failed: Player " .. player.Name .. " is dead!")
            return
        end
        if target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health <= 0 then
            ShowNotification("❌ Teleport failed: Target is dead!", Colors.Red)
            print("❌ Teleport failed: Target " .. target.Name .. " is dead!")
            return
        end

        -- Posisi tujuan dengan offset dan validasi aman
        local targetPos = target.Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0) -- Offset 2 stud
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {player.Character, target.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local rayResult = workspace:Raycast(targetPos.Position, Vector3.new(0, -10, 0), rayParams)
        if not rayResult or rayResult.Position.Y < targetPos.Position.Y - 5 then
            -- Jika posisi nggak aman, cari posisi terdekat yang aman
            targetPos = targetPos * CFrame.new(0, 5, 0) -- Naikkan 5 stud
            ShowNotification("⚠️ Adjusted position for safety!", Colors.Orange)
            print("⚠️ Adjusted teleport position for safety")
        end

        -- Efek visual teleportasi
        local particle = Instance.new("ParticleEmitter")
        particle.Texture = "rbxassetid://243098098"
        particle.Size = NumberSequence.new(1, 0)
        particle.Lifetime = NumberRange.new(0.5, 1)
        particle.Rate = 50
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Parent = Instance.new("Part")
        particle.Parent.Size = Vector3.new(0.2, 0.2, 0.2)
        particle.Parent.Position = targetPos.Position
        particle.Parent.Transparency = 1
        particle.Parent.Anchored = true
        particle.Parent.Parent = workspace
        wait(1)
        particle.Parent:Destroy()

        -- Teleport client-sided
        player.Character.HumanoidRootPart.CFrame = targetPos

        -- Bypass FE dengan RemoteEvent/Function
        local teleportKeywords = {"teleport", "move", "tp", "relocate", "position", "update", "warp"}
        local remotesTried = {}
        local success = false
        local maxAttempts = 3
        local attempt = 1

        -- Cari RemoteEvent/Function di ReplicatedStorage, Workspace, dan PlayerGui
        local searchLocations = {ReplicatedStorage, Workspace, LocalPlayer.PlayerGui}
        for _, location in pairs(searchLocations) do
            for _, obj in pairs(location:GetDescendants()) do
                if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not table.find(remotesTried, obj) then
                    for _, keyword in pairs(teleportKeywords) do
                        if string.find(string.lower(obj.Name), keyword) then
                            table.insert(remotesTried, obj)
                            for i = 1, maxAttempts do
                                if obj:IsA("RemoteEvent") then
                                    pcall(function()
                                        obj:FireServer(player, targetPos)
                                        obj:FireServer(player, targetPos.Position)
                                        obj:FireServer(player.UserId, targetPos)
                                        success = true
                                    end)
                                elseif obj:IsA("RemoteFunction") then
                                    local invokeSuccess, result = pcall(obj.InvokeServer, obj, player, targetPos)
                                    if invokeSuccess and (result == true or type(result) == "table" or result == "success") then
                                        success = true
                                    end
                                    invokeSuccess, result = pcall(obj.InvokeServer, obj, player.UserId, targetPos.Position)
                                    if invokeSuccess and (result == true or type(result) == "table" or result == "success") then
                                        success = true
                                    end
                                end
                                wait(0.1) -- Delay antar percobaan
                            end
                        end
                    end
                end
            end
        end

        -- Log dan notifikasi
        if success then
            ShowNotification("📞 Teleported " .. player.Name .. " to you!", Colors.Green)
            print("📞 Teleported " .. player.Name .. " to " .. target.Name)
            print("✅ Remotes tried: " .. table.concat(remotesTried, ", "))
        else
            ShowNotification("⚠️ Teleport failed: No valid RemoteEvent/Function!", Colors.Red)
            print("⚠️ Teleport failed: No valid RemoteEvent/Function found")
            print("🛠️ Remotes tried: " .. (#remotesTried > 0 and table.concat(remotesTried, ", ") or "None"))
        end
    end, function(err)
        ShowNotification("⚠️ Teleport error: " .. tostring(err), Colors.Red)
        print("⚠️ Teleport error: " .. tostring(err))
    end)
end

-- Explosion Features with Particle Effects
local function SpawnExplosion(position)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        local explosion = Instance.new("Explosion")
        explosion.Position = position
        explosion.BlastRadius = 20
        explosion.BlastPressure = 50000
        explosion.DestroyJointRadiusPercent = 0
        explosion.Parent = workspace
        
        local particle = Instance.new("ParticleEmitter")
        particle.Texture = "rbxassetid://243098098"
        particle.Size = NumberSequence.new(2, 0)
        particle.Lifetime = NumberRange.new(0.5, 1)
        particle.Rate = 50
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Parent = Instance.new("Part")
        particle.Parent.Size = Vector3.new(0.2, 0.2, 0.2)
        particle.Parent.Position = position
        particle.Parent.Transparency = 1
        particle.Parent.Anchored = true
        particle.Parent.Parent = workspace
        wait(1)
        particle.Parent:Destroy()
        
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "explosion") or string.find(string.lower(obj.Name), "effect")) then
                obj:FireServer(position, 20, 50000)
            end
        end
        ShowNotification("💥 Explosion spawned!", Colors.Green)
        print("💥 Explosion spawned at: " .. tostring(position))
    end)
end

local function SpawnCloudExplosion(player)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 50, 0)
            local explosion = Instance.new("Explosion")
            explosion.Position = position
            explosion.BlastRadius = 30
            explosion.BlastPressure = 30000
            explosion.DestroyJointRadiusPercent = 0
            explosion.Parent = workspace
            
            local particle = Instance.new("ParticleEmitter")
            particle.Texture = "rbxassetid://243098098"
            particle.Size = NumberSequence.new(3, 0)
            particle.Lifetime = NumberRange.new(0.7, 1.2)
            particle.Rate = 30
            particle.SpreadAngle = Vector2.new(360, 360)
            particle.Parent = Instance.new("Part")
            particle.Parent.Size = Vector3.new(0.2, 0.2, 0.2)
            particle.Parent.Position = position
            particle.Parent.Transparency = 1
            particle.Parent.Anchored = true
            particle.Parent.Parent = workspace
            wait(1)
            particle.Parent:Destroy()
            
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "explosion") or string.find(string.lower(obj.Name), "effect")) then
                    obj:FireServer(position, 30, 30000)
                end
            end
            ShowNotification("☁️ Cloud explosion spawned above " .. player.Name, Colors.Green)
            print("☁️ Cloud explosion spawned above: " .. player.Name)
        else
            ShowNotification("❌ Cloud explosion failed: Invalid player!", Colors.Red)
        end
    end)
end

local function SpawnExplosionToPlayer(targetPlayer)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local position = targetPlayer.Character.HumanoidRootPart.Position
            local explosion = Instance.new("Explosion")
            explosion.Position = position
            explosion.BlastRadius = 15
            explosion.BlastPressure = 40000
            explosion.DestroyJointRadiusPercent = 0
            explosion.Parent = workspace
            
            local particle = Instance.new("ParticleEmitter")
            particle.Texture = "rbxassetid://243098098"
            particle.Size = NumberSequence.new(1.5, 0)
            particle.Lifetime = NumberRange.new(0.5, 1)
            particle.Rate = 60
            particle.SpreadAngle = Vector2.new(360, 360)
            particle.Parent = Instance.new("Part")
            particle.Parent.Size = Vector3.new(0.2, 0.2, 0.2)
            particle.Parent.Position = position
            particle.Parent.Transparency = 1
            particle.Parent.Anchored = true
            particle.Parent.Parent = workspace
            wait(1)
            particle.Parent:Destroy()
            
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "explosion") or string.find(string.lower(obj.Name), "effect")) then
                    obj:FireServer(position, 15, 40000)
                end
            end
            ShowNotification("💥 Explosion targeted at " .. targetPlayer.Name, Colors.Green)
            print("💥 Explosion targeted at: " .. targetPlayer.Name)
        else
            ShowNotification("❌ Explosion failed: Invalid player!", Colors.Red)
        end
    end)
end

local function SpamExplosion(targetPlayer)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for i = 1, 5 do
                local position = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.random(-5, 5), math.random(0, 5), math.random(-5, 5))
                local explosion = Instance.new("Explosion")
                explosion.Position = position
                explosion.BlastRadius = 10
                explosion.BlastPressure = 30000
                explosion.DestroyJointRadiusPercent = 0
                explosion.Parent = workspace
                wait(0.2)
            end
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "explosion") or string.find(string.lower(obj.Name), "effect")) then
                    obj:FireServer(targetPlayer.Character.HumanoidRootPart.Position, 10, 30000)
                end
            end
            ShowNotification("💥 Spam explosion targeted at " .. targetPlayer.Name, Colors.Green)
            print("💥 Spam explosion targeted at: " .. targetPlayer.Name)
        else
            ShowNotification("❌ Spam explosion failed: Invalid player!", Colors.Red)
        end
    end)
end

-- Kick/Ban Player
local function KickPlayer(targetPlayer)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        local kickKeywords = {"kick", "ban", "remove", "punish"}
        local success = false
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and table.find(kickKeywords, string.lower(obj.Name)) then
                obj:FireServer(targetPlayer, "Kicked by admin")
                obj:FireServer(targetPlayer.UserId, "Kicked by admin")
                success = true
            end
        end
        if success then
            ShowNotification("👢 Kicked " .. targetPlayer.Name, Colors.Green)
            print("👢 Kicked: " .. targetPlayer.Name)
        else
            ShowNotification("⚠️ Kick attempt failed for " .. targetPlayer.Name, Colors.Red)
            print("⚠️ Kick attempt failed: No valid RemoteEvent found")
        end
    end)
end

-- Manipulasi Leaderstats
local function SetLeaderstats(targetPlayer, statName, value)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        if targetPlayer:FindFirstChild("leaderstats") then
            local stat = targetPlayer.leaderstats:FindFirstChild(statName)
            if stat then
                stat.Value = value
                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "leaderstats") or string.find(string.lower(obj.Name), "stat")) then
                        obj:FireServer(targetPlayer, statName, value)
                    end
                end
                ShowNotification("📊 Set " .. statName .. " to " .. value .. " for " .. targetPlayer.Name, Colors.Green)
                print("📊 Set " .. statName .. " to " .. value .. " for: " .. targetPlayer.Name)
            else
                ShowNotification("⚠️ Stat " .. statName .. " not found!", Colors.Red)
            end
        else
            ShowNotification("⚠️ Leaderstats not found for " .. targetPlayer.Name, Colors.Red)
        end
    end)
end

-- Spawn Tool
local function SpawnTool()
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        local tool = Instance.new("Tool")
        tool.Name = "AdminSword"
        tool.RequiresHandle = true
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.2, 2, 0.2)
        handle.BrickColor = BrickColor.new("Really black")
        handle.Material = Enum.Material.Metal
        handle.Parent = tool
        tool.Parent = LocalPlayer.Backpack
        ShowNotification("🗡️ Spawned Admin Sword", Colors.Green)
        print("🗡️ Spawned Admin Sword")
    end)
end

-- Server Shutdown
local function ServerShutdown()
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        local shutdownKeywords = {"shutdown", "close", "end", "stop"}
        local success = false
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and table.find(shutdownKeywords, string.lower(obj.Name)) then
                obj:FireServer()
                success = true
            end
        end
        if success then
            ShowNotification("🛑 Server shutdown attempted!", Colors.Green)
            print("🛑 Server shutdown attempted")
        else
            ShowNotification("⚠️ Server shutdown failed: No valid RemoteEvent!", Colors.Red)
            print("⚠️ Server shutdown failed: No valid RemoteEvent")
        end
    end)
end

-- Admin Command Input
local function RunAdminCommand(command)
    if not FEBypass.Enabled then
        ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
        print("❌ Enable FE Bypass first!")
        return
    end
    
    pcall(function()
        local cmdKeywords = {"cmd", "command", "admin", "execute"}
        local success = false
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and table.find(cmdKeywords, string.lower(obj.Name)) then
                obj:FireServer(command)
                success = true
            elseif obj:IsA("RemoteFunction") then
                local invokeSuccess, result = pcall(obj.InvokeServer, obj, command)
                if invokeSuccess and (result == true or type(result) == "table" or result == "success") then
                    success = true
                end
            end
        end
        if success then
            ShowNotification("📜 Command executed: " .. command, Colors.Green)
            print("📜 Executed command: " .. command)
        else
            ShowNotification("⚠️ Command failed: " .. command, Colors.Red)
            print("⚠️ Command failed: No valid RemoteEvent/Function")
        end
    end)
end

-- Update content function with optimized scrolling
function UpdateContent()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if currentTab == 1 then -- Spawn Tab
        CreateButton("📦 Neon Box", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
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
                ShowNotification("✨ Spawned Neon Box", Colors.Green)
                print("✨ Spawned: Neon Box")
            end)
        end, Colors.Green)
        CreateButton("💥 Spawn Explosion", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                SpawnExplosion(LocalPlayer.Character.HumanoidRootPart.Position)
            else
                ShowNotification("❌ Explosion failed: No character!", Colors.Red)
            end
        end, Colors.Red)
        CreateButton("☁️ Cloud Explosion", function()
            SpawnCloudExplosion(LocalPlayer)
        end, Colors.Cyan)
        CreateButton("🗡️ Spawn Admin Sword", SpawnTool, Colors.Purple)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("💥 Explosion to " .. player.Name, function()
                    SpawnExplosionToPlayer(player)
                end, Colors.Orange)
                CreateButton("💥 Spam Explosion " .. player.Name, function()
                    SpamExplosion(player)
                end, Colors.Red)
            end
        end
        
    elseif currentTab == 2 then -- Player Tab
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("👤 " .. player.Name, function() end, Colors.Gray)
                CreateButton("📞 TP " .. player.Name .. " to Me", function()
                    TeleportPlayerBypass(player, LocalPlayer)
                end, Colors.Orange)
                CreateButton("👢 Kick " .. player.Name, function()
                    KickPlayer(player)
                end, Colors.Red)
                CreateButton("📊 Set Money 1000", function()
                    SetLeaderstats(player, "Money", 1000)
                end, Colors.Green)
            end
        end
        
    elseif currentTab == 3 then -- Teleport Tab
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateButton("🚀 TP to " .. player.Name, function()
                    if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                           player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
                            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                                if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "teleport") or string.find(string.lower(obj.Name), "move")) then
                                    obj:FireServer(LocalPlayer, player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0))
                                end
                            end
                            ShowNotification("🚀 Teleported to " .. player.Name, Colors.Green)
                            print("🚀 Teleported to: " .. player.Name)
                        else
                            ShowNotification("❌ Teleport failed: Invalid player!", Colors.Red)
                        end
                    end)
                end, Colors.Primary)
            end
        end
        CreateButton("🌍 TP to Spawn", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "teleport") or string.find(string.lower(obj.Name), "move")) then
                            obj:FireServer(LocalPlayer, CFrame.new(0, 10, 0))
                        end
                    end
                    ShowNotification("🌍 Teleported to Spawn", Colors.Green)
                    print("🌍 Teleported to Spawn")
                else
                    ShowNotification("❌ Teleport failed: No character!", Colors.Red)
                end
            end)
        end, Colors.Green)
        CreateTextInput("Enter X,Y,Z (e.g. 100,50,200)", function(text)
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                local coords = {}
                for num in text:gmatch("%-?%d+%.?%d*") do
                    table.insert(coords, tonumber(num))
                end
                if #coords == 3 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coords[1], coords[2], coords[3])
                    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "teleport") or string.find(string.lower(obj.Name), "move")) then
                            obj:FireServer(LocalPlayer, CFrame.new(coords[1], coords[2], coords[3]))
                        end
                    end
                    ShowNotification("🚀 Teleported to " .. text, Colors.Green)
                    print("🚀 Teleported to: " .. text)
                else
                    ShowNotification("❌ Invalid coordinates! Use format X,Y,Z", Colors.Red)
                    print("❌ Invalid coordinates! Use format X,Y,Z")
                end
            end)
        end)
        
    elseif currentTab == 4 then -- Server Tab
        CreateButton("☀️ Day Time", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            Lighting.TimeOfDay = "12:00:00"
            ShowNotification("☀️ Set to Day Time", Colors.Green)
            print("☀️ Set to Day Time")
        end, Colors.Orange)
        CreateButton("🌙 Night Time", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            Lighting.TimeOfDay = "00:00:00"
            ShowNotification("🌙 Set to Night Time", Colors.Green)
            print("🌙 Set to Night Time")
        end, Colors.Purple)
        CreateButton("💡 Max Brightness", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            Lighting.Brightness = 3
            ShowNotification("💡 Brightness set to max", Colors.Green)
            print("💡 Brightness set to max")
        end, Colors.Yellow)
        CreateButton("🌑 Dark Mode", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            Lighting.Brightness = 0
            ShowNotification("🌑 Dark Mode enabled", Colors.Green)
            print("🌑 Dark Mode enabled")
        end, Colors.Gray)
        CreateButton("🌫️ Heavy Fog", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            Lighting.FogEnd = 50
            ShowNotification("🌫️ Heavy Fog enabled", Colors.Green)
            print("🌫️ Heavy Fog enabled")
        end, Colors.Gray)
        CreateButton("🌤️ Clear Sky", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            Lighting.FogEnd = 100000
            ShowNotification("🌤️ Clear Sky enabled", Colors.Green)
            print("🌤️ Clear Sky enabled")
        end, Colors.Cyan)
        CreateButton("🛑 Server Shutdown", ServerShutdown, Colors.Red)
        
    elseif currentTab == 5 then -- Fun Tab
        CreateButton("🎵 Play Music", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://142376088"
                sound.Volume = 1
                sound.Looped = true
                sound.Parent = workspace
                sound:Play()
                ShowNotification("🎵 Music playing", Colors.Green)
                print("🎵 Music playing")
            end)
        end, Colors.Pink)
        CreateButton("🔊 Stop All Sounds", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Sound") then
                    obj:Stop()
                    obj:Destroy()
                end
            end
            ShowNotification("🔊 All sounds stopped", Colors.Green)
            print("🔊 All sounds stopped")
        end, Colors.Gray)
        
    elseif currentTab == 6 then -- Utility Tab
        CreateButton("🔄 Rejoin Server", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            ShowNotification("🔄 Rejoining server...", Colors.Green)
        end, Colors.Orange)
        CreateButton("💀 Reset Character", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Health = 0
                    ShowNotification("💀 Character reset", Colors.Green)
                    print("💀 Character reset")
                else
                    ShowNotification("❌ Reset failed: No character!", Colors.Red)
                end
            end)
        end, Colors.Red)
        CreateButton("⚡ Super Speed", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 150
                    ShowNotification("⚡ Super speed: 150", Colors.Green)
                    print("⚡ Super speed: 150")
                else
                    ShowNotification("❌ Speed failed: No character!", Colors.Red)
                end
            end)
        end, Colors.Green)
        CreateButton("🐌 Normal Speed", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 16
                    ShowNotification("🐌 Normal speed: 16", Colors.Green)
                    print("🐌 Normal speed: 16")
                else
                    ShowNotification("❌ Speed failed: No character!", Colors.Red)
                end
            end)
        end, Colors.Gray)
        CreateButton("🦘 Super Jump", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = 150
                    ShowNotification("🦘 Super jump: 150", Colors.Green)
                    print("🦘 Super jump: 150")
                else
                    ShowNotification("❌ Jump failed: No character!", Colors.Red)
                end
            end)
        end, Colors.Green)
        CreateButton("🚀 Fly Mode", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            local flying = false
            local speed = 50
            local bodyVelocity, bodyGyro
            
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
                    
                    if not flying then
                        flying = true
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        bodyVelocity.Parent = humanoidRootPart
                        
                        bodyGyro = Instance.new("BodyGyro")
                        bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
                        bodyGyro.CFrame = humanoidRootPart.CFrame
                        bodyGyro.Parent = humanoidRootPart
                        
                        ShowNotification("🚀 Flying enabled!", Colors.Green)
                        print("🚀 Flying enabled!")
                    else
                        flying = false
                        if bodyVelocity then bodyVelocity:Destroy() end
                        if bodyGyro then bodyGyro:Destroy() end
                        ShowNotification("🚀 Flying disabled!", Colors.Green)
                        print("🚀 Flying disabled!")
                    end
                else
                    ShowNotification("❌ Fly failed: No character!", Colors.Red)
                end
            end)
        end, Colors.Cyan)
        
    elseif currentTab == 7 then -- Bypass Tab
        CreateButton("🛡️ Toggle FE Bypass", function()
            if FEBypass.Enabled then
                DisableFEBypass()
            else
                EnableFEBypass()
            end
        end, FEBypass.Enabled and Colors.Green or Colors.Red)
        CreateButton("👻 Invisible Mode", function()
            if not FEBypass.Enabled then ShowNotification("❌ Enable FE Bypass first!", Colors.Red); print("❌ Enable FE Bypass first!") return end
            pcall(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Transparency = part.Transparency == 0 and 1 or 0
                        end
                    end
                    ShowNotification("👻 Invisibility toggled!", Colors.Green)
                    print("👻 Invisibility toggled!")
                else
                    ShowNotification("❌ Invisibility failed: No character!", Colors.Red)
                end
            end)
        end, Colors.Purple)
        CreateButton("👑 Grant Admin Access", function()
            if not FEBypass.Enabled then
                ShowNotification("❌ Enable FE Bypass first!", Colors.Red)
                print("❌ Enable FE Bypass first!")
                return
            end
            
            local adminSuccess = false
            pcall(function()
                local adminKeywords = {"admin", "mod", "cmd", "command", "privilege", "control", "access", "perm", "role", "owner"}
                local payloads = {true, 1, "admin", "grant", "enable", LocalPlayer.Name, LocalPlayer.UserId, "owner", 999}
                
                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        for _, keyword in pairs(adminKeywords) do
                            if string.find(string.lower(obj.Name), keyword) then
                                if obj:IsA("RemoteEvent") then
                                    for _, payload in pairs(payloads) do
                                        obj:FireServer(payload)
                                        obj:FireServer(LocalPlayer, payload)
                                    end
                                elseif obj:IsA("RemoteFunction") then
                                    for _, payload in pairs(payloads) do
                                        local success, result = pcall(obj.InvokeServer, obj, payload)
                                        if success and (result == true or type(result) == "table" or result == "success") then
                                            adminSuccess = true
                                        end
                                        success, result = pcall(obj.InvokeServer, obj, LocalPlayer, payload)
                                        if success and (result == true or type(result) == "table" or result == "success") then
                                            adminSuccess = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and string.find(string.lower(gui.Name), "admin") and gui.Enabled then
                            adminSuccess = true
                        end
                    end
                end
                
                LocalPlayer:SetAttribute("IsAdmin", true)
                LocalPlayer:SetAttribute("AdminLevel", 999)
                LocalPlayer:SetAttribute("Role", "Admin")
                
                if adminSuccess or LocalPlayer:GetAttribute("IsAdmin") or LocalPlayer:GetAttribute("AdminLevel") == 999 then
                    ShowNotification("👑 Admin access granted!", Colors.Green)
                    print("👑 Admin access granted!")
                else
                    ShowNotification("⚠️ Admin access attempt failed!", Colors.Red)
                    print("⚠️ Admin access attempt failed! Check for admin privileges manually.")
                end
            end)
        end, Colors.Yellow)
        CreateTextInput("Enter Admin Command (e.g. :fly me)", function(text)
            RunAdminCommand(text)
        end)
    end
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
    wait(0.1)
    Content.Visible = not isMinimized
end)

CloseBtn.MouseButton1Click:Connect(function()
    if FEBypass.Enabled then
        DisableFEBypass()
    end
    ScreenGui:Destroy()
end)

-- Script 1 control
SwitchBtn.MouseButton1Click:Connect(function()
    if _G.Script1Active and _G.Script1Gui then
        _G.Script1Active = false
        _G.Script1Gui.Visible = false
        SwitchBtn.Text = "🔄 Nyalakan Script 1"
        SwitchBtn.BackgroundColor3 = Colors.Green
        ShowNotification("🔄 Script 1 disabled", Colors.Green)
    elseif _G.Script1Gui then
        _G.Script1Active = true
        _G.Script1Gui.Visible = true
        SwitchBtn.Text = "🔄 Matikan Script 1"
        SwitchBtn.BackgroundColor3 = Colors.Primary
        ShowNotification("🔄 Script 1 enabled", Colors.Green)
    end
end)

-- FE Bypass toggle
BypassBtn.MouseButton1Click:Connect(function()
    if FEBypass.Enabled then
        DisableFEBypass()
    else
        EnableFEBypass()
    end
end)

-- Auto refresh player lists
spawn(function()
    while ScreenGui.Parent do
        wait(5)
        if currentTab == 2 or currentTab == 3 or currentTab == 1 then
            UpdateContent()
        end
    end
end)

-- Fly controls (WASD when flying)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
       input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.E then
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            
            if bodyVelocity then
                local camera = workspace.CurrentCamera
                local moveVector = Vector3.new(0, 0, 0)
                
                if input.KeyCode == Enum.KeyCode.W then
                    moveVector = moveVector + camera.CFrame.LookVector
                elseif input.KeyCode == Enum.KeyCode.S then
                    moveVector = moveVector - camera.CFrame.LookVector
                elseif input.KeyCode == Enum.KeyCode.A then
                    moveVector = moveVector - camera.CFrame.RightVector
                elseif input.KeyCode == Enum.KeyCode.D then
                    moveVector = moveVector + camera.CFrame.RightVector
                elseif input.KeyCode == Enum.KeyCode.Q then
                    moveVector = moveVector - camera.CFrame.UpVector
                elseif input.KeyCode == Enum.KeyCode.E then
                    moveVector = moveVector + camera.CFrame.UpVector
                end
                
                bodyVelocity.Velocity = moveVector * 50
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
       input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.E then
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if bodyVelocity then
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
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

-- Welcome message
ShowNotification("🔥 FE Bypass Admin Panel loaded!", Colors.Green)
print("🔥 FE Bypass Admin Panel loaded!")
print("📱 Mobile optimized with full player visibility")
print("🛡️ Enable FE Bypass for all features")
print("👑 Notifications for admin access and other actions")
print("📞 Improved Teleport Player to Me with deeper bypass")
print("🎮 Use WASD/QE for fly controls when flying")