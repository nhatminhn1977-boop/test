local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Khởi tạo hoặc dọn dẹp bộ nhớ cũ tránh trùng lặp UI/ESP
if CoreGui:FindFirstChild("InteractManagerUI") then CoreGui.InteractManagerUI:Destroy() end
if CoreGui:FindFirstChild("InteractESP_Storage") then CoreGui.InteractESP_Storage:Destroy() end

local ESP_Storage = Instance.new("Folder")
ESP_Storage.Name = "InteractESP_Storage"
ESP_Storage.Parent = CoreGui

-- Trạng thái hệ thống
local espEnabled = true
local selectedPrompt = nil
local selectedButton = nil

-- ==================== THIẾT KẾ GIAO DIỆN (UI) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InteractManagerUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Khung chính lớn hơn để chứa danh sách
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Thickness = 1.5

-- Tiêu đề bảng điều khiển
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -100, 0, 40)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "INTERACT MANAGER (ESP & TELE)"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Bật/Tắt ESP nhanh bằng nút trên tiêu đề
local ToggleESPBtn = Instance.new("TextButton", MainFrame)
ToggleESPBtn.Size = UDim2.new(0, 70, 0, 26)
ToggleESPBtn.Position = UDim2.new(1, -82, 0, 7)
ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleESPBtn.Text = "ESP: ON"
ToggleESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPBtn.TextSize = 11
ToggleESPBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", ToggleESPBtn).CornerRadius = UDim.new(0, 5)

-- Danh sách cuộn chứa các Object tương tác
local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(1, -20, 0, 280)
ScrollList.Position = UDim2.new(0, 10, 0, 45)
ScrollList.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)

local ListLayout = Instance.new("UIListLayout", ScrollList)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

-- Nút REFRESH LIST
local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(0, 140, 0, 45)
RefreshBtn.Position = UDim2.new(0, 10, 1, -55)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
RefreshBtn.Text = "REFRESH LIST"
RefreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
RefreshBtn.TextSize = 13
RefreshBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 8)

-- Nút TELEPORT TO SELECTED
local TeleportBtn = Instance.new("TextButton", MainFrame)
TeleportBtn.Size = UDim2.new(0, 150, 0, 45)
TeleportBtn.Position = UDim2.new(1, -160, 1, -55)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
TeleportBtn.Text = "TELE TO SELECTED"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 13
TeleportBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TeleportBtn).CornerRadius = UDim.new(0, 8)

-- ==================== HỆ THỐNG XỬ LÝ LOGIC ====================

-- Hàm lấy vị trí và object cha thực tế
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

-- Hàm tạo ESP (Khung phát sáng xuyên tường + Chữ nổi lơ lửng)
local function applyESP(prompt, displayName)
    local pos, targetObj = getPromptTarget(prompt)
    if not targetObj then return end

    -- Tạo Text label trên đầu vật phẩm
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

    -- Tạo Khung Viền Phát Sáng (Highlight)
    local hl = Instance.new("Highlight", ESP_Storage)
    hl.Name = "ESP_Hl"
    hl.FillColor = Color3.fromRGB(0, 255, 150)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.2
    hl.Adornee = (targetObj:IsA("Attachment") and targetObj.Parent) or targetObj
end

-- Hàm quét và cập nhật danh sách UI kết hợp bật ESP
local function refreshInteractableList()
    -- Reset dữ liệu cũ
    ESP_Storage:ClearAllChildren()
    for _, child in pairs(ScrollList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    selectedPrompt = nil
    selectedButton = nil

    -- Quét toàn bộ map
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local pos, target = getPromptTarget(obj)
            if pos and target then
                -- Đặt tên hiển thị dễ nhận biết
                local name = (obj.ObjectText ~= "" and obj.ObjectText) or target.Name
                if obj.ActionText ~= "" then
                    name = name .. " [" .. obj.ActionText .. "]"
                end

                -- Tạo nút bấm trong danh sách danh sách
                local itemBtn = Instance.new("TextButton", ScrollList)
                itemBtn.Size = UDim2.new(1, -10, 0, 35)
                itemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                itemBtn.Text = "  " .. name
                itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemBtn.TextSize = 12
                itemBtn.Font = Enum.Font.SourceSans
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 6)

                -- Kích hoạt ESP nếu đang bật
                if espEnabled then
                    applyESP(obj, name)
                end

                -- Sự kiện Click chọn vật phẩm trong list
                itemBtn.MouseButton1Click:Connect(function()
                    if selectedButton then
                        selectedButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- Trả màu nút cũ
                        selectedButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    end
                    selectedPrompt = obj
                    selectedButton = itemBtn
                    itemBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255) -- Đổi màu nút được chọn
                    itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                end)
            end
        end
    end
    -- Tự động tính toán lại kích thước cuộn của danh sách
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

-- Sự kiện nhấn nút TELEPORT TO SELECTED
TeleportBtn.MouseButton1Click:Connect(function()
    if selectedPrompt and selectedPrompt.Parent then
        local pos, _ = getPromptTarget(selectedPrompt)
        local character = LocalPlayer.Character
        if pos and character and character:FindFirstChild("HumanoidRootPart") then
            -- Thực hiện dịch chuyển (cao hơn gốc 3 studs)
            character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            
            TeleportBtn.Text = "TELEPORTED!"
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            task.wait(0.6)
            TeleportBtn.Text = "TELE TO SELECTED"
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
        end
    else
        TeleportBtn.Text = "CHOOSE TARGET FIRST!"
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(1)
        TeleportBtn.Text = "TELE TO SELECTED"
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
    end
end)

-- Sự kiện nhấn nút REFRESH
RefreshBtn.MouseButton1Click:Connect(function()
    refreshInteractableList()
    RefreshBtn.Text = "REFRESHED!"
    task.wait(0.5)
    RefreshBtn.Text = "REFRESH LIST"
end)

-- Sự kiện Bật/Tắt ESP nhanh
ToggleESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleESPBtn.Text = "ESP: ON"
        ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        ToggleESPBtn.Text = "ESP: OFF"
        ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
    refreshInteractableList() -- Cập nhật lại giao diện và tắt/bật ESP tương ứng
end)

-- Chạy quét lần đầu ngay khi nạp script
refreshInteractableList()
