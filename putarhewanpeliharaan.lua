-- ============================================================================
-- ★ ROCKSTAR HUB v7.8 - [🎃] PUTAR HEWAN PELIHARAAN (CYBER-BLUE EDITION) ★
-- Game: [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299 | PlaceVersion: 1264)
-- Update v7.8:
--   [✓] UPGRADE PET / PODIUM JARAK JAUH: 100% Tanpa Teleport (Bypass Proximity & Remote)
--   [✓] FIX AUTO TREADMILL: Berdiri di Belt + Touch Physics + Auto Run aktif
--   [✓] FIX AUTO MENARA OTOMATIS PENUH:
--       - AutoClick GUI (Deteksi luas: Start/Fight/Battle/Mulai/Tarung/Stage)
--       - Auto Fast Combat Tap (VirtualInputManager + VirtualUser + 20 CPS)
--       - Auto Retry & Decline Revive instan
--   [✓] DADU TERBAIK & AUTO BUY TOKO DADU: Stabil & True Luck (Tanpa Skip Void)
--   [✓] AUTO SELL: Jual Pet Terlemah & Jual Semua Pet Cadangan
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- 1. PENGATURAN & STATE GLOBAL
-- ============================================================================
local Config = {
    -- Auto Roll & Pet
    AutoRoll = false,
    RollDelay = 0.15,
    AutoEquipBest = false,
    AutoFuse = false,
    AutoSellWeakest = false,
    AutoSellAll = false,

    -- Sistem Dadu v7.8
    AutoBuyDiceOnly = false,
    AutoEquipDice = false,
    DiceMode = "AutoBest",          -- "AutoBest" atau "Manual"
    SelectedDiceIndex = 1,
    LockedDiceId = nil,
    AutoTeleportDiceShop = false,

    -- Auto Collect & Plot
    AutoCollectCash = false,
    AutoBuyAutoCollect = false,
    AutoTreadmill = false,
    AutoWatchSkipAd = false,

    -- Auto Peningkatan Jarak Jauh
    AutoUpgradePodium = false,
    RemoteUpgradeOnly = true,       -- Upgrade 100% jarak jauh tanpa teleport
    AutoBuyAllUpgrades = false,
    AutoBuyRebirthUpgrades = false,
    AutoRerollTrait = false,
    TraitTargetMode = "BestOnly",
    AutoRollGrade = false,
    GradeTargetMode = "BestOnly",
    AutoTeleportTraitShop = false,
    AutoBuyCandyShop = false,
    AutoBuyQuestShop = false,
    AutoRebirth = false,

    -- Auto Menara (Full Automation)
    AutoTower = false,
    TowerStageMode = "Selected",    -- "Selected" atau "Highest"
    SelectedStage = 1,
    HighestUnlockedStage = 1,
    AutoTeleportToTowerPad = true,
    AutoTapTowerCombat = true,
    AutoRetryTower = true,
    AutoDeclineRevive = true,
    AutoEquipTowerTeam = true,

    -- Event & Utility
    AutoSpinWheel = false,
    AutoClaimRewards = false,
    AutoClaimCandy = false,
    AutoTeleportCandy = false,
    InstantPrompt = true,
    AntiAFK = true,
}

-- State Internal
local State = {
    CurrentDiceName = "Mendeteksi...",
    CurrentDiceLuck = 1,
    LastEquippedDiceId = nil,
    FailedEquipCount = 0,
    ManualOverrideUntil = 0,
    InTower = false,
    LastTowerAttempt = 0,
    LearnedDiceArgs = {},
    LearnedUpgradeArgs = {},
    CachedMyPlot = nil,
    OwnedDiceCache = {},
    LogBuffer = {},
    LogMaxLines = 10,
}

local function Log(msg)
    local timestamp = os.date("%X")
    local line = string.format("[%s] %s", timestamp, msg)
    table.insert(State.LogBuffer, 1, line)
    if #State.LogBuffer > State.LogMaxLines then
        table.remove(State.LogBuffer)
    end
    print("★ ROCKSTAR: " .. msg)
end

-- ============================================================================
-- 2. KONEKSI REMOTES RESMI (REPLICATEDSTORAGE.SHARED.REMOTES)
-- ============================================================================
local SharedFolder = ReplicatedStorage:WaitForChild("Shared", 10)
local RemotesFolder = SharedFolder and SharedFolder:WaitForChild("Remotes", 10)

local function GetRemote(name)
    local r = nil
    if RemotesFolder then
        r = RemotesFolder:FindFirstChild(name)
    end
    if not r then
        r = ReplicatedStorage:FindFirstChild(name, true)
    end
    return r
end

local Remotes = {
    RequestRoll = GetRemote("RequestRoll"),
    EquipBestPets = GetRemote("EquipBestPets"),
    EquipBestTeam = GetRemote("EquipBestTeam"),
    FusePets = GetRemote("FusePets"),
    SellWeakest = GetRemote("SellWeakest"),
    SellAll = GetRemote("SellAll"),
    SellPets = GetRemote("SellPets"),
    PodiumAction = GetRemote("PodiumAction"),
    CashCollected = GetRemote("CashCollected"),

    BuyUpgrade = GetRemote("BuyUpgrade"),
    UpgradeRebirthStat = GetRemote("UpgradeRebirthStat"),
    Rebirth = GetRemote("Rebirth"),
    BuyDice = GetRemote("BuyDice"),
    EquipDice = GetRemote("EquipDice"),
    BuyCandyShop = GetRemote("BuyCandyShop"),
    BuyQuestShop = GetRemote("BuyQuestShop"),
    RerollTrait = GetRemote("RerollTrait"),
    RollGrade = GetRemote("RollGrade"),

    StartTower = GetRemote("StartTower"),
    LeaveTower = GetRemote("LeaveTower"),
    DeclineRevive = GetRemote("DeclineRevive"),
    ResumeTower = GetRemote("ResumeTower"),
    SetTowerAutoRetry = GetRemote("SetTowerAutoRetry"),
    TowerEvent = GetRemote("TowerEvent"),

    GetData = GetRemote("GetData"),
    ClaimDaily = GetRemote("ClaimDaily"),
    ClaimPlaytime = GetRemote("ClaimPlaytime"),
    ClaimQuest = GetRemote("ClaimQuest"),
    ClaimStarterQuest = GetRemote("ClaimStarterQuest"),
    ClaimAllAchievements = GetRemote("ClaimAllAchievements"),
    ClaimGroupChest = GetRemote("ClaimGroupChest"),
    ClaimFriendChest = GetRemote("ClaimFriendChest"),
    ClaimFreePet = GetRemote("ClaimFreePet"),
    SpinWheel = GetRemote("SpinWheel"),
    WatchSkipAd = GetRemote("WatchSkipAd"),
    CandyClaim = GetRemote("CandyClaim"),
}

local function SafeCall(remoteName, isFire, ...)
    local r = Remotes[remoteName] or GetRemote(remoteName)
    if r then
        Remotes[remoteName] = r
        if isFire then
            return pcall(function(...) r:FireServer(...) end, ...)
        else
            return pcall(function(...) return r:InvokeServer(...) end, ...)
        end
    end
    return false
end

-- ============================================================================
-- 3. ENSIKLOPEDIA DADU RESMI (TRUE LUCK RANKING)
-- ============================================================================
local TierMultiplier = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 5,
    ["Epic"] = 15,
    ["Legendary"] = 50,
    ["Mythic"] = 200,
    ["Mythical"] = 200,
    ["Exotic"] = 1000,
    ["Secret"] = 5000,
    ["Divine"] = 25000,
    ["Celestial"] = 100000,
    ["Infinity"] = 500000,
}

