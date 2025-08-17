-- Aim.lua - Universal Aiming System Module (Simplified & Fixed)

local AimModule = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Aim Settings
local aimSettings = {
    WallShoot = {enabled = false},
    Aimbot = {enabled = false, fov = 90, smoothness = 0.1, targetPart = "Head", ignoreTeam = true, visibleOnly = false},
    AimBullet = {enabled = false, prediction = 0.5},
    FastReload = {enabled = false, speed = 2},
    NoSpread = {enabled = false},
    NoRecoil = {enabled = false},
    InfiniteAmmo = {enabled = false},
    RapidFire = {enabled = false, rate = 0.05},
    HeadshotOnly = {enabled = false},
    SilentAim = {enabled = false}
}

-- State variables
local currentTarget = nil
local connections = {}
local hookedEvents = {}
local originalValues = {}

-- Utility Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Error in safeCall: " .. tostring(result))
    end
    return success, result
end

local function getClosestPlayer()
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myPos = player.Character.HumanoidRootPart.Position
    local camera = workspace.CurrentCamera
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local hrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            -- Team check
            if aimSettings.Aimbot.ignoreTeam and otherPlayer.Team and player.Team and otherPlayer.Team == player.Team then
                continue
            end
            
            local distance = (myPos - hrp.Position).Magnitude
            
            -- FOV check
            if aimSettings.Aimbot.fov < 180 and camera then
                local screenPos, onScreen = camera:WorldToScreenPoint(hrp.Position)
                if onScreen then
                    local centerX, centerY = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
                    local fovDistance = math.sqrt((screenPos.X - centerX)^2 + (screenPos.Y - centerY)^2)
                    local maxFovDistance = math.tan(math.rad(aimSettings.Aimbot.fov / 2)) * distance
                    if fovDistance > maxFovDistance then continue end
                end
            end
            
            -- Visibility check
            if aimSettings.Aimbot.visibleOnly then
                local ray = Ray.new(myPos, (hrp.Position - myPos).Unit * distance)
                local hit, pos = workspace:FindPartOnRay(ray, player.Character)
                if hit and not hit:IsDescendantOf(otherPlayer.Character) then
                    continue
                end
            end
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = otherPlayer
            end
        end
    end
    
    return closestPlayer
end

local function getTargetPosition(target)
    if not target or not target.Character then return nil end
    
    local part = target.Character:FindFirstChild(aimSettings.Aimbot.targetPart) or 
                 target.Character:FindFirstChild("Head") or 
                 target.Character:FindFirstChild("HumanoidRootPart")
    
    if not part then return nil end
    
    local pos = part.Position
    
    -- Simple prediction
    if aimSettings.AimBullet.enabled and target.Character.HumanoidRootPart then
        local velocity = target.Character.HumanoidRootPart.Velocity
        if velocity.Magnitude > 5 then
            local distance = (player.Character.HumanoidRootPart.Position - pos).Magnitude
            local time = distance / 1000 -- Assume bullet speed
            pos = pos + (velocity * time * aimSettings.AimBullet.prediction)
        end
    end
    
    return pos
end

-- Simple Aimbot
local function enableAimbot()
    if connections.aimbot then connections.aimbot:Disconnect() end
    
    connections.aimbot = RunService.Heartbeat:Connect(function()
        if not aimSettings.Aimbot.enabled then return end
        if not player.Character or not workspace.CurrentCamera then return end
        
        currentTarget = getClosestPlayer()
        if not currentTarget then return end
        
        local targetPos = getTargetPosition(currentTarget)
        if not targetPos then return end
        
        local camera = workspace.CurrentCamera
        local currentCF = camera.CFrame
        local targetCF = CFrame.lookAt(camera.CFrame.Position, targetPos)
        
        -- Smooth aim
        camera.CFrame = currentCF:Lerp(targetCF, aimSettings.Aimbot.smoothness)
    end)
    
    print("✅ Aimbot enabled")
end

local function disableAimbot()
    if connections.aimbot then
        connections.aimbot:Disconnect()
        connections.aimbot = nil
    end
    currentTarget = nil
    print("❌ Aimbot disabled")
end

-- Simple Silent Aim (Hook mouse events)
local function enableSilentAim()
    if not mouse then return end
    
    -- Override mouse Hit and Target
    local mt = getrawmetatable(mouse)
    local oldIndex = mt.__index
    
    safeCall(function()
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            if key == "Hit" or key == "Target" then
                if aimSettings.SilentAim.enabled or aimSettings.AimBullet.enabled then
                    local target = getClosestPlayer()
                    if target then
                        local pos = getTargetPosition(target)
                        if pos then
                            if key == "Hit" then
                                return CFrame.new(pos)
                            elseif key == "Target" then
                                local part = target.Character:FindFirstChild(aimSettings.Aimbot.targetPart)
                                return part or target.Character.HumanoidRootPart
                            end
                        end
                    end
                end
            end
            return oldIndex(self, key)
        end)
        setreadonly(mt, true)
    end)
    
    print("✅ Silent Aim enabled")
end

