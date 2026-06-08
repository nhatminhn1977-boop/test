local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Tìm khớp cổ (Neck) của nhân vật (hỗ trợ cả R6 và R15)
local neck = character:FindFirstChild("Neck", true)

if neck then
    local progress = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function(dt)
        -- ĐÃ FIX: Thay character:Parent() bằng character.Parent thông thường
        if not character or not character.Parent or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
            connection:Disconnect()
            return
        end
        
        -- Hiệu ứng rơi mượt mà
        if progress < 1 then
            progress = progress + (dt * 2) -- Tốc độ rơi
            if progress > 1 then progress = 1 end
        end
        
        -- Tính toán tọa độ rơi xuống đất và nghiêng đầu
        local dropCFrame = CFrame.new(0, -3.5 * progress, 0) * CFrame.Angles(math.rad(90 * progress), 0, math.rad(45 * progress))
        
        -- Ép khớp cổ nhận tọa độ
        neck.Transform = dropCFrame
    end)
    
    print("Fix lỗi xong rồi! Đầu rơi thành công rồi nha =))")
else
    warn("Không tìm thấy khớp cổ (Neck) trên nhân vật!")
end
