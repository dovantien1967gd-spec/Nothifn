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
local CurrentLanguage = "VI"

-- HvH Variables
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

-- Combat & Revenge Sensor Variables
local LastTargetHealth = nil
local CombatCheckTimer = 0
local HasDealtDamage = false
local HasNotifiedCombatResult = false

local LastMyHealth = 100
local RevengeTarget = nil

-- Defense & Combat
local AntiRagdoll_Enabled = true
local AntiVoid_Enabled = true
local AntiFling_Enabled = true
local AntiGrab_Enabled = true
local AntiSlow_Enabled = false
local ChatSpam_Enabled = false
local HitboxExtender_Enabled = false

-- ESP Fixed Variables & Storage tables
local ESP_Enabled = false
local ESP_Boxes = false
local ESP_Tracers = false
local ESP_Names = false
local ESP_Health = false
local ESP_Distance = false
local ESP_Color = Color3.fromRGB(255, 0, 0)
local ESP_Drawings = {}

-- Visual Target Tracer Line
local TargetLine_Enabled = true
local TargetTracerLine = Drawing.new("Line")
TargetTracerLine.Thickness = 2
TargetTracerLine.Color = Color3.fromRGB(255, 0, 0)
TargetTracerLine.Visible = false

-- Target Highlight Instance
local TargetHighlightObj = Instance.new("Highlight")
TargetHighlightObj.Name = "ThesHubTargetHighlight"
TargetHighlightObj.FillColor = Color3.fromRGB(255, 0, 0)
TargetHighlightObj.FillTransparency = 0.5
TargetHighlightObj.OutlineColor = Color3.fromRGB(255, 255, 255)

-- Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "the's hub | Revenge & Damage Sensor Engine",
    LoadingTitle = "Loading Revenge Protocol...",
    LoadingSubtitle = "by that one larp guy",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- TẠO 7 TAB CƠ BẢN + TAB 11 SETTINGS
local TargetTab = Window:CreateTab("Targeting", 4483362458)
local HvHTab = Window:CreateTab("HvH & Flight", 4483362458)
local DefenseTab = Window:CreateTab("Defense", 4483362458)
local PvPTab = Window:CreateTab("PvP & Combat", 4483362458)
local CookTab = Window:CreateTab("☢️ Server Cooker", 4483362458)
local ESPTab = Window:CreateTab("Visual & ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc & Server", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings (Tab 11)", 4483362458)

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

-- ==================== [HỆ THỐNG ESP FIX TRIỆT ĐỂ] ====================
local function CreateESP(plr)
    if ESP_Drawings[plr] then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarBg = Drawing.new("Line"),
        Distance = Drawing.new("Text")
    }
    
    drawings.Box.Thickness = 1.5
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    
    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Visible = false
    
    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    drawings.Name.Visible = false
    
    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Color = Color3.fromRGB(200, 200, 200)
    drawings.Distance.Visible = false
    
    drawings.HealthBar.Thickness = 2.5
    drawings.HealthBar.Visible = false
    
    drawings.HealthBarBg.Thickness = 2.5
    drawings.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
    drawings.HealthBarBg.Visible = false
    
    ESP_Drawings[plr] = drawings
end

local function RemoveESP(plr)
    if ESP_Drawings[plr] then
        for _, obj in pairs(ESP_Drawings[plr]) do
            pcall(function() obj:Remove() end)
        end
        ESP_Drawings[plr] = nil
    end
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then CreateESP(plr) end
end
Players.PlayerAdded:Connect(function(plr) if plr ~= LocalPlayer then CreateESP(plr) end end)
Players.PlayerRemoving:Connect(function(plr) RemoveESP(plr) end)

-- ==================== [TAB 1: TARGETING] ====================
local TargetDropdown = TargetTab:CreateDropdown({
    Name = "Select Target Player",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(Option)
        if not ClosestPlayer_Enabled and Option[1] then SelectedPlayer = Players:FindFirstChild(Option[1]) end
    end,
})
TargetTab:CreateToggle({ Name = "Auto Select Closest Player", CurrentValue = false, Callback = function(V) ClosestPlayer_Enabled = V end })
TargetTab:CreateButton({ Name = "Quick Switch to Nearest Target (Hot-key)", Callback = function() SelectedPlayer = GetClosestPlayer() end })
TargetTab:CreateButton({ Name = "Refresh Player List", Callback = function() TargetDropdown:Refresh(GetPlayerNames()) end })
TargetTab:CreateToggle({ Name = "Highlight Selected Target", CurrentValue = true, Callback = function(V) TargetHighlight_Enabled = V end })
TargetTab:CreateToggle({ Name = "Draw Line To Target", CurrentValue = true, Callback = function(V) TargetLine_Enabled = V end })
TargetTab:CreateColorPicker({ Name = "Highlight Fill Color", Color = Color3.fromRGB(255, 0, 0), Callback = function(V) TargetHighlightObj.FillColor = V end })
TargetTab:CreateButton({ Name = "Clear Current Target", Callback = function() SelectedPlayer = nil TargetHighlightObj.Parent = nil TargetTracerLine.Visible = false end })

