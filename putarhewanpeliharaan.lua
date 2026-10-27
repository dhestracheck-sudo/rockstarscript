-- ============================================================================
-- ★ ROCKSTAR HUB v6.6 - [🎃] PUTAR HEWAN PELIHARAAN (CYBER-BLUE EDITION) ★
-- Game: [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299)
-- Update v6.6 (Berdasarkan Log Self-Learning v6.3):
--   [+] Fix Auto Halloween Candy (CandyClaim Event Listener + Smart Touch + Anti-Error)
--   [+] Pre-loaded Exact BuyUpgrade IDs (Luck1..5, RollSpeed1..5, MutationLuck1..5,
--       TreadmillLuck1..5, GoldenDice1..5, dll.)
--   [+] Fix StartTower & Menu Pilih Stage (Blokir nama function UI seperti ScaleTween/SetBar)
--   [+] Exact PodiumAction Signature: InvokeServer(SlotNumber, "Upgrade" / "UpgradeMax")
--   [+] Dilengkapi Log Self-Learning v6.6 + Tombol Salin Log
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

    -- Auto Collect & Plot
    AutoCollectCash = false,
    AutoBuyAutoCollect = false,
    AutoTreadmill = false,
    AutoWatchSkipAd = false,

    -- Auto Peningkatan & Beli (v6.6 Exact Keys)
    AutoUpgradePodium = false,
    AutoTeleportUpgrade = true,
    AutoBuyAllUpgrades = false,
    AutoBuyRebirthUpgrades = false,
    AutoBuyAndEquipDice = false,
    AutoBuyCandyShop = false,
    AutoBuyQuestShop = false,
    AutoClickUpgradeUI = false,
    AutoRebirth = false,
    AutoRerollTrait = false,
    AutoRollGrade = false,

    -- Auto Menara & Pilih Stage (v6.6)
    AutoTower = false,
    TowerStageMode = "Selected",   -- "Selected" (Stage Pilihan) atau "Highest" (Stage Tertinggi)
    SelectedStage = 1,
    HighestUnlockedStage = 1,
    AutoTeleportToTowerPad = true,
    AutoTapTowerCombat = true,
    AutoRetryTower = true,
    AutoDeclineRevive = true,
    AutoEquipTowerTeam = true,

    -- Auto Klaim & Event Halloween (v6.6 Fixed)
    AutoSpinWheel = false,
    AutoClaimRewards = false,
    AutoClaimCandy = false,
    AutoTeleportCandy = false,     -- Opsi teleport langsung ke permen yang muncul di map

    -- Utility
    InstantPrompt = true,
    AntiAFK = true,
}

-- ============================================================================
-- 2. KONEKSI REMOTES & DATABASE KUNCI ASLI (DARI LOG v6.3)
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
    -- Roll & Pets
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

    -- Upgrades, Shops & Progression
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

    -- Towers
    StartTower = GetRemote("StartTower"),
    LeaveTower = GetRemote("LeaveTower"),
    DeclineRevive = GetRemote("DeclineRevive"),
    ResumeTower = GetRemote("ResumeTower"),
    SetTowerAutoRetry = GetRemote("SetTowerAutoRetry"),
    TowerEvent = GetRemote("TowerEvent"),

    -- Claims & Data
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

-- Daftar Nama Method UI yang HARUS DIABAIKAN agar tidak masuk ke StartTower / BuyCandyShop
local BlacklistedMethodNames = {
    IsAutoClimbing = true, ShowUnit = true, ScaleTween = true, OnRevive = true,
    RenderRetry = true, SetHidden = true, GetProfile = true, DeclineRevive = true,
    SetOpen = true, DodgeStrip = true, ShakeArena = true, SyncRetry = true,
    PopText = true, Burst = true, Knockback = true, SetFloorAnchor = true,
    SetBar = true, Init = true, Start = true, Update = true, Destroy = true,
    Open = true, Close = true, Toggle = true, Bind = true, Render = true,
     Format = true, OnClick = true, Setup = true, Cleanup = true, New = true,
}

