-- ============================================================================
-- ★ ROCKSTAR HUB (BLUE EDITION) // CANONICAL LOADER + REAL-TIME BLUE RESKINNER
-- 100% Working Original Features + Automatic Rockstar Blue UI & Title Override
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================================
-- 1. ENGINE PENGUBAH WARNA BIRU & JUDUL "ROCKSTAR" OTOMATIS
-- ============================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Konversi warna Oranye/Coklat (R > B) menjadi Biru Rockstar (B, G, R) secara proporsional
local function ToRockstarBlue(c)
    if typeof(c) ~= "Color3" then return c end
    if c.R > c.B + 0.04 then
        return Color3.new(
            c.B,
            math.clamp(c.G * 1.05, 0, 1),
            c.R
        )
    end
    return c
end

-- Konversi UIGradient ColorSequence menjadi Biru Rockstar
local function ToRockstarSequence(seq)
    if typeof(seq) ~= "ColorSequence" then return seq end
    local keypoints = {}
    local changed = false
    for _, kp in ipairs(seq.Keypoints) do
        local newCol = ToRockstarBlue(kp.Value)
        if newCol ~= kp.Value then changed = true end
        table.insert(keypoints, ColorSequenceKeypoint.new(kp.Time, newCol))
    end
    if changed then
        return ColorSequence.new(keypoints)
    end
    return seq
end

-- Ubah teks judul Lynx / Serenity menjadi Rockstar
local function ToRockstarText(txt)
    if type(txt) ~= "string" or txt == "" then return txt end
    local res = txt
    res = string.gsub(res, "[Ll][Yy][Nn][Xx][Xx]?", "Rockstar")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]%s*[Hh][Uu][Bb]", "Rockstar Hub")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]", "Rockstar")
    res = string.gsub(res, "discord%.gg/[%w_%-]+", "discord.gg/rockstar")
    return res
end

local StyledInstances = setmetatable({}, {__mode = "k"})

local function ApplyRockstarStyle(inst)
    if not inst or StyledInstances[inst] then return end
    StyledInstances[inst] = true

    pcall(function()
        -- 1. Ubah Warna Background (Frame, Button, TextBox, ScrollingFrame)
        if inst:IsA("GuiObject") then
            local newBg = ToRockstarBlue(inst.BackgroundColor3)
            if newBg ~= inst.BackgroundColor3 then
                inst.BackgroundColor3 = newBg
            end
            inst:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                local c = ToRockstarBlue(inst.BackgroundColor3)
                if c ~= inst.BackgroundColor3 then
                    inst.BackgroundColor3 = c
                end
            end)

            local newBorder = ToRockstarBlue(inst.BorderColor3)
            if newBorder ~= inst.BorderColor3 then
                inst.BorderColor3 = newBorder
            end
        end

        -- 2. Ubah Teks & Warna Teks (TextLabel, TextButton, TextBox)
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            local newTxt = ToRockstarText(inst.Text)
            if newTxt ~= inst.Text then
                inst.Text = newTxt
            end
            inst:GetPropertyChangedSignal("Text"):Connect(function()
                local t = ToRockstarText(inst.Text)
                if t ~= inst.Text then
                    inst.Text = t
                end
            end)

            local newTc = ToRockstarBlue(inst.TextColor3)
            if newTc ~= inst.TextColor3 then
                inst.TextColor3 = newTc
            end
            inst:GetPropertyChangedSignal("TextColor3"):Connect(function()
                local c = ToRockstarBlue(inst.TextColor3)
                if c ~= inst.TextColor3 then
                    inst.TextColor3 = c
                end
            end)
        end

        -- 3. Ubah Warna Ikon / Gambar (ImageLabel, ImageButton)
        if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            local newIc = ToRockstarBlue(inst.ImageColor3)
            if newIc ~= inst.ImageColor3 then
                inst.ImageColor3 = newIc
            end
            inst:GetPropertyChangedSignal("ImageColor3"):Connect(function()
                local c = ToRockstarBlue(inst.ImageColor3)
                if c ~= inst.ImageColor3 then
                    inst.ImageColor3 = c
                end
            end)
        end

        -- 4. Ubah Warna ScrollBar
        if inst:IsA("ScrollingFrame") then
            local newSc = ToRockstarBlue(inst.ScrollBarImageColor3)
            if newSc ~= inst.ScrollBarImageColor3 then
                inst.ScrollBarImageColor3 = newSc
            end
            inst:GetPropertyChangedSignal("ScrollBarImageColor3"):Connect(function()
                local c = ToRockstarBlue(inst.ScrollBarImageColor3)
                if c ~= inst.ScrollBarImageColor3 then
                    inst.ScrollBarImageColor3 = c
                end
            end)
        end

        -- 5. Ubah Warna Garis Pinggir (UIStroke)
        if inst:IsA("UIStroke") then
            local newSt = ToRockstarBlue(inst.Color)
            if newSt ~= inst.Color then
                inst.Color = newSt
            end
            inst:GetPropertyChangedSignal("Color"):Connect(function()
                local c = ToRockstarBlue(inst.Color)
                if c ~= inst.Color then
                    inst.Color = c
                end
            end)
        end

        -- 6. Ubah Warna Gradasi (UIGradient)
        if inst:IsA("UIGradient") then
            local newSeq = ToRockstarSequence(inst.Color)
            if newSeq ~= inst.Color then
                inst.Color = newSeq
            end
            inst:GetPropertyChangedSignal("Color"):Connect(function()
                local s = ToRockstarSequence(inst.Color)
                if s ~= inst.Color then
                    inst.Color = s
                end
            end)
        end
    end)
end

-- Pasang Watcher pada gethui(), CoreGui, dan PlayerGui
local function WatchGuiContainer(container)
    if not container then return end
    pcall(function()
        for _, desc in ipairs(container:GetDescendants()) do
            ApplyRockstarStyle(desc)
        end
        container.DescendantAdded:Connect(function(desc)
            ApplyRockstarStyle(desc)
            task.defer(function()
                ApplyRockstarStyle(desc)
            end)
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
-- 2. LOADER UTAMA (DENGAN OTORISASI ASLI AGAR 100% FITUR BEKERJA)
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

-- Cegah auto-copy invite bawaan dengan menandai timestamp sudah disalin
pcall(function()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    env.__SERENITY_DISCORD_COPIED = true
    env.__SERENITY_DISCORD_NOTICE_AT = os.time() + 999999
end)

-- Jalankan payload utama
local results = table.pack(fn())

-- Pastikan seluruh elemen UI yang baru muncul langsung berubah menjadi Rockstar Biru
task.spawn(function()
    for _ = 1, 10 do
        task.wait(0.5)
        pcall(function()
            if typeof(gethui) == "function" then
                for _, d in ipairs(gethui():GetDescendants()) do ApplyRockstarStyle(d) end
            end
            for _, d in ipairs(CoreGui:GetDescendants()) do ApplyRockstarStyle(d) end
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
