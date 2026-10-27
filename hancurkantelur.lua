-- ============================================================================
-- ★ ROCKSTAR HUB v1.0 - [🎃BOSS] HANCURKAN TELUR BRAINROT! (CYBER-BLUE) ★
-- Game: [🎃BOSS] Hancurkan Telur Brainrot! (PlaceId: 119271610514030 | GameId: 9491545867)
-- Fitur:
--   [✓] AUTO HANCURKAN TELUR: Multi-mode (Terdekat, HP Rendah, Rarity Terbaik) + Fast Hit
--   [✓] AUTO AMBIL DROP: Auto Pick Up Brainrot & Items di Workspace
--   [✓] AUTO BASE / MARKAS: Auto Collect Cash, Upgrade Platform, Pasang Brainrot Terbaik, Inkubator
--   [✓] AUTO PALU & TOKO: Auto Beli & Pasang Palu Terkuat, Beli Gear, Buka Zona 1-4
--   [✓] AUTO BOSS VAULT & EGG VAULT: Auto Masuk, Serang Lengan Boss, Serang Loot Egg & Vault
--   [✓] AUTO REBIRTH & PET: Auto Rebirth, Naikkan Level Pet, Auto Equip Best Pet
--   [✓] AUTO HADIAH & EVENT: Free Daily Spin Wheel, Daily & Discovery Rewards, Brainrot Trader
--   [✓] TELEPORT LENGKAP: Base, Toko Zona 1-4, Trader, Upgrades, Vaults
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

-- ============================================================================
-- 1. FRAMEWORK KNIT REMOTE RESOLVER & STATE
-- ============================================================================
local KnitPackages = ReplicatedStorage:WaitForChild("Packages", 5)
local KnitServices = KnitPackages and KnitPackages:WaitForChild("Knit", 5) and KnitPackages.Knit:WaitForChild("Services", 5)

local function GetKnitRemote(serviceName, remoteType, remoteName)
    if not KnitServices then return nil end
    local svc = KnitServices:FindFirstChild(serviceName)
    if not svc then return nil end
    local folder = svc:FindFirstChild(remoteType) -- "RF" or "RE"
    if not folder then return nil end
    return folder:FindFirstChild(remoteName)
end

local function SafeInvoke(serviceName, remoteName, ...)
    local rf = GetKnitRemote(serviceName, "RF", remoteName)
    if rf and rf:IsA("RemoteFunction") then
        local args = {...}
        local ok, res = pcall(function() return rf:InvokeServer(unpack(args)) end)
        return ok, res
    end
    return false, "RemoteFunction not found"
end

local function SafeFire(serviceName, remoteName, ...)
    local re = GetKnitRemote(serviceName, "RE", remoteName)
    if re and re:IsA("RemoteEvent") then
        local args = {...}
        pcall(function() re:FireServer(unpack(args)) end)
        return true
    end
    return false
end

-- ============================================================================
-- 2. KONFIGURASI SISTEM LENGKAP
-- ============================================================================
local Config = {
    -- Auto Farm Telur
    AutoHitEgg = false,
    EggTargetMode = "Terdekat", -- "Terdekat", "HP Terendah", "Rarity Tertinggi"
    EggZoneFilter = "Semua",    -- "Semua", "Zone1", "Zone2", "Zone3", "Zone4"
    AutoTeleportToEgg = false,
    EggHitDelay = 0.08,         -- ~12 hits per detik
    AutoBreakLuckyBlock = true,
    AutoPickUpDrops = true,

    -- Auto Base / Markas
    AutoCollectPlatform = true,
    AutoUpgradePlatform = false,
    AutoEquipBestBrainrot = true,
    AutoHatchIncubator = true,
    AutoPlaceEggBase = true,

    -- Auto Palu & Toko
    AutoBuyBestHammer = false,
    AutoEquipHammer = true,
    AutoBuyGear = false,
    AutoUnlockZones = false,

    -- Auto Vault & Boss
    AutoBossVault = false,
    AutoAttackBossTarget = true,
    AutoHitBossLoot = true,
    AutoEggVault = false,

    -- Auto Rebirth & Pet
    AutoRebirth = false,
    AutoUpgradePet = false,
    AutoEquipPet = true,
    AutoBuyPetEgg = false,

    -- Hadiah & Event
    AutoSpinWheel = true,
    AutoClaimDaily = true,
    AutoClaimDiscovery = true,
    AutoTradeBrainrot = false,

    -- Misc
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
}

