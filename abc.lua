-- Ultimate Fly & Interact Manager System (Merged Version)

local G2L = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 1. Tự động dọn dẹp tài nguyên cũ để tránh xung đột UI hoặc nặng RAM
local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("UltimateFlySystemGui")
if oldGui then oldGui:Destroy() end
if CoreGui:FindFirstChild("InteractESP_Storage") then CoreGui.InteractESP_Storage:Destroy() end

-- Kho lưu trữ các phân vùng ESP xuyên tường
local ESP_Storage = Instance.new("Folder")
ESP_Storage.Name = "InteractESP_Storage"
ESP_Storage.Parent = CoreGui

-- Các biến trạng thái hệ thống
local flying = false
local speed = 120
local ANIMATION_ID = 96276041445117
local currentTrack = nil
local flyConnection = nil

local espEnabled = true
local selectedPrompt = nil
local selectedButton = nil

-- ====================================================
-- SỬ DỤNG HÀM HỖ TRỢ HOẠT ẢNH & ĐỊNH VỊ
-- ====================================================

local function playFlyAnim(char, state)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    
    if not state then
        if currentTrack then
            currentTrack:Stop()
            currentTrack = nil
        end
        return
    end
    if currentTrack then currentTrack:Stop() end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(ANIMATION_ID)
    
    pcall(function()
        currentTrack = animator:LoadAnimation(anim)
        currentTrack.Looped = true
        currentTrack.Priority = Enum.AnimationPriority.Movement
        currentTrack:Play()
    end)
end

local function getPromptTarget(prompt)
    local parent = prompt.Parent
    if not parent then return nil, nil end
    if parent:IsA("BasePart") then
        return parent.Position, parent
    elseif parent:IsA("Attachment") then
        return parent.WorldPosition, parent
    end
    return nil, nil
end

-- ====================================================
-- THIẾT KẾ KHUNG UI CHÍNH (MAIN SCREEN GUI)
-- ====================================================

G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "UltimateFlySystemGui"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = player:WaitForChild("PlayerGui")

-- Mở rộng kích thước MainFrame lên (Rộng 340, Cao 460) để chứa toàn bộ tính năng gộp
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 340, 0, 460)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EZ FLY & INTERACT MANAGER 🔥"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.BorderSizePixel = 0
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 5)

-- ====================================================
-- PHÂN KHU 1: HỆ THỐNG BAY (FLY CONTROLS)
-- ====================================================

local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 320, 0, 40)
FlyButton.Position = UDim2.new(0.5, -160, 0, 40)
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyButton.Text = "FLY: OFF [V]"
FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
FlyButton.TextSize = 13
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", FlyButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)
local ButtonStroke = Instance.new("UIStroke", FlyButton)
ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
ButtonStroke.Thickness = 1.5

-- Khung chỉnh tốc độ
local SpeedFrame = Instance.new("Frame", MainFrame)
SpeedFrame.Size = UDim2.new(0, 320, 0, 40)
SpeedFrame.Position = UDim2.new(0.5, -160, 0, 85)
SpeedFrame.BackgroundTransparency = 1

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Size = UDim2.new(0, 150, 1, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "SPEED: " .. tostring(speed)
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local DecButton = Instance.new("TextButton", SpeedFrame)
DecButton.Size = UDim2.new(0, 45, 0, 30)
DecButton.Position = UDim2.new(1, -95, 0.5, -15)
DecButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DecButton.Text = "-"
DecButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecButton.TextSize = 16
DecButton.Font = Enum.Font.SourceSansBold
DecButton.BorderSizePixel = 0
Instance.new("UICorner", DecButton).CornerRadius = UDim.new(0, 6)
local DecStroke = Instance.new("UIStroke", DecButton)
DecStroke.Color = Color3.fromRGB(55, 55, 55)
DecStroke.Thickness = 1

local IncButton = Instance.new("TextButton", SpeedFrame)
IncButton.Size = UDim2.new(0, 45, 0, 30)
IncButton.Position = UDim2.new(1, -45, 0.5, -15)
IncButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IncButton.Text = "+"
IncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IncButton.TextSize = 16
IncButton.Font = Enum.Font.SourceSansBold
IncButton.BorderSizePixel = 0
Instance.new("UICorner", IncButton).CornerRadius = UDim.new(0, 6)
local IncStroke = Instance.new("UIStroke", IncButton)
IncStroke.Color = Color3.fromRGB(55, 55, 55)
IncStroke.Thickness = 1

-- ====================================================
-- PHÂN KHU 2: HỆ THỐNG DANH SÁCH & ESP TƯƠNG TÁC
-- ====================================================

-- Nút Bật/Tắt ESP nhanh
local ToggleESPBtn = Instance.new("TextButton", MainFrame)
ToggleESPBtn.Size = UDim2.new(0, 155, 0, 35)
ToggleESPBtn.Position = UDim2.new(0, 10, 0, 135)
ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleESPBtn.Text = "ESP: ENABLED"
ToggleESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPBtn.TextSize = 12
ToggleESPBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", ToggleESPBtn).CornerRadius = UDim.new(0, 6)

-- Nút Quét lại Map (Refresh)
local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(0, 155, 0, 35)
RefreshBtn.Position = UDim2.new(1, -165, 0, 135)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RefreshBtn.Text = "REFRESH LIST"
RefreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
RefreshBtn.TextSize = 12
RefreshBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)
local RefStroke = Instance.new("UIStroke", RefreshBtn)
RefStroke.Color = Color3.fromRGB(55, 55, 55)
RefStroke.Thickness = 1

