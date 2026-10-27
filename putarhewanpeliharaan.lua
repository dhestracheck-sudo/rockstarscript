-- ============================================================================
-- ★ ROCKSTAR HUB v7.2 - [🎃] PUTAR HEWAN PELIHARAAN (ULTIMATE VERIFIED) ★
-- Game: [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299 | PlaceVersion: 1264)
-- Build: Cyber-Blue Edition (Fully Optimized, Clean & Error-Free)
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

    -- Sistem Dadu v7.2
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

-- ============================================================================
-- 5. SISTEM DADU v7.2 (DUAL MODE DENGAN PENILAIAN LUCK SEJATI)
-- ============================================================================
local function GetTargetDiceId()
    local list = DiscoveredData.VerifiedDice
    if #list == 0 then return nil end

    if Config.DiceMode == "Manual" and Config.LockedDiceId and IsValidKey(Config.LockedDiceId) then
        return Config.LockedDiceId
    end

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

local function EquipTargetDiceNow(forceEquip)
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
    end
    IsScriptCallingEquip = false
end

-- ============================================================================
-- 6. SISTEM AUTO TRAIT, GRADE & PENINGKATAN
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

            if petUuid and #tostring(petUuid) >= 5 and tostring(petUuid) ~= "None" and tostring(petUuid) ~= "0" then
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

            if petUuid and #tostring(petUuid) >= 5 and tostring(petUuid) ~= "None" and tostring(petUuid) ~= "0" then
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
-- 7. KLAIM 3 RAHASIA DADU EMAS & HALLOWEEN CANDY
-- ============================================================================
local SecretStashLocations = {
    {Name = "Alley Cat's Stash", Pos = Vector3.new(244.6, 329.1, -242.8), Path = "Workspace.AlleySecret.GoldenDice"},
    {Name = "Wizard's Stash (Tower Top)", Pos = Vector3.new(-323.4, 359.5, -22.2), Path = "Workspace.TowerSecret.GoldenDice"},
    {Name = "Hidden Stash", Pos = Vector3.new(-281.2, 316.3, 212.2), Path = "Workspace.HiddenSecret.GoldenDice"},
}

local function ClaimAllSecretStashes()
    local hrp = GetHRP()
    if not hrp then return end
    local originalCFrame = hrp.CFrame

    for _, secret in ipairs(SecretStashLocations) do
        SafeTeleport(CFrame.new(secret.Pos + Vector3.new(0, 3, 0)))
        task.wait(0.25)
        local obj = Workspace:FindFirstChild(secret.Path:gsub("Workspace%.", ""), true)
        local prompt = obj and obj:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            SafeFirePrompt(prompt)
            task.wait(0.15)
        end
    end

    task.wait(0.2)
    SafeTeleport(originalCFrame)
end

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

local function CollectHalloweenCandies()
    local hrp = GetHRP()
    if not hrp then return end

    if Remotes.CandyClaim and #DiscoveredData.ValidCandyTokens > 0 then
        for _, token in ipairs(DiscoveredData.ValidCandyTokens) do
            pcall(function() Remotes.CandyClaim:FireServer(token) end)
        end
    end

    local candyRain = Workspace:FindFirstChild("CandyRain")
    if candyRain then
        for _, item in ipairs(candyRain:GetChildren()) do
            if item:IsA("BasePart") and item.Name == "Candy" then
                if Config.AutoTeleportCandy and (hrp.Position - item.Position).Magnitude > 10 then
                    SafeTeleport(item.CFrame + Vector3.new(0, 2.5, 0))
                    task.wait(0.08)
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

-- ============================================================================
-- 8. SISTEM AUTO MENARA (TOWER COMBAT & STAGE SELECTOR)
-- ============================================================================
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
        elseif evStr:find("end") or evStr:find("die") or evStr:find("lose") or evStr:find("defeat") or evStr:find("fail") then
            TowerRuntime.InTower = false
            if Config.AutoDeclineRevive and Remotes.DeclineRevive then
                pcall(function() Remotes.DeclineRevive:InvokeServer() end)
            end
        end
    end)
end

