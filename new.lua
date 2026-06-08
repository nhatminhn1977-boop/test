local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Tìm khớp cổ (Neck) của nhân vật (hỗ trợ cả R6 và R15)
local neck = character:FindFirstChild("Neck", true)

if neck then
    local progress = 0
    local connection
    
    -- Sử dụng Heartbeat để liên tục ép tọa độ bất chấp animation hệ thống
    connection = RunService.Heartbeat:Connect(function(dt)
        -- Kiểm tra nếu nhân vật chết hoặc không tồn tại thì dừng script
        if not character or not character:Parent() or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
            connection:Disconnect()
            return
        end
        
        -- Hiệu ứng rơi mượt mà (Lerp) trong khoảng 0.5 giây ban đầu
        if progress < 1 then
            progress = progress + (dt * 2) -- Tốc độ rơi
            if progress > 1 then progress = 1 end
        end
        
        -- Tính toán tọa độ rơi: 
        -- CFrame.new(0, -3.5 * progress, 0) -> Đẩy đầu xuống thấp 3.5 studs (vừa chạm đất)
        -- CFrame.Angles(...) -> Xoay nghiêng đầu đi 90 độ cho giống đang nằm lăn lóc
        local dropCFrame = CFrame.new(0, -3.5 * progress, 0) * CFrame.Angles(math.rad(90 * progress), 0, math.rad(45 * progress))
        
        -- Ép khớp cổ nhận tọa độ này
        neck.Transform = dropCFrame
    end)
    
    print("Kích hoạt chặt đầu thành công! Thử nhìn xuống chân xem nào =))")
else
    warn("Không tìm thấy khớp cổ (Neck) trên nhân vật của bạn!")
end
