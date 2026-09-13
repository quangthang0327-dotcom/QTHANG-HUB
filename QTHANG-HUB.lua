--// HopSV v3
--// Server Hop + Fix Lag + FPS + Ping
--// Creator: @qthangccth

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

--==================================================
-- CLEAN OLD GUI
--==================================================

if _G.QH then
    pcall(function()
        _G.QH:Destroy()
    end)
end

_G.QH = Instance.new("ScreenGui")
_G.QH.Name = "HopSV"
_G.QH.ResetOnSpawn = false
_G.QH.IgnoreGuiInset = true
_G.QH.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_G.QH.Parent = CoreGui

local GUI = _G.QH

--==================================================
-- SETTINGS
--==================================================

local FixLagEnabled = false
local FixLagConnection = nil

local OldLighting = {}

--==================================================
-- HELPERS
--==================================================

local function Create(class, properties, parent)
    local obj = Instance.new(class)

    for property, value in pairs(properties) do
        obj[property] = value
    end

    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, parent)
end

local function Stroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness
    }, parent)
end

--==================================================
-- DRAG SYSTEM - MOUSE + TOUCH
--==================================================

local function MakeDraggable(frame, handle)
    handle = handle or frame

    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

--==================================================
-- FIX LAG
--==================================================

local function EnableFixLag()
    if FixLagEnabled then
        return
    end

    FixLagEnabled = true

    OldLighting.GlobalShadows = Lighting.GlobalShadows
    OldLighting.FogEnd = Lighting.FogEnd
    OldLighting.FogStart = Lighting.FogStart
    OldLighting.Brightness = Lighting.Brightness
    OldLighting.EnvironmentDiffuseScale =
        Lighting.EnvironmentDiffuseScale
    OldLighting.EnvironmentSpecularScale =
        Lighting.EnvironmentSpecularScale

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    local function OptimizeObject(obj)
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles") then

            obj.Enabled = false

        elseif obj:IsA("Decal")
        or obj:IsA("Texture") then

            obj.Transparency = 1
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        OptimizeObject(obj)
    end

    FixLagConnection = workspace.DescendantAdded:Connect(function(obj)
        if FixLagEnabled then
            task.defer(function()
                if obj and obj.Parent then
                    OptimizeObject(obj)
                end
            end)
        end
    end)
end

local function DisableFixLag()
    if not FixLagEnabled then
        return
    end

    FixLagEnabled = false

    if FixLagConnection then
        FixLagConnection:Disconnect()
        FixLagConnection = nil
    end

    pcall(function()
        Lighting.GlobalShadows = OldLighting.GlobalShadows
        Lighting.FogEnd = OldLighting.FogEnd
        Lighting.FogStart = OldLighting.FogStart
        Lighting.Brightness = OldLighting.Brightness
        Lighting.EnvironmentDiffuseScale =
            OldLighting.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale =
            OldLighting.EnvironmentSpecularScale
    end)
end

--==================================================
-- LOADING
--==================================================

local Loading = Create("Frame", {
    Size = UDim2.new(0, 220, 0, 105),
    Position = UDim2.new(0.5, -110, 0.5, -52),
    BackgroundColor3 = Color3.fromRGB(15, 25, 15),
    BorderSizePixel = 0
}, GUI)

Corner(Loading, 12)
Stroke(Loading, Color3.fromRGB(0, 255, 0), 2)

Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 0, 8),
    BackgroundTransparency = 1,
    Text = "HopSV v3",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 18,
    Font = Enum.Font.GothamBlack
}, Loading)

local BarBG = Create("Frame", {
    Size = UDim2.new(0.84, 0, 0, 13),
    Position = UDim2.new(0.08, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(30, 40, 30),
    BorderSizePixel = 0
}, Loading)

Corner(BarBG, 7)

local Bar = Create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 255, 0),
    BorderSizePixel = 0
}, BarBG)

Corner(Bar, 7)

local LoadingText = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 72),
    BackgroundTransparency = 1,
    Text = "Dang tai... 0%",
    TextColor3 = Color3.fromRGB(0, 255, 0),
    TextSize = 11,
    Font = Enum.Font.GothamBold
}, Loading)

