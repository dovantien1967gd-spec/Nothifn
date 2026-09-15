local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables
local SelectedPlayer = nil
local ClosestPlayer_Enabled = false
local TargetHighlight_Enabled = true

-- HvH Variables (Tách riêng Orbit và Spin)
local Orbit_Enabled = false
local OrbitSpeed = 37
local OrbitRadius = 2
local OrbitHeight = 7

local SpinAround_Enabled = false
local SpinSpeed = 50

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

-- Ultra Instinct & Auto Dodge Variables
local UltraInstinct_Enabled = false
local DodgeCooldown = 0

-- Block Counter / Backstab Variables
local AutoBackstab_Enabled = false
local BackstabCooldown = 0

-- Defense Variables
local AntiVoid_Enabled = true
local AntiFling_Enabled = true
local AntiGrab_Enabled = true
local AntiKnockback_Enabled = false
local AntiSlow_Enabled = false

-- PvP & Cook Variables
local AimbotCam_Enabled = false
local AntiStun = false
local AutoBlink_Enabled = false
local TriggerBot_Enabled = false
local HitboxExtender_Enabled = false
local ChatSpam_Enabled = false
local ChatSpamTimer = 0

-- ESP Variables
local ESP_Enabled = false
local ESP_Boxes = false
local ESP_Tracers = false
local ESP_Names = false
local ESP_Health = false
local ESP_Distance = false
local ESP_Color = Color3.fromRGB(255, 0, 0)
local ESP_Objects = {}

-- Target ESP Circle Variables
local TargetCircle_Enabled = false
local TargetCircle_Color = Color3.fromRGB(255, 0, 0)
local TargetCircle_Radius = 3

-- Target Circle Instance
local CirclePart = Instance.new("Part")
CirclePart.Name = "ThesHubTargetCircle"
CirclePart.Shape = Enum.PartType.Cylinder
CirclePart.Material = Enum.Material.Neon
CirclePart.Transparency = 0.4
CirclePart.CanCollide = false
CirclePart.Anchored = true
CirclePart.Size = Vector3.new(0.2, TargetCircle_Radius * 2, TargetCircle_Radius * 2)

-- Misc & Environment Variables
local WalkSpeed_Value = 16
local JumpPower_Value = 50
local Noclip_Enabled = false
local InfJump_Enabled = false
local CustomFOV_Enabled = false
local FOV_Value = 70
local Fullbright_Enabled = false
local NoFog_Enabled = false
local BlackWorld_Enabled = false

-- Target Highlight Instance
local TargetHighlightObj = Instance.new("Highlight")
TargetHighlightObj.Name = "ThesHubTargetHighlight"
TargetHighlightObj.FillColor = Color3.fromRGB(255, 0, 0)
TargetHighlightObj.FillTransparency = 0.5
TargetHighlightObj.OutlineColor = Color3.fromRGB(255, 255, 255)

-- Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "the's hub | Ultimate Combat Edition",
    LoadingTitle = "Initializing Combat Engine...",
    LoadingSubtitle = "by that one larp guy",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- TẠO 7 TAB
local TargetTab = Window:CreateTab("Targeting", 4483362458)
local HvHTab = Window:CreateTab("HvH & Flight", 4483362458)
local DefenseTab = Window:CreateTab("Defense", 4483362458)
local PvPTab = Window:CreateTab("PvP & Combat", 4483362458)
local CookTab = Window:CreateTab("☢️ Server Cooker", 4483362458)
local ESPTab = Window:CreateTab("Visual & ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc & Server", 4483362458)

local function GetPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
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

local function ClearESP(plr)
    if ESP_Objects[plr] then
        for _, obj in pairs(ESP_Objects[plr]) do
            pcall(function() obj:Remove() end)
        end
        ESP_Objects[plr] = nil
    end
end

-- ==================== [TAB 1: TARGETING] ====================
local TargetDropdown = TargetTab:CreateDropdown({
    Name = "1. Select Target Player",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(Option)
        if not ClosestPlayer_Enabled and Option[1] then SelectedPlayer = Players:FindFirstChild(Option[1]) end
    end,
})

