if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

if playerGui:FindFirstChild("RockstarLynxUI") then
    playerGui.RockstarLynxUI:Destroy()
end

-- ==========================================
-- 1. TEMA WARNA (GAYA LYNX DARK-ORANGE)
-- ==========================================
local Theme = {
    MainBg       = Color3.fromRGB(20, 11, 7),
    SidebarBg    = Color3.fromRGB(16, 9, 5),
    CardBg       = Color3.fromRGB(28, 16, 10),
    InputBg      = Color3.fromRGB(36, 20, 12),
    ActiveTabBg  = Color3.fromRGB(38, 22, 14),
    Stroke       = Color3.fromRGB(68, 38, 22),
    Divider      = Color3.fromRGB(52, 28, 16),
    Accent       = Color3.fromRGB(255, 115, 0),
    TextWhite    = Color3.fromRGB(240, 235, 230),
    TextMuted    = Color3.fromRGB(175, 155, 140)
}

-- ==========================================
-- 2. DATA & KONFIGURASI FITUR
-- ==========================================
local AllZones = {
    "Path1", "Path2", "Path3", "Path4", "Path5",
    "Path6", "Path7", "Path8", "Path9", "Path10",
    "Path11", "Path12", "Path13", "Path14", "Path15",
    "Path16", "Path17", "Path18", "Path19", "Path20"
}

local AllCageRarities = {
    "AstralCage", "InfinityCage", "DivineCage", "EternalCage",
    "SecretCage", "CosmicCage", "MythicCage", "LegendaryCage",
    "EpicCage", "RareCage", "CommonCage"
}

local CageRank = {
    AstralCage = 11, InfinityCage = 10, DivineCage = 9, EternalCage = 8,
    SecretCage = 7, CosmicCage = 6, MythicCage = 5, LegendaryCage = 4,
    EpicCage = 3, RareCage = 2, CommonCage = 1,
    Astral = 11, Infinity = 10, Divine = 9, Eternal = 8,
    Secret = 7, Cosmic = 6, Mythic = 5, Legendary = 4,
    Epic = 3, Rare = 2, Common = 1
}

local Config = {
    SelectedZones = { ["Path11"] = true, ["Path12"] = true },
    SelectedCages = {},

    CustomSpeed = 300,          -- Bebas diatur tanpa batas clamp!
    UseCustomSpeed = false,     -- Jika OFF, pakai Speed asli Treadmill (50.000+) tanpa ketahan!
    DisableSlowMode = true,     -- Otomatis matikan SlowMode bawaan game
    ResetOnZoneChange = true,   -- Auto reset karakter saat ganti Zona

    MinPetSize = "0",
    MinCashPerSec = "200B",

    AutoStealCage = false,
    AutoPlaceBestCage = false,  -- Instan tanpa jalan
    AutoOpenCage = false,       -- Instan tanpa jalan
    AutoCollectCash = false,    -- Instan tanpa jalan

    AutoUpgradeBase = false,    -- Auto Upgrade Plot + Barn 2
    AutoUpgradeTreadmill = false,-- Auto Upgrade Treadmill

    AutoTrainTreadmill = false,
    AutoStealDNA = false,
    AutoEquipBest = false,
    AutoTapBoost = true,
    AutoBrewCauldron = false,

    WebhookURL = "",
    SavedBasePosition = nil
}

local WalkSessionId = 0
local function abortCurrentWalk(doResetChar)
    WalkSessionId += 1
    if doResetChar and Config.ResetOnZoneChange then
        pcall(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                hum.Health = 0
            end
        end)
    end
end

-- ==========================================
-- 3. PEMBUATAN FRAME UTAMA & TOPBAR
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarLynxUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 420)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.BackgroundTransparency = 0.06
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(0, 95, 1, 0)
BrandTitle.Position = UDim2.new(0, 16, 0, 0)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "Rockstar"
BrandTitle.TextColor3 = Theme.Accent
BrandTitle.Font = Enum.Font.GothamBlack
BrandTitle.TextSize = 20
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
BrandTitle.Parent = TopBar

local PlanetIcon = Instance.new("TextLabel")
PlanetIcon.Size = UDim2.new(0, 26, 1, 0)
PlanetIcon.Position = UDim2.new(0, 112, 0, 0)
PlanetIcon.BackgroundTransparency = 1
PlanetIcon.Text = "🪐"
PlanetIcon.TextColor3 = Theme.Accent
PlanetIcon.Font = Enum.Font.GothamBold
PlanetIcon.TextSize = 16
PlanetIcon.Parent = TopBar

local HeaderPipe = Instance.new("Frame")
HeaderPipe.Size = UDim2.new(0, 1, 0, 20)
HeaderPipe.Position = UDim2.new(0, 144, 0.5, -10)
HeaderPipe.BackgroundColor3 = Theme.Stroke
HeaderPipe.BorderSizePixel = 0
HeaderPipe.Parent = TopBar

local GameSubTitle = Instance.new("TextLabel")
GameSubTitle.Size = UDim2.new(0, 240, 1, 0)
GameSubTitle.Position = UDim2.new(0, 156, 0, 0)
GameSubTitle.BackgroundTransparency = 1
GameSubTitle.Text = "Steal & Escape Cage (Uncapped Speed)"
GameSubTitle.TextColor3 = Theme.TextWhite
GameSubTitle.Font = Enum.Font.GothamBold
GameSubTitle.TextSize = 14
GameSubTitle.TextXAlignment = Enum.TextXAlignment.Left
GameSubTitle.Parent = TopBar

