-- Aimbot feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player, selectedPlayer
local aimConnection
local isAiming = false

local function init(deps)
    player = deps.player
    selectedPlayer = deps.selectedPlayer
end

local function enable(target)
    selectedPlayer = target or selectedPlayer
    if not selectedPlayer or not player.Character or not selectedPlayer.Character then return end
    isAiming = true
    aimConnection = RunService.RenderStepped:Connect(function()
        local targetPart = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head")
        if targetPart then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
        end
    end)
end

local function disable()
    isAiming = false
    if aimConnection then aimConnection:Disconnect() end
end

return {
    init = init,
    enable = enable,
    disable = disable
}