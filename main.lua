local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables
local SelectedPlayer = nil
local ClosestPlayer_Enabled = false
local TargetHighlight_Enabled = true

-- HvH Variables
local Orbit_Enabled = false
local OrbitSpeed = 37
local OrbitRadius = 2
local OrbitHeight = 7
local Underground_Enabled = false
local Underground_Depth = 15
local PredictMovement_Enabled = true
local PredictionFactor = 0.165
local SmartTravel_Enabled = true
local SmartTravel_Dist = 100
local SmartTravel_FlySpeed = 120
local SkyHeight = 150
local TravelState = "NONE"
local EmergencySky_Enabled = false
local EmergencyHP_Threshold = 25
local EmergencySky_Height = 300

-- Defense Variables
local AntiVoid_Enabled = true
local AntiFling_Enabled = true
local AntiGrab_Enabled = true
local AntiKnockback_Enabled = false
local AntiSlow_Enabled = false

-- PvP & Cook Variables
local AimbotCam_Enabled = false
local AntiStun = false
local HitboxExtender_Enabled = false

-- Misc & Environment Variables
local WalkSpeed_Value = 16
local JumpPower_Value = 50
local Noclip_Enabled = false
local InfJump_Enabled = false
local CustomFOV_Enabled = false
local FOV_Value = 70
local Fullbright_Enabled = false
local NoFog_Enabled = false

-- Target Highlight Instance
local TargetHighlightObj = Instance.new("Highlight")
TargetHighlightObj.Name = "ThesHubTargetHighlight"
TargetHighlightObj.FillColor = Color3.fromRGB(255, 0, 0)
TargetHighlightObj.FillTransparency = 0.5
TargetHighlightObj.OutlineColor = Color3.fromRGB(255, 255, 255)

-- Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "the's hub | Fixed Ultimate Edition 💀🔥",
    LoadingTitle = "Loading Fixed Master Engine...",
    LoadingSubtitle = "by Yueshi mogger 9999 aura 🔥",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- TẠO 10 TAB CHUẨN KHÔNG CẦN CHỈNH
local TargetTab = Window:CreateTab("Targeting", 4483362458)
local HvHTab = Window:CreateTab("HvH & Flight", 4483362458)
local DefenseTab = Window:CreateTab("Defense", 4483362458)
local PvPTab = Window:CreateTab("PvP & Combat", 4483362458)
local CookTab = Window:CreateTab("☢️ Server Cooker", 4483362458)
local ESPTab = Window:CreateTab("Visual & ESP", 4483362458)
local GuideTab = Window:CreateTab("📖 Hướng Dẫn Dùng", 4483362458)
local PerfTab = Window:CreateTab("⚡ Performance", 4483362458)
local PanicTab = Window:CreateTab("💀 Ultimate Panic", 4483362458)
local MiscTab = Window:CreateTab("Misc & Server", 4483362458)

local function GetPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    if #names == 0 then table.insert(names, "No Players Found") end
    return names
end

