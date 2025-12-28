-- [[ SlayHub X Emote Script | Compact Float Edition | V31 PRO ]] --

-- Theme Colors
local Theme = {
    Accent = Color3.fromRGB(180,80,255),
    Bg = Color3.fromRGB(18,18,18),
    Btn = Color3.fromRGB(28,28,28),
    BtnHover = Color3.fromRGB(45,45,45),
    Text = Color3.fromRGB(255,255,255),
    TextDim = Color3.fromRGB(180,180,180),
    Fav = Color3.fromRGB(255,215,0),
    Freeze = Color3.fromRGB(0,200,255)
}

-- Clear old UI
if game:GetService("CoreGui"):FindFirstChild("SlayHubX_Compact") then
    game:GetService("CoreGui"):FindFirstChild("SlayHubX_Compact"):Destroy()
end

-- Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Variables
local FavoriteFile = "SlayHubX_Favs.json"
local FavoritedEmotes = {}
local AllEmotesData = {}
local currentEmoteTrack = nil
local emotesWalkEnabled = false

-- Load/Save Favorites
local function SaveFavs() if writefile then writefile(FavoriteFile, HttpService:JSONEncode(FavoritedEmotes)) end end
local function LoadFavs() if isfile and isfile(FavoriteFile) then local ok, data = pcall(readfile, FavoriteFile) if ok then FavoritedEmotes = HttpService:JSONDecode(data) end end end
LoadFavs()

-- Utilities
local function StopCurrent() if currentEmoteTrack and typeof(currentEmoteTrack)=="Instance" then pcall(function() currentEmoteTrack:Stop() end) end currentEmoteTrack=nil end
local function ToggleAnimate(state) local c=LocalPlayer.Character if c and c:FindFirstChild("Animate") then c.Animate.Disabled = not state end end

local function PlayEmote(name,id)
    local c=LocalPlayer.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    local d=h and h:FindFirstChildOfClass("HumanoidDescription")
    if not d then return end
    StopCurrent()
    pcall(function()
        d:AddEmote(name,id)
        local t=h:PlayEmoteAndGetAnimTrackById(id)
        if t then
            currentEmoteTrack=t
            currentEmoteTrack.Priority=Enum.AnimationPriority.Action4
            currentEmoteTrack.Looped=true
            if emotesWalkEnabled then ToggleAnimate(false) currentEmoteTrack:Play() end
        end
    end)
end

-- ScreenGui
local ScreenGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
ScreenGui.Name="SlayHubX_Compact"
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

-- Floating Button
local ToggleBtn=Instance.new("TextButton",ScreenGui)
ToggleBtn.Size=UDim2.new(0,50,0,50)
ToggleBtn.Position=UDim2.new(0,25,0.5,-25)
ToggleBtn.BackgroundColor3=Theme.Bg
ToggleBtn.Text="S"
ToggleBtn.TextColor3=Theme.Accent
ToggleBtn.Font=Enum.Font.GothamBold
ToggleBtn.TextSize=22
Instance.new("UICorner",ToggleBtn).CornerRadius=UDim.new(1,0)
local ToggleStroke=Instance.new("UIStroke",ToggleBtn)
ToggleStroke.Color=Theme.Accent ToggleStroke.Thickness=1.6

-- Main Frame
local Main=Instance.new("Frame",ScreenGui)
Main.Size=UDim2.new(0,400,0,340)
Main.Position=UDim2.new(0.5,-200,0.5,-170)
Main.BackgroundColor3=Theme.Bg
Main.Visible=false
Main.Active=true
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
local Stroke=Instance.new("UIStroke",Main)
Stroke.Color=Theme.Accent Stroke.Thickness=1.3 Stroke.Transparency=0.5

-- Title Bar
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "SlayHub X Emote Script"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Divider Line
local Line = Instance.new("Frame", Main)
Line.Size = UDim2.new(1, -20, 0, 1)
Line.Position = UDim2.new(0, 10, 0, 43)
Line.BackgroundColor3 = Theme.Accent
Line.BorderSizePixel = 0
Line.BackgroundTransparency = 0.4