local KnownDiceCatalog = {
    { Name = "Common", Aliases = {"Biasa", "Common"}, Luck = 1, Tier = "Common" },
    { Name = "Wooden", Aliases = {"Kayu", "Wood", "Wooden"}, Luck = 1.25, Tier = "Common" },
    { Name = "Stone", Aliases = {"Batu", "Stone"}, Luck = 1.5, Tier = "Uncommon" },
    { Name = "Bronze", Aliases = {"Perunggu", "Bronze"}, Luck = 2.0, Tier = "Uncommon" },
    { Name = "Silver", Aliases = {"Perak", "Silver"}, Luck = 3.0, Tier = "Rare" },
    { Name = "Gold", Aliases = {"Emas", "Gold", "Golden"}, Luck = 5.0, Tier = "Rare" },
    { Name = "Diamond", Aliases = {"Berlian", "Diamond"}, Luck = 10.0, Tier = "Epic" },
    { Name = "Emerald", Aliases = {"Zamrud", "Emerald"}, Luck = 25.0, Tier = "Epic" },
    { Name = "Ruby", Aliases = {"Delima", "Ruby"}, Luck = 50.0, Tier = "Epic" },
    { Name = "Storm", Aliases = {"Badai", "Storm"}, Luck = 70.0, Tier = "Epic" },
    { Name = "Shadow", Aliases = {"Bayangan", "Shadow"}, Luck = 90.0, Tier = "Epic" },
    { Name = "Amethyst", Aliases = {"Kecubung", "Amethyst"}, Luck = 100.0, Tier = "Legendary" },
    { Name = "Obsidian", Aliases = {"Obsidian"}, Luck = 250.0, Tier = "Legendary" },
    { Name = "Magma", Aliases = {"Magma", "Lava"}, Luck = 500.0, Tier = "Legendary" },
    { Name = "Plasma", Aliases = {"Plasma"}, Luck = 750.0, Tier = "Legendary" },
    { Name = "Void", Aliases = {"Kekosongan", "Void"}, Luck = 1500.0, Tier = "Legendary" },
    { Name = "Pumpkin", Aliases = {"Labu", "Pumpkin"}, Luck = 5000.0, Tier = "Exotic" },
    { Name = "Halloween", Aliases = {"Halloween", "Spooky"}, Luck = 25000.0, Tier = "Exotic" },
    { Name = "Solar", Aliases = {"Solar", "Matahari"}, Luck = 10000000.0, Tier = "Mythical" },
    { Name = "Lunar", Aliases = {"Lunar", "Bulan"}, Luck = 40000000.0, Tier = "Mythical" },
    { Name = "Galaxy", Aliases = {"Galaxy", "Galaksi"}, Luck = 100000000.0, Tier = "Divine" },
    { Name = "Infinity", Aliases = {"Infinity", "Tak Terbatas"}, Luck = 500000000.0, Tier = "Infinity" },
}

local function ParseMultiplierString(str)
    if not str then return nil end
    local clean = string.gsub(str, "[,%+xX🍀]", "")
    clean = string.gsub(clean, "%s+", "")
    local numStr, unit = string.match(clean, "([%d%.]+)%s*([kKmMbBtT]?)")
    if numStr then
        local val = tonumber(numStr)
        if val then
            unit = string.upper(unit or "")
            if unit == "K" then val = val * 1e3
            elseif unit == "M" then val = val * 1e6
            elseif unit == "B" then val = val * 1e9
            elseif unit == "T" then val = val * 1e12 end
            return val
        end
    end
    return nil
end

local function EvaluateDiceLuck(rawTitle, rawTier, rawLuckStr)
    local parsedLuck = ParseMultiplierString(rawLuckStr)
    if parsedLuck and parsedLuck > 0 then
        return parsedLuck
    end

    local normTitle = string.lower(rawTitle or "")
    for _, item in ipairs(KnownDiceCatalog) do
        for _, alias in ipairs(item.Aliases) do
            if string.find(normTitle, string.lower(alias), 1, true) then
                return item.Luck
            end
        end
    end

    local normTier = string.gsub(rawTier or "", "[%[%]%s]", "")
    for tierName, mult in pairs(TierMultiplier) do
        if string.find(string.lower(normTier), string.lower(tierName), 1, true) then
            return mult * 10
        end
    end

    return 1
end

-- ============================================================================
-- 4. SCANNING DICE SHOP GUI (BEBAS INTERFERENSI)
-- ============================================================================
local function GetDiceCardsFromGui()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return {} end

    local targetContainers = {}
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            if string.find(gui.Name, "RockstarHub") then
                continue
            end

            local isShopGui = false
            local gName = string.lower(gui.Name)
            if string.find(gName, "dice") or string.find(gName, "shop") or string.find(gName, "dadu") or string.find(gName, "toko") then
                isShopGui = true
            else
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Visible then
                        local txt = string.lower(desc.Text)
                        if string.find(txt, "dice shop") or string.find(txt, "toko dadu") then
                            isShopGui = true
                            break
                        end
                    end
                end
            end

            if isShopGui then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if (desc:IsA("ScrollingFrame") or desc:IsA("Frame")) and desc:FindFirstChildOfClass("UIListLayout") then
                        table.insert(targetContainers, desc)
                    end
                end
            end
        end
    end

    local cardsFound = {}
    for _, container in ipairs(targetContainers) do
        for _, card in ipairs(container:GetChildren()) do
            if card:IsA("Frame") or card:IsA("ImageLabel") or card:IsA("ImageButton") then
                local titleLabel, tierLabel, luckLabel, equipBtn, buyBtn
                local isEquipped = false
                local isOwned = false

                for _, el in ipairs(card:GetDescendants()) do
                    if el:IsA("TextLabel") or el:IsA("TextButton") then
                        local txt = string.lower(el.Text)
                        if string.find(txt, "equipped") or string.find(txt, "terpasang") or string.find(txt, "dipakai") or string.find(txt, "dilengkapi") then
                            isEquipped = true
                            isOwned = true
                        elseif string.find(txt, "equip") or string.find(txt, "pasang") or string.find(txt, "pakai") or string.find(txt, "lengkapi") then
                            if el:IsA("TextButton") or el:IsA("ImageButton") or el.Parent:IsA("TextButton") or el.Parent:IsA("ImageButton") then
                                equipBtn = el:IsA("TextButton") and el or el.Parent
                                isOwned = true
                            end
                        elseif string.find(txt, "buy") or string.find(txt, "beli") or string.find(txt, "$") or string.find(txt, "🪙") then
                            if el:IsA("TextButton") or el:IsA("ImageButton") or el.Parent:IsA("TextButton") or el.Parent:IsA("ImageButton") then
                                buyBtn = el:IsA("TextButton") and el or el.Parent
                            end
                        end

                        if el:IsA("TextLabel") then
                            if string.find(txt, "🍀") or string.find(txt, "luck") or string.find(txt, "keberuntungan") or string.find(txt, "x") then
                                luckLabel = el.Text
                            end
                            for tierName, _ in pairs(TierMultiplier) do
                                if string.find(txt, string.lower(tierName)) then
                                    tierLabel = el.Text
                                    break
                                end
                            end
                            if not titleLabel and el.Text ~= "" and not string.find(txt, "luck") and not string.find(txt, "buy") and not string.find(txt, "equip") and not string.find(txt, "$") then
                                titleLabel = el.Text
                            end
                        end
                    end
                end

                if titleLabel then
                    local cleanName = string.match(titleLabel, "([^|%-

]+)") or titleLabel
                    cleanName = string.gsub(cleanName, "^%s+", "")
                    cleanName = string.gsub(cleanName, "%s+$", "")

                    local calculatedLuck = EvaluateDiceLuck(cleanName, tierLabel, luckLabel)
                    local cardStatus = "unowned"
                    if isEquipped then cardStatus = "equipped"
                    elseif isOwned then cardStatus = "owned"
                    end

                    table.insert(cardsFound, {
                        CardInstance = card,
                        Name = cleanName,
                        RawTitle = titleLabel,
                        Tier = tierLabel or "Unknown",
                        Luck = calculatedLuck,
                        Status = cardStatus,
                        EquipButton = equipBtn,
                        BuyButton = buyBtn,
                    })
                end
            end
        end
    end

    return cardsFound
