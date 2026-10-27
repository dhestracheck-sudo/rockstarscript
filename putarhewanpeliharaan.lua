-- ============================================================================
-- ★ ROCKSTAR HUB v7.4 - [🎃] PUTAR HEWAN PELIHARAAN (CYBER-BLUE EDITION) ★
-- Game: [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299 | PlaceVersion: 1264)
-- Update v7.4 (INDONESIAN DICE & LUCK PARSER VERIFIED EDITION):
--   [✓] Integrasi Dadu Asli Indonesia: Badai | Epik (7kx), Bayangan | Epik (40kx), Magma, Lava, dll.
--   [✓] Parser Otomatis Multiplier Keberuntungan (7kx -> 7,000, 40kx -> 40,000, 1.5Mx -> 1,500,000)
--   [✓] Sistem Bobot Tier Asli: Biasa, Langka, Epik, Legendaris, Mitos, Ilahi, Rahasia
--   [✓] UI Native Auto-Equip: Otomatis deteksi & klik tombol [Lengkapi] di Toko Dadu PlayerGui
--   [✓] Anti Dadu Ganti-Ganti Sendiri: Caching Dadu Terpasang + Cooldown Anti-Spam Remote
--   [✓] Deteksi Dadu Pilihan Manual saat pemain klik manual (Mode [Kunci Manual] otomatis aktif)
--   [✓] Tetap Mempertahankan Seluruh Fitur Map Scan: 16 Podium Plot, Menara, 3 Dadu Emas Rahasia, Halloween
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

    -- Sistem Dadu v7.4 (Indonesian & True Luck Edition)
    AutoBuyDiceOnly = false,
    AutoEquipDice = false,
    DiceMode = "AutoBest",          -- "AutoBest" atau "Manual"
    SelectedDiceIndex = 1,
    LockedDiceId = nil,
    SkipVoidDice = true,
    AutoTeleportDiceShop = false,

    -- Auto Collect & Plot
    AutoCollectCash = false,
    AutoBuyAutoCollect = false,
    AutoTreadmill = false,
    AutoWatchSkipAd = false,

    -- Auto Peningkatan, Trait & Grade
    AutoUpgradePodium = false,
    AutoTeleportUpgrade = true,
    AutoBuyAllUpgrades = false,
    AutoBuyRebirthUpgrades = false,
    AutoRerollTrait = false,
    TraitTargetMode = "BestOnly",   -- "BestOnly", "FillEmpty", "Always"
    AutoRollGrade = false,
    GradeTargetMode = "BestOnly",   -- "BestOnly" (S, S+, SS, SSS, X, Z)
    AutoTeleportTraitShop = false,
    AutoBuyCandyShop = false,
    AutoBuyQuestShop = false,
    AutoRebirth = false,

    -- Auto Menara & Stage
    AutoTower = false,
    TowerStageMode = "Selected",    -- "Selected" atau "Highest"
    SelectedStage = 1,
    HighestUnlockedStage = 1,
    AutoTeleportToTowerPad = true,
    AutoTapTowerCombat = true,
    AutoRetryTower = true,
    AutoDeclineRevive = true,
    AutoEquipTowerTeam = true,

    -- Event, Rahasia & Utility
    AutoClaimSecrets = false,
    AutoSpinWheel = false,
    AutoClaimRewards = false,
    AutoClaimCandy = false,
    AutoTeleportCandy = false,
    AntiAFK = true,
}

local TowerRuntime = {
    InTower = false,
    CurrentFloor = 0,
    CurrentStage = 1,
    AutoRetryCountdown = 0,
}

-- ============================================================================
-- 2. KONEKSI REMOTES RESMI (REPLICATEDSTORAGE.SHARED.REMOTES)
-- ============================================================================
local SharedFolder = ReplicatedStorage:WaitForChild("Shared", 15)
local RemotesFolder = SharedFolder and SharedFolder:WaitForChild("Remotes", 15)

local function GetRemote(name)
    if RemotesFolder then
        local r = RemotesFolder:FindFirstChild(name)
        if r then return r end
    end
    return ReplicatedStorage:FindFirstChild(name, true)
end

local Remotes = {
    RequestRoll = GetRemote("RequestRoll"),
    EquipBestPets = GetRemote("EquipBestPets"),
    EquipBestTeam = GetRemote("EquipBestTeam"),
    SetTeam = GetRemote("SetTeam"),
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
    BlimpShop = GetRemote("BlimpShop"),
    RerollTrait = GetRemote("RerollTrait"),
    RollGrade = GetRemote("RollGrade"),

    StartTower = GetRemote("StartTower"),
    LeaveTower = GetRemote("LeaveTower"),
    DeclineRevive = GetRemote("DeclineRevive"),
    ResumeTower = GetRemote("ResumeTower"),
    SetTowerAutoRetry = GetRemote("SetTowerAutoRetry"),
    TowerEvent = GetRemote("TowerEvent"),

    GetData = GetRemote("GetData"),
    DataChanged = GetRemote("DataChanged"),
    DataBatch = GetRemote("DataBatch"),
    ClaimDaily = GetRemote("ClaimDaily"),
    ClaimPlaytime = GetRemote("ClaimPlaytime"),
    ClaimQuest = GetRemote("ClaimQuest"),
    ClaimStarterQuest = GetRemote("ClaimStarterQuest"),
    ClaimAchievement = GetRemote("ClaimAchievement"),
    ClaimAllAchievements = GetRemote("ClaimAllAchievements"),
    ClaimGroupChest = GetRemote("ClaimGroupChest"),
    ClaimFriendChest = GetRemote("ClaimFriendChest"),
    ClaimFreePet = GetRemote("ClaimFreePet"),
    SpinWheel = GetRemote("SpinWheel"),
    WheelSpun = GetRemote("WheelSpun"),
    CandyDrops = GetRemote("CandyDrops"),
    CandyClaim = GetRemote("CandyClaim"),
    WatchSkipAd = GetRemote("WatchSkipAd"),
}

local BlacklistedNames = {
    IsAutoClimbing = true, ShowUnit = true, ScaleTween = true, OnRevive = true,
    RenderRetry = true, SetHidden = true, GetProfile = true, DeclineRevive = true,
    SetOpen = true, DodgeStrip = true, ShakeArena = true, SyncRetry = true,
    PopText = true, Burst = true, Knockback = true, SetFloorAnchor = true,
    SetBar = true, Init = true, Start = true, Update = true, Destroy = true,
    Open = true, Close = true, Toggle = true, Bind = true, Render = true,
    Format = true, OnClick = true, Setup = true, Cleanup = true, New = true,
    UIListLayout = true, UIGridLayout = true, UIPadding = true, UICorner = true,
    UIStroke = true, UIAspectRatioConstraint = true, UISizeConstraint = true,
    Template = true, ItemTemplate = true, RowTemplate = true, Header = true,
    Title = true, Background = true, CloseButton = true, Main = true, Container = true,
    ScrollingFrame = true, Frame = true, TextLabel = true, ImageLabel = true,
}

local BestTraitKeywords = {
    "transcendent", "monarch", "emperor", "overlord", "glitched", "divine",
    "celestial", "mythic", "mythical", "godly", "secret", "rainbow", "void",
    "immortal", "cosmic", "supreme", "omni", "ancient", "corrupted", "demonic",
    "angelic", "halloween", "spooky", "reaper", "titanic", "hyper", "ultra", "max"
}

local BestGradeList = {
    ["S"] = true, ["S+"] = true, ["SPLUS"] = true, ["SS"] = true, ["SSS"] = true,
    ["Z"] = true, ["X"] = true, ["XX"] = true, ["XXX"] = true, ["GODLY"] = true,
    ["DIVINE"] = true, ["GLITCHED"] = true, ["MYTHIC"] = true, ["MAX"] = true, ["10"] = true,
}

local DiscoveredData = {
    Upgrades = {
        "Luck1", "Luck2", "Luck3", "Luck4", "Luck5",
        "RollSpeed1", "RollSpeed2", "RollSpeed3", "RollSpeed4", "RollSpeed5",
        "MutationLuck1", "MutationLuck2", "MutationLuck3", "MutationLuck4", "MutationLuck5",
        "TreadmillLuck1", "TreadmillLuck2", "TreadmillLuck3", "TreadmillLuck4", "TreadmillLuck5",
        "GoldenDice1", "GoldenDice2", "GoldenDice3", "GoldenDice4", "GoldenDice5",
        "Cash1", "Cash2", "Cash3", "Cash4", "Cash5",
        "Inventory1", "Inventory2", "Inventory3",
    },
    RebirthStats = {
        "Luck1", "Luck2", "Luck3", "Cash1", "Cash2", "Cash3",
        "RollSpeed1", "RollSpeed2", "MutationLuck1", "MutationLuck2",
        "Luck", "Cash", "RollSpeed", "Inventory", "Damage", "Candy",
    },
    VerifiedDice = {},
    DiceLuckMap = {},
    DiceDisplayNameMap = {},
    DiceTierMap = {},
    OwnedDiceCount = {},
    CurrentEquippedDice = nil,
    LearnedDiceArgs = {},

    DiscoveredTraits = {},
    TopTraitsMap = {
        ["transcendent"] = true,
        ["monarch"] = true,
        ["divine"] = true,
        ["celestial"] = true,
        ["glitched"] = true,
        ["godly"] = true,
        ["mythic"] = true,
    },
    InventoryPetUuids = {},

    CandyShopItems = {
        "HauntedCrate", "PumpkinDice", "HalloweenDice", "CandyLuck1", "CandyLuck2",
        "CandyMultiplier1", "CandyRollSpeed1", "CandyPack1", "CandyPack2", "CandyPack3",
    },
    QuestShopItems = {
        "Luck1", "RollSpeed1", "MutationLuck1", "GoldenDice1",
    },
    ValidCandyTokens = {},
}

local LearningLogs = {}
local function AddLearningLog(remoteName, arg1, arg2, arg3)
    local timeStr = os.date("%H:%M:%S")
    local line = string.format("%s | %s: (%s, %s, %s)", timeStr, tostring(remoteName), tostring(arg1), tostring(arg2), tostring(arg3))
    for _, existing in ipairs(LearningLogs) do
        if existing:sub(12) == line:sub(12) then return end
    end
    table.insert(LearningLogs, 1, line)
    if #LearningLogs > 50 then table.remove(LearningLogs) end
end

local function IsValidKey(key)
    if key == nil then return false end
    if type(key) == "function" or type(key) == "userdata" or type(key) == "table" then return false end
    local str = tostring(key)
    if #str == 0 or #str > 45 or BlacklistedNames[str] then return false end
    if str == "__index" or str == "RBX_ReimportId" or str == "OwnerUserId" then return false end
    return true
end

local function AddUniqueKey(list, key)
    if not IsValidKey(key) then return end
    for _, existing in ipairs(list) do
        if existing == key then return end
    end
    table.insert(list, key)
end

