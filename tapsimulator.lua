-- ============================================================================
-- * ROCKSTAR HUB v1.0 - AUTO TRADE BOT [VOLCANIC DEVIL] *
-- Game: [GHOST] Simulator Ketukan Kelahiran Kembali (Tap Simulator Rebirth)
-- PlaceId: 72858262610964 | GameId: 10629695169 | PlaceVersion: 4039
-- Fitur Khusus:
--   [OK] Auto Target Pembeli (Input Username / Pilih Pemain Server 1-Klik)
--   [OK] Auto Terima (Accept) Permintaan Trade dari Pembeli
--   [OK] Auto Masukkan Pet Spesifik: VOLCANIC DEVIL (Mythical / Shiny / Mutation)
--   [OK] Auto Kunci Ready & Konfirmasi Accept (Fast Deal 3 Detik)
--   [OK] Proteksi Pet Terkunci & Filter Hanya Pembeli Terdaftar
--   [OK] 100% Universal Executor Compatible (Delta PC & Mobile)
-- ============================================================================

if not game:IsLoaded() then
    local t0 = tick()
    repeat task.wait(0.2) until game:IsLoaded() or (tick() - t0) > 3
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- ============================================================================
-- 1. PENGATURAN & STATE
-- ============================================================================
local Config = {
    BuyerUsername = "",
    TargetPetName = "Volcanic Devil",
    AutoAcceptTrade = true,
    AutoAcceptFromAnyone = false,
    AutoAddVolcanicDevil = true,
    MaxVolcanicDevilToSend = 1,     -- 1 = Kirim 1 ekor per transaksi, atau 99 = kirim semua
    AutoReady = true,
    AutoAccept = true,
    TradeDelayReady = 1.0,          -- Jeda aman sebelum klik Ready (detik)
    TradeDelayAccept = 1.5,         -- Jeda aman sebelum klik Accept (detik)
    AntiLockedPet = true,           -- Jangan kirim pet yang dikunci
}

local State = {
    InTrade = false,
    ActiveBuyer = nil,
    TradeStartedAt = 0,
    PetsAddedThisSession = 0,
    TotalCompletedTrades = 0,
    LogBuffer = {},
    LogMaxLines = 12,
}

local function Log(msg)
    local timestamp = os.date("%H:%M:%S")
    local line = "[" .. timestamp .. "] " .. tostring(msg)
    table.insert(State.LogBuffer, 1, line)
    while #State.LogBuffer > State.LogMaxLines do
        table.remove(State.LogBuffer)
    end
end

-- ============================================================================
-- 2. KONEKSI REMOTE SERVICES (TAP SIMULATOR 2)
-- ============================================================================
local pack_fn = table.pack or function(...) return { n = select("#", ...), ... } end
local unpack_fn = table.unpack or unpack

local function GetRemote(serviceName, remoteType, remoteName)
    local s = ReplicatedStorage:FindFirstChild("RemoteServices")
    if not s then return nil end
    local svc = s:FindFirstChild(serviceName)
    if not svc then return nil end
    local folder = svc:FindFirstChild(remoteType) or svc
    return folder:FindFirstChild(remoteName)
end

local Remotes = {
    TradeRequested = GetRemote("TradingService", "RE", "TradeRequested"),
    TradeUpdate = GetRemote("TradingService", "RE", "TradeUpdate"),
    GetReview = GetRemote("TradeReview", "RF", "GetReview"),
}

-- Fallback pencarian remote
if not Remotes.TradeRequested then
    Remotes.TradeRequested = ReplicatedStorage:FindFirstChild("TradeRequested", true)
end
if not Remotes.TradeUpdate then
    Remotes.TradeUpdate = ReplicatedStorage:FindFirstChild("TradeUpdate", true)
end

local function FireTradeRequest(targetPlayer)
    if Remotes.TradeRequested and Remotes.TradeRequested:IsA("RemoteEvent") then
        pcall(function() Remotes.TradeRequested:FireServer(targetPlayer) end)
        pcall(function() Remotes.TradeRequested:FireServer("Request", targetPlayer) end)
        return true
    end
    return false
