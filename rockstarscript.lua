-- Cek apakah game sudah dimuat
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rockstarscript",
   LoadingTitle = "rockstarscript Map Inspector",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Map Inspector Siap!",
   Content = "Klik tombol di tab untuk menganalisis struktur map.",
   Duration = 5,
})

local MainTab = Window:CreateTab("Map Analysis", 4483362458)
local MainSection = MainTab:CreateSection("Analisis Struktur Map")

MainTab:CreateButton({
   Name = "Analisis Objek & Model Terdekat",
   Callback = function()
      local player = game.Players.LocalPlayer
      local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
      
      if not hrp then
         Rayfield:Notify({Title = "Error", Content = "Karakter belum siap!", Duration = 3})
         return
      end
      
      local scannedCount = 0
      local foundCategories = {}
      
      -- Menelusuri seluruh folder dan model di dalam workspace
      for _, obj in pairs(workspace:GetChildren()) do
         if obj:IsA("Model") or obj:IsA("Folder") then
            -- Hitung jarak dari player ke model/folder tersebut (jika ada Part utamanya)
            local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if targetPart then
               local dist = (hrp.Position - targetPart.Position).Magnitude
               if dist < 100 then -- Jarak 100 meter dari player
                  scannedCount += 1
                  Rayfield:Notify({
                     Title = "Ketemu Folder/Model:",
                     Content = obj.Name .. " (Jarak: " .. math.floor(dist) .. "m)",
                     Duration = 4,
                  })
                  task.wait(1.2)
                  if scannedCount >= 8 then break end
               end
            end
         end
      end
      
      if scannedCount == 0 then
         Rayfield:Notify({
            Title = "Hasil Kosong",
            Content = "Coba pindah posisi karakter lalu scan ulang.",
            Duration = 4,
         })
      else
         Rayfield:Notify({
            Title = "Analisis Selesai",
            Content = "Total " .. scannedCount .. " struktur terdeteksi di sekitar Anda.",
            Duration = 5,
         })
      end
   end,
})
