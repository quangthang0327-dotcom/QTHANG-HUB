-- HopSV v2 - Server Hop GUI + Fix Lag 50%
-- Creator: @qthangccth -- ===== KHÓA SCRIPT =====
local LOCK_ENABLED = false   -- true = khóa, false = mở khóa

if LOCK_ENABLED then
    print("🔒 Script đã bị khóa! Liên hệ @qthangccth để mở khóa.")
    return
end
-- ========================
-- Features: Server hop + Fix Lag 50%

local P=game:GetService("Players")
local T=game:GetService("TeleportService")
local H=game:GetService("HttpService")
local C=game:GetService("CoreGui")
local U=game:GetService("UserInputService")
local L=P.LocalPlayer
local PID=game.PlaceId
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")

if _G.QH then
    pcall(function()
        _G.QH:Destroy()
    end)
end

local g=Instance.new("ScreenGui")
g.Name="QH"
g.Parent=C
_G.QH=g
g.ResetOnSpawn=false
g.IgnoreGuiInset=true

-- FIX LAG SYSTEM
local fixLagEnabled=false
local originalSettings={}
local fixLagConnection=nil
local hiddenParts={}

local function enableFixLag()
    if fixLagEnabled then return end
    fixLagEnabled=true
    
    -- Save original settings
    originalSettings.GlobalShadows=Lighting.GlobalShadows
    originalSettings.FogEnd=Lighting.FogEnd
    originalSettings.FogStart=Lighting.FogStart
    originalSettings.Brightness=Lighting.Brightness
    originalSettings.EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale
    originalSettings.EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale
    
    -- Optimize lighting
    Lighting.GlobalShadows=false
    Lighting.FogEnd=100000
    Lighting.FogStart=100000
    Lighting.Brightness=1
    Lighting.EnvironmentDiffuseScale=0
    Lighting.EnvironmentSpecularScale=0
    
    -- Remove textures and decals
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Transparency~=1 then
                obj.Transparency=1
            end
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled=false
        end
        if obj:IsA("BasePart") then
            obj.Material=Enum.Material.SmoothPlastic
            if obj:FindFirstChildOfClass("SpecialMesh") then
                obj:FindFirstChildOfClass("SpecialMesh"):Destroy()
            end
        end
    end
    
    -- Continuous optimization
    fixLagConnection=RS.Heartbeat:Connect(function()
        -- Remove effects from new parts
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                if obj.Enabled then obj.Enabled=false end
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Transparency~=1 then obj.Transparency=1 end
            end
        end
    end)
end

local function disableFixLag()
    if not fixLagEnabled then return end
    fixLagEnabled=false
    
    if fixLagConnection then
        fixLagConnection:Disconnect()
        fixLagConnection=nil
    end
    
    -- Restore original settings
    Lighting.GlobalShadows=originalSettings.GlobalShadows
    Lighting.FogEnd=originalSettings.FogEnd
    Lighting.FogStart=originalSettings.FogStart
    Lighting.Brightness=originalSettings.Brightness
    Lighting.EnvironmentDiffuseScale=originalSettings.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale=originalSettings.EnvironmentSpecularScale
end

-- LOADING SCREEN
local loadingFrame=Instance.new("Frame")
loadingFrame.Size=UDim2.new(0,250,0,120)
loadingFrame.Position=UDim2.new(0.5,-125,0.5,-60)
loadingFrame.BackgroundColor3=Color3.fromRGB(10,15,10)
loadingFrame.BorderSizePixel=0
loadingFrame.Parent=g

local loadingCorner=Instance.new("UICorner")
loadingCorner.CornerRadius=UDim.new(0,12)
loadingCorner.Parent=loadingFrame

local loadingStroke=Instance.new("UIStroke")
loadingStroke.Color=Color3.fromRGB(0,255,0)
loadingStroke.Thickness=2
loadingStroke.Parent=loadingFrame

