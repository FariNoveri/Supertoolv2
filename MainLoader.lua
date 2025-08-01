local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

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
    local spawnableObjects = {}
    local success, errorMsg = pcall(function()
        -- Scan ReplicatedStorage untuk model, part, atau item
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("Tool") or obj.Name:lower():match("item") then
                table.insert(spawnableObjects, obj.Name)
            end
        end
        -- Scan Remote Events terkait spawn
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (remote.Name:lower():match("spawn") or remote.Name:lower():match("item")) then
                table.insert(spawnableObjects, "Remote: " .. remote.Name)
            end
        end
        -- Jika tidak ada object ditemukan, tambahkan default
        if #spawnableObjects == 0 then
            table.insert(spawnableObjects, "BasicPart")
        end
    end)
    if not success then
        notify("⚠️ Detection failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
        print("Detection error: " .. tostring(errorMsg))
        return {"BasicPart"}
    end
    return spawnableObjects
end

-- Fungsi untuk spawn object client-side
local function spawnClientSideObject(objectName, position)
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
        print("Client-side spawn: " .. objectName .. " at " .. tostring(part.Position))
    end)
    if not success then
        notify("⚠️ Client-side spawn failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
        print("Client-side spawn error: " .. tostring(errorMsg))
    end
end

-- Fungsi untuk spawn object server-side
local function spawnServerSideObject(objectName, position)
    local success, errorMsg = pcall(function()
        local remote
        if objectName:match("Remote: ") then
            local remoteName = objectName:gsub("Remote: ", "")
            remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        else
            -- Cari Remote Event terkait spawn
            for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                if r:IsA("RemoteEvent") and (r.Name:lower():match("spawn") or r.Name:lower():match("item")) then
                    remote = r
                    break
                end
            end
        end
        if not remote then
            notify("⚠️ No spawn Remote Event found", Color3.fromRGB(255, 100, 100))
            print("No spawn Remote Event found")
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
        print("Server-side spawn attempt: " .. objectName .. " via " .. remote.Name)
    end)
    if not success then
        notify("⚠️ Server-side spawn failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
        print("Server-side spawn error: " .. tostring(errorMsg))
    end
end

-- Fungsi untuk membuat GUI dengan dropdown
local function createGUI()
    local success, errorMsg = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "AutoSpawnGUI"
        gui.ResetOnSpawn = false
        gui.Parent = player.PlayerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 200)
        frame.Position = UDim2.new(0.5, -125, 0.5, -100)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 0.1
        frame.Parent = gui

        local uil = Instance.new("UIListLayout")
        uil.FillDirection = Enum.FillDirection.Vertical
        uil.Padding = UDim.new(0, 5)
        uil.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Text = "Auto Spawn Objects"
        title.TextScaled = true
        title.Font = Enum.Font.Gotham
        title.Parent = frame

        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 40)
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
        dropdownList.Position = UDim2.new(0.05, 0, 0, 40)
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
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            itemBtn.TextColor3 = Color3.new(1, 1, 1)
            itemBtn.Text = objName
            itemBtn.TextScaled = true
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.Parent = dropdownList
            itemBtn.MouseButton1Click:Connect(function()
                dropdownLabel.Text = "Selected: " .. objName
                dropdownList.Visible = false
                dropdownBtn.Text = "▼"
            end)
        end
        dropdownList.Size = UDim2.new(0.9, 0, 0, #spawnableObjects * 32)

        dropdownBtn.MouseButton1Click:Connect(function()
            dropdownList.Visible = not dropdownList.Visible
            dropdownBtn.Text = dropdownList.Visible and "▲" or "▼"
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
            btn.Parent = frame
            btn.MouseButton1Click:Connect(function()
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

        notify("🖼️ Auto Spawn GUI Loaded", Color3.fromRGB(0, 255, 0))
    end)
    if not success then
        notify("⚠️ GUI creation failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
        print("GUI creation error: " .. tostring(errorMsg))
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
        print("Initialization error: " .. tostring(errorMsg))
    end
end

initialize()