local DiscordLabel = Instance.new("TextButton")
DiscordLabel.Size = UDim2.new(0, 175, 0, 28)
DiscordLabel.Position = UDim2.new(1, -235, 0.5, -14)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "👾 | discord.gg/rockstar"
DiscordLabel.TextColor3 = Theme.Accent
DiscordLabel.Font = Enum.Font.GothamBold
DiscordLabel.TextSize = 13
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Right
DiscordLabel.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 32)
MinBtn.Position = UDim2.new(1, -46, 0.5, -16)
MinBtn.BackgroundColor3 = Theme.CardBg
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Accent
MinBtn.Font = Enum.Font.GothamBlack
MinBtn.TextSize = 15
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 7)
local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = Theme.Stroke
MinStroke.Thickness = 1

local TopDivider = Instance.new("Frame")
TopDivider.Size = UDim2.new(1, 0, 0, 1)
TopDivider.Position = UDim2.new(0, 0, 0, 48)
TopDivider.BackgroundColor3 = Theme.Divider
TopDivider.BorderSizePixel = 0
TopDivider.Parent = MainFrame

-- Drag UI
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
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 680, 0, 48) or UDim2.new(0, 680, 0, 420)
    TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
end)

-- ==========================================
-- 4. SIDEBAR KIRI & SEARCH BAR
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 185, 1, -49)
Sidebar.Position = UDim2.new(0, 0, 0, 49)
Sidebar.BackgroundColor3 = Theme.SidebarBg
Sidebar.BackgroundTransparency = 0.3
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, -20, 0, 36)
SearchFrame.Position = UDim2.new(0, 10, 0, 10)
SearchFrame.BackgroundColor3 = Theme.CardBg
SearchFrame.Parent = Sidebar
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)
local SearchStroke = Instance.new("UIStroke", SearchFrame)
SearchStroke.Color = Theme.Stroke
SearchStroke.Thickness = 1

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 30, 1, 0)
SearchIcon.Position = UDim2.new(0, 6, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = Theme.TextMuted
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.TextSize = 13
SearchIcon.Parent = SearchFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -40, 1, 0)
SearchBox.Position = UDim2.new(0, 36, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Search feature..."
SearchBox.PlaceholderColor3 = Theme.TextMuted
SearchBox.Text = ""
SearchBox.TextColor3 = Theme.TextWhite
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchFrame

local TabListFrame = Instance.new("ScrollingFrame")
TabListFrame.Size = UDim2.new(1, -16, 1, -60)
TabListFrame.Position = UDim2.new(0, 8, 0, 54)
TabListFrame.BackgroundTransparency = 1
TabListFrame.BorderSizePixel = 0
TabListFrame.ScrollBarThickness = 0
TabListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
TabListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabListFrame.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout", TabListFrame)
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==========================================
-- 5. AREA KONTEN KANAN
-- ==========================================
local RightArea = Instance.new("Frame")
RightArea.Size = UDim2.new(1, -195, 1, -49)
RightArea.Position = UDim2.new(0, 195, 0, 49)
RightArea.BackgroundTransparency = 1
RightArea.Parent = MainFrame

local SubHeader = Instance.new("Frame")
SubHeader.Size = UDim2.new(1, -15, 0, 42)
SubHeader.Position = UDim2.new(0, 5, 0, 4)
SubHeader.BackgroundTransparency = 1
SubHeader.Parent = RightArea

local SubAccentBar = Instance.new("Frame")
SubAccentBar.Size = UDim2.new(0, 4, 0, 20)
SubAccentBar.Position = UDim2.new(0, 0, 0.5, -10)
SubAccentBar.BackgroundColor3 = Theme.Accent
SubAccentBar.BorderSizePixel = 0
SubAccentBar.Parent = SubHeader
Instance.new("UICorner", SubAccentBar).CornerRadius = UDim.new(0, 2)

local SubHeaderTitle = Instance.new("TextLabel")
SubHeaderTitle.Size = UDim2.new(1, -20, 1, 0)
SubHeaderTitle.Position = UDim2.new(0, 14, 0, 0)
SubHeaderTitle.BackgroundTransparency = 1
SubHeaderTitle.Text = "Main"
SubHeaderTitle.TextColor3 = Theme.TextWhite
SubHeaderTitle.Font = Enum.Font.GothamBold
SubHeaderTitle.TextSize = 16
SubHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
SubHeaderTitle.Parent = SubHeader

local SubDivider = Instance.new("Frame")
SubDivider.Size = UDim2.new(1, 0, 0, 1)
SubDivider.Position = UDim2.new(0, 0, 1, -1)
SubDivider.BackgroundColor3 = Theme.Divider
SubDivider.BorderSizePixel = 0
SubDivider.Parent = SubHeader

local PagesHolder = Instance.new("Frame")
PagesHolder.Size = UDim2.new(1, -10, 1, -52)
PagesHolder.Position = UDim2.new(0, 5, 0, 50)
PagesHolder.BackgroundTransparency = 1
PagesHolder.Parent = RightArea

-- ==========================================
-- 6. BUILDER TAB & ELEMEN UI
-- ==========================================
local Tabs = {}
local SearchableElements = {}

local function createTab(tabName, iconText, order, isDefault)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.BackgroundColor3 = Theme.ActiveTabBg
    TabBtn.BackgroundTransparency = isDefault and 0 or 1
    TabBtn.Text = ""
    TabBtn.LayoutOrder = order
    TabBtn.Parent = TabListFrame
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    local LeftBar = Instance.new("Frame")
    LeftBar.Size = UDim2.new(0, 3, 0, 20)
    LeftBar.Position = UDim2.new(0, 0, 0.5, -10)
    LeftBar.BackgroundColor3 = Theme.Accent
    LeftBar.BorderSizePixel = 0
    LeftBar.Visible = isDefault
    LeftBar.Parent = TabBtn
    Instance.new("UICorner", LeftBar).CornerRadius = UDim.new(0, 2)

    local IconLbl = Instance.new("TextLabel")
    IconLbl.Size = UDim2.new(0, 28, 1, 0)
    IconLbl.Position = UDim2.new(0, 10, 0, 0)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text = iconText
    IconLbl.TextColor3 = isDefault and Theme.Accent or Theme.TextMuted
    IconLbl.Font = Enum.Font.GothamBold
    IconLbl.TextSize = 15
    IconLbl.Parent = TabBtn

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -45, 1, 0)
    TitleLbl.Position = UDim2.new(0, 42, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = tabName
    TitleLbl.TextColor3 = isDefault and Theme.TextWhite or Theme.TextMuted
    TitleLbl.Font = isDefault and Enum.Font.GothamBold or Enum.Font.GothamMedium
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = isDefault
    Page.Parent = PagesHolder

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local PagePad = Instance.new("UIPadding", Page)
    PagePad.PaddingRight = UDim.new(0, 10)
    PagePad.PaddingBottom = UDim.new(0, 14)

    local tabData = {
        Name = tabName, Btn = TabBtn, Bar = LeftBar,
        Icon = IconLbl, Title = TitleLbl, Page = Page
    }
    table.insert(Tabs, tabData)

    TabBtn.MouseButton1Click:Connect(function()
        SubHeaderTitle.Text = tabName
        for _, t in ipairs(Tabs) do
            local active = (t == tabData)
            t.Btn.BackgroundTransparency = active and 0 or 1
            t.Bar.Visible = active
            t.Icon.TextColor3 = active and Theme.Accent or Theme.TextMuted
            t.Title.TextColor3 = active and Theme.TextWhite or Theme.TextMuted
            t.Title.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium
            t.Page.Visible = active
        end
    end)

    return Page
end

local function createInfoCard(page, text, order)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 74)
    Card.BackgroundColor3 = Theme.CardBg
    Card.BackgroundTransparency = 0.25
    Card.LayoutOrder = order
    Card.Parent = page
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Theme.Stroke
    Stroke.Thickness = 1

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -24, 1, -16)
    Desc.Position = UDim2.new(0, 12, 0, 8)
    Desc.BackgroundTransparency = 1
    Desc.Text = text
    Desc.TextColor3 = Theme.TextMuted
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 13
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextYAlignment = Enum.TextYAlignment.Top
    Desc.Parent = Card
