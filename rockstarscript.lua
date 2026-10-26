-- ============================================================================
-- ★ ROCKSTAR HUB (BLUE EDITION) - BREAK AND STEAL AN EGG
-- UI Replica (Lynx-Style Layout in Electric Blue) + Map Specific Features
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Hapus UI lama jika ada
if PlayerGui:FindFirstChild("RockstarBlueHub") then
    PlayerGui.RockstarBlueHub:Destroy()
end

-- ============================================================================
-- DATA & CONFIG
-- ============================================================================
local Config = {
    SelectedZone = "All Zones",
    SelectedEgg = "All Eggs",
    SelectedRarity = "Void, Omega, Inferno",
    MinAnimalSize = "0",
    MinCashPerSec = "200B",
    AutoBreakAndSteal = false,
    AutoStealAnimals = false,
    HelpFriendDrop = false,
    AutoSpeedTreadmill = false,
    AutoSwingPickaxe = false,
    AutoUpgradePlot = false,
    AutoUpgradeTreadmill = false,
    AutoHalloweenCandy = false,
    SelectedPickaxe = "21: Haunted Pickaxe",
    WebhookURL = "",
    AntiAFK = true
}

local ZoneList = {
    "All Zones",
    "Zone 1 - Chicken (-157, 3, -17)",
    "Zone 2 - Sphinx (-247, 3, -40)",
    "Zone 3 - Ice Yeti (-397, 3, -24)",
    "Zone 4 - Emerald Serpent (-504, 3, -19)",
    "Zone 5 - Woolly Mammoth (-784, 3, -2)",
    "Zone 6 - Redshell Crab (-1201, 3, 25)",
    "Zone 7 - Mole Titan (-1626, 3, -26)",
    "Zone 8 - Griffin (-2119, 3, 37)",
    "Zone 9 - 3Hydra (-2712, 3, 25)",
    "Zone 10 - Alien Guardian (-3237, 3, 2)",
    "Zone 11 - Haunted Graveyard (-3998, 4, 32)"
}

local ZoneCoordinates = {
    ["Zone 1 - Chicken (-157, 3, -17)"] = Vector3.new(-157.1, 4.5, -17.8),
    ["Zone 2 - Sphinx (-247, 3, -40)"] = Vector3.new(-247.3, 4.5, -40.9),
    ["Zone 3 - Ice Yeti (-397, 3, -24)"] = Vector3.new(-397.8, 4.5, -24.1),
    ["Zone 4 - Emerald Serpent (-504, 3, -19)"] = Vector3.new(-504.9, 4.5, -19.1),
    ["Zone 5 - Woolly Mammoth (-784, 3, -2)"] = Vector3.new(-784.6, 4.5, -2.9),
    ["Zone 6 - Redshell Crab (-1201, 3, 25)"] = Vector3.new(-1201.4, 4.5, 25.6),
    ["Zone 7 - Mole Titan (-1626, 3, -26)"] = Vector3.new(-1626.7, 4.5, -26.9),
    ["Zone 8 - Griffin (-2119, 3, 37)"] = Vector3.new(-2119.7, 4.5, 37.6),
    ["Zone 9 - 3Hydra (-2712, 3, 25)"] = Vector3.new(-2712.9, 4.5, 25.0),
    ["Zone 10 - Alien Guardian (-3237, 3, 2)"] = Vector3.new(-3237.8, 4.5, 2.6),
    ["Zone 11 - Haunted Graveyard (-3998, 4, 32)"] = Vector3.new(-3998.7, 5.0, 32.3)
}

local PickaxeList = {
    "1: Wooden Pickaxe", "2: Stone Pickaxe", "3: Iron Pickaxe",
    "4: Golden Pickaxe", "5: Diamond Pickaxe", "6: Strawberry Pickaxe",
    "7: Cactus Pickaxe", "8: Lightning Pickaxe", "9: Candy Pickaxe",
    "10: Rainbow Pickaxe", "11: Crystal Pickaxe", "12: Demon Pickaxe",
    "13: Hacker Pickaxe", "14: Ufo Pickaxe", "15: Secret Pickaxe",
    "16: Cool Pickaxe", "17: Galaxy Pickaxe", "18: Celestial Pickaxe",
    "19: Sci Fi Pickaxe", "20: Enchanted Pickaxe", "21: Haunted Pickaxe"
}

