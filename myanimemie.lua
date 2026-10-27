-- ============================================================================
-- * ROCKSTAR HUB - MY ANIME MINE AUTO-FARMING SCRIPT v2.0 *
-- Game: My Anime Mine / MineWorld
-- PlaceId: 72858262610964 | GameId: 10629695169
-- Fitur Lengkap (v2.0):
--   [1] Auto Mine (Fast Remote Hit + Pet Mine + Multi-Target Engine)
--   [2] Remote Autonomous Mode (Mining Jarak Jauh Tanpa Perlu Jalan Manual)
--   [3] Auto Beli Kapak Otomatis (Pickaxe Shop Remote + Proximity Prompt)
--   [4] Auto Pakai Best Anime / Pet (PetService Remote + UI Auto-Equip)
--   [5] Auto Upgrade Stats (UpgradeService + PhysicalUpgrade Remote Engine)
--   [6] Auto Rebirth (RebirthService Remote Auto-Trigger)
--   [7] Auto Collect Loot Magnet (Instant Drops Collector ke Tas)
--   [8] Auto Sell Otomatis (RF.Sell Remote + SellStand Prompt)
--   [9] Auto Lucky Block (Unreal Block Prompt Interactor)
--   [10] Waypoints Teleport (Plot, Toko Beli Kapak, Sell, Summon, Enchant, Hub)
--   [11] Anti-AFK 24 Jam (Zero Disconnect Universal)
--   [12] 100% Universal Delta Executor Compatible (PC & Android)
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Helper pack function universal
local function pack_fn(...)
    return { n = select("#", ...), ... }
end

-- ============================================================================
-- 1. KONFIGURASI BOT
-- ============================================================================
local Config = {
    -- Mining & Autonomous
    AutoMine = true,
    RemoteOnlyMining = true,            -- True = Mining jarak jauh tanpa perlu jalan kaki
    MineRarityFilter = "All",           -- "All", "Legendary", "Epic", "Rare", "Uncommon"
    AutoCollectLoot = true,
    
    -- Toko & Inventori
    AutoBuyPickaxe = true,             -- Otomatis beli kapak terkuat/baru
    BuyPickaxeInterval = 5,             -- Detik antar cek beli kapak
    AutoEquipBestAnime = true,          -- Otomatis pakai tim anime/pet terkuat
    EquipBestInterval = 8,              -- Detik antar equip best
    
    -- Upgrade & Rebirth
    AutoUpgrade = true,                 -- Otomatis upgrade stats (Pickaxe, Speed, Luck, Bag)
    UpgradeInterval = 4,                -- Detik antar cek upgrade
    AutoRebirth = false,                -- Otomatis rebirth jika syarat terpenuhi
    RebirthInterval = 15,               -- Detik
    
    -- Jual & Event
    AutoSell = true,
    AutoSellInterval = 15,              -- Detik
    AutoLuckyBlock = true,
    
    -- Navigasi & Karakter
    TweenSpeed = 50,                    -- Studs per detik jika teleport halus
    AntiAfk = true,
    WalkSpeed = 24,
    JumpPower = 50,
}

local State = {
    MyPlot = nil,
    CurrentTargetNode = nil,
    TotalMined = 0,
    TotalSold = 0,
    TotalPickaxesBought = 0,
    TotalUpgrades = 0,
    TotalRebirths = 0,
    IsTweening = false,
    Logs = {},
}

local function Log(msg)
    local timestamp = os.date("%H:%M:%S")
    local fullMsg = "[" .. timestamp .. "] " .. tostring(msg)
    table.insert(State.Logs, 1, fullMsg)
    if #State.Logs > 40 then
        table.remove(State.Logs)
    end
    print("[ROCKSTAR MINE v2]: " .. fullMsg)
end

-- Anti AFK Universal
if Config.AntiAfk then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            Log("Anti-AFK: Menghindari idle disconnect.")
        end)
    end)
end

-- ============================================================================
-- 2. RESOLVER REMOTE SERVICES & GAME REMOTES
-- ============================================================================
local Remotes = {
    -- Mining
    Hit = nil,
    CollectDrop = nil,
    Sell = nil,
    Enter = nil,
    Leave = nil,
    Surface = nil,
    PetMine = nil,
    MineReward = nil,
    MineReset = nil,
    MineNotice = nil,
    MiningPurchase = nil,
    MiningDailyBuy = nil,
    
    -- Pets / Anime
    PetActionRequested = nil,
    PetActionResult = nil,
    EquipPetTeam = nil,
    SharedEquipBestPets = nil,
    SharedEquipBestTeam = nil,
    
    -- Upgrades
    UpgradePurchase = nil,
    PhysicalUpgradePurchase = nil,
    SharedBuyUpgrade = nil,
    SharedUpgradeRebirthStat = nil,
    
    -- Rebirth
    RebirthRequested = nil,
    SharedRebirth = nil,
    
    -- Shrine & Enchant
    ShrineChoose = nil,
    EnchantRemote = nil,
}

local function GetRemote(path)
    local parts = string.split(path, ".")
    local curr = game
    for _, part in ipairs(parts) do
        curr = curr:FindFirstChild(part)
        if not curr then return nil end
    end
    return curr
end

-- Resolve Mining Remotes
Remotes.Hit = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Hit")
Remotes.CollectDrop = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.CollectDrop")
Remotes.Sell = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Sell")
Remotes.Enter = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Enter")
Remotes.Leave = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Leave")
Remotes.Surface = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Surface")
Remotes.PetMine = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.PetMine")
Remotes.MineReward = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.MineReward")
Remotes.MineReset = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.MineReset")
Remotes.MineNotice = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.MineNotice")
Remotes.MiningPurchase = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Purchase")
Remotes.MiningDailyBuy = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.DailyBuy")

