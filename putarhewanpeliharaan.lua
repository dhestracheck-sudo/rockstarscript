-- ============================================================================
-- ★ ROCKSTAR HUB v6.9 - [🎃] PUTAR HEWAN PELIHARAAN (CYBER-BLUE EDITION) ★
-- Game: [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299)
-- Update v6.9:
--   [+] FIX DADU GANTI-GANTI SENDIRI (Hapus total loop EquipDice!)
--   [+] Pisahkan "Auto Beli Stok Dadu (Tanpa Ganti Dadu)" & "Kunci 1 Dadu Pilihan"
--   [+] Auto Deteksi Dadu yang Diklik Manual Pemain agar Tidak Pernah Tertimpa
--   [+] Fix Auto Trait Terbaik & Grade Terbaik (PetUuid Podium + Stop Saat Top Trait)
--   [+] Fix Auto Halloween Candy, Exact BuyUpgrade & Menu Pilih Stage Menara
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
    AutoRoll = false,
    RollDelay = 0.15,
    AutoEquipBest = false,
    AutoFuse = false,
    AutoSellWeakest = false,

    -- Pengaturan Dadu (Fix v6.9 Anti Ganti-Ganti Sendiri)
    AutoBuyDiceOnly = false,        -- HANYA membeli stok dadu (TIDAK memanggil EquipDice sama sekali)
    AutoEquipSingleDice = false,    -- HANYA memasang 1 dadu yang dikunci di pemilih
    SelectedDiceIndex = 1,
    LockedDiceId = nil,             -- Nama 1 dadu tunggal yang dikunci pemain
    SkipVoidDice = true,            -- Jangan beli/pakai Dadu Kekosongan (Void)
    AutoTeleportDiceShop = false,

    -- Auto Collect & Plot
    AutoCollectCash = false,
    AutoBuyAutoCollect = false,
    AutoTreadmill = false,
    AutoWatchSkipAd = false,

    -- Auto Peningkatan, Trait & Grade Terbaik
    AutoUpgradePodium = false,
    AutoTeleportUpgrade = true,
    AutoBuyAllUpgrades = false,
    AutoBuyRebirthUpgrades = false,
    AutoRerollTrait = false,
    TraitTargetMode = "BestOnly",   -- "BestOnly", "FillEmpty", "Always"
    AutoRollGrade = false,
    GradeTargetMode = "BestOnly",
    AutoTeleportTraitShop = false,
    AutoBuyCandyShop = false,
    AutoBuyQuestShop = false,
    AutoRebirth = false,

    -- Auto Menara & Pilih Stage
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

-- ============================================================================
-- 2. KONEKSI REMOTES & DATABASE FILTER
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
    "glitched", "divine", "celestial", "mythic", "mythical", "godly", "secret",
    "rainbow", "void", "immortal", "transcendent", "cosmic", "supreme", "omni",
    "ancient", "corrupted", "demonic", "angelic", "halloween", "spooky", "reaper",
    "monarch", "emperor", "overlord", "titanic", "hyper", "ultra", "max"
}

local BestGradeList = {
    ["S"] = true, ["SS"] = true, ["SSS"] = true, ["S+"] = true, ["Z"] = true,
    ["X"] = true, ["XX"] = true, ["XXX"] = true, ["GODLY"] = true, ["DIVINE"] = true,
    ["GLITCHED"] = true, ["MYTHIC"] = true, ["MAX"] = true, ["10"] = true,
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
    VerifiedDice = {},       -- Terurut dari Luck Terendah -> Luck Tertinggi
    DiceLuckMap = {},        -- [diceId] = Skor Luck Asli
    OwnedDiceCount = {},     -- [diceId] = Jumlah stok di tas pemain
    CurrentEquippedDice = nil,

    DiscoveredTraits = {},
    TopTraitsMap = {},
    InventoryPetUuids = {},

    CandyShopItems = {
        "HauntedCrate", "PumpkinDice", "HalloweenDice", "CandyLuck1", "CandyLuck2",
        "CandyMultiplier1", "CandyRollSpeed1",
    },
    QuestShopItems = {
        "Luck1", "RollSpeed1", "MutationLuck1", "GoldenDice1",
    },
    ValidCandyTokens = {},
}

local LearningLogs = {}
local function AddLearningLog(remoteName, arg1, arg2, arg3)
    local timeStr = os.date("%H:%M:%S")
    local line = string.format("%s | Belajar %s: (%s, %s, %s)", timeStr, tostring(remoteName), tostring(arg1), tostring(arg2), tostring(arg3))
    for _, existing in ipairs(LearningLogs) do
        if existing:sub(12) == line:sub(12) then return end
    end
    table.insert(LearningLogs, 1, line)
    if #LearningLogs > 45 then table.remove(LearningLogs) end
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

local function GetKeywordDiceScore(diceId)
    local low = tostring(diceId or ""):lower()
    if low:find("basic") or low:find("starter") or low:find("normal") or low:find("wood") then return 10 end
    if low:find("stone") or low:find("iron") or low:find("bronze") or low:find("silver") then return 25 end
    if low:find("gold") and not low:find("god") then return 45 end
    if low:find("emerald") or low:find("ruby") or low:find("sapphire") or low:find("diamond") then return 70 end
    if low:find("obsidian") or low:find("dark") or low:find("shadow") then return 90 end
    if low:find("void") or low:find("kekosongan") then return 110 end
    if low:find("galaxy") or low:find("plasma") or low:find("star") or low:find("lava") then return 240 end
    if low:find("mythic") or low:find("rainbow") or low:find("prismatic") or low:find("chromatic") then return 350 end
    if low:find("pumpkin") or low:find("candy") or low:find("spooky") or low:find("haunted") or low:find("halloween") or low:find("reaper") then return 480 end
    if low:find("cosmic") or low:find("nebula") or low:find("astral") or low:find("celestial") then return 650 end
    if low:find("divine") or low:find("godly") or low:find("immortal") or low:find("supreme") then return 820 end
    if low:find("glitch") or low:find("chaos") or low:find("infinity") or low:find("omega") or low:find("secret") or low:find("titanic") then return 960 end
    return 160
end

local function RegisterVerifiedDice(diceId, luckVal, orderVal)
    if not IsValidKey(diceId) then return end
    if tostring(diceId):match("^GoldenDice%d+$") then return end

    local kwScore = GetKeywordDiceScore(diceId)
    local lNum = tonumber(luckVal)
    local oNum = tonumber(orderVal)

    local finalScore = kwScore
    if lNum and lNum > 0 then
        finalScore = (lNum * 100000) + kwScore
    elseif oNum and oNum > 0 then
        finalScore = (oNum * 500) + kwScore
    end

    local oldScore = DiscoveredData.DiceLuckMap[diceId]
    if not oldScore or finalScore > oldScore then
        DiscoveredData.DiceLuckMap[diceId] = finalScore
    end

    local exists = false
    for _, d in ipairs(DiscoveredData.VerifiedDice) do
        if d == diceId then exists = true break end
    end
    if not exists then
        table.insert(DiscoveredData.VerifiedDice, diceId)
    end

    table.sort(DiscoveredData.VerifiedDice, function(a, b)
        return (DiscoveredData.DiceLuckMap[a] or 0) < (DiscoveredData.DiceLuckMap[b] or 0)
    end)
end