local function IsVoidDice(diceId)
    local low = tostring(diceId or ""):lower()
    return low:find("void") ~= nil or low:find("kekosongan") ~= nil
end

local TierMultipliers = {
    ["biasa"] = 1,
    ["common"] = 1,
    ["dasar"] = 1,
    ["basic"] = 1,
    ["tidak biasa"] = 5,
    ["uncommon"] = 5,
    ["langka"] = 25,
    ["rare"] = 25,
    ["epik"] = 5000,
    ["epic"] = 5000,
    ["legendaris"] = 100000,
    ["legendary"] = 100000,
    ["mitos"] = 1000000,
    ["mythic"] = 1000000,
    ["ilahi"] = 10000000,
    ["dewa"] = 10000000,
    ["divine"] = 10000000,
    ["godly"] = 10000000,
    ["rahasia"] = 100000000,
    ["secret"] = 100000000,
    ["glitched"] = 100000000,
    ["event"] = 75000,
}

local function ParseLuckMultiplier(text)
    if not text or type(text) ~= "string" then return 1 end
    local clean = text:gsub(",", ""):gsub("%%", ""):lower()

    local nStr, unit = clean:match("([%d%.]+)%s*([kmbtq]?)%s*x")
    if not nStr then
        nStr, unit = clean:match("x%s*([%d%.]+)%s*([kmbtq]?)")
    end
    if not nStr then
        nStr, unit = clean:match("([%d%.]+)%s*([kmbtq]?)%s*k")
    end
    if not nStr then
        nStr = clean:match("([%d%.]+)")
        unit = ""
    end

    local num = tonumber(nStr)
    if not num then return 1 end

    unit = tostring(unit or ""):lower()
    if unit == "k" then
        num = num * 1000
    elseif unit == "m" then
        num = num * 1000000
    elseif unit == "b" then
        num = num * 1000000000
    elseif unit == "t" then
        num = num * 1000000000000
    elseif unit == "q" then
        num = num * 1000000000000000
    end
    return num
end

local function ParseTierMultiplier(text)
    if not text or type(text) ~= "string" then return 1 end
    local low = text:lower()
    for tierName, mult in pairs(TierMultipliers) do
        if low:find(tierName) then
            return mult
        end
    end
    return 1
end

local function CalculateDiceScore(diceNameOrText, luckStr)
    local luckVal = ParseLuckMultiplier(luckStr or diceNameOrText)
    local tierVal = ParseTierMultiplier(diceNameOrText)
    if luckVal and luckVal > 1 then
        return luckVal
    end
    return tierVal
end

local function RegisterVerifiedDice(diceId, luckVal, orderVal, displayName)
    if not IsValidKey(diceId) then return end
    local strId = tostring(diceId)
    if strId:match("^GoldenDice%d+$") then return end
    if strId:match("^Luck%d+$") or strId:match("^RollSpeed%d+$") or strId:match("^MutationLuck%d+$") or strId:match("^TreadmillLuck%d+$") then return end
    if strId:match("^Cash%d+$") or strId:match("^Inventory%d+$") then return end

    local finalScore = 1
    if type(luckVal) == "string" then
        finalScore = ParseLuckMultiplier(luckVal)
    elseif type(luckVal) == "number" and luckVal > 0 then
        finalScore = luckVal
    else
        finalScore = CalculateDiceScore(displayName or strId, nil)
    end

    local oNum = tonumber(orderVal)
    if (not finalScore or finalScore <= 1) and oNum and oNum > 0 then
        finalScore = oNum * 50
    end

    local oldScore = DiscoveredData.DiceLuckMap[strId]
    if not oldScore or finalScore > oldScore then
        DiscoveredData.DiceLuckMap[strId] = finalScore
    end

    if displayName and type(displayName) == "string" and #displayName > 0 then
        DiscoveredData.DiceDisplayNameMap[strId] = displayName
    elseif not DiscoveredData.DiceDisplayNameMap[strId] then
        DiscoveredData.DiceDisplayNameMap[strId] = strId
    end

    local exists = false
    for _, d in ipairs(DiscoveredData.VerifiedDice) do
        if d == strId then exists = true break end
    end
    if not exists then
        table.insert(DiscoveredData.VerifiedDice, strId)
    end

    table.sort(DiscoveredData.VerifiedDice, function(a, b)
        local lA = DiscoveredData.DiceLuckMap[a] or 1
        local lB = DiscoveredData.DiceLuckMap[b] or 1
        if lA == lB then
            return tostring(a) < tostring(b)
        end
        return lA < lB
    end)
end

-- Pre-Seeded Real Game Dice (Indonesian & Internal Names)
local PreSeededDice = {
    {"Dasar",                     1,               "Biasa",       "Dasar | Biasa"},
    {"Basic",                     1,               "Biasa",       "Dasar | Biasa"},
    {"Kayu",                      1,               "Biasa",       "Kayu | Biasa"},
    {"Wood",                      1,               "Biasa",       "Kayu | Biasa"},
    {"Batu",                      5,               "Biasa",       "Batu | Biasa"},
    {"Stone",                     5,               "Biasa",       "Batu | Biasa"},
    {"Besi",                      20,              "Biasa",       "Besi | Biasa"},
    {"Iron",                      20,              "Biasa",       "Besi | Biasa"},
    {"Perak",                     40,              "Biasa",       "Perak | Biasa"},
    {"Silver",                    40,              "Biasa",       "Perak | Biasa"},
    {"Kekosongan",                50,              "Langka",      "Kekosongan (Void)"},
    {"Void",                      50,              "Langka",      "Kekosongan (Void)"},
    {"Emas",                      100,             "Langka",      "Emas | Langka"},
    {"Gold",                      100,             "Langka",      "Emas | Langka"},
    {"Zamrud",                    250,             "Langka",      "Zamrud | Langka"},
    {"Emerald",                   250,             "Langka",      "Zamrud | Langka"},
    {"Berlian",                   500,             "Langka",      "Berlian | Langka"},
    {"Diamond",                   500,             "Langka",      "Berlian | Langka"},
    {"Petir",                     1000,            "Langka",      "Petir | Langka"},
    {"Lightning",                 1000,            "Langka",      "Petir | Langka"},
    {"Api",                       2500,            "Langka",      "Api | Langka"},
    {"Fire",                      2500,            "Langka",      "Api | Langka"},
    {"Badai",                     7000,            "Epik",        "Badai | Epik"},
    {"Storm",                     7000,            "Epik",        "Badai | Epik"},
    {"Lava",                      15000,           "Epik",        "Lava | Epik"},
    {"Magma",                     25000,           "Epik",        "Magma | Epik"},
    {"Bayangan",                  40000,           "Epik",        "Bayangan | Epik"},
    {"Shadow",                    40000,           "Epik",        "Bayangan | Epik"},
    {"PumpkinDice",               80000,           "Event",       "Dadu Labu (Pumpkin)"},
    {"HauntedDice",               120000,          "Event",       "Dadu Berhantu"},
    {"HalloweenDice",             180000,          "Event",       "Dadu Halloween"},
    {"Bintang",                   150000,          "Legendaris",  "Bintang | Legendaris"},
    {"Star",                      150000,          "Legendaris",  "Bintang | Legendaris"},
    {"Galaksi",                   250000,          "Legendaris",  "Galaksi | Legendaris"},
    {"Galaxy",                    250000,          "Legendaris",  "Galaksi | Legendaris"},
    {"Kosmik",                    1000000,         "Mitos",       "Kosmik | Mitos"},
    {"Cosmic",                    1000000,         "Mitos",       "Kosmik | Mitos"},
    {"Nebula",                    1500000,         "Mitos",       "Nebula | Mitos"},
    {"Ilahi",                     5000000,         "Ilahi",       "Ilahi | Dewa"},
    {"Divine",                    5000000,         "Divine",      "Ilahi | Dewa"},
    {"Godly",                     8000000,         "Godly",       "Dewa Tertinggi"},
    {"Glitched",                  15000000,        "Rahasia",     "Glitched | Rahasia"},
    {"Chaos",                     25000000,        "Rahasia",     "Chaos | Rahasia"},
    {"Infinity",                  50000000,        "Rahasia",     "Infinity | Rahasia"},
}

for _, item in ipairs(PreSeededDice) do
    RegisterVerifiedDice(item[1], item[2], nil, item[4])
    DiscoveredData.DiceTierMap[item[1]] = item[3]
end

local IsScriptCallingEquip = false
local UpdateDiceDisplayFunc = nil

-- Hook Self-Learning (__namecall)
if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if (method == "InvokeServer" or method == "FireServer") and typeof(self) == "Instance" then
                local rName = self.Name
                local a1, a2, a3 = ...
                if rName == "BuyDice" and a1 ~= nil then
                    RegisterVerifiedDice(a1, nil, nil)
                    if DiscoveredData.LearnedDiceArgs then
                        table.insert(DiscoveredData.LearnedDiceArgs, {a1, a2})
                    end
                    AddLearningLog("BuyDice", a1, a2, a3)
                elseif rName == "EquipDice" and a1 ~= nil then
                    RegisterVerifiedDice(a1, nil, nil)
                    DiscoveredData.CurrentEquippedDice = a1
                    if not IsScriptCallingEquip then
                        Config.LockedDiceId = a1
                        Config.DiceMode = "Manual"
                        if UpdateDiceDisplayFunc then task.spawn(UpdateDiceDisplayFunc) end
                    end
                    AddLearningLog("EquipDice", a1, a2, a3)
                elseif rName == "RerollTrait" then
                    AddLearningLog("RerollTrait", a1, a2, a3)
                elseif rName == "RollGrade" then
                    AddLearningLog("RollGrade", a1, a2, a3)
                elseif rName == "BuyUpgrade" and IsValidKey(a1) then
                    AddUniqueKey(DiscoveredData.Upgrades, a1)
                    AddLearningLog("BuyUpgrade", a1, a2, a3)
                elseif rName == "UpgradeRebirthStat" and IsValidKey(a1) then
                    AddUniqueKey(DiscoveredData.RebirthStats, a1)
                    AddLearningLog("UpgradeRebirthStat", a1, a2, a3)
                elseif rName == "BuyCandyShop" and IsValidKey(a1) then
                    AddUniqueKey(DiscoveredData.CandyShopItems, a1)
                    AddLearningLog("BuyCandyShop", a1, a2, a3)
                elseif rName == "CandyClaim" and a1 ~= nil then
                    AddUniqueKey(DiscoveredData.ValidCandyTokens, a1)
                    AddLearningLog("CandyClaim", a1, a2, a3)
                elseif rName == "StartTower" and not BlacklistedNames[tostring(a1)] then
                    AddLearningLog("StartTower", a1, a2, a3)
                elseif rName == "PodiumAction" then
                    AddLearningLog("PodiumAction", a1, a2, a3)
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

