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
local player = Players.LocalPlayer
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
local hookedRemotes = {}

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
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                raycastParams.FilterDescendantsInstances = {player.Character}
                
                local raycast = workspace:Raycast(playerPos, (targetPos - playerPos).Unit * distance, raycastParams)
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
        local targetVelocity = target.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
        if targetVelocity.Magnitude > 1 then
            local distance = (player.Character.HumanoidRootPart.Position - targetPos).Magnitude
            local timeToHit = distance / aimSettings.AimBullet.velocity
            targetPos = targetPos + (targetVelocity * timeToHit * aimSettings.AimBullet.prediction)
        end
    end
    
    return targetPos
end

-- Fixed WallShoot function
local function enableWallShoot()
    -- Hook workspace:Raycast method properly
    if not originalRaycast then
        originalRaycast = workspace.Raycast
        
        workspace.Raycast = function(self, origin, direction, raycastParams)
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
    end
    
    print("WallShoot enabled")
end

local function disableWallShoot()
    if originalRaycast then
        workspace.Raycast = originalRaycast
        originalRaycast = nil
        print("WallShoot disabled")
    end
end

-- Aimbot Functions
local function enableAimbot()
    if aimConnection then aimConnection:Disconnect() end
    
    aimConnection = RunService.Heartbeat:Connect(function()
        if not aimSettings.Aimbot.enabled then return end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        currentTarget = getClosestPlayer()
        if not currentTarget then return end
        
        local targetPos = getTargetPosition(currentTarget)
        if not targetPos then return end
        
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
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

-- Fixed RemoteEvent hooking
local function enableAimBullet()
    local function hookRemoteEvent(remoteEvent)
        if hookedRemotes[remoteEvent] then return end -- Prevent double hooking
        
        local mt = getrawmetatable(remoteEvent)
        if not mt then return end
        
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if self == remoteEvent and method == "FireServer" and aimSettings.AimBullet.enabled then
                local target = getClosestPlayer()
                if target then
                    local targetPos = getTargetPosition(target)
                    if targetPos then
                        -- Modify arguments based on common patterns
                        for i = 1, #args do
                            if typeof(args[i]) == "Vector3" then
                                args[i] = targetPos
                                break
                            elseif typeof(args[i]) == "table" and args[i].Position then
                                args[i].Position = targetPos
                                break
                            elseif typeof(args[i]) == "CFrame" then
                                args[i] = CFrame.new(args[i].Position, targetPos)
                                break
                            end
                        end
                    end
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
        
        setreadonly(mt, true)
        hookedRemotes[remoteEvent] = true
        print("Hooked RemoteEvent: " .. remoteEvent.Name)
    end
    
    -- Hook existing RemoteEvents
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if string.find(name, "shoot") or string.find(name, "fire") or 
               string.find(name, "bullet") or string.find(name, "weapon") or
               string.find(name, "gun") then
                hookRemoteEvent(obj)
            end
        end
    end
    
    -- Hook new RemoteEvents
    if shootConnection then shootConnection:Disconnect() end
    shootConnection = ReplicatedStorage.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then
            wait(0.1)
            local name = string.lower(obj.Name)
            if string.find(name, "shoot") or string.find(name, "fire") or 
               string.find(name, "bullet") or string.find(name, "weapon") or
               string.find(name, "gun") then
                hookRemoteEvent(obj)
            end
        end
    end)
    
    print("AimBullet enabled")
end

local function disableAimBullet()
    if shootConnection then
        shootConnection:Disconnect()
        shootConnection = nil
    end
    hookedRemotes = {}
    print("AimBullet disabled")
end