-- Flag untuk membedakan panggilan EquipDice dari script vs klik manual pemain
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
                    AddLearningLog("BuyDice", a1, a2, a3)
                elseif rName == "EquipDice" and a1 ~= nil then
                    RegisterVerifiedDice(a1, nil, nil)
                    DiscoveredData.CurrentEquippedDice = a1
                    -- Jika pemain yang klik manual di UI game, otomatis kunci dadu pilihan pemain tersebut!
                    if not IsScriptCallingEquip then
                        Config.LockedDiceId = a1
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
-- 3. PEMINDAI CERDAS DADU, TRAIT, GRADE & UPGRADE
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
                    if not Config.LockedDiceId then
                        Config.LockedDiceId = v
                    end
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

-- ============================================================================
-- 4. FUNGSI HELPER PLOT, PODIUM, PROMPT & UI SIGNAL
-- ============================================================================
local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function SafeTeleport(targetCFrame)
    local hrp = GetHRP()
    if hrp and targetCFrame then hrp.CFrame = targetCFrame end
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
        if child:IsA("Model") and child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
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

-- ============================================================================
-- 5. SISTEM DADU v6.9 (ANTI GANTI-GANTI SENDIRI!)
-- ============================================================================

-- Mengambil 1 Dadu Target yang dikunci saat ini
local function GetSingleTargetDice()
    if Config.LockedDiceId and IsValidKey(Config.LockedDiceId) then
        return Config.LockedDiceId
    end
    local list = DiscoveredData.VerifiedDice
    if #list == 0 then return nil end

    -- Cari 1 dadu dengan skor Luck tertinggi yang stoknya > 0 (dan bukan Void jika SkipVoid aktif)
    for i = #list, 1, -1 do
        local dId = list[i]
        local isSkippedVoid = Config.SkipVoidDice and IsVoidDice(dId)
        local ownedQty = DiscoveredData.OwnedDiceCount[dId]
        if not isSkippedVoid and (ownedQty and ownedQty > 0) then
            return dId
        end
    end

    for i = #list, 1, -1 do
        local dId = list[i]
        if not (Config.SkipVoidDice and IsVoidDice(dId)) then
            return dId
        end
    end
    return list[#list]
end

-- Fungsi 1: HANYA Membeli Stok Dadu di Toko (TIDAK memanggil EquipDice sama sekali!)
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

-- Fungsi 2: HANYA Memasang 1 Dadu Target (Tanpa Loop, Hanya jika belum terpasang!)
local function EquipSingleTargetDiceNow(forceEquip)
    if not Remotes.EquipDice then return end
    local targetDice = GetSingleTargetDice()
    if not targetDice or not IsValidKey(targetDice) then return end

    -- Jangan panggil EquipDice berulang-ulang jika dadu yang dipakai sudah sama!
    if not forceEquip and DiscoveredData.CurrentEquippedDice == targetDice then
        return
    end

    IsScriptCallingEquip = true
    pcall(function()
        Remotes.EquipDice:InvokeServer(targetDice)
    end)
    DiscoveredData.CurrentEquippedDice = targetDice
    IsScriptCallingEquip = false
end

-- ============================================================================
-- 6. SISTEM AUTO TRAIT TERBAIK, GRADE & PENINGKATAN
-- ============================================================================
local function IsBestTrait(traitStr)
    if not traitStr or type(traitStr) ~= "string" then return false end
    local clean = traitStr:lower():gsub("%s+", "")
    if clean == "" or clean == "none" or clean == "nil" or clean == "normal" or clean == "basic" or clean == "common" then
        return false
    end
    if DiscoveredData.TopTraitsMap[traitStr:lower()] then return true end
    for _, kw in ipairs(BestTraitKeywords) do
        if clean:find(kw) then return true end
    end
    return false
end

local function IsBestGrade(gradeStr)
    if not gradeStr then return false end
    local clean = tostring(gradeStr):upper():gsub("%s+", "")
    return BestGradeList[clean] == true
end

local function RunAutoBestTrait()
    if not Remotes.RerollTrait then return end

    if Config.AutoTeleportTraitShop then
        local modelFolder = Workspace:FindFirstChild("Model")
        local traitPad = modelFolder and modelFolder:FindFirstChild("TraitShopPad") or Workspace:FindFirstChild("TraitShopPad", true)
        local zone = traitPad and traitPad:FindFirstChild("Zone")
        local prompt = zone and zone:FindFirstChild("StandTraits", true)
        if zone and zone:IsA("BasePart") then
            local hrp = GetHRP()
            if hrp and (hrp.Position - zone.Position).Magnitude > 14 then
                SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0))
                task.wait(0.12)
            end
            if prompt then SafeFirePrompt(prompt) end
        end
    end

    for _, podium in ipairs(GetMyPodiums()) do
        if not Config.AutoRerollTrait then break end
        if podium:GetAttribute("Locked") ~= true then
            local petUuid = podium:GetAttribute("PetUuid")
            local currentTrait = tostring(podium:GetAttribute("PetTrait") or "")
            local slotNum = tonumber(podium:GetAttribute("Slot"))

            if petUuid and #tostring(petUuid) > 0 then
                local shouldReroll = false
                if Config.TraitTargetMode == "BestOnly" then
                    if not IsBestTrait(currentTrait) then shouldReroll = true end
                elseif Config.TraitTargetMode == "FillEmpty" then
                    if currentTrait == "" or currentTrait:lower() == "none" then shouldReroll = true end
                else
                    shouldReroll = true
                end

                if shouldReroll then
                    local ok1, res1 = pcall(function() return Remotes.RerollTrait:InvokeServer(petUuid) end)
                    if (not ok1 or res1 == false) and slotNum then
                        pcall(function() Remotes.RerollTrait:InvokeServer(slotNum) end)
                    end
                    task.wait(0.08)
                end
            end
        end
    end
end

local function RunAutoBestGrade()
    if not Remotes.RollGrade then return end

    if Config.AutoTeleportTraitShop then
        local modelFolder = Workspace:FindFirstChild("Model")
        local gradePad = modelFolder and modelFolder:FindFirstChild("GradeShopPad") or Workspace:FindFirstChild("GradeShopPad", true)
        local zone = gradePad and gradePad:FindFirstChild("Zone")
        local prompt = zone and zone:FindFirstChild("StandGrades", true)
        if zone and zone:IsA("BasePart") then
            local hrp = GetHRP()
            if hrp and (hrp.Position - zone.Position).Magnitude > 14 then
                SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0))
                task.wait(0.12)
            end
            if prompt then SafeFirePrompt(prompt) end
        end
    end

    for _, podium in ipairs(GetMyPodiums()) do
        if not Config.AutoRollGrade then break end
        if podium:GetAttribute("Locked") ~= true then
            local petUuid = podium:GetAttribute("PetUuid")
            local currentGrade = tostring(podium:GetAttribute("PetGrade") or "")
            local slotNum = tonumber(podium:GetAttribute("Slot"))

            if petUuid and #tostring(petUuid) > 0 then
                local shouldRoll = (Config.GradeTargetMode ~= "BestOnly") or (not IsBestGrade(currentGrade))
                if shouldRoll then
                    local ok1, res1 = pcall(function() return Remotes.RollGrade:InvokeServer(petUuid) end)
                    if (not ok1 or res1 == false) and slotNum then
                        pcall(function() Remotes.RollGrade:InvokeServer(slotNum) end)
                    end
                    task.wait(0.08)
                end
            end
        end
    end
end

local function RunAutoBuyAllUpgrades()
    if not Remotes.BuyUpgrade then return end
    for _, key in ipairs(DiscoveredData.Upgrades) do
        if IsValidKey(key) then
            pcall(function() Remotes.BuyUpgrade:InvokeServer(key) end)
            task.wait(0.02)
        end
    end
end

