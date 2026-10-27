-- ============================================================================
-- ★ ROCKSTAR HUB v6.0 - CYBER BLUE EDITION (100% NATIVE) ★
-- Game   : [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299)
-- Engine : Dibuat Presisi dari Data JSON Rockstar Dev Scanner v4.0
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Remotes = ReplicatedStorage:WaitForChild("Shared", 10) and ReplicatedStorage.Shared:WaitForChild("Remotes", 10)

-- ============================================================================
-- 1. STATE & KONFIGURASI FITUR
-- ============================================================================
local State = {
    AutoRoll = false,
    AutoCollectCash = false,
    AutoUpgradePodium = false,
    AutoEquipBest = false,
    AutoTreadmill = false,
    AutoSpinWheel = false,
    AutoClaimRewards = false,
    AutoSkipAdBoard = false,
    AutoTower = false,
    AutoRebirth = false,
    AutoSellWeakest = false,
    AutoCandyClaim = false,
    WalkSpeed = 16,
    CustomSpeed = false,
}

-- ============================================================================
-- 2. FUNGSI HELPER PRESISI MAP (PLOT, PODIUM, PROMPT, & REMOTE)
-- ============================================================================
local function GetRemote(name)
    if not Remotes then
        local sh = ReplicatedStorage:FindFirstChild("Shared")
        Remotes = sh and sh:FindFirstChild("Remotes")
    end
    return Remotes and Remotes:FindFirstChild(name)
end

local function SafeInvoke(remoteName, ...)
    local r = GetRemote(remoteName)
    if r and r:IsA("RemoteFunction") then
        local ok, res = pcall(function(...)
            return r:InvokeServer(...)
        end, ...)
        return ok, res
    end
    return false, nil
end

local function SafeFire(remoteName, ...)
    local r = GetRemote(remoteName)
    if r and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent")) then
        pcall(function(...)
            r:FireServer(...)
        end, ...)
    end
end

-- Cari Plot milik LocalPlayer berdasarkan atribut OwnerUserId
local function GetMyPlot()
    for i = 1, 8 do
        local plot = Workspace:FindFirstChild("Plot" .. tostring(i))
        if plot and plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end

-- Ambil semua Podium yang sudah terbuka (Lantai 1 & Lantai 2) di Plot kita
local function GetMyPodiums()
    local list = {}
    local plot = GetMyPlot()
    if not plot then return list end

    local f1 = plot:FindFirstChild("Podiums")
    if f1 then
        for _, pod in ipairs(f1:GetChildren()) do
            if pod:IsA("Model") and pod:GetAttribute("Locked") ~= true then
                table.insert(list, pod)
            end
        end
    end

    local floor2 = plot:FindFirstChild("Floor2")
    local f2 = floor2 and floor2:FindFirstChild("Podiums")
    if f2 then
        for _, pod in ipairs(f2:GetChildren()) do
            if pod:IsA("Model") and pod:GetAttribute("Locked") ~= true then
                table.insert(list, pod)
            end
        end
    end
    return list
end

local function TeleportTo(posOrCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if typeof(posOrCFrame) == "Vector3" then
        hrp.CFrame = CFrame.new(posOrCFrame + Vector3.new(0, 3, 0))
    elseif typeof(posOrCFrame) == "CFrame" then
        hrp.CFrame = posOrCFrame
    end
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if type(fireproximityprompt) == "function" then
        pcall(fireproximityprompt, prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(math.max(0.05, prompt.HoldDuration or 0))
            prompt:InputHoldEnd()
        end)
    end
end

local function TriggerTouch(part)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not part or not part:IsA("BasePart") then return end
    if type(firetouchinterest) == "function" then
        pcall(firetouchinterest, hrp, part, 0)
        pcall(firetouchinterest, hrp, part, 1)
    else
        -- Sentuh sangat cepat tanpa memindahkan pandangan
        local oldCF = hrp.CFrame
        hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.05)
        hrp.CFrame = oldCF
    end
end

