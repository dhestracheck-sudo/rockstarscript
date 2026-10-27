-- ============================================================================
-- * ROCKSTAR HUB - MY ANIME MINE AUTO-FARMING SCRIPT v3.0 *
-- Game: My Anime Mine / MineWorld
-- PlaceId: 72858262610964 | GameId: 10629695169
-- Pembaruan Utama (v3.0):
--   [FIX] 100% Guaranteed Auto-Sell: Teleport mikro instan ke depan SellStand
--         untuk tembus Server Distance Check, lalu otomatis balik ke tambang!
--   [FIX] Zero Robux Popups: Mematikan pembukaan toko otomatis & memblokir
--         semua popup Marketplace/Robux/Gamepass yang tidak diperlukan!
--   [FIX] Tanpa Buka Toko GUI: Tidak memicu PickaxeShopPrompt yang membuka jendela toko.
--   [NEW] Auto Pakai Best Anime: Langsung aktif otomatis memakai anime terkuat.
--   [NEW] Auto Upgrades Stats: Upgrade remote internal tanpa pop-up toko.
--   [OK] Anti-AFK 24 Jam Universal (Delta PC & Android Compatible)
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local MarketplaceService = game:GetService("MarketplaceService")

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
    RemoteOnlyMining = true,            -- True = Mining jarak jauh via Remote
    MineRarityFilter = "All",           -- "All", "Legendary", "Epic", "Rare", "Uncommon"
    AutoCollectLoot = true,
    
    -- Jual & Event
    AutoSell = true,                    -- Auto Jual 100% tembus distance check
    AutoSellInterval = 15,              -- Detik antar jual
    AutoLuckyBlock = true,
    
    -- Anime / Pet & Upgrades
    AutoEquipBestAnime = true,          -- Otomatis pakai anime/pet terbaik
    EquipBestInterval = 10,             -- Detik antar equip best
    AutoUpgrade = true,                 -- Otomatis upgrade stats via remote murni
    UpgradeInterval = 6,                -- Detik antar upgrade
    AutoRebirth = false,                -- Otomatis rebirth jika siap
    RebirthInterval = 20,               -- Detik
    
    -- Toko Kapak (Aman Tanpa Buka UI & Tanpa Robux)
    AutoBuyPickaxe = false,             -- Default OFF agar tidak mengganggu layar
    BuyPickaxeInterval = 12,            -- Detik
    
    -- Navigasi & Karakter
    AntiAfk = true,
    WalkSpeed = 24,
    JumpPower = 50,
}

local State = {
    MyPlot = nil,
    CurrentTargetNode = nil,
    TotalMined = 0,
    TotalSold = 0,
    TotalUpgrades = 0,
    TotalRebirths = 0,
    IsSelling = false,
    Logs = {},
}