TargetTab:CreateToggle({ Name = "2. Auto Select Closest Player", CurrentValue = false, Callback = function(V) ClosestPlayer_Enabled = V end })
TargetTab:CreateButton({ Name = "3. Refresh Player List", Callback = function() TargetDropdown:Refresh(GetPlayerNames()) end })
TargetTab:CreateToggle({ Name = "4. Highlight Selected Target", CurrentValue = true, Callback = function(V) TargetHighlight_Enabled = V end })
TargetTab:CreateColorPicker({ Name = "5. Highlight Fill Color", Color = Color3.fromRGB(255, 0, 0), Callback = function(V) TargetHighlightObj.FillColor = V end })
TargetTab:CreateSlider({ Name = "6. Highlight Transparency", Range = {0, 1}, Increment = 0.1, CurrentValue = 0.5, Callback = function(V) TargetHighlightObj.FillTransparency = V end })
TargetTab:CreateToggle({ Name = "7. Show Target Ground Circle", CurrentValue = false, Callback = function(V) TargetCircle_Enabled = V end })
TargetTab:CreateColorPicker({ Name = "8. Target Circle Color", Color = Color3.fromRGB(255, 0, 0), Callback = function(V) TargetCircle_Color = V CirclePart.Color = V end })
TargetTab:CreateSlider({ Name = "9. Target Circle Radius", Range = {1, 10}, Increment = 0.5, CurrentValue = 3, Callback = function(V) TargetCircle_Radius = V CirclePart.Size = Vector3.new(0.2, V*2, V*2) end })
TargetTab:CreateButton({ Name = "10. Clear Current Target", Callback = function() SelectedPlayer = nil TargetHighlightObj.Parent = nil end })

-- ==================== [TAB 2: HVH & FLIGHT] ====================
HvHTab:CreateToggle({ Name = "1. Enable Orbit System (Bám Quanh Target) 🌀", CurrentValue = false, Callback = function(V) Orbit_Enabled = V end })
HvHTab:CreateSlider({ Name = "2. Orbit Speed", Range = {1, 150}, Increment = 1, CurrentValue = 37, Callback = function(V) OrbitSpeed = V end })
HvHTab:CreateSlider({ Name = "3. Orbit Radius Distance", Range = {1, 30}, Increment = 1, CurrentValue = 2, Callback = function(V) OrbitRadius = V end })
HvHTab:CreateSlider({ Name = "4. Orbit Height Offset", Range = {-10, 50}, Increment = 1, CurrentValue = 7, Callback = function(V) OrbitHeight = V end })

HvHTab:CreateToggle({ Name = "5. Enable Spin-Around Target (Xoay Tại Chỗ) 🔄", CurrentValue = false, Callback = function(V) SpinAround_Enabled = V end })
HvHTab:CreateSlider({ Name = "6. Spin Rotation Speed", Range = {1, 300}, Increment = 5, CurrentValue = 50, Callback = function(V) SpinSpeed = V end })

HvHTab:CreateToggle({ Name = "7. Target Movement Prediction", CurrentValue = true, Callback = function(V) PredictMovement_Enabled = V end })
HvHTab:CreateSlider({ Name = "8. Prediction Intensity", Range = {0.01, 0.5}, Increment = 0.005, CurrentValue = 0.165, Callback = function(V) PredictionFactor = V end })
HvHTab:CreateToggle({ Name = "9. Smart Sky Travel (Sync w/ HvH) ✈️", CurrentValue = true, Callback = function(V) SmartTravel_Enabled = V end })
HvHTab:CreateSlider({ Name = "10. Travel Peak Height", Range = {50, 500}, Increment = 10, CurrentValue = 150, Callback = function(V) SkyHeight = V end })
HvHTab:CreateSlider({ Name = "11. Travel Speed", Range = {20, 500}, Increment = 10, CurrentValue = 120, Callback = function(V) SmartTravel_FlySpeed = V end })
HvHTab:CreateSlider({ Name = "12. Smart Travel Trigger Distance", Range = {20, 300}, Increment = 10, CurrentValue = 100, Callback = function(V) SmartTravel_Dist = V end })
HvHTab:CreateToggle({ Name = "13. Underground Desync Mode", CurrentValue = false, Callback = function(V) Underground_Enabled = V end })
HvHTab:CreateSlider({ Name = "14. Underground Depth", Range = {5, 50}, Increment = 1, CurrentValue = 15, Callback = function(V) Underground_Depth = V end })

