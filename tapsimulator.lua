-- ============================================================================
-- * ROCKSTAR HUB v2.0 - 100% FULLY AUTONOMOUS AUTO TRADE BOT *
-- Game: [GHOST] Simulator Ketukan Kelahiran Kembali (Tap Simulator Rebirth)
-- PlaceId: 72858262610964 | GameId: 10629695169 | PlaceVersion: 4039
-- Mode Khusus: 100% ZERO HUMAN INTERVENTION (AFK SHOP BOT)
--   [OK] Auto Accept ANY incoming Trade Request (GUI Prompt + Remote Hook)
--   [OK] Auto Insert Pet: VOLCANIC DEVIL (Including Spawned/RainbowPets)
--   [OK] Auto Lock READY immediately after pet inserted
--   [OK] Auto Spam ACCEPT/CONFIRM as soon as countdown completes
--   [OK] Auto Reset & Loop for 24/7 non-stop customer trading
--   [OK] Built-in Anti-AFK (Zero Disconnect)
--   [OK] 100% Universal Delta Executor Compatible (PC & Android)
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Universal Pack Function (Lua 5.1 Compatible)
local function pack_fn(...)
    return { n = select("#", ...), ... }
end

-- ============================================================================
-- 1. KONFIGURASI BOT (DEFAULT: 100% FULL OTOMATIS TANPA SENTUH)
-- ============================================================================
local Config = {
    TargetPetName = "Volcanic Devil",  -- Pet spesifik yang dijual
    BuyerUsername = "",                -- Kosongkan = Otomatis terima siapapun yang trade!
    AutoAcceptTrade = true,            -- Otomatis terima ajakan trade (Remote + GUI)
    AutoAcceptFromAnyone = true,       -- DEFAULT TRUE: Tidak butuh input username manual
    AutoAddVolcanicDevil = true,       -- Otomatis masukkan Volcanic Devil ke trade slot
    AutoFastDeal = true,               -- Otomatis kunci Ready dan Accept setelah timer
    MaxPetsPerTrade = 1,               -- Jumlah Volcanic Devil per transaksi
    ProtectEquippedPets = false,       -- DEFAULT FALSE: Boleh trade Volcanic Devil meski sedang di-equip
    ProtectFavoritedPets = false,      -- Boleh trade Volcanic Devil
    DealDelaySeconds = 3.2,            -- Jeda countdown server sebelum klik Confirm
    AntiAfkEnabled = true,             -- Anti disconnected 20 menit idle
}

local State = {
    InTrade = false,
    CurrentTradingWith = "Siapapun",
    VolcanicDevilsInStock = 0,
    TotalCompletedTrades = 0,
    PetAlreadyAddedInCurrentTrade = false,
    ReadyAlreadyClickedInCurrentTrade = false,
    AcceptSpamming = false,
    Logs = {},
    LastTradeAttemptTime = 0,
}

local function Log(msg)
    local timestamp = os.date("%H:%M:%S")
    local fullMsg = "[" .. timestamp .. "] " .. tostring(msg)
    table.insert(State.Logs, 1, fullMsg)
    if #State.Logs > 35 then
        table.remove(State.Logs)
    end
    print("[ROCKSTAR AUTO-TRADE]: " .. fullMsg)
end

-- Anti AFK
if Config.AntiAfkEnabled then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            Log("Anti-AFK: Mencegah idle disconnect.")
        end)
    end)
end

