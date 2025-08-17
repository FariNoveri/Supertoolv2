-- [Previous script content unchanged until moduleURLs]

-- Load modules
local modules = {}
local modulesLoaded = {}

local moduleURLs = {
    Movement = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/Movement.lua",
    Player = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/Player.lua",
    Aim = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/Aim.lua",
    Visual = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/Visual.lua",
    Brutal = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/Brutal.lua",
    Settings = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/Settings.lua",
    Info = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/Info.lua"
}

local function loadModule(moduleName)
    if not moduleURLs[moduleName] then
        warn("No URL defined for module: " .. moduleName)
        return false
    end
    
    local success, result = pcall(function()
        local response = game:HttpGet(moduleURLs[moduleName])
        if not response or response == "" then
            warn("Empty or invalid response for module: " .. moduleName)
            return nil
        end
        local func = loadstring(response)
        if not func then
            warn("Failed to compile module: " .. moduleName)
            return nil
        end
        local module = func()
        if not module then
            warn("Module " .. moduleName .. " returned nil")
            return nil
        end
        return module
    end)
    
    if success and result then
        modules[moduleName] = result
        modulesLoaded[moduleName] = true
        print("Loaded module: " .. moduleName)
        if selectedCategory == moduleName then
            task.spawn(loadButtons)
        end
        return true
    else
        warn("Failed to load module: " .. moduleName .. " Error: " .. tostring(result))
        return false
    end
end

-- Load all modules
for moduleName, _ in pairs(moduleURLs) do
    task.spawn(function() loadModule(moduleName) end)
end

-- Dependencies
local dependencies = {
    Players = Players,
    UserInputService = UserInputService,
    RunService = RunService,
    Workspace = Workspace,
    Lighting = Lighting,
    ScreenGui = ScreenGui,
    settings = settings,
    connections = connections,
    buttonStates = buttonStates,
    player = player,
    disableActiveFeature = disableActiveFeature,
    isExclusiveFeature = isExclusiveFeature
}

-- Initialize modules
local function initializeModules()
    for moduleName, module in pairs(modules) do
        if module and type(module.init) == "function" then
            local success, result = pcall(function()
                dependencies.character = character
                dependencies.humanoid = humanoid
                dependencies.rootPart = rootPart
                return module.init(dependencies)
            end)
            if not success then
                warn("Failed to initialize module " .. moduleName .. ": " .. tostring(result))
            else
                print("Initialized module: " .. moduleName)
            end
        end
    end
end

-- Create button
local function createButton(name, callback, categoryName)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = FeatureContainer
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, -2, 0, 20)
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 8
    button.LayoutOrder = #FeatureContainer:GetChildren()
    
    if type(callback) == "function" then
        button.MouseButton1Click:Connect(function()
            if isExclusiveFeature(name) then
                disableActiveFeature()
                activeFeature = {
                    name = name,
                    category = categoryName,
                    disableCallback = nil
                }
            end
            callback()
        end)
    end
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    print("Created button: " .. name .. " for category: " .. categoryName)
end

-- Create toggle button
local function createToggleButton(name, callback, categoryName, disableCallback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = FeatureContainer
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, -2, 0, 20)
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 8
    button.LayoutOrder = #FeatureContainer:GetChildren()
    
    if categoryStates[categoryName][name] == nil then
        categoryStates[categoryName][name] = false
    end
    button.BackgroundColor3 = categoryStates[categoryName][name] and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(60, 60, 60)
    
    button.MouseButton1Click:Connect(function()
        local newState = not categoryStates[categoryName][name]
        
        if newState and isExclusiveFeature(name) then
            disableActiveFeature()
            activeFeature = {
                name = name,
                category = categoryName,
                disableCallback = disableCallback
            }
        elseif not newState and activeFeature and activeFeature.name == name then
            activeFeature = nil
        end
        
        categoryStates[categoryName][name] = newState
        button.BackgroundColor3 = newState and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(60, 60, 60)
        
        if type(callback) == "function" then
            callback(newState)
        end
    end)
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = categoryStates[categoryName][name] and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 80, 80)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = categoryStates[categoryName][name] and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(60, 60, 60)
    end)
    print("Created toggle button: " .. name .. " for category: " .. categoryName)