local function AutoClickTowerGUI(stageNum)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return end

    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and g.Name ~= "RockstarHubUI" then
            local gName = g.Name:lower()
            if gName:find("tower") or gName:find("stage") or gName:find("floor") or gName:find("battle") then
                for _, b in ipairs(g:GetDescendants()) do
                    if b:IsA("TextButton") or b:IsA("ImageButton") then
                        local bText = (b:IsA("TextButton") and b.Text:lower()) or ""
                        local bName = b.Name:lower()
                        if bText:find("start") or bText:find("fight") or bText:find("battle") or bText:find("enter") or bText:find("retry") or bText:find("next")
                           or bName:find("start") or bName:find("fight") or bName:find("play") or bName:find("retry") or bName:find("next") then
                            FireGuiButton(b)
                        end
                        if tostring(stageNum) and (bText == tostring(stageNum) or bName == "stage" .. tostring(stageNum)) then
                            FireGuiButton(b)
                        end
                    end
                end
            end
        end
    end
end

local function StartTowerStage(stageNum)
    if os.clock() - TowerRuntime.LastStartAttempt < 1.5 then return end
    TowerRuntime.LastStartAttempt = os.clock()
    TowerRuntime.CurrentStagePlaying = stageNum

    if Config.AutoRetryTower and Remotes.SetTowerAutoRetry then
        pcall(function() Remotes.SetTowerAutoRetry:FireServer(true) end)
    end

    if Config.AutoEquipTowerTeam and Remotes.EquipBestTeam then
        pcall(function() Remotes.EquipBestTeam:InvokeServer() end)
        task.wait(0.08)
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

    if Remotes.StartTower then
        pcall(function() Remotes.StartTower:InvokeServer(stageNum) end)
        pcall(function() Remotes.StartTower:InvokeServer() end)
    end
end

-- ============================================================================
-- 9. TAMPILAN UI CYBER-BLUE EDITION
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(11, 16, 26),
    Sidebar    = Color3.fromRGB(16, 23, 38),
    Element    = Color3.fromRGB(21, 32, 51),
    Hover      = Color3.fromRGB(28, 43, 68),
    Accent     = Color3.fromRGB(0, 215, 255),
    AccentGlow = Color3.fromRGB(56, 225, 255),
    Success    = Color3.fromRGB(0, 230, 118),
    Warning    = Color3.fromRGB(255, 179, 0),
    TextMain   = Color3.fromRGB(232, 244, 255),
    TextDim    = Color3.fromRGB(142, 168, 199),
    Border     = Color3.fromRGB(30, 58, 95),
}

local OldGui = CoreGui:FindFirstChild("RockstarHubUI") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("RockstarHubUI")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Tombol Floating R★
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "RockstarFloatBtn"
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0.02, 0, 0.22, 0)
FloatBtn.BackgroundColor3 = Theme.Sidebar
FloatBtn.Text = "R★"
FloatBtn.TextColor3 = Theme.Accent
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 20
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Theme.Accent
FloatStroke.Thickness = 2
FloatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FloatStroke.Parent = FloatBtn

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 680, 0, 440)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.6
MainStroke.Parent = MainFrame

-- Draggable Logic
local function EnableDragging(dragHandle, frameToMove)
    local dragging = false
    local dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frameToMove.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frameToMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
EnableDragging(FloatBtn, FloatBtn)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 46)
Topbar.BackgroundColor3 = Theme.Sidebar
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame
EnableDragging(Topbar, MainFrame)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 420, 1, 0)
TitleLbl.Position = UDim2.new(0, 16, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "★ ROCKSTAR HUB  |  [🎃] PUTAR HEWAN PELIHARAAN"
TitleLbl.TextColor3 = Theme.Accent
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 14
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = Topbar

local VersionBadge = Instance.new("TextLabel")
VersionBadge.Size = UDim2.new(0, 120, 0, 22)
VersionBadge.Position = UDim2.new(1, -190, 0.5, -11)
VersionBadge.BackgroundColor3 = Theme.Element
VersionBadge.Text = "v7.2 • ULTIMATE"
VersionBadge.TextColor3 = Theme.Success
VersionBadge.Font = Enum.Font.GothamBold
VersionBadge.TextSize = 10
VersionBadge.Parent = Topbar
local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = VersionBadge

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -66, 0.5, -15)
MinBtn.BackgroundColor3 = Theme.Element
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.TextMain
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = Topbar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextMain
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Topbar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 175, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

-- Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -185, 1, -54)
ContentFrame.Position = UDim2.new(0, 180, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Tabs = {}
local TabButtons = {}
local CurrentTab = nil

local function CreateTab(name, icon, order)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 5
    TabPage.ScrollBarImageColor3 = Theme.Accent
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPage.Visible = false
    TabPage.Parent = ContentFrame

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = TabPage

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
    end)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Btn"
    TabBtn.Size = UDim2.new(0.9, 0, 0, 36)
    TabBtn.BackgroundColor3 = Theme.Element
    TabBtn.Text = "  " .. icon .. "  " .. name
    TabBtn.TextColor3 = Theme.TextDim
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.LayoutOrder = order
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Theme.Element
            b.TextColor3 = Theme.TextDim
        end
        TabPage.Visible = true
        TabBtn.BackgroundColor3 = Theme.Hover
        TabBtn.TextColor3 = Theme.Accent
        CurrentTab = name
    end)

    Tabs[name] = TabPage
    TabButtons[name] = TabBtn

    local ComponentFactory = {}

    function ComponentFactory:AddToggle(text, defaultState, callback)
        local state = defaultState
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -10, 0, 42)
        Row.BackgroundColor3 = Theme.Element
        Row.Parent = TabPage

        local RCorner = Instance.new("UICorner")
        RCorner.CornerRadius = UDim.new(0, 8)
        RCorner.Parent = Row

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -65, 1, 0)
        Lbl.Position = UDim2.new(0, 14, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Theme.TextMain
        Lbl.Font = Enum.Font.GothamSemibold
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 44, 0, 24)
        Switch.Position = UDim2.new(1, -54, 0.5, -12)
        Switch.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 55, 75)
        Switch.Text = ""
        Switch.AutoButtonColor = false
        Switch.Parent = Row

        local SCorner = Instance.new("UICorner")
        SCorner.CornerRadius = UDim.new(1, 0)
        SCorner.Parent = Switch

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 18, 0, 18)
        Knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Knob.BackgroundColor3 = Theme.TextMain
        Knob.BorderSizePixel = 0
        Knob.Parent = Switch

        local KCorner = Instance.new("UICorner")
        KCorner.CornerRadius = UDim.new(1, 0)
        KCorner.Parent = Knob

        local function UpdateState(newVal)
            state = newVal
            Switch.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 55, 75)
            Knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            if callback then callback(state) end
        end

        Switch.MouseButton1Click:Connect(function()
            UpdateState(not state)
        end)

        return {
            Set = function(_, v) UpdateState(v) end,
            Get = function() return state end,
        }
    end

    function ComponentFactory:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 38)
        Btn.BackgroundColor3 = Theme.Hover
        Btn.Text = text
        Btn.TextColor3 = Theme.AccentGlow
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12
        Btn.AutoButtonColor = true
        Btn.Parent = TabPage

        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 8)
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

Tab1:AddSection("Sistem Dadu v7.2")
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

local function UpdateDiceDisplay()
    local list = DiscoveredData.VerifiedDice
    if #list == 0 then
        DiceNameDisplay.Text = "Dadu: (Toko Dadu Kosong / Belum Terbaca)"
        return
    end

    if Config.DiceMode == "AutoBest" then
        local bestId = GetTargetDiceId()
        DiceModeBtn.Text = "Mode: [Auto-Best Luck] (Otomatis Terkuat)"
        DiceModeBtn.TextColor3 = Theme.Success
        DiceNameDisplay.Text = "Terbaik: " .. tostring(bestId or "None")
    else
        DiceModeBtn.Text = "Mode: [Kunci Manual] (Hanya Dadu Pilihan)"
        DiceModeBtn.TextColor3 = Theme.Warning
        if Config.LockedDiceId then
            DiceNameDisplay.Text = "Terkunci: " .. tostring(Config.LockedDiceId)
        else
            local cur = list[Config.SelectedDiceIndex] or list[1]
            DiceNameDisplay.Text = "Pilihan: " .. tostring(cur)
        end
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
Tab2:AddSection("Auto Peningkatan Podium (Slot 1–16)")
Tab2:AddToggle("⬆️ Auto Peningkatan Level Podium (Lantai 1 & 2)", Config.AutoUpgradePodium, function(v) Config.AutoUpgradePodium = v end)
Tab2:AddToggle("📍 Auto Mendekat ke Podium Saat Meningkatkan", Config.AutoTeleportUpgrade, function(v) Config.AutoTeleportUpgrade = v end)