local function RunAutoBuyRebirthUpgrades()
    if not Remotes.UpgradeRebirthStat then return end
    for _, key in ipairs(DiscoveredData.RebirthStats) do
        if IsValidKey(key) then
            pcall(function() Remotes.UpgradeRebirthStat:InvokeServer(key) end)
            task.wait(0.02)
        end
    end
end

local function RunAutoBuyEventShops()
    if Config.AutoBuyCandyShop and Remotes.BuyCandyShop then
        for _, itemKey in ipairs(DiscoveredData.CandyShopItems) do
            if IsValidKey(itemKey) then
                pcall(function() Remotes.BuyCandyShop:InvokeServer(itemKey) end)
                task.wait(0.03)
            end
        end
    end
    if Config.AutoBuyQuestShop and Remotes.BuyQuestShop then
        for _, itemKey in ipairs(DiscoveredData.QuestShopItems) do
            if IsValidKey(itemKey) then
                pcall(function() Remotes.BuyQuestShop:InvokeServer(itemKey) end)
                task.wait(0.03)
            end
        end
    end
end

local function UpgradeSinglePodium(podium, allowTeleport)
    if not podium or podium:GetAttribute("Locked") == true then return false end
    local slotNum = tonumber(podium:GetAttribute("Slot")) or tonumber(podium.Name:match("%d+"))
    local screen = podium:FindFirstChild("Screen")
    local screenFace = podium:FindFirstChild("ScreenFace")
    local targetPart = screen or screenFace or podium:FindFirstChild("CollectPad") or podium.PrimaryPart

    local hrp = GetHRP()
    if allowTeleport and hrp and targetPart and targetPart:IsA("BasePart") then
        if (hrp.Position - targetPart.Position).Magnitude > 11.5 then
            hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3.2, 0))
            task.wait(0.08)
        end
    end

    if Remotes.PodiumAction and slotNum then
        pcall(function() Remotes.PodiumAction:InvokeServer(slotNum, "UpgradeMax") end)
        pcall(function() Remotes.PodiumAction:InvokeServer(slotNum, "Upgrade") end)
    end

    local podiumPromptAtt = screen and screen:FindFirstChild("PodiumPrompt")
    if podiumPromptAtt then
        local upgMax = podiumPromptAtt:FindFirstChild("UpgradeMaxPrompt")
        local upgSingle = podiumPromptAtt:FindFirstChild("ProximityPrompt")
        if upgMax then SafeFirePrompt(upgMax) end
        if upgSingle then SafeFirePrompt(upgSingle) end
    end

    if screenFace then
        local maxFace = screenFace:FindFirstChild("MaxFace")
        if maxFace then
            local maxCd = maxFace:FindFirstChildOfClass("ClickDetector")
            if maxCd then SafeFireClick(maxCd) end
        end
        local singleCd = screenFace:FindFirstChildOfClass("ClickDetector")
        if singleCd then SafeFireClick(singleCd) end
    end
    return true
end

-- ============================================================================
-- 7. SISTEM AUTO HALLOWEEN CANDY & AUTO MENARA
-- ============================================================================
if Remotes.CandyClaim and Remotes.CandyClaim:IsA("RemoteEvent") then
    Remotes.CandyClaim.OnClientEvent:Connect(function(a1)
        if type(a1) == "string" or type(a1) == "number" then
            AddUniqueKey(DiscoveredData.ValidCandyTokens, a1)
            if Config.AutoClaimCandy then
                task.spawn(function() pcall(function() Remotes.CandyClaim:FireServer(a1) end) end)
            end
        elseif type(a1) == "table" then
            for k, v in pairs(a1) do
                local id = (type(v) == "table" and (v.Id or v.ID or v.UUID)) or (type(k) == "string" and k) or v
                if type(id) == "string" or type(id) == "number" then
                    AddUniqueKey(DiscoveredData.ValidCandyTokens, id)
                    if Config.AutoClaimCandy then
                        task.spawn(function() pcall(function() Remotes.CandyClaim:FireServer(id) end) end)
                    end
                end
            end
        end
    end)
end

local StaticHalloweenObjects = {
    CandyShopPad = true, HauntedCrateStand = true, HauntedCratePad = true,
    halloweenshop = true, Pumpkin = true,
}

local function CollectHalloweenCandies()
    local hrp = GetHRP()
    if not hrp then return end

    if Remotes.CandyClaim and #DiscoveredData.ValidCandyTokens > 0 then
        for _, token in ipairs(DiscoveredData.ValidCandyTokens) do
            pcall(function() Remotes.CandyClaim:FireServer(token) end)
        end
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if not StaticHalloweenObjects[obj.Name] and not obj.Name:match("^Plot%d+$") and obj ~= LocalPlayer.Character then
            local oName = obj.Name:lower()
            if oName:find("candy") or oName:find("treat") or oName:find("drop") or oName:find("spooky") then
                local targets = obj:IsA("BasePart") and {obj} or obj:GetDescendants()
                for _, item in ipairs(targets) do
                    if item:IsA("BasePart") and item.Name ~= "Zone" and item.Name ~= "Pozdro" then
                        local hasTouch = item:FindFirstChildOfClass("TouchTransmitter") ~= nil
                        local prompt = item:FindFirstChildOfClass("ProximityPrompt")
                        local candyId = item:GetAttribute("Id") or item:GetAttribute("CandyId") or item:GetAttribute("UUID")
                        if hasTouch or prompt or candyId then
                            if Config.AutoTeleportCandy and (hrp.Position - item.Position).Magnitude > 10 then
                                SafeTeleport(item.CFrame + Vector3.new(0, 2.5, 0))
                                task.wait(0.08)
                            end
                            if hasTouch and typeof(firetouchinterest) == "function" then
                                pcall(function()
                                    firetouchinterest(hrp, item, 0)
                                    firetouchinterest(hrp, item, 1)
                                end)
                            end
                            if prompt then SafeFirePrompt(prompt) end
                            if candyId and Remotes.CandyClaim then
                                pcall(function() Remotes.CandyClaim:FireServer(candyId) end)
                            end
                        end
                    end
                end
            end
        end
    end
end

local TowerRuntime = {
    InTower = false,
    LastStartAttempt = 0,
    LastStatusText = "Standby",
    CurrentStagePlaying = 1,
}

local function GetTargetTowerStage()
    if Config.TowerStageMode == "Highest" then
        return math.max(1, tonumber(Config.HighestUnlockedStage) or 1)
    end
    return math.max(1, tonumber(Config.SelectedStage) or 1)
end

if Remotes.TowerEvent and Remotes.TowerEvent:IsA("RemoteEvent") then
    Remotes.TowerEvent.OnClientEvent:Connect(function(eventType, payload)
        local evStr = tostring(eventType or ""):lower()
        TowerRuntime.LastStatusText = tostring(eventType or "Aktif")

        if type(payload) == "table" then
            local stg = tonumber(payload.Stage or payload.Floor or payload.Wave or payload.NextStage or payload.UnlockedStage)
            if stg and stg > Config.HighestUnlockedStage then Config.HighestUnlockedStage = stg end
        elseif type(payload) == "number" and payload > Config.HighestUnlockedStage and payload <= 1000 then
            Config.HighestUnlockedStage = payload
        end

        if evStr:find("start") or evStr:find("wave") or evStr:find("spawn") or evStr:find("enter") or evStr:find("fight") then
            TowerRuntime.InTower = true
        elseif evStr:find("win") or evStr:find("victory") or evStr:find("clear") or evStr:find("complete") then
            TowerRuntime.InTower = false
            if TowerRuntime.CurrentStagePlaying >= Config.HighestUnlockedStage then
                Config.HighestUnlockedStage = TowerRuntime.CurrentStagePlaying + 1
            end
        elseif evStr:find("end") or evStr:find("leave") or evStr:find("defeat") or evStr:find("lose") or evStr:find("fail") then
            TowerRuntime.InTower = false
            if Config.AutoDeclineRevive and Remotes.DeclineRevive then
                task.spawn(function() pcall(function() Remotes.DeclineRevive:InvokeServer() end) end)
            end
        elseif evStr:find("revive") or evStr:find("prompt") or evStr:find("dead") then
            if Config.AutoDeclineRevive and Remotes.DeclineRevive then
                task.spawn(function() pcall(function() Remotes.DeclineRevive:InvokeServer() end) end)
            end
            TowerRuntime.InTower = false
        end
    end)
