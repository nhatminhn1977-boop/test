-- 1.2


local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("InteractTeleportUI_v2") then
    CoreGui.InteractTeleportUI_v2:Destroy()
end

-- ==================== CÀI ĐẶT GIAO DIỆN ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InteractTeleportUI_v2"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 90)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -45)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Interact Teleport v2"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Name = "TeleportBtn"
TeleportBtn.Size = UDim2.new(0, 190, 0, 40)
TeleportBtn.Position = UDim2.new(0, 15, 0, 35)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
TeleportBtn.Text = "Teleport to Nearest"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 16
TeleportBtn.Font = Enum.Font.SourceSansBold
TeleportBtn.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = TeleportBtn

-- ==================== XỬ LÝ LOGIC QUÉT VỊ TRÍ ====================

-- Hàm lấy vị trí chính xác của Prompt (Bất kể nó nằm trong Part hay Attachment)
local function getPromptPosition(prompt)
    local parent = prompt.Parent
    if not parent then return nil end
    
    if parent:IsA("BasePart") then
        return parent.Position
    elseif parent:IsA("Attachment") then
        return parent.WorldPosition -- Lấy vị trí thực tế trong không gian 3D của Attachment
    end
    return nil
end

-- Hàm tìm điểm tương tác gần nhất
local function getClosestInteractable()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return nil, nil
    end
    
    local playerPos = character.HumanoidRootPart.Position
    local closestPrompt = nil
    local closestPos = nil
    local shortestDistance = math.huge

    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") then
            local promptPos = getPromptPosition(object)
            if promptPos then
                local distance = (playerPos - promptPos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPrompt = object
                    closestPos = promptPos
                end
            end
        end
    end

    return closestPrompt, closestPos
end

-- Sự kiện click chuột
TeleportBtn.MouseButton1Click:Connect(function()
    print("[Script] Đang quét tìm điểm tương tác gần nhất...")
    local targetPrompt, targetPos = getClosestInteractable()
    
    if targetPrompt and targetPos then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Dịch chuyển nhân vật đến vị trí của Prompt + cao lên 3 studs
            character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            
            -- Hiển thị trạng thái thành công trên nút
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Xanh lá
            TeleportBtn.Text = "Success!"
            print("[Script] Đã tele thành công đến: " .. targetPrompt.Name .. " | Tên object: " .. targetPrompt.Parent.Name)
            
            task.wait(0.7)
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
            TeleportBtn.Text = "Teleport to Nearest"
        end
    else
        -- Báo lỗi nếu không quét được gì
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Đỏ
        TeleportBtn.Text = "No target found!"
        warn("[Script] Không tìm thấy bất kỳ ProximityPrompt nào trong Workspace!")
        
        task.wait(1.2)
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
        TeleportBtn.Text = "Teleport to Nearest"
    end
end)
