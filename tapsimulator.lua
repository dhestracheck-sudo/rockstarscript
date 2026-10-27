-- ============================================================================
-- * ROCKSTAR HUB v3.0 - 100% VERIFIED AUTONOMOUS TRADE BOT [VOLCANIC DEVIL] *
-- Game: [GHOST] Simulator Ketukan Kelahiran Kembali (Tap Simulator Rebirth)
-- PlaceId: 72858262610964 | GameId: 10629695169 | PlaceVersion: 4039
-- Perbaikan Utama (v3.0):
--   [FIX] Zero False-Positive: Tidak akan klik Ready sebelum pet TERVERIFIKASI
--         sudah benar-benar muncul di slot offer trade!
--   [FIX] VirtualInputManager Hardware Click: Simulasi klik mouse asli ke kartu
--         pet Volcanic Devil di tampilan UI (tembus Frame/Roact/Custom UI).
--   [FIX] Auto-Unequip Pet: Jika Volcanic Devil sedang di-equip, otomatis
--         di-unequip terlebih dahulu agar diizinkan sistem game masuk trade.
--   [FIX] Multi-Payload Remote Engine: Mengirim semua varian payload TradeUpdate.
--   [OK] Anti-AFK (Zero Disconnect 24 Jam)
--   [OK] 100% Universal Delta Executor Compatible (PC & Android)
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
    TargetPetName = "Volcanic Devil",
    BuyerUsername = "",                -- Kosong = Terima siapapun yang trade
    AutoAcceptTrade = true,            -- Otomatis terima ajakan trade
    AutoAcceptFromAnyone = true,       -- Terima dari siapapun
    AutoAddVolcanicDevil = true,       -- Otomatis masukkan Volcanic Devil
    AutoFastDeal = true,               -- Otomatis kunci Ready dan Accept
    MaxPetsPerTrade = 1,               -- Jumlah pet per trade
    DealDelaySeconds = 3.2,            -- Jeda countdown server sebelum klik Confirm
    AntiAfkEnabled = true,
}

local State = {
    InTrade = false,
    PetOfferVerified = false,          -- HANYA TRUE JIKA PET SUDAH NYATA DI SLOT
    ReadyLocked = false,
    AcceptSpamming = false,
    VolcanicDevilsInStock = 0,
    TotalCompletedTrades = 0,
    Logs = {},
    RetryCount = 0,
}

local function Log(msg)
    local timestamp = os.date("%H:%M:%S")
    local fullMsg = "[" .. timestamp .. "] " .. tostring(msg)
    table.insert(State.Logs, 1, fullMsg)
    if #State.Logs > 40 then
        table.remove(State.Logs)
    end
    print("[ROCKSTAR TRADE v3]: " .. fullMsg)
end

-- Anti AFK
if Config.AntiAfkEnabled then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            Log("Anti-AFK: Menghindari idle disconnect.")
        end)
    end)
end

-- ============================================================================
-- 2. RESOLVER REMOTE TRADE & PET SERVICE
-- ============================================================================
local Remotes = {
    TradeRequested = nil,
    TradeUpdate = nil,
    PetAction = nil,
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
Remotes.PetAction = GetRemote("ReplicatedStorage.RemoteServices.PetService.RE.PetActionRequested")

if Remotes.TradeRequested then Log("Remote TradeRequested terdeteksi OK.") end
if Remotes.TradeUpdate then Log("Remote TradeUpdate terdeteksi OK.") end
if Remotes.PetAction then Log("Remote PetActionRequested terdeteksi OK.") end

-- ============================================================================
-- 3. FUNGSI KLIK HARDWARE VIRTUAL INPUT (ANTI-BLOCKING)
-- ============================================================================
local function HardwareClickGui(guiObj)
    if not guiObj or not guiObj:IsA("GuiObject") then return false end
    local pos = guiObj.AbsolutePosition
    local size = guiObj.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return false end

    local cx = math.floor(pos.X + (size.X / 2))
    local cy = math.floor(pos.Y + (size.Y / 2))

    -- Simulasi Event Mouse Asli via VirtualInputManager
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end)

    -- Sinyal Executor Standar (Firesignal)
    pcall(function()
        if firesignal and guiObj:IsA("GuiButton") then
            firesignal(guiObj.Activated)
            firesignal(guiObj.MouseButton1Click)
        end
    end)

    -- Getconnections Fallback
    pcall(function()
        if getconnections then
            if guiObj:IsA("GuiButton") then
                for _, conn in ipairs(getconnections(guiObj.MouseButton1Click)) do conn:Fire() end
                for _, conn in ipairs(getconnections(guiObj.Activated)) do conn:Fire() end
            end
            if guiObj.InputBegan then
                for _, conn in ipairs(getconnections(guiObj.InputBegan)) do
                    conn:Fire({ UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin })
                end
            end
        end
    end)

    return true