Tab2:AddSection("Auto Beli Peningkatan Status")
Tab2:AddToggle("📈 Auto Beli Peningkatan Status (Luck, RollSpeed, dll.)", Config.AutoBuyAllUpgrades, function(v) Config.AutoBuyAllUpgrades = v end)
Tab2:AddToggle("♻️ Auto Beli Peningkatan Rebirth", Config.AutoBuyRebirthUpgrades, function(v) Config.AutoBuyRebirthUpgrades = v end)

Tab2:AddSection("Auto Reroll Trait & Grade Terbaik")
Tab2:AddToggle("✨ Auto Reroll Trait Terbaik (Stop Saat Dapat Top Trait)", Config.AutoRerollTrait, function(v) Config.AutoRerollTrait = v end)
Tab2:AddToggle("⭐ Auto Roll Grade Terbaik (Stop Saat Dapat S/SS/SSS/X)", Config.AutoRollGrade, function(v) Config.AutoRollGrade = v end)
Tab2:AddToggle("📍 Auto Teleport ke Toko Trait / Grade", Config.AutoTeleportTraitShop, function(v) Config.AutoTeleportTraitShop = v end)

-- ============================================================================
-- 12. KONTEN TAB 3: PLOT & UANG
-- ============================================================================
Tab3:AddSection("Otomatisasi Plot")
Tab3:AddToggle("💰 Auto Ambil Uang Podium (CollectPad Instan)", Config.AutoCollectCash, function(v) Config.AutoCollectCash = v end)
Tab3:AddToggle("🏃 Auto Treadmill Plot (Bonus Luck)", Config.AutoTreadmill, function(v) Config.AutoTreadmill = v end)
Tab3:AddToggle("📦 Auto Beli Board Auto-Collect", Config.AutoBuyAutoCollect, function(v) Config.AutoBuyAutoCollect = v end)
Tab3:AddToggle("📺 Auto Tonton Skip Ad Board (5 Menit)", Config.AutoWatchSkipAd, function(v) Config.AutoWatchSkipAd = v end)
Tab3:AddToggle("🔄 Auto Rebirth Otomatis", Config.AutoRebirth, function(v) Config.AutoRebirth = v end)

-- ============================================================================
-- 13. KONTEN TAB 4: AUTO MENARA
-- ============================================================================
Tab4:AddSection("Target Stage Menara")
local StageBox = Instance.new("Frame")
StageBox.Size = UDim2.new(1, -10, 0, 70)
StageBox.BackgroundColor3 = Theme.Element
StageBox.Parent = Tabs["Auto Menara"]
local SB_Corner = Instance.new("UICorner")
SB_Corner.CornerRadius = UDim.new(0, 8)
SB_Corner.Parent = StageBox

local TowerModeBtn = Instance.new("TextButton")
TowerModeBtn.Size = UDim2.new(1, -20, 0, 24)
TowerModeBtn.Position = UDim2.new(0, 10, 0, 6)
TowerModeBtn.BackgroundColor3 = Theme.Hover
TowerModeBtn.Text = "Mode Menara: [Stage Pilihan Manual]"
TowerModeBtn.TextColor3 = Theme.Accent
TowerModeBtn.Font = Enum.Font.GothamBold
TowerModeBtn.TextSize = 11
TowerModeBtn.Parent = StageBox
local TMB_Corner = Instance.new("UICorner")
TMB_Corner.CornerRadius = UDim.new(0, 6)
TMB_Corner.Parent = TowerModeBtn

local StageDisplay = Instance.new("TextLabel")
StageDisplay.Size = UDim2.new(1, -170, 0, 28)
StageDisplay.Position = UDim2.new(0, 85, 0, 35)
StageDisplay.BackgroundColor3 = Theme.Sidebar
StageDisplay.Text = "Stage: 1 (Terbuka: 1)"
StageDisplay.TextColor3 = Theme.Success
StageDisplay.Font = Enum.Font.GothamBold
StageDisplay.TextSize = 12
StageDisplay.Parent = StageBox
local SD_Corner = Instance.new("UICorner")
SD_Corner.CornerRadius = UDim.new(0, 6)
SD_Corner.Parent = StageDisplay