end

-- ============================================================================
-- 5. LOGIKA DADU TERBAIK & PEMASANGAN OTOMATIS (ZERO SPAM)
-- ============================================================================
local IsScriptCallingEquip = false

local function EquipTargetDiceNow(force)
    if tick() < State.ManualOverrideUntil then return end
    if not Config.AutoEquipDice and not force then return end

    local cards = GetDiceCardsFromGui()
    local targetCard = nil

    if #cards > 0 then
        if Config.DiceMode == "Manual" and Config.LockedDiceId then
            for _, card in ipairs(cards) do
                if string.find(string.lower(card.Name), string.lower(Config.LockedDiceId), 1, true) then
                    if card.Status == "owned" or card.Status == "equipped" then
                        targetCard = card
                        break
                    end
                end
            end
        else
            local highestLuck = -1
            for _, card in ipairs(cards) do
                if card.Status == "owned" or card.Status == "equipped" then
                    if card.Luck > highestLuck then
                        highestLuck = card.Luck
                        targetCard = card
                    end
                end
            end
        end
    end

    -- Jika toko tertutup, periksa dari data server GetData
    if not targetCard and Remotes.GetData then
        local ok, pData = pcall(function() return Remotes.GetData:InvokeServer() end)
        if ok and type(pData) == "table" then
            local currentEq = pData.EquippedDice or pData.CurrentDice or pData.Dice
            if currentEq and type(currentEq) == "string" then
                State.CurrentDiceName = currentEq
            end

            local ownedDiceList = {}
            for k, v in pairs(pData) do
                local lk = tostring(k):lower()
                if lk:find("dice") and type(v) == "table" then
                    for dk, dv in pairs(v) do
                        local dName = (type(dk) == "string" and dk) or (type(dv) == "string" and dv)
                        if dName then
                            local lkVal = EvaluateDiceLuck(dName, nil, nil)
                            table.insert(ownedDiceList, { Name = dName, Luck = lkVal })
                        end
                    end
                end
            end

            table.sort(ownedDiceList, function(a, b) return a.Luck > b.Luck end)
            if #ownedDiceList > 0 then
                local bestServerDice = ownedDiceList[1]
                if State.CurrentDiceName == bestServerDice.Name then
                    return
                end

                IsScriptCallingEquip = true
                SafeCall("EquipDice", false, bestServerDice.Name)
                task.delay(0.5, function() IsScriptCallingEquip = false end)
                Log("Memasang Dadu Terbaik (Data Server): " .. bestServerDice.Name .. " (🍀 " .. bestServerDice.Luck .. "x)")
                State.CurrentDiceName = bestServerDice.Name
                return
            end
        end
    end

    if not targetCard then return end

    if targetCard.Status == "equipped" then
        State.CurrentDiceName = targetCard.Name
        State.CurrentDiceLuck = targetCard.Luck
        State.FailedEquipCount = 0
        return
    end

    if State.LastEquippedDiceId == targetCard.Name and State.FailedEquipCount >= 3 then
        return
    end

    if targetCard.Status == "owned" and targetCard.EquipButton then
        IsScriptCallingEquip = true
        pcall(function()
            for _, conn in ipairs(getconnections(targetCard.EquipButton.MouseButton1Click)) do conn:Fire() end
            for _, conn in ipairs(getconnections(targetCard.EquipButton.Activated)) do conn:Fire() end
        end)
        task.delay(0.5, function() IsScriptCallingEquip = false end)

        Log("Memasang Dadu Terbaik: " .. targetCard.Name .. " (🍀 " .. targetCard.Luck .. "x)")
        State.LastEquippedDiceId = targetCard.Name
        State.FailedEquipCount = State.FailedEquipCount + 1
        return
    end

    if Remotes.EquipDice then
        IsScriptCallingEquip = true
        SafeCall("EquipDice", false, targetCard.Name)
        task.delay(0.5, function() IsScriptCallingEquip = false end)

        Log("Remote Equip Dadu: " .. targetCard.Name)
        State.LastEquippedDiceId = targetCard.Name
        State.FailedEquipCount = State.FailedEquipCount + 1
    end
end

-- ============================================================================
-- 6. DETEKSI PLOT & SISTEM UPGRADE JARAK JAUH
-- ============================================================================
local function GetMyPlot()
    if State.CachedMyPlot and State.CachedMyPlot.Parent == Workspace and State.CachedMyPlot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
        return State.CachedMyPlot
    end

    for i = 1, 8 do
        local plot = Workspace:FindFirstChild("Plot" .. i)
        if plot and plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            State.CachedMyPlot = plot
            return plot
        end
    end

    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name:match("^Plot%d+$") and child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            State.CachedMyPlot = child
            return child
        end
    end
    return nil
end

local function GetMyPodiums()
    local plot = GetMyPlot()
    if not plot then return {} end
    local podiums = {}
    local f1 = plot:FindFirstChild("Podiums")
    if f1 then
        for _, p in ipairs(f1:GetChildren()) do
            if p:IsA("Model") then table.insert(podiums, p) end
        end
    end
    local floor2 = plot:FindFirstChild("Floor2")
    local f2 = floor2 and floor2:FindFirstChild("Podiums")
    if f2 then
        for _, p in ipairs(f2:GetChildren()) do
            if p:IsA("Model") then table.insert(podiums, p) end
        end
    end
    table.sort(podiums, function(a, b)
        return (tonumber(a:GetAttribute("Slot")) or 99) < (tonumber(b:GetAttribute("Slot")) or 99)
    end)
    return podiums
end

