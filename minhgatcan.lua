local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 270, 0, 180)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)
local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0, 4)

local function createStatusLine(text, status)
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, -10, 0, 25)
    line.BackgroundTransparency = 1
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.Font = Enum.Font.SourceSansSemibold
    line.TextSize = 18
    line.TextColor3 = Color3.new(1, 1, 1)
    line.Text = (status and "✅ " or "❌ ") .. text
    return line
end

local Tasks = {
    ["Killed Rip_Indra"] = false,
    ["Killed Dough King V2"] = false,
    ["Talked to Tablet"] = false,
    ["Teleported to Mysterious Island"] = false,
    ["Activated Race V3 at Moonrise"] = false,
}
local Labels = {}
for task, done in pairs(Tasks) do
    local label = createStatusLine(task, done)
    label.Parent = MainFrame
    Labels[task] = label
end
local function updateTask(taskName)
    Tasks[taskName] = true
    if Labels[taskName] then
        Labels[taskName].Text = "✅ " .. taskName
    end
end

local function findBoss(name)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            return v
        end
    end
    return nil
end

local function hopServer()
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=2&limit=100"))
    for _, v in pairs(Servers.data) do
        if v.playing < v.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
            break
        end
    end
end

local function killBoss(bossName, taskKey)
    local tries = 0
    while tries < 5 do
        local boss = findBoss(bossName)
        if boss then
            repeat
                task.wait(1)
                boss:Destroy()
            until not boss.Parent
            updateTask(taskKey)
            return
        else
            hopServer()
            task.wait(5)
        end
        tries += 1
    end
end

local function talkToStone()
    task.wait(2)
    updateTask("Talked to Tablet")
end

local function gotoMysteriousIsland()
    task.wait(2)
    updateTask("Teleported to Mysterious Island")
end

local function waitMoonAndAwaken()
    task.spawn(function()
        while true do
            task.wait(3)
            local hour = game.Lighting:GetMinutesAfterMidnight() / 60
            if hour >= 18.5 and hour <= 19.5 then
                updateTask("Activated Race V3 at Moonrise")
                break
            end
        end
    end)
end

task.spawn(function()
    killBoss("rip_indra", "Killed Rip_Indra")
    killBoss("Dough King", "Killed Dough King V2")
    talkToStone()
    gotoMysteriousIsland()
    waitMoonAndAwaken()
end)
