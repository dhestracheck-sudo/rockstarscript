if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rockstarscript | Zona Terakhir",
   LoadingTitle = "Auto Farm Zona Terakhir",
   LoadingSubtitle = "by dhestracheck-sudo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Filter Zona Aktif",
   Content = "Script dikhususkan untuk zona terakhir.",
   Duration = 4,
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local MainSection = MainTab:CreateSection("Target Zona Terakhir Saja")

local autoFarmLast = false

MainTab:CreateToggle({
   Name = "Auto Farm Zona Terakhir",
   CurrentValue = false,
   Flag = "AutoFarmLastZone",
   Callback = function(Value)
      autoFarmLast = Value
      task.spawn(function()
         -- Cari titik terjauh/zona terakhir berdasarkan posisi koordinat (Z atau Magnitude dari pusat)
         local function getTargetPrompts()
            local prompts = {}
            local maxDistance = 0
            
            -- Kumpulkan semua prompt dan cari posisi terjauh sebagai indikasi zona terakhir
            for _, prompt in pairs(workspace:GetDescendants()) do
               if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                  local part = prompt.Parent
                  if part and part:IsA("Attachment") then part = part.Parent end
                  if part and part:IsA("BasePart") then
                     local dist = part.Position.Magnitude
                     if dist > maxDistance then
                        maxDistance = dist
                     end
                     table.insert(prompts, {Prompt = prompt, Part = part, Dist = dist})
                  end
               end
            end
            
            -- Filter hanya ambil prompt yang berada di radius zona terjauh (15% dari jarak maksimal)
            local lastZonePrompts = {}
            for _, data in pairs(prompts) do
               if data.Dist >= (maxDistance - 150) then -- Toleransi jarak zona terakhir
                  table.insert(lastZonePrompts, data)
               end
            end
            
            return lastZonePrompts
         end

         while autoFarmLast do
            task.wait(0.2)
            pcall(function()
               local player = game.Players.LocalPlayer
               local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               
               if hrp then
                  local targetList = getTargetPrompts()
                  for _, target in pairs(targetList) do
                     if not autoFarmLast then break end
                     
                     if target.Prompt and target.Prompt.Enabled and target.Part then
                        -- Teleport presisi hanya ke titik di zona terakhir
                        hrp.CFrame = target.Part.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.05)
                        
                        fireproximityprompt(target.Prompt)
                        task.wait(0.25)
                     end
                  end
               end
            end)
         end
      end)
   end,
})
