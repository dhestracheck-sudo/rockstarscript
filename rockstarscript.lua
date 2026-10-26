-- ============================================================================
-- ★ ROCKSTAR HUB (BLUE EDITION) v3.1 - BREAK AND STEAL AN EGG
-- Crash-Free Engine + Fixed Auto Break, Auto Steal-to-Base & Auto Treadmill
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("RockstarBlueHub") then
    PlayerGui.RockstarBlueHub:Destroy()
end

-- ============================================================================
-- CONFIG & DATA ZONA
-- ============================================================================
local Config = {
    SelectedZone = "Zone 1 - Chicken",
    SelectedEgg = "All Eggs",
    SelectedRarity = "All Rarities",
    MinAnimalSize = 0,
    MinCashPerSec = "0",
    AutoFarmEggs = false,
    AutoStealAnimals = false,
    HelpFriendDrop = false,
    AutoTreadmill = false,
    AutoUnlockTreadmill = false,
    AutoSellPets = false,
    BatAura = false,
    SelectedBat = "GalaxyBat",
    AutoClaimRewards = false,
    AutoIndex = false,
    AutoPlaceAnimals = false,
    AutoMergeMachine = false,
    AutoFuseMachine = false,
    AutoUpgradePlot = false,
    AutoUpgradeTreadmill = false,
    AutoMasterySwing = false,
    SelectedPickaxe = "21: Haunted Pickaxe",
    AutoBuyPickaxe = false,
    SelectedTrail = "1",
    AutoHalloweenCandy = false,
    AutoHalloweenHeist = false,
    AutoHalloweenDoors = false,
    SelectedHalloweenItem = "Halloween Scythe",
    MyBasePos = nil,
    MyTreadmillPos = nil,
    AntiAFK = true
}

-- Simpan posisi awal saat script dijalankan (biasanya pemain berada di dekat Base miliknya)
pcall(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        Config.MyBasePos = root.Position
    end
end)

local ZoneList = {
    "Zone 1 - Chicken",
    "Zone 2 - Sphinx",
    "Zone 3 - Ice Yeti",
    "Zone 4 - Emerald Serpent",
    "Zone 5 - Woolly Mammoth",
    "Zone 6 - Redshell Crab",
    "Zone 7 - Mole Titan",
    "Zone 8 - Griffin",
    "Zone 9 - 3Hydra",
    "Zone 10 - Alien Guardian",
    "Haunted Graveyard"
}

local ZoneCoords = {
    ["Zone 1 - Chicken"] = Vector3.new(-157.1, 4.0, -17.8),
    ["Zone 2 - Sphinx"] = Vector3.new(-247.3, 4.0, -40.9),
    ["Zone 3 - Ice Yeti"] = Vector3.new(-397.8, 4.0, -24.1),
    ["Zone 4 - Emerald Serpent"] = Vector3.new(-504.9, 4.0, -19.1),
    ["Zone 5 - Woolly Mammoth"] = Vector3.new(-784.6, 4.0, -2.9),
    ["Zone 6 - Redshell Crab"] = Vector3.new(-1201.4, 4.0, 25.6),
    ["Zone 7 - Mole Titan"] = Vector3.new(-1626.7, 4.0, -26.9),
    ["Zone 8 - Griffin"] = Vector3.new(-2119.7, 4.0, 37.6),
    ["Zone 9 - 3Hydra"] = Vector3.new(-2712.9, 4.0, 25.0),
    ["Zone 10 - Alien Guardian"] = Vector3.new(-3237.8, 4.0, 2.6),
    ["Haunted Graveyard"] = Vector3.new(-3998.7, 4.5, 32.3)
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

local BatList = {
    "Bat", "TreeBat", "CactusBat", "LakeBat", "FrostBat",
    "LavaBat", "CandyBat", "BlossomBat", "GalaxyBat"
}

-- ============================================================================
-- WARNA TEMA ROCKSTAR BIRU
-- ============================================================================
local Theme = {
    MainBg = Color3.fromRGB(11, 16, 26),
    TopBg = Color3.fromRGB(13, 19, 32),
    SidebarBg = Color3.fromRGB(12, 18, 30),
    TabActiveBg = Color3.fromRGB(19, 32, 56),
    SectionBg = Color3.fromRGB(16, 25, 44),
    SectionBodyBg = Color3.fromRGB(13, 21, 36),
    ControlBg = Color3.fromRGB(20, 32, 56),
    Accent = Color3.fromRGB(0, 150, 255),
    AccentBright = Color3.fromRGB(65, 190, 255),
    Border = Color3.fromRGB(30, 56, 98),
    TextWhite = Color3.fromRGB(244, 248, 255),
    TextMuted = Color3.fromRGB(160, 180, 210)
}

-- ============================================================================
-- BASE UI
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarBlueHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 660, 0, 430)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -215)
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.BackgroundTransparency = 0.06
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Theme.Border

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.TopBg
TopBar.BorderSizePixel = 0

local TopLine = Instance.new("Frame", TopBar)
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = Theme.Border
TopLine.BorderSizePixel = 0

local BrandLabel = Instance.new("TextLabel", TopBar)
BrandLabel.Size = UDim2.new(0, 92, 1, 0)
BrandLabel.Position = UDim2.new(0, 16, 0, 0)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "Rockstar"
BrandLabel.TextColor3 = Theme.Accent
BrandLabel.Font = Enum.Font.GothamBlack
BrandLabel.TextSize = 20
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlanetIcon = Instance.new("TextLabel", TopBar)
PlanetIcon.Size = UDim2.new(0, 26, 1, 0)
PlanetIcon.Position = UDim2.new(0, 110, 0, 0)
PlanetIcon.BackgroundTransparency = 1
PlanetIcon.Text = "🪐"
PlanetIcon.TextColor3 = Theme.Accent
PlanetIcon.Font = Enum.Font.GothamBold
PlanetIcon.TextSize = 16

