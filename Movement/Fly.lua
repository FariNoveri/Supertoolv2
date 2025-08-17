-- Fly feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player, humanoid, rootPart
local flyConnection
local isFlying = false
local flySpeed = 50
local bodyVelocity, bodyGyro

local function init(deps)
    player = deps.player
    humanoid = deps.humanoid
    rootPart = deps.rootPart
    flySpeed = deps.settings and deps.settings.FlySpeed.value or flySpeed
end

local function updateFly()
    if not isFlying or not humanoid or not rootPart then return end
    local moveDirection = Vector3.new(0, 0, 0)
    
    -- Mobile-friendly touch input
    if UserInputService.TouchEnabled then
        for _, touch in pairs(UserInputService:GetTouchInput()) do
            local screenPos = touch.Position
            local screenMid = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
            local delta = (screenPos - screenMid).Unit * flySpeed
            moveDirection = moveDirection + Vector3.new(delta.X, delta.Y, 0)
        end
    end
    
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = moveDirection
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
end

local function enable()
    if not humanoid or not rootPart then return end
    isFlying = true
    humanoid.PlatformStand = true
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Parent = rootPart
    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = rootPart
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    flyConnection = RunService.RenderStepped:Connect(updateFly)
end

local function disable()
    isFlying = false
    if humanoid then humanoid.PlatformStand = false end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
end

return {
    init = init,
    enable = enable,
    disable = disable
}