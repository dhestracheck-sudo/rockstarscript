-- LocalScript di StarterPlayer > StarterPlayerScripts
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TARGET_PROMPT_NAME = "StealPrompt" -- ganti sesuai nama prompt; nil untuk mencari semua prompt

local previousGui = playerGui:FindFirstChild("MapPromptTester")
if previousGui then
	previousGui:Destroy()
end

local highlights = {}
local rows = {}

local function clearHighlights()
	for _, highlight in ipairs(highlights) do
		highlight:Destroy()
	end
	table.clear(highlights)
end

local function clearRows()
	for _, row in ipairs(rows) do
		row:Destroy()
	end
	table.clear(rows)
end

local function getTargetPart(prompt)
	local target = prompt.Parent

	if target and target:IsA("Attachment") then
		target = target.Parent
	end

	if target and target:IsA("BasePart") then
		return target
	end

	return nil
end

local gui = Instance.new("ScreenGui")
gui.Name = "MapPromptTester"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(410, 370)
frame.Position = UDim2.new(0, 24, 0.5, -185)
frame.BackgroundColor3 = Color3.fromRGB(24, 25, 31)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -48, 0, 42)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "Map Prompt Tester — Studio"
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(32, 30)
closeButton.Position = UDim2.new(1, -40, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(55, 57, 66)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 42)
status.Position = UDim2.fromOffset(14, 45)
status.BackgroundTransparency = 1
status.Text = "Tekan Scan untuk memeriksa prompt di map."
status.TextColor3 = Color3.fromRGB(190, 193, 203)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(1, -28, 0, 34)
scanButton.Position = UDim2.fromOffset(14, 90)
scanButton.BackgroundColor3 = Color3.fromRGB(225, 112, 36)
scanButton.Text = "Scan ulang"
scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
scanButton.Font = Enum.Font.GothamBold
scanButton.TextSize = 13
scanButton.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -28, 1, -140)
list.Position = UDim2.fromOffset(14, 134)
list.BackgroundColor3 = Color3.fromRGB(32, 34, 41)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = frame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 7)
listCorner.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 7)
padding.PaddingBottom = UDim.new(0, 7)
padding.PaddingLeft = UDim.new(0, 7)
padding.PaddingRight = UDim.new(0, 7)
padding.Parent = list

local function scanMap()
	clearRows()
	clearHighlights()

	local found = {}

	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("ProximityPrompt")
			and (TARGET_PROMPT_NAME == nil or object.Name == TARGET_PROMPT_NAME) then
			table.insert(found, object)
		end
	end

	table.sort(found, function(a, b)
		return a:GetFullName() < b:GetFullName()
	end)

	for index, prompt in ipairs(found) do
		local target = getTargetPart(prompt)

		if target then
			local highlight = Instance.new("Highlight")
			highlight.Name = "MapPromptTestHighlight"
			highlight.Adornee = target
			highlight.FillTransparency = 0.72
			highlight.OutlineColor = prompt.Enabled
				and Color3.fromRGB(80, 220, 120)
				or Color3.fromRGB(245, 75, 75)
			highlight.FillColor = highlight.OutlineColor
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = workspace
			table.insert(highlights, highlight)
		end

		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -2, 0, 48)
		button.BackgroundColor3 = Color3.fromRGB(46, 48, 57)
		button.TextColor3 = Color3.fromRGB(235, 236, 240)
		button.Font = Enum.Font.Gotham
		button.TextSize = 11
		button.TextWrapped = true
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.LayoutOrder = index
		button.Parent = list

		local enabledText = prompt.Enabled and "Aktif" or "Nonaktif"
		button.Text = string.format(
			"  %02d. %s | %s | Jarak %.1f | Tahan %.1fs",
			index,
			prompt:GetFullName(),
			enabledText,
			prompt.MaxActivationDistance,
			prompt.HoldDuration
		)

		table.insert(rows, button)

		button.MouseButton1Click:Connect(function()
			local part = getTargetPart(prompt)
			local character = player.Character

			if not part or not character then
				status.Text = "Target atau karakter tidak ditemukan."
				return
			end

			character:PivotTo(part.CFrame * CFrame.new(0, 3, 0))
			status.Text = "Dekat dengan " .. prompt:GetFullName()
				.. " — uji prompt secara normal dengan tombol E."
		end)
	end

	status.Text = string.format(
		"Ditemukan %d prompt%s. Hijau = aktif, merah = nonaktif.",
		#found,
		TARGET_PROMPT_NAME and (" bernama " .. TARGET_PROMPT_NAME) or ""
	)
end

scanButton.MouseButton1Click:Connect(scanMap)

closeButton.MouseButton1Click:Connect(function()
	clearHighlights()
	gui:Destroy()
end)

scanMap()
