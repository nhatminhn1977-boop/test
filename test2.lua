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
G2L["1"].Name = "AdvancedTrollHubWhite"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Nền TRẮNG tinh tế)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.4, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Nền trắng chủ đạo
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Thêm viền đổ bóng nhẹ cho sang trọng
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(220, 220, 220)
MainStroke.Thickness = 1.5

-- Tiêu đề Menu (Chữ tối màu trên nền trắng)
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🎯 PLAYER TARGET HUB 🎯"
Title.TextColor3 = Color3.fromRGB(40, 40, 40) -- Chữ xám đen cứng cáp
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

-- 3. KHUNG CUỘN DANH SÁCH (Màu xám siêu nhạt)
local PlayerListFrame = Instance.new("ScrollingFrame", MainFrame)
PlayerListFrame.Size = UDim2.new(0, 240, 0, 150)
PlayerListFrame.Position = UDim2.new(0.5, -120, 0, 45)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245) -- Nền xám nhạt sạch sẽ
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.ScrollBarThickness = 4
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)

local ListCorner = Instance.new("UICorner", PlayerListFrame)
ListCorner.CornerRadius = UDim.new(0, 8)

local ListStroke = Instance.new("UIStroke", PlayerListFrame)
ListStroke.Color = Color3.fromRGB(230, 230, 230)
ListStroke.Thickness = 1

local UIListLayout = Instance.new("UIListLayout", PlayerListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- 4. KHUNG ĐIỀN NỘI DUNG (TextBox nền xám trắng)
local ContentInput = Instance.new("TextBox", MainFrame)
ContentInput.Size = UDim2.new(0, 240, 0, 45)
ContentInput.Position = UDim2.new(0.5, -120, 0, 210)
ContentInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
ContentInput.TextColor3 = Color3.fromRGB(50, 50, 50)
ContentInput.PlaceholderText = "Nhập nội dung muốn troll tại đây..."
ContentInput.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
ContentInput.Text = ""
ContentInput.TextSize = 13
ContentInput.Font = Enum.Font.SourceSansSemibold
ContentInput.BorderSizePixel = 0
ContentInput.ClearTextOnFocus = false

local InputCorner = Instance.new("UICorner", ContentInput)
InputCorner.CornerRadius = UDim.new(0, 8)

local InputStroke = Instance.new("UIStroke", ContentInput)
InputStroke.Color = Color3.fromRGB(230, 230, 230)
InputStroke.Thickness = 1

-- 5. NÚT KÍCH HOẠT (Màu tím hoàng gia nổi bật trên nền trắng)
local ActionButton = Instance.new("TextButton", MainFrame)
ActionButton.Size = UDim2.new(0, 240, 0, 45)
ActionButton.Position = UDim2.new(0.5, -120, 0, 270)
ActionButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173) -- Giữ màu tím để tạo điểm nhấn
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

local selectedPlayer = nil 

local function RefreshPlayerList()
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        local pButton = Instance.new("TextButton", PlayerListFrame)
        pButton.Size = UDim2.new(1, -8, 0, 32)
        pButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Nút mặc định màu trắng tinh
        pButton.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
        pButton.TextColor3 = Color3.fromRGB(80, 80, 80) -- Chữ xám vừa phải
        pButton.TextXAlignment = Enum.TextXAlignment.Left -- Căn lề trái cho đẹp
        pButton.TextSize = 12
        pButton.Font = Enum.Font.SourceSansSemibold
        pButton.BorderSizePixel = 0
        
        local bCorner = Instance.new("UICorner", pButton)
        bCorner.CornerRadius = UDim.new(0, 6)
        
        local bStroke = Instance.new("UIStroke", pButton)
        bStroke.Color = Color3.fromRGB(235, 235, 235)
        bStroke.Thickness = 1
        
        pButton.MouseButton1Click:Connect(function()
            selectedPlayer = p
            -- Trả toàn bộ các nút khác về màu trắng viền xám nhạt
            for _, btn in ipairs(PlayerListFrame:GetChildren()) do
                if btn:IsA("TextButton") then 
                    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
                    btn.TextColor3 = Color3.fromRGB(80, 80, 80)
                end
            end
            -- Nút được chọn sẽ đổi sang màu xanh dương rực rỡ, chữ trắng
            pButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
            pButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ActionButton.Text = "KÍCH HOẠT -> " .. p.DisplayName
        end)
    end
    
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    if selectedPlayer == p then
        selectedPlayer = nil
        ActionButton.Text = "KÍCH HOẠT SCRIPT"
    end
    RefreshPlayerList()
end)

RefreshPlayerList()

-- =======================================================
-- SỰ KIỆN CLICK NÚT KÍCH HOẠT
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
        ActionButton.Text = "KÍCH HOẠT -> " .. selectedPlayer.DisplayName
        return
    end
    
    local char = selectedPlayer.Character
    local head = char and char:FindFirstChild("Head")
    
    if head then
        local bGui = Instance.new("BillboardGui", head)
        bGui.Size = UDim2.new(0, 200, 0, 50)
        bGui.StudsOffset = Vector3.new(0, 3, 0)
        
        local tLabel = Instance.new("TextLabel", bGui)
        tLabel.Size = UDim2.new(1, 0, 1, 0)
        tLabel.Text = textContent
        tLabel.TextColor3 = Color3.fromRGB(40, 40, 40) -- Chữ tối màu trên bong bóng chat giả
        tLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Bong bóng chat màu trắng đồng bộ luôn
        tLabel.BackgroundTransparency = 0.1
        tLabel.TextSize = 14
        tLabel.Font = Enum.Font.SourceSansBold
        
        local labelCorner = Instance.new("UICorner", tLabel)
        labelCorner.CornerRadius = UDim.new(0, 6)
        
        local labelStroke = Instance.new("UIStroke", tLabel)
        labelStroke.Color = Color3.fromRGB(200, 200, 200)
        labelStroke.Thickness = 1
        
        ActionButton.Text = "ĐÃ TROLL XONG!"
        ContentInput.Text = "" 
        
        task.wait(3)
        bGui:Destroy()
        
        if selectedPlayer then
            ActionButton.Text = "KÍCH HOẠT -> " .. selectedPlayer.DisplayName
        else
            ActionButton.Text = "KÍCH HOẠT SCRIPT"
        end
    else
        ActionButton.Text = "Mục tiêu không có Character!"
        task.wait(1.5)
        ActionButton.Text = "KÍCH HOẠT -> " .. selectedPlayer.DisplayName
    end
end)

return G2L["1"]
