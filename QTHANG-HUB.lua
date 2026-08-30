-- QTHANG-HUB ServerHop
-- Creator: @qthangccth

local P=game:GetService("Players")
local T=game:GetService("TeleportService")
local H=game:GetService("HttpService")
local C=game:GetService("CoreGui")
local U=game:GetService("UserInputService")
local L=P.LocalPlayer
local PID=game.PlaceId
if _G.QH then _G.QH:Destroy() end
local g=Instance.new("ScreenGui")
g.Name="QH"
g.Parent=C
_G.QH=g
local rf=Instance.new("Frame")
rf.Size=UDim2.new(0,360,0,346)
rf.Position=UDim2.new(0.5,-180,0.5,-173)
rf.BackgroundColor3=Color3.fromRGB(255,0,0)
rf.BorderSizePixel=0
rf.Parent=g
local rc=Instance.new("UICorner")
rc.CornerRadius=UDim.new(0,16)
rc.Parent=rf
local gr=Instance.new("UIGradient")
gr.Parent=rf
local h=0
spawn(function()
    while rf and rf.Parent do
        h=(h+0.3)%360
        gr.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromHSV((h/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.1,Color3.fromHSV(((h+30)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.2,Color3.fromHSV(((h+60)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.3,Color3.fromHSV(((h+90)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.4,Color3.fromHSV(((h+120)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.5,Color3.fromHSV(((h+150)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.6,Color3.fromHSV(((h+180)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.7,Color3.fromHSV(((h+210)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.8,Color3.fromHSV(((h+240)/360)%1,1,1)),
            ColorSequenceKeypoint.new(0.9,Color3.fromHSV(((h+270)/360)%1,0.8,0.5)),
            ColorSequenceKeypoint.new(1,Color3.fromHSV(((h+360)/360)%1,1,1))
        })
        wait(0.04)
    end
end)
local f=Instance.new("Frame")
f.Size=UDim2.new(0,348,0,334)
f.Position=UDim2.new(0.5,-174,0.5,-167)
f.BackgroundColor3=Color3.fromRGB(10,10,15)
f.BackgroundTransparency=0.05
f.BorderSizePixel=0
f.Active=true
f.Draggable=true
f.Parent=g
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,14)
c.Parent=f
local is=Instance.new("Frame")
is.Size=UDim2.new(1,0,1,0)
is.Position=UDim2.new(0,0,0,0)
is.BackgroundColor3=Color3.fromRGB(0,0,0)
is.BackgroundTransparency=0.3
is.BorderSizePixel=0
is.Parent=f
local ic=Instance.new("UICorner")
ic.CornerRadius=UDim.new(0,14)
ic.Parent=is
f:GetPropertyChangedSignal("Position"):Connect(function()
    local p=f.Position
    rf.Position=UDim2.new(p.X.Scale,p.X.Offset-6,p.Y.Scale,p.Y.Offset-6)
end)
f:GetPropertyChangedSignal("Size"):Connect(function()
    local s=f.Size
    rf.Size=UDim2.new(s.X.Scale,s.X.Offset+12,s.Y.Scale,s.Y.Offset+12)
end)
local tb=Instance.new("Frame")
tb.Size=UDim2.new(1,0,0,40)
tb.Position=UDim2.new(0,0,0,0)
tb.BackgroundColor3=Color3.fromRGB(20,20,30)
tb.BackgroundTransparency=0.3
tb.BorderSizePixel=0
tb.Parent=f
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,14)
tbc.Parent=tb
local t=Instance.new("TextLabel")
t.Size=UDim2.new(0.7,0,1,0)
t.Position=UDim2.new(0,15,0,0)
t.BackgroundTransparency=1
t.Text="QTHANG-HUB"
t.TextColor3=Color3.fromRGB(255,255,255)
t.TextSize=22
t.Font=Enum.Font.GothamBold
t.TextXAlignment=Enum.TextXAlignment.Left
t.TextYAlignment=Enum.TextYAlignment.Center
t.Parent=tb
local m=Instance.new("TextButton")
m.Size=UDim2.new(0,30,0,30)
m.Position=UDim2.new(1,-37,0,5)
m.BackgroundColor3=Color3.fromRGB(40,40,50)
m.Text="−"
m.TextColor3=Color3.fromRGB(255,255,255)
m.TextSize=20
m.Font=Enum.Font.GothamBold
m.Parent=tb
local mc=Instance.new("UICorner")
mc.CornerRadius=UDim.new(0,6)
mc.Parent=m
local cf=Instance.new("Frame")
cf.Size=UDim2.new(1,0,1,-40)
cf.Position=UDim2.new(0,0,0,40)
cf.BackgroundTransparency=1
cf.Parent=f
local pcl=Instance.new("TextLabel")
pcl.Size=UDim2.new(1,-20,0,30)
pcl.Position=UDim2.new(0,10,0,10)
pcl.BackgroundTransparency=1
pcl.Text="SỐ NGƯỜI CHƠI TRONG MAP: "..#P:GetPlayers()
pcl.TextColor3=Color3.fromRGB(255,255,255)
pcl.TextSize=16
pcl.Font=Enum.Font.GothamBold
pcl.TextXAlignment=Enum.TextXAlignment.Center
pcl.Parent=cf
spawn(function()
    while wait(1) do
        if pcl and pcl.Parent then
            pcl.Text="SỐ NGƯỜI CHƠI TRONG MAP: "..#P:GetPlayers()
        end
    end
end)
local hcl=Instance.new("TextLabel")
hcl.Size=UDim2.new(1,-20,0,25)
hcl.Position=UDim2.new(0,10,0,45)
hcl.BackgroundTransparency=1
hcl.Text="SỐ NGƯỜI CHƠI TRONG MAP KHI HOP SV"
hcl.TextColor3=Color3.fromRGB(200,200,220)
hcl.TextSize=14
hcl.Font=Enum.Font.GothamBold
hcl.TextXAlignment=Enum.TextXAlignment.Center
hcl.Parent=cf
local inf=Instance.new("Frame")
inf.Size=UDim2.new(0,50,0,35)
inf.Position=UDim2.new(0.5,-25,0,78)
inf.BackgroundColor3=Color3.fromRGB(15,15,25)
inf.BorderSizePixel=2
inf.BorderColor3=Color3.fromRGB(60,60,80)
inf.Parent=cf
local inc=Instance.new("UICorner")
inc.CornerRadius=UDim.new(0,8)
inc.Parent=inf
local ht=Instance.new("TextBox")
ht.Size=UDim2.new(1,0,1,0)
ht.Position=UDim2.new(0,0,0,0)
ht.BackgroundTransparency=1
ht.Text="1"
ht.TextColor3=Color3.fromRGB(255,255,255)
ht.TextSize=22
ht.Font=Enum.Font.GothamBold
ht.TextXAlignment=Enum.TextXAlignment.Center
ht.TextYAlignment=Enum.TextYAlignment.Center
ht.PlaceholderText="1"
ht.Parent=inf
ht:GetPropertyChangedSignal("Text"):Connect(function()
    local n=tonumber(ht.Text)
    if not n then ht.Text="1" elseif n<1 then ht.Text="1" end
end)
local gl=Instance.new("TextLabel")
gl.Size=UDim2.new(1,-20,0,20)
gl.Position=UDim2.new(0,10,0,118)
gl.BackgroundTransparency=1
gl.Text="Nhập số người chơi mong muốn ( ví dụ: 1 = server 1 người )"
gl.TextColor3=Color3.fromRGB(255,200,100)
gl.TextSize=11
gl.Font=Enum.Font.GothamBold
gl.TextXAlignment=Enum.TextXAlignment.Center
gl.Parent=cf
local sl=Instance.new("TextLabel")
sl.Size=UDim2.new(1,-20,0,20)
sl.Position=UDim2.new(0,10,0,140)
sl.BackgroundTransparency=1
sl.Text="Đang tìm server có đúng 1 người..."
sl.TextColor3=Color3.fromRGB(100,255,100)
sl.TextSize=12
sl.Font=Enum.Font.GothamBold
sl.TextXAlignment=Enum.TextXAlignment.Center
sl.Parent=cf
local hb=Instance.new("TextButton")
hb.Size=UDim2.new(0.8,0,0,45)
hb.Position=UDim2.new(0.1,0,0,168)
hb.BackgroundColor3=Color3.fromRGB(0,130,255)
hb.Text="HOP SV 1 NGƯỜI"
hb.TextColor3=Color3.fromRGB(255,255,255)
hb.TextSize=18
hb.Font=Enum.Font.GothamBold
hb.Parent=cf
local hbc=Instance.new("UICorner")
hbc.CornerRadius=UDim.new(0,10)
hbc.Parent=hb
hb.MouseEnter:Connect(function() hb.BackgroundColor3=Color3.fromRGB(0,150,255) end)
hb.MouseLeave:Connect(function() hb.BackgroundColor3=Color3.fromRGB(0,130,255) end)
local cl=Instance.new("TextLabel")
cl.Size=UDim2.new(1,-20,0,25)
cl.Position=UDim2.new(0,10,0,222)
cl.BackgroundTransparency=1
cl.Text="HÃY XEM TIKTOK CỦA @qthangccth ĐỂ BIẾT THÊM NHIỀU"
cl.TextColor3=Color3.fromRGB(255,100,150)
cl.TextSize=12
cl.Font=Enum.Font.GothamBold
cl.TextXAlignment=Enum.TextXAlignment.Center
cl.Parent=cf
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
    sl.Text="Đang tìm server có đúng "..tp.." người..."
    sl.TextColor3=Color3.fromRGB(255,200,100)
    local sv=gs(PID,tp)
    if #sv>0 then
        local ts=sv[math.random(1,#sv)]
        sl.Text="Đã tìm thấy! Đang hop đến server "..tp.." người..."
        sl.TextColor3=Color3.fromRGB(100,255,100)
        pcall(function() T:TeleportToPlaceInstance(PID,ts.id,L) end)
    else
        sl.Text="Không tìm thấy server có "..tp.." người! Thử lại..."
        sl.TextColor3=Color3.fromRGB(255,100,100)
        wait(3)
        if sl and sl.Parent then
            sl.Text="Đang tìm server có đúng "..tp.." người..."
            sl.TextColor3=Color3.fromRGB(100,255,100)
        end
    end
end
hb.MouseButton1Click:Connect(sh)
local im=false
m.MouseButton1Click:Connect(function()
    im=not im
    if im then
        f.Size=UDim2.new(0,200,0,40)
        f.Position=UDim2.new(0.5,-100,0.5,-20)
        cf.Visible=false
        m.Text="+"
        t.Size=UDim2.new(0.5,0,1,0)
        t.TextSize=18
        rf.Size=UDim2.new(0,212,0,52)
        rf.Position=UDim2.new(0.5,-106,0.5,-26)
    else
        f.Size=UDim2.new(0,348,0,334)
        f.Position=UDim2.new(0.5,-174,0.5,-167)
        cf.Visible=true
        m.Text="−"
        t.Size=UDim2.new(0.7,0,1,0)
        t.TextSize=22
        rf.Size=UDim2.new(0,360,0,346)
        rf.Position=UDim2.new(0.5,-180,0.5,-173)
    end
end)
local gv=true
U.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.F5 then
        gv=not gv
        f.Visible=gv
        rf.Visible=gv
    end
end)
m.MouseEnter:Connect(function() m.BackgroundColor3=Color3.fromRGB(60,60,70) end)
m.MouseLeave:Connect(function() m.BackgroundColor3=Color3.fromRGB(40,40,50) end)
print("✅ QTHANG-HUB đã tải thành công!")
print("🌈 Viền cầu vồng với nhiều màu sắc!")
print("📌 Nhấn F5 để ẩn/hiện menu")