local TopPipe = Instance.new("Frame", TopBar)
TopPipe.Size = UDim2.new(0, 1, 0, 20)
TopPipe.Position = UDim2.new(0, 142, 0.5, -10)
TopPipe.BackgroundColor3 = Theme.Border
TopPipe.BorderSizePixel = 0

local GameTitle = Instance.new("TextLabel", TopBar)
GameTitle.Size = UDim2.new(0, 210, 1, 0)
GameTitle.Position = UDim2.new(0, 154, 0, 0)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "Break and Steal an Egg"
GameTitle.TextColor3 = Theme.TextWhite
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 14
GameTitle.TextXAlignment = Enum.TextXAlignment.Left

local StatusBadge = Instance.new("TextLabel", TopBar)
StatusBadge.Size = UDim2.new(0, 230, 1, 0)
StatusBadge.Position = UDim2.new(1, -280, 0, 0)
StatusBadge.BackgroundTransparency = 1
StatusBadge.Text = "⚡ Status: Ready"
StatusBadge.TextColor3 = Theme.AccentBright
StatusBadge.Font = Enum.Font.GothamBold
StatusBadge.TextSize = 12
StatusBadge.TextXAlignment = Enum.TextXAlignment.Right

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -44, 0.5, -16)
MinBtn.BackgroundColor3 = Theme.SectionBg
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Accent
MinBtn.Font = Enum.Font.GothamBlack
MinBtn.TextSize = 15
MinBtn.AutoButtonColor = false
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MinBtn).Color = Theme.Border

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 188, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.BackgroundColor3 = Theme.SidebarBg
Sidebar.BackgroundTransparency = 0.25
Sidebar.BorderSizePixel = 0

local SearchBoxFrame = Instance.new("Frame", Sidebar)
SearchBoxFrame.Size = UDim2.new(1, -20, 0, 36)
SearchBoxFrame.Position = UDim2.new(0, 10, 0, 12)
SearchBoxFrame.BackgroundColor3 = Theme.SectionBg
Instance.new("UICorner", SearchBoxFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", SearchBoxFrame).Color = Theme.Border

local SearchInput = Instance.new("TextBox", SearchBoxFrame)
SearchInput.Size = UDim2.new(1, -24, 1, 0)
SearchInput.Position = UDim2.new(0, 12, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.PlaceholderText = "🔍 Search feature..."
SearchInput.PlaceholderColor3 = Theme.TextMuted
SearchInput.Text = ""
SearchInput.TextColor3 = Theme.TextWhite
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.TextSize = 13
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.ClearTextOnFocus = false

local TabList = Instance.new("ScrollingFrame", Sidebar)
TabList.Size = UDim2.new(1, -20, 1, -62)
TabList.Position = UDim2.new(0, 10, 0, 56)
TabList.BackgroundTransparency = 1
TabList.BorderSizePixel = 0
TabList.ScrollBarThickness = 0
TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabList.CanvasSize = UDim2.new(0, 0, 0, 0)

local TabListLayout = Instance.new("UIListLayout", TabList)
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -200, 1, -48)
ContentArea.Position = UDim2.new(0, 194, 0, 48)
ContentArea.BackgroundTransparency = 1

local HeaderBar = Instance.new("Frame", ContentArea)
HeaderBar.Size = UDim2.new(1, -16, 0, 40)
HeaderBar.Position = UDim2.new(0, 4, 0, 6)
HeaderBar.BackgroundTransparency = 1

local HeaderBlueIndicator = Instance.new("Frame", HeaderBar)
HeaderBlueIndicator.Size = UDim2.new(0, 4, 0, 22)
HeaderBlueIndicator.Position = UDim2.new(0, 0, 0.5, -11)
HeaderBlueIndicator.BackgroundColor3 = Theme.Accent
HeaderBlueIndicator.BorderSizePixel = 0
Instance.new("UICorner", HeaderBlueIndicator).CornerRadius = UDim.new(1, 0)

local HeaderTitle = Instance.new("TextLabel", HeaderBar)
HeaderTitle.Size = UDim2.new(1, -20, 1, 0)
HeaderTitle.Position = UDim2.new(0, 14, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "Main"
HeaderTitle.TextColor3 = Theme.TextWhite
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 17
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeaderLine = Instance.new("Frame", HeaderBar)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Theme.Border
HeaderLine.BorderSizePixel = 0

local PagesHolder = Instance.new("Frame", ContentArea)
PagesHolder.Size = UDim2.new(1, -12, 1, -56)
PagesHolder.Position = UDim2.new(0, 4, 0, 52)
PagesHolder.BackgroundTransparency = 1

-- Drag & Minimize
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local sz = minimized and UDim2.new(0, 660, 0, 48) or UDim2.new(0, 660, 0, 430)
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = sz}):Play()
end)

-- ============================================================================
-- TAB & ACCORDION BUILDER
-- ============================================================================
local Tabs = {}
local AllSections = {}
local FirstTab = true