-- Universal Value Modifier
local function modifyValues(searchTerms, newValue, restore)
    local function scanObject(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local name = child.Name:lower()
                for _, term in pairs(searchTerms) do
                    if name:find(term) then
                        if restore and originalValues[child] then
                            child.Value = originalValues[child]
                        elseif not restore then
                            if not originalValues[child] then
                                originalValues[child] = child.Value
                            end
                            child.Value = newValue
                        end
                        print((restore and "❌" or "✅") .. " Modified: " .. child.Name .. " = " .. tostring(child.Value))
                    end
                end
            end
            if #child:GetChildren() > 0 then
                scanObject(child)
            end
        end
    end
    
    -- Scan player character
    if player.Character then
        scanObject(player.Character)
    end
    
    -- Scan equipped tools
    if player.Character then
        for _, child in pairs(player.Character:GetChildren()) do
            if child:IsA("Tool") then
                scanObject(child)
            end
        end
    end
    
    -- Scan backpack
    if player.Backpack then
        scanObject(player.Backpack)
    end
end

-- Feature Functions
local function enableNoRecoil()
    modifyValues({"recoil", "kick", "sway"}, 0, false)
    print("✅ No Recoil enabled")
end

local function disableNoRecoil()
    modifyValues({"recoil", "kick", "sway"}, 0, true)
    print("❌ No Recoil disabled")
end

local function enableNoSpread()
    modifyValues({"spread", "accuracy", "deviation"}, 0, false)
    print("✅ No Spread enabled")
end

local function disableNoSpread()
    modifyValues({"spread", "accuracy", "deviation"}, 0, true)
    print("❌ No Spread disabled")
end

local function enableRapidFire()
    modifyValues({"firerate", "cooldown", "delay", "rpm"}, aimSettings.RapidFire.rate, false)
    print("✅ Rapid Fire enabled")
end

local function enableInfiniteAmmo()
    if connections.ammo then connections.ammo:Disconnect() end
    
    connections.ammo = RunService.Heartbeat:Connect(function()
        if not aimSettings.InfiniteAmmo.enabled then return end
        modifyValues({"ammo", "bullet", "mag", "magazine"}, 999, false)
    end)
    
    print("✅ Infinite Ammo enabled")
end

local function disableInfiniteAmmo()
    if connections.ammo then
        connections.ammo:Disconnect()
        connections.ammo = nil
    end
    print("❌ Infinite Ammo disabled")
end

local function enableFastReload()
    if connections.reload then connections.reload:Disconnect() end
    
    connections.reload = RunService.Heartbeat:Connect(function()
        if not aimSettings.FastReload.enabled then return end
        
        -- Speed up reload animations
        if player.Character then
            for _, track in pairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
                if track.Name:lower():find("reload") then
                    track:AdjustSpeed(aimSettings.FastReload.speed)
                end
            end
        end
        
        modifyValues({"reload"}, 0.1, false)
    end)
    
    print("✅ Fast Reload enabled")
end

local function disableFastReload()
    if connections.reload then
        connections.reload:Disconnect()
        connections.reload = nil
    end
    print("❌ Fast Reload disabled")
end

-- Universal RemoteEvent Hook
local function hookAllRemotes()
    local function hookRemote(remote)
        if hookedEvents[remote] then return end
        
        local oldFireServer = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            
            if (aimSettings.AimBullet.enabled or aimSettings.SilentAim.enabled) then
                local target = getClosestPlayer()
                if target then
                    local pos = getTargetPosition(target)
                    if pos then
                        -- Try to replace Vector3 arguments
                        for i = 1, #args do
                            if typeof(args[i]) == "Vector3" then
                                args[i] = pos
                                break
                            end
                        end
                    end
                end
            end
            
            return oldFireServer(self, unpack(args))
        end
        
        hookedEvents[remote] = true
        print("🔗 Hooked: " .. remote.Name)
    end
    
    -- Hook existing remotes
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            hookRemote(obj)
        end
    end
    
    -- Hook new remotes
    ReplicatedStorage.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then
            wait(0.1)
            hookRemote(obj)
        end
    end)
end

-- Module Functions
function AimModule.init(dependencies)
    print("🚀 Initializing Universal Aim Module...")
    
    -- Hook all remotes for silent aim
    safeCall(hookAllRemotes)
    safeCall(enableSilentAim)
    
    print("✅ Aim module initialized successfully")
    return true
end