-- ============================================================================
-- 3. PEMINDAI DATA GAME LENGKAP
-- ============================================================================
local function RefreshGameKnowledge()
    if SharedFolder then
        for _, inst in ipairs(SharedFolder:GetDescendants()) do
            if inst:IsA("ModuleScript") then
                local mName = inst.Name:lower()
                if not mName:find("controller") and not mName:find("client") and not mName:find("renderer") and not mName:find("ui") then
                    local ok, mod = pcall(require, inst)
                    if ok and type(mod) == "table" then
                        local function inspectConfigTable(tbl, depth, contextHint)
                            if depth > 3 then return end
                            for k, v in pairs(tbl) do
                                if type(v) == "table" then
                                    local keyStr = tostring(k)
                                    local lowKey = keyStr:lower()
                                    local hint = contextHint or mName

                                    local itemId = v.Id or v.ID or v.Key or v.DiceId or v.TraitId or v.UpgradeId or (type(k) == "string" and k)
                                    local luckVal = v.Luck or v.LuckMultiplier or v.RollLuck or v.BonusLuck or v.Multiplier or v.Boost or v.Power
                                    local orderVal = v.LayoutOrder or v.Order or v.Tier or v.Rank or v.Index or (type(k) == "number" and k)

                                    if hint:find("dice") or lowKey:find("dice") or v.DiceId or (luckVal and (v.Price or v.Cost) and not hint:find("upgrade")) then
                                        if itemId and IsValidKey(itemId) then
                                            RegisterVerifiedDice(itemId, luckVal, orderVal)
                                        end
                                    elseif hint:find("trait") or lowKey:find("trait") or v.TraitId then
                                        if itemId and IsValidKey(itemId) then
                                            AddUniqueKey(DiscoveredData.DiscoveredTraits, itemId)
                                            local chance = tonumber(v.Chance or v.Weight or v.Probability)
                                            local mult = tonumber(v.Multiplier or v.Boost or v.CashMultiplier or v.Power)
                                            if (chance and chance <= 5) or (mult and mult >= 3) then
                                                DiscoveredData.TopTraitsMap[tostring(itemId):lower()] = true
                                            end
                                        end
                                    elseif hint:find("upgrade") and not hint:find("rebirth") then
                                        if itemId and IsValidKey(itemId) then AddUniqueKey(DiscoveredData.Upgrades, itemId) end
                                    elseif hint:find("rebirth") then
                                        if itemId and IsValidKey(itemId) then AddUniqueKey(DiscoveredData.RebirthStats, itemId) end
                                    elseif hint:find("candy") then
                                        if itemId and IsValidKey(itemId) then AddUniqueKey(DiscoveredData.CandyShopItems, itemId) end
                                    end

                                    local nextHint = hint
                                    if lowKey:find("dice") or lowKey:find("trait") or lowKey:find("grade") or lowKey:find("upgrade") or lowKey:find("candy") then
                                        nextHint = lowKey
                                    end
                                    inspectConfigTable(v, depth + 1, nextHint)
                                end
                            end
                        end
                        inspectConfigTable(mod, 1, mName)
                    end
                end
            end
        end
    end

    if Remotes.GetData then
        local ok, pData = pcall(function() return Remotes.GetData:InvokeServer() end)
        if ok and type(pData) == "table" then
            for k, v in pairs(pData) do
                local lowerK = tostring(k):lower()
                if (lowerK:find("equippeddice") or lowerK:find("currentdice") or lowerK:find("selecteddice") or lowerK == "dice") and (type(v) == "string" or type(v) == "number") then
                    DiscoveredData.CurrentEquippedDice = v
                    RegisterVerifiedDice(v, nil, nil)
                end
                if type(v) == "number" and (lowerK:find("tower") or lowerK:find("stage") or lowerK:find("floor")) then
                    if v >= 1 and v <= 1000 and v > Config.HighestUnlockedStage then
                        Config.HighestUnlockedStage = math.floor(v)
                    end
                elseif type(v) == "table" then
                    if lowerK:find("dice") then
                        for dk, dv in pairs(v) do
                            if type(dk) == "string" and IsValidKey(dk) then
                                RegisterVerifiedDice(dk, nil, nil)
                                local qty = (type(dv) == "number" and dv) or (dv == true and 1) or 0
                                DiscoveredData.OwnedDiceCount[dk] = qty
                            elseif type(dv) == "string" and IsValidKey(dv) then
                                RegisterVerifiedDice(dv, nil, nil)
                                DiscoveredData.OwnedDiceCount[dv] = 1
                            elseif type(dv) == "table" then
                                local dId = dv.Id or dv.ID or dv.DiceId or dv.Name or (type(dk) == "string" and dk)
                                if dId and IsValidKey(dId) then
                                    RegisterVerifiedDice(dId, dv.Luck, dv.Order)
                                    DiscoveredData.OwnedDiceCount[dId] = tonumber(dv.Amount or dv.Count or dv.Quantity) or 1
                                end
                            end
                        end
                    elseif lowerK:find("pet") or lowerK:find("inventory") then
                        for pk, pv in pairs(v) do
                            if type(pv) == "table" then
                                local uuid = pv.UUID or pv.Uuid or pv.Id or pv.ID or (type(pk) == "string" and #pk >= 8 and pk)
                                if uuid and IsValidKey(uuid) then AddUniqueKey(DiscoveredData.InventoryPetUuids, uuid) end
                            elseif type(pk) == "string" and #pk >= 12 then
                                AddUniqueKey(DiscoveredData.InventoryPetUuids, pk)
                            end
                        end
                    elseif lowerK:find("upgrade") and not lowerK:find("rebirth") then
                        for uk, uv in pairs(v) do
                            if type(uv) ~= "function" then AddUniqueKey(DiscoveredData.Upgrades, uk) end
                        end
                    elseif lowerK:find("rebirth") then
                        for rk, rv in pairs(v) do
                            if type(rv) ~= "function" then AddUniqueKey(DiscoveredData.RebirthStats, rk) end
                        end
                    elseif lowerK:find("candy") and not lowerK:find("amount") then
                        for ck, cv in pairs(v) do
                            if type(cv) ~= "function" then AddUniqueKey(DiscoveredData.CandyShopItems, ck) end
                        end
                    end
                end
            end
        end
    end
end

task.spawn(RefreshGameKnowledge)

task.spawn(function()
    while true do
        pcall(function()
            if typeof(ScanDiceShopGui) == "function" then
                ScanDiceShopGui()
            end
        end)
        task.wait(2.5)
    end
end)

-- ============================================================================
-- 4. FUNGSI HELPER POSISI, PLOT & INTERAKSI PROXIMITY
-- ============================================================================
local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function SafeTeleport(targetCFrame)
    local hrp = GetHRP()
    if hrp and targetCFrame then
        hrp.CFrame = (typeof(targetCFrame) == "CFrame" and targetCFrame) or CFrame.new(targetCFrame)
    end
end

local CachedMyPlot = nil
local function GetMyPlot()
    if CachedMyPlot and CachedMyPlot.Parent == Workspace and CachedMyPlot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
        return CachedMyPlot
    end
    for i = 1, 8 do
        local plot = Workspace:FindFirstChild("Plot" .. i)
        if plot and plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            CachedMyPlot = plot
            return plot
        end
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name:match("^Plot%d+$") and child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            CachedMyPlot = child
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

local function SafeFirePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    prompt.HoldDuration = 0
    if typeof(fireproximityprompt) == "function" then
        pcall(fireproximityprompt, prompt)
        return true
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait()
            prompt:InputHoldEnd()
        end)
        return true
    end
end

local function SafeFireClick(cd)
    if not cd or not cd:IsA("ClickDetector") then return false end
    if typeof(fireclickdetector) == "function" then
        pcall(fireclickdetector, cd)
        return true
    end
    return false
end

local function FireGuiButton(btn)
    if not btn or not (btn:IsA("TextButton") or btn:IsA("ImageButton")) then return false end
    local fired = false
    if typeof(firesignal) == "function" then
        pcall(function() firesignal(btn.Activated) fired = true end)
        pcall(function() firesignal(btn.MouseButton1Click) fired = true end)
    end
    if typeof(getconnections) == "function" then
        pcall(function()
            for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() fired = true end
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() fired = true end
        end)
    end
    return fired
end

