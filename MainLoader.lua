-- Client-side script (main.lua)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- Unique identifier for this script instance
local SCRIPT_ID = tostring(math.random(1, 1000000))
local ACTIVE_SCRIPT_ID = SCRIPT_ID

-- Fungsi untuk notifikasi
local function notify(message, color)
    local success, errorMsg = pcall(function()
        local gui = Instance.new("ScreenGui", CoreGui)
        gui.Name = "NotifyGUI_" .. SCRIPT_ID
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
            task.wait(4)
            gui:Destroy()
        end)
    end)
    if not success then
        print("Notify error: " .. tostring(errorMsg))
    end
end

-- Fungsi untuk mengecek dan menonaktifkan instance sebelumnya
local function disablePreviousInstance()
    local success, errorMsg = pcall(function()
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui.Name:match("AutoSpawnGUI") and gui:FindFirstChild("ScriptID") then
                local scriptIdValue = gui:FindFirstChild("ScriptID")
                if scriptIdValue.Value ~= ACTIVE_SCRIPT_ID then
                    gui:Destroy()
                    notify("🗑️ Removed old GUI instance", Color3.fromRGB(255, 255, 0))
                end
            end
        end
    end)
    if not success then
        notify("⚠️ Error disabling previous instance: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Fungsi untuk mendeteksi object yang bisa di-spawn, termasuk rumah atau object besar
local function detectSpawnableObjects()
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return {} end
    local spawnableObjects = {}
    local success, errorMsg = pcall(function()
        -- Scan ReplicatedStorage
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if (obj:IsA("Model") and (obj.Name:lower():match("house") or 
               obj.Name:lower():match("building") or obj.Name:lower():match("structure"))) or
               obj:IsA("Part") or obj:IsA("Tool") or obj.Name:lower():match("item") then
                table.insert(spawnableObjects, obj.Name)
            end
        end
        -- Scan Workspace untuk model besar
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():match("house") or 
               obj.Name:lower():match("building") or obj.Name:lower():match("structure")) then
                table.insert(spawnableObjects, obj.Name)
            end
        end
        -- Scan Remote Events
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (remote.Name:lower():match("spawn") or 
               remote.Name:lower():match("item") or remote.Name:lower():match("place")) then
                table.insert(spawnableObjects, "Remote: " .. remote.Name)
            end
        end
        if #spawnableObjects == 0 then
            table.insert(spawnableObjects, "BasicPart")
        end
    end)
    if not success then
        notify("⚠️ Object detection failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
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
        notify("🟥 Client-side " .. objectName .. " spawned", Color3.fromRGB(0, 255, 0))
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
                if r:IsA("RemoteEvent") and (r.Name:lower():match("spawn") or 
                   r.Name:lower():match("item") or r.Name:lower():match("place")) then
                    remote = r
                    break
                end
            end
        end
        if not remote then
            notify("⚠️ No spawn RemoteEvent found", Color3.fromRGB(255, 100, 100))
            return
        end
        local model
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj.Name == objectName and obj:IsA("Model") then
                model = obj
                break
            end
        end
        if not model then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == objectName and obj:IsA("Model") then
                    model = obj
                    break
                end
            end
        end
        local objectData = {
            Name = objectName,
            ClassName = model and "Model" or "Part",
            Position = position or (player.Character and player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)) or Vector3.new(0, 5, 0),
            Size = not model and Vector3.new(5, 1, 5) or nil,
            BrickColor = not model and BrickColor.new("Really red") or nil,
            Anchored = true,
            CanCollide = true,
            ModelData = model and {Name = model.Name, PrimaryPart = model.PrimaryPart and model.PrimaryPart.CFrame or CFrame.new()}
        }
        remote:FireServer(objectData)
        notify("🟥 Attempted server-side spawn: " .. objectName, Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ Server-side spawn failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Fungsi untuk membuat GUI minimal
local function createGUI()
    if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
    local success, errorMsg = pcall(function()
        notify("🔄 Creating GUI...", Color3.fromRGB(255, 255, 0))
        disablePreviousInstance()

        local gui = Instance.new("ScreenGui")
        gui.Name = "AutoSpawnGUI_" .. SCRIPT_ID
        gui.ResetOnSpawn = false
        gui.Enabled = true
        gui.Parent = CoreGui

        local scriptIdValue = Instance.new("StringValue")
        scriptIdValue.Name = "ScriptID"
        scriptIdValue.Value = SCRIPT_ID
        scriptIdValue.Parent = gui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 150)
        frame.Position = UDim2.new(0.5, -100, 0.5, -75)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 0.2
        frame.Parent = gui
        frame.Active = true
        frame.Draggable = true

        local uil = Instance.new("UIListLayout")
        uil.FillDirection = Enum.FillDirection.Vertical
        uil.Padding = UDim.new(0, 5)
        uil.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Text = "Spawn Control"
        title.TextScaled = true
        title.Font = Enum.Font.Gotham
        title.Parent = frame

        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 30)
        dropdownFrame.Position = UDim2.new(0.05, 0, 0, 0)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        dropdownFrame.Parent = frame

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
        dropdownList.Position = UDim2.new(0.05, 0, 0, 30)
        dropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        dropdownList.Visible = false
        local dropdownListLayout = Instance.new("UIListLayout")
        dropdownListLayout.FillDirection = Enum.FillDirection.Vertical
        dropdownListLayout.Padding = UDim.new(0, 2)
        dropdownListLayout.Parent = dropdownList
        dropdownList.Parent = frame

        local spawnableObjects = detectSpawnableObjects()
        for _, objName in ipairs(spawnableObjects) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 25)
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
        dropdownList.Size = UDim2.new(0.9, 0, 0, #spawnableObjects * 27)

        dropdownBtn.MouseButton1Click:Connect(function()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            dropdownList.Visible = not dropdownList.Visible
            dropdownBtn.Text = dropdownList.Visible and "▲" or "▼"
        end)

        local spawnClientBtn = Instance.new("TextButton")
        spawnClientBtn.Size = UDim2.new(0.9, 0, 0, 30)
        spawnClientBtn.Position = UDim2.new(0.05, 0, 0, 0)
        spawnClientBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        spawnClientBtn.TextColor3 = Color3.new(1, 1, 1)
        spawnClientBtn.Text = "Spawn Client-Side"
        spawnClientBtn.TextScaled = true
        spawnClientBtn.Font = Enum.Font.Gotham
        spawnClientBtn.Parent = frame
        spawnClientBtn.MouseButton1Click:Connect(function()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local selected = dropdownLabel.Text:match("Selected: (.+)") or "BasicPart"
                spawnClientSideObject(selected)
            else
                notify("⚠️ Character not loaded", Color3.fromRGB(255, 100, 100))
            end
        end)

        local spawnServerBtn = Instance.new("TextButton")
        spawnServerBtn.Size = UDim2.new(0.9, 0, 0, 30)
        spawnServerBtn.Position = UDim2.new(0.05, 0, 0, 0)
        spawnServerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        spawnServerBtn.TextColor3 = Color3.new(1, 1, 1)
        spawnServerBtn.Text = "Spawn Server-Side"
        spawnServerBtn.TextScaled = true
        spawnServerBtn.Font = Enum.Font.Gotham
        spawnServerBtn.Parent = frame
        spawnServerBtn.MouseButton1Click:Connect(function()
            if ACTIVE_SCRIPT_ID ~= SCRIPT_ID then return end
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local selected = dropdownLabel.Text:match("Selected: (.+)") or "BasicPart"
                spawnServerSideObject(selected)
            else
                notify("⚠️ Character not loaded", Color3.fromRGB(255, 100, 100))
            end
        end)

        notify("🖼️ GUI Loaded (ID: " .. SCRIPT_ID .. ")", Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ GUI creation failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

-- Inisialisasi dengan retry mechanism
local function initialize()
    local success, errorMsg = pcall(function()
        local maxRetries = 10
        local retryCount = 0
        local function tryCreateGUI()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createGUI()
                notify("🔄 Character loaded, GUI created", Color3.fromRGB(0, 255, 0))
            else
                if retryCount < maxRetries then
                    retryCount = retryCount + 1
                    notify("🔄 Waiting for character (Attempt " .. retryCount .. "/" .. maxRetries .. ")", Color3.fromRGB(255, 255, 0))
                    task.wait(3)
                    tryCreateGUI()
                else
                    notify("⚠️ Failed to load GUI after " .. maxRetries .. " attempts", Color3.fromRGB(255, 100, 100))
                end
            end
        end
        tryCreateGUI()
        player.CharacterAdded:Connect(function()
            task.wait(2)
            createGUI()
            notify("🔄 Character respawned, GUI recreated", Color3.fromRGB(0, 255, 0))
        end)
    end)
    if not success then
        notify("⚠️ Initialization failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end

initialize()