-- UPGRADE 100% JARAK JAUH TANPA PERLU JALAN / TELEPORT
local function UpgradeAllPodiumsRemote()
    local podiums = GetMyPodiums()
    for _, podium in ipairs(podiums) do
        if not Config.AutoUpgradePodium then break end
        local slotNum = tonumber(podium:GetAttribute("Slot")) or tonumber(podium.Name:match("%d+"))
        local petUuid = podium:GetAttribute("PetUuid")

        -- 1. Panggil Remote Resmi (Bisa dari jarak berapapun)
        if slotNum then
            SafeCall("PodiumAction", false, slotNum, "UpgradeMax")
            SafeCall("PodiumAction", false, slotNum, "Upgrade")
        end
        if petUuid then
            SafeCall("UpgradePet", false, petUuid)
            SafeCall("LevelUpPet", false, petUuid)
            SafeCall("PodiumAction", false, petUuid, "UpgradeMax")
        end

        -- 2. Trigger ClickDetector dari jarak jauh (fireclickdetector bypass jarak)
        for _, desc in ipairs(podium:GetDescendants()) do
            if desc:IsA("ClickDetector") and typeof(fireclickdetector) == "function" then
                pcall(function() fireclickdetector(desc) end)
            end
        end

        -- 3. Trigger ProximityPrompt dari jarak jauh (Bypass Jarak Maksimal)
        for _, desc in ipairs(podium:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.MaxActivationDistance = math.huge
                desc.RequiresLineOfSight = false
                desc.HoldDuration = 0
                pcall(function() fireproximityprompt(desc) end)
            end
        end
        task.wait(0.04)
    end
end

-- ============================================================================
-- 7. SISTEM AUTO MENARA OTOMATIS PENUH (AUTO-CLICK GUI & FAST COMBAT)
-- ============================================================================
local function GetTargetTowerStage()
    if Config.TowerStageMode == "Highest" then
        return math.max(1, tonumber(Config.HighestUnlockedStage) or 1)
    end
    return math.max(1, tonumber(Config.SelectedStage) or 1)
end

if Remotes.TowerEvent and Remotes.TowerEvent:IsA("RemoteEvent") then
    Remotes.TowerEvent.OnClientEvent:Connect(function(eventType, payload)
        local evStr = tostring(eventType or ""):lower()
        if type(payload) == "table" then
            local stg = tonumber(payload.Stage or payload.Floor or payload.Wave or payload.NextStage or payload.UnlockedStage)
            if stg and stg > Config.HighestUnlockedStage then Config.HighestUnlockedStage = stg end
        elseif type(payload) == "number" and payload > Config.HighestUnlockedStage and payload <= 1000 then
            Config.HighestUnlockedStage = payload
        end

        if evStr:find("start") or evStr:find("wave") or evStr:find("spawn") or evStr:find("enter") or evStr:find("fight") then
            State.InTower = true
        elseif evStr:find("win") or evStr:find("victory") or evStr:find("clear") or evStr:find("complete") then
            State.InTower = false
            Config.HighestUnlockedStage = math.max(Config.HighestUnlockedStage, Config.SelectedStage + 1)
        elseif evStr:find("end") or evStr:find("die") or evStr:find("lose") or evStr:find("defeat") or evStr:find("fail") then
            State.InTower = false
            if Config.AutoDeclineRevive then
                SafeCall("DeclineRevive", false)
            end
        end
    end)
end

local function AutoClickTowerGUI(stageNum)
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then return end

    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and not string.find(g.Name, "RockstarHub") then
            for _, desc in ipairs(g:GetDescendants()) do
                if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                    local bText = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                    local bName = desc.Name:lower()

                    -- Klik tombol mulai / bertarung
                    if bText:find("start") or bText:find("fight") or bText:find("battle") or bText:find("mulai") 
                       or bText:find("tarung") or bText:find("masuk") or bText:find("play") or bText:find("enter") 
                       or bText:find("retry") or bText:find("ulang") or bText:find("next") or bText:find("lanjut")
                       or bName:find("start") or bName:find("fight") or bName:find("battle") or bName:find("enter") then
                        pcall(function()
                            for _, conn in ipairs(getconnections(desc.MouseButton1Click)) do conn:Fire() end
                            for _, conn in ipairs(getconnections(desc.Activated)) do conn:Fire() end
                        end)
                    end

                    -- Klik tombol stage
                    if stageNum and (bText == tostring(stageNum) or bName == "stage" .. tostring(stageNum) or bName == tostring(stageNum)) then
                        pcall(function()
                            for _, conn in ipairs(getconnections(desc.MouseButton1Click)) do conn:Fire() end
                            for _, conn in ipairs(getconnections(desc.Activated)) do conn:Fire() end
                        end)
                    end
                end
            end
        end
    end
end

local function StartTowerStage(stageNum)
    if tick() - State.LastTowerAttempt < 2.0 then return end
    State.LastTowerAttempt = tick()

    if Config.AutoRetryTower then
        SafeCall("SetTowerAutoRetry", true, true)
    end

    if Config.AutoEquipTowerTeam then
        SafeCall("EquipBestTeam", false)
    end

    local towersPad = Workspace:FindFirstChild("TowersPad", true) or Workspace:FindFirstChild("TowerPad", true)
    local zone = towersPad and (towersPad:FindFirstChild("Zone") or towersPad:FindFirstChildOfClass("BasePart"))
    local standPrompt = towersPad and (towersPad:FindFirstChild("StandTowers", true) or towersPad:FindFirstChildOfClass("ProximityPrompt"))

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if Config.AutoTeleportToTowerPad and zone and hrp then
        if (hrp.Position - zone.Position).Magnitude > 12 then
            hrp.CFrame = zone.CFrame + Vector3.new(0, 3.5, 0)
            task.wait(0.2)
        end
    end

    if standPrompt then
        standPrompt.MaxActivationDistance = math.huge
        standPrompt.RequiresLineOfSight = false
        standPrompt.HoldDuration = 0
        pcall(function() fireproximityprompt(standPrompt) end)
        task.wait(0.1)
    end

    AutoClickTowerGUI(stageNum)
    SafeCall("StartTower", false, stageNum)
    SafeCall("StartTower", false)
end

-- ============================================================================
-- 8. BACKGROUND LOOPS OTOMATISASI LENGKAP
-- ============================================================================

-- Loop 1: Auto Roll Pet, Equip Best, Fuse & Auto Sell
task.spawn(function()
    while true do
        if Config.AutoRoll then
            SafeCall("RequestRoll", false)

            if Config.AutoEquipBest then
                SafeCall("EquipBestPets", false)
            end
            if Config.AutoFuse then
                SafeCall("FusePets", false, "All")
                SafeCall("FusePets", false)
            end
            if Config.AutoSellWeakest then
                SafeCall("SellWeakest", false)
            end
            if Config.AutoSellAll then
                SafeCall("SellAll", false)
            end
            task.wait(Config.RollDelay)
        else
            if Config.AutoSellWeakest then
                SafeCall("SellWeakest", false)
            end
            if Config.AutoSellAll then
                SafeCall("SellAll", false)
            end
            task.wait(0.5)
        end
    end
end)

-- Loop 2: Auto Collect Cash (CollectPad)
task.spawn(function()
    while true do
        if Config.AutoCollectCash then
            local plot = GetMyPlot()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if plot and hrp then
                for _, podium in ipairs(GetMyPodiums()) do
                    local colPad = podium:FindFirstChild("CollectPad")
                    if colPad and colPad:IsA("BasePart") then
                        if typeof(firetouchinterest) == "function" then
                            pcall(function()
                                firetouchinterest(hrp, colPad, 0)
                                firetouchinterest(hrp, colPad, 1)
                            end)
                        end
                    end
                end
            end
            SafeCall("CashCollected", true)
        end
        task.wait(0.3)
    end
end)

-- Loop 2B: Auto Treadmill (Teleport ke Belt + Touch + Auto Move)
task.spawn(function()
    while true do
        if Config.AutoTreadmill then
            local plot = GetMyPlot()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if plot and hrp then
                local tm = plot:FindFirstChild("Treadmill") or plot:FindFirstChild("TreadmillSpot")
                if tm then
                    local belt = tm:FindFirstChild("Belt") or tm:FindFirstChild("Deck") or tm:FindFirstChildOfClass("BasePart")
                    if belt then
                        -- Berdiri di atas permukaan belt
                        if (hrp.Position - belt.Position).Magnitude > 8 then
                            hrp.CFrame = belt.CFrame + Vector3.new(0, 2.8, 0)
                            task.wait(0.1)
                        end

                        if typeof(firetouchinterest) == "function" then
                            pcall(function()
                                firetouchinterest(hrp, belt, 0)
                                firetouchinterest(hrp, belt, 1)
                            end)
                        end

                        if humanoid and humanoid.MoveDirection.Magnitude == 0 then
                            humanoid:Move(Vector3.new(0, 0, -1), true)
                        end
                    end
                end
            end
            task.wait(0.25)
        else
            task.wait(1.0)
        end
    end
end)

-- Loop 3: Auto Beli Dadu Toko
task.spawn(function()
    while true do
        if Config.AutoBuyDiceOnly then
            if Config.AutoTeleportDiceShop then
                local dicePad = Workspace:FindFirstChild("DiceShopPad", true)
                local zone = dicePad and dicePad:FindFirstChild("Zone")
                local prompt = dicePad and dicePad:FindFirstChild("StandDiceShop", true)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if zone and hrp and (hrp.Position - zone.Position).Magnitude > 12 then
                    hrp.CFrame = zone.CFrame + Vector3.new(0, 3.5, 0)
                    task.wait(0.15)
                end
                if prompt then
                    prompt.MaxActivationDistance = math.huge
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end

            local cards = GetDiceCardsFromGui()
            for _, card in ipairs(cards) do
                if card.Status == "unowned" and card.BuyButton then
                    pcall(function()
                        for _, conn in ipairs(getconnections(card.BuyButton.MouseButton1Click)) do conn:Fire() end
                        for _, conn in ipairs(getconnections(card.BuyButton.Activated)) do conn:Fire() end
                    end)
                    task.wait(0.15)
                end
            end

            for _, d in ipairs(KnownDiceCatalog) do
                SafeCall("BuyDice", false, d.Name)
                task.wait(0.04)
            end

            if Config.AutoEquipDice then
                EquipTargetDiceNow(false)
            end
        end
        task.wait(2.0)
    end
end)

-- Loop 4: Auto Pasang Dadu (Thread Tenang 4 Detik)
task.spawn(function()
    while true do
        if Config.AutoEquipDice then
            EquipTargetDiceNow(false)
        end
        task.wait(4.0)
    end
end)

-- Loop 5: Auto Peningkatan (Podium Jarak Jauh, Upgrade Toko & Rebirth)
local PreseededUpgrades = {
    "Luck1", "Luck2", "Luck3", "Luck4", "Luck5",
    "RollSpeed1", "RollSpeed2", "RollSpeed3", "RollSpeed4", "RollSpeed5",
    "MutationLuck1", "MutationLuck2", "MutationLuck3", "MutationLuck4", "MutationLuck5",
    "TreadmillLuck1", "TreadmillLuck2", "TreadmillLuck3", "TreadmillLuck4", "TreadmillLuck5",
    "GoldenDice1", "GoldenDice2", "GoldenDice3", "GoldenDice4", "GoldenDice5",
    "Cash1", "Cash2", "Cash3", "Cash4", "Cash5",
    "Inventory1", "Inventory2", "Inventory3",
}

local PreseededRebirthStats = {
    "Luck1", "Luck2", "Luck3", "Cash1", "Cash2", "Cash3",
    "RollSpeed1", "RollSpeed2", "MutationLuck1", "MutationLuck2",
    "Luck", "Cash", "RollSpeed", "Inventory", "Damage", "Candy",
}

local PreseededCandyShopItems = {
    "HauntedCrate", "PumpkinDice", "HalloweenDice", "CandyLuck1", "CandyLuck2",
    "CandyMultiplier1", "CandyRollSpeed1", "CandyPack1", "CandyPack2", "CandyPack3",
}

local PreseededQuestShopItems = {
    "Luck1", "RollSpeed1", "MutationLuck1", "GoldenDice1",
}

task.spawn(function()
    while true do
        if Config.AutoUpgradePodium then
            UpgradeAllPodiumsRemote()
        end

        if Config.AutoBuyAllUpgrades then
            for _, key in ipairs(PreseededUpgrades) do
                SafeCall("BuyUpgrade", false, key)
                task.wait(0.02)
            end
            for key, args in pairs(State.LearnedUpgradeArgs) do
                SafeCall("BuyUpgrade", false, unpack(args))
            end
        end

        if Config.AutoBuyRebirthUpgrades then
            for _, key in ipairs(PreseededRebirthStats) do
                SafeCall("UpgradeRebirthStat", false, key)
                task.wait(0.02)
            end
        end

        if Config.AutoBuyCandyShop then
            for _, itemKey in ipairs(PreseededCandyShopItems) do
                SafeCall("BuyCandyShop", false, itemKey)
                task.wait(0.02)
            end
        end

        if Config.AutoBuyQuestShop then
            for _, itemKey in ipairs(PreseededQuestShopItems) do
                SafeCall("BuyQuestShop", false, itemKey)
                task.wait(0.02)
            end
        end

        task.wait(1.0)
    end
end)

-- Loop 6: Auto Menara Pertarungan (Stage Enter & 20 CPS Combat Tap)
task.spawn(function()
    while true do
        if Config.AutoTower then
            local targetStage = GetTargetTowerStage()

            if Config.AutoRetryTower then
                SafeCall("SetTowerAutoRetry", true, true)
            end
            if Config.AutoDeclineRevive then
                SafeCall("DeclineRevive", false)
            end

            AutoClickTowerGUI(targetStage)

            if not State.InTower then
                StartTowerStage(targetStage)
                task.wait(0.8)
            else
                task.wait(0.2)
            end
        else
            task.wait(1.5)
        end
    end
end)

-- Loop 6B: Fast Combat Tap di Menara (20 Clicks Per Second)
task.spawn(function()
    while true do
        if Config.AutoTower and Config.AutoTapTowerCombat then
            local cam = Workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
            local center = Vector2.new(vp.X / 2, vp.Y / 2)

            -- 1. VirtualInputManager Click
            if VIM then
                pcall(function()
                    VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
                    VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
                end)
            end

            -- 2. VirtualUser Click
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(center)
                VirtualUser:Button1Up(center)
            end)

            -- 3. Klik tombol tap overlay di GUI jika ada
            pcall(function()
                local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if pGui then
                    for _, desc in ipairs(pGui:GetDescendants()) do
                        if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                            local txt = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                            local n = desc.Name:lower()
                            if n:find("tap") or n:find("attack") or n:find("hit") or txt:find("tap") or txt:find("serang") then
                                pcall(function()
                                    for _, conn in ipairs(getconnections(desc.MouseButton1Click)) do conn:Fire() end
                                    for _, conn in ipairs(getconnections(desc.Activated)) do conn:Fire() end
                                end)
                            end
                        end
                    end
                end
            end)

            SafeCall("TowerAttack", false)
            SafeCall("TowerTap", false)
            task.wait(0.05)
        else
            task.wait(0.5)
        end
    end
end)

