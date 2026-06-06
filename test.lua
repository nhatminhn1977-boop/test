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
G2L["1"].Name = "ProFlyMenu"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Menu bo góc)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Kéo di chuyển menu thoải mái

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "PRO FLY MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

-- 3. Nút bấm Bật/Tắt Bay
local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 160, 0, 45)
FlyButton.Position = UDim2.new(0.5, -80, 0.5, -10)
FlyButton.BackgroundColor3 = Color3.fromRGB(219, 68, 85) -- Màu đỏ (OFF)
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 16
FlyButton.Font = Enum.Font.SourceSansSemibold
FlyButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", FlyButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)

-- =======================================================
-- LOGIC FLY SỬ DỤNG VECTOR CAMERA (XỊN)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flying = false
local speed = 60 -- Tốc độ bay (Đã buff nhẹ lên 60 cho bay mượt)
local flyConnection = nil -- Biến lưu trữ kết nối để ngắt sạch khi tắt

local function toggleFly()
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    if flying then
        -- Thay đổi trạng thái nút bấm sang ON (Xanh lá)
        FlyButton.Text = "Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)

        -- Khởi tạo lực đẩy chống trọng lực
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        -- Khóa hoạt ảnh đứng yên một chút cho nhân vật đỡ bị rung chân khi bay
        humanoid.PlatformStand = true

        -- Lưu kết nối RenderStepped vào biến để quản lý giải phóng bộ nhớ
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying then return end
            
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            -- Tính toán hướng bay chuẩn xác dựa trên tổ hợp phím WASD của bạn
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            
            bv.Velocity = moveDir * speed
        end)
    else
        -- Thay đổi trạng thái nút bấm sang OFF (Đỏ)
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(219, 68, 85)

        -- Dọn dẹp kết nối để tránh bị ngốn hiệu năng (Lag)
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        -- Xóa bỏ BodyVelocity cũ
        local activeVelocity = hrp:FindFirstChild("FlyVelocity")
        if activeVelocity then
            activeVelocity:Destroy()
        end
        
        -- Trả nhân vật về trạng thái vật lý bình thường
        humanoid.PlatformStand = false
    end
end

-- Kết nối nút bấm UI với hàm xử lý
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    toggleFly()
end)

-- Tự động dọn dẹp khi nhân vật chết
player.CharacterRemoving:Connect(function()
    flying = false
    if flyConnection then 
        flyConnection:Disconnect()
        flyConnection = nil
    end
end)

return G2L["1"]
