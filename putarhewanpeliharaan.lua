-- ============================================================================
-- ★ ROCKSTAR HUB v7.5 - [🎃] PUTAR HEWAN PELIHARAAN (CYBER-BLUE EDITION) ★
-- Game: [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299 | PlaceVersion: 1264)
-- Update v7.5 (AUDIT TUNTAS: ANTI DADU GANTI-GANTI SENDIRI & UNIVERSAL DICE SHOP):
--   [✓] Solusi Mutlak Dadu Ganti-Ganti Sendiri: Hentikan loop Equip 1 detik & pasang verifikasi [Equipped]
--   [✓] Stop Total jika Dadu Terbaik Sudah Dipasang (Zero Click, Zero Remote spam)
--   [✓] Proteksi Kunci Manual 5 Detik saat pemain klik manual (Anti overwrite)
--   [✓] Integrasi Dadu Mythical & Divine: Solar (10Mx), Lunar (40Mx), Galaxy (100Mx+ Divine)
--   [✓] Parsing Presisi Kartu UI: Hanya scan anak langsung container list, cegah tumpang tindih nama/tombol
--   [✓] Filter Kepemilikan Ketat: DILARANG KERAS mencoba pasang dadu yang belum terkonfirmasi dimiliki
--   [✓] Pemisahan Thread Auto-Equip ke polling tenang (4 detik) agar tidak bentrok dengan BuyDice
--   [✓] Fix Total UI Crash: Header.Parent = MainFrame (Hilangkan Blank Hitam)
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

    -- Sistem Dadu v7.5 (Anti-Switch & True Luck Edition)
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
    TraitTargetMode = "BestOnly",
    AutoRollGrade = false,
    GradeTargetMode = "BestOnly",
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

    -- Event & Utility
    AutoSpinWheel = false,
    AutoClaimRewards = false,
    AutoClaimCandy = false,
    AutoTeleportCandy = false,
    InstantPrompt = true,
    AntiAFK = true,
}

-- State Internal & Tracking
local State = {
    CurrentDiceName = "Mendeteksi...",
    CurrentDiceLuck = 1,
    LastEquippedDiceId = nil,
    FailedEquipCount = 0,
    ManualOverrideUntil = 0,
    LearnedDiceArgs = {},
    LearnedUpgradeArgs = {},
    TowerUnderway = false,
    CurrentTowerFloor = 1,
    PlayerPlotModel = nil,
    LogBuffer = {},
    LogMaxLines = 8,
}

-- Cache Remote Game
local Remotes = {}
local function CacheRemotes()
    local rf = ReplicatedStorage:FindFirstChild("RemoteFunctions") or ReplicatedStorage:FindFirstChild("Remotes")
    local re = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:FindFirstChild("Remotes")
    
    if rf then
        Remotes.Roll = rf:FindFirstChild("Roll") or rf:FindFirstChild("RollPet")
        Remotes.BuyUpgrade = rf:FindFirstChild("BuyUpgrade")
        Remotes.BuyRebirthUpgrade = rf:FindFirstChild("BuyRebirthUpgrade")
        Remotes.EquipDice = rf:FindFirstChild("EquipDice") or rf:FindFirstChild("SetDice")
        Remotes.BuyDice = rf:FindFirstChild("BuyDice")
        Remotes.RerollTrait = rf:FindFirstChild("RerollTrait") or rf:FindFirstChild("RollTrait")
        Remotes.RollGrade = rf:FindFirstChild("RollGrade") or rf:FindFirstChild("RerollGrade")
        Remotes.EquipBest = rf:FindFirstChild("EquipBest") or rf:FindFirstChild("EquipBestPets")
        Remotes.FusePets = rf:FindFirstChild("FusePets") or rf:FindFirstChild("FuseAll")
        Remotes.SellPet = rf:FindFirstChild("SellPet")
        Remotes.Rebirth = rf:FindFirstChild("Rebirth")
        Remotes.SpinWheel = rf:FindFirstChild("SpinWheel")
        Remotes.ClaimPlaytime = rf:FindFirstChild("ClaimPlaytimeReward")
        Remotes.ClaimQuest = rf:FindFirstChild("ClaimQuestReward")
        Remotes.ClaimStarterQuest = rf:FindFirstChild("ClaimStarterQuestReward")
        Remotes.ClaimDaily = rf:FindFirstChild("ClaimDailyReward")
        Remotes.ClaimGroupChest = rf:FindFirstChild("ClaimGroupChest")
        Remotes.ClaimFriendChest = rf:FindFirstChild("ClaimFriendChest")
        Remotes.ClaimFreePet = rf:FindFirstChild("ClaimFreePet")
        Remotes.ClaimAllAchievements = rf:FindFirstChild("ClaimAllAchievements")
        Remotes.WatchSkipAd = rf:FindFirstChild("WatchSkipAd")
        Remotes.TowerAttack = rf:FindFirstChild("TowerTap") or rf:FindFirstChild("TowerAttack")
        Remotes.ReviveResponse = rf:FindFirstChild("TowerReviveResponse") or rf:FindFirstChild("DeclineRevive")
        Remotes.CandyShopBuy = rf:FindFirstChild("BuyCandyShop") or rf:FindFirstChild("CandyShopBuy")
        Remotes.QuestShopBuy = rf:FindFirstChild("BuyQuestShop") or rf:FindFirstChild("QuestShopBuy")
    end

    if re then
        Remotes.CollectCash = re:FindFirstChild("CollectCash") or re:FindFirstChild("PickupCash")
        Remotes.PickupCandy = re:FindFirstChild("PickupCandy") or re:FindFirstChild("CollectCandy")
        Remotes.TowerEvent = re:FindFirstChild("TowerEvent") or re:FindFirstChild("TowerState")
    end
