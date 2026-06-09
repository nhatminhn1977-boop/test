-- SCRIPT AUTO BLOCK & AIM V2 (DÀNH CHO EXECUTOR)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TRIGGER_DISTANCE = 6 -- Khoảng cách kích hoạt (6 studs)
local BLOCK_DURATION = 0.3 -- Thời gian giữ block (0.3 giây)

local isBlocking = false
local cancelBlockUntil = 0 -- Thời gian đóng băng Auto Block để ưu tiên skill/M1

-- Danh sách các phím skill khi bấm sẽ NHẢ BLOCK ngay lập tức
local SKILL_KEYS = {
    [Enum.KeyCode.One] = true,
    [Enum.KeyCode.Two] = true,
    [Enum.KeyCode.Three] = true,
    [Enum.KeyCode.Four] = true,
    [Enum.KeyCode.R] = true,
    [Enum.KeyCode.Q] = true
}

-- Hàm tìm đối thủ gần nhất trong tầm 6 studs
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = TRIGGER_DISTANCE

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myHRP = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
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

-- Hàm thực hiện lệnh nhả Block ngay lập tức
local function forceUnblock()
    if isBlocking then
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        isBlocking = false
    end
end

-- Hàm mô phỏng hành động bấm phím F để Block giữ trong 0.3s
local function pressBlockKey()
    if isBlocking or os.clock() < cancelBlockUntil then return end
    isBlocking = true
    
    -- Mô phỏng nhấn giữ phím F
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    
    -- Thả phím F ra sau đúng 0.3 giây
    task.delay(BLOCK_DURATION, function()
        forceUnblock()
    end)
end

-- LẮNG NGHE HÀNH VI CỦA NGƯỜI CHƠI (ƯU TIÊN TẤN CÔNG / LƯỚT CHIÊU)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end -- Bỏ qua khi đang gõ chat

    local shouldCancel = false

    -- Kiểm tra nếu người chơi Click chuột trái (M1)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        shouldCancel = true
    -- Kiểm tra nếu người chơi bấm các phím 1,2,3,4,R,Q
    elseif input.UserInputType == Enum.UserInputType.Keyboard and SKILL_KEYS[input.KeyCode] then
        shouldCancel = true
    end

    if shouldCancel then
        forceUnblock() -- Nhả block ngay lập tức
        cancelBlockUntil = os.clock() + 0.4 -- Đóng băng Auto Block trong 0.4s để chiêu kịp tung ra không bị kẹt ẩn
    end
end)

-- VÒNG LẶP CHÍNH THEO DÕI KHUNG HÌNH (HEARTBEAT)
local Connection
Connection = RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = myChar.HumanoidRootPart

    -- Nếu đang trong thời gian ưu tiên tung skill/M1 thì không kích hoạt Auto Block
    if os.clock() < cancelBlockUntil then return end

    local targetPlayer = getClosestPlayer()

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        -- Xoay hướng về phía đối thủ
        local targetPosition = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetPosition)
        
        -- Kích hoạt Block
        pressBlockKey()
    end
end)

-- Thông báo kích hoạt bản V2 mượt mà
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Minh AutoBlock V2",
    Text = "Hệ thống Ưu tiên Chiêu & M1 đã sẵn sàng!",
    Duration = 3
})