local function CreateTab(tabName, iconText)
    local TabBtn = Instance.new("TextButton", TabList)
    TabBtn.Size = UDim2.new(1, 0, 0, 42)
    TabBtn.BackgroundColor3 = Theme.TabActiveBg
    TabBtn.BackgroundTransparency = FirstTab and 0.1 or 1
    TabBtn.Text = ""
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    local LeftBar = Instance.new("Frame", TabBtn)
    LeftBar.Size = UDim2.new(0, 4, 0, 24)
    LeftBar.Position = UDim2.new(0, 0, 0.5, -12)
    LeftBar.BackgroundColor3 = Theme.Accent
    LeftBar.BorderSizePixel = 0
    LeftBar.Visible = FirstTab
    Instance.new("UICorner", LeftBar).CornerRadius = UDim.new(1, 0)

    local Icon = Instance.new("TextLabel", TabBtn)
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.Position = UDim2.new(0, 10, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = iconText
    Icon.TextColor3 = FirstTab and Theme.Accent or Theme.TextMuted
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 16

    local Label = Instance.new("TextLabel", TabBtn)
    Label.Size = UDim2.new(1, -46, 1, 0)
    Label.Position = UDim2.new(0, 44, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = tabName
    Label.TextColor3 = FirstTab and Theme.TextWhite or Theme.TextMuted
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Page = Instance.new("ScrollingFrame", PagesHolder)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = FirstTab
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local PagePad = Instance.new("UIPadding", Page)
    PagePad.PaddingRight = UDim.new(0, 8)
    PagePad.PaddingBottom = UDim.new(0, 12)

    FirstTab = false
    table.insert(Tabs, {Btn = TabBtn, Bar = LeftBar, Icon = Icon, Label = Label, Page = Page})

    TabBtn.MouseButton1Click:Connect(function()
        HeaderTitle.Text = tabName
        for _, t in ipairs(Tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundTransparency = 1
            t.Bar.Visible = false
            t.Icon.TextColor3 = Theme.TextMuted
            t.Label.TextColor3 = Theme.TextMuted
        end
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.1
        LeftBar.Visible = true
        Icon.TextColor3 = Theme.Accent
        Label.TextColor3 = Theme.TextWhite
    end)

    local TabObj = {}

    function TabObj:AddSection(sectionTitle, defaultOpen)
        local isOpen = defaultOpen or false

        local SectionContainer = Instance.new("Frame", Page)
        SectionContainer.Size = UDim2.new(1, 0, 0, 44)
        SectionContainer.BackgroundColor3 = Theme.SectionBg
        SectionContainer.BackgroundTransparency = 0.15
        SectionContainer.BorderSizePixel = 0
        SectionContainer.AutomaticSize = Enum.AutomaticSize.Y
        Instance.new("UICorner", SectionContainer).CornerRadius = UDim.new(0, 8)

        local SecStroke = Instance.new("UIStroke", SectionContainer)
        SecStroke.Color = Theme.Border
        SecStroke.Thickness = 1
        SecStroke.Transparency = 0.4

        local HeaderBtn = Instance.new("TextButton", SectionContainer)
        HeaderBtn.Size = UDim2.new(1, 0, 0, 44)
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Text = ""
        HeaderBtn.AutoButtonColor = false

        local TitleLbl = Instance.new("TextLabel", HeaderBtn)
        TitleLbl.Size = UDim2.new(1, -50, 1, 0)
        TitleLbl.Position = UDim2.new(0, 16, 0, 0)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = sectionTitle
        TitleLbl.TextColor3 = Theme.TextWhite
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextSize = 14
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local ArrowLbl = Instance.new("TextLabel", HeaderBtn)
        ArrowLbl.Size = UDim2.new(0, 30, 1, 0)
        ArrowLbl.Position = UDim2.new(1, -34, 0, 0)
        ArrowLbl.BackgroundTransparency = 1
        ArrowLbl.Text = isOpen and "▴" or "▾"
        ArrowLbl.TextColor3 = Theme.Accent
        ArrowLbl.Font = Enum.Font.GothamBold
        ArrowLbl.TextSize = 14

        local BodyFrame = Instance.new("Frame", SectionContainer)
        BodyFrame.Size = UDim2.new(1, -24, 0, 0)
        BodyFrame.Position = UDim2.new(0, 12, 0, 44)
        BodyFrame.BackgroundTransparency = 1
        BodyFrame.Visible = isOpen
        BodyFrame.AutomaticSize = Enum.AutomaticSize.Y

        local BodyLayout = Instance.new("UIListLayout", BodyFrame)
        BodyLayout.Padding = UDim.new(0, 8)
        BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local BodyPad = Instance.new("UIPadding", BodyFrame)
        BodyPad.PaddingTop = UDim.new(0, 4)
        BodyPad.PaddingBottom = UDim.new(0, 12)

        HeaderBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            BodyFrame.Visible = isOpen
            ArrowLbl.Text = isOpen and "▴" or "▾"
        end)

        table.insert(AllSections, {Frame = SectionContainer, Title = string.lower(sectionTitle)})

        local SecItems = {}

        function SecItems:AddInfoBox(infoText)
            local Box = Instance.new("Frame", BodyFrame)
            Box.Size = UDim2.new(1, 0, 0, 66)
            Box.BackgroundColor3 = Theme.SectionBodyBg
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 7)
            Instance.new("UIStroke", Box).Color = Theme.Border

            local Lbl = Instance.new("TextLabel", Box)
            Lbl.Size = UDim2.new(1, -20, 1, -14)
            Lbl.Position = UDim2.new(0, 10, 0, 7)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = infoText
            Lbl.TextColor3 = Theme.TextMuted
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 12
            Lbl.TextWrapped = true
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.TextYAlignment = Enum.TextYAlignment.Top
        end

        function SecItems:AddDropdown(labelText, options, defaultText, callback)
            local Row = Instance.new("Frame", BodyFrame)
            Row.Size = UDim2.new(1, 0, 0, 36)
            Row.BackgroundTransparency = 1
            Row.ClipsDescendants = true

            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Size = UDim2.new(0.52, 0, 0, 36)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = labelText
            Lbl.TextColor3 = Theme.TextWhite
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local DropBtn = Instance.new("TextButton", Row)
            DropBtn.Size = UDim2.new(0.46, 0, 0, 34)
            DropBtn.Position = UDim2.new(0.54, 0, 0, 1)
            DropBtn.BackgroundColor3 = Theme.ControlBg
            DropBtn.Text = ""
            DropBtn.AutoButtonColor = false
            Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", DropBtn).Color = Theme.Border

            local ValLbl = Instance.new("TextLabel", DropBtn)
            ValLbl.Size = UDim2.new(1, -30, 1, 0)
            ValLbl.Position = UDim2.new(0, 10, 0, 0)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Text = defaultText or options[1] or ""
            ValLbl.TextColor3 = Theme.TextWhite
            ValLbl.Font = Enum.Font.GothamBold
            ValLbl.TextSize = 12
            ValLbl.TextTruncate = Enum.TextTruncate.AtEnd
            ValLbl.TextXAlignment = Enum.TextXAlignment.Left

            local Arr = Instance.new("TextLabel", DropBtn)
            Arr.Size = UDim2.new(0, 22, 1, 0)
            Arr.Position = UDim2.new(1, -24, 0, 0)
            Arr.BackgroundTransparency = 1
            Arr.Text = "▾"
            Arr.TextColor3 = Theme.Accent
            Arr.Font = Enum.Font.GothamBold
            Arr.TextSize = 13

            local ListHolder = Instance.new("Frame", Row)
            ListHolder.Size = UDim2.new(0.46, 0, 0, #options * 26)
            ListHolder.Position = UDim2.new(0.54, 0, 0, 38)
            ListHolder.BackgroundColor3 = Theme.SectionBodyBg
            Instance.new("UICorner", ListHolder).CornerRadius = UDim.new(0, 6)
            local LLayout = Instance.new("UIListLayout", ListHolder)
            LLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local openDrop = false
            for _, opt in ipairs(options) do
                local OBtn = Instance.new("TextButton", ListHolder)
                OBtn.Size = UDim2.new(1, 0, 0, 26)
                OBtn.BackgroundTransparency = 1
                OBtn.Text = "  " .. opt
                OBtn.TextColor3 = Theme.TextMuted
                OBtn.Font = Enum.Font.GothamSemibold
                OBtn.TextSize = 12
                OBtn.TextTruncate = Enum.TextTruncate.AtEnd
                OBtn.TextXAlignment = Enum.TextXAlignment.Left

                OBtn.MouseButton1Click:Connect(function()
                    ValLbl.Text = opt
                    openDrop = false
                    Row.Size = UDim2.new(1, 0, 0, 36)
                    if callback then callback(opt) end
                end)
            end

            DropBtn.MouseButton1Click:Connect(function()
                openDrop = not openDrop
                Row.Size = UDim2.new(1, 0, 0, openDrop and (40 + #options * 26) or 36)
            end)
        end

        function SecItems:AddInput(labelText, defaultVal, callback)
            local Row = Instance.new("Frame", BodyFrame)
            Row.Size = UDim2.new(1, 0, 0, 36)
            Row.BackgroundTransparency = 1

            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Size = UDim2.new(0.52, 0, 1, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = labelText
            Lbl.TextColor3 = Theme.TextWhite
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Box = Instance.new("TextBox", Row)
            Box.Size = UDim2.new(0.46, 0, 0, 34)
            Box.Position = UDim2.new(0.54, 0, 0, 1)
            Box.BackgroundColor3 = Theme.ControlBg
            Box.Text = defaultVal or ""
            Box.PlaceholderText = "..."
            Box.PlaceholderColor3 = Theme.TextMuted
            Box.TextColor3 = Theme.TextWhite
            Box.Font = Enum.Font.GothamBold
            Box.TextSize = 12
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = false
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
            Instance.new("UIPadding", Box).PaddingLeft = UDim.new(0, 10)
            Instance.new("UIStroke", Box).Color = Theme.Border

            Box.FocusLost:Connect(function()
                if callback then callback(Box.Text) end
            end)
            return Box
        end

        function SecItems:AddToggle(labelText, defaultState, callback)
            local state = defaultState or false
            local Row = Instance.new("Frame", BodyFrame)
            Row.Size = UDim2.new(1, 0, 0, 34)
            Row.BackgroundTransparency = 1

            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Size = UDim2.new(0.75, 0, 1, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = labelText
            Lbl.TextColor3 = Theme.TextWhite
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Sw = Instance.new("TextButton", Row)
            Sw.Size = UDim2.new(0, 44, 0, 22)
            Sw.Position = UDim2.new(1, -46, 0.5, -11)
            Sw.BackgroundColor3 = state and Theme.Accent or Theme.ControlBg
            Sw.Text = ""
            Sw.AutoButtonColor = false
            Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", Sw).Color = Theme.Border

            local Dot = Instance.new("Frame", Sw)
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Dot.BackgroundColor3 = Theme.TextWhite
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            Sw.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Sw, TweenInfo.new(0.18), {BackgroundColor3 = state and Theme.Accent or Theme.ControlBg}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.18), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
                if callback then callback(state) end
            end)
        end

        function SecItems:AddButton(btnText, callback)
            local Btn = Instance.new("TextButton", BodyFrame)
            Btn.Size = UDim2.new(1, 0, 0, 34)
            Btn.BackgroundColor3 = Theme.ControlBg
            Btn.Text = "  " .. btnText
            Btn.TextColor3 = Theme.AccentBright
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.AutoButtonColor = false
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", Btn).Color = Theme.Border

            Btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return Btn
        end

        return SecItems
    end

    return TabObj
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchInput.Text)
    for _, sec in ipairs(AllSections) do
        sec.Frame.Visible = (q == "" or string.find(sec.Title, q, 1, true) ~= nil)
    end
end)

-- ============================================================================
-- HELPER POSISI, BASE PLOT, TREADMILL, DAN TELUR
-- ============================================================================
local function GetPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, cf = pcall(function() return obj:GetPivot() end)
        if ok and cf then return cf.Position end
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        if p then return p.Position end
    end
    return nil
end

local function FindMyPlotModel()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, base in ipairs(plots:GetChildren()) do
        for _, v in pairs(base:GetAttributes()) do
            if tostring(v) == LocalPlayer.Name or tostring(v) == tostring(LocalPlayer.UserId) then
                return base
            end
        end
        for _, d in ipairs(base:GetDescendants()) do
            if (d:IsA("StringValue") or d:IsA("TextLabel")) then
                local txt = tostring(d:IsA("StringValue") and d.Value or d.Text)
                if string.find(txt, LocalPlayer.Name, 1, true) or string.find(txt, LocalPlayer.DisplayName, 1, true) then
                    return base
                end
            elseif d:IsA("ObjectValue") and d.Value == LocalPlayer then
                return base
            end
        end
    end
    -- Fallback: cari Base terdekat dari posisi awal spawn
    if Config.MyBasePos then
        local bestBase, bestDist = nil, math.huge
        for _, base in ipairs(plots:GetChildren()) do
            local p = GetPos(base)
            if p and (p - Config.MyBasePos).Magnitude < bestDist then
                bestDist = (p - Config.MyBasePos).Magnitude
                bestBase = base
            end
        end
        return bestBase
    end
    return nil
end

local function FindMyTreadmillPart()
    local myPlot = FindMyPlotModel()
    if myPlot then
        for _, d in ipairs(myPlot:GetDescendants()) do
            if d:IsA("BasePart") and string.find(string.lower(d.Name), "treadmill") then
                return d
            end
            if d:IsA("Model") and string.find(string.lower(d.Name), "treadmill") then
                local p = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart", true)
                if p then return p end
            end
        end
    end
    local vfx = workspace:FindFirstChild("TreadmillSpawnVFX")
    if vfx and vfx:IsA("BasePart") then return vfx end
    return nil
end

local function EquipToolByKeyword(kw)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(kw), 1, true) then
            return t
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(kw), 1, true) then
                hum:EquipTool(t)
                return t
            end
        end
        local anyTool = bp:FindFirstChildOfClass("Tool")
        if anyTool then
            hum:EquipTool(anyTool)
            return anyTool
        end
    end
    return nil
