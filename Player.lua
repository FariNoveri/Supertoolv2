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
    MagnetPlayer = {enabled = false, distance = 50, speed = 5, targetPlayer = nil}, -- Adjusted speed for smoother movement
    ESP = {enabled = false, color = Color3.fromRGB(0, 255, 255), ignoreTeam = true, transparency = 0.5},
    ESPHealth = {enabled = false, ignoreTeam = true, showBar = true, showText = true},
    NameESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 255, 255)},
    DistanceESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 255, 0)},
    TracerESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 0, 255)},
    BoxESP = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 255, 255)},
    Chams = {enabled = false, ignoreTeam = true, color = Color3.fromRGB(255, 0, 0)},
    PlayerTeleport = {enabled = false},
    SpectatePlayer = {enabled = false, targetPlayer = nil},
    CameraMode = {currentMode = "Default"}
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

-- Button references for state updates
local buttonStates = {}

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

-- Respawn Handler
local respawnConnection = nil

-- Utility Functions
local function shouldIgnorePlayer(targetPlayer)
    if not targetPlayer or targetPlayer == player then return true end
    if playerSettings.ESP.ignoreTeam and targetPlayer.Team == player.Team then return true end
    return false
end

local function getPlayerDistance(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
    local distance = (player.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end

local function getNextPlayer()
    local playerList = Players:GetPlayers()
    if #playerList <= 1 then return nil end
    local currentIndex = 1
    for i, p in ipairs(playerList) do
        if p == selectedPlayer then
            currentIndex = i
            break
        end
    end
    local nextIndex = currentIndex + 1
    if nextIndex > #playerList then nextIndex = 1 end
    local nextPlayer = playerList[nextIndex]
    if nextPlayer == player then
        nextIndex = nextIndex + 1
        if nextIndex > #playerList then nextIndex = 1 end
        nextPlayer = playerList[nextIndex]
    end
    return nextPlayer
end

local function getPreviousPlayer()
    local playerList = Players:GetPlayers()
    if #playerList <= 1 then return nil end
    local currentIndex = 1
    for i, p in ipairs(playerList) do
        if p == selectedPlayer then
            currentIndex = i
            break
        end
    end
    local prevIndex = currentIndex - 1
    if prevIndex < 1 then prevIndex = #playerList end
    local prevPlayer = playerList[prevIndex]
    if prevPlayer == player then
        prevIndex = prevIndex - 1
        if prevIndex < 1 then prevIndex = #playerList end
        prevPlayer = playerList[prevIndex]
    end
    return prevPlayer
end

local function updateButtonState(buttonName, enabled)
    if buttonStates[buttonName] and buttonStates[buttonName].updateState then
        buttonStates[buttonName].updateState(enabled)
    end
end

-- Magnet Player Functions
local function enableMagnetPlayer()
    if magnetConnection then magnetConnection:Disconnect() end
    magnetConnection = RunService.Heartbeat:Connect(function()
        if not playerSettings.MagnetPlayer.enabled then return end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then return end
        local playerRootPart = player.Character.HumanoidRootPart
        local playerHumanoid = player.Character.Humanoid
        local camera = Workspace.CurrentCamera
        if not camera then return end
        local closestPlayer, closestDistance = nil, playerSettings.MagnetPlayer.distance
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if not shouldIgnorePlayer(targetPlayer) and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetRootPart = targetPlayer.Character.HumanoidRootPart
                local distanceToPlayer = (playerRootPart.Position - targetRootPart.Position).Magnitude
                if distanceToPlayer <= closestDistance then
                    closestPlayer = targetPlayer
                    closestDistance = distanceToPlayer
                end
            end
        end
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetRootPart = closestPlayer.Character.HumanoidRootPart
            local direction = (targetRootPart.Position - playerRootPart.Position).Unit
            local targetPos = playerRootPart.Position + direction * playerSettings.MagnetPlayer.speed
            local distanceFromTarget = (targetPos - targetRootPart.Position).Magnitude
            if distanceFromTarget < 5 then
                targetPos = targetRootPart.Position + (direction * -5)
            elseif distanceFromTarget > 10 then
                targetPos = targetRootPart.Position + (direction * -10)
            end
            playerHumanoid:MoveTo(targetPos)
            print("Magnet Player: Moving to " .. closestPlayer.Name)
        end
    end)
    print("Magnet Player enabled - Moving towards closest enemy")
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
    local existingHighlight = targetPlayer.Character:FindFirstChild("PlayerESP_" .. targetPlayer.Name)
    if existingHighlight then existingHighlight:Destroy() end
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP_" .. targetPlayer.Name
    highlight.Parent = targetPlayer.Character
    highlight.FillColor = playerSettings.ESP.color
    highlight.OutlineColor = playerSettings.ESP.color
    highlight.FillTransparency = playerSettings.ESP.transparency
    highlight.OutlineTransparency = 0
    highlight.Adornee = targetPlayer.Character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    print("ESP Highlight created for: " .. targetPlayer.Name)
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
            local existingChams = part:FindFirstChild("Chams_" .. targetPlayer.Name)
            if existingChams then existingChams:Destroy() end
            local chams = Instance.new("SelectionBox")
            chams.Name = "Chams_" .. targetPlayer.Name
            chams.Parent = part
            chams.Adornee = part
            chams.Color3 = playerSettings.Chams.color
            chams.Transparency = 0.3
            chams.LineThickness = 0.2
            chams.SurfaceTransparency = 0.8
            if part.Transparency < 0.9 then
                part.Transparency = 0.7
            end
        end
    end
    print("Chams created for: " .. targetPlayer.Name)
end

local function updateESP()
    for _, espList in pairs(espObjects) do
        for _, espObj in pairs(espList) do
            if espObj and espObj.Parent then espObj:Destroy() end
        end
    end
    espObjects = {highlight = {}, health = {}, name = {}, distance = {}, box = {}, chams = {}}
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if not shouldIgnorePlayer(targetPlayer) and targetPlayer.Character then
            if playerSettings.ESP.enabled then
                local highlight = createHighlight(targetPlayer)
                if highlight then table.insert(espObjects.highlight, highlight) end
            end
            if playerSettings.ESPHealth.enabled then
                local healthESP = createHealthESP(targetPlayer)
                if healthESP then table.insert(espObjects.health, healthESP) end
            end
            if playerSettings.NameESP.enabled then
                local nameESP = createNameESP(targetPlayer)
                if nameESP then table.insert(espObjects.name, nameESP) end
            end
            if playerSettings.DistanceESP.enabled then
                local distanceESP = createDistanceESP(targetPlayer)
                if distanceESP then table.insert(espObjects.distance, distanceESP) end
            end
            if playerSettings.BoxESP.enabled then
                local boxESP = createBoxESP(targetPlayer)
                if boxESP then table.insert(espObjects.box, boxESP) end
            end
            if playerSettings.Chams.enabled then
                createChams(targetPlayer)
            end
        end
    end
    print("ESP updated for " .. (#Players:GetPlayers() - 1) .. " enemies")
end

local function updateHealthESP()
    RunService.Heartbeat:Connect(function()
        if not playerSettings.ESPHealth.enabled and not playerSettings.DistanceESP.enabled then return end
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if not shouldIgnorePlayer(targetPlayer) and targetPlayer.Character then
                local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                local head = targetPlayer.Character:FindFirstChild("Head")
                if humanoid and head then
                    if playerSettings.ESPHealth.enabled then
                        local healthESP = head:FindFirstChild("HealthESP_" .. targetPlayer.Name)
                        if healthESP then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            local healthBar = healthESP:FindFirstChild("HealthBarBG") and healthESP.HealthBarBG:FindFirstChild("HealthBar")
                            if healthBar then
                                healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                                healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                            end
                            local healthText = healthESP:FindFirstChild("HealthText")
                            if healthText then
                                healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                            end
                        end
                    end
                    if playerSettings.DistanceESP.enabled then
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
    if not originalCameraType then
        originalCameraType = camera.CameraType
        originalCameraMaxZoomDistance = player.CameraMaxZoomDistance
        originalCameraMinZoomDistance = player.CameraMinZoomDistance
    end
    camera.CameraType = Enum.CameraType.Custom
    player.CameraMaxZoomDistance = 0.5
    player.CameraMinZoomDistance = 0.5
    playerSettings.CameraMode.currentMode = "FPP"
    print("Switched to First Person Perspective (FPP)")
end

local function switchToTPP()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    if not originalCameraType then
        originalCameraType = camera.CameraType
        originalCameraMaxZoomDistance = player.CameraMaxZoomDistance
        originalCameraMinZoomDistance = player.CameraMinZoomDistance
    end
    camera.CameraType = Enum.CameraType.Custom
    player.CameraMaxZoomDistance = 128
    player.CameraMinZoomDistance = 5
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
    if originalCameraType then
        camera.CameraType = originalCameraType
    end
    if originalCameraMaxZoomDistance then
        player.CameraMaxZoomDistance = originalCameraMaxZoomDistance
    end
    if originalCameraMinZoomDistance then
        player.CameraMinZoomDistance = originalCameraMinZoomDistance
    end
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    playerSettings.CameraMode.currentMode = "Default"
    print("Reset to Default Camera Mode")
end

-- Respawn handling function
local function setupRespawnHandler()
    if respawnConnection then
        respawnConnection:Disconnect()
    end
    respawnConnection = player.CharacterAdded:Connect(function(newCharacter)
        wait(1)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        print("Character respawned, reapplying features...")
        if playerSettings.MagnetPlayer.enabled then
            enableMagnetPlayer()
        end
        if playerSettings.SpectatePlayer.enabled then
            enableSpectate()
        end
        if playerSettings.CameraMode.currentMode == "FPP" then
            wait(0.5)
            switchToFPP()
        elseif playerSettings.CameraMode.currentMode == "TPP" then
            wait(0.5)
            switchToTPP()
        end
        wait(0.5)
        updateESP()
        print("All features reapplied after respawn")
    end)
end

-- Function to reapply all active features after respawn
local function reapplyAllFeatures()
    wait(2)
    if playerSettings.MagnetPlayer.enabled then
        enableMagnetPlayer()
        updateButtonState("Magnet Player", true)
    end
    if playerSettings.SpectatePlayer.enabled then
        enableSpectate()
        updateButtonState("Spectate Player", true)
    end
    if playerSettings.CameraMode.currentMode == "FPP" then
        switchToFPP()
    elseif playerSettings.CameraMode.currentMode == "TPP" then
        switchToTPP()
    end
    if playerSettings.ESP.enabled then
        updateButtonState("ESP Highlight", true)
    end
    if playerSettings.ESPHealth.enabled then
        updateButtonState("ESP Health", true)
    end
    if playerSettings.NameESP.enabled then
        updateButtonState("ESP Names", true)
    end
    if playerSettings.DistanceESP.enabled then
        updateButtonState("ESP Distance", true)
    end
    if playerSettings.BoxESP.enabled then
        updateButtonState("ESP Box", true)
    end
    if playerSettings.Chams.enabled then
        updateButtonState("Chams", true)
    end
    updateESP()
    print("All features reapplied and button states updated")
end

-- Module Functions
function PlayerModule.init(dependencies)
    if not dependencies or not dependencies.player then
        warn("PlayerModule.init: Missing dependencies or player")
        return false
    end
    player = dependencies.player
    character = dependencies.character
    humanoid = dependencies.humanoid
    rootPart = dependencies.rootPart
    settings = dependencies.settings
    connections = dependencies.connections
    mouse = player:GetMouse()
    espObjects = {highlight = {}, health = {}, name = {}, distance = {}, box = {}, chams = {}}
    local playerList = Players:GetPlayers()
    for _, p in ipairs(playerList) do
        if p ~= player then
            selectedPlayer = p
            break
        end
    end
    updateHealthESP()
    setupRespawnHandler()
    print("Player module initialized successfully")
    return true
end

function PlayerModule.getSelectedPlayer()
    return selectedPlayer
end

function PlayerModule.loadPlayerButtons(createButton, createToggleButton, currentSelectedPlayer)
    if not createButton or type(createButton) ~= "function" or not createToggleButton or type(createToggleButton) ~= "function" then
        warn("PlayerModule.loadPlayerButtons: Invalid button creation functions")
        return false
    end
    selectedPlayer = currentSelectedPlayer or selectedPlayer
    local function safeCreateToggleButton(name, onCallback, offCallback)
        local success, result = pcall(function()
            local button = createToggleButton(name, function(enabled)
                if onCallback then onCallback(enabled) end
            end, offCallback)
            buttonStates[name] = {
                button = button,
                updateState = function(enabled)
                    if button and button.updateState then
                        button.updateState(enabled)
                    end
                end
            }
            return button
        end)
        if not success then
            warn("Failed to create toggle button '" .. name .. "': " .. tostring(result))
            return nil
        end
        return result
    end
    local function safeCreateButton(name, callback)
        local success, result = pcall(function()
            return createButton(name, callback)
        end)
        if not success then
            warn("Failed to create button '" .. name .. "': " .. tostring(result))
            return nil
        end
        return result
    end
    safeCreateButton("Next Player", function()
        local nextPlayer = getNextPlayer()
        if nextPlayer then
            selectedPlayer = nextPlayer
            print("Selected Player: " .. selectedPlayer.Name)
        else
            print("No other players available")
        end
    end)
    safeCreateButton("Previous Player", function()
        local prevPlayer = getPreviousPlayer()
        if prevPlayer then
            selectedPlayer = prevPlayer
            print("Selected Player: " .. prevPlayer.Name)
        else
            print("No other players available")
        end
    end)
    safeCreateButton("Show Selected", function()
        if selectedPlayer then
            print("Currently Selected: " .. selectedPlayer.Name)
        else
            print("No player selected")
        end
    end)
    safeCreateToggleButton("Magnet Player", function(enabled)
        playerSettings.MagnetPlayer.enabled = enabled
        if enabled then
            enableMagnetPlayer()
        else
            disableMagnetPlayer()
        end
    end, function()
        playerSettings.MagnetPlayer.enabled = false
        disableMagnetPlayer()
    end)
    safeCreateToggleButton("ESP Highlight", function(enabled)
        playerSettings.ESP.enabled = enabled
        updateESP()
    end, nil)
    safeCreateToggleButton("ESP Health", function(enabled)
        playerSettings.ESPHealth.enabled = enabled
        updateESP()
    end, nil)
    safeCreateToggleButton("ESP Names", function(enabled)
        playerSettings.NameESP.enabled = enabled
        updateESP()
    end, nil)
    safeCreateToggleButton("ESP Distance", function(enabled)
        playerSettings.DistanceESP.enabled = enabled
        updateESP()
    end, nil)
    safeCreateToggleButton("ESP Box", function(enabled)
        playerSettings.BoxESP.enabled = enabled
        updateESP()
    end, nil)
    safeCreateToggleButton("Chams", function(enabled)
        playerSettings.Chams.enabled = enabled
        updateESP()
    end, nil)
    safeCreateButton("ESP Color", function()
        currentColorIndex = currentColorIndex + 1
        if currentColorIndex > #espColors then currentColorIndex = 1 end
        local newColor = espColors[currentColorIndex]
        playerSettings.ESP.color = newColor.color
        playerSettings.BoxESP.color = newColor.color
        playerSettings.Chams.color = newColor.color
        print("ESP Color: " .. newColor.name)
        updateESP()
    end)
    safeCreateButton("Team Ignore Toggle", function()
        playerSettings.ESP.ignoreTeam = not playerSettings.ESP.ignoreTeam
        playerSettings.ESPHealth.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.NameESP.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.DistanceESP.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.BoxESP.ignoreTeam = playerSettings.ESP.ignoreTeam
        playerSettings.Chams.ignoreTeam = playerSettings.ESP.ignoreTeam
        print("Ignore Team: " .. tostring(playerSettings.ESP.ignoreTeam))
        updateESP()
    end)
    safeCreateButton("Teleport to Player", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                print("Teleported to: " .. selectedPlayer.Name)
            end
        else
            print("Selected player not available")
        end
    end)
    safeCreateToggleButton("Spectate Player", function(enabled)
        playerSettings.SpectatePlayer.enabled = enabled
        if enabled then
            enableSpectate()
        else
            disableSpectate()
        end
    end, function()
        playerSettings.SpectatePlayer.enabled = false
        disableSpectate()
    end)
    safeCreateButton("Switch to FPP", function()
        switchToFPP()
    end)
    safeCreateButton("Switch to TPP", function()
        switchToTPP()
    end)
    safeCreateButton("Reset Camera", function()
        resetCameraMode()
    end)
    safeCreateButton("Show Camera Mode", function()
        print("Current Camera Mode: " .. playerSettings.CameraMode.currentMode)
    end)
    safeCreateButton("Magnet Distance +", function()
        playerSettings.MagnetPlayer.distance = playerSettings.MagnetPlayer.distance + 10
        print("Magnet Distance: " .. playerSettings.MagnetPlayer.distance .. " studs")
    end)
    safeCreateButton("Magnet Distance -", function()
        playerSettings.MagnetPlayer.distance = math.max(playerSettings.MagnetPlayer.distance - 10, 10)
        print("Magnet Distance: " .. playerSettings.MagnetPlayer.distance .. " studs")
    end)
    safeCreateButton("Magnet Speed +", function()
        playerSettings.MagnetPlayer.speed = math.min(playerSettings.MagnetPlayer.speed + 0.5, 10)
        print("Magnet Speed: " .. playerSettings.MagnetPlayer.speed)
    end)
    safeCreateButton("Magnet Speed -", function()
        playerSettings.MagnetPlayer.speed = math.max(playerSettings.MagnetPlayer.speed - 0.5, 0.5)
        print("Magnet Speed: " .. playerSettings.MagnetPlayer.speed)
    end)
    safeCreateButton("Test ESP", function()
        local enemyCount = 0
        for _, p in pairs(Players:GetPlayers()) do
            if not shouldIgnorePlayer(p) then
                enemyCount = enemyCount + 1
            end
        end
        print("Found " .. enemyCount .. " enemies for ESP")
        updateESP()
    end)
    safeCreateButton("Test Magnet", function()
        local enemyCount = 0
        for _, p in pairs(Players:GetPlayers()) do
            if not shouldIgnorePlayer(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local distance = getPlayerDistance(p)
                if distance <= playerSettings.MagnetPlayer.distance then
                    enemyCount = enemyCount + 1
                end
            end
        end
        print("Found " .. enemyCount .. " enemies in magnet range (" .. playerSettings.MagnetPlayer.distance .. " studs)")
    end)
    spawn(function()
        wait(0.5)
        updateButtonState("Magnet Player", playerSettings.MagnetPlayer.enabled)
        updateButtonState("ESP Highlight", playerSettings.ESP.enabled)
        updateButtonState("ESP Health", playerSettings.ESPHealth.enabled)
        updateButtonState("ESP Names", playerSettings.NameESP.enabled)
        updateButtonState("ESP Distance", playerSettings.DistanceESP.enabled)
        updateButtonState("ESP Box", playerSettings.BoxESP.enabled)
        updateButtonState("Chams", playerSettings.Chams.enabled)
        updateButtonState("Spectate Player", playerSettings.SpectatePlayer.enabled)
    end)
    print("Player buttons loaded successfully")
    return true
end

function PlayerModule.resetStates()
    playerSettings.MagnetPlayer.enabled = false
    playerSettings.ESP.enabled = false
    playerSettings.ESPHealth.enabled = false
    playerSettings.NameESP.enabled = false
    playerSettings.DistanceESP.enabled = false
    playerSettings.BoxESP.enabled = false
    playerSettings.Chams.enabled = false
    playerSettings.SpectatePlayer.enabled = false
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end
    if spectateConnection then
        spectateConnection:Disconnect()
        spectateConnection = nil
    end
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    if respawnConnection then
        respawnConnection:Disconnect()
        respawnConnection = nil
    end
    for _, espList in pairs(espObjects) do
        for _, espObj in pairs(espList) do
            if espObj and espObj.Parent then espObj:Destroy() end
        end
    end
    espObjects = {highlight = {}, health = {}, name = {}, distance = {}, box = {}, chams = {}}
    disableSpectate()
    resetCameraMode()
    for buttonName, _ in pairs(buttonStates) do
        updateButtonState(buttonName, false)
    end
    print("Player module states reset successfully")
    return true
end

function PlayerModule.saveSettings()
    return {
        MagnetPlayer = {
            enabled = playerSettings.MagnetPlayer.enabled,
            distance = playerSettings.MagnetPlayer.distance,
            speed = playerSettings.MagnetPlayer.speed
        },
        ESP = {
            enabled = playerSettings.ESP.enabled,
            color = playerSettings.ESP.color,
            ignoreTeam = playerSettings.ESP.ignoreTeam,
            transparency = playerSettings.ESP.transparency
        },
        ESPHealth = {
            enabled = playerSettings.ESPHealth.enabled,
            ignoreTeam = playerSettings.ESPHealth.ignoreTeam
        },
        NameESP = {
            enabled = playerSettings.NameESP.enabled,
            ignoreTeam = playerSettings.NameESP.ignoreTeam,
            color = playerSettings.NameESP.color
        },
        DistanceESP = {
            enabled = playerSettings.DistanceESP.enabled,
            ignoreTeam = playerSettings.DistanceESP.ignoreTeam,
            color = playerSettings.DistanceESP.color
        },
        BoxESP = {
            enabled = playerSettings.BoxESP.enabled,
            ignoreTeam = playerSettings.BoxESP.ignoreTeam,
            color = playerSettings.BoxESP.color
        },
        Chams = {
            enabled = playerSettings.Chams.enabled,
            ignoreTeam = playerSettings.Chams.ignoreTeam,
            color = playerSettings.Chams.color
        },
        SpectatePlayer = {
            enabled = playerSettings.SpectatePlayer.enabled
        },
        CameraMode = {
            currentMode = playerSettings.CameraMode.currentMode
        },
        selectedPlayerName = selectedPlayer and selectedPlayer.Name or nil,
        currentColorIndex = currentColorIndex
    }
end

function PlayerModule.loadSettings(savedSettings)
    if not savedSettings then return false end
    for category, settings in pairs(savedSettings) do
        if playerSettings[category] then
            for setting, value in pairs(settings) do
                if playerSettings[category][setting] ~= nil then
                    playerSettings[category][setting] = value
                end
            end
        end
    end
    if savedSettings.selectedPlayerName then
        local targetPlayer = Players:FindFirstChild(savedSettings.selectedPlayerName)
        if targetPlayer then
            selectedPlayer = targetPlayer
        end
    end
    if savedSettings.currentColorIndex then
        currentColorIndex = savedSettings.currentColorIndex
    end
    spawn(function()
        wait(1)
        reapplyAllFeatures()
    end)
    print("Settings loaded and features reapplied")
    return true
end

local function handlePlayerLeaving()
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == selectedPlayer then
            selectedPlayer = getNextPlayer()
            if selectedPlayer then
                print("Selected player left, switched to: " .. selectedPlayer.Name)
            else
                print("Selected player left, no other players available")
            end
        end
        wait(0.5)
        updateESP()
    end)
    Players.PlayerAdded:Connect(function(newPlayer)
        wait(2)
        updateESP()
        if not selectedPlayer and newPlayer ~= player then
            selectedPlayer = newPlayer
            print("New player joined and selected: " .. newPlayer.Name)
        end
    end)
end

local function enhancedInit()
    handlePlayerLeaving()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            p.CharacterAdded:Connect(function()
                wait(1)
                if playerSettings.ESP.enabled or playerSettings.ESPHealth.enabled or 
                   playerSettings.NameESP.enabled or playerSettings.DistanceESP.enabled or 
                   playerSettings.BoxESP.enabled or playerSettings.Chams.enabled then
                    updateESP()
                end
            end)
        end
    end
    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer ~= player then
            newPlayer.CharacterAdded:Connect(function()
                wait(1)
                if playerSettings.ESP.enabled or playerSettings.ESPHealth.enabled or 
                   playerSettings.NameESP.enabled or playerSettings.DistanceESP.enabled or 
                   playerSettings.BoxESP.enabled or playerSettings.Chams.enabled then
                    updateESP()
                end
            end)
        end
    end)
end

function PlayerModule.getDebugInfo()
    local debugInfo = {
        selectedPlayer = selectedPlayer and selectedPlayer.Name or "None",
        playerCount = #Players:GetPlayers(),
        espObjectsCount = {},
        activeConnections = {
            magnet = magnetConnection ~= nil,
            spectate = spectateConnection ~= nil,
            camera = cameraConnection ~= nil,
            respawn = respawnConnection ~= nil
        },
        settings = {
            magnetEnabled = playerSettings.MagnetPlayer.enabled,
            espEnabled = playerSettings.ESP.enabled,
            spectateEnabled = playerSettings.SpectatePlayer.enabled,
            cameraMode = playerSettings.CameraMode.currentMode
        },
        buttonStatesCount = 0
    }
    for espType, espList in pairs(espObjects) do
        debugInfo.espObjectsCount[espType] = #espList
    end
    for _ in pairs(buttonStates) do
        debugInfo.buttonStatesCount = debugInfo.buttonStatesCount + 1
    end
    return debugInfo
end

function PlayerModule.validateState()
    local issues = {}
    if not player then
        table.insert(issues, "Player reference is nil")
    end
    if not Players:FindFirstChild(player.Name) then
        table.insert(issues, "Player not found in Players service")
    end
    if selectedPlayer and not Players:FindFirstChild(selectedPlayer.Name) then
        table.insert(issues, "Selected player no longer exists")
        selectedPlayer = getNextPlayer()
    end
    local activeConnections = 0
    if magnetConnection then activeConnections = activeConnections + 1 end
    if spectateConnection then activeConnections = activeConnections + 1 end
    if cameraConnection then activeConnections = activeConnections + 1 end
    if respawnConnection then activeConnections = activeConnections + 1 end
    if activeConnections > 0 then
        print("Active connections: " .. activeConnections)
    end
    return issues
end

function PlayerModule.forceRefresh()
    print("Force refreshing all player features...")
    if playerSettings.MagnetPlayer.enabled then
        disableMagnetPlayer()
        wait(0.1)
        enableMagnetPlayer()
    end
    if playerSettings.SpectatePlayer.enabled then
        disableSpectate()
        wait(0.1)
        enableSpectate()
    end
    updateESP()
    for buttonName in pairs(buttonStates) do
        local enabled = false
        if buttonName == "Magnet Player" then enabled = playerSettings.MagnetPlayer.enabled
        elseif buttonName == "ESP Highlight" then enabled = playerSettings.ESP.enabled
        elseif buttonName == "ESP Health" then enabled = playerSettings.ESPHealth.enabled
        elseif buttonName == "ESP Names" then enabled = playerSettings.NameESP.enabled
        elseif buttonName == "ESP Distance" then enabled = playerSettings.DistanceESP.enabled
        elseif buttonName == "ESP Box" then enabled = playerSettings.BoxESP.enabled
        elseif buttonName == "Chams" then enabled = playerSettings.Chams.enabled
        elseif buttonName == "Spectate Player" then enabled = playerSettings.SpectatePlayer.enabled
        end
        updateButtonState(buttonName, enabled)
    end
    print("Force refresh completed")
end

spawn(function()
    wait(2)
    enhancedInit()
end)

return PlayerModule
