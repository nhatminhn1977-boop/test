-- Xóa UI cũ nếu chạy lại script
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("SimpleHarvestUI") then
    CoreGui.SimpleHarvestUI:Destroy()
end

-- Khởi tạo UI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleHarvestUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Khung chứa nhỏ gọn (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 130)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- Màu tối Cyberpunk
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Thoải mái kéo thả trên màn hình
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12) -- Bo góc mịn
MainCorner.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "🍒 SIMPLE HARVEST v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Nút Bật/Tắt duy nhất
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) -- Màu đỏ (OFF)
ToggleBtn.Text = "AUTO HARVEST: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8) -- Nút cũng được bo góc
BtnCorner.Parent = ToggleBtn

--- LOGIC HOẠT ĐỘNG ---
local IsEnabled = false

-- Sự kiện bấm nút thay đổi trạng thái
ToggleBtn.MouseButton1Click:Connect(function()
    IsEnabled = not IsEnabled
    if IsEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60) -- Đổi sang màu xanh (ON)
        ToggleBtn.Text = "AUTO HARVEST: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) -- Về lại đỏ
        ToggleBtn.Text = "AUTO HARVEST: OFF"
    end
end)

-- Vòng lặp quét map đứng từ xa kích hoạt
task.spawn(function()
    while true do
        task.wait(0.2) -- Khoảng nghỉ quét map để không bị giật lag game
        
        if IsEnabled then
            for _, object in ipairs(workspace:GetDescendants()) do
                if not IsEnabled then break end
                
                -- Tìm tất cả ProximityPrompt có chữ Harvest
                if object:IsA("ProximityPrompt") and (object.ActionText == "Harvest" or string.find(object.ActionText, "Harvest")) then
                    
                    -- Kích hoạt ép nút tự nhấn từ xa (Không cần đi bộ hay nhảy đến)
                    object:InputHoldBegin()
                    task.wait(object.HoldDuration) -- Tự động đợi nếu nút bắt giữ E (ví dụ 0.5s)
                    object:InputHoldEnd()
                    
                    task.wait(0.1) -- Nghỉ một chút trước khi chuyển sang quả tiếp theo để tránh spam gói tin quá nhanh
                end
            end
        end
    end
end)