local function ScanDiceShopGui()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return nil end

    local bestOwnedCard = nil
    local bestLuck = -1

    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and g.Name ~= "RockstarHubUI" then
            for _, item in ipairs(g:GetDescendants()) do
                if item:IsA("GuiObject") and (item.Name:find("Dice") or item.Name:find("Item") or item.Name:find("Card") or item.Name:find("Template") or item:FindFirstChildOfClass("UIListLayout") == nil) then
                    local equipBtn = nil
                    local isEquipped = false
                    local isOwned = false
                    local titleText = ""
                    local luckText = ""

                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text and #child.Text > 0 then
                            local t = child.Text
                            if t:find("|") or t:find("Epik") or t:find("Langka") or t:find("Legendaris") or t:find("Mitos") or t:find("Biasa") then
                                titleText = t
                            end
                            if t:find("Keberuntungan") or t:find("Luck") or t:find("🍀") or t:find("x") then
                                luckText = t
                            end
                        elseif (child:IsA("TextButton") or child:IsA("ImageButton")) then
                            local btnTxt = ""
                            if child:IsA("TextButton") then
                                btnTxt = child.Text:lower()
                            else
                                for _, sc in ipairs(child:GetChildren()) do
                                    if sc:IsA("TextLabel") then btnTxt = sc.Text:lower() break end
                                end
                            end
                            if btnTxt:find("dilengkapi") or btnTxt:find("equipped") then
                                isEquipped = true
                                isOwned = true
                            elseif btnTxt:find("lengkapi") or btnTxt:find("equip") then
                                isOwned = true
                                equipBtn = child
                            end
                        end
                    end

                    if isOwned or #titleText > 0 or #luckText > 0 then
                        local cardLuck = CalculateDiceScore(titleText, luckText)
                        local diceName = titleText:match("^([^|]+)") or item:GetAttribute("DiceId") or item:GetAttribute("Id") or item.Name
                        diceName = tostring(diceName):gsub("^%s+", ""):gsub("%s+$", "")

                        if IsValidKey(diceName) then
                            RegisterVerifiedDice(diceName, cardLuck, nil, #titleText > 0 and titleText or diceName)
                            if isOwned then
                                DiscoveredData.OwnedDiceCount[diceName] = 1
                            end
                        end

                        if isEquipped then
                            DiscoveredData.CurrentEquippedDice = diceName
                        end

                        if isOwned and not (Config.SkipVoidDice and IsVoidDice(diceName)) then
                            if cardLuck > bestLuck then
                                bestLuck = cardLuck
                                bestOwnedCard = {
                                    Button = equipBtn,
                                    DiceId = diceName,
                                    Luck = cardLuck,
                                    Title = titleText,
                                    IsEquipped = isEquipped
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    return bestOwnedCard
end

-- ============================================================================
-- 5. SISTEM DADU v7.4 (INDONESIAN & TRUE LUCK VERIFIED EDITION)
-- ============================================================================
local function GetTargetDiceId()
    local list = DiscoveredData.VerifiedDice
    if #list == 0 then return nil end

    if Config.DiceMode == "Manual" and Config.LockedDiceId and IsValidKey(Config.LockedDiceId) then
        return Config.LockedDiceId
    end

    -- Prioritas 1: Dadu milik pemain dari scan UI / data dengan Luck tertinggi (bukan Void)
    local bestId = nil
    local maxLuck = -1
    for _, dId in ipairs(list) do
        local isSkippedVoid = Config.SkipVoidDice and IsVoidDice(dId)
        local ownedQty = DiscoveredData.OwnedDiceCount[dId]
        if not isSkippedVoid and (ownedQty and ownedQty > 0) then
            local lk = DiscoveredData.DiceLuckMap[dId] or 1
            if lk > maxLuck then
                maxLuck = lk
                bestId = dId
            end
        end
    end
    if bestId then return bestId end

    -- Prioritas 2: Cari di VerifiedDice dari tertinggi ke terendah (bukan Void)
    for i = #list, 1, -1 do
        local dId = list[i]
        if not (Config.SkipVoidDice and IsVoidDice(dId)) then
            return dId
        end
    end

    return list[#list]
end

local function RunBuyDiceStockOnly()
    if not Remotes.BuyDice then return end

    if Config.AutoTeleportDiceShop then
        local modelFolder = Workspace:FindFirstChild("Model")
        local dicePad = modelFolder and modelFolder:FindFirstChild("DiceShopPad") or Workspace:FindFirstChild("DiceShopPad", true)
        local zone = dicePad and dicePad:FindFirstChild("Zone")
        local prompt = zone and zone:FindFirstChild("StandDiceShop", true)
        if zone and zone:IsA("BasePart") then
            local hrp = GetHRP()
            if hrp and (hrp.Position - zone.Position).Magnitude > 14 then
                SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0))
                task.wait(0.12)
            end
            if prompt then SafeFirePrompt(prompt) end
        end
    end

    local list = DiscoveredData.VerifiedDice
    for i = #list, 2, -1 do
        local diceId = list[i]
        if IsValidKey(diceId) and not (Config.SkipVoidDice and IsVoidDice(diceId)) then
            pcall(function()
                Remotes.BuyDice:InvokeServer(diceId)
            end)
            task.wait(0.02)
        end
    end
end

local LastEquipTick = 0
local function EquipTargetDiceNow(forceEquip)
    if not forceEquip and (tick() - LastEquipTick < 1.2) then return end

    -- 1. Coba deteksi langsung dari UI Toko Dadu jika sedang terbuka
    if Config.DiceMode == "AutoBest" then
        local bestCard = ScanDiceShopGui()
        if bestCard and not (Config.SkipVoidDice and IsVoidDice(bestCard.DiceId)) then
            if bestCard.IsEquipped then
                DiscoveredData.CurrentEquippedDice = bestCard.DiceId
                return
            end
            if bestCard.Button then
                IsScriptCallingEquip = true
                FireGuiButton(bestCard.Button)
                LastEquipTick = tick()
                DiscoveredData.CurrentEquippedDice = bestCard.DiceId
                IsScriptCallingEquip = false
                if UpdateDiceDisplayFunc then task.spawn(UpdateDiceDisplayFunc) end
                return
            end
        end
    end

    -- 2. Pasang via Remote
    if not Remotes.EquipDice then return end
    local targetDice = GetTargetDiceId()
    if not targetDice or not IsValidKey(targetDice) then return end

    if not forceEquip and DiscoveredData.CurrentEquippedDice == targetDice then
        return
    end

    IsScriptCallingEquip = true
    local ok, res = pcall(function()
        return Remotes.EquipDice:InvokeServer(targetDice)
    end)
    if ok and res ~= false then
        DiscoveredData.CurrentEquippedDice = targetDice
        LastEquipTick = tick()
    end
    IsScriptCallingEquip = false
    if UpdateDiceDisplayFunc then task.spawn(UpdateDiceDisplayFunc) end
end

-- ============================================================================
-- 6. SISTEM AUTO TRAIT, GRADE & PENINGKATAN
-- ============================================================================
local function GetPodiumPetUuid(podium)
    if not podium then return nil end
    local stand = podium:FindFirstChild("Stand")
    local model = stand and (stand:FindFirstChild("Pet") or stand:FindFirstChildOfClass("Model"))
    if model then
        local uuid = model:GetAttribute("PetUuid") or model:GetAttribute("UUID") or model:GetAttribute("Id")
        if uuid and IsValidKey(uuid) and tostring(uuid) ~= "0" and tostring(uuid):lower() ~= "none" then
            return tostring(uuid)
        end
    end
    local pUuid = podium:GetAttribute("EquippedPetUuid") or podium:GetAttribute("PetUuid")
    if pUuid and IsValidKey(pUuid) and tostring(pUuid) ~= "0" and tostring(pUuid):lower() ~= "none" then
        return tostring(pUuid)
    end
    return nil
end

local function GetPodiumPetInfo(podium)
    if not podium then return nil, nil, nil end
    local petUuid = GetPodiumPetUuid(podium)
    local traitVal, gradeVal = nil, nil

    local stand = podium:FindFirstChild("Stand")
    local model = stand and (stand:FindFirstChild("Pet") or stand:FindFirstChildOfClass("Model"))
    if model then
        traitVal = model:GetAttribute("Trait") or model:GetAttribute("TraitName")
        gradeVal = model:GetAttribute("Grade") or model:GetAttribute("PetGrade")
    end

    if not traitVal then traitVal = podium:GetAttribute("PetTrait") end
    if not gradeVal then gradeVal = podium:GetAttribute("PetGrade") end

    return petUuid, traitVal, gradeVal
end

local function IsTopTierTrait(traitName)
    if not traitName or type(traitName) ~= "string" or #traitName == 0 then return false end
    local low = traitName:lower()
    if DiscoveredData.TopTraitsMap[low] then return true end
    for _, kw in ipairs(BestTraitKeywords) do
        if low:find(kw) then return true end
    end
    return false
end

local function IsTopTierGrade(gradeName)
    if not gradeName or type(gradeName) ~= "string" or #gradeName == 0 then return false end
    local up = gradeName:upper():gsub("%s+", "")
    return BestGradeList[up] == true
end

local function RunAutoBestTrait()
    if not Remotes.RerollTrait then return end

    if Config.AutoTeleportTraitShop then
        local tPad = Workspace:FindFirstChild("TraitShopPad", true) or Workspace:FindFirstChild("TraitPad", true)
        local zone = tPad and (tPad:FindFirstChild("Zone") or tPad:FindFirstChildOfClass("BasePart"))
        if zone then
            local hrp = GetHRP()
            if hrp and (hrp.Position - zone.Position).Magnitude > 14 then
                SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0))
                task.wait(0.12)
            end
        end
    end

    for _, podium in ipairs(GetMyPodiums()) do
        if not Config.AutoRerollTrait then break end
        local slot = tonumber(podium:GetAttribute("Slot")) or 1
        local petUuid, currentTrait, _ = GetPodiumPetInfo(podium)

        if petUuid and #petUuid >= 8 then
            local hasTopTrait = IsTopTierTrait(currentTrait)
            local shouldReroll = false

            if Config.TraitTargetMode == "BestOnly" then
                shouldReroll = not hasTopTrait
            elseif Config.TraitTargetMode == "FillEmpty" then
                shouldReroll = (currentTrait == nil or tostring(currentTrait):lower() == "none" or #tostring(currentTrait) == 0)
            else
                shouldReroll = true
            end

            if shouldReroll then
                pcall(function()
                    Remotes.RerollTrait:InvokeServer(petUuid, slot)
                end)
                pcall(function()
                    Remotes.RerollTrait:InvokeServer(petUuid)
                end)
                task.wait(0.08)
            end
        end
    end
end

local function RunAutoBestGrade()
    if not Remotes.RollGrade then return end

    for _, podium in ipairs(GetMyPodiums()) do
        if not Config.AutoRollGrade then break end
        local slot = tonumber(podium:GetAttribute("Slot")) or 1
        local petUuid, _, currentGrade = GetPodiumPetInfo(podium)

        if petUuid and #petUuid >= 8 then
            local hasTopGrade = IsTopTierGrade(currentGrade)
            local shouldRoll = false

            if Config.GradeTargetMode == "BestOnly" then
                shouldRoll = not hasTopGrade
            else
                shouldRoll = true
            end

            if shouldRoll then
                pcall(function()
                    Remotes.RollGrade:InvokeServer(petUuid, slot)
                end)
                pcall(function()
                    Remotes.RollGrade:InvokeServer(petUuid)
                end)
                task.wait(0.08)
            end
        end
    end
end

local function UpgradeSinglePodium(podium, autoTeleport)
    if not podium then return end
    local upPad = podium:FindFirstChild("UpgradePad")
    local zone = upPad and upPad:FindFirstChild("Zone")
    local prompt = zone and zone:FindFirstChild("StandPodiumUpgrade", true)

    if zone and zone:IsA("BasePart") then
        local hrp = GetHRP()
        if autoTeleport and hrp and (hrp.Position - zone.Position).Magnitude > 12 then
            SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0))
            task.wait(0.06)
        end
        if prompt then
            SafeFirePrompt(prompt)
        end
    end

    if Remotes.PodiumAction then
        local slot = tonumber(podium:GetAttribute("Slot")) or 1
        pcall(function()
            Remotes.PodiumAction:FireServer("Upgrade", slot)
        end)
    end
end

local function RunAutoBuyAllUpgrades()
    if not Remotes.BuyUpgrade then return end
    for _, upId in ipairs(DiscoveredData.Upgrades) do
        if IsValidKey(upId) then
            pcall(function()
                Remotes.BuyUpgrade:InvokeServer(upId)
            end)
            task.wait(0.02)
        end
    end

    if Config.AutoBuyAutoCollect then
        local plot = GetMyPlot()
        local autoCollectBtn = plot and plot:FindFirstChild("AutoCollectPad", true)
        local btnPart = autoCollectBtn and (autoCollectBtn:FindFirstChild("Button") or autoCollectBtn:FindFirstChild("Zone") or autoCollectBtn)
        if btnPart and btnPart:IsA("BasePart") then
            local hrp = GetHRP()
            if hrp and typeof(firetouchinterest) == "function" then
                pcall(function()
                    firetouchinterest(hrp, btnPart, 0)
                    firetouchinterest(hrp, btnPart, 1)
                end)
            end
        end
    end
end

local function RunAutoBuyRebirthUpgrades()
    if not Remotes.UpgradeRebirthStat then return end
    for _, rStat in ipairs(DiscoveredData.RebirthStats) do
        if IsValidKey(rStat) then
            pcall(function()
                Remotes.UpgradeRebirthStat:InvokeServer(rStat)
            end)
            task.wait(0.02)
        end
    end
end

