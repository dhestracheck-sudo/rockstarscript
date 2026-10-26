if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================================================
-- 1. FUNGSI UNIVERSAL ALL-MAP SCANNER (ANTI-TERPOTONG)
-- =========================================================
local function openUniversalMapScanner()
    if playerGui:FindFirstChild("RockstarAllMapScanner") then
        playerGui.RockstarAllMapScanner:Destroy()
    end

    local function copyToClipboard(text)
        local copyFunc = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
        if typeof(copyFunc) == "function" then
            local ok = pcall(copyFunc, text)
            if ok then return true end
        end
        return false
    end

    local function runUniversalScan()
        local lines = {}
        local function log(str) table.insert(lines, str) end
        local function isPlayerChar(inst) return Players:GetPlayerFromCharacter(inst) ~= nil end

        local function formatAttributes(inst)
            local ok, attrs = pcall(function() return inst:GetAttributes() end)
            if not ok or not attrs then return "" end
            local list = {}
            for k, v in pairs(attrs) do
                if k ~= "RBX_ReimportId" and k ~= "ArchimedesID" then
                    table.insert(list, tostring(k) .. "=" .. tostring(v))
                end
            end
            return #list > 0 and (" {Attr: " .. table.concat(list, ", ") .. "}") or ""
        end

        local gameName = "Unknown Game"
        pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

        log("==========================================")
        log("ROCKSTAR UNIVERSAL ALL-MAP SCANNER")
        log("Game Name : " .. tostring(gameName))
        log("PlaceId   : " .. tostring(game.PlaceId))
        log("GameId    : " .. tostring(game.GameId))
        log("==========================================\n")

        log("=== [1] DATA PLAYER & INVENTORY ===")
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            for _, v in ipairs(ls:GetChildren()) do
                log(string.format("- leaderstats.%s [%s] = %s", v.Name, v.ClassName, tostring(v.Value)))
            end
        end
        local pAttrs = formatAttributes(player)
        if pAttrs ~= "" then log("- Player" .. pAttrs) end
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                log(string.format("- Backpack Tool: %s [%s]%s", tool.Name, tool.ClassName, formatAttributes(tool)))
            end
        end

        log("\n=== [2] STRUKTUR HIERARKI WORKSPACE ===")
        local ignoredFolderNames = {
            ["InitialPoses"] = true,
            ["AnimSaves"] = true
        }
        local function dumpTree(parent, indent, depth)
            if depth > 4 then return end
            local groups, order = {}, {}
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name ~= "Camera" and child.Name ~= "Terrain" and not ignoredFolderNames[child.Name] and not isPlayerChar(child) then
                    local cleanName = child.Name
                    if #cleanName >= 30 and string.find(cleanName, "%-") then
                        cleanName = "<UUID_Object>"
                    end
                    local key = cleanName .. "|" .. child.ClassName
                    if not groups[key] then
                        groups[key] = { sample = child, count = 0 }
                        table.insert(order, key)
                    end
                    groups[key].count += 1
                end
            end
            for _, key in ipairs(order) do
                local g = groups[key]
                local obj = g.sample
                local countStr = g.count > 1 and string.format(" (x%d)", g.count) or ""
                local extra = formatAttributes(obj)
                if obj:IsA("ValueBase") and not obj:IsA("CFrameValue") then
                    extra = " = " .. tostring(obj.Value) .. extra
                elseif obj:IsA("ProximityPrompt") then
                    extra = string.format(" [Act:'%s' | Obj:'%s']", obj.ActionText, obj.ObjectText) .. extra
                end
                local hasChildren = #obj:GetChildren() > 0
                local isImportant = obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("ProximityPrompt")
                    or obj:IsA("ClickDetector") or obj:IsA("TouchTransmitter") or extra ~= ""
                if isImportant or hasChildren or depth <= 2 then
                    log(string.format("%s|- %s [%s]%s%s", indent, obj.Name, obj.ClassName, countStr, extra))
                    if hasChildren then dumpTree(obj, indent .. "  ", depth + 1) end
                end
            end
        end
        dumpTree(workspace, "", 1)

        log("\n=== [3] PROXIMITY PROMPTS & CLICK DETECTORS ===")
        local interactGroups = {}
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local pat = string.gsub(v:GetFullName(), "%d+", "#")
                if not interactGroups[pat] then
                    interactGroups[pat] = {
                        count = 0, sample = v:GetFullName(),
                        info = string.format("ProximityPrompt | Act:'%s' | Obj:'%s' | Parent:%s", v.ActionText, v.ObjectText, v.Parent and v.Parent.ClassName or "Nil")
                    }
                end
                interactGroups[pat].count += 1
            elseif v:IsA("ClickDetector") then
                local pat = string.gsub(v:GetFullName(), "%d+", "#")
                if not interactGroups[pat] then
                    interactGroups[pat] = {
                        count = 0, sample = v:GetFullName(),
                        info = "ClickDetector | Parent:" .. (v.Parent and v.Parent.ClassName or "Nil")
                    }
                end
                interactGroups[pat].count += 1
            end
        end
        for _, d in pairs(interactGroups) do
            log(string.format("[%dx] %s\n   -> %s", d.count, d.sample, d.info))
        end

        log("\n=== [4] TOUCH INTEREST (SENSOR INJAK/SENTUH) ===")
        local touches = {}
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("TouchTransmitter") and v.Parent then
                local part = v.Parent
                local model = part:FindFirstAncestorOfClass("Model")
                if not (model and isPlayerChar(model)) then
                    local pat = string.gsub(part:GetFullName(), "%d+", "#")
                    if not touches[pat] then
                        touches[pat] = { count = 0, sample = part:GetFullName() }
                    end
                    touches[pat].count += 1
                end
            end
        end
        for _, d in pairs(touches) do log(string.format("[%dx] %s", d.count, d.sample)) end

        log("\n=== [5] REMOTES DI REPLICATEDSTORAGE ===")
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                log(string.format("- %s [%s]", v:GetFullName(), v.ClassName))
            end
        end

        return table.concat(lines, "\n")
    end

    local ScannerGui = Instance.new("ScreenGui")
    ScannerGui.Name = "RockstarAllMapScanner"
    ScannerGui.ResetOnSpawn = false
    ScannerGui.Parent = playerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 580, 0, 390)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -195)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 11, 7)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScannerGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(68, 38, 22)
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 0, 36)
    Title.Position = UDim2.new(0, 16, 0, 4)
    Title.BackgroundTransparency = 1
    Title.Text = "Rockstar | Universal All-Map Scanner"
    Title.TextColor3 = Color3.fromRGB(255, 115, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 26)
    CloseBtn.Position = UDim2.new(1, -40, 0, 9)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = MainFrame
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function() ScannerGui:Destroy() end)

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -32, 0, 20)
    StatusLabel.Position = UDim2.new(0, 16, 0, 36)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Status: Memindai seluruh map..."
    StatusLabel.TextColor3 = Color3.fromRGB(180, 220, 180)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    local OutputScroll = Instance.new("ScrollingFrame")
    OutputScroll.Size = UDim2.new(1, -32, 1, -115)
    OutputScroll.Position = UDim2.new(0, 16, 0, 58)
    OutputScroll.BackgroundColor3 = Color3.fromRGB(14, 8, 5)
    OutputScroll.BorderSizePixel = 0
    OutputScroll.ScrollBarThickness = 5
    OutputScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 115, 0)
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    OutputScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OutputScroll.Parent = MainFrame
    Instance.new("UICorner", OutputScroll).CornerRadius = UDim.new(0, 8)

    local OutputBox = Instance.new("TextBox")
    OutputBox.Size = UDim2.new(1, -16, 0, 0)
    OutputBox.Position = UDim2.new(0, 8, 0, 8)
    OutputBox.AutomaticSize = Enum.AutomaticSize.Y
    OutputBox.BackgroundTransparency = 1
    OutputBox.Text = "Sedang memindai seluruh map..."
    OutputBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    OutputBox.Font = Enum.Font.Code
    OutputBox.TextSize = 12
    OutputBox.TextXAlignment = Enum.TextXAlignment.Left
    OutputBox.TextYAlignment = Enum.TextYAlignment.Top
    OutputBox.TextWrapped = true
    OutputBox.ClearTextOnFocus = false
    OutputBox.TextEditable = false
    OutputBox.MultiLine = true
    OutputBox.Parent = OutputScroll

    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0.48, -16, 0, 36)
    CopyBtn.Position = UDim2.new(0, 16, 1, -46)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 115, 0)
    CopyBtn.Text = "SALIN KE CLIPBOARD"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextSize = 13
    CopyBtn.Parent = MainFrame
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 8)

    local RescanBtn = Instance.new("TextButton")
    RescanBtn.Size = UDim2.new(0.48, -16, 0, 36)
    RescanBtn.Position = UDim2.new(0.52, 0, 1, -46)
    RescanBtn.BackgroundColor3 = Color3.fromRGB(38, 22, 14)
    RescanBtn.Text = "SCAN ULANG MAP"
    RescanBtn.TextColor3 = Color3.fromRGB(240, 235, 230)
    RescanBtn.Font = Enum.Font.GothamBold
    RescanBtn.TextSize = 13
    RescanBtn.Parent = MainFrame
    Instance.new("UICorner", RescanBtn).CornerRadius = UDim.new(0, 8)

    local currentReport = ""
    local function executeScan()
        StatusLabel.Text = "Status: Sedang memindai seluruh map..."
        task.wait(0.1)
        currentReport = runUniversalScan()
        OutputBox.Text = currentReport
        if copyToClipboard(currentReport) then
            StatusLabel.Text = "Status: Otomatis Tersalin ke Clipboard! Tinggal Paste (Ctrl+V)."
        else
            StatusLabel.Text = "Status: Selesai! Klik SALIN KE CLIPBOARD di bawah."
        end
    end

    CopyBtn.MouseButton1Click:Connect(function()
        if copyToClipboard(currentReport) then
            CopyBtn.Text = "BERHASIL DISALIN!"
            StatusLabel.Text = "Status: Berhasil disalin ke Clipboard! Tinggal Ctrl+V."
        else
            OutputBox:CaptureFocus()
            OutputBox.SelectionStart = 1
            OutputBox.CursorPosition = #currentReport + 1
            CopyBtn.Text = "TEKS DIBLOK (CTRL+C)"
        end
        task.wait(1.5)
        if CopyBtn.Parent then CopyBtn.Text = "SALIN KE CLIPBOARD" end
    end)

    RescanBtn.MouseButton1Click:Connect(function()
        RescanBtn.Text = "MEMINDAI..."
        executeScan()
        RescanBtn.Text = "SCAN ULANG MAP"
    end)

    task.spawn(executeScan)
