-- Xóa UI cũ nếu có
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("InstantHarvestUI") then
    CoreGui.InstantHarvestUI:Destroy()
end

-- Khai báo dịch vụ hệ thống
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Khởi tạo UI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InstantHarvestUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 130)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "⚡ INSTANT HARVEST v4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
ToggleBtn.Text = "AUTO HARVEST: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

--- LOGIC KÍCH HOẠT SIÊU TỐC ---
local IsEnabled = false

ToggleBtn.MouseButton1Click:Connect(function()
    IsEnabled = not IsEnabled
    if IsEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
        ToggleBtn.Text = "AUTO HARVEST: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        ToggleBtn.Text = "AUTO HARVEST: OFF"
    end
end)

-- Hàm tối ưu hóa việc nhấn nút
local function executePrompt(prompt)
    -- Nếu Executor hỗ trợ hàm kích hoạt nhanh độc quyền
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        -- Phương án dự phòng thủ công nhưng không gây delay hàng đợi
        task.spawn(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration)
            prompt:InputHoldEnd()
        end)
    end
end

-- CƠ CHẾ 1: Đón đầu - Vừa đi tới hiện UI lên là nổ nút ngay lập tức
ProximityPromptService.PromptShown:Connect(function(prompt)
    if IsEnabled then
        if prompt.ActionText == "Harvest" or string.find(prompt.ActionText, "Harvest") then
            executePrompt(prompt)
        end
    end
end)

-- CƠ CHẾ 2: Quét quét thông minh vùng lân cận (Bán kính gần nhân vật)
-- Giải quyết trường hợp bạn đang đứng sẵn ở bụi cây rồi mới bấm nút BẬT hack
task.spawn(function()
    while true do
        task.wait(0.1) -- Quét liên tục mỗi 0.1 giây cực nhẹ
        if IsEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, object in ipairs(workspace:GetDescendants()) do
                    if not IsEnabled then break end
                    if object:IsA("ProximityPrompt") and (object.ActionText == "Harvest" or string.find(object.ActionText, "Harvest")) then
                        local parentPart = object.Parent
                        if parentPart and parentPart:IsA("BasePart") then
                            -- Chỉ xử lý nếu khoảng cách từ bạn tới quả nhỏ hơn khoảng cách kích hoạt của game
                            local distance = (root.Position - parentPart.Position).Magnitude
                            if distance <= object.MaxActivationDistance then
                                executePrompt(object)
                            end
                        end
                    end
                end
            end
        end
    end
end)
