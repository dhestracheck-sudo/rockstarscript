-- ============================================================================
-- ★ ROCKSTAR HUB (CYBER BLUE EDITION) // CUSTOM UI REDESIGN & NO DISCORD LINK
-- Menghapus Total Logo "SR", Menghapus Link Discord, & Merombak Tampilan UI
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Abaikan GUI bawaan sistem Roblox
local IgnoredSystemGuis = {
    ["RobloxGui"] = true,
    ["TopBarApp"] = true,
    ["Chat"] = true,
    ["PlayerList"] = true,
    ["TouchGui"] = true,
    ["Backpack"] = true,
    ["DevConsoleMaster"] = true,
    ["PurchasePrompt"] = true,
    ["PurchasePromptApp"] = true,
    ["RobloxNetworkPauseNotification"] = true,
    ["TeleportEffectGui"] = true
}

local function IsInsideSystemGui(inst)
    local curr = inst
    while curr do
        if IgnoredSystemGuis[curr.Name] then
            return true
        end
        curr = curr.Parent
    end
    return false
end

-- ============================================================================
-- 1. PALET WARNA ROCKSTAR CYBER BLUE (MEROMBAK SEMUA WARNA LAMA)
-- ============================================================================
local function ToRockstarBlue(c, isBackground)
    if typeof(c) ~= "Color3" then return c end

    -- Jangan ubah warna teks Putih bersih
    if c.R > 0.85 and c.G > 0.85 and c.B > 0.85 then
        return Color3.fromRGB(240, 248, 255)
    end

    -- Jika ini warna latar gelap (Hitam/Coklat Tua/Abu Gelap), ubah jadi Midnight Navy Blue
    local maxVal = math.max(c.R, c.G, c.B)
    if maxVal < 0.28 then
        if maxVal < 0.10 then
            return Color3.fromRGB(9, 15, 28)   -- Deep Midnight Blue
        elseif maxVal < 0.18 then
            return Color3.fromRGB(14, 23, 42)  -- Dark Royal Navy
        else
            return Color3.fromRGB(20, 34, 62)  -- Slate Blue Card
        end
    end

    -- Jika warna Oranye / Merah / Coklat / Ungu (Aksen lama), ubah jadi Electric Cyan-Blue
    if c.R > c.B + 0.03 then
        return Color3.fromRGB(0, 165, 255)
    end

    return c
end

local function ToRockstarSequence(seq)
    if typeof(seq) ~= "ColorSequence" then return seq end
    local keypoints = {}
    for _, kp in ipairs(seq.Keypoints) do
        table.insert(keypoints, ColorSequenceKeypoint.new(kp.Time, ToRockstarBlue(kp.Value, false)))
    end
    return ColorSequence.new(keypoints)
end

-- ============================================================================
-- 2. HAPUS TOTAL LINK DISCORD & UBAH JUDUL JADI "★ ROCKSTAR"
-- ============================================================================
local function ProcessAndCleanText(inst)
    local txt = inst.Text
    if type(txt) ~= "string" or txt == "" then return end

    local lower = string.lower(txt)

    -- A. HAPUS LINK DISCORD & SEMBUNYIKAN IKON DISCORD DI SEBELAHNYA
    if string.find(lower, "discord", 1, true) or string.find(lower, "lynxx", 1, true) then
        inst.Text = ""
        inst.Visible = false
        -- Sembunyikan juga ikon Discord & garis pemisah di dalam container yang sama
        if inst.Parent then
            for _, sib in ipairs(inst.Parent:GetChildren()) do
                if sib ~= inst and (sib:IsA("ImageLabel") or sib:IsA("Frame")) then
                    -- Jika posisinya dekat di sebelah kanan atas (area Discord)
                    if sib.Position.X.Scale > 0.45 or sib.Position.X.Offset > 250 or sib.Size.X.Offset <= 28 then
                        sib.Visible = false
                    end
                end
            end
        end
        return
    end

    -- B. UBAH JUDUL LYNX / SERENITY MENJADI "★ ROCKSTAR"
    if lower == "lynx" or lower == "serenity" or lower == "serenity hub" then
        inst.Text = "★ ROCKSTAR"
        inst.TextColor3 = Color3.fromRGB(35, 195, 255)
        return
    end

    local res = txt
    res = string.gsub(res, "[Ll][Yy][Nn][Xx][Xx]?", "Rockstar")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]%s*[Hh][Uu][Bb]", "Rockstar Hub")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]", "Rockstar")
    if res ~= txt then
        inst.Text = res
    end