-- ==================== [TAB 3: DEFENSE] ====================
DefenseTab:CreateToggle({ Name = "1. Anti-Void Fall Protection", CurrentValue = true, Callback = function(V) AntiVoid_Enabled = V end })
DefenseTab:CreateToggle({ Name = "2. Anti-Fling Physics Shield", CurrentValue = true, Callback = function(V) AntiFling_Enabled = V end })
DefenseTab:CreateToggle({ Name = "3. Anti-Grab / Carry Evade", CurrentValue = true, Callback = function(V) AntiGrab_Enabled = V end })
DefenseTab:CreateToggle({ Name = "4. Anti-Knockback Velocity Reset", CurrentValue = false, Callback = function(V) AntiKnockback_Enabled = V end })
DefenseTab:CreateToggle({ Name = "5. Anti-Slow Speed Lock", CurrentValue = false, Callback = function(V) AntiSlow_Enabled = V end })
DefenseTab:CreateToggle({ Name = "6. Emergency Low HP Sky Safe", CurrentValue = false, Callback = function(V) EmergencySky_Enabled = V end })
DefenseTab:CreateSlider({ Name = "7. Low HP Threshold (%)", Range = {5, 50}, Increment = 5, CurrentValue = 25, Callback = function(V) EmergencyHP_Threshold = V end })
DefenseTab:CreateSlider({ Name = "8. Emergency Safe Sky Height", Range = {100, 1000}, Increment = 50, CurrentValue = 300, Callback = function(V) EmergencySky_Height = V end })
DefenseTab:CreateButton({ Name = "9. Manual Panic Escape (Teleport Up)", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then myHRP.CFrame = myHRP.CFrame + Vector3.new(0, 300, 0) end
end })
DefenseTab:CreateButton({ Name = "10. Reset Velocity Immediately", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then myHRP.AssemblyLinearVelocity = Vector3.zero myHRP.AssemblyAngularVelocity = Vector3.zero end
end })

-- ==================== [TAB 4: PVP & COMBAT] ====================
PvPTab:CreateToggle({ Name = "1. Camera Lock Aimbot", CurrentValue = false, Callback = function(V) AimbotCam_Enabled = V end })
PvPTab:CreateToggle({ Name = "2. Anti-Stun Humanoid State", CurrentValue = false, Callback = function(V) AntiStun = V end })
PvPTab:CreateToggle({ Name = "3. Auto Backstab On Enemy Block ⚡", CurrentValue = false, Callback = function(V) AutoBackstab_Enabled = V end })
PvPTab:CreateToggle({ Name = "12. Auto Ultra Instinct Dodge & Counter 🌀", CurrentValue = false, Callback = function(V) UltraInstinct_Enabled = V end })
PvPTab:CreateButton({ Name = "4. Instant Teleport Behind Target", Callback = function() 
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        if myHRP then myHRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end 
    end 
end })
PvPTab:CreateButton({ Name = "5. Instant Teleport Above Target", Callback = function() 
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        if myHRP then myHRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) end 
    end 
end })
PvPTab:CreateToggle({ Name = "6. Auto Blink Behind Target On Low HP", CurrentValue = false, Callback = function(V) AutoBlink_Enabled = V end })
PvPTab:CreateToggle({ Name = "7. Auto Clicker / TriggerBot Test", CurrentValue = false, Callback = function(V) TriggerBot_Enabled = V end })
PvPTab:CreateButton({ Name = "8. Face Target Direction", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(SelectedPlayer.Character.HumanoidRootPart.Position.X, myHRP.Position.Y, SelectedPlayer.Character.HumanoidRootPart.Position.Z))
    end
end })
PvPTab:CreateButton({ Name = "9. Break Target Lock", Callback = function() SelectedPlayer = nil end })
PvPTab:CreateButton({ Name = "10. Force Un-anchor Character", Callback = function()
    if LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = false end
        end
    end
end })
PvPTab:CreateButton({ Name = "11. Clear Character Velocity", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then myHRP.AssemblyLinearVelocity = Vector3.zero end
end })

-- ==================== [TAB 5: ☢️ SERVER COOKER] ====================
CookTab:CreateToggle({ Name = "1. Auto Flex Chat Spam", CurrentValue = false, Callback = function(V) ChatSpam_Enabled = V end })
CookTab:CreateToggle({ Name = "2. Hitbox Extender (Mass Reach Test)", CurrentValue = false, Callback = function(V) 
    HitboxExtender_Enabled = V 
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if V then
                hrp.Size = Vector3.new(10, 10, 10)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 0
            end
        end
    end
end })
CookTab:CreateButton({ Name = "3. Teleport All Players To Me (Test)", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    plr.Character.HumanoidRootPart.CFrame = myHRP.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                end)
            end
        end
    end
end })
CookTab:CreateButton({ Name = "4. Void Send All Players (If Unanchored)", Callback = function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
            end)
        end
    end
end })
CookTab:CreateButton({ Name = "5. Kill All Enemies (If Tool/Remote Valid)", Callback = function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function()
                plr.Character.Humanoid.Health = 0
            end)
        end
    end
end })
CookTab:CreateButton({ Name = "6. Sky Bombardment (Teleport All Up)", Callback = function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 300, 0)
            end)
        end
    end