-- Fixed Fast Reload
local function enableFastReload()
    if reloadConnection then reloadConnection:Disconnect() end
    
    reloadConnection = RunService.Heartbeat:Connect(function()
        if not aimSettings.FastReload.enabled then return end
        
        pcall(function()
            -- Speed up animations
            if player.Character then
                for _, obj in pairs(player.Character:GetDescendants()) do
                    if obj:IsA("AnimationTrack") then
                        local animId = obj.Animation.AnimationId:lower()
                        if animId:find("reload") then
                            obj:AdjustSpeed(aimSettings.FastReload.speed)
                        end
                    end
                end
            end
            
            -- Speed up reload values in tools
            if player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("NumberValue") then
                            local name = obj.Name:lower()
                            if name:find("reload") and obj.Value > 0 then
                                obj.Value = math.max(obj.Value / aimSettings.FastReload.speed, 0.1)
                            end
                        end
                    end
                end
            end
        end)
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

-- Fixed No Recoil
local function enableNoRecoil()
    pcall(function()
        if player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local name = obj.Name:lower()
                        if name:find("recoil") or name:find("kick") or name:find("sway") then
                            if not originalRecoil[obj] then
                                originalRecoil[obj] = obj.Value
                            end
                            obj.Value = 0
                        end
                    end
                end
            end
        end
        
        -- Check ReplicatedStorage
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                local name = obj.Name:lower()
                if name:find("recoil") or name:find("kick") then
                    if not originalRecoil[obj] then
                        originalRecoil[obj] = obj.Value
                    end
                    obj.Value = 0
                end
            end
        end
    end)
    print("No Recoil enabled")
end

local function disableNoRecoil()
    for obj, originalValue in pairs(originalRecoil) do
        pcall(function()
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end)
    end
    originalRecoil = {}
    print("No Recoil disabled")
end

-- Fixed No Spread
local function enableNoSpread()
    pcall(function()
        if player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local name = obj.Name:lower()
                        if name:find("spread") or name:find("accuracy") then
                            if not originalSpread[obj] then
                                originalSpread[obj] = obj.Value
                            end
                            obj.Value = 0
                        end
                    end
                end
            end
        end
    end)
    print("No Spread enabled")
end

local function disableNoSpread()
    for obj, originalValue in pairs(originalSpread) do
        pcall(function()
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end)
    end
    originalSpread = {}
    print("No Spread disabled")
end

-- Fixed Infinite Ammo
local function enableInfiniteAmmo()
    if ammoConnection then ammoConnection:Disconnect() end
    
    ammoConnection = RunService.Heartbeat:Connect(function()
        if not aimSettings.InfiniteAmmo.enabled then return end
        
        pcall(function()
            -- Check equipped tool
            if player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                            local name = obj.Name:lower()
                            if name:find("ammo") or name:find("bullet") or name:find("mag") then
                                if obj.Value < 999 then
                                    obj.Value = 999
                                end
                            end
                        end
                    end
                end
            end
            
            -- Check backpack tools
            if player.Backpack then
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                                local name = obj.Name:lower()
                                if name:find("ammo") or name:find("bullet") then
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

-- Fixed Rapid Fire
local function enableRapidFire()
    pcall(function()
        if player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") then
                        local name = obj.Name:lower()
                        if name:find("firerate") or name:find("cooldown") or name:find("delay") then
                            obj.Value = aimSettings.RapidFire.rate
                        end
                    end
                end
            end
        end
    end)
    print("Rapid Fire enabled")
end

-- Module Functions
function AimModule.init(dependencies)
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
        return aimSettings.WallShoot.enabled -- Return state for button color
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
        return aimSettings.Aimbot.enabled
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
        return aimSettings.AimBullet.enabled
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
        return aimSettings.FastReload.enabled
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
        return aimSettings.NoRecoil.enabled
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
        return aimSettings.NoSpread.enabled
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
        return aimSettings.InfiniteAmmo.enabled
    end)
    
    -- Rapid Fire Toggle
    createButton("Rapid Fire", function()
        aimSettings.RapidFire.enabled = not aimSettings.RapidFire.enabled
        print("Rapid Fire toggled: " .. tostring(aimSettings.RapidFire.enabled))
        
        if aimSettings.RapidFire.enabled then
            enableRapidFire()
        end
        return aimSettings.RapidFire.enabled
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
        return aimSettings.HeadshotOnly.enabled
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
        return aimSettings.SilentAim.enabled
    end)
    
    -- Settings Buttons
    createButton("Aimbot FOV +", function()
        aimSettings.Aimbot.fov = math.min(aimSettings.Aimbot.fov + 10, 180)
        print("Aimbot FOV: " .. aimSettings.Aimbot.fov)
        return false -- Settings buttons don't change color
    end)
    
    createButton("Aimbot FOV -", function()
        aimSettings.Aimbot.fov = math.max(aimSettings.Aimbot.fov - 10, 10)
        print("Aimbot FOV: " .. aimSettings.Aimbot.fov)
        return false
    end)
    
    createButton("Smoothness +", function()
        aimSettings.Aimbot.smoothness = math.min(aimSettings.Aimbot.smoothness + 0.05, 1)
        print("Aimbot Smoothness: " .. string.format("%.2f", aimSettings.Aimbot.smoothness))
        return false
    end)
    
    createButton("Smoothness -", function()
        aimSettings.Aimbot.smoothness = math.max(aimSettings.Aimbot.smoothness - 0.05, 0.01)
        print("Aimbot Smoothness: " .. string.format("%.2f", aimSettings.Aimbot.smoothness))
        return false
    end)
    
    createButton("Toggle Team Ignore", function()
        aimSettings.Aimbot.ignoreTeam = not aimSettings.Aimbot.ignoreTeam
        aimSettings.AimBullet.ignoreTeam = aimSettings.Aimbot.ignoreTeam
        print("Ignore Team: " .. tostring(aimSettings.Aimbot.ignoreTeam))
        return aimSettings.Aimbot.ignoreTeam
    end)
    
    createButton("Toggle Visible Only", function()
        aimSettings.Aimbot.visibleOnly = not aimSettings.Aimbot.visibleOnly
        print("Visible Only: " .. tostring(aimSettings.Aimbot.visibleOnly))
        return aimSettings.Aimbot.visibleOnly
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
    hookedRemotes = {}
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