-- Kunci Asli BuyUpgrade hasil tangkapan Log Self-Learning + ekspansi tier 1..5
local DiscoveredData = {
    Upgrades = {
        -- Kunci terkonfirmasi 100% dari Log Self-Learning v6.3:
        "Luck1", "Luck2", "Luck3", "Luck4", "Luck5",
        "RollSpeed1", "RollSpeed2", "RollSpeed3", "RollSpeed4", "RollSpeed5",
        "MutationLuck1", "MutationLuck2", "MutationLuck3", "MutationLuck4", "MutationLuck5",
        "TreadmillLuck1", "TreadmillLuck2", "TreadmillLuck3", "TreadmillLuck4", "TreadmillLuck5",
        "GoldenDice1", "GoldenDice2", "GoldenDice3", "GoldenDice4", "GoldenDice5",
        -- Ekspansi nama standar berpola sama:
        "Cash1", "Cash2", "Cash3", "Cash4", "Cash5",
        "CashMultiplier1", "CashMultiplier2", "CashMultiplier3",
        "Inventory1", "Inventory2", "Inventory3", "Inventory4",
        "PetCapacity1", "PetCapacity2", "PetCapacity3",
        "WalkSpeed1", "WalkSpeed2", "WalkSpeed3",
        "Candy1", "Candy2", "Candy3",
        "Luck", "RollSpeed", "MutationLuck", "TreadmillLuck", "GoldenDice",
    },
    RebirthStats = {
        "Luck1", "Luck2", "Luck3", "Cash1", "Cash2", "Cash3",
        "RollSpeed1", "RollSpeed2", "MutationLuck1", "MutationLuck2",
        "Luck", "Cash", "RollSpeed", "Inventory", "Damage", "Candy",
        "CashMultiplier", "LuckMultiplier", "ExtraPets", "StartingCash"
    },
    DiceList = {
        "Basic", "BasicDice", "Silver", "SilverDice", "Golden", "GoldenDice",
        "Diamond", "DiamondDice", "Emerald", "EmeraldDice", "Ruby", "RubyDice",
        "Mythic", "MythicDice", "Void", "VoidDice", "Glitched", "GlitchedDice",
        "Halloween", "HalloweenDice", "Pumpkin", "PumpkinDice", "Spooky", "SpookyDice",
        "Haunted", "HauntedDice", "Candy", "CandyDice"
    },
    CandyShopItems = {
        "HauntedCrate", "PumpkinDice", "HalloweenDice", "CandyLuck1", "CandyLuck2",
        "CandyMultiplier1", "CandyMultiplier2", "CandyRollSpeed1", "CandyPotion",
        "SpookyEgg", "GhostPet", "CandyUpgrade1", "CandyUpgrade2",
        "Luck1", "Luck2", "RollSpeed1", "MutationLuck1", "GoldenDice1"
    },
    QuestShopItems = {
        "Luck1", "RollSpeed1", "MutationLuck1", "GoldenDice1",
        "Luck", "RollSpeed", "Cash", "Dice", "Potion"
    },
    ValidCandyTokens = {}, -- Diisi otomatis saat server memunculkan permen atau dari Self-Learning
}

-- Sistem Log Self-Learning v6.6
local LearningLogs = {}
local function AddLearningLog(remoteName, arg1, arg2)
    local timeStr = os.date("%H:%M:%S")
    local line = string.format("%s | Belajar %s: (%s, %s)", timeStr, tostring(remoteName), tostring(arg1), tostring(arg2))
    for _, existing in ipairs(LearningLogs) do
        if existing:sub(12) == line:sub(12) then return end
    end
    table.insert(LearningLogs, 1, line)
    if #LearningLogs > 40 then
        table.remove(LearningLogs)
    end
end

local function AddUniqueKey(list, key)
    if key == nil then return end
    if type(key) == "function" or type(key) == "userdata" then return end
    local str = tostring(key)
    if #str == 0 or #str > 45 then return end
    if BlacklistedMethodNames[str] then return end
    if str == "__index" or str == "RBX_ReimportId" or str == "OwnerUserId" then return end
    for _, existing in ipairs(list) do
        if existing == key then return end
    end
    table.insert(list, key)