end

-- =========================================================
-- 2. BUILDER UI LYNX ROCKSTAR (DIGUNAKAN OLEH SEMUA MAP)
-- =========================================================
local function createRockstarWindow(subTitleText)
    if playerGui:FindFirstChild("RockstarLynxUI") then
        playerGui.RockstarLynxUI:Destroy()
    end

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
    GameSubTitle.Size = UDim2.new(0, 260, 1, 0)
    GameSubTitle.Position = UDim2.new(0, 156, 0, 0)
    GameSubTitle.BackgroundTransparency = 1
    GameSubTitle.Text = subTitleText
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

    local Tabs = {}
    local SearchableElements = {}

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(SearchBox.Text)
        for _, item in ipairs(SearchableElements) do
            item.Frame.Visible = (q == "" or string.find(item.Text, q, 1, true) ~= nil)
        end
    end)

    local UI = { ScreenGui = ScreenGui }

    function UI:CreateTab(tabName, iconText, order, isDefault)
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

        local tabData = { Name = tabName, Btn = TabBtn, Bar = LeftBar, Icon = IconLbl, Title = TitleLbl, Page = Page }
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

    function UI:CreateInfoCard(page, text, order)
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

    function UI:CreateMultiDropdown(page, labelText, optionsList, selectedTable, order, onChanged)
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
                if onChanged then onChanged(opt, selectedTable[opt]) end
            end)
        end

        refreshSummary()
        DropBtn.MouseButton1Click:Connect(function()
            ListContainer.Visible = not ListContainer.Visible
            Arrow.Text = ListContainer.Visible and "▲" or "▼"
        end)
    end

    function UI:CreateInputRow(page, labelText, defaultText, order, callback)
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

        Box.FocusLost:Connect(function() callback(Box.Text) end)
    end

    function UI:CreateToggleRow(page, labelText, defaultVal, order, callback)
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

    function UI:CreateActionRow(page, labelText, btnText, order, callback)
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

        ActBtn.MouseButton1Click:Connect(function() callback(ActBtn) end)
    end

    return UI
