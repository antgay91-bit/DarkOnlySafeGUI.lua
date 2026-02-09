-- =================================================
-- Project Polaro - Dark Only Safe Mode + GUI
-- Delta Executor / Mobile Friendly
-- =================================================

-- ======================
-- CONFIG SAFE
-- ======================
local MIN_DELAY = 0.35
local MAX_DELAY = 0.75
local MAX_HUNTS = 2800

local PAUSE_MIN = 20
local PAUSE_MAX = 45
local PAUSE_EVERY_MIN = 150
local PAUSE_EVERY_MAX = 280

local CAPTURE_CHANCE = 85 -- %

local rareItems = {
    ["Dark Aura"] = true,
    ["Dark Skinifier"] = true
}

-- ======================
-- SERVICES
-- ======================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
local HuntRemote = Remotes:WaitForChild("Hunt")
local CatchRemote = Remotes:WaitForChild("CatchPokemon")
local RevealRemote = Remotes:FindFirstChild("RevealEncounter")

-- ======================
-- GUI INDICADOR
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "PolaroDarkIndicator"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3, 0.14)
frame.Position = UDim2.fromScale(0.65, 0.8)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.3)
title.BackgroundTransparency = 1
title.Text = "🟣 Project Polaro"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(190,190,255)

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.fromScale(0,0.35)
status.Size = UDim2.fromScale(1,0.3)
status.BackgroundTransparency = 1
status.Text = "Dark Hunt: ON"
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.TextColor3 = Color3.fromRGB(120,255,120)

local counter = Instance.new("TextLabel", frame)
counter.Position = UDim2.fromScale(0,0.65)
counter.Size = UDim2.fromScale(1,0.3)
counter.BackgroundTransparency = 1
counter.Text = "Hunts: 0"
counter.Font = Enum.Font.Gotham
counter.TextScaled = true
counter.TextColor3 = Color3.fromRGB(220,220,220)

-- ======================
-- UTILS
-- ======================
local function humanDelay()
    task.wait(math.random(MIN_DELAY*1000, MAX_DELAY*1000)/1000)
end

local function hasDarkItem(data)
    if not data.Items then return false end
    for _, item in pairs(data.Items) do
        if rareItems[item] then
            return true
        end
    end
    return false
end

-- ======================
-- MAIN LOOP
-- ======================
task.spawn(function()
    local hunts = 0
    local nextPause = math.random(PAUSE_EVERY_MIN, PAUSE_EVERY_MAX)

    while hunts < MAX_HUNTS do
        hunts += 1
        counter.Text = "Hunts: " .. hunts
        humanDelay()

        local success, data = pcall(function()
            return HuntRemote:InvokeServer()
        end)

        if success and data and hasDarkItem(data) then
            status.Text = "🩸 DARK ENCONTRADO!"
            status.TextColor3 = Color3.fromRGB(180,80,255)

            if RevealRemote then
                RevealRemote:FireServer(data.EncounterId)
            end

            task.wait(0.6)

            if math.random(1,100) <= CAPTURE_CHANCE then
                CatchRemote:FireServer(data.EncounterId)
            end

            task.wait(1.5)
            status.Text = "Dark Hunt: ON"
            status.TextColor3 = Color3.fromRGB(120,255,120)
        end

        if hunts >= nextPause then
            status.Text = "😴 Pausa de segurança"
            status.TextColor3 = Color3.fromRGB(255,200,120)
            task.wait(math.random(PAUSE_MIN, PAUSE_MAX))
            status.Text = "Dark Hunt: ON"
            status.TextColor3 = Color3.fromRGB(120,255,120)
            nextPause += math.random(PAUSE_EVERY_MIN, PAUSE_EVERY_MAX)
        end
    end

    status.Text = "Dark Hunt: OFF"
    status.TextColor3 = Color3.fromRGB(255,120,120)
end)

print("✅ Dark-Only Safe Mode com GUI iniciado")