function AimModule.loadAimButtons(createButton)
    if not createButton then
        warn("❌ createButton function not provided!")
        return
    end
    
    -- Main Features
    createButton("Aimbot", function()
        aimSettings.Aimbot.enabled = not aimSettings.Aimbot.enabled
        if aimSettings.Aimbot.enabled then
            enableAimbot()
        else
            disableAimbot()
        end
        return aimSettings.Aimbot.enabled
    end)
    
    createButton("Silent Aim", function()
        aimSettings.SilentAim.enabled = not aimSettings.SilentAim.enabled
        aimSettings.AimBullet.enabled = aimSettings.SilentAim.enabled
        print((aimSettings.SilentAim.enabled and "✅" or "❌") .. " Silent Aim: " .. tostring(aimSettings.SilentAim.enabled))
        return aimSettings.SilentAim.enabled
    end)
    
    createButton("No Recoil", function()
        aimSettings.NoRecoil.enabled = not aimSettings.NoRecoil.enabled
        if aimSettings.NoRecoil.enabled then
            enableNoRecoil()
        else
            disableNoRecoil()
        end
        return aimSettings.NoRecoil.enabled
    end)
    
    createButton("No Spread", function()
        aimSettings.NoSpread.enabled = not aimSettings.NoSpread.enabled
        if aimSettings.NoSpread.enabled then
            enableNoSpread()
        else
            disableNoSpread()
        end
        return aimSettings.NoSpread.enabled
    end)
    
    createButton("Rapid Fire", function()
        aimSettings.RapidFire.enabled = not aimSettings.RapidFire.enabled
        if aimSettings.RapidFire.enabled then
            enableRapidFire()
        end
        print((aimSettings.RapidFire.enabled and "✅" or "❌") .. " Rapid Fire: " .. tostring(aimSettings.RapidFire.enabled))
        return aimSettings.RapidFire.enabled
    end)
    
    createButton("Infinite Ammo", function()
        aimSettings.InfiniteAmmo.enabled = not aimSettings.InfiniteAmmo.enabled
        if aimSettings.InfiniteAmmo.enabled then
            enableInfiniteAmmo()
        else
            disableInfiniteAmmo()
        end
        return aimSettings.InfiniteAmmo.enabled
    end)
    
    createButton("Fast Reload", function()
        aimSettings.FastReload.enabled = not aimSettings.FastReload.enabled
        if aimSettings.FastReload.enabled then
            enableFastReload()
        else
            disableFastReload()
        end
        return aimSettings.FastReload.enabled
    end)
    
    createButton("Headshot Only", function()
        aimSettings.HeadshotOnly.enabled = not aimSettings.HeadshotOnly.enabled
        aimSettings.Aimbot.targetPart = aimSettings.HeadshotOnly.enabled and "Head" or "HumanoidRootPart"
        print((aimSettings.HeadshotOnly.enabled and "✅" or "❌") .. " Headshot Only: " .. tostring(aimSettings.HeadshotOnly.enabled))
        return aimSettings.HeadshotOnly.enabled
    end)
    
    -- Settings
    createButton("FOV +10", function()
        aimSettings.Aimbot.fov = math.min(aimSettings.Aimbot.fov + 10, 180)
        print("📐 FOV: " .. aimSettings.Aimbot.fov)
        return false
    end)
    
    createButton("FOV -10", function()
        aimSettings.Aimbot.fov = math.max(aimSettings.Aimbot.fov - 10, 30)
        print("📐 FOV: " .. aimSettings.Aimbot.fov)
        return false
    end)
    
    createButton("Smooth +", function()
        aimSettings.Aimbot.smoothness = math.min(aimSettings.Aimbot.smoothness + 0.1, 1)
        print("🎯 Smoothness: " .. string.format("%.1f", aimSettings.Aimbot.smoothness))
        return false
    end)
    
    createButton("Smooth -", function()
        aimSettings.Aimbot.smoothness = math.max(aimSettings.Aimbot.smoothness - 0.1, 0.1)
        print("🎯 Smoothness: " .. string.format("%.1f", aimSettings.Aimbot.smoothness))
        return false
    end)
    
    createButton("Toggle Team Check", function()
        aimSettings.Aimbot.ignoreTeam = not aimSettings.Aimbot.ignoreTeam
        print("👥 Ignore Team: " .. tostring(aimSettings.Aimbot.ignoreTeam))
        return aimSettings.Aimbot.ignoreTeam
    end)
    
    createButton("Toggle Wallcheck", function()
        aimSettings.Aimbot.visibleOnly = not aimSettings.Aimbot.visibleOnly
        print("👁️ Visible Only: " .. tostring(aimSettings.Aimbot.visibleOnly))
        return aimSettings.Aimbot.visibleOnly
    end)
    
    print("🎮 All aim buttons loaded successfully!")
end

function AimModule.resetStates()
    print("🔄 Resetting all aim states...")
    
    -- Disable all features
    for feature, data in pairs(aimSettings) do
        if type(data) == "table" and data.enabled ~= nil then
            data.enabled = false
        end
    end
    
    -- Disconnect all connections
    for name, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
            connections[name] = nil
        end
    end
    
    -- Restore original values
    for obj, value in pairs(originalValues) do
        if obj and obj.Parent then
            obj.Value = value
        end
    end
    originalValues = {}
    
    -- Clear other states
    currentTarget = nil
    hookedEvents = {}
    
    print("✅ All aim states reset successfully")
end

-- Debug functions
function AimModule.getSettings()
    return aimSettings
end

function AimModule.getCurrentTarget()
    return currentTarget
end

function AimModule.printStatus()
    print("=== AIM MODULE STATUS ===")
    for feature, data in pairs(aimSettings) do
        if type(data) == "table" and data.enabled ~= nil then
            print(feature .. ": " .. (data.enabled and "✅" or "❌"))
        end
    end
    print("Current Target: " .. (currentTarget and currentTarget.Name or "None"))
    print("========================")
end

return AimModule