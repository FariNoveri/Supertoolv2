-- Tracers feature for MinimalHackGUI (Mobile-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player
local tracerConnections = {}
local tracerParts = {}
local isActive = false

local function init(deps)
    player = deps.player
end

local function addTracer(target)
    if not target.Character then return end
    local beam = Instance.new("Beam")
    beam.Parent = workspace
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    local attachment0 = Instance.new("Attachment", player.Character and player.Character:FindFirstChild("HumanoidRootPart") or workspace)
    local attachment1 = Instance.new("Attachment", target.Character:FindFirstChild("HumanoidRootPart"))
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    tracerParts[target] = {beam = beam, attachment0 = attachment0, attachment1 = attachment1}
end

local function enable()
    isActive = true
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            addTracer(p)
        end
    end
    tracerConnections["playerAdded"] = Players.PlayerAdded:Connect(function(p)
        if p ~= player then
            addTracer(p)
        end
    end)
    tracerConnections["update"] = RunService.RenderStepped:Connect(function()
        for target, data in pairs(tracerParts) do
            if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
                data.beam:Destroy()
                data.attachment0:Destroy()
                data.attachment1:Destroy()
                tracerParts[target] = nil
            end
        end
    end)
end

local function disable()
    isActive = false
    for _, data in pairs(tracerParts) do
        if data.beam then data.beam:Destroy() end
        if data.attachment0 then data.attachment0:Destroy() end
        if data.attachment1 then data.attachment1:Destroy() end
    end
    for _, conn in pairs(tracerConnections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    tracerParts = {}
    tracerConnections = {}
end

return {
    init = init,
    enable = enable,
    disable = disable
}