-- ==========================================
-- ROCKSTAR SCRIPT HUB - MULTI-GAME LOADER
-- Map 1: Steal & Escape Cage (95168737547508) [100% Pure Legit]
-- Map 2: Panjat untuk Telur Hewan (85738654635245) [Anti-Steal-Blocked Glide]
-- Fallback: Universal Map Scanner
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local placeId = game.PlaceId

-- ==========================================
-- STEALTH UI PARENT (SEMBUNYI DARI DETEKSI GAME)
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
-- UNIVERSAL PROMPT & REMOTE SCANNER
-- ==========================================
local function runPromptsAndRemotesScan()
    local lines = {}
    local function add(t) table.insert(lines, t) end

    add("==========================================")
    add("ROCKSTAR PROMPTS & REMOTES SCANNER")
    add("PlaceId : " .. tostring(game.PlaceId))
    add("==========================================\n")

    add("=== [1] PROXIMITY PROMPTS & CLICK DETECTORS ===")
    local pSeen = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local key = v.Name .. "|" .. v.ActionText .. "|" .. (v.Parent and v.Parent.Name or "")
            if not pSeen[key] then
                pSeen[key] = true
                add("Prompt: " .. v:GetFullName() .. " [Act:'" .. v.ActionText .. "' | Obj:'" .. v.ObjectText .. "' | Hold:" .. tostring(v.HoldDuration) .. "]")
            end
        elseif v:IsA("ClickDetector") then
            local key = v.Name .. "|" .. (v.Parent and v.Parent.Name or "")
            if not pSeen[key] then
                pSeen[key] = true
                add("ClickDetector: " .. v:GetFullName())
            end
        end
    end

    add("\n=== [2] REPLICATEDSTORAGE REMOTES ===")
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            add(string.format("[%s] %s", v.ClassName, v:GetFullName()))
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

    -- Dragging Window
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

    -- Sidebar
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

-- ==========================================
-- HELPER INTERAKSI PROMPT MURNI
-- ==========================================
local function usePromptPureLegit(prompt)
    if not prompt or not prompt.Parent then return false end
    local holdTime = prompt.HoldDuration or 0

    local ok = pcall(function()
        prompt:InputHoldBegin()
    end)
    if ok then
        task.wait(holdTime + 0.18)
        pcall(function()
            prompt:InputHoldEnd()
        end)
        return true
    end

    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(holdTime + 0.18)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        return true
    end
    return false
end

