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
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
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
Title.Text = "Scanner Auto-Save (Ke Notepad)"
Title.Parent = MainFrame

local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(1, -40, 0, 50)
ScanButton.Position = UDim2.new(0, 20, 0, 60)
ScanButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.Font = Enum.Font.GothamBold
ScanButton.TextSize = 14
ScanButton.Text = "Mulai Scan & Simpan File .txt"
ScanButton.Parent = MainFrame
Instance.new("UICorner", ScanButton).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 100)
StatusLabel.Position = UDim2.new(0, 20, 0, 130)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.TextWrapped = true
StatusLabel.Text = "Tekan tombol di atas. Hasil akan otomatis tersimpan jadi file Notepad di PC Anda."
StatusLabel.Parent = MainFrame

ScanButton.MouseButton1Click:Connect(function()
    ScanButton.Text = "Scanning Map..."
    StatusLabel.Text = "Mohon tunggu sebentar..."
    task.wait(0.1)
    
    local count = 0
    local finalResult = "=== HASIL SCAN MAP (ROCKSTARSCRIPT) ===\n\n"
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            count = count + 1
            finalResult = finalResult .. "[" .. count .. "] PATH: " .. obj:GetFullName() .. "\n"
        end
    end
    
    finalResult = finalResult .. "\n=== TOTAL DITEMUKAN: " .. count .. " PROMPT ==="

    -- Fitur ajaib untuk PC Executor: Langsung tulis ke file!
    if writefile then
        local success, err = pcall(function()
            writefile("HasilScanMap.txt", finalResult)
        end)
        
        if success then
            StatusLabel.Text = "✅ BERHASIL!\nCek folder instalasi Delta Anda.\nBuka folder bernama 'workspace'.\nDi dalamnya ada file 'HasilScanMap.txt'."
            ScanButton.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
        else
            StatusLabel.Text = "❌ Gagal menulis file: " .. tostring(err)
        end
    else
        StatusLabel.Text = "❌ Executor Anda tidak mendukung fitur writefile()."
    end
    
    ScanButton.Text = "Scan Selesai!"
end)
