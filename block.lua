-- SCRIPT AUTO BLOCK & AIM (DÀNH CHO EXECUTOR)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local TRIGGER_DISTANCE = 6 -- Khoảng cách kích hoạt (6 studs)

-- Hàm tìm đối thủ gần nhất trong tầm 6 studs
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = TRIGGER_DISTANCE

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    local myHRP = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            -- Kiểm tra xem đối thủ còn sống không
            if player.Character.Humanoid.Health > 0 then
                local enemyHRP = player.Character.HumanoidRootPart
                local distance = (myHRP.Position - enemyHRP.Position).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Hàm mô phỏng hành động bấm phím F để Block
local isBlocking = false
local function pressBlockKey()
    if isBlocking then return end
    isBlocking = true
    
    -- Mô phỏng nhấn giữ phím F
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    
    -- Thả phím F ra sau một khoảng thời gian ngắn (ví dụ 0.3 giây) để tránh bị kẹt trạng thái block
    task.delay(0.3, function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        isBlocking = false
    end)
end

-- Vòng lặp chính chạy theo thời gian thực (Real-time)
local Connection
Connection = RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    -- Tìm mục tiêu gần nhất
    local targetPlayer = getClosestPlayer()

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        -- 1. XOAY NGƯỜI: Tính toán góc xoay hướng thẳng về phía đối thủ (chỉ xoay trục Y để không bị chúi người xuống đất)
        local targetPosition = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetPosition)
        
        -- 2. BẤM F: Kích hoạt nút đỡ đòn
        pressBlockKey()
    end
end)

-- Thông báo góc màn hình khi Inject thành công
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Minh AutoBlock",
    Text = "Hệ thống phản xạ 6 Studs đã kích hoạt!",
    Duration = 3
})
