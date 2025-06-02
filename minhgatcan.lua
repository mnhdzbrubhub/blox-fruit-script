--[[ 
    Auto Gạt Cần Script (by MinhDz)
    ✅ Kill Rip_Indra
    ✅ Kill Dough King
    ✅ Nói chuyện bia đá
    ✅ Hop Đảo Kỳ Bí
    ✅ Bật tộc V3 khi trăng lên
--]]

repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ⚙️ Helper
local function serverHop()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
            wait(5)
        end
    end
end

-- 📍 Check boss exists
local function bossExists(name)
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name:lower():find(name:lower()) then
            return v
        end
    end
    return nil
end

-- 🥊 Auto kill boss
local function killBoss(name)
    local boss = nil
    repeat
        boss = bossExists(name)
        if boss then
            pcall(function()
                repeat wait()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0,10,0)
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                until not boss or boss.Humanoid.Health <= 0
            end)
        else
            serverHop()
        end
    until boss and boss.Humanoid.Health <= 0
end

-- 💬 Nói chuyện với tấm bia
local function interactWithTablet()
    local tablet = workspace:FindFirstChild("StoneTablet")
    if tablet then
        fireclickdetector(tablet.ClickDetector)
    end
end

-- 🗺️ Tìm đảo kỳ bí
local function hopToMirageIsland()
    local found = false
    repeat
        for _, island in pairs(workspace:GetChildren()) do
            if island.Name == "Mirage Island" then
                found = true
                break
            end
        end
        if not found then
            serverHop()
        end
        wait(5)
    until found
end

-- 🌙 Đợi trăng và bật tộc
local function waitForMoonAndAwaken()
    local moon = game.Lighting:FindFirstChild("Moon")
    repeat wait() until moon and moon.Visible
    local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    root.CFrame = CFrame.new(0,1000,0) -- lên trời ngắm trăng
    wait(2)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "T", false, game) -- nút bật tộc
end

-- 🔁 QUY TRÌNH
killBoss("rip_indra")
wait(2)
killBoss("Dough King")
wait(2)
interactWithTablet()
wait(1)
hopToMirageIsland()
wait(1)
waitForMoonAndAwaken()