local function RunAutoBuyEventShops()
    if Config.AutoBuyCandyShop and Remotes.BuyCandyShop then
        for _, cItem in ipairs(DiscoveredData.CandyShopItems) do
            if IsValidKey(cItem) then
                pcall(function() Remotes.BuyCandyShop:InvokeServer(cItem) end)
                task.wait(0.02)
            end
        end
    end
    if Config.AutoBuyQuestShop and Remotes.BuyQuestShop then
        for _, qItem in ipairs(DiscoveredData.QuestShopItems) do
            if IsValidKey(qItem) then
                pcall(function() Remotes.BuyQuestShop:InvokeServer(qItem) end)
                task.wait(0.02)
            end
        end
    end
end

-- ============================================================================
-- 7. KLAIM 3 RAHASIA DADU EMAS & HALLOWEEN CANDY
-- ============================================================================
local SecretStashLocations = {
    Alley = Vector3.new(198.8, 328.2, -67.1),
    TowerTop = Vector3.new(158.5, 396.9, 87.7),
    Hidden = Vector3.new(-281.2, 316.3, 212.2),
}

local function ClaimAllSecretStashes()
    local hrp = GetHRP()
    if not hrp then return end
    local originalCFrame = hrp.CFrame

    for name, pos in pairs(SecretStashLocations) do
        local model = Workspace:FindFirstChild(name .. "Secret", true)
        local goldenDice = model and model:FindFirstChild("GoldenDice")
        local prompt = goldenDice and goldenDice:FindFirstChildOfClass("ProximityPrompt")

        if not prompt then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent.Name == "GoldenDice" then
                    local pPos = obj.Parent.Position
                    if (pPos - pos).Magnitude < 10 then
                        prompt = obj
                        break
                    end
                end
            end
        end

        SafeTeleport(pos + Vector3.new(0, 3, 0))
        task.wait(0.2)
        if prompt then
            SafeFirePrompt(prompt)
            task.wait(0.15)
        end
    end

    task.wait(0.2)
    SafeTeleport(originalCFrame)
end

local function CollectHalloweenCandies()
    local hrp = GetHRP()
    if not hrp then return end

    local candyDropsFolder = Workspace:FindFirstChild("CandyDrops") or Workspace:FindFirstChild("CandyRain") or Workspace:FindFirstChild("Halloween")
    if candyDropsFolder then
        for _, candy in ipairs(candyDropsFolder:GetChildren()) do
            if candy:IsA("BasePart") or candy:IsA("MeshPart") then
                if Config.AutoTeleportCandy then
                    SafeTeleport(candy.CFrame)
                    task.wait(0.04)
                end
                if typeof(firetouchinterest) == "function" then
                    pcall(function()
                        firetouchinterest(hrp, candy, 0)
                        firetouchinterest(hrp, candy, 1)
                    end)
                end
                local p = candy:FindFirstChildOfClass("ProximityPrompt")
                if p then SafeFirePrompt(p) end
            end
        end
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj.Name:find("Candy") or obj.Name:find("Permen")) and (obj:IsA("BasePart") or obj:IsA("MeshPart")) then
            if typeof(firetouchinterest) == "function" then
                pcall(function()
                    firetouchinterest(hrp, obj, 0)
                    firetouchinterest(hrp, obj, 1)
                end)
            end
        end
    end

    if Remotes.CandyClaim and Remotes.CandyClaim:IsA("RemoteEvent") then
        for _, token in ipairs(DiscoveredData.ValidCandyTokens) do
            pcall(function() Remotes.CandyClaim:FireServer(token) end)
        end
    end
end

-- ============================================================================
-- 8. SISTEM AUTO MENARA (TOWER COMBAT & STAGE SELECTOR)
-- ============================================================================
local function GetTargetTowerStage()
    if Config.TowerStageMode == "Highest" then
        return math.max(1, Config.HighestUnlockedStage)
    end
    return math.max(1, Config.SelectedStage)
end

local function StartTowerStage(stageNum)
    if not Remotes.StartTower then return false end
    local target = stageNum or GetTargetTowerStage()

    if Config.AutoTeleportToTowerPad then
        local towerModel = Workspace:FindFirstChild("Tower") or Workspace:FindFirstChild("Menara")
        local enterPad = towerModel and (towerModel:FindFirstChild("EnterPad") or towerModel:FindFirstChild("Pad") or towerModel:FindFirstChild("Zone"))
        if enterPad and enterPad:IsA("BasePart") then
            local hrp = GetHRP()
            if hrp and (hrp.Position - enterPad.Position).Magnitude > 16 then
                SafeTeleport(enterPad.CFrame + Vector3.new(0, 3.5, 0))
                task.wait(0.12)
            end
            local prompt = enterPad:FindFirstChildOfClass("ProximityPrompt")
            if prompt then SafeFirePrompt(prompt) end
        end
    end

    local ok1 = pcall(function() Remotes.StartTower:InvokeServer(target) end)
    if not ok1 then
        pcall(function() Remotes.StartTower:FireServer(target) end)
    end
    pcall(function() Remotes.StartTower:InvokeServer(tostring(target)) end)
    pcall(function() Remotes.StartTower:InvokeServer(tonumber(target), "Solo") end)
    return true
end

local function AutoClickTowerGUI(stageNum)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end

    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and (g.Name:find("Tower") or g.Name:find("Menara") or g.Name:find("Dungeon")) then
            for _, desc in ipairs(g:GetDescendants()) do
                if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                    local txt = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                    if txt:find("start") or txt:find("mulai") or txt:find("battle") or txt:find("tarung") or txt:find("fight") or txt:find("masuk") then
                        FireGuiButton(desc)
                    elseif stageNum and (txt == tostring(stageNum) or txt:find("stage " .. tostring(stageNum)) or txt:find("lantai " .. tostring(stageNum))) then
                        FireGuiButton(desc)
                    end
                end
            end
        end
    end
    return true
end

-- Listener Event Menara
if Remotes.TowerEvent and Remotes.TowerEvent:IsA("RemoteEvent") then
    Remotes.TowerEvent.OnClientEvent:Connect(function(eventType, payload)
        if typeof(eventType) == "string" then
            local low = eventType:lower()
            if low:find("start") or low:find("enter") or low:find("floor") then
                TowerRuntime.InTower = true
                if type(payload) == "table" and payload.Floor then
                    TowerRuntime.CurrentFloor = tonumber(payload.Floor) or TowerRuntime.CurrentFloor
                end
            elseif low:find("end") or low:find("finish") or low:find("leave") or low:find("victory") or low:find("defeat") then
                TowerRuntime.InTower = false
            end
        end
    end)
end

-- ============================================================================
-- 9. TAMPILAN UI CYBER-BLUE EDITION
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(11, 16, 26),
    Sidebar    = Color3.fromRGB(15, 23, 42),
    Header     = Color3.fromRGB(13, 20, 36),
    Element    = Color3.fromRGB(19, 31, 56),
    Border     = Color3.fromRGB(24, 43, 77),
    Accent     = Color3.fromRGB(0, 215, 255),
    AccentDim  = Color3.fromRGB(0, 140, 180),
    TextMain   = Color3.fromRGB(240, 246, 252),
    TextDim    = Color3.fromRGB(139, 155, 180),
    Success    = Color3.fromRGB(56, 239, 125),
    Warning    = Color3.fromRGB(255, 170, 0),
    Hover      = Color3.fromRGB(26, 44, 80),
}

local OldGui = CoreGui:FindFirstChild("RockstarHubUI") or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("RockstarHubUI"))
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Circular Floating Toggle Button (R★)
local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "RockstarToggle"
FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
FloatingToggle.Position = UDim2.new(0.02, 0, 0.45, 0)
FloatingToggle.BackgroundColor3 = Theme.Background
FloatingToggle.Text = "R★"
FloatingToggle.TextColor3 = Theme.Accent
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.TextSize = 18
FloatingToggle.AutoButtonColor = false
FloatingToggle.Parent = ScreenGui

local FT_Corner = Instance.new("UICorner")
FT_Corner.CornerRadius = UDim.new(1, 0)
FT_Corner.Parent = FloatingToggle

local FT_Stroke = Instance.new("UIStroke")
FT_Stroke.Color = Theme.Accent
FT_Stroke.Thickness = 1.8
FT_Stroke.Parent = FloatingToggle

-- Draggable Logic untuk Floating Toggle
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

-- Draggable MainFrame
local draggingMF, dragStartMF, startPosMF
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - MainFrame.AbsolutePosition.Y <= 40 then
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
    if draggingMF and input.UserInputType == Enum.UserInputType.MouseMovement then
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

local HeaderStroke = Instance.new("Frame")
HeaderStroke.Size = UDim2.new(1, 0, 0, 1)
HeaderStroke.Position = UDim2.new(0, 0, 1, -1)
HeaderStroke.BackgroundColor3 = Theme.Border
HeaderStroke.BorderSizePixel = 0
HeaderStroke.Parent = Header

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
VersionBadge.Size = UDim2.new(0, 130, 0, 22)
VersionBadge.Position = UDim2.new(0, 340, 0.5, -11)
VersionBadge.BackgroundColor3 = Theme.Element
VersionBadge.Text = "v7.4 • TRUE LUCK"
VersionBadge.TextColor3 = Theme.Accent
VersionBadge.Font = Enum.Font.GothamBold
VersionBadge.TextSize = 11
VersionBadge.Parent = Header
local VBCorner = Instance.new("UICorner")
VBCorner.CornerRadius = UDim.new(0, 5)
VBCorner.Parent = VersionBadge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundColor3 = Theme.Element
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Header
local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 6)
CBCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Left Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideBorder = Instance.new("Frame")
SideBorder.Size = UDim2.new(0, 1, 1, 0)
SideBorder.Position = UDim2.new(1, -1, 0, 0)
SideBorder.BackgroundColor3 = Theme.Border
SideBorder.BorderSizePixel = 0
SideBorder.Parent = Sidebar

local NavList = Instance.new("ScrollingFrame")
NavList.Size = UDim2.new(1, 0, 1, -10)
NavList.Position = UDim2.new(0, 0, 0, 5)
NavList.BackgroundTransparency = 1
NavList.ScrollBarThickness = 2
NavList.ScrollBarImageColor3 = Theme.AccentDim
NavList.CanvasSize = UDim2.new(0, 0, 0, 320)
NavList.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 3)
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLayout.Parent = NavList

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -155, 1, -42)
ContentContainer.Position = UDim2.new(0, 155, 0, 42)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local NavButtons = {}
local CurrentTab = nil

