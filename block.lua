-- SCRIPT AUTO BLOCK & AIM V3 (DÀNH CHO EXECUTOR)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TRIGGER_DISTANCE = 10 -- Khoảng cách kích hoạt (6 studs)
local BLOCK_DURATION = 0.3 -- Thời gian giữ block tối thiểu khi di chuyển

local isBlocking = false
local cancelBlockUntil = 0 -- Thời gian đóng băng Auto Block để ưu tiên hành động khác

-- Danh sách các phím khi bấm sẽ HỦY BLOCK ngay lập tức (Bao gồm skill, di chuyển và nhảy)
local BYPASS_KEYS = {
    [Enum.KeyCode.One] = true,
    [Enum.KeyCode.Two] = true,
    [Enum.KeyCode.Three] = true,
    [Enum.KeyCode.Four] = true,
    [Enum.KeyCode.R] = true,
    [Enum.KeyCode.Q] = true,
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true
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

-- Hàm xử lý hành động bấm và giữ phím F
local function pressBlockKey()
    if isBlocking or os.clock() < cancelBlockUntil then return end
    isBlocking = true
    
    -- Mô phỏng nhấn giữ phím F
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    
    -- Quản lý thời gian nhả block dựa trên trạng thái đứng yên/di chuyển
    task.spawn(function()
        local startTime = os.clock()
        while isBlocking and (os.clock() - startTime) < BLOCK_DURATION do
            task.wait()
        end
        
        -- Sau 0.3s, kiểm tra xem người chơi có đang ĐỨNG YÊN không
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("Humanoid") then
            local humanoid = myChar.Humanoid
            -- Nếu đang di chuyển (MoveDirection > 0), tiến hành nhả block theo form cũ
            if humanoid.MoveDirection.Magnitude > 0 then
                forceUnblock()
            else
                -- Nếu ĐỨNG YÊN: Không làm gì cả (vòng lặp Heartbeat phía dưới sẽ tiếp tục giữ trạng thái block này)
            end
        else
            forceUnblock()
        end
    end)
end

-- LẮNG NGHE NÚT BẤM ĐỂ HỦY BLOCK LẬP TỨC (BYPASS)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end -- Bỏ qua khi gõ chat

    local shouldCancel = false

    -- Kiểm tra Click chuột trái (M1)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        shouldCancel = true
    -- Kiểm tra các phím trong danh sách Bypass (1,2,3,4,R,Q,W,A,D,Space)
    elseif input.UserInputType == Enum.UserInputType.Keyboard and BYPASS_KEYS[input.KeyCode] then
        shouldCancel = true
    end

    if shouldCancel then
        forceUnblock() 
        cancelBlockUntil = os.clock() + 0.35 -- Tạm dừng Auto Block một chút để hành động mượt mà
    end
end)

-- VÒNG LẶP THEO DÕI REAL-TIME (HEARTBEAT)
local Connection
Connection = RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not myChar:FindFirstChild("Humanoid") then 
        forceUnblock()
        return 
    end
    
    local myHRP = myChar.HumanoidRootPart
    local targetPlayer = getClosestPlayer()

    -- Nếu có địch trong tầm và không trong trạng thái bị đóng băng bởi phím bấm bypass
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and os.clock() >= cancelBlockUntil then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        -- Luôn xoay người về phía đối thủ
        local targetPosition = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetPosition)
        
        -- Gọi lệnh Block
        pressBlockKey()
    else
        -- Nhả block ngay khi đối thủ đi RA NGOÀI TẦM 6 studs hoặc không tìm thấy mục tiêu
        forceUnblock()
    end
end)

-- Thông báo kích hoạt bản V3 siêu thủ thế
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Minh AutoBlock V3",
    Text = "Chế độ Đứng Yên Thủ Thế đã bật!",
    Duration = 3
})
