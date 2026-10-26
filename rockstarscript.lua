-- Cek apakah game sudah sepenuhnya dimuat
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Inisialisasi Window Utama
local Window = Rayfield:CreateWindow({
   Name = "rockstarscript",
   LoadingTitle = "rockstarscript Scanner",
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

Rayfield:Notify({
   Title = "rockstarscript Loaded!",
   Content = "Menu Scanner Map & Remote Aktif!",
   Duration = 5,
   Image = 4483362458,
})

----------------------------------------------------------------
-- TAB 1: SCANNER & AUTO FARM
----------------------------------------------------------------
local MainTab = Window:CreateTab("Scanner Map", 4483362458)
local MainSection = MainTab:CreateSection("Alat Pemindai Struktur Game")

MainTab:CreateButton({
   Name = "Scan Workspace & ProximityPrompt",
   Callback = function()
      local countPrompt = 0
      local foundZones = {}
      
      pcall(function()
          for _, v in pairs(workspace:GetDescendants()) do
              if v:IsA("ProximityPrompt") then
                  countPrompt += 1
                  local parentName = v.Parent and v.Parent.Name or "Unknown"
                  if not foundZones[parentName] then
                      foundZones[parentName] = 0
                  end
                  foundZones[parentName] += 1
              end
          end
      end)
      
      -- Tampilkan hasil scan lewat Notifikasi Rayfield
      Rayfield:Notify({
         Title = "Hasil Scan Selesai!",
         Content = "Ditemukan " .. countPrompt .. " ProximityPrompt di map.",
         Duration = 7,
      })
      
      print("=== ROCKSTARSCRIPT SCANNER RESULT ===")
      print("Total ProximityPrompt: " .. countPrompt)
      for name, qty in pairs(foundZones) do
          print("- Parent Object: " .. name .. " (Jumlah: " .. qty .. ")")
      end
      print("======================================")
   end,
})

MainTab:CreateButton({
   Name = "Scan ReplicatedStorage (RemoteEvent)",
   Callback = function()
      local countRemotes = 0
      pcall(function()
          for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
              if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                  countRemotes += 1
                  print("Remote Ditemukan: " .. v:GetFullName())
              end
          end
      end)
      
      Rayfield:Notify({
         Title = "Scan Remote Selesai!",
         Content = "Cek Console/F9 di game untuk melihat daftar RemoteEvent.",
         Duration = 7,
      })
   end,
})

local autoSteal = false
MainTab:CreateToggle({
   Name = "Auto Steal Pet (Teleport & Curi Otomatis)",
   CurrentValue = false,
   Flag = "AutoStealV2",
   Callback = function(Value)
      autoSteal = Value
      task.spawn(function()
         while autoSteal do
             task.wait(0.2)
             pcall(function()
                 local player = game.Players.LocalPlayer
                 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                 
                 if hrp then
                     for _, prompt in pairs(workspace:GetDescendants()) do
                         if not autoSteal then break end
                         
                         if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                             local parentObj = prompt.Parent
                             if parentObj and parentObj:IsA("BasePart") then
                                 hrp.CFrame = parentObj.CFrame * CFrame.new(0, 2, 0)
                                 task.wait(0.1)
                                 fireproximityprompt(prompt)
                                 task.wait(prompt.HoldDuration > 0 and prompt.HoldDuration or 0.2)
                             end
                         end
                     end
                 end
             end)
         end
      end)
   end,
})
