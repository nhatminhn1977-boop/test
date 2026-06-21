-- Xóa UI cũ nếu có
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("PremiumHarvestUI_V2") then
    CoreGui.PremiumHarvestUI_V2:Destroy()
end

-- Khởi tạo UI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumHarvestUI_V2"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Khung chứa (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 230)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Tiêu đề UI
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "🍒 AUTOFARM HARVEST v2.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Nút Bật/Tắt
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 280, 0, 45)
ToggleBtn.Position = UDim2.new(0, 20, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
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
BlacklistInput.Text = "Cherry" 
BlacklistInput.PlaceholderText = "Ví dụ: Cherry, Apple"
BlacklistInput.TextColor3 = Color3.fromRGB(255, 255, 255)
BlacklistInput.TextSize = 14
BlacklistInput.Font = Enum.Font.Gotham
BlacklistInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = BlacklistInput

--- LOGIC XỬ LÝ BỘ LỌC THÔNG MINH ---
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local BlacklistTable = {}

-- Hàm trích xuất "Tên Thật" của trái cây (Bỏ qua các từ khóa hệ thống)
local function getFruitRealName(prompt)
    local parent = prompt.Parent
    if not parent then return "" end
    
    -- Bước 1: Tìm kiếm TextLabel hiển thị tên (như bảng Cherry 1.97kg trong ảnh)
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("TextLabel") and child.Text ~= "" then
            local textLower = string.lower(child.Text)
            -- Nếu text chứa chữ "harvest" hệ thống thì bỏ qua, tìm bảng text khác sạch hơn
            if not string.find(textLower, "harvest") then
                return textLower
            end
        end
    end
    
    -- Bước 2: Kiểm tra ObjectText của ProximityPrompt nếu có
    if prompt.ObjectText and prompt.ObjectText ~= "" then
        return string.lower(prompt.ObjectText)
    end
    
    -- Bước 3: Hướng giải quyết cuối cùng - Lấy tên Part và lọc sạch từ bẩn
    local rawName = string.lower(parent.Name)
    -- Lọc bỏ các từ hệ thống phổ biến để tránh nhận diện nhầm
    rawName = string.gsub(rawName, "harvest", "")
    rawName = string.gsub(rawName, "part", "")
    rawName = string.gsub(rawName, "node", "")
    rawName = string.gsub(rawName, "spawn", "")
    rawName = string.gsub(rawName, "model", "")
    rawName = string.gsub(rawName, "%s+", "") -- Xóa khoảng trắng thừa
    
    return rawName
end

-- Cập nhật danh sách chặn từ UI
local function updateBlacklist()
    BlacklistTable = {}
    for item in string.gmatch(BlacklistInput.Text, "[^,]+") do
        local cleanItem = string.lower(string.gsub(item, "^%s*(.-)%s*$", "%1"))
        if cleanItem ~= "" then
            table.insert(BlacklistTable, cleanItem)
        end
    end
end

BlacklistInput:GetPropertyChangedSignal("Text"):Connect(updateBlacklist)
updateBlacklist()

ToggleBtn.MouseButton1Click:Connect(function()
    IsEnabled = not IsEnabled
    if IsEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
        ToggleBtn.Text = "Trạng Thái: ĐANG BẬT"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        ToggleBtn.Text = "Trạng Thái: ĐANG TẮT"
    end
end)

-- Vòng lặp chính
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if IsEnabled then
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                for _, object in ipairs(workspace:GetDescendants()) do
                    if not IsEnabled then break end
                    
                    if object:IsA("ProximityPrompt") and (object.ActionText == "Harvest" or string.find(object.ActionText, "Harvest")) then
                        
                        -- Lấy tên thật đã qua bộ lọc của trái cây
                        local realFruitName = getFruitRealName(object)
                        
                        -- Kiểm tra với danh sách Blacklist
                        local shouldSkip = false
                        for _, bannedWord in ipairs(BlacklistTable) do
                            if bannedWord ~= "" and string.find(realFruitName, bannedWord) then
                                shouldSkip = true
                                break
                            end
                        end
                        
                        -- Tiến hành thu hoạch nếu không bị chặn
                        if not shouldSkip then
                            local parentPart = object.Parent
                            if parentPart and parentPart:IsA("BasePart") then
                                rootPart.CFrame = parentPart.CFrame * CFrame.new(0, 2, 0)
                                task.wait(0.2)
                                
                                object:InputHoldBegin()
                                task.wait(object.HoldDuration)
                                object:InputHoldEnd()
                                
                                task.wait(0.3)
                            end
                        end
                        
                    end
                end
            end
        end
    end
end)
