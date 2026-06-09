-- SCRIPT AUTO BLOCK & AIM V6 (FIX SHIFT-LOCK TUYỆT ĐỐI - CHẠY THEO FORM NHẬT MINH HUB)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TRIGGER_DISTANCE = 10 -- Khoảng cách kích hoạt 6 studs
local BLOCK_DURATION = 0.3 
local FORCE_BLOCK_TIME = 0.1 

local isBlocking = false
local blockStartTime = 0
local blockEndTime = 0
local cancelBlockUntil = 0

-- Danh sách phím Bypass hủy block
local BYPASS_KEYS = {
    [Enum.KeyCode.One] = true, [Enum.KeyCode.Two] = true, [Enum.KeyCode.Three] = true, [Enum.KeyCode.Four] = true,
    [Enum.KeyCode.R] = true, [Enum.KeyCode.Q] = true,
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.D] = true, [Enum.KeyCode.Space] = true
}

-- Hàm tìm đối thủ gần nhất (Sử dụng đúng logic quét mượt của Nhật Minh Hub)
local function getClosestPlayer()
    local closest, min = nil, TRIGGER_DISTANCE
    local myChar = LocalPlayer.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myHead then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
            local pHum = p.Character:FindFirstChildOfClass("Humanoid")
            if pHum and pHum.Health > 0 then
                local d = (p.Character.Head.Position - myHead.Position).Magnitude
                if d < min then
                    min = d
                    closest = p
                end
            end
        end
    end
    return closest
end

-- LẮNG NGHE PHÍM BYPASS HỦY BLOCK
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local shouldCancel = false
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        shouldCancel = true
    elseif input.UserInputType == Enum.UserInputType.Keyboard and BYPASS_KEYS[input.KeyCode] then
        shouldCancel = true
    end

    if shouldCancel then
        -- Chặn hủy nếu đang trong 0.1s khóa bắt buộc
        if isBlocking and (os.clock() - blockStartTime < FORCE_BLOCK_TIME) then
            return
        end
        cancelBlockUntil = os.clock() + 0.35
        if isBlocking then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
    end
end)

-- VÒNG LẶP RENDERSTEPPED (BẮT BUỘC ĐỂ ĐÈ SHIFT LOCK MỖI FRAME)
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then
        if isBlocking then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
        return
    end

    -- Nếu đang bị đóng băng bởi phím Bypass
    if os.clock() < cancelBlockUntil then 
        hum.AutoRotate = true
        return 
    end

    local targetPlayer = getClosestPlayer()

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        -- 🔥 BÍ QUYẾT ĐÈ SHIFT LOCK: Khóa cứng AutoRotate và viết đè tọa độ CFrame liên tục
        hum.AutoRotate = false
        
        local targetPosition = Vector3.new(targetHRP.Position.X, root.Position.Y, targetHRP.Position.Z)
        
        -- Ép cứng cụm tọa độ xoay (nhân vật sẽ không bị camera xoay kéo đi)
        root.CFrame = CFrame.lookAt(root.Position, targetPosition)
        
        -- Nếu đang trong thời gian 0.1s khóa bắt buộc, bỏ qua kiểm tra phím bấm để giữ block an toàn
        if isBlocking and (os.clock() - blockStartTime < FORCE_BLOCK_TIME) then
            return
        end

        -- XỬ LÝ LỆNH BẤM F
        if not isBlocking then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            isBlocking = true
            blockStartTime = os.clock()
            blockEndTime = os.clock() + BLOCK_DURATION
        else
            if os.clock() >= blockEndTime then
                blockEndTime = os.clock() + BLOCK_DURATION
            end
        end
    else
        -- Trả lại tự do xoay người khi không có địch
        hum.AutoRotate = true
        if isBlocking and os.clock() >= blockEndTime then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isBlocking = false
        end
    end
end)

-- Thông báo góc màn hình
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nhật Minh Hub Upgraded",
    Text = "AutoBlock V6: Shift-Lock Overrider Active!",
    Duration = 3
})
