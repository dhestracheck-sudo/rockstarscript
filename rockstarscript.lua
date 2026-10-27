-- ============================================================================
-- ★ ROCKSTAR HUB v6.0 - CUSTOM CYBER BLUE EDITION (VERSI SENDIRI) ★
-- Game: Pecahkan dan Curi Telur (Break and Steal an Egg)
-- Fitur: 100% Working Engine + Custom Rockstar UI + Zero Discord + R★ Emblem
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. Matikan semua penyalinan Discord & telemetri bawaan
local env = (type(getgenv) == "function" and getgenv()) or _G
local futureTime = os.time() + (365 * 24 * 60 * 60)
env.__SERENITY_DISCORD_NOTICE_AT = futureTime
env.__SERENITY_DISCORD_COPIED = true
env.SerenityPresenceEnabled = false
_G.__SERENITY_DISCORD_NOTICE_AT = futureTime
_G.__SERENITY_DISCORD_COPIED = true
_G.SerenityPresenceEnabled = false

-- Blokir setclipboard agar tidak pernah menyalin link discord
local function WrapClipboard(origFn)
    if type(origFn) ~= "function" then return origFn end
    return function(text, ...)
        if type(text) == "string" then
            local lower = text:lower()
            if lower:find("discord") or lower:find("lynx") or lower:find("serenity") or lower:find("flowauth") then
                return true
            end
        end
        return origFn(text, ...)
    end
end

pcall(function()
    if type(setclipboard) == "function" then env.setclipboard = WrapClipboard(setclipboard) end
    if type(toclipboard) == "function" then env.toclipboard = WrapClipboard(toclipboard) end
end)

-- ============================================================================
-- 2. PROTEKSI UI ASLI MAP GAME (Agar Toko, Indeks, Ayunan Otomatis Normal)
-- ============================================================================
local GameNativeGuis = {}
local CoreSystemNames = {
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
    ["RobloxPromptGui"] = true,
    ["TeleportEffectGui"] = true,
}

pcall(function()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, child in ipairs(pg:GetChildren()) do
            if child:IsA("ScreenGui") then
                GameNativeGuis[child] = true
            end
        end
    end
end)

local function IsProtectedGameGui(obj)
    if not obj then return true end
    local sg = obj:IsA("ScreenGui") and obj or obj:FindFirstAncestorOfClass("ScreenGui")
    if not sg then return false end
    -- Jangan pernah sentuh GUI asli map di PlayerGui
    if GameNativeGuis[sg] then return true end
    if sg.Parent and sg.Parent:IsA("PlayerGui") then
        -- Di PlayerGui, hanya proses jika jelas-jelas GUI Hub
        local n = sg.Name:lower()
        if not (n:find("serenity") or n:find("lynx") or n:find("flow") or n:find("hub") or n:find("rockstar")) then
            return true
        end
    end
    -- Jangan sentuh GUI sistem standar Roblox di CoreGui
    if CoreSystemNames[sg.Name] then return true end
    return false
end

-- ============================================================================
-- 3. PALET WARNA & TEMA ROCKSTAR CYBER BLUE
-- ============================================================================
local R_BG_DEEP      = Color3.fromRGB(7, 12, 22)     -- Navy gelap pekat
local R_BG_PANEL     = Color3.fromRGB(12, 20, 36)    -- Biru panel elegan
local R_BG_CARD      = Color3.fromRGB(16, 28, 50)    -- Kartu section biru gelap
local R_BG_INPUT     = Color3.fromRGB(20, 35, 62)    -- Input & tombol
local R_ACCENT_BLUE  = Color3.fromRGB(0, 145, 255)   -- Biru elektrik utama
local R_ACCENT_CYAN  = Color3.fromRGB(0, 215, 255)   -- Cyan neon menyala
local R_STROKE_BLUE  = Color3.fromRGB(0, 175, 255)   -- Garis tepi biru
local R_TEXT_WHITE   = Color3.fromRGB(240, 248, 255) -- Putih kebiruan
local R_TEXT_MUTED   = Color3.fromRGB(145, 185, 230) -- Abu-biru lembut