-- Resolve Pet / Anime Remotes
Remotes.PetActionRequested = GetRemote("ReplicatedStorage.RemoteServices.PetService.RE.PetActionRequested")
Remotes.PetActionResult = GetRemote("ReplicatedStorage.RemoteServices.PetService.RE.PetActionResult")
Remotes.EquipPetTeam = GetRemote("ReplicatedStorage.RemoteServices.PetService.RF.EquipPetTeam")
Remotes.SharedEquipBestPets = GetRemote("ReplicatedStorage.Shared.Remotes.EquipBestPets")
Remotes.SharedEquipBestTeam = GetRemote("ReplicatedStorage.Shared.Remotes.EquipBestTeam")

-- Resolve Upgrade Remotes
Remotes.UpgradePurchase = GetRemote("ReplicatedStorage.RemoteServices.UpgradeService.RF.Purchase")
Remotes.PhysicalUpgradePurchase = GetRemote("ReplicatedStorage.RemoteServices.PhysicalUpgradeService.RF.Purchase")
Remotes.SharedBuyUpgrade = GetRemote("ReplicatedStorage.Shared.Remotes.BuyUpgrade")
Remotes.SharedUpgradeRebirthStat = GetRemote("ReplicatedStorage.Shared.Remotes.UpgradeRebirthStat")

-- Resolve Rebirth Remotes
Remotes.RebirthRequested = GetRemote("ReplicatedStorage.RemoteServices.RebirthService.RE.RebirthRequested")
Remotes.SharedRebirth = GetRemote("ReplicatedStorage.Shared.Remotes.Rebirth")

-- Resolve Shrine & Enchant
Remotes.ShrineChoose = GetRemote("ReplicatedStorage.RemoteServices.ShrineService.RF.Choose")
Remotes.EnchantRemote = GetRemote("ReplicatedStorage.RemoteServices.EnchantService.RF.Enchant")

if Remotes.Hit then Log("Remote Hit terhubung OK.") end
if Remotes.CollectDrop then Log("Remote CollectDrop terhubung OK.") end
if Remotes.Sell then Log("Remote Sell terhubung OK.") end
if Remotes.MiningPurchase then Log("Remote Beli Kapak (MiningPurchase) terhubung OK.") end
if Remotes.PetActionRequested or Remotes.SharedEquipBestPets then Log("Remote Equip Best Anime terhubung OK.") end
if Remotes.UpgradePurchase or Remotes.PhysicalUpgradePurchase then Log("Remote Upgrades terhubung OK.") end

-- ============================================================================
-- 3. DETEKSI PLOT MILIK SENDIRI
-- ============================================================================
local function FindMyPlot()
    local myUserId = LocalPlayer.UserId
    local plotsFolder = workspace:FindFirstChild("MineWorld") and workspace.MineWorld:FindFirstChild("Plots")
    if not plotsFolder then
        plotsFolder = workspace:FindFirstChild("Plots")
    end
    if not plotsFolder then return nil end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local owner = plot:GetAttribute("OwnerUserId") or plot:GetAttribute("Owner")
        if owner and tonumber(owner) == myUserId then
            State.MyPlot = plot
            return plot
        end
    end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local bill = plot:FindFirstChild("OwnerBillboardPart")
        if bill then
            local textLbl = bill:FindFirstChildWhichIsA("TextLabel", true)
            if textLbl and string.find(string.lower(textLbl.Text), string.lower(LocalPlayer.Name), 1, true) then
                State.MyPlot = plot
                return plot
            end
        end
    end

    return State.MyPlot
end

-- ============================================================================
-- 4. NAVIGASI KARAKTER (SAFE TELEPORT & TWEEN)
-- ============================================================================
local function GetRootPart()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function SafeTeleport(targetPos)
    local root = GetRootPart()
    if not root then return false end
    root.CFrame = CFrame.new(targetPos)
    return true
end

-- ============================================================================
-- 5. PENCARI ORE NODE & REMOTE MINING ENGINE
-- ============================================================================
local RarityWeights = {
    ["Legendary"] = 5,
    ["Epic"] = 4,
    ["Rare"] = 3,
    ["Uncommon"] = 2,
    ["Common"] = 1,
}

