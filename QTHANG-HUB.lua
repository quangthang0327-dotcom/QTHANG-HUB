--==================================================
-- HopSV v5 - FIX GUI + FIX LAG + GRAPHICS 99%
--==================================================

repeat task.wait() until game:IsLoaded()

--==================================================
-- SERVICES
--==================================================

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

if not LocalPlayer then
    warn("HopSV: Khong tim thay LocalPlayer")
    return
end

--==================================================
-- XÓA GUI CŨ
--==================================================

pcall(function()
    if _G.HopSV_GUI then
        _G.HopSV_GUI:Destroy()
        _G.HopSV_GUI = nil
    end
end)

--==================================================
-- TẠO GUI - NHIỀU FALLBACK
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "HopSV"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiCreated = false

-- Ưu tiên gethui
pcall(function()
    if type(gethui) == "function" then
        local hui = gethui()
        if hui then
            GUI.Parent = hui
            guiCreated = true
        end
    end
end)

-- Fallback PlayerGui
if not guiCreated then
    pcall(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        if PlayerGui then
            GUI.Parent = PlayerGui
            guiCreated = true
        end
    end)
end

-- Fallback CoreGui
if not guiCreated then
    pcall(function()
        GUI.Parent = CoreGui
        if GUI.Parent then
            guiCreated = true
        end
    end)
end

if not guiCreated then
    warn("HopSV: Khong the tao GUI")
    return
end

_G.HopSV_GUI = GUI

--==================================================
-- VARIABLES
--==================================================

local FixLagEnabled = false
local Graphics99Enabled = false
local MenuVisible = true
local Hopping = false

local OldMaterial = {}
local OldParticle = {}
local OldTransparency = {}
local OldDecalTransparency = {}
local OldTerrainDecoration = nil

--==================================================
-- MAIN FRAME
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = GUI
Main.Size = UDim2.new(0, 270, 0, 300)
Main.Position = UDim2.new(0.5, -135, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "HOPSV"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

--==================================================
-- FPS / PING
--==================================================

local Info = Instance.new("TextLabel")
Info.Parent = Main
Info.Size = UDim2.new(1, -20, 0, 25)
Info.Position = UDim2.new(0, 10, 0, 38)
Info.BackgroundTransparency = 1
Info.Text = "FPS: -- | Ping: --"
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 13
Info.Font = Enum.Font.Gotham
Info.TextXAlignment = Enum.TextXAlignment.Left

local PlayerCount = Instance.new("TextLabel")
PlayerCount.Parent = Main
PlayerCount.Size = UDim2.new(1, -20, 0, 22)
PlayerCount.Position = UDim2.new(0, 10, 0, 60)
PlayerCount.BackgroundTransparency = 1
PlayerCount.TextColor3 = Color3.fromRGB(180, 180, 180)
PlayerCount.TextSize = 12
PlayerCount.Font = Enum.Font.Gotham
PlayerCount.TextXAlignment = Enum.TextXAlignment.Left

--==================================================
-- TARGET PLAYER INPUT
--==================================================

local Input = Instance.new("TextBox")
Input.Parent = Main
Input.Size = UDim2.new(1, -20, 0, 35)
Input.Position = UDim2.new(0, 10, 0, 88)
Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Input.BorderSizePixel = 0
Input.PlaceholderText = "Số người server (1-50)"
Input.Text = "1"
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
Input.TextSize = 14
Input.Font = Enum.Font.Gotham

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 7)
InputCorner.Parent = Input

--==================================================
-- BUTTON FUNCTION
--==================================================

local function CreateButton(text, y)
    local Button = Instance.new("TextButton")
    Button.Parent = Main
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Position = UDim2.new(0, 10, 0, y)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = true

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Button

    return Button
end

--==================================================
-- BUTTONS
--==================================================

local HopButton = CreateButton("HOP SERVER", 130)
local FixButton = CreateButton("FIX LAG: OFF", 170)
local GraphicsButton = CreateButton("GRAPHICS 99%: OFF", 210)
local MenuButton = CreateButton("ẨN MENU", 250)

--==================================================
-- DRAG MENU MOBILE
--==================================================

local dragging = false
local dragStart
local startPos

local function UpdateDrag(input)
    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        UpdateDrag(input)
    end
end)

