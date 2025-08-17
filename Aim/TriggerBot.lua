-- TriggerBot feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player, selectedPlayer
local triggerConnection
local isActive = false

local function init(deps)
    player = deps.player
    selectedPlayer = deps.selectedPlayer
end

local function enable(target)
    selectedPlayer = target or selectedPlayer
    if not selectedPlayer or not player.Character or not selectedPlayer.Character then return end
    isActive = true
    triggerConnection = RunService.RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
        local targetPart = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head")
        if targetPart then
            local screenPoint = camera:WorldToViewportPoint(targetPart.Position)
            local onScreen = screenPoint.Z > 0
            if onScreen and UserInputService.TouchEnabled then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    -- Simulate firing (simplified)
                    print("TriggerBot fired at: " .. selectedPlayer.Name)
                end
            end
        end
    end)
end

local function disable()
    isActive = false
    if triggerConnection then triggerConnection:Disconnect() end
end

return {
    init = init,
    enable = enable,
    disable = disable
}