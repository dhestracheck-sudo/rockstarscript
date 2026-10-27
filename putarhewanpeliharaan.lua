-- ============================================================================
-- ★ ROCKSTAR HUB v6.3 - CYBER BLUE EDITION (TOWER & UPGRADE FIX) ★
-- Game   : [🎃] Putar Hewan Peliharaan (PlaceId: 73275665439299)
-- Fitur  : Smart Auto Tower + Smart Podium/Stat Upgrade + Live Learning Log
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local Remotes = Shared and Shared:WaitForChild("Remotes", 10)

-- ============================================================================
-- 1. STATE & DATA PEMBELAJARAN OTOMATIS (SELF-LEARNING ENGINE)
-- ============================================================================
local State = {
    AutoRoll = false,
    AutoCollectCash = false,
    AutoUpgradePodium = false,
    AutoBuyUpgrades = false,
    AutoBuyDice = false,
    AutoEquipBest = false,
    AutoTreadmill = false,
    AutoSpinWheel = false,
    AutoClaimRewards = false,
    AutoSkipAdBoard = false,
    AutoTower = false,
    AutoRebirth = false,
    AutoSellWeakest = false,
    AutoCandyClaim = false,
    CustomSpeed = false,
}

local TowerRuntime = {
    InTower = false,
    LastStartAttempt = 0,
}

local Discovered = {
    UpgradeIds = {},
    RebirthStatIds = {},
    DiceIds = {},
    TowerIds = {},
    -- Menyimpan argumen pasti yang tertangkap saat pemain klik manual 1x
    LearnedCalls = {
        PodiumAction = nil,
        BuyUpgrade = {},
        UpgradeRebirthStat = {},
        BuyDice = {},
        StartTower = nil,
    },
    RecentLogs = {},
}

local function AddLog(msg)
    local line = os.date("%H:%M:%S") .. " | " .. tostring(msg)
    table.insert(Discovered.RecentLogs, 1, line)
    if #Discovered.RecentLogs > 25 then
        table.remove(Discovered.RecentLogs)
    end
end

local function AddUnique(list, val)
    if val == nil then return end
    for _, v in ipairs(list) do
        if v == val then return end
    end
    table.insert(list, val)
end

-- ============================================================================
-- 2. FUNGSI REMOTE, PARSER UANG, & EKSTRAKTOR MODULE SHARED
-- ============================================================================
local function GetRemote(name)
    if not Remotes then
        Shared = ReplicatedStorage:FindFirstChild("Shared")
        Remotes = Shared and Shared:FindFirstChild("Remotes")
    end
    return Remotes and Remotes:FindFirstChild(name)
end

local function SafeInvoke(remoteName, ...)
    local r = GetRemote(remoteName)
    if r and r:IsA("RemoteFunction") then
        local ok, res = pcall(function(...)
            return r:InvokeServer(...)
        end, ...)
        return ok, res
    end
    return false, nil
end

local function SafeFire(remoteName, ...)
    local r = GetRemote(remoteName)
    if r and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent")) then
        pcall(function(...)
            r:FireServer(...)
        end, ...)
    end
end

local SuffixMap = {
    k = 1e3, m = 1e6, b = 1e9, t = 1e12,
    qa = 1e15, qd = 1e15, qi = 1e18, sx = 1e21, sp = 1e24, oc = 1e27, no = 1e30, dc = 1e33
}

