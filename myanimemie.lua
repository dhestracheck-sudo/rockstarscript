-- ============================================================================
-- * ROCKSTAR HUB - MY ANIME MINE AUTO-FARMING SCRIPT v1.0 *
-- Game: My Anime Mine / MineWorld
-- Fitur Utama:
--   [1] Auto Mine (Fast Hit Remote + Pet Mine + Auto Teleport ke Ore)
--   [2] Filter Rarity Ore (Legendary, Epic, Rare, Uncommon, Common)
--   [3] Auto Collect Loot (Magnet Drops Otomatis ke Tas)
--   [4] Auto Sell (Remote RF.Sell + ProximityPrompt SellStand)
--   [5] Auto Lucky Block (Unreal Block Interactor)
--   [6] Waypoint Teleport (My Plot, Sell, Pickaxe, Summon, Enchant, Hub)
--   [7] Anti-AFK 24 Jam (Zero Disconnect)
--   [8] 100% Universal Delta Executor Compatible (PC & Android)
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================================
-- 1. KONFIGURASI BOT
-- ============================================================================
local Config = {
    AutoMine = false,
    MineRarityFilter = "All",          -- "All", "Legendary", "Epic", "Rare"
    AutoCollectLoot = true,
    AutoSell = false,
    AutoSellInterval = 20,             -- Detik
    AutoLuckyBlock = false,
    TweenSpeed = 45,                   -- Kecepatan terbang/teleport (studs/sec)
    AntiAfk = true,
    WalkSpeed = 16,
    JumpPower = 50,
}