end

-- =========================================================
-- 3. MAP 2: [🎃] PANJAT UNTUK TELUR HEWAN 🥚 (PlaceId: 85738654635245)
-- =========================================================
if game.PlaceId == 85738654635245 then
    local UI = createRockstarWindow("Climb & Steal Animal Eggs 🥚")
    local ScreenGui = UI.ScreenGui

    local AllEggZones = {
        "WitchDrops", "Witches Castle", "Pumpkin Abyss", "Bone Field",
        "Forbidden Forest", "Realm of Legends", "Celestial", "Divine Heights",
        "Mystic Isles", "PreHistoric", "Jungle", "Winter",
        "Desert", "Crystal Mines", "Ocean", "Forest"
    }

    local AllEggRarities = {
        "Astral", "Celestial", "Radiant", "Eternal",
        "Divine", "Legendary", "Rare", "Uncommon", "Common"
    }

    local AllEggVariants = {
        "Golden", "Rainbow", "Shiny", "Mutated", "Normal"
    }

    local RarityScore = {
        Astral = 9, Celestial = 8, Radiant = 7, Eternal = 6,
        Divine = 5, Legendary = 4, Rare = 3, Uncommon = 2, Common = 1
    }

    local EggConfig = {
        SelectedZones = { ["WitchDrops"] = true, ["Forbidden Forest"] = true, ["Witches Castle"] = true, ["Pumpkin Abyss"] = true },
        SelectedRarities = { ["Astral"] = true, ["Celestial"] = true, ["Radiant"] = true, ["Eternal"] = true, ["Divine"] = true },
        SelectedVariants = {},
        MinSizeScale = 0,
        MinWeightKg = 0,
        WalkSpeedBoost = 160,
        UseSpeedBoost = false,

        AutoStealEgg = false,
        UseTeleportMode = true, -- Teleport langsung ke telur & kembali ke Base Home
        AutoPlaceAndHatch = false,
        AutoCollectBaseCash = false,
        AutoTrainTreadmill = false,
        AutoFarmMiniMonsters = false,
        SavedBasePosition = nil
    }

    local MainPage       = UI:CreateTab("Main",       "🏠", 1, true)
    local AutomationPage = UI:CreateTab("Automation", "⏭", 2, false)
    local ShopPage       = UI:CreateTab("Shop",       "🛒", 3, false)
    local EventPage      = UI:CreateTab("Event",      "⭐", 4, false)
    local WebhookPage    = UI:CreateTab("Webhook",    "➤", 5, false)
    local SettingsPage   = UI:CreateTab("Settings",   "⚙", 6, false)
    local ConfigPage     = UI:CreateTab("Config",     "↻", 7, false)

    -- [TAB 1: MAIN]
    UI:CreateInfoCard(
        MainPage,
        "Finds spawned Animal Eggs in Workspace.SpawnedEggs matching your picked Zones, Rarities, Variants, Min Size, and WeightKg, grabs them, and banks them at your Base!",
        1
    )
    UI:CreateMultiDropdown(MainPage, "Zones (empty = all)", AllEggZones, EggConfig.SelectedZones, 2)
    UI:CreateMultiDropdown(MainPage, "Animal Rarities (empty = all)", AllEggRarities, EggConfig.SelectedRarities, 3)
    UI:CreateMultiDropdown(MainPage, "Egg Variants (empty = all)", AllEggVariants, EggConfig.SelectedVariants, 4)
    UI:CreateInputRow(MainPage, "Min Animal Size (AssetScale x)", "0", 5, function(v)
        EggConfig.MinSizeScale = tonumber(v) or 0
    end)
    UI:CreateInputRow(MainPage, "Min Egg Weight (Kg)", "0", 6, function(v)
        EggConfig.MinWeightKg = tonumber(v) or 0
    end)
    UI:CreateToggleRow(MainPage, "Auto Steal & Bank Animal Eggs", false, 7, function(v)
        EggConfig.AutoStealEgg = v
    end)
    UI:CreateToggleRow(MainPage, "Use Instant Teleport to Egg & Base", true, 8, function(v)
        EggConfig.UseTeleportMode = v
    end)

    -- [TAB 2: AUTOMATION]
    UI:CreateInfoCard(
        AutomationPage,
        "Automatically places carried Eggs at your Base, hatches ready Eggs in PlacedEggs, collects money from Animals, and trains on your Treadmill.",
        1
    )
    UI:CreateToggleRow(AutomationPage, "Auto Place & Hatch Eggs at Base", false, 2, function(v)
        EggConfig.AutoPlaceAndHatch = v
    end)
    UI:CreateToggleRow(AutomationPage, "Auto Collect Base Animals Cash", false, 3, function(v)
        EggConfig.AutoCollectBaseCash = v
    end)
    UI:CreateToggleRow(AutomationPage, "Auto Train on My Treadmill", false, 4, function(v)
        EggConfig.AutoTrainTreadmill = v
    end)
    UI:CreateActionRow(AutomationPage, "Claim Group Reward Chest", "CLAIM", 5, function()
        local chestPrompt = workspace:FindFirstChild("Scoreboard")
            and workspace.Scoreboard:FindFirstChild("Chest")
            and workspace.Scoreboard.Chest:FindFirstChild("Hitbox")
            and workspace.Scoreboard.Chest.Hitbox:FindFirstChild("GroupRewardPrompt")
        if chestPrompt and typeof(fireproximityprompt) == "function" then
            pcall(fireproximityprompt, chestPrompt)
        end
    end)

    -- [TAB 3: SHOP & TELEPORTS]
    UI:CreateInfoCard(
        ShopPage,
        "Teleport directly to Sell Animals, Mutate Machine, Event Shop, or Trails Shop.",
        1
    )
    UI:CreateActionRow(ShopPage, "Teleport to Sell Animals", "TELEPORT", 2, function()
        local hit = workspace:FindFirstChild("Tends") and workspace.Tends:FindFirstChild("SellAnimals") and workspace.Tends.SellAnimals:FindFirstChild("Hitbox")
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hit and hrp then hrp.CFrame = hit.CFrame * CFrame.new(0, 3, 0) end
    end)
    UI:CreateActionRow(ShopPage, "Teleport to Mutate Machine", "TELEPORT", 3, function()
        local hit = workspace:FindFirstChild("MutateMachine") and workspace.MutateMachine:FindFirstChild("Hitbox")
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hit and hrp then hrp.CFrame = hit.CFrame * CFrame.new(0, 3, 0) end
    end)
    UI:CreateActionRow(ShopPage, "Teleport to Event Shop", "TELEPORT", 4, function()
        local hit = workspace:FindFirstChild("EventShop") and workspace.EventShop:FindFirstChild("BaseMap")
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hit and hrp then hrp.CFrame = hit.CFrame * CFrame.new(0, 4, 0) end
    end)

    -- [TAB 4: EVENT HALLOWEEN]
    UI:CreateInfoCard(
        EventPage,
        "Halloween Dimension features: Auto Farm ActiveMiniMonsters (CoffinMonster, Pumpkin, Gargoyle) with your Bat and enter Halloween Portal.",
        1
    )
    UI:CreateToggleRow(EventPage, "Auto Farm Halloween Mini-Monsters", false, 2, function(v)
        EggConfig.AutoFarmMiniMonsters = v
    end)
    UI:CreateActionRow(EventPage, "Enter Halloween Dimension Portal", "TELEPORT", 3, function()
        local trig = workspace:FindFirstChild("HalloweenDimension")
            and workspace.HalloweenDimension:FindFirstChild("Portals")
            and workspace.HalloweenDimension.Portals:FindFirstChild("LobbyToHalloween")
            and workspace.HalloweenDimension.Portals.LobbyToHalloween:FindFirstChild("Trigger")
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if trig and hrp then hrp.CFrame = trig.CFrame * CFrame.new(0, 3, 0) end
    end)

    -- [TAB 5: WEBHOOK]
    UI:CreateInfoCard(WebhookPage, "Discord Webhook notifications for Astral, Celestial & Radiant Eggs.", 1)
    UI:CreateInputRow(WebhookPage, "Discord Webhook URL", "", 2, function() end)

    -- [TAB 6: SETTINGS]
    UI:CreateInfoCard(SettingsPage, "Adjust Custom Speed or save your Base Home position.", 1)
    UI:CreateInputRow(SettingsPage, "Custom WalkSpeed Value", "160", 2, function(v)
        EggConfig.WalkSpeedBoost = tonumber(v) or 160
    end)
    UI:CreateToggleRow(SettingsPage, "Enable Custom WalkSpeed", false, 3, function(v)
        EggConfig.UseSpeedBoost = v
    end)
    UI:CreateActionRow(SettingsPage, "Set Current Position as My Base", "SET BASE", 4, function(btn)
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            EggConfig.SavedBasePosition = hrp.Position
            btn.Text = "SAVED!"
            task.wait(1)
            if btn.Parent then btn.Text = "SET BASE" end
        end
    end)

    -- [TAB 7: CONFIG]
    UI:CreateInfoCard(ConfigPage, "Launch Universal All-Map Scanner to inspect any new updates or remotes.", 1)
    UI:CreateActionRow(ConfigPage, "Open Universal All-Map Scanner", "SCAN MAP", 2, function()
        openUniversalMapScanner()
    end)

    -- HELPER FUNGSI MAP 2
    local function isEmpty(t)
        for _, v in pairs(t) do if v then return false end end
        return true
    end

    -- Mencari Base milik pemain di Workspace.Structures.Bases
    local function getMyEggBase()
        local bases = workspace:FindFirstChild("Structures") and workspace.Structures:FindFirstChild("Bases")
        if not bases then return nil end

        local pName = string.lower(player.Name)
        local pDisp = string.lower(player.DisplayName)

        for _, base in ipairs(bases:GetChildren()) do
            -- 1. Cek Attribute OwnerUserId pada Treadmill di dalam Base
            local treadFolder = base:FindFirstChild("Treadmill")
            if treadFolder then
                for _, tm in ipairs(treadFolder:GetChildren()) do
                    if tm:GetAttribute("OwnerUserId") == player.UserId then
                        return base
                    end
                end
            end
            -- 2. Cek teks PlayerName di BaseOwner / Home
            for _, partName in ipairs({"BaseOwner", "Home"}) do
                local p = base:FindFirstChild(partName)
                if p then
                    for _, lbl in ipairs(p:GetDescendants()) do
                        if lbl:IsA("TextLabel") then
                            local txt = string.lower(lbl.Text)
                            if string.find(txt, pName, 1, true) or string.find(txt, pDisp, 1, true) then
                                return base
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local function getMyBaseHomeCFrame()
        if EggConfig.SavedBasePosition then
            return CFrame.new(EggConfig.SavedBasePosition)
        end
        local myBase = getMyEggBase()
        if myBase then
            local home = myBase:FindFirstChild("Home") or myBase:FindFirstChild("BaseOwner")
            if home and home:IsA("BasePart") then
                return home.CFrame * CFrame.new(0, 3, 0)
            end
        end
        local safeZone = workspace:FindFirstChild("Structures")
            and workspace.Structures:FindFirstChild("Others")
            and workspace.Structures.Others:FindFirstChild("Arrows")
            and workspace.Structures.Others.Arrows:FindFirstChild("SafeZone")
        if safeZone and safeZone:IsA("BasePart") then
            return safeZone.CFrame * CFrame.new(0, 3, 0)
        end
        return nil
    end

    local function triggerEggPrompt(modelOrPart)
        if not modelOrPart then return end
        for _, d in ipairs(modelOrPart:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                pcall(function()
                    d.HoldDuration = 0
                    d.MaxActivationDistance = 45
                    d.RequiresLineOfSight = false
                end)
                if typeof(fireproximityprompt) == "function" then
                    pcall(fireproximityprompt, d)
                end
                pcall(function()
                    d:InputHoldBegin()
                    task.wait(0.06)
                    d:InputHoldEnd()
                end)
            end
        end
    end

    local function findBestSpawnedEgg()
        local spawnedEggs = workspace:FindFirstChild("SpawnedEggs")
        if not spawnedEggs then return nil end

        local allZones = isEmpty(EggConfig.SelectedZones)
        local allRarities = isEmpty(EggConfig.SelectedRarities)
        local allVariants = isEmpty(EggConfig.SelectedVariants)
        local candidates = {}

        for _, biomeFolder in ipairs(spawnedEggs:GetChildren()) do
            if allZones or EggConfig.SelectedZones[biomeFolder.Name] then
                for _, eggModel in ipairs(biomeFolder:GetChildren()) do
                    if eggModel:IsA("Model") and eggModel.Name ~= "Nest" then
                        local hitbox = eggModel:FindFirstChild("Hitbox")
                        if hitbox and hitbox:IsA("BasePart") then
                            local rarity = tostring(eggModel:GetAttribute("Rarity") or "Common")
                            local variant = tostring(eggModel:GetAttribute("Variant") or "Normal")
                            local scale = tonumber(eggModel:GetAttribute("AssetScale")) or 0
                            local weight = tonumber(eggModel:GetAttribute("WeightKg")) or 0

                            local rarityOk = allRarities or EggConfig.SelectedRarities[rarity]
                            local variantOk = allVariants or EggConfig.SelectedVariants[variant]
                            local scaleOk = (scale >= EggConfig.MinSizeScale)
                            local weightOk = (weight >= EggConfig.MinWeightKg)

                            if rarityOk and variantOk and scaleOk and weightOk then
                                local score = (RarityScore[rarity] or 1) * 1000 + weight * 0.001
                                if biomeFolder.Name == "WitchDrops" then
                                    score += 50000 -- Prioritas utama drop Boss Witch
                                end
                                table.insert(candidates, {
                                    egg = eggModel,
                                    hitbox = hitbox,
                                    score = score
                                })
                            end
                        end
                    end
                end
            end
        end

        table.sort(candidates, function(a, b) return a.score > b.score end)
        return candidates[1]
    end

    RunService.Heartbeat:Connect(function()
        if not ScreenGui.Parent or not EggConfig.UseSpeedBoost then return end
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum.WalkSpeed = EggConfig.WalkSpeedBoost
        end
    end)

    -- LOOP UTAMA MAP 2 (PANJAT UNTUK TELUR HEWAN)
    task.spawn(function()
        while ScreenGui.Parent do
            task.wait(0.2)
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                -- 1. AUTO STEAL & BANK ANIMAL EGGS
                if EggConfig.AutoStealEgg then
                    local baseCF = getMyBaseHomeCFrame() or hrp.CFrame
                    local target = findBestSpawnedEgg()

                    if target and target.hitbox and target.hitbox.Parent then
                        pcall(function() player:RequestStreamAroundAsync(target.hitbox.Position, 2) end)

                        if EggConfig.UseTeleportMode then
                            hrp.CFrame = target.hitbox.CFrame * CFrame.new(0, 3, 0)
                            task.wait(0.18)
                            triggerEggPrompt(target.egg)
                            task.wait(0.15)
                            -- Kembali ke Base Home untuk menyimpan telur
                            hrp.CFrame = baseCF
                            task.wait(0.25)
                            local myBase = getMyEggBase()
                            if myBase then
                                triggerEggPrompt(myBase)
                            end
                        else
                            hum:MoveTo(target.hitbox.Position)
                            if (hrp.Position - target.hitbox.Position).Magnitude <= 10 then
                                triggerEggPrompt(target.egg)
                                task.wait(0.15)
                                hum:MoveTo(baseCF.Position)
                            end
                        end
                    end
                end

                -- 2. AUTO PLACE & HATCH EGGS DI BASE
                if EggConfig.AutoPlaceAndHatch then
                    local myBase = getMyEggBase()
                    if myBase then
                        triggerEggPrompt(myBase)
                        local placedEggs = myBase:FindFirstChild("PlacedEggs")
                        if placedEggs then
                            for _, pEgg in ipairs(placedEggs:GetChildren()) do
                                triggerEggPrompt(pEgg)
                            end
                        end
                    end
                end

                -- 3. AUTO COLLECT BASE CASH
                if EggConfig.AutoCollectBaseCash then
                    local myBase = getMyEggBase()
                    if myBase then
                        local home = myBase:FindFirstChild("Home")
                        if home and home:IsA("BasePart") and typeof(firetouchinterest) == "function" then
                            pcall(firetouchinterest, hrp, home, 0)
                            pcall(firetouchinterest, hrp, home, 1)
                        end
                        local animals = myBase:FindFirstChild("Animals")
                        if animals then
                            for _, anim in ipairs(animals:GetChildren()) do
                                triggerEggPrompt(anim)
                            end
                        end
                    end
                end

                -- 4. AUTO FARM HALLOWEEN MINI MONSTERS
                if EggConfig.AutoFarmMiniMonsters and not EggConfig.AutoStealEgg then
                    local monsters = workspace:FindFirstChild("HalloweenDimension")
                        and workspace.HalloweenDimension:FindFirstChild("ActiveMiniMonsters")
                    if monsters then
                        for _, mob in ipairs(monsters:GetChildren()) do
                            local hp = tonumber(mob:GetAttribute("Health")) or 0
                            local part = mob:FindFirstChildWhichIsA("BasePart")
                            if hp > 0 and part then
                                -- Equip Bat jika ada di Backpack
                                local bat = player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Bat")
                                if bat then pcall(function() hum:EquipTool(bat) end) end
                                local heldTool = char:FindFirstChildOfClass("Tool")
                                hrp.CFrame = part.CFrame * CFrame.new(0, 0, 3.5)
                                if heldTool then pcall(function() heldTool:Activate() end) end
                                break
                            end
                        end
                    end
                end

                -- 5. AUTO TRAIN TREADMILL
                if EggConfig.AutoTrainTreadmill and not EggConfig.AutoStealEgg then
                    local myBase = getMyEggBase()
                    local treadFolder = myBase and myBase:FindFirstChild("Treadmill")
                    local treadModel = treadFolder and treadFolder:GetChildren()[1]
                    if treadModel then
                        local ok, piv = pcall(function() return treadModel:GetPivot() end)
                        if ok and piv then
                            hum:MoveTo(piv.Position)
                        end
                    end
                end
            end)
        end
    end)

    return