-- ============================================================================
-- WARNA TEMA ROCKSTAR BIRU (PERSIS GAYA LYNX TAPI BIRU)
-- ============================================================================
local Theme = {
    MainBg = Color3.fromRGB(10, 15, 26),
    TopBg = Color3.fromRGB(12, 18, 30),
    SidebarBg = Color3.fromRGB(11, 16, 28),
    TabActiveBg = Color3.fromRGB(18, 32, 58),
    ControlBg = Color3.fromRGB(16, 26, 46),
    ControlHover = Color3.fromRGB(22, 36, 64),
    InfoBoxBg = Color3.fromRGB(14, 22, 38),
    Accent = Color3.fromRGB(0, 150, 255),
    AccentBright = Color3.fromRGB(55, 185, 255),
    Border = Color3.fromRGB(28, 52, 90),
    TextWhite = Color3.fromRGB(242, 247, 255),
    TextMuted = Color3.fromRGB(155, 175, 205)
}

-- ============================================================================
-- PEMBUATAN BASE UI
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarBlueHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.BackgroundTransparency = 0.04
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.2

-- ============================================================================
-- TOPBAR (Rockstar | Break and Steal an Egg | discord.gg/rockstar | —)
-- ============================================================================
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.TopBg
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0

local TopDivider = Instance.new("Frame", TopBar)
TopDivider.Size = UDim2.new(1, 0, 0, 1)
TopDivider.Position = UDim2.new(0, 0, 1, -1)
TopDivider.BackgroundColor3 = Theme.Border
TopDivider.BorderSizePixel = 0

-- Brand "Rockstar"
local BrandTitle = Instance.new("TextLabel", TopBar)
BrandTitle.Size = UDim2.new(0, 95, 1, 0)
BrandTitle.Position = UDim2.new(0, 16, 0, 0)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "Rockstar"
BrandTitle.TextColor3 = Theme.Accent
BrandTitle.Font = Enum.Font.GothamBlack
BrandTitle.TextSize = 20
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Planet/Star Icon
local PlanetIcon = Instance.new("TextLabel", TopBar)
PlanetIcon.Size = UDim2.new(0, 26, 1, 0)
PlanetIcon.Position = UDim2.new(0, 112, 0, 0)
PlanetIcon.BackgroundTransparency = 1
PlanetIcon.Text = "🪐"
PlanetIcon.TextColor3 = Theme.Accent
PlanetIcon.Font = Enum.Font.GothamBold
PlanetIcon.TextSize = 16

-- Vertical Pipe
local Pipe1 = Instance.new("Frame", TopBar)
Pipe1.Size = UDim2.new(0, 1, 0, 20)
Pipe1.Position = UDim2.new(0, 144, 0.5, -10)
Pipe1.BackgroundColor3 = Theme.Border
Pipe1.BorderSizePixel = 0

-- Nama Game
local GameTitle = Instance.new("TextLabel", TopBar)
GameTitle.Size = UDim2.new(0, 240, 1, 0)
GameTitle.Position = UDim2.new(0, 156, 0, 0)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "Break and Steal an Egg"
GameTitle.TextColor3 = Theme.TextWhite
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 14
GameTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Link Kanan Atas
local DiscordLabel = Instance.new("TextLabel", TopBar)
DiscordLabel.Size = UDim2.new(0, 180, 1, 0)
DiscordLabel.Position = UDim2.new(1, -235, 0, 0)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "💎  |  rockstar.hub/blue"
DiscordLabel.TextColor3 = Theme.Accent
DiscordLabel.Font = Enum.Font.GothamBold
DiscordLabel.TextSize = 13
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Tombol Minimize (—)
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -44, 0.5, -16)
MinBtn.BackgroundColor3 = Theme.ControlBg
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Accent
MinBtn.Font = Enum.Font.GothamBlack
MinBtn.TextSize = 15
MinBtn.AutoButtonColor = false
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = Theme.Border
MinStroke.Thickness = 1