local State = {
    MyBaseId = nil,
    TargetEgg = nil,
    HitsCount = 0,
    CashEarned = 0,
    InBossVault = false,
    LogBuffer = {},
}

local function Log(msg)
    local ts = os.date("%X")
    local entry = string.format("[%s] %s", ts, tostring(msg))
    table.insert(State.LogBuffer, 1, entry)
    if #State.LogBuffer > 35 then
        table.remove(State.LogBuffer)
    end
    print(entry)
end

-- ============================================================================
-- 3. DETEKSI MARKAS / BASE PEMAIN
-- ============================================================================
local function GetMyBase()
    if State.MyBaseId and Workspace:FindFirstChild("Bases") and Workspace.Bases:FindFirstChild(State.MyBaseId) then
        return Workspace.Bases[State.MyBaseId]
    end

    -- 1. Panggil Remote GetPlayerBaseId
    local ok, baseId = SafeInvoke("BaseService", "GetPlayerBaseId")
    if ok and baseId and Workspace:FindFirstChild("Bases") and Workspace.Bases:FindFirstChild(tostring(baseId)) then
        State.MyBaseId = tostring(baseId)
        return Workspace.Bases[State.MyBaseId]
    end

    -- 2. Cek Attr Owner di BaseFloor / Incubator
    local myUserId = LocalPlayer.UserId
    if Workspace:FindFirstChild("Bases") then
        for _, b in ipairs(Workspace.Bases:GetChildren()) do
            local bf = b:FindFirstChild("BaseFloor")
            if bf then
                if bf:GetAttribute("Owner") == myUserId then
                    State.MyBaseId = b.Name
                    return b
                end
                for _, desc in ipairs(bf:GetChildren()) do
                    if desc:GetAttribute("Owner") == myUserId then
                        State.MyBaseId = b.Name
                        return b
                    end
                end
            end
        end

        -- 3. Cek BillboardGui "YourBasePart"
        for _, b in ipairs(Workspace.Bases:GetChildren()) do
            local ybp = b:FindFirstChild("YourBasePart")
            if ybp and ybp:FindFirstChild("BillboardGui") and ybp.BillboardGui.Enabled then
                State.MyBaseId = b.Name
                return b
            end
        end
    end
    return nil
end

-- ============================================================================
-- 4. LOGIKA AUTO HIT EGG CERDAS (SELEKSI TARGET & OPTIMASI)
-- ============================================================================
local RarityPriority = {
    ["Common"] = 1,
    ["Rare"] = 2,
    ["Epic"] = 3,
    ["Legendary"] = 4,
    ["Mythic"] = 5,
    ["OG"] = 6,
    ["Godly"] = 7,
    ["Emerald"] = 8,
    ["Sapphire"] = 9,
    ["Amethyst"] = 10,
    ["Shadow"] = 11,
    ["Yeti"] = 12,
    ["DJ"] = 13,
    ["Gentleman"] = 14,
    ["Obsidian"] = 15,
    ["Celestite"] = 16,
    ["Angel"] = 17,
    ["Titan"] = 18,
    ["Inferno"] = 19,
    ["DIVINE"] = 20,
    ["COSMIC"] = 21,
    ["Admin"] = 22,
    ["Secret"] = 23,
    ["GodlyLuckyBlock"] = 24,
    ["MythicLuckyBlock"] = 25,
}

local function GetTargetEgg()
    local eggsFolder = Workspace:FindFirstChild("Eggs")
    if not eggsFolder then return nil end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local candidates = {}
    for _, eggPart in ipairs(eggsFolder:GetChildren()) do
        if eggPart:IsA("BasePart") then
            local hp = tonumber(eggPart:GetAttribute("Health")) or 0
            if hp > 0 then
                local strip = tostring(eggPart:GetAttribute("StripType") or "")
                local eggId = tostring(eggPart:GetAttribute("EggId") or "Common")
                local uuid = eggPart:GetAttribute("UUID") or eggPart.Name

                -- Filter Zone
                local passFilter = true
                if Config.EggZoneFilter ~= "Semua" then
                    if not strip:find(Config.EggZoneFilter) then
                        passFilter = false
                    end
                end

                if passFilter then
                    local dist = (hrp.Position - eggPart.Position).Magnitude
                    table.insert(candidates, {
                        Part = eggPart,
                        UUID = uuid,
                        HP = hp,
                        EggId = eggId,
                        Distance = dist,
                        RarityScore = RarityPriority[eggId] or 1,
                    })
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    -- Urutkan sesuai Target Mode
    if Config.EggTargetMode == "Terdekat" then
        table.sort(candidates, function(a, b) return a.Distance < b.Distance end)
    elseif Config.EggTargetMode == "HP Terendah" then
        table.sort(candidates, function(a, b) return a.HP < b.HP end)
    elseif Config.EggTargetMode == "Rarity Tertinggi" then
        table.sort(candidates, function(a, b)
            if a.RarityScore == b.RarityScore then
                return a.Distance < b.Distance
            end
            return a.RarityScore > b.RarityScore
        end)
    end

    return candidates[1]
