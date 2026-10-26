if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("RockstarProUI") then
    playerGui.RockstarProUI:Destroy()
end

-- ==========================================
-- 1. TEMA WARNA
-- ==========================================
local Theme = {
    Background = Color3.fromRGB(22, 14, 10),
    Sidebar = Color3.fromRGB(15, 9, 6),
    Accent = Color3.fromRGB(255, 120, 0),
    Element = Color3.fromRGB(35, 22, 15),
    Text = Color3.fromRGB(230, 230, 230),
    TextDim = Color3.fromRGB(150, 150, 150)
}

-- ==========================================
-- 2. PEMBUATAN UI UTAMA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 380)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- 3. TOP BAR & SIDEBAR
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 150, 1, 0)
LogoText.Position = UDim2.new(0, 15, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "Rockstar Store"
LogoText.TextColor3 = Theme.Accent
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 18
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = TopBar

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, 0, 0, 1)
Separator.Position = UDim2.new(0, 0, 1, 0)
Separator.BackgroundColor3 = Color3.fromRGB(40, 25, 18)
Separator.BorderSizePixel = 0
Separator.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -41)
Sidebar.Position = UDim2.new(0, 0, 0, 41)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarPatch = Instance.new("Frame")
SidebarPatch.Size = UDim2.new(0, 10, 1, 0)
SidebarPatch.Position = UDim2.new(1, -10, 0, 0)
SidebarPatch.BackgroundColor3 = Theme.Sidebar
SidebarPatch.BorderSizePixel = 0
SidebarPatch.Parent = Sidebar

local MainTab = Instance.new("TextLabel")
MainTab.Size = UDim2.new(1, 0, 0, 40)
MainTab.Position = UDim2.new(0, 0, 0, 10)
MainTab.BackgroundTransparency = 1
MainTab.Text = "   Main"
MainTab.TextColor3 = Theme.Text
MainTab.Font = Enum.Font.GothamBold
MainTab.TextSize = 14
MainTab.TextXAlignment = Enum.TextXAlignment.Left
MainTab.Parent = Sidebar

local ActiveMarker = Instance.new("Frame")
ActiveMarker.Size = UDim2.new(0, 3, 0, 20)
ActiveMarker.Position = UDim2.new(0, 0, 0.5, -10)
ActiveMarker.BackgroundColor3 = Theme.Accent
ActiveMarker.BorderSizePixel = 0
ActiveMarker.Parent = MainTab

local AutoTab = Instance.new("TextLabel")
AutoTab.Size = UDim2.new(1, 0, 0, 40)
AutoTab.Position = UDim2.new(0, 0, 0, 50)
AutoTab.BackgroundTransparency = 1
AutoTab.Text = "   Automation"
AutoTab.TextColor3 = Theme.TextDim
AutoTab.Font = Enum.Font.Gotham
AutoTab.TextSize = 14
AutoTab.TextXAlignment = Enum.TextXAlignment.Left
AutoTab.Parent = Sidebar

-- ==========================================
-- 4. KONTEN UTAMA
-- ==========================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -160, 1, -51)
Content.Position = UDim2.new(0, 160, 0, 51)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local SectionTitle = Instance.new("TextLabel")
SectionTitle.Size = UDim2.new(1, 0, 0, 30)
SectionTitle.Position = UDim2.new(0, 10, 0, 0)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "Manage Cages & Base"
SectionTitle.TextColor3 = Theme.Text
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.TextSize = 16
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
SectionTitle.Parent = Content

local SectionMarker = Instance.new("Frame")
SectionMarker.Size = UDim2.new(0, 3, 0, 16)
SectionMarker.Position = UDim2.new(0, -10, 0.5, -8)
SectionMarker.BackgroundColor3 = Theme.Accent
SectionMarker.BorderSizePixel = 0
SectionMarker.Parent = SectionTitle

-- Baris Tombol Angkat Kandang
local RowFrame = Instance.new("Frame")
RowFrame.Size = UDim2.new(1, -30, 0, 45)
RowFrame.Position = UDim2.new(0, 10, 0, 40)
RowFrame.BackgroundColor3 = Theme.Element
RowFrame.BorderSizePixel = 0
RowFrame.Parent = Content
Instance.new("UICorner", RowFrame).CornerRadius = UDim.new(0, 6)

local RowLabel = Instance.new("TextLabel")
RowLabel.Size = UDim2.new(0.6, 0, 1, 0)
RowLabel.Position = UDim2.new(0, 15, 0, 0)
RowLabel.BackgroundTransparency = 1
RowLabel.Text = "Auto Lift & Bring to Base"
RowLabel.TextColor3 = Theme.Text
RowLabel.Font = Enum.Font.GothamBold
RowLabel.TextSize = 13
RowLabel.TextXAlignment = Enum.TextXAlignment.Left
RowLabel.Parent = RowFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleBtn.Position = UDim2.new(1, -90, 0.5, -15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 25)
ToggleBtn.TextColor3 = Theme.TextDim
ToggleBtn.Text = "OFF"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = RowFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 5. LOGIKA ANGKAT & BAWA KANDANG KE BASE
-- ==========================================
local autoLiftActive = false

ToggleBtn.MouseButton1Click:Connect(function()
    autoLiftActive = not autoLiftActive
    if autoLiftActive then
        ToggleBtn.Text = "ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.BackgroundColor3 = Theme.Accent
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = Theme.TextDim
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 25)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if autoLiftActive then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    -- Target jalur kandang di map Anda
                    local pathsFolder = workspace:FindFirstChild("Paths")
                    local path20 = pathsFolder and pathsFolder:FindFirstChild("Path20")
                    local cages = path20 and path20:FindFirstChild("Cages")
                    
                    if cages then
                        for _, cage in pairs(cages:GetChildren()) do
                            if not autoLiftActive then break end
                            
                            local rootPart = cage:FindFirstChild("Root") or cage:FindFirstChildWhichIsA("BasePart")
                            
                            if rootPart then
                                -- Pindahkan posisi kandang langsung mengikuti posisi karakter / base Anda
                                rootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                            end
                        end
                    end
                end
            end)
        end
    end
end)