-- ============================================================================
-- SIDEBAR KIRI (SEARCH BAR + DAFTAR MENU)
-- ============================================================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 190, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.BackgroundColor3 = Theme.SidebarBg
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0

-- Search Bar Box
local SearchFrame = Instance.new("Frame", Sidebar)
SearchFrame.Size = UDim2.new(1, -20, 0, 36)
SearchFrame.Position = UDim2.new(0, 10, 0, 12)
SearchFrame.BackgroundColor3 = Theme.ControlBg
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)
local SearchStroke = Instance.new("UIStroke", SearchFrame)
SearchStroke.Color = Theme.Border
SearchStroke.Thickness = 1

local SearchIcon = Instance.new("TextLabel", SearchFrame)
SearchIcon.Size = UDim2.new(0, 28, 1, 0)
SearchIcon.Position = UDim2.new(0, 6, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = Theme.TextMuted
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.TextSize = 13

local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1, -38, 1, 0)
SearchBox.Position = UDim2.new(0, 34, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Search feature..."
SearchBox.PlaceholderColor3 = Theme.TextMuted
SearchBox.Text = ""
SearchBox.TextColor3 = Theme.TextWhite
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false

-- Daftar Tab Container
local TabListFrame = Instance.new("ScrollingFrame", Sidebar)
TabListFrame.Size = UDim2.new(1, -20, 1, -64)
TabListFrame.Position = UDim2.new(0, 10, 0, 56)
TabListFrame.BackgroundTransparency = 1
TabListFrame.BorderSizePixel = 0
TabListFrame.ScrollBarThickness = 0
TabListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local TabListLayout = Instance.new("UIListLayout", TabListFrame)
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ============================================================================
-- AREA KONTEN KANAN
-- ============================================================================
local RightArea = Instance.new("Frame", MainFrame)
RightArea.Size = UDim2.new(1, -200, 1, -48)
RightArea.Position = UDim2.new(0, 195, 0, 48)
RightArea.BackgroundTransparency = 1

-- Header Judul Bagian Kanan (Garis Biru Vertikal + Nama Tab)
local SectionHeader = Instance.new("Frame", RightArea)
SectionHeader.Size = UDim2.new(1, -16, 0, 40)
SectionHeader.Position = UDim2.new(0, 4, 0, 6)
SectionHeader.BackgroundTransparency = 1

local BlueAccentBar = Instance.new("Frame", SectionHeader)
BlueAccentBar.Size = UDim2.new(0, 4, 0, 22)
BlueAccentBar.Position = UDim2.new(0, 0, 0.5, -11)
BlueAccentBar.BackgroundColor3 = Theme.Accent
BlueAccentBar.BorderSizePixel = 0
Instance.new("UICorner", BlueAccentBar).CornerRadius = UDim.new(1, 0)

local ActiveTabTitle = Instance.new("TextLabel", SectionHeader)
ActiveTabTitle.Size = UDim2.new(1, -20, 1, 0)
ActiveTabTitle.Position = UDim2.new(0, 14, 0, 0)
ActiveTabTitle.BackgroundTransparency = 1
ActiveTabTitle.Text = "Main"
ActiveTabTitle.TextColor3 = Theme.TextWhite
ActiveTabTitle.Font = Enum.Font.GothamBold
ActiveTabTitle.TextSize = 17
ActiveTabTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeaderBottomLine = Instance.new("Frame", SectionHeader)
HeaderBottomLine.Size = UDim2.new(1, 0, 0, 1)
HeaderBottomLine.Position = UDim2.new(0, 0, 1, -1)
HeaderBottomLine.BackgroundColor3 = Theme.Border
HeaderBottomLine.BorderSizePixel = 0

local PagesFolder = Instance.new("Frame", RightArea)
PagesFolder.Size = UDim2.new(1, -12, 1, -56)
PagesFolder.Position = UDim2.new(0, 4, 0, 50)
PagesFolder.BackgroundTransparency = 1

-- ============================================================================
-- SISTEM DRAG & MINIMIZE
-- ============================================================================
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
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    local target = isMin and UDim2.new(0, 650, 0, 48) or UDim2.new(0, 650, 0, 420)
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = target}):Play()
end)