local loadingTitle=Instance.new("TextLabel")
loadingTitle.Size=UDim2.new(1,0,0,30)
loadingTitle.Position=UDim2.new(0,0,0,10)
loadingTitle.BackgroundTransparency=1
loadingTitle.Text="HopSV v2"
loadingTitle.TextColor3=Color3.fromRGB(255,255,255)
loadingTitle.TextSize=20
loadingTitle.Font=Enum.Font.GothamBlack
loadingTitle.Parent=loadingFrame

local loadingBarBg=Instance.new("Frame")
loadingBarBg.Size=UDim2.new(0.85,0,0,15)
loadingBarBg.Position=UDim2.new(0.075,0,0,55)
loadingBarBg.BackgroundColor3=Color3.fromRGB(20,30,20)
loadingBarBg.BorderSizePixel=0
loadingBarBg.Parent=loadingFrame

local loadingBarBgCorner=Instance.new("UICorner")
loadingBarBgCorner.CornerRadius=UDim.new(0,7)
loadingBarBgCorner.Parent=loadingBarBg

local loadingBar=Instance.new("Frame")
loadingBar.Size=UDim2.new(0,0,1,0)
loadingBar.Position=UDim2.new(0,0,0,0)
loadingBar.BackgroundColor3=Color3.fromRGB(0,255,0)
loadingBar.BorderSizePixel=0
loadingBar.Parent=loadingBarBg

local loadingBarCorner=Instance.new("UICorner")
loadingBarCorner.CornerRadius=UDim.new(0,7)
loadingBarCorner.Parent=loadingBar

local loadingText=Instance.new("TextLabel")
loadingText.Size=UDim2.new(1,0,0,20)
loadingText.Position=UDim2.new(0,0,0,85)
loadingText.BackgroundTransparency=1
loadingText.Text="Dang tai... 0%"
loadingText.TextColor3=Color3.fromRGB(0,255,0)
loadingText.TextSize=12
loadingText.Font=Enum.Font.GothamBold
loadingText.Parent=loadingFrame

spawn(function()
    local progress=0
    while progress<100 do
        progress=progress+math.random(15,30)
        if progress>100 then progress=100 end
        loadingBar.Size=UDim2.new(progress/100,0,1,0)
        loadingText.Text="Dang tai... "..progress.."%"
        wait(0.06)
    end
    wait(0.15)
    loadingFrame:Destroy()
    createMainMenu()
end)