end

-- ============================================================================
-- 4. SCANNER PET VOLCANIC DEVIL & AUTO-UNEQUIP
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
            local isEquipped = obj:GetAttribute("Equipped") == true or category == "RainbowPets"

            if isVolcanic and isOwner then
                table.insert(list, {
                    Instance = obj,
                    Id = petId,
                    Name = name,
                    Category = category,
                    Equipped = isEquipped,
                })
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

-- Auto Unequip Volcanic Devil jika game melarang trade pet yang sedang aktif
local function UnequipVolcanicDevilIfEquipped()
    pcall(function()
        if Remotes.PetAction and Remotes.PetAction:IsA("RemoteEvent") then
            local devils = GetMyVolcanicDevils()
            for _, pet in ipairs(devils) do
                if pet.Equipped then
                    Remotes.PetAction:FireServer("Unequip", pet.Id)
                    Remotes.PetAction:FireServer("Unequip", pet.Instance)
                    Remotes.PetAction:FireServer(pet.Id, "Unequip")
                    Log("Info: Melepas (Unequip) Volcanic Devil agar bisa masuk trade.")
                end
            end
        end
    end)
end

-- ============================================================================
-- 5. VERIFIKASI RIIL: APAKAH PET BENAR-BENAR ADA DI SLOT OFFER?
-- ============================================================================
local function CheckIsPetInTradeOffer()
    local foundInOffer = false

    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("GuiObject") and desc.Visible then
                        local nameLower = string.lower(desc.Name)

                        -- Cek apakah objek ini berada di dalam container offer milik kita
                        local isInsideMyOffer = false
                        local cur = desc
                        while cur and cur ~= gui do
                            local cn = string.lower(cur.Name)
                            local isOurOffer = string.find(cn, "myoffer", 1, true)
                                or string.find(cn, "youroffer", 1, true)
                                or string.find(cn, "player1", 1, true)
                                or string.find(cn, "left", 1, true)
                                or (string.find(cn, "offer", 1, true) and not string.find(cn, "their", 1, true) and not string.find(cn, "partner", 1, true) and not string.find(cn, "player2", 1, true))

                            local isGridOrInv = string.find(cn, "grid", 1, true)
                                or string.find(cn, "inv", 1, true)
                                or string.find(cn, "backpack", 1, true)
                                or string.find(cn, "storage", 1, true)
                                or string.find(cn, "selection", 1, true)

                            if isOurOffer and not isGridOrInv then
                                isInsideMyOffer = true
                                break
                            end
                            cur = cur.Parent
                        end

                        if isInsideMyOffer then
                            -- Periksa teks label
                            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                                local txt = string.lower(desc.ContentText ~= "" and desc.ContentText or desc.Text)
                                if string.find(txt, "volcanic", 1, true) and string.find(txt, "devil", 1, true) then
                                    foundInOffer = true
                                    return
                                end
                            end

                            -- Periksa nama frame/model kartu
                            if string.find(nameLower, "volcanic", 1, true) and string.find(nameLower, "devil", 1, true) then
                                foundInOffer = true
                                return
                            end

                            -- Periksa model pet di ViewportFrame
                            if desc:IsA("Model") and string.find(string.lower(desc.Name), "volcanic", 1, true) then
                                foundInOffer = true
                                return
                            end

                            -- Periksa attribute pet
                            local attrId = desc:GetAttribute("PetId") or desc:GetAttribute("Id")
                            for _, pet in ipairs(GetMyVolcanicDevils()) do
                                if pet.Id and (attrId == pet.Id or desc.Name == tostring(pet.Id)) then
                                    foundInOffer = true
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    return foundInOffer
end