local function ParseMoney(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    local clean = val:lower():gsub("[,%$%s]", ""):gsub("/s", "")
    local numStr, suf = clean:match("^([%d%.]+)([a-z]*)$")
    local num = tonumber(numStr)
    if not num then return tonumber(clean) or 0 end
    if suf and suf ~= "" and SuffixMap[suf] then
        return num * SuffixMap[suf]
    end
    return num
end

local function GetPlayerMoney()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local mVal = ls and ls:FindFirstChild("Money")
    if mVal then return ParseMoney(mVal.Value) end
    return 0
end

-- Bongkar semua ModuleScript di ReplicatedStorage.Shared & GetData untuk mendapatkan ID asli
local function ExtractSharedData()
    pcall(function()
        local ok, data = SafeInvoke("GetData")
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                local kl = tostring(k):lower()
                if type(v) == "table" then
                    if kl:find("upgrade") and not kl:find("rebirth") then
                        for id, _ in pairs(v) do AddUnique(Discovered.UpgradeIds, id) end
                    elseif kl:find("rebirth") then
                        for id, _ in pairs(v) do AddUnique(Discovered.RebirthStatIds, id) end
                    elseif kl:find("dice") then
                        for id, _ in pairs(v) do AddUnique(Discovered.DiceIds, id) end
                    elseif kl:find("tower") then
                        for id, _ in pairs(v) do AddUnique(Discovered.TowerIds, id) end
                    end
                end
            end
        end
    end)

    if Shared then
        for _, mod in ipairs(Shared:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local nLower = mod.Name:lower()
                pcall(function()
                    local ok, tbl = pcall(require, mod)
                    if ok and type(tbl) == "table" then
                        local function ScanTableKeys(t, targetList)
                            for k, v in pairs(t) do
                                if type(k) == "string" and k ~= "Order" and k ~= "Config" and k ~= "Types" then
                                    AddUnique(targetList, k)
                                end
                                if type(v) == "table" then
                                    if type(v.Id) == "string" then AddUnique(targetList, v.Id) end
                                    if type(v.Name) == "string" and #v.Name < 30 then AddUnique(targetList, v.Name) end
                                    if type(v.Key) == "string" then AddUnique(targetList, v.Key) end
                                end
                            end
                        end

                        if nLower:find("upgrade") and not nLower:find("rebirth") then
                            ScanTableKeys(tbl, Discovered.UpgradeIds)
                        elseif nLower:find("rebirth") then
                            ScanTableKeys(tbl, Discovered.RebirthStatIds)
                        elseif nLower:find("dice") then
                            ScanTableKeys(tbl, Discovered.DiceIds)
                        elseif nLower:find("tower") then
                            ScanTableKeys(tbl, Discovered.TowerIds)
                        end
                    end
                end)
            end
        end
    end

    AddLog(string.format(
        "Config dimuat: %d Upgrade, %d RebirthStat, %d Dice, %d Tower",
        #Discovered.UpgradeIds, #Discovered.RebirthStatIds, #Discovered.DiceIds, #Discovered.TowerIds
    ))
end
task.spawn(ExtractSharedData)

-- Pantau TowerEvent dari Server agar tahu kapan masuk/keluar/kalah di Menara
pcall(function()
    local towerEv = GetRemote("TowerEvent")
    if towerEv and towerEv:IsA("RemoteEvent") then
        towerEv.OnClientEvent:Connect(function(action, data)
            local actStr = tostring(action or ""):lower()
            AddLog("TowerEvent: " .. tostring(action))
            if actStr:find("start") or actStr:find("wave") or actStr:find("spawn") or actStr:find("floor") or actStr:find("fight") then
                TowerRuntime.InTower = true
            elseif actStr:find("revive") or actStr:find("dead") or actStr:find("die") or actStr:find("prompt") then
                -- Jika muncul layar Revive saat Auto Tower aktif, otomatis tolak Revive & lanjutkan!
                if State.AutoTower then
                    task.defer(function()
                        SafeInvoke("DeclineRevive")
                        task.wait(0.3)
                        SafeInvoke("ResumeTower")
                    end)
                end
            elseif actStr:find("end") or actStr:find("leave") or actStr:find("defeat") or actStr:find("lose") or actStr:find("win") or actStr:find("victory") or actStr:find("finish") then
                TowerRuntime.InTower = false
            end
        end)
    end
end)

-- Self-Learning Hook: Menangkap argumen asli saat pemain mengklik tombol di dalam game
pcall(function()
    if type(getrawmetatable) == "function" then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        if setreadonly then setreadonly(mt, false) end
        local inHook = false

        mt.__namecall = newcclosure and newcclosure(function(self, ...)
            if not inHook then
                local method = getnamecallmethod and getnamecallmethod()
                if method == "InvokeServer" or method == "FireServer" then
                    inHook = true
                    local args = { ... }
                    pcall(function()
                        local name = tostring(self)
                        if name == "PodiumAction" then
                            Discovered.LearnedCalls.PodiumAction = args
                            AddLog("Belajar PodiumAction: (" .. tostring(args[1]) .. ", " .. tostring(args[2]) .. ", " .. tostring(args[3]) .. ")")
                        elseif name == "BuyUpgrade" then
                            if args[1] ~= nil then AddUnique(Discovered.UpgradeIds, args[1]) end
                            Discovered.LearnedCalls.BuyUpgrade = args
                            AddLog("Belajar BuyUpgrade: (" .. tostring(args[1]) .. ", " .. tostring(args[2]) .. ")")
                        elseif name == "UpgradeRebirthStat" then
                            if args[1] ~= nil then AddUnique(Discovered.RebirthStatIds, args[1]) end
                            Discovered.LearnedCalls.UpgradeRebirthStat = args
                            AddLog("Belajar RebirthStat: (" .. tostring(args[1]) .. ")")
                        elseif name == "BuyDice" then
                            if args[1] ~= nil then AddUnique(Discovered.DiceIds, args[1]) end
                            AddLog("Belajar BuyDice: (" .. tostring(args[1]) .. ")")
                        elseif name == "StartTower" then
                            Discovered.LearnedCalls.StartTower = args
                            TowerRuntime.InTower = true
                            AddLog("Belajar StartTower: (" .. tostring(args[1]) .. ", " .. tostring(args[2]) .. ")")
                        elseif name == "LeaveTower" then
                            TowerRuntime.InTower = false
                        end
                    end)
                    inHook = false
                end
            end
            return oldNamecall(self, ...)
        end) or mt.__namecall

        if setreadonly then setreadonly(mt, true) end
    end
end)

-- ============================================================================
-- 3. HELPER PLOT, PODIUM, & INTERAKSI MAP
-- ============================================================================
local function GetMyPlot()
    for i = 1, 8 do
        local plot = Workspace:FindFirstChild("Plot" .. tostring(i))
        if plot and plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end

local function GetMyPodiums()
    local list = {}
    local plot = GetMyPlot()
    if not plot then return list end

    local function Collect(folder)
        if not folder then return end
        for _, pod in ipairs(folder:GetChildren()) do
            if pod:IsA("Model") and pod:GetAttribute("Locked") ~= true then
                table.insert(list, pod)
            end
        end
    end

    Collect(plot:FindFirstChild("Podiums"))
    local floor2 = plot:FindFirstChild("Floor2")
    if floor2 then Collect(floor2:FindFirstChild("Podiums")) end
    return list
end

local function TeleportTo(posOrCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if typeof(posOrCFrame) == "Vector3" then
        hrp.CFrame = CFrame.new(posOrCFrame + Vector3.new(0, 3, 0))
    elseif typeof(posOrCFrame) == "CFrame" then
        hrp.CFrame = posOrCFrame
    end
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999
    end)
    if type(fireproximityprompt) == "function" then
        pcall(fireproximityprompt, prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(math.max(0.04, prompt.HoldDuration or 0))
            prompt:InputHoldEnd()
        end)
    end
end

local function TriggerClickDetector(cd)
    if not cd or not cd:IsA("ClickDetector") then return end
    pcall(function() cd.MaxActivationDistance = 999 end)
    if type(fireclickdetector) == "function" then
        pcall(fireclickdetector, cd)
    end
end

local function TriggerTouch(part)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not part or not part:IsA("BasePart") then return end
    if type(firetouchinterest) == "function" then
        pcall(firetouchinterest, hrp, part, 0)
        pcall(firetouchinterest, hrp, part, 1)
    else
        local oldCF = hrp.CFrame
        hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.05)
        hrp.CFrame = oldCF
    end
end

-- Fungsi Upgrade Podium Pintar
local function UpgradeSinglePodium(pod, allowTeleport)
    if not pod then return false end
    local slot = pod:GetAttribute("Slot") or tonumber(pod.Name:match("%d+"))
    local petUuid = pod:GetAttribute("PetUuid")
    if not petUuid or petUuid == "" then return false end

    local cost = tonumber(pod:GetAttribute("UpgradeCost")) or 0
    local myMoney = GetPlayerMoney()

    local screenMesh = pod:FindFirstChild("Screen")
    local podPromptFolder = screenMesh and screenMesh:FindFirstChild("PodiumPrompt")
    local upgPrompt = podPromptFolder and podPromptFolder:FindFirstChild("ProximityPrompt")
    local upgMaxPrompt = podPromptFolder and podPromptFolder:FindFirstChild("UpgradeMaxPrompt")

    local screenFace = pod:FindFirstChild("ScreenFace")
    local maxFace = screenFace and screenFace:FindFirstChild("MaxFace")
    local cdSingle = screenFace and screenFace:FindFirstChildOfClass("ClickDetector")
    local cdMax = maxFace and maxFace:FindFirstChildOfClass("ClickDetector")

    local canAfford = (cost > 0 and myMoney >= cost)
    if not canAfford and upgMaxPrompt then
        local actText = tostring(upgMaxPrompt.ActionText or "")
        if actText ~= "" and not actText:find("%(%+0%)") then
            canAfford = true
        end
    end
    if not canAfford and cost == 0 then canAfford = true end
    if not canAfford then return false end

    local oldLevel = tonumber(pod:GetAttribute("Level")) or 1

    -- 1. Gunakan pola PodiumAction yang sudah dipelajari (jika ada)
    local learned = Discovered.LearnedCalls.PodiumAction
    if learned then
        if type(learned[1]) == "number" then
            SafeInvoke("PodiumAction", slot, learned[2], learned[3])
        elseif type(learned[2]) == "number" then
            SafeInvoke("PodiumAction", learned[1], slot, learned[3])
        elseif type(learned[1]) == "table" then
            local copyTbl = {}
            for k, v in pairs(learned[1]) do copyTbl[k] = v end
            if copyTbl.Slot then copyTbl.Slot = slot end
            if copyTbl.slot then copyTbl.slot = slot end
            SafeInvoke("PodiumAction", copyTbl)
        else
            SafeInvoke("PodiumAction", table.unpack(learned))
        end
    else
        -- Hanya coba 2 kombinasi paling umum agar tidak kena rate-limit server
        SafeInvoke("PodiumAction", "UpgradeMax", slot)
        SafeInvoke("PodiumAction", slot, "UpgradeMax")
    end

    -- 2. Trigger ClickDetector & ProximityPrompt
    if cdMax then TriggerClickDetector(cdMax) end
    if cdSingle then TriggerClickDetector(cdSingle) end
    if upgMaxPrompt then TriggerPrompt(upgMaxPrompt) end
    if upgPrompt then TriggerPrompt(upgPrompt) end

    task.wait(0.1)

    -- 3. Jika server mewajibkan jarak < 14 stud dari layar Podium, teleport ke dekat Podium
    local newLevel = tonumber(pod:GetAttribute("Level")) or 1
    if newLevel <= oldLevel and allowTeleport then
        local targetPart = screenFace or screenMesh or pod:FindFirstChild("PadBase")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if targetPart and hrp then
            if (hrp.Position - targetPart.Position).Magnitude > 11 then
                local savedCF = hrp.CFrame
                hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2.5, 4))
                task.wait(0.18)
                if cdMax then TriggerClickDetector(cdMax) end
                if cdSingle then TriggerClickDetector(cdSingle) end
                if upgMaxPrompt then TriggerPrompt(upgMaxPrompt) end
                if upgPrompt then TriggerPrompt(upgPrompt) end
                task.wait(0.15)
                if not State.AutoTreadmill then
                    hrp.CFrame = savedCF
                end
            end
        end
    end
    return true