end

-- ============================================================================
-- 3. ROMBAK TOMBOL FLOATING "SR" JADI KAPSUL "★ ROCKSTAR" & HAPUS GAMBAR "SR"
-- ============================================================================
local ProtectedTabWords = {
    "main", "automation", "shop", "event", "webhook", "settings", "config", "search"
}

local function HasProtectedTabSibling(inst)
    local p1 = inst.Parent
    local p2 = p1 and p1.Parent
    for _, container in ipairs({p1, p2}) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") then
                    local t = string.lower((child:IsA("TextBox") and child.PlaceholderText or "") .. " " .. (child.Text or ""))
                    for _, word in ipairs(ProtectedTabWords) do
                        if string.find(t, word, 1, true) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function IsInsideScrollingContent(inst)
    local curr = inst.Parent
    while curr do
        if curr:IsA("ScrollingFrame") then
            return true
        end
        curr = curr.Parent
    end
    return false
end

local function WipeLogoAndMakeRockstar(imgInst)
    if not imgInst then return end
    if IsInsideSystemGui(imgInst) then return end
    if IsInsideScrollingContent(imgInst) then return end
    if HasProtectedTabSibling(imgInst) then return end

    pcall(function()
        -- 1. Hapus paksa gambar "SR" / Planet
        imgInst.Image = ""
        imgInst.ImageTransparency = 1

        -- 2. Cek apakah ini berada di dalam Tombol Floating (Kotak "SR")
        local parentBtn = imgInst.Parent
        if parentBtn and parentBtn:IsA("GuiObject") then
            -- Jika ukuran kotak parent kecil/sedang (Tombol Floating "SR"), ubah bentuknya jadi Kapsul Panjang "★ ROCKSTAR"!
            local w = parentBtn.Size.X.Offset
            local h = parentBtn.Size.Y.Offset
            if (w >= 28 and w <= 115 and h >= 28 and h <= 115) or parentBtn.Parent:IsA("ScreenGui") then
                parentBtn.Size = UDim2.new(0, 130, 0, 38)
                parentBtn.BackgroundColor3 = Color3.fromRGB(10, 20, 38)
                parentBtn.BackgroundTransparency = 0.05

                local corner = parentBtn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", parentBtn)
                corner.CornerRadius = UDim.new(1, 0) -- Bentuk Kapsul Pill

                local stroke = parentBtn:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", parentBtn)
                stroke.Color = Color3.fromRGB(0, 175, 255)
                stroke.Thickness = 2

                if not parentBtn:FindFirstChild("RockstarCapsuleTitle") then
                    local title = Instance.new("TextLabel")
                    title.Name = "RockstarCapsuleTitle"
                    title.Size = UDim2.new(1, 0, 1, 0)
                    title.BackgroundTransparency = 1
                    title.Text = "★ ROCKSTAR"
                    title.TextColor3 = Color3.fromRGB(55, 205, 255)
                    title.Font = Enum.Font.GothamBlack
                    title.TextSize = 13
                    title.Active = false
                    title.Parent = parentBtn
                end
                return
            end
        end

        -- 3. Jika ini adalah logo di dalam TopBar (sebelah tulisan Rockstar), sembunyikan total karena judul sudah memakai "★ ROCKSTAR"
        imgInst.Visible = false
    end)
end

-- ============================================================================
-- 4. TERAPKAN DESAIN BARU KE SELURUH KOMPONEN UI
-- ============================================================================
local ConnectedSignals = setmetatable({}, {__mode = "k"})

