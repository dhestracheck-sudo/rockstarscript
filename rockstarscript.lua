if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("RockstarScannerUI") then
    playerGui.RockstarScannerUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarScannerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
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
Title.Text = "Scanner Log (Auto Copy)"
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
        if child:IsA("Frame") then child:Destroy() end
    end

    ScanButton.Text = "Scanning..."
    task.wait(0.1)
    
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            count = count + 1
            
            -- Buat baris (Row) untuk menampung Teks dan Tombol Copy
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, -10, 0, 40)
            Row.BackgroundTransparency = 1
            Row.Parent = ScrollFrame

            -- Kolom Teks Path
            local resultBox = Instance.new("TextBox")
            resultBox.Size = UDim2.new(1, -80, 1, 0)
            resultBox.BackgroundTransparency = 1
            resultBox.TextColor3 = Color3.fromRGB(150, 255, 150)
            resultBox.Font = Enum.Font.Code
            resultBox.TextSize = 11
            resultBox.TextXAlignment = Enum.TextXAlignment.Left
            resultBox.TextWrapped = true
            resultBox.ClearTextOnFocus = false
            resultBox.TextEditable = true -- Dibuat true agar bisa diblok manual jika perlu
            resultBox.Text = "[" .. count .. "] " .. obj:GetFullName()
            resultBox.Parent = Row

            -- Tombol Auto Copy
            local CopyBtn = Instance.new("TextButton")
            CopyBtn.Size = UDim2.new(0, 70, 0, 30)
            CopyBtn.Position = UDim2.new(1, -70, 0, 5)
            CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
            CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            CopyBtn.Font = Enum.Font.GothamBold
            CopyBtn.TextSize = 12
            CopyBtn.Text = "COPY"
            CopyBtn.Parent = Row
            Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)

            -- Logika saat tombol copy ditekan
            CopyBtn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(obj:GetFullName())
                    CopyBtn.Text = "COPIED!"
                    CopyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    task.wait(1.5)
                    CopyBtn.Text = "COPY"
                    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
                else
                    CopyBtn.Text = "Gagal"
                end
            end)
        end
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 45)
    ScanButton.Text = "Scan Selesai! (" .. count .. " Prompt Ditemukan)"
end)
