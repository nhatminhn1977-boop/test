-- Ultimate Fly & Chest Tracker System (v1.4 Auto-Refresh & Distance)

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

local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 340, 0, 460)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)[cite: 2]
MainFrame.BorderSizePixel = 0
MainFrame.Active = true[cite: 2]
MainFrame.Draggable = true [cite: 2]

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)[cite: 2]
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)[cite: 2]
MainStroke.Thickness = 1.5[cite: 2]

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)[cite: 2]
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1[cite: 2]
Title.Text = "CHEST SNIPER & FLY MANAGER 🏴‍☠️"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)[cite: 2]
Title.TextSize = 12[cite: 2]
Title.Font = Enum.Font.SourceSansBold[cite: 2]
Title.TextXAlignment = Enum.TextXAlignment.Left[cite: 2]

local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)[cite: 2]
MinimizeButton.Position = UDim2.new(1, -30, 0, 5)[cite: 2]
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)[cite: 2]
MinimizeButton.Text = "-"[cite: 2]
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)[cite: 2]
MinimizeButton.TextSize = 16[cite: 2]
MinimizeButton.Font = Enum.Font.SourceSansBold[cite: 2]
MinimizeButton.BorderSizePixel = 0[cite: 2]
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 5)[cite: 2]

-- ====================================================
-- PHÂN KHU 1: HỆ THỐNG BAY (FLY CONTROLS)
-- ====================================================

local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 320, 0, 40)
FlyButton.Position = UDim2.new(0.5, -160, 0, 40)
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)[cite: 2]
FlyButton.Text = "FLY: OFF [V]"[cite: 2]
FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)[cite: 2]
FlyButton.TextSize = 13
FlyButton.Font = Enum.Font.SourceSansBold[cite: 2]
FlyButton.BorderSizePixel = 0[cite: 2]

local ButtonCorner = Instance.new("UICorner", FlyButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)[cite: 2]
local ButtonStroke = Instance.new("UIStroke", FlyButton)
ButtonStroke.Color = Color3.fromRGB(150, 40, 40)[cite: 2]
ButtonStroke.Thickness = 1.5[cite: 2]

local SpeedFrame = Instance.new("Frame", MainFrame)
SpeedFrame.Size = UDim2.new(0, 320, 0, 40)
SpeedFrame.Position = UDim2.new(0.5, -160, 0, 85)
SpeedFrame.BackgroundTransparency = 1[cite: 2]

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Size = UDim2.new(0, 150, 1, 0)[cite: 2]
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)[cite: 2]
SpeedLabel.BackgroundTransparency = 1[cite: 2]
SpeedLabel.Text = "SPEED: " .. tostring(speed)[cite: 2]
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)[cite: 2]
SpeedLabel.TextSize = 13[cite: 2]
SpeedLabel.Font = Enum.Font.SourceSansBold[cite: 2]
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left[cite: 2]

local DecButton = Instance.new("TextButton", SpeedFrame)
DecButton.Size = UDim2.new(0, 45, 0, 30)
DecButton.Position = UDim2.new(1, -95, 0.5, -15)
DecButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)[cite: 2]
DecButton.Text = "-"[cite: 2]
DecButton.TextColor3 = Color3.fromRGB(255, 255, 255)[cite: 2]
DecButton.TextSize = 16[cite: 2]
DecButton.Font = Enum.Font.SourceSansBold[cite: 2]
DecButton.BorderSizePixel = 0[cite: 2]
Instance.new("UICorner", DecButton).CornerRadius = UDim.new(0, 6)[cite: 2]
local DecStroke = Instance.new("UIStroke", DecButton)
DecStroke.Color = Color3.fromRGB(55, 55, 55)[cite: 2]
DecStroke.Thickness = 1[cite: 2]

local IncButton = Instance.new("TextButton", SpeedFrame)
IncButton.Size = UDim2.new(0, 45, 0, 30)
IncButton.Position = UDim2.new(1, -45, 0.5, -15)
IncButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)[cite: 2]
IncButton.Text = "+"[cite: 2]
IncButton.TextColor3 = Color3.fromRGB(255, 255, 255)[cite: 2]
IncButton.TextSize = 16[cite: 2]
IncButton.Font = Enum.Font.SourceSansBold[cite: 2]
IncButton.BorderSizePixel = 0[cite: 2]
Instance.new("UICorner", IncButton).CornerRadius = UDim.new(0, 6)[cite: 2]
local IncStroke = Instance.new("UIStroke", IncButton)
IncStroke.Color = Color3.fromRGB(55, 55, 55)[cite: 2]
IncStroke.Thickness = 1[cite: 2]