end

-- ============================================================================
-- 5. DAFTAR ID PALU / HAMMERS DI TOKO
-- ============================================================================
local KnownHammerIds = {
    "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9", "i10",
    "i11", "i12", "i13", "i14", "i15", "i16", "i17", "i18", "i19", "i20",
    "i21", "i22", "i23", "i24", "i25", "i26", "i27", "i28", "i29", "i30",
    "i31", "i32", "i33", "i34", "i35", "i36", "i37", "i38", "i39", "i40",
    "i86", "i87"
}

-- ============================================================================
-- 6. BACKGROUND WORKER LOOPS
-- ============================================================================

-- Loop 1: Auto Hancurkan Telur (Fast Hit Egg)
task.spawn(function()
    while true do
        if Config.AutoHitEgg then
            local target = GetTargetEgg()
            if target then
                State.TargetEgg = target

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Teleport ke telur jika diaktifkan & jarak > 8 stud
                if Config.AutoTeleportToEgg and hrp and target.Distance > 8 then
                    hrp.CFrame = target.Part.CFrame + Vector3.new(0, 3.2, 0)
                    task.wait(0.04)
                end

                -- Kirim Remote RequestHitEgg (Format Knit Server)
                local hitRF = GetKnitRemote("EggSpawnerService", "RF", "RequestHitEgg")
                if hitRF then
                    pcall(function()
                        hitRF:InvokeServer({ [1] = target.UUID })
                    end)
                    State.HitsCount = State.HitsCount + 1
                end

                -- Tool Swing animation/activation
                pcall(function()
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end)
            end
            task.wait(Config.EggHitDelay)
        else
            State.TargetEgg = nil
            task.wait(0.5)
        end
    end
end)

-- Loop 2: Auto Ambil Drops (Brainrot & Item di Lantai)
task.spawn(function()
    while true do
        if Config.AutoPickUpDrops then
            local brainrotsFolder = Workspace:FindFirstChild("Brainrots")
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if brainrotsFolder and hrp then
                for _, item in ipairs(brainrotsFolder:GetChildren()) do
                    if not Config.AutoPickUpDrops then break end
                    -- Remote PickUp
                    SafeInvoke("BrainrotSpawnerService", "RequestPickUp", item.Name)
                    SafeInvoke("BrainrotSpawnerService", "RequestPickUp", item)

                    -- Fisika sentuhan jika dekat
                    local itemPart = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")
                    if itemPart and (hrp.Position - itemPart.Position).Magnitude < 25 and typeof(firetouchinterest) == "function" then
                        pcall(function()
                            firetouchinterest(hrp, itemPart, 0)
                            firetouchinterest(hrp, itemPart, 1)
                        end)
                    end
                end
            end
            task.wait(0.6)
        else
            task.wait(1.5)
        end
    end
end)

-- Loop 3: Auto Base / Markas (Collect Cash, Upgrade, Equip Best Brainrot)
task.spawn(function()
    while true do
        local base = GetMyBase()
        if base then
            -- 1. Panen Cash dari platform
            if Config.AutoCollectPlatform then
                SafeInvoke("BaseService", "RequestPlatformCollect")
                -- Trigger touch CollectZone jika ada
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local cz = base:FindFirstChild("CollectZone", true)
                if cz and hrp and typeof(firetouchinterest) == "function" then
                    pcall(function()
                        firetouchinterest(hrp, cz, 0)
                        firetouchinterest(hrp, cz, 1)
                    end)
                end
            end

            -- 2. Pasang Brainrot Terbaik
            if Config.AutoEquipBestBrainrot then
                SafeInvoke("BaseService", "RequestEquipBestBrainrots")
            end

            -- 3. Upgrade Semua Platform
            if Config.AutoUpgradePlatform then
                SafeInvoke("BaseService", "RequestPlatformUpgrade")
                local floors = base:FindFirstChild("Floor_1") or base:FindFirstChild("Floor_3")
                local platforms = floors and floors:FindFirstChild("Platforms")
                if platforms then
                    for _, plat in ipairs(platforms:GetChildren()) do
                        local platNum = tonumber(plat.Name:match("%d+"))
                        if platNum then
                            SafeInvoke("BaseService", "RequestPlatformUpgrade", platNum)
                        end
                    end
                end
            end

            -- 4. Tetaskan Telur di Inkubator & Tempatkan Telur
            if Config.AutoHatchIncubator then
                SafeInvoke("BaseService", "RequestHatchNow")
                SafeInvoke("BaseService", "RequestCollectEgg")
            end
            if Config.AutoPlaceEggBase then
                SafeInvoke("BaseService", "RequestPlaceEgg")
            end
        end
        task.wait(1.2)
    end
end)

