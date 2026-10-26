-- ==========================================
-- ROCKSTAR SCRIPT HUB - MULTI-GAME LOADER (FULL DECOMPILED BYPASS)
-- Map 1: Steal & Escape Cage (95168737547508) [Safe Velocity Boost]
-- Map 2: Panjat untuk Telur Hewan (85738654635245) [True Truss Climb + SpeedCurve Sync]
-- Fallback: Deep Module Decompiler
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local placeId = game.PlaceId

-- ==========================================
-- STEALTH UI PARENT
-- ==========================================
local function getSafeGuiParent()
    local ok, hui = pcall(function()
        if gethui then return gethui() end
    end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function()
        return CoreGui
    end)
    if ok2 and cg then return cg end
    return lp:WaitForChild("PlayerGui")
end

-- ==========================================
-- DEEP AUDITOR (DECOMPILE TARGET MODULES)
-- ==========================================
local LastStealRefusedReason = "Belum ada penolakan terekam"

local function runDeepAuditScan()
    local lines = {}
    local function add(t) table.insert(lines, t) end

    add("==========================================")
    add("ROCKSTAR TARGETED MODULE AUDITOR")
    add("PlaceId : " .. tostring(game.PlaceId))
    add("Last StealRefused Info : " .. tostring(LastStealRefusedReason))
    add("==========================================\n")

    local targetNames = {
        ["speedCurve"] = true,
        ["zones"] = true,
        ["zoneConfig"] = true,
        ["staminaConfig"] = true,
        ["climbController"] = true,
        ["boostMotion"] = true,
        ["eggCarryController"] = true,
        ["staminaController"] = true
    }

    for _, container in ipairs({ReplicatedStorage, lp:FindFirstChild("PlayerScripts")}) do
        if container then
            for _, v in ipairs(container:GetDescendants()) do
                if v:IsA("ModuleScript") and targetNames[v.Name] then
                    add("=== MODULE: " .. v:GetFullName() .. " ===")
                    pcall(function()
                        if decompile then
                            add(decompile(v))
                        end
                    end)
                    add("\n")
                end
            end
        end
    end

    local result = table.concat(lines, "\n")
    if setclipboard then
        setclipboard(result)
    elseif toclipboard then
        toclipboard(result)
    end
    return result
end

