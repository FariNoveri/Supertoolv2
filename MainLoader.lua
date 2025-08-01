local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local mouse = player:GetMouse()

-- Unique identifier for this script instance
local SCRIPT_ID = tostring(math.random(1, 1000000))
local ACTIVE_SCRIPT_ID = SCRIPT_ID

-- Fungsi untuk mengecek dan menonaktifkan instance sebelumnya
local function disablePreviousInstance()
    local success, errorMsg = pcall(function()
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "AutoSpawnGUI" and gui:FindFirstChild("ScriptID") then
                local scriptIdValue = gui:FindFirstChild("ScriptID")
                if scriptIdValue.Value ~= ACTIVE_SCRIPT_ID then
                    gui:Destroy()
                end
            end
        end
    end)
    if not success then
        print("Error disabling previous instance: " .. tostring(errorMsg))
    end
end

-- Fungsi untuk notifikasi
local function notify(message, color)
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(0, 200, 0, 50)
    label.Position = UDim2.new(0.5, -100, 0.1, 0)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.BackgroundTransparency = 0.5
    label.TextColor3 = color or Color3.fromRGB(0, 255, 0)
    label.Text = message
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    task.spawn(function()
        task.wait(3)
        gui:Destroy()
    end)
end

-- Fungsi untuk mendeteksi object yang bisa di-spawn
local function detectSpawnableObjects()
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return {} end
    local spawnableObjects = {}
    local success, errorMsg = pcall(function()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("Tool") or obj.Name:lower():match("item") then
                table.insert(spawnableObjects, obj.Name)
            end
        end
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (remote.Name:lower():match("spawn") or remote.Name:lower():match("item")) then
                table.insert(spawnableObjects, "Remote: " .. remote.Name)
            end
        end
        if #spawnableObjects == 0 then
            table.insert(spawnableObjects, "BasicPart")
        end
    end)
    if not success then
        notify("⚠️ Detection failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
        return {"BasicPart"}
    end
    return spawnableObjects
end

-- Fungsi untuk spawn object client-side
local function spawnClientSideObject(objectName, position)
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
    local success, errorMsg = pcall(function()
        local part = Instance.new("Part")
        part.Size = Vector3.new(5, 1, 5)
        part.Position = position or player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        part.BrickColor = BrickColor.new("Really red")
        part.Anchored = true
        part.CanCollide = true
        part.Name = objectName
        part.Parent = workspace
        notify("🟥 Client-side " .. objectName .. " Spawned", Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ Client-side spawn failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Fungsi untuk spawn object server-side
local function spawnServerSideObject(objectName, position)
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
    local success, errorMsg = pcall(function()
        local remote
        if objectName:match("Remote: ") then
            local remoteName = objectName:gsub("Remote: ", "")
            remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        else
            for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                if r:IsA("RemoteEvent") and (r.Name:lower():match("spawn") or r.Name:lower():match("item")) then
                    remote = r
                    break
                end
            end
        end
        if not remote then
            notify("⚠️ No spawn Remote Event found", Color3.fromRGB(255, 100, 100))
            return
        end
        local objectData = {
            Name = objectName,
            ClassName = objectName == "BasicPart" and "Part" or "Model",
            Position = position or player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0),
            Size = objectName == "BasicPart" and Vector3.new(5, 1, 5) or nil,
            BrickColor = objectName == "BasicPart" and BrickColor.new("Really red") or nil,
            Anchored = true,
            CanCollide = true
        }
        remote:FireServer(objectData)
        notify("🟥 Attempted server-side spawn: " .. objectName, Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ Server-side spawn failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Fungsi untuk copy avatar
local function copyAvatar(targetPlayer)
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
    local success, errorMsg = pcall(function()
        if not targetPlayer.Character then return end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or not targetHumanoid then return end

        local description = targetHumanoid:GetAppliedDescription()
        humanoid:ApplyDescription(description)

        for _, accessory in pairs(player.Character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end
        for _, accessory in pairs(targetPlayer.Character:GetChildren()) do
            if accessory:IsA("Accessory") then
                local newAccessory = accessory:Clone()
                newAccessory.Parent = player.Character
            end
        end
        notify("👤 Copied avatar from " .. targetPlayer.Name, Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ Failed to copy avatar: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Fungsi untuk teleport player
local function teleportPlayer(targetPlayer)
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
    local success, errorMsg = pcall(function()
        if not targetPlayer.Character or not player.Character then return end
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot or not playerRoot then return end
        playerRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
        notify("🚀 Teleported to " .. targetPlayer.Name, Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ Failed to teleport: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Fungsi untuk membuat GUI dengan dropdown
local function createGUI()
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
    local success, errorMsg = pcall(function()
        -- Nonaktifkan instance sebelumnya
        disablePreviousInstance()

        local gui = Instance.new("ScreenGui")
        gui.Name = "AutoSpawnGUI"
        gui.ResetOnSpawn = false
        gui.Parent = player.PlayerGui

        -- Simpan Script ID
        local scriptIdValue = Instance.new("StringValue")
        scriptIdValue.Name = "ScriptID"
        scriptIdValue.Value = SCRIPT_ID
        scriptIdValue.Parent = gui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 350)
        frame.Position = UDim2.new(0.5, -150, 0.5, -175)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 0.1
        frame.Parent = gui
        frame.Active = true
        frame.Draggable = true

        local uil = Instance.new("UIListLayout")
        uil.FillDirection = Enum.FillDirection.Vertical
        uil.Padding = UDim.new(0, 5)
        uil.Parent = frame

        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 30)
        titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        titleBar.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0.8, 0, 1, 0)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Text = "Auto Spawn & Player Control"
        title.TextScaled = true
        title.Font = Enum.Font.Gotham
        title.Parent = titleBar

        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Size = UDim2.new(0.1, 0, 1, 0)
        minimizeBtn.Position = UDim2.new(0.8, 0, 0, 0)
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
        minimizeBtn.Text = "-"
        minimizeBtn.TextScaled = true
        minimizeBtn.Parent = titleBar

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0.1, 0, 1, 0)
        closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.Text = "X"
        closeBtn.TextScaled = true
        closeBtn.Parent = titleBar

        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, 0, 1, -30)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Parent = frame
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.FillDirection = Enum.FillDirection.Vertical
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.Parent = contentFrame

        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 40)
        dropdownFrame.Position = UDim2.new(0.05, 0, 0, 0)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        dropdownFrame.Parent = contentFrame

        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Size = UDim2.new(0.8, 0, 1, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.TextColor3 = Color3.new(1, 1, 1)
        dropdownLabel.Text = "Select Object"
        dropdownLabel.TextScaled = true
        dropdownLabel.Font = Enum.Font.Gotham
        dropdownLabel.Parent = dropdownFrame

        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Size = UDim2.new(0.2, 0, 1, 0)
        dropdownBtn.Position = UDim2.new(0.8, 0, 0, 0)
        dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
        dropdownBtn.Text = "▼"
        dropdownBtn.TextScaled = true
        dropdownBtn.Parent = dropdownFrame

        local dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(0.9, 0, 0, 0)
        dropdownList.Position = UDim2.new(0.05, 0, 0, 40)
        dropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        dropdownList.Visible = false
        local dropdownListLayout = Instance.new("UIListLayout")
        dropdownListLayout.FillDirection = Enum.FillDirection.Vertical
        dropdownListLayout.Padding = UDim.new(0, 2)
        dropdownListLayout.Parent = dropdownList
        dropdownList.Parent = contentFrame

        local spawnableObjects = detectSpawnableObjects()
        for _, objName in ipairs(spawnableObjects) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            itemBtn.TextColor3 = Color3.new(1, 1, 1)
            itemBtn.Text = objName
            itemBtn.TextScaled = true
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.Parent = dropdownList
            itemBtn.MouseButton1Click:Connect(function()
                if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
                dropdownLabel.Text = "Selected: " .. objName
                dropdownList.Visible = false
                dropdownBtn.Text = "▼"
            end)
        end
        dropdownList.Size = UDim2.new(0.9, 0, 0, #spawnableObjects * 32)

        dropdownBtn.MouseButton1Click:Connect(function()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            dropdownList.Visible = not dropdownList.Visible
            dropdownBtn.Text = dropdownList.Visible and "▲" or "▼"
        end)

        -- Player selection dropdown
        local playerDropdownFrame = Instance.new("Frame")
        playerDropdownFrame.Size = UDim2.new(0.9, 0, 0, 40)
        playerDropdownFrame.Position = UDim2.new(0.05, 0, 0, 0)
        playerDropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        playerDropdownFrame.Parent = contentFrame

        local playerDropdownLabel = Instance.new("TextLabel")
        playerDropdownLabel.Size = UDim2.new(0.8, 0, 1, 0)
        playerDropdownLabel.BackgroundTransparency = 1
        playerDropdownLabel.TextColor3 = Color3.new(1, 1, 1)
        playerDropdownLabel.Text = "Select Player"
        playerDropdownLabel.TextScaled = true
        playerDropdownLabel.Font = Enum.Font.Gotham
        playerDropdownLabel.Parent = playerDropdownFrame

        local playerDropdownBtn = Instance.new("TextButton")
        playerDropdownBtn.Size = UDim2.new(0.2, 0, 1, 0)
        playerDropdownBtn.Position = UDim2.new(0.8, 0, 0, 0)
        playerDropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        playerDropdownBtn.TextColor3 = Color3.new(1, 1, 1)
        playerDropdownBtn.Text = "▼"
        playerDropdownBtn.TextScaled = true
        playerDropdownBtn.Parent = playerDropdownFrame

        local playerDropdownList = Instance.new("Frame")
        playerDropdownList.Size = UDim2.new(0.9, 0, 0, 0)
        playerDropdownList.Position = UDim2.new(0.05, 0, 0, 40)
        playerDropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        playerDropdownList.Visible = false
        local playerDropdownListLayout = Instance.new("UIListLayout")
        playerDropdownListLayout.FillDirection = Enum.FillDirection.Vertical
        playerDropdownListLayout.Padding = UDim.new(0, 2)
        playerDropdownListLayout.Parent = playerDropdownList
        playerDropdownList.Parent = contentFrame

        local function updatePlayerList()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            playerDropdownList:ClearAllChildren()
            playerDropdownListLayout:Clone().Parent = playerDropdownList
            local players = Players:GetPlayers()
            for _, p in ipairs(players) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, 0, 0, 30)
                itemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                itemBtn.TextColor3 = Color3.new(1, 1, 1)
                itemBtn.Text = p.Name
                itemBtn.TextScaled = true
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.Parent = playerDropdownList
                itemBtn.MouseButton1Click:Connect(function()
                    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
                    playerDropdownLabel.Text = "Selected: " .. p.Name
                    playerDropdownList.Visible = false
                    playerDropdownBtn.Text = "▼"
                end)
            end
            playerDropdownList.Size = UDim2.new(0.9, 0, 0, #players * 32)
        end

        playerDropdownBtn.MouseButton1Click:Connect(function()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            updatePlayerList()
            playerDropdownList.Visible = not playerDropdownList.Visible
            playerDropdownBtn.Text = playerDropdownList.Visible and "▲" or "▼"
        end)

        local function createButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 40)
            btn.Position = UDim2.new(0.05, 0, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Text = text
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.Parent = contentFrame
            btn.MouseButton1Click:Connect(function()
                if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
                local success, errorMsg = pcall(callback)
                if not success then
                    notify("⚠️ Button error: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
                end
            end)
        end

        createButton("Spawn Client-Side", function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local selected = dropdownLabel.Text:match("Selected: (.+)") or "BasicPart"
                spawnClientSideObject(selected)
            else
                notify("⚠️ Character not loaded", Color3.fromRGB(255, 100, 100))
            end
        end)

        createButton("Spawn Server-Side", function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local selected = dropdownLabel.Text:match("Selected: (.+)") or "BasicPart"
                spawnServerSideObject(selected)
            else
                notify("⚠️ Character not loaded", Color3.fromRGB(255, 100, 100))
            end
        end)

        createButton("Copy Avatar", function()
            local selected = playerDropdownLabel.Text:match("Selected: (.+)")
            if selected then
                local target = Players:FindFirstChild(selected)
                if target then
                    copyAvatar(target)
                else
                    notify("⚠️ Player not found", Color3.fromRGB(255, 100, 100))
                end
            else
                notify("⚠️ Select a player first", Color3.fromRGB(255, 100, 100))
            end
        end)

        createButton("Teleport to Player", function()
            local selected = playerDropdownLabel.Text:match("Selected: (.+)")
            if selected then
                local target = Players:FindFirstChild(selected)
                if target then
                    teleportPlayer(target)
                else
                    notify("⚠️ Player not found", Color3.fromRGB(255, 100, 100))
                end
            else
                notify("⚠️ Select a player first", Color3.fromRGB(255, 100, 100))
            end
        end)

        minimizeBtn.MouseButton1Click:Connect(function()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            contentFrame.Visible = not contentFrame.Visible
            minimizeBtn.Text = contentFrame.Visible and "-" or "+"
            frame.Size = contentFrame.Visible and UDim2.new(0, 300, 0, 350) or UDim2.new(0, 300, 0, 30)
        end)

        closeBtn.MouseButton1Click:Connect(function()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            gui:Destroy()
            notify("🖼️ GUI Closed", Color3.fromRGB(0, 255, 0))
        end)

        notify("🖼️ Auto Spawn & Player Control GUI Loaded (ID: " .. SCRIPT_ID .. ")", Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ GUI creation failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Inisialisasi
local function initialize()
    local success, errorMsg = pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            createGUI()
        else
            player.CharacterAdded:Connect(function()
                task.wait(1)
                createGUI()
            end)
        end
    end)
    if not success then
        notify("⚠️ Initialization failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

initialize()