task.spawn(function()
    for i = 0, 100, 10 do
        Bar.Size = UDim2.new(i / 100, 0, 1, 0)
        LoadingText.Text = "Dang tai... " .. i .. "%"
        task.wait(0.035)
    end

    task.wait(0.15)

    if Loading then
        Loading:Destroy()
    end
end)

--==================================================
-- MAIN GUI
--==================================================

task.wait(0.55)

local Main = Create("Frame", {
    Size = UDim2.new(0, 235, 0, 250),
    Position = UDim2.new(0.5, -117, 0.5, -125),
    BackgroundColor3 = Color3.fromRGB(15, 25, 15),
    BorderSizePixel = 0,
    Active = true
}, GUI)

Corner(Main, 12)
Stroke(Main, Color3.fromRGB(0, 255, 0), 1.5)

--==================================================
-- TITLE
--==================================================

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Color3.fromRGB(8, 18, 8),
    BorderSizePixel = 0,
    Active = true
}, Main)

Corner(Header, 12)

Create("TextLabel", {
    Size = UDim2.new(1, -45, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "HopSV v3",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 14,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local Close = Create("TextButton", {
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -30, 0, 5),
    BackgroundColor3 = Color3.fromRGB(40, 60, 40),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    Font = Enum.Font.GothamBold
}, Header)

Corner(Close, 6)

MakeDraggable(Main, Header)

--==================================================
-- FPS / PING
--==================================================

local StatsLabel = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 22),
    Position = UDim2.new(0, 10, 0, 39),
    BackgroundTransparency = 1,
    Text = "FPS: --   |   PING: --",
    TextColor3 = Color3.fromRGB(0, 255, 0),
    TextSize = 12,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Center
}, Main)

local Frames = 0
local LastFPSUpdate = os.clock()
local CurrentFPS = 0

RunService.RenderStepped:Connect(function()
    Frames += 1

    local now = os.clock()

    if now - LastFPSUpdate >= 1 then
        CurrentFPS = Frames
        Frames = 0
        LastFPSUpdate = now

        local Ping = "--"

        pcall(function()
            local item =
                Stats.Network.ServerStatsItem["Data Ping"]

            Ping = math.floor(item:GetValue())
        end)

        StatsLabel.Text =
            "FPS: " .. CurrentFPS .. "   |   PING: " .. Ping .. " ms"
    end
end)

--==================================================
-- PLAYER COUNT
--==================================================

local PlayerLabel = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 62),
    BackgroundTransparency = 1,
    Text = "SO NGUOI CHOI: " .. #Players:GetPlayers(),
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center
}, Main)

task.spawn(function()
    while Main.Parent do
        PlayerLabel.Text =
            "SO NGUOI CHOI: " .. #Players:GetPlayers()

        task.wait(1)
    end
end)

--==================================================
-- SERVER TARGET
--==================================================

Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 17),
    Position = UDim2.new(0, 10, 0, 84),
    BackgroundTransparency = 1,
    Text = "SO NGUOI CHOI KHI HOP SV",
    TextColor3 = Color3.fromRGB(255, 215, 0),
    TextSize = 10,
    Font = Enum.Font.GothamBold
}, Main)

local InputBG = Create("Frame", {
    Size = UDim2.new(0, 45, 0, 28),
    Position = UDim2.new(0.5, -22, 0, 103),
    BackgroundColor3 = Color3.fromRGB(8, 18, 8),
    BorderSizePixel = 0
}, Main)

Corner(InputBG, 7)
Stroke(InputBG, Color3.fromRGB(255, 215, 0), 1)

local ServerInput = Create("TextBox", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "1",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    Font = Enum.Font.GothamBlack,
    ClearTextOnFocus = false
}, InputBG)

ServerInput:GetPropertyChangedSignal("Text"):Connect(function()
    local n = tonumber(ServerInput.Text)

    if not n then
        ServerInput.Text = "1"
    elseif n < 1 then
        ServerInput.Text = "1"
    elseif n > 50 then
        ServerInput.Text = "50"
    end
end)

Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 15),
    Position = UDim2.new(0, 10, 0, 133),
    BackgroundTransparency = 1,
    Text = "Nhap so nguoi muon tim",
    TextColor3 = Color3.fromRGB(255, 165, 0),
    TextSize = 9,
    Font = Enum.Font.GothamBold
}, Main)

--==================================================
-- STATUS
--==================================================