end

-- =========================================================
-- 4. JIKA BUKAN MAP 1 ATAU MAP 2 -> OTOMATIS BUKA SCANNER
-- =========================================================
if game.PlaceId ~= 95168737547508 then
    openUniversalMapScanner()
    return
end

-- =========================================================
-- 5. MAP 1: STEAL & ESCAPE CAGE (PlaceId: 95168737547508)
-- =========================================================
local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local UI = createRockstarWindow("Steal & Escape Cage")
local ScreenGui = UI.ScreenGui

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
    CustomSpeed = 500,
    UseCustomSpeed = false,
    DisableSlowMode = true,
    ResetOnZoneChange = true,
    AutoStealCage = false,
    AutoPlaceBestCage = false,
    AutoOpenCage = false,
    AutoCollectCash = false,
    AutoUpgradeBase = false,
    AutoUpgradeTreadmill = false,
    AutoTrainTreadmill = false,
    AutoTapBoost = true,
    AutoEquipBest = false,
    AutoBrewCauldron = false,
    SavedBasePosition = nil
}

local WalkSessionId = 0
local function abortCurrentWalk(doResetChar)
    WalkSessionId += 1
    if doResetChar and Config.ResetOnZoneChange then
        pcall(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum.Health = 0 end
        end)
    end