-- Rumus deteksi semua warna Oranye, Coklat, Merah, Pink, dan UNGU:
-- Pada warna Biru/Cyan/Navy/Putih/Abu/Hijau, nilai Green selalu >= Red.
-- Pada warna Oranye, Coklat, Merah, Pink, dan Ungu/Violet, nilai Red selalu > Green!
local function IsNonBlueThemeColor(c)
    if not c then return false end
    -- Semua warna hangat (oranye/coklat/merah/pink) ATAU ungu/violet (R > G dan B tinggi)
    if c.R > c.G + 0.025 then
        return true
    end
    return false
end

local function ConvertToRockstarColor(c)
    if not c then return R_ACCENT_BLUE end
    local lum = math.max(c.R, c.G, c.B)
    if lum < 0.11 then
        return R_BG_DEEP
    elseif lum < 0.20 then
        return R_BG_PANEL
    elseif lum < 0.34 then
        return R_BG_CARD
    elseif lum < 0.52 then
        return R_BG_INPUT
    elseif c.B > c.R then
        -- Ungu terang -> Cyan Elektrik
        return R_ACCENT_CYAN
    else
        -- Oranye/Merah/Pink terang -> Biru Elektrik
        return R_ACCENT_BLUE
    end
end

-- ============================================================================
-- 4. PEMBUAT EMBLEM & BADGE KUSTOM ROCKSTAR (R★)
-- ============================================================================
local function MountRockstarEmblem(target, isFloatingToggle)
    if not target or not target.Parent then return end
    if target:FindFirstChild("RockstarCustomEmblem") then return end

    local badge = Instance.new("Frame")
    badge.Name = "RockstarCustomEmblem"
    badge.Size = UDim2.new(1, 0, 1, 0)
    badge.Position = UDim2.new(0, 0, 0, 0)
    badge.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
    badge.BackgroundTransparency = 0
    badge.BorderSizePixel = 0
    badge.ZIndex = math.max((target.ZIndex or 1) + 5, 10)
    badge.Parent = target

    local corner = Instance.new("UICorner")
    -- Jika tombol floating, buat BULAT PENUH (lingkaran) agar beda total dari kotak SR
    corner.CornerRadius = isFloatingToggle and UDim.new(1, 0) or UDim.new(0, 8)
    corner.Parent = badge

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 225, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 115, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 40, 135))
    })
    grad.Rotation = 45
    grad.Parent = badge

    local stroke = Instance.new("UIStroke")
    stroke.Color = R_ACCENT_CYAN
    stroke.Thickness = isFloatingToggle and 2.2 or 1.5
    stroke.Transparency = 0.05
    stroke.Parent = badge

    local lbl = Instance.new("TextLabel")
    lbl.Name = "RockstarLogoText"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "R★"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextScaled = true
    lbl.ZIndex = badge.ZIndex + 1
    lbl.Parent = badge

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0.12, 0)
    pad.PaddingRight = UDim.new(0.12, 0)
    pad.PaddingTop = UDim.new(0.12, 0)
    pad.PaddingBottom = UDim.new(0.12, 0)
    pad.Parent = lbl

    -- Jika ini tombol floating, ubah juga bentuk parent-nya jadi lingkaran
    if isFloatingToggle and target.Parent and (target.Parent:IsA("GuiObject")) then
        local pCorner = target.Parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", target.Parent)
        pCorner.CornerRadius = UDim.new(1, 0)
        local pStroke = target.Parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", target.Parent)
        pStroke.Color = R_ACCENT_CYAN
        pStroke.Thickness = 2
    end
end