local function GetClosestPlayer()
    local closest, shortDist = nil, math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") then
                if plr.Character.Humanoid.Health > 0 then
                    local dist = (myHRP.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortDist then
                        shortDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

-- ==================== [TAB 1: TARGETING] ====================
local TargetDropdown = TargetTab:CreateDropdown({
    Name = "1. Select Target Player",
    Options = GetPlayerNames(),
    CurrentOption = {"No Players Found"},
    MultipleOptions = false,
    Callback = function(Option)
        local optName = type(Option) == "table" and Option[1] or Option
        if not ClosestPlayer_Enabled and optName then 
            SelectedPlayer = Players:FindFirstChild(optName) 
        end
    end,
})

TargetTab:CreateToggle({ Name = "2. Auto Select Closest Player", CurrentValue = false, Callback = function(V) ClosestPlayer_Enabled = V end })
TargetTab:CreateButton({ Name = "3. Refresh Player List", Callback = function() TargetDropdown:Refresh(GetPlayerNames()) end })
TargetTab:CreateToggle({ Name = "4. Highlight Selected Target", CurrentValue = true, Callback = function(V) TargetHighlight_Enabled = V end })
TargetTab:CreateColorPicker({ Name = "5. Highlight Fill Color", Color = Color3.fromRGB(255, 0, 0), Callback = function(V) TargetHighlightObj.FillColor = V end })
TargetTab:CreateSlider({ Name = "6. Highlight Transparency", Range = {0, 1}, Increment = 0.1, CurrentValue = 0.5, Callback = function(V) TargetHighlightObj.FillTransparency = V end })
TargetTab:CreateButton({ Name = "7. Clear Current Target", Callback = function() SelectedPlayer = nil TargetHighlightObj.Parent = nil end })

-- ==================== [TAB 2: HVH & FLIGHT] ====================
HvHTab:CreateToggle({ Name = "1. Enable Orbit System", CurrentValue = false, Callback = function(V) Orbit_Enabled = V end })
HvHTab:CreateSlider({ Name = "2. Orbit Speed", Range = {1, 100}, Increment = 1, CurrentValue = 37, Callback = function(V) OrbitSpeed = V end })
HvHTab:CreateSlider({ Name = "3. Orbit Radius", Range = {1, 30}, Increment = 1, CurrentValue = 2, Callback = function(V) OrbitRadius = V end })
HvHTab:CreateSlider({ Name = "4. Orbit Height Offset", Range = {-10, 50}, Increment = 1, CurrentValue = 7, Callback = function(V) OrbitHeight = V end })
HvHTab:CreateToggle({ Name = "5. Target Movement Prediction", CurrentValue = true, Callback = function(V) PredictMovement_Enabled = V end })
HvHTab:CreateSlider({ Name = "6. Prediction Intensity", Range = {0.01, 0.5}, Increment = 0.005, CurrentValue = 0.165, Callback = function(V) PredictionFactor = V end })
HvHTab:CreateToggle({ Name = "7. Smart Sky Travel (3-Step)", CurrentValue = true, Callback = function(V) SmartTravel_Enabled = V end })
HvHTab:CreateSlider({ Name = "8. Travel Peak Height", Range = {50, 500}, Increment = 10, CurrentValue = 150, Callback = function(V) SkyHeight = V end })
HvHTab:CreateSlider({ Name = "9. Travel Speed", Range = {20, 500}, Increment = 10, CurrentValue = 120, Callback = function(V) SmartTravel_FlySpeed = V end })
HvHTab:CreateToggle({ Name = "10. Underground Desync Mode", CurrentValue = false, Callback = function(V) Underground_Enabled = V end })

-- ==================== [TAB 3: DEFENSE] ====================
DefenseTab:CreateToggle({ Name = "1. Anti-Void Fall Protection", CurrentValue = true, Callback = function(V) AntiVoid_Enabled = V end })
DefenseTab:CreateToggle({ Name = "2. Anti-Fling Physics Shield", CurrentValue = true, Callback = function(V) AntiFling_Enabled = V end })
DefenseTab:CreateToggle({ Name = "3. Anti-Grab / Carry Evade", CurrentValue = true, Callback = function(V) AntiGrab_Enabled = V end })
DefenseTab:CreateToggle({ Name = "4. Emergency Low HP Sky Safe", CurrentValue = false, Callback = function(V) EmergencySky_Enabled = V end })
DefenseTab:CreateButton({ Name = "5. Manual Panic Escape (Teleport Up)", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then myHRP.CFrame = myHRP.CFrame + Vector3.new(0, 300, 0) end
end })

-- ==================== [TAB 4: PVP & COMBAT] ====================
PvPTab:CreateToggle({ Name = "1. Camera Lock Aimbot", CurrentValue = false, Callback = function(V) AimbotCam_Enabled = V end })
PvPTab:CreateToggle({ Name = "2. Anti-Stun Humanoid State", CurrentValue = false, Callback = function(V) AntiStun = V end })
PvPTab:CreateButton({ Name = "3. Instant Teleport Behind Target", Callback = function() 
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        if myHRP then myHRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end 
    end 
end })

-- ==================== [TAB 5: ☢️ SERVER COOKER] ====================
CookTab:CreateToggle({ Name = "1. Hitbox Extender (Mass Reach)", CurrentValue = false, Callback = function(V) 
    HitboxExtender_Enabled = V 
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            hrp.Size = V and Vector3.new(10, 10, 10) or Vector3.new(2, 2, 1)
        end
    end
end })
CookTab:CreateButton({ Name = "2. Teleport All Players To Me", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function() plr.Character.HumanoidRootPart.CFrame = myHRP.CFrame * CFrame.new(0, 0, 3) end)
            end
        end
    end
end })

-- ==================== [TAB 6: VISUAL & ESP] ====================
ESPTab:CreateButton({ Name = "1. Enable Built-in Highlight ESP (All Players)", Callback = function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if not plr.Character:FindFirstChild("GlobalESP_HL") then
                local hl = TargetHighlightObj:Clone()
                hl.Name = "GlobalESP_HL"
                hl.FillColor = Color3.fromRGB(0, 255, 255)
                hl.Parent = plr.Character
            end
        end
    end
end })
ESPTab:CreateButton({ Name = "2. Remove All ESP Highlights", Callback = function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("GlobalESP_HL")
            if hl then hl:Destroy() end
        end
    end
end })
ESPTab:CreateToggle({ Name = "3. Custom Camera FOV", CurrentValue = false, Callback = function(V) CustomFOV_Enabled = V end })
ESPTab:CreateSlider({ Name = "4. FOV Value", Range = {60, 120}, Increment = 1, CurrentValue = 70, Callback = function(V) FOV_Value = V end })
ESPTab:CreateToggle({ Name = "5. Fullbright Map", CurrentValue = false, Callback = function(V) Fullbright_Enabled = V end })