end

local function AutoClickTowerGUI(targetStage)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return end
    local stageStr = tostring(targetStage)

    for _, guiObj in ipairs(pGui:GetDescendants()) do
        if (guiObj:IsA("TextButton") or guiObj:IsA("ImageButton")) and guiObj.Visible then
            local fullPath = guiObj:GetFullName():lower()
            if fullPath:find("tower") or fullPath:find("stage") or fullPath:find("wave") or fullPath:find("battle") then
                local bName = guiObj.Name:lower()
                local bText = guiObj:IsA("TextButton") and (guiObj.Text or ""):lower() or ""
                local attrStage = guiObj:GetAttribute("Stage") or guiObj:GetAttribute("Floor") or guiObj:GetAttribute("Level")
                local parentStage = guiObj.Parent and (guiObj.Parent:GetAttribute("Stage") or guiObj.Parent:GetAttribute("Floor") or guiObj.Parent.Name)

                local isForbidden = bName:find("robux") or bText:find("robux") or bName:find("leave")
                    or bText:find("leave") or bName:find("exit") or bName:find("close") or bName:find("cancel")

                if not isForbidden then
                    local isMatchingStageBtn = (tostring(attrStage) == stageStr)
                        or (tostring(parentStage):lower() == "stage" .. stageStr)
                        or (tostring(parentStage) == stageStr)
                        or (bName == stageStr or bName == "stage" .. stageStr or bName == "floor" .. stageStr)
                        or (bText == stageStr or bText == "stage " .. stageStr or bText == "floor " .. stageStr)

                    if isMatchingStageBtn then FireGuiButton(guiObj) end

                    local isActionBtn = bName:find("start") or bName:find("fight") or bName:find("enter")
                        or bName:find("play") or bName:find("battle") or bName:find("retry")
                        or bName:find("next") or bName:find("confirm") or bName:find("decline")
                        or bText:find("start") or bText:find("fight") or bText:find("enter")
                        or bText:find("mulai") or bText:find("masuk") or bText:find("retry")
                        or bText:find("next") or bText:find("no thanks") or bText:find("decline")

                    if isActionBtn then FireGuiButton(guiObj) end
                end
            end
        end
    end
end

local function EnterTowerAtStage(stageNum)
    stageNum = math.max(1, math.floor(tonumber(stageNum) or 1))
    TowerRuntime.CurrentStagePlaying = stageNum
    TowerRuntime.LastStartAttempt = tick()

    if Config.AutoRetryTower and Remotes.SetTowerAutoRetry then
        pcall(function() Remotes.SetTowerAutoRetry:FireServer(true) end)
    end
    if Config.AutoEquipTowerTeam and Remotes.EquipBestTeam then
        pcall(function() Remotes.EquipBestTeam:InvokeServer() end)
        task.wait(0.1)
    end

    local towersPad = Workspace:FindFirstChild("TowersPad")
    local zone = towersPad and towersPad:FindFirstChild("Zone")
    local standAtt = zone and zone:FindFirstChild("StandPromptAttachment")
    local standPrompt = standAtt and standAtt:FindFirstChild("StandTowers")

    if Config.AutoTeleportToTowerPad and zone and zone:IsA("BasePart") then
        local hrp = GetHRP()
        if hrp and (hrp.Position - zone.Position).Magnitude > 14 then
            SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0))
            task.wait(0.12)
        end
    end

    if standPrompt then
        SafeFirePrompt(standPrompt)
        task.wait(0.08)
    end

    AutoClickTowerGUI(stageNum)

    local started = false
    if Remotes.StartTower then
        local ok1, res1 = pcall(function() return Remotes.StartTower:InvokeServer(stageNum) end)
        if ok1 and res1 ~= false then
            started = true
        else
            local ok2, res2 = pcall(function() return Remotes.StartTower:InvokeServer() end)
            if ok2 and res2 ~= false then started = true end
        end
    end

    task.wait(0.08)
    AutoClickTowerGUI(stageNum)

    if started then
        TowerRuntime.InTower = true
        TowerRuntime.LastStatusText = "Aktif di Stage " .. tostring(stageNum)
    else
        TowerRuntime.LastStatusText = "Masuk Stage " .. tostring(stageNum)
    end
end

local function StepAutoTower()
    local targetStage = GetTargetTowerStage()
    if Config.AutoRetryTower and Remotes.SetTowerAutoRetry then
        pcall(function() Remotes.SetTowerAutoRetry:FireServer(true) end)
    end
    if Config.AutoDeclineRevive and Remotes.DeclineRevive then
        pcall(function() Remotes.DeclineRevive:InvokeServer() end)
    end
    AutoClickTowerGUI(targetStage)
    if TowerRuntime.InTower then
        if Remotes.ResumeTower then pcall(function() Remotes.ResumeTower:InvokeServer() end) end
        if tick() - TowerRuntime.LastStartAttempt > 20 then
            TowerRuntime.InTower = false
        else
            return
        end
    end
    EnterTowerAtStage(targetStage)
end

-- ============================================================================
-- 8. SISTEM UI ROCKSTAR HUB v6.9 (CYBER-BLUE EDITION)
-- ============================================================================
local ParentGui = (typeof(gethui) == "function" and gethui()) or CoreGui
if ParentGui:FindFirstChild("RockstarHub_PutarHewan") then
    ParentGui.RockstarHub_PutarHewan:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarHub_PutarHewan"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "RockstarToggleBtn"
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(0, 20, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(10, 18, 32)
FloatBtn.Text = "R★"
FloatBtn.TextColor3 = Color3.fromRGB(0, 215, 255)
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 20
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 195, 255)
FloatStroke.Thickness = 2.2
FloatStroke.Parent = FloatBtn

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 615, 0, 425)
MainFrame.Position = UDim2.new(0.5, -307, 0.5, -212)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 16, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 175, 240)
MainStroke.Thickness = 1.6
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 23, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -100, 1, 0)
TitleLbl.Position = UDim2.new(0, 16, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "★ ROCKSTAR HUB v6.9  |  [🎃] Putar Hewan Peliharaan"
TitleLbl.TextColor3 = Color3.fromRGB(0, 220, 255)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 14
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 28)
MinBtn.Position = UDim2.new(1, -40, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(22, 34, 54)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(0, 215, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local function EnableDrag(guiObj)
    local dragging, dragInput, dragStart, startPos
    guiObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiObj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

EnableDrag(MainFrame)
EnableDrag(FloatBtn)

FloatBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local function Notify(title, msg)
    task.spawn(function()
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 290, 0, 56)
        toast.Position = UDim2.new(1, -305, 1, -72)
        toast.BackgroundColor3 = Color3.fromRGB(13, 21, 36)
        toast.Parent = ScreenGui

        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0, 8)
        tc.Parent = toast

        local ts = Instance.new("UIStroke")
        ts.Color = Color3.fromRGB(0, 205, 255)
        ts.Thickness = 1.5
        ts.Parent = toast

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -16, 0, 22)
        tl.Position = UDim2.new(0, 10, 0, 5)
        tl.BackgroundTransparency = 1
        tl.Text = "★ " .. tostring(title)
        tl.TextColor3 = Color3.fromRGB(0, 220, 255)
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Parent = toast

        local ml = Instance.new("TextLabel")
        ml.Size = UDim2.new(1, -16, 0, 24)
        ml.Position = UDim2.new(0, 10, 0, 26)
        ml.BackgroundTransparency = 1
        ml.Text = tostring(msg)
        ml.TextColor3 = Color3.fromRGB(220, 232, 245)
        ml.Font = Enum.Font.Gotham
        ml.TextSize = 12
        ml.TextXAlignment = Enum.TextXAlignment.Left
        ml.Parent = toast

        task.wait(3)
        if toast and toast.Parent then toast:Destroy() end
    end)
