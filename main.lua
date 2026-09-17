local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables
local SelectedPlayer = nil
local ClosestPlayer_Enabled = false
local TargetHighlight_Enabled = true

-- HvH & Flight Variables
local Orbit_Enabled = false
local OrbitSpeed = 37
local OrbitRadius = 2
local OrbitHeight = 7
local OrbitHasHit = false
local LastTargetHealth = 100

local SpinAround_Enabled = false
local SpinSpeed = 50
local SpinHasHit = false

local PredictMovement_Enabled = true
local PredictionFactor = 0.165
local SmartTravel_Enabled = true
local SmartTravel_Dist = 100
local SmartTravel_FlySpeed = 200
local SkyHeight = 150
local TravelState = "NONE"
local targetPeakHeight = 0

-- VIP ESP Variables (Có thêm tùy chỉnh màu)
local ESP_Enabled = false
local ThreatAnalyzer_Enabled = true
local ESP_BoxMode = "2D Box"
local ESP_FilledBox = true
local ESP_Skeleton = true
local ESP_HeadDot = true
local ESP_Tracers = true
local ESP_Names = true
local ESP_Distance = true
local ESP_HealthBar = true
local ESP_MaxDist = 2000
local ESP_Drawings = {}

-- Biến màu sắc ESP (Mặc định Xanh Dương 0, 170, 255)
local ESP_CustomColor = Color3.fromRGB(0, 170, 255)

-- Visual Target Tracer Line
local TargetLine_Enabled = true
local TargetTracerLine = Drawing.new("Line")
TargetTracerLine.Thickness = 2
TargetTracerLine.Color = ESP_CustomColor
TargetTracerLine.Visible = false

-- Target Highlight Instance
local TargetHighlightObj = Instance.new("Highlight")
TargetHighlightObj.Name = "ThesHubTargetHighlight"
TargetHighlightObj.FillColor = ESP_CustomColor
TargetHighlightObj.FillTransparency = 0.5
TargetHighlightObj.OutlineColor = Color3.fromRGB(255, 255, 255)

-- Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "the's hub | Custom ESP Color Edition",
    LoadingTitle = "Loading VIP Protocol...",
    LoadingSubtitle = "by yueshi mogger 9999 aura 💙",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("⚡ Combat & Travel", 4483362458)
local ESPTab   = Window:CreateTab("👁️ VIP ESP (17 Pro)", 4483362458)
local ServerTab = Window:CreateTab("🌐 Server & Misc", 4483362458)

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

-- ==================== [VIP ESP SETUP] ====================
local function CreateESP(plr)
    if ESP_Drawings[plr] then return end
    local success, drawings = pcall(function()
        return {
            Box = Drawing.new("Square"),
            FilledBox = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            Name = Drawing.new("Text"),
            HealthBar = Drawing.new("Line"),
            HealthBarBg = Drawing.new("Line"),
            Distance = Drawing.new("Text"),
            HeadDot = Drawing.new("Circle"),
            Arrow = Drawing.new("Triangle"),
            Bones = {}
        }
    end)
    if not success or not drawings then return end
    
    drawings.Box.Thickness = 1.5
    drawings.Box.Visible = false
    drawings.FilledBox.Thickness = 1
    drawings.FilledBox.Filled = true
    drawings.FilledBox.Transparency = 0.2
    drawings.FilledBox.Visible = false
    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Visible = false
    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Visible = false
    drawings.HealthBar.Thickness = 2.5
    drawings.HealthBar.Visible = false
    drawings.HealthBarBg.Thickness = 2.5
    drawings.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
    drawings.HealthBarBg.Visible = false
    drawings.HeadDot.Radius = 4
    drawings.HeadDot.Filled = true
    drawings.HeadDot.Visible = false
    drawings.Arrow.Filled = true
    drawings.Arrow.Visible = false

    for i = 1, 6 do
        local bone = Drawing.new("Line")
        bone.Thickness = 1.5
        bone.Visible = false
        table.insert(drawings.Bones, bone)
    end
    ESP_Drawings[plr] = drawings