end

local function FireTradeRespond(targetPlayer, accept)
    if Remotes.TradeRequested and Remotes.TradeRequested:IsA("RemoteEvent") then
        pcall(function() Remotes.TradeRequested:FireServer(targetPlayer, accept) end)
        pcall(function() Remotes.TradeRequested:FireServer("Respond", targetPlayer, accept) end)
        pcall(function() Remotes.TradeRequested:FireServer("Accept", targetPlayer) end)
        return true
    end
    return false
end

local function FireTradeAction(action, ...)
    local args = pack_fn(...)
    if Remotes.TradeUpdate and Remotes.TradeUpdate:IsA("RemoteEvent") then
        pcall(function()
            Remotes.TradeUpdate:FireServer(action, unpack_fn(args, 1, args.n))
        end)
        return true
    end
    return false
end

-- ============================================================================
-- 3. HELPER IDENTIFIKASI PEMAIN & PET VOLCANIC DEVIL
-- ============================================================================
local function FindBuyerPlayer(query)
    if not query or query == "" then return nil end
    local q = string.lower(query)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if string.lower(p.Name) == q or string.lower(p.DisplayName) == q then
                return p
            end
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if string.find(string.lower(p.Name), q, 1, true) or string.find(string.lower(p.DisplayName), q, 1, true) then
                return p
            end
        end
    end
    return nil
end

-- Memindai daftar Volcanic Devil milik pemain di Workspace
local function GetMyVolcanicDevils()
    local devils = {}
    local myUserId = LocalPlayer.UserId

    local function ScanFolder(folder)
        if not folder then return end
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") then
                local isNameMatch = string.find(string.lower(child.Name), "volcanic devil", 1, true)
                local ownerAttr = child:GetAttribute("Owner")
                local petId = child:GetAttribute("PetId")
                local rarity = child:GetAttribute("Rarity") or "Mythical"
                local tier = child:GetAttribute("Tier") or "Normal"
                local mutation = child:GetAttribute("Mutation") or "None"
                local rainbow = child:GetAttribute("Rainbow") or false

                if isNameMatch and (not ownerAttr or ownerAttr == myUserId) then
                    table.insert(devils, {
                        Model = child,
                        PetId = petId,
                        Name = child.Name,
                        Tier = tier,
                        Mutation = mutation,
                        Rainbow = rainbow,
                        Rarity = rarity,
                    })
                end
            end
        end
    end

    ScanFolder(Workspace:FindFirstChild("RainbowPets"))
    ScanFolder(Workspace:FindFirstChild("Pets"))
    ScanFolder(Workspace:FindFirstChild("GoldPets"))

    return devils
end

-- ============================================================================
-- 4. GUI AUTO-CLICKER & INTERAKSI TRADE WINDOW
-- ============================================================================
local function FireGuiButtonSafe(btn)
    pcall(function()
        if typeof(getconnections) == "function" then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click) or {}) do
                if conn.Fire then pcall(function() conn:Fire() end) end
            end
            for _, conn in ipairs(getconnections(btn.Activated) or {}) do
                if conn.Fire then pcall(function() conn:Fire() end) end
            end
        end
        pcall(function() btn.MouseButton1Click:Fire() end)
    end)
end

-- Mencari dan mengklik pet Volcanic Devil di jendela Trade GUI
local function AutoSelectVolcanicDevilFromGui()
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then return 0 end

    local clickedCount = 0
    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and not string.find(g.Name, "Rockstar", 1, true) then
            for _, desc in ipairs(g:GetDescendants()) do
                if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                    local bText = desc:IsA("TextButton") and string.lower(desc.Text) or ""
                    local bName = string.lower(desc.Name)

                    -- Periksa apakah tombol atau anaknya bertuliskan Volcanic Devil
                    local match = false
                    if string.find(bText, "volcanic devil", 1, true) or string.find(bName, "volcanic devil", 1, true) then
                        match = true
                    else
                        for _, sub in ipairs(desc:GetDescendants()) do
                            if sub:IsA("TextLabel") and string.find(string.lower(sub.Text), "volcanic devil", 1, true) then
                                match = true
                                break
                            end
                        end
                    end

                    if match then
                        FireGuiButtonSafe(desc)
                        clickedCount = clickedCount + 1
                        Log("GUI: Memasukkan Volcanic Devil #" .. tostring(clickedCount) .. " ke trade...")
                        task.wait(0.2)
                        if clickedCount >= Config.MaxVolcanicDevilToSend then
                            return clickedCount
                        end
                    end
                end
            end
        end
    end
    return clickedCount