end

-- Hook Self-Learning (__namecall) untuk merekam argumen asli saat pemain klik manual 1x
if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if (method == "InvokeServer" or method == "FireServer") and typeof(self) == "Instance" then
                local rName = self.Name
                local a1, a2 = ...
                if rName == "BuyUpgrade" and a1 ~= nil and not BlacklistedMethodNames[tostring(a1)] then
                    AddUniqueKey(DiscoveredData.Upgrades, a1)
                    AddLearningLog("BuyUpgrade", a1, a2)
                elseif rName == "UpgradeRebirthStat" and a1 ~= nil then
                    AddUniqueKey(DiscoveredData.RebirthStats, a1)
                    AddLearningLog("UpgradeRebirthStat", a1, a2)
                elseif rName == "BuyCandyShop" and a1 ~= nil and not BlacklistedMethodNames[tostring(a1)] then
                    AddUniqueKey(DiscoveredData.CandyShopItems, a1)
                    AddLearningLog("BuyCandyShop", a1, a2)
                elseif rName == "BuyQuestShop" and a1 ~= nil and not BlacklistedMethodNames[tostring(a1)] then
                    AddUniqueKey(DiscoveredData.QuestShopItems, a1)
                    AddLearningLog("BuyQuestShop", a1, a2)
                elseif rName == "BuyDice" and a1 ~= nil then
                    AddUniqueKey(DiscoveredData.DiceList, a1)
                    AddLearningLog("BuyDice", a1, a2)
                elseif rName == "CandyClaim" and a1 ~= nil then
                    AddUniqueKey(DiscoveredData.ValidCandyTokens, a1)
                    AddLearningLog("CandyClaim", a1, a2)
                elseif rName == "StartTower" and not BlacklistedMethodNames[tostring(a1)] then
                    AddLearningLog("StartTower", a1, a2)
                elseif rName == "PodiumAction" then
                    AddLearningLog("PodiumAction", a1, a2)
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

-- Pemindaian Data Game (HANYA mengambil tabel/data, memblokir function UI!)
local function RefreshGameKnowledge()
    if Remotes.GetData then
        local ok, pData = pcall(function()
            return Remotes.GetData:InvokeServer()
        end)
        if ok and type(pData) == "table" then
            for k, v in pairs(pData) do
                local lowerK = tostring(k):lower()
                if type(v) == "number" and (lowerK:find("tower") or lowerK:find("stage") or lowerK:find("floor")) then
                    if v >= 1 and v <= 1000 and v > Config.HighestUnlockedStage then
                        Config.HighestUnlockedStage = math.floor(v)
                    end
                elseif type(v) == "table" then
                    if lowerK:find("upgrade") and not lowerK:find("rebirth") then
                        for uk, uv in pairs(v) do
                            if type(uv) ~= "function" then AddUniqueKey(DiscoveredData.Upgrades, uk) end
                        end
                    elseif lowerK:find("rebirth") or lowerK:find("prestige") then
                        for rk, rv in pairs(v) do
                            if type(rv) ~= "function" then AddUniqueKey(DiscoveredData.RebirthStats, rk) end
                        end
                    elseif lowerK:find("dice") then
                        for dk, dv in pairs(v) do
                            if type(dv) ~= "function" then AddUniqueKey(DiscoveredData.DiceList, dk) end
                        end
                    elseif lowerK:find("candy") and not lowerK:find("amount") then
                        for ck, cv in pairs(v) do
                            if type(cv) ~= "function" then AddUniqueKey(DiscoveredData.CandyShopItems, ck) end
                        end
                    elseif lowerK:find("quest") then
                        for qk, qv in pairs(v) do
                            if type(qv) ~= "function" then AddUniqueKey(DiscoveredData.QuestShopItems, qk) end
                        end
                    elseif lowerK:find("tower") then
                        for tk, tv in pairs(v) do
                            local ltk = tostring(tk):lower()
                            if type(tv) == "number" and (ltk:find("stage") or ltk:find("floor") or ltk:find("max") or ltk:find("high") or ltk:find("current")) then
                                if tv >= 1 and tv <= 1000 and tv > Config.HighestUnlockedStage then
                                    Config.HighestUnlockedStage = math.floor(tv)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if SharedFolder then
        for _, inst in ipairs(SharedFolder:GetDescendants()) do
            if inst:IsA("ModuleScript") then
                local mName = inst.Name:lower()
                -- Abaikan ModuleScript yang merupakan Controller/Client UI agar tidak mengambil nama function
                if not mName:find("controller") and not mName:find("client") and not mName:find("ui") and not mName:find("renderer") then
                    local ok, mod = pcall(require, inst)
                    if ok and type(mod) == "table" then
                        for k, v in pairs(mod) do
                            -- PENTING: Abaikan jika v adalah function!
                            if type(v) == "table" then
                                local itemId = v.Id or v.ID or v.Key or v.UpgradeId or type(k) == "string" and k
                                if itemId and not BlacklistedMethodNames[tostring(itemId)] then
                                    if mName:find("upgrade") and not mName:find("rebirth") then
                                        AddUniqueKey(DiscoveredData.Upgrades, itemId)
                                        AddLearningLog("BuyUpgrade", itemId, nil)
                                    elseif mName:find("rebirth") then
                                        AddUniqueKey(DiscoveredData.RebirthStats, itemId)
                                    elseif mName:find("dice") then
                                        AddUniqueKey(DiscoveredData.DiceList, itemId)
                                    elseif mName:find("candy") then
                                        AddUniqueKey(DiscoveredData.CandyShopItems, itemId)
                                        AddLearningLog("BuyCandyShop", itemId, nil)
                                    elseif mName:find("quest") then
                                        AddUniqueKey(DiscoveredData.QuestShopItems, itemId)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