local function Log(msg)
    local timestamp = os.date("%H:%M:%S")
    local fullMsg = "[" .. timestamp .. "] " .. tostring(msg)
    table.insert(State.Logs, 1, fullMsg)
    if #State.Logs > 40 then
        table.remove(State.Logs)
    end
    print("[ROCKSTAR MINE v3]: " .. fullMsg)
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
-- 2. BLOKIR POPUP ROBUX / TOKO TIDAK PERLU
-- ============================================================================
-- Memastikan dialog Robux atau toko berbayar tidak mengganggu layar
task.spawn(function()
    while true do
        task.wait(0.6)
        pcall(function()
            -- Tutup CoreGui PurchasePrompt (Robux Dialog)
            local purchaseGui = CoreGui:FindFirstChild("PurchasePrompt") or CoreGui:FindFirstChild("PurchasePromptApp")
            if purchaseGui then
                for _, btn in ipairs(purchaseGui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local txt = string.lower(btn:IsA("TextButton") and btn.Text or btn.Name)
                        if string.find(txt, "cancel", 1, true) or string.find(txt, "batal", 1, true) or string.find(txt, "close", 1, true) or string.find(txt, "no", 1, true) then
                            if firesignal then
                                firesignal(btn.MouseButton1Click)
                            end
                        end
                    end
                end
            end

            -- Tutup jendela Shop jika terbuka sendiri dan berisi penawaran Robux
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "RockstarMyAnimeMineGui" then
                    local nameLow = string.lower(gui.Name)
                    if string.find(nameLow, "robux", 1, true) or string.find(nameLow, "gamepass", 1, true) or string.find(nameLow, "starterpack", 1, true) then
                        gui.Enabled = false
                    end
                end
            end
        end)
    end
end)

-- ============================================================================
-- 3. RESOLVER REMOTE SERVICES
-- ============================================================================
local Remotes = {
    -- Mining
    Hit = nil,
    CollectDrop = nil,
    Sell = nil,
    PetMine = nil,
    MiningPurchase = nil,
    SharedSellAll = nil,
    
    -- Pets / Anime
    PetActionRequested = nil,
    EquipPetTeam = nil,
    SharedEquipBestPets = nil,
    SharedEquipBestTeam = nil,
    
    -- Upgrades & Rebirth
    UpgradePurchase = nil,
    PhysicalUpgradePurchase = nil,
    SharedBuyUpgrade = nil,
    RebirthRequested = nil,
    SharedRebirth = nil,
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

Remotes.Hit = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Hit")
Remotes.CollectDrop = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.CollectDrop")
Remotes.Sell = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Sell")
Remotes.PetMine = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.PetMine")
Remotes.MiningPurchase = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Purchase")
Remotes.SharedSellAll = GetRemote("ReplicatedStorage.Shared.Remotes.SellAll")

Remotes.PetActionRequested = GetRemote("ReplicatedStorage.RemoteServices.PetService.RE.PetActionRequested")
Remotes.EquipPetTeam = GetRemote("ReplicatedStorage.RemoteServices.PetService.RF.EquipPetTeam")
Remotes.SharedEquipBestPets = GetRemote("ReplicatedStorage.Shared.Remotes.EquipBestPets")
Remotes.SharedEquipBestTeam = GetRemote("ReplicatedStorage.Shared.Remotes.EquipBestTeam")

Remotes.UpgradePurchase = GetRemote("ReplicatedStorage.RemoteServices.UpgradeService.RF.Purchase")
Remotes.PhysicalUpgradePurchase = GetRemote("ReplicatedStorage.RemoteServices.PhysicalUpgradeService.RF.Purchase")
Remotes.SharedBuyUpgrade = GetRemote("ReplicatedStorage.Shared.Remotes.BuyUpgrade")
Remotes.RebirthRequested = GetRemote("ReplicatedStorage.RemoteServices.RebirthService.RE.RebirthRequested")
Remotes.SharedRebirth = GetRemote("ReplicatedStorage.Shared.Remotes.Rebirth")

if Remotes.Hit then Log("Remote Hit terhubung OK.") end
if Remotes.CollectDrop then Log("Remote CollectDrop terhubung OK.") end
if Remotes.Sell then Log("Remote Sell terhubung OK.") end
if Remotes.PetActionRequested or Remotes.SharedEquipBestPets then Log("Remote Best Anime terhubung OK.") end

-- ============================================================================
-- 4. DETEKSI PLOT MILIK SENDIRI
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
-- 5. NAVIGASI KARAKTER (SAFE TELEPORT & ROOT)
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

local function TriggerProximity(prompt)
    if not prompt then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

-- ============================================================================
-- 6. PENCARI ORE NODE & REMOTE MINING ENGINE
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

    -- 2. RemoteEvent PetMine
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
-- 7. 100% RELIABLE AUTO SELL (TELEPORT MIKRO KE DEPAN SELLSTAND)
-- ============================================================================
local function PerformSell()
    if State.IsSelling then return end
    State.IsSelling = true

    local root = GetRootPart()
    if not root then
        State.IsSelling = false
        return
    end

    -- Posisi tepat di depan NPC Toko Jual (SkeletonMiner)
    local sellStandPos = Vector3.new(-5980.5, 502.0, -5999.7)
    local prevCFrame = root.CFrame
    local dist = (root.Position - sellStandPos).Magnitude
    local didTeleport = false

    -- Jika jarak > 10 studs, lakukan teleport kilat untuk tembus server distance check
    if dist > 10 then
        root.CFrame = CFrame.new(sellStandPos)
        didTeleport = true
        task.wait(0.12) -- Tunggu server menerima CFrame baru
    end

    local sold = false

    -- 1. Panggil RemoteFunction Sell resmi game
    if Remotes.Sell and Remotes.Sell:IsA("RemoteFunction") then
        pcall(function()
            local res = Remotes.Sell:InvokeServer()
            if res ~= false then sold = true end
        end)
        pcall(function() Remotes.Sell:InvokeServer("All") end)
        pcall(function() Remotes.Sell:InvokeServer(true) end)
    end

    -- 2. Panggil Shared SellAll
    if Remotes.SharedSellAll and Remotes.SharedSellAll:IsA("RemoteFunction") then
        pcall(function()
            Remotes.SharedSellAll:InvokeServer()
            sold = true
        end)
    end

    -- 3. Trigger ProximityPrompt di SellStand (jarak sudah 0 studs)
    pcall(function()
        local sellStand = workspace:FindFirstChild("SellStand", true) or (workspace:FindFirstChild("MineWorld") and workspace.MineWorld:FindFirstChild("SellStand", true))
        if sellStand then
            local prompt = sellStand:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                TriggerProximity(prompt)
                sold = true
            end
        end
    end)

    if sold then
        State.TotalSold = State.TotalSold + 1
        Log("SELL: Berhasil menjual seluruh ore ke Toko!")
    end

    -- Kembalikan posisi karakter ke tambang asal secara instan
    if didTeleport and prevCFrame then
        task.wait(0.1)
        local curRoot = GetRootPart()
        if curRoot then
            curRoot.CFrame = prevCFrame
        end
    end

    State.IsSelling = false
end

-- ============================================================================
-- 8. AUTO PAKAI BEST ANIME (TANPA BUKA TOKO/MENU)
-- ============================================================================
local function PerformAutoEquipBestAnime()
    if not Config.AutoEquipBestAnime then return end

    local ok = false

    -- 1. RemoteEvent PetActionRequested
    if Remotes.PetActionRequested and Remotes.PetActionRequested:IsA("RemoteEvent") then
        pcall(function()
            Remotes.PetActionRequested:FireServer("EquipBest")
            ok = true
        end)
        pcall(function()
            Remotes.PetActionRequested:FireServer({ Action = "EquipBest" })
            ok = true
        end)
        pcall(function()
            Remotes.PetActionRequested:FireServer("Best")
            ok = true
        end)
    end

    -- 2. RemoteFunction Shared & PetTeam
    if Remotes.SharedEquipBestPets and Remotes.SharedEquipBestPets:IsA("RemoteFunction") then
        pcall(function()
            Remotes.SharedEquipBestPets:InvokeServer()
            ok = true
        end)
    end

    if Remotes.SharedEquipBestTeam and Remotes.SharedEquipBestTeam:IsA("RemoteFunction") then
        pcall(function()
            Remotes.SharedEquipBestTeam:InvokeServer()
            ok = true
        end)
    end

    if Remotes.EquipPetTeam and Remotes.EquipPetTeam:IsA("RemoteFunction") then
        pcall(function()
            Remotes.EquipPetTeam:InvokeServer("Best")
            ok = true
        end)
    end

    if ok then
        Log("ANIME: Best Anime berhasil di-equip otomatis!")
    end
end

-- ============================================================================
-- 9. AUTO UPGRADES STATS (REMOTE MURNI TANPA ROBUX)
-- ============================================================================
local SafeUpgradeNames = {
    "MiningSpeed", "PickaxePower", "OreMultiplier", "BagCapacity", 
    "Luck", "PetDamage", "WalkSpeed", "PlayerSpeed",
    1, 2, 3, 4, 5
}

local function PerformAutoUpgrade()
    if not Config.AutoUpgrade then return end

    if Remotes.UpgradePurchase and Remotes.UpgradePurchase:IsA("RemoteFunction") then
        for _, upg in ipairs(SafeUpgradeNames) do
            pcall(function()
                local res = Remotes.UpgradePurchase:InvokeServer(upg)
                if res == true or (type(res) == "table" and res.Success) then
                    State.TotalUpgrades = State.TotalUpgrades + 1
                    Log("UPGRADE: Sukses upgrade " .. tostring(upg))
                end
            end)
        end
    end

    if Remotes.PhysicalUpgradePurchase and Remotes.PhysicalUpgradePurchase:IsA("RemoteFunction") then
        for step = 1, 5 do
            pcall(function()
                local res = Remotes.PhysicalUpgradePurchase:InvokeServer(step)
                if res == true then
                    State.TotalUpgrades = State.TotalUpgrades + 1
                    Log("UPGRADE: Physical step " .. step .. " sukses!")
                end
            end)
        end
    end

    if Remotes.SharedBuyUpgrade and Remotes.SharedBuyUpgrade:IsA("RemoteFunction") then
        for _, upg in ipairs(SafeUpgradeNames) do
            pcall(function()
                Remotes.SharedBuyUpgrade:InvokeServer(upg)
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
            Log("REBIRTH: Eksekusi Rebirth via Remote...")
        end)
    end

    if Remotes.SharedRebirth and Remotes.SharedRebirth:IsA("RemoteFunction") then
        pcall(function()
            Remotes.SharedRebirth:InvokeServer()
            State.TotalRebirths = State.TotalRebirths + 1
            Log("REBIRTH: Eksekusi Shared.Rebirth!")
        end)
    end
end

-- ============================================================================
-- 10. AUTO BELI KAPAK (HANYA REMOTE MURNI JIKA DIAKTIFKAN - TANPA BUKA UI)
-- ============================================================================
local function PerformAutoBuyPickaxe()
    if not Config.AutoBuyPickaxe then return end

    -- HANYA panggil RemoteFunction koin murni tingkat rendah, TANPA memicu ProximityPrompt / UI
    if Remotes.MiningPurchase and Remotes.MiningPurchase:IsA("RemoteFunction") then
        for tier = 1, 8 do
            pcall(function()
                Remotes.MiningPurchase:InvokeServer(tier)
            end)
        end
    end
end

-- ============================================================================
-- 11. AUTO COLLECT LOOT & LUCKY BLOCK
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

local function PerformLuckyBlock()
    if not Config.AutoLuckyBlock then return end
    pcall(function()
        local blockDisplay = workspace:FindFirstChild("UnrealLuckyBlockDisplay", true)
        if blockDisplay then
            local prompt = blockDisplay:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                TriggerProximity(prompt)
            end
        end
    end)
end

-- ============================================================================
-- 12. MASTER LOOPS (AUTONOMOUS ENGINE)
-- ============================================================================

-- Loop 1: Mining Engine
task.spawn(function()
    Log("Autonomous Mining Engine v3.0 Aktif.")
    while true do
        task.wait(0.15)
        if Config.AutoMine and not State.IsSelling then
            local nodes = GetAvailableNodes()
            local target = PickBestNode(nodes)

            if target then
                State.CurrentTargetNode = target
                
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

-- Loop 3: Auto Sell Terjadwal
task.spawn(function()
    while true do
        task.wait(Config.AutoSellInterval)
        if Config.AutoSell then
            PerformSell()
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

-- Loop 5: Auto Upgrades
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

-- Loop 6: Auto Beli Kapak (Hanya jika diaktifkan user)
task.spawn(function()
    while true do
        task.wait(Config.BuyPickaxeInterval)
        if Config.AutoBuyPickaxe then
            PerformAutoBuyPickaxe()
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

-- Loop 8: WalkSpeed & JumpPower
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
-- 13. USER INTERFACE (CLEAN CYBERPUNK HUD v3.0)
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
OpenBtn.Text = "ROCKSTAR MINE v3.0"
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
MainFrame.Size = UDim2.new(0, 550, 0, 510)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -255)
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
TitleLabel.Text = "ROCKSTAR HUB v3.0 - NO-ROBUX AUTONOMOUS"
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

-- Container Tombol Fitur
local FeatureCard = Instance.new("Frame")
FeatureCard.Size = UDim2.new(1, -24, 0, 185)
FeatureCard.Position = UDim2.new(0, 12, 0, 122)
FeatureCard.BackgroundColor3 = Theme.Card
FeatureCard.BorderSizePixel = 0
FeatureCard.Parent = MainFrame

local FcCorner = Instance.new("UICorner")
FcCorner.CornerRadius = UDim.new(0, 8)
FcCorner.Parent = FeatureCard

-- Baris 1: Auto-Mine & Remote Mode
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
    Log("Remote Jalan Sendiri: " .. (Config.RemoteOnlyMining and "Aktif" or "Nonaktif"))
end)

-- Baris 2: Auto Sell (100% Reliable) & Pakai Best Anime
local SellToggle = Instance.new("TextButton")
SellToggle.Size = UDim2.new(0.48, -4, 0, 38)
SellToggle.Position = UDim2.new(0, 8, 0, 52)
SellToggle.BackgroundColor3 = Config.AutoSell and Theme.AccentGreen or Theme.Sidebar
SellToggle.Text = Config.AutoSell and "AUTO SELL (15s): ON" or "AUTO SELL: OFF"
SellToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SellToggle.Font = Enum.Font.GothamBold
SellToggle.TextSize = 10
SellToggle.Parent = FeatureCard

local StCorner = Instance.new("UICorner")
StCorner.CornerRadius = UDim.new(0, 6)
StCorner.Parent = SellToggle

SellToggle.MouseButton1Click:Connect(function()
    Config.AutoSell = not Config.AutoSell
    SellToggle.BackgroundColor3 = Config.AutoSell and Theme.AccentGreen or Theme.Sidebar
    SellToggle.Text = Config.AutoSell and "AUTO SELL (15s): ON" or "AUTO SELL: OFF"
    Log("Auto-Sell: " .. (Config.AutoSell and "Aktif (Anti-Gagal)" or "Nonaktif"))
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

-- Baris 3: Auto Upgrades & Beli Kapak Remote
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

local BuyPickToggle = Instance.new("TextButton")
BuyPickToggle.Size = UDim2.new(0.48, -4, 0, 38)
BuyPickToggle.Position = UDim2.new(0.52, 0, 0, 96)
BuyPickToggle.BackgroundColor3 = Config.AutoBuyPickaxe and Theme.AccentGreen or Theme.Sidebar
BuyPickToggle.Text = Config.AutoBuyPickaxe and "BELI KAPAK: ON" or "BELI KAPAK: OFF"
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
    BuyPickToggle.Text = Config.AutoBuyPickaxe and "BELI KAPAK: ON" or "BELI KAPAK: OFF"
    Log("Beli Kapak: " .. (Config.AutoBuyPickaxe and "Aktif (Remote Murni)" or "Nonaktif"))
end)

-- Baris 4: Filter Ore & Jual Instan Sekarang
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
    { Name = "Toko Jual", Pos = Vector3.new(-5980.5, 502.0, -5999.7) },
    { Name = "Toko Kapak", Pos = Vector3.new(-6022.0, 504.0, -6000.0) },
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
ConsoleText.Text = "Rockstar Mine v3.0 siap..."
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
        local curOre = State.CurrentTargetNode and (State.CurrentTargetNode.Name .. " (" .. State.CurrentTargetNode.Rarity .. ")") or "Standby / Menambang Ore"
        StatusLbl.Text = "Plot: " .. plotName .. " | Target: " .. curOre .. "\nTotal Mined: " .. State.TotalMined .. " | Sold: " .. State.TotalSold .. "x | Upgrades: " .. State.TotalUpgrades
        if #State.Logs > 0 then
            ConsoleText.Text = table.concat(State.Logs, "\n")
        end
        task.wait(1.5)
    end
end)

Log("ROCKSTAR MINE v3.0 READY: Auto-Sell Tembus Server & Bebas Robux Popups!")
