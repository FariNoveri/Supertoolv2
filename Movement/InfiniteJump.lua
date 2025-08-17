-- InfiniteJump feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player, humanoid
local jumpConnection
local isInfiniteJump = false

local function init(deps)
    player = deps.player
    humanoid = deps.humanoid
end

local function enable()
    if not humanoid then return end
    isInfiniteJump = true
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if isInfiniteJump and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function disable()
    isInfiniteJump = false
    if jumpConnection then jumpConnection:Disconnect() end
end

return {
    init = init,
    enable = enable,
    disable = disable
}