local function GetAvailableNodes()
    local plot = State.MyPlot or FindMyPlot()
    local nodes = {}

    local function CollectFromFolder(f)
        if not f then return end
        for _, obj in ipairs(f:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local oreName = obj:GetAttribute("OreName") or obj.Name
                local oreRarity = obj:GetAttribute("OreRarity") or "Common"
                local pos = nil
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    pos = obj:GetPivot().Position
                end

                if pos then
                    local weight = RarityWeights[oreRarity] or 1
                    table.insert(nodes, {
                        Instance = obj,
                        Name = oreName,
                        Rarity = oreRarity,
                        Weight = weight,
                        Position = pos,
                    })
                end
            end
        end
    end

    if plot and plot:FindFirstChild("Nodes") then
        CollectFromFolder(plot.Nodes)
    end

    if #nodes == 0 and workspace:FindFirstChild("MineWorld") then
        for _, desc in ipairs(workspace.MineWorld:GetDescendants()) do
            if desc:GetAttribute("OreName") then
                local pos = nil
                if desc:IsA("BasePart") then
                    pos = desc.Position
                elseif desc:IsA("Model") then
                    pos = desc:GetPivot().Position
                end
                if pos then
                    local r = desc:GetAttribute("OreRarity") or "Common"
                    table.insert(nodes, {
                        Instance = desc,
                        Name = desc:GetAttribute("OreName"),
                        Rarity = r,
                        Weight = RarityWeights[r] or 1,
                        Position = pos,
                    })
                end
            end
        end
    end

    return nodes
end

local function PickBestNode(nodes)
    if #nodes == 0 then return nil end
    local root = GetRootPart()
    local myPos = root and root.Position or Vector3.new(0, 0, 0)

    local filtered = {}
    for _, node in ipairs(nodes) do
        if Config.MineRarityFilter == "All" then
            table.insert(filtered, node)
        elseif Config.MineRarityFilter == "Legendary" and node.Rarity == "Legendary" then
            table.insert(filtered, node)
        elseif Config.MineRarityFilter == "Epic" and (node.Rarity == "Legendary" or node.Rarity == "Epic") then
            table.insert(filtered, node)
        elseif Config.MineRarityFilter == "Rare" and (node.Rarity == "Legendary" or node.Rarity == "Epic" or node.Rarity == "Rare") then
            table.insert(filtered, node)
        elseif Config.MineRarityFilter == "Uncommon" and node.Rarity ~= "Common" then
            table.insert(filtered, node)
        end
    end

    if #filtered == 0 then filtered = nodes end

    table.sort(filtered, function(a, b)
        if a.Weight ~= b.Weight then
            return a.Weight > b.Weight
        end
        local distA = (a.Position - myPos).Magnitude
        local distB = (b.Position - myPos).Magnitude
        return distA < distB
    end)

    return filtered[1]
end

-- Eksekusi Memukul Ore (Hit Remote + Tool Swing + Pet Mine)
local function MineTargetNode(node)
    if not node or not node.Instance or not node.Instance.Parent then return end

    -- 1. RemoteFunction Hit
    if Remotes.Hit and Remotes.Hit:IsA("RemoteFunction") then
        pcall(function()
            Remotes.Hit:InvokeServer(node.Instance)
        end)
        pcall(function()
            local nId = node.Instance:GetAttribute("NodeId") or node.Instance:GetAttribute("Id") or node.Instance.Name
            Remotes.Hit:InvokeServer(nId)
        end)
    end

    -- 2. RemoteEvent PetMine (Perintahkan seluruh anime menambang)
    if Remotes.PetMine and Remotes.PetMine:IsA("RemoteEvent") then
        pcall(function()
            Remotes.PetMine:FireServer(node.Instance)
        end)
    end

    -- 3. Tool Swing Fisik
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildWhichIsA("Tool")
        if not tool then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                local pick = bp:FindFirstChildWhichIsA("Tool")
                if pick then
                    pick.Parent = char
                    tool = pick
                end
            end
        end
        if tool then
            pcall(function() tool:Activate() end)
        end
    end

    State.TotalMined = State.TotalMined + 1
end

-- ============================================================================
-- 6. AUTO BELI KAPAK OTOMATIS (PICKAXE AUTO-BUY ENGINE)
-- ============================================================================
local function PerformAutoBuyPickaxe()
    if not Config.AutoBuyPickaxe then return end

    -- Cara 1: RemoteFunction MiningPurchase
    if Remotes.MiningPurchase and Remotes.MiningPurchase:IsA("RemoteFunction") then
        -- Coba beli tier kapak berikutnya (1 sampai 25)
        for tier = 1, 25 do
            pcall(function()
                local res = Remotes.MiningPurchase:InvokeServer(tier)
                if res == true or (type(res) == "table" and res.Success) then
                    State.TotalPickaxesBought = State.TotalPickaxesBought + 1
                    Log("KAPAK: Berhasil membeli Pickaxe Tier " .. tier .. " via Remote!")
                end
            end)
            pcall(function()
                local res = Remotes.MiningPurchase:InvokeServer("Pickaxe", tier)
                if res == true then
                    State.TotalPickaxesBought = State.TotalPickaxesBought + 1
                    Log("KAPAK: Berhasil membeli Pickaxe (" .. tier .. ") via Remote!")
                end
            end)
        end
    end

    -- Cara 2: RemoteFunction DailyBuy (Jika ada penawaran kapak harian)
    if Remotes.MiningDailyBuy and Remotes.MiningDailyBuy:IsA("RemoteFunction") then
        pcall(function()
            Remotes.MiningDailyBuy:InvokeServer(1)
        end)
    end

    -- Cara 3: ProximityPrompt PickaxeShopPrompt di SkeletonMiner
    pcall(function()
        local shopPrompt = workspace:FindFirstChild("PickaxeShopPrompt", true)
        if not shopPrompt and workspace:FindFirstChild("MineWorld") then
            shopPrompt = workspace.MineWorld:FindFirstChild("PickaxeShopPrompt", true)
        end
        if shopPrompt and fireproximityprompt then
            fireproximityprompt(shopPrompt)
        end
    end)

    -- Cara 4: UI Button Auto-Purchase di PlayerGui
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                        local btnText = string.lower(desc:IsA("TextButton") and desc.Text or desc.Name)
                        if (string.find(btnText, "buy", 1, true) or string.find(btnText, "beli", 1, true) or string.find(btnText, "purchase", 1, true)) 
                           and (string.find(btnText, "pickaxe", 1, true) or string.find(btnText, "kapak", 1, true) or string.find(string.lower(desc.Parent.Name), "pickaxe", 1, true)) then
                            if firesignal then
                                firesignal(desc.MouseButton1Click)
                            elseif desc.Active then
                                desc.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- 7. AUTO PAKAI BEST ANIME (AUTO EQUIP BEST ANIME / PETS)
-- ============================================================================
local function PerformAutoEquipBestAnime()
    if not Config.AutoEquipBestAnime then return end

    local success = false

    -- Cara 1: RemoteEvent PetActionRequested dengan semua varian payload
    if Remotes.PetActionRequested and Remotes.PetActionRequested:IsA("RemoteEvent") then
        pcall(function()
            Remotes.PetActionRequested:FireServer("EquipBest")
            success = true
        end)
        pcall(function()
            Remotes.PetActionRequested:FireServer({ Action = "EquipBest" })
            success = true
        end)
        pcall(function()
            Remotes.PetActionRequested:FireServer("EquipBestTeam")
            success = true
        end)
        pcall(function()
            Remotes.PetActionRequested:FireServer("Best")
            success = true
        end)
    end

    -- Cara 2: RemoteFunction EquipPetTeam / Shared Remotes
    if Remotes.EquipPetTeam and Remotes.EquipPetTeam:IsA("RemoteFunction") then
        pcall(function()
            Remotes.EquipPetTeam:InvokeServer("Best")
            success = true
        end)
        pcall(function()
            Remotes.EquipPetTeam:InvokeServer(1)
            success = true
        end)
    end

    if Remotes.SharedEquipBestPets and Remotes.SharedEquipBestPets:IsA("RemoteFunction") then
        pcall(function()
            Remotes.SharedEquipBestPets:InvokeServer()
            success = true
        end)
    end

    if Remotes.SharedEquipBestTeam and Remotes.SharedEquipBestTeam:IsA("RemoteFunction") then
        pcall(function()
            Remotes.SharedEquipBestTeam:InvokeServer()
            success = true
        end)
    end

    -- Cara 3: UI Auto Click Tombol "Equip Best" di PlayerGui
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                        local btnText = string.lower(desc:IsA("TextButton") and desc.Text or desc.Name)
                        if string.find(btnText, "equip best", 1, true) or string.find(btnText, "equipbest", 1, true) or string.find(btnText, "best anime", 1, true) or string.find(btnText, "auto equip", 1, true) then
                            if firesignal then
                                firesignal(desc.MouseButton1Click)
                                success = true
                            end
                        end
                    end
                end
            end
        end
    end)

    if success then
        Log("ANIME: Auto-Equip Best Anime dijalankan!")
    end