end

-- Fungsi Masuk / Jalankan Menara Tanpa Error
local function TryEnterOrRunTower()
    -- Selalu aktifkan Auto Retry & tolak Revive jika sedang sangkut di layar Revive
    SafeFire("SetTowerAutoRetry", true)
    SafeInvoke("DeclineRevive")
    SafeInvoke("ResumeTower")

    -- Jangan spam StartTower kalau sedang di dalam pertarungan menara!
    if TowerRuntime.InTower and (os.clock() - TowerRuntime.LastStartAttempt) < 20 then
        return
    end

    TowerRuntime.LastStartAttempt = os.clock()

    -- Pastikan tim pet menara terbaik sudah terpasang sebelum mulai
    SafeInvoke("EquipBestTeam")
    task.wait(0.15)

    -- 1. Jika pemain sudah pernah masuk menara 1x, gunakan argumen persis milik pemain
    if Discovered.LearnedCalls.StartTower then
        local ok, res = SafeInvoke("StartTower", table.unpack(Discovered.LearnedCalls.StartTower))
        if ok and res ~= false then
            TowerRuntime.InTower = true
            return
        end
    end

    -- 2. Coba panggil StartTower tanpa argumen dulu
    local ok0, res0 = SafeInvoke("StartTower")
    if ok0 and res0 ~= false and res0 ~= nil then
        TowerRuntime.InTower = true
        return
    end

    -- 3. Coba ID Menara yang diekstrak dari ReplicatedStorage.Shared
    for _, tId in ipairs(Discovered.TowerIds) do
        local ok, res = SafeInvoke("StartTower", tId)
        if ok and res ~= false and res ~= nil then
            Discovered.LearnedCalls.StartTower = { tId }
            TowerRuntime.InTower = true
            return
        end
    end

    -- 4. Coba buka lewat StandTowers ProximityPrompt di TowersPad jika perlu
    local towersPad = Workspace:FindFirstChild("TowersPad")
    local zone = towersPad and towersPad:FindFirstChild("Zone")
    local att = zone and zone:FindFirstChild("StandPromptAttachment")
    local standPrompt = att and att:FindFirstChild("StandTowers")
    if standPrompt then
        TriggerPrompt(standPrompt)
    end
