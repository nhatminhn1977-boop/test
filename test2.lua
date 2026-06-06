--[=[
 d888b  db     db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88     88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88     88    88           odD'      88      88    88 88ooo88 
88  ooo 88     88    88         .88'        88      88    88 88~~~88 
88. ~8~ 88b   d88   .88.        j88.         88booo. 88b   d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L = {}

-- 1. Khởi tạo ScreenGui
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "TeleportGuiSystem"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Menu bo góc)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 260, 0, 110)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0) -- Căn gần giữa màn hình
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo di chuyển quanh màn hình

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "BRING PLAYER TOOL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

-- 3. Ô TextBox nhập tên người chơi
local NameInput = Instance.new("TextBox", MainFrame)
NameInput.Size = UDim2.new(0, 220, 0, 45)
NameInput.Position = UDim2.new(0.5, -110, 0, 45)
NameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderText = "Nhập tên mục tiêu rồi ấn Enter..."
NameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
NameInput.Text = ""
NameInput.TextSize = 14
NameInput.Font = Enum.Font.SourceSansSemibold
NameInput.BorderSizePixel = 0
NameInput.ClearTextOnFocus = true

local InputCorner = Instance.new("UICorner", NameInput)
InputCorner.CornerRadius = UDim.new(0, 8)

local InputStroke = Instance.new("UIStroke", NameInput)
InputStroke.Color = Color3.fromRGB(230, 126, 34) -- Viền màu cam nổi bật
InputStroke.Thickness = 1.5

-- =======================================================
-- LOGIC XỬ LÝ DỊCH CHUYỂN (TELEPORT / BRING PLAYER)
-- =======================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hàm tìm kiếm người chơi dựa trên chuỗi chữ nhập vào (không phân biệt hoa thường)
local function GetPlayerByName(targetName)
    targetName = string.lower(targetName)
    for _, p in ipairs(Players:GetPlayers()) do
        -- Kiểm tra xem tên hiển thị (DisplayName) hoặc tên gốc (Name) có chứa chuỗi nhập vào không
        if string.find(string.lower(p.Name), targetName) or string.find(string.lower(p.DisplayName), targetName) then
            return p
        end
    end
    return nil
end

-- Lắng nghe sự kiện khi người dùng gõ tên xong và nhấn ENTER
NameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and NameInput.Text ~= "" then
        local inputText = NameInput.Text
        
        -- Kiểm tra Character của bản thân trước để lấy vị trí gốc
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if not myHrp then
            warn("Không tìm thấy vị trí của bạn!")
            NameInput.Text = ""
            return
        end
        
        -- Tìm kiếm người chơi mục tiêu
        local targetPlayer = GetPlayerByName(inputText)
        
        if targetPlayer then
            -- Không tự dịch chuyển chính mình
            if targetPlayer == LocalPlayer then
                NameInput.PlaceholderText = "Đó là tên của bạn mà!"
                NameInput.Text = ""
                return
            end
            
            local targetChar = targetPlayer.Character
            local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if targetHrp then
                -- THỰC HIỆN TELEPORT: Đưa CFrame của mục tiêu về vị trí trước mặt bạn một chút (tránh kẹt)
                targetHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -3)
                
                -- Đổi chữ gợi ý báo thành công
                NameInput.PlaceholderText = "Đã kéo thành công: " .. targetPlayer.DisplayName
            else
                NameInput.PlaceholderText = "Người chơi đó hiện không có Character!"
            end
        else
            -- Nếu không tìm thấy ai khớp tên
            NameInput.PlaceholderText = "Không tìm thấy người chơi này!"
        end
        
        -- Xóa chữ đã nhập để sẵn sàng cho lần gõ tiếp theo
        NameInput.Text = ""
    end
end)

return G2L["1"]
