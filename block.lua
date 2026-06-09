-- SCRIPT AUTO BLOCK & AIM V4 (INSTANT DEFENSE - DÀNH CHO EXECUTOR)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TRIGGER_DISTANCE = 6 -- Khoảng cách kích hoạt (6 studs)
local BLOCK_DURATION = 0.3 -- Khoảng giữ tối thiểu của một nhịp Block (0.3s)

local isBlocking = false
local blockEndTime = 0
local cancelBlockUntil = 0

-- Danh sách các phím Bypass để HỦY BLOCK lập tức
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

-- LẮNG NGHE BẤM PHÍM BYPASS - NẰM RIÊNG ĐỂ ĐẢM BẢO NGẮT BLOCK LẬP TỨC
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local shouldCancel = false
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        shouldCancel = true
    elseif input.UserInputType == Enum.UserInputType.Keyboard and BYPASS_KEYS[input.KeyCode] then
        shouldCancel = true
    end

    if shouldCancel then
        cancelBlockUntil = os.clock() + 0.35 -- Khóa Auto Block trong 0.35s để ưu tiên hành động
        if isBlocking then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
    end
end)

-- VÒNG LẶP CHÍNH CHẠY THEO KHUNG HÌNH (TỐC ĐỘ PHẢN ỨNG TUYỆT ĐỐI)
local Connection
Connection = RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then 
        if isBlocking then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
        return 
    end
    
    local myHRP = myChar.HumanoidRootPart
    
    -- Kiểm tra điều kiện Bypass trước
    if os.clock() < cancelBlockUntil then return end

    local targetPlayer = getClosestPlayer()

    -- NẾU THỎA MÃN ĐIỀU KIỆN (Có địch trong tầm 6 studs)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        -- 1. XOAY ROOT NGAY LẬP TỨC (Mỗi khung hình)
        local targetPosition = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetPosition)
        
        -- 2. BLOCK NGAY LẬP TỨC
        if not isBlocking then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            isBlocking = true
            blockEndTime = os.clock() + BLOCK_DURATION -- Đặt mốc thời gian giữ ít nhất 0.3s
        else
            -- Nếu đang trong trạng thái block và đã quá 0.3s, nhưng địch VẪN TRONG TẦM -> Gia hạn thời gian Block tiếp
            if os.clock() >= blockEndTime then
                blockEndTime = os.clock() + BLOCK_DURATION
            end
        end
    else
        -- NẾU KHÔNG ĐỦ ĐIỀU KIỆN (Địch ra ngoài tầm)
        -- Chỉ nhả Block khi đã giữ ĐỦ 0.3s của nhịp đó
        if isBlocking and os.clock() >= blockEndTime then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
    end
end)

-- Thông báo kích hoạt bản V4 Instant Block
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Minh AutoBlock V4",
    Text = "Instant Response & Keep Block Activated!",
    Duration = 3
})
