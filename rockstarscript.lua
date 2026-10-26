if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("RockstarFullScannerUI") then
    playerGui.RockstarFullScannerUI:Destroy()
end

-- Fungsi Copy Universal (Support semua executor PC & Mobile)
local function copyToClipboard(text)
    local copyFunc = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if typeof(copyFunc) == "function" then
        local ok = pcall(copyFunc, text)
        if ok then return true end
    end
    return false
end

-- Fungsi Simpan ke File (Cadangan jika ingin buka lewat file manager)
local function saveToFile(filename, text)
    if typeof(writefile) == "function" then
        pcall(writefile, filename, text)
        return true
    end
    return false
end

-- ==========================================
-- FUNGSI SCAN 1 MAP PENUH
-- ==========================================
local function generateFullMapDump()
    local lines = {}
    local function log(str)
        table.insert(lines, str)
    end

    local function isPlayerCharacter(inst)
        return Players:GetPlayerFromCharacter(inst) ~= nil
    end

    log("==========================================")
    log("FULL MAP SCANNER REPORT - ROCKSTAR")
    log("PlaceId: " .. tostring(game.PlaceId))
    log("==========================================\n")

    -- 1. STRUKTUR POHON WORKSPACE (FULL HIERARCHY)
    log("=== [1] STRUKTUR HIERARKI SELURUH WORKSPACE ===")
    local function dumpTree(parent, indent, depth)
        if depth > 5 then return end

        local groups = {}
        local order = {}

        for _, child in ipairs(parent:GetChildren()) do
            if child.Name ~= "Camera" and child.Name ~= "Terrain" and not isPlayerCharacter(child) then
                local key = child.Name .. "|" .. child.ClassName
                if not groups[key] then
                    groups[key] = { sample = child, count = 0 }
                    table.insert(order, key)
                end
                groups[key].count += 1
            end
        end

        for _, key in ipairs(order) do
            local group = groups[key]
            local obj = group.sample
            local countStr = group.count > 1 and string.format(" (x%d)", group.count) or ""

            local extra = ""
            if obj:IsA("ValueBase") then
                extra = " = " .. tostring(obj.Value)
            elseif obj:IsA("ProximityPrompt") then
                extra = string.format(" [Action:'%s' | Object:'%s']", obj.ActionText, obj.ObjectText)
            end

            local hasChildren = #obj:GetChildren() > 0
            local isImportant = obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("ProximityPrompt")
                or obj:IsA("ClickDetector") or obj:IsA("TouchTransmitter") or obj:IsA("ValueBase")
                or obj.Name == "Root" or obj.Name == "PrimaryPart"
                or obj:FindFirstChildOfClass("ProximityPrompt")
                or obj:FindFirstChildOfClass("TouchTransmitter")

            if isImportant or hasChildren or depth <= 3 then
                log(string.format("%s|- %s [%s]%s%s", indent, obj.Name, obj.ClassName, countStr, extra))
                if hasChildren then
                    dumpTree(obj, indent .. "  ", depth + 1)
                end
            end
        end
    end

    dumpTree(workspace, "", 1)

    -- 2. SEMUA PROXIMITY PROMPT DI SELURUH MAP
    log("\n=== [2] SEMUA PROXIMITY PROMPT DI MAP ===")
    local prompts = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local pattern = string.gsub(v:GetFullName(), "%d+", "#")
            if not prompts[pattern] then
                prompts[pattern] = {
                    count = 0,
                    realExample = v:GetFullName(),
                    action = v.ActionText,
                    object = v.ObjectText,
                    parentClass = v.Parent and v.Parent.ClassName or "Nil"
                }
            end
            prompts[pattern].count += 1
        end
    end
    for _, data in pairs(prompts) do
        log(string.format("[%dx] %s", data.count, data.realExample))
        log(string.format("   -> Action: '%s' | Object: '%s' | ParentClass: %s", data.action, data.object, data.parentClass))
    end

    -- 3. SEMUA TOUCH INTEREST (SENSOR INJAK / BASE / COLLECT)
    log("\n=== [3] SEMUA TOUCH INTEREST (AREA INJAK/SENTUH) ===")
    local touches = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent then
            local part = v.Parent
            local ancestorModel = part:FindFirstAncestorOfClass("Model")
            if not (ancestorModel and isPlayerCharacter(ancestorModel)) then
                local pattern = string.gsub(part:GetFullName(), "%d+", "#")
                if not touches[pattern] then
                    touches[pattern] = { count = 0, realExample = part:GetFullName() }
                end
                touches[pattern].count += 1
            end
        end
    end
    for _, data in pairs(touches) do
        log(string.format("[%dx] %s", data.count, data.realExample))
    end

    -- 4. REMOTES DI REPLICATED STORAGE
    log("\n=== [4] REMOTES DI REPLICATEDSTORAGE ===")
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            log(string.format("- %s [%s]", v:GetFullName(), v.ClassName))
        end
    end

    return table.concat(lines, "\n")
