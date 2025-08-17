-- Aim.lua - Fixed Complete Aiming System Module by Fari Noveri

local AimModule = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer -- Fixed: Initialize player
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
local ammoConnection = nil
local originalRaycast = nil

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

-- Fixed: Store original raycast properly
local function enableWallShoot()
    if not originalRaycast then
        originalRaycast = Workspace.Raycast
    end
    
    -- Override raycast to ignore walls
    Workspace.Raycast = function(self, origin, direction, raycastParams)
        if aimSettings.WallShoot.enabled then
            -- Create new raycast params if none provided
            if not raycastParams then
                raycastParams = RaycastParams.new()
            end
            
            -- Modify raycast to only hit players
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            local playerChars = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p ~= player then
                    table.insert(playerChars, p.Character)
                end
            end
            raycastParams.FilterDescendantsInstances = playerChars
        end
        return originalRaycast(self, origin, direction, raycastParams)
    end
    
    print("WallShoot enabled")
end

local function disableWallShoot()
    if originalRaycast then
        Workspace.Raycast = originalRaycast
        print("WallShoot disabled - Original raycast restored")
    end
end

-- Aimbot Functions
local function enableAimbot()
    if aimConnection then aimConnection:Disconnect() end
    
    aimConnection = RunService.Heartbeat:Connect(function()
        if not aimSettings.Aimbot.enabled then return end -- Added check
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

-- Fixed: Better RemoteEvent detection and hooking
local function enableAimBullet()
    if shootConnection then shootConnection:Disconnect() end
    
    local function hookRemoteEvent()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = string.lower(obj.Name)
                if string.find(name, "shoot") or string.find(name, "fire") or string.find(name, "bullet") then
                    local originalFireServer = obj.FireServer
                    
                    obj.FireServer = function(self, ...)
                        local args = {...}
                        local target = getClosestPlayer()
                        
                        if target and aimSettings.AimBullet.enabled then
                            local targetPos = getTargetPosition(target)
                            if targetPos then
                                -- Try to modify different argument positions
                                if #args >= 1 and typeof(args[1]) == "Vector3" then
                                    args[1] = targetPos
                                elseif #args >= 2 and typeof(args[2]) == "Vector3" then
                                    args[2] = targetPos
                                end
                            end
                        end
                        
                        return originalFireServer(self, unpack(args))
                    end
                    print("Hooked RemoteEvent: " .. obj.Name)
                end
            end
        end
    end
    
    -- Also hook new RemoteEvents that might be created
    shootConnection = ReplicatedStorage.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if string.find(name, "shoot") or string.find(name, "fire") or string.find(name, "bullet") then
                wait(0.1) -- Small delay to ensure the event is fully loaded
                hookRemoteEvent()
            end
        end
    end)
    
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

-- Fixed: Better reload detection
local function enableFastReload()
    if reloadConnection then reloadConnection:Disconnect() end
    
    reloadConnection = RunService.Heartbeat:Connect(function()
        if not aimSettings.FastReload.enabled then return end
        
        if player.Character then
            -- Speed up reload animations
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj:IsA("AnimationTrack") then
                    local name = string.lower(obj.Animation.AnimationId)
                    if string.find(name, "reload") then
                        obj:AdjustSpeed(aimSettings.FastReload.speed)
                    end
                end
            end
            
            -- Also check for NumberValues related to reload time
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj:IsA("NumberValue") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "reload") and obj.Value > 0 then
                        obj.Value = obj.Value / aimSettings.FastReload.speed
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

-- Fixed: Better recoil detection
local function enableNoRecoil()
    if player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj:IsA("NumberValue") then
                local name = string.lower(obj.Name)
                if string.find(name, "recoil") or string.find(name, "kick") or string.find(name, "sway") then
                    if not originalRecoil[obj] then -- Prevent overwriting
                        originalRecoil[obj] = obj.Value
                    end
                    obj.Value = 0
                end
            end
        end
        
        -- Also check in ReplicatedStorage or other locations
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("NumberValue") then
                local name = string.lower(obj.Name)
                if string.find(name, "recoil") and obj.Parent.Name == player.Name then
                    if not originalRecoil[obj] then
                        originalRecoil[obj] = obj.Value
                    end
                    obj.Value = 0
                end
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