end })
CookTab:CreateButton({ Name = "7. Spinbot All Server View (Visual Disorient)", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        for i = 1, 50 do
            myHRP.CFrame = myHRP.CFrame * CFrame.Angles(0, math.rad(45), 0)
            task.wait(0.01)
        end
    end
end })
CookTab:CreateButton({ Name = "8. Anti-Fling Chaos Wave (Fling Everyone)", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        local oldPos = myHRP.CFrame
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                myHRP.CFrame = plr.Character.HumanoidRootPart.CFrame
                myHRP.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                task.wait(0.05)
            end
        end
        myHRP.CFrame = oldPos
    end
end })
CookTab:CreateButton({ Name = "9. Clean Workspace Debris (Reduce Lag)", Callback = function()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Part") and not obj.Anchored and obj.Name ~= "HumanoidRootPart" then
            pcall(function() obj:Destroy() end)
        end
    end
end })
CookTab:CreateButton({ Name = "10. Force Server-Hop", Callback = function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })

-- ==================== [TAB 6: VISUAL & ESP] ====================
ESPTab:CreateToggle({ Name = "1. Master ESP Toggle", CurrentValue = false, Callback = function(V) 
    ESP_Enabled = V 
    if not V then for plr, _ in pairs(ESP_Objects) do ClearESP(plr) end end 
end })
ESPTab:CreateToggle({ Name = "2. Show ESP Boxes", CurrentValue = false, Callback = function(V) ESP_Boxes = V end })
ESPTab:CreateToggle({ Name = "3. Show ESP Tracers", CurrentValue = false, Callback = function(V) ESP_Tracers = V end })
ESPTab:CreateToggle({ Name = "4. Show ESP Names", CurrentValue = false, Callback = function(V) ESP_Names = V end })
ESPTab:CreateToggle({ Name = "5. Show ESP Health Bar", CurrentValue = false, Callback = function(V) ESP_Health = V end })
ESPTab:CreateToggle({ Name = "6. Show ESP Distance", CurrentValue = false, Callback = function(V) ESP_Distance = V end })
ESPTab:CreateColorPicker({ Name = "7. ESP Color Scheme", Color = Color3.fromRGB(255, 0, 0), Callback = function(V) ESP_Color = V end })
ESPTab:CreateToggle({ Name = "8. Custom Camera FOV", CurrentValue = false, Callback = function(V) CustomFOV_Enabled = V end })
ESPTab:CreateSlider({ Name = "9. FOV Value", Range = {60, 120}, Increment = 1, CurrentValue = 70, Callback = function(V) FOV_Value = V end })
ESPTab:CreateToggle({ Name = "10. Fullbright (Map Ambient)", CurrentValue = false, Callback = function(V) Fullbright_Enabled = V end })
ESPTab:CreateToggle({ Name = "11. Remove Atmosphere Fog", CurrentValue = false, Callback = function(V) NoFog_Enabled = V end })