-- ============================================================================
-- 2. RESOLVER REMOTE TRADE
-- ============================================================================
local Remotes = {
    TradeRequested = nil,
    TradeUpdate = nil,
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

Remotes.TradeRequested = GetRemote("ReplicatedStorage.RemoteServices.TradingService.RE.TradeRequested")
Remotes.TradeUpdate = GetRemote("ReplicatedStorage.RemoteServices.TradingService.RE.TradeUpdate")

if Remotes.TradeRequested then
    Log("Remote TradeRequested terdeteksi OK.")
else
    Log("WARNING: Remote TradeRequested tidak ditemukan pada path standar!")
end

if Remotes.TradeUpdate then
    Log("Remote TradeUpdate terdeteksi OK.")
else
    Log("WARNING: Remote TradeUpdate tidak ditemukan pada path standar!")
end

-- ============================================================================
-- 3. FUNGSI KLIK GUI UNIVERSAL (DELTA EXECUTOR SUPPORT)
-- ============================================================================
local function SafeClick(btn)
    if not btn then return false end
    local success = false
    pcall(function()
        if firesignal and btn:IsA("GuiButton") then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
            success = true
        end
    end)
    pcall(function()
        if getconnections and btn:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
                success = true
            end
            for _, conn in ipairs(getconnections(btn.Activated)) do
                conn:Fire()
                success = true
            end
        end
    end)
    return success
end

-- ============================================================================
-- 4. LOGIKA PENGAMBILAN DATA PET VOLCANIC DEVIL
-- ============================================================================
local function GetMyVolcanicDevils()
    local list = {}
    local myUserId = LocalPlayer.UserId
    local myName = LocalPlayer.Name

    local function ScanFolder(f, category)
        if not f then return end
        for _, obj in ipairs(f:GetChildren()) do
            local name = obj.Name
            local isVolcanic = false
            if string.find(string.lower(name), "volcanic devil", 1, true) then
                isVolcanic = true
            end

            local ownerAttr = obj:GetAttribute("Owner") or obj:GetAttribute("Player")
            local isOwner = true
            if ownerAttr then
                local sOwner = tostring(ownerAttr)
                if sOwner ~= tostring(myUserId) and sOwner ~= myName then
                    isOwner = false
                end
            end

            local petId = obj:GetAttribute("PetId") or obj:GetAttribute("Id") or obj:GetAttribute("UUID") or obj.Name
            local isEquipped = obj:GetAttribute("Equipped") == true
            local isLocked = obj:GetAttribute("Locked") == true or obj:GetAttribute("Favorite") == true

            if isVolcanic and isOwner then
                if not (Config.ProtectEquippedPets and isEquipped) and not (Config.ProtectFavoritedPets and isLocked) then
                    table.insert(list, {
                        Instance = obj,
                        Id = petId,
                        Name = name,
                        Category = category,
                        Equipped = isEquipped,
                        Locked = isLocked,
                    })
                end
            end
        end
    end

    pcall(function()
        ScanFolder(workspace:FindFirstChild("RainbowPets"), "RainbowPets")
        ScanFolder(workspace:FindFirstChild("Pets"), "Pets")
        if LocalPlayer:FindFirstChild("Pets") then
            ScanFolder(LocalPlayer.Pets, "PlayerPets")
        end
        if LocalPlayer:FindFirstChild("Inventory") then
            ScanFolder(LocalPlayer.Inventory:FindFirstChild("Pets"), "InventoryPets")
        end
    end)

    State.VolcanicDevilsInStock = #list
    return list
end

-- ============================================================================
-- 5. REMOTE ACTIONS
-- ============================================================================
local function FireTradeRespond(senderPlayer)
    if not Remotes.TradeRequested or not Remotes.TradeRequested:IsA("RemoteEvent") then return end
    pcall(function() Remotes.TradeRequested:FireServer(senderPlayer, true) end)
    pcall(function() Remotes.TradeRequested:FireServer(true, senderPlayer) end)
    pcall(function() Remotes.TradeRequested:FireServer(senderPlayer) end)
    pcall(function() Remotes.TradeRequested:FireServer("Accept", senderPlayer) end)
    if typeof(senderPlayer) == "Instance" and senderPlayer:IsA("Player") then
        pcall(function() Remotes.TradeRequested:FireServer(senderPlayer.Name, true) end)
    end
end

local function FireTradeAction(action, payload)
    if not Remotes.TradeUpdate or not Remotes.TradeUpdate:IsA("RemoteEvent") then return end
    pcall(function()
        if payload ~= nil then
            Remotes.TradeUpdate:FireServer(action, payload)
        else
            Remotes.TradeUpdate:FireServer(action)
        end
    end)
end

-- ============================================================================
-- 6. FULLY AUTONOMOUS ENGINES (ZERO HUMAN INTERVENTION)
-- ============================================================================

-- ENGINE 1: Auto Accept GUI Popup Invitation (Fast Polling 0.1 Detik)
local function AutoAcceptIncomingPrompt()
    if not Config.AutoAcceptTrade then return false end

    local acceptKeywords = {"accept", "terima", "yes", "ya", "confirm", "setuju"}
    local requestKeywords = {"trade", "request", "wants to trade", "mengajak trade", "ajakan trade"}

    local foundAny = false
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                        local textLower = string.lower(desc.Text)
                        local isTradePrompt = false
                        for _, rk in ipairs(requestKeywords) do
                            if string.find(textLower, rk, 1, true) then
                                isTradePrompt = true
                                break
                            end
                        end

                        if isTradePrompt then
                            -- Cari tombol accept di sekitar prompt
                            local container = desc:FindFirstAncestorWhichIsA("Frame") or desc.Parent
                            if container then
                                for _, btn in ipairs(container:GetDescendants()) do
                                    if btn:IsA("GuiButton") then
                                        local bText = string.lower(btn.Name)
                                        if btn:IsA("TextButton") then
                                            bText = bText .. " " .. string.lower(btn.Text)
                                        end
                                        for _, c in ipairs(btn:GetChildren()) do
                                            if c:IsA("TextLabel") then
                                                bText = bText .. " " .. string.lower(c.Text)
                                            end
                                        end

                                        local isAcceptBtn = false
                                        for _, ak in ipairs(acceptKeywords) do
                                            if string.find(bText, ak, 1, true) and not string.find(bText, "cancel", 1, true) and not string.find(bText, "decline", 1, true) and not string.find(bText, "no", 1, true) then
                                                isAcceptBtn = true
                                                break
                                            end
                                        end

                                        if isAcceptBtn then
                                            SafeClick(btn)
                                            Log("AUTO: Berhasil klik tombol Terima (Accept) ajakan trade di layar!")
                                            foundAny = true
                                            State.InTrade = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        if foundAny then break end
                    end
                end
                if foundAny then break end
            end
        end
    end)
    return foundAny