local State = {
    MyPlot = nil,
    CurrentTargetNode = nil,
    TotalMined = 0,
    TotalSold = 0,
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
    print("[ROCKSTAR MINE]: " .. fullMsg)
end

-- Anti AFK
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
-- 2. RESOLVER REMOTE MINING SERVICE
-- ============================================================================
local Remotes = {
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
Remotes.Enter = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Enter")
Remotes.Leave = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Leave")
Remotes.Surface = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RF.Surface")
Remotes.PetMine = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.PetMine")
Remotes.MineReward = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.MineReward")
Remotes.MineReset = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.MineReset")
Remotes.MineNotice = GetRemote("ReplicatedStorage.RemoteServices.MiningService.RE.MineNotice")

if Remotes.Hit then Log("Remote Hit terdeteksi OK.") end
if Remotes.CollectDrop then Log("Remote CollectDrop terdeteksi OK.") end
if Remotes.Sell then Log("Remote Sell terdeteksi OK.") end
if Remotes.PetMine then Log("Remote PetMine terdeteksi OK.") end

-- ============================================================================
-- 3. DETEKSI PLOT MILIK SENDIRI DI MINEWORLD
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
-- 4. NAVIGASI KARAKTER (TELEPORT & TWEEN HALUS)
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
-- 5. PENCARI ORE NODE & LOGIKA AUTO-MINE
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
-- 6. AUTO COLLECT LOOT (MAGNET DROPS)
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

-- ============================================================================
-- 7. AUTO SELL (REMOTE RF.SELL + PROXIMITY PROMPT)
-- ============================================================================
local function PerformSell()
    Log("SELL: Menjual semua hasil tambang...")

    if Remotes.Sell and Remotes.Sell:IsA("RemoteFunction") then
        pcall(function()
            Remotes.Sell:InvokeServer()
            State.TotalSold = State.TotalSold + 1
            Log("SELL: Berhasil menjual via Remote RF.Sell!")
        end)
    end

    pcall(function()
        local sellStand = workspace:FindFirstChild("SellStand", true)
        if sellStand then
            local prompt = sellStand:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                fireproximityprompt(prompt)
                State.TotalSold = State.TotalSold + 1
                Log("SELL: Berhasil trigger SellPrompt di SellStand!")
            end
        end
    end)
end

-- ============================================================================
-- 8. AUTO LUCKY BLOCK (UNREAL BLOCK INTERACTION)
-- ============================================================================
local function PerformLuckyBlock()
    if not Config.AutoLuckyBlock then return end
    pcall(function()
        local blockDisplay = workspace:FindFirstChild("UnrealLuckyBlockDisplay", true)
        if blockDisplay then
            local prompt = blockDisplay:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                fireproximityprompt(prompt)
                Log("LUCKY BLOCK: Berhasil trigger UnrealBlockPrompt!")
            end
        end
    end)
end

-- ============================================================================
-- 9. MASTER LOOPS (AUTONOMOUS ENGINE)
-- ============================================================================
-- Loop 1: Auto Mine & Navigasi Ore
task.spawn(function()
    Log("Engine Auto-Mine Aktif.")
    while true do
        task.wait(0.2)
        if Config.AutoMine then
            local nodes = GetAvailableNodes()
            local target = PickBestNode(nodes)

            if target then
                State.CurrentTargetNode = target
                local root = GetRootPart()
                if root then
                    local targetPos = target.Position + Vector3.new(0, 3, 0)
                    local dist = (root.Position - targetPos).Magnitude

                    if dist > 8 then
                        SafeTeleport(targetPos)
                        task.wait(0.1)
                    end

                    MineTargetNode(target)
                end
            else
                State.CurrentTargetNode = nil
            end
        end
    end
end)

-- Loop 2: Auto Collect Loot Drops
task.spawn(function()
    while true do
        task.wait(1.0)
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

-- Loop 4: Auto Lucky Block
task.spawn(function()
    while true do
        task.wait(5.0)
        if Config.AutoLuckyBlock then
            PerformLuckyBlock()
        end
    end
end)

-- Loop 5: Player Character Attributes (WalkSpeed, JumpPower)
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
-- 10. USER INTERFACE (CYBERPUNK ROCKSTAR HUD)
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(15, 20, 32),
    Sidebar = Color3.fromRGB(22, 28, 44),
    Card = Color3.fromRGB(28, 36, 56),
    Accent = Color3.fromRGB(0, 200, 255),
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
OpenBtn.Size = UDim2.new(0, 150, 0, 38)
OpenBtn.Position = UDim2.new(0, 18, 0.42, 0)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.Text = "ROCKSTAR MINE v1.0"
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
MainFrame.Size = UDim2.new(0, 540, 0, 460)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -230)
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
TitleLabel.Size = UDim2.new(0, 420, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ROCKSTAR HUB - MY ANIME MINE AUTO-FARMING"
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
StatusCard.Size = UDim2.new(1, -24, 0, 56)
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
StatusLbl.TextSize = 11
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = StatusCard

-- Toggle Controls Card
local ToggleCard = Instance.new("Frame")
ToggleCard.Size = UDim2.new(1, -24, 0, 100)
ToggleCard.Position = UDim2.new(0, 12, 0, 114)
ToggleCard.BackgroundColor3 = Theme.Card
ToggleCard.BorderSizePixel = 0
ToggleCard.Parent = MainFrame

local TcCorner = Instance.new("UICorner")
TcCorner.CornerRadius = UDim.new(0, 8)
TcCorner.Parent = ToggleCard

-- Tombol Auto-Mine
local MineToggle = Instance.new("TextButton")
MineToggle.Size = UDim2.new(0.48, -4, 0, 40)
MineToggle.Position = UDim2.new(0, 8, 0, 8)
MineToggle.BackgroundColor3 = Config.AutoMine and Theme.AccentGreen or Theme.Sidebar
MineToggle.Text = Config.AutoMine and "AUTO MINE: ON" or "AUTO MINE: OFF"
MineToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MineToggle.Font = Enum.Font.GothamBold
MineToggle.TextSize = 11
MineToggle.Parent = ToggleCard

local MtCorner = Instance.new("UICorner")
MtCorner.CornerRadius = UDim.new(0, 6)
MtCorner.Parent = MineToggle

MineToggle.MouseButton1Click:Connect(function()
    Config.AutoMine = not Config.AutoMine
    MineToggle.BackgroundColor3 = Config.AutoMine and Theme.AccentGreen or Theme.Sidebar
    MineToggle.Text = Config.AutoMine and "AUTO MINE: ON" or "AUTO MINE: OFF"
    Log("Auto-Mine: " .. (Config.AutoMine and "Aktif" or "Nonaktif"))
end)

-- Tombol Auto-Sell
local SellToggle = Instance.new("TextButton")
SellToggle.Size = UDim2.new(0.48, -4, 0, 40)
SellToggle.Position = UDim2.new(0.52, 0, 0, 8)
SellToggle.BackgroundColor3 = Config.AutoSell and Theme.AccentGreen or Theme.Sidebar
SellToggle.Text = Config.AutoSell and "AUTO SELL: ON (20s)" or "AUTO SELL: OFF"
SellToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SellToggle.Font = Enum.Font.GothamBold
SellToggle.TextSize = 11
SellToggle.Parent = ToggleCard

local StCorner = Instance.new("UICorner")
StCorner.CornerRadius = UDim.new(0, 6)
StCorner.Parent = SellToggle

SellToggle.MouseButton1Click:Connect(function()
    Config.AutoSell = not Config.AutoSell
    SellToggle.BackgroundColor3 = Config.AutoSell and Theme.AccentGreen or Theme.Sidebar
    SellToggle.Text = Config.AutoSell and "AUTO SELL: ON (20s)" or "AUTO SELL: OFF"
    Log("Auto-Sell: " .. (Config.AutoSell and "Aktif" or "Nonaktif"))
end)

-- Tombol Filter Rarity Ore
local FilterBtn = Instance.new("TextButton")
FilterBtn.Size = UDim2.new(0.48, -4, 0, 36)
FilterBtn.Position = UDim2.new(0, 8, 0, 54)
FilterBtn.BackgroundColor3 = Theme.Sidebar
FilterBtn.Text = "Filter Ore: " .. Config.MineRarityFilter
FilterBtn.TextColor3 = Theme.Accent
FilterBtn.Font = Enum.Font.GothamBold
FilterBtn.TextSize = 10
FilterBtn.Parent = ToggleCard

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
    else
        Config.MineRarityFilter = "All"
    end
    FilterBtn.Text = "Filter Ore: " .. Config.MineRarityFilter
    Log("Filter Ore diubah ke: " .. Config.MineRarityFilter)
end)

-- Tombol Jual Manual Sekarang
local InstantSellBtn = Instance.new("TextButton")
InstantSellBtn.Size = UDim2.new(0.48, -4, 0, 36)
InstantSellBtn.Position = UDim2.new(0.52, 0, 0, 54)
InstantSellBtn.BackgroundColor3 = Theme.AccentOrange
InstantSellBtn.Text = "JUAL SEKARANG (INSTANT)"
InstantSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantSellBtn.Font = Enum.Font.GothamBold
InstantSellBtn.TextSize = 10
InstantSellBtn.Parent = ToggleCard

local IsCorner = Instance.new("UICorner")
IsCorner.CornerRadius = UDim.new(0, 6)
IsCorner.Parent = InstantSellBtn

InstantSellBtn.MouseButton1Click:Connect(function()
    PerformSell()
end)

-- Teleport Waypoints Card
local TeleportCard = Instance.new("Frame")
TeleportCard.Size = UDim2.new(1, -24, 0, 76)
TeleportCard.Position = UDim2.new(0, 12, 0, 220)
TeleportCard.BackgroundColor3 = Theme.Card
TeleportCard.BorderSizePixel = 0
TeleportCard.Parent = MainFrame

local TpcCorner = Instance.new("UICorner")
TpcCorner.CornerRadius = UDim.new(0, 8)
TpcCorner.Parent = TeleportCard

local TpTitle = Instance.new("TextLabel")
TpTitle.Size = UDim2.new(1, -16, 0, 18)
TpTitle.Position = UDim2.new(0, 8, 0, 4)
TpTitle.BackgroundTransparency = 1
TpTitle.Text = "TELEPORT CEPAT (WAYPOINTS):"
TpTitle.TextColor3 = Theme.AccentPurple
TpTitle.Font = Enum.Font.GothamBold
TpTitle.TextSize = 10
TpTitle.TextXAlignment = Enum.TextXAlignment.Left
TpTitle.Parent = TeleportCard

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
    btn.Size = UDim2.new(0.31, -4, 0, 22)
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    btn.Position = UDim2.new(col * 0.33 + 0.015, 0, 0, 24 + row * 24)
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
LogCard.Size = UDim2.new(1, -24, 1, -308)
LogCard.Position = UDim2.new(0, 12, 0, 302)
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
ConsoleText.Text = "Rockstar Mine siap..."
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
        StatusLbl.Text = "Plot: " .. plotName .. " | Target: " .. curOre .. "\nTotal Mined: " .. State.TotalMined .. " | Total Sold: " .. State.TotalSold
        if #State.Logs > 0 then
            ConsoleText.Text = table.concat(State.Logs, "\n")
        end
        task.wait(1.5)
    end
end)

Log("ROCKSTAR MINE v1.0 SIAP: Auto-farm & magnet loot aktif!")