-- ====================================================
-- PHÂN KHU 2: HỆ THỐNG DANH SÁCH & ESP RƯƠNG (CHEST ONLY)
-- ====================================================

local ToggleESPBtn = Instance.new("TextButton", MainFrame)
ToggleESPBtn.Size = UDim2.new(0, 155, 0, 35)
ToggleESPBtn.Position = UDim2.new(0, 10, 0, 135)
ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleESPBtn.Text = "ESP: ENABLED"
ToggleESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPBtn.TextSize = 12
ToggleESPBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", ToggleESPBtn).CornerRadius = UDim.new(0, 6)

local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(0, 155, 0, 35)
RefreshBtn.Position = UDim2.new(1, -165, 0, 135)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RefreshBtn.Text = "REFRESHING (1.5s)"
RefreshBtn.TextColor3 = Color3.fromRGB(46, 204, 113) -- Đổi sang màu xanh lá báo hiệu đang tự động chạy
RefreshBtn.TextSize = 12
RefreshBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)
local RefStroke = Instance.new("UIStroke", RefreshBtn)
RefStroke.Color = Color3.fromRGB(55, 55, 55)
RefStroke.Thickness = 1

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

local TeleportBtn = Instance.new("TextButton", MainFrame)
TeleportBtn.Size = UDim2.new(0, 320, 0, 40)
TeleportBtn.Position = UDim2.new(0.5, -160, 0, 400)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
TeleportBtn.Text = "TELE TO SELECTED CHEST"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 13
TeleportBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TeleportBtn).CornerRadius = UDim.new(0, 8)

-- ====================================================
-- XỬ LÝ TOÀN BỘ LOGIC HOẠT ĐỘNG
-- ====================================================

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15)
end)

-- Hàm vẽ ESP chứa tên + Khoảng cách lơ lửng
local function applyESP(prompt, displayName, distance)
    local pos, targetObj = getPromptTarget(prompt)
    if not targetObj then return end

    local bbg = Instance.new("BillboardGui", ESP_Storage)
    bbg.Name = "ESP_Txt"
    bbg.AlwaysOnTop = true
    bbg.Size = UDim2.new(0, 150, 0, 30)
    bbg.ExtentsOffset = Vector3.new(0, 2, 0)
    bbg.Adornee = targetObj

    local tl = Instance.new("TextLabel", bbg)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(255, 185, 0) -- Đổi sang màu Vàng hoàng kim cho hợp với Rương
    tl.Text = displayName .. " [" .. tostring(distance) .. "s]"
    tl.TextSize = 11
    tl.Font = Enum.Font.SourceSansBold
    tl.TextStrokeTransparency = 0.5

    local hl = Instance.new("Highlight", ESP_Storage)
    hl.Name = "ESP_Hl"
    hl.FillColor = Color3.fromRGB(255, 185, 0)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.2
    hl.Adornee = (targetObj:IsA("Attachment") and targetObj.Parent) or targetObj
end

