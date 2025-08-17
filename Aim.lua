-- Aim.lua - Complete Aiming System Module by Fari Noveri

local AimModule = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local player
local character, humanoid, rootPart
local connections = {}
local settings
local mouse

-- Aim Settings
local aimSettings = {
    WallShoot = {enabled = false, range = 1000},
    Aimbot = {enabled = false, fov = 90, smoothness = 0.1, targetPart = "Head", ignoreTeam = true, visibleOnly = false},
    AimBullet = {enabled = false, prediction = 0.5, velocity = 2000, ignoreTeam = true},
    FastReload = {enabled = false, speed = 2},
    NoSpread = {enabled = false},
    NoRecoil = {enabled = false},
    InfiniteAmmo = {enabled = false},
    RapidFire = {enabled = false, rate = 0.1},
    HeadshotOnly = {enabled = false},
    SilentAim = {enabled = false, fov = 30}
}

-- State variables
local currentTarget = nil
local originalRecoil = {}
local originalSpread = {}
local aimConnection = nil
local reloadConnection = nil
local shootConnection = nil

-- Utility Functions
local function getClosestPlayer()
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    local playerPos = player.Character.HumanoidRootPart.Position
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Team check
            if aimSettings.Aimbot.ignoreTeam and otherPlayer.Team == player.Team then
                continue
            end
            
            local targetPos = otherPlayer.Character.HumanoidRootPart.Position
            local distance = (playerPos - targetPos).Magnitude
            
            -- FOV check
            if aimSettings.Aimbot.fov < 180 then
                local camera = Workspace.CurrentCamera
                local screenPos, onScreen = camera:WorldToScreenPoint(targetPos)
                if onScreen then
                    local centerX, centerY = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
                    local fovDistance = math.sqrt((screenPos.X - centerX)^2 + (screenPos.Y - centerY)^2)
                    local maxFovDistance = math.tan(math.rad(aimSettings.Aimbot.fov / 2)) * distance
                    if fovDistance > maxFovDistance then
                        continue
                    end
                end
            end
            
            -- Visibility check
            if aimSettings.Aimbot.visibleOnly then
                local raycast = Workspace:Raycast(playerPos, (targetPos - playerPos).Unit * distance)
                if raycast and raycast.Instance and not raycast.Instance:IsDescendantOf(otherPlayer.Character) then
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
    
    local targetPart = target.Character:FindFirstChild(aimSettings.Aimbot.targetPart)
    if not targetPart then
        targetPart = target.Character:FindFirstChild("HumanoidRootPart")
    end
    
    if not targetPart then return nil end
    
    local targetPos = targetPart.Position
    
    -- Prediction for moving targets
    if aimSettings.AimBullet.enabled and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetVelocity = target.Character.HumanoidRootPart.AssemblyLinearVelocity
        if targetVelocity.Magnitude > 1 then
            local distance = (player.Character.HumanoidRootPart.Position - targetPos).Magnitude
            local timeToHit = distance / aimSettings.AimBullet.velocity
            targetPos = targetPos + (targetVelocity * timeToHit * aimSettings.AimBullet.prediction)
        end
    end
    
    return targetPos
end

-- Wallshoot Functions
local function enableWallShoot()
    if not player.Character then return end
    
    -- Override raycast to ignore walls
    local originalRaycast = Workspace.Raycast
    Workspace.Raycast = function(self, origin, direction, raycastParams)
        if aimSettings.WallShoot.enabled then
            -- Modify raycast to only hit players
            if raycastParams then
                raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
                local playerChars = {}
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p ~= player then
                        table.insert(playerChars, p.Character)
                    end
                end
                raycastParams.FilterDescendantsInstances = playerChars
            end
        end
        return originalRaycast(self, origin, direction, raycastParams)
    end
    
    print("WallShoot enabled")
end

local function disableWallShoot()
    -- Restore original raycast (this is simplified - in practice you'd need to store the original)
    print("WallShoot disabled")
end

-- Aimbot Functions
local function enableAimbot()
    if aimConnection then aimConnection:Disconnect() end
    
    aimConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        currentTarget = getClosestPlayer()
        if not currentTarget then return end
        
        local targetPos = getTargetPosition(currentTarget)
        if not targetPos then return end
        
        local camera = Workspace.CurrentCamera
        local currentCFrame = camera.CFrame
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
        
        -- Smooth aiming
        local smoothedCFrame = currentCFrame:Lerp(targetCFrame, aimSettings.Aimbot.smoothness)
        camera.CFrame = smoothedCFrame
    end)
    
    print("Aimbot enabled")
end

local function disableAimbot()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    currentTarget = nil
    print("Aimbot disabled")
end

