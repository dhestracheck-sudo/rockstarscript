if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Hapus UI lama jika ada (otomatis menghentikan loop lama)
if playerGui:FindFirstChild("RockstarProUI") then
    playerGui.RockstarProUI:Destroy()
end

-- ==========================================
-- 1. TEMA WARNA (DARK ORANGE)
-- ==========================================
local Theme = {
    Background = Color3.fromRGB(22, 14, 10),
    Sidebar = Color3.fromRGB(15, 9, 6),
    Accent = Color3.fromRGB(255, 120, 0),
    Element = Color3.fromRGB(35, 22, 15),
    ElementHover = Color3.fromRGB(45, 30, 20),
    ButtonOff = Color3.fromRGB(50, 35, 25),
    Text = Color3.fromRGB(230, 230, 230),
    TextDim = Color3.fromRGB(150, 150, 150)
}

-- ==========================================
-- 2. PEMBUATAN UI UTAMA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 380)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- 3. TOP BAR & DRAG SYSTEM
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 200, 1, 0)
LogoText.Position = UDim2.new(0, 15, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "Rockstar Store"
LogoText.TextColor3 = Theme.Accent
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 18
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = TopBar

-- Tombol Minimize (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 26)
MinBtn.Position = UDim2.new(1, -75, 0.5, -13)
MinBtn.BackgroundColor3 = Theme.Element
MinBtn.Text = "-"
MinBtn.TextColor3 = Theme.Text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 26)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, 0, 0, 1)
Separator.Position = UDim2.new(0, 0, 1, 0)
Separator.BackgroundColor3 = Color3.fromRGB(40, 25, 18)
Separator.BorderSizePixel = 0
Separator.Parent = TopBar

-- Sistem Drag Modern (Menggantikan .Draggable yang deprecated)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Fungsi Minimize & Close
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 600, 0, 40) or UDim2.new(0, 600, 0, 380)
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Shortcut RightControl untuk Hide/Show UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ==========================================
-- 4. SIDEBAR & SISTEM TAB
-- ==========================================
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

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -160, 1, -51)
ContentContainer.Position = UDim2.new(0, 160, 0, 51)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local function createTab(name, yPos, isDefault)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.Position = UDim2.new(0, 0, 0, yPos)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "   " .. name
    TabBtn.TextColor3 = isDefault and Theme.Text or Theme.TextDim
    TabBtn.Font = isDefault and Enum.Font.GothamBold or Enum.Font.Gotham
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar

    local Marker = Instance.new("Frame")
    Marker.Size = UDim2.new(0, 3, 0, 20)
    Marker.Position = UDim2.new(0, 0, 0.5, -10)
    Marker.BackgroundColor3 = Theme.Accent
    Marker.BorderSizePixel = 0
    Marker.Visible = isDefault
    Marker.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = isDefault
    Page.Parent = ContentContainer

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = Page

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 15)
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.Parent = Page

    return TabBtn, Marker, Page
end

local MainTabBtn, MainMarker, MainPage = createTab("Main", 10, true)
local AutoTabBtn, AutoMarker, AutoPage = createTab("Settings", 50, false)

local function switchTab(activeBtn, activeMarker, activePage)
    for _, data in pairs({
        {MainTabBtn, MainMarker, MainPage},
        {AutoTabBtn, AutoMarker, AutoPage}
    }) do
        local isSelected = (data[1] == activeBtn)
        data[1].TextColor3 = isSelected and Theme.Text or Theme.TextDim
        data[1].Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
        data[2].Visible = isSelected
        data[3].Visible = isSelected
    end
end

MainTabBtn.MouseButton1Click:Connect(function() switchTab(MainTabBtn, MainMarker, MainPage) end)
AutoTabBtn.MouseButton1Click:Connect(function() switchTab(AutoTabBtn, AutoMarker, AutoPage) end)

-- ==========================================
-- 5. KOMPONEN UI HELPER
-- ==========================================
local function createSectionTitle(parent, titleText, order)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 28)
    Holder.BackgroundTransparency = 1
    Holder.LayoutOrder = order
    Holder.Parent = parent

    local Marker = Instance.new("Frame")
    Marker.Size = UDim2.new(0, 3, 0, 16)
    Marker.Position = UDim2.new(0, 0, 0.5, -8)
    Marker.BackgroundColor3 = Theme.Accent
    Marker.BorderSizePixel = 0
    Marker.Parent = Holder

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -12, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Holder
end

local function createToggleRow(parent, labelText, defaultState, order, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 45)
    RowFrame.BackgroundColor3 = Theme.Element
    RowFrame.BorderSizePixel = 0
    RowFrame.LayoutOrder = order
    RowFrame.Parent = parent
    Instance.new("UICorner", RowFrame).CornerRadius = UDim.new(0, 6)

    local RowLabel = Instance.new("TextLabel")
    RowLabel.Size = UDim2.new(0.65, 0, 1, 0)
    RowLabel.Position = UDim2.new(0, 15, 0, 0)
    RowLabel.BackgroundTransparency = 1
    RowLabel.Text = labelText
    RowLabel.TextColor3 = Theme.Text
    RowLabel.Font = Enum.Font.GothamBold
    RowLabel.TextSize = 13
    RowLabel.TextXAlignment = Enum.TextXAlignment.Left
    RowLabel.Parent = RowFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -90, 0.5, -15)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 13
    ToggleBtn.Parent = RowFrame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

    local state = defaultState
    local function updateVisual()
        if state then
            ToggleBtn.Text = "ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.BackgroundColor3 = Theme.Accent
        else
            ToggleBtn.Text = "OFF"
            ToggleBtn.TextColor3 = Theme.TextDim
            ToggleBtn.BackgroundColor3 = Theme.ButtonOff
        end
    end
    updateVisual()

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        callback(state)
    end)