end

-- Load buttons implementation
local function loadButtons()
    for _, child in pairs(FeatureContainer:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for categoryName, categoryData in pairs(categoryFrames) do
        categoryData.button.BackgroundColor3 = categoryName == selectedCategory and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(25, 25, 25)
    end

    if not selectedCategory then
        warn("No category selected!")
        return
    end
    
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Parent = FeatureContainer
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Size = UDim2.new(1, -2, 0, 20)
    loadingLabel.Font = Enum.Font.Gotham
    loadingLabel.Text = "Loading " .. selectedCategory .. "..."
    loadingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadingLabel.TextSize = 8
    loadingLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        task.wait(0.2)
        
        local success = false
        local errorMessage = nil

        if selectedCategory == "Movement" and modules.Movement and type(modules.Movement.loadMovementButtons) == "function" then
            success, errorMessage = pcall(function()
                print("Loading Movement buttons...")
                modules.Movement.loadMovementButtons(
                    function(name, callback) createButton(name, callback, "Movement") end,
                    function(name, callback, disableCallback) createToggleButton(name, callback, "Movement", disableCallback) end
                )
            end)
        elseif selectedCategory == "Player" and modules.Player and type(modules.Player.loadPlayerButtons) == "function" then
            success, errorMessage = pcall(function()
                local selectedPlayer = modules.Player.getSelectedPlayer and modules.Player.getSelectedPlayer() or nil
                print("Loading Player buttons with selectedPlayer: " .. tostring(selectedPlayer))
                modules.Player.loadPlayerButtons(
                    function(name, callback) createButton(name, callback, "Player") end,
                    function(name, callback, disableCallback) createToggleButton(name, callback, "Player", disableCallback) end,
                    selectedPlayer
                )
            end)
        elseif selectedCategory == "Aim" and modules.Aim and type(modules.Aim.loadAimButtons) == "function" then
            success, errorMessage = pcall(function()
                local selectedPlayer = modules.Player and modules.Player.getSelectedPlayer and modules.Player.getSelectedPlayer() or nil
                print("Loading Aim buttons with selectedPlayer: " .. tostring(selectedPlayer))
                modules.Aim.loadAimButtons(
                    function(name, callback) createButton(name, callback, "Aim") end,
                    function(name, callback, disableCallback) createToggleButton(name, callback, "Aim", disableCallback) end,
                    selectedPlayer
                )
            end)
        elseif selectedCategory == "Visual" and modules.Visual and type(modules.Visual.loadVisualButtons) == "function" then
            success, errorMessage = pcall(function()
                print("Loading Visual buttons...")
                modules.Visual.loadVisualButtons(function(name, callback, disableCallback)
                    createToggleButton(name, callback, "Visual", disableCallback)
                end)
            end)
        elseif selectedCategory == "Brutal" and modules.Brutal and type(modules.Brutal.loadBrutalButtons) == "function" then
            success, errorMessage = pcall(function()
                print("Loading Brutal buttons...")
                modules.Brutal.loadBrutalButtons(
                    function(name, callback) createButton(name, callback, "Brutal") end,
                    function(name, callback, disableCallback) createToggleButton(name, callback, "Brutal", disableCallback) end
                )
            end)
        elseif selectedCategory == "Settings" and modules.Settings and type(modules.Settings.loadSettingsButtons) == "function" then
            success, errorMessage = pcall(function()
                print("Loading Settings buttons...")
                modules.Settings.loadSettingsButtons(function(name, callback)
                    createButton(name, callback, "Settings")
                end)
            end)
        elseif selectedCategory == "Info" and modules.Info and type(modules.Info.loadInfoButtons) == "function" then
            success, errorMessage = pcall(function()
                print("Loading Info buttons...")
                modules.Info.loadInfoButtons(function(name, callback)
                    createButton(name, callback, "Info")
                end)
            end)
        else
            errorMessage = "Module for " .. selectedCategory .. " not loaded or invalid!"
            warn(errorMessage)
        end

        if loadingLabel and loadingLabel.Parent then
            if not success or errorMessage then
                loadingLabel.Text = "Failed to load " .. selectedCategory .. " buttons: " .. tostring(errorMessage)
                loadingLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            else
                loadingLabel:Destroy()
            end
        end
    end)