end
CacheRemotes()

-- Logger Ringan
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
-- 2. TIER MULTIPLIER & ENSIKLOPEDIA DADU UNIVERSAL
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
    { Name = "Amethyst", Aliases = {"Kecubung", "Amethyst"}, Luck = 100.0, Tier = "Legendary" },
    { Name = "Obsidian", Aliases = {"Obsidian"}, Luck = 250.0, Tier = "Legendary" },
    { Name = "Plasma", Aliases = {"Plasma"}, Luck = 750.0, Tier = "Legendary" },
    { Name = "Void", Aliases = {"Kekosongan", "Void"}, Luck = 1500.0, Tier = "Legendary" },
    { Name = "Solar", Aliases = {"Solar", "Matahari"}, Luck = 10000000.0, Tier = "Mythical" },
    { Name = "Lunar", Aliases = {"Lunar", "Bulan"}, Luck = 40000000.0, Tier = "Mythical" },
    { Name = "Galaxy", Aliases = {"Galaxy", "Galaksi"}, Luck = 100000000.0, Tier = "Divine" },
    { Name = "Infinity", Aliases = {"Infinity", "Tak Terbatas"}, Luck = 500000000.0, Tier = "Infinity" },
}

-- Parsing angka string (contoh: "10M", "40Mx", "250K", "1.5x")
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

-- Evaluasi Luck Dadu dari Judul dan Tier
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
-- 3. SCANNING DICE SHOP GUI DENGAN METODE PRESISI (ANTI TUMPANG TINDIH)
-- ============================================================================
local function GetDiceCardsFromGui()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return {} end

    local targetContainers = {}
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (string.find(string.lower(gui.Name), "dice") or string.find(string.lower(gui.Name), "shop") or gui:FindFirstChild("MainFrame", true)) then
            for _, desc in ipairs(gui:GetDescendants()) do
                if (desc:IsA("ScrollingFrame") or desc:IsA("Frame")) and desc:FindFirstChildOfClass("UIListLayout") then
                    table.insert(targetContainers, desc)
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
                        
                        if string.find(txt, "equipped") or string.find(txt, "terpasang") or string.find(txt, "dipakai") then
                            isEquipped = true
                            isOwned = true
                        elseif string.find(txt, "equip") or string.find(txt, "pasang") or string.find(txt, "pakai") then
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
                            if string.find(txt, "🍀") or string.find(txt, "luck") or string.find(txt, "x") then
                                luckLabel = el.Text
                            end
                            for tierName, _ in pairs(TierMultiplier) do
                                if string.find(txt, string.lower(tierName)) then
                                    tierLabel = el.Text
                                    break
                                end
                            end
                            if not titleLabel and el.Text ~= "" and not string.find(txt, "luck") and not string.find(txt, "buy") and not string.find(txt, "equip") then
                                titleLabel = el.Text
                            end
                        end
                    end
                end

                if titleLabel then
                    local cleanName = string.match(titleLabel, "([^|%-\n]+)") or titleLabel
                    cleanName = string.gsub(cleanName, "%s+$", "")
                    cleanName = string.gsub(cleanName, "^%s+", "")

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
-- 4. LOGIKA PEMASANGAN DADU (ZERO FLICKERING & ZERO SPAM)
-- ============================================================================
local IsScriptCallingEquip = false