end

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 162, 1, -54)
Sidebar.Position = UDim2.new(0, 8, 0, 48)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 21, 34)
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.PaddingBottom = UDim.new(0, 8)
SidePad.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -184, 1, -54)
ContentContainer.Position = UDim2.new(0, 176, 0, 48)
ContentContainer.BackgroundColor3 = Color3.fromRGB(14, 21, 34)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentContainer

local Tabs = {}
local function CreateTab(tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(175, 195, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = Sidebar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -12, 1, -12)
    page.Position = UDim2.new(0, 6, 0, 6)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 195, 255)
    page.Visible = false
    page.Parent = ContentContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
    end)

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(Tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
            t.Btn.TextColor3 = Color3.fromRGB(175, 195, 220)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    table.insert(Tabs, { Btn = btn, Page = page })
    if #Tabs == 1 then
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    return page
end

local function AddSection(page, title)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -6, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "◆ " .. tostring(title)
    lbl.TextColor3 = Color3.fromRGB(0, 215, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = page
    return lbl
end

local function AddToggle(page, labelText, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(20, 29, 46)
    row.Parent = page

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(230, 240, 255)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 46, 0, 22)
    toggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
    toggleBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(0, 185, 245) or Color3.fromRGB(45, 58, 80)
    toggleBtn.Text = defaultVal and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.Parent = row

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 6)
    tc.Parent = toggleBtn

    local state = defaultVal
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 185, 245) or Color3.fromRGB(45, 58, 80)
        toggleBtn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
end

local function AddButton(page, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(0, 115, 180)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = page

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function CreateSmallBtn(parent, txt, width, color, onClick)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width, 1, 0)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b

    b.MouseButton1Click:Connect(onClick)
    return b
end

-- ============================================================================
-- 9. MEMBANGUN TAB MENU ROCKSTAR HUB v6.9
-- ============================================================================
local TabRoll = CreateTab("🎲 Roll & Dadu")
local TabUpgrade = CreateTab("⬆️ Upgrade & Trait")
local TabTower = CreateTab("🗼 Auto Menara")
local TabEvent = CreateTab("🎃 Halloween & Klaim")
local TabCollect = CreateTab("💰 Uang & Plot")
local TabTeleport = CreateTab("📍 Teleport & Log")

-- ----------------------------------------------------------------------------
-- TAB 1: ROLL, PET & DADU ANTI GANTI-GANTI SENDIRI (v6.9)
-- ----------------------------------------------------------------------------
AddSection(TabRoll, "Auto Roll & Manajemen Hewan Peliharaan")

AddToggle(TabRoll, "🎲 Auto Roll Hewan Peliharaan (Cepat)", Config.AutoRoll, function(v) Config.AutoRoll = v end)
AddToggle(TabRoll, "🐾 Auto Pasang Pet Terbaik (Equip Best Pets)", Config.AutoEquipBest, function(v) Config.AutoEquipBest = v end)
AddToggle(TabRoll, "🧬 Auto Gabungkan Pet Kembar (Auto Fuse)", Config.AutoFuse, function(v) Config.AutoFuse = v end)
AddToggle(TabRoll, "🗑️ Auto Jual Pet Terlemah Saat Penuh (Sell Weakest)", Config.AutoSellWeakest, function(v) Config.AutoSellWeakest = v end)

AddSection(TabRoll, "Kontrol Dadu v6.9 (Anti Ganti-Ganti Sendiri)")

local DiceSelectorCard = Instance.new("Frame")
DiceSelectorCard.Size = UDim2.new(1, -6, 0, 74)
DiceSelectorCard.BackgroundColor3 = Color3.fromRGB(18, 27, 44)
DiceSelectorCard.Parent = TabRoll

local DiceCardCorner = Instance.new("UICorner")
DiceCardCorner.CornerRadius = UDim.new(0, 8)
DiceCardCorner.Parent = DiceSelectorCard

local DiceCardStroke = Instance.new("UIStroke")
DiceCardStroke.Color = Color3.fromRGB(0, 175, 240)
DiceCardStroke.Thickness = 1.2
DiceCardStroke.Parent = DiceSelectorCard

local DiceTitleLbl = Instance.new("TextLabel")
DiceTitleLbl.Size = UDim2.new(1, -16, 0, 24)
DiceTitleLbl.Position = UDim2.new(0, 10, 0, 5)
DiceTitleLbl.BackgroundTransparency = 1
DiceTitleLbl.Text = "🎲 Dadu Terkunci: Memindai..."
DiceTitleLbl.TextColor3 = Color3.fromRGB(0, 225, 255)
DiceTitleLbl.Font = Enum.Font.GothamBold
DiceTitleLbl.TextSize = 12
DiceTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
DiceTitleLbl.Parent = DiceSelectorCard

local DiceCtrlRow = Instance.new("Frame")
DiceCtrlRow.Size = UDim2.new(1, -20, 0, 32)
DiceCtrlRow.Position = UDim2.new(0, 10, 0, 34)
DiceCtrlRow.BackgroundTransparency = 1
DiceCtrlRow.Parent = DiceSelectorCard

local DiceCtrlLayout = Instance.new("UIListLayout")
DiceCtrlLayout.FillDirection = Enum.FillDirection.Horizontal
DiceCtrlLayout.Padding = UDim.new(0, 6)
DiceCtrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
DiceCtrlLayout.Parent = DiceCtrlRow

local function UpdateDiceDisplay()
    local target = GetSingleTargetDice() or "Belum Dipilih"
    local qty = DiscoveredData.OwnedDiceCount[target]
    local qtyStr = qty and (" [Stok: " .. tostring(qty) .. "]") or ""
    DiceTitleLbl.Text = "🔒 Dadu Terkunci:  " .. tostring(target) .. qtyStr
end
UpdateDiceDisplayFunc = UpdateDiceDisplay