-- Loop 4: Auto Palu & Toko (Beli & Pasang Palu Terkuat, Beli Gear)
task.spawn(function()
    while true do
        if Config.AutoBuyBestHammer then
            -- Coba beli dari palu tertinggi ke terendah
            for i = #KnownHammerIds, 1, -1 do
                local hId = KnownHammerIds[i]
                SafeInvoke("HammerShopService", "PurchaseHammer", hId)
            end
        end

        if Config.AutoEquipHammer then
            -- Coba pasang palu terkuat yang dimiliki
            for i = #KnownHammerIds, 1, -1 do
                local hId = KnownHammerIds[i]
                local ok = SafeInvoke("HammerShopService", "EquipHammer", hId)
                if ok then break end
            end
        end

        if Config.AutoBuyGear then
            SafeInvoke("GearShopService", "SetGearAutoBuy", true)
        end

        if Config.AutoUnlockZones then
            for z = 2, 4 do
                SafeInvoke("ZoneUnlockService", "RequestPurchaseZoneUnlock", z)
            end
        end
        task.wait(3.0)
    end
end)

-- Loop 5: Auto Boss Vault & Egg Vault
task.spawn(function()
    while true do
        -- Boss Vault
        if Config.AutoBossVault then
            local bossVault = Workspace:FindFirstChild("BossVault")
            if bossVault then
                -- Mulai Vault jika siap
                SafeInvoke("BossVaultService", "RequestStartVault")

                -- Serang AttackTargets pada Boss
                local targets = bossVault:FindFirstChild("AttackTargets")
                if targets and Config.AutoAttackBossTarget then
                    for _, tgt in ipairs(targets:GetChildren()) do
                        if tgt:IsA("BasePart") and tgt:GetAttribute("Active") == true then
                            SafeInvoke("BossVaultService", "RequestHitAttackTarget", tgt.Name)
                        end
                    end
                end

                -- Serang Loot Egg setelah Boss kalah
                if Config.AutoHitBossLoot then
                    SafeInvoke("BossVaultService", "RequestHitLootEgg")
                end
            end
        end

        -- Egg Vault (Cash Vault / Diamond / Chaos)
        if Config.AutoEggVault then
            SafeInvoke("EggVaultService", "RequestStartVault")
            SafeInvoke("EggVaultService", "RequestStartDiamondVault")
            SafeInvoke("EggVaultService", "RequestStartChaosVault")
            SafeInvoke("EggVaultService", "RequestHitVaultEgg")
        end

        task.wait(0.2)
    end
end)

-- Loop 6: Auto Rebirth, Pet & Event Gratis
task.spawn(function()
    while true do
        -- Auto Rebirth
        if Config.AutoRebirth then
            SafeInvoke("RebirthService", "RequestRebirth")
        end

        -- Auto Pet
        if Config.AutoUpgradePet then
            SafeInvoke("PetService", "RequestUpgradePet")
        end
        if Config.AutoEquipPet then
            SafeInvoke("PetService", "RequestEquipPet")
        end
        if Config.AutoBuyPetEgg then
            SafeInvoke("PetEggStockService", "PurchasePetEgg")
        end

        -- Auto Wheel Spin Gratis
        if Config.AutoSpinWheel then
            SafeInvoke("WheelSpinService", "RequestAccrueFreeSpins")
            SafeInvoke("WheelSpinService", "RequestSpin")
            SafeInvoke("WheelSpinService", "RequestClaimSpin")
        end

        -- Auto Klaim Hadiah Harian & Discovery
        if Config.AutoClaimDaily then
            SafeInvoke("RewardService", "ClaimDailyReward")
            SafeInvoke("RewardService", "RefreshDailyRewards")
        end
        if Config.AutoClaimDiscovery then
            SafeInvoke("RewardService", "ClaimDiscoveryReward")
            SafeInvoke("RewardTrackService", "RequestClaimNext")
            SafeInvoke("RewardTrackService", "RequestClaimMilestoneReward")
        end

        -- Auto Trade Brainrot Trader
        if Config.AutoTradeBrainrot then
            SafeInvoke("BrainrotTraderService", "RequestDepositBest")
            SafeInvoke("BrainrotTraderService", "RequestTrade")
            SafeInvoke("BrainrotTraderService", "RequestClaimTrade")
        end

        task.wait(4.0)
    end
end)