local function WipeImageAndMountEmblem(imgObj, isFloatingToggle)
    if not imgObj or imgObj:GetAttribute("RockstarWiped") then return end
    imgObj:SetAttribute("RockstarWiped", true)
    pcall(function()
        imgObj.Image = ""
        imgObj.ImageTransparency = 1
        imgObj.BackgroundTransparency = 1
    end)
    MountRockstarEmblem(imgObj, isFloatingToggle)
    -- Jaga agar script asli tidak bisa mengembalikan gambar SR belakangan
    pcall(function()
        imgObj:GetPropertyChangedSignal("Image"):Connect(function()
            if imgObj.Image ~= "" then
                imgObj.Image = ""
                imgObj.ImageTransparency = 1
            end
        end)
        imgObj:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
            if imgObj.ImageTransparency < 1 then
                imgObj.ImageTransparency = 1
            end
        end)
    end)
end

-- ============================================================================
-- 5. KAMUS KUSTOMISASI UI VERSI ROCKSTAR (Mengubah Tampilan Menu)
-- ============================================================================
local ExactMenuReplacements = {
    -- Branding
    ["Lynx"] = "★ ROCKSTAR HUB",
    ["LYNX"] = "★ ROCKSTAR HUB",
    ["Serenity Hub"] = "★ ROCKSTAR HUB",
    ["SERENITY HUB"] = "★ ROCKSTAR HUB",
    ["Rockstar Hub"] = "★ ROCKSTAR HUB",
    ["Break and Steal an Egg"] = "VIP • Pecahkan & Curi Telur",
    -- Sidebar Tabs
    ["Main"] = "⚡ Menu Utama",
    ["Automation"] = "🤖 Otomatisasi",
    ["Shop"] = "🛒 Toko & Beli",
    ["Event"] = "🔥 Event Spesial",
    ["Webhook"] = "🌐 Rockstar Web",
    ["Settings"] = "⚙️ Pengaturan UI",
    ["Config"] = "💾 Konfigurasi",
    ["About"] = "★ Info Rockstar",
    ["Feedback"] = "💬 Laporan",
    -- Section Cards
    ["Support Features"] = "🛡️ Fitur Pelindung Rockstar",
    ["Bat Aura"] = "⚔️ Pukulan Aura Otomatis",
    ["Auto Farm Eggs"] = "🥚 Auto Hancurkan & Curi Telur",
    ["Auto Treadmill"] = "🏃 Auto Lari Treadmill",
    ["Auto Sell Pets"] = "💰 Auto Jual Hewan",
    ["Steal Animal Webhook"] = "🌐 Rockstar Web: Curi Hewan",
    ["Stats Webhook"] = "📊 Rockstar Web: Statistik",
    ["Event Webhook"] = "🎉 Rockstar Web: Event",
    ["Connected"] = "⚡ Rockstar Aktif",
}

local function TransformTextToRockstar(str)
    if type(str) ~= "string" or str == "" then return str end

    -- 1. Hapus semua link Discord
    local lower = str:lower()
    if lower:find("discord%.gg") or lower:find("discord%.com/invite") or lower:find("lynxx") or lower:find("pwps7428we") or lower:find("ccsvkn7pp") then
        return ""
    end
    if lower:find("join discord") or lower:find("serenity community") or lower:find("copy discord") then
        return "★ ROCKSTAR VIP EDITION"
    end

    -- 2. Cek kamus menu eksak (agar UI berubah jadi versi kita)
    local trimmed = str:match("^%s*(.-)%s*$")
    if ExactMenuReplacements[trimmed] then
        return ExactMenuReplacements[trimmed]
    end

    -- 3. Ganti kata Serenity / Lynx / FlowAuth di kalimat lain
    local out = str
    out = out:gsub("[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]%s*[Hh][Uu][Bb]", "★ ROCKSTAR HUB")
    out = out:gsub("[Ss][Ee][Rr][Ee][Nn][Ii][Tt][Yy]", "Rockstar")
    out = out:gsub("[Ll][Yy][Nn][Xx]+", "★ ROCKSTAR")
    out = out:gsub("[Ff][Ll][Oo][Ww][Aa][Uu][Tt][Hh]", "Rockstar")
    out = out:gsub("Search feature%.%.%.", "🔍 Cari fitur Rockstar...")
    out = out:gsub("Search controls", "🔍 Cari fitur Rockstar...")
    return out
