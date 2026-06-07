--[=[
 d888b  db     db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88     88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88     88    88           odD'      88      88    88 88ooo88 
88  ooo 88     88    88         .88'        88      88    88 88~~~88 
88. ~8~ 88b   d88   .88.        j88.         88booo. 88b   d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. Khởi tạo ScreenGui nền trắng
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "SpinPushPlayerHub"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.4, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(220, 220, 220)
MainStroke.Thickness = 1.5

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🌪️ SPIN PUSH TOOL 🌪️"
Title.TextColor3 = Color3.fromRGB(40, 40, 40)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

-- 3. Danh sách người chơi
local PlayerListFrame = Instance.new("ScrollingFrame", MainFrame)
PlayerListFrame.Size = UDim2.new(0, 240, 0, 140)
PlayerListFrame.Position = UDim2.new(0.5, -120, 0, 45)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.ScrollBarThickness = 4
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)

local ListCorner = Instance.new("UICorner", PlayerListFrame)
ListCorner.CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout", PlayerListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- 4. Ô điền lực đẩy
local PushPowerInput = Instance.new("TextBox", MainFrame)
PushPowerInput.Size = UDim2.new(0, 240, 0, 45)
PushPowerInput.Position = UDim2.new(0.5, -120, 0, 200)
PushPowerInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
PushPowerInput.TextColor3 = Color3.fromRGB(50, 50, 50)
PushPowerInput.PlaceholderText = "Nhập lực đẩy văng..."
PushPowerInput.Text = "120" -- Tăng nhẹ mặc định lên 120 cho bay gắt
PushPowerInput.TextSize = 13
PushPowerInput.Font = Enum.Font.SourceSansSemibold
PushPowerInput.BorderSizePixel = 0

local InputCorner = Instance.new("UICorner", PushPowerInput)
InputCorner.CornerRadius = UDim.new(0, 8)

-- 5. Nút kích hoạt xoay đẩy
local ActionButton = Instance.new("TextButton", MainFrame)
ActionButton.Size = UDim2.new(0, 240, 0, 45)
ActionButton.Position = UDim2.new(0.5, -120, 0, 260)
ActionButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Màu đỏ bão tố
ActionButton.Text = "KÍCH HOẠT SPIN-PUSH"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.TextSize = 14
ActionButton.Font = Enum.Font.SourceSansBold
ActionButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", ActionButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)

local selectedPlayer = nil 
local isPushing = false

-- =======================================================
-- TỰ ĐỘNG CẬP NHẬT DANH SÁCH NGƯỜI CHƠI
-- =======================================================
local function RefreshPlayerList()
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pButton = Instance.new("TextButton", PlayerListFrame)
            pButton.Size = UDim2.new(1, -8, 0, 32)
            pButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            pButton.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            pButton.TextColor3 = Color3.fromRGB(80, 80, 80)
            pButton.TextXAlignment = Enum.TextXAlignment.Left
            pButton.TextSize = 12
            pButton.Font = Enum.Font.SourceSansSemibold
            
            local bCorner = Instance.new("UICorner", pButton)
            bCorner.CornerRadius = UDim.new(0, 6)
            local bStroke = Instance.new("UIStroke", pButton)
            bStroke.Color = Color3.fromRGB(235, 235, 235)
            
            pButton.MouseButton1Click:Connect(function()
                selectedPlayer = p
                for _, btn in ipairs(PlayerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) btn.TextColor3 = Color3.fromRGB(80, 80, 80) end
                end
                pButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                pButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                ActionButton.Text = "HÚC XOÁY NGƯỜI -> " .. p.DisplayName
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(p) if selectedPlayer == p then selectedPlayer = nil ActionButton.Text = "KÍCH HOẠT SPIN-PUSH" end RefreshPlayerList() end)
RefreshPlayerList()

-- =======================================================
-- LOGIC LAO ĐẨY KẾT HỢP XOAY THÂN (KHÔNG QUAY CAMERA)
-- =======================================================

ActionButton.MouseButton1Click:Connect(function()
    if isPushing then
        isPushing = false
        ActionButton.Text = "KÍCH HOẠT SPIN-PUSH"
        ActionButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        return
    end

    if not selectedPlayer then
        ActionButton.Text = "Vui lòng chọn mục tiêu!"
        task.wait(1.5)
        ActionButton.Text = "KÍCH HOẠT SPIN-PUSH"
        return
    end

    local power = tonumber(PushPowerInput.Text) or 120
    isPushing = true
    ActionButton.Text = "ĐANG QUÉT (ẤN ĐỂ DỪNG)"
    ActionButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Màu xanh khi đang hoạt động

    task.spawn(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isPushing or not selectedPlayer then
                if connection then connection:Disconnect() end
                return
            end

            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            local tarChar = selectedPlayer.Character
            local tarHrp = tarChar and tarChar:FindFirstChild("HumanoidRootPart")

            if myHrp and tarHrp then
                -- 1. XOAY THÂN HÌNH SIÊU TỐC: Chỉ đổi RotVelocity của nhân vật để va chạm liên tục
                -- Hoàn toàn không đụng vào Camera nên màn hình của bạn vẫn đứng im bình thường!
                myHrp.RotVelocity = Vector3.new(0, 10000, 0) 

                -- Vô hiệu hóa va chạm tạm thời giữa các chi của bạn để không bị kẹt khi quay sát mục tiêu
                for _, part in ipairs(myChar:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end

                -- 2. ĐẨY VẬN TỐC LAO ĐẾN: Tính toán hướng di chuyển dính chặt vào người đó
                local direction = (tarHrp.Position - myHrp.Position).Unit
                myHrp.Velocity = direction * power
                
                -- Khóa CFrame áp sát liên tục vào tâm của mục tiêu
                myHrp.CFrame = CFrame.new(myHrp.Position, tarHrp.Position)
            else
                isPushing = false
            end
        end)
        
        while isPushing do task.wait(0.1) end
        if connection then connection:Disconnect() end
        
        -- DỌN DẸP: Khi tắt, đưa nhân vật về trạng thái đứng im bình thường
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.RotVelocity = Vector3.new(0, 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
            -- Bật lại va chạm cơ thể
            for _, part in ipairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        
        if selectedPlayer then
            ActionButton.Text = "HÚC XOÁY NGƯỜI -> " .. selectedPlayer.DisplayName
        else
            ActionButton.Text = "KÍCH HOẠT SPIN-PUSH"
        end
        ActionButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end)
end)

return G2L["1"]