local function CreateTab(name, icon, layoutOrder)
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, -14, 0, 32)
    NavBtn.BackgroundColor3 = Theme.Sidebar
    NavBtn.Text = "   " .. icon .. "  " .. name
    NavBtn.TextColor3 = Theme.TextDim
    NavBtn.Font = Enum.Font.GothamMedium
    NavBtn.TextSize = 12
    NavBtn.TextXAlignment = Enum.TextXAlignment.Left
    NavBtn.LayoutOrder = layoutOrder or 1
    NavBtn.AutoButtonColor = false
    NavBtn.Parent = NavList

    local NBCorner = Instance.new("UICorner")
    NBCorner.CornerRadius = UDim.new(0, 6)
    NBCorner.Parent = NavBtn

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Tab"
    TabPage.Size = UDim2.new(1, -16, 1, -12)
    TabPage.Position = UDim2.new(0, 8, 0, 6)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 3
    TabPage.ScrollBarImageColor3 = Theme.AccentDim
    TabPage.Visible = false
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 480)
    TabPage.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 7)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.Parent = TabPage

    Tabs[name] = TabPage
    NavButtons[name] = NavBtn

    local function Activate()
        for tabName, page in pairs(Tabs) do
            page.Visible = (tabName == name)
            local btn = NavButtons[tabName]
            if tabName == name then
                btn.BackgroundColor3 = Theme.Element
                btn.TextColor3 = Theme.Accent
                btn.Font = Enum.Font.GothamBold
            else
                btn.BackgroundColor3 = Theme.Sidebar
                btn.TextColor3 = Theme.TextDim
                btn.Font = Enum.Font.GothamMedium
            end
        end
        CurrentTab = name
    end

    NavBtn.MouseButton1Click:Connect(Activate)

    -- Builder Tools untuk Konten
    local ComponentFactory = {}

    function ComponentFactory:AddToggle(title, defaultState, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -10, 0, 34)
        Row.BackgroundColor3 = Theme.Element
        Row.Parent = TabPage

        local RCorner = Instance.new("UICorner")
        RCorner.CornerRadius = UDim.new(0, 6)
        RCorner.Parent = Row

        local RStroke = Instance.new("UIStroke")
        RStroke.Color = Theme.Border
        RStroke.Thickness = 1
        RStroke.Parent = Row

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -55, 1, 0)
        Lbl.Position = UDim2.new(0, 10, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = title
        Lbl.TextColor3 = Theme.TextMain
        Lbl.Font = Enum.Font.GothamMedium
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 36, 0, 20)
        Switch.Position = UDim2.new(1, -44, 0.5, -10)
        Switch.BackgroundColor3 = defaultState and Theme.Accent or Theme.Sidebar
        Switch.Text = ""
        Switch.Parent = Row

        local SCorner = Instance.new("UICorner")
        SCorner.CornerRadius = UDim.new(1, 0)
        SCorner.Parent = Switch

        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 14, 0, 14)
        Dot.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dot.Parent = Switch
        local DCorner = Instance.new("UICorner")
        DCorner.CornerRadius = UDim.new(1, 0)
        DCorner.Parent = Dot

        local state = defaultState
        local function SetToggle(val)
            state = val
            Switch.BackgroundColor3 = state and Theme.Accent or Theme.Sidebar
            Dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            if callback then callback(state) end
        end

        Switch.MouseButton1Click:Connect(function()
            SetToggle(not state)
        end)

        return { Set = SetToggle, Get = function() return state end }
    end

    function ComponentFactory:AddButton(title, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 32)
        Btn.BackgroundColor3 = Theme.Element
        Btn.Text = title
        Btn.TextColor3 = Theme.Accent
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12
        Btn.AutoButtonColor = true
        Btn.Parent = TabPage

        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 6)
        BCorner.Parent = Btn

        local BStroke = Instance.new("UIStroke")
        BStroke.Color = Theme.Border
        BStroke.Thickness = 1.2
        BStroke.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        return Btn
    end

    function ComponentFactory:AddSection(title)
        local SecFrame = Instance.new("Frame")
        SecFrame.Size = UDim2.new(1, -10, 0, 26)
        SecFrame.BackgroundTransparency = 1
        SecFrame.Parent = TabPage

        local SecLbl = Instance.new("TextLabel")
        SecLbl.Size = UDim2.new(1, 0, 1, 0)
        SecLbl.BackgroundTransparency = 1
        SecLbl.Text = "——  " .. title .. "  ——"
        SecLbl.TextColor3 = Theme.Accent
        SecLbl.Font = Enum.Font.GothamBold
        SecLbl.TextSize = 11
        SecLbl.TextXAlignment = Enum.TextXAlignment.Center
        SecLbl.Parent = SecFrame
    end

    return ComponentFactory
end

local Tab1 = CreateTab("Roll & Dadu", "🎲", 1)
local Tab2 = CreateTab("Peningkatan", "⬆️", 2)
local Tab3 = CreateTab("Plot & Uang", "💰", 3)
local Tab4 = CreateTab("Auto Menara", "🗼", 4)
local Tab5 = CreateTab("Halloween", "🎃", 5)
local Tab6 = CreateTab("Klaim & TP", "🎁", 6)
local Tab7 = CreateTab("Log Status", "📍", 7)

-- ============================================================================
-- 10. KONTEN TAB 1: ROLL & DADU
-- ============================================================================
Tab1:AddSection("Auto Roll & Pet")
Tab1:AddToggle("⚡ Auto Roll Cepat (Tanpa Delay)", Config.AutoRoll, function(v) Config.AutoRoll = v end)
Tab1:AddToggle("🐾 Auto Equip Pet Terkuat (Best Pets)", Config.AutoEquipBest, function(v) Config.AutoEquipBest = v end)
Tab1:AddToggle("🧬 Auto Gabung Pet (Auto Fuse All)", Config.AutoFuse, function(v) Config.AutoFuse = v end)
Tab1:AddToggle("🗑️ Auto Jual Pet Terlemah (Sell Weakest)", Config.AutoSellWeakest, function(v) Config.AutoSellWeakest = v end)

Tab1:AddSection("Sistem Dadu v7.4 (Indonesian & True Luck)")
Tab1:AddToggle("🛒 Auto Beli Stok Dadu Toko (Tanpa Mengganti Dadu)", Config.AutoBuyDiceOnly, function(v) Config.AutoBuyDiceOnly = v end)
Tab1:AddToggle("🎲 Auto Pasang Dadu (Equip Dice)", Config.AutoEquipDice, function(v) Config.AutoEquipDice = v end)
Tab1:AddToggle("🚫 Jangan Pakai Dadu Kekosongan (Skip Void Dice)", Config.SkipVoidDice, function(v) Config.SkipVoidDice = v end)

local DiceCtrlRow = Instance.new("Frame")
DiceCtrlRow.Size = UDim2.new(1, -10, 0, 72)
DiceCtrlRow.BackgroundColor3 = Theme.Element
DiceCtrlRow.Parent = Tabs["Roll & Dadu"]
local DCRCorner = Instance.new("UICorner")
DCRCorner.CornerRadius = UDim.new(0, 8)
DCRCorner.Parent = DiceCtrlRow

local DiceModeBtn = Instance.new("TextButton")
DiceModeBtn.Size = UDim2.new(1, -20, 0, 24)
DiceModeBtn.Position = UDim2.new(0, 10, 0, 6)
DiceModeBtn.BackgroundColor3 = Theme.Hover
DiceModeBtn.Text = "Mode Dadu: [Auto-Best Luck] (Otomatis Terkuat)"
DiceModeBtn.TextColor3 = Theme.Accent
DiceModeBtn.Font = Enum.Font.GothamBold
DiceModeBtn.TextSize = 11
DiceModeBtn.Parent = DiceCtrlRow
local DMB_Corner = Instance.new("UICorner")
DMB_Corner.CornerRadius = UDim.new(0, 6)
DMB_Corner.Parent = DiceModeBtn

local PrevDiceBtn = Instance.new("TextButton")
PrevDiceBtn.Size = UDim2.new(0, 70, 0, 28)
PrevDiceBtn.Position = UDim2.new(0, 10, 0, 36)
PrevDiceBtn.BackgroundColor3 = Theme.Sidebar
PrevDiceBtn.Text = "◀ Prev"
PrevDiceBtn.TextColor3 = Theme.TextMain
PrevDiceBtn.Font = Enum.Font.GothamBold
PrevDiceBtn.TextSize = 11
PrevDiceBtn.Parent = DiceCtrlRow
local PDB_Corner = Instance.new("UICorner")
PDB_Corner.CornerRadius = UDim.new(0, 6)
PDB_Corner.Parent = PrevDiceBtn

local DiceNameDisplay = Instance.new("TextLabel")
DiceNameDisplay.Size = UDim2.new(1, -165, 0, 28)
DiceNameDisplay.Position = UDim2.new(0, 83, 0, 36)
DiceNameDisplay.BackgroundColor3 = Theme.Sidebar
DiceNameDisplay.Text = "Dadu: Memuat..."
DiceNameDisplay.TextColor3 = Theme.Success
DiceNameDisplay.Font = Enum.Font.GothamBold
DiceNameDisplay.TextSize = 11
DiceNameDisplay.Parent = DiceCtrlRow
local DND_Corner = Instance.new("UICorner")
DND_Corner.CornerRadius = UDim.new(0, 6)
DND_Corner.Parent = DiceNameDisplay

local NextDiceBtn = Instance.new("TextButton")
NextDiceBtn.Size = UDim2.new(0, 70, 0, 28)
NextDiceBtn.Position = UDim2.new(1, -78, 0, 36)
NextDiceBtn.BackgroundColor3 = Theme.Sidebar
NextDiceBtn.Text = "Next ▶"
NextDiceBtn.TextColor3 = Theme.TextMain
NextDiceBtn.Font = Enum.Font.GothamBold
NextDiceBtn.TextSize = 11
NextDiceBtn.Parent = DiceCtrlRow
local NDB_Corner = Instance.new("UICorner")
NDB_Corner.CornerRadius = UDim.new(0, 6)
NDB_Corner.Parent = NextDiceBtn

local function FormatLuckNumber(num)
    if not num or num <= 1 then return "1x" end
    if num >= 1000000000000 then
        return string.format("%.1fTx", num / 1000000000000)
    elseif num >= 1000000000 then
        return string.format("%.1fBx", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.1fMx", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.0fkx", num / 1000)
    else
        return string.format("%dx", math.floor(num))
    end
end

local function UpdateDiceDisplay()
    local list = DiscoveredData.VerifiedDice
    if #list == 0 then
        DiceNameDisplay.Text = "Dadu: (Memindai Toko Dadu...)"
        return
    end

    if Config.DiceMode == "AutoBest" then
        local bestId = GetTargetDiceId()
        local lk = (bestId and DiscoveredData.DiceLuckMap[bestId]) or 1
        local disp = (bestId and DiscoveredData.DiceDisplayNameMap[bestId]) or tostring(bestId or "None")
        DiceModeBtn.Text = "Mode: [Auto-Best Luck] (Otomatis Terkuat)"
        DiceModeBtn.TextColor3 = Theme.Success
        DiceNameDisplay.Text = string.format("Terbaik: %s (%s)", disp, FormatLuckNumber(lk))
    else
        DiceModeBtn.Text = "Mode: [Kunci Manual] (Hanya Dadu Pilihan)"
        DiceModeBtn.TextColor3 = Theme.Warning
        local curId = Config.LockedDiceId or list[Config.SelectedDiceIndex] or list[1]
        local lk = (curId and DiscoveredData.DiceLuckMap[curId]) or 1
        local disp = (curId and DiscoveredData.DiceDisplayNameMap[curId]) or tostring(curId or "None")
        DiceNameDisplay.Text = string.format("Terkunci: %s (%s)", disp, FormatLuckNumber(lk))
    end