end

-- ==========================================
-- UI PENAMPIL & TOMBOL SALIN
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RockstarFullScannerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 390)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 14, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Full Map Scanner (Bisa Disalin)"
Title.TextColor3 = Color3.fromRGB(255, 120, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 26)
CloseBtn.Position = UDim2.new(1, -38, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -30, 0, 20)
StatusLabel.Position = UDim2.new(0, 15, 0, 36)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Memindai seluruh map..."
StatusLabel.TextColor3 = Color3.fromRGB(180, 220, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -30, 1, -115)
OutputScroll.Position = UDim2.new(0, 15, 0, 58)
OutputScroll.BackgroundColor3 = Color3.fromRGB(15, 9, 6)
OutputScroll.BorderSizePixel = 0
OutputScroll.ScrollBarThickness = 6
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
OutputScroll.Parent = MainFrame
Instance.new("UICorner", OutputScroll).CornerRadius = UDim.new(0, 6)

local OutputBox = Instance.new("TextBox")
OutputBox.Size = UDim2.new(1, -16, 0, 0)
OutputBox.Position = UDim2.new(0, 8, 0, 8)
OutputBox.AutomaticSize = Enum.AutomaticSize.Y
OutputBox.BackgroundTransparency = 1
OutputBox.Text = "Sedang memindai seluruh map..."
OutputBox.TextColor3 = Color3.fromRGB(220, 220, 220)
OutputBox.Font = Enum.Font.Code
OutputBox.TextSize = 12
OutputBox.TextXAlignment = Enum.TextXAlignment.Left
OutputBox.TextYAlignment = Enum.TextYAlignment.Top
OutputBox.TextWrapped = true
OutputBox.ClearTextOnFocus = false
OutputBox.TextEditable = false
OutputBox.MultiLine = true
OutputBox.Parent = OutputScroll

-- Tombol 1: Salin Otomatis ke Clipboard
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.48, -15, 0, 36)
CopyBtn.Position = UDim2.new(0, 15, 1, -46)
CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
CopyBtn.Text = "SALIN KE CLIPBOARD"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 13
CopyBtn.Parent = MainFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

-- Tombol 2: Blok Semua Teks (Untuk Salin Manual Ctrl+C / HP)
local SelectAllBtn = Instance.new("TextButton")
SelectAllBtn.Size = UDim2.new(0.48, -15, 0, 36)
SelectAllBtn.Position = UDim2.new(0.52, 0, 1, -46)
SelectAllBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 25)
SelectAllBtn.Text = "BLOK SEMUA TEKS (MANUAL)"
SelectAllBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
SelectAllBtn.Font = Enum.Font.GothamBold
SelectAllBtn.TextSize = 12
SelectAllBtn.Parent = MainFrame
Instance.new("UICorner", SelectAllBtn).CornerRadius = UDim.new(0, 6)

-- Jalankan Scan
task.spawn(function()
    task.wait(0.1)
    local report = generateFullMapDump()
    OutputBox.Text = report

    local copied = copyToClipboard(report)
    local saved = saveToFile("Rockstar_MapScan.txt", report)

    if copied and saved then
        StatusLabel.Text = "Status: Berhasil disalin ke Clipboard & disimpan ke Rockstar_MapScan.txt!"
    elseif copied then
        StatusLabel.Text = "Status: Otomatis tersalin ke Clipboard! Tinggal Paste (Ctrl+V)."
    else
        StatusLabel.Text = "Status: Selesai! Klik tombol di bawah untuk menyalin."
    end

    CopyBtn.MouseButton1Click:Connect(function()
        if copyToClipboard(report) then
            CopyBtn.Text = "TER-SALIN KE CLIPBOARD!"
            StatusLabel.Text = "Status: Berhasil disalin ke Clipboard!"
        else
            OutputBox:CaptureFocus()
            OutputBox.SelectionStart = 1
            OutputBox.CursorPosition = #report + 1
            CopyBtn.Text = "TEKS DIBLOK (TEKAN COPY)"
            StatusLabel.Text = "Status: Tekan Ctrl+C atau tahan teks lalu pilih Salin."
        end
        task.wait(1.5)
        if CopyBtn.Parent then
            CopyBtn.Text = "SALIN KE CLIPBOARD"
        end
    end)

    SelectAllBtn.MouseButton1Click:Connect(function()
        OutputBox:CaptureFocus()
        OutputBox.SelectionStart = 1
        OutputBox.CursorPosition = #report + 1
        StatusLabel.Text = "Status: Semua teks diblok! Tekan Ctrl+C (PC) atau tahan & pilih Salin (HP)."
    end)
end)