end

local MainPage       = UI:CreateTab("Main",       "🏠", 1, true)
local AutomationPage = UI:CreateTab("Automation", "⏭", 2, false)
local ShopPage       = UI:CreateTab("Shop",       "🛒", 3, false)
local EventPage      = UI:CreateTab("Event",      "⭐", 4, false)
local WebhookPage    = UI:CreateTab("Webhook",    "➤", 5, false)
local SettingsPage   = UI:CreateTab("Settings",   "⚙", 6, false)
local ConfigPage     = UI:CreateTab("Config",     "↻", 7, false)

UI:CreateInfoCard(MainPage, "Multi-Game Rockstar Hub (Map 1: Steal & Escape Cage). Supports full uncapped speed & instant remote Plot features.", 1)
UI:CreateMultiDropdown(MainPage, "Zones (empty = all)", AllZones, Config.SelectedZones, 2, function() abortCurrentWalk(Config.AutoStealCage) end)
UI:CreateMultiDropdown(MainPage, "Cage Rarities (empty = all)", AllCageRarities, Config.SelectedCages, 3, function() abortCurrentWalk(false) end)
UI:CreateToggleRow(MainPage, "Auto Steal & Escape Cage (Full Speed)", false, 4, function(v)
    Config.AutoStealCage = v
    if not v then abortCurrentWalk(false) end
end)
UI:CreateToggleRow(MainPage, "Auto Place Best Cage (Bring Prompt / No Walk)", false, 5, function(v) Config.AutoPlaceBestCage = v end)
UI:CreateToggleRow(MainPage, "Auto Open Cage (Bring Prompt / No Walk)", false, 6, function(v) Config.AutoOpenCage = v end)
UI:CreateToggleRow(MainPage, "Auto Collect Cash (No Walk / Instant)", false, 7, function(v) Config.AutoCollectCash = v end)
UI:CreateToggleRow(MainPage, "Auto Upgrade Base (Plot & Barn 2)", false, 8, function(v) Config.AutoUpgradeBase = v end)
UI:CreateToggleRow(MainPage, "Auto Upgrade Treadmill", false, 9, function(v) Config.AutoUpgradeTreadmill = v end)
UI:CreateInputRow(MainPage, "Custom Speed Value (Uncapped)", "500", 10, function(v) Config.CustomSpeed = tonumber(v) or 500 end)
UI:CreateToggleRow(MainPage, "Enable Custom Speed Override", false, 11, function(v) Config.UseCustomSpeed = v end)

