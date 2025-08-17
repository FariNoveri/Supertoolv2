-- AimBullet feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player, selectedPlayer
local aimBulletConnection
local isActive = false

local function init(deps)
    player = deps.player
    selectedPlayer = deps.selectedPlayer
end

local function enable(target)
    selectedPlayer = target or selectedPlayer
    if not selectedPlayer or not player.Character or not selectedPlayer.Character then return end
    isActive = true
    aimBulletConnection = RunService.RenderStepped:Connect(function()
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            local targetPart = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                tool.CFrame = CFrame.new(tool.Position, targetPart.Position)
            end
        end
    end)
end

local function disable()
    isActive = false
    if aimBulletConnection then aimBulletConnection:Disconnect() end
end

return {
    init = init,
    enable = enable,
    disable = disable
}