end

-- Cari Telur di Workspace.Eggs maupun di dalam Workspace.Build.ZoneBuilds
local function FindBestEgg()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end

    local list = {}
    local eggsFolder = workspace:FindFirstChild("Eggs")
    if eggsFolder then
        for _, e in ipairs(eggsFolder:GetChildren()) do
            table.insert(list, e)
        end
    end

    -- Cek juga di dalam ZoneBuilds kalau telur di-parent ke dalam Zone
    local build = workspace:FindFirstChild("Build")
    if build and build:FindFirstChild("ZoneBuilds") then
        for _, z in ipairs(build.ZoneBuilds:GetChildren()) do
            for _, child in ipairs(z:GetChildren()) do
                if string.find(string.lower(child.Name), "egg") then
                    table.insert(list, child)
                end
            end
        end
    end

    local bestEgg, bestPos, bestDist = nil, nil, math.huge
    for _, egg in ipairs(list) do
        local p = GetPos(egg)
        if p then
            local d = (p - root.Position).Magnitude
            if d < bestDist then
                bestDist = d
                bestEgg = egg
                bestPos = p
            end
        end
    end
    return bestEgg, bestPos
end

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

-- 1. TAB MAIN
local SecSupport = MainTab:AddSection("Support Features", false)
SecSupport:AddToggle("Anti-AFK Protection", true, function(v) Config.AntiAFK = v end)
SecSupport:AddButton("📍 Simpan Posisi Berdiri Sebagai Base Plot Saya", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        Config.MyBasePos = root.Position
        StatusBadge.Text = "✅ Posisi Base Disimpan!"
    end
end)
SecSupport:AddButton("🏃 Simpan Posisi Berdiri Sebagai Treadmill Saya", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        Config.MyTreadmillPos = root.Position
        StatusBadge.Text = "✅ Posisi Treadmill Disimpan!"
    end
end)
SecSupport:AddDropdown("Quick Teleport Zone", ZoneList, "Zone 1 - Chicken", function(z)
    local pos = ZoneCoords[z]
    if pos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end)