CreateSmallBtn(DiceCtrlRow, "◀ Prev Dadu", 105, Color3.fromRGB(32, 48, 76), function()
    RefreshGameKnowledge()
    local list = DiscoveredData.VerifiedDice
    if #list > 0 then
        Config.SelectedDiceIndex = ((Config.SelectedDiceIndex - 2) % #list) + 1
        Config.LockedDiceId = list[Config.SelectedDiceIndex]
    end
    UpdateDiceDisplay()
end)

CreateSmallBtn(DiceCtrlRow, "Pasang Dadu Ini", 130, Color3.fromRGB(0, 150, 210), function()
    EquipSingleTargetDiceNow(true)
    UpdateDiceDisplay()
    Notify("Dadu Dipasang", "Berhasil memasang 1 dadu: " .. tostring(GetSingleTargetDice()))
end)

CreateSmallBtn(DiceCtrlRow, "Next Dadu ▶", 105, Color3.fromRGB(32, 48, 76), function()
    RefreshGameKnowledge()
    local list = DiscoveredData.VerifiedDice
    if #list > 0 then
        Config.SelectedDiceIndex = (Config.SelectedDiceIndex % #list) + 1
        Config.LockedDiceId = list[Config.SelectedDiceIndex]
    end
    UpdateDiceDisplay()
end)

AddToggle(TabRoll, "🛒 Auto Beli Stok Dadu Toko (Tanpa Mengganti Dadu yang Dipakai)", Config.AutoBuyDiceOnly, function(v)
    Config.AutoBuyDiceOnly = v
    if v then
        Notify("Auto Beli Stok", "Membeli stok dadu di toko tanpa mengubah dadu yang sedang kamu pakai!")
    end
end)

AddToggle(TabRoll, "🔒 Auto Kunci & Pertahankan 1 Dadu Pilihan di Atas", Config.AutoEquipSingleDice, function(v)
    Config.AutoEquipSingleDice = v
    if v then
        EquipSingleTargetDiceNow(true)
        Notify("Dadu Dikunci", "Mengunci dadu: " .. tostring(GetSingleTargetDice()))
    end
end)

AddToggle(TabRoll, "🚫 Jangan Beli Dadu Kekosongan / Skip Void Dice", Config.SkipVoidDice, function(v)
    Config.SkipVoidDice = v
    UpdateDiceDisplay()
end)

-- ----------------------------------------------------------------------------
-- TAB 2: PENINGKATAN, PODIUM & AUTO TRAIT TERBAIK
-- ----------------------------------------------------------------------------
AddSection(TabUpgrade, "Auto Trait Terbaik & Grade Terbaik (PetUuid Podium)")

AddToggle(TabUpgrade, "✨ Auto Reroll Trait Terbaik (Semua Pet Podium)", Config.AutoRerollTrait, function(v)
    Config.AutoRerollTrait = v
end)

local TraitModeBtn
TraitModeBtn = AddButton(TabUpgrade, "🎯 Mode Target Trait: Berhenti Saat Dapat Trait Terbaik (Top Tier)", function()
    if Config.TraitTargetMode == "BestOnly" then
        Config.TraitTargetMode = "FillEmpty"
        TraitModeBtn.Text = "🎯 Mode Target Trait: Hanya Isi Pet yang Belum Punya Trait"
    elseif Config.TraitTargetMode == "FillEmpty" then
        Config.TraitTargetMode = "Always"
        TraitModeBtn.Text = "🎯 Mode Target Trait: Reroll Terus Tanpa Henti"
    else
        Config.TraitTargetMode = "BestOnly"
        TraitModeBtn.Text = "🎯 Mode Target Trait: Berhenti Saat Dapat Trait Terbaik (Top Tier)"
    end
end)

AddToggle(TabUpgrade, "⭐ Auto Roll Grade Terbaik (Berhenti di S / SS / SSS / X)", Config.AutoRollGrade, function(v)
    Config.AutoRollGrade = v
end)

AddToggle(TabUpgrade, "📍 Auto Mendekat ke Trait / Grade Pad Saat Reroll", Config.AutoTeleportTraitShop, function(v)
    Config.AutoTeleportTraitShop = v
end)

AddSection(TabUpgrade, "Auto Buy Peningkatan Statistik & Podium")

AddToggle(TabUpgrade, "📈 Auto Buy Semua Peningkatan (Luck1..5, RollSpeed1..5, dll.)", Config.AutoBuyAllUpgrades, function(v)
    Config.AutoBuyAllUpgrades = v
end)

AddToggle(TabUpgrade, "♻️ Auto Buy Peningkatan Rebirth (UpgradeRebirthStat)", Config.AutoBuyRebirthUpgrades, function(v)
    Config.AutoBuyRebirthUpgrades = v
end)

AddToggle(TabUpgrade, "⬆️ Auto Upgrade Level Semua Podium (Slot 1-16)", Config.AutoUpgradePodium, function(v)
    Config.AutoUpgradePodium = v
end)

AddToggle(TabUpgrade, "📍 Teleport Mendekat Saat Upgrade Podium (<14m)", Config.AutoTeleportUpgrade, function(v)
    Config.AutoTeleportUpgrade = v
end)

AddToggle(TabUpgrade, "🔥 Auto Rebirth Otomatis", Config.AutoRebirth, function(v)
    Config.AutoRebirth = v
end)

-- ----------------------------------------------------------------------------
-- TAB 3: AUTO MENARA & MENU PILIH STAGE
-- ----------------------------------------------------------------------------
local TowerStatusLabel = AddSection(TabTower, "Status Menara: Standby  |  Target: Stage 1")

local StageSelectorCard = Instance.new("Frame")
StageSelectorCard.Size = UDim2.new(1, -6, 0, 118)
StageSelectorCard.BackgroundColor3 = Color3.fromRGB(18, 27, 44)
StageSelectorCard.Parent = TabTower

local StageCardCorner = Instance.new("UICorner")
StageCardCorner.CornerRadius = UDim.new(0, 8)
StageCardCorner.Parent = StageSelectorCard

local StageCardStroke = Instance.new("UIStroke")
StageCardStroke.Color = Color3.fromRGB(0, 175, 240)
StageCardStroke.Thickness = 1.2
StageCardStroke.Parent = StageSelectorCard

local StageTitleLbl = Instance.new("TextLabel")
StageTitleLbl.Size = UDim2.new(1, -16, 0, 24)
StageTitleLbl.Position = UDim2.new(0, 10, 0, 6)
StageTitleLbl.BackgroundTransparency = 1
StageTitleLbl.Text = "🎯 Pilih Stage Menara:  STAGE 1  (Mode: Stage Pilihan)"
StageTitleLbl.TextColor3 = Color3.fromRGB(0, 225, 255)
StageTitleLbl.Font = Enum.Font.GothamBold
StageTitleLbl.TextSize = 12
StageTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
StageTitleLbl.Parent = StageSelectorCard

local function UpdateStageDisplay()
    local target = GetTargetTowerStage()
    local modeTxt = (Config.TowerStageMode == "Highest") and "Auto Stage Tertinggi" or "Kunci Stage Pilihan"
    StageTitleLbl.Text = string.format("🎯 Target Menara:  STAGE %d  (%s)", target, modeTxt)
    TowerStatusLabel.Text = string.format("◆ Status: %s  |  Stage: %d", tostring(TowerRuntime.LastStatusText), target)
end

local StepRow = Instance.new("Frame")
StepRow.Size = UDim2.new(1, -20, 0, 34)
StepRow.Position = UDim2.new(0, 10, 0, 34)
StepRow.BackgroundTransparency = 1
StepRow.Parent = StageSelectorCard

local StepLayout = Instance.new("UIListLayout")
StepLayout.FillDirection = Enum.FillDirection.Horizontal
StepLayout.Padding = UDim.new(0, 6)
StepLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StepLayout.Parent = StepRow

CreateSmallBtn(StepRow, "-10", 54, Color3.fromRGB(32, 48, 76), function()
    Config.TowerStageMode = "Selected"
    Config.SelectedStage = math.max(1, Config.SelectedStage - 10)
    UpdateStageDisplay()
end)

CreateSmallBtn(StepRow, "-1", 50, Color3.fromRGB(32, 48, 76), function()
    Config.TowerStageMode = "Selected"
    Config.SelectedStage = math.max(1, Config.SelectedStage - 1)
    UpdateStageDisplay()
end)

local ModeSwitchBtn
ModeSwitchBtn = CreateSmallBtn(StepRow, "Mode: Pilihan", 140, Color3.fromRGB(0, 135, 205), function()
    if Config.TowerStageMode == "Selected" then
        Config.TowerStageMode = "Highest"
        ModeSwitchBtn.Text = "Mode: Tertinggi"
        ModeSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 130)
        RefreshGameKnowledge()
    else
        Config.TowerStageMode = "Selected"
        ModeSwitchBtn.Text = "Mode: Pilihan"
        ModeSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 135, 205)
    end
    UpdateStageDisplay()
end)