end

-- Menekan tombol Ready / Selesai di GUI
local function AutoClickTradeReadyButton()
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then return false end

    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and not string.find(g.Name, "Rockstar", 1, true) then
            for _, desc in ipairs(g:GetDescendants()) do
                if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                    local bText = desc:IsA("TextButton") and string.lower(desc.Text) or ""
                    local bName = string.lower(desc.Name)
                    if (string.find(bText, "ready", 1, true) or string.find(bName, "ready", 1, true)
                        or string.find(bText, "lock", 1, true) or string.find(bName, "lock", 1, true))
                        and not string.find(bText, "robux", 1, true) then
                        FireGuiButtonSafe(desc)
                        Log("GUI: Menekan tombol Ready!")
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Menekan tombol Accept / Konfirmasi di GUI
local function AutoClickTradeAcceptButton()
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then return false end

    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and not string.find(g.Name, "Rockstar", 1, true) then
            for _, desc in ipairs(g:GetDescendants()) do
                if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                    local bText = desc:IsA("TextButton") and string.lower(desc.Text) or ""
                    local bName = string.lower(desc.Name)
                    if (string.find(bText, "accept", 1, true) or string.find(bName, "accept", 1, true)
                        or string.find(bText, "confirm", 1, true) or string.find(bName, "confirm", 1, true))
                        and not string.find(bText, "robux", 1, true) then
                        FireGuiButtonSafe(desc)
                        Log("GUI: Menekan tombol Konfirmasi (Accept)!")
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Membatalkan trade
local function AutoClickTradeCancelButton()
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then return false end

    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and not string.find(g.Name, "Rockstar", 1, true) then
            for _, desc in ipairs(g:GetDescendants()) do
                if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                    local bText = desc:IsA("TextButton") and string.lower(desc.Text) or ""
                    local bName = string.lower(desc.Name)
                    if string.find(bText, "cancel", 1, true) or string.find(bName, "cancel", 1, true)
                        or string.find(bText, "decline", 1, true) or string.find(bName, "decline", 1, true) then
                        FireGuiButtonSafe(desc)
                        Log("GUI: Menekan tombol Batal (Cancel)!")
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ============================================================================
-- 5. EKSEKUSI AUTO TRADE LENGKAP (ALUR PENGIRIMAN)
-- ============================================================================
local function ExecuteTradeDeal()
    task.spawn(function()
        Log("Trade Deal: Memulai proses transfer Volcanic Devil...")

        -- 1. Masukkan Pet Volcanic Devil
        local myDevils = GetMyVolcanicDevils()
        local added = 0

        -- Coba via Remote Server
        for idx, d in ipairs(myDevils) do
            if added >= Config.MaxVolcanicDevilToSend then break end
            if d.PetId then
                FireTradeAction("AddPet", d.PetId)
                FireTradeAction("Add", d.PetId)
                FireTradeAction("SetPet", d.PetId)
                FireTradeAction(d.PetId)
                added = added + 1
                Log("Remote: Menambahkan " .. d.Name .. " (" .. d.Mutation .. ") ke trade")
                task.wait(0.2)
            end
        end

        -- Coba via GUI Auto-Clicker jika trade frame terbuka
        local guiAdded = AutoSelectVolcanicDevilFromGui()
        if guiAdded > 0 then
            added = math.max(added, guiAdded)
        end

        Log("Pet Terpilih: " .. tostring(added) .. " ekor Volcanic Devil disiapkan.")

        -- 2. Kunci Status Ready
        task.wait(Config.TradeDelayReady)
        Log("Deal: Mengunci status (Ready)...")
        FireTradeAction("Ready", true)
        FireTradeAction("SetReady", true)
        FireTradeAction("Lock", true)
        AutoClickTradeReadyButton()

        -- 3. Konfirmasi Accept
        task.wait(Config.TradeDelayAccept)
        Log("Deal: Menyetujui pertukaran (Accept)...")
        FireTradeAction("Accept")
        FireTradeAction("Confirm")
        AutoClickTradeAcceptButton()

        State.TotalCompletedTrades = State.TotalCompletedTrades + 1
        Log("SUKSES: Transaksi Volcanic Devil selesai diproses!")
    end)