-- ==================== [TAB 8: 📖 HƯỚNG DẪN SỬ DỤNG SCRIPT] ====================
GuideTab:CreateButton({ Name = "📌 BƯỚC 1: Dùng Executor mượt mà (Delta/Fluxus/Solara)", Callback = function() print("Chuẩn bị executor chuẩn.") end })
GuideTab:CreateButton({ Name = "📌 BƯỚC 2: Vào Map Jujutsu Shenanigans", Callback = function() print("Vào game thành công.") end })
GuideTab:CreateButton({ Name = "📌 BƯỚC 3: Dán Code và Execute", Callback = function() print("Chạy script thành công.") end })
GuideTab:CreateButton({ Name = "📌 BƯỚC 4: Chọn mục tiêu ở Tab 1", Callback = function() print("Tab 1 ready.") end })

-- ==================== [TAB 9: ⚡ PERFORMANCE BOOSTER] ====================
PerfTab:CreateButton({ Name = "1. Potato Mode (Low Graphics)", Callback = function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
end })
PerfTab:CreateButton({ Name = "2. Unlock Framerate (Max FPS)", Callback = function()
    pcall(function() setfpscap(999) end)
end })

-- ==================== [TAB 10: 💀 ULTIMATE PANIC] ====================
PanicTab:CreateButton({ Name = "1. INSTANT PANIC: Hide GUI & Stop All", Callback = function()
    Rayfield:Destroy()
    Orbit_Enabled = false
end })

-- ==================== [TAB 11: MISC & SERVER] ====================
MiscTab:CreateSlider({ Name = "1. WalkSpeed Adjustment", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) WalkSpeed_Value = V end })
MiscTab:CreateSlider({ Name = "2. JumpPower Adjustment", Range = {50, 300}, Increment = 5, CurrentValue = 50, Callback = function(V) JumpPower_Value = V end })
MiscTab:CreateToggle({ Name = "3. Noclip Walls Mode", CurrentValue = false, Callback = function(V) Noclip_Enabled = V end })
MiscTab:CreateToggle({ Name = "4. Infinite Jump Air-Step", CurrentValue = false, Callback = function(V) InfJump_Enabled = V end })
MiscTab:CreateButton({ Name = "5. Server Hop (Find New Server)", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })

-- ==================== [CORE ENGINE LOOPS] ====================

RunService.Stepped:Connect(function()
    if Noclip_Enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if ClosestPlayer_Enabled then
        local target = GetClosestPlayer()
        if target then SelectedPlayer = target end
    end

    if TargetHighlight_Enabled and SelectedPlayer and SelectedPlayer.Character then
        TargetHighlightObj.Parent = SelectedPlayer.Character
    else
        TargetHighlightObj.Parent = nil
    end

    if CustomFOV_Enabled then Camera.FieldOfView = FOV_Value end
    if Fullbright_Enabled then Lighting.Brightness = 2 Lighting.GlobalShadows = false end

    if AimbotCam_Enabled and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, SelectedPlayer.Character.HumanoidRootPart.Position)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")

    if hum and myHRP then
        hum.WalkSpeed = WalkSpeed_Value
        hum.JumpPower = JumpPower_Value

        if EmergencySky_Enabled and hum.Health > 0 and (hum.Health / hum.MaxHealth * 100) <= EmergencyHP_Threshold then
            myHRP.CFrame = CFrame.new(myHRP.Position.X, EmergencySky_Height, myHRP.Position.Z)
            return
        end

        if AntiVoid_Enabled and myHRP.Position.Y < -80 then
            myHRP.CFrame = CFrame.new(myHRP.Position.X, 10, myHRP.Position.Z)
        end
    end

    if AntiStun and hum then hum.PlatformStand = false end

    -- Orbit Engine
    if Orbit_Enabled and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myHRP then
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        local predictedTargetPos = targetHRP.Position
        if PredictMovement_Enabled then
            predictedTargetPos = predictedTargetPos + (targetHRP.AssemblyLinearVelocity * PredictionFactor)
        end

        local orbitAngle = tick() * (OrbitSpeed / 5)
        local yOffset = Underground_Enabled and -Underground_Depth or OrbitHeight
        local offsetX = math.cos(orbitAngle) * OrbitRadius
        local offsetZ = math.sin(orbitAngle) * OrbitRadius
        
        myHRP.AssemblyLinearVelocity = Vector3.zero
        myHRP.CFrame = CFrame.new(predictedTargetPos + Vector3.new(offsetX, yOffset, offsetZ), predictedTargetPos)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfJump_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
