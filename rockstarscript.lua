-- ============================================================================
-- ★ ROCKSTAR HUB (BLUE EDITION) // SAFE HUB-ONLY RESKINNER
-- Hanya Mengubah Warna & Judul pada UI Script Hub (Tidak Menyentuh UI Game!)
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- 1. CATAT SEMUA GUI GAME YANG SUDAH ADA AGAR TIDAK PERNAH DISENTUH
-- ============================================================================
local ExistingGuis = setmetatable({}, {__mode = "k"})

local function SnapshotExistingGuis(container)
    if not container then return end
    pcall(function()
        for _, child in ipairs(container:GetChildren()) do
            ExistingGuis[child] = true
        end
    end)
end

pcall(function()
    if typeof(gethui) == "function" then SnapshotExistingGuis(gethui()) end
end)
pcall(function() SnapshotExistingGuis(CoreGui) end)
pcall(function()
    if LocalPlayer then
        SnapshotExistingGuis(LocalPlayer:WaitForChild("PlayerGui", 5))
    end
end)

-- Cek apakah sebuah elemen berada di dalam GUI lama milik game/Roblox
local function IsGameOrSystemGui(inst)
    local curr = inst
    while curr and curr.Parent do
        if ExistingGuis[curr] then
            return true
        end
        if curr:IsA("ScreenGui") then
            return ExistingGuis[curr] == true
        end
        curr = curr.Parent
    end
    return false
end

-- ============================================================================
-- 2. KONVERSI WARNA ORANYE/COKLAT HUB -> BIRU ROCKSTAR (TANPA UBAH UKURAN)
-- ============================================================================
local function ToRockstarBlue(c)
    if typeof(c) ~= "Color3" then return c end
    -- Hanya tukar warna yang bernuansa Oranye/Coklat (R > B) menjadi Biru Rockstar
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

-- Ubah teks Lynx/Serenity menjadi Rockstar & Hapus teks link Discord
local function CleanHubText(txt)
    if type(txt) ~= "string" or txt == "" then return txt end
    local lower = string.lower(txt)

    -- Kosongkan teks link discord tanpa menyembunyikan frame lain
    if string.find(lower, "discord.gg", 1, true) or string.find(lower, "discord", 1, true) then
        return ""
    end

    local res = txt
    res = string.gsub(res, "[Ll][Yy][Nn][Xx][Xx]?", "Rockstar")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]%s*[Hh][Uu][Bb]", "Rockstar Hub")
    res = string.gsub(res, "[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]", "Rockstar")
    return res
end

-- Ganti gambar logo "SR" pada tombol kecil (Floating Button) tanpa mengubah ukuran frame apa pun!
local function CheckAndReplaceSmallLogo(imgInst)
    if not (imgInst:IsA("ImageLabel") or imgInst:IsA("ImageButton")) then return end
    if imgInst:FindFirstChild("RockstarLogoText") then return end

    pcall(function()
        local parent = imgInst.Parent
        if not parent or not parent:IsA("GuiObject") then return end

        -- Hanya jika parent-nya adalah tombol kotak kecil mengambang (ukuran 30px s/d 75px)
        -- dan TIDAK memiliki TextLabel saudara (agar tidak mengenai menu tab atau jendela utama!)
        local w = parent.AbsoluteSize.X
        local h = parent.AbsoluteSize.Y
        if w >= 28 and w <= 75 and h >= 28 and h <= 75 then
            for _, sib in ipairs(parent:GetChildren()) do
                if sib:IsA("TextLabel") or sib:IsA("TextBox") or sib:IsA("ScrollingFrame") then
                    return
                end
            end

            -- Pastikan bukan di dalam jendela besar (cek parent di atasnya adalah ScreenGui atau Folder)
            if parent.Parent and (parent.Parent:IsA("ScreenGui") or parent.Parent:IsA("Folder")) then
                imgInst.ImageTransparency = 1
                local lbl = Instance.new("TextLabel")
                lbl.Name = "RockstarLogoText"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "R★"
                lbl.TextColor3 = Color3.fromRGB(0, 175, 255)
                lbl.Font = Enum.Font.GothamBlack
                lbl.TextSize = 18
                lbl.Active = false
                lbl.Parent = imgInst
            end
        end
    end)
end

local StyledInstances = setmetatable({}, {__mode = "k"})

local function StyleHubElement(inst)
    if not inst or IsGameOrSystemGui(inst) then return end

    if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
        CheckAndReplaceSmallLogo(inst)
    end

    if StyledInstances[inst] then return end
    StyledInstances[inst] = true

    pcall(function()
        -- 1. Ubah Warna Background (Hanya pada UI Hub)
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

            local newBd = ToRockstarBlue(inst.BorderColor3)
            if newBd ~= inst.BorderColor3 then
                inst.BorderColor3 = newBd
            end
        end

        -- 2. Ubah Teks & Warna Teks
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            local newTxt = CleanHubText(inst.Text)
            if newTxt ~= inst.Text then
                inst.Text = newTxt
            end
            inst:GetPropertyChangedSignal("Text"):Connect(function()
                local t = CleanHubText(inst.Text)
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

        -- 3. Ubah Warna Gambar / Ikon
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

        -- 5. Ubah Warna Garis Tepi (UIStroke)
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

-- Hanya pantau ScreenGui BARU yang dibuat oleh Script Hub (Bukan UI Game!)
local function WatchNewHubGuisOnly(container)
    if not container then return end
    pcall(function()
        container.DescendantAdded:Connect(function(desc)
            if not IsGameOrSystemGui(desc) then
                StyleHubElement(desc)
                task.delay(0.2, function()
                    StyleHubElement(desc)
                end)
            end
        end)
    end)
end

pcall(function()
    if typeof(gethui) == "function" then WatchNewHubGuisOnly(gethui()) end
end)
pcall(function() WatchNewHubGuisOnly(CoreGui) end)
pcall(function()
    if LocalPlayer then
        WatchNewHubGuisOnly(LocalPlayer:WaitForChild("PlayerGui", 5))
    end
end)

-- ============================================================================
-- 3. LOADER UTAMA
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
    env.__SERENITY_DISCORD_NOTICE_AT = os.time() + 99999999
end)

local results = table.pack(fn())

-- Sweep khusus pada GUI baru milik Hub (tidak menyentuh GUI game)
task.spawn(function()
    for _ = 1, 12 do
        task.wait(0.4)
        pcall(function()
            if typeof(gethui) == "function" then
                for _, d in ipairs(gethui():GetDescendants()) do StyleHubElement(d) end
            end
            for _, d in ipairs(CoreGui:GetDescendants()) do StyleHubElement(d) end
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