-- ============================================================================
-- 3. UI ROCKSTAR HUB v6.0 (CUSTOM CYBER BLUE - VERSI SENDIRI)
-- ============================================================================
local guiParent = (type(gethui) == "function" and gethui()) or CoreGui
local oldUI = guiParent:FindFirstChild("RockstarHubRollPetsV6")
if oldUI then oldUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RockstarHubRollPetsV6"
screenGui.DisplayOrder = 999999999
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- Tombol Floating Lingkaran Neon R★
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 54, 0, 54)
floatBtn.Position = UDim2.new(0, 18, 0.42, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(0, 125, 255)
floatBtn.Font = Enum.Font.GothamBlack
floatBtn.TextSize = 18
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Text = "R★"
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local floatGrad = Instance.new("UIGradient", floatBtn)
floatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 225, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 210))
})
floatGrad.Rotation = 45

local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = Color3.fromRGB(0, 225, 255)
floatStroke.Thickness = 2.2

-- Main Window
local mainWin = Instance.new("Frame")
mainWin.Size = UDim2.new(0, 560, 0, 390)
mainWin.Position = UDim2.new(0.5, -280, 0.5, -195)
mainWin.BackgroundColor3 = Color3.fromRGB(7, 12, 22)
mainWin.BorderSizePixel = 0
mainWin.Active = true
mainWin.Draggable = true
mainWin.Parent = screenGui
Instance.new("UICorner", mainWin).CornerRadius = UDim.new(0, 12)

local winStroke = Instance.new("UIStroke", mainWin)
winStroke.Color = Color3.fromRGB(0, 185, 255)
winStroke.Thickness = 2

floatBtn.MouseButton1Click:Connect(function()
    mainWin.Visible = not mainWin.Visible
end)

-- Top Header Bar
local topBar = Instance.new("Frame", mainWin)
topBar.Size = UDim2.new(1, 0, 0, 46)
topBar.BackgroundColor3 = Color3.fromRGB(11, 22, 42)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topLine = Instance.new("Frame", topBar)
topLine.Size = UDim2.new(1, -24, 0, 2)
topLine.Position = UDim2.new(0, 12, 1, -2)
topLine.BackgroundColor3 = Color3.fromRGB(0, 215, 255)
topLine.BorderSizePixel = 0

local badgeLogo = Instance.new("TextLabel", topBar)
badgeLogo.Size = UDim2.new(0, 34, 0, 30)
badgeLogo.Position = UDim2.new(0, 12, 0, 8)
badgeLogo.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
badgeLogo.Font = Enum.Font.GothamBlack
badgeLogo.TextSize = 14
badgeLogo.TextColor3 = Color3.new(1, 1, 1)
badgeLogo.Text = "R★"
Instance.new("UICorner", badgeLogo).CornerRadius = UDim.new(0, 7)

local titleText = Instance.new("TextLabel", topBar)
titleText.Size = UDim2.new(1, -160, 1, 0)
titleText.Position = UDim2.new(0, 54, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextColor3 = Color3.fromRGB(235, 248, 255)
titleText.Text = "ROCKSTAR HUB v6.0  •  [🎃] PUTAR HEWAN PELIHARAAN"

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -42, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(18, 38, 72)
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(0, 215, 255)
minBtn.Text = "—"
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 7)
minBtn.MouseButton1Click:Connect(function()
    mainWin.Visible = false
end)

-- Sidebar Kiri
local sidebar = Instance.new("Frame", mainWin)
sidebar.Size = UDim2.new(0, 155, 1, -58)
sidebar.Position = UDim2.new(0, 10, 0, 52)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 18, 34)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
local sideStroke = Instance.new("UIStroke", sidebar)
sideStroke.Color = Color3.fromRGB(0, 120, 210)
sideStroke.Transparency = 0.55

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop = UDim.new(0, 10)

-- Area Konten Kanan
local contentHolder = Instance.new("Frame", mainWin)
contentHolder.Size = UDim2.new(1, -182, 1, -58)
contentHolder.Position = UDim2.new(0, 172, 0, 52)
contentHolder.BackgroundTransparency = 1

local Pages = {}
local TabButtons = {}