local Status = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 148),
    BackgroundTransparency = 1,
    Text = "San sang...",
    TextColor3 = Color3.fromRGB(0, 255, 0),
    TextSize = 10,
    Font = Enum.Font.GothamBold
}, Main)

--==================================================
-- SERVER HOP
--==================================================

local function GetServers(targetPlayers)
    local success, result = pcall(function()
        local URL =
            "https://games.roblox.com/v1/games/"
            .. PlaceId
            .. "/servers/Public?sortOrder=Asc&limit=100"

        return HttpService:JSONDecode(
            game:HttpGet(URL)
        )
    end)

    if not success or not result or not result.data then
        return {}
    end

    local servers = {}

    for _, server in ipairs(result.data) do
        if server.playing == targetPlayers
        and server.playing < server.maxPlayers
        and server.id ~= game.JobId then

            table.insert(servers, server)
        end
    end

    return servers
end

local HopButton = Create("TextButton", {
    Size = UDim2.new(0.86, 0, 0, 31),
    Position = UDim2.new(0.07, 0, 0, 170),
    BackgroundColor3 = Color3.fromRGB(0, 220, 0),
    Text = "HOP SERVER",
    TextColor3 = Color3.new(0, 0, 0),
    TextSize = 13,
    Font = Enum.Font.GothamBlack
}, Main)

Corner(HopButton, 8)

HopButton.MouseButton1Click:Connect(function()
    local target = tonumber(ServerInput.Text) or 1

    Status.Text = "Dang tim server..."
    Status.TextColor3 = Color3.fromRGB(255, 200, 0)

    local servers = GetServers(target)

    if #servers > 0 then
        local server =
            servers[math.random(1, #servers)]

        Status.Text = "Da tim thay! Dang hop..."
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)

        pcall(function()
            TeleportService:TeleportToPlaceInstance(
                PlaceId,
                server.id,
                LocalPlayer
            )
        end)
    else
        Status.Text = "Khong tim thay server!"
        Status.TextColor3 = Color3.fromRGB(255, 60, 60)

        task.wait(2)

        if Status.Parent then
            Status.Text = "San sang..."
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end)

--==================================================
-- FIX LAG BUTTON
--==================================================

local FixButton = Create("TextButton", {
    Size = UDim2.new(0.86, 0, 0, 29),
    Position = UDim2.new(0.07, 0, 0, 206),
    BackgroundColor3 = Color3.fromRGB(80, 80, 80),
    Text = "FIX LAG: OFF",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 11,
    Font = Enum.Font.GothamBlack
}, Main)

Corner(FixButton, 8)

FixButton.MouseButton1Click:Connect(function()
    if FixLagEnabled then
        DisableFixLag()

        FixButton.Text = "FIX LAG: OFF"
        FixButton.BackgroundColor3 =
            Color3.fromRGB(80, 80, 80)
    else
        EnableFixLag()

        FixButton.Text = "FIX LAG: ON"
        FixButton.BackgroundColor3 =
            Color3.fromRGB(0, 190, 0)
    end
end)

--==================================================
-- HIDE / SHOW BUTTON
--==================================================

local Toggle = Create("TextButton", {
    Size = UDim2.new(0, 55, 0, 55),
    Position = UDim2.new(0.5, -27, 0.5, -27),
    BackgroundColor3 = Color3.fromRGB(20, 30, 20),
    Text = "MENU",
    TextColor3 = Color3.fromRGB(0, 255, 0),
    TextSize = 12,
    Font = Enum.Font.GothamBlack,
    Visible = false,
    Active = true
}, GUI)

Corner(Toggle, 12)
Stroke(Toggle, Color3.fromRGB(0, 255, 0), 2)

MakeDraggable(Toggle)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Toggle.Visible = true
end)

Toggle.MouseButton1Click:Connect(function()
    Main.Visible = true
    Toggle.Visible = false
end)

--==================================================
-- F5 TOGGLE
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F5 then
        if Main.Visible then
            Main.Visible = false
            Toggle.Visible = true
        else
            Main.Visible = true
            Toggle.Visible = false
        end
    end
end)

print("================================")
print("HopSV v3 Loaded")
print("Server Hop: ON")
print("Fix Lag: Ready")
print("FPS / Ping: ON")
print("Mobile Drag: ON")
print("================================")
