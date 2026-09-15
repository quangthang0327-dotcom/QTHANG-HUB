-- HopSV v3 - Fixed Server Hop
-- Server Hop + Fix Lag + FPS + Ping
-- Creator: @qthangccth
-- Fixed: Server hop with proper API fallback

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

local FixLagEnabled = false
local FixLagConnection = nil
local OldLighting = {}

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

local function EnableFixLag()
    if FixLagEnabled then return end
    FixLagEnabled = true

    OldLighting.GlobalShadows = Lighting.GlobalShadows
    OldLighting.FogEnd = Lighting.FogEnd
    OldLighting.FogStart = Lighting.FogStart
    OldLighting.Brightness = Lighting.Brightness

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    Lighting.Brightness = 1

    local function OptimizeObject(obj)
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
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
    if not FixLagEnabled then return end
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
    end)
end

-- Loading
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
        task.wait(0.03)
    end
    task.wait(0.1)
    if Loading then Loading:Destroy() end
end)

task.wait(0.5)

-- Rainbow Frame
local RainbowFrame = Create("Frame", {
    Size = UDim2.new(0, 247, 0, 262),
    Position = UDim2.new(0.5, -123.5, 0.5, -131),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0
}, GUI)

Corner(RainbowFrame, 14)

local RainbowGradient = Instance.new("UIGradient")
RainbowGradient.Parent = RainbowFrame

local colorList = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(128, 0, 128),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
}

local hueOffset = 0
task.spawn(function()
    while RainbowFrame and RainbowFrame.Parent do
        hueOffset = hueOffset + 0.02
        if hueOffset > 1 then hueOffset = 0 end
        local colors = {}
        local segmentCount = #colorList
        for i = 0, segmentCount do
            local ratio = i / segmentCount
            local shiftedRatio = (ratio + hueOffset) % 1
            local colorPosition = shiftedRatio * segmentCount
            local colorIndex1 = math.floor(colorPosition) % segmentCount + 1
            local colorIndex2 = (colorIndex1 % segmentCount) + 1
            local blendFactor = colorPosition - math.floor(colorPosition)
            local c1 = colorList[colorIndex1]
            local c2 = colorList[colorIndex2]
            local blendedColor = Color3.new(
                c1.R + (c2.R - c1.R) * blendFactor,
                c1.G + (c2.G - c1.G) * blendFactor,
                c1.B + (c2.B - c1.B) * blendFactor
            )
            table.insert(colors, ColorSequenceKeypoint.new(ratio, blendedColor))
        end
        RainbowGradient.Color = ColorSequence.new(colors)
        task.wait(0.03)
    end
end)

-- Main
local Main = Create("Frame", {
    Size = UDim2.new(0, 235, 0, 250),
    Position = UDim2.new(0.5, -117, 0.5, -125),
    BackgroundColor3 = Color3.fromRGB(15, 25, 15),
    BorderSizePixel = 0,
    Active = true
}, GUI)

Corner(Main, 12)

local function UpdateRainbow()
    RainbowFrame.Position = UDim2.new(
        Main.Position.X.Scale,
        Main.Position.X.Offset - 6,
        Main.Position.Y.Scale,
        Main.Position.Y.Offset - 6
    )
end

Main:GetPropertyChangedSignal("Position"):Connect(UpdateRainbow)

-- Header
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

-- FPS/Ping
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

RunService.RenderStepped:Connect(function()
    Frames = Frames + 1
    local now = os.clock()
    if now - LastFPSUpdate >= 1 then
        local fps = Frames
        Frames = 0
        LastFPSUpdate = now
        local ping = "--"
        pcall(function()
            local item = Stats.Network.ServerStatsItem["Data Ping"]
            ping = math.floor(item:GetValue())
        end)
        StatsLabel.Text = "FPS: " .. fps .. "   |   PING: " .. ping .. " ms"
    end
end)

-- Player Count
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
        PlayerLabel.Text = "SO NGUOI CHOI: " .. #Players:GetPlayers()
        task.wait(1)
    end
end)

-- Server Target
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

local Status = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 148),
    BackgroundTransparency = 1,
    Text = "San sang...",
    TextColor3 = Color3.fromRGB(0, 255, 0),
    TextSize = 10,
    Font = Enum.Font.GothamBold
}, Main)