end

-- ============================================================================
-- 6. PEROMBAK KARTU STATUS ("Rockstar Hub" + Logo SR + Garis Ungu)
-- ============================================================================
local function RestyleBrandCardContainer(cardFrame)
    if not cardFrame or not cardFrame:IsA("GuiObject") then return end

    -- Ubah warna background kartu menjadi Navy Gelap
    pcall(function()
        if cardFrame.BackgroundTransparency < 0.95 then
            cardFrame.BackgroundColor3 = R_BG_DEEP
        end
    end)

    -- Ubah border kartu (UIStroke) dari ungu ke Biru Cyan Menyala
    for _, child in ipairs(cardFrame:GetDescendants()) do
        if child:IsA("UIStroke") then
            child.Color = R_ACCENT_CYAN
            child.Thickness = math.max(child.Thickness, 1.5)
        elseif child:IsA("UIGradient") then
            child.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, R_ACCENT_CYAN),
                ColorSequenceKeypoint.new(1, R_ACCENT_BLUE)
            })
        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
            -- Semua gambar kecil/menengah di dalam kartu brand adalah logo SR / Planet / Discord
            local w = child.AbsoluteSize.X
            local h = child.AbsoluteSize.Y
            if w < 120 and h < 120 then
                WipeImageAndMountEmblem(child, false)
            end
        elseif child:IsA("Frame") then
            -- Garis pemisah horizontal (garis ungu di bawah Rockstar Hub) atau vertikal
            local w, h = child.AbsoluteSize.X, child.AbsoluteSize.Y
            local soY = child.Size.Y.Offset
            local soX = child.Size.X.Offset
            if (h > 0 and h <= 6) or (soY > 0 and soY <= 6 and child.Size.Y.Scale == 0) or (w > 0 and w <= 6) or (soX > 0 and soX <= 6 and child.Size.X.Scale == 0) then
                child.BackgroundColor3 = R_ACCENT_CYAN
                child.BackgroundTransparency = 0
                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("UIGradient") then
                        sub.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, R_ACCENT_CYAN),
                            ColorSequenceKeypoint.new(0.5, R_ACCENT_BLUE),
                            ColorSequenceKeypoint.new(1, R_ACCENT_CYAN)
                        })
                    end
                end
            elseif IsNonBlueThemeColor(child.BackgroundColor3) then
                child.BackgroundColor3 = ConvertToRockstarColor(child.BackgroundColor3)
            end
        end
    end
end

-- ============================================================================
-- 7. MESIN PEROMBAK SEMUA ELEMEN UI HUB SECARA REAL-TIME
-- ============================================================================
local StyledObjects = setmetatable({}, { __mode = "k" })