UI:CreateInfoCard(AutomationPage, "Background Plot & Barn automation.", 1)
UI:CreateToggleRow(AutomationPage, "Auto Place Best Cage (Instant)", false, 2, function(v) Config.AutoPlaceBestCage = v end)
UI:CreateToggleRow(AutomationPage, "Auto Open Cages (Instant)", false, 3, function(v) Config.AutoOpenCage = v end)
UI:CreateToggleRow(AutomationPage, "Auto Collect CashPad (Instant)", false, 4, function(v) Config.AutoCollectCash = v end)
UI:CreateToggleRow(AutomationPage, "Auto TapBoost & Disable SlowMode", true, 5, function(v)
    Config.AutoTapBoost = v
    Config.DisableSlowMode = v
end)
UI:CreateToggleRow(AutomationPage, "Auto Equip Best Pets", false, 6, function(v) Config.AutoEquipBest = v end)

UI:CreateInfoCard(ShopPage, "Upgrades and pet selling.", 1)
UI:CreateActionRow(ShopPage, "Sell All Unlocked Pets", "SELL ALL", 2, function(btn)
    pcall(function() Remotes.SellAllPets:FireServer() end)
    btn.Text = "SOLD!"
    task.wait(1)
    if btn.Parent then btn.Text = "SELL ALL" end
end)