-- Hàm quét lọc Rương và cập nhật khoảng cách thực tế
local function refreshInteractableList()
    -- Ghi nhớ rương đang chọn trước khi làm mới danh sách
    local lastSelectedPrompt = selectedPrompt

    ESP_Storage:ClearAllChildren()
    for _, child in pairs(ScrollList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    selectedButton = nil

    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            -- BỘ LỌC CHỈ TÌM CHỮ "CHEST" (Bỏ qua các thứ khác như hái nấm, nhặt cỏ...)
            local actionText = string.lower(obj.ActionText)
            local objectText = string.lower(obj.ObjectText)
            
            if string.find(actionText, "chest") or string.find(objectText, "chest") then
                local pos, target = getPromptTarget(obj)
                if pos and target then
                    -- Tính toán khoảng cách thời gian thực (Làm tròn số)
                    local distance = math.floor((hrp.Position - pos).Magnitude)
                    
                    -- Đặt lại tên rương gọn gàng sạch sẽ
                    local cleanName = "Chest [Open Chest]"
                    local displayTitle = cleanName .. " - " .. tostring(distance) .. " Studs"

                    -- Tạo nút hiển thị trong danh sách bảng điều khiển
                    local itemBtn = Instance.new("TextButton", ScrollList)
                    itemBtn.Size = UDim2.new(1, 0, 0, 35)
                    itemBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
                    itemBtn.Text = "  " .. displayTitle
                    itemBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    itemBtn.TextSize = 12
                    itemBtn.Font = Enum.Font.SourceSans
                    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 6)
                    Instance.new("UIStroke", itemBtn).Color = Color3.fromRGB(40, 40, 45)

                    -- Nếu đây là rương người chơi đã bấm chọn từ trước, kích hoạt lại trạng thái Highlight xanh dương
                    if obj == lastSelectedPrompt then
                        selectedPrompt = obj
                        selectedButton = itemBtn
                        itemBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
                        itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end

                    -- Vẽ ESP rương
                    if espEnabled then
                        applyESP(obj, cleanName, distance)
                    end

                    -- Sự kiện khi bấm chọn rương trong menu
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
    
    -- Nếu rương cũ đã bị người khác mở mất hoặc biến mất, xóa biến khóa mục tiêu
    if selectedPrompt and not selectedPrompt:IsDescendantOf(workspace) then
        selectedPrompt = nil
    end
end

-- VÒNG LẶP CHẠY NGẦM: TỰ ĐỘNG CẬP NHẬT MỖI 1.5 GIÂY
task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(refreshInteractableList)
    end
end)

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
            TeleportBtn.Text = "TELE TO SELECTED CHEST"
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
        end
    else
        TeleportBtn.Text = "CHOOSE A CHEST FROM LIST FIRST!"
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(1)
        TeleportBtn.Text = "TELE TO SELECTED CHEST"
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

-- Nút bấm thủ công (Vẫn giữ phòng khi bạn muốn ép xung refresh ngay lập tức)
RefreshBtn.MouseButton1Click:Connect(function()
    refreshInteractableList()
end)

-- Speed control events[cite: 2]
local function updateSpeedDisplay()
    SpeedLabel.Text = "SPEED: " .. tostring(speed)[cite: 2]
end

DecButton.MouseButton1Click:Connect(function()
    if speed > 10 then [cite: 2]
        speed = speed - 10[cite: 2]
        updateSpeedDisplay()[cite: 2]
    end[cite: 2]
end)

IncButton.MouseButton1Click:Connect(function()
    speed = speed + 10[cite: 2]
    updateSpeedDisplay()[cite: 2]
end)

-- ====================================================
-- SỰ KIỆN ĐIỀU KHIỂN FLY (V)[cite: 2]
-- ====================================================

local function fly()
    local character = player.Character[cite: 2]
    if not character then return end[cite: 2]
    local hrp = character:FindFirstChild("HumanoidRootPart")[cite: 2]
    local humanoid = character:FindFirstChild("Humanoid")[cite: 2]
    if not hrp or not humanoid then return end[cite: 2]
    
    if flyConnection then [cite: 2]
        flyConnection:Disconnect() [cite: 2]
        flyConnection = nil [cite: 2]
    end[cite: 2]
    
    local oldBv = hrp:FindFirstChild("FlyVelocity")[cite: 2]
    if oldBv then oldBv:Destroy() end[cite: 2]
    local oldBg = hrp:FindFirstChild("FlyGyro")[cite: 2]
    if oldBg then oldBg:Destroy() end[cite: 2]

    if flying then[cite: 2]
        local bv = Instance.new("BodyVelocity")[cite: 2]
        bv.Name = "FlyVelocity"[cite: 2]
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)[cite: 2]
        bv.Velocity = Vector3.new(0, 0, 0)[cite: 2]
        bv.Parent = hrp[cite: 2]
        
        local bg = Instance.new("BodyGyro")[cite: 2]
        bg.Name = "FlyGyro"[cite: 2]
        bg.P = 90000 [cite: 2]
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)[cite: 2]
        bg.CFrame = hrp.CFrame[cite: 2]
        bg.Parent = hrp[cite: 2]
        
        humanoid.PlatformStand = true[cite: 2]
        
        flyConnection = RunService.RenderStepped:Connect(function()[cite: 2]
            if not flying or not hrp:IsDescendantOf(workspace) then [cite: 2]
                bv:Destroy()[cite: 2]
                bg:Destroy()[cite: 2]
                humanoid.PlatformStand = false[cite: 2]
                if flyConnection then[cite: 2]
                    flyConnection:Disconnect()[cite: 2]
                    flyConnection = nil[cite: 2]
                end[cite: 2]
                return [cite: 2]
            end[cite: 2]
            
            local cam = workspace.CurrentCamera[cite: 2]
            local moveDir = Vector3.new(0, 0, 0)[cite: 2]
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end[cite: 2]
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end[cite: 2]
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end[cite: 2]
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end[cite: 2]
            
            bv.Velocity = moveDir * speed[cite: 2]
            bg.CFrame = cam.CFrame[cite: 2]
        end)[cite: 2]
    else[cite: 2]
        humanoid.PlatformStand = false[cite: 2]
    end[cite: 2]
