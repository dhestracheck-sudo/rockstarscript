-- Cek apakah game sudah sepenuhnya dimuat
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rockstarscript",
   LoadingTitle = "rockstarscript Scanner v2",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Scanner Siap!",
   Content = "Klik tombol di bawah untuk melihat hasil scan di layar.",
   Duration = 5,
})

local MainTab = Window:CreateTab("Scanner Map", 4483362458)
local MainSection = MainTab:CreateSection("Pemindai Langsung")

MainTab:CreateButton({
   Name = "Scan & Tampilkan Nama Prompt/Zone",
   Callback = function()
      local foundNames = {}
      local count = 0
      
      pcall(function()
          for _, v in pairs(workspace:GetDescendants()) do
              if v:IsA("ProximityPrompt") then
                  count += 1
                  local parentName = v.Parent and v.Parent.Name or "Unknown"
                  if not foundNames[parentName] then
                      foundNames[parentName] = true
                      -- Munculkan nama objek langsung ke notifikasi layar satu per satu
                      Rayfield:Notify({
                         Title = "Ditemukan Zone/Objek:",
                         Content = parentName,
                         Duration = 4,
                      })
                      task.wait(1)
                  end
              end
          end
      end)
      
      Rayfield:Notify({
         Title = "Scan Selesai!",
         Content = "Total ProximityPrompt: " .. count,
         Duration = 6,
      })
   end,
})