-- ============================================================================
-- PEMBUAT TAB & KOMPONEN BERGAYA LYNX (VERSI BIRU)
-- ============================================================================
local AllTabs = {}
local SearchableRows = {}
local FirstTab = true

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", TabListFrame)
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.BackgroundColor3 = Theme.TabActiveBg
    TabBtn.BackgroundTransparency = FirstTab and 0 or 1
    TabBtn.Text = ""
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    local IconLbl = Instance.new("TextLabel", TabBtn)
    IconLbl.Size = UDim2.new(0, 30, 1, 0)
    IconLbl.Position = UDim2.new(0, 8, 0, 0)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text = icon
    IconLbl.TextColor3 = FirstTab and Theme.Accent or Theme.TextMuted
    IconLbl.Font = Enum.Font.GothamBold
    IconLbl.TextSize = 16

    local NameLbl = Instance.new("TextLabel", TabBtn)
    NameLbl.Size = UDim2.new(1, -44, 1, 0)
    NameLbl.Position = UDim2.new(0, 42, 0, 0)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = name
    NameLbl.TextColor3 = FirstTab and Theme.TextWhite or Theme.TextMuted
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 14
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local Page = Instance.new("ScrollingFrame", PagesFolder)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = FirstTab
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local PagePad = Instance.new("UIPadding", Page)
    PagePad.PaddingRight = UDim.new(0, 8)
    PagePad.PaddingBottom = UDim.new(0, 12)

    FirstTab = false
    table.insert(AllTabs, {Btn = TabBtn, Icon = IconLbl, Label = NameLbl, Page = Page, Name = name})

    TabBtn.MouseButton1Click:Connect(function()
        ActiveTabTitle.Text = name
        for _, t in ipairs(AllTabs) do
            t.Page.Visible = false
            t.Btn.BackgroundTransparency = 1
            t.Icon.TextColor3 = Theme.TextMuted
            t.Label.TextColor3 = Theme.TextMuted
        end
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0
        IconLbl.TextColor3 = Theme.Accent
        NameLbl.TextColor3 = Theme.TextWhite
    end)

    local Components = {}

    -- Kotak Deskripsi Informasi (Persis di bagian atas gambar)
    function Components:AddInfoBox(text)
        local Box = Instance.new("Frame", Page)
        Box.Size = UDim2.new(1, 0, 0, 68)
        Box.BackgroundColor3 = Theme.InfoBoxBg
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
        local Stroke = Instance.new("UIStroke", Box)
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1

        local Lbl = Instance.new("TextLabel", Box)
        Lbl.Size = UDim2.new(1, -24, 1, -16)
        Lbl.Position = UDim2.new(0, 12, 0, 8)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Theme.TextMuted
        Lbl.Font = Enum.Font.GothamMedium
        Lbl.TextSize = 12
        Lbl.TextWrapped = true
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.TextYAlignment = Enum.TextYAlignment.Top
    end

    -- Baris Dropdown Kanan (Persis gambar: Label di kiri, Box + Panah Biru di kanan)
    function Components:AddDropdown(labelText, options, defaultVal, callback)
        local Row = Instance.new("Frame", Page)
        Row.Size = UDim2.new(1, 0, 0, 38)
        Row.BackgroundTransparency = 1
        Row.ClipsDescendants = true

        local Lbl = Instance.new("TextLabel", Row)
        Lbl.Size = UDim2.new(0.52, 0, 0, 38)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = labelText
        Lbl.TextColor3 = Theme.TextWhite
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local DropBtn = Instance.new("TextButton", Row)
        DropBtn.Size = UDim2.new(0.46, 0, 0, 36)
        DropBtn.Position = UDim2.new(0.54, 0, 0, 1)
        DropBtn.BackgroundColor3 = Theme.ControlBg
        DropBtn.Text = ""
        DropBtn.AutoButtonColor = false
        Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 7)
        local Stroke = Instance.new("UIStroke", DropBtn)
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1

        local SelectedText = Instance.new("TextLabel", DropBtn)
        SelectedText.Size = UDim2.new(1, -34, 1, 0)
        SelectedText.Position = UDim2.new(0, 12, 0, 0)
        SelectedText.BackgroundTransparency = 1
        SelectedText.Text = defaultVal or options[1] or ""
        SelectedText.TextColor3 = Theme.TextWhite
        SelectedText.Font = Enum.Font.GothamBold
        SelectedText.TextSize = 12
        SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
        SelectedText.TextXAlignment = Enum.TextXAlignment.Left

        local Arrow = Instance.new("TextLabel", DropBtn)
        Arrow.Size = UDim2.new(0, 24, 1, 0)
        Arrow.Position = UDim2.new(1, -26, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Theme.Accent
        Arrow.Font = Enum.Font.GothamBold
        Arrow.TextSize = 10

        local OptionList = Instance.new("Frame", Row)
        OptionList.Size = UDim2.new(0.46, 0, 0, #options * 28)
        OptionList.Position = UDim2.new(0.54, 0, 0, 42)
        OptionList.BackgroundColor3 = Theme.ControlBg
        Instance.new("UICorner", OptionList).CornerRadius = UDim.new(0, 7)
        local OptLayout = Instance.new("UIListLayout", OptionList)
        OptLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local opened = false
        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton", OptionList)
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = "  " .. opt
            OptBtn.TextColor3 = Theme.TextMuted
            OptBtn.Font = Enum.Font.GothamSemibold
            OptBtn.TextSize = 12
            OptBtn.TextTruncate = Enum.TextTruncate.AtEnd
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left

            OptBtn.MouseButton1Click:Connect(function()
                SelectedText.Text = opt
                opened = false
                Row.Size = UDim2.new(1, 0, 0, 38)
                Arrow.Text = "▼"
                if callback then callback(opt) end
            end)
        end

        DropBtn.MouseButton1Click:Connect(function()
            opened = not opened
            Arrow.Text = opened and "▲" or "▼"
            local newHeight = opened and (44 + (#options * 28)) or 38
            Row.Size = UDim2.new(1, 0, 0, newHeight)
        end)

        table.insert(SearchableRows, {Row = Row, Text = string.lower(labelText)})
    end

    -- Baris Input Kanan (Persis gambar: Min Animal Size (x) | [ 0 ], Min Cash Per Second | [ 200B ])
    function Components:AddInputRow(labelText, defaultVal, callback)
        local Row = Instance.new("Frame", Page)
        Row.Size = UDim2.new(1, 0, 0, 38)
        Row.BackgroundTransparency = 1

        local Lbl = Instance.new("TextLabel", Row)
        Lbl.Size = UDim2.new(0.52, 0, 1, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = labelText
        Lbl.TextColor3 = Theme.TextWhite
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local InputBox = Instance.new("TextBox", Row)
        InputBox.Size = UDim2.new(0.46, 0, 0, 36)
        InputBox.Position = UDim2.new(0.54, 0, 0, 1)
        InputBox.BackgroundColor3 = Theme.ControlBg
        InputBox.Text = defaultVal or ""
        InputBox.PlaceholderText = "Enter value..."
        InputBox.PlaceholderColor3 = Theme.TextMuted
        InputBox.TextColor3 = Theme.TextWhite
        InputBox.Font = Enum.Font.GothamBold
        InputBox.TextSize = 13
        InputBox.TextXAlignment = Enum.TextXAlignment.Left
        InputBox.ClearTextOnFocus = false
        Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 7)

        local Pad = Instance.new("UIPadding", InputBox)
        Pad.PaddingLeft = UDim.new(0, 12)

        local Stroke = Instance.new("UIStroke", InputBox)
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1

        InputBox.FocusLost:Connect(function()
            if callback then callback(InputBox.Text) end
        end)

        table.insert(SearchableRows, {Row = Row, Text = string.lower(labelText)})
        return InputBox
    end

    -- Baris Toggle Switch Biru
    function Components:AddToggleRow(labelText, defaultVal, callback)
        local state = defaultVal or false
        local Row = Instance.new("Frame", Page)
        Row.Size = UDim2.new(1, 0, 0, 38)
        Row.BackgroundTransparency = 1

        local Lbl = Instance.new("TextLabel", Row)
        Lbl.Size = UDim2.new(0.7, 0, 1, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = labelText
        Lbl.TextColor3 = Theme.TextWhite
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local SwitchBtn = Instance.new("TextButton", Row)
        SwitchBtn.Size = UDim2.new(0, 46, 0, 24)
        SwitchBtn.Position = UDim2.new(1, -48, 0.5, -12)
        SwitchBtn.BackgroundColor3 = state and Theme.Accent or Theme.ControlBg
        SwitchBtn.Text = ""
        SwitchBtn.AutoButtonColor = false
        Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(1, 0)
        local Stroke = Instance.new("UIStroke", SwitchBtn)
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1

        local Knob = Instance.new("Frame", SwitchBtn)
        Knob.Size = UDim2.new(0, 18, 0, 18)
        Knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Knob.BackgroundColor3 = Theme.TextWhite
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        SwitchBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(SwitchBtn, TweenInfo.new(0.18), {
                BackgroundColor3 = state and Theme.Accent or Theme.ControlBg
            }):Play()
            TweenService:Create(Knob, TweenInfo.new(0.18), {
                Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            }):Play()
            if callback then callback(state) end
        end)

        table.insert(SearchableRows, {Row = Row, Text = string.lower(labelText)})
    end

    -- Baris Tombol Aksi
    function Components:AddButton(text, callback)
        local Btn = Instance.new("TextButton", Page)
        Btn.Size = UDim2.new(1, 0, 0, 36)
        Btn.BackgroundColor3 = Theme.ControlBg
        Btn.Text = "  " .. text
        Btn.TextColor3 = Theme.AccentBright
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 13
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.AutoButtonColor = false
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 7)

        local Stroke = Instance.new("UIStroke", Btn)
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ControlHover}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ControlBg}):Play()
        end)
        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        table.insert(SearchableRows, {Row = Btn, Text = string.lower(text)})
        return Btn
    end

    return Components