-- ==========================================
-- SHARED UI BUILDER: ROCKSTAR LYNX DARK-ORANGE
-- ==========================================
local function createRockstarWindow(gameTitleText)
    local guiParent = getSafeGuiParent()
    local oldGui = guiParent:FindFirstChild("RockstarLynxUI")
    if oldGui then oldGui:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "RockstarLynxUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = guiParent

    local C_BG = Color3.fromRGB(24, 18, 15)
    local C_SIDEBAR = Color3.fromRGB(28, 21, 18)
    local C_CARD = Color3.fromRGB(36, 28, 24)
    local C_CARD_DARK = Color3.fromRGB(20, 15, 12)
    local C_ORANGE = Color3.fromRGB(242, 108, 29)
    local C_TEXT = Color3.fromRGB(245, 240, 235)
    local C_SUBTEXT = Color3.fromRGB(165, 155, 148)
    local C_STROKE = Color3.fromRGB(58, 45, 38)

    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 115, 0, 34)
    floatBtn.Position = UDim2.new(0, 15, 0.5, -17)
    floatBtn.BackgroundColor3 = C_BG
    floatBtn.TextColor3 = C_ORANGE
    floatBtn.Font = Enum.Font.GothamBlack
    floatBtn.TextSize = 12
    floatBtn.Text = "🐾 ROCKSTAR"
    floatBtn.Visible = false
    floatBtn.Parent = sg
    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 8)
    local fbStroke = Instance.new("UIStroke", floatBtn)
    fbStroke.Color = C_ORANGE
    fbStroke.Thickness = 1.5

    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = UDim2.new(0, 650, 0, 410)
    main.Position = UDim2.new(0.5, -325, 0.5, -205)
    main.BackgroundColor3 = C_BG
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = C_STROKE
    mainStroke.Thickness = 1.2

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 44)
    topBar.BackgroundColor3 = C_SIDEBAR
    topBar.BorderSizePixel = 0
    topBar.Parent = main

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 1, -1)
    topLine.BackgroundColor3 = C_STROKE
    topLine.BorderSizePixel = 0
    topLine.Parent = topBar

    local logoIcon = Instance.new("TextLabel")
    logoIcon.Size = UDim2.new(0, 28, 0, 28)
    logoIcon.Position = UDim2.new(0, 12, 0.5, -14)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "🐾"
    logoIcon.TextSize = 18
    logoIcon.Parent = topBar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0, 85, 1, 0)
    titleLbl.Position = UDim2.new(0, 42, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "ROCKSTAR"
    titleLbl.TextColor3 = C_ORANGE
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 15
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = topBar

    local subTitleLbl = Instance.new("TextLabel")
    subTitleLbl.Size = UDim2.new(0, 260, 1, 0)
    subTitleLbl.Position = UDim2.new(0, 132, 0, 0)
    subTitleLbl.BackgroundTransparency = 1
    subTitleLbl.Text = gameTitleText
    subTitleLbl.TextColor3 = C_SUBTEXT
    subTitleLbl.Font = Enum.Font.GothamBold
    subTitleLbl.TextSize = 12
    subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    subTitleLbl.Parent = topBar

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 24)
    minBtn.Position = UDim2.new(1, -38, 0.5, -12)
    minBtn.BackgroundColor3 = C_CARD
    minBtn.Text = "—"
    minBtn.TextColor3 = C_TEXT
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 12
    minBtn.Parent = topBar
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        floatBtn.Visible = true
    end)
    floatBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        floatBtn.Visible = false
    end)

    local dragging, dragInput, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 175, 1, -44)
    sidebar.Position = UDim2.new(0, 0, 0, 44)
    sidebar.BackgroundColor3 = C_SIDEBAR
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sideLine = Instance.new("Frame")
    sideLine.Size = UDim2.new(0, 1, 1, 0)
    sideLine.Position = UDim2.new(1, -1, 0, 0)
    sideLine.BackgroundColor3 = C_STROKE
    sideLine.BorderSizePixel = 0
    sideLine.Parent = sidebar

    local tabList = Instance.new("ScrollingFrame")
    tabList.Size = UDim2.new(1, -20, 1, -20)
    tabList.Position = UDim2.new(0, 10, 0, 10)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.Parent = sidebar
    local tabLayout = Instance.new("UIListLayout", tabList)
    tabLayout.Padding = UDim.new(0, 5)

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -175, 1, -44)
    contentArea.Position = UDim2.new(0, 175, 0, 44)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    local pages = {}
    local tabButtons = {}

    local function createTab(tabName, iconTxt)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = C_ORANGE
        btn.BackgroundTransparency = 1
        btn.Text = "   " .. iconTxt .. "   " .. tabName
        btn.TextColor3 = C_SUBTEXT
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = tabList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -24, 1, -20)
        page.Position = UDim2.new(0, 12, 0, 10)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = C_ORANGE
        page.Visible = false
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Parent = contentArea

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        pages[tabName] = page
        tabButtons[tabName] = btn

        btn.MouseButton1Click:Connect(function()
            for k, p in pairs(pages) do
                p.Visible = (k == tabName)
                tabButtons[k].BackgroundTransparency = (k == tabName) and 0 or 1
                tabButtons[k].TextColor3 = (k == tabName) and C_TEXT or C_SUBTEXT
            end
        end)
        return page
    end

    local function createCard(parent, titleText, subText)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -6, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = C_CARD
        card.BorderSizePixel = 0
        card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", card)
        st.Color = C_STROKE
        st.Thickness = 1

        local pad = Instance.new("UIPadding", card)
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)

        local lay = Instance.new("UIListLayout", card)
        lay.Padding = UDim.new(0, 8)
        lay.SortOrder = Enum.SortOrder.LayoutOrder

        if titleText then
            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, subText and 32 or 20)
            header.BackgroundTransparency = 1
            header.LayoutOrder = 1
            header.Parent = card

            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 0, 18)
            t.BackgroundTransparency = 1
            t.Text = titleText
            t.TextColor3 = C_TEXT
            t.Font = Enum.Font.GothamBold
            t.TextSize = 13
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = header

            if subText then
                local s = Instance.new("TextLabel")
                s.Size = UDim2.new(1, 0, 0, 14)
                s.Position = UDim2.new(0, 0, 0, 18)
                s.BackgroundTransparency = 1
                s.Text = subText
                s.TextColor3 = C_SUBTEXT
                s.Font = Enum.Font.Gotham
                s.TextSize = 11
                s.TextXAlignment = Enum.TextXAlignment.Left
                s.Parent = header
            end
        end
        return card
    end

    local function addStatusBox(card, defaultText)
        local box = Instance.new("Frame")
        box.Size = UDim2.new(1, 0, 0, 32)
        box.BackgroundColor3 = C_CARD_DARK
        box.LayoutOrder = 2
        box.Parent = card
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 1, -8)
        bar.Position = UDim2.new(0, 4, 0, 4)
        bar.BackgroundColor3 = C_ORANGE
        bar.BorderSizePixel = 0
        bar.Parent = box
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -18, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = defaultText
        lbl.TextColor3 = C_TEXT
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = box
        return lbl
    end

    local function addToggle(card, labelText, defaultVal, callback, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order or 10
        row.Parent = card

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = C_TEXT
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local swBg = Instance.new("TextButton")
        swBg.Size = UDim2.new(0, 44, 0, 22)
        swBg.Position = UDim2.new(1, -44, 0.5, -11)
        swBg.BackgroundColor3 = defaultVal and C_ORANGE or C_CARD_DARK
        swBg.Text = ""
        swBg.Parent = row
        Instance.new("UICorner", swBg).CornerRadius = UDim.new(1, 0)
        local st = Instance.new("UIStroke", swBg)
        st.Color = C_STROKE
        st.Thickness = 1

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = C_TEXT
        knob.Parent = swBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = defaultVal
        swBg.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(swBg, TweenInfo.new(0.18), {BackgroundColor3 = state and C_ORANGE or C_CARD_DARK}):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
            if callback then task.spawn(callback, state) end
        end)
    end

    local function addMultiDropdown(card, labelText, itemsList, selectedTable, order)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 32)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.BackgroundTransparency = 1
        container.LayoutOrder = order or 5
        container.Parent = card

        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 30)
        topRow.BackgroundTransparency = 1
        topRow.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.42, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = C_TEXT
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = topRow

        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(0.58, 0, 0, 28)
        dropBtn.Position = UDim2.new(0.42, 0, 0, 1)
        dropBtn.BackgroundColor3 = C_CARD_DARK
        dropBtn.TextColor3 = C_TEXT
        dropBtn.Font = Enum.Font.GothamMedium
        dropBtn.TextSize = 11
        dropBtn.TextXAlignment = Enum.TextXAlignment.Left
        dropBtn.TextTruncate = Enum.TextTruncate.AtEnd
        dropBtn.Parent = topRow
        Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
        local dst = Instance.new("UIStroke", dropBtn)
        dst.Color = C_ORANGE
        dst.Thickness = 1

        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, 0, 0, 0)
        listFrame.Position = UDim2.new(0, 0, 0, 34)
        listFrame.AutomaticSize = Enum.AutomaticSize.Y
        listFrame.BackgroundColor3 = C_CARD_DARK
        listFrame.Visible = false
        listFrame.Parent = container
        Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)

        local lPad = Instance.new("UIPadding", listFrame)
        lPad.PaddingTop = UDim.new(0, 6)
        lPad.PaddingBottom = UDim.new(0, 6)
        lPad.PaddingLeft = UDim.new(0, 8)
        lPad.PaddingRight = UDim.new(0, 8)

        local lLay = Instance.new("UIListLayout", listFrame)
        lLay.Padding = UDim.new(0, 4)

        local function updateText()
            local active = {}
            for _, item in ipairs(itemsList) do
                if selectedTable[item] then table.insert(active, item) end
            end
            if #active == 0 then
                dropBtn.Text = "  None Selected  ▼"
            else
                dropBtn.Text = "  " .. table.concat(active, ", ") .. "  ▼"
            end
        end

        for _, item in ipairs(itemsList) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 24)
            itemBtn.BackgroundColor3 = selectedTable[item] and C_ORANGE or C_CARD
            itemBtn.Text = "  " .. (selectedTable[item] and "☑ " or "☐ ") .. item
            itemBtn.TextColor3 = C_TEXT
            itemBtn.Font = Enum.Font.GothamBold
            itemBtn.TextSize = 11
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.Parent = listFrame
            Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 5)

            itemBtn.MouseButton1Click:Connect(function()
                selectedTable[item] = not selectedTable[item]
                itemBtn.BackgroundColor3 = selectedTable[item] and C_ORANGE or C_CARD
                itemBtn.Text = "  " .. (selectedTable[item] and "☑ " or "☐ ") .. item
                updateText()
            end)
        end

        updateText()
        dropBtn.MouseButton1Click:Connect(function()
            listFrame.Visible = not listFrame.Visible
        end)
    end

    local function addButton(card, btnText, callback, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = C_ORANGE
        btn.Text = btnText
        btn.TextColor3 = C_TEXT
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12
        btn.LayoutOrder = order or 20
        btn.Parent = card
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            if callback then task.spawn(callback) end
        end)
        return btn
    end

    return {
        createTab = createTab,
        createCard = createCard,
        addStatusBox = addStatusBox,
        addToggle = addToggle,
        addMultiDropdown = addMultiDropdown,
        addButton = addButton,
        pages = pages,
        tabButtons = tabButtons,
        C_TEXT = C_TEXT,
        C_SUBTEXT = C_SUBTEXT
    }