local function EquipTargetDiceNow(force)
    if tick() < State.ManualOverrideUntil then
        return
    end

    if not Config.AutoEquipDice and not force then
        return
    end

    local cards = GetDiceCardsFromGui()
    if #cards == 0 then
        return
    end

    local targetCard = nil

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
                if not (Config.SkipVoidDice and string.lower(card.Name) == "void" and highestLuck > 1500) then
                    if card.Luck > highestLuck then
                        highestLuck = card.Luck
                        targetCard = card
                    end
                end
            end
        end
    end

    if not targetCard then
        return
    end

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
            for _, conn in ipairs(getconnections(targetCard.EquipButton.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(targetCard.EquipButton.Activated)) do
                conn:Fire()
            end
        end)
        
        task.delay(0.5, function()
            IsScriptCallingEquip = false
        end)

        Log("Memasang Dadu: " .. targetCard.Name .. " (🍀 " .. targetCard.Luck .. "x)")
        State.LastEquippedDiceId = targetCard.Name
        State.FailedEquipCount = State.FailedEquipCount + 1
        return
    end

    if Remotes.EquipDice then
        IsScriptCallingEquip = true
        pcall(function()
            local arg = State.LearnedDiceArgs[targetCard.Name] or targetCard.Name
            Remotes.EquipDice:InvokeServer(arg)
        end)
        task.delay(0.5, function()
            IsScriptCallingEquip = false
        end)

        Log("Remote Equip: " .. targetCard.Name)
        State.LastEquippedDiceId = targetCard.Name
        State.FailedEquipCount = State.FailedEquipCount + 1
    end
end

-- ============================================================================
-- 5. DETEKSI KLIK MANUAL PEMAIN & HOOK PENGAMAN
-- ============================================================================
pcall(function()
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if (method == "InvokeServer" or method == "FireServer") and self then
            if Remotes.EquipDice and self == Remotes.EquipDice then
                if not IsScriptCallingEquip then
                    local diceArg = args[1]
                    if diceArg and type(diceArg) == "string" then
                        State.ManualOverrideUntil = tick() + 5
                        Config.DiceMode = "Manual"
                        Config.LockedDiceId = diceArg
                        Log("Pemain Memasang Dadu Manual: " .. tostring(diceArg) .. " (Terkunci 5 Detik)")
                    end
                end
            elseif Remotes.BuyUpgrade and self == Remotes.BuyUpgrade then
                if #args >= 1 and type(args[1]) == "string" then
                    State.LearnedUpgradeArgs[args[1]] = args
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(gmt, true)
end)

-- ============================================================================
-- 6. SISTEM UPGRADE PODIUM, TRAIT, GRADE & SHOP
-- ============================================================================
local function GetPlayerPlot()
    if State.PlayerPlotModel and State.PlayerPlotModel.Parent then
        return State.PlayerPlotModel
    end

    local plots = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("PlotsFolder")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("OwnerName")
            if owner and (owner.Value == LocalPlayer or owner.Value == LocalPlayer.Name) then
                State.PlayerPlotModel = plot
                return plot
            end
            local sign = plot:FindFirstChild("Sign", true)
            if sign and sign:IsA("TextLabel") and string.find(string.lower(sign.Text), string.lower(LocalPlayer.Name)) then
                State.PlayerPlotModel = plot
                return plot
            end
        end
    end
    return nil
end

local function UpgradeAllPlotPodiums()
    local plot = GetPlayerPlot()
    if not plot then return end

    local podiumsFolder = plot:FindFirstChild("Podiums") or plot:FindFirstChild("Stands") or plot
    for i = 1, 16 do
        local podium = podiumsFolder:FindFirstChild("Podium" .. i) or podiumsFolder:FindFirstChild("Stand" .. i)
        if podium then
            local prompt = podium:FindFirstChildOfClass("ProximityPrompt") or podium:FindFirstChild("UpgradePrompt", true)
            if prompt then
                if Config.AutoTeleportUpgrade then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = podium:GetPivot() + Vector3.new(0, 3, 0)
                        task.wait(0.08)
                    end
                end
                fireproximityprompt(prompt)
            end
        end
    end
end

-- ============================================================================
-- 7. BACKGROUND LOOPS OTOMATISASI LENGKAP
-- ============================================================================

