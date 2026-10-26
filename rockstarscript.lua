if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rockstarscript | Pro Zone & Rarity",
   LoadingTitle = "Advanced Auto Farm Panel",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Panel Siap!",
   Content = "Pilih zona dan rarity kandang yang ingin diambil.",
   Duration = 4,
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)
MainTab:CreateSection("Pengaturan Filter Target")

-- Fungsi mendeteksi folder/zona secara otomatis di workspace
local function getZones()
   local zones = {"Semua Zona", "Black Hole"}
   pcall(function()
      for _, child in pairs(workspace:GetChildren()) do
         if (child:IsA("Folder") or child:IsA("Model")) and child.Name ~= "Black Hole" then
            table.insert(zones, child.Name)
         end
      end
   end)
   return zones
end

local selectedZone = "Semua Zona"
local selectedRarity = "Semua Rarity"
local autoFarmActive = false

-- Dropdown Pilihan Zona
local ZoneDropdown = MainTab:CreateDropdown({
   Name = "Pilih Zona Map",
   Options = getZones(),
   CurrentOption = "Semua Zona",
   Flag = "ZoneDropdown",
   Callback = function(Option)
      selectedZone = Option
   end,
})

-- Dropdown Pilihan Rarity Kandang
MainTab:CreateDropdown({
   Name = "Pilih Rarity Kandang",
   Options = {"Semua Rarity", "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Godly"},
   CurrentOption = "Semua Rarity",
   Flag = "RarityDropdown",
   Callback = function(Option)
      selectedRarity = Option
   end,
})

MainTab:CreateButton({
   Name = "Refresh Daftar Zona",
   Callback = function()
      ZoneDropdown:Refresh(getZones())
      Rayfield:Notify({
         Title = "Berhasil",
         Content = "Daftar zona berhasil diperbarui!",
         Duration = 2,
      })
   end,
})

MainTab:CreateSection("Eksekusi Filter")

MainTab:CreateToggle({
   Name = "Mulai Auto Farm (Zona & Rarity)",
   CurrentValue = false,
   Flag = "AutoFarmZoneRarity",
   Callback = function(Value)
      autoFarmActive = Value
      task.spawn(function()
         while autoFarmActive do
            task.wait(0.1)
            pcall(function()
               local player = game.Players.LocalPlayer
               local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               
               if hrp then
                  for _, prompt in pairs(workspace:GetDescendants()) do
                     if not autoFarmActive then break end
                     
                     if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local currentParent = prompt.Parent
                        local matchZone = false
                        local matchRarity = false
                        
                        -- 1. Validasi Zona
                        if selectedZone == "Semua Zona" then
                           matchZone = true
                        else
                           local foundZone = false
                           local tempParent = currentParent
                           while tempParent and tempParent ~= workspace do
                              if string.find(string.lower(tempParent.Name), string.lower(selectedZone)) then
                                 foundZone = true
                                 break
                              end
                              tempParent = tempParent.Parent
                           end
                           matchZone = found