-- Khung cuộn chứa tên các vật phẩm (List)
local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(0, 320, 0, 210)
ScrollList.Position = UDim2.new(0.5, -160, 0, 180)
ScrollList.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)

local ListLayout = Instance.new("UIListLayout", ScrollList)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

local ListPadding = Instance.new("UIPadding", ScrollList)
ListPadding.PaddingLeft = UDim.new(0, 5)
ListPadding.PaddingRight = UDim.new(0, 5)
ListPadding.PaddingTop = UDim.new(0, 5)

-- Nút Teleport đến mục tiêu được chọn
local TeleportBtn = Instance.new("TextButton", MainFrame)
TeleportBtn.Size = UDim2.new(0, 320, 0, 40)
TeleportBtn.Position = UDim2.new(0.5, -160, 0, 400)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
TeleportBtn.Text = "TELE TO SELECTED OBJECT"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 13
TeleportBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TeleportBtn).CornerRadius = UDim.new(0, 8)

-- ====================================================
-- XỬ LÝ TOÀN BỘ LOGIC HOẠT ĐỘNG
-- ====================================================

-- Tự động căn chỉnh chiều dài thanh cuộn danh sách
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15)
end)

-- Hàm tạo ESP vẽ viền Highlight xuyên tường
local function applyESP(prompt, displayName)
    local pos, targetObj = getPromptTarget(prompt)
    if not targetObj then return end

    local bbg = Instance.new("BillboardGui", ESP_Storage)
    bbg.Name = "ESP_Txt"
    bbg.AlwaysOnTop = true
    bbg.Size = UDim2.new(0, 120, 0, 30)
    bbg.ExtentsOffset = Vector3.new(0, 2, 0)
    bbg.Adornee = targetObj

    local tl = Instance.new("TextLabel", bbg)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(0, 255, 150)
    tl.Text = displayName
    tl.TextSize = 11
    tl.Font = Enum.Font.SourceSansBold
    tl.TextStrokeTransparency = 0.5

    local hl = Instance.new("Highlight", ESP_Storage)
    hl.Name = "ESP_Hl"
    hl.FillColor = Color3.fromRGB(0, 255, 150)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.2
    hl.Adornee = (targetObj:IsA("Attachment") and targetObj.Parent) or targetObj
end

-- Hàm làm mới danh sách vật phẩm tương tác
local function refreshInteractableList()
    ESP_Storage:ClearAllChildren()
    for _, child in pairs(ScrollList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    selectedPrompt = nil
    selectedButton = nil

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local pos, target = getPromptTarget(obj)
            if pos and target then
                local name = (obj.ObjectText ~= "" and obj.ObjectText) or target.Name
                if obj.ActionText ~= "" then
                    name = name .. " [" .. obj.ActionText .. "]"
                end

                local itemBtn = Instance.new("TextButton", ScrollList)
                itemBtn.Size = UDim2.new(1, 0, 0, 35)
                itemBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
                itemBtn.Text = "  " .. name
                itemBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                itemBtn.TextSize = 12
                itemBtn.Font = Enum.Font.SourceSans
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 6)
                Instance.new("UIStroke", itemBtn).Color = Color3.fromRGB(40, 40, 45)

                if espEnabled then
                    applyESP(obj, name)
                end

                itemBtn.MouseButton1Click:Connect(function()
                    if selectedButton then
                        selectedButton.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
                        selectedButton.TextColor3 = Color3.fromRGB(180, 180, 180)
                    end
                    selectedPrompt = obj
                    selectedButton = itemBtn
                    itemBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
                    itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                end)
            end
        end
    end
