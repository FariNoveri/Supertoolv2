-- Noclip feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player, humanoid, rootPart
local noclipConnection
local isNoclipping = false

local function init(deps)
    player = deps.player
    humanoid = deps.humanoid
    rootPart = deps.rootPart
end

local function updateNoclip()
    if not isNoclipping or not humanoid or not rootPart then return end
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function enable()
    if not humanoid or not rootPart then return end
    isNoclipping = true
    noclipConnection = RunService.Stepped:Connect(updateNoclip)
end

local function disable()
    isNoclipping = false
    if noclipConnection then noclipConnection:Disconnect() end
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

return {
    init = init,
    enable = enable,
    disable = disable
}