end

local function ToggleFlyState()
    local character = player.Character[cite: 2]
    if flying then[cite: 2]
        FlyButton.Text = "FLY: ACTIVE [V]"[cite: 2]
        FlyButton.BackgroundColor3 = Color3.fromRGB(20, 180, 20)[cite: 2]
        FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)[cite: 2]
        ButtonStroke.Color = Color3.fromRGB(50, 255, 50)[cite: 2]
        fly()[cite: 2]
        if character then playFlyAnim(character, true) end[cite: 2]
    else[cite: 2]
        FlyButton.Text = "FLY: OFF [V]"[cite: 2]
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)[cite: 2]
        FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)[cite: 2]
        ButtonStroke.Color = Color3.fromRGB(150, 40, 40)[cite: 2]
        fly()[cite: 2]
        if character then playFlyAnim(character, false) end[cite: 2]
    end[cite: 2]
end

FlyButton.MouseButton1Click:Connect(function()
    flying = not flying[cite: 2]
    ToggleFlyState()[cite: 2]
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.V then[cite: 2]
        flying = not flying[cite: 2]
        ToggleFlyState()[cite: 2]
    end[cite: 2]
end)

player.CharacterAdded:Connect(function(newCharacter)
    if flying then[cite: 2]
        flying = false[cite: 2]
        ToggleFlyState()[cite: 2]
    end[cite: 2]
end)

-- ====================================================
-- LOGIC THU NHỎ / PHÓNG TO MENU (-)[cite: 2]
-- ====================================================

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized[cite: 2]
    if isMinimized then[cite: 2]
        MainFrame.Size = UDim2.new(0, 35, 0, 35)[cite: 2]
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) [cite: 2]
        MainStroke.Color = Color3.fromRGB(150, 40, 40) [cite: 2]
        Title.Visible = false[cite: 2]
        FlyButton.Visible = false[cite: 2]
        SpeedFrame.Visible = false[cite: 2]
        
        ToggleESPBtn.Visible = false
        RefreshBtn.Visible = false
        ScrollList.Visible = false
        TeleportBtn.Visible = false
        
        MinimizeButton.Position = UDim2.new(0, 5, 0, 5)[cite: 2]
        MinimizeButton.Text = "+"[cite: 2]
    else[cite: 2]
        MainFrame.Size = UDim2.new(0, 340, 0, 460)
        MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) [cite: 2]
        MainStroke.Color = Color3.fromRGB(45, 45, 45) [cite: 2]
        Title.Visible = true[cite: 2]
        FlyButton.Visible = true[cite: 2]
        SpeedFrame.Visible = true[cite: 2]
        
        ToggleESPBtn.Visible = true
        RefreshBtn.Visible = true
        ScrollList.Visible = true
        TeleportBtn.Visible = true
        
        MinimizeButton.Position = UDim2.new(1, -30, 0, 5)[cite: 2]
        MinimizeButton.Text = "-"[cite: 2]
    end[cite: 2]
end)

-- Khởi chạy lần đầu tiên
refreshInteractableList()