task.spawn(RefreshGameKnowledge)

-- ============================================================================
-- 3. FUNGSI HELPER PLOT, PODIUM, PROMPT & UI SIGNAL
-- ============================================================================
local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function SafeTeleport(targetCFrame)
    local hrp = GetHRP()
    if hrp and targetCFrame then
        hrp.CFrame = targetCFrame
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
            for _, conn in ipairs(getconnections(btn.Activated)) do
                conn:Fire()
                fired = true
            end
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
                fired = true
            end
        end)
    end
    return fired
end

-- ============================================================================
-- 4. SISTEM AUTO HALLOWEEN CANDY BEBAS ERROR (v6.6)
-- ============================================================================

-- 1. Listener jika Server mengirimkan ID Permen melalui CandyClaim.OnClientEvent
if Remotes.CandyClaim and Remotes.CandyClaim:IsA("RemoteEvent") then
    Remotes.CandyClaim.OnClientEvent:Connect(function(a1, a2)
        -- Simpan token/ID permen yang dikirim server
        if type(a1) == "string" or type(a1) == "number" then
            AddUniqueKey(DiscoveredData.ValidCandyTokens, a1)
            if Config.AutoClaimCandy then
                task.spawn(function()
                    pcall(function() Remotes.CandyClaim:FireServer(a1) end)
                end)
            end
        elseif type(a1) == "table" then
            for k, v in pairs(a1) do
                local id = (type(v) == "table" and (v.Id or v.ID or v.UUID)) or (type(k) == "string" and k) or v
                if type(id) == "string" or type(id) == "number" then
                    AddUniqueKey(DiscoveredData.ValidCandyTokens, id)
                    if Config.AutoClaimCandy then
                        task.spawn(function()
                            pcall(function() Remotes.CandyClaim:FireServer(id) end)
                        end)
                    end
                end
            end
        end
    end)
end

-- Daftar objek bangunan statis bertema Halloween di map yang BUKAN permen jatuh
local StaticHalloweenObjects = {
    CandyShopPad = true,
    HauntedCrateStand = true,
    HauntedCratePad = true,
    halloweenshop = true,
    Pumpkin = true, -- Dekorasi labu di dekat HauntedCrateStand
}