local SecBatAura = MainTab:AddSection("Bat Aura", false)
SecBatAura:AddToggle("Enable Bat Hit Aura", false, function(v) Config.BatAura = v end)
SecBatAura:AddDropdown("Select Bat Tool", BatList, "GalaxyBat", function(v) Config.SelectedBat = v end)
SecBatAura:AddButton("Unlock Selected Bat", function()
    if ReplicatedStorage:FindFirstChild("BatUnlockRemote") then
        pcall(function() ReplicatedStorage.BatUnlockRemote:FireServer(Config.SelectedBat) end)
    end
end)

local SecAutoFarm = MainTab:AddSection("Auto Farm Eggs", true)
SecAutoFarm:AddInfoBox(
    "otherwise breaks eggs in the picked Zones and steals what hatches. Min Size / Min $/s use the values over the animal's head (e.g. 2.5, 150M, 13.2B). Help Friend drops animals in the Forest Zone instead of banking them."
)
SecAutoFarm:AddDropdown("Zones (empty = all)", ZoneList, "Zone 1 - Chicken", function(v) Config.SelectedZone = v end)
SecAutoFarm:AddDropdown("Egg Types (empty = all)", {"Skull Egg,...", "Titanic Egg", "Crystal Egg", "All Eggs"}, "All Eggs", function(v) Config.SelectedEgg = v end)
SecAutoFarm:AddDropdown("Animal Rarities (empty = all)", {"Void, Omega, Inferno...", "Secret, Mythical", "All Rarities"}, "All Rarities", function(v) Config.SelectedRarity = v end)
SecAutoFarm:AddInput("Min Animal Size (x)", "0", function(v) Config.MinAnimalSize = tonumber(v) or 0 end)
SecAutoFarm:AddInput("Min Cash Per Second ($/s)", "200B", function(v) Config.MinCashPerSec = v end)
SecAutoFarm:AddToggle("Auto Farm & Break Eggs", false, function(v) Config.AutoFarmEggs = v end)
SecAutoFarm:AddToggle("Auto Steal Hatched Animals", false, function(v) Config.AutoStealAnimals = v end)
SecAutoFarm:AddToggle("Help Friend (Drop in Forest Zone)", false, function(v) Config.HelpFriendDrop = v end)

