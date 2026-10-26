-- Cek apakah game sudah dimuat sepenuhnya
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rockstarscript | Pro Inspector",
   LoadingTitle = "rockstarscript Professional Scanner",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Pro Scanner Siap!",
   Content = "Sistem pemindaian mendalam berhasil dimuat.",
   Duration = 4,
})

local MainTab = Window:CreateTab("Pro Scanner", 4483362458)
local MainSection = MainTab:CreateSection("Analisis Komprehensif Map & Objek")

MainTab:CreateButton({
   Name = "Jalankan Pemindaian Profesional",
   Callback = function()
      task.spawn(function()
         Rayfield:Notify({
            Title = "Memindai...",
            Content = "Sedang menganalisis seluruh struktur Workspace...",
            Duration = 3,
         })

         local promptCount = 0
         local uniqueParents = {}
         local workspaceFolders = {}

         pcall(function()
            -- Scan seluruh isi workspace secara aman
            for _, obj in ipairs(workspace:GetDescendants()) do
               if obj:IsA("ProximityPrompt") then
                  promptCount += 1
                  local parent = obj.Parent
                  if parent then
                     local parentName = parent.Name
                     uniqueParents[parentName] = (uniqueParents[parentName] or 0) + 1
                  end
               end
            end

            for _, child in ipairs(workspace:GetChildren()) do
               if child:IsA("Folder") or child:IsA("Model") then
                  workspaceFolders[child.Name] = child.ClassName
               end
            end
         end)

         -- Cetak laporan lengkap dan rapi ke Console (F9 / Console Executor)
         print("\n================ [ROCKSTAR SCRIPT PRO REPORT] ================")
         print("Total ProximityPrompt Ditemukan: " .. promptCount)
         print("\n--- Daftar Parent / Wadah Prompt Unik ---")
         for name, count in pairs(uniqueParents) do
            print(string.format("Nama Parent: '%s' | Ditemukan: %d buah", name, count))
         end
         print("\n--- Folder / Model Utama di Workspace ---")
         for fName, fType in pairs(workspaceFolders) do
            print(string.format("Nama: '%s' [%s]", fName, fType))
         end
         print("============================================================\n")

         Rayfield:Notify({
            Title = "Scan Selesai!",
            Content = "Total Prompt: " .. promptCount .. ". Buka Console untuk lihat detail!",
            Duration = 6,
         })
      end)
   end,
})
