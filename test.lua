-- Xóa UI cũ nếu có để tránh bị đè màn hình
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("PremiumHarvestUI") then
    CoreGui.PremiumHarvestUI:Destroy()
end

-- Khởi tạo UI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumHarvestUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Khung chứa (Main Frame) - Bo góc tròn
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 230)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32) -- Màu nền tối hiện đại
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo di chuyển trên màn hình
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12) -- Bo góc 12px siêu mượt
MainCorner.Parent = MainFrame

-- Tiêu đề UI
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "🍒 AUTOFARM HARVEST v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Nút Bật/Tắt (Toggle Button)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 280, 0, 45)
ToggleBtn.Position = UDim2.new(0, 20, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) -- Mặc định màu đỏ (OFF)
ToggleBtn.Text = "Trạng Thái: ĐANG TẮT"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- Nhãn hướng dẫn Blacklist
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(0, 280, 0, 20)
Label.Position = UDim2.new(0, 20, 0, 115)
Label.BackgroundTransparency = 1
Label.Text = "Danh sách chặn (Cách nhau bằng dấu phẩy):"
Label.TextColor3 = Color3.fromRGB(160, 160, 165)
Label.TextSize = 12
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Font = Enum.Font.Gotham
Label.Parent = MainFrame

-- Ô nhập Blacklist (TextBox)
local BlacklistInput = Instance.new("TextBox")
BlacklistInput.Size = UDim2.new(0, 280, 0, 40)
BlacklistInput.Position = UDim2.new(0, 20, 0, 140)
BlacklistInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
BlacklistInput.Text = "Apple" -- Mặc định điền sẵn Cherry dựa theo image_5109dc.png
BlacklistInput.PlaceholderText = "Ví dụ: Cherry, Apple, Wood"
BlacklistInput.TextColor3 = Color3.fromRGB(255, 255, 255)
BlacklistInput.TextSize = 14
BlacklistInput.Font = Enum.Font.Gotham
BlacklistInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = BlacklistInput

--- LẬP TRÌNH LOGIC HOẠT ĐỘNG ---
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local BlacklistTable = {}

-- Hàm cập nhật danh sách chặn từ TextBox
local function updateBlacklist()
    BlacklistTable = {}
    for item in string.gmatch(BlacklistInput.Text, "[^,]+") do
        -- Cắt khoảng trắng thừa và chuyển về chữ thường để so sánh chính xác
        local cleanItem = string.lower(string.gsub(item, "^%s*(.-)%s*$", "%1"))
        if cleanItem ~= "" then
            table.insert(BlacklistTable, cleanItem)
        end
    end
end

-- Lắng nghe mỗi khi người dùng thay đổi chữ trong ô Blacklist
BlacklistInput:GetPropertyChangedSignal("Text"):Connect(updateBlacklist)
updateBlacklist() -- Chạy khởi tạo lần đầu

-- Xử lý sự kiện bấm nút Bật/Tắt
ToggleBtn.MouseButton1Click:Connect(function()
    IsEnabled = not IsEnabled
    if IsEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60) -- Đổi sang màu xanh
        ToggleBtn.Text = "Trạng Thái: ĐANG BẬT"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) -- Trả về màu đỏ
        ToggleBtn.Text = "Trạng Thái: ĐANG TẮT"
    end
end)

-- Vòng lặp quét và gom vật phẩm tự động
task.spawn(function()
    while true do
        task.wait(0.1) -- Giảm tải cho CPU
        
        if IsEnabled then
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                for _, object in ipairs(workspace:GetDescendants()) do
                    if not IsEnabled then break end
                    
                    -- Tìm các điểm có ProximityPrompt và có chữ Harvest
                    if object:IsA("ProximityPrompt") and (object.ActionText == "Harvest" or string.find(object.ActionText, "Harvest")) then
                        
                        -- Lấy tên định danh của vật phẩm (từ ObjectText hoặc tên của cây/quả)
                        local objectText = string.lower(object.ObjectText)
                        local parentName = string.lower(object.Parent.Name)
                        
                        -- Kiểm tra xem tên này có nằm trong danh sách Blacklist không
                        local shouldSkip = false
                        for _, bannedWord in ipairs(BlacklistTable) do
                            if string.find(objectText, bannedWord) or string.find(parentName, bannedWord) then
                                shouldSkip = true
                                break
                            end
                        end
                        
                        -- Nếu không bị chặn thì tiến hành Teleport đến nhặt
                        if not shouldSkip then
                            local parentPart = object.Parent
                            if parentPart and parentPart:IsA("BasePart") then
                                -- Dịch chuyển lên trên vật thể một chút để kích hoạt nút ổn định hơn
                                rootPart.CFrame = parentPart.CFrame * CFrame.new(0, 2, 0)
                                task.wait(0.2) -- Chờ game load vị trí mới
                                
                                -- Giả lập hành động nhấn và giữ nút tương tác
                                object:InputHoldBegin()
                                task.wait(object.HoldDuration)
                                object:InputHoldEnd()
                                
                                task.wait(0.3) -- Nghỉ ngắn trước khi đổi mục tiêu, tránh bị Anticheat phát hiện kích hoạt quá nhanh
                            end
                        end
                        
                    end
                end
            end
        end
    end
end)