-- Fixed: Better spread detection
local function enableNoSpread()
    if player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj:IsA("NumberValue") then
                local name = string.lower(obj.Name)
                if string.find(name, "spread") or string.find(name, "accuracy") then
                    if not originalSpread[obj] then
                        originalSpread[obj] = obj.Value
                    end
                    obj.Value = 0
                end
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

-- Fixed: Better infinite ammo implementation
local function enableInfiniteAmmo()
    if ammoConnection then ammoConnection:Disconnect() end
    
    ammoConnection = RunService.Heartbeat:Connect(function()
        if not aimSettings.InfiniteAmmo.enabled then return end
        
        if player.Character then
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "ammo") or string.find(name, "bullet") or string.find(name, "mag") then
                        if obj.Value < 999 then
                            obj.Value = 999
                        end
                    end
                end
            end
        end
        
        -- Also check player's backpack/tools
        if player.Backpack then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                            local name = string.lower(obj.Name)
                            if string.find(name, "ammo") or string.find(name, "bullet") then
                                if obj.Value < 999 then
                                    obj.Value = 999
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    print("Infinite Ammo enabled")
end

local function disableInfiniteAmmo()
    if ammoConnection then
        ammoConnection:Disconnect()
        ammoConnection = nil
    end
    print("Infinite Ammo disabled")
end

-- Fixed: Better rapid fire implementation
local function enableRapidFire()
    if player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj:IsA("NumberValue") then
                local name = string.lower(obj.Name)
                if string.find(name, "firerate") or string.find(name, "cooldown") or string.find(name, "delay") then
                    obj.Value = aimSettings.RapidFire.rate
                end
            end
        end
    end
    
    -- Also check equipped tools
    if player.Character and player.Character:FindFirstChildOfClass("Tool") then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("NumberValue") then
                local name = string.lower(obj.Name)
                if string.find(name, "firerate") or string.find(name, "cooldown") then
                    obj.Value = aimSettings.RapidFire.rate
                end
            end
        end
    end
    
    print("Rapid Fire enabled")
end

-- Module Functions
function AimModule.init(dependencies)
    -- Use LocalPlayer if dependencies don't provide player
    player = dependencies and dependencies.player or Players.LocalPlayer
    character = dependencies and dependencies.character
    humanoid = dependencies and dependencies.humanoid
    rootPart = dependencies and dependencies.rootPart
    settings = dependencies and dependencies.settings
    connections = dependencies and dependencies.connections or {}
    
    mouse = player:GetMouse()
    
    print("Aim module initialized")
    return true
end