-- FIXED SERVER HOP FUNCTION
local function GetServers(targetPlayers)
    local servers = {}
    
    -- Try multiple pages
    local cursor = ""
    local attempts = 0
    
    while attempts < 4 do
        attempts = attempts + 1
        
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    if targetPlayers == 0 then
                        -- Any server
                        table.insert(servers, server)
                    elseif server.playing == targetPlayers then
                        table.insert(servers, server)
                    end
                end
            end
            
            if result.nextPageCursor and result.nextPageCursor ~= "" then
                cursor = result.nextPageCursor
            else
                break
            end
        else
            break
        end
    end
    
    return servers
end

local function HopToServer(serverId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
    end)
    return success, err
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

local isHopping = false

HopButton.MouseButton1Click:Connect(function()
    if isHopping then return end
    isHopping = true
    
    local target = tonumber(ServerInput.Text) or 1
    
    Status.Text = "Dang tim server..."
    Status.TextColor3 = Color3.fromRGB(255, 200, 0)
    HopButton.Text = "DANG TIM..."
    HopButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    
    task.spawn(function()
        local servers = GetServers(target)
        
        if #servers > 0 then
            local server = servers[math.random(1, #servers)]
            Status.Text = "Da tim thay! Dang hop..."
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            HopButton.Text = "DANG HOP..."
            
            local success, err = HopToServer(server.id)
            
            if not success then
                -- Retry with TeleportAsync
                local ok = pcall(function()
                    TeleportService:TeleportAsync(PlaceId, {LocalPlayer}, 
                        Instance.new("TeleportOptions"))
                end)
                
                if not ok then
                    Status.Text = "Hop that bai! Thu lai..."
                    Status.TextColor3 = Color3.fromRGB(255, 60, 60)
                    task.wait(2)
                    Status.Text = "San sang..."
                    Status.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
            end
        else
            Status.Text = "Khong tim thay server!"
            Status.TextColor3 = Color3.fromRGB(255, 60, 60)
            task.wait(2)
            if Status.Parent then
                Status.Text = "San sang..."
                Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
        
        HopButton.Text = "HOP SERVER"
        HopButton.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        isHopping = false
    end)
end)

-- Fix Lag Button
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
        FixButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    else
        EnableFixLag()
        FixButton.Text = "FIX LAG: ON"
        FixButton.BackgroundColor3 = Color3.fromRGB(0, 190, 0)
    end
end)

-- Toggle Button
local Toggle = Create("TextButton", {
    Size = UDim2.new(0, 70, 0, 70),
    Position = UDim2.new(0.5, -35, 0.5, -35),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Text = "MENU",
    TextColor3 = Color3.fromRGB(255, 0, 0),
    TextSize = 15,
    Font = Enum.Font.GothamBlack,
    Visible = false,
    Active = true,
    AutoButtonColor = false
}, GUI)

Corner(Toggle, 14)
Stroke(Toggle, Color3.fromRGB(0, 0, 0), 3)

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Parent = Toggle

task.spawn(function()
    local hue = 0
    while Toggle and Toggle.Parent do
        hue = (hue + 2) % 360
        local colors = {}
        for i = 0, 10 do
            local h = ((hue + i * 36) % 360) / 360
            table.insert(colors, ColorSequenceKeypoint.new(i / 10, Color3.fromHSV(h, 1, 1)))
        end
        ToggleGradient.Color = ColorSequence.new(colors)
        Toggle.TextColor3 = Color3.fromHSV(hue / 360, 1, 1)
        task.wait(0.03)
    end
end)

MakeDraggable(Toggle)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    RainbowFrame.Visible = false
    Toggle.Visible = true
    Toggle.Text = "MO MENU"
end)

Toggle.MouseButton1Click:Connect(function()
    Main.Visible = true
    RainbowFrame.Visible = true
    Toggle.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        if Main.Visible then
            Main.Visible = false
            RainbowFrame.Visible = false
            Toggle.Visible = true
            Toggle.Text = "MO MENU"
        else
            Main.Visible = true
            RainbowFrame.Visible = true
            Toggle.Visible = false
        end
    end
end)

print("================================")
print("HopSV v3 Loaded - FIXED")
print("Server Hop: FIXED (multi-page)")
print("Fix Lag: Ready")
print("FPS / Ping: ON")
print("================================")
