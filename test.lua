--[=[
 d888b  db     db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88     88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88     88    88           odD'      88      88    88 88ooo88 
88  ooo 88     88    88         .88'        88      88    88 88~~~88 
88. ~8~ 88b   d88   .88.        j88.         88booo. 88b   d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L = {};

-- 1. Khởi tạo ScreenGui
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "RealChatFeeder"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Khởi tạo TextBox
G2L["2"] = Instance.new("TextBox", G2L["1"])
G2L["2"].Name = "ChatInput"
G2L["2"].Size = UDim2.new(0, 250, 0, 45)
G2L["2"].Position = UDim2.new(0.5, -125, 0.8, 0)
G2L["2"].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
G2L["2"].TextColor3 = Color3.fromRGB(255, 255, 255)
G2L["2"].PlaceholderText = "Nhập nội dung muốn CHAT..."
G2L["2"].PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
G2L["2"].Text = ""
G2L["2"].TextSize = 15
G2L["2"].Font = Enum.Font.SourceSansSemibold
G2L["2"].BorderSizePixel = 0
G2L["2"].ClearTextOnFocus = true

-- Bo góc & Viền
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = G2L["2"]

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = G2L["2"]

-- =======================================================
-- XỬ LÝ SỰ KIỆN: GỬI TIN NHẮN VÀO HỆ THỐNG CHAT THẬT
-- =======================================================

local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Hàm xử lý gửi chat
local function sendChatMessage(message)
    -- Hướng xử lý 1: Dành cho các game đời mới sử dụng TextChatService
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if textChannel then
            textChannel:SendAsync(message)
        end
    else
        -- Hướng xử lý 2: Dành cho các game đời cũ sử dụng LegacyChatService (Dùng DefaultChatSystemChatEvents)
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local sayMessageRequest = chatEvents:FindFirstChild("SayMessageRequest")
            if sayMessageRequest and sayMessageRequest:IsA("RemoteEvent") then
                sayMessageRequest:FireServer(message, "All")
            end
        end
    end
end

-- Lắng nghe khi bấm Enter
G2L["2"].FocusLost:Connect(function(enterPressed)
    if enterPressed and G2L["2"].Text ~= "" then
        local message = G2L["2"].Text
        
        -- Gọi hàm gửi tin nhắn thật
        sendChatMessage(message)
        
        -- Xóa chữ trong ô nhập sau khi đã chat xong
        G2L["2"].Text = ""
    end
end)

return G2L["1"];