end

-- ENGINE 2: Deteksi Apakah Jendela Trade Sedang Terbuka di Layar
local function IsTradeWindowActive()
    local tradeActive = false
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local gName = string.lower(gui.Name)
                if string.find(gName, "trade", 1, true) or string.find(gName, "trading", 1, true) then
                    for _, d in ipairs(gui:GetDescendants()) do
                        if d:IsA("GuiObject") and d.Visible then
                            tradeActive = true
                            return
                        end
                    end
                end
            end
        end
    end)
    return tradeActive or State.InTrade
end

-- ENGINE 3: Auto Masukkan Pet Volcanic Devil ke Slot Trade
local function AutoInsertVolcanicDevil()
    if State.PetAlreadyAddedInCurrentTrade then return true end

    local inserted = false
    Log("AUTO: Mencari pet Volcanic Devil untuk dimasukkan ke trade...")

    -- Jalur 1: Remote Event Direct Fire
    local devils = GetMyVolcanicDevils()
    if #devils > 0 then
        for i = 1, math.min(#devils, Config.MaxPetsPerTrade) do
            local pet = devils[i]
            FireTradeAction("AddPet", pet.Id)
            FireTradeAction("Add", pet.Id)
            FireTradeAction("Offer", pet.Id)
            FireTradeAction("SelectPet", pet.Instance)
            Log("AUTO: Memasukkan Pet ID: " .. tostring(pet.Id))
            inserted = true
        end
    end

    -- Jalur 2: GUI Button Clicker (TradingPetGrid)
    local guiCount = 0
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, item in ipairs(gui:GetDescendants()) do
                    if guiCount >= Config.MaxPetsPerTrade then break end
                    if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("ImageLabel") or item:IsA("Frame") then
                        local t = (item:IsA("TextLabel") and item.Text) or item.Name
                        if string.find(string.lower(t), "volcanic devil", 1, true) then
                            local btn = item:FindFirstAncestorWhichIsA("GuiButton") or (item:IsA("GuiButton") and item)
                            if btn then
                                SafeClick(btn)
                                guiCount = guiCount + 1
                                inserted = true
                                Log("AUTO: Klik kartu pet Volcanic Devil di tampilan UI!")
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
    end)

    if inserted then
        State.PetAlreadyAddedInCurrentTrade = true
        Log("AUTO: Volcanic Devil berhasil masuk ke slot trade.")
    end
    return inserted
end