-- Loop 7: Event, Hadiah, CandyRain & Utilitas
task.spawn(function()
    while true do
        if Config.AutoClaimCandy then
            local candyRain = Workspace:FindFirstChild("CandyRain")
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if candyRain and hrp then
                for _, item in ipairs(candyRain:GetChildren()) do
                    if item:IsA("BasePart") and item.Name == "Candy" then
                        if Config.AutoTeleportCandy and (hrp.Position - item.Position).Magnitude > 10 then
                            hrp.CFrame = item.CFrame + Vector3.new(0, 2.5, 0)
                            task.wait(0.06)
                        end
                        if typeof(firetouchinterest) == "function" then
                            pcall(function()
                                firetouchinterest(hrp, item, 0)
                                firetouchinterest(hrp, item, 1)
                            end)
                        end
                    end
                end
            end
        end

        if Config.AutoSpinWheel then
            SafeCall("SpinWheel", false)
        end
        if Config.AutoWatchSkipAd then
            SafeCall("WatchSkipAd", false)
        end
        if Config.AutoRebirth then
            SafeCall("Rebirth", false)
        end

        if Config.AutoClaimRewards then
            SafeCall("ClaimDaily", false)
            SafeCall("ClaimStarterQuest", false)
            SafeCall("ClaimAllAchievements", false)
            SafeCall("ClaimGroupChest", false)
            SafeCall("ClaimFriendChest", false)
            SafeCall("ClaimFreePet", false)
            for i = 1, 12 do SafeCall("ClaimPlaytime", false, i) end
            for i = 1, 15 do SafeCall("ClaimQuest", false, i) end
        end

        task.wait(3.0)
    end
end)