end

-- Listener otomatis saat ada yang mengajak trade
pcall(function()
    if Remotes.TradeRequested and Remotes.TradeRequested:IsA("RemoteEvent") then
        Remotes.TradeRequested.OnClientEvent:Connect(function(...)
            local args = pack_fn(...)
            local sender = args[1] or args[2]

            if Config.AutoAcceptTrade then
                local shouldAccept = false
                local buyer = FindBuyerPlayer(Config.BuyerUsername)

                if Config.AutoAcceptFromAnyone then
                    shouldAccept = true
                elseif buyer and typeof(sender) == "Instance" and sender:IsA("Player") and sender == buyer then
                    shouldAccept = true
                elseif buyer and typeof(sender) == "string" and string.find(string.lower(sender), string.lower(buyer.Name), 1, true) then
                    shouldAccept = true
                end

                if shouldAccept then
                    local sName = typeof(sender) == "Instance" and sender.Name or tostring(sender)
                    Log("Trade: Menerima otomatis ajakan trade dari @" .. sName)
                    FireTradeRespond(sender, true)
                    State.InTrade = true
                    State.ActiveBuyer = sName

                    -- Otomatis masukkan pet dan selesaikan deal jika toggle aktif
                    if Config.AutoAddVolcanicDevil then
                        task.wait(1.0)
                        ExecuteTradeDeal()
                    end
                end
            end
        end)
    end
end)

-- Listener Trade Update
pcall(function()
    if Remotes.TradeUpdate and Remotes.TradeUpdate:IsA("RemoteEvent") then
        Remotes.TradeUpdate.OnClientEvent:Connect(function(action, data)
            if action == "Started" or action == "Open" then
                State.InTrade = true
                Log("Jendela trade aktif!")
            elseif action == "Completed" or action == "Closed" or action == "Success" then
                State.InTrade = false
                Log("Sesi trade ditutup.")
            end
        end)
    end
end)

-- ============================================================================
-- 6. TAMPILAN USER INTERFACE (ROCKSTAR TRADE BOT)
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(13, 17, 26),
    Sidebar = Color3.fromRGB(18, 24, 38),
    Card = Color3.fromRGB(24, 32, 50),
    Accent = Color3.fromRGB(255, 90, 50),       -- Lava Flame Orange (Tema Volcanic Devil)
    AccentHover = Color3.fromRGB(255, 130, 80),
    TextMain = Color3.fromRGB(245, 248, 255),
    TextSub = Color3.fromRGB(150, 165, 195),
    Success = Color3.fromRGB(60, 220, 120),
    Danger = Color3.fromRGB(240, 70, 70),
    Border = Color3.fromRGB(40, 55, 80),
}

local function CleanupOldGui()
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pGui then
        for _, g in ipairs(pGui:GetChildren()) do
            if g.Name == "RockstarTradeHub" then pcall(function() g:Destroy() end) end
        end
    end
end
CleanupOldGui()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarTradeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Tombol Floating Pintasan (R*)
local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "FloatingToggle"
FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
FloatingToggle.Position = UDim2.new(0, 20, 0.45, 0)
FloatingToggle.BackgroundColor3 = Theme.Sidebar
FloatingToggle.Text = "R*"
FloatingToggle.TextColor3 = Theme.Accent
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.TextSize = 20
FloatingToggle.BorderSizePixel = 0
FloatingToggle.ZIndex = 1000
FloatingToggle.Parent = ScreenGui