end

-- ============================================================================
-- 4. UI ROCKSTAR HUB v6.3 (CUSTOM CYBER BLUE)
-- ============================================================================
local guiParent = (type(gethui) == "function" and gethui()) or CoreGui
local oldUI = guiParent:FindFirstChild("RockstarHubRollPetsV6")
if oldUI then oldUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RockstarHubRollPetsV6"
screenGui.DisplayOrder = 999999999
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 54, 0, 54)
floatBtn.Position = UDim2.new(0, 18, 0.42, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(0, 125, 255)
floatBtn.Font = Enum.Font.GothamBlack
floatBtn.TextSize = 18
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Text = "R★"
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local floatGrad = Instance.new("UIGradient", floatBtn)
floatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 225, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 210))
})
floatGrad.Rotation = 45

local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = Color3.fromRGB(0, 225, 255)
floatStroke.Thickness = 2.2

local mainWin = Instance.new("Frame")
mainWin.Size = UDim2.new(0, 560, 0, 400)
mainWin.Position = UDim2.new(0.5, -280, 0.5, -200)
mainWin.BackgroundColor3 = Color3.fromRGB(7, 12, 22)
mainWin.BorderSizePixel = 0
mainWin.Active = true
mainWin.Draggable = true
mainWin.Parent = screenGui
Instance.new("UICorner", mainWin).CornerRadius = UDim.new(0, 12)

local winStroke = Instance.new("UIStroke", mainWin)
winStroke.Color = Color3.fromRGB(0, 185, 255)
winStroke.Thickness = 2

floatBtn.MouseButton1Click:Connect(function()
    mainWin.Visible = not mainWin.Visible
end)

local topBar = Instance.new("Frame", mainWin)
topBar.Size = UDim2.new(1, 0, 0, 46)
topBar.BackgroundColor3 = Color3.fromRGB(11, 22, 42)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topLine = Instance.new("Frame", topBar)
topLine.Size = UDim2.new(1, -24, 0, 2)
topLine.Position = UDim2.new(0, 12, 1, -2)
topLine.BackgroundColor3 = Color3.fromRGB(0, 215, 255)
topLine.BorderSizePixel = 0

local badgeLogo = Instance.new("TextLabel", topBar)
badgeLogo.Size = UDim2.new(0, 34, 0, 30)
badgeLogo.Position = UDim2.new(0, 12, 0, 8)
badgeLogo.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
badgeLogo.Font = Enum.Font.GothamBlack
badgeLogo.TextSize = 14
badgeLogo.TextColor3 = Color3.new(1, 1, 1)
badgeLogo.Text = "R★"
Instance.new("UICorner", badgeLogo).CornerRadius = UDim.new(0, 7)