-- Loop 1: Auto Roll Pet
task.spawn(function()
    while true do
        if Config.AutoRoll and Remotes.Roll then
            pcall(function()
                Remotes.Roll:InvokeServer()
            end)
            if Config.AutoEquipBest and Remotes.EquipBest then
                pcall(function() Remotes.EquipBest:InvokeServer() end)
            end
            if Config.AutoFuse and Remotes.FusePets then
                pcall(function() Remotes.FusePets:InvokeServer() end)
            end
            task.wait(Config.RollDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- Loop 2: Auto Collect Cash, Treadmill & Auto Collect Upgrade
task.spawn(function()
    while true do
        if Config.AutoCollectCash then
            local plot = GetPlayerPlot()
            if plot then
                for _, desc in ipairs(plot:GetDescendants()) do
                    if desc:IsA("TouchTransmitter") or desc.Name == "CashDrop" or desc.Name == "Coin" then
                        local part = desc:IsA("BasePart") and desc or desc.Parent
                        local char = LocalPlayer.Character
                        if part and char and char:FindFirstChild("HumanoidRootPart") then
                            firetouchinterest(char.HumanoidRootPart, part, 0)
                            firetouchinterest(char.HumanoidRootPart, part, 1)
                        end
                    end
                end
            end
            if Remotes.CollectCash then
                pcall(function() Remotes.CollectCash:FireServer() end)
            end
        end

        if Config.AutoTreadmill then
            local plot = GetPlayerPlot()
            local treadmill = plot and (plot:FindFirstChild("Treadmill", true) or plot:FindFirstChild("TreadmillZone", true))
            if treadmill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local tPart = treadmill:IsA("BasePart") and treadmill or treadmill:FindFirstChildOfClass("BasePart")
                if tPart then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, tPart, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, tPart, 1)
                end
            end
        end

        task.wait(0.4)
    end
end)

-- Loop 3: Auto Beli Dadu Toko (TANPA GANTI DADU PEMAIN)
task.spawn(function()
    while true do
        if Config.AutoBuyDiceOnly then
            local cards = GetDiceCardsFromGui()
            for _, card in ipairs(cards) do
                if card.Status == "unowned" and card.BuyButton then
                    pcall(function()
                        for _, conn in ipairs(getconnections(card.BuyButton.MouseButton1Click)) do
                            conn:Fire()
                        end
                    end)
                    task.wait(0.2)
                end
            end
        end
        task.wait(1.5)
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

-- Loop 5: Auto Peningkatan Podium & Shop
task.spawn(function()
    while true do
        if Config.AutoUpgradePodium then
            UpgradeAllPlotPodiums()
        end

        if Config.AutoBuyAllUpgrades and Remotes.BuyUpgrade then
            for upgradeName, argTbl in pairs(State.LearnedUpgradeArgs) do
                pcall(function()
                    Remotes.BuyUpgrade:InvokeServer(unpack(argTbl))
                end)
            end
        end

        if Config.AutoBuyRebirthUpgrades and Remotes.BuyRebirthUpgrade then
            for i = 1, 10 do
                pcall(function() Remotes.BuyRebirthUpgrade:InvokeServer(i) end)
            end
        end

        if Config.AutoBuyCandyShop and Remotes.CandyShopBuy then
            for i = 1, 8 do
                pcall(function() Remotes.CandyShopBuy:InvokeServer(i) end)
            end
        end

        if Config.AutoBuyQuestShop and Remotes.QuestShopBuy then
            for i = 1, 8 do
                pcall(function() Remotes.QuestShopBuy:InvokeServer(i) end)
            end
        end

        task.wait(1.0)
    end
end)

-- Loop 6: Auto Menara Pertarungan
task.spawn(function()
    while true do
        if Config.AutoTower then
            if Config.AutoTeleportToTowerPad then
                local pad = Workspace:FindFirstChild("TowerPad", true) or Workspace:FindFirstChild("TowerEntrance", true)
                local char = LocalPlayer.Character
                if pad and char and char:FindFirstChild("HumanoidRootPart") then
                    local pPart = pad:IsA("BasePart") and pad or pad:FindFirstChildOfClass("BasePart")
                    if pPart and (char.HumanoidRootPart.Position - pPart.Position).Magnitude > 25 then
                        char.HumanoidRootPart.CFrame = pPart.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.5)
                    end
                end
            end

            if Config.AutoTapTowerCombat and Remotes.TowerAttack then
                pcall(function()
                    Remotes.TowerAttack:InvokeServer()
                end)
            end

            if Config.AutoDeclineRevive and Remotes.ReviveResponse then
                pcall(function()
                    Remotes.ReviveResponse:InvokeServer(false)
                end)
            end
            task.wait(0.12)
        else
            task.wait(1.0)
        end
    end
end)

-- Loop 7: Event, Hadiah, Candy & Utilitas
task.spawn(function()
    while true do
        if Config.AutoClaimCandy then
            local candies = Workspace:FindFirstChild("Candies") or Workspace:FindFirstChild("HalloweenCandy")
            if candies then
                for _, candy in ipairs(candies:GetChildren()) do
                    if candy:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        if Config.AutoTeleportCandy then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = candy.CFrame
                            task.wait(0.08)
                        else
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, candy, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, candy, 1)
                        end
                    end
                end
            end
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
-- 8. USER INTERFACE (CYBER-BLUE EDITION // ROCKSTAR HUB v7.5)
-- ============================================================================
local TweenService = game:GetService("TweenService")

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
ScreenGui.Name = "RockstarHub_PutarHewan_v7_5"
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

-- Draggable MainFrame (PC & Mobile / Touch Support)
local draggingMF, dragStartMF, startPosMF
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - MainFrame.AbsolutePosition.Y <= 40 then
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

-- Top Header Bar (100% FIXED: Parent ke MainFrame)
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
VersionBadge.Size = UDim2.new(0, 80, 0, 20)
VersionBadge.Position = UDim2.new(0, 340, 0.5, -10)
VersionBadge.BackgroundColor3 = Theme.Card
VersionBadge.Text = "v7.5 CYBER"
VersionBadge.TextColor3 = Theme.Accent
VersionBadge.Font = Enum.Font.GothamBold
VersionBadge.TextSize = 10
VersionBadge.Parent = Header

local VBCorner = Instance.new("UICorner")
VBCorner.CornerRadius = UDim.new(0, 4)
VBCorner.Parent = VersionBadge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextSub
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 6)
CBCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Sidebar Tabs
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarStroke = Instance.new("Frame")
SidebarStroke.Size = UDim2.new(0, 1, 1, 0)
SidebarStroke.Position = UDim2.new(1, -1, 0, 0)
SidebarStroke.BackgroundColor3 = Theme.Border
SidebarStroke.BorderSizePixel = 0
SidebarStroke.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 6)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -155, 1, -42)
ContentContainer.Position = UDim2.new(0, 155, 0, 42)
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
        else
            btn.BackgroundColor3 = Color3.fromRGB(16, 22, 34)
            btn.TextColor3 = Theme.TextSub
        end
    end