end
UpdateDiceDisplayFunc = UpdateDiceDisplay

DiceModeBtn.MouseButton1Click:Connect(function()
    if Config.DiceMode == "AutoBest" then
        Config.DiceMode = "Manual"
        local list = DiscoveredData.VerifiedDice
        if #list > 0 then
            Config.LockedDiceId = list[Config.SelectedDiceIndex] or list[#list]
        end
    else
        Config.DiceMode = "AutoBest"
        Config.LockedDiceId = nil
    end
    UpdateDiceDisplay()
end)

PrevDiceBtn.MouseButton1Click:Connect(function()
    local list = DiscoveredData.VerifiedDice
    if #list == 0 then return end
    Config.DiceMode = "Manual"
    Config.SelectedDiceIndex = Config.SelectedDiceIndex - 1
    if Config.SelectedDiceIndex < 1 then Config.SelectedDiceIndex = #list end
    Config.LockedDiceId = list[Config.SelectedDiceIndex]
    UpdateDiceDisplay()
    EquipTargetDiceNow(true)
end)

NextDiceBtn.MouseButton1Click:Connect(function()
    local list = DiscoveredData.VerifiedDice
    if #list == 0 then return end
    Config.DiceMode = "Manual"
    Config.SelectedDiceIndex = Config.SelectedDiceIndex + 1
    if Config.SelectedDiceIndex > #list then Config.SelectedDiceIndex = 1 end
    Config.LockedDiceId = list[Config.SelectedDiceIndex]
    UpdateDiceDisplay()
    EquipTargetDiceNow(true)
end)

Tab1:AddButton("🎯 Pasang Dadu Pilihan Sekarang", function()
    EquipTargetDiceNow(true)
    UpdateDiceDisplay()
end)

-- ============================================================================
-- 11. KONTEN TAB 2: PENINGKATAN & TRAIT
-- ============================================================================
Tab2:AddSection("Auto Peningkatan Podium (Plot 6 / Milik Anda)")
Tab2:AddToggle("🏗️ Auto Upgrade 16 Podium", Config.AutoUpgradePodium, function(v) Config.AutoUpgradePodium = v end)
Tab2:AddToggle("📍 Auto Teleport ke UpgradePad Podium", Config.AutoTeleportUpgrade, function(v) Config.AutoTeleportUpgrade = v end)

Tab2:AddSection("Auto Peningkatan Statistik Plot & Rebirth")
Tab2:AddToggle("📈 Auto Beli Semua Upgrade Plot (Luck1..5, dll)", Config.AutoBuyAllUpgrades, function(v) Config.AutoBuyAllUpgrades = v end)
Tab2:AddToggle("🔄 Auto Beli Rebirth Upgrade (RebirthStats)", Config.AutoBuyRebirthUpgrades, function(v) Config.AutoBuyRebirthUpgrades = v end)

Tab2:AddSection("Auto Trait & Grade Pet Terbaik (Podium)")
Tab2:AddToggle("✨ Auto Reroll Trait Terbaik (Stop di Transcendent/Monarch)", Config.AutoRerollTrait, function(v) Config.AutoRerollTrait = v end)
Tab2:AddToggle("🎖️ Auto Roll Grade Terbaik (Stop di S/SS/SSS/X)", Config.AutoRollGrade, function(v) Config.AutoRollGrade = v end)
Tab2:AddToggle("🚪 Dekati TraitShopPad Otomatis", Config.AutoTeleportTraitShop, function(v) Config.AutoTeleportTraitShop = v end)

-- ============================================================================
-- 12. KONTEN TAB 3: PLOT & UANG
-- ============================================================================
Tab3:AddSection("Pengumpulan Uang & Hadiah")
Tab3:AddToggle("💵 Auto Kumpulkan Uang Plot (CollectPad)", Config.AutoCollectCash, function(v) Config.AutoCollectCash = v end)
Tab3:AddToggle("🏃 Auto Treadmill (Lari Menambah Luck)", Config.AutoTreadmill, function(v) Config.AutoTreadmill = v end)
Tab3:AddToggle("📺 Auto Lewati Iklan (WatchSkipAd)", Config.AutoWatchSkipAd, function(v) Config.AutoWatchSkipAd = v end)
Tab3:AddToggle("🔄 Auto Rebirth (Kelahiran Kembali)", Config.AutoRebirth, function(v) Config.AutoRebirth = v end)

-- ============================================================================
-- 13. KONTEN TAB 4: AUTO MENARA
-- ============================================================================
Tab4:AddSection("Kontrol Auto Menara / Tower")
Tab4:AddToggle("🗼 Aktifkan Auto Menara", Config.AutoTower, function(v) Config.AutoTower = v end)
Tab4:AddToggle("⚔️ Auto Tap Serangan Pertarungan", Config.AutoTapTowerCombat, function(v) Config.AutoTapTowerCombat = v end)
Tab4:AddToggle("🔁 Auto Coba Lagi Jika Kalah (Retry)", Config.AutoRetryTower, function(v) Config.AutoRetryTower = v end)
Tab4:AddToggle("❌ Tolak Hidupkan Kembali Berbayar", Config.AutoDeclineRevive, function(v) Config.AutoDeclineRevive = v end)

Tab4:AddSection("Pemilihan Stage Menara")
local StageCtrlRow = Instance.new("Frame")
StageCtrlRow.Size = UDim2.new(1, -10, 0, 72)
StageCtrlRow.BackgroundColor3 = Theme.Element
StageCtrlRow.Parent = Tabs["Auto Menara"]
local SCRCorner = Instance.new("UICorner")
SCRCorner.CornerRadius = UDim.new(0, 8)
SCRCorner.Parent = StageCtrlRow

local StageModeBtn = Instance.new("TextButton")
StageModeBtn.Size = UDim2.new(1, -20, 0, 24)
StageModeBtn.Position = UDim2.new(0, 10, 0, 6)
StageModeBtn.BackgroundColor3 = Theme.Hover
StageModeBtn.Text = "Mode: [Pilihan Sendiri (Selected)]"
StageModeBtn.TextColor3 = Theme.Accent
StageModeBtn.Font = Enum.Font.GothamBold
StageModeBtn.TextSize = 11
StageModeBtn.Parent = StageCtrlRow
local SMB_Corner = Instance.new("UICorner")
SMB_Corner.CornerRadius = UDim.new(0, 6)
SMB_Corner.Parent = StageModeBtn

local PrevStageBtn = Instance.new("TextButton")
PrevStageBtn.Size = UDim2.new(0, 65, 0, 28)
PrevStageBtn.Position = UDim2.new(0, 10, 0, 36)
PrevStageBtn.BackgroundColor3 = Theme.Sidebar
PrevStageBtn.Text = "◀ -1"
PrevStageBtn.TextColor3 = Theme.TextMain
PrevStageBtn.Font = Enum.Font.GothamBold
PrevStageBtn.TextSize = 11
PrevStageBtn.Parent = StageCtrlRow
local PSB_Corner = Instance.new("UICorner")
PSB_Corner.CornerRadius = UDim.new(0, 6)
PSB_Corner.Parent = PrevStageBtn

local StageNumDisplay = Instance.new("TextLabel")
StageNumDisplay.Size = UDim2.new(1, -220, 0, 28)
StageNumDisplay.Position = UDim2.new(0, 80, 0, 36)
StageNumDisplay.BackgroundColor3 = Theme.Sidebar
StageNumDisplay.Text = "Target: Stage 1"
StageNumDisplay.TextColor3 = Theme.Success
StageNumDisplay.Font = Enum.Font.GothamBold
StageNumDisplay.TextSize = 12
StageNumDisplay.Parent = StageCtrlRow
local SND_Corner = Instance.new("UICorner")
SND_Corner.CornerRadius = UDim.new(0, 6)
SND_Corner.Parent = StageNumDisplay

local NextStageBtn = Instance.new("TextButton")
NextStageBtn.Size = UDim2.new(0, 65, 0, 28)
NextStageBtn.Position = UDim2.new(1, -135, 0, 36)
NextStageBtn.BackgroundColor3 = Theme.Sidebar
NextStageBtn.Text = "+1 ▶"
NextStageBtn.TextColor3 = Theme.TextMain
NextStageBtn.Font = Enum.Font.GothamBold
NextStageBtn.TextSize = 11
NextStageBtn.Parent = StageCtrlRow
local NSB_Corner = Instance.new("UICorner")
NSB_Corner.CornerRadius = UDim.new(0, 6)
NSB_Corner.Parent = NextStageBtn

local Plus10StageBtn = Instance.new("TextButton")
Plus10StageBtn.Size = UDim2.new(0, 60, 0, 28)
Plus10StageBtn.Position = UDim2.new(1, -68, 0, 36)
Plus10StageBtn.BackgroundColor3 = Theme.Sidebar
Plus10StageBtn.Text = "+10 ⏩"
Plus10StageBtn.TextColor3 = Theme.TextMain
Plus10StageBtn.Font = Enum.Font.GothamBold
Plus10StageBtn.TextSize = 11
Plus10StageBtn.Parent = StageCtrlRow
local P10_Corner = Instance.new("UICorner")
P10_Corner.CornerRadius = UDim.new(0, 6)
P10_Corner.Parent = Plus10StageBtn

local function UpdateStageLabel()
    if Config.TowerStageMode == "Highest" then
        StageModeBtn.Text = "Mode: [Tertinggi Terbuka (Highest)]"
        StageModeBtn.TextColor3 = Theme.Success
        StageNumDisplay.Text = "Target: Stage " .. tostring(Config.HighestUnlockedStage)
    else
        StageModeBtn.Text = "Mode: [Pilihan Sendiri (Selected)]"
        StageModeBtn.TextColor3 = Theme.Accent
        StageNumDisplay.Text = "Target: Stage " .. tostring(Config.SelectedStage)
    end
end

StageModeBtn.MouseButton1Click:Connect(function()
    Config.TowerStageMode = (Config.TowerStageMode == "Selected") and "Highest" or "Selected"
    UpdateStageLabel()
end)

PrevStageBtn.MouseButton1Click:Connect(function()
    Config.TowerStageMode = "Selected"
    Config.SelectedStage = math.max(1, Config.SelectedStage - 1)
    UpdateStageLabel()
end)

NextStageBtn.MouseButton1Click:Connect(function()
    Config.TowerStageMode = "Selected"
    Config.SelectedStage = math.min(100, Config.SelectedStage + 1)
    UpdateStageLabel()
end)

Plus10StageBtn.MouseButton1Click:Connect(function()
    Config.TowerStageMode = "Selected"
    Config.SelectedStage = math.min(100, Config.SelectedStage + 10)
    UpdateStageLabel()
end)

Tab4:AddButton("🚀 Masuk Menara Sekarang", function()
    StartTowerStage(GetTargetTowerStage())
end)

-- ============================================================================
-- 14. KONTEN TAB 5: HALLOWEEN & RAHASIA
-- ============================================================================
Tab5:AddSection("Event Halloween (Spooky)")
Tab5:AddToggle("🍬 Auto Kumpulkan Permen (CandyRain / Drops)", Config.AutoClaimCandy, function(v) Config.AutoClaimCandy = v end)
Tab5:AddToggle("⚡ Auto Teleport ke Jatuhan Permen", Config.AutoTeleportCandy, function(v) Config.AutoTeleportCandy = v end)
Tab5:AddToggle("📦 Auto Beli Toko Permen (CandyShop & Crate)", Config.AutoBuyCandyShop, function(v) Config.AutoBuyCandyShop = v end)
Tab5:AddToggle("📜 Auto Beli Toko Misi (QuestShop)", Config.AutoBuyQuestShop, function(v) Config.AutoBuyQuestShop = v end)

Tab5:AddSection("3 Rahasia Dadu Emas Map")
Tab5:AddButton("🏆 Klaim Semua Dadu Emas (Alley, Tower, Hidden)", function()
    ClaimAllSecretStashes()
end)

-- ============================================================================
-- 15. KONTEN TAB 6: KLAIM HADIAH & TELEPORT
-- ============================================================================
Tab6:AddSection("Klaim Otomatis")
Tab6:AddToggle("🎁 Auto Klaim Semua Hadiah (Daily, Quest, Playtime)", Config.AutoClaimRewards, function(v) Config.AutoClaimRewards = v end)
Tab6:AddToggle("🎡 Auto Putar Roda Keberuntungan (SpinWheel)", Config.AutoSpinWheel, function(v) Config.AutoSpinWheel = v end)

Tab6:AddSection("Teleport Lokasi Kunci Map")
Tab6:AddButton("🏠 Teleport ke Plot Sendiri (Plot 6)", function()
    local plot = GetMyPlot()
    local spawnPad = plot and (plot:FindFirstChild("SpawnPad") or plot:FindFirstChild("Spawn") or plot:FindFirstChild("Floor1"))
    if spawnPad then SafeTeleport(spawnPad.CFrame + Vector3.new(0, 3.5, 0)) end
end)

Tab6:AddButton("🎲 Teleport ke Toko Dadu (DiceShopPad)", function()
    local dicePad = Workspace:FindFirstChild("DiceShopPad", true)
    local zone = dicePad and dicePad:FindFirstChild("Zone")
    if zone then SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0)) end