-- Anti AFK
if Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- ============================================================================
-- 9. USER INTERFACE (CYBER-BLUE EDITION)
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(11, 16, 26),
    Header = Color3.fromRGB(16, 24, 40),
    Sidebar = Color3.fromRGB(14, 20, 32),
    Card = Color3.fromRGB(19, 29, 48),
    Border = Color3.fromRGB(30, 58, 95),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentHover = Color3.fromRGB(50, 205, 255),
    ActiveGreen = Color3.fromRGB(0, 230, 130),
    InactiveRed = Color3.fromRGB(235, 65, 85),
    TextMain = Color3.fromRGB(235, 245, 255),
    TextSub = Color3.fromRGB(130, 155, 185),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarHub_PutarHewan_v7_8"
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

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Floating Toggle Button (R★)
local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "FloatingToggle"
FloatingToggle.Size = UDim2.new(0, 46, 0, 46)
FloatingToggle.Position = UDim2.new(0, 16, 0.5, -23)
FloatingToggle.BackgroundColor3 = Theme.Header
FloatingToggle.Text = "R★"
FloatingToggle.TextColor3 = Theme.Accent
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.TextSize = 16
FloatingToggle.BorderSizePixel = 0
FloatingToggle.Parent = ScreenGui

local FT_Corner = Instance.new("UICorner")
FT_Corner.CornerRadius = UDim.new(1, 0)
FT_Corner.Parent = FloatingToggle

local FT_Stroke = Instance.new("UIStroke")
FT_Stroke.Color = Theme.Accent
FT_Stroke.Thickness = 1.8
FT_Stroke.Parent = FloatingToggle

local draggingFT, dragStartFT, startPosFT
FloatingToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFT = true
        dragStartFT = input.Position
        startPosFT = FloatingToggle.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingFT = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFT and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartFT
        FloatingToggle.Position = UDim2.new(startPosFT.X.Scale, startPosFT.X.Offset + delta.X, startPosFT.Y.Scale, startPosFT.Y.Offset + delta.Y)
    end
end)

-- Main Hub Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 680, 0, 430)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -215)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MFCorner = Instance.new("UICorner")
MFCorner.CornerRadius = UDim.new(0, 10)
MFCorner.Parent = MainFrame

local MFStroke = Instance.new("UIStroke")
MFStroke.Color = Theme.Border
MFStroke.Thickness = 1.2
MFStroke.Parent = MainFrame

local draggingMF, dragStartMF, startPosMF
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - MainFrame.AbsolutePosition.Y <= 42 then
        draggingMF = true
        dragStartMF = input.Position
        startPosMF = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMF = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMF and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMF
        MainFrame.Position = UDim2.new(startPosMF.X.Scale, startPosMF.X.Offset + delta.X, startPosMF.Y.Scale, startPosMF.Y.Offset + delta.Y)
    end
end)

FloatingToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Top Header Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Theme.Header
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderBottomBorder = Instance.new("Frame")
HeaderBottomBorder.Size = UDim2.new(1, 0, 0, 1)
HeaderBottomBorder.Position = UDim2.new(0, 0, 0, 42)
HeaderBottomBorder.BackgroundColor3 = Theme.Border
HeaderBottomBorder.BorderSizePixel = 0
HeaderBottomBorder.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 320, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "★ ROCKSTAR HUB  —  PUTAR HEWAN PELIHARAAN"
Title.TextColor3 = Theme.TextMain
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local VersionBadge = Instance.new("TextLabel")
VersionBadge.Size = UDim2.new(0, 80, 0, 20)
VersionBadge.Position = UDim2.new(0, 340, 0.5, -10)
VersionBadge.BackgroundColor3 = Theme.Card
VersionBadge.Text = "v7.8 CYBER"
VersionBadge.TextColor3 = Theme.Accent
VersionBadge.Font = Enum.Font.GothamBold
VersionBadge.TextSize = 10
VersionBadge.Parent = Header

local VBCorner = Instance.new("UICorner")
VBCorner.CornerRadius = UDim.new(0, 4)
VBCorner.Parent = VersionBadge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextSub
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 6)
CBCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Sidebar Container
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -43)
Sidebar.Position = UDim2.new(0, 0, 0, 43)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, -43)
SidebarDivider.Position = UDim2.new(0, 155, 0, 43)
SidebarDivider.BackgroundColor3 = Theme.Border
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 6)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -156, 1, -43)
ContentContainer.Position = UDim2.new(0, 156, 0, 43)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local TabFrames = {}
local TabButtons = {}

local TabDefs = {
    { Id = "Roll", Name = "🎲 Putar & Pet" },
    { Id = "Dice", Name = "🎲 Toko Dadu" },
    { Id = "Upgrade", Name = "⚡ Peningkatan" },
    { Id = "Tower", Name = "🏰 Menara" },
    { Id = "Event", Name = "🎃 Halloween" },
    { Id = "Log", Name = "📋 Konsol Log" },
}

local function SwitchTab(tabId)
    for id, frame in pairs(TabFrames) do
        frame.Visible = (id == tabId)
    end
    for id, btn in pairs(TabButtons) do
        if id == tabId then
            btn.BackgroundColor3 = Theme.Card
            btn.TextColor3 = Theme.Accent
            btn.Font = Enum.Font.GothamBold
        else
            btn.BackgroundColor3 = Color3.fromRGB(16, 22, 34)
            btn.TextColor3 = Theme.TextSub
            btn.Font = Enum.Font.GothamMedium
        end
    end
end

for idx, tab in ipairs(TabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = (idx == 1) and Theme.Card or Color3.fromRGB(16, 22, 34)
    btn.Text = "  " .. tab.Name
    btn.TextColor3 = (idx == 1) and Theme.Accent or Theme.TextSub
    btn.Font = (idx == 1) and Enum.Font.GothamBold or Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.LayoutOrder = idx
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Theme.Border
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        SwitchTab(tab.Id)
    end)
    TabButtons[tab.Id] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (idx == 1)
    page.Parent = ContentContainer

    local pageList = Instance.new("UIListLayout")
    pageList.Padding = UDim.new(0, 8)
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Parent = page

    TabFrames[tab.Id] = page
end

-- Helper Komponen UI: Card Container
local function CreateCard(parent, titleText, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, height or 100)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.AutomaticSize = height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
    card.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Theme.Border
    cStroke.Thickness = 1
    cStroke.Parent = card

    local cPadding = Instance.new("UIPadding")
    cPadding.PaddingTop = UDim.new(0, 10)
    cPadding.PaddingBottom = UDim.new(0, 10)
    cPadding.PaddingLeft = UDim.new(0, 12)
    cPadding.PaddingRight = UDim.new(0, 12)
    cPadding.Parent = card

    local cList = Instance.new("UIListLayout")
    cList.Padding = UDim.new(0, 8)
    cList.SortOrder = Enum.SortOrder.LayoutOrder
    cList.Parent = card

    if titleText then
        local cTitle = Instance.new("TextLabel")
        cTitle.Size = UDim2.new(1, 0, 0, 18)
        cTitle.BackgroundTransparency = 1
        cTitle.Text = string.upper(titleText)
        cTitle.TextColor3 = Theme.Accent
        cTitle.Font = Enum.Font.GothamBold
        cTitle.TextSize = 10
        cTitle.TextXAlignment = Enum.TextXAlignment.Left
        cTitle.Parent = card
    end

    return card
end

-- Helper Komponen UI: Toggle Switch
local function CreateToggle(parent, labelText, descText, configKey, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local textCol = Instance.new("Frame")
    textCol.Size = UDim2.new(1, -60, 1, 0)
    textCol.BackgroundTransparency = 1
    textCol.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Theme.TextMain
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = textCol

    if descText then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 14)
        desc.Position = UDim2.new(0, 0, 0, 18)
        desc.BackgroundTransparency = 1
        desc.Text = descText
        desc.TextColor3 = Theme.TextSub
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 10
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = textCol
    end

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 48, 0, 24)
    switch.Position = UDim2.new(1, -48, 0.5, -12)
    switch.BackgroundColor3 = Config[configKey] and Theme.ActiveGreen or Theme.InactiveRed
    switch.Text = Config[configKey] and "ON" or "OFF"
    switch.TextColor3 = Color3.fromRGB(255, 255, 255)
    switch.Font = Enum.Font.GothamBold
    switch.TextSize = 10
    switch.BorderSizePixel = 0
    switch.Parent = row

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(1, 0)
    sCorner.Parent = switch

    switch.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        switch.BackgroundColor3 = Config[configKey] and Theme.ActiveGreen or Theme.InactiveRed
        switch.Text = Config[configKey] and "ON" or "OFF"
        Log(labelText .. ": " .. (Config[configKey] and "AKTIF [ON]" or "NONAKTIF [OFF]"))
        if callback then callback(Config[configKey]) end
    end)

    return row