local function CreateTab(tabName)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(15, 28, 52)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(160, 200, 240)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. tabName
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("ScrollingFrame", contentHolder)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 205, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", page)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(Pages) do p.Visible = (k == tabName) end
        for k, b in pairs(TabButtons) do
            if k == tabName then
                b.BackgroundColor3 = Color3.fromRGB(0, 135, 255)
                b.TextColor3 = Color3.new(1, 1, 1)
            else
                b.BackgroundColor3 = Color3.fromRGB(15, 28, 52)
                b.TextColor3 = Color3.fromRGB(160, 200, 240)
            end
        end
    end)

    Pages[tabName] = page
    TabButtons[tabName] = btn
    return page
end

local function AddToggle(page, title, desc, defaultVal, callback)
    local card = Instance.new("Frame", page)
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = Color3.fromRGB(13, 24, 44)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)
    local st = Instance.new("UIStroke", card)
    st.Color = Color3.fromRGB(0, 140, 235)
    st.Transparency = 0.55

    local lblTitle = Instance.new("TextLabel", card)
    lblTitle.Size = UDim2.new(1, -75, 0, 22)
    lblTitle.Position = UDim2.new(0, 12, 0, 6)
    lblTitle.BackgroundTransparency = 1
    lblTitle.Font = Enum.Font.GothamBold
    lblTitle.TextSize = 13
    lblTitle.TextXAlignment = Enum.TextXAlignment.Left
    lblTitle.TextColor3 = Color3.fromRGB(235, 248, 255)
    lblTitle.Text = title

    local lblDesc = Instance.new("TextLabel", card)
    lblDesc.Size = UDim2.new(1, -75, 0, 16)
    lblDesc.Position = UDim2.new(0, 12, 0, 27)
    lblDesc.BackgroundTransparency = 1
    lblDesc.Font = Enum.Font.Gotham
    lblDesc.TextSize = 10
    lblDesc.TextXAlignment = Enum.TextXAlignment.Left
    lblDesc.TextColor3 = Color3.fromRGB(135, 175, 220)
    lblDesc.Text = desc

    local swBtn = Instance.new("TextButton", card)
    swBtn.Size = UDim2.new(0, 48, 0, 24)
    swBtn.Position = UDim2.new(1, -60, 0.5, -12)
    swBtn.Font = Enum.Font.GothamBlack
    swBtn.TextSize = 10
    swBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", swBtn).CornerRadius = UDim.new(1, 0)

    local state = defaultVal == true
    local function Render()
        swBtn.BackgroundColor3 = state and Color3.fromRGB(0, 195, 255) or Color3.fromRGB(30, 48, 78)
        swBtn.Text = state and "ON" or "OFF"
    end
    Render()

    swBtn.MouseButton1Click:Connect(function()
        state = not state
        Render()
        task.spawn(callback, state)
    end)
end

local function AddButton(page, title, btnText, callback)
    local card = Instance.new("Frame", page)
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Color3.fromRGB(13, 24, 44)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)
    local st = Instance.new("UIStroke", card)
    st.Color = Color3.fromRGB(0, 140, 235)
    st.Transparency = 0.55

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -120, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(235, 248, 255)
    lbl.Text = title

    local actBtn = Instance.new("TextButton", card)
    actBtn.Size = UDim2.new(0, 100, 0, 28)
    actBtn.Position = UDim2.new(1, -110, 0.5, -14)
    actBtn.BackgroundColor3 = Color3.fromRGB(0, 135, 255)
    actBtn.Font = Enum.Font.GothamBlack
    actBtn.TextSize = 11
    actBtn.TextColor3 = Color3.new(1, 1, 1)
    actBtn.Text = btnText
    Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 7)

    actBtn.MouseButton1Click:Connect(function()
        task.spawn(callback, actBtn)
    end)
end

-- ============================================================================
-- 4. ISI MENU & FITUR (SESUAI STRUKTUR JSON MAP)
-- ============================================================================
local tabMain     = CreateTab("⚡ Auto Utama")
local tabRewards  = CreateTab("🎁 Klaim & Rahasia")
local tabEvent    = CreateTab("🎃 Event & Tower")
local tabTeleport = CreateTab("📍 Teleport Map")
local tabPlayer   = CreateTab("⚙️ Karakter")