end

local function RemoveESP(plr)
    if ESP_Drawings[plr] then
        for _, obj in pairs(ESP_Drawings[plr]) do
            if type(obj) == "table" then
                for _, bone in pairs(obj) do pcall(function() bone:Remove() end) end
            else
                pcall(function() obj:Remove() end)
            end
        end
        ESP_Drawings[plr] = nil
    end
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then CreateESP(plr) end
end
Players.PlayerAdded:Connect(function(plr) if plr ~= LocalPlayer then CreateESP(plr) end end)
Players.PlayerRemoving:Connect(function(plr) RemoveESP(plr) end)

-- UI COMPONENTS - MAIN TAB
local TargetDropdown = MainTab:CreateDropdown({
    Name = "Select Target Player",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(Option)
        if Option[1] then SelectedPlayer = Players:FindFirstChild(Option[1]) end
    end,
})
MainTab:CreateToggle({ Name = "Auto Select Closest Player", CurrentValue = false, Callback = function(V) ClosestPlayer_Enabled = V end })
MainTab:CreateButton({ Name = "Quick Switch to Nearest Target", Callback = function() SelectedPlayer = GetClosestPlayer() end })
MainTab:CreateButton({ Name = "Refresh Player List", Callback = function() TargetDropdown:Refresh(GetPlayerNames()) end })
MainTab:CreateToggle({ Name = "Highlight Selected Target", CurrentValue = true, Callback = function(V) TargetHighlight_Enabled = V end })
MainTab:CreateToggle({ Name = "Draw Line To Target", CurrentValue = true, Callback = function(V) TargetLine_Enabled = V end })

MainTab:CreateSection("Flight & HvH Systems")
MainTab:CreateToggle({ Name = "Enable Orbit System", CurrentValue = false, Callback = function(V) 
    Orbit_Enabled = V 
    OrbitHasHit = false
    if V then
        if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LastTargetHealth = SelectedPlayer.Character.Humanoid.Health
        end
        Rayfield:Notify({Title = "Orbit System", Content = "Đã kích hoạt Orbit nhắm vào mục tiêu đã chọn!", Duration = 2})
    else
        Rayfield:Notify({Title = "Orbit System", Content = "Đã tắt Orbit.", Duration = 2})
    end
end })
MainTab:CreateSlider({ Name = "Orbit Speed", Range = {1, 150}, Increment = 1, CurrentValue = 37, Callback = function(V) OrbitSpeed = V end })
MainTab:CreateSlider({ Name = "Orbit Radius Distance", Range = {1, 30}, Increment = 1, CurrentValue = 2, Callback = function(V) OrbitRadius = V end })

MainTab:CreateToggle({ Name = "Enable Spin-Around Target", CurrentValue = false, Callback = function(V) 
    SpinAround_Enabled = V 
    SpinHasHit = false
    if V then
        if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LastTargetHealth = SelectedPlayer.Character.Humanoid.Health
        end
        Rayfield:Notify({Title = "Spin-Around", Content = "Đã kích hoạt Spin nhắm vào mục tiêu đã chọn!", Duration = 2})
    else
        Rayfield:Notify({Title = "Spin-Around", Content = "Đã tắt Spin.", Duration = 2})
    end
end })

MainTab:CreateToggle({ Name = "Smart Sky Travel (Smooth)", CurrentValue = true, Callback = function(V) SmartTravel_Enabled = V end })
MainTab:CreateSlider({ Name = "Travel Speed (100 - 400)", Range = {100, 400}, Increment = 10, CurrentValue = 200, Callback = function(V) SmartTravel_FlySpeed = V end })
MainTab:CreateSlider({ Name = "Travel Peak Height", Range = {50, 500}, Increment = 10, CurrentValue = 150, Callback = function(V) SkyHeight = V end })