end

-- ============================================================================
-- 8. FITUR AUTO UPGRADE STATS & REBIRTH
-- ============================================================================
local UpgradeNames = {
    "MiningSpeed", "PickaxePower", "OreMultiplier", "BagCapacity", 
    "Luck", "PetDamage", "WalkSpeed", "PlayerSpeed", "DrillPower",
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10
}

local function PerformAutoUpgrade()
    if not Config.AutoUpgrade then return end

    -- 1. UpgradeService Purchase Remote
    if Remotes.UpgradePurchase and Remotes.UpgradePurchase:IsA("RemoteFunction") then
        for _, upg in ipairs(UpgradeNames) do
            pcall(function()
                local res = Remotes.UpgradePurchase:InvokeServer(upg)
                if res == true or (type(res) == "table" and res.Success) then
                    State.TotalUpgrades = State.TotalUpgrades + 1
                    Log("UPGRADE: Berhasil upgrade (" .. tostring(upg) .. ")!")
                end
            end)
        end
    end

    -- 2. PhysicalUpgradeService Purchase Remote
    if Remotes.PhysicalUpgradePurchase and Remotes.PhysicalUpgradePurchase:IsA("RemoteFunction") then
        for step = 1, 15 do
            pcall(function()
                local res = Remotes.PhysicalUpgradePurchase:InvokeServer(step)
                if res == true then
                    State.TotalUpgrades = State.TotalUpgrades + 1
                    Log("UPGRADE: Physical Upgrade Step " .. step .. " berhasil!")
                end
            end)
        end
    end

    -- 3. Shared BuyUpgrade
    if Remotes.SharedBuyUpgrade and Remotes.SharedBuyUpgrade:IsA("RemoteFunction") then
        for _, upg in ipairs(UpgradeNames) do
            pcall(function()
                Remotes.SharedBuyUpgrade:InvokeServer(upg)
            end)
        end
    end

    -- 4. Shared UpgradeRebirthStat
    if Remotes.SharedUpgradeRebirthStat and Remotes.SharedUpgradeRebirthStat:IsA("RemoteFunction") then
        for _, upg in ipairs({"Damage", "Speed", "Luck", "Capacity", 1, 2, 3}) do
            pcall(function()
                Remotes.SharedUpgradeRebirthStat:InvokeServer(upg)
            end)
        end
    end
end

local function PerformAutoRebirth()
    if not Config.AutoRebirth then return end

    if Remotes.RebirthRequested and Remotes.RebirthRequested:IsA("RemoteEvent") then
        pcall(function()
            Remotes.RebirthRequested:FireServer()
            State.TotalRebirths = State.TotalRebirths + 1
            Log("REBIRTH: Meminta Rebirth ke server...")
        end)
    end

    if Remotes.SharedRebirth and Remotes.SharedRebirth:IsA("RemoteFunction") then
        pcall(function()
            Remotes.SharedRebirth:InvokeServer()
            State.TotalRebirths = State.TotalRebirths + 1
            Log("REBIRTH: Eksekusi Rebirth via Shared.Rebirth!")
        end)
    end
end

