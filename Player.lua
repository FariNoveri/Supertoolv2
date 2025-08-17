-- Player.lua - Complete Player System Module by Fari Noveri

local PlayerModule = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Variables
local player
local character, humanoid, rootPart
local connections = {}
local settings
local mouse

-- Player Settings
local playerSettings = {
    MagnetPlayer = {enabled = false, distance = 50, speed = 0.1, targetPlayer = nil},
    ESP = {enabled = false, color = Color3.fromRGB(0, 255, 255), ignoreTeam = true, transparency = 0.5},
    ESPHealth = {enabled = false, ignoreTeam = true, showBar = true, showText = true},
    NameESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 255, 255)},
    DistanceESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 255, 0)},
    TracerESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 0, 255)},
    BoxESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 255, 255)},
    Chams = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 0, 0)},
    PlayerTeleport = {enabled = false},
    SpectatePlayer = {enabled = false, targetPlayer = nil},
    CameraMode = {currentMode = "Default"} -- Default, FPP, TPP
}

-- State variables
local selectedPlayer = nil
local espObjects = {}
local magnetConnection = nil
local spectateConnection = nil
local originalCameraSubject = nil
local cameraConnection = nil
local originalCameraType = nil
local originalCameraMaxZoomDistance = nil
local originalCameraMinZoomDistance = nil

-- ESP Colors
local espColors = {
    {name = "Cyan", color = Color3.fromRGB(0, 255, 255)},
    {name = "Red", color = Color3.fromRGB(255, 0, 0)},
    {name = "Green", color = Color3.fromRGB(0, 255, 0)},
    {name = "Blue", color = Color3.fromRGB(0, 0, 255)},
    {name = "Yellow", color = Color3.fromRGB(255, 255, 0)},
    {name = "Purple", color = Color3.fromRGB(255, 0, 255)},
    {name = "Orange", color = Color3.fromRGB(255, 165, 0)},
    {name = "White", color = Color3.fromRGB(255, 255, 255)},
    {name = "Pink", color = Color3.fromRGB(255, 192, 203)}
}
local currentColorIndex = 1

-- Utility Functions
local function shouldIgnorePlayer(targetPlayer)
    if not targetPlayer or targetPlayer == player then return true end
    
    -- Team check
    if playerSettings.ESP.ignoreTeam and targetPlayer.Team == player.Team then
        return true
    end
    
    return false
end

