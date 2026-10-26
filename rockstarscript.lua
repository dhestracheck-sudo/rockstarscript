-- Cek apakah game sudah dimuat
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rockstarscript",
   LoadingTitle = "rockstarscript Auto Farm Presisi",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Auto Farm Siap!",
   Content = "Menargetkan semua PromptPoint di map.",
   Duration = 5,
})

local MainTab = Window:CreateTab("Auto Farm Zona", 4483362458)
local MainSection = MainTab:CreateSection("Pencari & Auto Farm Berdasarkan Scan")

local autoFarm = false
MainTab:CreateToggle({
   Name = "Auto Farm PromptPoint",
   CurrentValue = false,
   Flag = "AutoFarmPromptPoint",
   Callback = function(Value)
      autoFarm = Value
      task.spawn(function()
         while autoFarm do
            task.wait(0.1)
            pcall(function()
               local player = game.Players.LocalPlayer
               local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               
               if hrp then
                  -- Menelusuri seluruh objek berdasarkan data scan asli (PromptPoint)
                  for _, prompt in pairs(workspace:GetDescendants()) do
                     if not autoFarm then break end
                     
                     if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local parentObj = prompt.Parent
                        -- Memastikan target sesuai dengan nama yang terekam saat scan
                        if parentObj and parentObj.Name == "PromptPoint" then
                           
                           -- Teleport ke posisi PromptPoint secara presisi
                           hrp.CFrame = parentObj.CFrame * CFrame.new(0, 3, 0)
                           task.wait(0.05)
                           
                           -- Eksekusi interaksi game otomatis
                           fireproximityprompt(prompt)
                           
                           task.wait(0.2)
                        end
                     end
                  end
               end
            end)
         end
      end)
   end,
})
