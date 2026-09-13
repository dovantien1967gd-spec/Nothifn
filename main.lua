local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_Enabled = false
local Orbit_Enabled = false
local ClosestPlayer_Enabled = false
local Invisible_Enabled = false
local AimbotCam_Enabled = false
local AimbotChar_Enabled = false

local SelectedPlayer = nil

-- Giá trị tùy chỉnh
local OrbitSpeed = 5
local TeleportDistance = 3
local InvisoDepth = 15

local ESP_Objects = {}

-- Cửa sổ giao diện Rayfield
local Window = Rayfield:CreateWindow({
    Name = "The 's Hub | Jujutsu Shenanigans",
    LoadingTitle = "The 's Loading...",
    LoadingSubtitle = "by Yueshi mogger 9999 aura 🔥",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local AimTab = Window:CreateTab("Aimbot & Visual", 4483362458)

-- Hàm dọn dẹp ESP
local function ClearESP(plr)
    if ESP_Objects[plr] then
        if ESP_Objects[plr].Tracer then ESP_Objects[plr].Tracer:Remove() end
        if ESP_Objects[plr].Box then ESP_Objects[plr].Box:Remove() end
        if ESP_Objects[plr].Name then ESP_Objects[plr].Name:Remove() end
        ESP_Objects[plr] = nil
    end
end

-- Update ESP
RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if ESP_Enabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.Humanoid.Health > 0 then
                if not ESP_Objects[plr] then
                    ESP_Objects[plr] = {
                        Tracer = Drawing.new("Line"),
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text")
                    }
                    
                    ESP_Objects[plr].Tracer.Color = Color3.fromRGB(255, 0, 0)
                    ESP_Objects[plr].Tracer.Thickness = 1.5
                    
                    ESP_Objects[plr].Box.Color = Color3.fromRGB(255, 0, 0)
                    ESP_Objects[plr].Box.Thickness = 1.5
                    ESP_Objects[plr].Box.Filled = false
                    
                    ESP_Objects[plr].Name.Color = Color3.fromRGB(255, 0, 0)
                    ESP_Objects[plr].Name.Size = 14
                    ESP_Objects[plr].Name.Center = true
                    ESP_Objects[plr].Name.Outline = true
                end

                local hrp = plr.Character.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    ESP_Objects[plr].Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    ESP_Objects[plr].Tracer.To = Vector2.new(vector.X, vector.Y)
                    ESP_Objects[plr].Tracer.Visible = true

                    local head = plr.Character:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                    local height = math.abs(vector.Y - headPos.Y) * 2
                    local width = height / 1.5

                    ESP_Objects[plr].Box.Size = Vector2.new(width, height)
                    ESP_Objects[plr].Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                    ESP_Objects[plr].Box.Visible = true

                    ESP_Objects[plr].Name.Text = plr.DisplayName
                    ESP_Objects[plr].Name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                    ESP_Objects[plr].Name.Visible = true
                else
                    ESP_Objects[plr].Tracer.Visible = false
                    ESP_Objects[plr].Box.Visible = false
                    ESP_Objects[plr].Name.Visible = false
                end
            else
                ClearESP(plr)
            end
        end
    end
end)

-- Helper Functions
local function GetPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    return names
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if myHRP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local dist = (myHRP.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- [MAIN TAB CONTROLS]
MainTab:CreateToggle({
    Name = "Bật ESP (Tracer & Box Red)",
    CurrentValue = false,
    Callback = function(Value)
        ESP_Enabled = Value
        if not Value then
            for plr, _ in pairs(ESP_Objects) do ClearESP(plr) end
        end
    end,
})

local MainPlayerDropdown = MainTab:CreateDropdown({
    Name = "Chọn Player Target (Main)",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(Option)
        if not ClosestPlayer_Enabled and Option[1] then
            SelectedPlayer = Players:FindFirstChild(Option[1])
        end
    end,
})

MainTab:CreateButton({
    Name = "Refresh Danh Sách Player",
    Callback = function()
        MainPlayerDropdown:Refresh(GetPlayerNames())
        Rayfield:Notify({ Title = "Thông báo", Content = "Đã cập nhật danh sách!", Duration = 2 })
    end,
})

MainTab:CreateToggle({
    Name = "Tự động chọn Player gần nhất (Closest Player)",
    CurrentValue = false,
    Callback = function(Value) ClosestPlayer_Enabled = Value end,
})

MainTab:CreateSlider({
    Name = "Độ sâu Tàng Hình",
    Range = {5, 30},
    Increment = 1,
    Suffix = " Studs",
    CurrentValue = 15,
    Callback = function(Value) InvisoDepth = Value end,
})

MainTab:CreateToggle({
    Name = "Tàng hình dưới đất (Underground Invisible)",
    CurrentValue = false,
    Callback = function(Value) Invisible_Enabled = Value end,
})

MainTab:CreateSlider({
    Name = "Khoảng cách TP (Sau lưng)",
    Range = {1, 15},
    Increment = 1,
    Suffix = " Studs",
    CurrentValue = 3,
    Callback = function(Value) TeleportDistance = Value end,
})

MainTab:CreateButton({
    Name = "Teleport Ra Sau Lưng Target",
    Callback = function()
        if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                myHRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, TeleportDistance)
            end
        else
            Rayfield:Notify({ Title = "Lỗi", Content = "Chưa chọn Target hợp lệ!", Duration = 3 })
        end
    end,
})

MainTab:CreateSlider({
    Name = "Tốc độ xoay Orbit",
    Range = {1, 20},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 5,
    Callback = function(Value) OrbitSpeed = Value end,
})

MainTab:CreateToggle({
    Name = "Xoay Vòng Vòng Quanh Target (Spinbot)",
    CurrentValue = false,
    Callback = function(Value) Orbit_Enabled = Value end,
})

-- [AIMBOT TAB CONTROLS]
local AimPlayerDropdown = AimTab:CreateDropdown({
    Name = "Chọn Player Target (Aimbot)",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(Option)
        if not ClosestPlayer_Enabled and Option[1] then
            SelectedPlayer = Players:FindFirstChild(Option[1])
        end
    end,
})

AimTab:CreateButton({
    Name = "Refresh Danh Sách Target",
    Callback = function()
        AimPlayerDropdown:Refresh(GetPlayerNames())
        Rayfield:Notify({ Title = "Thông báo", Content = "Đã cập nhật danh sách!", Duration = 2 })
    end,
})

AimTab:CreateToggle({
    Name = "Aimbot 1: Khóa Camera vào Target",
    CurrentValue = false,
    Callback = function(Value) AimbotCam_Enabled = Value end,
})

AimTab:CreateToggle({
    Name = "Aimbot 2: Nhân vật luôn hướng về Target",
    CurrentValue = false,
    Callback = function(Value) AimbotChar_Enabled = Value end,
})

-- [SYSTEM LOGIC LOOPS]

-- Closest Player Loop
RunService.Heartbeat:Connect(function()
    if ClosestPlayer_Enabled then
        local target = GetClosestPlayer()
        if target then SelectedPlayer = target end
    end
end)

-- Underground Loop
RunService.Heartbeat:Connect(function()
    if Invisible_Enabled and not Orbit_Enabled then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            myHRP.CFrame = myHRP.CFrame * CFrame.new(0, -InvisoDepth / 10, 0)
        end
    end
end)

-- Orbit Loop
local orbitAngle = 0
RunService.Heartbeat:Connect(function(dt)
    if Orbit_Enabled and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            local targetHRP = SelectedPlayer.Character.HumanoidRootPart
            orbitAngle = orbitAngle + (dt * OrbitSpeed)
            
            local radius = 5
            local yOffset = Invisible_Enabled and -InvisoDepth or 0
            local offsetX = math.cos(orbitAngle) * radius
            local offsetZ = math.sin(orbitAngle) * radius
            
            local newPos = targetHRP.Position + Vector3.new(offsetX, yOffset, offsetZ)
            myHRP.CFrame = CFrame.new(newPos, targetHRP.Position)
        end
    end
end)

-- Aimbot 1 & 2 Loop
RunService.RenderStepped:Connect(function()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        
        if AimbotCam_Enabled then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
        end
        
        if AimbotChar_Enabled then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local currentPos = myHRP.Position
                local lookPos = Vector3.new(targetHRP.Position.X, currentPos.Y, targetHRP.Position.Z)
                myHRP.CFrame = CFrame.new(currentPos, lookPos)
            end
        end
    end
end)

-- Auto Update Player List Events
local function RefreshAllDropdowns()
    local names = GetPlayerNames()
    MainPlayerDropdown:Refresh(names)
    AimPlayerDropdown:Refresh(names)
end

Players.PlayerAdded:Connect(RefreshAllDropdowns)
Players.PlayerRemoving:Connect(function(plr) 
    ClearESP(plr)
    RefreshAllDropdowns()
end)