local function ApplyRockstarStyle(inst)
    if not inst or IsInsideSystemGui(inst) then return end

    pcall(function()
        -- A. Cek & Hapus Gambar Logo "SR" / Planet Setiap Kali Ditemukan (Tanpa Dikunci!)
        if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            if not IsInsideScrollingContent(inst) and not HasProtectedTabSibling(inst) then
                WipeLogoAndMakeRockstar(inst)
            else
                local c = ToRockstarBlue(inst.ImageColor3, false)
                if c ~= inst.ImageColor3 then
                    inst.ImageColor3 = c
                end
            end
        end

        -- B. Ubah Warna Background & Bentuk Sudut
        if inst:IsA("GuiObject") then
            local newBg = ToRockstarBlue(inst.BackgroundColor3, true)
            if newBg ~= inst.BackgroundColor3 then
                inst.BackgroundColor3 = newBg
            end
        end

        -- C. Bersihkan Link Discord & Ubah Judul Teks
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            ProcessAndCleanText(inst)
            local newTc = ToRockstarBlue(inst.TextColor3, false)
            if newTc ~= inst.TextColor3 then
                inst.TextColor3 = newTc
            end
        end

        -- D. ScrollBar Biru
        if inst:IsA("ScrollingFrame") then
            inst.ScrollBarImageColor3 = Color3.fromRGB(0, 165, 255)
        end

        -- E. Garis Pinggir (UIStroke) Biru Elektrik
        if inst:IsA("UIStroke") then
            inst.Color = Color3.fromRGB(28, 85, 160)
        end

        -- F. Gradasi Biru
        if inst:IsA("UIGradient") then
            inst.Color = ToRockstarSequence(inst.Color)
        end

        -- Pasang listener perubahan properti sekali saja per objek
        if not ConnectedSignals[inst] then
            ConnectedSignals[inst] = true

            if inst:IsA("GuiObject") then
                inst:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                    local c = ToRockstarBlue(inst.BackgroundColor3, true)
                    if c ~= inst.BackgroundColor3 then inst.BackgroundColor3 = c end
                end)
            end

            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                inst:GetPropertyChangedSignal("Text"):Connect(function()
                    ProcessAndCleanText(inst)
                end)
                inst:GetPropertyChangedSignal("TextColor3"):Connect(function()
                    local c = ToRockstarBlue(inst.TextColor3, false)
                    if c ~= inst.TextColor3 then inst.TextColor3 = c end
                end)
            end

            if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                inst:GetPropertyChangedSignal("Image"):Connect(function()
                    if not IsInsideScrollingContent(inst) and not HasProtectedTabSibling(inst) then
                        WipeLogoAndMakeRockstar(inst)
                    end
                end)
                inst:GetPropertyChangedSignal("Size"):Connect(function()
                    if not IsInsideScrollingContent(inst) and not HasProtectedTabSibling(inst) then
                        WipeLogoAndMakeRockstar(inst)
                    end
                end)
            end
        end
    end)
end

local function WatchGuiContainer(container)
    if not container then return end
    pcall(function()
        for _, desc in ipairs(container:GetDescendants()) do
            ApplyRockstarStyle(desc)
        end
        container.DescendantAdded:Connect(function(desc)
            ApplyRockstarStyle(desc)
            task.delay(0.1, function() ApplyRockstarStyle(desc) end)
            task.delay(0.5, function() ApplyRockstarStyle(desc) end)
        end)
    end)
end

pcall(function()
    if typeof(gethui) == "function" then
        WatchGuiContainer(gethui())
    end
end)
pcall(function() WatchGuiContainer(CoreGui) end)
pcall(function()
    if LocalPlayer then
        WatchGuiContainer(LocalPlayer:WaitForChild("PlayerGui", 5))
    end
end)

-- ============================================================================
-- 5. LOADER UTAMA (100% FITUR BEKERJA)
-- ============================================================================
local BASE = "https://raw.githubusercontent.com/MUshihara/Serenity-hub/main/"
local isMM2 = game.PlaceId == 142823291 or game.GameId == 66654135
local isStealASeed = game.PlaceId == 122216176958450 or game.GameId == 10764328008
local isLiftACube = game.PlaceId == 109530157755211 or game.GameId == 10759860151
local isStealAnAnimeEgg = game.PlaceId == 76377501906469 or game.GameId == 10747748563
local isBreakAndStealAnEgg = game.PlaceId == 114326934417838 or game.GameId == 10765288803
local isRideAPet = game.PlaceId == 124216119978534 or game.GameId == 10035204815
local isStrengthGrowArm = game.PlaceId == 86259628805375 or game.GameId == 10310999762
local isAnimeDice = game.PlaceId == 113290951185459 or game.GameId == 10708913337
local isLootToForge = game.PlaceId == 118805555015549 or game.GameId == 10684750879
local isLiftRockForEggs = game.PlaceId == 76731343328034 or game.GameId == 10768316438