end

-- ============================================================================
-- MAP 1: STEAL & ESCAPE CAGE (PlaceId: 95168737547508)
-- ============================================================================
if placeId == 95168737547508 then
    local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
    local ui = createRockstarWindow("Steal & Escape Cage (Audited Speed)")

    local tabMain = ui.createTab("Main", "🏠")
    local tabAuto = ui.createTab("Automation", "⚡")
    local tabShop = ui.createTab("Shop", "🛒")
    local tabConfig = ui.createTab("Config", "📁")

    ui.pages["Main"].Visible = true
    ui.tabButtons["Main"].BackgroundTransparency = 0
    ui.tabButtons["Main"].TextColor3 = ui.C_TEXT

    local State = {
        AutoSteal = false,
        VelocityBoost = false,
        TurboMultiplier = false,
        AutoCollectCash = false,
        SelectedRarities = {
            ["AstralCage"] = true, ["InfinityCage"] = true, ["DivineCage"] = true,
            ["EternalCage"] = true, ["SecretCage"] = true, ["CosmicCage"] = true,
            ["MythicCage"] = true, ["LegendaryCage"] = false, ["EpicCage"] = false,
            ["RareCage"] = false, ["CommonCage"] = false
        },
        SelectedPaths = {
            ["Path20"] = true, ["Path19"] = true, ["Path18"] = true, ["Path17"] = true, ["Path16"] = true
        }
    }
    for i = 1, 15 do State.SelectedPaths["Path" .. i] = false end

    local RarityOrder = {
        "AstralCage", "InfinityCage", "DivineCage", "EternalCage",
        "SecretCage", "CosmicCage", "MythicCage", "LegendaryCage",
        "EpicCage", "RareCage", "CommonCage"
    }
    local PathOrder = {}
    for i = 20, 1, -1 do table.insert(PathOrder, "Path" .. i) end

    RunService.Heartbeat:Connect(function()
        if not State.VelocityBoost then return end
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 and hum.MoveDirection.Magnitude > 0.1 then
            local baseSpd = hum.WalkSpeed
            local mult = State.TurboMultiplier and 1.85 or 1.40
            local targetSpd = math.clamp(baseSpd * mult, 28, 320)
            local dir = hum.MoveDirection.Unit
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * targetSpd, hrp.AssemblyLinearVelocity.Y, dir.Z * targetSpd)
        end
    end)

    local function getMyPlot()
        local plots = Workspace:FindFirstChild("Hub") and Workspace.Hub:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local od = plot:FindFirstChild("OwnerDisplay")
            if od then
                for _, d in ipairs(od:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        local t = string.lower(d.Text or "")
                        if string.find(t, string.lower(lp.Name), 1, true) or string.find(t, string.lower(lp.DisplayName), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end

    local function pureLegitWalkTo(targetPos, stopDist, checkToggleFunc)
        stopDist = stopDist or 6
        local startTime = os.clock()
        while os.clock() - startTime < 22 do
            if checkToggleFunc and not checkToggleFunc() then return false end
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return false end

            local flatDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            if flatDist <= stopDist then return true end
            hum:MoveTo(targetPos)
            task.wait(0.1)
        end
        return false
    end

    local function holdPromptMap1(prompt)
        if not prompt or not prompt.Parent then return end
        local hold = prompt.HoldDuration or 0
        pcall(function()
            prompt.RequiresLineOfSight = false
            prompt:InputHoldBegin()
        end)
        task.wait(hold + 0.18)
        pcall(function() prompt:InputHoldEnd() end)
    end

    local cardSteal = ui.createCard(tabMain, "Audited Auto Steal Cage + Safe Speed", "Tanpa ubah properti WalkSpeed (Lolos Anti-Cheat PenProblem)")
    local statusLbl = ui.addStatusBox(cardSteal, "Status: Idle (100% Anti-Ban Mode)")
    ui.addMultiDropdown(cardSteal, "Filter Rarity", RarityOrder, State.SelectedRarities, 3)
    ui.addMultiDropdown(cardSteal, "Filter Path", PathOrder, State.SelectedPaths, 4)

    ui.addToggle(cardSteal, "Safe Physics Velocity Boost (1.4x Speed)", false, function(val)
        State.VelocityBoost = val
    end, 5)

    ui.addToggle(cardSteal, "Turbo Velocity Multiplier (1.85x Speed)", false, function(val)
        State.TurboMultiplier = val
    end, 6)

    ui.addToggle(cardSteal, "Start Audited Auto Steal", false, function(val)
        State.AutoSteal = val
        if not val then statusLbl.Text = "Status: Idle" return end
        task.spawn(function()
            while State.AutoSteal do
                local pathsFolder = Workspace:FindFirstChild("Paths")
                local foundCage, foundPath = nil, nil
                if pathsFolder then
                    for _, rName in ipairs(RarityOrder) do
                        if State.SelectedRarities[rName] then
                            for i = 20, 1, -1 do
                                local pName = "Path" .. i
                                if State.SelectedPaths[pName] then
                                    local pMod = pathsFolder:FindFirstChild(pName)
                                    local cages = pMod and pMod:FindFirstChild("Cages")
                                    if cages then
                                        for _, c in ipairs(cages:GetChildren()) do
                                            if c.Name == rName then
                                                foundCage = c
                                                foundPath = pMod
                                                break
                                            end
                                        end
                                    end
                                end
                                if foundCage then break end
                            end
                        end
                        if foundCage then break end
                    end
                end

                if foundCage and foundPath then
                    statusLbl.Text = "Running to " .. foundCage.Name .. " (" .. foundPath.Name .. ")..."
                    local targetPos = foundCage:GetPivot().Position
                    pureLegitWalkTo(targetPos, 7, function() return State.AutoSteal end)

                    local root = foundCage:FindFirstChild("Root")
                    if root then
                        pureLegitWalkTo(root.Position, 5.5, function() return State.AutoSteal end)
                        local prompt = root:FindFirstChild("StealPrompt") or foundCage:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and State.AutoSteal then
                            statusLbl.Text = "Holding E on " .. foundCage.Name .. "..."
                            holdPromptMap1(prompt)
                            local plot = getMyPlot()
                            if plot and State.AutoSteal then
                                statusLbl.Text = "Returning to Base..."
                                pureLegitWalkTo(plot:GetPivot().Position, 10, function() return State.AutoSteal end)
                            end
                        end
                    end
                else
                    statusLbl.Text = "Scanning selected Paths & Rarities..."
                end
                task.wait(0.35)
            end
        end)
    end, 7)

    local cardPlot = ui.createCard(tabAuto, "Legit Plot Automation", "Berjalan menghampiri CashPad secara natural")
    ui.addToggle(cardPlot, "Auto Walk to CashPad (Collect Cash)", false, function(val)
        State.AutoCollectCash = val
        task.spawn(function()
            while State.AutoCollectCash do
                if not State.AutoSteal then
                    local plot = getMyPlot()
                    local btn = plot and plot:FindFirstChild("CashPad") and plot.CashPad:FindFirstChild("Button")
                    if btn then
                        pureLegitWalkTo(btn.Position, 3, function() return State.AutoCollectCash and not State.AutoSteal end)
                    end
                end
                task.wait(4)
            end
        end)
    end, 1)

    local cardShop = ui.createCard(tabShop, "Upgrades & Pets", "Upgrade resmi via tombol UI game")
    ui.addButton(cardShop, "UPGRADE TREADMILL (SPEED)", function()
        pcall(function() Remotes.UpgradeTreadmill:FireServer() end)
    end, 1)
    ui.addButton(cardShop, "UPGRADE PLOT", function()
        pcall(function() Remotes.UpgradePlot:FireServer() end)
    end, 2)

-- ============================================================================
-- MAP 2: [🎃] PANJAT UNTUK TELUR HEWAN 🥚 (PlaceId: 85738654635245)
-- [TRUE TRUSS CLIMB + SPEEDCURVE.TOWALKSPEED + INFINITE STAMINA + JUMP TO START]
-- ============================================================================
elseif placeId == 85738654635245 then
    local ui = createRockstarWindow("Panjat untuk Telur Hewan (True Truss Bypass)")

    local tabMain = ui.createTab("Main", "🥚")
    local tabAuto = ui.createTab("Automation", "⚡")
    local tabShop = ui.createTab("Shop", "🛒")
    local tabTeleport = ui.createTab("Islands", "🏝️")
    local tabConfig = ui.createTab("Config", "📁")

    ui.pages["Main"].Visible = true
    ui.tabButtons["Main"].BackgroundTransparency = 0
    ui.tabButtons["Main"].TextColor3 = ui.C_TEXT

    -- Require Modul Internal Asli Map 2
    local Knit = nil
    local speedCurve = nil
    local zonesUtil = nil

    pcall(function() Knit = require(ReplicatedStorage.src.Packages.knit) end)
    pcall(function() speedCurve = require(ReplicatedStorage.src.utility.speedCurve) end)
    pcall(function() zonesUtil = require(ReplicatedStorage.src.utility.zones) end)

    local function getKnitService(serviceName)
        local ok, svc = pcall(function()
            if Knit then return Knit.GetService(serviceName) end
            return ReplicatedStorage.src.Packages._Index["sleitnick_knit@1.7.0"].knit.Services[serviceName]
        end)
        return ok and svc or nil
    end

    local function getKnitController(ctrlName)
        local ok, ctrl = pcall(function()
            if Knit then return Knit.GetController(ctrlName) end
        end)
        return ok and ctrl or nil
    end

    local DataController = getKnitController("DataController")
    local StaminaController = getKnitController("StaminaController")
    local SpeedStateController = getKnitController("SpeedStateController")
    local JetpackController = getKnitController("JetpackController")
    local BaseController = getKnitController("BaseController")
    local ZoneController = getKnitController("ZoneController")
    local EggCarryController = getKnitController("EggCarryController")
    local EggPlacementController = getKnitController("EggPlacementController")

    local EggSpawnSvc = getKnitService("EggSpawnService")
    local EggPlaceSvc = getKnitService("EggPlacementService")
    local EggHatchSvc = getKnitService("EggHatchService")
    local BaseUpgSvc = getKnitService("BaseUpgradeService")
    local TreadmillSvc = getKnitService("TreadmillService")
    local RebirthSvc = getKnitService("RebirthService")
    local CashFlowSvc = getKnitService("CashFlowService")
    local GiftPlayTimeSvc = getKnitService("GiftPlayTimeService")
    local DailyRewardsSvc = getKnitService("DailyRewardsService")
    local IndexSvc = getKnitService("IndexService")
    local StaminaUpgSvc = getKnitService("StaminaUpgradeService")

    -- 1. BYPASS STAMINA CLIENT-SIDE (TIDAK PERNAH LELAH SAAT MEMANJAT TANGGA!)
    if StaminaController then
        pcall(function()
            StaminaController.Multiplier = 1
            StaminaController.pushTiredNotification = function() end
            StaminaController.updateWalkSpeed = function(self, hum)
                self.Multiplier = 1
                if SpeedStateController and hum then
                    hum.WalkSpeed = SpeedStateController:GetWalkSpeed()
                end
            end
        end)
    end

    -- Listener StealRefused
    local StealRefusedFlag = false
    local rawEggSpawnRE = nil
    pcall(function()
        rawEggSpawnRE = ReplicatedStorage.src.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.EggSpawnService.RE.StealRefused
    end)
    if rawEggSpawnRE then
        rawEggSpawnRE.OnClientEvent:Connect(function(reason)
            StealRefusedFlag = true
            LastStealRefusedReason = tostring(reason)
        end)
    end

    local State = {
        AutoStealEgg = false,
        InfiniteStamina = true,
        AutoHatchBase = false,
        AutoClaimRewards = false,
        SelectedRarities = {
            ["Astral"] = true, ["Celestial"] = true, ["Radiant"] = true,
            ["Eternal"] = true, ["Divine"] = true, ["Legendary"] = true,
            ["Rare"] = true, ["Uncommon"] = false, ["Common"] = false
        },
        SelectedBiomes = {
            ["Forbidden Forest"] = true, ["Realm of Legends"] = true,
            ["Celestial"] = true, ["Divine Heights"] = true,
            ["Mystic Isles"] = true, ["PreHistoric"] = true,
            ["Jungle"] = true, ["Winter"] = true, ["Desert"] = true,
            ["Crystal Mines"] = true, ["Ocean"] = true,
            ["Forest"] = true
        }
    }

    local RarityOrder = {
        "Astral", "Celestial", "Radiant", "Eternal", "Divine",
        "Legendary", "Rare", "Uncommon", "Common"
    }
    local RarityWeight = {
        ["Astral"] = 9, ["Celestial"] = 8, ["Radiant"] = 7,
        ["Eternal"] = 6, ["Divine"] = 5, ["Legendary"] = 4,
        ["Rare"] = 3, ["Uncommon"] = 2, ["Common"] = 1
    }
    local BiomeList = {
        "Forbidden Forest", "Realm of Legends", "Celestial", "Divine Heights",
        "Mystic Isles", "PreHistoric", "Jungle", "Winter", "Desert",
        "Crystal Mines", "Ocean", "Forest"
    }

    -- Hitung Kecepatan Panjat Resmi Server berdasarkan speedCurve.ToWalkSpeed(Speed)
    local function getLegalClimbSpeed()
        local rawSpeed = 448
        if DataController then
            local ok, s = pcall(function() return DataController:GetValue("Speed") end)
            if ok and tonumber(s) then rawSpeed = tonumber(s) end
        elseif lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Speed") then
            rawSpeed = tonumber(lp.leaderstats.Speed.Value) or 448
        end

        local walkSpd = 38
        if speedCurve and speedCurve.ToWalkSpeed then
            local ok, calc = pcall(function() return speedCurve.ToWalkSpeed(rawSpeed) end)
            if ok and tonumber(calc) then walkSpd = tonumber(calc) end
        end

        local jpMult = 1
        if JetpackController then
            local ok, m = pcall(function() return JetpackController:GetSpeedMultiplier() end)
            if ok and tonumber(m) then jpMult = tonumber(m) end
        end

        return walkSpd * jpMult
    end

    -- Kumpulkan semua TrussPart di Workspace.Structures untuk jalur panjat resmi
    local CachedTrusses = {}
    local function refreshTrusses()
        table.clear(CachedTrusses)
        local structures = Workspace:FindFirstChild("Structures")
        if not structures then return end
        for _, v in ipairs(structures:GetDescendants()) do
            if v:IsA("TrussPart") then
                table.insert(CachedTrusses, v)
            end
        end
        table.sort(CachedTrusses, function(a, b)
            return a.Position.Y < b.Position.Y
        end)
    end
    refreshTrusses()

    -- Cari TrussPart terdekat pada ketinggian Y tertentu
    local function getTrussAtHeight(targetY, refXZ)
        local bestTruss = nil
        local bestDist = math.huge
        for _, tr in ipairs(CachedTrusses) do
            if tr and tr.Parent then
                local halfH = tr.Size.Y / 2 + 4
                if targetY >= (tr.Position.Y - halfH) and targetY <= (tr.Position.Y + halfH) then
                    local d = refXZ and (Vector2.new(tr.Position.X, tr.Position.Z) - refXZ).Magnitude or 0
                    if d < bestDist then
                        bestDist = d
                        bestTruss = tr
                    end
                end
            end
        end
        return bestTruss
    end

    -- Reset ke Lobby ("Jump To The Start!") menggunakan mekanisme resmi OutOfBoundsController (Y <= 20)
    local function resetToLobbyLegit(statusLbl)
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if statusLbl then
            statusLbl.Text = "Reset ke Lobby (Membersihkan Flag Server)..."
        end

        -- Terjun ke Y = 18 agar OutOfBoundsController resmi memindahkan karakter ke TpCFrame di Lobby
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(hrp.Position.X, 18, hrp.Position.Z)

        local waitStart = os.clock()
        while os.clock() - waitStart < 2.5 do
            char = lp.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            local zName = ZoneController and ZoneController.Zone or nil
            if zName == "Lobby" or (hrp and hrp.Position.Y > 25 and hrp.Position.Y < 55) then
                break
            end
            task.wait(0.1)
        end

        StealRefusedFlag = false
        task.wait(0.6)
    end

    -- Jalan kaki di darat dengan kecepatan resmi Idle (26 studs/detik)
    local function walkOnGroundTo(targetPos, stopDist, checkFunc)
        stopDist = stopDist or 4.5
        local startTime = os.clock()
        while os.clock() - startTime < 18 do
            if checkFunc and not checkFunc() then return false end
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return false end

            local flatDiff = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
            if flatDiff.Magnitude <= stopDist then
                return true
            end

            hum:MoveTo(targetPos)
            task.wait(0.1)
        end
        return false
    end

    -- PANJAT TANGGA (TRUSS) RESMI SESUAI SPEEDCURVE.TOWALKSPEED(SPEED)
    local function climbTrussToHeight(targetY, targetXZ, statusLbl, checkFunc)
        if #CachedTrusses == 0 then refreshTrusses() end
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return false end

        -- 1. Cari Truss paling bawah di Lobby (Y ~ 30..60)
        local bottomTruss = getTrussAtHeight(40) or CachedTrusses[1]
        if not bottomTruss then return false end

        -- 2. Jika masih di Lobby, jalan kaki dulu ke depan Truss bawah!
        if hrp.Position.Y < 55 then
            if statusLbl then statusLbl.Text = "Berjalan ke kaki Tangga (Truss)..." end
            local trussBasePos = Vector3.new(bottomTruss.Position.X, hrp.Position.Y, bottomTruss.Position.Z + 2)
            walkOnGroundTo(trussBasePos, 4, checkFunc)
        end

        -- 3. Memanjat naik sepanjang TrussPart dengan kecepatan resmi speedCurve.ToWalkSpeed(Speed)!
        local currentXZ = Vector2.new(bottomTruss.Position.X, bottomTruss.Position.Z)
        local lastTick = os.clock()

        while hrp and hrp.Parent and hrp.Position.Y < (targetY - 2) do
            if checkFunc and not checkFunc() then return false end
            char = lp.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return false end

            local now = os.clock()
            local dt = math.clamp(now - lastTick, 0.01, 0.1)
            lastTick = now

            local legalClimbSpd = getLegalClimbSpeed()
            if StaminaController then StaminaController.Multiplier = 1 end
            if SpeedStateController then
                pcall(function() SpeedStateController:UpdateState("Climbing") end)
            end
            hum.WalkSpeed = legalClimbSpd

            if statusLbl then
                statusLbl.Text = string.format("Memanjat Tangga: Y=%d / %d (Spd: %.0f)", math.floor(hrp.Position.Y), math.floor(targetY), legalClimbSpd)
            end

            -- Cari TrussPart pada ketinggian saat ini
            local curY = hrp.Position.Y
            local activeTruss = getTrussAtHeight(curY + 2, targetXZ or currentXZ) or bottomTruss
            if activeTruss then
                currentXZ = Vector2.new(activeTruss.Position.X, activeTruss.Position.Z)
            end

            local nextY = math.min(curY + (legalClimbSpd * dt * 0.96), targetY + 2)
            local climbPos = Vector3.new(currentXZ.X, nextY, currentXZ.Y + 1.2)
            local lookAtTruss = Vector3.new(currentXZ.X, nextY, currentXZ.Y)

            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Climbing) end)
            hrp.AssemblyLinearVelocity = Vector3.new(0, legalClimbSpd * 0.96, 0)
            hrp.CFrame = CFrame.lookAt(climbPos, lookAtTruss)

            -- Gerakkan kaki ke depan agar ClimbController mendeteksi gerakan memanjat
            hum:Move(Vector3.new(0, 0, -1), true)

            task.wait()
        end

        if SpeedStateController then
            pcall(function() SpeedStateController:UpdateState("Idle") end)
        end
        return true
    end

    local cardEgg = ui.createCard(tabMain, "True Truss Climb + Auto Steal Egg", "Panjat tangga sesuai SpeedCurve asli + Infinite Stamina + Jump To Start")
    local statusEggLbl = ui.addStatusBox(cardEgg, "Status: Idle (Siap memanjat & ambil telur)")

    ui.addMultiDropdown(cardEgg, "Filter Rarity", RarityOrder, State.SelectedRarities, 3)
    ui.addMultiDropdown(cardEgg, "Filter Biome", BiomeList, State.SelectedBiomes, 4)

    ui.addToggle(cardEgg, "Start True Truss Auto Steal", false, function(val)
        State.AutoStealEgg = val
        if not val then
            statusEggLbl.Text = "Status: Idle"
            return
        end

        task.spawn(function()
            -- Pastikan mulai dari Lobby dengan status bersih
            local hrpStart = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrpStart and (hrpStart.Position.Y > 55 or StealRefusedFlag) then
                resetToLobbyLegit(statusEggLbl)
            end

            while State.AutoStealEgg do
                if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                    pcall(function() lp.Character.Humanoid:UnequipTools() end)
                end

                local spawned = Workspace:FindFirstChild("SpawnedEggs")
                local bestEgg = nil
                local bestHitbox = nil
                local bestScore = -1

                if spawned then
                    for _, biomeFolder in ipairs(spawned:GetChildren()) do
                        if State.SelectedBiomes[biomeFolder.Name] then
                            for _, eggModel in ipairs(biomeFolder:GetChildren()) do
                                if eggModel.Name ~= "Nest" then
                                    local r = eggModel:GetAttribute("Rarity")
                                    local hitbox = eggModel:FindFirstChild("Hitbox") or eggModel:FindFirstChildWhichIsA("BasePart")
                                    if r and State.SelectedRarities[r] and hitbox then
                                        local score = (RarityWeight[r] or 1) * 1000 + (tonumber(eggModel:GetAttribute("WeightKg")) or 0)
                                        if score > bestScore then
                                            bestScore = score
                                            bestEgg = eggModel
                                            bestHitbox = hitbox
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if bestEgg and bestHitbox then
                    local rName = bestEgg:GetAttribute("Rarity") or ""
                    local eName = bestEgg:GetAttribute("EggName") or bestEgg.Name
                    local eggPos = bestHitbox.Position
                    local eggXZ = Vector2.new(eggPos.X, eggPos.Z)

                    -- 1. Panjat Tangga (Truss) resmi sampai ketinggian pulau telur!
                    local climbed = climbTrussToHeight(eggPos.Y + 2, eggXZ, statusEggLbl, function()
                        return State.AutoStealEgg and bestEgg.Parent ~= nil
                    end)

                    if climbed and State.AutoStealEgg and bestEgg.Parent then
                        -- 2. Jalan kaki alami di atas pulau menuju telur (Kecepatan Idle resmi 26 studs/s)
                        statusEggLbl.Text = string.format("Berjalan di Pulau ke [%s] %s...", rName, eName)
                        walkOnGroundTo(bestHitbox.Position, 4.5, function()
                            return State.AutoStealEgg and bestEgg.Parent ~= nil
                        end)

                        task.wait(0.35)

                        -- 3. Arahkan kamera & tahan StealPrompt selama 0.65 detik
                        local prompt = bestEgg:FindFirstChild("StealPrompt", true) or bestEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function()
                                prompt.RequiresLineOfSight = false
                                prompt.MaxActivationDistance = 20
                                prompt.Enabled = true
                            end)
                        end

                        local cam = Workspace.CurrentCamera
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if cam and hrp then
                            cam.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 3, 0), bestHitbox.Position)
                        end
                        task.wait(0.2)

                        statusEggLbl.Text = "Menahan StealPrompt [" .. rName .. "] " .. eName .. "..."
                        if prompt then pcall(function() prompt:InputHoldBegin() end) end
                        if VirtualInputManager then
                            pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
                        end

                        for _ = 1, 13 do
                            if not State.AutoStealEgg then break end
                            if cam and hrp and bestHitbox then
                                cam.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 3, 0), bestHitbox.Position)
                            end
                            task.wait(0.05)
                        end

                        if prompt then pcall(function() prompt:InputHoldEnd() end) end
                        if VirtualInputManager then
                            pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
                        end

                        task.wait(0.3)

                        -- 4. Cek apakah telur berhasil digendong (CarryingEgg ~= nil)
                        if lp:GetAttribute("CarryingEgg") ~= nil then
                            statusEggLbl.Text = "✅ Telur Dapat! Jump To The Start (Auto Claim)..."
                            resetToLobbyLegit(statusEggLbl)
                            if EggCarryController then
                                pcall(function() EggCarryController:tryClaimEgg() end)
                            end
                            task.wait(0.8)

                            -- Otomatis taruh telur dari Backpack ke Base Anda!
                            local baseModel = BaseController and BaseController:GetBase() or nil
                            local fences = baseModel and baseModel:FindFirstChild("Fences")
                            local placeCF = fences and fences:GetPivot() or (hrp and hrp.CFrame)
                            for _, tool in ipairs(lp.Backpack:GetChildren()) do
                                if tool:IsA("Tool") and tool:GetAttribute("Handler") == "Egg" then
                                    local refName = tool:GetAttribute("ReferenceName") or tool.Name
                                    if EggPlacementController and placeCF then
                                        pcall(function() EggPlacementController:Place(refName, placeCF) end)
                                    elseif EggPlaceSvc and placeCF then
                                        pcall(function() EggPlaceSvc.RF.RequestToPlace:InvokeServer(refName, placeCF) end)
                                    end
                                end
                            end
                        elseif StealRefusedFlag then
                            statusEggLbl.Text = "⚠️ Reset Flag ke Lobby: " .. tostring(LastStealRefusedReason)
                            resetToLobbyLegit(statusEggLbl)
                        end
                    end
                else
                    statusEggLbl.Text = "Scanning SpawnedEggs (Menunggu Rarity terpilih)..."
                end
                task.wait(0.4)
            end
        end)
    end, 5)

    -- TAB AUTOMATION
    local cardBase = ui.createCard(tabAuto, "Base & Rewards Automation", "Otomatis tetaskan telur & klaim hadiah")
    ui.addToggle(cardBase, "Auto Hatch Ready Eggs at Base", false, function(val)
        State.AutoHatchBase = val
        task.spawn(function()
            while State.AutoHatchBase do
                local myBase = BaseController and BaseController:GetBase()
                local placed = myBase and myBase:FindFirstChild("PlacedEggs")
                if placed then
                    for _, egg in ipairs(placed:GetChildren()) do
                        if egg:GetAttribute("CanHatch") == true then
                            if EggHatchSvc and EggHatchSvc:FindFirstChild("RF") then
                                pcall(function() EggHatchSvc.RF.Hatch:InvokeServer(egg.Name) end)
                                pcall(function() EggHatchSvc.RF.CompleteHatch:InvokeServer(egg.Name) end)
                            end
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end, 1)

    ui.addToggle(cardBase, "Auto Claim Offline Cash, Gifts & Index", false, function(val)
        State.AutoClaimRewards = val
        task.spawn(function()
            while State.AutoClaimRewards do
                pcall(function() CashFlowSvc.RF.ClaimOfflineCash:InvokeServer() end)
                pcall(function() DailyRewardsSvc.RF.Claim:InvokeServer() end)
                pcall(function() IndexSvc.RF.ClaimAll:InvokeServer() end)
                for i = 1, 12 do
                    pcall(function() GiftPlayTimeSvc.RF.Claim:InvokeServer(i) end)
                end
                task.wait(10)
            end
        end)
    end, 2)

    -- TAB SHOP
    local cardShop = ui.createCard(tabShop, "Upgrades & Rebirth", "Upgrade resmi menggunakan Knit Services Map 2")
    ui.addButton(cardShop, "⚡ UPGRADE TREADMILL", function()
        pcall(function() TreadmillSvc.RF.RequestToUpgrade:InvokeServer() end)
    end, 1)
    ui.addButton(cardShop, "🏠 EXPAND BASE / PLOT", function()
        pcall(function() BaseUpgSvc.RF.RequestToUpgrade:InvokeServer() end)
    end, 2)
    ui.addButton(cardShop, "🔋 UPGRADE STAMINA", function()
        local lvl = DataController and DataController:GetValue("StaminaLevel") or 1
        pcall(function() StaminaUpgSvc.RF.Purchase:InvokeServer(lvl) end)
    end, 3)
    ui.addButton(cardShop, "🔄 REBIRTH SEKARANG", function()
        pcall(function() RebirthSvc.RF.Request:InvokeServer() end)
    end, 4)

    -- TAB ISLANDS
    local cardTp = ui.createCard(tabTeleport, "True Truss Climb ke Pulau", "Panjat tangga otomatis ke pulau pilihan")
    local islandsFolder = Workspace:FindFirstChild("Structures") and Workspace.Structures:FindFirstChild("Islands")
    if islandsFolder then
        for idx, isl in ipairs(islandsFolder:GetChildren()) do
            ui.addButton(cardTp, "🧗 CLIMB KE: " .. string.upper(isl.Name), function()
                local spawnPart = isl:FindFirstChild("Area") or isl:FindFirstChild("SpawnEggs") or isl:FindFirstChildWhichIsA("BasePart", true)
                if spawnPart then
                    climbTrussToHeight(spawnPart.Position.Y + 2, Vector2.new(spawnPart.Position.X, spawnPart.Position.Z), statusEggLbl)
                end
            end, idx)
        end
    end

    -- TAB CONFIG
    local cardCfg = ui.createCard(tabConfig, "Targeted Module Decompiler", "Decompile modul speedCurve, climbController & zones")
    local scanStatus = ui.addStatusBox(cardCfg, "Klik tombol di bawah jika butuh decompile modul panjat")
    ui.addButton(cardCfg, "🔍 DECOMPILE CLIMB & SPEED MODULES (COPY)", function()
        runDeepAuditScan()
        scanStatus.Text = "✅ Modul berhasil di-copy!"
    end, 5)

-- ============================================================================
-- FALLBACK: UNIVERSAL DEEP AUDITOR
-- ============================================================================
else
    runDeepAuditScan()
end
