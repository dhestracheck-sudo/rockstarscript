assert(game:GetService("RunService"):IsStudio(), "Jalankan hanya di Roblox Studio")

local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function allDescendants(root)
	local items = {root}
	for _, item in ipairs(root:GetDescendants()) do
		table.insert(items, item)
	end
	return items
end

local function hasZoneWord(name)
	name = string.lower(name)
	for _, word in ipairs({"zone", "area", "world", "island", "last", "final", "steal", "kandang"}) do
		if string.find(name, word, 1, true) then
			return true
		end
	end
	return false
end

local function getAttributes(instance)
	local result = {}
	for key, value in pairs(instance:GetAttributes()) do
		table.insert(result, key .. "=" .. tostring(value))
	end
	table.sort(result)
	return #result > 0 and table.concat(result, ", ") or "-"
end

local function findZoneAncestor(instance)
	local parent = instance.Parent
	while parent and parent ~= workspace do
		if (parent:IsA("Model") or parent:IsA("Folder")) and hasZoneWord(parent.Name) then
			return parent:GetFullName()
		end
		parent = parent.Parent
	end
	return "-"
end

local function printList(title, items, limit)
	table.sort(items, function(a, b)
		return a:GetFullName() < b:GetFullName()
	end)

	print("\n=== " .. title .. " (" .. #items .. ") ===")
	for index, item in ipairs(items) do
		if index > limit then
			print("... sisanya tidak ditampilkan")
			break
		end
		print(item:GetFullName() .. " [" .. item.ClassName .. "]")
	end
end

local worldItems = allDescendants(workspace)

local zones = {}
local prompts = {}
for _, item in ipairs(worldItems) do
	if (item:IsA("Model") or item:IsA("Folder")) and hasZoneWord(item.Name) then
		table.insert(zones, item)
	end
	if item:IsA("ProximityPrompt") then
		table.insert(prompts, item)
	end
end

printList("KANDIDAT ZONA DI WORKSPACE", zones, 150)

table.sort(prompts, function(a, b)
	return a:GetFullName() < b:GetFullName()
end)
print("\n=== PROXIMITY PROMPTS (" .. #prompts .. ") ===")
for index, prompt in ipairs(prompts) do
	if index > 200 then
		print("... sisanya tidak ditampilkan")
		break
	end

	local parent = prompt.Parent
	local part = parent
	if part and part:IsA("Attachment") then
		part = part.Parent
	end

	local position = "-"
	if part and part:IsA("BasePart") then
		position = tostring(part.Position)
	end

	print(string.format(
		"%s | zone=%s | enabled=%s | jarak=%.1f | tahan=%.1f | LOS=%s | posisi=%s | attrs=%s",
		prompt:GetFullName(),
		findZoneAncestor(prompt),
		tostring(prompt.Enabled),
		prompt.MaxActivationDistance,
		prompt.HoldDuration,
		tostring(prompt.RequiresLineOfSight),
		position,
		getAttributes(prompt)
	))
end

local remotes = {}
for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
	if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
		table.insert(remotes, item)
	end
end
printList("REMOTE DI REPLICATEDSTORAGE (nama/path saja)", remotes, 150)

local scriptRoots = {
	game:GetService("ServerScriptService"),
	game:GetService("ServerStorage"),
	game:GetService("StarterPlayer"),
	game:GetService("StarterGui"),
	ReplicatedStorage,
	workspace,
}

local scripts = {}
for _, root in ipairs(scriptRoots) do
	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
			table.insert(scripts, item)
		end
	end
end
printList("SCRIPT YANG MUNGKIN MENGATUR ZONA/PROMPT (nama/path saja)", scripts, 200)

print("\n=== SELESAI: kirim isi Output ini untuk ditinjau ===")