end

for idx, tab in ipairs(TabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 138, 0, 36)
    btn.BackgroundColor3 = (idx == 1) and Theme.Card or Color3.fromRGB(16, 22, 34)
    btn.Text = tab.Name
    btn.TextColor3 = (idx == 1) and Theme.Accent or Theme.TextSub
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.LayoutOrder = idx
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

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
        if callback then callback(Config[configKey]) end
    end)

    return row
end

-- ============================================================================
-- 9. ISI TAB UI
-- ============================================================================

-- TAB 1: PUTAR & PET
local p1Card = CreateCard(TabFrames["Roll"], "Otomatisasi Putar Hewan")
CreateToggle(p1Card, "Auto Putar (Auto Roll)", "Putar gacha hewan peliharaan otomatis", "AutoRoll")
CreateToggle(p1Card, "Auto Pasang Hewan Terbaik", "Pasang otomatis pet dengan bonus tertinggi", "AutoEquipBest")
CreateToggle(p1Card, "Auto Gabung Hewan (Fuse)", "Gabungkan pet duplikat untuk menaikkan tier", "AutoFuse")

local p1PlotCard = CreateCard(TabFrames["Roll"], "Otomatisasi Plot & Pendapatan")
CreateToggle(p1PlotCard, "Auto Ambil Uang Plot", "Ambil tumpukan uang kas plot tanpa jalan kaki", "AutoCollectCash")
CreateToggle(p1PlotCard, "Auto Treadmill", "Berlari di treadmill plot untuk menaikkan speed", "AutoTreadmill")

-- TAB 2: TOKO DADU v7.5
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
    DiceStatusLabel.Text = "Dadu Aktif: Tidak ada info di GUI"
end

local ModeSwitchBtn = Instance.new("TextButton")
ModeSwitchBtn.Size = UDim2.new(1, 0, 0, 32)
ModeSwitchBtn.BackgroundColor3 = Color3.fromRGB(24, 38, 62)
ModeSwitchBtn.Text = "Mode Dadu: " .. (Config.DiceMode == "AutoBest" and "🌟 Auto-Best Luck" or "🔒 Kunci Manual")
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