end

-- Create category buttons
for _, category in ipairs(categories) do
    local categoryButton = Instance.new("TextButton")
    categoryButton.Name = category.name .. "Category"
    categoryButton.Parent = CategoryContainer
    categoryButton.BackgroundColor3 = selectedCategory == category.name and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(25, 25, 25)
    categoryButton.BorderColor3 = Color3.fromRGB(45, 45, 45)
    categoryButton.Size = UDim2.new(1, -5, 0, 25)
    categoryButton.LayoutOrder = category.order
    categoryButton.Font = Enum.Font.GothamBold
    categoryButton.Text = category.name
    categoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    categoryButton.TextSize = 8

    categoryButton.MouseButton1Click:Connect(function()
        selectedCategory = category.name
        task.spawn(loadButtons)
    end)

    categoryButton.MouseEnter:Connect(function()
        if selectedCategory ~= category.name then
            categoryButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
    end)

    categoryButton.MouseLeave:Connect(function()
        if selectedCategory ~= category.name then
            categoryButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
    end)

    categoryFrames[category.name] = {button = categoryButton}
    categoryStates[category.name] = {}
end

-- Minimize/Maximize
local function toggleMinimize()
    isMinimized = not isMinimized
    Frame.Visible = not isMinimized
    MinimizedLogo.Visible = isMinimized
    MinimizeButton.Text = isMinimized and "+" or "-"
end

-- Reset states
local function resetStates()
    print("Resetting all states")
    activeFeature = nil -- Reset active feature
    
    for _, connection in pairs(connections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end
    connections = {}
    
    for _, module in pairs(modules) do
        if module and type(module.resetStates) == "function" then
            pcall(function() module.resetStates() end)
        end
    end
    
    if selectedCategory then
        task.spawn(loadButtons)
    end
end

-- Character setup
local function onCharacterAdded(newCharacter)
    if not newCharacter then return end
    
    local success, result = pcall(function()
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid", 30)
        rootPart = character:WaitForChild("HumanoidRootPart", 30)
        
        dependencies.character = character
        dependencies.humanoid = humanoid
        dependencies.rootPart = rootPart
        
        initializeModules()
        
        if humanoid and humanoid.Died then
            connections.humanoidDied = humanoid.Died:Connect(resetStates)
        end
    end)
    if not success then
        warn("Failed to set up character: " .. tostring(result))
    end
end

-- Initialize
if player.Character then
    onCharacterAdded(player.Character)
end
connections.characterAdded = player.CharacterAdded:Connect(onCharacterAdded)

-- Event connections
MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
LogoButton.MouseButton1Click:Connect(toggleMinimize)

connections.toggleGui = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Home then
        toggleMinimize()
    end
end)

-- Start initialization
task.spawn(function()
    local timeout = 15
    local startTime = tick()
    
    -- Wait for critical modules to load
    while (not modules.Movement or not modules.Player or not modules.Teleport) and tick() - startTime < timeout do
        task.wait(0.1)
    end

    -- Check if modules loaded successfully
    for _, moduleName in ipairs({"Movement", "Player", "Teleport"}) do
        if not modules[moduleName] then
            warn("Failed to load " .. moduleName .. " module after timeout!")
        else
            print(moduleName .. " module loaded successfully")
        end
    end

    initializeModules()
    task.spawn(loadButtons)
end)