local DecStgBtn = Instance.new("TextButton")
DecStgBtn.Size = UDim2.new(0, 70, 0, 28)
DecStgBtn.Position = UDim2.new(0, 10, 0, 35)
DecStgBtn.BackgroundColor3 = Theme.Sidebar
DecStgBtn.Text = "— 1 Stage"
DecStgBtn.TextColor3 = Theme.TextMain
DecStgBtn.Font = Enum.Font.GothamBold
DecStgBtn.TextSize = 11
DecStgBtn.Parent = StageBox
local DSB_Corner = Instance.new("UICorner")
DSB_Corner.CornerRadius = UDim.new(0, 6)
DSB_Corner.Parent = DecStgBtn

local IncStgBtn = Instance.new("TextButton")
IncStgBtn.Size = UDim2.new(0, 70, 0, 28)
IncStgBtn.Position = UDim2.new(1, -80, 0, 35)
IncStgBtn.BackgroundColor3 = Theme.Sidebar
IncStgBtn.Text = "+ 1 Stage"
IncStgBtn.TextColor3 = Theme.TextMain
IncStgBtn.Font = Enum.Font.GothamBold
IncStgBtn.TextSize = 11
IncStgBtn.Parent = StageBox
local ISB_Corner = Instance.new("UICorner")
ISB_Corner.CornerRadius = UDim.new(0, 6)
ISB_Corner.Parent = IncStgBtn

local function UpdateStageLabel()
    StageDisplay.Text = string.format("Stage: %d (Terbuka: %d)", Config.SelectedStage, Config.HighestUnlockedStage)
end

TowerModeBtn.MouseButton1Click:Connect(function()
    if Config.TowerStageMode == "Selected" then
        Config.TowerStageMode = "Highest"
        TowerModeBtn.Text = "Mode Menara: [Auto Stage Tertinggi]"
        TowerModeBtn.TextColor3 = Theme.Success
    else
        Config.TowerStageMode = "Selected"
        TowerModeBtn.Text = "Mode Menara: [Stage Pilihan Manual]"
        TowerModeBtn.TextColor3 = Theme.Accent
    end
end)

DecStgBtn.MouseButton1Click:Connect(function()
    Config.SelectedStage = math.max(1, Config.SelectedStage - 1)
    UpdateStageLabel()
end)

IncStgBtn.MouseButton1Click:Connect(function()
    Config.SelectedStage = Config.SelectedStage + 1
    UpdateStageLabel()
end)

Tab4:AddSection("Fitur Bertarung Menara")
Tab4:AddToggle("🗼 Auto Buka & Farm Menara Sesuai Stage", Config.AutoTower, function(v) Config.AutoTower = v end)
Tab4:AddToggle("⚔️ Auto Pasang Tim Terbaik (Equip Best Team)", Config.AutoEquipTowerTeam, function(v) Config.AutoEquipTowerTeam = v end)
Tab4:AddToggle("💥 Auto Tap Serang di Menara (Tap Combat)", Config.AutoTapTowerCombat, function(v) Config.AutoTapTowerCombat = v end)
Tab4:AddToggle("🔁 Auto Ulangi Saat Menang (Auto Retry)", Config.AutoRetryTower, function(v) Config.AutoRetryTower = v end)
Tab4:AddToggle("🛡️ Auto Tolak Layar Revive Robux (Decline Revive)", Config.AutoDeclineRevive, function(v) Config.AutoDeclineRevive = v end)

Tab4:AddButton("🚀 Masuk ke Stage Pilihan Sekarang", function()
    StartTowerStage(GetTargetTowerStage())
end)

-- ============================================================================
-- 14. KONTEN TAB 5: HALLOWEEN & RAHASIA
-- ============================================================================
Tab5:AddSection("Rahasia Dadu Emas (Secret Rewards)")
Tab5:AddButton("✨ KLAIM SEMUA 3 RAHASIA DADU EMAS (Alley, Tower, Hidden)", function()
    ClaimAllSecretStashes()
end)

Tab5:AddSection("Event Halloween")
Tab5:AddToggle("🍬 Auto Ambil Permen Fisik (Workspace.CandyRain)", Config.AutoClaimCandy, function(v) Config.AutoClaimCandy = v end)
Tab5:AddToggle("📍 Auto Teleport ke Titik Permen", Config.AutoTeleportCandy, function(v) Config.AutoTeleportCandy = v end)
Tab5:AddToggle("🍭 Auto Beli Item Halloween Candy Shop", Config.AutoBuyCandyShop, function(v) Config.AutoBuyCandyShop = v end)
Tab5:AddToggle("📜 Auto Beli Item Toko Quest", Config.AutoBuyQuestShop, function(v) Config.AutoBuyQuestShop = v end)