-- Aktifkan tab pertama
TabButtons["⚡ Auto Utama"].BackgroundColor3 = Color3.fromRGB(0, 135, 255)
TabButtons["⚡ Auto Utama"].TextColor3 = Color3.new(1, 1, 1)
Pages["⚡ Auto Utama"].Visible = true

-- [TAB 1: AUTO UTAMA]
AddToggle(tabMain, "🎲 Auto Roll Cepat (RequestRoll)", "Otomatis memutar dadu/hewan peliharaan terus-menerus tanpa henti", false, function(v)
    State.AutoRoll = v
end)

AddToggle(tabMain, "💰 Auto Ambil Uang Podium (Plot Sendiri)", "Otomatis mengambil uang dari semua CollectPad Podium di Plot kamu", false, function(v)
    State.AutoCollectCash = v
end)

AddToggle(tabMain, "⬆️ Auto Upgrade Semua Podium (Max)", "Otomatis klik Upgrade Max pada semua Podium yang terbuka di Plot kamu", false, function(v)
    State.AutoUpgradePodium = v
end)

AddToggle(tabMain, "🐾 Auto Equip Pet & Tim Terbaik", "Otomatis memanggil EquipBestPets & EquipBestTeam secara berkala", false, function(v)
    State.AutoEquipBest = v
end)

AddToggle(tabMain, "🏃 Auto Lari di Treadmill Plot", "Otomatis menempatkan karakter di atas Treadmill Plot untuk Luck Boost", false, function(v)
    State.AutoTreadmill = v
end)

-- [TAB 2: KLAIM & RAHASIA]
AddButton(tabRewards, "🌟 Klaim 3 Golden Dice Rahasia (Alley, Hidden, Tower)", "KLAIM SEMUA", function(btn)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local oldCF = hrp.CFrame
    btn.Text = "MENGAMBIL..."

    local secrets = {
        Workspace:FindFirstChild("AlleySecret"),
        Workspace:FindFirstChild("HiddenSecret"),
        Workspace:FindFirstChild("TowerSecret"),
    }

    for _, model in ipairs(secrets) do
        local dice = model and model:FindFirstChild("GoldenDice")
        local prompt = dice and dice:FindFirstChildOfClass("ProximityPrompt")
        if dice and prompt then
            TeleportTo(dice.Position)
            task.wait(0.35)
            TriggerPrompt(prompt)
            task.wait(1.1)
        end
    end

    hrp.CFrame = oldCF
    btn.Text = "✅ SELESAI!"
    task.delay(2, function() if btn and btn.Parent then btn.Text = "KLAIM SEMUA" end end)
end)

AddToggle(tabRewards, "🎡 Auto Spin Wheel Gratis", "Otomatis memutar Spin Wheel setiap kali tersedia", false, function(v)
    State.AutoSpinWheel = v
end)

AddToggle(tabRewards, "🎁 Auto Klaim Daily, Playtime, Quest & Chest", "Otomatis klaim hadiah harian, waktu main, achievement, & peti grup/teman", false, function(v)
    State.AutoClaimRewards = v
end)

AddToggle(tabRewards, "⏩ Auto Skip 5 Menit (AdBoard Plot)", "Otomatis memicu WatchSkipAd / WatchPrompt di papan iklan Plot", false, function(v)
    State.AutoSkipAdBoard = v
end)

-- [TAB 3: EVENT & TOWER]
AddToggle(tabEvent, "🍬 Auto Klaim Permen Halloween (CandyRain)", "Otomatis menyedot dan klaim semua permen yang jatuh saat Candy Rain", false, function(v)
    State.AutoCandyClaim = v
end)

AddToggle(tabEvent, "🗼 Auto Masuk & Retry Tower", "Otomatis mengaktifkan Auto Retry dan masuk ke dalam Tower", false, function(v)
    State.AutoTower = v
    if v then
        SafeFire("SetTowerAutoRetry", true)
    end
end)

AddToggle(tabEvent, "♻️ Auto Rebirth Otomatis", "Otomatis melakukan Rebirth begitu syarat uang terpenuhi", false, function(v)
    State.AutoRebirth = v
end)