end

local function createMultiDropdown(page, labelText, optionsList, selectedTable, order, onChanged)
    local Wrapper = Instance.new("Frame")
    Wrapper.Size = UDim2.new(1, 0, 0, 42)
    Wrapper.AutomaticSize = Enum.AutomaticSize.Y
    Wrapper.BackgroundTransparency = 1
    Wrapper.LayoutOrder = order
    Wrapper.Parent = page
    table.insert(SearchableElements, {Frame = Wrapper, Text = string.lower(labelText)})

    local TopRow = Instance.new("Frame")
    TopRow.Size = UDim2.new(1, 0, 0, 40)
    TopRow.BackgroundTransparency = 1
    TopRow.Parent = Wrapper

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.52, -10, 1, 0)
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopRow

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0.46, 0, 0, 36)
    DropBtn.Position = UDim2.new(0.54, 0, 0.5, -18)
    DropBtn.BackgroundColor3 = Theme.CardBg
    DropBtn.Text = ""
    DropBtn.Parent = TopRow
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 8)
    local DropStroke = Instance.new("UIStroke", DropBtn)
    DropStroke.Color = Theme.Stroke
    DropStroke.Thickness = 1

    local SelectedText = Instance.new("TextLabel")
    SelectedText.Size = UDim2.new(1, -34, 1, 0)
    SelectedText.Position = UDim2.new(0, 12, 0, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.TextColor3 = Theme.TextWhite
    SelectedText.Font = Enum.Font.GothamBold
    SelectedText.TextSize = 13
    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
    SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
    SelectedText.Parent = DropBtn

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 24, 1, 0)
    Arrow.Position = UDim2.new(1, -26, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Theme.Accent
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 11
    Arrow.Parent = DropBtn

    local ListContainer = Instance.new("Frame")
    ListContainer.Size = UDim2.new(0.46, 0, 0, 0)
    ListContainer.Position = UDim2.new(0.54, 0, 0, 42)
    ListContainer.AutomaticSize = Enum.AutomaticSize.Y
    ListContainer.BackgroundColor3 = Theme.SidebarBg
    ListContainer.Visible = false
    ListContainer.Parent = Wrapper
    Instance.new("UICorner", ListContainer).CornerRadius = UDim.new(0, 8)
    local ListStroke = Instance.new("UIStroke", ListContainer)
    ListStroke.Color = Theme.Stroke
    ListStroke.Thickness = 1

    local ListLayout = Instance.new("UIListLayout", ListContainer)
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ListPad = Instance.new("UIPadding", ListContainer)
    ListPad.PaddingTop = UDim.new(0, 6)
    ListPad.PaddingBottom = UDim.new(0, 6)
    ListPad.PaddingLeft = UDim.new(0, 6)
    ListPad.PaddingRight = UDim.new(0, 6)

    local function refreshSummary()
        local active = {}
        for _, opt in ipairs(optionsList) do
            if selectedTable[opt] then
                table.insert(active, (string.gsub(opt, "Cage", "")))
            end
        end
        if #active == 0 then
            SelectedText.Text = "All (Empty)"
            SelectedText.TextColor3 = Theme.TextMuted
        else
            SelectedText.Text = table.concat(active, ", ")
            SelectedText.TextColor3 = Theme.TextWhite
        end
    end

    for idx, opt in ipairs(optionsList) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 26)
        OptBtn.BackgroundColor3 = Theme.ActiveTabBg
        OptBtn.BackgroundTransparency = selectedTable[opt] and 0 or 1
        OptBtn.Text = "  " .. (selectedTable[opt] and "☑ " or "☐ ") .. opt
        OptBtn.TextColor3 = selectedTable[opt] and Theme.Accent or Theme.TextMuted
        OptBtn.Font = Enum.Font.GothamBold
        OptBtn.TextSize = 12
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.LayoutOrder = idx
        OptBtn.Parent = ListContainer
        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 5)

        OptBtn.MouseButton1Click:Connect(function()
            selectedTable[opt] = not selectedTable[opt]
            OptBtn.BackgroundTransparency = selectedTable[opt] and 0 or 1
            OptBtn.Text = "  " .. (selectedTable[opt] and "☑ " or "☐ ") .. opt
            OptBtn.TextColor3 = selectedTable[opt] and Theme.Accent or Theme.TextMuted
            refreshSummary()
            if onChanged then
                onChanged(opt, selectedTable[opt])
            end
        end)
    end

    refreshSummary()

    DropBtn.MouseButton1Click:Connect(function()
        ListContainer.Visible = not ListContainer.Visible
        Arrow.Text = ListContainer.Visible and "▲" or "▼"
    end)
