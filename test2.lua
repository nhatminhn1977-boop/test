--[=[
 d888b  db     db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88     88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88     88    88           odD'      88      88    88 88ooo88 
88  ooo 88     88    88         .88'        88      88    88 88~~~88 
88. ~8~ 88b   d88   .88.        j88.         88booo. 88b   d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L = {}

-- 1. Khởi tạo ScreenGui
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "SpeedTrollGui"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Menu bo góc xịn)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "FORCE SPEED TROLL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold

-- 3. Ô nhập tên nạn nhân
local NameInput = Instance.new("TextBox", MainFrame)
NameInput.Size = UDim2.new(0, 220, 0, 40)
NameInput.Position = UDim2.new(0.5, -110, 0, 40)
NameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderText = "Nhập tên nạn nhân..."
NameInput.Text = ""
NameInput.TextSize = 14
NameInput.Font = Enum.Font.SourceSansSemibold
NameInput.ClearTextOnFocus = true

local Corner1 = Instance.new("UICorner", NameInput)
Corner1.CornerRadius = UDim.new(0, 6)

-- 4. Ô nhập tốc độ ép buộc (Ví dụ: 100 để đẩy bay màu, 0 để đóng băng)
local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.Size = UDim2.new(0, 220, 0, 40)
SpeedInput.Position = UDim2.new(0.5, -110, 0, 95)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Nhập tốc độ muốn ép (Ví dụ: 100)"
SpeedInput.Text = ""
SpeedInput.TextSize = 14
SpeedInput.Font = Enum.Font.SourceSansSemibold
SpeedInput.ClearTextOnFocus = true

local Corner2 = Instance.new("UICorner", SpeedInput)
Corner2.CornerRadius = UDim.new(0, 6)

local UIStroke = Instance.new("UIStroke", SpeedInput)
UIStroke.Color = Color3.fromRGB(155, 89, 182) -- Viền màu tím huyền bí
UIStroke.Thickness = 1.5

-- =======================================================
-- LOGIC TÁC ĐỘNG VẬN TỐC ÉP TỐC ĐỘ (SPEED FORCE)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function GetPlayerByName(targetName)
    targetName = string.lower(targetName)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), targetName) or string.find(string.lower(p.DisplayName), targetName) then
            return p
        end
    end
    return nil
end

-- Lắng nghe khi nhập xong Tốc độ và ấn ENTER
SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and NameInput.Text ~= "" and SpeedInput.Text ~= "" then
        local targetPlayer = GetPlayerByName(NameInput.Text)
        local targetSpeed = tonumber(SpeedInput.Text) or 50 -- Mặc định là 50 nếu gõ nhầm chữ
        
        if not targetPlayer then
            SpeedInput.PlaceholderText = "Không tìm thấy người này!"
            SpeedInput.Text = ""
            return
        end
        
        if targetPlayer == LocalPlayer then
            -- Nếu tự chỉnh bản thân thì quá đơn giản, chỉnh trực tiếp WalkSpeed luôn vì máy mình có quyền!
            local myHumanoid = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            myHumanoid = myHumanoid:FindFirstChildOfClass("Humanoid")
            if myHumanoid then myHumanoid.WalkSpeed = targetSpeed end
            SpeedInput.PlaceholderText = "Đã chỉnh tốc độ bản thân!"
            SpeedInput.Text = ""
            return
        end

        -- TROLL NGƯỜI KHÁC: Tạo thread đẩy lực liên tục trong 5 giây
        task.spawn(function()
            SpeedInput.PlaceholderText = "Đang ép tốc độ lên " .. targetPlayer.DisplayName
            local startTime = os.clock()
            
            while os.clock() - startTime < 5 do -- Tác dụng trong 5 giây
                local char = targetPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid then
                    -- Xóa BodyVelocity troll cũ nếu có
                    local oldV = hrp:FindFirstChild("TrollVelocity")
                    if oldV then oldV:Destroy() end
                    
                    -- Tạo lực đẩy dựa trên hướng di chuyển hiện tại của họ
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "TrollVelocity"
                    bv.MaxForce = Vector3.new(1e5, 0, 1e5) -- Chỉ đẩy theo trục ngang mặt đất
                    
                    if humanoid.MoveDirection.Magnitude > 0 then
                        -- Nếu họ đang đi, buff cho họ lao đi như tên bắn
                        bv.Velocity = humanoid.MoveDirection * targetSpeed
                    else
                        -- Nếu targetSpeed = 0 và họ đang đứng im, ghim chặt không cho họ đi
                        if targetSpeed == 0 then
                            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                    
                    bv.Parent = hrp
                else
                    break
                end
                task.wait(0.1) -- Cập nhật mỗi 0.1 giây
            end
            
            -- Dọn dẹp sau khi hết 5 giây troll
            local char = targetPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local oldV = hrp:FindFirstChild("TrollVelocity")
                if oldV then oldV:Destroy() end
            end
            SpeedInput.PlaceholderText = "Hết thời gian troll!"
        end)
        
        SpeedInput.Text = ""
    end
end)

return G2L["1"]