if isMM2 or isStealASeed or isLiftACube or isStealAnAnimeEgg or isBreakAndStealAnEgg or isRideAPet or isStrengthGrowArm or isAnimeDice or isLootToForge or isLiftRockForEggs then
    local env = (type(getgenv) == "function" and getgenv()) or _G
    env.__SERENITY_PAYLOAD_AUTHORIZED = true
    _G.__SERENITY_PAYLOAD_AUTHORIZED = true
end

local target
local chunkName

if isMM2 then
    target = "dist/runtime/games/MM2.lua"
    chunkName = "@SerenityHub/Game-MM2"
elseif isStealASeed then
    target = "dist/runtime/games/stealaseed.lua"
    chunkName = "@SerenityHub/Game-StealASeed"
elseif isLiftACube then
    target = "dist/runtime/games/liftacube.lua"
    chunkName = "@SerenityHub/Game-LiftACube"
elseif isStealAnAnimeEgg then
    target = "dist/runtime/games/StealAnAnimeEgg.lua"
    chunkName = "@SerenityHub/Game-StealAnAnimeEgg"
elseif isBreakAndStealAnEgg then
    target = "dist/runtime/games/breakandstealegg.lua"
    chunkName = "@SerenityHub/Game-BreakAndStealAnEgg"
elseif isRideAPet then
    target = "dist/runtime/games/rideapet.lua"
    chunkName = "@SerenityHub/Game-RideAPet"
elseif isStrengthGrowArm then
    target = "dist/runtime/games/+1strengthgrowarm.lua"
    chunkName = "@SerenityHub/Game-StrengthGrowArm"
elseif isAnimeDice then
    target = "dist/runtime/games/animedice.lua"
    chunkName = "@SerenityHub/Game-AnimeDice"
elseif isLootToForge then
    target = "dist/runtime/games/loottoforge.lua"
    chunkName = "@SerenityHub/Game-LootToForge"
elseif isLiftRockForEggs then
    target = "dist/runtime/games/LiftRockForEggs.lua"
    chunkName = "@SerenityHub/Game-LiftRockForEggs"
else
    target = "dist/loader.lua"
    chunkName = "@SerenityHub/CurrentLoader"
end

local url = BASE .. target .. "?cb=" .. tostring(os.time()) .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(url, true)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[ROCKSTAR HUB] Loader is unavailable. Try again in a moment.", 0)
end

local fn, err = loadstring(source, chunkName)
source = nil

if not fn then
    error("[ROCKSTAR HUB] Loader compile failed: " .. tostring(err), 0)
end

-- Matikan permanen copy link Discord
pcall(function()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    env.__SERENITY_DISCORD_COPIED = true
    env.__SERENITY_DISCORD_NOTICE_AT = os.time() + 99999999
end)

local results = table.pack(fn())

-- Loop pembersih berkelanjutan agar tidak ada logo "SR" atau link Discord yang muncul belakangan
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if typeof(gethui) == "function" then
                for _, d in ipairs(gethui():GetDescendants()) do ApplyRockstarStyle(d) end
            end
            for _, d in ipairs(CoreGui:GetDescendants()) do ApplyRockstarStyle(d) end
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                for _, d in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do ApplyRockstarStyle(d) end
            end
        end)
    end
end)

pcall(function()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    local previous = env.__SERENITY_IDLE_RUNTIME
    if type(previous) == "table" then
        previous.Alive = false
        if previous.Connection then
            pcall(function() previous.Connection:Disconnect() end)
        end
    end
    local legacy = env.__SERENITY_IDLE_CONNECTION
    if legacy then pcall(function() legacy:Disconnect() end) end
    env.__SERENITY_IDLE_RUNTIME = nil
    env.__SERENITY_IDLE_CONNECTION = nil
end)

return table.unpack(results, 1, results.n)