local function StyleHubElement(obj)
    if not obj or not obj.Parent then return end
    if IsProtectedGameGui(obj) then return end
    if obj.Name == "RockstarCustomEmblem" or obj.Name == "RockstarLogoText" then return end

    -- A. Pastikan ScreenGui Hub berada di layer teratas
    if obj:IsA("ScreenGui") then
        pcall(function()
            obj.DisplayOrder = 999999999
        end)
        return
    end

    -- B. Teks (TextLabel, TextButton, TextBox)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        pcall(function()
            -- Jangan ubah isi TextBox yang sedang diketik pemain
            if not obj:IsA("TextBox") then
                local raw = obj.Text or ""
                local newText = TransformTextToRockstar(raw)
                if newText == "" and raw ~= "" then
                    -- Teks link discord -> sembunyikan teks & ikon discord di sebelahnya
                    obj.Text = "★ ROCKSTAR VIP"
                    obj.TextColor3 = R_ACCENT_CYAN
                    if obj.Parent then
                        for _, sib in ipairs(obj.Parent:GetChildren()) do
                            if sib:IsA("ImageLabel") or sib:IsA("ImageButton") then
                                sib.Image = ""
                                sib.ImageTransparency = 1
                                sib.Visible = false
                            end
                        end
                    end
                elseif newText ~= raw then
                    obj.Text = newText
                end

                -- Jika teks ini adalah judul "★ ROCKSTAR HUB", rombak seluruh kartu induknya!
                if obj.Text:find("ROCKSTAR HUB") then
                    obj.TextColor3 = R_ACCENT_CYAN
                    obj.Font = Enum.Font.GothamBlack
                    if obj.Parent then
                        RestyleBrandCardContainer(obj.Parent)
                        if obj.Parent.Parent and obj.Parent.Parent:IsA("GuiObject") and obj.Parent.Parent.AbsoluteSize.Y < 160 then
                            RestyleBrandCardContainer(obj.Parent.Parent)
                        end
                    end
                end
            else
                local ph = obj.PlaceholderText or ""
                local newPh = TransformTextToRockstar(ph)
                if newPh ~= ph then obj.PlaceholderText = newPh end
            end

            -- Ubah warna teks oranye/ungu menjadi Cyan / Putih Rockstar
            if IsNonBlueThemeColor(obj.TextColor3) then
                obj.TextColor3 = R_ACCENT_CYAN
            end
            if obj.BackgroundTransparency < 0.98 and IsNonBlueThemeColor(obj.BackgroundColor3) then
                obj.BackgroundColor3 = ConvertToRockstarColor(obj.BackgroundColor3)
            end
        end)

        if not StyledObjects[obj] then
            StyledObjects[obj] = true
            if not obj:IsA("TextBox") then
                pcall(function()
                    obj:GetPropertyChangedSignal("Text"):Connect(function()
                        if obj.Name == "RockstarLogoText" then return end
                        local clean = TransformTextToRockstar(obj.Text)
                        if clean ~= obj.Text then
                            obj.Text = clean ~= "" and clean or "★ ROCKSTAR VIP"
                        end
                        if obj.Text:find("ROCKSTAR HUB") and obj.Parent then
                            RestyleBrandCardContainer(obj.Parent)
                        end
                    end)
                end)
            end
            pcall(function()
                obj:GetPropertyChangedSignal("TextColor3"):Connect(function()
                    if IsNonBlueThemeColor(obj.TextColor3) then
                        obj.TextColor3 = R_ACCENT_CYAN
                    end
                end)
            end)
        end
    end

    -- C. Frame / CanvasGroup / ScrollingFrame
    if obj:IsA("Frame") or obj:IsA("CanvasGroup") or obj:IsA("ScrollingFrame") then
        pcall(function()
            local w, h = obj.AbsoluteSize.X, obj.AbsoluteSize.Y
            local soY = obj.Size.Y.Offset
            local soX = obj.Size.X.Offset
            local isLine = (h > 0 and h <= 5) or (soY > 0 and soY <= 5 and obj.Size.Y.Scale == 0)
                or (w > 0 and w <= 5) or (soX > 0 and soX <= 5 and obj.Size.X.Scale == 0)

            if isLine and obj.BackgroundTransparency < 0.95 then
                -- Semua garis pembatas (termasuk garis ungu & bar tab aktif) wajib Cyan Elektrik!
                obj.BackgroundColor3 = R_ACCENT_CYAN
            elseif obj.BackgroundTransparency < 0.98 then
                if IsNonBlueThemeColor(obj.BackgroundColor3) then
                    obj.BackgroundColor3 = ConvertToRockstarColor(obj.BackgroundColor3)
                elseif w > 380 and h > 240 then
                    -- Frame utama window Hub -> beri warna Navy Gelap Solid & Border Biru Menyala
                    obj.BackgroundColor3 = R_BG_DEEP
                    obj.BackgroundTransparency = math.min(obj.BackgroundTransparency, 0.04)
                    if not obj:FindFirstChild("RockstarMainBorder") then
                        local st = obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", obj)
                        st.Name = "RockstarMainBorder"
                        st.Color = R_STROKE_BLUE
                        st.Thickness = 2
                        st.Transparency = 0.1
                    end
                elseif obj.BackgroundColor3.R < 0.16 and obj.BackgroundColor3.G < 0.16 and obj.BackgroundColor3.B < 0.18 then
                    -- Panel hitam polos -> ubah ke Navy Panel Rockstar
                    obj.BackgroundColor3 = R_BG_PANEL
                end
            end

            if obj:IsA("ScrollingFrame") then
                obj.ScrollBarImageColor3 = R_ACCENT_CYAN
            end
        end)

        if not StyledObjects[obj] then
            StyledObjects[obj] = true
            pcall(function()
                obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                    if IsNonBlueThemeColor(obj.BackgroundColor3) then
                        obj.BackgroundColor3 = ConvertToRockstarColor(obj.BackgroundColor3)
                    end
                end)
            end)
        end
    end

    -- D. ImageLabel & ImageButton (Ganti semua logo SR, Planet, Discord)
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        pcall(function()
            local img = tostring(obj.Image or "")
            local imgLower = img:lower()

            -- Jangan ubah foto profil pemain atau thumbnail game
            if imgLower:find("avatarheadshot") or imgLower:find("gameicon") then
                return
            end
            -- Jangan ubah bayangan slice window
            if obj.ScaleType == Enum.ScaleType.Slice or imgLower:find("1316045217") then
                return
            end

            local w, h = obj.AbsoluteSize.X, obj.AbsoluteSize.Y
            local inScroll = obj:FindFirstAncestorOfClass("ScrollingFrame") ~= nil

            -- 1. Cek apakah gambar ini adalah logo SR berdasarkan ID atau lokasinya
            local isSRLogo = imgLower:find("89023606689629")
                or imgLower:find("serenity")
                or imgLower:find("lynx")
                or imgLower:find("flowauth")

            -- 2. Semua gambar berukuran >= 25x25 yang TIDAK berada di dalam ScrollingFrame adalah Logo SR (di Kartu Status / Tombol Floating)
            local isFloating = false
            if not inScroll and w >= 24 and w <= 100 and h >= 24 and h <= 100 then
                isSRLogo = true
                -- Cek apakah ini tombol floating pembuka UI
                local p = obj.Parent
                if p and (p:IsA("ImageButton") or p:IsA("TextButton") or (p:IsA("Frame") and p.AbsoluteSize.X <= 90 and p.AbsoluteSize.Y <= 90)) then
                    if not p:FindFirstChildOfClass("TextLabel") then
                        isFloating = true
                    end
                end
            end

            -- 3. Cek apakah di dalam kartu yang sama (hingga 2 level ke atas) ada teks ROCKSTAR HUB
            if not isSRLogo and not inScroll and w < 100 and h < 100 then
                local container = obj.Parent and obj.Parent.Parent or obj.Parent
                if container and container:IsA("GuiObject") and container.AbsoluteSize.Y < 140 then
                    for _, d in ipairs(container:GetDescendants()) do
                        if d:IsA("TextLabel") and (d.Text:find("ROCKSTAR") or d.Text:lower():find("serenity") or d.Text:lower():find("lynx")) then
                            isSRLogo = true
                            break
                        end
                    end
                end
            end

            if isSRLogo then
                WipeImageAndMountEmblem(obj, isFloating)
            else
                -- Ikon kecil di menu tab / panah dropdown -> ubah warnanya jadi Cyan / Biru Muda
                if IsNonBlueThemeColor(obj.ImageColor3) then
                    obj.ImageColor3 = R_ACCENT_CYAN
                end
            end
        end)

        if not StyledObjects[obj] then
            StyledObjects[obj] = true
            pcall(function()
                obj:GetPropertyChangedSignal("Image"):Connect(function()
                    task.defer(StyleHubElement, obj)
                end)
                obj:GetPropertyChangedSignal("ImageColor3"):Connect(function()
                    if IsNonBlueThemeColor(obj.ImageColor3) then
                        obj.ImageColor3 = R_ACCENT_CYAN
                    end
                end)
            end)
        end
    end

    -- E. UIStroke (Border Ungu / Oranye -> Biru Cyan)
    if obj:IsA("UIStroke") then
        pcall(function()
            local p = obj.Parent
            if p and p.Name ~= "RockstarCustomEmblem" then
                if IsNonBlueThemeColor(obj.Color) or (p:IsA("GuiObject") and p.AbsoluteSize.Y < 160) then
                    obj.Color = R_STROKE_BLUE
                end
            end
        end)
        if not StyledObjects[obj] then
            StyledObjects[obj] = true
            pcall(function()
                obj:GetPropertyChangedSignal("Color"):Connect(function()
                    if IsNonBlueThemeColor(obj.Color) then
                        obj.Color = R_STROKE_BLUE
                    end
                end)
            end)
        end
    end

    -- F. UIGradient (Penyebab utama garis & border tetap berwarna ungu!)
    if obj:IsA("UIGradient") then
        pcall(function()
            if obj.Parent and obj.Parent.Name ~= "RockstarCustomEmblem" then
                obj.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, R_ACCENT_CYAN),
                    ColorSequenceKeypoint.new(1, R_ACCENT_BLUE)
                })
            end
        end)
    end
