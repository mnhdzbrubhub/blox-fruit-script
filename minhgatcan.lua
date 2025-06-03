--// Variables
local taskState = {
    ["Killed Rip_Indra"] = false,
    ["Killed Dough King V2"] = false,
    ["Talked to Tablet"] = false,
    ["Teleported to Mysterious Island"] = false,
    ["Activated Race V3 at Moonrise"] = false
}

--// UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 400, 0, 200)
Frame.Position = UDim2.new(0, 20, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local taskLabels = {}

local function createTaskLabel(taskName)
    local label = Instance.new("TextLabel", Frame)
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    taskLabels[taskName] = label
end

local function updateTask(taskName)
    taskState[taskName] = true
    if taskLabels[taskName] then
        taskLabels[taskName].Text = "✅ " .. taskName
        taskLabels[taskName].TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

local function isTaskDone(taskName)
    return taskState[taskName]
end

for taskName in pairs(taskState) do
    createTaskLabel(taskName)
    updateTask(taskName) -- update lại lần đầu để hiển thị đúng màu
end

--// Helpers
function findBoss(name)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and string.lower(v.Name):find(name:lower()) then
            return v
        end
    end
end

function hopToRandomServer()
    local HttpService = game:GetService("HttpService")
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
            break
        end
    end
end

function killBoss(bossName, taskKey)
    while not isTaskDone(taskKey) do
        local boss = findBoss(bossName)
        if not boss then
            hopToRandomServer()
            return
        end
        pcall(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
        end)
        wait(1)
        if boss:FindFirstChild("Humanoid") and boss.Humanoid.Health <= 0 then
            updateTask(taskKey)
        end
        wait(2)
    end
end

function talkToStone()
    if isTaskDone("Talked to Tablet") then return end
    local stone = workspace:FindFirstChild("Tablet")
    if stone and stone:FindFirstChild("TalkPrompt") then
        fireproximityprompt(stone.TalkPrompt)
        wait(1)
        updateTask("Talked to Tablet")
    end
end

function gotoMysteriousIsland()
    if isTaskDone("Teleported to Mysterious Island") then return end
    local teleport = workspace:FindFirstChild("MysteriousIslandTeleport")
    if teleport and teleport:FindFirstChild("ProximityPrompt") then
        fireproximityprompt(teleport.ProximityPrompt)
        wait(1)
        updateTask("Teleported to Mysterious Island")
    end
end

function waitMoonAndAwaken()
    while not isTaskDone("Activated Race V3 at Moonrise") do
        wait(3)
        local hour = game.Lighting:GetMinutesAfterMidnight() / 60
        if hour >= 18.5 and hour <= 19.5 then
            updateTask("Activated Race V3 at Moonrise")
        end
    end
end

--// Main
task.spawn(function()
    killBoss("rip_indra", "Killed Rip_Indra")
    killBoss("Dough King", "Killed Dough King V2")
    talkToStone()
    gotoMysteriousIsland()
    waitMoonAndAwaken()
end)
