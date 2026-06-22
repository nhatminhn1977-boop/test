-- Khai báo các Service cần thiết
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Xóa UI cũ nếu bạn lỡ nhấn Execute nhiều lần (tránh bị trùng đè UI)
if CoreGui:FindFirstChild("InteractTeleportUI") then
    CoreGui.InteractTeleportUI:Destroy()
end

-- ==================== KHỞI TẠO GIAO DIỆN (UI) ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InteractTeleportUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Khung Menu chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 90)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -45) -- Nằm giữa màn hình lúc đầu
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- Màu nền tối
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Giúp bạn có thể giữ chuột kéo UI đi chỗ khác
MainFrame.Parent = ScreenGui

-- Bo góc cho Khung Menu
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

-- Tiêu đề Menu
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Auto Interact Teleport"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

-- Nút bấm Teleport
local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Name = "TeleportBtn"
TeleportBtn.Size = UDim2.new(0, 190, 0, 40)
TeleportBtn.Position = UDim2.new(0, 15, 0, 35)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255) -- Màu xanh công nghệ
TeleportBtn.Text = "Teleport to Nearest"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 16
TeleportBtn.Font = Enum.Font.SourceSansBold
TeleportBtn.Parent = MainFrame

-- Bo góc cho Nút bấm
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = TeleportBtn

-- ==================== LOGIC XỬ LÝ (BACKEND) ====================

-- Hàm tìm ProximityPrompt gần nhất
local function getClosestInteractable()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    
    local playerPos = character.HumanoidRootPart.Position
    local closestPrompt = nil
    local shortestDistance = math.huge

    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") then
            local parentPart = object.Parent
            if parentPart and parentPart:IsA("BasePart") then
                local distance = (playerPos - parentPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPrompt = object
                end
            end
        end
    end

    return closestPrompt
end

-- Sự kiện khi click vào nút
TeleportBtn.MouseButton1Click:Connect(function()
    local targetPrompt = getClosestInteractable()
    
    if targetPrompt and targetPrompt.Parent then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Teleport đến object
            character.HumanoidRootPart.CFrame = targetPrompt.Parent.CFrame + Vector3.new(0, 3, 0)
            
            -- Đổi màu nút tạm thời để báo hiệu thành công
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Màu xanh lá
            TeleportBtn.Text = "Success!"
            task.wait(0.5)
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
            TeleportBtn.Text = "Teleport to Nearest"
        end
    else
        -- Thông báo nếu không tìm thấy
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Màu đỏ
        TeleportBtn.Text = "No target found!"
        task.wait(1)
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
        TeleportBtn.Text = "Teleport to Nearest"
    end
end)