end

-- ============================================================================
-- 8. PASANG PENGAWAS REAL-TIME DI GETHUI(), COREGUI, DAN PLAYERGUI
-- ============================================================================
local WatchedContainers = {}
local function WatchContainer(container)
    if not container or WatchedContainers[container] then return end
    WatchedContainers[container] = true

    for _, desc in ipairs(container:GetDescendants()) do
        task.spawn(StyleHubElement, desc)
    end

    container.DescendantAdded:Connect(function(desc)
        task.defer(StyleHubElement, desc)
        task.delay(0.15, function()
            if desc and desc.Parent then StyleHubElement(desc) end
        end)
        task.delay(0.6, function()
            if desc and desc.Parent then StyleHubElement(desc) end
        end)
    end)
end

pcall(function()
    if type(gethui) == "function" then WatchContainer(gethui()) end
end)
pcall(function() WatchContainer(CoreGui) end)
pcall(function()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then WatchContainer(pg) end
end)

-- Sapu bersih secara berkala selama 25 detik pertama (menjamin elemen yang dimuat lambat ikut berubah)
task.spawn(function()
    for i = 1, 50 do
        for container, _ in pairs(WatchedContainers) do
            pcall(function()
                for _, desc in ipairs(container:GetDescendants()) do
                    StyleHubElement(desc)
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ============================================================================
-- 9. JALANKAN ENGINE FITUR UTAMA (100% FITUR WORK)
-- ============================================================================
env.__SERENITY_PAYLOAD_AUTHORIZED = true
_G.__SERENITY_PAYLOAD_AUTHORIZED = true

local BASE = "https://raw.githubusercontent.com/MUshihara/Serenity-hub/main/"
local target = "dist/runtime/games/breakandstealegg.lua"
local chunkName = "@SerenityHub/Game-BreakAndStealAnEgg"
local url = BASE .. target .. "?cb=" .. tostring(os.time()) .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(url, true)
end)

if not ok or type(source) ~= "string" or source == "" then
    warn("[ROCKSTAR HUB] Gagal mengambil data script, coba lagi.")
    return
end

local fn, err = loadstring(source, chunkName)
source = nil

if not fn then
    warn("[ROCKSTAR HUB] Gagal kompilasi: " .. tostring(err))
    return
end

local results = table.pack(fn())

-- Sapu bersih langsung setelah UI terbuka
task.defer(function()
    for container, _ in pairs(WatchedContainers) do
        pcall(function()
            for _, desc in ipairs(container:GetDescendants()) do
                StyleHubElement(desc)
            end
        end)
    end
end)

return table.unpack(results, 1, results.n)