end

local function createInputRow(page, labelText, defaultText, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = page
    table.insert(SearchableElements, {Frame = Row, Text = string.lower(labelText)})

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.52, -10, 1, 0)
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local InputBg = Instance.new("Frame")
    InputBg.Size = UDim2.new(0.46, 0, 0, 36)
    InputBg.Position = UDim2.new(0.54, 0, 0.5, -18)
    InputBg.BackgroundColor3 = Theme.InputBg
    InputBg.Parent = Row
    Instance.new("UICorner", InputBg).CornerRadius = UDim.new(0, 8)

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -24, 1, 0)
    Box.Position = UDim2.new(0, 12, 0, 0)
    Box.BackgroundTransparency = 1
    Box.Text = defaultText
    Box.TextColor3 = Theme.TextWhite
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 13
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    Box.Parent = InputBg

    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

local function createToggleRow(page, labelText, defaultVal, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = page
    table.insert(SearchableElements, {Frame = Row, Text = string.lower(labelText)})

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, -10, 1, 0)
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 90, 0, 34)
    ToggleBtn.Position = UDim2.new(1, -90, 0.5, -17)
    ToggleBtn.BackgroundColor3 = defaultVal and Theme.Accent or Theme.InputBg
    ToggleBtn.Text = defaultVal and "ENABLED" or "DISABLED"
    ToggleBtn.TextColor3 = defaultVal and Color3.fromRGB(255, 255, 255) or Theme.TextMuted
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 12
    ToggleBtn.Parent = Row
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
    local TStroke = Instance.new("UIStroke", ToggleBtn)
    TStroke.Color = Theme.Stroke
    TStroke.Thickness = 1

    local state = defaultVal
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Theme.Accent or Theme.InputBg
        ToggleBtn.Text = state and "ENABLED" or "DISABLED"
        ToggleBtn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Theme.TextMuted
        callback(state)
    end)
end

local function createActionRow(page, labelText, btnText, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = page
    table.insert(SearchableElements, {Frame = Row, Text = string.lower(labelText)})

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, -10, 1, 0)
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActBtn = Instance.new("TextButton")
    ActBtn.Size = UDim2.new(0, 120, 0, 34)
    ActBtn.Position = UDim2.new(1, -120, 0.5, -17)
    ActBtn.BackgroundColor3 = Theme.CardBg
    ActBtn.Text = btnText
    ActBtn.TextColor3 = Theme.Accent
    ActBtn.Font = Enum.Font.GothamBold
    ActBtn.TextSize = 12
    ActBtn.Parent = Row
    Instance.new("UICorner", ActBtn).CornerRadius = UDim.new(0, 8)
    local AStroke = Instance.new("UIStroke", ActBtn)
    AStroke.Color = Theme.Accent
    AStroke.Thickness = 1

    ActBtn.MouseButton1Click:Connect(function()
        callback(ActBtn)
    end)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBox.Text)
    for _, item in ipairs(SearchableElements) do
        if q == "" or string.find(item.Text, q, 1, true) then
            item.Frame.Visible = true
        else
            item.Frame.Visible = false
        end
    end