local function getPlayerDistance(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    
    local distance = (player.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end

-- Magnet Player Functions
local function enableMagnetPlayer()
    if magnetConnection then magnetConnection:Disconnect() end
    
    magnetConnection = RunService.Heartbeat:Connect(function()
        if not playerSettings.MagnetPlayer.enabled then return end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
        local targetPlayer = selectedPlayer
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not shouldIgnorePlayer(targetPlayer) then
                local targetPos = targetPlayer.Character.HumanoidRootPart.Position
                local currentPos = player.Character.HumanoidRootPart.Position
                local direction = (targetPos - currentPos).Unit
                local distance = (targetPos - currentPos).Magnitude
                
                if distance <= playerSettings.MagnetPlayer.distance then
                    -- Move player towards crosshair position
                    local newPos = currentPos + direction * playerSettings.MagnetPlayer.speed
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
                end
            end
        end
    end)
    
    print("Magnet Player enabled")
end

local function disableMagnetPlayer()
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end
    print("Magnet Player disabled")
end

-- ESP Functions
local function createHighlight(targetPlayer)
    if not targetPlayer.Character then return nil end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP_" .. targetPlayer.Name
    highlight.Parent = targetPlayer.Character
    highlight.FillColor = playerSettings.ESP.color
    highlight.OutlineColor = playerSettings.ESP.color
    highlight.FillTransparency = playerSettings.ESP.transparency
    highlight.OutlineTransparency = 0
    highlight.Adornee = targetPlayer.Character
    
    return highlight
end

local function createHealthESP(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return nil end
    
    local head = targetPlayer.Character.Head
    local gui = Instance.new("BillboardGui")
    gui.Name = "HealthESP_" .. targetPlayer.Name
    gui.Parent = head
    gui.Size = UDim2.new(0, 100, 0, 50)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.AlwaysOnTop = true
    
    if playerSettings.ESPHealth.showBar then
        local healthBarBG = Instance.new("Frame")
        healthBarBG.Name = "HealthBarBG"
        healthBarBG.Parent = gui
        healthBarBG.Size = UDim2.new(0, 80, 0, 8)
        healthBarBG.Position = UDim2.new(0, 10, 0, 0)
        healthBarBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        healthBarBG.BorderSizePixel = 1
        healthBarBG.BorderColor3 = Color3.fromRGB(255, 255, 255)
        
        local healthBar = Instance.new("Frame")
        healthBar.Name = "HealthBar"
        healthBar.Parent = healthBarBG
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.Position = UDim2.new(0, 0, 0, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
    end
    
    if playerSettings.ESPHealth.showText then
        local healthText = Instance.new("TextLabel")
        healthText.Name = "HealthText"
        healthText.Parent = gui
        healthText.Size = UDim2.new(1, 0, 0, 20)
        healthText.Position = UDim2.new(0, 0, 0, 12)
        healthText.BackgroundTransparency = 1
        healthText.Font = Enum.Font.GothamBold
        healthText.TextSize = 12
        healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthText.TextStrokeTransparency = 0
        healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthText.Text = "100/100"
    end
    
    return gui
end

local function createNameESP(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return nil end
    
    local head = targetPlayer.Character.Head
    local gui = Instance.new("BillboardGui")
    gui.Name = "NameESP_" .. targetPlayer.Name
    gui.Parent = head
    gui.Size = UDim2.new(0, 200, 0, 25)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = gui
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextColor3 = playerSettings.NameESP.color
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = targetPlayer.DisplayName or targetPlayer.Name
    
    return gui
end

local function createDistanceESP(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return nil end
    
    local head = targetPlayer.Character.Head
    local gui = Instance.new("BillboardGui")
    gui.Name = "DistanceESP_" .. targetPlayer.Name
    gui.Parent = head
    gui.Size = UDim2.new(0, 100, 0, 20)
    gui.StudsOffset = Vector3.new(0, -1, 0)
    gui.AlwaysOnTop = true
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Parent = gui
    distanceLabel.Size = UDim2.new(1, 0, 1, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 14
    distanceLabel.TextColor3 = playerSettings.DistanceESP.color
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Text = getPlayerDistance(targetPlayer) .. "m"
    
    return gui
end

local function createBoxESP(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local rootPart = targetPlayer.Character.HumanoidRootPart
    local gui = Instance.new("BillboardGui")
    gui.Name = "BoxESP_" .. targetPlayer.Name
    gui.Parent = rootPart
    gui.Size = UDim2.new(0, 4, 0, 6)
    gui.StudsOffset = Vector3.new(0, 0, 0)
    gui.AlwaysOnTop = true
    
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Parent = gui
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = playerSettings.BoxESP.color
    
    return gui
end

local function createChams(targetPlayer)
    if not targetPlayer.Character then return nil end
    
    for _, part in pairs(targetPlayer.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local chams = Instance.new("SelectionBox")
            chams.Name = "Chams_" .. targetPlayer.Name
            chams.Parent = part
            chams.Adornee = part
            chams.Color3 = playerSettings.Chams.color
            chams.Transparency = 0.5
            chams.LineThickness = 0.1
        end
    end
end

local function updateESP()
    -- Clear existing ESP
    for _, espList in pairs(espObjects) do
        for _, espObj in pairs(espList) do
            if espObj and espObj.Parent then
                espObj:Destroy()
            end
        end
    end
    espObjects = {highlight = {}, health = {}, name = {}, distance = {}, box = {}, chams = {}}
    
    -- Create ESP for all players
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if not shouldIgnorePlayer(targetPlayer) and targetPlayer.Character then
            -- Highlight ESP
            if playerSettings.ESP.enabled then
                local highlight = createHighlight(targetPlayer)
                if highlight then
                    table.insert(espObjects.highlight, highlight)
                end
            end
            
            -- Health ESP
            if playerSettings.ESPHealth.enabled then
                local healthESP = createHealthESP(targetPlayer)
                if healthESP then
                    table.insert(espObjects.health, healthESP)
                end
            end
            
            -- Name ESP
            if playerSettings.NameESP.enabled then
                local nameESP = createNameESP(targetPlayer)
                if nameESP then
                    table.insert(espObjects.name, nameESP)
                end
            end
            
            -- Distance ESP
            if playerSettings.DistanceESP.enabled then
                local distanceESP = createDistanceESP(targetPlayer)
                if distanceESP then
                    table.insert(espObjects.distance, distanceESP)
                end
            end
            
            -- Box ESP
            if playerSettings.BoxESP.enabled then
                local boxESP = createBoxESP(targetPlayer)
                if boxESP then
                    table.insert(espObjects.box, boxESP)
                end
            end
            
            -- Chams
            if playerSettings.Chams.enabled then
                createChams(targetPlayer)
            end
        end
    end
end

local function updateHealthESP()
    RunService.Heartbeat:Connect(function()
        if not playerSettings.ESPHealth.enabled then return end
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if not shouldIgnorePlayer(targetPlayer) and targetPlayer.Character then
                local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                local head = targetPlayer.Character:FindFirstChild("Head")
                
                if humanoid and head then
                    local healthESP = head:FindFirstChild("HealthESP_" .. targetPlayer.Name)
                    if healthESP then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        
                        -- Update health bar
                        local healthBar = healthESP:FindFirstChild("HealthBarBG") and healthESP.HealthBarBG:FindFirstChild("HealthBar")
                        if healthBar then
                            healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                            healthBar.BackgroundColor3 = Color3.fromRGB(
                                255 * (1 - healthPercent),
                                255 * healthPercent,
                                0
                            )
                        end
                        
                        -- Update health text
                        local healthText = healthESP:FindFirstChild("HealthText")
                        if healthText then
                            healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        end
                    end
                end
                
                -- Update distance
                local head = targetPlayer.Character:FindFirstChild("Head")
                if head then
                    local distanceESP = head:FindFirstChild("DistanceESP_" .. targetPlayer.Name)
                    if distanceESP then
                        local distanceLabel = distanceESP:FindFirstChild("DistanceLabel")
                        if distanceLabel then
                            distanceLabel.Text = getPlayerDistance(targetPlayer) .. "m"
                        end
                    end
                end
            end
        end
    end)
end

-- Spectate Functions
local function enableSpectate()
    if not selectedPlayer or not selectedPlayer.Character then return end
    
    local camera = Workspace.CurrentCamera
    originalCameraSubject = camera.CameraSubject
    
    if spectateConnection then spectateConnection:Disconnect() end
    
    spectateConnection = RunService.Heartbeat:Connect(function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = selectedPlayer.Character.Humanoid
        end
    end)
    
    print("Spectating: " .. selectedPlayer.Name)
end

local function disableSpectate()
    if spectateConnection then
        spectateConnection:Disconnect()
        spectateConnection = nil
    end
    
    local camera = Workspace.CurrentCamera
    if originalCameraSubject then
        camera.CameraSubject = originalCameraSubject
    elseif player.Character and player.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = player.Character.Humanoid
    end
    
    print("Stopped spectating")
end

-- Camera Mode Functions
local function switchToFPP()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    -- Store original camera settings
    if not originalCameraType then
        originalCameraType = camera.CameraType
        originalCameraMaxZoomDistance = player.CameraMaxZoomDistance
        originalCameraMinZoomDistance = player.CameraMinZoomDistance
    end
    
    -- Set First Person settings
    camera.CameraType = Enum.CameraType.Custom
    player.CameraMaxZoomDistance = 0.5
    player.CameraMinZoomDistance = 0.5
    
    playerSettings.CameraMode.currentMode = "FPP"
    print("Switched to First Person Perspective (FPP)")
end

local function switchToTPP()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    -- Store original camera settings
    if not originalCameraType then
        originalCameraType = camera.CameraType
        originalCameraMaxZoomDistance = player.CameraMaxZoomDistance
        originalCameraMinZoomDistance = player.CameraMinZoomDistance
    end
    
    -- Set Third Person settings
    camera.CameraType = Enum.CameraType.Custom
    player.CameraMaxZoomDistance = 128
    player.CameraMinZoomDistance = 5
    
    -- Force camera to third person distance
    if cameraConnection then cameraConnection:Disconnect() end
    cameraConnection = RunService.Heartbeat:Connect(function()
        if playerSettings.CameraMode.currentMode == "TPP" and player.Character and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.CameraOffset = Vector3.new(0, 0, 0)
            end
        end
    end)
    
    playerSettings.CameraMode.currentMode = "TPP"
    print("Switched to Third Person Perspective (TPP)")
end

local function resetCameraMode()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    -- Restore original camera settings
    if originalCameraType then
        camera.CameraType = originalCameraType
    end
    if originalCameraMaxZoomDistance then
        player.CameraMaxZoomDistance = originalCameraMaxZoomDistance
    end
    if originalCameraMinZoomDistance then
        player.CameraMinZoomDistance = originalCameraMinZoomDistance
    end
    
    -- Disconnect camera connection
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    
    playerSettings.CameraMode.currentMode = "Default"
    print("Reset to Default Camera Mode")
end
    local playerList = Players:GetPlayers()
    local currentIndex = 1
    
    for i, p in ipairs(playerList) do
        if p == selectedPlayer then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = currentIndex + 1
    if nextIndex > #playerList then
        nextIndex = 1
    end
    
    -- Skip self
    local nextPlayer = playerList[nextIndex]
    if nextPlayer == player then
        nextIndex = nextIndex + 1
        if nextIndex > #playerList then
            nextIndex = 1
        end
        nextPlayer = playerList[nextIndex]
    end
    
    return nextPlayer
end

local function getPreviousPlayer()
    local playerList = Players:GetPlayers()
    local currentIndex = 1
    
    for i, p in ipairs(playerList) do
        if p == selectedPlayer then
            currentIndex = i
            break
        end
    end
    
    local prevIndex = currentIndex - 1
    if prevIndex < 1 then
        prevIndex = #playerList
    end
    
    -- Skip self
    local prevPlayer = playerList[prevIndex]
    if prevPlayer == player then
        prevIndex = prevIndex - 1
        if prevIndex < 1 then
            prevIndex = #playerList
        end
        prevPlayer = playerList[prevIndex]
    end
    
    return prevPlayer
end

-- Module Functions
function PlayerModule.init(dependencies)
    player = dependencies.player
    character = dependencies.character
    humanoid = dependencies.humanoid
    rootPart = dependencies.rootPart
    settings = dependencies.settings
    connections = dependencies.connections
    
    mouse = player:GetMouse()
    
    -- Initialize ESP objects
    espObjects = {highlight = {}, health = {}, name = {}, distance = {}, box = {}, chams = {}}
    
    -- Set initial selected player
    local playerList = Players:GetPlayers()
    for _, p in ipairs(playerList) do
        if p ~= player then
            selectedPlayer = p
            break
        end
    end
    
    -- Start health ESP updater
    updateHealthESP()
    
    print("Player module initialized")
    return true
end

function PlayerModule.getSelectedPlayer()
    return selectedPlayer
end

function PlayerModule.loadPlayerButtons(createButton, createToggleButton, currentSelectedPlayer)
    selectedPlayer = currentSelectedPlayer or selectedPlayer
    
    -- Player Selection
    createButton("Next Player", function()
        selectedPlayer = getNextPlayer()
        print("Selected Player: " .. (selectedPlayer and selectedPlayer.Name or "None"))
    end)
    
    createButton("Previous Player", function()
        selectedPlayer = getPreviousPlayer()
        print("Selected Player: " .. (selectedPlayer and selectedPlayer.Name or "None"))
    end)
    
    createButton("Show Selected", function()
        if selectedPlayer then
            print("Currently Selected: " .. selectedPlayer.Name)
        else
            print("No player selected")
        end
    end)
    
    -- Magnet Player
    createToggleButton("Magnet Player", function(enabled)
        playerSettings.MagnetPlayer.enabled = enabled
        if enabled then
            enableMagnetPlayer()
        else
            disableMagnetPlayer()
        end
    end, "Player")
    
    -- ESP Features
    createToggleButton("ESP Highlight", function(enabled)
        playerSettings.ESP.enabled = enabled
        updateESP()
    end, "Player")
    
    createToggleButton("ESP Health", function(enabled)
        playerSettings.ESPHealth.enabled = enabled
        updateESP()
    end, "Player")
    
    createToggleButton("ESP Names", function(enabled)
        playerSettings.NameESP.enabled = enabled
        updateESP()
    end, "Player")
    
    createToggleButton("ESP Distance", function(enabled)
        playerSettings.DistanceESP.enabled = enabled
        updateESP()
    end, "Player")
    
    createToggleButton("ESP Box", function(enabled)
        playerSettings.BoxESP.enabled = enabled
        updateESP()
    end, "Player")
    
    createToggleButton("Chams", function(enabled)
        playerSettings.Chams.enabled = enabled
        updateESP()
    end, "Player")
    
    -- ESP Settings
    createButton("ESP Color", function()
        currentColorIndex = currentColorIndex + 1
        if currentColorIndex > #espColors then
            currentColorIndex = 1
        end
        
        local newColor = espColors[currentColorIndex]
        playerSettings.ESP.color = newColor.color
        playerSettings.BoxESP.color = newColor.color
        playerSettings.Chams.color = newColor.color
        
        print("ESP Color: " .. newColor.name)
        updateESP()
    end)
    
    createButton("Team Ignore Toggle", function()
        playerSettings.ESP.ignoreTeam = not playerSettings.ESP.ignoreTeam
        playerSettings.ESPHealth.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.NameESP.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.DistanceESP.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.BoxESP.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.Chams.ignoreTeam = playerSettings.ESP.ignoreTeam
        
        print("Ignore Team: " .. tostring(playerSettings.ESP.ignoreTeam))
        updateESP()
    end)
    
    -- Player Actions
    createButton("Teleport to Player", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                print("Teleported to: " .. selectedPlayer.Name)
            end
        else
            print("Selected player not available")
        end
    end)
    
    createToggleButton("Spectate Player", function(enabled)
        playerSettings.SpectatePlayer.enabled = enabled
        if enabled then
            enableSpectate()
        else
            disableSpectate()
        end
    end, "Player")
    
    -- Magnet Settings
    createButton("Magnet Distance +", function()
        playerSettings.MagnetPlayer.distance = playerSettings.MagnetPlayer.distance + 10
        print("Magnet Distance: " .. playerSettings.MagnetPlayer.distance)
    end)
    
    createButton("Magnet Distance -", function()
        playerSettings.MagnetPlayer.distance = math.max(playerSettings.MagnetPlayer.distance - 10, 10)
        print("Magnet Distance: " .. playerSettings.MagnetPlayer.distance)
    end)
    
    createButton("Magnet Speed +", function()
        playerSettings.MagnetPlayer.speed = math.min(playerSettings.MagnetPlayer.speed + 0.05, 1)
        print("Magnet Speed: " .. playerSettings.MagnetPlayer.speed)
    end)
    
    createButton("Magnet Speed -", function()
        playerSettings.MagnetPlayer.speed = math.max(playerSettings.MagnetPlayer.speed - 0.05, 0.01)
        print("Magnet Speed: " .. playerSettings.MagnetPlayer.speed)
    end)
end

function PlayerModule.resetStates()
    -- Disable all features
    playerSettings.MagnetPlayer.enabled = false
    playerSettings.ESP.enabled = false
    playerSettings.ESPHealth.enabled = false
    playerSettings.NameESP.enabled = false
    playerSettings.DistanceESP.enabled = false
    playerSettings.BoxESP.enabled = false
    playerSettings.Chams.enabled = false
    playerSettings.SpectatePlayer.enabled = false
    
    -- Clean up connections
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end
    
    if spectateConnection then
        spectateConnection:Disconnect()
        spectateConnection = nil
    end
    
    -- Clean up ESP objects
    for _, espList in pairs(espObjects) do
        for _, espObj in pairs(espList) do
            if espObj and espObj.Parent then
                espObj:Destroy()
            end
        end
    end
    espObjects = {highlight = {}, health = {}, name = {}, distance = {}, box = {}, chams = {}}
    
    -- Restore camera
    disableSpectate()
    
    print("Player module states reset")
end

return PlayerModule