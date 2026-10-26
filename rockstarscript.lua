if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Hapus UI lama jika script dijalankan ulang
local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("RockstarNativeUI") then
    coreGui.RockstarNativeUI:Destroy()
end

-- Membuat ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarNativeUI"
ScreenGui.Parent = coreGui

-- Membuat Tombol Melayang (Floating Toggle Button)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 45)
ToggleButton.Position = UDim2.new(0, 40, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Auto Farm: OFF"
ToggleButton.Draggable = true -- Tombol bisa digeser-geser di layar
ToggleButton.Active = true
ToggleButton.Parent = ScreenGui

-- Desain sudut tombol melengkung rapi
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleButton

local autoFarmActive = false

-- Fungsi tombol ketika diklik
ToggleButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        ToggleButton.Text = "Auto Farm: ON (Black Hole)"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 160, 80)
    else
        ToggleButton.Text = "Auto Farm: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
end)

-- Logika Utama Auto Farm Khusus Zona Black Hole
task.spawn(function()
    while true do
        task.wait(0.1)
        if autoFarmActive then
            pcall(function()
                local player = game.Players.LocalPlayer
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    for _, prompt in pairs(workspace:GetDescendants()) do
                        if not autoFarmActive then break end
                        
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            -- Validasi wajib berada di dalam zona Black Hole
                            local isInBlackHole = false
                            local currentParent = prompt.Parent
                            
                            while currentParent and currentParent ~= workspace do
                                local nameLower = string.lower(currentParent.Name)
                                if string.find(nameLower, "black") or string.find(nameLower, "hole") then
                                    isInBlackHole = true
                                    break
                                end
                                currentParent = currentParent.Parent
                            end
                            
                            -- Jika di zona Black Hole, teleport dan eksekusi
                            if isInBlackHole then
                                local targetPart = prompt.Parent
                                if targetPart and targetPart:IsA("Attachment") then
                                    targetPart = targetPart.Parent
                                end
                                
                                if targetPart and targetPart:IsA("BasePart") then
                                    hrp.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                                    task.wait(0.05)
                                    fireproximityprompt(prompt)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