-- ============================================================================
-- 9. AUTO COLLECT LOOT & AUTO SELL
-- ============================================================================
local function AutoCollectNearbyDrops()
    if not Config.AutoCollectLoot then return end
    local plot = State.MyPlot or FindMyPlot()
    local lootFolder = plot and plot:FindFirstChild("Loot")

    if lootFolder then
        for _, drop in ipairs(lootFolder:GetChildren()) do
            if drop:IsA("BasePart") or drop:IsA("Model") then
                if Remotes.CollectDrop and Remotes.CollectDrop:IsA("RemoteFunction") then
                    pcall(function() Remotes.CollectDrop:InvokeServer(drop) end)
                    pcall(function() Remotes.CollectDrop:InvokeServer(drop.Name) end)
                end
            end
        end
    end

    local mw = workspace:FindFirstChild("MineWorld")
    if mw and mw:FindFirstChild("Loot") then
        for _, drop in ipairs(mw.Loot:GetChildren()) do
            if Remotes.CollectDrop and Remotes.CollectDrop:IsA("RemoteFunction") then
                pcall(function() Remotes.CollectDrop:InvokeServer(drop) end)
            end
        end
    end
end

local function PerformSell()
    Log("SELL: Menjual hasil tambang via Remote RF.Sell...")

    if Remotes.Sell and Remotes.Sell:IsA("RemoteFunction") then
        pcall(function()
            Remotes.Sell:InvokeServer()
            State.TotalSold = State.TotalSold + 1
        end)
    end

    pcall(function()
        local sellStand = workspace:FindFirstChild("SellStand", true)
        if sellStand then
            local prompt = sellStand:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                fireproximityprompt(prompt)
                State.TotalSold = State.TotalSold + 1
            end
        end
    end)
end

local function PerformLuckyBlock()
    if not Config.AutoLuckyBlock then return end
    pcall(function()
        local blockDisplay = workspace:FindFirstChild("UnrealLuckyBlockDisplay", true)
        if blockDisplay then
            local prompt = blockDisplay:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end
    end)
end

-- ============================================================================
-- 10. MASTER LOOPS (AUTONOMOUS REMOTE ENGINE)
-- ============================================================================

-- Loop 1: Auto Mine (Remote Autonomous + Fast Hit)
task.spawn(function()
    Log("Autonomous Mining Engine v2 Aktif.")
    while true do
        task.wait(0.15)
        if Config.AutoMine then
            local nodes = GetAvailableNodes()
            local target = PickBestNode(nodes)

            if target then
                State.CurrentTargetNode = target
                
                -- Jika RemoteOnlyMining = false, karakter terbang/teleport ke ore
                if not Config.RemoteOnlyMining then
                    local root = GetRootPart()
                    if root then
                        local targetPos = target.Position + Vector3.new(0, 3, 0)
                        local dist = (root.Position - targetPos).Magnitude
                        if dist > 8 then
                            SafeTeleport(targetPos)
                            task.wait(0.05)
                        end
                    end
                end

                -- Eksekusi Remote Hit & Pet Mine langsung ke target
                MineTargetNode(target)
            else
                State.CurrentTargetNode = nil
            end
        end
    end
end)

-- Loop 2: Auto Collect Magnet Loot
task.spawn(function()
    while true do
        task.wait(0.8)
        if Config.AutoCollectLoot then
            AutoCollectNearbyDrops()
        end
    end
end)

-- Loop 3: Auto Beli Kapak (Pickaxe Auto-Buyer)
task.spawn(function()
    while true do
        task.wait(Config.BuyPickaxeInterval)
        if Config.AutoBuyPickaxe then
            PerformAutoBuyPickaxe()
        end
    end
end)

-- Loop 4: Auto Equip Best Anime
task.spawn(function()
    while true do
        task.wait(Config.EquipBestInterval)
        if Config.AutoEquipBestAnime then
            PerformAutoEquipBestAnime()
        end
    end
end)

-- Loop 5: Auto Upgrades & Rebirth
task.spawn(function()
    while true do
        task.wait(Config.UpgradeInterval)
        if Config.AutoUpgrade then
            PerformAutoUpgrade()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(Config.RebirthInterval)
        if Config.AutoRebirth then
            PerformAutoRebirth()
        end
    end
end)

-- Loop 6: Auto Sell Terjadwal
task.spawn(function()
    while true do
        task.wait(Config.AutoSellInterval)
        if Config.AutoSell then
            PerformSell()
        end
    end
end)

-- Loop 7: Auto Lucky Block
task.spawn(function()
    while true do
        task.wait(4.0)
        if Config.AutoLuckyBlock then
            PerformLuckyBlock()
        end
    end
end)

-- Loop 8: Kecepatan Karakter (WalkSpeed & JumpPower)
task.spawn(function()
    while true do
        task.wait(1.5)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if Config.WalkSpeed > 16 then hum.WalkSpeed = Config.WalkSpeed end
            if Config.JumpPower > 50 then hum.JumpPower = Config.JumpPower end
        end
    end
end)

-- ============================================================================
-- 11. USER INTERFACE (CYBERPUNK ROCKSTAR HUD v2.0)
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(15, 20, 32),
    Sidebar = Color3.fromRGB(22, 28, 44),
    Card = Color3.fromRGB(28, 36, 56),
    Accent = Color3.fromRGB(0, 200, 255),       -- Cyan Cyberpunk
    AccentGreen = Color3.fromRGB(46, 213, 115),
    AccentOrange = Color3.fromRGB(255, 120, 50),
    AccentPurple = Color3.fromRGB(160, 90, 255),
    TextMain = Color3.fromRGB(245, 248, 255),
    TextDim = Color3.fromRGB(160, 175, 205),
    Border = Color3.fromRGB(45, 60, 95)
}

local function CleanupOldGui()
    local old = CoreGui:FindFirstChild("RockstarMyAnimeMineGui")
    if old then old:Destroy() end
    local oldP = PlayerGui:FindFirstChild("RockstarMyAnimeMineGui")
    if oldP then oldP:Destroy() end
end
CleanupOldGui()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarMyAnimeMineGui"
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