-- ==================== [TAB 2: HVH & FLIGHT (REVENGE ENGINE)] ====================
HvHTab:CreateToggle({ 
    Name = "Enable Orbit System (Revenge Mode)", 
    CurrentValue = false, 
    Callback = function(V) 
        Orbit_Enabled = V 
        HasDealtDamage = false
        HasNotifiedCombatResult = false
        if V then
            Rayfield:Notify({Title = "Orbit Status", Content = "Đã bật Orbit & Chế độ trả thù tự động!", Duration = 3})
        else
            Rayfield:Notify({Title = "Orbit Status", Content = "Đã tắt hệ thống Orbit.", Duration = 2})
        end
    end 
})
HvHTab:CreateSlider({ Name = "Orbit Speed", Range = {1, 150}, Increment = 1, CurrentValue = 37, Callback = function(V) OrbitSpeed = V end })
HvHTab:CreateSlider({ Name = "Orbit Radius Distance", Range = {1, 30}, Increment = 1, CurrentValue = 2, Callback = function(V) OrbitRadius = V end })
HvHTab:CreateSlider({ Name = "Orbit Height Offset", Range = {-10, 50}, Increment = 1, CurrentValue = 7, Callback = function(V) OrbitHeight = V end })

HvHTab:CreateToggle({ 
    Name = "Enable Spin-Around Target (Revenge Mode)", 
    CurrentValue = false, 
    Callback = function(V) 
        SpinAround_Enabled = V 
        HasDealtDamage = false
        HasNotifiedCombatResult = false
        if V then
            Rayfield:Notify({Title = "Spin-Around Status", Content = "Đã bật Spin-Around & Chế độ trả thù tự động!", Duration = 3})
        else
            Rayfield:Notify({Title = "Spin-Around Status", Content = "Đã tắt hệ thống Spin-Around.", Duration = 2})
        end
    end 
})
HvHTab:CreateSlider({ Name = "Spin Rotation Speed", Range = {1, 300}, Increment = 5, CurrentValue = 50, Callback = function(V) SpinSpeed = V end })
HvHTab:CreateToggle({ Name = "Target Movement Prediction", CurrentValue = true, Callback = function(V) PredictMovement_Enabled = V end })
HvHTab:CreateSlider({ Name = "Prediction Intensity", Range = {0.01, 0.5}, Increment = 0.005, CurrentValue = 0.165, Callback = function(V) PredictionFactor = V end })
HvHTab:CreateToggle({ Name = "Smart Sky Travel", CurrentValue = true, Callback = function(V) SmartTravel_Enabled = V end })
HvHTab:CreateSlider({ Name = "Travel Peak Height", Range = {50, 500}, Increment = 10, CurrentValue = 150, Callback = function(V) SkyHeight = V end })
HvHTab:CreateSlider({ Name = "Travel Speed", Range = {20, 500}, Increment = 10, CurrentValue = 120, Callback = function(V) SmartTravel_FlySpeed = V end })

-- ==================== [TAB 3: DEFENSE] ====================
DefenseTab:CreateToggle({ Name = "Anti-Ragdoll / Anti-Sit State Lock", CurrentValue = true, Callback = function(V) AntiRagdoll_Enabled = V end })
DefenseTab:CreateToggle({ Name = "Anti-Void Fall Protection", CurrentValue = true, Callback = function(V) AntiVoid_Enabled = V end })
DefenseTab:CreateToggle({ Name = "Anti-Fling Physics Shield", CurrentValue = true, Callback = function(V) AntiFling_Enabled = V end })
DefenseTab:CreateToggle({ Name = "Anti-Grab / Carry Evade", CurrentValue = true, Callback = function(V) AntiGrab_Enabled = V end })
DefenseTab:CreateToggle({ Name = "Anti-Slow Speed Lock", CurrentValue = false, Callback = function(V) AntiSlow_Enabled = V end })