local titleText = Instance.new("TextLabel", topBar)
titleText.Size = UDim2.new(1, -110, 1, 0)
titleText.Position = UDim2.new(0, 54, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 13
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextColor3 = Color3.fromRGB(235, 248, 255)
titleText.Text = "ROCKSTAR HUB v6.3  •  [🎃] PUTAR HEWAN PELIHARAAN"

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -42, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(18, 38, 72)
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(0, 215, 255)
minBtn.Text = "—"
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 7)
minBtn.MouseButton1Click:Connect(function()
    mainWin.Visible = false
end)

local sidebar = Instance.new("Frame", mainWin)
sidebar.Size = UDim2.new(0, 155, 1, -58)
sidebar.Position = UDim2.new(0, 10, 0, 52)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 18, 34)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
local sideStroke = Instance.new("UIStroke", sidebar)
sideStroke.Color = Color3.fromRGB(0, 120, 210)
sideStroke.Transparency = 0.55

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop = UDim.new(0, 10)

local contentHolder = Instance.new("Frame", mainWin)
contentHolder.Size = UDim2.new(1, -182, 1, -58)
contentHolder.Position = UDim2.new(0, 172, 0, 52)
contentHolder.BackgroundTransparency = 1

local Pages = {}
local TabButtons = {}

local function CreateTab(tabName)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(15, 28, 52)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(160, 200, 240)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. tabName
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("ScrollingFrame", contentHolder)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 205, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", page)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(Pages) do p.Visible = (k == tabName) end
        for k, b in pairs(TabButtons) do
            if k == tabName then
                b.BackgroundColor3 = Color3.fromRGB(0, 135, 255)
                b.TextColor3 = Color3.new(1, 1, 1)
            else
                b.BackgroundColor3 = Color3.fromRGB(15, 28, 52)
                b.TextColor3 = Color3.fromRGB(160, 200, 240)
            end
        end
    end)

    Pages[tabName] = page
    TabButtons[tabName] = btn
    return page
end

local function AddToggle(page, title, desc, defaultVal, callback)
    local card = Instance.new("Frame", page)
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = Color3.fromRGB(13, 24, 44)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)
    local st = Instance.new("UIStroke", card)
    st.Color = Color3.fromRGB(0, 140, 235)
    st.Transparency = 0.55

    local lblTitle = Instance.new("TextLabel", card)
    lblTitle.Size = UDim2.new(1, -75, 0, 22)
    lblTitle.Position = UDim2.new(0, 12, 0, 6)
    lblTitle.BackgroundTransparency = 1
    lblTitle.Font = Enum.Font.GothamBold
    lblTitle.TextSize = 13
    lblTitle.TextXAlignment = Enum.TextXAlignment.Left
    lblTitle.TextColor3 = Color3.fromRGB(235, 248, 255)
    lblTitle.Text = title

    local lblDesc = Instance.new("TextLabel", card)
    lblDesc.Size = UDim2.new(1, -75, 0, 16)
    lblDesc.Position = UDim2.new(0, 12, 0, 27)
    lblDesc.BackgroundTransparency = 1
    lblDesc.Font = Enum.Font.Gotham
    lblDesc.TextSize = 10
    lblDesc.TextXAlignment = Enum.TextXAlignment.Left
    lblDesc.TextColor3 = Color3.fromRGB(135, 175, 220)
    lblDesc.Text = desc

    local swBtn = Instance.new("TextButton", card)
    swBtn.Size = UDim2.new(0, 48, 0, 24)
    swBtn.Position = UDim2.new(1, -60, 0.5, -12)
    swBtn.Font = Enum.Font.GothamBlack
    swBtn.TextSize = 10
    swBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", swBtn).CornerRadius = UDim.new(1, 0)

    local state = defaultVal == true
    local function Render()
        swBtn.BackgroundColor3 = state and Color3.fromRGB(0, 195, 255) or Color3.fromRGB(30, 48, 78)
        swBtn.Text = state and "ON" or "OFF"
    end
    Render()

    swBtn.MouseButton1Click:Connect(function()
        state = not state
        Render()
        task.spawn(callback, state)
    end)
end

local function AddButton(page, title, btnText, callback)
    local card = Instance.new("Frame", page)
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Color3.fromRGB(13, 24, 44)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)
    local st = Instance.new("UIStroke", card)
    st.Color = Color3.fromRGB(0, 140, 235)
    st.Transparency = 0.55

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -120, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(235, 248, 255)
    lbl.Text = title

    local actBtn = Instance.new("TextButton", card)
    actBtn.Size = UDim2.new(0, 100, 0, 28)
    actBtn.Position = UDim2.new(1, -110, 0.5, -14)
    actBtn.BackgroundColor3 = Color3.fromRGB(0, 135, 255)
    actBtn.Font = Enum.Font.GothamBlack
    actBtn.TextSize = 11
    actBtn.TextColor3 = Color3.new(1, 1, 1)
    actBtn.Text = btnText
    Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 7)

    actBtn.MouseButton1Click:Connect(function()
        task.spawn(callback, actBtn)
    end)
end