-- Loop 7: Player Mods (WalkSpeed, JumpPower, Noclip, InfJump)
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.WalkSpeed ~= Config.WalkSpeed and Config.WalkSpeed ~= 16 then
                hum.WalkSpeed = Config.WalkSpeed
            end
            if hum.JumpPower ~= Config.JumpPower and Config.JumpPower ~= 50 then
                hum.JumpPower = Config.JumpPower
            end
        end
        task.wait(0.5)
    end
end)

-- ============================================================================
-- 7. ANTARMUKA PENGGUNA (CYBER-BLUE EDITION UI)
-- ============================================================================
local Theme = {
    BgMain = Color3.fromRGB(11, 16, 26),
    BgCard = Color3.fromRGB(18, 26, 42),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentGlow = Color3.fromRGB(0, 220, 255),
    TextMain = Color3.fromRGB(240, 245, 255),
    TextSub = Color3.fromRGB(130, 150, 180),
    Success = Color3.fromRGB(34, 197, 94),
    Danger = Color3.fromRGB(239, 68, 68),
    Border = Color3.fromRGB(30, 41, 59),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarHub_BrainrotEgg"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

-- FLOATING TOGGLE BUTTON (R★)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "FloatingToggle"
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
ToggleBtn.BackgroundColor3 = Theme.BgCard
ToggleBtn.Text = "R★"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Theme.Accent
ToggleStroke.Thickness = 1.8
ToggleStroke.Parent = ToggleBtn

-- MAKE TOGGLE DRAGGABLE
local draggingToggle, dragStartToggle, startPosToggle
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        dragStartToggle = input.Position
        startPosToggle = ToggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingToggle = false end
        end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if draggingToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartToggle
        ToggleBtn.Position = UDim2.new(startPosToggle.X.Scale, startPosToggle.X.Offset + delta.X, startPosToggle.Y.Scale, startPosToggle.Y.Offset + delta.Y)
    end
end)

