-- ==========================================
-- إعدادات الخدمات
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- الإعدادات الرئيسية (Settings)
-- ==========================================
local Settings = {
    Aimbot = {
        Enabled = false,
        ShowFOV = false,
        FOV_Radius = 120 -- حجم دائرة المنتصف (التقاط الهدف)
    },
    ESP = {
        Enabled = false,
        Box = true,
        HealthBar = true,
        Tracers = true
    },
    Combo = {
        SpeedBoost = false,
        SpeedValue = 32
    }
}

-- ==========================================
-- 1. بناء واجهة المستخدم (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileProHub_V5"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- مهم جداً لدقة الشاشة على الهواتف
ScreenGui.Parent = CoreGui

-- حاوية الـ ESP
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Folder"
ESPFolder.Parent = ScreenGui

-- ==========================================
-- 2. دائرة الـ FOV (ثابتة في المنتصف)
-- ==========================================
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.Aimbot.FOV_Radius * 2, 0, Settings.Aimbot.FOV_Radius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0) -- في منتصف الشاشة تماماً
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVCircle

-- ==========================================
-- 3. واجهة التحكم الرئيسية (القائمة)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "📱 Hub الهاتف الاحترافي 📱"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- دالة لإنشاء أزرار التفعيل بسلاسة
local function CreateToggle(name, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 210, 0, 40)
    btn.Position = UDim2.new(0.5, -105, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
        local targetTextColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        btn.TextColor3 = targetTextColor
        callback(state)
    end)
end

-- إضافة الأزرار (معدلة للهاتف)
CreateToggle("AimbotToggle", "تفعيل Aimbot (تلقائي للهاتف)", 50, function(state)
    Settings.Aimbot.Enabled = state
end)

CreateToggle("FOVToggle", "إظهار دائرة FOV بالمنتصف", 100, function(state)
    Settings.Aimbot.ShowFOV = state
    FOVCircle.Visible = state
end)

CreateToggle("ESPToggle", "تفعيل ESP المتكامل", 150, function(state)
    Settings.ESP.Enabled = state
    if not state then ESPFolder:ClearAllChildren() end
end)

CreateToggle("SpeedToggle", "تفعيل السرعة (2x)", 200, function(state)
    Settings.Combo.SpeedBoost = state
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = state and Settings.Combo.SpeedValue or 16
    end
end)

-- زر الانتقال الآني
local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(0, 210, 0, 40)
TpBtn.Position = UDim2.new(0.5, -105, 0, 250)
TpBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
TpBtn.Text = "🎯 انتقال خلف أقرب لاعب"
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Font = Enum.Font.GothamBold
TpBtn.TextSize = 14
TpBtn.Parent = MainFrame

local TpCorner = Instance.new("UICorner")
TpCorner.CornerRadius = UDim.new(0, 6)
TpCorner.Parent = TpBtn

-- جعل القائمة قابلة للسحب بإصبع اليد (Touch Support)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        -- تم إضافة دعم اللمس (Touch) للهواتف
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            else
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end
MakeDraggable(MainFrame)

-- ==========================================
-- 4. دوال الايم بوت التلقائي (للهاتف)
-- ==========================================
-- دالة جلب أقرب لاعب داخل دائرة الـ FOV
local function GetClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDist = Settings.Aimbot.FOV_Radius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist <= shortestDist then
                        shortestDist = dist
                        closestPlayer = p
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- تثبيت خارق وتلقائي بالكامل (Auto-Lock)
RunService:BindToRenderStep("SuperMobileAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    -- سيعمل فوراً إذا كان مفعلاً ووجد لاعباً داخل الدائرة بدون أي أزرار إضافية
    if Settings.Aimbot.Enabled then
        local target = GetClosestPlayerToCenter()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- ==========================================
-- 5. الـ ESP فائق الدقة
-- ==========================================
local ESP_Objects = {}

RunService.RenderStepped:Connect(function()
    if not Settings.ESP.Enabled then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not ESP_Objects[p] then
                ESP_Objects[p] = {
                    Box = Instance.new("Frame"),
                    HealthBG = Instance.new("Frame"),
                    HealthBar = Instance.new("Frame"),
                    Tracer = Instance.new("Frame")
                }
                
                ESP_Objects[p].Box.BackgroundTransparency = 1
                ESP_Objects[p].Box.BorderColor3 = Color3.fromRGB(255, 50, 50)
                ESP_Objects[p].Box.BorderSizePixel = 2
                ESP_Objects[p].Box.Parent = ESPFolder

                ESP_Objects[p].HealthBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                ESP_Objects[p].HealthBG.BorderSizePixel = 0
                ESP_Objects[p].HealthBG.Parent = ESPFolder

                ESP_Objects[p].HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                ESP_Objects[p].HealthBar.BorderSizePixel = 0
                ESP_Objects[p].HealthBar.Parent = ESP_Objects[p].HealthBG
                
                ESP_Objects[p].Tracer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ESP_Objects[p].Tracer.BorderSizePixel = 0
                ESP_Objects[p].Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
                ESP_Objects[p].Tracer.Parent = ESPFolder
            end

            local objs = ESP_Objects[p]
            local char = p.Character
            local isValid = false

            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char.Humanoid.Health > 0 then
                local topPos = char.Head.Position + Vector3.new(0, 1, 0)
                local bottomPos = char.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                
                local top2D, onScreen1 = Camera:WorldToViewportPoint(topPos)
                local bottom2D, onScreen2 = Camera:WorldToViewportPoint(bottomPos)

                if onScreen1 or onScreen2 then
                    isValid = true
                    
                    local height = math.abs(bottom2D.Y - top2D.Y)
                    local width = height / 2

                    objs.Box.Size = UDim2.new(0, width, 0, height)
                    objs.Box.Position = UDim2.new(0, top2D.X - width/2, 0, top2D.Y)

                    local hpPct = char.Humanoid.Health / char.Humanoid.MaxHealth
                    objs.HealthBG.Size = UDim2.new(0, 3, 0, height)
                    objs.HealthBG.Position = UDim2.new(0, (top2D.X - width/2) - 6, 0, top2D.Y)
                    objs.HealthBar.Size = UDim2.new(1, 0, hpPct, 0)
                    objs.HealthBar.Position = UDim2.new(0, 0, 1 - hpPct, 0)
                    objs.HealthBar.BackgroundColor3 = Color3.fromRGB(255 - (hpPct*255), hpPct*255, 50)

                    local startPos = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    local endPos = Vector2.new(top2D.X, top2D.Y)
                    local distance = (endPos - startPos).Magnitude

                    objs.Tracer.Size = UDim2.new(0, distance, 0, 1)
                    objs.Tracer.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                    objs.Tracer.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))
                end
            end

            for _, element in pairs(objs) do element.Visible = isValid end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESP_Objects[p] then
        for _, v in pairs(ESP_Objects[p]) do v:Destroy() end
        ESP_Objects[p] = nil
    end
end)

-- ==========================================
-- 6. الانتقال الآني (Teleport)
-- ==========================================
TpBtn.MouseButton1Click:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local d = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist, nearest = d, p end
            end
        end
    end

    if nearest then
        local targetRoot = nearest.Character.HumanoidRootPart
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
    end
end)

-- الحفاظ على السرعة بعد الموت
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if Settings.Combo.SpeedBoost then
        hum.WalkSpeed = Settings.Combo.SpeedValue
    end
end)