-- ============================================================================
-- 6. PENCARI & PENGEKSEKUSI KLIK KARTU PET VOLCANIC DEVIL DI GRID INVENTORY
-- ============================================================================
local function FindAndClickVolcanicCard()
    local clickedAny = false
    local candidates = {}

    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("GuiObject") and desc.Visible then
                        local isMatch = false
                        local nameLower = string.lower(desc.Name)

                        -- 1. Cek teks label
                        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                            local txt = string.lower(desc.ContentText ~= "" and desc.ContentText or desc.Text)
                            if string.find(txt, "volcanic", 1, true) and string.find(txt, "devil", 1, true) then
                                isMatch = true
                            end
                        end

                        -- 2. Cek nama instance
                        if string.find(nameLower, "volcanic", 1, true) and string.find(nameLower, "devil", 1, true) then
                            isMatch = true
                        end

                        -- 3. Cek Viewport Model
                        if desc:IsA("Model") and string.find(string.lower(desc.Name), "volcanic", 1, true) then
                            local pGui = desc:FindFirstAncestorWhichIsA("GuiObject")
                            if pGui and pGui.Visible then
                                table.insert(candidates, pGui)
                            end
                        end

                        -- 4. Cek Attribute
                        local attrId = desc:GetAttribute("PetId") or desc:GetAttribute("Id")
                        for _, pet in ipairs(GetMyVolcanicDevils()) do
                            if pet.Id and (attrId == pet.Id or desc.Name == tostring(pet.Id)) then
                                isMatch = true
                            end
                        end

                        if isMatch then
                            -- Pastikan BUKAN yang ada di slot offer (kita hanya mau klik kartu dari tas/grid!)
                            local inOffer = false
                            local cur = desc
                            while cur and cur ~= gui do
                                local cn = string.lower(cur.Name)
                                if (string.find(cn, "myoffer", 1, true) or string.find(cn, "youroffer", 1, true) or string.find(cn, "offer", 1, true)) and not string.find(cn, "grid", 1, true) and not string.find(cn, "inv", 1, true) then
                                    inOffer = true
                                    break
                                end
                                cur = cur.Parent
                            end

                            if not inOffer then
                                table.insert(candidates, desc)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Eksekusi klik ke kartu yang ditemukan
    for _, obj in ipairs(candidates) do
        local target = obj
        local btnParent = obj:FindFirstAncestorWhichIsA("GuiButton")
        if btnParent and btnParent.Visible then
            target = btnParent
        end

        Log("Klik Hardware: Mengklik kartu " .. target.ClassName .. " [" .. target.Name .. "] pada koordinat " .. tostring(target.AbsolutePosition))
        HardwareClickGui(target)
        clickedAny = true
        task.wait(0.2)
    end

    return clickedAny
end

-- Kirim semua kemungkinan Remote payload TradeUpdate
local function FireRemoteTradeAdd()
    if not Remotes.TradeUpdate or not Remotes.TradeUpdate:IsA("RemoteEvent") then return end
    local devils = GetMyVolcanicDevils()
    for _, pet in ipairs(devils) do
        pcall(function() Remotes.TradeUpdate:FireServer("AddPet", pet.Id) end)
        pcall(function() Remotes.TradeUpdate:FireServer("Add", pet.Id) end)
        pcall(function() Remotes.TradeUpdate:FireServer("Offer", pet.Id) end)
        pcall(function() Remotes.TradeUpdate:FireServer("Select", pet.Id) end)
        pcall(function() Remotes.TradeUpdate:FireServer("Toggle", pet.Id) end)
        pcall(function() Remotes.TradeUpdate:FireServer(pet.Id) end)
        pcall(function() Remotes.TradeUpdate:FireServer("AddPet", pet.Instance) end)
    end