-- MAIN WINDOW
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 680, 0, 440)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
MainFrame.BackgroundColor3 = Theme.BgMain
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- MAKE MAINFRAME DRAGGABLE
local draggingMain, dragStartMain, startPosMain
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.Y - MainFrame.AbsolutePosition.Y <= 48 then
            draggingMain = true
            dragStartMain = input.Position
            startPosMain = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then draggingMain = false end
            end)
        end
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMain
        MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- TOP HEADER BAR
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Theme.BgCard
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0.7, 0, 1, 0)
HeaderTitle.Position = UDim2.new(0, 16, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "★ ROCKSTAR HUB - [🎃] HANCURKAN TELUR BRAINROT! ★"
HeaderTitle.TextColor3 = Theme.AccentGlow
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 13
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Theme.BgMain
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextSub
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- LEFT SIDEBAR
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.BackgroundColor3 = Theme.BgCard
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Theme.Accent
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 380)
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- CONTENT CONTAINER
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -150, 1, -48)
Content.Position = UDim2.new(0, 150, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local TabFrames = {}
local TabButtons = {}

local TabsList = {
    { Name = "Farm", Icon = "⚡", Title = "Auto Hancurkan Telur & Drops" },
    { Name = "Base", Icon = "🏛️", Title = "Markas & Platform Brainrot" },
    { Name = "Palu", Icon = "🔨", Title = "Toko Palu, Gear & Zona" },
    { Name = "Vault", Icon = "👑", Title = "Boss Vault & Egg Vault" },
    { Name = "Rebirth", Icon = "⭐", Title = "Rebirth & Pet System" },
    { Name = "Event", Icon = "🎁", Title = "Hadiah Gratis & Trader" },
    { Name = "Teleport", Icon = "🚀", Title = "Teleport & Player Mods" },
    { Name = "Log", Icon = "📋", Title = "Konsol Log Realtime" },
}

local function SwitchTab(tabName)
    for name, frame in pairs(TabFrames) do
        frame.Visible = (name == tabName)
    end
    for name, btn in pairs(TabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Theme.BgMain
            btn.TextColor3 = Theme.TextSub
        end
    end
end

for idx, tabInfo in ipairs(TabsList) do
    local btn = Instance.new("TextButton")
    btn.Name = tabInfo.Name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.BgMain
    btn.Text = tabInfo.Icon .. "  " .. tabInfo.Name
    btn.TextColor3 = Theme.TextSub
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.LayoutOrder = idx
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    TabButtons[tabInfo.Name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Name = tabInfo.Name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 600)
    page.Visible = false
    page.Parent = Content

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingLeft = UDim.new(0, 14)
    pagePadding.PaddingRight = UDim.new(0, 14)
    pagePadding.PaddingTop = UDim.new(0, 12)
    pagePadding.PaddingBottom = UDim.new(0, 12)
    pagePadding.Parent = page

    TabFrames[tabInfo.Name] = page

    btn.MouseButton1Click:Connect(function()
        SwitchTab(tabInfo.Name)
    end)
end

-- ============================================================================
-- 8. UI BUILDER HELPERS (CARD, TOGGLE, BUTTON, SLIDER, DROPDOWN)
-- ============================================================================
local function CreateCard(parent, title)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 40)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.BgCard
    card.BorderSizePixel = 0
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Theme.Border
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Padding = UDim.new(0, 6)
    cardLayout.Parent = card

    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingLeft = UDim.new(0, 12)
    cardPadding.PaddingRight = UDim.new(0, 12)
    cardPadding.PaddingTop = UDim.new(0, 10)
    cardPadding.PaddingBottom = UDim.new(0, 10)
    cardPadding.Parent = card

    if title then
        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, 0, 0, 20)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = title:upper()
        tLabel.TextColor3 = Theme.Accent
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = 10
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.Parent = card
    end

    return card
end

