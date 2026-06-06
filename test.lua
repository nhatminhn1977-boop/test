--[=[
 d888b  db     db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88     88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88     88    88           odD'      88      88    88 88ooo88 
88  ooo 88     88    88         .88'        88      88    88 88~~~88 
88. ~8~ 88b   d88   .88.        j88.         88booo. 88b   d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L = {};

-- 1. Khởi tạo ScreenGui (Đặt ResetOnSpawn = false để chết không bị mất khung nhập)
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "BubbleChatFeeder"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Khởi tạo TextBox (Ô nhập chữ) với giao diện tối (Dark Theme) cho đẹp mắt
G2L["2"] = Instance.new("TextBox", G2L["1"])
G2L["2"].Name = "ChatInput"
G2L["2"].Size = UDim2.new(0, 250, 0, 45) -- Kích thước ô gõ
G2L["2"].Position = UDim2.new(0.5, -125, 0.8, 0) -- Căn giữa, nằm ở gần cạnh dưới màn hình
G2L["2"].BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Nền xám tối
G2L["2"].TextColor3 = Color3.fromRGB(255, 255, 255) -- Chữ màu trắng
G2L["2"].PlaceholderText = "Nhập nội dung rồi ấn Enter..." -- Chữ gợi ý khi chưa gõ
G2L["2"].PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
G2L["2"].Text = ""
G2L["2"].TextSize = 15
G2L["2"].Font = Enum.Font.SourceSansSemibold
G2L["2"].BorderSizePixel = 0
G2L["2"].ClearTextOnFocus = true -- Tự động xóa chữ cũ khi click vào gõ tiếp

-- Thêm bo góc cho ô nhập chữ nhìn cho mượt
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = G2L["2"]

-- Thêm viền nhẹ cho sang trọng
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255) -- Viền màu xanh dương
UIStroke.Thickness = 1.5
UIStroke.Parent = G2L["2"]


-- =======================================================
-- XỬ LÝ SỰ KIỆN: HIỆN BONG BÓNG CHAT KHI ẤN ENTER
-- =======================================================

local ChatService = game:GetService("Chat")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Lắng nghe sự kiện người dùng tương tác với TextBox
G2L["2"].FocusLost:Connect(function(enterPressed)
    -- Kiểm tra xem có đúng là người dùng nhấn phím Enter hay không
    if enterPressed and G2L["2"].Text ~= "" then
        local message = G2L["2"].Text
        
        -- Lấy Character (nhân vật) và Head (đầu) của bạn để treo bong bóng chat lên đó
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Head") then
            
            -- Gọi hàm tạo bong bóng chat mặc định của Roblox
            -- Tham số: (Bộ phận xuất hiện chat, Nội dung chat, Màu sắc bong bóng mặc định)
            ChatService:Chat(character.Head, message, Enum.ChatColor.White)
            
        end
        
        -- Sau khi chat xong, xóa sạch chữ trong ô nhập để sẵn sàng cho lần gõ tiếp theo
        G2L["2"].Text = ""
    end
end)

return G2L["1"];