local SecTreadmill = MainTab:AddSection("Auto Treadmill", false)
SecTreadmill:AddToggle("Auto Treadmill & Speed Gain", false, function(v) Config.AutoTreadmill = v end)
SecTreadmill:AddToggle("Auto Unlock Treadmill", false, function(v) Config.AutoUnlockTreadmill = v end)

local SecSellPets = MainTab:AddSection("Auto Sell Pets", false)
SecSellPets:AddToggle("Auto Sell Backpack Pets", false, function(v) Config.AutoSellPets = v end)
SecSellPets:AddButton("Sell All Pets Now", function()
    local r = ReplicatedStorage:FindFirstChild("BackpackSellRemote")
    if r then pcall(function() r:InvokeServer() end) end
end)

-- 2. TAB AUTOMATION
local SecClaim = AutomationTab:AddSection("Claim & Index", false)
SecClaim:AddToggle("Auto Claim Group, Offline & Discord Rewards", false, function(v) Config.AutoClaimRewards = v end)
SecClaim:AddToggle("Auto Claim Animal Index", false, function(v) Config.AutoIndex = v end)

local SecAnimalsEggs = AutomationTab:AddSection("Animals & Eggs", false)
SecAnimalsEggs:AddToggle("Auto Place Animals on Plot", false, function(v) Config.AutoPlaceAnimals = v end)
SecAnimalsEggs:AddToggle("Auto Merge Machine", false, function(v) Config.AutoMergeMachine = v end)
SecAnimalsEggs:AddToggle("Auto Fuse Machine", false, function(v) Config.AutoFuseMachine = v end)

local SecUpgrades = AutomationTab:AddSection("Upgrades & Gear", false)
SecUpgrades:AddToggle("Auto Upgrade Plot", false, function(v) Config.AutoUpgradePlot = v end)
SecUpgrades:AddToggle("Auto Upgrade Treadmill", false, function(v) Config.AutoUpgradeTreadmill = v end)
SecUpgrades:AddToggle("Auto Mastery Pickaxe Swing", false, function(v) Config.AutoMasterySwing = v end)

-- 3. TAB SHOP
local SecPickaxeShop = ShopTab:AddSection("Pickaxe Shop", false)
SecPickaxeShop:AddDropdown("Select Pickaxe", PickaxeList, "21: Haunted Pickaxe", function(v) Config.SelectedPickaxe = v end)
SecPickaxeShop:AddToggle("Auto Buy Selected Pickaxe", false, function(v) Config.AutoBuyPickaxe = v end)
SecPickaxeShop:AddButton("Buy Selected Pickaxe Now", function()
    local r = ReplicatedStorage:FindFirstChild("PickaxeShopRequest")
    if r then
        local idStr, nameOnly = string.match(Config.SelectedPickaxe, "^(%d+):%s*(.+)$")
        pcall(function() r:FireServer(Config.SelectedPickaxe) end)
        if idStr then pcall(function() r:FireServer(tonumber(idStr)) end) end
        if nameOnly then pcall(function() r:FireServer(nameOnly) end) end
    end
end)

local SecTrailsShop = ShopTab:AddSection("Trails Shop", false)
SecTrailsShop:AddInput("Trail ID / Name", "1", function(v) Config.SelectedTrail = v end)
SecTrailsShop:AddButton("Buy Trail Now", function()
    local r = ReplicatedStorage:FindFirstChild("TrailShopRequest")
    if r then
        pcall(function() r:FireServer(Config.SelectedTrail) end)
        pcall(function() r:FireServer(tonumber(Config.SelectedTrail) or 1) end)
    end
end)

-- 4. TAB EVENT
local SecHalloweenEv = EventTab:AddSection("Halloween Events", false)
SecHalloweenEv:AddToggle("Auto Halloween Candy Drops", false, function(v) Config.AutoHalloweenCandy = v end)
SecHalloweenEv:AddToggle("Auto Halloween Candy Heist", false, function(v) Config.AutoHalloweenHeist = v end)
SecHalloweenEv:AddToggle("Auto Trick-or-Treat Doors", false, function(v) Config.AutoHalloweenDoors = v end)

local SecHalloweenShop = EventTab:AddSection("Halloween Shop (1B Speed)", false)
SecHalloweenShop:AddDropdown("Halloween Item", {"Halloween Scythe", "Halloween Shovel", "21: Haunted Pickaxe", "CandyBat"}, "Halloween Scythe", function(v)
    Config.SelectedHalloweenItem = v
end)
SecHalloweenShop:AddButton("Buy Halloween Item", function()
    local r = ReplicatedStorage:FindFirstChild("HalloweenShopRequest")
    if r then pcall(function() r:InvokeServer(Config.SelectedHalloweenItem) end) end
end)

-- 5. TAB WEBHOOK
local SecStealWH = WebhookTab:AddSection("Steal Animal Webhook", false)
SecStealWH:AddInput("Webhook URL", "", function() end)
local SecStatsWH = WebhookTab:AddSection("Stats Webhook", false)
SecStatsWH:AddInput("Webhook URL", "", function() end)
local SecEventWH = WebhookTab:AddSection("Event Webhook", false)
SecEventWH:AddInput("Webhook URL", "", function() end)

-- 6. TAB SETTINGS
local SecSettings = SettingsTab:AddSection("Player Settings", true)
SecSettings:AddInput("WalkSpeed", "16", function(v)
    local n = tonumber(v)
    if n and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = n
    end
end)
SecSettings:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- 7. TAB CONFIG & SAFE INSPECTOR (TANPA HOOK CRASH)
local SecConfig = ConfigTab:AddSection("Safe Inspector (Cek Struktur Plot & Telur)", true)
local ScanBox = SecConfig:AddInput("JSON Output", "")

