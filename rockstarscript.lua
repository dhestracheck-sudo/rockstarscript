-- Cek apakah game sudah sepenuhnya dimuat
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Inisialisasi Window Utama
local Window = Rayfield:CreateWindow({
   Name = "rockstarscript",
   LoadingTitle = "rockstarscript Hub",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RockstarScriptConfig",
      FileName = "MainConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      Keys = {}
   },
   KeySystem = false
})

-- Notifikasi Berhasil Dijalankan
Rayfield:Notify({
   Title = "rockstarscript Loaded!",
   Content = "Fitur Auto Curi & Zona berhasil diperbarui!",
   Duration = 5,
   Image = 4483362458,
})

----------------------------------------------------------------
-- TAB 1: AUTO FARM & ZONA CURI
----------------------------------------------------------------
local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local MainSection = MainTab:CreateSection("Pengaturan Zona & Curi Pet")

-- Variabel untuk menyimpan target zona yang dipilih
local selectedZone = "Semua Zona"

MainTab:CreateDropdown({
   Name = "Pilih Zona Curi Pet",
   Options = {"Semua Zona", "Zona 1 (Normal)", "Zona 2 (Rare)", "Zona 3 (Epic/Legendary)"},
   CurrentOption = {"Semua Zona"},
   MultipleOptions = false,
   Flag = "ZoneDropdown",
   Callback = function(Option)
      selectedZone = Option[1]
   end,
})

local autoSteal = false
MainTab:CreateToggle({
   Name = "Auto Steal Pet (Diperbaiki & Aman)",
   CurrentValue = false,
   Flag = "AutoSteal",
   Callback = function(Value)
      autoSteal = Value
      task.spawn(function()
         while autoSteal do
             task.wait(0.4)
             pcall(function()
                 -- Loop untuk mendeteksi ProximityPrompt atau bagian Pet di workspace
                 for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("ProximityPrompt") then
                         local textCheck = (v.ActionText .. " " .. v.ObjectText):lower()
                         if textCheck:find("steal") or textCheck:find("pet") then
                             -- Filter berdasarkan Zona yang dipilih user
                             local passZone = false
                             if selectedZone == "Semua Zona" then
                                 passZone = true
                             elseif selectedZone:find("Zona 1") and v.Parent and v.Parent.Name:lower():find("zone1") then
                                 passZone = true
                             elseif selectedZone:find("Zona 2") and v.Parent and v.Parent.Name:lower():find("zone2") then
                                 passZone = true
                             elseif selectedZone:find("Zona 3") and v.Parent and v.Parent.Name:lower():find("zone3") then
                                 passZone = true
                             end
                             
                             -- Jika zona sesuai atau memilih Semua Zona, jalankan prompt secara aman
                             if passZone or selectedZone == "Semua Zona" then
                                 fireproximityprompt(v)
                             end
                         end
                     end
                 end
             end)
         end
      end)
   end,
})

local autoCoin = false
MainTab:CreateToggle({
   Name = "Auto Collect Coins (Ambil Koin)",
   CurrentValue = false,
   Flag = "AutoCoin",
   Callback = function(Value)
      autoCoin = Value
      task.spawn(function()
         while autoCoin do
             task.wait(0.3)
             pcall(function()
                 local player = game.Players.LocalPlayer
                 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then
                     for _, coin in pairs(workspace:GetDescendants()) do
                         if coin:IsA("BasePart") and (coin.Name:lower():find("coin") or coin.Name:lower():find("gem") or coin.Name:lower():find("money")) then
                             coin.CFrame = hrp.CFrame
                         end
                     end
                 end
             end)
         end
      end)
   end,
})

----------------------------------------------------------------
-- TAB 2: RIDE PET
----------------------------------------------------------------
local RideTab = Window:CreateTab("Ride Pet", 4483362458)
local RideSection = RideTab:CreateSection("Kustomisasi & Tunggangan")

RideTab:CreateButton({
   Name = "Naiki Pet Terdekat (Ride)",
   Callback = function()
      pcall(function()
          local player = game.Players.LocalPlayer
          local char = player.Character
          local hrp = char and char:FindFirstChild("HumanoidRootPart")
          
          if hrp then
              local targetPet = nil
              local shortestDistance = math.huge
              
              for _, obj in pairs(workspace:GetDescendants()) do
                  if obj:IsA("Model") and (obj.Name:lower():find("pet") or obj.Name:lower():find("animal")) and obj ~= char then
                      local petPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
                      if petPart then
                          local dist = (hrp.Position - petPart.Position).Magnitude
                          if dist < shortestDistance and dist < 25 then
                              shortestDistance = dist
                              targetPet = petPart
                          end
                      end
                  end
              end
              
              if targetPet then
                  hrp.CFrame = targetPet.CFrame + Vector3.new(0, 3, 0)
                  Rayfield:Notify({Title = "Berhasil!", Content = "Anda menaiki hewan peliharaan.", Duration = 3})
              else
                  Rayfield:Notify({Title = "Gagal", Content = "Tidak ada pet di sekitar Anda!", Duration = 3})
              end
          end
      end)
   end,
})

RideTab:CreateSlider({
   Name = "Kecepatan Naik Pet (Speed Multiplier)",
   Range = {16, 150},
   Increment = 1,
   Suffix = "WalkSpeed",
   CurrentValue = 16,
   Flag = "PetSpeed",
   Callback = function(Value)
      pcall(function()
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

----------------------------------------------------------------
-- TAB 3: PLAYER MODS
----------------------------------------------------------------
local PlayerTab = Window:CreateTab("Player", 4483362458)
local PlayerSection = PlayerTab:CreateSection("Pengaturan Karakter")

PlayerTab:CreateSlider({
   Name = "Player WalkSpeed",
   Range = {16, 250},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "PlayerSpeed",
   Callback = function(Value)
      pcall(function()
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

PlayerTab:CreateSlider({
   Name = "Player JumpPower",
   Range = {50, 300},
   Increment = 10,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "PlayerJump",
   Callback = function(Value)
      pcall(function()
          game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
          game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
      end)
   end,
})

local infJump = false
PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      infJump = Value
   end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
   if infJump then
      pcall(function()
          game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
      end)
   end
end)