-- 2. Fungsi Pemindai & Pengambil Permen Halloween di Map (Tanpa Error)
local function CollectHalloweenCandies()
    local hrp = GetHRP()
    if not hrp then return end

    -- A. Klaim token permen yang sudah valid dari event server
    if Remotes.CandyClaim and #DiscoveredData.ValidCandyTokens > 0 then
        for _, token in ipairs(DiscoveredData.ValidCandyTokens) do
            pcall(function()
                Remotes.CandyClaim:FireServer(token)
            end)
        end
    end

    -- B. Pindai objek permen fisik di Workspace (yang punya TouchInterest / ProximityPrompt / Attribute Candy)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if not StaticHalloweenObjects[obj.Name] and not obj.Name:match("^Plot%d+$") and obj ~= LocalPlayer.Character then
            local oName = obj.Name:lower()
            local isCandyContainer = oName:find("candy") or oName:find("treat") or oName:find("drop")
                or oName:find("event") or oName:find("spooky") or oName:find("collect")

            if isCandyContainer then
                local targets = obj:IsA("BasePart") and {obj} or obj:GetDescendants()
                for _, item in ipairs(targets) do
                    if item:IsA("BasePart") and item.Name ~= "Zone" and item.Name ~= "Pozdro" then
                        local hasTouch = item:FindFirstChildOfClass("TouchTransmitter") ~= nil
                        local prompt = item:FindFirstChildOfClass("ProximityPrompt")
                        local candyId = item:GetAttribute("Id") or item:GetAttribute("CandyId") or item:GetAttribute("UUID")
                            or ( item.Parent and (item.Parent:GetAttribute("Id") or item.Parent:GetAttribute("CandyId")) )

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
                            if prompt then
                                SafeFirePrompt(prompt)
                            end
                            if candyId and Remotes.CandyClaim then
                                pcall(function() Remotes.CandyClaim:FireServer(candyId) end)
                            elseif Remotes.CandyClaim and item.Name ~= "Part" and item.Name ~= "MeshPart" then
                                pcall(function() Remotes.CandyClaim:FireServer(item.Name) end)
                                pcall(function() Remotes.CandyClaim:FireServer(item) end)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================================
-- 5. SISTEM AUTO BUY PENINGKATAN & UPGRADE PODIUM (BERDASARKAN LOG v6.3)
-- ============================================================================

-- A. Auto Buy Semua Peningkatan (Menggunakan Kunci Asli: Luck1, RollSpeed1, MutationLuck1, TreadmillLuck1, GoldenDice1, dll.)
local function RunAutoBuyAllUpgrades()
    if not Remotes.BuyUpgrade then return end
    for _, key in ipairs(DiscoveredData.Upgrades) do
        if not BlacklistedMethodNames[tostring(key)] then
            pcall(function()
                Remotes.BuyUpgrade:InvokeServer(key)
            end)
            task.wait(0.02)
        end
    end
end

-- B. Auto Buy Peningkatan Rebirth
local function RunAutoBuyRebirthUpgrades()
    if not Remotes.UpgradeRebirthStat then return end
    for _, key in ipairs(DiscoveredData.RebirthStats) do
        if not BlacklistedMethodNames[tostring(key)] then
            pcall(function()
                Remotes.UpgradeRebirthStat:InvokeServer(key)
            end)
            task.wait(0.02)
        end
    end
end

-- C. Auto Buy & Equip Dadu Terbaik
local function RunAutoBuyAndEquipDice()
    if Remotes.BuyDice then
        for _, diceKey in ipairs(DiscoveredData.DiceList) do
            if not BlacklistedMethodNames[tostring(diceKey)] then
                pcall(function()
                    Remotes.BuyDice:InvokeServer(diceKey)
                end)
                task.wait(0.02)
            end
        end
    end
    if Remotes.EquipDice then
        for i = #DiscoveredData.DiceList, 1, -1 do
            local diceKey = DiscoveredData.DiceList[i]
            pcall(function() Remotes.EquipDice:InvokeServer(diceKey) end)
        end
    end