SecConfig:AddButton("📋 Copy Detail Isi Base_1, Eggs & Zone1 (Aman Tanpa Crash)", function()
    local info = {Base1 = {}, Eggs = {}, Zone1 = {}}
    local plots = workspace:FindFirstChild("Plots")
    if plots and plots:FindFirstChild("Base_1") then
        for _, c in ipairs(plots.Base_1:GetDescendants()) do
            if c:IsA("Model") or c:IsA("Folder") or c:IsA("ProximityPrompt") or c:IsA("BasePart") then
                if #info.Base1 < 50 then
                    table.insert(info.Base1, c.Name .. " [" .. c.ClassName .. "]")
                end
            end
        end
    end
    local eggs = workspace:FindFirstChild("Eggs")
    if eggs then
        for i, e in ipairs(eggs:GetChildren()) do
            if i <= 15 then
                table.insert(info.Eggs, {Name = e.Name, Class = e.ClassName, Pos = tostring(GetPos(e)), Attr = e:GetAttributes()})
            end
        end
    end
    local build = workspace:FindFirstChild("Build")
    if build and build:FindFirstChild("ZoneBuilds") and build.ZoneBuilds:FindFirstChild("Zone1") then
        for _, c in ipairs(build.ZoneBuilds.Zone1:GetDescendants()) do
            if #info.Zone1 < 40 then
                table.insert(info.Zone1, c.Name .. " [" .. c.ClassName .. "]")
            end
        end
    end
    local json = HttpService:JSONEncode(info)
    ScanBox.Text = json
    StatusBadge.Text = "✅ Data Copied!"
    if typeof(setclipboard) == "function" then pcall(setclipboard, json) end
end)

