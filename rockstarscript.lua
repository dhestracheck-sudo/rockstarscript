-- Rockstar UI - Blue Theme (With Full Map Analyzer & Config System)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Hapus UI lama jika sudah ada
if PlayerGui:FindFirstChild("RockstarBlueUI") then
    PlayerGui.RockstarBlueUI:Destroy()
end

-- Tabel Penyimpanan Config
local Config = {
    FiturUtama = false,
    AutoAction = false,
    IncludeRemotes = true,
    IncludeNPCs = true,
    IncludeInteractables = true,
    IncludeZones = true,
    LastSaved = ""
}

-- Warna Tema Rockstar Blue
local Theme = {
    Background = Color3.fromRGB(13, 17, 26),
    Sidebar = Color3.fromRGB(18, 24, 38),
    Element = Color3.fromRGB(23, 31, 48),
    ElementHover = Color3.fromRGB(30, 41, 64),
    Accent = Color3.fromRGB(0, 140, 255),
    AccentBright = Color3.fromRGB(50, 180, 255),
    TextPrimary = Color3.fromRGB(240, 245, 255),
    TextSecondary = Color3.fromRGB(150, 165, 190),
    Stroke = Color3.fromRGB(35, 65, 110)
}

-- ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarBlueUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 390)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -195)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Topbar / Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 10)
TopBarCover.Position = UDim2.new(0, 0, 1, -10)
TopBarCover.BackgroundColor3 = Theme.Sidebar
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

local DividerLine = Instance.new("Frame")
DividerLine.Size = UDim2.new(1, 0, 0, 1)
DividerLine.Position = UDim2.new(0, 0, 1, -1)
DividerLine.BackgroundColor3 = Theme.Stroke
DividerLine.BorderSizePixel = 0
DividerLine.Parent = TopBar

-- Judul Rockstar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 250, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "★ ROCKSTAR HUB"
TitleLabel.TextColor3 = Theme.AccentBright
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 200, 1, 0)
SubTitle.Position = UDim2.new(0, 165, 0, 1)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "BLUE EDITION • FULL ANALYZER"
SubTitle.TextColor3 = Theme.TextSecondary
SubTitle.Font = Enum.Font.GothamSemibold
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar
SubTitle.Parent = TopBar

-- Tombol Minimize & Close
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -68, 0.5, -14)
MinimizeBtn.BackgroundColor3 = Theme.Element
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.TextPrimary
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 13
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextPrimary
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Container Body
local BodyFrame = Instance.new("Frame")
BodyFrame.Name = "BodyFrame"
BodyFrame.Size = UDim2.new(1, 0, 1, -42)
BodyFrame.Position = UDim2.new(0, 0, 0, 42)
BodyFrame.BackgroundTransparency = 1
BodyFrame.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -16)
Sidebar.Position = UDim2.new(0, 8, 0, 8)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = BodyFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = Theme.Stroke
SidebarStroke.Thickness = 1
SidebarStroke.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -179, 1, -16)
ContentContainer.Position = UDim2.new(0, 171, 0, 8)
ContentContainer.BackgroundColor3 = Theme.Sidebar
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = BodyFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentContainer

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = Theme.Stroke
ContentStroke.Thickness = 1
ContentStroke.Parent = ContentContainer

-- Sistem Dragging Window
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

-- Fungsi Minimize & Close
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 580, 0, 42) or UDim2.new(0, 580, 0, 390)
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Fungsi Pembuat Tab & Elemen
local Tabs = {}
local ToggleUpdaters = {}
local FirstTab = true