-- ============================================================================
-- 5. ISI TAB & FITUR LENGKAP
-- ============================================================================
local tabMain     = CreateTab("⚡ Auto Utama")
local tabUpgrade  = CreateTab("⬆️ Peningkatan")
local tabEvent    = CreateTab("🗼 Menara & Event")
local tabRewards  = CreateTab("🎁 Klaim & Rahasia")
local tabTeleport = CreateTab("📍 Teleport Map")
local tabDebug    = CreateTab("🔍 Log & Belajar")

TabButtons["⚡ Auto Utama"].BackgroundColor3 = Color3.fromRGB(0, 135, 255)
TabButtons["⚡ Auto Utama"].TextColor3 = Color3.new(1, 1, 1)
Pages["⚡ Auto Utama"].Visible = true

-- [TAB 1: AUTO UTAMA]
AddToggle(tabMain, "🎲 Auto Roll Cepat (RequestRoll)", "Otomatis memutar hewan peliharaan terus-menerus", false, function(v)
    State.AutoRoll = v
end)

AddToggle(tabMain, "💰 Auto Ambil Uang Podium (Plot Sendiri)", "Otomatis menyentuh CollectPad semua Podium di Plot kamu", false, function(v)
    State.AutoCollectCash = v
end)

AddToggle(tabMain, "🐾 Auto Pasang Pet & Tim Terbaik", "Otomatis memanggil EquipBestPets & EquipBestTeam", false, function(v)
    State.AutoEquipBest = v
end)

AddToggle(tabMain, "🏃 Auto Lari di Treadmill Plot", "Otomatis berdiri di atas Treadmill Plot untuk Luck Boost", false, function(v)
    State.AutoTreadmill = v
end)

AddToggle(tabMain, "⚡ Lari Cepat (WalkSpeed 55)", "Meningkatkan kecepatan jalan karakter di map", false, function(v)
    State.CustomSpeed = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and not v then hum.WalkSpeed = 16 end
end)

-- [TAB 2: PENINGKATAN]
AddToggle(tabUpgrade, "⬆️ Auto Peningkatan Level Podium", "Otomatis mendekati & meng-upgrade semua Podium yang uangnya cukup", false, function(v)
    State.AutoUpgradePodium = v
end)

AddButton(tabUpgrade, "⚡ Paksa Upgrade Semua Podium Sekarang (1x Keliling)", "UPGRADE MAX", function(btn)
    btn.Text = "PROSES..."
    for _, pod in ipairs(GetMyPodiums()) do
        UpgradeSinglePodium(pod, true)
    end
    btn.Text = "✅ SELESAI!"
    task.delay(1.5, function() if btn and btn.Parent then btn.Text = "UPGRADE MAX" end end)
end)

AddToggle(tabUpgrade, "📈 Auto Beli Peningkatan Status & Rebirth", "Otomatis membeli upgrade di menu Peningkatan & Rebirth", false, function(v)
    State.AutoBuyUpgrades = v
    if v then task.spawn(ExtractSharedData) end
end)

AddToggle(tabUpgrade, "🎲 Auto Beli & Pasang Dadu Terbaik", "Otomatis membeli dan memasang dadu terbaik", false, function(v)
    State.AutoBuyDice = v
    if v then task.spawn(ExtractSharedData) end
end)

-- [TAB 3: MENARA & EVENT]
AddToggle(tabEvent, "🗼 Smart Auto Menara (Auto Team + Anti-Macet Revive)", "Pasang tim terbaik, masuk menara, tolak layar Revive, & Auto Retry", false, function(v)
    State.AutoTower = v
    if v then
        TowerRuntime.InTower = false
        TowerRuntime.LastStartAttempt = 0
        TryEnterOrRunTower()
    end
end)

AddButton(tabEvent, "⚔️ Pasang Tim Terbaik & Buka Menu Menara", "BUKA MENARA", function()
    SafeInvoke("EquipBestTeam")
    TeleportTo(Vector3.new(-309.8, 329.5, -28.2))
    task.wait(0.25)
    local towersPad = Workspace:FindFirstChild("TowersPad")
    local zone = towersPad and towersPad:FindFirstChild("Zone")
    local att = zone and zone:FindFirstChild("StandPromptAttachment")
    local standPrompt = att and att:FindFirstChild("StandTowers")
    if standPrompt then TriggerPrompt(standPrompt) end
end)

AddToggle(tabEvent, "🍬 Auto Klaim Permen Halloween (CandyRain)", "Otomatis menyedot dan klaim semua permen saat Candy Rain", false, function(v)
    State.AutoCandyClaim = v
end)

AddToggle(tabEvent, "♻️ Auto Rebirth Otomatis", "Otomatis melakukan Rebirth begitu syarat uang terpenuhi", false, function(v)
    State.AutoRebirth = v
end)

AddToggle(tabEvent, "🗑️ Auto Jual Pet Terlemah (SellWeakest)", "Otomatis menjual pet terlemah agar tas tidak penuh", false, function(v)
    State.AutoSellWeakest = v
end)

