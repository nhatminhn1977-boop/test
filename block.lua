-- SCRIPT AUTO BLOCK & AIM V5 (FORCE 0.1S BLOCK & SHIFT-LOCK BYPASS)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TRIGGER_DISTANCE = 6 -- Khoảng cách kích hoạt (6 studs)
local BLOCK_DURATION = 0.3 -- Tổng khoảng giữ tối đa của một nhịp Block (0.3s)
local FORCE_BLOCK_TIME = 0.1 -- Khoảng thời gian KHÓA CHẶT bắt buộc (0.1s)

local isBlocking = false
local blockStartTime = 0
local blockEndTime = 0
local cancelBlockUntil = 0

-- Danh sách các phím Bypass để HỦY BLOCK sau khi hết thời gian khóa bắt buộc
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

-- LẮNG NGHE BẤM PHÍM BYPASS (CÓ KIỂM TRA ĐIỀU KIỆN KHÓA 0.1S)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local shouldCancel = false
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        shouldCancel = true
    elseif input.UserInputType == Enum.UserInputType.Keyboard and BYPASS_KEYS[input.KeyCode] then
        shouldCancel = true
    end

    if shouldCancel then
        -- Nếu đang trong thời gian KHÓA BẮT BUỘC (0.1s đầu), từ chối Bypass hoàn toàn
        if isBlocking and (os.clock() - blockStartTime < FORCE_BLOCK_TIME) then
            return
        end

        -- Nếu đã qua 0.1s, cho phép hủy block bình thường
        cancelBlockUntil = os.clock() + 0.35
        if isBlocking then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
    end
end)

-- VÒNG LẶP CHẠY THEO TỪNG KHUNG HÌNH (HEARTBEAT)
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
    local targetPlayer = getClosestPlayer()

    -- Trường hợp đang giữ block bắt buộc (trong 0.1s đầu): BẮT BUỘC giữ góc quay và phím F, bỏ qua mọi lệnh hủy
    if isBlocking and (os.clock() - blockStartTime < FORCE_BLOCK_TIME) then
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = targetPlayer.Character.HumanoidRootPart
            local targetPosition = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
            myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetPosition)
        end
        return
    end

    -- Nếu đang trong thời gian bị đóng băng sau khi bấm Bypass thành công, tạm thời không bắt địch mới
    if os.clock() < cancelBlockUntil then return end

    -- NẾU THỎA MÃN ĐIỀU KIỆN (Có địch trong tầm 6 studs)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        -- XOAY ROOT BẮT BUỘC (Đè hoàn toàn lên Shift Lock bằng cách gán CFrame liên tục mỗi frame)
        local targetPosition = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetPosition)
        
        -- KÍCH HOẠT / GIA HẠN BLOCK
        if not isBlocking then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            isBlocking = true
            blockStartTime = os.clock() -- Ghi lại mốc thời gian bắt đầu khóa chặt
            blockEndTime = os.clock() + BLOCK_DURATION
        else
            -- Địch vẫn trong tầm và đã hết 0.3s nhịp cũ, tự động nối thêm nhịp mới
            if os.clock() >= blockEndTime then
                blockEndTime = os.clock() + BLOCK_DURATION
            end
        end
    else
        -- NẾU ĐỊCH RA KHỎI TẦM
        -- Chỉ nhả Block khi đã giữ đủ ít nhất 0.3s của nhịp đó
        if isBlocking and os.clock() >= blockEndTime then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
    end
end)

-- Thông báo bản V5 Unstoppable Defense
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Minh AutoBlock V5",
    Text = "Force 0.1s & Shift-Lock Override Active!",
    Duration = 3
})
