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
local LocalPlayer = Players.LocalPlayer

-- 1. Khởi tạo ScreenGui
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "AdvancedTrollHub"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Menu bo góc xịn)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.4, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🎯 PLAYER TARGET HUB 🎯"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

-- 3. KHUNG CUỘN DANH SÁCH NGƯỜI CHƠI (ScrollingFrame)
local PlayerListFrame = Instance.new("ScrollingFrame", MainFrame)
PlayerListFrame.Size = UDim2.new(0, 240, 0, 150)
PlayerListFrame.Position = UDim2.new(0.5, -120, 0, 45)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Tự động co giãn theo số lượng người
PlayerListFrame.ScrollBarThickness = 6
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

local ListCorner = Instance.new("UICorner", PlayerListFrame)
ListCorner.CornerRadius = UDim.new(0, 8)

-- Layout để các nút tên người chơi tự động xếp thẳng hàng xuống dưới
local UIListLayout = Instance.new("UIListLayout", PlayerListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- 4. KHUNG ĐIỀN NỘI DUNG (TextBox)
local ContentInput = Instance.new("TextBox", MainFrame)
ContentInput.Size = UDim2.new(0, 240, 0, 45)
ContentInput.Position = UDim2.new(0.5, -120, 0, 210)
ContentInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ContentInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ContentInput.PlaceholderText = "Nhập nội dung muốn troll tại đây..."
ContentInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
ContentInput.Text = ""
ContentInput.TextSize = 13
ContentInput.Font = Enum.Font.SourceSansSemibold
ContentInput.BorderSizePixel = 0
ContentInput.ClearTextOnFocus = false

local InputCorner = Instance.new("UICorner", ContentInput)
InputCorner.CornerRadius = UDim.new(0, 8)

-- 5. NÚT KÍCH HOẠT (TextButton)
local ActionButton = Instance.new("TextButton", MainFrame)
ActionButton.Size = UDim2.new(0, 240, 0, 45)
ActionButton.Position = UDim2.new(0.5, -120, 0, 270)
ActionButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173) -- Màu tím hoàng gia quyền lực
ActionButton.Text = "KÍCH HOẠT SCRIPT"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.TextSize = 15
ActionButton.Font = Enum.Font.SourceSansBold
ActionButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", ActionButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)

-- =======================================================
-- HỆ THỐNG XỬ LÝ LOGIC UI VÀ TỰ ĐỘNG CẬP NHẬT DANH SÁCH
-- =======================================================

local selectedPlayer = nil -- Biến lưu trữ người chơi đang được chọn

-- Hàm cập nhật và vẽ lại toàn bộ danh sách người chơi
local function RefreshPlayerList()
    -- Xóa các nút cũ trước (trừ cái UIListLayout)
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Duyệt qua tất cả người chơi trong phòng để tạo nút bấm
    for _, p in ipairs(Players:GetPlayers()) do
        local pButton = Instance.new("TextButton", PlayerListFrame)
        pButton.Size = UDim2.new(1, -8, 0, 30) -- Rộng fit khung cuộn, cao 30px
        pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        pButton.Text = p.DisplayName .. " (@" .. p.Name .. ")"
        pButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        pButton.TextSize = 12
        pButton.Font = Enum.Font.SourceSans
        pButton.BorderSizePixel = 0
        
        local bCorner = Instance.new("UICorner", pButton)
        bCorner.CornerRadius = UDim.new(0, 4)
        
        -- Sự kiện khi click chọn người chơi này trong danh sách
        pButton.MouseButton1Click:Connect(function()
            selectedPlayer = p
            -- Đổi màu tất cả các nút khác về màu tối mặc định
            for _, btn in ipairs(PlayerListFrame:GetChildren()) do
                if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
            end
            -- Đổi nút được chọn sang màu xanh dương để đánh dấu
            pButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            ActionButton.Text = "KÍCH HOẠT $\rightarrow$ " .. p.DisplayName
        end)
    end
    
    -- Tự động tính toán lại chiều dài thanh cuộn dựa trên số lượng người chơi
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Tự động vẽ lại danh sách khi có người vào hoặc rời server
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    if selectedPlayer == p then
        selectedPlayer = nil
        ActionButton.Text = "KÍCH HOẠT SCRIPT"
    end
    RefreshPlayerList()
end)

-- Chạy cập nhật danh sách ngay khi mở script lần đầu
RefreshPlayerList()

-- =======================================================
-- SỰ KIỆN CLICK NÚT KÍCH HOẠT (NƠI BẠN BỎ CODE TROLL VÀO)
-- =======================================================

ActionButton.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        ActionButton.Text = "Vui lòng chọn 1 người trước!"
        task.wait(1.5)
        ActionButton.Text = "KÍCH HOẠT SCRIPT"
        return
    end
    
    local textContent = ContentInput.Text
    if textContent == "" then
        ActionButton.Text = "Vui lòng nhập nội dung!"
        task.wait(1.5)
        ActionButton.Text = "KÍCH HOẠT $\rightarrow$ " .. selectedPlayer.DisplayName
        return
    end
    
    -------------------------------------------------------
    -- [ĐOẠN TROLL]: Hiện bong bóng chat giả trên đầu mục tiêu
    -------------------------------------------------------
    local char = selectedPlayer.Character
    local head = char and char:FindFirstChild("Head")
    
    if head then
        -- Tạo bảng Billboard trên đầu mục tiêu để hiện chữ giả
        local bGui = Instance.new("BillboardGui", head)
        bGui.Size = UDim2.new(0, 200, 0, 50)
        bGui.StudsOffset = Vector3.new(0, 3, 0)
        
        local tLabel = Instance.new("TextLabel", bGui)
        tLabel.Size = UDim2.new(1, 0, 1, 0)
        tLabel.Text = textContent -- Lấy nội dung bạn vừa gõ ở ô điền vào đây
        tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tLabel.BackgroundTransparency = 0.3
        tLabel.TextSize = 14
        tLabel.Font = Enum.Font.SourceSansBold
        
        local labelCorner = Instance.new("UICorner", tLabel)
        labelCorner.CornerRadius = UDim.new(0, 6)
        
        -- Báo hiệu kích hoạt thành công trên nút bấm
        ActionButton.Text = "ĐÃ TROLL XONG!"
        ContentInput.Text = "" -- Xóa chữ trong ô nhập sau khi dùng
        
        task.wait(3) -- Bong bóng tồn tại 3 giây rồi biến mất
        bGui:Destroy()
        
        -- Trả tên nút bấm về trạng thái cũ
        if selectedPlayer then
            ActionButton.Text = "KÍCH HOẠT $\rightarrow$ " .. selectedPlayer.DisplayName
        else
            ActionButton.Text = "KÍCH HOẠT SCRIPT"
        end
    else
        ActionButton.Text = "Mục tiêu không có Character!"
        task.wait(1.5)
        ActionButton.Text = "KÍCH HOẠT $\rightarrow$ " .. selectedPlayer.DisplayName
    end
end)

return G2L["1"]