Tab5:AddButton("📦 Buka Peti Haunted Crate Sekarang", function()
    local stand = Workspace:FindFirstChild("HauntedCrateStand")
    local pad = stand and stand:FindFirstChild("HauntedCratePad")
    local zone = pad and pad:FindFirstChild("Zone")
    if zone then
        SafeTeleport(zone.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.15)
        local prompt = zone:FindFirstChildOfClass("ProximityPrompt")
        if prompt then SafeFirePrompt(prompt) end
    end
end)

-- ============================================================================
-- 15. KONTEN TAB 6: KLAIM HADIAH & TELEPORT
-- ============================================================================
Tab6:AddSection("Otomatisasi Hadiah")
Tab6:AddToggle("🎁 Auto Klaim Semua Hadiah (Harian, Quests, Chests)", Config.AutoClaimRewards, function(v) Config.AutoClaimRewards = v end)
Tab6:AddToggle("🎡 Auto Putar Roda Gratis (Spin Wheel)", Config.AutoSpinWheel, function(v) Config.AutoSpinWheel = v end)

Tab6:AddSection("Teleport Lokasi Cepat")
Tab6:AddButton("🏠 Teleport ke Plot Saya (Plot6)", function()
    local plot = GetMyPlot()
    local sp = plot and plot:FindFirstChild("Spawn")
    if sp then SafeTeleport(sp.CFrame + Vector3.new(0, 3.5, 0)) end
end)

Tab6:AddButton("🗼 Teleport ke Pintu Menara", function()
    SafeTeleport(Vector3.new(-309.8, 329.5, -28.2))
end)

Tab6:AddButton("🎲 Teleport ke Toko Dadu (Dice Shop)", function()
    local dicePad = Workspace:FindFirstChild("DiceShopPad", true)
    local zone = dicePad and dicePad:FindFirstChild("Zone")
    if zone then SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0)) end
end)

Tab6:AddButton("✨ Teleport ke Toko Trait & Grade", function()
    local traitPad = Workspace:FindFirstChild("TraitShopPad", true)
    local zone = traitPad and traitPad:FindFirstChild("Zone")
    if zone then SafeTeleport(zone.CFrame + Vector3.new(0, 3.5, 0)) end
end)

Tab6:AddButton("🍬 Teleport ke Toko Permen Halloween", function()
    SafeTeleport(Vector3.new(203.7, 329.5, 48.1))
end)

Tab6:AddButton("🎡 Teleport ke Roda Hadiah (Spin Wheel)", function()
    SafeTeleport(Vector3.new(235.5, 339.1, -53.7))
end)

-- ============================================================================
-- 16. KONTEN TAB 7: LOG & DIAGNOSTIK
-- ============================================================================
Tab7:AddSection("Informasi Akun & Map")
local LogBox = Instance.new("TextBox")
LogBox.Size = UDim2.new(1, -10, 0, 180)
LogBox.BackgroundColor3 = Theme.Element
LogBox.Text = "Memuat log aktivitas..."
LogBox.TextColor3 = Theme.TextMain
LogBox.Font = Enum.Font.Code
LogBox.TextSize = 10
LogBox.ClearTextOnFocus = false
LogBox.TextEditable = false
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.Parent = Tabs["Log Status"]
local LB_Corner = Instance.new("UICorner")
LB_Corner.CornerRadius = UDim.new(0, 8)
LB_Corner.Parent = LogBox

Tab7:AddButton("📋 Salin Log Diagnostik Lengkap ke Clipboard", function()
    local text = table.concat(LearningLogs, "\n")
    if typeof(setclipboard) == "function" then
        pcall(setclipboard, text)
    end
end)

local function RefreshLogDisplay()
    local lines = {}
    table.insert(lines, "=== LOG STATUS ROCKSTAR v7.2 ===")
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
TabButtons["Roll & Dadu"].BackgroundColor3 = Theme.Hover
TabButtons["Roll & Dadu"].TextColor3 = Theme.Accent
Tabs["Roll & Dadu"].Visible = true
CurrentTab = "Roll & Dadu"

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

print("★ Rockstar Hub v7.2 Berhasil Dijalankan! Tema: Cyber-Blue Edition ★")