end

-- Filter Search Feature Real-time
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBox.Text)
    for _, item in ipairs(SearchableRows) do
        if q == "" or string.find(item.Text, q, 1, true) then
            item.Row.Visible = true
        else
            item.Row.Visible = false
        end
    end
end)

-- ============================================================================
-- MEMBANGUN 7 TAB PERSIS GAMBAR
-- ============================================================================
local MainTab       = CreateTab("Main", "🏠")
local AutomationTab = CreateTab("Automation", "⏭")
local ShopTab       = CreateTab("Shop", "🛒")
local EventTab      = CreateTab("Event", "⭐")
local WebhookTab    = CreateTab("Webhook", "➤")
local SettingsTab   = CreateTab("Settings", "⚙")
local ConfigTab     = CreateTab("Config", "🔄")

-- ----------------------------------------------------------------------------
-- 1. TAB MAIN (Persis Tampilan Gambar)
-- ----------------------------------------------------------------------------
MainTab:AddInfoBox(
    "Breaks eggs in the picked Zones and steals what hatches. Min Size / Min $/s use the values over the animal's head (e.g. 2.5, 150M, 13.2B). Help Friend drops animals in the Forest Zone instead of banking them."
)

MainTab:AddDropdown("Zones (empty = all)", ZoneList, "Zone 11 - Haunted Graveyard (-3998, 4, 32)", function(val)
    Config.SelectedZone = val
end)