local function CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -16, 0, 34)
    TabButton.BackgroundColor3 = FirstTab and Theme.Accent or Theme.Element
    TabButton.Text = tabName
    TabButton.TextColor3 = FirstTab and Theme.TextPrimary or Theme.TextSecondary
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 13
    TabButton.AutoButtonColor = false
    TabButton.Parent = Sidebar

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabButton

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -16, 1, -16)
    Page.Position = UDim2.new(0, 8, 0, 8)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = FirstTab
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

    FirstTab = false
    table.insert(Tabs, {Button = TabButton, Page = Page})

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.Page.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Element,
                TextColor3 = Theme.TextSecondary
            }):Play()
        end
        Page.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Accent,
            TextColor3 = Theme.TextPrimary
        }):Play()
    end)

    local Elements = {}

    function Elements:AddLabel(text)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -6, 0, 22)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Theme.AccentBright
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Page
        return Lbl
    end

    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -6, 0, 36)
        Btn.BackgroundColor3 = Theme.Element
        Btn.Text = "  " .. text
        Btn.TextColor3 = Theme.TextPrimary
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 13
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.AutoButtonColor = false
        Btn.Parent = Page

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Btn

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Stroke
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ElementHover}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Element}):Play()
        end)
        Btn.MouseButton1Click:Connect(function()
            if callback then callback(Btn) end
        end)
        return Btn
    end

    function Elements:AddToggle(configKey, text, default, callback)
        local state = (Config[configKey] ~= nil) and Config[configKey] or (default or false)
        Config[configKey] = state

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -6, 0, 38)
        ToggleFrame.BackgroundColor3 = Theme.Element
        ToggleFrame.Parent = Page

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = ToggleFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Stroke
        Stroke.Thickness = 1
        Stroke.Parent = ToggleFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.TextPrimary
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local SwitchBg = Instance.new("TextButton")
        SwitchBg.Size = UDim2.new(0, 40, 0, 20)
        SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
        SwitchBg.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 55, 75)
        SwitchBg.Text = ""
        SwitchBg.AutoButtonColor = false
        SwitchBg.Parent = ToggleFrame

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = SwitchBg

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 14, 0, 14)
        Circle.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        Circle.BackgroundColor3 = Theme.TextPrimary
        Circle.Parent = SwitchBg

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = Circle

        local function SetState(newState)
            state = newState
            Config[configKey] = state
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 55, 75)
            }):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            }):Play()
            if callback then callback(state) end
        end

        SwitchBg.MouseButton1Click:Connect(function()
            SetState(not state)
        end)

        ToggleUpdaters[configKey] = SetState
    end

    function Elements:AddTextBox(placeholder, height)
        local BoxFrame = Instance.new("Frame")
        BoxFrame.Size = UDim2.new(1, -6, 0, height or 110)
        BoxFrame.BackgroundColor3 = Theme.Background
        BoxFrame.Parent = Page

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = BoxFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Stroke
        Stroke.Thickness = 1
        Stroke.Parent = BoxFrame

        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -16, 1, -12)
        Box.Position = UDim2.new(0, 8, 0, 6)
        Box.BackgroundTransparency = 1
        Box.Text = ""
        Box.PlaceholderText = placeholder
        Box.PlaceholderColor3 = Theme.TextSecondary
        Box.TextColor3 = Theme.TextPrimary
        Box.Font = Enum.Font.Code
        Box.TextSize = 11
        Box.TextXAlignment = Enum.TextXAlignment.Left
        Box.TextYAlignment = Enum.TextYAlignment.Top
        Box.TextWrapped = true
        Box.MultiLine = true
        Box.ClearTextOnFocus = false
        Box.Parent = BoxFrame

        return Box
    end

    return Elements
end

-- ==========================================
-- HELPER KOORDINAT OBJEK
-- ==========================================
local function GetObjectPosition(obj)
    if obj:IsA("BasePart") then
        local p = obj.Position
        return string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
    elseif obj:IsA("Model") then
        local ok, cf = pcall(function() return obj:GetPivot() end)
        if ok and cf then
            local p = cf.Position
            return string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        end
        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local p = part.Position
            return string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        end
    end
    return "N/A"
end

