if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("RockstarVisualScanner") then
    playerGui.RockstarVisualScanner:Destroy()
end

local espFolder = Instance.new("ScreenGui")
espFolder.Name = "RockstarVisualScanner"
espFolder.ResetOnSpawn = false
espFolder.Parent = playerGui

local function createESP(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if prompt:FindFirstChild("RockstarESP_Tag") then return end
    
    local tag = Instance.new("BoolValue")
    tag.Name = "RockstarESP_Tag"
    tag.Parent = prompt
    
    local part = prompt.Parent
    if part:IsA("Attachment") then part = part.Parent end
    if not part or not part:IsA("BasePart") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PromptESP"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 250, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Code
    textLabel.TextWrapped = true
    textLabel.Text = "⬇️ TARGET DITEMUKAN ⬇️\n" .. prompt:GetFullName()
    textLabel.Parent = billboard
    
    billboard.Parent = espFolder
end

for _, obj in pairs(workspace:GetDescendants()) do
    createESP(obj)
end

workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    createESP(obj)
end)

local StarterGui = game:GetService("StarterGui")
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Rockstar Scanner";
        Text = "Visual ESP Aktif! Kelilingi map, cari teks melayang warna Cyan.";
        Duration = 10;
    })
end)
