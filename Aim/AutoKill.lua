-- AutoKill feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player, selectedPlayer
local autoKillConnection
local isActive = false

local function init(deps)
    player = deps.player
    selectedPlayer = deps.selectedPlayer
end

local function enable(target)
    selectedPlayer = target or selectedPlayer
    if not selectedPlayer or not player.Character or not selectedPlayer.Character then return end
    isActive = true
    autoKillConnection = RunService.Heartbeat:Connect(function()
        local targetHumanoid = selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoid and targetHumanoid.Health > 0 then
            targetHumanoid.Health = 0
        end
    end)
end

local function disable()
    isActive = false
    if autoKillConnection then autoKillConnection:Disconnect() end
end

return {
    init = init,
    enable = enable,
    disable = disable
}