end)

-- ==========================================
-- 7. MEMBANGUN 7 TAB MENU
-- ==========================================
local MainPage       = createTab("Main",       "🏠", 1, true)
local AutomationPage = createTab("Automation", "⏭", 2, false)
local ShopPage       = createTab("Shop",       "🛒", 3, false)
local EventPage      = createTab("Event",      "⭐", 4, false)
local WebhookPage    = createTab("Webhook",    "➤", 5, false)
local SettingsPage   = createTab("Settings",   "⚙", 6, false)
local ConfigPage     = createTab("Config",     "↻", 7, false)

-- [TAB 1: MAIN]
createInfoCard(
    MainPage,
    "Direct Uncapped Speed Run (No 4-stud Pathfinding brakes & Auto-Disables Game SlowMode!). Supports your full 50,000+ Treadmill Speed or Custom Speed Override.",
    1
)

createMultiDropdown(MainPage, "Zones (empty = all)", AllZones, Config.SelectedZones, 2, function()
    abortCurrentWalk(Config.AutoStealCage)
end)

createMultiDropdown(MainPage, "Cage Rarities (empty = all)", AllCageRarities, Config.SelectedCages, 3, function()
    abortCurrentWalk(false)
end)

createToggleRow(MainPage, "Auto Steal & Escape Cage (Full Speed)", false, 4, function(v)
    Config.AutoStealCage = v
    if not v then abortCurrentWalk(false) end
end)

createToggleRow(MainPage, "Auto Place Best Cage (No Walk / Instant)", false, 5, function(v)
    Config.AutoPlaceBestCage = v
end)

createToggleRow(MainPage, "Auto Open Cage (No Walk / Instant)", false, 6, function(v)
    Config.AutoOpenCage = v
end)

createToggleRow(MainPage, "Auto Collect Cash (No Walk / Instant)", false, 7, function(v)
    Config.AutoCollectCash = v
end)

createToggleRow(MainPage, "Auto Upgrade Base (Plot & Barn 2)", false, 8, function(v)
    Config.AutoUpgradeBase = v
end)

createToggleRow(MainPage, "Auto Upgrade Treadmill", false, 9, function(v)
    Config.AutoUpgradeTreadmill = v
end)

createInputRow(MainPage, "Custom Speed Value (Uncapped)", "500", 10, function(v)
    Config.CustomSpeed = tonumber(v) or 500
end)

createToggleRow(MainPage, "Enable Custom Speed Override", false, 11, function(v)
    Config.UseCustomSpeed = v
end)

-- [TAB 2: AUTOMATION]
createInfoCard(
    AutomationPage,
    "All Plot, Upgrade, and Barn features run automatically in the background from anywhere on the map without walking.",
    1
)
createToggleRow(AutomationPage, "Auto Place Best Cage (Instant)", false, 2, function(v) Config.AutoPlaceBestCage = v end)
createToggleRow(AutomationPage, "Auto Open Cages (Instant)", false, 3, function(v) Config.AutoOpenCage = v end)
createToggleRow(AutomationPage, "Auto Collect CashPad (Instant)", false, 4, function(v) Config.AutoCollectCash = v end)
createToggleRow(AutomationPage, "Auto Upgrade Base (Plot & Barn 2)", false, 5, function(v) Config.AutoUpgradeBase = v end)
createToggleRow(AutomationPage, "Auto Upgrade Treadmill", false, 6, function(v) Config.AutoUpgradeTreadmill = v end)
createToggleRow(AutomationPage, "Auto TapBoost & Disable SlowMode", true, 7, function(v)
    Config.AutoTapBoost = v
    Config.DisableSlowMode = v
end)
createToggleRow(AutomationPage, "Auto Equip Best Pets", false, 8, function(v) Config.AutoEquipBest = v end)
createToggleRow(AutomationPage, "Auto Train Speed on My Treadmill", false, 9, function(v) Config.AutoTrainTreadmill = v end)

-- [TAB 3: SHOP]
createInfoCard(
    ShopPage,
    "Remotely upgrades your Base Plot, Barn 2, and Treadmill or sells unlocked pets.",
    1
)
createToggleRow(ShopPage, "Auto Upgrade Base (Plot & Barn 2)", false, 2, function(v) Config.AutoUpgradeBase = v end)
createToggleRow(ShopPage, "Auto Upgrade Treadmill", false, 3, function(v) Config.AutoUpgradeTreadmill = v end)
createActionRow(ShopPage, "Sell All Unlocked Pets", "SELL ALL", 4, function(btn)
    pcall(function() Remotes.SellAllPets:FireServer() end)
    btn.Text = "SOLD!"
    task.wait(1)
    if btn.Parent then btn.Text = "SELL ALL" end
end)