MainTab:AddDropdown("Egg Types (empty = all)", {
    "All Eggs", "Skull Egg", "Titanic Egg", "Crystal Egg", "Galaxy Egg", "Basic Egg"
}, "Skull Egg,...", function(val)
    Config.SelectedEgg = val
end)

MainTab:AddDropdown("Animal Rarities (empty = all)", {
    "All Rarities", "Void, Omega, Inferno...", "Secret, Mythical", "Legendary, Epic"
}, "Void, Omega, Inferno...", function(val)
    Config.SelectedRarity = val
end)

MainTab:AddInputRow("Min Animal Size (x)", "0", function(val)
    Config.MinAnimalSize = val
end)

MainTab:AddInputRow("Min Cash Per Second ($/s)", "200B", function(val)
    Config.MinCashPerSec = val
end)

MainTab:AddToggleRow("Auto Break & Steal Eggs", false, function(state)
    Config.AutoBreakAndSteal = state
end)

MainTab:AddToggleRow("Auto Steal Hatched Animals (PromptAnchor)", false, function(state)
    Config.AutoStealAnimals = state
end)

MainTab:AddToggleRow("Help Friend (Drop Carried Animal)", false, function(state)
    Config.HelpFriendDrop = state
    if state and ReplicatedStorage:FindFirstChild("DropCarriedRemote") then
        ReplicatedStorage.DropCarriedRemote:FireServer()
    end
end)