-- Floating Open/Close Button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "RockstarMineOpenBtn"
OpenBtn.Size = UDim2.new(0, 160, 0, 38)
OpenBtn.Position = UDim2.new(0, 18, 0.42, 0)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.Text = "ROCKSTAR MINE v2.0"
OpenBtn.TextColor3 = Color3.fromRGB(10, 15, 25)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 12
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenBtn

-- Main Frame (Jendela GUI Utama)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 520)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Header Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Theme.Sidebar
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderPatch = Instance.new("Frame")
HeaderPatch.Size = UDim2.new(1, 0, 0, 12)
HeaderPatch.Position = UDim2.new(0, 0, 1, -12)
HeaderPatch.BackgroundColor3 = Theme.Sidebar
HeaderPatch.BorderSizePixel = 0
HeaderPatch.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 440, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ROCKSTAR HUB v2.0 - MY ANIME MINE AUTONOMOUS"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 7)
CloseBtn.BackgroundColor3 = Theme.Card
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextMain
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Status Card
local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, -24, 0, 64)
StatusCard.Position = UDim2.new(0, 12, 0, 52)
StatusCard.BackgroundColor3 = Theme.Card
StatusCard.BorderSizePixel = 0
StatusCard.Parent = MainFrame

local ScCorner = Instance.new("UICorner")
ScCorner.CornerRadius = UDim.new(0, 8)
ScCorner.Parent = StatusCard

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -20, 1, -10)
StatusLbl.Position = UDim2.new(0, 10, 0, 5)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Status: Memuat MineWorld..."
StatusLbl.TextColor3 = Theme.TextMain
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 10
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = StatusCard

-- Container Tombol Fitur Baru (Scrollable jika layar kecil)
local FeatureCard = Instance.new("Frame")
FeatureCard.Size = UDim2.new(1, -24, 0, 185)
FeatureCard.Position = UDim2.new(0, 12, 0, 122)
FeatureCard.BackgroundColor3 = Theme.Card
FeatureCard.BorderSizePixel = 0
FeatureCard.Parent = MainFrame

local FcCorner = Instance.new("UICorner")
FcCorner.CornerRadius = UDim.new(0, 8)
FcCorner.Parent = FeatureCard

-- Baris 1: Auto-Mine & Remote-Only Mode
local MineToggle = Instance.new("TextButton")
MineToggle.Size = UDim2.new(0.48, -4, 0, 38)
MineToggle.Position = UDim2.new(0, 8, 0, 8)
MineToggle.BackgroundColor3 = Config.AutoMine and Theme.AccentGreen or Theme.Sidebar
MineToggle.Text = Config.AutoMine and "AUTO MINE: ON" or "AUTO MINE: OFF"
MineToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MineToggle.Font = Enum.Font.GothamBold
MineToggle.TextSize = 10
MineToggle.Parent = FeatureCard

local MtCorner = Instance.new("UICorner")
MtCorner.CornerRadius = UDim.new(0, 6)
MtCorner.Parent = MineToggle

MineToggle.MouseButton1Click:Connect(function()
    Config.AutoMine = not Config.AutoMine
    MineToggle.BackgroundColor3 = Config.AutoMine and Theme.AccentGreen or Theme.Sidebar
    MineToggle.Text = Config.AutoMine and "AUTO MINE: ON" or "AUTO MINE: OFF"
    Log("Auto-Mine: " .. (Config.AutoMine and "Aktif" or "Nonaktif"))
end)

local RemoteToggle = Instance.new("TextButton")
RemoteToggle.Size = UDim2.new(0.48, -4, 0, 38)
RemoteToggle.Position = UDim2.new(0.52, 0, 0, 8)
RemoteToggle.BackgroundColor3 = Config.RemoteOnlyMining and Theme.AccentPurple or Theme.Sidebar
RemoteToggle.Text = Config.RemoteOnlyMining and "REMOTE JALAN SENDIRI: ON" or "REMOTE MODE: OFF"
RemoteToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RemoteToggle.Font = Enum.Font.GothamBold
RemoteToggle.TextSize = 10
RemoteToggle.Parent = FeatureCard

local RtCorner = Instance.new("UICorner")
RtCorner.CornerRadius = UDim.new(0, 6)
RtCorner.Parent = RemoteToggle

RemoteToggle.MouseButton1Click:Connect(function()
    Config.RemoteOnlyMining = not Config.RemoteOnlyMining
    RemoteToggle.BackgroundColor3 = Config.RemoteOnlyMining and Theme.AccentPurple or Theme.Sidebar
    RemoteToggle.Text = Config.RemoteOnlyMining and "REMOTE JALAN SENDIRI: ON" or "REMOTE MODE: OFF"
    Log("Remote Jalan Sendiri: " .. (Config.RemoteOnlyMining and "Aktif (Tanpa jalan kaki)" or "Nonaktif (Teleport fisik)"))
end)

-- Baris 2: Auto Beli Kapak & Auto Best Anime
local BuyPickToggle = Instance.new("TextButton")
BuyPickToggle.Size = UDim2.new(0.48, -4, 0, 38)
BuyPickToggle.Position = UDim2.new(0, 8, 0, 52)
BuyPickToggle.BackgroundColor3 = Config.AutoBuyPickaxe and Theme.AccentGreen or Theme.Sidebar
BuyPickToggle.Text = Config.AutoBuyPickaxe and "AUTO BELI KAPAK: ON" or "AUTO BELI KAPAK: OFF"
BuyPickToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BuyPickToggle.Font = Enum.Font.GothamBold
BuyPickToggle.TextSize = 10
BuyPickToggle.Parent = FeatureCard

local BpCorner = Instance.new("UICorner")
BpCorner.CornerRadius = UDim.new(0, 6)
BpCorner.Parent = BuyPickToggle