-- [TAB 4: EVENT]
createInfoCard(
    EventPage,
    "Halloween Event automation: Auto Brew at the Witch's Cauldron remotely.",
    1
)
createToggleRow(EventPage, "Auto Brew Witch's Cauldron", false, 2, function(v) Config.AutoBrewCauldron = v end)

-- [TAB 5: WEBHOOK]
createInfoCard(
    WebhookPage,
    "Send notifications to your Discord Webhook whenever you steal High-Rarity Cages.",
    1
)
createInputRow(WebhookPage, "Discord Webhook URL", "", 2, function(v) Config.WebhookURL = v end)

-- [TAB 6: SETTINGS]
createInfoCard(
    SettingsPage,
    "Configure Auto Reset on Zone change and set your Plot's Base position.",
    1
)
createToggleRow(SettingsPage, "Auto Reset Character When Changing Zones", true, 2, function(v)
    Config.ResetOnZoneChange = v
end)
createActionRow(SettingsPage, "Set Current Position as My Plot / Base", "SET BASE", 3, function(btn)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        Config.SavedBasePosition = hrp.Position
        btn.Text = "SAVED!"
        task.wait(1)
        if btn.Parent then btn.Text = "SET BASE" end
    end
end)

-- [TAB 7: CONFIG]
createInfoCard(
    ConfigPage,
    "Reset your saved Plot position.",
    1
)
createActionRow(ConfigPage, "Reset Saved Plot Position", "RESET", 2, function(btn)
    Config.SavedBasePosition = nil
    btn.Text = "DONE!"
    task.wait(1)
    if btn.Parent then btn.Text = "RESET" end
end)

-- ==========================================
-- 8. KECEPATAN PENUH TANPA REM (UNCAPPED SPEED)
-- ==========================================
RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent then return end
    if not Config.UseCustomSpeed then return end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then
        hum.WalkSpeed = Config.CustomSpeed
        if hum.MoveDirection.Magnitude > 0.05 then
            local vel = hum.MoveDirection * Config.CustomSpeed
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, hrp.AssemblyLinearVelocity.Y, vel.Z)
        end
    end
end)

-- ==========================================
-- 9. FUNGSI HELPER
-- ==========================================
local function isTableEmpty(t)
    for _, v in pairs(t) do
        if v then return false end
    end
    return true
end