-- ----------------------------------------------------------------------------
-- 2. TAB AUTOMATION (Berdasarkan Remote & Lokasi Map)
-- ----------------------------------------------------------------------------
AutomationTab:AddToggleRow("Auto Train Speed (SpeedGain & Treadmill)", false, function(state)
    Config.AutoSpeedTreadmill = state
end)

AutomationTab:AddToggleRow("Auto Swing Pickaxe (MasteryPickaxeSwing)", false, function(state)
    Config.AutoSwingPickaxe = state
end)

AutomationTab:AddToggleRow("Auto Upgrade Treadmill", false, function(state)
    Config.AutoUpgradeTreadmill = state
end)

AutomationTab:AddToggleRow("Auto Upgrade Plot", false, function(state)
    Config.AutoUpgradePlot = state
end)

AutomationTab:AddDropdown("Teleport to Zone (1 - 11)", ZoneList, "Zone 1 - Chicken (-157, 3, -17)", function(zoneName)
    local targetPos = ZoneCoordinates[zoneName]
    if targetPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
    end
end)

AutomationTab:AddButton("⚡ Teleport to Egg Machine (-72, 0, 87)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-72.5, 4.0, 87.9)
    end
end)

AutomationTab:AddButton("🔮 Teleport to Fuse Machine (-2924, 8, -60)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2924.4, 8.4, -60.1)
    end
end)

AutomationTab:AddButton("💰 Sell All Backpack (BackpackSellRemote)", function()
    local remote = ReplicatedStorage:FindFirstChild("BackpackSellRemote")
    if remote and remote:IsA("RemoteFunction") then
        pcall(function() remote:InvokeServer() end)
    end
end)

-- ----------------------------------------------------------------------------
-- 3. TAB SHOP (Berdasarkan ReplicatedStorage.Pickaxes & Booths)
-- ----------------------------------------------------------------------------
ShopTab:AddDropdown("Select Pickaxe (1 - 21)", PickaxeList, "21: Haunted Pickaxe", function(val)
    Config.SelectedPickaxe = val
end)

ShopTab:AddButton("⛏ Buy Selected Pickaxe (PickaxeShopRequest)", function()
    local remote = ReplicatedStorage:FindFirstChild("PickaxeShopRequest")
    if remote then
        remote:FireServer(Config.SelectedPickaxe)
    end
end)

ShopTab:AddButton("🏪 Teleport to Pickaxe Shop (-69, 7, 66)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-69.4, 7.0, 66.0)
    end
end)

ShopTab:AddButton("✨ Teleport to Trails Shop (-65, 7, -63)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-65.0, 7.0, -63.4)
    end
end)

ShopTab:AddButton("⚒ Teleport to Masteries Booth (-3874, 9, -57)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-3874.9, 9.3, -57.8)
    end
end)

-- ----------------------------------------------------------------------------
-- 4. TAB EVENT (Berdasarkan Remote Halloween & PumpkinKing)
-- ----------------------------------------------------------------------------
EventTab:AddToggleRow("Auto Halloween Candy Drops & Heist", false, function(state)
    Config.AutoHalloweenCandy = state
end)

EventTab:AddButton("🎃 Teleport to Halloween Merchant (-74, 1, -42)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-74.0, 4.0, -42.3)
    end
end)

EventTab:AddButton("👑 Contact Pumpkin King (PumpkinKingContact)", function()
    local remote = ReplicatedStorage:FindFirstChild("PumpkinKingContact")
    if remote then remote:FireServer() end
end)

