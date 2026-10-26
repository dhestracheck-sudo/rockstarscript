-- Cek apakah game sudah dimuat
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rockstarscript | Test Exploiter",
   LoadingTitle = "Auto Steal & Farm Tester",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Tester Berhasil Dimuat!",
   Content = "Gunakan menu di bawah untuk menguji keamanan map.",
   Duration = 5,
})

local MainTab = Window:CreateTab("Auto Steal Test", 4483362458)
local MainSection = MainTab:CreateSection("Simulasi Serangan Auto Steal")

local autoStealActive = false

MainTab:CreateToggle({
   Name = "Mulai Auto Steal / Farm Egg",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
      autoStealActive = Value
      task.spawn(function()
         while autoStealActive do
            task.wait(0.1)
            pcall(function()
               local player = game.Players.LocalPlayer
               local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               
               if hrp then
                  -- Menelusuri seluruh ProximityPrompt di dalam map
                  for _, prompt in pairs(workspace:GetDescendants()) do
                     if not autoStealActive then break end
                     
                     if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local targetPart = prompt.Parent
                        
                        -- Sesuaikan jika wadahnya berupa Attachment atau BasePart
                        if targetPart and targetPart:IsA("Attachment") then
                           targetPart = targetPart.Parent
                        end
                        
                        if targetPart and targetPart:IsA("BasePart") then
                           -- Teleport karakter ke dekat objek untuk mensimulasikan pencurian
                           hrp.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                           task.wait(0.05)
                           
                           -- Pemicu interaksi prompt
                           fireproximityprompt(prompt)
                           
                           Rayfield:Notify({
                              Title = "Mencoba Mengambil...",
                              Content = "Target: " .. tostring(targetPart.Name),
                              Duration = 1,
                           })
                           
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