-- MAIN MENU
function createMainMenu()
    local rf=Instance.new("Frame")
    rf.Size=UDim2.new(0,260,0,290)
    rf.Position=UDim2.new(0.5,-130,0.5,-145)
    rf.BackgroundColor3=Color3.fromRGB(255,255,255)
    rf.BorderSizePixel=0
    rf.BackgroundTransparency=1
    rf.Parent=g

    local rc=Instance.new("UICorner")
    rc.CornerRadius=UDim.new(0,14)
    rc.Parent=rf

    local gr=Instance.new("UIGradient")
    gr.Parent=rf

    local colorList={
        Color3.fromRGB(255,255,255),
        Color3.fromRGB(255,0,0),
        Color3.fromRGB(255,255,0),
        Color3.fromRGB(128,0,128),
        Color3.fromRGB(0,255,0),
        Color3.fromRGB(0,0,255),
    }

    local offset=0
    spawn(function()
        while rf and rf.Parent do
            offset=offset+0.02
            if offset>1 then offset=0 end
            local colors={}
            local segmentCount=#colorList
            for i=0,segmentCount do
                local ratio=i/segmentCount
                local shiftedRatio=(ratio+offset)%1
                local colorPosition=shiftedRatio*segmentCount
                local colorIndex1=math.floor(colorPosition)%segmentCount+1
                local colorIndex2=(colorIndex1%segmentCount)+1
                local blendFactor=colorPosition-math.floor(colorPosition)
                local c1=colorList[colorIndex1]
                local c2=colorList[colorIndex2]
                local blendedColor=Color3.new(
                    c1.R+(c2.R-c1.R)*blendFactor,
                    c1.G+(c2.G-c1.G)*blendFactor,
                    c1.B+(c2.B-c1.B)*blendFactor
                )
                table.insert(colors,ColorSequenceKeypoint.new(ratio,blendedColor))
            end
            gr.Color=ColorSequence.new(colors)
            wait(0.03)
        end
    end)

    local f=Instance.new("Frame")
    f.Size=UDim2.new(0,248,0,278)
    f.Position=UDim2.new(0.5,-124,0.5,-139)
    f.BackgroundColor3=Color3.fromRGB(15,25,15)
    f.BackgroundTransparency=0
    f.BorderSizePixel=0
    f.Active=true
    f.Draggable=true
    f.Parent=g

    local rfFadeIn=TS:Create(rf,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0})
    rfFadeIn:Play()

    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,12)
    c.Parent=f

    -- Background
    local bgFrame=Instance.new("Frame")
    bgFrame.Size=UDim2.new(1,0,1,0)
    bgFrame.Position=UDim2.new(0,0,0,0)
    bgFrame.BackgroundColor3=Color3.fromRGB(15,25,15)
    bgFrame.BorderSizePixel=0
    bgFrame.ZIndex=1
    bgFrame.Parent=f

    local bgFrameCorner=Instance.new("UICorner")
    bgFrameCorner.CornerRadius=UDim.new(0,12)
    bgFrameCorner.Parent=bgFrame

    -- RAIN
    local rainContainer=Instance.new("Frame")
    rainContainer.Size=UDim2.new(1,0,1,0)
    rainContainer.Position=UDim2.new(0,0,0,0)
    rainContainer.BackgroundTransparency=1
    rainContainer.ClipsDescendants=true
    rainContainer.ZIndex=5
    rainContainer.Parent=f

    local rainCorner=Instance.new("UICorner")
    rainCorner.CornerRadius=UDim.new(0,12)
    rainCorner.Parent=rainContainer

    spawn(function()
        while rainContainer and rainContainer.Parent do
            local drop=Instance.new("Frame")
            drop.Size=UDim2.new(0,math.random(1,2),0,math.random(8,20))
            drop.Position=UDim2.new(0,math.random(0,240),0,math.random(-30,0))
            drop.BackgroundColor3=Color3.fromRGB(0,255,0)
            drop.BackgroundTransparency=0.4
            drop.BorderSizePixel=0
            drop.ZIndex=6
            drop.Parent=rainContainer
            spawn(function()
                local currentY=drop.Position.Y.Offset
                while drop and drop.Parent and currentY<290 do
                    currentY=currentY+math.random(4,10)
                    drop.Position=UDim2.new(0,drop.Position.X.Offset,0,currentY)
                    wait(0.016)
                end
                if drop and drop.Parent then drop:Destroy() end
            end)
            wait(math.random(1,5)/10)
        end
    end)

    local function updateRainbowPosition()
        local p=f.Position
        rf.Position=UDim2.new(p.X.Scale,p.X.Offset-6,p.Y.Scale,p.Y.Offset-6)
    end

    local function updateRainbowSize()
        local s=f.Size
        rf.Size=UDim2.new(s.X.Scale,s.X.Offset+12,s.Y.Scale,s.Y.Offset+12)
    end

    f:GetPropertyChangedSignal("Position"):Connect(updateRainbowPosition)
    f:GetPropertyChangedSignal("Size"):Connect(updateRainbowSize)

    -- Title Bar
    local tb=Instance.new("Frame")
    tb.Size=UDim2.new(1,0,0,35)
    tb.Position=UDim2.new(0,0,0,0)
    tb.BackgroundColor3=Color3.fromRGB(10,20,10)
    tb.BorderSizePixel=0
    tb.ZIndex=10
    tb.Parent=f

    local tbc=Instance.new("UICorner")
    tbc.CornerRadius=UDim.new(0,12)
    tbc.Parent=tb

    local t=Instance.new("TextLabel")
    t.Size=UDim2.new(0.7,0,1,0)
    t.Position=UDim2.new(0,10,0,0)
    t.BackgroundTransparency=1
    t.Text="HopSV v2"
    t.TextColor3=Color3.fromRGB(255,255,255)
    t.TextSize=15
    t.Font=Enum.Font.GothamBlack
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.ZIndex=11
    t.Parent=tb

    local m=Instance.new("TextButton")
    m.Size=UDim2.new(0,25,0,25)
    m.Position=UDim2.new(1,-30,0,5)
    m.BackgroundColor3=Color3.fromRGB(20,40,20)
    m.Text="X"
    m.TextColor3=Color3.fromRGB(255,255,255)
    m.TextSize=14
    m.Font=Enum.Font.GothamBold
    m.ZIndex=11
    m.Parent=tb

    local mc=Instance.new("UICorner")
    mc.CornerRadius=UDim.new(0,6)
    mc.Parent=m

    -- Content Frame
    local cf=Instance.new("Frame")
    cf.Size=UDim2.new(1,0,1,-35)
    cf.Position=UDim2.new(0,0,0,35)
    cf.BackgroundTransparency=1
    cf.ZIndex=10
    cf.Parent=f

    -- Player Count
    local pcl=Instance.new("TextLabel")
    pcl.Size=UDim2.new(1,-20,0,22)
    pcl.Position=UDim2.new(0,10,0,5)
    pcl.BackgroundTransparency=1
    pcl.Text="SO NGUOI CHOI: "..#P:GetPlayers()
    pcl.TextColor3=Color3.fromRGB(255,255,255)
    pcl.TextSize=12
    pcl.Font=Enum.Font.GothamBold
    pcl.TextXAlignment=Enum.TextXAlignment.Center
    pcl.ZIndex=11
    pcl.Parent=cf

    spawn(function()
        while wait(1) do
            if pcl and pcl.Parent then
                pcl.Text="SO NGUOI CHOI: "..#P:GetPlayers()
            end
        end
    end)

    -- Header
    local hcl=Instance.new("TextLabel")
    hcl.Size=UDim2.new(1,-20,0,18)
    hcl.Position=UDim2.new(0,10,0,30)
    hcl.BackgroundTransparency=1
    hcl.Text="SO NGUOI CHOI KHI HOP SV"
    hcl.TextColor3=Color3.fromRGB(255,215,0)
    hcl.TextSize=11
    hcl.Font=Enum.Font.GothamBold
    hcl.TextXAlignment=Enum.TextXAlignment.Center
    hcl.ZIndex=11
    hcl.Parent=cf

    -- Input Frame
    local inf=Instance.new("Frame")
    inf.Size=UDim2.new(0,45,0,30)
    inf.Position=UDim2.new(0.5,-22.5,0,52)
    inf.BackgroundColor3=Color3.fromRGB(10,20,10)
    inf.BorderSizePixel=2
    inf.BorderColor3=Color3.fromRGB(255,215,0)
    inf.ZIndex=11
    inf.Parent=cf

    local inc=Instance.new("UICorner")
    inc.CornerRadius=UDim.new(0,8)
    inc.Parent=inf

    local ht=Instance.new("TextBox")
    ht.Size=UDim2.new(1,0,1,0)
    ht.BackgroundTransparency=1
    ht.Text="1"
    ht.TextColor3=Color3.fromRGB(255,255,255)
    ht.TextSize=18
    ht.Font=Enum.Font.GothamBlack
    ht.TextXAlignment=Enum.TextXAlignment.Center
    ht.TextYAlignment=Enum.TextYAlignment.Center
    ht.ZIndex=12
    ht.Parent=inf

    ht:GetPropertyChangedSignal("Text"):Connect(function()
        local n=tonumber(ht.Text)
        if not n then ht.Text="1" elseif n<1 then ht.Text="1" elseif n>50 then ht.Text="50" end
    end)

    ht.FocusLost:Connect(function()
        local n=tonumber(ht.Text)
        if not n or n<1 then ht.Text="1" elseif n>50 then ht.Text="50" end
    end)

    -- Guide
    local gl=Instance.new("TextLabel")
    gl.Size=UDim2.new(1,-20,0,15)
    gl.Position=UDim2.new(0,10,0,85)
    gl.BackgroundTransparency=1
    gl.Text="Nhap so nguoi choi muon tim"
    gl.TextColor3=Color3.fromRGB(255,165,0)
    gl.TextSize=9
    gl.Font=Enum.Font.GothamBold
    gl.TextXAlignment=Enum.TextXAlignment.Center
    gl.ZIndex=11
    gl.Parent=cf

    -- Status
    local sl=Instance.new("TextLabel")
    sl.Size=UDim2.new(1,-20,0,15)
    sl.Position=UDim2.new(0,10,0,102)
    sl.BackgroundTransparency=1
    sl.Text="Dang tim server..."
    sl.TextColor3=Color3.fromRGB(0,255,0)
    sl.TextSize=10
    sl.Font=Enum.Font.GothamBold
    sl.TextXAlignment=Enum.TextXAlignment.Center
    sl.ZIndex=11
    sl.Parent=cf

    -- HOP BUTTON
    local hb=Instance.new("TextButton")
    hb.Size=UDim2.new(0.85,0,0,35)
    hb.Position=UDim2.new(0.075,0,0,122)
    hb.BackgroundColor3=Color3.fromRGB(0,255,0)
    hb.Text="HOP SERVER NGAY"
    hb.TextColor3=Color3.fromRGB(0,0,0)
    hb.TextSize=14
    hb.Font=Enum.Font.GothamBlack
    hb.ZIndex=11
    hb.Parent=cf

    local hbStroke=Instance.new("UIStroke")
    hbStroke.Color=Color3.fromRGB(255,255,255)
    hbStroke.Thickness=2
    hbStroke.Parent=hb

    local hbc=Instance.new("UICorner")
    hbc.CornerRadius=UDim.new(0,8)
    hbc.Parent=hb

    hb.MouseEnter:Connect(function()
        hb.BackgroundColor3=Color3.fromRGB(100,255,100)
        hb.TextSize=15
    end)
    hb.MouseLeave:Connect(function()
        hb.BackgroundColor3=Color3.fromRGB(0,255,0)
        hb.TextSize=14
    end)

    -- FIX LAG BUTTON
    local fixLagButton=Instance.new("TextButton")
    fixLagButton.Size=UDim2.new(0.85,0,0,30)
    fixLagButton.Position=UDim2.new(0.075,0,0,162)
    fixLagButton.BackgroundColor3=Color3.fromRGB(100,100,100)
    fixLagButton.Text="FIX LAG: OFF"
    fixLagButton.TextColor3=Color3.fromRGB(255,255,255)
    fixLagButton.TextSize=12
    fixLagButton.Font=Enum.Font.GothamBlack
    fixLagButton.ZIndex=11
    fixLagButton.Parent=cf

    local fixLagStroke=Instance.new("UIStroke")
    fixLagStroke.Color=Color3.fromRGB(255,255,255)
    fixLagStroke.Thickness=1
    fixLagStroke.Parent=fixLagButton

    local fixLagCorner=Instance.new("UICorner")
    fixLagCorner.CornerRadius=UDim.new(0,8)
    fixLagCorner.Parent=fixLagButton

    fixLagButton.MouseEnter:Connect(function()
        fixLagButton.BackgroundColor3=Color3.fromRGB(150,150,150)
    end)
    fixLagButton.MouseLeave:Connect(function()
        if fixLagEnabled then
            fixLagButton.BackgroundColor3=Color3.fromRGB(0,200,0)
        else
            fixLagButton.BackgroundColor3=Color3.fromRGB(100,100,100)
        end
    end)

    fixLagButton.MouseButton1Click:Connect(function()
        if fixLagEnabled then
            disableFixLag()
            fixLagButton.Text="FIX LAG: OFF"
            fixLagButton.BackgroundColor3=Color3.fromRGB(100,100,100)
        else
            enableFixLag()
            fixLagButton.Text="FIX LAG: ON"
            fixLagButton.BackgroundColor3=Color3.fromRGB(0,200,0)
        end
    end)

    -- TikTok Label
    local cl=Instance.new("TextLabel")
    cl.Size=UDim2.new(1,-20,0,15)
    cl.Position=UDim2.new(0,10,0,198)
    cl.BackgroundTransparency=1
    cl.Text="TIKTOK: @qthangccth"
    cl.TextColor3=Color3.fromRGB(255,105,180)
    cl.TextSize=10
    cl.Font=Enum.Font.GothamBold
    cl.TextXAlignment=Enum.TextXAlignment.Center
    cl.ZIndex=11
    cl.Parent=cf

    -- Server hop function
    local function gs(id,tp)
        if not id then id=PID end
        if not tp then tp=1 end
        local s,r=pcall(function()
            return H:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..id.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if s and r and r.data then
            local sv={}
            for _,v in ipairs(r.data) do
                if v.playing==tp and v.playing<v.maxPlayers and v.id~=game.JobId then
                    table.insert(sv,v)
                end
            end
            return sv
        end
        return {}
    end

    local function sh()
        local tp=tonumber(ht.Text) or 1
        sl.Text="Dang tim server co "..tp.." nguoi..."
        sl.TextColor3=Color3.fromRGB(255,200,0)
        local sv=gs(PID,tp)
        if #sv>0 then
            local ts=sv[math.random(1,#sv)]
            sl.Text="Da tim thay! Dang hop..."
            sl.TextColor3=Color3.fromRGB(0,255,0)
            pcall(function()
                T:TeleportToPlaceInstance(PID,ts.id,L)
            end)
        else
            sl.Text="Khong tim thay!"
            sl.TextColor3=Color3.fromRGB(255,0,0)
            wait(2)
            if sl and sl.Parent then
                sl.Text="Dang tim server..."
                sl.TextColor3=Color3.fromRGB(0,255,0)
            end
        end
    end

    hb.MouseButton1Click:Connect(sh)

    -- TOGGLE BUTTON
    local menuVisible=true
    local toggleButton=Instance.new("TextButton")
    toggleButton.Size=UDim2.new(0,70,0,70)
    toggleButton.Position=UDim2.new(0.5,-35,0.5,-35)
    toggleButton.BackgroundColor3=Color3.fromRGB(255,255,255)
    toggleButton.Text="MENU"
    toggleButton.TextColor3=Color3.fromRGB(255,0,0)
    toggleButton.TextSize=16
    toggleButton.Font=Enum.Font.GothamBlack
    toggleButton.ZIndex=100
    toggleButton.AutoButtonColor=false
    toggleButton.Active=true
    toggleButton.Draggable=true
    toggleButton.Visible=false
    toggleButton.Parent=g

    local toggleCorner=Instance.new("UICorner")
    toggleCorner.CornerRadius=UDim.new(0,14)
    toggleCorner.Parent=toggleButton

    local toggleGradient=Instance.new("UIGradient")
    toggleGradient.Parent=toggleButton

    spawn(function()
        local hue=0
        while toggleButton and toggleButton.Parent do
            hue=(hue+2)%360
            local colors={}
            for i=0,10 do
                local h=((hue+i*36)%360)/360
                table.insert(colors,ColorSequenceKeypoint.new(i/10,Color3.fromHSV(h,1,1)))
            end
            toggleGradient.Color=ColorSequence.new(colors)
            wait(0.03)
        end
    end)

    local toggleStroke=Instance.new("UIStroke")
    toggleStroke.Color=Color3.fromRGB(0,0,0)
    toggleStroke.Thickness=3
    toggleStroke.Parent=toggleButton

    spawn(function()
        local textHue=0
        while toggleButton and toggleButton.Parent do
            textHue=(textHue+3)%360
            toggleButton.TextColor3=Color3.fromHSV(textHue/360,1,1)
            wait(0.05)
        end
    end)

    local function hideMenu()
        menuVisible=false
        f.Visible=false
        rf.Visible=false
        toggleButton.Visible=true
        toggleButton.Text="MO MENU"
    end

    local function showMenu()
        menuVisible=true
        f.Visible=true
        rf.Visible=true
        toggleButton.Visible=false
    end

    m.MouseButton1Click:Connect(hideMenu)
    toggleButton.MouseButton1Click:Connect(showMenu)

    U.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.F5 then
            if menuVisible then
                hideMenu()
            else
                showMenu()
            end
        end
    end)

    print("HopSV v2 loaded")
    print("Features: Server hop + Fix Lag 50%")
    print("Press F5 or X to toggle menu")
end

print("HopSV v2 starting...")