-- ==========================================
-- FUNGSI FULL MAP ANALYZER (SEMUA MAP)
-- ==========================================
local function GenerateFullMapAnalysis(statusLabel)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local playerPos = root and string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z) or "N/A"

    local gameName = "Unknown"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    local allZones = {}
    local allNPCs = {}
    local allInteractables = {}
    local allSpawns = {}
    local allToolsAndItems = {}
    local allRemotes = {}

    -- 1. Scan Semua Folder & Model Utama (Zones / Islands / Buildings)
    if Config.IncludeZones then
        if statusLabel then statusLabel.Text = "Status: Memindai Semua Zona & Folder Map..." end
        task.wait()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj ~= char and not Players:GetPlayerFromCharacter(obj) and obj.Name ~= "Terrain" and obj.Name ~= "Camera" then
                local subStructure = {}
                local childGroupCount = {}

                for _, sub in ipairs(obj:GetChildren()) do
                    local key = sub.Name .. " [" .. sub.ClassName .. "]"
                    childGroupCount[key] = (childGroupCount[key] or 0) + 1
                end

                for k, count in pairs(childGroupCount) do
                    local entry = count > 1 and (k .. " x" .. tostring(count)) or k
                    table.insert(subStructure, entry)
                end

                -- Ambil koordinat sub-area penting jika obj adalah Folder
                local subLocations = {}
                if obj:IsA("Folder") or obj:IsA("Model") then
                    for _, sub in ipairs(obj:GetChildren()) do
                        if sub:IsA("Model") or sub:IsA("BasePart") or sub:IsA("Folder") then
                            local pos = GetObjectPosition(sub)
                            if pos ~= "N/A" and #subLocations < 60 then
                                table.insert(subLocations, {
                                    Name = sub.Name,
                                    Position = pos
                                })
                            end
                        end
                    end
                end

                table.insert(allZones, {
                    Name = obj.Name,
                    Class = obj.ClassName,
                    Position = GetObjectPosition(obj),
                    TotalChildren = #obj:GetChildren(),
                    ChildrenSummary = subStructure,
                    SubLocations = subLocations
                })
            end
        end
    end

    -- 2. Scan Seluruh Descendants Workspace (NPC, Interactables, Spawns, Items)
    if statusLabel then statusLabel.Text = "Status: Memindai Seluruh Isi Map (NPC, Interaksi, Item)..." end
    task.wait()

    local descendants = workspace:GetDescendants()
    local seenInteractables = {}
    local seenNPCs = {}

    for i, desc in ipairs(descendants) do
        if i % 2500 == 0 then
            task.wait() -- Mencegah lag/freeze pada map berukuran besar
        end

        -- Deteksi Semua NPC (Model dengan Humanoid bukan Player)
        if Config.IncludeNPCs and desc:IsA("Humanoid") then
            local npcModel = desc.Parent
            if npcModel and npcModel:IsA("Model") and not Players:GetPlayerFromCharacter(npcModel) then
                local pos = GetObjectPosition(npcModel)
                local key = npcModel:GetFullName()
                if not seenNPCs[key] then
                    seenNPCs[key] = true
                    table.insert(allNPCs, {
                        Name = npcModel.Name,
                        Path = key,
                        Health = string.format("%.0f/%.0f", desc.Health, desc.MaxHealth),
                        Position = pos
                    })
                end
            end
        end

        -- Deteksi Semua Objek Interaktif (ProximityPrompt, ClickDetector, Seat)
        if Config.IncludeInteractables then
            if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
                local parent = desc.Parent
                local pos = parent and GetObjectPosition(parent) or "N/A"
                local parentPath = parent and parent:GetFullName() or "Nil"
                local key = desc.ClassName .. "|" .. parentPath
                if not seenInteractables[key] then
                    seenInteractables[key] = true
                    table.insert(allInteractables, {
                        Type = desc.ClassName,
                        ObjectName = parent and parent.Name or "Unknown",
                        Path = parentPath,
                        ActionText = desc:IsA("ProximityPrompt") and (desc.ActionText .. " (" .. desc.ObjectText .. ")") or "",
                        Position = pos
                    })
                end
            elseif desc:IsA("SpawnLocation") then
                table.insert(allSpawns, {
                    Name = desc.Name,
                    Path = desc:GetFullName(),
                    Position = GetObjectPosition(desc)
                })
            elseif desc:IsA("Tool") then
                table.insert(allToolsAndItems, {
                    Name = desc.Name,
                    Location = "Workspace",
                    Path = desc:GetFullName(),
                    Position = GetObjectPosition(desc)
                })
            end
        end
    end

    -- 3. Scan ReplicatedStorage (Remotes & Items)
    if Config.IncludeRemotes then
        if statusLabel then statusLabel.Text = "Status: Memindai ReplicatedStorage & Remotes..." end
        task.wait()
        for i, desc in ipairs(ReplicatedStorage:GetDescendants()) do
            if i % 2500 == 0 then
                task.wait()
            end
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") or desc:IsA("BindableEvent") then
                table.insert(allRemotes, {
                    Name = desc.Name,
                    Type = desc.ClassName,
                    Path = desc:GetFullName()
                })
            elseif desc:IsA("Tool") then
                table.insert(allToolsAndItems, {
                    Name = desc.Name,
                    Location = "ReplicatedStorage",
                    Path = desc:GetFullName()
                })
            end
        end
    end

    local fullReport = {
        GameInfo = {
            GameName = gameName,
            PlaceId = game.PlaceId,
            PlaceVersion = game.PlaceVersion,
            ScanTimestamp = os.date("%Y-%m-%d %H:%M:%S"),
            PlayerPosition = playerPos,
            TotalWorkspaceDescendants = #descendants
        },
        SummaryCounts = {
            TopZonesCount = #allZones,
            NPCsCount = #allNPCs,
            InteractablesCount = #allInteractables,
            SpawnsCount = #allSpawns,
            ToolsAndItemsCount = #allToolsAndItems,
            RemotesCount = #allRemotes
        },
        AllMapZones = allZones,
        AllNPCs = allNPCs,
        AllInteractables = allInteractables,
        AllSpawnLocations = allSpawns,
        AllToolsAndItems = allToolsAndItems,
        AllRemotes = allRemotes
    }

    if statusLabel then
        statusLabel.Text = string.format(
            "Status: Selesai! (Zona: %d | NPC: %d | Interaksi: %d | Remote: %d)",
            #allZones, #allNPCs, #allInteractables, #allRemotes
        )
    end

    return HttpService:JSONEncode(fullReport)