-- ==================== [TAB 7: MISC & SERVER] ====================
MiscTab:CreateSlider({ Name = "1. WalkSpeed Adjustment", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) WalkSpeed_Value = V end })
MiscTab:CreateSlider({ Name = "2. JumpPower Adjustment", Range = {50, 300}, Increment = 5, CurrentValue = 50, Callback = function(V) JumpPower_Value = V end })
MiscTab:CreateToggle({ Name = "3. Noclip Walls Mode", CurrentValue = false, Callback = function(V) Noclip_Enabled = V end })
MiscTab:CreateToggle({ Name = "4. Infinite Jump Air-Step", CurrentValue = false, Callback = function(V) InfJump_Enabled = V end })
MiscTab:CreateToggle({ Name = "5. Black World / Sky Modifier", CurrentValue = false, Callback = function(V) 
    BlackWorld_Enabled = V 
    if V then Lighting.TimeOfDay = "00:00:00" else Lighting.TimeOfDay = "14:00:00" end
end })
MiscTab:CreateButton({ Name = "6. Rejoin Current Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
MiscTab:CreateButton({ Name = "7. Server Hop (Search New Server)", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
MiscTab:CreateButton({ Name = "8. Reset Local Character", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end })
MiscTab:CreateButton({ Name = "9. Destroy GUI Engine", Callback = function() Rayfield:Destroy() end })
MiscTab:CreateButton({ Name = "10. Copy Server Job ID", Callback = function() setclipboard(tostring(game.JobId)) end })
MiscTab:CreateButton({ Name = "11. Copy Player Place ID", Callback = function() setclipboard(tostring(game.PlaceId)) end })

-- ==================== [CORE ENGINE LOOPS] ====================

LocalPlayer.CharacterAdded:Connect(function(newChar)
    repeat task.wait(0.1) until newChar and newChar:FindFirstChild("HumanoidRootPart") and newChar:FindFirstChildOfClass("Humanoid")
    TravelState = "NONE"
end)

RunService.Stepped:Connect(function()
    if Noclip_Enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if ClosestPlayer_Enabled then
        local target = GetClosestPlayer()
        if target then SelectedPlayer = target end
    end

    -- Chat Spam Loop
    if ChatSpam_Enabled then
        ChatSpamTimer = ChatSpamTimer + dt
        if ChatSpamTimer >= 3 then
            ChatSpamTimer = 0
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channel = TextChatService.TextChannels.RBXGeneral
                    channel:SendAsync("the's hub | combat engine by that one larp guy 🔥")
                else
                    game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents", true):FindFirstChild("SayMessageRequest"):FireServer("the's hub | combat engine by that one larp guy 🔥", "All")
                end
            end)
        end
    end

    if SelectedPlayer then
        local isDead = false
        if not SelectedPlayer.Character or not SelectedPlayer.Character:FindFirstChildOfClass("Humanoid") then
            isDead = true
        else
            local hum = SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health <= 0 then isDead = true end
        end

        if isDead then
            local newTarget = GetClosestPlayer()
            if newTarget then SelectedPlayer = newTarget else SelectedPlayer = nil end
        end
    end

    if TargetHighlight_Enabled and SelectedPlayer and SelectedPlayer.Character then
        TargetHighlightObj.Parent = SelectedPlayer.Character
    else
        TargetHighlightObj.Parent = nil
    end

    if TargetCircle_Enabled and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        CirclePart.Parent = workspace
        CirclePart.Color = TargetCircle_Color
        CirclePart.CFrame = CFrame.new(targetHRP.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
    else
        CirclePart.Parent = nil
    end

    if CustomFOV_Enabled then Camera.FieldOfView = FOV_Value end
    if Fullbright_Enabled then Lighting.Brightness = 2 Lighting.GlobalShadows = false end
    if NoFog_Enabled then Lighting.FogEnd = 9e9 end

    if AimbotCam_Enabled and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, SelectedPlayer.Character.HumanoidRootPart.Position)
    end

    if AntiGrab_Enabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and (hum:GetState() == Enum.HumanoidStateType.PlatformStanding or hum:GetState() == Enum.HumanoidStateType.Seated) then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    -- ESP Rendering
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if ESP_Enabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.Humanoid.Health > 0 then
                if not ESP_Objects[plr] then
                    pcall(function()
                        ESP_Objects[plr] = {
                            Tracer = Drawing.new("Line"),
                            Box = Drawing.new("Square"),
                            Name = Drawing.new("Text")
                        }
                    end)
                end

                local hrp = plr.Character.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen and ESP_Objects[plr] then
                    if ESP_Tracers and ESP_Objects[plr].Tracer then
                        ESP_Objects[plr].Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        ESP_Objects[plr].Tracer.To = Vector2.new(vector.X, vector.Y)
                        ESP_Objects[plr].Tracer.Color = ESP_Color
                        ESP_Objects[plr].Tracer.Visible = true
                    elseif ESP_Objects[plr].Tracer then
                        ESP_Objects[plr].Tracer.Visible = false
                    end

                    if ESP_Boxes and ESP_Objects[plr].Box then
                        local head = plr.Character:FindFirstChild("Head")
                        local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                        local height = math.abs(vector.Y - headPos.Y) * 2
                        local width = height / 1.5
                        ESP_Objects[plr].Box.Size = Vector2.new(width, height)
                        ESP_Objects[plr].Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                        ESP_Objects[plr].Box.Color = ESP_Color
                        ESP_Objects[plr].Box.Visible = true
                    elseif ESP_Objects[plr].Box then
                        ESP_Objects[plr].Box.Visible = false
                    end

                    if ESP_Names and ESP_Objects[plr].Name then
                        ESP_Objects[plr].Name.Text = plr.Name
                        ESP_Objects[plr].Name.Position = Vector2.new(vector.X, vector.Y - 20)
                        ESP_Objects[plr].Name.Color = ESP_Color
                        ESP_Objects[plr].Name.Center = true
                        ESP_Objects[plr].Name.Outline = true
                        ESP_Objects[plr].Name.Visible = true
                    elseif ESP_Objects[plr].Name then
                        ESP_Objects[plr].Name.Visible = false
                    end
                elseif ESP_Objects[plr] then
                    if ESP_Objects[plr].Tracer then ESP_Objects[plr].Tracer.Visible = false end
                    if ESP_Objects[plr].Box then ESP_Objects[plr].Box.Visible = false end
                    if ESP_Objects[plr].Name then ESP_Objects[plr].Name.Visible = false end
                end
            else
                ClearESP(plr)
            end
        end
    end
end)

-- Physics Loop
local orbitAngle = 0
local spinAngle = 0
local targetPeakHeight = 0

RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")

    if hum and myHRP then
        if not AntiSlow_Enabled or hum.WalkSpeed < WalkSpeed_Value then
            hum.WalkSpeed = WalkSpeed_Value
        end
        hum.JumpPower = JumpPower_Value

        if EmergencySky_Enabled and hum.Health > 0 and (hum.Health / hum.MaxHealth * 100) <= EmergencyHP_Threshold then
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero
            myHRP.CFrame = CFrame.new(myHRP.Position.X, EmergencySky_Height, myHRP.Position.Z)
            return
        end

        if AntiVoid_Enabled and myHRP.Position.Y < -80 then
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.CFrame = CFrame.new(myHRP.Position.X, 10, myHRP.Position.Z)
        end

        if AntiFling_Enabled then
            if myHRP.AssemblyAngularVelocity.Magnitude > 50 or myHRP.AssemblyLinearVelocity.Magnitude > 200 then
                myHRP.AssemblyAngularVelocity = Vector3.zero
                myHRP.AssemblyLinearVelocity = Vector3.zero
            end
        end

        if AntiKnockback_Enabled then
            myHRP.AssemblyLinearVelocity = Vector3.new(0, myHRP.AssemblyLinearVelocity.Y, 0)
        end
    end

    if AntiStun and hum then hum.PlatformStand = false end

    -- Ultra Instinct / Auto Dodge Engine
    if UltraInstinct_Enabled and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myHRP then
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        local targetHum = SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        local isAttacking = false
        if targetHum and (myHRP.Position - targetHRP.Position).Magnitude < 7 and tick() - DodgeCooldown > 1 then
            pcall(function()
                for _, anim in pairs(targetHum.Animator:GetPlayingAnimationTracks()) do
                    local name = string.lower(anim.Animation.Name)
                    if string.find(name, "punch") or string.find(name, "kick") or string.find(name, "attack") or string.find(name, "skill") or string.find(name, "slash") then
                        isAttacking = true
                        break
                    end
                end
            end)
        end

        if isAttacking then
            DodgeCooldown = tick()
            TravelState = "NONE"
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-4, 4), 15, math.random(-4, 4)) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
            
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    TextChatService.TextChannels.RBXGeneral:SendAsync("Bro thought he could hit the's hub! 💀 Blud got ultra instinct diffed! 🌀")
                else
                    game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents", true):FindFirstChild("SayMessageRequest"):FireServer("Bro thought he could hit the's hub! 💀 Blud got ultra instinct diffed! 🌀", "All")
                end
            end)
            task.wait(0.1)
        end
    end

    -- Shared Smart Sky Travel Function
    local function HandleSmartTravel(predictedTargetPos)
        local distToTarget = (myHRP.Position - predictedTargetPos).Magnitude
        if SmartTravel_Enabled and (distToTarget > SmartTravel_Dist or TravelState ~= "NONE") then
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero

            if TravelState == "NONE" then
                TravelState = "PHASE1_ASCEND"
                targetPeakHeight = myHRP.Position.Y + SkyHeight
            end

            if TravelState == "PHASE1_ASCEND" then
                local ascendPos = Vector3.new(myHRP.Position.X, targetPeakHeight, myHRP.Position.Z)
                local dir = (ascendPos - myHRP.Position).Unit
                myHRP.CFrame = CFrame.new(myHRP.Position + dir * (SmartTravel_FlySpeed * dt), predictedTargetPos)

                if math.abs(myHRP.Position.Y - targetPeakHeight) < 5 then
                    TravelState = "PHASE2_CRUISE"
                end
            elseif TravelState == "PHASE2_CRUISE" then
                local skyAboveTarget = Vector3.new(predictedTargetPos.X, targetPeakHeight, predictedTargetPos.Z)
                local dir = (skyAboveTarget - myHRP.Position).Unit
                myHRP.CFrame = CFrame.new(myHRP.Position + dir * (SmartTravel_FlySpeed * dt), predictedTargetPos)

                local horizontalDist = Vector3.new(myHRP.Position.X - predictedTargetPos.X, 0, myHRP.Position.Z - predictedTargetPos.Z).Magnitude
                if horizontalDist < 8 then
                    TravelState = "PHASE3_DESCENT"
                end
            elseif TravelState == "PHASE3_DESCENT" then
                local landPos = predictedTargetPos + Vector3.new(0, OrbitHeight, 0)
                local dir = (landPos - myHRP.Position).Unit
                myHRP.CFrame = CFrame.new(myHRP.Position + dir * (SmartTravel_FlySpeed * dt), predictedTargetPos)

                if (myHRP.Position - landPos).Magnitude < 4 then
                    TravelState = "NONE"
                end
            end
            return true
        end
        TravelState = "NONE"
        return false
    end

    -- Auto Backstab Check
    local function CheckBackstab(targetHRP, targetHum)
        if AutoBackstab_Enabled and targetHum and tick() - BackstabCooldown > 1.5 then
            local isBlocking = false
            pcall(function()
                for _, anim in pairs(targetHum.Animator:GetPlayingAnimationTracks()) do
                    if string.find(string.lower(anim.Animation.Name), "block") or string.find(string.lower(anim.Animation.Name), "guard") then
                        isBlocking = true
                        break
                    end
                end
            end)
            if isBlocking then
                BackstabCooldown = tick()
                TravelState = "NONE"
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3) * CFrame.Angles(0, math.rad(180), 0)
                task.wait(0.05)
                return true
            end
        end
        return false
    end

    -- Main HvH Execution (Orbit / Spin-Around)
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myHRP then
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        local targetHum = SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")

        local predictedTargetPos = targetHRP.Position
        if PredictMovement_Enabled then
            predictedTargetPos = predictedTargetPos + (targetHRP.AssemblyLinearVelocity * PredictionFactor)
        end

        if CheckBackstab(targetHRP, targetHum) then return end

        if Orbit_Enabled then
            if not HandleSmartTravel(predictedTargetPos) then
                spinAroundActive = false
                orbitAngle = orbitAngle + (dt * (OrbitSpeed / 5))
                local yOffset = Underground_Enabled and -Underground_Depth or OrbitHeight
                local offsetX = math.cos(orbitAngle) * OrbitRadius
                local offsetZ = math.sin(orbitAngle) * OrbitRadius
                
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.CFrame = CFrame.new(predictedTargetPos + Vector3.new(offsetX, yOffset, offsetZ), predictedTargetPos)
            end
        elseif SpinAround_Enabled then
            if not HandleSmartTravel(predictedTargetPos) then
                spinAngle = spinAngle + (dt * (SpinSpeed / 2))
                -- Giữ nguyên vị trí hiện tại hoặc ngay trên target nhưng xoay mặt liên tục tít mù vòng quanh target
                local standoffDist = 4
                local sX = math.cos(spinAngle) * standoffDist
                local sZ = math.sin(spinAngle) * standoffDist
                
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.CFrame = CFrame.new(predictedTargetPos + Vector3.new(sX, 3, sZ), predictedTargetPos)
            end
        else
            TravelState = "NONE"
        end
    else
        TravelState = "NONE"
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfJump_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Players.PlayerAdded:Connect(function() TargetDropdown:Refresh(GetPlayerNames()) end)
Players.PlayerRemoving:Connect(function(plr)
    ClearESP(plr)
    TargetDropdown:Refresh(GetPlayerNames())
end)
