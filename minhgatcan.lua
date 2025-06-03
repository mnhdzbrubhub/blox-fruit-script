
-- Auto Gạt Cần Blox Fruits Full Logic + UI Progress

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- UI INIT
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GatCanProgress"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0, 10, 0.5, -100)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.BackgroundTransparency = 0.3
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0

local taskStatus = {
    ["Killed Rip_Indra"] = false,
    ["Killed Dough King V2"] = false,
    ["Talked to Tablet"] = false,
    ["Teleported to Mysterious Island"] = false,
    ["Activated Race V3 at Moonrise"] = false
}

local labelRefs = {}

local function updateTask(name)
    taskStatus[name] = true
    if labelRefs[name] then
        labelRefs[name].Text = "✅ " .. name
        labelRefs[name].TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

local function createTaskLabels()
    local y = 10
    for taskName, _ in pairs(taskStatus) do
        local Label = Instance.new("TextLabel", Frame)
        Label.Text = "❌ " .. taskName
        Label.Position = UDim2.new(0, 10, 0, y)
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.TextColor3 = Color3.fromRGB(255, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        labelRefs[taskName] = Label
        y = y + 25
    end
end

createTaskLabels()

-- LOGIC
local function hopServer()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=2&limit=100"))
    for _, v in pairs(servers.data) do
        if v.playing < v.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
            break
        end
    end
end

local function waitForBoss(name)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find(name:lower()) then
            return v
        end
    end
end

local function attackBoss(boss)
    while boss and boss.Parent do
        LocalPlayer.Character:PivotTo(boss:GetPivot())
        task.wait(0.5)
    end
end

local function killBoss(name, taskKey)
    if taskStatus[taskKey] then return end
    local found = waitForBoss(name)
    if not found then hopServer() return end
    attackBoss(found)
    updateTask(taskKey)
end

local function talkToStone()
    if taskStatus["Talked to Tablet"] then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == "Tablet" then
            fireclickdetector(v:FindFirstChildWhichIsA("ClickDetector"))
            updateTask("Talked to Tablet")
            break
        end
    end
end

local function gotoMysteriousIsland()
    if taskStatus["Teleported to Mysterious Island"] then return end
    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "MysteriousIslandTeleport" then
            v:FireServer()
            updateTask("Teleported to Mysterious Island")
            break
        end
    end
end

local function waitMoonAndAwaken()
    if taskStatus["Activated Race V3 at Moonrise"] then return end
    task.spawn(function()
        while true do
            task.wait(2)
            local hour = game.Lighting:GetMinutesAfterMidnight() / 60
            if hour >= 18.5 and hour <= 19.5 then
                updateTask("Activated Race V3 at Moonrise")
                break
            end
        end
    end)
end

-- MAIN THREAD
task.spawn(function()
    killBoss("rip_indra", "Killed Rip_Indra")
    killBoss("Dough King", "Killed Dough King V2")
    talkToStone()
    gotoMysteriousIsland()
    waitMoonAndAwaken()
end)