end)

Tab6:AddButton("🍬 Teleport ke Toko Permen Halloween (CandyShop)", function()
    local candyPad = Workspace:FindFirstChild("CandyShopPad", true)
    local zone = candyPad and candyPad:FindFirstChild("Zone")
    if zone then SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0)) end
end)

Tab6:AddButton("🗼 Teleport ke Menara (TowerPad)", function()
    local tower = Workspace:FindFirstChild("Tower", true) or Workspace:FindFirstChild("Menara", true)
    if tower then SafeTeleport(tower.CFrame + Vector3.new(0, 3.5, 0)) end
end)

-- ============================================================================
-- 16. KONTEN TAB 7: LOG & DIAGNOSTIK
-- ============================================================================
Tab7:AddSection("Log Interaksi Remote & Diagnostik")
local LogBox = Instance.new("TextLabel")
LogBox.Size = UDim2.new(1, -10, 0, 320)
LogBox.BackgroundColor3 = Theme.Sidebar
LogBox.Text = "Memuat log diagnostik..."
LogBox.TextColor3 = Theme.TextDim
LogBox.Font = Enum.Font.Code
LogBox.TextSize = 10
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.Parent = Tabs["Log Status"]
local LBCorner = Instance.new("UICorner")
LBCorner.CornerRadius = UDim.new(0, 6)
LBCorner.Parent = LogBox

local function RefreshLogDisplay()
    local lines = {}
    table.insert(lines, "=== LOG STATUS ROCKSTAR v7.4 (TRUE LUCK) ===")
    table.insert(lines, "Plot Terdeteksi: Plot6 (Owner: 11818951686)")
    table.insert(lines, "Stage Menara Terbuka: " .. tostring(Config.HighestUnlockedStage))
    table.insert(lines, "Dadu Terverifikasi: " .. tostring(#DiscoveredData.VerifiedDice))
    table.insert(lines, "Permen Event Terbaca: " .. tostring(#DiscoveredData.ValidCandyTokens))
    table.insert(lines, "--------------------------------")
    for i = 1, math.min(15, #LearningLogs) do
        table.insert(lines, LearningLogs[i])
    end
    LogBox.Text = table.concat(lines, "\n")
end

-- Buka tab pertama secara default
Tabs["Roll & Dadu"].Visible = true
NavButtons["Roll & Dadu"].BackgroundColor3 = Theme.Element
NavButtons["Roll & Dadu"].TextColor3 = Theme.Accent
NavButtons["Roll & Dadu"].Font = Enum.Font.GothamBold

-- ============================================================================
-- 17. LOOP LATAR BELAKANG INDEPENDEN
-- ============================================================================

-- Loop 1: Auto Roll
task.spawn(function()
    while true do
        if Config.AutoRoll and Remotes.RequestRoll then
            pcall(function() Remotes.RequestRoll:InvokeServer() end)
        end
        task.wait(Config.RollDelay)
    end
end)

-- Loop 2: Auto Collect Cash & Treadmill
task.spawn(function()
    while true do
        if Config.AutoCollectCash then
            local plot = GetMyPlot()
            local hrp = GetHRP()
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
        end

        if Config.AutoTreadmill then
            local plot = GetMyPlot()
            local tm = plot and plot:FindFirstChild("Treadmill")
            local deck = tm and tm:FindFirstChild("Deck")
            local promptAtt = deck and deck:FindFirstChild("PromptAnchor")
            local prompt = promptAtt and promptAtt:FindFirstChildOfClass("ProximityPrompt")
            if prompt then SafeFirePrompt(prompt) end
        end

        if Config.AutoClaimCandy then
            CollectHalloweenCandies()
        end

        task.wait(0.25)
    end
end)

-- Loop 3: Auto Buy Peningkatan Status & Dadu
task.spawn(function()
    while true do
        if Config.AutoBuyAllUpgrades then RunAutoBuyAllUpgrades() end
        if Config.AutoBuyRebirthUpgrades then RunAutoBuyRebirthUpgrades() end
        if Config.AutoBuyCandyShop or Config.AutoBuyQuestShop then RunAutoBuyEventShops() end
        if Config.AutoBuyDiceOnly then RunBuyDiceStockOnly() end
        if Config.AutoEquipDice then EquipTargetDiceNow(false) end
        task.wait(1.0)
    end
end)

-- Loop 4: Auto Upgrade Podium
task.spawn(function()
    while true do
        if Config.AutoUpgradePodium then
            for _, podium in ipairs(GetMyPodiums()) do
                if not Config.AutoUpgradePodium then break end
                UpgradeSinglePodium(podium, Config.AutoTeleportUpgrade)
                task.wait(0.08)
            end
        end
        task.wait(1.5)
    end
end)

-- Loop 5: Auto Trait & Grade
task.spawn(function()
    while true do
        if Config.AutoRerollTrait then RunAutoBestTrait() end
        if Config.AutoRollGrade then RunAutoBestGrade() end
        task.wait(1.2)
    end
end)

-- Loop 6: Auto Menara
task.spawn(function()
    while true do
        if Config.AutoTower then
            local targetStage = GetTargetTowerStage()
            if Config.AutoRetryTower and Remotes.SetTowerAutoRetry then
                pcall(function() Remotes.SetTowerAutoRetry:FireServer(true) end)
            end
            if Config.AutoDeclineRevive and Remotes.DeclineRevive then
                pcall(function() Remotes.DeclineRevive:InvokeServer() end)
            end
            AutoClickTowerGUI(targetStage)

            if not TowerRuntime.InTower then
                StartTowerStage(targetStage)
            else
                if Config.AutoTapTowerCombat and typeof(VirtualUser) == "Instance" then
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(500, 500))
                        task.wait(0.05)
                        VirtualUser:Button1Up(Vector2.new(500, 500))
                    end)
                end
            end
        end
        task.wait(0.8)
    end
end)

-- Loop 7: Klaim Hadiah & Anti AFK
task.spawn(function()
    while true do
        if Config.AutoEquipBest and Remotes.EquipBestPets then
            pcall(function() Remotes.EquipBestPets:InvokeServer() end)
        end
        if Config.AutoFuse and Remotes.FusePets then
            pcall(function() Remotes.FusePets:InvokeServer() end)
            pcall(function() Remotes.FusePets:InvokeServer("All") end)
        end
        if Config.AutoSellWeakest and Remotes.SellWeakest then
            pcall(function() Remotes.SellWeakest:InvokeServer() end)
        end
        if Config.AutoSpinWheel and Remotes.SpinWheel then
            pcall(function() Remotes.SpinWheel:InvokeServer() end)
        end
        if Config.AutoWatchSkipAd and Remotes.WatchSkipAd then
            pcall(function() Remotes.WatchSkipAd:InvokeServer() end)
        end
        if Config.AutoRebirth and Remotes.Rebirth then
            pcall(function() Remotes.Rebirth:InvokeServer() end)
        end

        if Config.AutoClaimRewards then
            if Remotes.ClaimDaily then pcall(function() Remotes.ClaimDaily:InvokeServer() end) end
            if Remotes.ClaimStarterQuest then pcall(function() Remotes.ClaimStarterQuest:InvokeServer() end) end
            if Remotes.ClaimAllAchievements then pcall(function() Remotes.ClaimAllAchievements:InvokeServer() end) end
            if Remotes.ClaimGroupChest then pcall(function() Remotes.ClaimGroupChest:InvokeServer() end) end
            if Remotes.ClaimFriendChest then pcall(function() Remotes.ClaimFriendChest:InvokeServer() end) end
            if Remotes.ClaimFreePet then pcall(function() Remotes.ClaimFreePet:InvokeServer() end) end
            if Remotes.ClaimPlaytime then
                for i = 1, 12 do pcall(function() Remotes.ClaimPlaytime:InvokeServer(i) end) end
            end
            if Remotes.ClaimQuest then
                for i = 1, 15 do pcall(function() Remotes.ClaimQuest:InvokeServer(i) end) end
            end
        end

        task.spawn(RefreshLogDisplay)
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

task.delay(1, function()
    UpdateDiceDisplay()
    UpdateStageLabel()
end)

print("★ Rockstar Hub v7.4 (Indonesian & True Luck Edition) Berhasil Dijalankan! Tema: Cyber-Blue ★")
