-- Player module loader for MinimalHackGUI

-- Services
local Players = game:GetService("Players")

-- Local variables
local player = Players.LocalPlayer
local selectedPlayer = nil
local modules = {}
local connections = {}

-- Feature URLs
local featureURLs = {
    Kill = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/player/Kill.lua",
    Respawn = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/player/Respawn.lua",
    Kick = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/player/Kick.lua",
    TeleportTo = "https://raw.githubusercontent.com/FariNoveri/SupertoolV2/main/Backup/player/TeleportTo.lua"
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
                    Players = Players,
                    selectedPlayer = selectedPlayer
                })
            end)
            if not success then
                warn("Failed to initialize feature " .. featureName .. ": " .. tostring(result))
            else
                print("Initialized feature: " .. featureName)
            end
        end
    end
    
    -- Player selection logic
    connections.playerAdded = Players.PlayerAdded:Connect(function(newPlayer)
        if not selectedPlayer then
            selectedPlayer = newPlayer
            print("Selected player: " .. newPlayer.Name)
        end
    end)
    
    connections.playerRemoving = Players.PlayerRemoving:Connect(function(leavingPlayer)
        if selectedPlayer == leavingPlayer then
            selectedPlayer = nil
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    selectedPlayer = p
                    print("New selected player: " .. p.Name)
                    break
                end
            end
        end
    end)
end

-- Get selected player
local function getSelectedPlayer()
    return selectedPlayer
end

-- Load player buttons
local function loadPlayerButtons(createButton, createToggleButton, currentSelectedPlayer)
    selectedPlayer = currentSelectedPlayer or selectedPlayer
    
    -- Create button to select a player
    createButton("Select Player", function()
        local players = Players:GetPlayers()
        local index = selectedPlayer and table.find(players, selectedPlayer) or 1
        index = index % #players + 1
        selectedPlayer = players[index]
        print("Selected player: " .. (selectedPlayer and selectedPlayer.Name or "None"))
    end, "Player")
    
    -- Load feature buttons
    for featureName, module in pairs(modules) do
        if module and type(module.enable) == "function" then
            local disableCallback = type(module.disable) == "function" and module.disable or nil
            createToggleButton(featureName, function(state)
                local success, result = pcall(function()
                    if state then
                        module.enable(selectedPlayer)
                    else
                        if disableCallback then
                            disableCallback(selectedPlayer)
                        end
                    end
                end)
                if not success then
                    warn("Error toggling feature " .. featureName .. ": " .. tostring(result))
                end
            end, "Player", disableCallback)
        end
    end
end

-- Reset states
local function resetStates()
    for featureName, module in pairs(modules) do
        if module and type(module.disable) == "function" then
            pcall(function() module.disable(selectedPlayer) end)
        end
    end
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    connections = {}
    selectedPlayer = nil
end

return {
    init = init,
    getSelectedPlayer = getSelectedPlayer,
    loadPlayerButtons = loadPlayerButtons,
    resetStates = resetStates
}