-- ============================================================================
-- MAP 1: STEAL & ESCAPE CAGE (PlaceId: 95168737547508)
-- ============================================================================
if placeId == 95168737547508 then
    local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
    local ui = createRockstarWindow("Steal & Escape Cage (Safe Mode)")

    local tabMain = ui.createTab("Main", "🏠")
    local tabAuto = ui.createTab("Automation", "⚡")
    local tabShop = ui.createTab("Shop", "🛒")
    local tabConfig = ui.createTab("Config", "📁")

    ui.pages["Main"].Visible = true
    ui.tabButtons["Main"].BackgroundTransparency = 0
    ui.tabButtons["Main"].TextColor3 = ui.C_TEXT

    local State = {
        AutoSteal = false,
        AutoCollectCash = false,
        AutoClaimStalls = false,
        AutoEquipBest = false,
        AutoSellPets = false,
        SelectedRarities = {
            ["AstralCage"] = true,
            ["InfinityCage"] = true,
            ["DivineCage"] = true,
            ["EternalCage"] = true,
            ["SecretCage"] = true,
            ["CosmicCage"] = true,
            ["MythicCage"] = true,
            ["LegendaryCage"] = false,
            ["EpicCage"] = false,
            ["RareCage"] = false,
            ["CommonCage"] = false
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
            task.wait(0.12)
        end
        return false
    end

    local cardSteal = ui.createCard(tabMain, "Pure Legit Auto Steal Cage", "100% jalan kaki murni tanpa ubah WalkSpeed / CFrame")
    local statusLbl = ui.addStatusBox(cardSteal, "Status: Idle (100% Anti-Ban Mode)")
    ui.addMultiDropdown(cardSteal, "Filter Rarity", RarityOrder, State.SelectedRarities, 3)
    ui.addMultiDropdown(cardSteal, "Filter Path", PathOrder, State.SelectedPaths, 4)

    ui.addToggle(cardSteal, "Start Legit Auto Steal", false, function(val)
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
                    statusLbl.Text = "Walking to " .. foundCage.Name .. " (" .. foundPath.Name .. ")..."
                    local targetPos = foundCage:GetPivot().Position
                    pureLegitWalkTo(targetPos, 7, function() return State.AutoSteal end)

                    local root = foundCage:FindFirstChild("Root")
                    if root then
                        pureLegitWalkTo(root.Position, 6, function() return State.AutoSteal end)
                        local prompt = root:FindFirstChild("StealPrompt") or foundCage:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and State.AutoSteal then
                            statusLbl.Text = "Holding E on " .. foundCage.Name .. "..."
                            usePromptPureLegit(prompt)
                            local plot = getMyPlot()
                            if plot and State.AutoSteal then
                                statusLbl.Text = "Walking back to Base..."
                                pureLegitWalkTo(plot:GetPivot().Position, 10, function() return State.AutoSteal end)
                            end
                        end
                    end
                else
                    statusLbl.Text = "Scanning selected Paths & Rarities..."
                end
                task.wait(0.4)
            end
        end)
    end, 6)

    local cardPlot = ui.createCard(tabAuto, "Legit Plot Automation", "Berjalan menghampiri CashPad & Stall kandang secara natural")
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

    local cardCfg = ui.createCard(tabConfig, "Scanner", "Salin Remotes & Prompts")
    ui.addButton(cardCfg, "SCAN PROMPTS & REMOTES", function()
        runPromptsAndRemotesScan()
    end, 1)

-- ============================================================================
-- MAP 2: [🎃] PANJAT UNTUK TELUR HEWAN 🥚 (PlaceId: 85738654635245)
-- ============================================================================
elseif placeId == 85738654635245 then
    local ui = createRockstarWindow("Panjat untuk Telur Hewan (Anti-Block)")

    local tabMain = ui.createTab("Main", "🥚")
    local tabAuto = ui.createTab("Automation", "⚡")
    local tabTeleport = ui.createTab("Islands", "🏝️")
    local tabConfig = ui.createTab("Config", "📁")

    ui.pages["Main"].Visible = true
    ui.tabButtons["Main"].BackgroundTransparency = 0
    ui.tabButtons["Main"].TextColor3 = ui.C_TEXT

    local State = {
        AutoStealEgg = false,
        AutoHatchBase = false,
        SavedHomeCFrame = nil,
        SelectedRarities = {
            ["Astral"] = true,
            ["Celestial"] = true,
            ["Radiant"] = true,
            ["Eternal"] = true,
            ["Divine"] = true,
            ["Legendary"] = false,
            ["Rare"] = false,
            ["Uncommon"] = false,
            ["Common"] = false
        },
        SelectedBiomes = {
            ["WitchDrops"] = true,
            ["Witches Castle"] = true,
            ["Pumpkin Abyss"] = true,
            ["Bone Field"] = true,
            ["Forbidden Forest"] = true,
            ["Realm of Legends"] = true,
            ["Celestial"] = true,
            ["Divine Heights"] = true,
            ["Mystic Isles"] = true,
            ["PreHistoric"] = false,
            ["Jungle"] = false,
            ["Winter"] = false,
            ["Desert"] = false,
            ["Crystal Mines"] = false,
            ["Ocean"] = false,
            ["Ocean Abyss"] = false,
            ["Forest"] = false
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
        "WitchDrops", "Witches Castle", "Pumpkin Abyss", "Bone Field",
        "Forbidden Forest", "Realm of Legends", "Celestial", "Divine Heights",
        "Mystic Isles", "PreHistoric", "Jungle", "Winter", "Desert",
        "Crystal Mines", "Ocean", "Ocean Abyss", "Forest"
    }

    -- Cari Base milik kita di Workspace.Structures.Bases
    local function getMyBase()
        local structures = Workspace:FindFirstChild("Structures")
        local bases = structures and structures:FindFirstChild("Bases")
        if not bases then return nil end

        for _, base in ipairs(bases:GetChildren()) do
            -- Cek OwnerUserId di Treadmill
            for _, desc in ipairs(base:GetDescendants()) do
                if desc:GetAttribute("OwnerUserId") == lp.UserId then
                    return base
                end
                if desc:IsA("TextLabel") then
                    local txt = string.lower(desc.Text or "")
                    if string.find(txt, string.lower(lp.Name), 1, true) or string.find(txt, string.lower(lp.DisplayName), 1, true) then
                        return base
                    end
                end
            end
        end
        return nil
    end

    -- Lepas Tool Bat agar tidak memblokir pengambilan telur
    local function unequipAllTools()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:UnequipTools() end)
        end
    end

    -- Cek apakah karakter sedang memegang/membawa telur
    local function isCarryingEgg()
        local char = lp.Character
        if not char then return false end
        if char:GetAttribute("CarryingEgg") or char:GetAttribute("HasEgg") or lp:GetAttribute("CarryingEgg") then
            return true
        end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and child.Name ~= "Bat" then
                return true
            end
            if child:IsA("Model") and (child:GetAttribute("EggId") or child:GetAttribute("Rarity") or string.find(string.lower(child.Name), "egg")) then
                return true
            end
        end
        return false
    end

    -- Smooth Glide mengikuti kecepatan karakter (Anti-Steal-Blocked / Anti-Rubberband)
    local function smoothGlideTo(targetPos, checkFunc)
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return false end

        -- Baca kecepatan resmi pemain dari leaderstats.Speed (minimal 180, maksimal 650 studs/detik agar tidak kena anti-TP)
        local playerSpeed = 260
        local ls = lp:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Speed") then
            local sp = tonumber(ls.Speed.Value)
            if sp and sp > 80 then
                playerSpeed = math.clamp(sp * 0.85, 180, 600)
            end
        end

        local startPos = hrp.Position
        local dist = (targetPos - startPos).Magnitude
        if dist <= 5 then return true end

        local duration = math.clamp(dist / playerSpeed, 0.25, 6.0)
        local steps = math.max(math.floor(duration / 0.03), 8)
        local stepVec = (targetPos - startPos) / steps

        for i = 1, steps do
            if checkFunc and not checkFunc() then return false end
            char = lp.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end

            local nextPos = startPos + (stepVec * i)
            hrp.Velocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(nextPos + Vector3.new(0, 2.5, 0))
            task.wait(0.03)
        end

        hrp.Velocity = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        return true
    end

    local cardEgg = ui.createCard(tabMain, "Auto Steal Egg (Anti-Steal Blocked)", "Meluncur sesuai Speed akun + Unequip Bat + Balik ke Base")
    local statusEggLbl = ui.addStatusBox(cardEgg, "Status: Idle (Siap cari telur)")

    ui.addButton(cardEgg, "📍 SET POSISI BASE SAAT INI (OPSIONAL)", function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            State.SavedHomeCFrame = hrp.CFrame
            statusEggLbl.Text = "Base disimpan di posisi Anda sekarang!"
        end
    end, 3)

    ui.addMultiDropdown(cardEgg, "Filter Rarity", RarityOrder, State.SelectedRarities, 4)
    ui.addMultiDropdown(cardEgg, "Filter Biome", BiomeList, State.SelectedBiomes, 5)

    ui.addToggle(cardEgg, "Auto Steal & Return to Base", false, function(val)
        State.AutoStealEgg = val
        if not val then
            statusEggLbl.Text = "Status: Idle"
            return
        end

        -- Simpan posisi awal sebagai fallback Home jika Base belum terdeteksi
        local hrpNow = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrpNow and not State.SavedHomeCFrame then
            State.SavedHomeCFrame = hrpNow.CFrame
        end

        task.spawn(function()
            while State.AutoStealEgg do
                unequipAllTools()

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
                    statusEggLbl.Text = string.format("Gliding to [%s] %s...", rName, eName)

                    -- 1. Meluncur mulus ke posisi telur agar tidak kena Steal Blocked
                    local arrived = smoothGlideTo(bestHitbox.Position, function()
                        return State.AutoStealEgg and bestEgg.Parent ~= nil
                    end)

                    if arrived and State.AutoStealEgg and bestEgg.Parent then
                        unequipAllTools()
                        -- Tunggu 0.45 detik di atas telur supaya server memvalidasi jarak karakter!
                        statusEggLbl.Text = "Validasi jarak server (Anti-Block)..."
                        task.wait(0.45)

                        -- Cari ProximityPrompt di dalam telur
                        local prompt = bestEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            statusEggLbl.Text = "Mengambil [" .. rName .. "] " .. eName .. "..."
                            usePromptPureLegit(prompt)
                        else
                            -- Tekan E via VirtualInputManager jika prompt custom
                            if VirtualInputManager then
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.35)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end
                        end

                        task.wait(0.35)

                        -- 2. Kembali ke Base.Home untuk menaruh telur!
                        local myBase = getMyBase()
                        local homePart = myBase and (myBase:FindFirstChild("Home") or myBase:FindFirstChild("PlacedEggs") or myBase:FindFirstChild("BaseOwner"))
                        local homePos = nil
                        if homePart then
                            homePos = homePart:IsA("BasePart") and homePart.Position or homePart:GetPivot().Position
                        elseif State.SavedHomeCFrame then
                            homePos = State.SavedHomeCFrame.Position
                        end

                        if homePos and State.AutoStealEgg then
                            statusEggLbl.Text = "Membawa telur pulang ke Base..."
                            smoothGlideTo(homePos, function() return State.AutoStealEgg end)
                            task.wait(0.6)

                            -- Jika di Base ada Prompt untuk menaruh telur, tekan otomatis
                            if myBase then
                                local placePrompt = myBase:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if placePrompt and isCarryingEgg() then
                                    usePromptPureLegit(placePrompt)
                                end
                            end
                        end
                    end
                else
                    statusEggLbl.Text = "Scanning SpawnedEggs (Menunggu Rarity terpilih)..."
                end
                task.wait(0.4)
            end
        end)
    end, 6)

    -- TAB AUTOMATION (AUTO HATCH PLACED EGGS DI BASE)
    local cardBase = ui.createCard(tabAuto, "Base Egg Automation", "Otomatis tetaskan telur yang sudah siap di Base Anda")
    ui.addToggle(cardBase, "Auto Hatch Ready Eggs at Base", false, function(val)
        State.AutoHatchBase = val
        task.spawn(function()
            while State.AutoHatchBase do
                if not State.AutoStealEgg then
                    local myBase = getMyBase()
                    local placed = myBase and myBase:FindFirstChild("PlacedEggs")
                    if placed then
                        for _, egg in ipairs(placed:GetChildren()) do
                            if egg:GetAttribute("CanHatch") == true then
                                local p = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                                local part = egg:FindFirstChildWhichIsA("BasePart", true)
                                if part then
                                    smoothGlideTo(part.Position, function() return State.AutoHatchBase end)
                                    task.wait(0.3)
                                    if p then usePromptPureLegit(p) end
                                end
                            end
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end, 1)

    -- TAB ISLANDS (SMOOTH GLIDE KE PULAU)
    local cardTp = ui.createCard(tabTeleport, "Smooth Glide ke Pulau", "Meluncur aman ke pulau tanpa kena rubberband")
    local islandsFolder = Workspace:FindFirstChild("Structures") and Workspace.Structures:FindFirstChild("Islands")
    if islandsFolder then
        for idx, isl in ipairs(islandsFolder:GetChildren()) do
            ui.addButton(cardTp, "🏝️ GLIDE KE: " .. string.upper(isl.Name), function()
                local spawnPart = isl:FindFirstChild("SpawnEggs") or isl:FindFirstChild("Area") or isl:FindFirstChildWhichIsA("BasePart", true)
                if spawnPart then
                    smoothGlideTo(spawnPart.Position)
                end
            end, idx)
        end
    end

    -- TAB CONFIG (SCANNER KHUSUS PROMPTS & REMOTES)
    local cardCfg = ui.createCard(tabConfig, "Scanner Prompts & Remotes", "Klik tombol ini jika ingin melihat semua Remote & Prompt Map 2")
    local scanStatus = ui.addStatusBox(cardCfg, "Klik tombol di bawah untuk salin Prompts & Remotes")
    ui.addButton(cardCfg, "📋 SCAN PROMPTS & REMOTES (COPY)", function()
        runPromptsAndRemotesScan()
        scanStatus.Text = "✅ Berhasil disalin! Silakan Paste ke chat AI."
    end, 5)

-- ============================================================================
-- FALLBACK: UNIVERSAL MAP SCANNER
-- ============================================================================
else
    runPromptsAndRemotesScan()
end