-- AimBullet Functions (Silent Aim)
local function enableAimBullet()
    -- Hook into shooting mechanics
    if shootConnection then shootConnection:Disconnect() end
    
    -- This would need to be adapted based on the specific game's shooting system
    -- Example for games using RemoteEvents
    local function hookRemoteEvent()
        local originalFireFunction
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "shoot") or string.find(string.lower(obj.Name), "fire")) then
                originalFireFunction = obj.FireServer
                obj.FireServer = function(self, ...)
                    local args = {...}
                    local target = getClosestPlayer()
                    
                    if target and aimSettings.AimBullet.enabled then
                        local targetPos = getTargetPosition(target)
                        if targetPos then
                            -- Modify shooting arguments to aim at target
                            if #args >= 1 then
                                args[1] = targetPos -- Assume first argument is position
                            end
                        end
                    end
                    
                    return originalFireFunction(self, unpack(args))
                end
                break
            end
        end
    end
    
    hookRemoteEvent()
    print("AimBullet enabled")
end

local function disableAimBullet()
    if shootConnection then
        shootConnection:Disconnect()
        shootConnection = nil
    end
    print("AimBullet disabled")
end

-- Fast Reload Functions
local function enableFastReload()
    if reloadConnection then reloadConnection:Disconnect() end
    
    reloadConnection = RunService.Heartbeat:Connect(function()
        if player.Character then
            -- Speed up reload animations and processes
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj:IsA("Animation") and string.find(string.lower(obj.Name), "reload") then
                    if obj.AnimationTrack then
                        obj.AnimationTrack:AdjustSpeed(aimSettings.FastReload.speed)
                    end
                end
            end
        end
    end)
    
    print("Fast Reload enabled")
end

local function disableFastReload()
    if reloadConnection then
        reloadConnection:Disconnect()
        reloadConnection = nil
    end
    print("Fast Reload disabled")
end

-- No Recoil Functions
local function enableNoRecoil()
    if player.Character then
        -- Store and modify recoil values
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj:IsA("NumberValue") and (string.find(string.lower(obj.Name), "recoil") or string.find(string.lower(obj.Name), "kick")) then
                originalRecoil[obj] = obj.Value
                obj.Value = 0
            end
        end
    end
    print("No Recoil enabled")
end

local function disableNoRecoil()
    for obj, originalValue in pairs(originalRecoil) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    originalRecoil = {}
    print("No Recoil disabled")
end

-- No Spread Functions
local function enableNoSpread()
    if player.Character then
        -- Store and modify spread values
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj:IsA("NumberValue") and string.find(string.lower(obj.Name), "spread") then
                originalSpread[obj] = obj.Value
                obj.Value = 0
            end
        end
    end
    print("No Spread enabled")
end

local function disableNoSpread()
    for obj, originalValue in pairs(originalSpread) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    originalSpread = {}
    print("No Spread disabled")
end

-- Infinite Ammo Functions
local function enableInfiniteAmmo()
    if player.Character then
        RunService.Heartbeat:Connect(function()
            if not aimSettings.InfiniteAmmo.enabled then return end
            
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj:IsA("IntValue") and (string.find(string.lower(obj.Name), "ammo") or string.find(string.lower(obj.Name), "bullet")) then
                    obj.Value = math.max(obj.Value, 999)
                end
            end
        end)
    end
    print("Infinite Ammo enabled")
end

-- Rapid Fire Functions
local function enableRapidFire()
    -- Override fire rate
    if player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj:IsA("NumberValue") and (string.find(string.lower(obj.Name), "firerate") or string.find(string.lower(obj.Name), "cooldown")) then
                obj.Value = aimSettings.RapidFire.rate
            end
        end
    end
    print("Rapid Fire enabled")
end

-- Module Functions
function AimModule.init(dependencies)
    player = dependencies.player
    character = dependencies.character
    humanoid = dependencies.humanoid
    rootPart = dependencies.rootPart
    settings = dependencies.settings
    connections = dependencies.connections
    
    mouse = player:GetMouse()
    
    print("Aim module initialized")
    return true
end