end

-- ==========================================
-- PEMBUATAN TAB & FITUR
-- ==========================================
local MainTab = CreateTab("Main")
local AnalyzerTab = CreateTab("Full Map Analyzer")
local ConfigTab = CreateTab("Config")

-- 1. Isi Tab Main
MainTab:AddLabel("Fitur Utama")
MainTab:AddToggle("FiturUtama", "Aktifkan Fitur Utama", false, function(val)
    print("Fitur Utama:", val)
end)

MainTab:AddToggle("AutoAction", "Auto Action", false, function(val)
    print("Auto Action:", val)
end)

-- 2. Isi Tab Full Map Analyzer
local AnalyzerStatus = AnalyzerTab:AddLabel("Status: Siap memindai seluruh map")
local OutputAnalyzerBox = AnalyzerTab:AddTextBox("Hasil Analisis Semua Map (JSON) akan muncul di sini...", 115)

AnalyzerTab:AddButton("🌍 Scan Semua Map Sekarang (Full Map Analysis)", function()
    task.spawn(function()
        local ok, result = pcall(GenerateFullMapAnalysis, AnalyzerStatus)
        if ok then
            OutputAnalyzerBox.Text = result
            if typeof(setclipboard) == "function" then
                pcall(setclipboard, result)
            end
            if typeof(writefile) == "function" then
                pcall(writefile, "Rockstar_FullMapAnalysis_" .. tostring(game.PlaceId) .. ".json", result)
            end
        else
            AnalyzerStatus.Text = "Status: Error saat scan"
            OutputAnalyzerBox.Text = "Gagal melakukan scan: " .. tostring(result)
        end
    end)
end)

AnalyzerTab:AddToggle("IncludeZones", "Sertakan Semua Zona / Pulau / Gedung", true)
AnalyzerTab:AddToggle("IncludeNPCs", "Sertakan Semua NPC & Karakter", true)
AnalyzerTab:AddToggle("IncludeInteractables", "Sertakan Semua Interaksi & Item", true)
AnalyzerTab:AddToggle("IncludeRemotes", "Sertakan Semua Remote ReplicatedStorage", true)

AnalyzerTab:AddButton("📍 Salin Posisi Karakter Saat Ini", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local cframeStr = string.format("CFrame.new(%.2f, %.2f, %.2f)", root.Position.X, root.Position.Y, root.Position.Z)
        OutputAnalyzerBox.Text = cframeStr
        AnalyzerStatus.Text = "Status: Koordinat karakter disalin!"
        if typeof(setclipboard) == "function" then
            pcall(setclipboard, cframeStr)
        end
    end
end)

-- 3. Isi Tab Config
ConfigTab:AddLabel("Manajemen Config (Export / Import JSON)")
local ConfigBox = ConfigTab:AddTextBox("Data JSON Config akan muncul di sini...", 110)

ConfigTab:AddButton("💾 Export / Salin Config JSON", function()
    Config.LastSaved = os.date("%Y-%m-%d %H:%M:%S")
    local json = HttpService:JSONEncode(Config)
    ConfigBox.Text = json
    if typeof(setclipboard) == "function" then
        pcall(setclipboard, json)
    end
    if typeof(writefile) == "function" then
        pcall(writefile, "Rockstar_Config_" .. tostring(game.PlaceId) .. ".json", json)
    end
end)

ConfigTab:AddButton("📂 Load / Terapkan Config dari Box", function()
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(ConfigBox.Text)
    end)
    if success and type(decoded) == "table" then
        for k, v in pairs(decoded) do
            Config[k] = v
            if ToggleUpdaters[k] and type(v) == "boolean" then
                ToggleUpdaters[k](v)
            end
        end
    end
end)