local function usePromptSafely(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return end
    if typeof(fireproximityprompt) == "function" then
        pcall(fireproximityprompt, prompt)
    end
    local holdTime = prompt.HoldDuration or 0
    prompt:InputHoldBegin()
    if holdTime > 0 then
        task.wait(holdTime + 0.05)
    else
        task.wait(0.08)
    end
    prompt:InputHoldEnd()
end

local function firePromptRemote(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return end
    if typeof(fireproximityprompt) == "function" then
        pcall(fireproximityprompt, prompt)
    else
        prompt:InputHoldBegin()
        task.wait()
        prompt:InputHoldEnd()
    end
end

local function equipBestCageInBackpack()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    if not hum or not backpack then return nil end

    local bestTool = nil
    local bestScore = -1

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            for k, score in pairs(CageRank) do
                if string.find(string.lower(item.Name), string.lower(k)) and score > bestScore then
                    bestScore = score
                    bestTool = item
                end
            end
        end
    end

    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local matchedScore = 0
            for k, score in pairs(CageRank) do
                if string.find(string.lower(item.Name), string.lower(k)) and score > matchedScore then
                    matchedScore = score
                end
            end
            if matchedScore > bestScore then
                bestScore = matchedScore
                bestTool = item
            end
        end
    end

    if bestTool and bestTool.Parent == backpack then
        pcall(function() hum:EquipTool(bestTool) end)
    end
    return bestTool
end

local function getMyPlot()
    local plots = workspace:FindFirstChild("Hub") and workspace.Hub:FindFirstChild("Plots")
    if not plots then return nil end

    local pName = string.lower(player.Name)
    local pDisp = string.lower(player.DisplayName)

    for _, plot in ipairs(plots:GetChildren()) do
        for _, attrVal in pairs(plot:GetAttributes()) do
            local s = string.lower(tostring(attrVal))
            if s == pName or s == pDisp or attrVal == player.UserId then
                return plot
            end
        end

        local ownerDisp = plot:FindFirstChild("OwnerDisplay")
        if ownerDisp then
            for _, d in ipairs(ownerDisp:GetDescendants()) do
                if d:IsA("TextLabel") then
                    local txt = string.lower(d.Text)
                    if string.find(txt, pName, 1, true) or string.find(txt, pDisp, 1, true) then
                        return plot
                    end
                end
            end
        end
    end

    local refPos = Config.SavedBasePosition
    if not refPos then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        refPos = hrp and hrp.Position
    end

    if refPos then
        local closestPlot = nil
        local shortestDist = math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            local btn = plot:FindFirstChild("CashPad") and plot.CashPad:FindFirstChild("Button")
            if btn and btn:IsA("BasePart") then
                local dist = (btn.Position - refPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlot = plot
                end
            end
        end
        return closestPlot
    end

    return nil
end

local function getBasePosition()
    if Config.SavedBasePosition then
        return Config.SavedBasePosition
    end
    local myPlot = getMyPlot()
    if myPlot then
        local btn = myPlot:FindFirstChild("CashPad") and myPlot.CashPad:FindFirstChild("Button")
        if btn and btn:IsA("BasePart") then
            return btn.Position
        end
    end
    local safeZone = workspace:FindFirstChild("World2") and workspace.World2:FindFirstChild("SafeZone")
    if safeZone and safeZone:IsA("BasePart") then
        return safeZone.Position
    end
    return nil
end

-- LARI LURUS KECEPATAN PENUH (TANPA REM PATHFINDING 4 STUD!)
local function fastDirectWalkTo(targetPos, stopDist, maxTime, checkFlagFunc)
    local mySession = WalkSessionId
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    stopDist = stopDist or 6
    maxTime = maxTime or 25
    local startTime = os.clock()

    -- Matikan SlowMode bawaan game sebelum lari agar speed 50.000 keluar penuh!
    if Config.DisableSlowMode then
        pcall(function() Remotes.SetSlowMode:FireServer(false) end)
    end

    while ScreenGui.Parent and mySession == WalkSessionId and (os.clock() - startTime) < maxTime do
        if checkFlagFunc and not checkFlagFunc() then return false end
        char = player.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return false end

        local flatDiff = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
        local flatDist = flatDiff.Magnitude

        -- Anti-Overshoot: Jika jarak sudah dekat (atau kecepatan sangat tinggi), langsung rem tepat di titik target
        local dynamicStopDist = math.max(stopDist, math.min(hum.WalkSpeed * 0.08, 14))
        if flatDist <= dynamicStopDist then
            hum:MoveTo(hrp.Position)
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            return true
        end

        hum:MoveTo(targetPos)
        RunService.Heartbeat:Wait()
    end

    return false
end

local function findTargetCage()
    local pathsFolder = workspace:FindFirstChild("Paths")
    if not pathsFolder then return nil, nil end

    local allZonesAllowed = isTableEmpty(Config.SelectedZones)
    local allCagesAllowed = isTableEmpty(Config.SelectedCages)
    local list = {}

    for _, pathFolder in ipairs(pathsFolder:GetChildren()) do
        if allZonesAllowed or Config.SelectedZones[pathFolder.Name] then
            local cagesFolder = pathFolder:FindFirstChild("Cages")
            if cagesFolder then
                for _, cage in ipairs(cagesFolder:GetChildren()) do
                    if cage:IsA("Model") and (allCagesAllowed or Config.SelectedCages[cage.Name]) then
                        table.insert(list, {
                            cage = cage,
                            pathFolder = pathFolder,
                            rank = CageRank[cage.Name] or 1
                        })
                    end
                end
            end
        end
    end

    table.sort(list, function(a, b) return a.rank > b.rank end)

    for _, item in ipairs(list) do
        local root = item.cage:FindFirstChild("Root")
        local prompt = root and root:FindFirstChild("StealPrompt")
        if not root or (prompt and prompt.Enabled) then
            return item.cage, item.pathFolder
        end
    end
    return nil, nil
end

local function getCageTargetPosition(cage, pathFolder)
    local root = cage:FindFirstChild("Root")
    if root and root:IsA("BasePart") then return root.Position end

    local ok, pivot = pcall(function() return cage:GetPivot() end)
    if ok and pivot and pivot.Position.Magnitude > 1 then return pivot.Position end

    local spots = pathFolder:FindFirstChild("CageSpots")
    local spot = spots and spots:GetChildren()[1]
    if spot and spot:IsA("BasePart") then return spot.Position end

    local floor = pathFolder:FindFirstChild("Ground") and pathFolder.Ground:FindFirstChild("Floor")
    if floor then
        local okF, fPivot = pcall(function() return floor:GetPivot() end)
        if okF and fPivot then return fPivot.Position end
    end
    return nil
end

-- ==========================================
-- 10. LOOP BACKGROUND INSTAN (TANPA WALK!)
-- Collect Cash, Place Best Cage, Open Cage, Upgrade Base & Treadmill
-- ==========================================
local originalCashPadCF = nil

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.7)
        pcall(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Pastikan SlowMode selalu mati agar lari tetap kencang
            if Config.DisableSlowMode then
                pcall(function() Remotes.SetSlowMode:FireServer(false) end)
            end

            local myPlot = getMyPlot()

            -- [1] AUTO COLLECT CASH (TANPA WALK)
            if Config.AutoCollectCash and myPlot then
                local cashBtn = myPlot:FindFirstChild("CashPad") and myPlot.CashPad:FindFirstChild("Button")
                if cashBtn and cashBtn:IsA("BasePart") then
                    if not originalCashPadCF then
                        originalCashPadCF = cashBtn.CFrame
                    end
                    cashBtn.CanCollide = false
                    cashBtn.CFrame = hrp.CFrame
                    if typeof(firetouchinterest) == "function" then
                        pcall(firetouchinterest, hrp, cashBtn, 0)
                        pcall(firetouchinterest, hrp, cashBtn, 1)
                    end
                    pcall(function() Remotes.CashCollected:FireServer() end)
                    task.wait(0.12)
                    if originalCashPadCF then
                        cashBtn.CFrame = originalCashPadCF
                    end
                end
            end

            -- [2] AUTO PLACE BEST CAGE (TANPA WALK)
            if Config.AutoPlaceBestCage and myPlot then
                local bestTool = equipBestCageInBackpack()
                for _, barnName in ipairs({"Barn", "Barn2"}) do
                    local barn = myPlot:FindFirstChild(barnName)
                    local stalls = barn and barn:FindFirstChild("Stalls")
                    if stalls then
                        for _, stall in ipairs(stalls:GetChildren()) do
                            local stallNum = tonumber(string.match(stall.Name, "%d+"))
                            local anchor = stall:FindFirstChild("PenPromptAnchor")
                            local penPrompt = anchor and anchor:FindFirstChild("PenPrompt")
                            if penPrompt and penPrompt.Enabled then
                                firePromptRemote(penPrompt)
                            end
                            if stallNum then
                                pcall(function() Remotes.PlaceCage:FireServer(stallNum) end)
                                if bestTool then
                                    pcall(function() Remotes.PlaceCage:FireServer(stallNum, bestTool.Name) end)
                                end
                            end
                            pcall(function() Remotes.PlaceCage:FireServer(stall.Name) end)
                        end
                    end
                end
            end

            -- [3] AUTO OPEN CAGE (TANPA WALK)
            if Config.AutoOpenCage and myPlot then
                pcall(function() Remotes.OpenNow:FireServer() end)

                local plotCages = myPlot:FindFirstChild("Cages")
                if plotCages then
                    for _, cageModel in ipairs(plotCages:GetChildren()) do
                        local cleanId = string.gsub(cageModel.Name, "^Away_", "")
                        pcall(function() Remotes.OpenCage:FireServer(cageModel.Name) end)
                        pcall(function() Remotes.OpenCage:FireServer(cleanId) end)

                        local prompt = cageModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            firePromptRemote(prompt)
                        end
                    end
                end

                for _, barnName in ipairs({"Barn", "Barn2"}) do
                    local barn = myPlot:FindFirstChild(barnName)
                    local stalls = barn and barn:FindFirstChild("Stalls")
                    if stalls then
                        for _, stall in ipairs(stalls:GetChildren()) do
                            local stallNum = tonumber(string.match(stall.Name, "%d+"))
                            if stallNum then
                                pcall(function() Remotes.OpenCage:FireServer(stallNum) end)
                            end
                            pcall(function() Remotes.OpenCage:FireServer(stall.Name) end)

                            local anchor = stall:FindFirstChild("PenPromptAnchor")
                            local penPrompt = anchor and anchor:FindFirstChild("PenPrompt")
                            if penPrompt and penPrompt.Enabled then
                                firePromptRemote(penPrompt)
                            end
                        end
                    end
                end
            end

            -- [4] AUTO UPGRADE BASE (PLOT & BARN 2) & TREADMILL
            if Config.AutoUpgradeBase then
                pcall(function()
                    Remotes.UpgradePlot:FireServer()
                    Remotes.UpgradeBarn2:FireServer()
                end)
            end
            if Config.AutoUpgradeTreadmill then
                pcall(function()
                    Remotes.UpgradeTreadmill:FireServer()
                end)
            end

            -- [5] TAPBOOST, EQUIPBEST, BREW
            if Config.AutoTapBoost then pcall(function() Remotes.TapBoost:FireServer() end) end
            if Config.AutoEquipBest then pcall(function() Remotes.EquipBest:FireServer() end) end
            if Config.AutoBrewCauldron then pcall(function() Remotes.Brew:FireServer() end) end
        end)
    end
end)

-- ==========================================
-- 11. LOOP UTAMA LARI CEPAT (STEAL CAGE & TREADMILL)
-- ==========================================
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.15)
        pcall(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end

            if Config.AutoStealCage then
                local mySession = WalkSessionId
                local basePos = getBasePosition() or hrp.Position
                local cage, pathFolder = findTargetCage()

                if cage and pathFolder and mySession == WalkSessionId then
                    local targetPos = getCageTargetPosition(cage, pathFolder)
                    if targetPos then
                        fastDirectWalkTo(targetPos, 8, 25, function() return Config.AutoStealCage end)

                        local root = cage:FindFirstChild("Root")
                        if root and root:IsA("BasePart") and mySession == WalkSessionId then
                            local reached = fastDirectWalkTo(root.Position, 6, 8, function() return Config.AutoStealCage end)
                            if reached then
                                local stealPrompt = root:FindFirstChild("StealPrompt") or root:FindFirstChildOfClass("ProximityPrompt")
                                if stealPrompt and stealPrompt.Enabled then
                                    usePromptSafely(stealPrompt)
                                    task.wait(0.12)
                                end
                            end
                        end

                        if mySession == WalkSessionId then
                            fastDirectWalkTo(basePos, 6, 25, function() return Config.AutoStealCage end)
                            task.wait(0.2)
                        end
                    end
                end
            elseif Config.AutoTrainTreadmill then
                local myPlot = getMyPlot()
                local tread = myPlot and myPlot:FindFirstChild("Treadmill")
                local anchor = tread and tread:FindFirstChild("LabelAnchor")
                if anchor and anchor:IsA("BasePart") then
                    fastDirectWalkTo(anchor.Position, 4, 15, function() return Config.AutoTrainTreadmill end)
                end
            end
        end)
    end
end)