EventTab:AddButton("🎁 Claim Group & Offline Rewards", function()
    if ReplicatedStorage:FindFirstChild("GroupRewardRemote") then
        ReplicatedStorage.GroupRewardRemote:FireServer()
    end
    if ReplicatedStorage:FindFirstChild("OfflineRewardRemote") then
        ReplicatedStorage.OfflineRewardRemote:FireServer()
    end
    if ReplicatedStorage:FindFirstChild("DiscordRewardRemote") then
        ReplicatedStorage.DiscordRewardRemote:FireServer()
    end
end)

-- ----------------------------------------------------------------------------
-- 5. TAB WEBHOOK
-- ----------------------------------------------------------------------------
WebhookTab:AddInputRow("Discord Webhook URL", "", function(val)
    Config.WebhookURL = val
end)

WebhookTab:AddToggleRow("Notify When Rare Animal Hatched / Stolen", false, function(state)
    Config.WebhookNotify = state
end)

-- ----------------------------------------------------------------------------
-- 6. TAB SETTINGS
-- ----------------------------------------------------------------------------
SettingsTab:AddInputRow("WalkSpeed", "16", function(val)
    local num = tonumber(val)
    if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = num
    end
end)

SettingsTab:AddToggleRow("Anti-AFK Protection", true, function(state)
    Config.AntiAFK = state
end)

SettingsTab:AddButton("🔄 Rejoin Current Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- ----------------------------------------------------------------------------
-- 7. TAB CONFIG (Export Config & Map Analyzer)
-- ----------------------------------------------------------------------------
local ConfigOutput = ConfigTab:AddInputRow("Config / Map JSON Output", "", function() end)

ConfigTab:AddButton("💾 Copy Current Config JSON", function()
    local json = HttpService:JSONEncode(Config)
    ConfigOutput.Text = json
    if typeof(setclipboard) == "function" then
        pcall(setclipboard, json)
    end
end)

-- ============================================================================
-- LOOP OTOMATISASI (BERDASARKAN REMOTE GAME)
-- ============================================================================
task.spawn(function()
    while task.wait(0.25) do
        if not ScreenGui.Parent then break end

        -- Auto Break Egg & Swing
        if Config.AutoBreakAndSteal then
            local eggRemote = ReplicatedStorage:FindFirstChild("EggHitRequest")
            if eggRemote then
                pcall(function() eggRemote:FireServer() end)
            end
        end

        -- Auto Steal Animal (Trigger ProximityPrompt pada PromptAnchor)
        if Config.AutoStealAnimals then
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name == "PromptAnchor" then
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and typeof(fireproximityprompt) == "function" then
                        pcall(fireproximityprompt, prompt)
                    end
                end
            end
        end

        -- Auto Speed / Treadmill
        if Config.AutoSpeedTreadmill then
            local speedRemote = ReplicatedStorage:FindFirstChild("SpeedGainRemote")
            if speedRemote then
                pcall(function() speedRemote:FireServer() end)
            end
        end

        -- Auto Swing Pickaxe Mastery
        if Config.AutoSwingPickaxe then
            local swingRemote = ReplicatedStorage:FindFirstChild("MasteryPickaxeSwing")
            if swingRemote then
                pcall(function() swingRemote:FireServer() end)
            end
        end

        -- Auto Upgrade Treadmill & Plot
        if Config.AutoUpgradeTreadmill and ReplicatedStorage:FindFirstChild("UpgradeTreadmillRequest") then
            pcall(function() ReplicatedStorage.UpgradeTreadmillRequest:FireServer() end)
        end

        if Config.AutoUpgradePlot and ReplicatedStorage:FindFirstChild("UpgradePlotRequest") then
            pcall(function() ReplicatedStorage.UpgradePlotRequest:FireServer() end)
        end

        -- Auto Halloween Event
        if Config.AutoHalloweenCandy then
            if ReplicatedStorage:FindFirstChild("HalloweenCandyDrops") then
                pcall(function() ReplicatedStorage.HalloweenCandyDrops:FireServer() end)
            end
            if ReplicatedStorage:FindFirstChild("HalloweenCandyHeist") then
                pcall(function() ReplicatedStorage.HalloweenCandyHeist:FireServer() end)
            end
        end
    end
end)
