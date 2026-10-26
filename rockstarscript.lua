if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Bersihkan UI sebelumnya jika ada
if playerGui:FindFirstChild("RockstarScannerUI") then
    playerGui.RockstarScannerUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarScannerUI"
ScreenGui.ResetOnSpawn = false -- Agar UI tidak hilang kalau karakter mati
ScreenGui.Parent = playerGui

-- Panel Utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Text = "Scanner Log (PlayerGui Version)"
Title.Parent = MainFrame

local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(1, -20, 0, 40)
ScanButton.Position = UDim2.new(0, 10, 0, 40)
ScanButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.Font = Enum.Font.GothamBold
ScanButton.TextSize = 14
ScanButton.Text = "Mulai Scan"
ScanButton.Parent = MainFrame
Instance.new("UICorner", ScanButton).CornerRadius = UDim.new(0, 6)

-- Area Scroll untuk Hasil Scan
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -100)
ScrollFrame.Position = UDim2.new(0, 10, 0, 90)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = MainFrame
Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 6)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

ScanButton.MouseButton1Click:Connect(function()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    ScanButton.Text = "Scanning..."
    task.wait(0.1)
    
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            count = count + 1
            
            local resultLabel = Instance.new("TextLabel")
            resultLabel.Size = UDim2.new(1, -10, 0, 30)
            resultLabel.BackgroundTransparency = 1
            resultLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            resultLabel.Font = Enum.Font.Code
            resultLabel.TextSize = 12
            resultLabel.TextXAlignment = Enum.TextXAlignment.Left
            resultLabel.TextWrapped = true
            resultLabel.Text = "[" .. count .. "] " .. obj:GetFullName()
            resultLabel.Parent = ScrollFrame
        end
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 35)
    ScanButton.Text = "Scan Selesai! (" .. count .. " Prompt Ditemukan)"
end)