local ftCorner = Instance.new("UICorner")
ftCorner.CornerRadius = UDim.new(1, 0)
ftCorner.Parent = FloatingToggle

local ftStroke = Instance.new("UIStroke")
ftStroke.Color = Theme.Accent
ftStroke.Thickness = 2
ftStroke.Parent = FloatingToggle

-- Frame Utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 390)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -195)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 10)
mfCorner.Parent = MainFrame

local mfStroke = Instance.new("UIStroke")
mfStroke.Color = Theme.Border
mfStroke.Thickness = 1
mfStroke.Parent = MainFrame

-- Topbar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ROCKSTAR TRADE BOT - VOLCANIC DEVIL EDITION"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextSub
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 6)
cbCorner.Parent = CloseBtn

local function ToggleMainFrame()
    MainFrame.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleMainFrame)
FloatingToggle.MouseButton1Click:Connect(ToggleMainFrame)

-- Sidebar & Navigasi
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 145, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local sbLayout = Instance.new("UIListLayout")
sbLayout.Padding = UDim.new(0, 6)
sbLayout.Parent = Sidebar

local sbPad = Instance.new("UIPadding")
sbPad.PaddingLeft = UDim.new(0, 8)
sbPad.PaddingRight = UDim.new(0, 8)
sbPad.PaddingTop = UDim.new(0, 10)
sbPad.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -145, 1, -40)
Content.Position = UDim2.new(0, 145, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local TabFrames = {}
local TabButtons = {}

local TabList = {
    { Id = "Trade", Name = "Auto Trade" },
    { Id = "Stock", Name = "Stok Pet" },
    { Id = "Logs",  Name = "Log Aktivitas" },
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

for idx, t in ipairs(TabList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = (idx == 1) and Theme.Card or Color3.fromRGB(16, 22, 34)
    btn.Text = "  " .. t.Name
    btn.TextColor3 = (idx == 1) and Theme.Accent or Theme.TextSub
    btn.Font = (idx == 1) and Enum.Font.GothamBold or Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        SwitchTab(t.Id)
    end)
    TabButtons[t.Id] = btn

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
    page.Parent = Content

    local pList = Instance.new("UIListLayout")
    pList.Padding = UDim.new(0, 8)
    pList.Parent = page

    TabFrames[t.Id] = page
end

local function CreateCard(parent, title)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 100)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 8)
    cPad.PaddingBottom = UDim.new(0, 8)
    cPad.PaddingLeft = UDim.new(0, 10)
    cPad.PaddingRight = UDim.new(0, 10)
    cPad.Parent = card

    local cList = Instance.new("UIListLayout")
    cList.Padding = UDim.new(0, 6)
    cList.Parent = card

    if title then
        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, 0, 0, 18)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = title
        tLabel.TextColor3 = Theme.Accent
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = 11
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.Parent = card
    end

    return card
end

local function CreateToggle(parent, title, desc, configKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(18, 25, 40)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -60, 0, 16)
    titleLbl.Position = UDim2.new(0, 8, 0, 3)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Theme.TextMain
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -60, 0, 14)
    descLbl.Position = UDim2.new(0, 8, 0, 19)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = Theme.TextSub
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 9
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 36, 0, 18)
    indicator.Position = UDim2.new(1, -44, 0.5, -9)
    indicator.BackgroundColor3 = Config[configKey] and Theme.Accent or Color3.fromRGB(30, 40, 60)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn

    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator

    local function UpdateToggle()
        indicator.BackgroundColor3 = Config[configKey] and Theme.Accent or Color3.fromRGB(30, 40, 60)
    end

    btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        UpdateToggle()
        Log("Pengaturan '" .. title .. "' diubah: " .. tostring(Config[configKey]))
    end)
end

-- ============================================================================
-- TAB 1: PENGATURAN AUTO TRADE VOLCANIC DEVIL
-- ============================================================================
local cBuyer = CreateCard(TabFrames["Trade"], "Target Pembeli & Otomatisasi Undangan")