end

-- ==========================================
-- 6. KONFIGURASI & ELEMEN FITUR
-- ==========================================
local Config = {
    AutoFarm = false,
    ScanAllPaths = false,      -- Jika true, memindai semua folder di dalam Paths
    TeleportPlayerMode = false,-- Jika true, karakter ikut teleport ke kandang lalu balik ke Base
    SavedBaseCFrame = nil
}

-- Halaman Main
createSectionTitle(MainPage, "Auto Steal & Teleport Cage", 1)

createToggleRow(MainPage, "Auto Steal & Teleport to Base", false, 2, function(val)
    Config.AutoFarm = val
    if val then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            Config.SavedBaseCFrame = hrp.CFrame
        end
    end
end)

createToggleRow(MainPage, "Teleport Karakter ke Kandang (Bypass Jarak Server)", false, 3, function(val)
    Config.TeleportPlayerMode = val
end)

-- Halaman Settings
createSectionTitle(AutoPage, "Farm Configuration", 1)

createToggleRow(AutoPage, "Scan Semua Folder Path (Bukan Hanya Path20)", false, 2, function(val)
    Config.ScanAllPaths = val
end)

-- Tombol Set Base Manual di halaman Settings
local SetBaseRow = Instance.new("Frame")
SetBaseRow.Size = UDim2.new(1, 0, 0, 45)
SetBaseRow.BackgroundColor3 = Theme.Element
SetBaseRow.BorderSizePixel = 0
SetBaseRow.LayoutOrder = 3
SetBaseRow.Parent = AutoPage
Instance.new("UICorner", SetBaseRow).CornerRadius = UDim.new(0, 6)

local SetBaseLabel = Instance.new("TextLabel")
SetBaseLabel.Size = UDim2.new(0.6, 0, 1, 0)
SetBaseLabel.Position = UDim2.new(0, 15, 0, 0)
SetBaseLabel.BackgroundTransparency = 1
SetBaseLabel.Text = "Simpan Lokasi Base Saat Ini"
SetBaseLabel.TextColor3 = Theme.Text
SetBaseLabel.Font = Enum.Font.GothamBold
SetBaseLabel.TextSize = 13
SetBaseLabel.TextXAlignment = Enum.TextXAlignment.Left
SetBaseLabel.Parent = SetBaseRow

local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(0, 80, 0, 30)
SetBaseBtn.Position = UDim2.new(1, -90, 0.5, -15)
SetBaseBtn.BackgroundColor3 = Theme.Accent
SetBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBaseBtn.Text = "SET"
SetBaseBtn.Font = Enum.Font.GothamBold
SetBaseBtn.TextSize = 13
SetBaseBtn.Parent = SetBaseRow
Instance.new("UICorner", SetBaseBtn).CornerRadius = UDim.new(0, 6)

SetBaseBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        Config.SavedBaseCFrame = hrp.CFrame
        SetBaseBtn.Text = "SAVED!"
        task.wait(1)
        if SetBaseBtn.Parent then
            SetBaseBtn.Text = "SET"
        end
    end
end)

-- ==========================================
-- 7. LOGIKA UTAMA AUTO FARM
-- ==========================================
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    prompt.MaxActivationDistance = 999999
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false

    if typeof(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait()
        prompt:InputHoldEnd()
    end
end

local function getTargetCages()
    local cageList = {}
    local pathsFolder = workspace:FindFirstChild("Paths")
    if not pathsFolder then return cageList end

    if Config.ScanAllPaths then
        for _, pathFolder in ipairs(pathsFolder:GetChildren()) do
            local cages = pathFolder:FindFirstChild("Cages")
            if cages then
                for _, cage in ipairs(cages:GetChildren()) do
                    table.insert(cageList, cage)
                end
            end
        end
    else
        local path20 = pathsFolder:FindFirstChild("Path20")
        local cages = path20 and path20:FindFirstChild("Cages")
        if cages then
            for _, cage in ipairs(cages:GetChildren()) do
                table.insert(cageList, cage)
            end
        end
    end

    return cageList
end

task.spawn(function()
    -- Loop otomatis berhenti jika ScreenGui di-destroy
    while ScreenGui.Parent do
        task.wait(0.25)
        if Config.AutoFarm then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                if not Config.SavedBaseCFrame then
                    Config.SavedBaseCFrame = hrp.CFrame
                end

                local cages = getTargetCages()
                for _, cage in ipairs(cages) do
                    if not Config.AutoFarm or not ScreenGui.Parent then break end

                    local rootPart = cage:FindFirstChild("Root")
                    local stealPrompt = rootPart and (rootPart:FindFirstChild("StealPrompt") or rootPart:FindFirstChildWhichIsA("ProximityPrompt", true))

                    if rootPart and rootPart:IsA("BasePart") and stealPrompt and stealPrompt.Enabled then
                        if Config.TeleportPlayerMode then
                            -- Opsi 1: Teleport karakter ke kandang, ambil, lalu kembali ke Base
                            hrp.CFrame = rootPart.CFrame * CFrame.new(0, 3, 0)
                            task.wait(0.1)
                            triggerPrompt(stealPrompt)
                            task.wait(0.05)
                            hrp.CFrame = Config.SavedBaseCFrame
                        else
                            -- Opsi 2: Tarik kandang ke posisi karakter & picu prompt dari jauh
                            rootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)
                            triggerPrompt(stealPrompt)
                        end
                    end
                end
            end)
        end
    end
end)