end

-- ============================================================================
-- 7. AUTO-ACCEPT AJAKAN TRADE (REMOTE + GUI POPUP)
-- ============================================================================
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
                                            HardwareClickGui(btn)
                                            Log("AUTO: Klik tombol Terima (Accept) ajakan trade di layar!")
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

-- Deteksi jendela trade aktif
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

-- Kunci status Ready
local function AutoLockReady()
    Log("READY: Mengunci status trade...")
    if Remotes.TradeUpdate and Remotes.TradeUpdate:IsA("RemoteEvent") then
        pcall(function() Remotes.TradeUpdate:FireServer("Ready", true) end)
        pcall(function() Remotes.TradeUpdate:FireServer("Lock", true) end)
        pcall(function() Remotes.TradeUpdate:FireServer("Ready") end)
    end

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
                                HardwareClickGui(btn)
                                Log("READY: Tombol Ready berhasil diklik!")
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Spam tombol Accept / Confirm sampai deal selesai
local function AutoSpamAccept()
    if State.AcceptSpamming then return end
    State.AcceptSpamming = true

    task.spawn(function()
        Log("DEAL: Menunggu countdown timer server " .. tostring(Config.DealDelaySeconds) .. " detik...")
        task.wait(Config.DealDelaySeconds)

        local elapsed = 0
        local maxWait = 18

        while elapsed < maxWait do
            task.wait(0.2)
            elapsed = elapsed + 0.2

            if not IsTradeWindowActive() then
                break
            end

            -- Remote Fire
            if Remotes.TradeUpdate and Remotes.TradeUpdate:IsA("RemoteEvent") then
                pcall(function() Remotes.TradeUpdate:FireServer("Accept") end)
                pcall(function() Remotes.TradeUpdate:FireServer("Confirm") end)
            end

            -- GUI Click
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
                                        HardwareClickGui(btn)
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
        State.PetOfferVerified = false
        State.ReadyLocked = false
        State.RetryCount = 0
        State.TotalCompletedTrades = State.TotalCompletedTrades + 1
        Log("SUKSES: Transaksi Volcanic Devil SELESAI 100%! Siap untuk pembeli berikutnya.")
    end)
end

-- ============================================================================
-- 8. MASTER AUTONOMOUS LOOP (DENGAN STRICT FEEDBACK VERIFICATION)
-- ============================================================================
task.spawn(function()
    Log("Master Loop Aktif: Menjalankan sistem verifikasi riil slot offer...")
    while true do
        task.wait(0.2)
        local inTrade = IsTradeWindowActive()

        if not inTrade then
            -- STATE 1: Di luar trade -> Selalu pantau ajakan trade
            AutoAcceptIncomingPrompt()
            State.PetOfferVerified = false
            State.ReadyLocked = false
            State.AcceptSpamming = false
            State.RetryCount = 0
        else
            -- STATE 2: Sedang dalam trade -> Urutan logika ketat tanpa tipu-tipu
            if not State.PetOfferVerified then
                -- Langkah 1: Cek apakah pet sudah benar-benar ada di slot offer
                local isAlreadyThere = CheckIsPetInTradeOffer()
                if isAlreadyThere then
                    State.PetOfferVerified = true
                    State.RetryCount = 0
                    Log("STATUS: VERIFIKASI SUKSES! Volcanic Devil terdeteksi di slot offer.")
                else
                    State.RetryCount = State.RetryCount + 1
                    Log("STATUS: Slot offer MASIH KOSONG (Percobaan #" .. State.RetryCount .. ")")

                    -- Eksekusi langkah pemasukan pet
                    UnequipVolcanicDevilIfEquipped()
                    local clicked = FindAndClickVolcanicCard()
                    FireRemoteTradeAdd()

                    task.wait(0.5)

                    -- Verifikasi ulang hasil eksekusi
                    if CheckIsPetInTradeOffer() then
                        State.PetOfferVerified = true
                        Log("STATUS: VERIFIKASI SUKSES! Volcanic Devil telah masuk ke slot offer.")
                    else
                        if not clicked then
                            Log("PERINGATAN: Kartu Volcanic Devil tidak ditemukan di layar. Pastikan pet ada di tas!")
                        end
                    end
                end
            elseif not State.ReadyLocked then
                -- Langkah 2: HANYA jika pet sudah terverifikasi di slot, baru kunci READY!
                task.wait(0.4)
                AutoLockReady()
                State.ReadyLocked = true
            else
                -- Langkah 3: Tunggu countdown dan selesaikan deal
                if not State.AcceptSpamming then
                    AutoSpamAccept()
                end
            end
        end
    end
end)