end

-- Sự kiện nhấn nút Dịch chuyển (Teleport)
TeleportBtn.MouseButton1Click:Connect(function()
    if selectedPrompt and selectedPrompt.Parent then
        local pos, _ = getPromptTarget(selectedPrompt)
        local character = player.Character
        if pos and character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            
            TeleportBtn.Text = "SUCCESSFULLY TELEPORTED!"
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            task.wait(0.6)
            TeleportBtn.Text = "TELE TO SELECTED OBJECT"
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
        end
    else
        TeleportBtn.Text = "CHOOSE A TARGET FROM LIST!"
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(1)
        TeleportBtn.Text = "TELE TO SELECTED OBJECT"
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
    end
end)

-- Sự kiện Bật/Tắt ESP nhanh
ToggleESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleESPBtn.Text = "ESP: ENABLED"
        ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        ToggleESPBtn.Text = "ESP: DISABLED"
        ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
    refreshInteractableList()
end)

-- Sự kiện nhấn làm mới danh sách
RefreshBtn.MouseButton1Click:Connect(function()
    refreshInteractableList()
    RefreshBtn.Text = "REFRESHED!"
    task.wait(0.5)
    RefreshBtn.Text = "REFRESH LIST"
end)

-- Speed control events
local function updateSpeedDisplay()
    SpeedLabel.Text = "SPEED: " .. tostring(speed)
end

DecButton.MouseButton1Click:Connect(function()
    if speed > 10 then 
        speed = speed - 10
        updateSpeedDisplay()
    end
end)

IncButton.MouseButton1Click:Connect(function()
    speed = speed + 10
    updateSpeedDisplay()
end)

-- ====================================================
-- SỰ KIỆN ĐIỀU KHIỂN FLY (V)
-- ====================================================

local function fly()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    if flyConnection then 
        flyConnection:Disconnect() 
        flyConnection = nil 
    end
    
    local oldBv = hrp:FindFirstChild("FlyVelocity")
    if oldBv then oldBv:Destroy() end
    local oldBg = hrp:FindFirstChild("FlyGyro")
    if oldBg then oldBg:Destroy() end

    if flying then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.P = 90000 
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        
        humanoid.PlatformStand = true
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying or not hrp:IsDescendantOf(workspace) then 
                bv:Destroy()
                bg:Destroy()
                humanoid.PlatformStand = false
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                return 
            end
            
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            
            bv.Velocity = moveDir * speed
            bg.CFrame = cam.CFrame
        end)
    else
        humanoid.PlatformStand = false
    end
end

local function ToggleFlyState()
    local character = player.Character
    if flying then
        FlyButton.Text = "FLY: ACTIVE [V]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(20, 180, 20)
        FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonStroke.Color = Color3.fromRGB(50, 255, 50)
        fly()
        if character then playFlyAnim(character, true) end
    else
        FlyButton.Text = "FLY: OFF [V]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
        fly()
        if character then playFlyAnim(character, false) end
    end
end

FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    ToggleFlyState()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.V then
        flying = not flying
        ToggleFlyState()
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    if flying then
        flying = false
        ToggleFlyState()
    end
end)

-- ====================================================
-- LOGIC THU NHỎ / PHÓNG TO MENU (-)
-- ====================================================

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 35, 0, 35)
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) 
        MainStroke.Color = Color3.fromRGB(150, 40, 40) 
        Title.Visible = false
        FlyButton.Visible = false
        SpeedFrame.Visible = false
        
        -- Ẩn thêm các nút tương tác mới khi thu nhỏ
        ToggleESPBtn.Visible = false
        RefreshBtn.Visible = false
        ScrollList.Visible = false
        TeleportBtn.Visible = false
        
        MinimizeButton.Position = UDim2.new(0, 5, 0, 5)
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 340, 0, 460) -- Khôi phục chuẩn kích thước gộp
        MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) 
        MainStroke.Color = Color3.fromRGB(45, 45, 45) 
        Title.Visible = true
        FlyButton.Visible = true
        SpeedFrame.Visible = true
        
        -- Hiện lại đầy đủ các nút tương tác
        ToggleESPBtn.Visible = true
        RefreshBtn.Visible = true
        ScrollList.Visible = true
        TeleportBtn.Visible = true
        
        MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
        MinimizeButton.Text = "-"
    end
end)

-- Kích hoạt quét danh sách vật phẩm ngay lần đầu chạy script
refreshInteractableList()
