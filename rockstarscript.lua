-- ============================================================================
-- ★ ROCKSTAR HUB (BLUE EDITION) // LOADER + BLUE THEME & LOGO REPLACER
-- Menghapus Logo Asli (Planet/Serenity/Lynx) & Menggantinya Jadi Logo Rockstar
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- [OPSIONAL] Jika Anda punya ID Decal/Gambar Roblox sendiri untuk logo,
-- isi di bawah ini (contoh: "rbxassetid://123456789").
-- Jika dikosongkan (""), otomatis memakai Logo Emblem Bintang ★ Rockstar Biru!
local CUSTOM_LOGO_ID = ""

-- ============================================================================
-- 1. ENGINE PENGUBAH WARNA BIRU, JUDUL, DAN PENGGANTI LOGO ROCKSTAR
-- ============================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local DetectedOriginalLogoIds = {}

-- Konversi warna Oranye/Coklat (R > B) menjadi Biru Rockstar (B, G, R)
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

local function ToRockstarText(txt)
    if type(txt) ~= "string" or txt == "" then return txt end
    local res = txt
    res = string.gsub(res, "[Ll][Yy][Nn][Xx][Xx]?", "Rockstar")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]%s*[Hh][Uu][Bb]", "Rockstar Hub")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]", "Rockstar")
    res = string.gsub(res, "discord%.gg/[%w_%-]+", "discord.gg/rockstar")
    return res
end

-- Fungsi untuk mengganti ImageLabel / ImageButton logo asli dengan Logo Rockstar
local function ReplaceWithRockstarLogo(imgInst)
    if not imgInst or imgInst:FindFirstChild("RockstarLogoBadge") then return end

    pcall(function()
        if CUSTOM_LOGO_ID ~= "" then
            imgInst.Image = CUSTOM_LOGO_ID
            imgInst.ImageColor3 = Color3.fromRGB(0, 170, 255)
            imgInst.ImageTransparency = 0
            imgInst:GetPropertyChangedSignal("Image"):Connect(function()
                if imgInst.Image ~= CUSTOM_LOGO_ID then
                    imgInst.Image = CUSTOM_LOGO_ID
                end
            end)
        else
            -- Sembunyikan gambar logo bawaan mereka sepenuhnya
            imgInst.ImageTransparency = 1
            imgInst.Image = ""
            imgInst:GetPropertyChangedSignal("Image"):Connect(function()
                if imgInst.Image ~= "" then
                    imgInst.Image = ""
                    imgInst.ImageTransparency = 1
                end
            end)
            imgInst:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                if imgInst.ImageTransparency ~= 1 then
                    imgInst.ImageTransparency = 1
                end
            end)

            -- Pasang Emblem Bintang ★ Rockstar Biru Elektrik di tempat logo mereka
            local Badge = Instance.new("Frame")
            Badge.Name = "RockstarLogoBadge"
            Badge.Size = UDim2.new(1, 2, 1, 2)
            Badge.Position = UDim2.new(0.5, 0, 0.5, 0)
            Badge.AnchorPoint = Vector2.new(0.5, 0.5)
            Badge.BackgroundColor3 = Color3.fromRGB(14, 28, 52)
            Badge.BorderSizePixel = 0
            Badge.Parent = imgInst

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(1, 0)
            Corner.Parent = Badge

            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(0, 165, 255)
            Stroke.Thickness = 1.5
            Stroke.Parent = Badge

            local Star = Instance.new("TextLabel")
            Star.Name = "StarIcon"
            Star.Size = UDim2.new(1, 0, 1, 0)
            Star.BackgroundTransparency = 1
            Star.Text = "★"
            Star.TextColor3 = Color3.fromRGB(40, 190, 255)
            Star.Font = Enum.Font.GothamBlack
            Star.TextScaled = true
            Star.Parent = Badge
        end
    end)
end