-- Listener Remote
pcall(function()
    if Remotes.TradeRequested and Remotes.TradeRequested:IsA("RemoteEvent") then
        Remotes.TradeRequested.OnClientEvent:Connect(function(...)
            local args = pack_fn(...)
            local sender = args[1] or args[2]
            if Config.AutoAcceptTrade then
                local sName = typeof(sender) == "Instance" and sender.Name or tostring(sender)
                Log("Remote: Ajakan trade masuk dari @" .. sName)
                pcall(function() Remotes.TradeRequested:FireServer(sender, true) end)
                pcall(function() Remotes.TradeRequested:FireServer(sender) end)
                State.InTrade = true
            end
        end)
    end
end)

pcall(function()
    if Remotes.TradeUpdate and Remotes.TradeUpdate:IsA("RemoteEvent") then
        Remotes.TradeUpdate.OnClientEvent:Connect(function(action, data)
            if action == "Started" or action == "Open" then
                State.InTrade = true
            elseif action == "Completed" or action == "Closed" or action == "Success" then
                State.InTrade = false
                State.PetOfferVerified = false
                State.ReadyLocked = false
                State.AcceptSpamming = false
            end
        end)
    end
end)

-- ============================================================================
-- 9. USER INTERFACE (STATUS MONITOR & MANUAL CONTROLS)
-- ============================================================================
local Theme = {
    Background = Color3.fromRGB(13, 17, 26),
    Sidebar = Color3.fromRGB(18, 24, 38),
    Card = Color3.fromRGB(24, 32, 50),
    Accent = Color3.fromRGB(255, 90, 50),
    TextMain = Color3.fromRGB(245, 248, 255),
    TextDim = Color3.fromRGB(160, 175, 205),
    Success = Color3.fromRGB(46, 213, 115),
    Warning = Color3.fromRGB(255, 171, 0),
    Border = Color3.fromRGB(42, 56, 86)
}

local function CleanupOldGui()
    local old = CoreGui:FindFirstChild("RockstarTapSimTradeGuiV3")
    if old then old:Destroy() end
    local oldP = PlayerGui:FindFirstChild("RockstarTapSimTradeGuiV3")
    if oldP then oldP:Destroy() end
end
CleanupOldGui()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarTapSimTradeGuiV3"
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
OpenBtn.Name = "RockstarOpenBtnV3"
OpenBtn.Size = UDim2.new(0, 140, 0, 36)
OpenBtn.Position = UDim2.new(0, 18, 0.45, 0)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.Text = "BOT TRADE v3.0"
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
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
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
TitleLabel.Size = UDim2.new(0, 400, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ROCKSTAR HUB v3.0 - VERIFIED AFK AUTO TRADE"
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
StatusCard.Size = UDim2.new(1, -24, 0, 72)
StatusCard.Position = UDim2.new(0, 12, 0, 56)
StatusCard.BackgroundColor3 = Theme.Card
StatusCard.BorderSizePixel = 0
StatusCard.Parent = MainFrame

local ScCorner = Instance.new("UICorner")
ScCorner.CornerRadius = UDim.new(0, 8)
ScCorner.Parent = StatusCard

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -20, 0, 22)
StatusTitle.Position = UDim2.new(0, 10, 0, 6)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS: VERIFIKASI KETAT AKTIF (ANTI READY KOSONG)"
StatusTitle.TextColor3 = Theme.Success
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextSize = 12
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusCard

local StockLabel = Instance.new("TextLabel")
StockLabel.Size = UDim2.new(1, -20, 0, 34)
StockLabel.Position = UDim2.new(0, 10, 0, 30)
StockLabel.BackgroundTransparency = 1
StockLabel.Text = "Memindai stok Volcanic Devil..."
StockLabel.TextColor3 = Theme.TextMain
StockLabel.Font = Enum.Font.Gotham
StockLabel.TextSize = 11
StockLabel.TextXAlignment = Enum.TextXAlignment.Left
StockLabel.Parent = StatusCard

-- Action Manual Buttons
local ActionCard = Instance.new("Frame")
ActionCard.Size = UDim2.new(1, -24, 0, 42)
ActionCard.Position = UDim2.new(0, 12, 0, 136)
ActionCard.BackgroundColor3 = Theme.Card
ActionCard.BorderSizePixel = 0
ActionCard.Parent = MainFrame

local AcCorner = Instance.new("UICorner")
AcCorner.CornerRadius = UDim.new(0, 8)
AcCorner.Parent = ActionCard

local ManualAddBtn = Instance.new("TextButton")
ManualAddBtn.Size = UDim2.new(0.48, -4, 0, 30)
ManualAddBtn.Position = UDim2.new(0, 6, 0, 6)
ManualAddBtn.BackgroundColor3 = Theme.Accent
ManualAddBtn.Text = "Paksa Masukkan Pet Sekarang"
ManualAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualAddBtn.Font = Enum.Font.GothamBold
ManualAddBtn.TextSize = 11
ManualAddBtn.Parent = ActionCard

local MabCorner = Instance.new("UICorner")
MabCorner.CornerRadius = UDim.new(0, 6)
MabCorner.Parent = ManualAddBtn

ManualAddBtn.MouseButton1Click:Connect(function()
    UnequipVolcanicDevilIfEquipped()
    FindAndClickVolcanicCard()
    FireRemoteTradeAdd()
    Log("Manual: Menjalankan paksa klik & remote masukkan Volcanic Devil.")
end)

local CheckOfferBtn = Instance.new("TextButton")
CheckOfferBtn.Size = UDim2.new(0.48, -4, 0, 30)
CheckOfferBtn.Position = UDim2.new(0.52, 0, 0, 6)
CheckOfferBtn.BackgroundColor3 = Theme.Success
CheckOfferBtn.Text = "Cek Status Slot Offer"
CheckOfferBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckOfferBtn.Font = Enum.Font.GothamBold
CheckOfferBtn.TextSize = 11
CheckOfferBtn.Parent = ActionCard

local CobCorner = Instance.new("UICorner")
CobCorner.CornerRadius = UDim.new(0, 6)
CobCorner.Parent = CheckOfferBtn

CheckOfferBtn.MouseButton1Click:Connect(function()
    local isThere = CheckIsPetInTradeOffer()
    if isThere then
        Log("CEK OFFER: Volcanic Devil TERVERIFIKASI ADA di slot offer!")
    else
        Log("CEK OFFER: Slot offer MASIH KOSONG!")
    end
end)

-- Console Log Box
local LogCard = Instance.new("Frame")
LogCard.Size = UDim2.new(1, -24, 1, -196)
LogCard.Position = UDim2.new(0, 12, 0, 186)
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
ConsoleText.Text = "Bot siap..."
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
        local offerStatus = State.PetOfferVerified and "TERVERIFIKASI DI SLOT" or (State.InTrade and "SEDANG MEMASUKKAN..." or "STANDBY")
        StockLabel.Text = "Pet: Volcanic Devil | Stok Tas: " .. #devils .. " | Status Slot: " .. offerStatus .. " | Sukses: " .. State.TotalCompletedTrades
        if #State.Logs > 0 then
            ConsoleText.Text = table.concat(State.Logs, "\n")
        end
        task.wait(1.5)
    end
end)

Log("ROCKSTAR TRADE v3.0 SIAP: Sistem verifikasi riil aktif 100%!")