-- Stable Drag Function
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos

    obj.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragStart=input.Position
            startPos=obj.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            dragInput=input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input==dragInput and dragging then
            local delta=input.Position - dragStart
            obj.Position=UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

MakeDraggable(ToggleBtn)
MakeDraggable(Main)

-- Tabs
local TabFrame=Instance.new("Frame",Main)
TabFrame.Size=UDim2.new(1,-20,0,30)
TabFrame.Position=UDim2.new(0,10,0,45)
TabFrame.BackgroundTransparency=1
local TabLayout=Instance.new("UIListLayout",TabFrame)
TabLayout.FillDirection=Enum.FillDirection.Horizontal TabLayout.Padding=UDim.new(0,8)

local CurrentTab="All"
local function CreateTabBtn(txt)
    local b=Instance.new("TextButton",TabFrame)
    b.Size=UDim2.new(0,85,1,0)
    b.BackgroundColor3=Theme.Btn
    b.Text=txt
    b.TextColor3=(txt=="All") and Theme.Accent or Theme.TextDim
    b.Font=Enum.Font.GothamBold b.TextSize=13
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        CurrentTab=txt
        for _,v in pairs(TabFrame:GetChildren()) do if v:IsA("TextButton") then v.TextColor3=Theme.TextDim end end
        b.TextColor3=Theme.Accent
        for _,f in pairs(Main:GetChildren()) do if f:IsA("ScrollingFrame") then f.Visible=(f.Name==txt.."Page") end end
    end)
    return b
end

CreateTabBtn("All")
local FavBtn=CreateTabBtn("Fav")

-- Search Box
local SearchBox=Instance.new("TextBox",Main)
SearchBox.Size=UDim2.new(0,170,0,28)
SearchBox.Position=UDim2.new(1,-180,0,45)
SearchBox.BackgroundColor3=Theme.Btn
SearchBox.PlaceholderText="🔍 Search..."
SearchBox.TextColor3=Theme.Text
SearchBox.Font=Enum.Font.Gotham
SearchBox.TextSize=13
Instance.new("UICorner",SearchBox).CornerRadius=UDim.new(0,6)

-- Scroll Frames
local function CreateScroll(name)
    local s=Instance.new("ScrollingFrame",Main)
    s.Name=name.."Page"
    s.Size=UDim2.new(1,-20,1,-150)
    s.Position=UDim2.new(0,10,0,85)
    s.BackgroundTransparency=1
    s.ScrollBarThickness=3 s.ScrollBarImageColor3=Theme.Accent
    s.Visible=(name=="All")
    s.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local list=Instance.new("UIListLayout",s) list.Padding=UDim.new(0,8) list.HorizontalAlignment=Enum.HorizontalAlignment.Center
    local pad=Instance.new("UIPadding",s) pad.PaddingBottom=UDim.new(0,20)
    return s
end

local AllPage=CreateScroll("All")
local FavPage=CreateScroll("Fav")