end

-- D. Auto Buy Candy Shop & Quest Shop (Bebas Error Function Key)
local function RunAutoBuyEventShops()
    if Config.AutoBuyCandyShop and Remotes.BuyCandyShop then
        -- Pindai juga tombol di UI CandyShop jika sedang dibuka
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            for _, obj in ipairs(pGui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Parent and obj.Parent.Name:lower():find("candy") then
                    local attrId = obj:GetAttribute("Id") or obj:GetAttribute("ItemId") or obj:GetAttribute("ShopId")
                    if attrId then AddUniqueKey(DiscoveredData.CandyShopItems, attrId) end
                    if obj.Name ~= "Template" and not obj.Name:find("UI") then
                        AddUniqueKey(DiscoveredData.CandyShopItems, obj.Name)
                    end
                end
            end
        end

        for _, itemKey in ipairs(DiscoveredData.CandyShopItems) do
            if not BlacklistedMethodNames[tostring(itemKey)] then
                pcall(function()
                    Remotes.BuyCandyShop:InvokeServer(itemKey)
                end)
                task.wait(0.03)
            end
        end
    end

    if Config.AutoBuyQuestShop and Remotes.BuyQuestShop then
        for _, itemKey in ipairs(DiscoveredData.QuestShopItems) do
            if not BlacklistedMethodNames[tostring(itemKey)] then
                pcall(function()
                    Remotes.BuyQuestShop:InvokeServer(itemKey)
                end)
                task.wait(0.03)
            end
        end
    end
end

-- E. Upgrade Podium Sesuai Format Log v6.3: PodiumAction:InvokeServer(slotNum, "Upgrade")
local function UpgradeSinglePodium(podium, allowTeleport)
    if not podium or podium:GetAttribute("Locked") == true then return false end

    local slotNum = tonumber(podium:GetAttribute("Slot")) or tonumber(podium.Name:match("%d+"))
    local screen = podium:FindFirstChild("Screen")
    local screenFace = podium:FindFirstChild("ScreenFace")
    local targetPart = screen or screenFace or podium:FindFirstChild("CollectPad") or podium.PrimaryPart

    local hrp = GetHRP()
    if allowTeleport and hrp and targetPart and targetPart:IsA("BasePart") then
        local dist = (hrp.Position - targetPart.Position).Magnitude
        if dist > 11.5 then
            hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3.2, 0))
            task.wait(0.08)
        end
    end

    -- 1. Panggil PodiumAction dengan format yang terkonfirmasi di Log: (slotNum, "Upgrade") & (slotNum, "UpgradeMax")
    if Remotes.PodiumAction and slotNum then
        pcall(function() Remotes.PodiumAction:InvokeServer(slotNum, "UpgradeMax") end)
        pcall(function() Remotes.PodiumAction:InvokeServer(slotNum, "Upgrade") end)
    end

    -- 2. Trigger ProximityPrompt pada Podium.Screen.PodiumPrompt
    local podiumPromptAtt = screen and screen:FindFirstChild("PodiumPrompt")
    if podiumPromptAtt then
        local upgMax = podiumPromptAtt:FindFirstChild("UpgradeMaxPrompt")
        local upgSingle = podiumPromptAtt:FindFirstChild("ProximityPrompt")
        if upgMax then SafeFirePrompt(upgMax) end
        if upgSingle then SafeFirePrompt(upgSingle) end
    end

    -- 3. Trigger ClickDetector pada Podium.ScreenFace
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
-- 6. SISTEM AUTO MENARA + PILIH STAGE + AUTO TAP UI (v6.6)
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
            if stg and stg > Config.HighestUnlockedStage then
                Config.HighestUnlockedStage = stg
            end
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
                task.spawn(function()
                    pcall(function() Remotes.DeclineRevive:InvokeServer() end)
                end)
            end
        elseif evStr:find("revive") or evStr:find("prompt") or evStr:find("dead") then
            if Config.AutoDeclineRevive and Remotes.DeclineRevive then
                task.spawn(function()
                    pcall(function() Remotes.DeclineRevive:InvokeServer() end)
                end)
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
                local bText = ""
                if guiObj:IsA("TextButton") then
                    bText = (guiObj.Text or ""):lower()
                else
                    local childTxt = guiObj:FindFirstChildWhichIsA("TextLabel", true)
                    if childTxt then bText = (childTxt.Text or ""):lower() end
                end

                local attrStage = guiObj:GetAttribute("Stage") or guiObj:GetAttribute("Floor") or guiObj:GetAttribute("Level")
                local parentStage = guiObj.Parent and (guiObj.Parent:GetAttribute("Stage") or guiObj.Parent:GetAttribute("Floor") or guiObj.Parent.Name)

                local isForbidden = bName:find("robux") or bText:find("robux") or bName:find("leave")
                    or bText:find("leave") or bName:find("exit") or bText:find("keluar")
                    or bName:find("close") or bName:find("cancel")

                if not isForbidden then
                    local isMatchingStageBtn = (tostring(attrStage) == stageStr)
                        or (tostring(parentStage):lower() == "stage" .. stageStr)
                        or (tostring(parentStage) == stageStr)
                        or (bName == stageStr or bName == "stage" .. stageStr or bName == "floor" .. stageStr)
                        or (bText == stageStr or bText == "stage " .. stageStr or bText == "floor " .. stageStr)

                    if isMatchingStageBtn then
                        FireGuiButton(guiObj)
                    end

                    local isActionBtn = bName:find("start") or bName:find("fight") or bName:find("enter")
                        or bName:find("play") or bName:find("battle") or bName:find("retry")
                        or bName:find("next") or bName:find("confirm") or bName:find("decline")
                        or bName:find("dodge") or bName:find("attack")
                        or bText:find("start") or bText:find("fight") or bText:find("enter")
                        or bText:find("mulai") or bText:find("masuk") or bText:find("retry")
                        or bText:find("next") or bText:find("no thanks") or bText:find("decline")

                    if isActionBtn then
                        FireGuiButton(guiObj)
                    end
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

    -- Panggil StartTower HANYA dengan argumen Stage/Angka bersih (tanpa nama function UI!)
    local started = false
    if Remotes.StartTower then
        local ok1, res1 = pcall(function() return Remotes.StartTower:InvokeServer(stageNum) end)
        if ok1 and res1 ~= false then
            started = true
        else
            local ok2, res2 = pcall(function() return Remotes.StartTower:InvokeServer() end)
            if ok2 and res2 ~= false then
                started = true
            else
                local ok3, res3 = pcall(function() return Remotes.StartTower:InvokeServer(tostring(stageNum)) end)
                if ok3 and res3 ~= false then started = true end
            end
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
        if Remotes.ResumeTower then
            pcall(function() Remotes.ResumeTower:InvokeServer() end)
        end
        if tick() - TowerRuntime.LastStartAttempt > 20 then
            TowerRuntime.InTower = false
        else
            return
        end
    end

    EnterTowerAtStage(targetStage)
end

-- ============================================================================
-- 7. SISTEM UI ROCKSTAR HUB v6.6 (CYBER-BLUE EDITION)
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

-- Tombol Mengambang Bulat (R★)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "RockstarToggleBtn"
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(0, 20, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(10, 18, 32)
FloatBtn.Text = "R★"
FloatBtn.TextColor3 = Color3.fromRGB(0, 215, 255)
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 20
FloatBtn.AutoButtonColor = true
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 195, 255)
FloatStroke.Thickness = 2.2
FloatStroke.Parent = FloatBtn

-- Jendela Utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 610, 0, 415)
MainFrame.Position = UDim2.new(0.5, -305, 0.5, -207)
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

-- Header Bar
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
TitleLbl.Text = "★ ROCKSTAR HUB v6.6  |  [🎃] Putar Hewan Peliharaan"
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
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            guiObj.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

EnableDrag(MainFrame)
EnableDrag(FloatBtn)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

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
        if toast and toast.Parent then
            toast:Destroy()
        end
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
        btn.TextColor3 = Color3.