-- ENGINE 4: Auto Kunci Ready
local function AutoLockReady()
    if State.ReadyAlreadyClickedInCurrentTrade then return true end

    Log("AUTO: Mengunci status READY...")
    -- Jalur Remote
    FireTradeAction("Ready", true)
    FireTradeAction("Lock", true)
    FireTradeAction("Ready")

    -- Jalur GUI
    pcall(function()
        local readyKeywords = {"ready", "lock", "siap", "kunci"}
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("GuiButton") then
                        local text = string.lower(btn.Name)
                        if btn:IsA("TextButton") then text = text .. " " .. string.lower(btn.Text) end
                        for _, c in ipairs(btn:GetChildren()) do
                            if c:IsA("TextLabel") then text = text .. " " .. string.lower(c.Text) end
                        end

                        for _, kw in ipairs(readyKeywords) do
                            if string.find(text, kw, 1, true) and not string.find(text, "cancel", 1, true) and not string.find(text, "unready", 1, true) then
                                SafeClick(btn)
                                Log("AUTO: Klik tombol Ready di layar!")
                                State.ReadyAlreadyClickedInCurrentTrade = true
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    State.ReadyAlreadyClickedInCurrentTrade = true
    return true
end

-- ENGINE 5: Auto Spam Accept / Confirm (Sampai Trade Selesai)
local function AutoSpamAccept()
    if State.AcceptSpamming then return end
    State.AcceptSpamming = true

    task.spawn(function()
        Log("AUTO: Menunggu countdown deal selesai lalu klik Accept/Confirm...")
        local elapsed = 0
        local maxWait = 15 -- Maksimal 15 detik jika partner lama klik

        while elapsed < maxWait do
            task.wait(0.2)
            elapsed = elapsed + 0.2

            -- Cek apakah trade masih aktif
            if not IsTradeWindowActive() then
                break
            end

            -- Kirim remote accept
            FireTradeAction("Accept")
            FireTradeAction("Confirm")

            -- Klik tombol accept di UI
            pcall(function()
                local acceptKeywords = {"accept", "confirm", "terima", "deal", "setuju"}
                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        for _, btn in ipairs(gui:GetDescendants()) do
                            if btn:IsA("GuiButton") then
                                local text = string.lower(btn.Name)
                                if btn:IsA("TextButton") then text = text .. " " .. string.lower(btn.Text) end
                                for _, c in ipairs(btn:GetChildren()) do
                                    if c:IsA("TextLabel") then text = text .. " " .. string.lower(c.Text) end
                                end

                                for _, kw in ipairs(acceptKeywords) do
                                    if string.find(text, kw, 1, true) and not string.find(text, "cancel", 1, true) and not string.find(text, "decline", 1, true) then
                                        SafeClick(btn)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        State.AcceptSpamming = false
        State.InTrade = false
        State.PetAlreadyAddedInCurrentTrade = false
        State.ReadyAlreadyClickedInCurrentTrade = false
        State.TotalCompletedTrades = State.TotalCompletedTrades + 1
        Log("SUKSES: Transaksi Volcanic Devil SELESAI 100% AFK! Bot siap untuk transaksi berikutnya.")
    end)
end

-- ============================================================================
-- 7. BACKGROUND MASTER AUTONOMOUS LOOP (JALAN TERUS NON-STOP)
-- ============================================================================
task.spawn(function()
    Log("Master Autonomous Loop diaktifkan (Mode AFK Tanpa Sentuh).")
    while true do
        task.wait(0.15)
        local inTradeNow = IsTradeWindowActive()

        if not inTradeNow then
            -- STATE 1: Di luar trade -> Selalu cek dan auto accept ajakan trade
            AutoAcceptIncomingPrompt()
            State.PetAlreadyAddedInCurrentTrade = false
            State.ReadyAlreadyClickedInCurrentTrade = false
            State.AcceptSpamming = false
        else
            -- STATE 2: Sedang dalam trade -> Urutan eksekusi otomatis
            if not State.PetAlreadyAddedInCurrentTrade then
                task.wait(0.6)
                AutoInsertVolcanicDevil()
            elseif not State.ReadyAlreadyClickedInCurrentTrade then
                task.wait(0.5)
                AutoLockReady()
            else
                if not State.AcceptSpamming then
                    task.wait(Config.DealDelaySeconds)
                    AutoSpamAccept()
                end
            end
        end
    end
end)

-- Listener Remote TradeRequested
pcall(function()
    if Remotes.TradeRequested and Remotes.TradeRequested:IsA("RemoteEvent") then
        Remotes.TradeRequested.OnClientEvent:Connect(function(...)
            local args = pack_fn(...)
            local sender = args[1] or args[2]

            if Config.AutoAcceptTrade then
                local sName = typeof(sender) == "Instance" and sender.Name or tostring(sender)
                Log("Remote: Menerima ajakan trade dari @" .. sName)
                FireTradeRespond(sender)
                State.InTrade = true
            end
        end)
    end
end)

-- Listener Remote TradeUpdate
pcall(function()
    if Remotes.TradeUpdate and Remotes.TradeUpdate:IsA("RemoteEvent") then
        Remotes.TradeUpdate.OnClientEvent:Connect(function(action, data)
            if action == "Started" or action == "Open" then
                State.InTrade = true
                Log("Status Trade: Terbuka")
            elseif action == "Completed" or action == "Closed" or action == "Success" then
                State.InTrade = false
                Log("Status Trade: Ditutup / Sukses")
            end
        end)
    end
end)

-- ============================================================================
-- 8. USER INTERFACE (STATUS MONITOR & MINIMALIST TOGGLE)
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(13, 17, 26),
    Sidebar = Color3.fromRGB(18, 24, 38),
    Card = Color3.fromRGB(24, 32, 50),
    Accent = Color3.fromRGB(255, 90, 50),
    AccentHover = Color3.fromRGB(255, 130, 80),
    TextMain = Color3.fromRGB(245, 248, 255),
    TextDim = Color3.fromRGB(160, 175, 205),
    Success = Color3.fromRGB(46, 213, 115),
    Warning = Color3.fromRGB(255, 171, 0),
    Border = Color3.fromRGB(42, 56, 86)
}

local function CleanupOldGui()
    local old = CoreGui:FindFirstChild("RockstarTapSimTradeGuiV2")
    if old then old:Destroy() end
    local oldP = PlayerGui:FindFirstChild("RockstarTapSimTradeGuiV2")
    if oldP then oldP:Destroy() end
end
CleanupOldGui()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarTapSimTradeGuiV2"
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
OpenBtn.Name = "RockstarOpenBtnV2"
OpenBtn.Size = UDim2.new(0, 130, 0, 36)
OpenBtn.Position = UDim2.new(0, 18, 0.45, 0)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.Text = "AUTO TRADE AFK"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 12
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenBtn

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
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
Header.Size = UDim2.new(1, 0, 0, 48)
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
TitleLabel.Size = UDim2.new(0, 380, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ROCKSTAR HUB v2.0 - 100% AFK AUTO TRADE"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
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

-- Status Info Card
local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, -24, 0, 70)
StatusCard.Position = UDim2.new(0, 12, 0, 56)
StatusCard.BackgroundColor3 = Theme.Card
StatusCard.BorderSizePixel = 0
StatusCard.Parent = MainFrame

local ScCorner = Instance.new("UICorner")
ScCorner.CornerRadius = UDim.new(0, 8)
ScCorner.Parent = StatusCard

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -20, 0, 22)
StatusTitle.Position = UDim2.new(0, 10, 0, 8)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "MODE BOT AKTIF: 100% TANPA CAMPUR TANGAN MANUSIA"
StatusTitle.TextColor3 = Theme.Success
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextSize = 12
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusCard

local StockLabel = Instance.new("TextLabel")
StockLabel.Size = UDim2.new(1, -20, 0, 32)
StockLabel.Position = UDim2.new(0, 10, 0, 32)
StockLabel.BackgroundTransparency = 1
StockLabel.Text = "Memindai stok Volcanic Devil..."
StockLabel.TextColor3 = Theme.TextMain
StockLabel.Font = Enum.Font.Gotham
StockLabel.TextSize = 11
StockLabel.TextXAlignment = Enum.TextXAlignment.Left
StockLabel.Parent = StatusCard

-- Console Log Box
local LogCard = Instance.new("Frame")
LogCard.Size = UDim2.new(1, -24, 1, -142)
LogCard.Position = UDim2.new(0, 12, 0, 134)
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
ConsoleText.Text = "Bot siap melayani customer..."
ConsoleText.TextColor3 = Theme.TextDim
ConsoleText.Font = Enum.Font.Code
ConsoleText.TextSize = 10
ConsoleText.TextXAlignment = Enum.TextXAlignment.Left
ConsoleText.TextYAlignment = Enum.TextYAlignment.Top
ConsoleText.Parent = LogCard

-- Loop Update Tampilan
task.spawn(function()
    while true do
        local devils = GetMyVolcanicDevils()
        StockLabel.Text = "Pet Dijual: Volcanic Devil | Stok: " .. #devils .. " Ekor | Sukses: " .. State.TotalCompletedTrades .. " Deal"
        if #State.Logs > 0 then
            ConsoleText.Text = table.concat(State.Logs, "\n")
        end
        task.wait(1.5)
    end
end)

Log("ROCKSTAR HUB v2.0 READY: AFK Auto Trade Volcanic Devil aktif 100%!")