BuyPickToggle.MouseButton1Click:Connect(function()
    Config.AutoBuyPickaxe = not Config.AutoBuyPickaxe
    BuyPickToggle.BackgroundColor3 = Config.AutoBuyPickaxe and Theme.AccentGreen or Theme.Sidebar
    BuyPickToggle.Text = Config.AutoBuyPickaxe and "AUTO BELI KAPAK: ON" or "AUTO BELI KAPAK: OFF"
    Log("Auto Beli Kapak: " .. (Config.AutoBuyPickaxe and "Aktif" or "Nonaktif"))
end)

local EquipAnimeToggle = Instance.new("TextButton")
EquipAnimeToggle.Size = UDim2.new(0.48, -4, 0, 38)
EquipAnimeToggle.Position = UDim2.new(0.52, 0, 0, 52)
EquipAnimeToggle.BackgroundColor3 = Config.AutoEquipBestAnime and Theme.AccentGreen or Theme.Sidebar
EquipAnimeToggle.Text = Config.AutoEquipBestAnime and "PAKAI BEST ANIME: ON" or "PAKAI BEST ANIME: OFF"
EquipAnimeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EquipAnimeToggle.Font = Enum.Font.GothamBold
EquipAnimeToggle.TextSize = 10
EquipAnimeToggle.Parent = FeatureCard

local EaCorner = Instance.new("UICorner")
EaCorner.CornerRadius = UDim.new(0, 6)
EaCorner.Parent = EquipAnimeToggle

EquipAnimeToggle.MouseButton1Click:Connect(function()
    Config.AutoEquipBestAnime = not Config.AutoEquipBestAnime
    EquipAnimeToggle.BackgroundColor3 = Config.AutoEquipBestAnime and Theme.AccentGreen or Theme.Sidebar
    EquipAnimeToggle.Text = Config.AutoEquipBestAnime and "PAKAI BEST ANIME: ON" or "PAKAI BEST ANIME: OFF"
    Log("Auto Pakai Best Anime: " .. (Config.AutoEquipBestAnime and "Aktif" or "Nonaktif"))
    if Config.AutoEquipBestAnime then
        PerformAutoEquipBestAnime()
    end
end)

-- Baris 3: Auto Upgrades & Auto Rebirth
local UpgradeToggle = Instance.new("TextButton")
UpgradeToggle.Size = UDim2.new(0.48, -4, 0, 38)
UpgradeToggle.Position = UDim2.new(0, 8, 0, 96)
UpgradeToggle.BackgroundColor3 = Config.AutoUpgrade and Theme.AccentGreen or Theme.Sidebar
UpgradeToggle.Text = Config.AutoUpgrade and "AUTO UPGRADES: ON" or "AUTO UPGRADES: OFF"
UpgradeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
UpgradeToggle.Font = Enum.Font.GothamBold
UpgradeToggle.TextSize = 10
UpgradeToggle.Parent = FeatureCard

local UtCorner = Instance.new("UICorner")
UtCorner.CornerRadius = UDim.new(0, 6)
UtCorner.Parent = UpgradeToggle

UpgradeToggle.MouseButton1Click:Connect(function()
    Config.AutoUpgrade = not Config.AutoUpgrade
    UpgradeToggle.BackgroundColor3 = Config.AutoUpgrade and Theme.AccentGreen or Theme.Sidebar
    UpgradeToggle.Text = Config.AutoUpgrade and "AUTO UPGRADES: ON" or "AUTO UPGRADES: OFF"
    Log("Auto Upgrades: " .. (Config.AutoUpgrade and "Aktif" or "Nonaktif"))
end)

local RebirthToggle = Instance.new("TextButton")
RebirthToggle.Size = UDim2.new(0.48, -4, 0, 38)
RebirthToggle.Position = UDim2.new(0.52, 0, 0, 96)
RebirthToggle.BackgroundColor3 = Config.AutoRebirth and Theme.AccentGreen or Theme.Sidebar
RebirthToggle.Text = Config.AutoRebirth and "AUTO REBIRTH: ON" or "AUTO REBIRTH: OFF"
RebirthToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RebirthToggle.Font = Enum.Font.GothamBold
RebirthToggle.TextSize = 10
RebirthToggle.Parent = FeatureCard

local RbtCorner = Instance.new("UICorner")
RbtCorner.CornerRadius = UDim.new(0, 6)
RbtCorner.Parent = RebirthToggle

RebirthToggle.MouseButton1Click:Connect(function()
    Config.AutoRebirth = not Config.AutoRebirth
    RebirthToggle.BackgroundColor3 = Config.AutoRebirth and Theme.AccentGreen or Theme.Sidebar
    RebirthToggle.Text = Config.AutoRebirth and "AUTO REBIRTH: ON" or "AUTO REBIRTH: OFF"
    Log("Auto Rebirth: " .. (Config.AutoRebirth and "Aktif" or "Nonaktif"))
end)

-- Baris 4: Filter Ore & Jual Sekarang
local FilterBtn = Instance.new("TextButton")
FilterBtn.Size = UDim2.new(0.48, -4, 0, 36)
FilterBtn.Position = UDim2.new(0, 8, 0, 140)
FilterBtn.BackgroundColor3 = Theme.Sidebar
FilterBtn.Text = "Filter Ore: " .. Config.MineRarityFilter
FilterBtn.TextColor3 = Theme.Accent
FilterBtn.Font = Enum.Font.GothamBold
FilterBtn.TextSize = 10
FilterBtn.Parent = FeatureCard

local FbCorner = Instance.new("UICorner")
FbCorner.CornerRadius = UDim.new(0, 6)
FbCorner.Parent = FilterBtn

