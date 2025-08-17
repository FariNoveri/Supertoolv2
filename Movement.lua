-- Movement module loader for MinimalHackGUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character, humanoid, rootPart
local modules = {}
local connections = {}

local featureURLs = {
    Fly = "https://raw.githubusercontent.com/FariNoveri/Supertool/main/Backup/movement/Fly.lua"
}

local function loadFeature(featureName)
    if not featureURLs[featureName] then
        warn("No URL defined for feature: " .. featureName .. " URL: " .. tostring(featureURLs[featureName]))
        return false
    end
    local success, result = pcall(function()
        local response = game:HttpGet(featureURLs[featureName], true, 10)
        if not response or response == "" then
            warn("Empty response for feature: " .. featureName .. " URL: " .. featureURLs[featureName])
            return nil
        end
        local func, compileError = loadstring(response)
        if not func then
            warn("Failed to compile feature: " .. featureName .. " Error: " .. tostring(compileError))
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

local function init(deps)
    player = deps.player or player
    character = deps.character
    humanoid = deps.humanoid
    rootPart = deps.rootPart
    connections = deps.connections or connections
    for featureName, _ in pairs(featureURLs) do
        task.spawn(function() loadFeature(featureName) end)
    end
    task.wait(0.1)
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
        else
            warn("Feature " .. featureName .. " missing enable function")
        end
    end
end

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