-- Card Creation
local function CreateCard(name,id,parent)
    local card=Instance.new("Frame",parent)
    card.Size=UDim2.new(0.95,0,0,80)
    card.BackgroundColor3=Theme.Btn
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)

    local img=Instance.new("ImageLabel",card)
    img.Size=UDim2.new(0,70,0,70)
    img.Position=UDim2.new(0,5,0,5)
    img.BackgroundTransparency=1
    img.Image="rbxthumb://type=Asset&id="..id.."&w=150&h=150"
    Instance.new("UICorner",img)

    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,-120,1,0)
    lbl.Position=UDim2.new(0,85,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=name
    lbl.TextColor3=Theme.Text
    lbl.Font=Enum.Font.GothamMedium
    lbl.TextSize=14
    lbl.TextXAlignment="Left"

    -- ปุ่มเล่น (สร้างก่อน)
    local playBtn=Instance.new("TextButton",card)
    playBtn.Size=UDim2.new(1,0,1,0)
    playBtn.BackgroundTransparency=1
    playBtn.Text=""
    playBtn.ZIndex = 1
    playBtn.MouseButton1Click:Connect(function()
        PlayEmote(name,id)
    end)

    -- ปุ่มดาว (อยู่บนสุด)
    local favBtn=Instance.new("TextButton",card)
    favBtn.Size=UDim2.new(0,30,0,30)
    favBtn.Position=UDim2.new(1,-35,0.5,-15)
    favBtn.BackgroundTransparency=1
    favBtn.Text=table.find(FavoritedEmotes,id) and "★" or "☆"
    favBtn.TextColor3=Theme.Fav
    favBtn.TextSize=20
    favBtn.ZIndex = 2
    favBtn.MouseButton1Click:Connect(function()
        local idx=table.find(FavoritedEmotes,id)
        if idx then
            table.remove(FavoritedEmotes,idx)
            favBtn.Text="☆"
        else
            table.insert(FavoritedEmotes,id)
            favBtn.Text="★"
        end
        SaveFavs()
    end)
end

-- Freeze Toggle (Fixed walking & animation)
local FreezeBtn=Instance.new("TextButton",Main)
FreezeBtn.Size=UDim2.new(1,-20,0,38)
FreezeBtn.Position=UDim2.new(0,10,1,-48)
FreezeBtn.BackgroundColor3=Theme.Btn
FreezeBtn.Text="EMOTE FREEZE: OFF"
FreezeBtn.TextColor3=Theme.Text
FreezeBtn.Font=Enum.Font.GothamBold
Instance.new("UICorner",FreezeBtn).CornerRadius=UDim.new(0,8)
FreezeBtn.MouseButton1Click:Connect(function()
    emotesWalkEnabled = not emotesWalkEnabled
    FreezeBtn.BackgroundColor3 = emotesWalkEnabled and Theme.Freeze or Theme.Btn
    FreezeBtn.Text = "EMOTE FREEZE: "..(emotesWalkEnabled and "ON" or "OFF")
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        if emotesWalkEnabled then
            ToggleAnimate(false)
            if currentEmoteTrack then currentEmoteTrack:Play() end
        else
            ToggleAnimate(true)
            StopCurrent()
        end
    end
end)

-- Search Logic
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchBox.Text:lower()
    local targetPage=(CurrentTab=="Fav") and FavPage or AllPage
    for _,child in pairs(targetPage:GetChildren()) do
        if child:IsA("Frame") then
            local text=child:FindFirstChildOfClass("TextLabel").Text:lower()
            child.Visible=text:find(q) and true or false
        end
    end
end)

-- Favorite Refresh
FavBtn.MouseButton1Click:Connect(function()
    for _,v in pairs(FavPage:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for _,e in pairs(AllEmotesData) do
        if table.find(FavoritedEmotes,e.id) then CreateCard(e.name,e.id,FavPage) end
    end
end)

-- Load Emotes from Catalog
task.spawn(function()
    local Cursor=""
    while true do
        local ok,res=pcall(function() return game:HttpGetAsync("https://catalog.roblox.com/v1/search/items/details?Category=12&Subcategory=39&SortType=1&limit=30&cursor="..Cursor) end)
        if not ok then break end
        local data=HttpService:JSONDecode(res)
        for _,item in pairs(data.data) do
            table.insert(AllEmotesData,{name=item.name,id=item.id})
            CreateCard(item.name,item.id,AllPage)
        end
        if data.nextPageCursor then Cursor=data.nextPageCursor else break end
        task.wait(0.1)
    end
end)

-- Toggle GUI Visibility (Smooth)
ToggleBtn.MouseButton1Click:Connect(function()
    if not Main.Visible then
        Main.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,400,0,340)}):Play()
    else
        local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        tween:Play()
        tween.Completed:Connect(function() Main.Visible = false end)
    end
end)

-- Loop Fix for Freeze
RunService.Stepped:Connect(function()
    if emotesWalkEnabled and currentEmoteTrack and typeof(currentEmoteTrack)=="Instance" then
        pcall(function()
            if not currentEmoteTrack.IsPlaying then currentEmoteTrack:Play() end
            currentEmoteTrack:AdjustWeight(1)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Animate") then ToggleAnimate(false) end
        end)
    end
end)