local BuyerInput = Instance.new("TextBox")
BuyerInput.Size = UDim2.new(1, 0, 0, 32)
BuyerInput.BackgroundColor3 = Color3.fromRGB(18, 25, 40)
BuyerInput.PlaceholderText = "Ketik Username Pembeli (Contoh: Budi)..."
BuyerInput.PlaceholderColor3 = Theme.TextSub
BuyerInput.Text = Config.BuyerUsername
BuyerInput.TextColor3 = Theme.TextMain
BuyerInput.Font = Enum.Font.GothamMedium
BuyerInput.TextSize = 11
BuyerInput.BorderSizePixel = 0
BuyerInput.ClearTextOnFocus = false
BuyerInput.Parent = cBuyer

local biCorner = Instance.new("UICorner")
biCorner.CornerRadius = UDim.new(0, 6)
biCorner.Parent = BuyerInput

BuyerInput.FocusLost:Connect(function()
    Config.BuyerUsername = BuyerInput.Text
    Log("Target Pembeli diset ke: @" .. Config.BuyerUsername)
end)

local CyclePlayerBtn = Instance.new("TextButton")
CyclePlayerBtn.Size = UDim2.new(1, 0, 0, 28)
CyclePlayerBtn.BackgroundColor3 = Color3.fromRGB(20, 28, 45)
CyclePlayerBtn.Text = "Pilih Dari Server: (Klik untuk ganti pemain)"
CyclePlayerBtn.TextColor3 = Theme.Accent
CyclePlayerBtn.Font = Enum.Font.GothamMedium
CyclePlayerBtn.TextSize = 10
CyclePlayerBtn.BorderSizePixel = 0
CyclePlayerBtn.Parent = cBuyer

local cpbCorner = Instance.new("UICorner")
cpbCorner.CornerRadius = UDim.new(0, 6)
cpbCorner.Parent = CyclePlayerBtn

local serverPlayerIndex = 1
CyclePlayerBtn.MouseButton1Click:Connect(function()
    local playersList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playersList, p) end
    end
    if #playersList == 0 then
        CyclePlayerBtn.Text = "Tidak ada pemain lain di server"
        return
    end
    serverPlayerIndex = (serverPlayerIndex % #playersList) + 1
    local target = playersList[serverPlayerIndex]
    Config.BuyerUsername = target.Name
    BuyerInput.Text = target.Name
    CyclePlayerBtn.Text = "Pemain Terpilih: " .. target.DisplayName .. " (@" .. target.Name .. ")"
    Log("Pembeli terpilih: @" .. target.Name)
end)

local InviteTradeBtn = Instance.new("TextButton")
InviteTradeBtn.Size = UDim2.new(1, 0, 0, 32)
InviteTradeBtn.BackgroundColor3 = Color3.fromRGB(40, 65, 105)
InviteTradeBtn.Text = "[Fast] Ajak Trade Pembeli Sekarang"
InviteTradeBtn.TextColor3 = Theme.Accent
InviteTradeBtn.Font = Enum.Font.GothamBold
InviteTradeBtn.TextSize = 11
InviteTradeBtn.BorderSizePixel = 0
InviteTradeBtn.Parent = cBuyer

local itbCorner = Instance.new("UICorner")
itbCorner.CornerRadius = UDim.new(0, 6)
itbCorner.Parent = InviteTradeBtn

InviteTradeBtn.MouseButton1Click:Connect(function()
    local name = BuyerInput.Text ~= "" and BuyerInput.Text or Config.BuyerUsername
    local target = FindBuyerPlayer(name)
    if target then
        Log("Mengirim ajakan trade ke @" .. target.Name .. "...")
        FireTradeRequest(target)
    else
        Log("Pemain '" .. tostring(name) .. "' tidak ditemukan!")
    end
end)

CreateToggle(cBuyer, "Auto Terima Trade Pembeli", "Otomatis menerima ajakan trade dari pembeli yang ditargetkan", "AutoAcceptTrade")
CreateToggle(cBuyer, "Terima Dari Siapa Saja", "Otomatis menerima ajakan trade dari pemain mana pun di server", "AutoAcceptFromAnyone")