end

-- ============================================================================
-- 10. ISI TAB UI LENGKAP
-- ============================================================================

-- TAB 1: PUTAR & PET
local p1Card = CreateCard(TabFrames["Roll"], "Otomatisasi Putar Hewan")
CreateToggle(p1Card, "Auto Putar (Auto Roll)", "Putar gacha hewan peliharaan otomatis", "AutoRoll")
CreateToggle(p1Card, "Auto Pasang Hewan Terbaik", "Pasang otomatis pet dengan bonus tertinggi", "AutoEquipBest")
CreateToggle(p1Card, "Auto Gabung Hewan (Fuse)", "Gabungkan pet duplikat untuk menaikkan tier", "AutoFuse")
CreateToggle(p1Card, "Auto Jual Hewan Terlemah", "Jual otomatis hewan dengan stat terlemah di tas", "AutoSellWeakest")
CreateToggle(p1Card, "Auto Jual Semua Pet Cadangan", "Jual semua pet yang tidak sedang terpasang", "AutoSellAll")

local p1PlotCard = CreateCard(TabFrames["Roll"], "Otomatisasi Plot & Pendapatan")
CreateToggle(p1PlotCard, "Auto Ambil Uang Plot", "Ambil kas plot via CollectPad tanpa jalan kaki", "AutoCollectCash")
CreateToggle(p1PlotCard, "Auto Treadmill (Berlari di Treadmill)", "Berdiri dan berlari otomatis di treadmill plot", "AutoTreadmill")

-- TAB 2: TOKO DADU
local p2Card = CreateCard(TabFrames["Dice"], "Mode Pemasangan Dadu (Anti Bentrok)")
local DiceStatusLabel = Instance.new("TextLabel")
DiceStatusLabel.Size = UDim2.new(1, 0, 0, 20)
DiceStatusLabel.BackgroundTransparency = 1
DiceStatusLabel.Text = "Dadu Terdeteksi: Membaca toko..."
DiceStatusLabel.TextColor3 = Theme.AccentHover
DiceStatusLabel.Font = Enum.Font.GothamMedium
DiceStatusLabel.TextSize = 11
DiceStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
DiceStatusLabel.Parent = p2Card

local function UpdateDiceDisplay()
    local cards = GetDiceCardsFromGui()
    for _, c in ipairs(cards) do
        if c.Status == "equipped" then
            DiceStatusLabel.Text = string.format("Dadu Aktif: %s (Tier: %s | 🍀 %sx)", c.Name, c.Tier, tostring(c.Luck))
            return
        end
    end
    if State.CurrentDiceName and State.CurrentDiceName ~= "Mendeteksi..." then
        DiceStatusLabel.Text = "Dadu Aktif (Server): " .. State.CurrentDiceName
    else
        DiceStatusLabel.Text = "Dadu Aktif: Tidak ada info di GUI"
    end
end

local ModeSwitchBtn = Instance.new("TextButton")
ModeSwitchBtn.Size = UDim2.new(1, 0, 0, 32)
ModeSwitchBtn.BackgroundColor3 = Color3.fromRGB(24, 38, 62)
ModeSwitchBtn.Text = "Mode Dadu: " .. (Config.DiceMode == "AutoBest" and "🌟 Auto-Best Luck (Tertinggi)" or "🔒 Kunci Manual")
ModeSwitchBtn.TextColor3 = Theme.Accent
ModeSwitchBtn.Font = Enum.Font.GothamBold
ModeSwitchBtn.TextSize = 11
ModeSwitchBtn.BorderSizePixel = 0
ModeSwitchBtn.Parent = p2Card

local msbCorner = Instance.new("UICorner")
msbCorner.CornerRadius = UDim.new(0, 6)
msbCorner.Parent = ModeSwitchBtn

ModeSwitchBtn.MouseButton1Click:Connect(function()
    if Config.DiceMode == "AutoBest" then
        Config.DiceMode = "Manual"
        ModeSwitchBtn.Text = "Mode Dadu: 🔒 Kunci Manual (Dadu Terpilih)"
    else
        Config.DiceMode = "AutoBest"
        ModeSwitchBtn.Text = "Mode Dadu: 🌟 Auto-Best Luck (Tertinggi)"
    end
end)

CreateToggle(p2Card, "Auto Pasang Dadu (Auto-Equip)", "Pasang dadu terbaik secara tenang (Anti gonta-ganti)", "AutoEquipDice")
CreateToggle(p2Card, "Auto Beli Stok Dadu Toko", "Beli stok dadu baru dari toko tanpa mengganggu dadu aktif", "AutoBuyDiceOnly")
CreateToggle(p2Card, "Teleport ke Toko Dadu saat Beli", "Mendekat otomatis ke pad toko dadu saat membeli", "AutoTeleportDiceShop")

local ForceEquipBtn = Instance.new("TextButton")
ForceEquipBtn.Size = UDim2.new(1, 0, 0, 30)
ForceEquipBtn.BackgroundColor3 = Color3.fromRGB(30, 65, 110)
ForceEquipBtn.Text = "⚡ Paksa Pasang Dadu Terbaik Sekarang"
ForceEquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ForceEquipBtn.Font = Enum.Font.GothamBold
ForceEquipBtn.TextSize = 11
ForceEquipBtn.BorderSizePixel = 0
ForceEquipBtn.Parent = p2Card

local febCorner = Instance.new("UICorner")
febCorner.CornerRadius = UDim.new(0, 6)
febCorner.Parent = ForceEquipBtn

ForceEquipBtn.MouseButton1Click:Connect(function()
    State.ManualOverrideUntil = 0
    EquipTargetDiceNow(true)
    UpdateDiceDisplay()
end)

-- TAB 3: PENINGKATAN, PODIUM & REBIRTH (JARAK JAUH)
local p3Card = CreateCard(TabFrames["Upgrade"], "Peningkatan Level Pet & Podium (Jarak Jauh)")
CreateToggle(p3Card, "Auto Tingkatkan 16 Podium", "Tingkatkan 16 podium & level pet 100% jarak jauh", "AutoUpgradePodium")

local RemoteUpgradeNowBtn = Instance.new("TextButton")
RemoteUpgradeNowBtn.Size = UDim2.new(1, 0, 0, 30)
RemoteUpgradeNowBtn.BackgroundColor3 = Color3.fromRGB(24, 48, 80)
RemoteUpgradeNowBtn.Text = "⚡ Tingkatkan Semua Podium Sekarang (Jarak Jauh)"
RemoteUpgradeNowBtn.TextColor3 = Theme.Accent
RemoteUpgradeNowBtn.Font = Enum.Font.GothamBold
RemoteUpgradeNowBtn.TextSize = 11
RemoteUpgradeNowBtn.BorderSizePixel = 0
RemoteUpgradeNowBtn.Parent = p3Card

local rubCorner = Instance.new("UICorner")
rubCorner.CornerRadius = UDim.new(0, 6)
rubCorner.Parent = RemoteUpgradeNowBtn

RemoteUpgradeNowBtn.MouseButton1Click:Connect(function()
    UpgradeAllPodiumsRemote()
    Log("Berhasil menaikkan level semua podium dari jarak jauh!")
end)