-- Cek apakah sebuah ImageLabel/ImageButton adalah logo utama di TopBar atau Tombol Floating
local function CheckIfBrandLogo(imgInst)
    if not (imgInst:IsA("ImageLabel") or imgInst:IsA("ImageButton")) then return false end

    -- 1. Jika asset ID gambarnya sama dengan logo TopBar yang sudah terdeteksi
    if imgInst.Image ~= "" and DetectedOriginalLogoIds[imgInst.Image] then
        return true
    end

    local parent = imgInst.Parent
    if not parent then return false end

    -- Jangan ganti ikon menu tab di Sidebar (Main, Automation, Shop, Event, Webhook, Settings, Config, Search)
    local sidebarNames = {
        ["main"] = true, ["automation"] = true, ["shop"] = true,
        ["event"] = true, ["webhook"] = true, ["settings"] = true,
        ["config"] = true, ["search feature..."] = true
    }
    for _, sibling in ipairs(parent:GetChildren()) do
        if sibling:IsA("TextLabel") or sibling:IsA("TextBox") then
            local t = string.lower(sibling.Text or sibling.PlaceholderText or "")
            if sidebarNames[t] then
                return false
            end
        end
    end

    -- 2. Jika berada satu baris/container dengan judul "Lynx" / "Serenity" / "Rockstar" di TopBar
    for _, sibling in ipairs(parent:GetChildren()) do
        if sibling:IsA("TextLabel") or sibling:IsA("TextButton") then
            local raw = string.lower(sibling.Text or "")
            if raw == "lynx" or raw == "serenity" or raw == "rockstar" or string.find(raw, "rockstar", 1, true) or string.find(raw, "lynx", 1, true) then
                if imgInst.Image ~= "" then
                    DetectedOriginalLogoIds[imgInst.Image] = true
                end
                return true
            end
        end
    end

    -- 3. Jika merupakan tombol floating (ImageButton/Frame kecil di luar MainFrame untuk buka/tutup UI)
    if imgInst:IsA("ImageButton") and (parent:IsA("ScreenGui") or (parent:IsA("Frame") and parent.Parent and parent.Parent:IsA("ScreenGui") and parent.Size.X.Offset <= 70 and parent.Size.X.Offset > 0)) then
        if imgInst.Image ~= "" then
            DetectedOriginalLogoIds[imgInst.Image] = true
        end
        return true
    end

    return false
end

local StyledInstances = setmetatable({}, {__mode = "k"})

local function ApplyRockstarStyle(inst)
    if not inst then return end

    -- Selalu cek apakah ini logo yang harus diganti
    if (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) and CheckIfBrandLogo(inst) then
        ReplaceWithRockstarLogo(inst)
    end

    if StyledInstances[inst] then return end
    StyledInstances[inst] = true

    pcall(function()
        -- 1. Ubah Warna Background
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

        -- 2. Ubah Teks & Warna Teks
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            local origLower = string.lower(inst.Text or "")
            local isBrandTitle = (origLower == "lynx" or origLower == "serenity" or string.find(origLower, "lynx", 1, true) or string.find(origLower, "serenity", 1, true))

            local newTxt = ToRockstarText(inst.Text)
            if newTxt ~= inst.Text then
                inst.Text = newTxt
            end

            -- Jika ini adalah teks judul di TopBar, langsung cek semua ImageLabel di sebelahnya (di dalam TopBar) dan ganti logonya!
            if isBrandTitle and inst.Parent then
                for _, sib in ipairs(inst.Parent:GetDescendants()) do
                    if (sib:IsA("ImageLabel") or sib:IsA("ImageButton")) then
                        if sib.Image ~= "" then
                            DetectedOriginalLogoIds[sib.Image] = true
                        end
                        ReplaceWithRockstarLogo(sib)
                    end
                end
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

        -- 3. Ubah Warna Ikon / Gambar & Cek Logo
        if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            if CheckIfBrandLogo(inst) then
                ReplaceWithRockstarLogo(inst)
            else
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
-- 2. LOADER UTAMA
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

pcall(function()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    env.__SERENITY_DISCORD_COPIED = true
    env.__SERENITY_DISCORD_NOTICE_AT = os.time() + 999999
end)

local results = table.pack(fn())

-- Sweep ulang untuk memastikan semua logo & warna berubah menjadi Rockstar Biru
task.spawn(function()
    for _ = 1, 12 do
        task.wait(0.4)
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