-- [TAB 4: KLAIM & RAHASIA]
AddButton(tabRewards, "🌟 Klaim 3 Golden Dice Rahasia (Alley, Hidden, Tower)", "KLAIM SEMUA", function(btn)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local oldCF = hrp.CFrame
    btn.Text = "MENGAMBIL..."

    local secrets = {
        Workspace:FindFirstChild("AlleySecret"),
        Workspace:FindFirstChild("HiddenSecret"),
        Workspace:FindFirstChild("TowerSecret"),
    }

    for _, model in ipairs(secrets) do
        local dice = model and model:FindFirstChild("GoldenDice")
        local prompt = dice and dice:FindFirstChildOfClass("ProximityPrompt")
        if dice and prompt then
            TeleportTo(dice.Position)
            task.wait(0.35)
            TriggerPrompt(prompt)
            task.wait(1.1)
        end
    end

    hrp.CFrame = oldCF
    btn.Text = "✅ SELESAI!"
    task.delay(2, function() if btn and btn.Parent then btn.Text = "KLAIM SEMUA" end end)
end)

AddToggle(tabRewards, "🎡 Auto Spin Wheel Gratis", "Otomatis memutar Spin Wheel setiap kali tersedia", false, function(v)
    State.AutoSpinWheel = v
end)

AddToggle(tabRewards, "🎁 Auto Klaim Daily, Playtime, Quest & Chest", "Otomatis klaim hadiah harian, waktu main, achievement, & peti", false, function(v)
    State.AutoClaimRewards = v
end)

AddToggle(tabRewards, "⏩ Auto Skip 5 Menit (AdBoard Plot)", "Otomatis memicu WatchSkipAd / WatchPrompt di papan iklan Plot", false, function(v)
    State.AutoSkipAdBoard = v
end)

-- [TAB 5: TELEPORT MAP]
AddButton(tabTeleport, "🏠 Teleport ke Plot / Base Sendiri", "TELEPORT", function()
    local plot = GetMyPlot()
    local sp = plot and plot:FindFirstChild("Spawn")
    if sp then TeleportTo(sp.Position) else SafeInvoke("TravelHome") end
end)

AddButton(tabTeleport, "🧬 Teleport ke Mesin Fuse (FusingMachine)", "TELEPORT", function()
    TeleportTo(Vector3.new(229.0, 326.0, 13.5))
end)

AddButton(tabTeleport, "🍬 Teleport ke Candy Shop Halloween", "TELEPORT", function()
    TeleportTo(Vector3.new(203.7, 329.5, 48.1))
end)

AddButton(tabTeleport, "⚰️ Teleport ke Haunted Crate Stand", "TELEPORT", function()
    TeleportTo(Vector3.new(189.5, 330.3, 55.6))
end)

AddButton(tabTeleport, "🎡 Teleport ke Roda Putar (Spin Wheel)", "TELEPORT", function()
    TeleportTo(Vector3.new(235.5, 339.1, -53.7))
end)

AddButton(tabTeleport, "🗼 Teleport ke Gerbang Towers", "TELEPORT", function()
    TeleportTo(Vector3.new(-297.8, 326.0, -28.2))
end)

-- [TAB 6: LOG & BELAJAR OTOMATIS]
local debugBox = Instance.new("TextBox", tabDebug)
debugBox.Size = UDim2.new(1, 0, 0, 210)
debugBox.BackgroundColor3 = Color3.fromRGB(5, 10, 18)
debugBox.TextColor3 = Color3.fromRGB(0, 215, 255)
debugBox.Font = Enum.Font.Code
debugBox.TextSize = 11
debugBox.TextXAlignment = Enum.TextXAlignment.Left
debugBox.TextYAlignment = Enum.TextYAlignment.Top
debugBox.MultiLine = true
debugBox.TextWrapped = true
debugBox.ClearTextOnFocus = false
debugBox.TextEditable = false
debugBox.Text = "Klik manual 1x pada tombol Upgrade atau Menara di game, maka script otomatis merekam dan mempelajari argumennya di sini!"
Instance.new("UICorner", debugBox).CornerRadius = UDim.new(0, 8)

AddButton(tabDebug, "📋 Copy Log Pembelajaran Remote", "COPY LOG", function(btn)
    local fn = setclipboard or toclipboard
    if type(fn) == "function" then
        pcall(fn, debugBox.Text)
        btn.Text = "✅ TERSALIN!"
        task.delay(1.5, function() if btn and btn.Parent then btn.Text = "COPY LOG" end end)
    end
end)

task.spawn(function()
    while screenGui.Parent do
        if Pages["🔍 Log & Belajar"].Visible then
            debugBox.Text = "=== LOG SELF-LEARNING ROCKSTAR v6.3 ===\n"
                .. "InTower Status: " .. tostring(TowerRuntime.InTower) .. "\n"
                .. table.concat(Discovered.RecentLogs, "\n")
        end
        task.wait(1)
    end
end)

-- ============================================================================
-- 6. LOOP OTOMATISASI PRESISI (BACKGROUND ENGINE)
-- ============================================================================

LocalPlayer.Idled:Connect(function()
    pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
end)

-- Loop 1: Auto Roll Cepat
task.spawn(function()
    while screenGui.Parent do
        if State.AutoRoll then
            SafeInvoke("RequestRoll", false)
            task.wait(0.15)
        else
            task.wait(0.4)
        end
    end
end)

