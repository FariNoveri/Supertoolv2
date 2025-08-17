-- Movement module loader for MinimalHackGUI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Local variables
local player = Players.LocalPlayer
local character, humanoid, rootPart
local modules = {}
local connections = {}

-- Feature URLs
local featureURLs = {
    Fly = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/movement/Fly.lua",
    Noclip = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/movement/Noclip.lua",
    Speed = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/movement/Speed.lua",
    JumpHeight = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/movement/JumpHeight.lua",
    InfiniteJump = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/movement/InfiniteJump.lua"
}

-- Load feature module
local function loadFeature(featureName)
    if not featureURLs[featureName] then
        warn("No URL defined for feature: " .. featureName)
        return false
    end
    
    local success, result = pcall(function()
        local response = game:HttpGet(featureURLs[featureName])
        if not response or response == "" then
            warn("Empty or invalid response for feature: " .. featureName)
            return nil
        end
        local func = loadstring(response)
        if not func then
            warn("Failed to compile feature: " .. featureName)
            return nil
        end
        local module = func()
        if not module then
            warn("Feature " .. featureName .. " returned nil")
            return nil
        end
        return module
    end)
    
    if success and result then
        modules[featureName] = result
        print("Loaded feature: " .. featureName)
        return true
    else
        warn("Failed to load feature: " .. featureName .. " Error: " .. tostring(result))
        return false
    end
end

-- Initialize module
local function init(deps)
    player = deps.player or player
    character = deps.character
    humanoid = deps.humanoid
    rootPart = deps.rootPart
    connections = deps.connections or connections
    
    -- Load all feature modules
    for featureName, _ in pairs(featureURLs) do
        task.spawn(function() loadFeature(featureName) end)
    end
    
    -- Initialize feature modules
    for featureName, module in pairs(modules) do
        if module and type(module.init) == "function" then
            local success, result = pcall(function()
                module.init({
                    player = player,
                    character = character,
                    humanoid = humanoid,
                    rootPart = rootPart,
                    RunService = RunService,
                    UserInputService = UserInputService
                })
            end)
            if not success then
                warn("Failed to initialize feature " .. featureName .. ": " .. tostring(result))
            else
                print("Initialized feature: " .. featureName)
            end
        end
    end
end

-- Load movement buttons
local function loadMovementButtons(createButton, createToggleButton)
    for featureName, module in pairs(modules) do
        if module and type(module.enable) == "function" then
            local disableCallback = type(module.disable) == "function" and module.disable or nil
            createToggleButton(featureName, function(state)
                local success, result = pcall(function()
                    if state then
                        module.enable()
                    else
                        if disableCallback then
                            disableCallback()
                        end
                    end
                end)
                if not success then
                    warn("Error toggling feature " .. featureName .. ": " .. tostring(result))
                end
            end, "Movement", disableCallback)
        end
    end
end

-- Reset states
local function resetStates()
    for featureName, module in pairs(modules) do
        if module and type(module.disable) == "function" then
            pcall(function() module.disable() end)
        end
    end
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    connections = {}
end

return {
    init = init,
    loadMovementButtons = loadMovementButtons,
    resetStates = resetStates
}