function AimModule.loadAimButtons(createButton, selectedPlayer, freecamEnabled, freecamPosition, toggleFreecam)
    -- WallShoot Toggle
    createButton("WallShoot", function()
        aimSettings.WallShoot.enabled = not aimSettings.WallShoot.enabled
        if aimSettings.WallShoot.enabled then
            enableWallShoot()
        else
            disableWallShoot()
        end
    end)
    
    -- Aimbot Toggle
    createButton("Aimbot", function()
        aimSettings.Aimbot.enabled = not aimSettings.Aimbot.enabled
        if aimSettings.Aimbot.enabled then
            enableAimbot()
        else
            disableAimbot()
        end
    end)
    
    -- AimBullet Toggle
    createButton("AimBullet (Silent)", function()
        aimSettings.AimBullet.enabled = not aimSettings.AimBullet.enabled
        if aimSettings.AimBullet.enabled then
            enableAimBullet()
        else
            disableAimBullet()
        end
    end)
    
    -- Fast Reload Toggle
    createButton("Fast Reload", function()
        aimSettings.FastReload.enabled = not aimSettings.FastReload.enabled
        if aimSettings.FastReload.enabled then
            enableFastReload()
        else
            disableFastReload()
        end
    end)
    
    -- No Recoil Toggle
    createButton("No Recoil", function()
        aimSettings.NoRecoil.enabled = not aimSettings.NoRecoil.enabled
        if aimSettings.NoRecoil.enabled then
            enableNoRecoil()
        else
            disableNoRecoil()
        end
    end)
    
    -- No Spread Toggle
    createButton("No Spread", function()
        aimSettings.NoSpread.enabled = not aimSettings.NoSpread.enabled
        if aimSettings.NoSpread.enabled then
            enableNoSpread()
        else
            disableNoSpread()
        end
    end)
    
    -- Infinite Ammo Toggle
    createButton("Infinite Ammo", function()
        aimSettings.InfiniteAmmo.enabled = not aimSettings.InfiniteAmmo.enabled
        if aimSettings.InfiniteAmmo.enabled then
            enableInfiniteAmmo()
        end
    end)
    
    -- Rapid Fire Toggle
    createButton("Rapid Fire", function()
        aimSettings.RapidFire.enabled = not aimSettings.RapidFire.enabled
        if aimSettings.RapidFire.enabled then
            enableRapidFire()
        end
    end)
    
    -- Headshot Only Toggle
    createButton("Headshot Only", function()
        aimSettings.HeadshotOnly.enabled = not aimSettings.HeadshotOnly.enabled
        if aimSettings.HeadshotOnly.enabled then
            aimSettings.Aimbot.targetPart = "Head"
        else
            aimSettings.Aimbot.targetPart = "HumanoidRootPart"
        end
    end)
    
    -- Silent Aim Toggle
    createButton("Silent Aim", function()
        aimSettings.SilentAim.enabled = not aimSettings.SilentAim.enabled
        if aimSettings.SilentAim.enabled then
            enableAimBullet() -- Silent aim uses similar logic to AimBullet
        else
            disableAimBullet()
        end
    end)
    
    -- Settings Buttons
    createButton("Aimbot FOV +", function()
        aimSettings.Aimbot.fov = math.min(aimSettings.Aimbot.fov + 10, 180)
        print("Aimbot FOV: " .. aimSettings.Aimbot.fov)
    end)
    
    createButton("Aimbot FOV -", function()
        aimSettings.Aimbot.fov = math.max(aimSettings.Aimbot.fov - 10, 10)
        print("Aimbot FOV: " .. aimSettings.Aimbot.fov)
    end)
    
    createButton("Smoothness +", function()
        aimSettings.Aimbot.smoothness = math.min(aimSettings.Aimbot.smoothness + 0.05, 1)
        print("Aimbot Smoothness: " .. aimSettings.Aimbot.smoothness)
    end)
    
    createButton("Smoothness -", function()
        aimSettings.Aimbot.smoothness = math.max(aimSettings.Aimbot.smoothness - 0.05, 0.01)
        print("Aimbot Smoothness: " .. aimSettings.Aimbot.smoothness)
    end)
    
    createButton("Toggle Team Ignore", function()
        aimSettings.Aimbot.ignoreTeam = not aimSettings.Aimbot.ignoreTeam
        aimSettings.AimBullet.ignoreTeam = aimSettings.Aimbot.ignoreTeam
        print("Ignore Team: " .. tostring(aimSettings.Aimbot.ignoreTeam))
    end)
    
    createButton("Toggle Visible Only", function()
        aimSettings.Aimbot.visibleOnly = not aimSettings.Aimbot.visibleOnly
        print("Visible Only: " .. tostring(aimSettings.Aimbot.visibleOnly))
    end)
end

function AimModule.resetStates()
    -- Disable all aim features
    aimSettings.WallShoot.enabled = false
    aimSettings.Aimbot.enabled = false
    aimSettings.AimBullet.enabled = false
    aimSettings.FastReload.enabled = false
    aimSettings.NoRecoil.enabled = false
    aimSettings.NoSpread.enabled = false
    aimSettings.InfiniteAmmo.enabled = false
    aimSettings.RapidFire.enabled = false
    aimSettings.HeadshotOnly.enabled = false
    aimSettings.SilentAim.enabled = false
    
    -- Disconnect connections
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    if reloadConnection then
        reloadConnection:Disconnect()
        reloadConnection = nil
    end
    if shootConnection then
        shootConnection:Disconnect()
        shootConnection = nil
    end
    
    -- Restore original values
    disableNoRecoil()
    disableNoSpread()
    disableWallShoot()
    
    currentTarget = nil
    print("Aim module states reset")
end

return AimModule