AddToggle(tabEvent, "🗑️ Auto Jual Pet Terlemah (SellWeakest)", "Otomatis menjual pet terlemah agar tas tidak penuh", false, function(v)
    State.AutoSellWeakest = v
end)

-- [TAB 4: TELEPORT MAP]
AddButton(tabTeleport, "🏠 Teleport ke Plot / Base Sendiri", "TELEPORT", function()
    local plot = GetMyPlot()
    local sp = plot and plot:FindFirstChild("Spawn")
    if sp then
        TeleportTo(sp.Position)
    else
        SafeInvoke("TravelHome")
    end
end)

AddButton(tabTeleport, "🧬 Teleport ke Mesin Fuse (FusingMachine)", "TELEPORT", function()
    TeleportTo(Vector3.new(229.0, 326.0, 13.5))
end)

AddButton(tabTeleport, "🍬 Teleport ke Candy Shop Halloween", "TELEPORT", function()
    TeleportTo(Vector3.new(203.7, 329.5, 48.1))
end)

AddButton(tabTeleport, "⚰️ Teleport ke Haunted Crate Stand", "TELEPORT", function()
    TeleportTo(Vector3.new(189.5, 330.3, 55.6))
end)

AddButton(tabTeleport, "🎡 Teleport ke Roda Putar (Spin Wheel)", "TELEPORT", function()
    TeleportTo(Vector3.new(235.5, 339.1, -53.7))
end)

AddButton(tabTeleport, "🗼 Teleport ke Gerbang Towers", "TELEPORT", function()
    TeleportTo(Vector3.new(-297.8, 326.0, -28.2))
end)

AddButton(tabTeleport, "🤝 Teleport ke Area Trading (TradePad)", "TELEPORT", function()
    TeleportTo(Vector3.new(119.6, 329.5, -26.2))
end)

AddButton(tabTeleport, "🎈 Teleport ke Balon Glitch Blimp", "TELEPORT", function()
    TeleportTo(Vector3.new(97.5, 382.0, -235.0))
end)

AddButton(tabTeleport, "🧙 Teleport ke Ruang Rahasia Wizard's Stash", "TELEPORT", function()
    TeleportTo(Vector3.new(-328.4, 358.4, -32.2))
end)

-- [TAB 5: KARAKTER]
AddToggle(tabPlayer, "⚡ Lari Cepat (WalkSpeed 55)", "Meningkatkan kecepatan jalan karakter di map", false, function(v)
    State.CustomSpeed = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and not v then hum.WalkSpeed = 16 end
end)

AddButton(tabPlayer, "🔓 Buka Semua Pintu Podium & Klaim Pet Gratis", "JALANKAN", function()
    SafeInvoke("ClaimFreePet")
    SafeInvoke("EquipBestPets")
    SafeInvoke("EquipBestTeam")
end)

-- ============================================================================
-- 5. LOOP OTOMATISASI PRESISI (BACKGROUND ENGINE)
-- ============================================================================

-- Anti-AFK Otomatis
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Loop 1: Auto Roll Cepat (RequestRoll)
task.spawn(function()
    while screenGui.Parent do
        if State.AutoRoll then
            SafeInvoke("RequestRoll", false)
            task.wait(0.15)
        else
            task.wait(0.4)
        end
    end
end)