--==================================================
-- FPS / PING UPDATE
--==================================================

local frames = 0
local lastTime = tick()
local fps = 0

RunService.RenderStepped:Connect(function()
    frames += 1

    local now = tick()

    if now - lastTime >= 1 then
        fps = frames
        frames = 0
        lastTime = now

        local ping = "--"

        pcall(function()
            local item = Stats.Network.ServerStatsItem["Data Ping"]

            if item then
                ping = math.floor(item:GetValue())
            end
        end)

        Info.Text = "FPS: " .. fps .. " | Ping: " .. ping .. " ms"
        PlayerCount.Text =
            "Players: " ..
            #Players:GetPlayers() ..
            "/" ..
            Players.MaxPlayers
    end
end)

--==================================================
-- FIX LAG
--==================================================

local function OptimizeObject(obj)

    if obj:IsA("ParticleEmitter")
    or obj:IsA("Trail")
    or obj:IsA("Beam")
    or obj:IsA("Smoke")
    or obj:IsA("Fire")
    or obj:IsA("Sparkles") then

        if OldParticle[obj] == nil then
            OldParticle[obj] = obj.Enabled
        end

        pcall(function()
            obj.Enabled = false
        end)

    elseif obj:IsA("BasePart") then

        if OldMaterial[obj] == nil then
            OldMaterial[obj] = obj.Material
        end

        pcall(function()
            obj.Material = Enum.Material.SmoothPlastic
        end)
    end
end

local function EnableFixLag()

    if FixLagEnabled then
        return
    end

    FixLagEnabled = true
    FixButton.Text = "FIX LAG: ON"

    task.spawn(function()

        local objects = workspace:GetDescendants()

        for i, obj in ipairs(objects) do

            if not FixLagEnabled then
                break
            end

            pcall(function()
                OptimizeObject(obj)
            end)

            -- Chia nhỏ việc quét để tránh giật khi bật
            if i % 150 == 0 then
                task.wait()
            end
        end
    end)
end

local function DisableFixLag()

    FixLagEnabled = false
    FixButton.Text = "FIX LAG: OFF"

    for obj, material in pairs(OldMaterial) do
        if obj and obj.Parent then
            pcall(function()
                obj.Material = material
            end)
        end
    end

    OldMaterial = {}

    for obj, enabled in pairs(OldParticle) do
        if obj and obj.Parent then
            pcall(function()
                obj.Enabled = enabled
            end)
        end
    end

    OldParticle = {}
end

FixButton.MouseButton1Click:Connect(function()

    if FixLagEnabled then
        DisableFixLag()
    else
        EnableFixLag()
    end

end)

--==================================================
-- TỰ ĐỘNG TỐI ƯU OBJECT MỚI
--==================================================

workspace.DescendantAdded:Connect(function(obj)

    if FixLagEnabled then
        task.defer(function()
            pcall(function()
                OptimizeObject(obj)
            end)
        end)
    end

end)

--==================================================
-- GRAPHICS 99%
--==================================================

local function HideObject(obj)

    -- Không ẩn nhân vật của mình
    if LocalPlayer.Character
    and obj:IsDescendantOf(LocalPlayer.Character) then
        return
    end

    if obj:IsA("BasePart") then

        if OldTransparency[obj] == nil then
            OldTransparency[obj] = obj.LocalTransparencyModifier
        end

        pcall(function()
            obj.LocalTransparencyModifier = 1
        end)

    elseif obj:IsA("Decal")
    or obj:IsA("Texture") then

        if OldDecalTransparency[obj] == nil then
            OldDecalTransparency[obj] = obj.Transparency
        end

        pcall(function()
            obj.Transparency = 1
        end)

    elseif obj:IsA("ParticleEmitter")
    or obj:IsA("Trail")
    or obj:IsA("Beam")
    or obj:IsA("Smoke")
    or obj:IsA("Fire")
    or obj:IsA("Sparkles") then

        if OldParticle[obj] == nil then
            OldParticle[obj] = obj.Enabled
        end

        pcall(function()
            obj.Enabled = false
        end)
    end
end