FilterBtn.MouseButton1Click:Connect(function()
    if Config.MineRarityFilter == "All" then
        Config.MineRarityFilter = "Legendary"
    elseif Config.MineRarityFilter == "Legendary" then
        Config.MineRarityFilter = "Epic"
    elseif Config.MineRarityFilter == "Epic" then
        Config.MineRarityFilter = "Rare"
    elseif Config.MineRarityFilter == "Rare" then
        Config.MineRarityFilter = "Uncommon"
    else
        Config.MineRarityFilter = "All"
    end
    FilterBtn.Text = "Filter Ore: " .. Config.MineRarityFilter
    Log("Filter Ore diubah ke: " .. Config.MineRarityFilter)
end)

local InstantSellBtn = Instance.new("TextButton")
InstantSellBtn.Size = UDim2.new(0.48, -4, 0, 36)
InstantSellBtn.Position = UDim2.new(0.52, 0, 0, 140)
InstantSellBtn.BackgroundColor3 = Theme.AccentOrange
InstantSellBtn.Text = "JUAL SEKARANG (INSTANT)"
InstantSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantSellBtn.Font = Enum.Font.GothamBold
InstantSellBtn.TextSize = 10
InstantSellBtn.Parent = FeatureCard

local IsCorner = Instance.new("UICorner")
IsCorner.CornerRadius = UDim.new(0, 6)
IsCorner.Parent = InstantSellBtn

InstantSellBtn.MouseButton1Click:Connect(function()
    PerformSell()
end)

-- Teleport Waypoints Card
local TeleportCard = Instance.new("Frame")
TeleportCard.Size = UDim2.new(1, -24, 0, 68)
TeleportCard.Position = UDim2.new(0, 12, 0, 313)
TeleportCard.BackgroundColor3 = Theme.Card
TeleportCard.BorderSizePixel = 0
TeleportCard.Parent = MainFrame

local TpcCorner = Instance.new("UICorner")
TpcCorner.CornerRadius = UDim.new(0, 8)
TpcCorner.Parent = TeleportCard

local Waypoints = {
    { Name = "My Plot", Pos = function()
        local plot = State.MyPlot or FindMyPlot()
        return plot and (plot:GetPivot().Position + Vector3.new(0, 4, 0)) or Vector3.new(-6000, 501, -6000)
    end },
    { Name = "Toko Jual", Pos = Vector3.new(-5978.0, 504.0, -6000.0) },
    { Name = "Beli Pickaxe", Pos = Vector3.new(-6022.0, 504.0, -6000.0) },
    { Name = "Summon Gacha", Pos = Vector3.new(-6048.2, 511.0, -5952.4) },
    { Name = "Enchant Altar", Pos = Vector3.new(-6048.2, 512.0, -6047.6) },
    { Name = "Center Hub", Pos = Vector3.new(-6000.0, 502.0, -6000.0) },
}

for i, wp in ipairs(Waypoints) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, -4, 0, 24)
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    btn.Position = UDim2.new(col * 0.33 + 0.015, 0, 0, 8 + row * 28)
    btn.BackgroundColor3 = Theme.Sidebar
    btn.Text = wp.Name
    btn.TextColor3 = Theme.TextMain
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 9
    btn.Parent = TeleportCard

    local Bc = Instance.new("UICorner")
    Bc.CornerRadius = UDim.new(0, 4)
    Bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local target = type(wp.Pos) == "function" and wp.Pos() or wp.Pos
        SafeTeleport(target)
        Log("Teleport ke: " .. wp.Name)
    end)
end

-- Console Log Box
local LogCard = Instance.new("Frame")
LogCard.Size = UDim2.new(1, -24, 1, -394)
LogCard.Position = UDim2.new(0, 12, 0, 388)
LogCard.BackgroundColor3 = Theme.Sidebar
LogCard.BorderSizePixel = 0
LogCard.Parent = MainFrame

local LcCorner = Instance.new("UICorner")
LcCorner.CornerRadius = UDim.new(0, 8)
LcCorner.Parent = LogCard

local ConsoleText = Instance.new("TextLabel")
ConsoleText.Size = UDim2.new(1, -16, 1, -16)
ConsoleText.Position = UDim2.new(0, 8, 0, 8)
ConsoleText.BackgroundTransparency = 1
ConsoleText.Text = "Rockstar Mine v2.0 siap..."
ConsoleText.TextColor3 = Theme.TextDim
ConsoleText.Font = Enum.Font.Code
ConsoleText.TextSize = 9
ConsoleText.TextXAlignment = Enum.TextXAlignment.Left
ConsoleText.TextYAlignment = Enum.TextYAlignment.Top
ConsoleText.Parent = LogCard

-- Loop Update Tampilan
task.spawn(function()
    while true do
        local plot = State.MyPlot or FindMyPlot()
        local plotName = plot and plot.Name or "Mencari Plot..."
        local curOre = State.CurrentTargetNode and (State.CurrentTargetNode.Name .. " (" .. State.CurrentTargetNode.Rarity .. ")") or "Standby / Mencari Ore"
        StatusLbl.Text = "Plot: " .. plotName .. " | Target: " .. curOre .. "\nTotal Mined: " .. State.TotalMined .. " | Sold: " .. State.TotalSold .. " | Kapak: " .. State.TotalPickaxesBought .. " | Upgrades: " .. State.TotalUpgrades .. " | Rebirth: " .. State.TotalRebirths
        if #State.Logs > 0 then
            ConsoleText.Text = table.concat(State.Logs, "\n")
        end
        task.wait(1.5)
    end
end)

Log("ROCKSTAR MINE v2.0 READY: Auto Pickaxe, Best Anime, & Upgrades Aktif!")