CreateToggle(p3Card, "Auto Beli Semua Peningkatan", "Beli upgrade general yang telah dipelajari", "AutoBuyAllUpgrades")
CreateToggle(p3Card, "Auto Beli Peningkatan Rebirth", "Beli peningkatan toko rebirth otomatis", "AutoBuyRebirthUpgrades")
CreateToggle(p3Card, "Auto Rebirth", "Lakukan Rebirth otomatis saat persyaratan terpenuhi", "AutoRebirth")

-- TAB 4: MENARA PERTARUNGAN (FULL AUTOMATIC)
local p4Card = CreateCard(TabFrames["Tower"], "Pengaturan Menara Pertarungan (Otomatis)")
local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1, 0, 0, 18)
StageLabel.BackgroundTransparency = 1
StageLabel.Text = "Stage Terpilih: " .. Config.SelectedStage .. " (Mode: " .. Config.TowerStageMode .. ")"
StageLabel.TextColor3 = Theme.TextMain
StageLabel.Font = Enum.Font.GothamMedium
StageLabel.TextSize = 12
StageLabel.TextXAlignment = Enum.TextXAlignment.Left
StageLabel.Parent = p4Card

local function UpdateStageLabel()
    StageLabel.Text = "Stage Terpilih: " .. Config.SelectedStage .. " (Mode: " .. Config.TowerStageMode .. ")"
end

local TowerModeBtn = Instance.new("TextButton")
TowerModeBtn.Size = UDim2.new(1, 0, 0, 30)
TowerModeBtn.BackgroundColor3 = Color3.fromRGB(24, 38, 62)
TowerModeBtn.Text = "Mode Stage: " .. (Config.TowerStageMode == "Selected" and "🎯 Stage Manual Pilihan" or "🌟 Auto Stage Tertinggi")
TowerModeBtn.TextColor3 = Theme.Accent
TowerModeBtn.Font = Enum.Font.GothamBold
TowerModeBtn.TextSize = 11
TowerModeBtn.BorderSizePixel = 0
TowerModeBtn.Parent = p4Card

local tmbCorner = Instance.new("UICorner")
tmbCorner.CornerRadius = UDim.new(0, 6)
tmbCorner.Parent = TowerModeBtn

TowerModeBtn.MouseButton1Click:Connect(function()
    if Config.TowerStageMode == "Selected" then
        Config.TowerStageMode = "Highest"
        TowerModeBtn.Text = "Mode Stage: 🌟 Auto Stage Tertinggi"
    else
        Config.TowerStageMode = "Selected"
        TowerModeBtn.Text = "Mode Stage: 🎯 Stage Manual Pilihan"
    end
    UpdateStageLabel()
end)

local StageControlRow = Instance.new("Frame")
StageControlRow.Size = UDim2.new(1, 0, 0, 32)
StageControlRow.BackgroundTransparency = 1
StageControlRow.Parent = p4Card

local PrevStageBtn = Instance.new("TextButton")
PrevStageBtn.Size = UDim2.new(0, 80, 1, 0)
PrevStageBtn.BackgroundColor3 = Color3.fromRGB(24, 38, 62)
PrevStageBtn.Text = "◀ Kurang"
PrevStageBtn.TextColor3 = Theme.Accent
PrevStageBtn.Font = Enum.Font.GothamBold
PrevStageBtn.TextSize = 11
PrevStageBtn.BorderSizePixel = 0
PrevStageBtn.Parent = StageControlRow

local psCorner = Instance.new("UICorner")
psCorner.CornerRadius = UDim.new(0, 6)
psCorner.Parent = PrevStageBtn

local NextStageBtn = Instance.new("TextButton")
NextStageBtn.Size = UDim2.new(0, 80, 1, 0)
NextStageBtn.Position = UDim2.new(0, 90, 0, 0)
NextStageBtn.BackgroundColor3 = Color3.fromRGB(24, 38, 62)
NextStageBtn.Text = "Tambah ▶"
NextStageBtn.TextColor3 = Theme.Accent
NextStageBtn.Font = Enum.Font.GothamBold
NextStageBtn.TextSize = 11
NextStageBtn.BorderSizePixel = 0
NextStageBtn.Parent = StageControlRow

local nsCorner = Instance.new("UICorner")
nsCorner.CornerRadius = UDim.new(0, 6)
nsCorner.Parent = NextStageBtn

PrevStageBtn.MouseButton1Click:Connect(function()
    if Config.SelectedStage > 1 then
        Config.SelectedStage = Config.SelectedStage - 1
        UpdateStageLabel()
    end
end)

NextStageBtn.MouseButton1Click:Connect(function()
    Config.SelectedStage = Config.SelectedStage + 1
    UpdateStageLabel()
end)

CreateToggle(p4Card, "Auto Masuk & Selesaikan Menara", "Masuk otomatis ke menara dan auto selesaikan", "AutoTower")
CreateToggle(p4Card, "Auto Ketuk Serang Cepat (20 CPS Combat)", "Serangan otomatis cepat tanpa perlu klik manual", "AutoTapTowerCombat")
CreateToggle(p4Card, "Auto Pasang Tim Menara Terbaik", "Pasang otomatis pet combat terbaik untuk menara", "AutoEquipTowerTeam")
CreateToggle(p4Card, "Auto Ulangi Saat Menang (Auto Retry)", "Ulangi otomatis menara untuk farming instan", "AutoRetryTower")
CreateToggle(p4Card, "Teleport ke Pad Pintu Menara", "Pindah otomatis ke TowersPad saat mulai", "AutoTeleportToTowerPad")
CreateToggle(p4Card, "Tolak Tawaran Revive Robux", "Tolak popup revive otomatis agar tidak macet", "AutoDeclineRevive")

-- TAB 5: HALLOWEEN EVENT & HADIAH
local p5Card = CreateCard(TabFrames["Event"], "Event Halloween 2026")
CreateToggle(p5Card, "Auto Ambil Permen Halloween", "Kumpulkan permen labu (CandyRain) di map", "AutoClaimCandy")
CreateToggle(p5Card, "Teleport ke Titik Permen", "Pindah langsung ke lokasi permen terdekat", "AutoTeleportCandy")
CreateToggle(p5Card, "Auto Beli Toko Permen", "Tukarkan permen di Toko Candy Shop otomatis", "AutoBuyCandyShop")
CreateToggle(p5Card, "Auto Beli Toko Quest", "Beli item di Toko Quest Shop otomatis", "AutoBuyQuestShop")

local p5RewardCard = CreateCard(TabFrames["Event"], "Hadiah Gratis & Putar Roda")
CreateToggle(p5RewardCard, "Auto Putar Roda Keberuntungan", "Putar Wheel of Fortune setiap putaran gratis siap", "AutoSpinWheel")
CreateToggle(p5RewardCard, "Auto Klaim Semua Hadiah", "Klaim Daily, Peti Teman, Grup, Quest & Waktu Bermain", "AutoClaimRewards")
CreateToggle(p5RewardCard, "Auto Tonton Skip Iklan", "Klaim hadiah skip iklan gratis secara berkala", "AutoWatchSkipAd")

-- TAB 6: KONSOL LOG REALTIME
local p6Card = CreateCard(TabFrames["Log"], "Status Sistem & Aktivitas")
local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, 0, 0, 160)
LogText.BackgroundTransparency = 1
LogText.Text = "Menunggu aktivitas..."
LogText.TextColor3 = Theme.TextSub
LogText.Font = Enum.Font.Code
LogText.TextSize = 10
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Parent = p6Card

local function RefreshLogDisplay()
    LogText.Text = table.concat(State.LogBuffer, "\n")
end

task.spawn(function()
    while true do
        pcall(RefreshLogDisplay)
        pcall(UpdateDiceDisplay)
        task.wait(2.0)
    end
end)

Log("★ ROCKSTAR HUB v7.8 DIMUAT LENGKAP ★")
print("★ ROCKSTAR HUB v7.8 - [🎃] PUTAR HEWAN PELIHARAAN BERHASIL DIMUAT LENGKAP! ★")
