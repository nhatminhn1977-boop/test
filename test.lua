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
G2L["1"].Name = "FlyMenuSystem"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Bảng menu bo góc)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0) -- Nằm bên cạnh trái màn hình cho đỡ vướng
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Bạn có thể lấy chuột kéo menu này đi khắp màn hình

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "FLY MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

-- 3. Nút bấm Bật/Tắt Bay (Bo góc xịn sò)
local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 160, 0, 45)
FlyButton.Position = UDim2.new(0.5, -80, 0.5, -10)
FlyButton.BackgroundColor3 = Color3.fromRGB(219, 68, 85) -- Mặc định màu đỏ (Tắt)
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 16
FlyButton.Font = Enum.Font.SourceSansSemibold
FlyButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", FlyButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)

-- =======================================================
-- LẬP TRÌNH TÍNH NĂNG BAY (FLY SCRIPT)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flying = false
local speed = 50 -- Tốc độ bay (bạn có thể chỉnh cao hơn nếu muốn bay nhanh)
local bVelocity, bGyro
local connection

-- Hàm xử lý bắt đầu bay
local function startFly()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    -- Thao túng vật lý để nhân vật không bị rơi rơi xuống
    bVelocity = Instance.new("BodyVelocity")
    bVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bVelocity.Velocity = Vector3.new(0, 0, 0)
    bVelocity.Parent = rootPart
    
    bGyro = Instance.new("BodyGyro")
    bGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bGyro.CFrame = rootPart.CFrame
    bGyro.Parent = rootPart
    
    humanoid.PlatformStand = true -- Đưa nhân vật vào trạng thái thả lỏng (không chạy nền đất)

    -- Cập nhật hướng bay liên tục theo Camera bằng RunService
    connection = RunService.RenderStepped:Connect(function()
        if flying and rootPart and humanoid then
            -- Nhận diện hướng di chuyển từ bàn phím di chuyển mặc định của game
            local moveDirection = humanoid.MoveDirection
            
            if moveDirection.Magnitude > 0 then
                -- Bay theo hướng camera đang nhìn
                bVelocity.Velocity = Camera.CFrame:VectorToWorldSpace(Vector3.new(moveDirection.X, 0, moveDirection.Z * 1.5)) * speed
            else
                -- Đứng im trên không nếu không bấm nút di chuyển
                bVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Giữ nhân vật luôn thẳng đứng theo hướng camera
            bGyro.CFrame = Camera.CFrame
        end
    end)
end

-- Hàm xử lý dừng bay
local function stopFly()
    flying = false
    if connection then connection:Disconnect() end
    if bVelocity then bVelocity:Destroy() end
    if bGyro then bGyro:Destroy() end
    
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false -- Trả nhân vật về trạng thái đi bộ bình thường
    end
end

-- Sự kiện Click nút UI
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    
    if flying then
        FlyButton.Text = "Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Đổi sang màu xanh lá
        startFly()
    else
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(219, 68, 85) -- Trả về màu đỏ
        stopFly()
    end
end)

-- Tự động ngắt bay nếu nhân vật bị reset/chết
LocalPlayer.CharacterRemoving:Connect(function()
    stopFly()
end)

return G2L["1"]
