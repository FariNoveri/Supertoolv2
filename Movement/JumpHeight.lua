-- JumpHeight feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")

local player, humanoid
local defaultJumpHeight = 7.2
local jumpHeight = 7.2

local function init(deps)
    player = deps.player
    humanoid = deps.humanoid
    jumpHeight = deps.settings and deps.settings.JumpHeight.value or jumpHeight
    defaultJumpHeight = deps.settings and deps.settings.JumpHeight.default or defaultJumpHeight
end

local function enable()
    if humanoid then
        humanoid.JumpHeight = jumpHeight
    end
end

local function disable()
    if humanoid then
        humanoid.JumpHeight = defaultJumpHeight
    end
end

return {
    init = init,
    enable = enable,
    disable = disable
}