CreateToggle(p2Card, "Auto Pasang Dadu (Auto-Equip)", "Pasang dadu sesuai mode (Auto-Best / Manual)", "AutoEquipDice")
CreateToggle(p2Card, "Abaikan Dadu Kekosongan (Void)", "Cegah pakai dadu Void jika memiliki Solar/Lunar/Galaxy", "SkipVoidDice")
CreateToggle(p2Card, "Hanya Beli Stok Dadu (Tanpa Ganti)", "Beli stok dadu tanpa mengganggu dadu di tangan", "AutoBuyDiceOnly")

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

-- TAB 3: PENINGKATAN, TRAIT & REBIRTH
local p3Card = CreateCard(TabFrames["Upgrade"], "Peningkatan Podium Plot")
CreateToggle(p3Card, "Auto Tingkatkan 16 Podium", "Tingkatkan podium plot secara berurutan", "AutoUpgradePodium")
CreateToggle(p3Card, "Teleport ke Podium saat Upgrade", "Mendekat otomatis ke podium saat ditingkatkan", "AutoTeleportUpgrade")
CreateToggle(p3Card, "Auto Beli Semua Peningkatan", "Beli upgrade general yang telah dipelajari", "AutoBuyAllUpgrades")
CreateToggle(p3Card, "Auto Beli Peningkatan Rebirth", "Beli peningkatan toko rebirth otomatis", "AutoBuyRebirthUpgrades")
CreateToggle(p3Card, "Auto Rebirth", "Lakukan Rebirth otomatis saat persyaratan terpenuhi", "AutoRebirth")

-- TAB 4: MENARA PERTARUNGAN & PILIH STAGE
local p4Card = CreateCard(TabFrames["Tower"], "Pengaturan Menara Pertarungan")
local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1, 0, 0, 18)
StageLabel.BackgroundTransparency = 1
StageLabel.Text = "Stage Terpilih: " .. Config.SelectedStage
StageLabel.TextColor3 = Theme.TextMain
StageLabel.Font = Enum.Font.GothamMedium
StageLabel.TextSize = 12
StageLabel.TextXAlignment = Enum.TextXAlignment.Left
StageLabel.Parent = p4Card

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

local function UpdateStageLabel()
    StageLabel.Text = "Stage Terpilih: " .. Config.SelectedStage .. " (Mode: " .. Config.TowerStageMode .. ")"
end

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

CreateToggle(p4Card, "Auto Masuk & Selesaikan Menara", "Masuk ke menara dan jalankan auto combat", "AutoTower")
CreateToggle(p4Card, "Auto Ketuk Serangan Cepat", "Kirim serangan cepat terus-menerus ke musuh menara", "AutoTapTowerCombat")
CreateToggle(p4Card, "Tolak Tawaran Revive Robux", "Tolak jendela popup revive otomatis agar tidak macet", "AutoDeclineRevive")

-- TAB 5: HALLOWEEN EVENT & HADIAH
local p5Card = CreateCard(TabFrames["Event"], "Event Halloween 2026")
CreateToggle(p5Card, "Auto Ambil Permen Halloween", "Kumpulkan permen labu yang tersebar di map", "AutoClaimCandy")
CreateToggle(p5Card, "Teleport ke Titik Permen", "Pindah langsung ke lokasi permen terdekat", "AutoTeleportCandy")
CreateToggle(p5Card, "Auto Beli Toko Permen", "Tukarkan permen di Toko Candy Shop otomatis", "AutoBuyCandyShop")

local p5RewardCard = CreateCard(TabFrames["Event"], "Hadiah Gratis & Putar Roda")
CreateToggle(p5RewardCard, "Auto Putar Roda Keberuntungan", "Putar Wheel of Fortune setiap putaran gratis siap", "AutoSpinWheel")
CreateToggle(p5RewardCard, "Auto Klaim Semua Hadiah", "Klaim Daily, Peti Teman, Grup, Quest & Waktu Bermain", "AutoClaimRewards")

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

-- Refresh berkala
task.spawn(function()
    while true do
        pcall(RefreshLogDisplay)
        pcall(UpdateDiceDisplay)
        task.wait(2.0)
    end
end)

print("★ ROCKSTAR HUB v7.5 - [🎃] PUTAR HEWAN PELIHARAAN BERHASIL DIMUAT LENGKAP! ★")