-- ============================================================================
-- ENGINE EKSEKUSI BEBAS ERROR (AUTO BREAK, AUTO STEAL, AUTO TREADMILL)
-- ============================================================================
task.spawn(function()
    while task.wait(0.22) do
        if not ScreenGui.Parent then break end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        -- --------------------------------------------------------------------
        -- 1. AUTO STEAL HATCHED ANIMALS (PromptAnchor -> StealPrompt -> Base)
        -- --------------------------------------------------------------------
        if (Config.AutoStealAnimals or Config.AutoFarmEggs) and root then
            local stolenNow = false
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name == "PromptAnchor" and obj:IsA("BasePart") then
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        StatusBadge.Text = "🐾 Stealing: " .. tostring(prompt.ActionText)
                        -- Teleport tegak lurus ke atas PromptAnchor
                        root.CFrame = CFrame.new(obj.Position.X, obj.Position.Y + 3, obj.Position.Z)
                        -- Tunggu 0.35 detik agar posisi kita ter-validasi di server
                        task.wait(0.35)

                        pcall(function() prompt.HoldDuration = 0 end)
                        if typeof(fireproximityprompt) == "function" then
                            pcall(fireproximityprompt, prompt)
                        end
                        pcall(function()
                            prompt:InputHoldBegin()
                            task.wait(0.15)
                            prompt:InputHoldEnd()
                        end)

                        task.wait(0.35)
                        stolenNow = true
                        break
                    end
                end
            end

            -- Jika baru saja mencuri hewan, bawa pulang ke Base/Plot atau Drop di Forest
            if stolenNow and root then
                if Config.HelpFriendDrop then
                    StatusBadge.Text = "🤝 Dropping in Zone 1..."
                    root.CFrame = CFrame.new(ZoneCoords["Zone 1 - Chicken"])
                    task.wait(0.35)
                    if ReplicatedStorage:FindFirstChild("DropCarriedRemote") then
                        pcall(function() ReplicatedStorage.DropCarriedRemote:FireServer() end)
                    end
                else
                    local myPlot = FindMyPlotModel()
                    local basePos = Config.MyBasePos or GetPos(myPlot) or Vector3.new(-29.6, 4.0, 87.8)
                    StatusBadge.Text = "🏦 Banking Animal at Base..."
                    root.CFrame = CFrame.new(basePos.X, basePos.Y + 3, basePos.Z)
                    task.wait(0.6)
                    if ReplicatedStorage:FindFirstChild("PlaceAnimalRemote") then
                        pcall(function() ReplicatedStorage.PlaceAnimalRemote:FireServer() end)
                    end
                end
            end
        end

        -- --------------------------------------------------------------------
        -- 2. AUTO BREAK EGGS (Equip Pickaxe -> Pindah ke Telur -> Swing & Touch)
        -- --------------------------------------------------------------------
        if Config.AutoFarmEggs and root and hum then
            local tool = EquipToolByKeyword("Pickaxe")
            local targetEgg, eggPos = FindBestEgg()

            if targetEgg and eggPos then
                StatusBadge.Text = "⛏ Breaking: " .. targetEgg.Name
                -- Teleport tegak lurus di sebelah telur hanya jika jarak > 7 stud (agar tidak jitter/jatuh)
                local standPos = Vector3.new(eggPos.X, eggPos.Y + 2, eggPos.Z + 3.5)
                if (root.Position - standPos).Magnitude > 7 then
                    root.CFrame = CFrame.new(standPos)
                    task.wait(0.2)
                end

                -- Ayunkan Pickaxe
                if tool then
                    pcall(function() tool:Activate() end)
                    -- Sentuhkan Handle Pickaxe ke bagian telur (jika mendukung firetouchinterest)
                    local handle = tool:FindFirstChild("Handle")
                    local eggPart = targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart", true)
                    if handle and eggPart and typeof(firetouchinterest) == "function" then
                        pcall(function()
                            firetouchinterest(handle, eggPart, 0)
                            firetouchinterest(handle, eggPart, 1)
                        end)
                    end
                end

                -- Simulasi Klik Kiri
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end)

                -- Kirim Remote EggHitRequest & EggHitLanded
                local hitReq = ReplicatedStorage:FindFirstChild("EggHitRequest")
                if hitReq then
                    pcall(function() hitReq:FireServer(targetEgg) end)
                    pcall(function() hitReq:FireServer(targetEgg.Name) end)
                    pcall(function() hitReq:FireServer() end)
                end
                local hitLanded = ReplicatedStorage:FindFirstChild("EggHitLanded")
                if hitLanded then
                    pcall(function() hitLanded:FireServer(targetEgg) end)
                end
            else
                -- Jika belum ada telur yang ter-stream, pindah ke Zona yang dipilih
                local zPos = ZoneCoords[Config.SelectedZone] or ZoneCoords["Zone 1 - Chicken"]
                if zPos and (root.Position - zPos).Magnitude > 40 then
                    StatusBadge.Text = "🚀 Moving to " .. Config.SelectedZone
                    root.CFrame = CFrame.new(zPos)
                    task.wait(0.4)
                else
                    StatusBadge.Text = "🔍 Waiting for Eggs..."
                end
            end
        end

        -- --------------------------------------------------------------------
        -- 3. AUTO TREADMILL (Berdiri di Atas Treadmill + SpeedGainRemote)
        -- --------------------------------------------------------------------
        if Config.AutoTreadmill and root then
            StatusBadge.Text = "🏃 Running on Treadmill..."
            local tmPart = FindMyTreadmillPart()
            local tmPos = Config.MyTreadmillPos or (tmPart and tmPart.Position) or Vector3.new(-61.8, 3.5, -2.8)

            if (root.Position - tmPos).Magnitude > 6 then
                root.CFrame = CFrame.new(tmPos.X, tmPos.Y + 3, tmPos.Z)
                task.wait(0.25)
            end

            if tmPart and typeof(firetouchinterest) == "function" then
                pcall(function()
                    firetouchinterest(root, tmPart, 0)
                    firetouchinterest(root, tmPart, 1)
                end)
            end

            if ReplicatedStorage:FindFirstChild("TreadmillSessionRemote") then
                pcall(function() ReplicatedStorage.TreadmillSessionRemote:FireServer(true) end)
                pcall(function() ReplicatedStorage.TreadmillSessionRemote:FireServer() end)
            end
            if ReplicatedStorage:FindFirstChild("SpeedGainRemote") then
                pcall(function() ReplicatedStorage.SpeedGainRemote:FireServer() end)
                pcall(function() ReplicatedStorage.SpeedGainRemote:FireServer(1) end)
            end
        end

        -- --------------------------------------------------------------------
        -- 4. FITUR LAINNYA
        -- --------------------------------------------------------------------
        if Config.BatAura then
            local bat = EquipToolByKeyword("Bat")
            if bat then pcall(function() bat:Activate() end) end
            if ReplicatedStorage:FindFirstChild("BatHitRequest") then
                pcall(function() ReplicatedStorage.BatHitRequest:FireServer() end)
            end
        end

        if Config.AutoUnlockTreadmill and ReplicatedStorage:FindFirstChild("UnlockTreadmillRequest") then
            pcall(function() ReplicatedStorage.UnlockTreadmillRequest:FireServer() end)
        end

        if Config.AutoSellPets and ReplicatedStorage:FindFirstChild("BackpackSellRemote") then
            pcall(function() ReplicatedStorage.BackpackSellRemote:InvokeServer() end)
        end

        if Config.AutoClaimRewards then
            if ReplicatedStorage:FindFirstChild("GroupRewardRemote") then pcall(function() ReplicatedStorage.GroupRewardRemote:FireServer() end) end
            if ReplicatedStorage:FindFirstChild("OfflineRewardRemote") then pcall(function() ReplicatedStorage.OfflineRewardRemote:FireServer() end) end
            if ReplicatedStorage:FindFirstChild("DiscordRewardRemote") then pcall(function() ReplicatedStorage.DiscordRewardRemote:FireServer() end) end
        end

        if Config.AutoPlaceAnimals and ReplicatedStorage:FindFirstChild("PlaceAnimalRemote") then
            pcall(function() ReplicatedStorage.PlaceAnimalRemote:FireServer() end)
        end
        if Config.AutoMergeMachine and ReplicatedStorage:FindFirstChild("MergeMachineRemote") then
            pcall(function() ReplicatedStorage.MergeMachineRemote:FireServer() end)
        end
        if Config.AutoFuseMachine and ReplicatedStorage:FindFirstChild("FuseMachineRequest") then
            pcall(function() ReplicatedStorage.FuseMachineRequest:FireServer() end)
        end
        if Config.AutoUpgradePlot and ReplicatedStorage:FindFirstChild("UpgradePlotRequest") then
            pcall(function() ReplicatedStorage.UpgradePlotRequest:FireServer() end)
        end
        if Config.AutoUpgradeTreadmill and ReplicatedStorage:FindFirstChild("UpgradeTreadmillRequest") then
            pcall(function() ReplicatedStorage.UpgradeTreadmillRequest:FireServer() end)
        end
        if Config.AutoMasterySwing and ReplicatedStorage:FindFirstChild("MasteryPickaxeSwing") then
            pcall(function() ReplicatedStorage.MasteryPickaxeSwing:FireServer() end)
        end
        if Config.AutoHalloweenCandy and ReplicatedStorage:FindFirstChild("HalloweenCandyDrops") then
            pcall(function() ReplicatedStorage.HalloweenCandyDrops:FireServer() end)
        end
        if Config.AutoHalloweenHeist and ReplicatedStorage:FindFirstChild("HalloweenCandyHeist") then
            pcall(function() ReplicatedStorage.HalloweenCandyHeist:FireServer() end)
        end
        if Config.AutoHalloweenDoors and ReplicatedStorage:FindFirstChild("HalloweenDoors") then
            pcall(function() ReplicatedStorage.HalloweenDoors:FireServer() end)
        end
    end
end)