CreateSmallBtn(StepRow, "+1", 50, Color3.fromRGB(32, 48, 76), function()
    Config.TowerStageMode = "Selected"
    Config.SelectedStage = Config.SelectedStage + 1
    UpdateStageDisplay()
end)

CreateSmallBtn(StepRow, "+10", 54, Color3.fromRGB(32, 48, 76), function()
    Config.TowerStageMode = "Selected"
    Config.SelectedStage = Config.SelectedStage + 10
    UpdateStageDisplay()
end)

local PresetRow = Instance.new("Frame")
PresetRow.Size = UDim2.new(1, -20, 0, 30)
PresetRow.Position = UDim2.new(0, 10, 0, 76)
PresetRow.BackgroundTransparency = 1
PresetRow.Parent = StageSelectorCard

local PresetLayout = Instance.new("UIListLayout")
PresetLayout.FillDirection = Enum.FillDirection.Horizontal
PresetLayout.Padding = UDim.new(0, 5)
PresetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PresetLayout.Parent = PresetRow

for _, presetNum in ipairs({1, 5, 10, 20, 30, 50}) do
    CreateSmallBtn(PresetRow, "Stg " .. presetNum, 58, Color3.fromRGB(24, 38, 62), function()
        Config.TowerStageMode = "Selected"
        Config.SelectedStage = presetNum
        ModeSwitchBtn.Text = "Mode: Pilihan"
        ModeSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 135, 205)
        UpdateStageDisplay()
    end)
end

AddButton(TabTower, "🚀 Buka & Masuk ke Stage Pilihan Sekarang", function()
    task.spawn(function()
        local stg = GetTargetTowerStage()
        EnterTowerAtStage(stg)
        UpdateStageDisplay()
    end)
end)

AddToggle(TabTower, "🗼 Auto Buka & Farm Menara Sesuai Stage", Config.AutoTower, function(v)
    Config.AutoTower = v
    if v then
        task.spawn(function()
            EnterTowerAtStage(GetTargetTowerStage())
            UpdateStageDisplay()
        end)
    else
        TowerRuntime.InTower = false
        TowerRuntime.LastStatusText = "Standby"
        UpdateStageDisplay()
    end
end)

AddToggle(TabTower, "⚔️ Auto Tap Serang & Klik Tombol UI Menara", Config.AutoTapTowerCombat, function(v) Config.AutoTapTowerCombat = v end)
AddToggle(TabTower, "📍 Auto Teleport ke TowersPad Saat Buka Menara", Config.AutoTeleportToTowerPad, function(v) Config.AutoTeleportToTowerPad = v end)
AddToggle(TabTower, "🔄 Aktifkan Auto-Retry Menara (Server)", Config.AutoRetryTower, function(v)
    Config.AutoRetryTower = v
    if Remotes.SetTowerAutoRetry then pcall(function() Remotes.SetTowerAutoRetry:FireServer(v) end) end
end)
AddToggle(TabTower, "🛡️ Auto Tolak Popup Revive Robux (DeclineRevive)", Config.AutoDeclineRevive, function(v) Config.AutoDeclineRevive = v end)

AddButton(TabTower, "🚪 Keluar dari Menara Sekarang (LeaveTower)", function()
    if Remotes.LeaveTower then pcall(function() Remotes.LeaveTower:InvokeServer() end) end
    TowerRuntime.InTower = false
    TowerRuntime.LastStatusText = "Keluar Manual"
    UpdateStageDisplay()
end)

-- ----------------------------------------------------------------------------
-- TAB 4: EVENT HALLOWEEN & KLAIM
-- ----------------------------------------------------------------------------
AddSection(TabEvent, "Event Halloween & Klaim Hadiah")

AddToggle(TabEvent, "🍬 Auto Ambil & Klaim Permen Halloween", Config.AutoClaimCandy, function(v) Config.AutoClaimCandy = v end)
AddToggle(TabEvent, "📍 Teleport ke Permen Saat Muncul di Map", Config.AutoTeleportCandy, function(v) Config.AutoTeleportCandy = v end)
AddToggle(TabEvent, "🍭 Auto Beli Item Candy Shop (BuyCandyShop)", Config.AutoBuyCandyShop, function(v) Config.AutoBuyCandyShop = v end)
AddToggle(TabEvent, "📜 Auto Beli Item Quest Shop (BuyQuestShop)", Config.AutoBuyQuestShop, function(v) Config.AutoBuyQuestShop = v end)
AddToggle(TabEvent, "🎡 Auto Putar Spin Wheel Gratis", Config.AutoSpinWheel, function(v) Config.AutoSpinWheel = v end)
AddToggle(TabEvent, "🎁 Auto Klaim Semua Hadiah (Daily, Playtime, Quest, Chest)", Config.AutoClaimRewards, function(v) Config.AutoClaimRewards = v end)

AddButton(TabEvent, "🎲 Ambil 3 Golden Dice Rahasia di Peta (Sekali Klik)", function()
    task.spawn(function()
        local hrp = GetHRP()
        local oldCF = hrp and hrp.CFrame
        for _, name in ipairs({"AlleySecret", "HiddenSecret", "TowerSecret"}) do
            local sec = Workspace:FindFirstChild(name)
            local gd = sec and sec:FindFirstChild("GoldenDice")
            local prompt = gd and gd:FindFirstChildOfClass("ProximityPrompt")
            if gd and gd:IsA("BasePart") then
                SafeTeleport(gd.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.25)
                if prompt then SafeFirePrompt(prompt) end
                task.wait(0.2)
            end
        end
        if oldCF then SafeTeleport(oldCF) end
        Notify("Golden Dice", "3 Golden Dice Rahasia telah diambil!")
    end)
end)

-- ----------------------------------------------------------------------------
-- TAB 5: UANG & PLOT
-- ----------------------------------------------------------------------------
AddSection(TabCollect, "Auto Kumpul Uang & Fasilitas Plot")

AddToggle(TabCollect, "💰 Auto Kumpul Uang Semua Podium (Lantai 1 & 2)", Config.AutoCollectCash, function(v) Config.AutoCollectCash = v end)
AddToggle(TabCollect, "🛒 Auto Beli Papan 'Auto Collect' di Plot", Config.AutoBuyAutoCollect, function(v) Config.AutoBuyAutoCollect = v end)
AddToggle(TabCollect, "🏃 Auto Gunakan Treadmill Plot", Config.AutoTreadmill, function(v) Config.AutoTreadmill = v end)
AddToggle(TabCollect, "⏩ Auto Lewati Iklan 5 Menit (WatchSkipAd)", Config.AutoWatchSkipAd, function(v) Config.AutoWatchSkipAd = v end)

-- ----------------------------------------------------------------------------
-- TAB 6: TELEPORT PETA & LOG DIAGNOSTIK v6.9
-- ----------------------------------------------------------------------------
AddSection(TabTeleport, "Log Self-Learning & Diagnostik v6.9")

