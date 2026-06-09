-- SCRIPT AUTO BLOCK & AIM V8 (EMERGENCY COUNTER & ESCAPE - DÀNH CHO EXECUTOR)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TRIGGER_DISTANCE = 11 
local BLOCK_DURATION = 0.5 
local FORCE_BLOCK_TIME = 0.2 

local isBlocking = false
local blockStartTime = 0
local blockEndTime = 0
local cancelBlockUntil = 0
local damageDealtTimeout = 0

-- Các biến phục vụ tính năng Tự Vệ Khẩn Cấp
local lastHealth = 100
local emergencyMode = false
local emergencyStep = 0
local emergencyTimer = 0

local BYPASS_KEYS = {
    [Enum.KeyCode.One] = true, [Enum.KeyCode.Two] = true, [Enum.KeyCode.Three] = true, [Enum.KeyCode.Four] = true,
    [Enum.KeyCode.R] = true, [Enum.KeyCode.Q] = true,
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.D] = true, [Enum.KeyCode.Space] = true
}

local function isEscapeComboPressed()
    if UserInputService:IsKeyDown(Enum.KeyCode.S) and UserInputService:IsKeyDown(Enum.KeyCode.Q) then return true end
    if UserInputService:IsKeyDown(Enum.KeyCode.W) and UserInputService:IsKeyDown(Enum.KeyCode.A) and UserInputService:IsKeyDown(Enum.KeyCode.Space) then return true end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) and UserInputService:IsKeyDown(Enum.KeyCode.D) then return true end
    return false
end

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
                if d < min then min = d; closest = p end
            end
        end
    end
    return closest
end

-- Hàm thực hiện nhả F an toàn
local function forceUnblock()
    if isBlocking then
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        isBlocking = false
    end
end

-- LẮNG NGHE BYPASS PHÍM ĐƠN
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or emergencyMode or isEscapeComboPressed() then return end

    local shouldCancel = false
    if input.UserInputType == Enum.UserInputType.MouseButton1 then shouldCancel = true
    elseif input.UserInputType == Enum.UserInputType.Keyboard and BYPASS_KEYS[input.KeyCode] then shouldCancel = true end

    if shouldCancel then
        if isBlocking and (os.clock() - blockStartTime < FORCE_BLOCK_TIME) then return end
        cancelBlockUntil = os.clock() + 0.35
        forceUnblock()
    end
end)

-- THEO DÕI LOGIC KHI BẢN THÂN DEAL DAMAGE
local function setupDamageListener(character)
    if not character then return end
    character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Part") and (descendant.Name:lower():find("hitbox") or descendant.Name:lower():find("slash") or descendant.Name:lower():find("damage")) then
            damageDealtTimeout = os.clock() + 0.3 
            if not emergencyMode then forceUnblock() end
        end
    end)
end
setupDamageListener(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(function(char)
    setupDamageListener(char)
    local hum = char:WaitForChild("Humanoid")
    lastHealth = hum.Health
end)

-- VÒNG LẶP CHÍNH RENDERSTEPPED (PHẢN ỨNG KHẨN CẤP THEO FRAME)
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    -- 🚨 KIỂM TRA NHẬN DAMAGE (BỊ ĐÁNH) ĐỂ KÍCH HOẠT TỰ VỆ KHẨN CẤP
    if hum.Health < lastHealth then
        lastHealth = hum.Health
        -- Nếu bị stun (không thể bấm nút do game khóa), cơ chế spam F vẫn xếp hàng chờ, ngay khi hết chuỗi đòn của địch sẽ bung ra
        emergencyMode = true
        emergencyStep = 1 -- Bước 1: Spam F tự vệ khẩn cấp
        emergencyTimer = os.clock()
    end
    lastHealth = hum.Health -- Cập nhật liên tục máu hiện tại

    -- 🛡️ XỬ LÝ CHUỖI TỰ VỆ KHẨN CẤP (EMERGENCY STATE MACHINE)
    if emergencyMode then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- BẮT BUỘC XOAY ROOT VỀ PHÍA ĐỊCH TRONG KHI ĐANG THEO DÕI KHẨN CẤP
            hum.AutoRotate = false
            local targetPosition = Vector3.new(targetPlayer.Character.HumanoidRootPart.Position.X, root.Position.Y, targetPlayer.Character.HumanoidRootPart.Position.Z)
            root.CFrame = CFrame.lookAt(root.Position, targetPosition)
        end

        -- BƯỚC 1: Spam Block F trong 0.1s ngay sau khi dính đòn (hoặc ngay sau khi thoát stun)
        if emergencyStep == 1 then
            if not isBlocking then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                isBlocking = true
            end
            if os.clock() - emergencyTimer >= 0.1 then
                forceUnblock() -- Nhả block ra để chuẩn bị thực hiện dash
                emergencyStep = 2 -- Chuyển sang Bước 2: Side Dash
                emergencyTimer = os.clock()
            end
            return -- Khóa toàn bộ các logic khác trong thời gian này
        end

        -- BƯỚC 2: Giữ D và nhấn Q (Side Dash sang phải để thoát góc chết)
        if emergencyStep == 2 then
            -- Nhấn giữ phím D
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
            -- Nhấn phím Q (Dash)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
            task.wait(0.05) -- Giữ phím D một tích tắc để game nhận diện hướng di chuyển bên phải trước khi thả
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
            
            -- Hoàn thành chuỗi thoát hiểm khẩn cấp, trả trạng thái về bình thường
            emergencyMode = false
            emergencyStep = 0
            cancelBlockUntil = os.clock() + 0.2 -- Cho 0.2s hồi phục để animation dash mượt mà
            return
        end
    end

    -- --- LOGIC AUTO BLOCK THÔNG THƯỜNG (KHI KHÔNG CÓ TRẠNG THÁI KHẨN CẤP) ---
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.FreeFall or state == Enum.HumanoidStateType.Jumping then
        hum.AutoRotate = true
        forceUnblock()
        return
    end

    if isEscapeComboPressed() then
        hum.AutoRotate = true
        cancelBlockUntil = os.clock() + 0.4
        forceUnblock()
        return
    end

    if os.clock() < damageDealtTimeout or os.clock() < cancelBlockUntil then
        hum.AutoRotate = true
        return
    end

    local targetPlayer = getClosestPlayer()

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        
        hum.AutoRotate = false
        local targetPosition = Vector3.new(targetHRP.Position.X, root.Position.Y, targetHRP.Position.Z)
        root.CFrame = CFrame.lookAt(root.Position, targetPosition)
        
        if isBlocking and (os.clock() - blockStartTime < FORCE_BLOCK_TIME) then return end

        if not isBlocking then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            isBlocking = true
            blockStartTime = os.clock()
            blockEndTime = os.clock() + BLOCK_DURATION
        else
            if os.clock() >= blockEndTime then blockEndTime = os.clock() + BLOCK_DURATION end
        end
    else
        hum.AutoRotate = true
        if isBlocking and os.clock() >= blockEndTime then forceUnblock() end
    end
end)

-- Thông báo kích hoạt V8
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nhật Minh Hub V8",
    Text = "Emergency Side-Dash System Loaded!",
    Duration = 3
})