local function EnableGraphics99()

    if Graphics99Enabled then
        return
    end

    Graphics99Enabled = true
    GraphicsButton.Text = "GRAPHICS 99%: ON"

    pcall(function()
        OldTerrainDecoration = workspace.Terrain.Decoration
        workspace.Terrain.Decoration = false
    end)

    task.spawn(function()

        local objects = workspace:GetDescendants()

        for i, obj in ipairs(objects) do

            if not Graphics99Enabled then
                break
            end

            pcall(function()
                HideObject(obj)
            end)

            if i % 150 == 0 then
                task.wait()
            end
        end
    end)
end

local function DisableGraphics99()

    Graphics99Enabled = false
    GraphicsButton.Text = "GRAPHICS 99%: OFF"

    for obj, transparency in pairs(OldTransparency) do
        if obj and obj.Parent then
            pcall(function()
                obj.LocalTransparencyModifier = transparency
            end)
        end
    end

    OldTransparency = {}

    for obj, transparency in pairs(OldDecalTransparency) do
        if obj and obj.Parent then
            pcall(function()
                obj.Transparency = transparency
            end)
        end
    end

    OldDecalTransparency = {}

    for obj, enabled in pairs(OldParticle) do
        if obj and obj.Parent then
            pcall(function()
                obj.Enabled = enabled
            end)
        end
    end

    OldParticle = {}

    if OldTerrainDecoration ~= nil then
        pcall(function()
            workspace.Terrain.Decoration = OldTerrainDecoration
        end)

        OldTerrainDecoration = nil
    end
end

GraphicsButton.MouseButton1Click:Connect(function()

    if Graphics99Enabled then
        DisableGraphics99()
    else
        EnableGraphics99()
    end

end)

--==================================================
-- OBJECT MỚI KHI GRAPHICS 99%
--==================================================

workspace.DescendantAdded:Connect(function(obj)

    if Graphics99Enabled then

        task.defer(function()

            pcall(function()
                HideObject(obj)
            end)

        end)

    end

end)

--==================================================
-- SERVER HOP
--==================================================

local function GetTargetPlayers()

    local number = tonumber(Input.Text)

    if not number then
        return 1
    end

    number = math.floor(number)

    if number < 1 then
        number = 1
    end

    if number > 50 then
        number = 50
    end

    Input.Text = tostring(number)

    return number
end

local function HopServer()

    if Hopping then
        return
    end

    Hopping = true
    HopButton.Text = "ĐANG TÌM SERVER..."

    local target = GetTargetPlayers()
    local found = false

    task.spawn(function()

        local cursor = ""

        for page = 1, 10 do

            if found then
                break
            end

            local url =
                "https://games.roblox.com/v1/games/" ..
                PlaceId ..
                "/servers/Public?sortOrder=Asc&limit=100"

            if cursor ~= "" then
                url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
            end

            local success, result = pcall(function()
                return game:HttpGet(url)
            end)

            if not success then
                break
            end

            local dataSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)

            if not dataSuccess or not data then
                break
            end

            for _, server in ipairs(data.data or {}) do

                if server.id
                and server.id ~= game.JobId
                and server.playing
                and server.maxPlayers
                and server.playing == target then

                    found = true

                    HopButton.Text = "ĐANG TELEPORT..."

                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(
                            PlaceId,
                            server.id,
                            LocalPlayer
                        )
                    end)

                    break
                end

            end

            cursor = data.nextPageCursor or ""

            if cursor == "" then
                break
            end

            task.wait(0.2)
        end

        if not found then
            HopButton.Text = "KHÔNG TÌM THẤY"
            task.wait(1)
            HopButton.Text = "HOP SERVER"
        end

        Hopping = false
    end)
end

HopButton.MouseButton1Click:Connect(HopServer)

--==================================================
-- ẨN / HIỆN MENU
--==================================================

MenuButton.MouseButton1Click:Connect(function()

    MenuVisible = not MenuVisible

    if MenuVisible then
        Main.Visible = true
        MenuButton.Text = "ẨN MENU"
    else
        Main.Visible = false
    end

end)

--==================================================
-- PHÍM F5
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)

    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F5 then

        MenuVisible = not MenuVisible
        Main.Visible = MenuVisible

    end

end)

--==================================================
-- HOÀN TẤT
--==================================================

print("================================")
print("HopSV v5 loaded successfully")
print("GUI: OK")
print("Fix Lag: OK")
print("Graphics 99%: OK")
print("Server Hop: OK")
print("================================")
