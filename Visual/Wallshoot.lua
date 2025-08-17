-- Wallshoot feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player
local wallshootConnection
local isActive = false

local function init(deps)
    player = deps.player
end

local function enable()
    isActive = true
    wallshootConnection = RunService.RenderStepped:Connect(function()
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(player.Character) then
                part.Transparency = math.max(part.Transparency, 0.7)
                part.CanCollide = false
            end
        end
    end)
end

local function disable()
    isActive = false
    if wallshootConnection then wallshootConnection:Disconnect() end
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(player.Character) then
            part.Transparency = 0
            part.CanCollide = true
        end
    end
end

return {
    init = init,
    enable = enable,
    disable = disable
}