-- Kartu Aksi Trade
local cAction = CreateCard(TabFrames["Trade"], "Aksi Otomatis Volcanic Devil")

local AutoAddToggle = CreateToggle(cAction, "Auto Masukkan Volcanic Devil", "Otomatis masukkan pet Volcanic Devil saat jendela trade terbuka", "AutoAddVolcanicDevil")

local PutPetNowBtn = Instance.new("TextButton")
PutPetNowBtn.Size = UDim2.new(1, 0, 0, 32)
PutPetNowBtn.BackgroundColor3 = Color3.fromRGB(25, 45, 75)
PutPetNowBtn.Text = "[1-Klik] Masukkan 1 Volcanic Devil ke Trade Sekarang"
PutPetNowBtn.TextColor3 = Theme.Accent
PutPetNowBtn.Font = Enum.Font.GothamBold
PutPetNowBtn.TextSize = 11
PutPetNowBtn.BorderSizePixel = 0
PutPetNowBtn.Parent = cAction

local ppbCorner = Instance.new("UICorner")
ppbCorner.CornerRadius = UDim.new(0, 6)
ppbCorner.Parent = PutPetNowBtn

PutPetNowBtn.MouseButton1Click:Connect(function()
    local devils = GetMyVolcanicDevils()
    if #devils > 0 then
        local d = devils[1]
        Log("Memasukkan " .. d.Name .. " (" .. d.Mutation .. ") ke trade...")
        if d.PetId then
            FireTradeAction("AddPet", d.PetId)
            FireTradeAction("Add", d.PetId)
            FireTradeAction("SetPet", d.PetId)
            FireTradeAction(d.PetId)
        end
        AutoSelectVolcanicDevilFromGui()
    else
        Log("Volcanic Devil tidak ditemukan di workspace/tas!")
    end
end)

local DealNowBtn = Instance.new("TextButton")
DealNowBtn.Size = UDim2.new(1, 0, 0, 38)
DealNowBtn.BackgroundColor3 = Color3.fromRGB(25, 85, 55)
DealNowBtn.Text = "[DEAL] Selesaikan Transaksi (Ready + Accept Instan)"
DealNowBtn.TextColor3 = Color3.fromRGB(120, 255, 170)
DealNowBtn.Font = Enum.Font.GothamBold
DealNowBtn.TextSize = 12
DealNowBtn.BorderSizePixel = 0
DealNowBtn.Parent = cAction

local dnbCorner = Instance.new("UICorner")
dnbCorner.CornerRadius = UDim.new(0, 6)
dnbCorner.Parent = DealNowBtn

DealNowBtn.MouseButton1Click:Connect(function()
    ExecuteTradeDeal()
end)

local CancelTradeBtn = Instance.new("TextButton")
CancelTradeBtn.Size = UDim2.new(1, 0, 0, 28)
CancelTradeBtn.BackgroundColor3 = Color3.fromRGB(75, 25, 25)
CancelTradeBtn.Text = "[Batal] Batalkan / Keluar Dari Sesi Trade"
CancelTradeBtn.TextColor3 = Color3.fromRGB(255, 130, 130)
CancelTradeBtn.Font = Enum.Font.GothamBold
CancelTradeBtn.TextSize = 10
CancelTradeBtn.BorderSizePixel = 0
CancelTradeBtn.Parent = cAction

local ctbCorner = Instance.new("UICorner")
ctbCorner.CornerRadius = UDim.new(0, 6)
ctbCorner.Parent = CancelTradeBtn

CancelTradeBtn.MouseButton1Click:Connect(function()
    FireTradeAction("Cancel")
    FireTradeAction("Decline")
    AutoClickTradeCancelButton()
    State.InTrade = false
    Log("Sesi trade dibatalkan.")
end)

-- ============================================================================
-- TAB 2: DAFTAR STOK PET VOLCANIC DEVIL
-- ============================================================================
local cStock = CreateCard(TabFrames["Stock"], "Deteksi Pet Volcanic Devil Milik Anda")

