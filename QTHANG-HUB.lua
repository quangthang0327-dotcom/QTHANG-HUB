-- QTHANG-HUB ServerHop - No Crown Version
-- Creator: @qthangccth -- ===== KHÓA SCRIPT =====
local LOCK_ENABLED = false -- true = khóa, false = mở khóa

if LOCK_ENABLED then
    print("🔒 Script đã bị khóa! Liên hệ @qthangccth để mở khóa.")
    return
end
-- ========================
-- Features: Server hop + Aura only

local P=game:GetService("Players")
local T=game:GetService("TeleportService")
local H=game:GetService("HttpService")
local C=game:GetService("CoreGui")
local U=game:GetService("UserInputService")
local L=P.LocalPlayer
local PID=game.PlaceId
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")

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

-- AURA SYSTEM
local auraEnabled=false
local auraParts={}
local auraConnection=nil

local function createAura()
    local character=L.Character
    if not character then return end
    local humanoidRootPart=character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    for i=1,6 do
        local auraPart=Instance.new("Part")
        auraPart.Name="AuraPart"..i
        auraPart.Size=Vector3.new(0.3,0.3,0.3)
        auraPart.Shape=Enum.PartType.Ball
        auraPart.Material=Enum.Material.Neon
        auraPart.Color=Color3.fromRGB(255,0,0)
        auraPart.Anchored=true
        auraPart.CanCollide=false
        auraPart.Transparency=0.3
        auraPart.Parent=character
        table.insert(auraParts,auraPart)
    end
end