-- UI COMPONENTS - VIP ESP TAB (CÓ COLOR PICKER)
ESPTab:CreateSection("ESP Customization & Theme")
ESPTab:CreateColorPicker({
    Name = "ESP Theme Color (Chỉnh màu ESP)",
    Color = Color3.fromRGB(0, 170, 255),
    Flag = "ESPColorPicker",
    Callback = function(Value)
        ESP_CustomColor = Value
        TargetTracerLine.Color = Value
        TargetHighlightObj.FillColor = Value
        Rayfield:Notify({Title = "ESP Color", Content = "Đã cập nhật màu ESP mới!", Duration = 1.5})
    end
})

ESPTab:CreateSection("ESP Control Center")
ESPTab:CreateToggle({ Name = "Master VIP ESP", CurrentValue = false, Callback = function(V) 
    ESP_Enabled = V 
    if V then
        Rayfield:Notify({Title = "VIP ESP", Content = "✅ Kích hoạt ESP thành công!", Duration = 2})
    else
        Rayfield:Notify({Title = "VIP ESP", Content = "❌ Đã tắt VIP ESP.", Duration = 2})
    end
end })
ESPTab:CreateToggle({ Name = "Threat Analyzer Tags", CurrentValue = true, Callback = function(V) ThreatAnalyzer_Enabled = V end })
ESPTab:CreateToggle({ Name = "Box ESP", CurrentValue = true, Callback = function(V) ESP_BoxMode = V and "2D Box" or "Off" end })
ESPTab:CreateToggle({ Name = "Filled Box Background", CurrentValue = true, Callback = function(V) ESP_FilledBox = V end })
ESPTab:CreateToggle({ Name = "Snapline Tracers", CurrentValue = true, Callback = function(V) ESP_Tracers = V end })
ESPTab:CreateToggle({ Name = "Player Name Tags", CurrentValue = true, Callback = function(V) ESP_Names = V end })
ESPTab:CreateToggle({ Name = "Distance Measurement [m]", CurrentValue = true, Callback = function(V) ESP_Distance = V end })
ESPTab:CreateToggle({ Name = "Dynamic Health Bar (Chuyển màu máu)", CurrentValue = true, Callback = function(V) ESP_HealthBar = V end })
ESPTab:CreateToggle({ Name = "Head Dot Hitbox Pro", CurrentValue = true, Callback = function(V) ESP_HeadDot = V end })
ESPTab:CreateSlider({ Name = "Max Render Distance", Range = {200, 5000}, Increment = 100, CurrentValue = 2000, Callback = function(V) ESP_MaxDist = V end })

-- UI COMPONENTS - SERVER & MISC TAB
ServerTab:CreateSection("Server Control")
ServerTab:CreateButton({ Name = "Server Hop (Random)", Callback = function()
    local success, err = pcall(function()
        local servers = {}
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(req.data) do
            if type(s) == "table" and s.maxPlayers and s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, s.id)
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
    if not success then TeleportService:Teleport(game.PlaceId, LocalPlayer) end
end })