UI:CreateInfoCard(EventPage, "Halloween Event Cauldron.", 1)
UI:CreateToggleRow(EventPage, "Auto Brew Witch's Cauldron", false, 2, function(v) Config.AutoBrewCauldron = v end)

UI:CreateInfoCard(WebhookPage, "Discord Webhook settings.", 1)
UI:CreateInputRow(WebhookPage, "Discord Webhook URL", "", 2, function() end)

UI:CreateInfoCard(SettingsPage, "Zone reset and Base position settings.", 1)
UI:CreateToggleRow(SettingsPage, "Auto Reset Character When Changing Zones", true, 2, function(v) Config.ResetOnZoneChange = v end)
UI:CreateActionRow(SettingsPage, "Set Current Position as My Plot / Base", "SET BASE", 3, function(btn)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        Config.SavedBasePosition = hrp.Position
        btn.Text = "SAVED!"
        task.wait(1)
        if btn.Parent then btn.Text = "SET BASE" end
    end
end)

UI:CreateInfoCard(ConfigPage, "Open Universal Map Scanner.", 1)
UI:CreateActionRow(ConfigPage, "Open Universal All-Map Scanner", "SCAN MAP", 2, function() openUniversalMapScanner() end)

RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent or not Config.UseCustomSpeed then return end
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

local function isTableEmpty(t)
    for _, v in pairs(t) do if v then return false end end
    return true
end