-- Loop 2: Auto Collect Cash Podium & Auto Upgrade Podium
task.spawn(function()
    while screenGui.Parent do
        if State.AutoCollectCash or State.AutoUpgradePodium then
            local podiums = GetMyPodiums()
            for _, pod in ipairs(podiums) do
                if State.AutoCollectCash then
                    local pad = pod:FindFirstChild("CollectPad")
                    if pad then
                        local storedBase = tonumber(pad:GetAttribute("StoredBase")) or 0
                        local storedRate = tonumber(pad:GetAttribute("StoredRate")) or 0
                        if storedBase > 0 or storedRate > 0 then
                            TriggerTouch(pad)
                            SafeFire("CashCollected", pod:GetAttribute("Slot"))
                        end
                    end
                end

                if State.AutoUpgradePodium then
                    local slot = pod:GetAttribute("Slot")
                    if slot then
                        SafeInvoke("PodiumAction", "UpgradeMax", slot)
                        SafeInvoke("PodiumAction", "Upgrade", slot)
                    end
                    local screenFace = pod:FindFirstChild("ScreenFace")
                    local maxFace = screenFace and screenFace:FindFirstChild("MaxFace")
                    local clickDet = (maxFace and maxFace:FindFirstChildOfClass("ClickDetector")) or (screenFace and screenFace:FindFirstChildOfClass("ClickDetector"))
                    if clickDet and type(fireclickdetector) == "function" then
                        pcall(fireclickdetector, clickDet)
                    end
                    local screenMesh = pod:FindFirstChild("Screen")
                    local podPromptFolder = screenMesh and screenMesh:FindFirstChild("PodiumPrompt")
                    local upgMaxPrompt = podPromptFolder and podPromptFolder:FindFirstChild("UpgradeMaxPrompt")
                    if upgMaxPrompt then
                        TriggerPrompt(upgMaxPrompt)
                    end
                end
            end
        end
        task.wait(0.8)
    end
end)

-- Loop 3: Auto Treadmill & WalkSpeed
RunService.Heartbeat:Connect(function()
    if not screenGui.Parent then return end
    local char = LocalPlayer.Character
    if not char then return end

    if State.CustomSpeed then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed < 55 then
            hum.WalkSpeed = 55
        end
    end

    if State.AutoTreadmill then
        local plot = GetMyPlot()
        local tm = plot and plot:FindFirstChild("Treadmill")
        local deck = tm and tm:FindFirstChild("Deck")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if deck and hrp then
            if (hrp.Position - deck.Position).Magnitude > 6 then
                hrp.CFrame = deck.CFrame + Vector3.new(0, 3.2, 0)
            end
            for _, d in ipairs(tm:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    TriggerPrompt(d)
                end
            end
        end
    end
end)

-- Loop 4: Auto Equip, Rewards, Spin, Tower, Rebirth, Candy
task.spawn(function()
    while screenGui.Parent do
        if State.AutoEquipBest then
            SafeInvoke("EquipBestPets")
            SafeInvoke("EquipBestTeam")
        end

        if State.AutoSpinWheel then
            SafeInvoke("SpinWheel")
            local sw = Workspace:FindFirstChild("SpinWheel")
            local base = sw and sw:FindFirstChild("Base")
            local pr = base and base:FindFirstChildOfClass("ProximityPrompt")
            if pr then TriggerPrompt(pr) end
        end

        if State.AutoClaimRewards then
            SafeInvoke("ClaimDaily")
            SafeInvoke("ClaimAllAchievements")
            SafeInvoke("ClaimStarterQuest")
            SafeInvoke("ClaimGroupChest")
            SafeInvoke("ClaimFriendChest")
            for i = 1, 12 do
                SafeInvoke("ClaimPlaytime", i)
                SafeInvoke("ClaimQuest", i)
            end
        end

        if State.AutoSkipAdBoard then
            SafeInvoke("WatchSkipAd")
            local plot = GetMyPlot()
            local ad = plot and plot:FindFirstChild("AdBoard")
            local panel = ad and ad:FindFirstChild("Panel")
            local wp = panel and panel:FindFirstChild("WatchPrompt")
            if wp then TriggerPrompt(wp) end
        end

        if State.AutoTower then
            SafeFire("SetTowerAutoRetry", true)
            SafeInvoke("ResumeTower")
            SafeInvoke("StartTower")
        end

        if State.AutoRebirth then
            SafeInvoke("Rebirth")
        end

        if State.AutoSellWeakest then
            SafeInvoke("SellWeakest")
        end

        if State.AutoCandyClaim then
            SafeFire("CandyClaim")
            local cr = Workspace:FindFirstChild("CandyRain")
            if cr then
                for _, item in ipairs(cr:GetDescendants()) do
                    if item:IsA("BasePart") and item.Position.Y > 0 then
                        TriggerTouch(item)
                    end
                end
            end
        end

        task.wait(2.5)
    end
end)