-- ==================== [TAB 4: PVP & COMBAT] ====================
PvPTab:CreateButton({ Name = "Instant Teleport Behind Target", Callback = function() 
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        if myHRP then 
            myHRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) 
            Rayfield:Notify({Title = "PvP Status", Content = "Teleport ra sau lưng mục tiêu thành công!", Duration = 2})
        end 
    else
        Rayfield:Notify({Title = "PvP Error", Content = "Chưa chọn mục tiêu hợp lệ để teleport!", Duration = 2})
    end 
end })
PvPTab:CreateButton({ Name = "Instant Teleport Above Target", Callback = function() 
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        if myHRP then 
            myHRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) 
            Rayfield:Notify({Title = "PvP Status", Content = "Teleport lên đầu mục tiêu thành công!", Duration = 2})
        end 
    else
        Rayfield:Notify({Title = "PvP Error", Content = "Chưa chọn mục tiêu hợp lệ để teleport!", Duration = 2})
    end 
end })
PvPTab:CreateButton({ Name = "Face Target Direction", Callback = function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(SelectedPlayer.Character.HumanoidRootPart.Position.X, myHRP.Position.Y, SelectedPlayer.Character.HumanoidRootPart.Position.Z))
    end
end })

-- ==================== [TAB 5: SERVER COOKER] ====================
CookTab:CreateToggle({ Name = "Auto Flex Chat Spam", CurrentValue = false, Callback = function(V) ChatSpam_Enabled = V end })
CookTab:CreateToggle({ Name = "Mobile Hitbox Extender", CurrentValue = false, Callback = function(V) 
    HitboxExtender_Enabled = V 
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if V then hrp.Size = Vector3.new(12, 12, 12) hrp.Transparency = 0.7 hrp.CanCollide = false
            else hrp.Size = Vector3.new(2, 2, 1) hrp.Transparency = 0 end
        end
    end
end })
CookTab:CreateButton({ Name = "Force Server-Hop", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })

-- ==================== [TAB 6: VISUAL & ESP] ====================
ESPTab:CreateToggle({ Name = "Master ESP Toggle", CurrentValue = false, Callback = function(V) ESP_Enabled = V end })
ESPTab:CreateToggle({ Name = "Show ESP Boxes", CurrentValue = false, Callback = function(V) ESP_Boxes = V end })
ESPTab:CreateToggle({ Name = "Show ESP Tracers", CurrentValue = false, Callback = function(V) ESP_Tracers = V end })
ESPTab:CreateToggle({ Name = "Show ESP Names", CurrentValue = false, Callback = function(V) ESP_Names = V end })
ESPTab:CreateToggle({ Name = "Show ESP Health Bar", CurrentValue = false, Callback = function(V) ESP_Health = V end })
ESPTab:CreateToggle({ Name = "Show ESP Distance", CurrentValue = false, Callback = function(V) ESP_Distance = V end })
ESPTab:CreateColorPicker({ Name = "ESP Color Selector", Color = Color3.fromRGB(255, 0, 0), Callback = function(V) ESP_Color = V end })