local function updateAura()
    local character=L.Character
    if not character then return end
    local humanoidRootPart=character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local time=tick()
    for i,auraPart in ipairs(auraParts) do
        if auraPart and auraPart.Parent then
            local angle=time*3+(i-1)*(math.pi*2/#auraParts)
            local radius=3
            local x=math.cos(angle)*radius
            local z=math.sin(angle)*radius
            local y=math.cos(time*2+i*0.5)*2
            auraPart.Position=humanoidRootPart.Position+Vector3.new(x,y+2,z)
            local hue=((time*50+i*60)%360)/360
            auraPart.Color=Color3.fromHSV(hue,1,1)
        end
    end
end

local function startAura()
    if auraEnabled then return end
    auraEnabled=true
    createAura()
    if auraConnection then auraConnection:Disconnect() end
    auraConnection=RS.RenderStepped:Connect(updateAura)
end

local function stopAura()
    if not auraEnabled then return end
    auraEnabled=false
    if auraConnection then
        auraConnection:Disconnect()
        auraConnection=nil
    end
    for _,part in ipairs(auraParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    auraParts={}
end

-- Handle respawn
L.CharacterAdded:Connect(function(character)
    if auraEnabled then
        stopAura()
        wait(0.5)
        startAura()
    end
end)

-- LOADING SCREEN
local loadingFrame=Instance.new("Frame")
loadingFrame.Size=UDim2.new(0,280,0,140)
loadingFrame.Position=UDim2.new(0.5,-140,0.5,-70)
loadingFrame.BackgroundColor3=Color3.fromRGB(20,30,20)
loadingFrame.BorderSizePixel=0
loadingFrame.Parent=g

local loadingCorner=Instance.new("UICorner")
loadingCorner.CornerRadius=UDim.new(0,12)
loadingCorner.Parent=loadingFrame

local loadingTitle=Instance.new("TextLabel")
loadingTitle.Size=UDim2.new(1,0,0,35)
loadingTitle.Position=UDim2.new(0,0,0,15)
loadingTitle.BackgroundTransparency=1
loadingTitle.Text="QTHANG-HUB"
loadingTitle.TextColor3=Color3.fromRGB(255,255,255)
loadingTitle.TextSize=22
loadingTitle.Font=Enum.Font.GothamBold
loadingTitle.Parent=loadingFrame

local loadingBarBg=Instance.new("Frame")
loadingBarBg.Size=UDim2.new(0.8,0,0,18)
loadingBarBg.Position=UDim2.new(0.1,0,0,70)
loadingBarBg.BackgroundColor3=Color3.fromRGB(30,40,30)
loadingBarBg.BorderSizePixel=0
loadingBarBg.Parent=loadingFrame

local loadingBarBgCorner=Instance.new("UICorner")
loadingBarBgCorner.CornerRadius=UDim.new(0,9)
loadingBarBgCorner.Parent=loadingBarBg

local loadingBar=Instance.new("Frame")
loadingBar.Size=UDim2.new(0,0,1,0)
loadingBar.Position=UDim2.new(0,0,0,0)
loadingBar.BackgroundColor3=Color3.fromRGB(0,255,0)
loadingBar.BorderSizePixel=0
loadingBar.Parent=loadingBarBg

local loadingBarCorner=Instance.new("UICorner")
loadingBarCorner.CornerRadius=UDim.new(0,9)
loadingBarCorner.Parent=loadingBar

local loadingText=Instance.new("TextLabel")
loadingText.Size=UDim2.new(1,0,0,25)
loadingText.Position=UDim2.new(0,0,0,100)
loadingText.BackgroundTransparency=1
loadingText.Text="Dang tai... 0%"
loadingText.TextColor3=Color3.fromRGB(200,255,200)
loadingText.TextSize=13
loadingText.Font=Enum.Font.GothamBold
loadingText.Parent=loadingFrame

spawn(function()
    local progress=0
    while progress<100 do
        progress=progress+math.random(15,30)
        if progress>100 then progress=100 end
        loadingBar.Size=UDim2.new(progress/100,0,1,0)
        loadingText.Text="Dang tai... "..progress.."%"
        wait(0.08)
    end
    wait(0.2)
    loadingFrame:Destroy()
    createMainMenu()
end)

-- MAIN MENU
function createMainMenu()
    local rf=Instance.new("Frame")
    rf.Size=UDim2.new(0,310,0,340)
    rf.Position=UDim2.new(0.5,-155,0.5,-170)
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
    f.Size=UDim2.new(0,298,0,328)
    f.Position=UDim2.new(0.5,-149,0.5,-164)
    f.BackgroundColor3=Color3.fromRGB(20,30,20)
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
    bgFrame.BackgroundColor3=Color3.fromRGB(20,30,20)
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
            drop.Size=UDim2.new(0,math.random(1,2),0,math.random(8,18))
            drop.Position=UDim2.new(0,math.random(0,290),0,math.random(-30,0))
            drop.BackgroundColor3=Color3.fromRGB(150,255,150)
            drop.BackgroundTransparency=0.5
            drop.BorderSizePixel=0
            drop.ZIndex=6
            drop.Parent=rainContainer
            spawn(function()
                local currentY=drop.Position.Y.Offset
                while drop and drop.Parent and currentY<340 do
                    currentY=currentY+math.random(3,8)
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
    tb.BackgroundColor3=Color3.fromRGB(15,25,15)
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
    t.Text="QTHANG-HUB"
    t.TextColor3=Color3.fromRGB(255,255,255)
    t.TextSize=17
    t.Font=Enum.Font.GothamBlack
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.ZIndex=11
    t.Parent=tb

    local m=Instance.new("TextButton")
    m.Size=UDim2.new(0,28,0,28)
    m.Position=UDim2.new(1,-34,0,4)
    m.BackgroundColor3=Color3.fromRGB(30,40,30)
    m.Text="—"
    m.TextColor3=Color3.fromRGB(255,255,255)
    m.TextSize=18
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
    pcl.Size=UDim2.new(1,-20,0,25)
    pcl.Position=UDim2.new(0,10,0,8)
    pcl.BackgroundTransparency=1
    pcl.Text="SO NGUOI CHOI: "..#P:GetPlayers()
    pcl.TextColor3=Color3.fromRGB(255,255,255)
    pcl.TextSize=13
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
    hcl.Size=UDim2.new(1,-20,0,22)
    hcl.Position=UDim2.new(0,10,0,38)
    hcl.BackgroundTransparency=1
    hcl.Text="SO NGUOI CHOI KHI HOP SV"
    hcl.TextColor3=Color3.fromRGB(255,255,255)
    hcl.TextSize=12
    hcl.Font=Enum.Font.GothamBold
    hcl.TextXAlignment=Enum.TextXAlignment.Center
    hcl.ZIndex=11
    hcl.Parent=cf

    -- Input Frame
    local inf=Instance.new("Frame")
    inf.Size=UDim2.new(0,45,0,32)
    inf.Position=UDim2.new(0.5,-22.5,0,65)
    inf.BackgroundColor3=Color3.fromRGB(25,35,25)
    inf.BorderSizePixel=2
    inf.BorderColor3=Color3.fromRGB(255,255,255)
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

    -- Guide
    local gl=Instance.new("TextLabel")
    gl.Size=UDim2.new(1,-20,0,18)
    gl.Position=UDim2.new(0,10,0,102)
    gl.BackgroundTransparency=1
    gl.Text="Nhap so nguoi choi (vd: 1 = 1 nguoi)"
    gl.TextColor3=Color3.fromRGB(255,255,255)
    gl.TextSize=10
    gl.Font=Enum.Font.GothamBold
    gl.TextXAlignment=Enum.TextXAlignment.Center
    gl.ZIndex=11
    gl.Parent=cf

    -- Status
    local sl=Instance.new("TextLabel")
    sl.Size=UDim2.new(1,-20,0,18)
    sl.Position=UDim2.new(0,10,0,122)
    sl.BackgroundTransparency=1
    sl.Text="Dang tim server..."
    sl.TextColor3=Color3.fromRGB(200,255,200)
    sl.TextSize=11
    sl.Font=Enum.Font.GothamBold
    sl.TextXAlignment=Enum.TextXAlignment.Center
    sl.ZIndex=11
    sl.Parent=cf

    -- HOP BUTTON
    local hb=Instance.new("TextButton")
    hb.Size=UDim2.new(0.85,0,0,40)
    hb.Position=UDim2.new(0.075,0,0,145)
    hb.BackgroundColor3=Color3.fromRGB(0,255,0)
    hb.Text="HOP SERVER"
    hb.TextColor3=Color3.fromRGB(0,0,0)
    hb.TextSize=16
    hb.Font=Enum.Font.GothamBlack
    hb.ZIndex=11
    hb.Parent=cf

    local hbc=Instance.new("UICorner")
    hbc.CornerRadius=UDim.new(0,10)
    hbc.Parent=hb

    hb.MouseEnter:Connect(function()
        hb.BackgroundColor3=Color3.fromRGB(100,255,100)
    end)
    hb.MouseLeave:Connect(function()
        hb.BackgroundColor3=Color3.fromRGB(0,255,0)
    end)

    -- AURA BUTTON
    local auraButton=Instance.new("TextButton")
    auraButton.Size=UDim2.new(0.85,0,0,35)
    auraButton.Position=UDim2.new(0.075,0,0,195)
    auraButton.BackgroundColor3=Color3.fromRGB(180,0,180)
    auraButton.Text="AURA: OFF"
    auraButton.TextColor3=Color3.fromRGB(0,0,0)
    auraButton.TextSize=14
    auraButton.Font=Enum.Font.GothamBlack
    auraButton.ZIndex=11
    auraButton.Parent=cf

    local auraCorner=Instance.new("UICorner")
    auraCorner.CornerRadius=UDim.new(0,10)
    auraCorner.Parent=auraButton

    auraButton.MouseButton1Click:Connect(function()
        if auraEnabled then
            stopAura()
            auraButton.Text="AURA: OFF"
            auraButton.BackgroundColor3=Color3.fromRGB(180,0,180)
        else
            startAura()
            auraButton.Text="AURA: ON"
            auraButton.BackgroundColor3=Color3.fromRGB(255,0,255)
        end
    end)

    -- TikTok Label
    local cl=Instance.new("TextLabel")
    cl.Size=UDim2.new(1,-20,0,20)
    cl.Position=UDim2.new(0,10,0,245)
    cl.BackgroundTransparency=1
    cl.Text="TIKTOK: @qthangccth"
    cl.TextColor3=Color3.fromRGB(255,105,180)
    cl.TextSize=11
    cl.Font=Enum.Font.GothamBold
    cl.TextXAlignment=Enum.TextXAlignment.Center
    cl.ZIndex=11
    cl.Parent=cf

    -- RESIZE BUTTON
    local resizeButton=Instance.new("TextButton")
    resizeButton.Size=UDim2.new(0,18,0,18)
    resizeButton.Position=UDim2.new(1,-20,1,-20)
    resizeButton.BackgroundColor3=Color3.fromRGB(30,40,30)
    resizeButton.Text="◢"
    resizeButton.TextColor3=Color3.fromRGB(255,255,255)
    resizeButton.TextSize=10
    resizeButton.Font=Enum.Font.GothamBold
    resizeButton.ZIndex=20
    resizeButton.AutoButtonColor=false
    resizeButton.Parent=f

    local resizeCorner=Instance.new("UICorner")
    resizeCorner.CornerRadius=UDim.new(0,4)
    resizeCorner.Parent=resizeButton

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
        local sv=gs(PID,tp)
        if #sv>0 then
            local ts=sv[math.random(1,#sv)]
            sl.Text="Da tim thay! Dang hop..."
            pcall(function()
                T:TeleportToPlaceInstance(PID,ts.id,L)
            end)
        else
            sl.Text="Khong tim thay!"
            wait(2)
            if sl and sl.Parent then
                sl.Text="Dang tim server..."
            end
        end
    end

    hb.MouseButton1Click:Connect(sh)

    -- Minimize/Expand
    local im=false
    m.MouseButton1Click:Connect(function()
        im=not im
        if im then
            f.Size=UDim2.new(0,180,0,35)
            f.Position=UDim2.new(0.5,-90,0.5,-17.5)
            cf.Visible=false
            resizeButton.Visible=false
            m.Text="+"
            rf.Size=UDim2.new(0,192,0,47)
            rf.Position=UDim2.new(0.5,-96,0.5,-23.5)
        else
            f.Size=UDim2.new(0,298,0,328)
            f.Position=UDim2.new(0.5,-149,0.5,-164)
            cf.Visible=true
            resizeButton.Visible=true
            resizeButton.Position=UDim2.new(1,-20,1,-20)
            m.Text="—"
            rf.Size=UDim2.new(0,310,0,340)
            rf.Position=UDim2.new(0.5,-155,0.5,-170)
        end
    end)

    -- F5 Toggle
    local gv=true
    U.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.F5 then
            gv=not gv
            f.Visible=gv
            rf.Visible=gv
        end
    end)

    print("QTHANG-HUB loaded successfully")
    print("Features: Server hop + Aura")
    print("Press F5 to toggle menu")
end

print("QTHANG-HUB starting...")