ServerTab:CreateButton({ Name = "Hop Small Server (Săn Server Vắng)", Callback = function()
    pcall(function()
        local cursor = ""
        local lowestServers = {}
        repeat
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor="..cursor or "")
            local req = HttpService:JSONDecode(game:HttpGet(url))
            for _, s in pairs(req.data) do
                if type(s) == "table" and s.playing and s.id ~= game.JobId then
                    table.insert(lowestServers, {id = s.id, playing = s.playing})
                end
            end
            cursor = req.nextPageCursor
        until not cursor or #lowestServers > 50
        
        table.sort(lowestServers, function(a, b) return a.playing < b.playing end)
        if #lowestServers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, lowestServers[1].id, LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end })

ServerTab:CreateButton({ Name = "Rejoin Current Server", Callback = function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end })

ServerTab:CreateSection("GUI Management")
ServerTab:CreateButton({ Name = "🗑️ Unload GUI (Xóa Sổ Giao Diện)", Callback = function()
    pcall(function()
        TargetTracerLine:Remove()
        TargetHighlightObj:Destroy()
        for _, drawings in pairs(ESP_Drawings) do
            for _, obj in pairs(drawings) do
                if type(obj) == "table" then
                    for _, b in pairs(obj) do b:Remove() end
                else
                    obj:Remove()
                end
            end
        end
        Rayfield:Destroy()
    end)
end })

-- RENDER LOOP: ÁP DỤNG MÀU TÙY CHỈNH CHO ESP VÀ TARGET
RunService.RenderStepped:Connect(function(dt)
    pcall(function()
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
            if isDead and ClosestPlayer_Enabled then SelectedPlayer = GetClosestPlayer() end
        end

        if TargetHighlight_Enabled and SelectedPlayer and SelectedPlayer.Character then
            TargetHighlightObj.Parent = SelectedPlayer.Character
        else
            TargetHighlightObj.Parent = nil
        end

        for plr, drawings in pairs(ESP_Drawings) do
            local character = plr.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local dist = (hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 9999
            local show = ESP_Enabled and character and hrp and humanoid and humanoid.Health > 0 and dist <= ESP_MaxDist
            
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
                    
                    if ESP_BoxMode == "2D Box" then
                        drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                        drawings.Box.Position = boxPos
                        drawings.Box.Color = ESP_CustomColor
                        drawings.Box.Visible = true
                        drawings.FilledBox.Size = Vector2.new(boxWidth, boxHeight)
                        drawings.FilledBox.Position = boxPos
                        drawings.FilledBox.Color = ESP_CustomColor
                        drawings.FilledBox.Visible = ESP_FilledBox
                    else
                        drawings.Box.Visible = false
                        drawings.FilledBox.Visible = false
                    end
                    
                    if ESP_Tracers then
                        drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(vector.X, vBottom.Y)
                        drawings.Tracer.Color = ESP_CustomColor
                        drawings.Tracer.Visible = true
                    else
                        drawings.Tracer.Visible = false
                    end
                    
                    if ESP_Names then
                        local threatStr = ThreatAnalyzer_Enabled and " [THREAT]" or ""
                        drawings.Name.Text = plr.Name .. threatStr .. " [" .. math.floor(dist) .. "m]"
                        drawings.Name.Position = Vector2.new(vector.X, boxPos.Y - 18)
                        drawings.Name.Visible = true
                    else
                        drawings.Name.Visible = false
                    end
                    
                    if ESP_HeadDot and head then
                        local headV = Camera:WorldToViewportPoint(head.Position)
                        drawings.HeadDot.Position = Vector2.new(headV.X, headV.Y)
                        drawings.HeadDot.Color = ESP_CustomColor
                        drawings.HeadDot.Visible = true
                    else
                        drawings.HeadDot.Visible = false
                    end
                    
                    if ESP_HealthBar then
                        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = boxHeight * healthPercent
                        drawings.HealthBarBg.From = Vector2.new(boxPos.X - 6, boxPos.Y)
                        drawings.HealthBarBg.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                        drawings.HealthBarBg.Visible = true
                        
                        drawings.HealthBar.From = Vector2.new(boxPos.X - 6, boxPos.Y + (boxHeight - barHeight))
                        drawings.HealthBar.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                        
                        local hpColor
                        if healthPercent > 0.5 then
                            hpColor = Color3.fromRGB(255, 255, 0):Lerp(Color3.fromRGB(0, 255, 0), (healthPercent - 0.5) * 2)
                        else
                            hpColor = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(255, 255, 0), healthPercent * 2)
                        end
                        drawings.HealthBar.Color = hpColor
                        drawings.HealthBar.Visible = true
                    else
                        drawings.HealthBar.Visible = false
                        drawings.HealthBarBg.Visible = false
                    end
                else
                    for _, obj in pairs(drawings) do 
                        if type(obj) == "table" then for _, b in pairs(obj) do b.Visible = false end
                        else obj.Visible = false end 
                    end
                end
            else
                for _, obj in pairs(drawings) do 
                    if type(obj) == "table" then for _, b in pairs(obj) do b.Visible = false end
                    else obj.Visible = false end 
                end
            end
        end
    end)
end)

-- HEARTBEAT: SMART SKY TRAVEL & CHECK GÂY SÁT THƯƠNG
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")

        if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local currentTargetHP = SelectedPlayer.Character.Humanoid.Health
            if currentTargetHP < LastTargetHealth then
                if Orbit_Enabled and not OrbitHasHit then
                    OrbitHasHit = true
                    Rayfield:Notify({Title = "Orbit Success!", Content = "🎯 Đã tiếp cận và gây sát thương thành công mục tiêu!", Duration = 3})
                elseif SpinAround_Enabled and not SpinHasHit then
                    SpinHasHit = true
                    Rayfield:Notify({Title = "Spin Success!", Content = "🎯 Đã quay và gây sát thương thành công mục tiêu!", Duration = 3})
                end
            end
            LastTargetHealth = currentTargetHP
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
                    if dir.Magnitude > 3 then
                        myHRP.CFrame = myHRP.CFrame:Lerp(CFrame.new(myHRP.Position + dir.Unit * math.min(SmartTravel_FlySpeed * dt, dir.Magnitude)), 0.3)
                    else
                        TravelState = "PHASE2_CRUISE"
                    end
                elseif TravelState == "PHASE2_CRUISE" then
                    local skyAboveTarget = Vector3.new(predictedTargetPos.X, targetPeakHeight, predictedTargetPos.Z)
                    local dir = (skyAboveTarget - myHRP.Position)
                    local lookCf = CFrame.new(myHRP.Position, predictedTargetPos)
                    if dir.Magnitude > 5 then
                        myHRP.CFrame = myHRP.CGrade and myHRP.CFrame:Lerp(lookCf + (dir.Unit * math.min(SmartTravel_FlySpeed * dt, dir.Magnitude)), 0.3) or myHRP.CFrame:Lerp(lookCf + (dir.Unit * math.min(SmartTravel_FlySpeed * dt, dir.Magnitude)), 0.3)
                    else
                        TravelState = "PHASE3_DESCENT"
                    end
                elseif TravelState == "PHASE3_DESCENT" then
                    local landPos = predictedTargetPos + Vector3.new(0, OrbitHeight, 0)
                    local dir = (landPos - myHRP.Position)
                    local lookCf = CFrame.new(myHRP.Position, predictedTargetPos)
                    if dir.Magnitude > 3 then
                        myHRP.CFrame = myHRP.CFrame:Lerp(lookCf + (dir.Unit * math.min((SmartTravel_FlySpeed / 2) * dt, dir.Magnitude)), 0.3)
                    else
                        TravelState = "NONE"
                    end
                end
                return true
            end
            TravelState = "NONE"
            return false
        end

        if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myHRP then
            local targetHRP = SelectedPlayer.Character.HumanoidRootPart
            local predictedTargetPos = targetHRP.Position + (PredictMovement_Enabled and (targetHRP.AssemblyLinearVelocity * PredictionFactor) or Vector3.zero)

            if Orbit_Enabled then
                if not HandleSmartTravel(predictedTargetPos) then
                    local orbitAngle = tick() * (OrbitSpeed / 5)
                    myHRP.AssemblyLinearVelocity = Vector3.zero
                    myHRP.CFrame = CFrame.new(predictedTargetPos + Vector3.new(math.cos(orbitAngle) * OrbitRadius, OrbitHeight, math.sin(orbitAngle) * OrbitRadius), predictedTargetPos)
                end
            elseif SpinAround_Enabled then
                if not HandleSmartTravel(predictedTargetPos) then
                    local spinAngle = tick() * (SpinSpeed / 2)
                    myHRP.AssemblyLinearVelocity = Vector3.zero
                    myHRP.CFrame = CFrame.new(predictedTargetPos + Vector3.new(math.cos(spinAngle) * 4, 2, math.sin(spinAngle) * 4), predictedTargetPos)
                end
            else
                TravelState = "NONE"
            end
        else
            TravelState = "NONE"
        end
    end)
end)