function AimModule.loadAimButtons(createButton, selectedPlayer, freecamEnabled, freecamPosition, toggleFreecam)
    if not createButton then
        warn("createButton function not provided!")
        return
    end
    
    -- WallShoot Toggle
    createButton("WallShoot", function()
        aimSettings.WallShoot.enabled = not aimSettings.WallShoot.enabled
        print("WallShoot toggled: " .. tostring(aimSettings.WallShoot.enabled))
        
        if aimSettings.WallShoot.enabled then
            enableWallShoot()
        else
            disableWallShoot()
        end
    end)
    
    -- Aimbot Toggle
    createButton("Aimbot", function()
        aimSettings.Aimbot.enabled = not aimSettings.Aimbot.enabled
        print("Aimbot toggled: " .. tostring(aimSettings.Aimbot.enabled))
        
        if aimSettings.Aimbot.enabled then
            enableAimbot()
        else
            disableAimbot()
        end
    end)
    
    -- AimBullet Toggle
    createButton("AimBullet (Silent)", function()
        aimSettings.AimBullet.enabled = not aimSettings.AimBullet.enabled
        print("AimBullet toggled: " .. tostring(aimSettings.AimBullet.enabled))
        
        if aimSettings.AimBullet.enabled then
            enableAimBullet()
        else
            disableAimBullet()
        end
    end)
    
    -- Fast Reload Toggle
    createButton("Fast Reload", function()
        aimSettings.FastReload.enabled = not aimSettings.FastReload.enabled
        print("Fast Reload toggled: " .. tostring(aimSettings.FastReload.enabled))
        
        if aimSettings.FastReload.enabled then
            enableFastReload()
        else
            disableFastReload()
        end
    end)
    
    -- No Recoil Toggle
    createButton("No Recoil", function()
        aimSettings.NoRecoil.enabled = not aimSettings.NoRecoil.enabled
        print("No Recoil toggled: " .. tostring(aimSettings.NoRecoil.enabled))
        
        if aimSettings.NoRecoil.enabled then
            enableNoRecoil()
        else
            disableNoRecoil()
        end
    end)
    
    -- No Spread Toggle
    createButton("No Spread", function()
        aimSettings.NoSpread.enabled = not aimSettings.NoSpread.enabled
        print("No Spread toggled: " .. tostring(aimSettings.NoSpread.enabled))
        
        if aimSettings.NoSpread.enabled then
            enableNoSpread()
        else
            disableNoSpread()
        end
    end)
    
    -- Infinite Ammo Toggle
    createButton("Infinite Ammo", function()
        aimSettings.InfiniteAmmo.enabled = not aimSettings.InfiniteAmmo.enabled
        print("Infinite Ammo toggled: " .. tostring(aimSettings.InfiniteAmmo.enabled))
        
        if aimSettings.InfiniteAmmo.enabled then
            enableInfiniteAmmo()
        else
            disableInfiniteAmmo()
        end
    end)
    
    -- Rapid Fire Toggle
    createButton("Rapid Fire", function()
        aimSettings.RapidFire.enabled = not aimSettings.RapidFire.enabled
        print("Rapid Fire toggled: " .. tostring(aimSettings.RapidFire.enabled))
        
        if aimSettings.RapidFire.enabled then
            enableRapidFire()
        end
    end)
    
    -- Headshot Only Toggle
    createButton("Headshot Only", function()
        aimSettings.HeadshotOnly.enabled = not aimSettings.HeadshotOnly.enabled
        print("Headshot Only toggled: " .. tostring(aimSettings.HeadshotOnly.enabled))
        
        if aimSettings.HeadshotOnly.enabled then
            aimSettings.Aimbot.targetPart = "Head"
        else
            aimSettings.Aimbot.targetPart = "HumanoidRootPart"
        end
    end)
    
    -- Silent Aim Toggle
    createButton("Silent Aim", function()
        aimSettings.SilentAim.enabled = not aimSettings.SilentAim.enabled
        print("Silent Aim toggled: " .. tostring(aimSettings.SilentAim.enabled))
        
        if aimSettings.SilentAim.enabled then
            aimSettings.AimBullet.enabled = true
            enableAimBullet()
        else
            aimSettings.AimBullet.enabled = false
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
    
    print("Aim buttons loaded successfully")
end

function AimModule.resetStates()
    print("Resetting aim module states...")
    
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
    
    -- Disconnect all connections
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
    if ammoConnection then
        ammoConnection:Disconnect()
        ammoConnection = nil
    end
    
    -- Restore original values
    disableNoRecoil()
    disableNoSpread()
    disableWallShoot()
    disableInfiniteAmmo()
    
    currentTarget = nil
    print("Aim module states reset successfully")
end

-- Getter functions for debugging
function AimModule.getSettings()
    return aimSettings
end

function AimModule.getCurrentTarget()
    return currentTarget
end

return AimModule