local function CreateToggle(parent, title, desc, configKey, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local tTitle = Instance.new("TextLabel")
    tTitle.Size = UDim2.new(0.72, 0, 0, 18)
    tTitle.Position = UDim2.new(0, 0, 0, 0)
    tTitle.BackgroundTransparency = 1
    tTitle.Text = title
    tTitle.TextColor3 = Theme.TextMain
    tTitle.Font = Enum.Font.GothamMedium
    tTitle.TextSize = 11
    tTitle.TextXAlignment = Enum.TextXAlignment.Left
    tTitle.Parent = row

    local tDesc = Instance.new("TextLabel")
    tDesc.Size = UDim2.new(0.72, 0, 0, 14)
    tDesc.Position = UDim2.new(0, 0, 0, 18)
    tDesc.BackgroundTransparency = 1
    tDesc.Text = desc or ""
    tDesc.TextColor3 = Theme.TextSub
    tDesc.Font = Enum.Font.Gotham
    tDesc.TextSize = 9
    tDesc.TextXAlignment = Enum.TextXAlignment.Left
    tDesc.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 42, 0, 22)
    switch.Position = UDim2.new(1, -42, 0.5, -11)
    switch.BackgroundColor3 = Config[configKey] and Theme.Accent or Theme.BgMain
    switch.Text = ""
    switch.Parent = row

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = Config[configKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    switch.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        local isEnabled = Config[configKey]
        TweenService:Create(switch, TweenInfo.new(0.2), {
            BackgroundColor3 = isEnabled and Theme.Accent or Theme.BgMain
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = isEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        if callback then callback(isEnabled) end
        Log(title .. " -> " .. (isEnabled and "AKTIF" or "NONAKTIF"))
    end)
    return row
end

local function CreateActionButton(parent, text, color, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color or Theme.Accent
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(onClick)
    end)
    return btn
end

-- ============================================================================
-- 9. POPULASI HALAMAN TAB LENGKAP
-- ============================================================================

-- TAB 1: AUTO FARM (TELUR & DROPS)
local p1Card = CreateCard(TabFrames["Farm"], "Otomatisasi Pukul Telur (Egg Farming)")
CreateToggle(p1Card, "Auto Hancurkan Telur", "Pukul telur secara otomatis dengan palu", "AutoHitEgg")
CreateToggle(p1Card, "Auto Teleport ke Telur", "Teleport melayang tepat di atas telur target", "AutoTeleportToEgg")
CreateToggle(p1Card, "Auto Hancurkan Lucky Block", "Prioritaskan Lucky Block saat muncul di map", "AutoBreakLuckyBlock")

local p1DropCard = CreateCard(TabFrames["Farm"], "Pengambilan Hadiah & Brainrot")
CreateToggle(p1DropCard, "Auto Ambil Brainrot & Drop", "Otomatis ambil semua item & brainrot yang jatuh di map", "AutoPickUpDrops")

-- TAB 2: BASE & MARKAS
local p2Card = CreateCard(TabFrames["Base"], "Manajemen Markas (Platforms & Incubator)")
CreateToggle(p2Card, "Auto Panen Cash Markas", "Ambil penghasilan uang platform otomatis", "AutoCollectPlatform")
CreateToggle(p2Card, "Auto Pasang Brainrot Terbaik", "Otomatis pasang brainrot terkuat ke platform", "AutoEquipBestBrainrot")
CreateToggle(p2Card, "Auto Tingkatkan Semua Platform", "Naikkan level semua platform markas pemain", "AutoUpgradePlatform")
CreateToggle(p2Card, "Auto Tetaskan Telur Inkubator", "Tetaskan telur markas secara otomatis", "AutoHatchIncubator")
CreateToggle(p2Card, "Auto Tempatkan Telur Markas", "Tempatkan telur cadangan ke inkubator markas", "AutoPlaceEggBase")

CreateActionButton(p2Card, "🚀 Teleport ke Markas Sendiri", Theme.Accent, function()
    local b = GetMyBase()
    local spawnLoc = b and (b:FindFirstChild("SpawnLocation") or b:FindFirstChild("BaseFloor"))
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if spawnLoc and hrp then
        hrp.CFrame = spawnLoc.CFrame + Vector3.new(0, 4, 0)
        Log("Berhasil teleport ke markas!")
    else
        Log("Markas belum ditemukan!")
    end
end)

-- TAB 3: PALU & TOKO
local p3Card = CreateCard(TabFrames["Palu"], "Toko Palu (Hammers), Gear & Zona")
CreateToggle(p3Card, "Auto Beli Palu Terkuat", "Beli palu tertinggi yang uangnya mencukupi", "AutoBuyBestHammer")
CreateToggle(p3Card, "Auto Pasang Palu Terbaik", "Otomatis gunakan palu terkuat yang dimiliki", "AutoEquipHammer")
CreateToggle(p3Card, "Auto Beli Gear Toko", "Aktifkan pembelian otomatis perlengkapan", "AutoBuyGear")
CreateToggle(p3Card, "Auto Buka Semua Zona (1-4)", "Buka gerbang zona baru otomatis saat mampu", "AutoUnlockZones")

CreateActionButton(p3Card, "🔨 Pasang Palu Terkuat Sekarang", Theme.Accent, function()
    for i = #KnownHammerIds, 1, -1 do
        local hId = KnownHammerIds[i]
        local ok = SafeInvoke("HammerShopService", "EquipHammer", hId)
        if ok then
            Log("Berhasil memasang palu: " .. hId)
            break
        end
    end
end)

-- TAB 4: VAULT & BOSS
local p4Card = CreateCard(TabFrames["Vault"], "Pertarungan Boss Vault & Egg Vault")
CreateToggle(p4Card, "Auto Boss Vault Penuh", "Masuk otomatis ke Boss Vault & serang", "AutoBossVault")
CreateToggle(p4Card, "Auto Serang Lengan Boss", "Serang target Left/Right arms otomatis", "AutoAttackBossTarget")
CreateToggle(p4Card, "Auto Serang Loot Egg Boss", "Hancurkan loot egg hadiah setelah Boss kalah", "AutoHitBossLoot")
CreateToggle(p4Card, "Auto Cash & Diamond Vault", "Buka dan serang peti vault secara otomatis", "AutoEggVault")

CreateActionButton(p4Card, "⚡ Mulai Pertarungan Boss Sekarang", Theme.Accent, function()
    SafeInvoke("BossVaultService", "RequestStartVault")
    Log("Mencoba memulai Boss Vault!")
end)

-- TAB 5: REBIRTH & PET
local p5Card = CreateCard(TabFrames["Rebirth"], "Peningkatan Rebirth & Hewan Peliharaan (Pets)")
CreateToggle(p5Card, "Auto Rebirth Otomatis", "Lakukan Rebirth setiap kali syarat terpenuhi", "AutoRebirth")
CreateToggle(p5Card, "Auto Tingkatkan Level Pet", "Tingkatkan kekuatan pet otomatis", "AutoUpgradePet")
CreateToggle(p5Card, "Auto Pasang Pet Terbaik", "Pasang pet dengan status tertinggi", "AutoEquipPet")
CreateToggle(p5Card, "Auto Beli Telur Pet", "Beli telur pet otomatis di Pet Shop", "AutoBuyPetEgg")

CreateActionButton(p5Card, "⭐ Rebirth Sekarang", Theme.Accent, function()
    local ok = SafeInvoke("RebirthService", "RequestRebirth")
    if ok then Log("Berhasil Rebirth!") else Log("Syarat Rebirth belum cukup!") end
end)

-- TAB 6: HADIAH GRATIS & EVENT
local p6Card = CreateCard(TabFrames["Event"], "Hadiah Gratis & Brainrot Trader")
CreateToggle(p6Card, "Auto Putar Roda Gratis (Wheel Spin)", "Klaim free spin dan putar roda keberuntungan", "AutoSpinWheel")
CreateToggle(p6Card, "Auto Klaim Hadiah Harian", "Ambil Daily Rewards otomatis setiap hari", "AutoClaimDaily")
CreateToggle(p6Card, "Auto Klaim Discovery & Milestone", "Klaim reward discovery & track otomatis", "AutoClaimDiscovery")
CreateToggle(p6Card, "Auto Trade Brainrot Trader", "Setor dan tukar brainrot di NPC Trader", "AutoTradeBrainrot")

-- TAB 7: TELEPORT & PLAYER MODS
local p7Card = CreateCard(TabFrames["Teleport"], "Lokasi Teleport Penting")
local TeleportLocations = {
    { Name = "Toko Palu & Gear Zona 1", Pos = Vector3.new(-17.3, 3.0, -57.8) },
    { Name = "Toko Palu & Gear Zona 2", Pos = Vector3.new(-17.0, 3.5, -280.8) },
    { Name = "Toko Palu & Gear Zona 3", Pos = Vector3.new(-16.9, 3.5, -560.0) },
    { Name = "Toko Palu & Gear Zona 4", Pos = Vector3.new(-16.9, 3.5, -839.0) },
    { Name = "Mesin Peningkatan (Upgrades)", Pos = Vector3.new(-25.0, 3.0, 43.5) },
    { Name = "Brainrot Trader", Pos = Vector3.new(-72.1, 3.0, -56.8) },
    { Name = "Gerbang Egg Vault", Pos = Vector3.new(108.8, 4.0, -58.8) },
    { Name = "Gerbang Boss Vault", Pos = Vector3.new(-142.2, 4.0, -58.8) },
}

for _, loc in ipairs(TeleportLocations) do
    CreateActionButton(p7Card, "📍 " .. loc.Name, Theme.BgMain, function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(loc.Pos)
            Log("Teleport ke: " .. loc.Name)
        end
    end)
end

local p7ModsCard = CreateCard(TabFrames["Teleport"], "Modifikasi Karakter Pemain")
CreateToggle(p7ModsCard, "Lompatan Tanpa Batas (Inf Jump)", "Lompat di udara tanpa henti", "InfiniteJump")
CreateToggle(p7ModsCard, "Menembus Dinding (Noclip)", "Karakter dapat menembus tembok & pagar", "Noclip")

-- TAB 8: KONSOL LOG
local p8Card = CreateCard(TabFrames["Log"], "Status Sistem & Riwayat Aktivitas")
local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, 0, 0, 220)
LogText.BackgroundTransparency = 1
LogText.Text = "Menunggu aktivitas sistem..."
LogText.TextColor3 = Theme.TextSub
LogText.Font = Enum.Font.Code
LogText.TextSize = 10
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Parent = p8Card

local function RefreshLogDisplay()
    LogText.Text = table.concat(State.LogBuffer, "\n")
end

task.spawn(function()
    while true do
        pcall(RefreshLogDisplay)
        task.wait(1.5)
    end
end)

-- Default Tab
SwitchTab("Farm")

Log("★ ROCKSTAR HUB DIMUAT - HANCURKAN TELUR BRAINROT! ★")
print("★ ROCKSTAR HUB - [🎃BOSS] HANCURKAN TELUR BRAINROT! BERHASIL DIMUAT! ★")