-- ==================== [TAB 7: MISC & SERVER] ====================
MiscTab:CreateToggle({ Name = "Noclip Mode", CurrentValue = false, Callback = function(V) Noclip_Enabled = V end })
MiscTab:CreateButton({ Name = "Rejoin Current Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
MiscTab:CreateButton({ Name = "Reset Local Character", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end })

-- ==================== [TAB 11: SETTINGS (Language Switcher)] ====================
SettingsTab:CreateParagraph({Title = "Language Settings / Cài đặt ngôn ngữ", Content = "Switch interface language between English and Vietnamese instantly."})
SettingsTab:CreateDropdown({
    Name = "Select Language / Chọn Ngôn Ngữ",
    Options = {"Tiếng Việt", "English"},
    CurrentOption = {"Tiếng Việt"},
    MultipleOptions = false,
    Callback = function(Option)
        if Option[1] == "English" then
            CurrentLanguage = "EN"
            Rayfield:Notify({Title = "System", Content = "Language switched to English!", Duration = 3})
        else
            CurrentLanguage = "VI"
            Rayfield:Notify({Title = "Hệ Thống", Content = "Đã chuyển sang Tiếng Việt!", Duration = 3})
        end
    end,
})

-- ==================== [RENDER & ESP LOOP] ====================
RunService.RenderStepped:Connect(function(dt)
    if ClosestPlayer_Enabled then
        local target = GetClosestPlayer()
        if target then SelectedPlayer = target end
    end

    if TargetLine_Enabled and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
        local targetPos, onScreen = Camera:WorldToViewportPoint(SelectedPlayer.Character.HumanoidRootPart.Position)
        if onScreen then
            TargetTracerLine.From = Vector2.new(myPos.X, myPos.Y)
            TargetTracerLine.To = Vector2.new(targetPos.X, targetPos.Y)
            TargetTracerLine.Visible = true
        else
            TargetTracerLine.Visible = false
        end
    else
        TargetTracerLine.Visible = false
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
            -- Nếu mục tiêu trả thù đã chết, xóa ghim trả thù
            if SelectedPlayer == RevengeTarget then
                RevengeTarget = nil
                Rayfield:Notify({Title = "🔥 Revenge Success", Content = "Đã báo thù thành công, mục tiêu đã nằm xuống!", Duration = 3})
            end
            local newTarget = GetClosestPlayer()
            if newTarget then SelectedPlayer = newTarget else SelectedPlayer = nil end
        end
    end

    if TargetHighlight_Enabled and SelectedPlayer and SelectedPlayer.Character then
        TargetHighlightObj.Parent = SelectedPlayer.Character
    else
        TargetHighlightObj.Parent = nil
    end

    -- ESP Rendering Loop
    for plr, drawings in pairs(ESP_Drawings) do
        local character = plr.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        local show = ESP_Enabled and character and hrp and humanoid and humanoid.Health > 0
        
        if show then
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local head = character:FindFirstChild("Head")
                local rootPos = hrp.Position
                local headPos = head and head.Position + Vector3.new(0, 0.5, 0) or rootPos + Vector3.new(0, 3, 0)
                
                local vTop = Camera:WorldToViewportPoint(headPos)
                local vBottom = Camera:WorldToViewportPoint(rootPos - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(vTop.Y - vBottom.Y)
                local boxWidth = boxHeight / 2
                local boxPos = Vector2.new(vector.X - boxWidth / 2, vTop.Y)
                
                if ESP_Boxes then
                    drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                    drawings.Box.Position = boxPos
                    drawings.Box.Color = ESP_Color
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end
                
                if ESP_Tracers then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(vector.X, vBottom.Y)
                    drawings.Tracer.Color = ESP_Color
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
                
                if ESP_Names then
                    drawings.Name.Text = plr.Name
                    drawings.Name.Position = Vector2.new(vector.X, boxPos.Y - 18)
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end
                
                if ESP_Health then
                    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    local barHeight = boxHeight * healthPercent
                    
                    drawings.HealthBarBg.From = Vector2.new(boxPos.X - 6, boxPos.Y)
                    drawings.HealthBarBg.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                    drawings.HealthBarBg.Visible = true
                    
                    drawings.HealthBar.From = Vector2.new(boxPos.X - 6, boxPos.Y + (boxHeight - barHeight))
                    drawings.HealthBar.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                    drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPercent)
                    drawings.HealthBar.Visible = true
                else
                    drawings.HealthBar.Visible = false
                    drawings.HealthBarBg.Visible = false
                end
                
                if ESP_Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    drawings.Distance.Text = "[" .. dist .. "m]"
                    drawings.Distance.Position = Vector2.new(vector.X, boxPos.Y + boxHeight + 2)
                    drawings.Distance.Visible = true
                else
                    drawings.Distance.Visible = false
                end
            else
                for _, obj in pairs(drawings) do obj.Visible = false end
            end
        else
            for _, obj in pairs(drawings) do obj.Visible = false end
        end
    end
end)

-- ==================== [HVH ENGINE WITH REVENGE & DAMAGE SENSOR] ====================
local orbitAngle = 0
local spinAngle = 0
local targetPeakHeight = 0

RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")

    if hum and myHRP then
        if not AntiSlow_Enabled or hum.WalkSpeed < 16 then
            hum.WalkSpeed = 16
        end

        if AntiVoid_Enabled and myHRP.Position.Y < -80 then
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.CFrame = CFrame.new(myHRP.Position.X, 10, myHRP.Position.Z)
        end

        -- Hệ thống kiểm tra máu của bản thân để phát hiện ai vừa đánh trúng mình
        if Orbit_Enabled or SpinAround_Enabled then
            if hum.Health < LastMyHealth then
                local damageTaken = LastMyHealth - hum.Health
                if damageTaken > 1 then
                    -- Quét tìm player ở gần nhất có thể vừa gây sát thương hoặc dùng người chơi đang nhìn vào/gần nhất làm thủ phạm trả thù
                    local culprit = GetClosestPlayer()
                    if culprit and culprit ~= RevengeTarget then
                        RevengeTarget = culprit
                        SelectedPlayer = culprit
                        Rayfield:Notify({Title = "⚡ REVENGE TRIGGERED", Content = "Bị " .. culprit.Name .. " đánh trúng! Ghim chặt mục tiêu trả thù!", Duration = 3})
                    end
                end
            end
            LastMyHealth = hum.Health
        else
            LastMyHealth = hum.Health
            RevengeTarget = nil
        end
    end

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
                local dir = (ascendPos - myHRP.Position)
                if dir.Magnitude > 2 then
                    myHRP.CFrame = myHRP.CFrame + dir.Unit * math.min(SmartTravel_FlySpeed * dt, dir.Magnitude)
                else
                    TravelState = "PHASE2_CRUISE"
                end
            elseif TravelState == "PHASE2_CRUISE" then
                local skyAboveTarget = Vector3.new(predictedTargetPos.X, targetPeakHeight, predictedTargetPos.Z)
                local dir = (skyAboveTarget - myHRP.Position)
                myHRP.CFrame = CFrame.new(myHRP.Position, predictedTargetPos)
                
                if dir.Magnitude > 5 then
                    myHRP.CFrame = myHRP.CFrame + dir.Unit * math.min(SmartTravel_FlySpeed * dt, dir.Magnitude)
                else
                    TravelState = "PHASE3_DESCENT"
                end
            elseif TravelState == "PHASE3_DESCENT" then
                local landPos = predictedTargetPos + Vector3.new(0, OrbitHeight, 0)
                local dir = (landPos - myHRP.Position)
                myHRP.CFrame = CFrame.new(myHRP.Position, predictedTargetPos)
                
                if dir.Magnitude > 4 then
                    myHRP.CFrame = myHRP.CFrame + dir.Unit * math.min(SmartTravel_FlySpeed * dt, dir.Magnitude)
                else
                    TravelState = "NONE"
                end
            end
            return true
        end
        
        TravelState = "NONE"
        return false
    end

    -- Logic check sát thương nhắm vào địch
    if (Orbit_Enabled or SpinAround_Enabled) and SelectedPlayer and SelectedPlayer.Character then
        local targetHum = SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHum then
            if LastTargetHealth == nil then
                LastTargetHealth = targetHum.Health
                CombatCheckTimer = tick()
            else
                if targetHum.Health < LastTargetHealth and not HasDealtDamage then
                    HasDealtDamage = true
                    if not HasNotifiedCombatResult then
                        Rayfield:Notify({Title = "🔥 Combat Success", Content = "Tiếp cận thành công & Đã cấu máu địch!", Duration = 3})
                        HasNotifiedCombatResult = true
                    end
                end

                if not HasDealtDamage and (tick() - CombatCheckTimer > 4) and not HasNotifiedCombatResult then
                    Rayfield:Notify({Title = "❌ Combat Failed", Content = "Áp sát thành công nhưng chưa gây được sát thương!", Duration = 3})
                    HasNotifiedCombatResult = true
                end
            end
        end
    else
        LastTargetHealth = nil
        HasDealtDamage = false
        HasNotifiedCombatResult = false
    end

    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myHRP and hum then
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        local predictedTargetPos = targetHRP.Position
        if PredictMovement_Enabled then
            predictedTargetPos = predictedTargetPos + (targetHRP.AssemblyLinearVelocity * PredictionFactor)
        end

        if Orbit_Enabled then
            if not HandleSmartTravel(predictedTargetPos) then
                orbitAngle = orbitAngle + (dt * (OrbitSpeed / 5))
                local yOffset = Underground_Enabled and -Underground_Depth or OrbitHeight
                local offsetX = math.cos(orbitAngle) * OrbitRadius
                local offsetZ = math.sin(orbitAngle) * OrbitRadius
                local targetOrbitPos = predictedTargetPos + Vector3.new(offsetX, yOffset, offsetZ)
                
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.AssemblyAngularVelocity = Vector3.zero
                myHRP.CFrame = CFrame.new(targetOrbitPos, predictedTargetPos)
            end
        elseif SpinAround_Enabled then
            if not HandleSmartTravel(predictedTargetPos) then
                spinAngle = spinAngle + (dt * (SpinSpeed / 2))
                local standoffDist = 4
                local sX = math.cos(spinAngle) * standoffDist
                local sZ = math.sin(spinAngle) * standoffDist
                local spinPos = predictedTargetPos + Vector3.new(sX, 2, sZ)
                
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.AssemblyAngularVelocity = Vector3.zero
                myHRP.CFrame = CFrame.new(spinPos, predictedTargetPos)
            end
        else
            TravelState = "NONE"
        end
    else
        TravelState = "NONE"
    end

    if AntiRagdoll_Enabled and hum then
        if hum:GetState() == Enum.HumanoidStateType.PlatformStanding or hum:GetState() == Enum.HumanoidStateType.Physics or hum.Sit then
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)