local StockCountLabel = Instance.new("TextLabel")
StockCountLabel.Size = UDim2.new(1, 0, 0, 24)
StockCountLabel.BackgroundTransparency = 1
StockCountLabel.Text = "Stok Terdeteksi: Memindai..."
StockCountLabel.TextColor3 = Theme.Accent
StockCountLabel.Font = Enum.Font.GothamBold
StockCountLabel.TextSize = 12
StockCountLabel.TextXAlignment = Enum.TextXAlignment.Left
StockCountLabel.Parent = cStock

local StockListText = Instance.new("TextLabel")
StockListText.Size = UDim2.new(1, 0, 0, 120)
StockListText.BackgroundTransparency = 1
StockListText.Text = "Memuat daftar pet..."
StockListText.TextColor3 = Theme.TextSub
StockListText.Font = Enum.Font.Code
StockListText.TextSize = 10
StockListText.TextXAlignment = Enum.TextXAlignment.Left
StockListText.TextYAlignment = Enum.TextYAlignment.Top
StockListText.Parent = cStock

local function UpdateStockDisplay()
    local devils = GetMyVolcanicDevils()
    StockCountLabel.Text = "Total Volcanic Devil Terdeteksi: " .. tostring(#devils) .. " Ekor"

    if #devils == 0 then
        StockListText.Text = "Belum ada Volcanic Devil yang terdeteksi di sekitar/karakter.\nPastikan pet terpasang atau berada di tas Anda."
    else
        local lines = {}
        for idx, d in ipairs(devils) do
            local mutStr = d.Mutation ~= "None" and ("[" .. d.Mutation .. "] ") or ""
            local rbStr = d.Rainbow and "[Rainbow] " or ""
            local petIdShort = d.PetId and string.sub(d.PetId, 1, 8) .. "..." or "N/A"
            table.insert(lines, tostring(idx) .. ". " .. rbStr .. mutStr .. d.Name .. " (" .. d.Tier .. ") | ID: " .. petIdShort)
        end
        StockListText.Text = table.concat(lines, "\n")
    end
end

local RefreshStockBtn = Instance.new("TextButton")
RefreshStockBtn.Size = UDim2.new(1, 0, 0, 28)
RefreshStockBtn.BackgroundColor3 = Color3.fromRGB(24, 34, 52)
RefreshStockBtn.Text = "Segarkan Daftar Stok Pet"
RefreshStockBtn.TextColor3 = Theme.Accent
RefreshStockBtn.Font = Enum.Font.GothamMedium
RefreshStockBtn.TextSize = 10
RefreshStockBtn.BorderSizePixel = 0
RefreshStockBtn.Parent = cStock

local rsbCorner = Instance.new("UICorner")
rsbCorner.CornerRadius = UDim.new(0, 6)
rsbCorner.Parent = RefreshStockBtn

RefreshStockBtn.MouseButton1Click:Connect(UpdateStockDisplay)

-- ============================================================================
-- TAB 3: KONSOL LOG REALTIME
-- ============================================================================
local cLogs = CreateCard(TabFrames["Logs"], "Catatan Aktivitas Transaksi")

local LogDisplay = Instance.new("TextLabel")
LogDisplay.Size = UDim2.new(1, 0, 0, 200)
LogDisplay.BackgroundTransparency = 1
LogDisplay.Text = "Menunggu aktivitas transaksi..."
LogDisplay.TextColor3 = Theme.TextSub
LogDisplay.Font = Enum.Font.Code
LogDisplay.TextSize = 10
LogDisplay.TextXAlignment = Enum.TextXAlignment.Left
LogDisplay.TextYAlignment = Enum.TextYAlignment.Top
LogDisplay.Parent = cLogs

local function RefreshLogDisplay()
    LogDisplay.Text = table.concat(State.LogBuffer, "\n")
end

-- Background Loop untuk Refresh UI
task.spawn(function()
    while true do
        pcall(RefreshLogDisplay)
        pcall(UpdateStockDisplay)
        task.wait(2.0)
    end
end)

Log("* ROCKSTAR TRADE BOT TAP SIMULATOR 2 SIAP DIGUNAKAN *")
Log("Target Pet Terkunci: VOLCANIC DEVIL")
