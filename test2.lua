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
G2L["1"].Name = "HoldPlayerGuiSystem"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Menu bo góc)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 260, 0, 110)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "BRING & HOLD 1S TOOL"
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
InputStroke.Color = Color3.fromRGB(46, 204, 113) -- Đổi sang màu xanh lá cho uy tín
InputStroke.Thickness = 1.5

-- =======================================================
-- LOGIC XỬ LÝ DỊCH CHUYỂN VÀ GIỮ CHÂN MỤC TIÊU 1 GIÂY
-- =======================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hàm tìm kiếm người chơi viết tắt
local function GetPlayerByName(targetName)
    targetName = string.lower(targetName)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), targetName) or string.find(string.lower(p.DisplayName), targetName) then
            return p
        end
    end
    return nil
end

-- Lắng nghe sự kiện gõ tên xong nhấn ENTER
NameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and NameInput.Text ~= "" then
        local inputText = NameInput.Text
        
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if not myHrp then
            NameInput.PlaceholderText = "Không tìm thấy vị trí của bạn!"
            NameInput.Text = ""
            return
        end
        
        local targetPlayer = GetPlayerByName(inputText)
        
        if targetPlayer then
            if targetPlayer == LocalPlayer then
                NameInput.PlaceholderText = "Bạn nhập tên bạn làm gì?"
                NameInput.Text = ""
                return
            end
            
            -- Chạy bất đồng bộ (Thread riêng) bằng task.spawn để không làm treo UI
            task.spawn(function()
                NameInput.PlaceholderText = "Đang giữ chân: " .. targetPlayer.DisplayName
                
                -- Tạo một mốc thời gian bắt đầu ghim vị trí
                local startTime = os.clock()
                
                -- Vòng lặp liên tục ghim vị trí mục tiêu trước mặt bạn trong đúng 1 giây
                while os.clock() - startTime < 1 do
                    local targetChar = targetPlayer.Character
                    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                    
                    -- Cập nhật lại tọa độ của bạn liên tục (phòng trường hợp bạn đang di chuyển)
                    myChar = LocalPlayer.Character
                    myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    
                    if targetHrp and myHrp then
                        -- Ghim liên tục mục tiêu cách bạn 3 studs về phía trước mặt
                        targetHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -3)
                    else
                        break -- Nếu họ thoát game hoặc chết thì dừng vòng lặp
                    end
                    
                    -- Chờ 1 khoảng cực ngắn (chu kỳ quét vật lý) rồi lặp lại để ghim liên tục
                    task.wait() 
                end
                
                NameInput.PlaceholderText = "Đã thả mục tiêu ra!"
            end)
        else
            NameInput.PlaceholderText = "Không tìm thấy ai khớp tên!"
        end
        
        NameInput.Text = ""
    end
end)

return G2L["1"]