AddButton(TabTeleport, "📋 Salin Log Diagnostik (Urutan Dadu, Stok, Trait, Tower)", function()
    RefreshGameKnowledge()
    local diceDetails = {}
    for i, dId in ipairs(DiscoveredData.VerifiedDice) do
        local score = DiscoveredData.DiceLuckMap[dId] or 0
        local qty = DiscoveredData.OwnedDiceCount[dId]
        table.insert(diceDetails, string.format("%d.%s(Score:%d,Stok:%s)", i, tostring(dId), math.floor(score), tostring(qty or "?")))
    end
    local lines = {
        "=== LOG SELF-LEARNING ROCKSTAR v6.9 ===",
        "Locked Single Dice: " .. tostring(GetSingleTargetDice()),
        "Sorted Dice (" .. #diceDetails .. "): " .. table.concat(diceDetails, " | "),
        "Discovered Traits (" .. #DiscoveredData.DiscoveredTraits .. "): " .. table.concat(DiscoveredData.DiscoveredTraits, ", "),
        "--- Captured Remote Calls ---",
    }
    for _, l in ipairs(LearningLogs) do table.insert(lines, l) end
    local fullText = table.concat(lines, "\n")
    if typeof(setclipboard) == "function" then
        setclipboard(fullText)
        Notify("Log Disalin", "Log Diagnostik v6.9 berhasil disalin ke Clipboard!")
    else
        print(fullText)
    end
end)

AddSection(TabTeleport, "Teleport Cepat ke Plot & Toko")

AddButton(TabTeleport, "🏠 Teleport ke Plot Milikku", function()
    local myPlot = GetMyPlot()
    if myPlot then SafeTeleport(myPlot:GetPivot() + Vector3.new(0, 5, 0)) end
end)

local MapLocations = {
    { Name = "🎲 Toko Dadu (Dice Shop)", Path = function() return Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("DiceShopPad") end, Fallback = Vector3.new(200, 330, 10) },
    { Name = "🍬 Toko Permen (Candy Shop)", Path = function() return Workspace:FindFirstChild("CandyShopPad") end, Fallback = Vector3.new(203.7, 332.5, 48.1) },
    { Name = "🎃 Peti Angker (Haunted Crate)", Path = function() return Workspace:FindFirstChild("HauntedCrateStand") end, Fallback = Vector3.new(189.5, 333.3, 55.6) },
    { Name = "✨ Toko Trait (Trait Shop)", Path = function() return Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("TraitShopPad") end, Fallback = Vector3.new(210, 330, -15) },
    { Name = "⭐ Toko Grade (Grade Shop)", Path = function() return Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("GradeShopPad") end, Fallback = Vector3.new(215, 330, -30) },
    { Name = "🗼 Menara Pertarungan (TowersPad)", Path = function() return Workspace:FindFirstChild("TowersPad") end, Fallback = Vector3.new(-309.8, 333.5, -28.2) },
}

for _, loc in ipairs(MapLocations) do
    AddButton(TabTeleport, loc.Name, function()
        local obj = loc.Path()
        if obj then
            local zone = obj:FindFirstChild("Zone", true)
            if zone and zone:IsA("BasePart") then
                SafeTeleport(zone.CFrame + Vector3.new(0, 4, 0))
                return
            end
            SafeTeleport(obj:GetPivot() + Vector3.new(0, 4, 0))
        else
            SafeTeleport(CFrame.new(loc.Fallback))
        end
    end)
end

-- ============================================================================
-- 10. LOOP OTOMATISASI UTAMA (BACKGROUND WORKERS)
-- ============================================================================
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if Config.InstantPrompt then
        prompt.HoldDuration = 0
        SafeFirePrompt(prompt)
    end
end)

LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while task.wait(Config.RollDelay) do
        if Config.AutoRoll and Remotes.RequestRoll then
            pcall(function() Remotes.RequestRoll:InvokeServer(false) end)
        end
        if Config.AutoTower and Config.AutoTapTowerCombat and TowerRuntime.InTower then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(500, 300))
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoCollectCash then
            local hrp = GetHRP()
            for _, podium in ipairs(GetMyPodiums()) do
                if podium:GetAttribute("Locked") ~= true then
                    local pad = podium:FindFirstChild("CollectPad")
                    local slot = tonumber(podium:GetAttribute("Slot"))
                    if pad and pad:IsA("BasePart") and hrp and typeof(firetouchinterest) == "function" then
                        pcall(function()
                            firetouchinterest(hrp, pad, 0)
                            firetouchinterest(hrp, pad, 1)
                        end)
                    end
                    if Remotes.CashCollected and slot then
                        pcall(function() Remotes.CashCollected:FireServer(slot) end)
                    end
                end
            end
        end
        if Config.AutoClaimCandy then pcall(CollectHalloweenCandies) end
        if Config.AutoBuyAutoCollect then
            local plot = GetMyPlot()
            local board = plot and plot:FindFirstChild("AutoCollectBoard")
            local panel = board and board:FindFirstChild("Panel")
            local buyPrompt = panel and panel:FindFirstChild("BuyPrompt")
            if buyPrompt and buyPrompt.Enabled then SafeFirePrompt(buyPrompt) end
        end
    end
end)

task.spawn(function()
    local refreshCounter = 0
    while task.wait(1.0) do
        refreshCounter = refreshCounter + 1
        if refreshCounter >= 12 then
            refreshCounter = 0
            task.spawn(function()
                RefreshGameKnowledge()
                UpdateDiceDisplay()
            end)
        end
        if Config.AutoBuyAllUpgrades then RunAutoBuyAllUpgrades() end
        if Config.AutoBuyRebirthUpgrades then RunAutoBuyRebirthUpgrades() end

        -- v6.9: Auto Beli Stok Dadu TIDAK mengubah dadu yang sedang dipakai!
        if Config.AutoBuyDiceOnly then RunBuyDiceStockOnly() end

        -- v6.9: Auto Kunci 1 Dadu HANYA memasang 1 dadu pilihan jika belum terpasang!
        if Config.AutoEquipSingleDice then EquipSingleTargetDiceNow(false) end

        if Config.AutoRerollTrait then RunAutoBestTrait() end
        if Config.AutoRollGrade then RunAutoBestGrade() end
        if Config.AutoBuyCandyShop or Config.AutoBuyQuestShop then RunAutoBuyEventShops() end
        if Config.AutoUpgradePodium then
            for _, podium in ipairs(GetMyPodiums()) do
                if not Config.AutoUpgradePodium then break end
                if podium:GetAttribute("Locked") ~= true then
                    UpgradeSinglePodium(podium, Config.AutoTeleportUpgrade and not TowerRuntime.InTower)
                    task.wait(0.08)
                end
            end
        end
        if Config.AutoRebirth and Remotes.Rebirth then
            pcall(function() Remotes.Rebirth:InvokeServer() end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if Config.AutoTower then
            StepAutoTower()
            UpdateStageDisplay()
        end
    end
end)

task.spawn(function()
    while task.wait(3.5) do
        if Config.AutoEquipBest then
            if Remotes.EquipBestPets then pcall(function() Remotes.EquipBestPets:InvokeServer() end) end
            if Remotes.EquipBestTeam then pcall(function() Remotes.EquipBestTeam:InvokeServer() end) end
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
    end
end)

task.delay(1, UpdateDiceDisplay)
Notify("Rockstar Hub v6.9 Aktif", "Fix Dadu Anti Ganti-Ganti Sendiri siap digunakan!")