-- Loop 2: Auto Collect Cash & Smart Podium Upgrade
task.spawn(function()
    while screenGui.Parent do
        if State.AutoCollectCash or State.AutoUpgradePodium then
            local podiums = GetMyPodiums()
            for _, pod in ipairs(podiums) do
                if State.AutoCollectCash then
                    local pad = pod:FindFirstChild("CollectPad")
                    if pad then
                        local storedBase = tonumber(pad:GetAttribute("StoredBase")) or 0
                        local storedRate = tonumber(pad:GetAttribute("StoredRate")) or 0
                        if storedBase > 0 or storedRate > 0 then
                            TriggerTouch(pad)
                            SafeFire("CashCollected", pod:GetAttribute("Slot"))
                        end
                    end
                end

                if State.AutoUpgradePodium then
                    UpgradeSinglePodium(pod, true)
                end
            end
        end
        task.wait(1.2)
    end
end)

-- Loop 3: Auto Beli Peningkatan Status & Dadu
task.spawn(function()
    while screenGui.Parent do
        if State.AutoBuyUpgrades then
            if #Discovered.LearnedCalls.BuyUpgrade > 0 then
                SafeInvoke("BuyUpgrade", table.unpack(Discovered.LearnedCalls.BuyUpgrade))
            end
            for _, upgId in ipairs(Discovered.UpgradeIds) do
                if not State.AutoBuyUpgrades then break end
                SafeInvoke("BuyUpgrade", upgId)
                task.wait(0.05)
            end
            if #Discovered.LearnedCalls.UpgradeRebirthStat > 0 then
                SafeInvoke("UpgradeRebirthStat", table.unpack(Discovered.LearnedCalls.UpgradeRebirthStat))
            end
            for _, statId in ipairs(Discovered.RebirthStatIds) do
                if not State.AutoBuyUpgrades then break end
                SafeInvoke("UpgradeRebirthStat", statId)
                task.wait(0.05)
            end
        end

        if State.AutoBuyDice then
            for _, diceId in ipairs(Discovered.DiceIds) do
                if not State.AutoBuyDice then break end
                SafeInvoke("BuyDice", diceId)
                SafeInvoke("EquipDice", diceId)
                task.wait(0.05)
            end
        end

        task.wait(2.5)
    end
end)

-- Loop 4: Auto Treadmill & WalkSpeed
RunService.Heartbeat:Connect(function()
    if not screenGui.Parent then return end
    local char = LocalPlayer.Character
    if not char then return end

    if State.CustomSpeed then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed < 55 then hum.WalkSpeed = 55 end
    end

    if State.AutoTreadmill then
        local plot = GetMyPlot()
        local tm = plot and plot:FindFirstChild("Treadmill")
        local deck = tm and tm:FindFirstChild("Deck")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if deck and hrp then
            if (hrp.Position - deck.Position).Magnitude > 6 then
                hrp.CFrame = deck.CFrame + Vector3.new(0, 3.2, 0)
            end
            for _, d in ipairs(tm:GetDescendants()) do
                if d:IsA("ProximityPrompt") then TriggerPrompt(d) end
            end
        end
    end
end)

-- Loop 5: Auto Menara, Equip, Rewards, Spin, Rebirth, Candy
task.spawn(function()
    while screenGui.Parent do
        if State.AutoEquipBest then
            SafeInvoke("EquipBestPets")
            SafeInvoke("EquipBestTeam")
        end

        if State.AutoTower then
            TryEnterOrRunTower()
        end

        if State.AutoSpinWheel then
            SafeInvoke("SpinWheel")
            local sw = Workspace:FindFirstChild("SpinWheel")
            local base = sw and sw:FindFirstChild("Base")
            local pr = base and base:FindFirstChildOfClass("ProximityPrompt")
            if pr then TriggerPrompt(pr) end
        end

        if State.AutoClaimRewards then
            SafeInvoke("ClaimDaily")
            SafeInvoke("ClaimAllAchievements")
            SafeInvoke("ClaimStarterQuest")
            SafeInvoke("ClaimGroupChest")
            SafeInvoke("ClaimFriendChest")
            for i = 1, 12 do
                SafeInvoke("ClaimPlaytime", i)
                SafeInvoke("ClaimQuest", i)
            end
        end

        if State.AutoSkipAdBoard then
            SafeInvoke("WatchSkipAd")
            local plot = GetMyPlot()
            local ad = plot and plot:FindFirstChild("AdBoard")
            local panel = ad and ad:FindFirstChild("Panel")
            local wp = panel and panel:FindFirstChild("WatchPrompt")
            if wp then TriggerPrompt(wp) end
        end

        if State.AutoRebirth then SafeInvoke("Rebirth") end
        if State.AutoSellWeakest then SafeInvoke("SellWeakest") end

        if State.AutoCandyClaim then
            SafeFire("CandyClaim")
            local cr = Workspace:FindFirstChild("CandyRain")
            if cr then
                for _, item in ipairs(cr:GetDescendants()) do
                    if item:IsA("BasePart") and item.Position.Y > 0 then
                        TriggerTouch(item)
                    end
                end
            end
        end

        task.wait(2.5)
    end
end)