local function bringAndTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local parent = prompt.Parent
    local savedAttachmentPos, savedPartCF = nil, nil
    pcall(function()
        if parent:IsA("Attachment") then
            savedAttachmentPos = parent.Position
            parent.WorldPosition = hrp.Position + Vector3.new(0, 1, 0)
        elseif parent:IsA("BasePart") then
            savedPartCF = parent.CFrame
            parent.CanCollide = false
            parent.CFrame = hrp.CFrame
        end
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 40
        prompt.RequiresLineOfSight = false
    end)
    RunService.Heartbeat:Wait()
    task.wait(0.05)
    if typeof(fireproximityprompt) == "function" then pcall(fireproximityprompt, prompt) end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.06)
        prompt:InputHoldEnd()
    end)
    pcall(function()
        if parent:IsA("Attachment") and savedAttachmentPos then parent.Position = savedAttachmentPos
        elseif parent:IsA("BasePart") and savedPartCF then parent.CFrame = savedPartCF end
    end)
    return true
end

local function getMyPlot()
    local plots = workspace:FindFirstChild("Hub") and workspace.Hub:FindFirstChild("Plots")
    if not plots then return nil end
    local pName, pDisp = string.lower(player.Name), string.lower(player.DisplayName)
    for _, plot in ipairs(plots:GetChildren()) do
        local ownerDisp = plot:FindFirstChild("OwnerDisplay")
        if ownerDisp then
            for _, d in ipairs(ownerDisp:GetDescendants()) do
                if d:IsA("TextLabel") then
                    local txt = string.lower(d.Text)
                    if string.find(txt, pName, 1, true) or string.find(txt, pDisp, 1, true) then return plot end
                end
            end
        end
    end
    return nil
end

local function getBasePosition()
    if Config.SavedBasePosition then return Config.SavedBasePosition end
    local myPlot = getMyPlot()
    local btn = myPlot and myPlot:FindFirstChild("CashPad") and myPlot.CashPad:FindFirstChild("Button")
    if btn and btn:IsA("BasePart") then return btn.Position end
    local safeZone = workspace:FindFirstChild("World2") and workspace.World2:FindFirstChild("SafeZone")
    if safeZone and safeZone:IsA("BasePart") then return safeZone.Position end
    return nil
end

local function fastDirectWalkTo(targetPos, stopDist, maxTime, checkFlagFunc)
    local mySession = WalkSessionId
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    stopDist = stopDist or 6
    maxTime = maxTime or 25
    local startTime = os.clock()
    if Config.DisableSlowMode then pcall(function() Remotes.SetSlowMode:FireServer(false) end) end
    while ScreenGui.Parent and mySession == WalkSessionId and (os.clock() - startTime) < maxTime do
        if checkFlagFunc and not checkFlagFunc() then return false end
        char = player.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return false end
        local flatDist = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z).Magnitude
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
                        table.insert(list, { cage = cage, pathFolder = pathFolder, rank = CageRank[cage.Name] or 1 })
                    end
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.rank > b.rank end)
    for _, item in ipairs(list) do
        local root = item.cage:FindFirstChild("Root")
        local prompt = root and root:FindFirstChild("StealPrompt")
        if not root or (prompt and prompt.Enabled) then return item.cage, item.pathFolder end
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
    return nil
end

local originalCashPadCF = nil
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.6)
        pcall(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if Config.DisableSlowMode then pcall(function() Remotes.SetSlowMode:FireServer(false) end) end
            local myPlot = getMyPlot()
            if Config.AutoCollectCash and myPlot then
                local cashBtn = myPlot:FindFirstChild("CashPad") and myPlot.CashPad:FindFirstChild("Button")
                if cashBtn and cashBtn:IsA("BasePart") then
                    if not originalCashPadCF then originalCashPadCF = cashBtn.CFrame end
                    cashBtn.CanCollide = false
                    cashBtn.CFrame = hrp.CFrame
                    if typeof(firetouchinterest) == "function" then
                        pcall(firetouchinterest, hrp, cashBtn, 0)
                        pcall(firetouchinterest, hrp, cashBtn, 1)
                    end
                    task.wait(0.12)
                    if originalCashPadCF then cashBtn.CFrame = originalCashPadCF end
                end
            end
            if (Config.AutoPlaceBestCage or Config.AutoOpenCage) and myPlot then
                if Config.AutoOpenCage then pcall(function() Remotes.OpenNow:FireServer() end) end
                for _, barnName in ipairs({"Barn", "Barn2"}) do
                    local barn = myPlot:FindFirstChild(barnName)
                    local stalls = barn and barn:FindFirstChild("Stalls")
                    if stalls then
                        for _, stall in ipairs(stalls:GetChildren()) do
                            if not Config.AutoPlaceBestCage and not Config.AutoOpenCage then break end
                            local anchor = stall:FindFirstChild("PenPromptAnchor")
                            local penPrompt = anchor and anchor:FindFirstChild("PenPrompt")
                            if penPrompt and penPrompt.Enabled then
                                bringAndTriggerPrompt(penPrompt)
                                task.wait(0.08)
                            end
                        end
                    end
                end
            end
            if Config.AutoUpgradeBase then
                pcall(function() Remotes.UpgradePlot:FireServer() Remotes.UpgradeBarn2:FireServer() end)
            end
            if Config.AutoUpgradeTreadmill then pcall(function() Remotes.UpgradeTreadmill:FireServer() end) end
            if Config.AutoTapBoost then pcall(function() Remotes.TapBoost:FireServer() end) end
            if Config.AutoEquipBest then pcall(function() Remotes.EquipBest:FireServer() end) end
            if Config.AutoBrewCauldron then pcall(function() Remotes.Brew:FireServer() end) end
        end)
    end
end)

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
                                    bringAndTriggerPrompt(stealPrompt)
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
            end
        end)
    end
end)
