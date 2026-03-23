--// ADVANCED GUI LIBRARY (ALL-IN-ONE)
--// Mobile + Draggable + Tabs + Button + Toggle + Slider + Dropdown + Notification + Theme + Config

local Library = {Flags = {}, Theme = {}}

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--// Theme
Library.Theme = {
    Main = Color3.fromRGB(18,18,24),
    Sidebar = Color3.fromRGB(25,25,32),
    Accent = Color3.fromRGB(0,170,255),
    Element = Color3.fromRGB(35,35,45),
    Text = Color3.new(1,1,1)
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AdvancedUILib"
ScreenGui.ResetOnSpawn = false

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,50,0,50)
ToggleBtn.Position = UDim2.new(0,10,0.5,-25)
ToggleBtn.Text = "≡"
ToggleBtn.BackgroundColor3 = Library.Theme.Element
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

-- Main
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,520,0,340)
Main.Position = UDim2.new(0.5,-260,0.5,-170)
Main.BackgroundColor3 = Library.Theme.Main
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

-- Drag
local drag=false;local dragInput;local dragStart;local startPos
Main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true;dragStart=i.Position;startPos=Main.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
Main.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput=i end
end)
UIS.InputChanged:Connect(function(i)
    if i==dragInput and drag then
        local delta=i.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)

-- Top
local Top = Instance.new("TextLabel", Main)
Top.Size = UDim2.new(1,0,0,40)
Top.BackgroundTransparency = 1
Top.Text = "Advanced UI"
Top.TextColor3 = Library.Theme.Text

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,130,1,-40)
Sidebar.Position = UDim2.new(0,0,0,40)
Sidebar.BackgroundColor3 = Library.Theme.Sidebar
Instance.new("UICorner", Sidebar)

-- Content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-140,1,-50)
Content.Position = UDim2.new(0,140,0,45)
Content.BackgroundTransparency = 1

-- Profile
local Profile = Instance.new("Frame", Sidebar)
Profile.Size = UDim2.new(1,0,0,60)
Profile.Position = UDim2.new(0,0,1,-60)
Profile.BackgroundTransparency = 1

local Avatar = Instance.new("ImageLabel", Profile)
Avatar.Size = UDim2.new(0,40,0,40)
Avatar.Position = UDim2.new(0,10,0.5,-20)
Avatar.BackgroundTransparency = 1
Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId

local Name = Instance.new("TextLabel", Profile)
Name.Size = UDim2.new(1,-60,1,0)
Name.Position = UDim2.new(0,55,0,0)
Name.Text = LocalPlayer.Name
Name.BackgroundTransparency = 1
Name.TextColor3 = Library.Theme.Text

-- Layouts
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0,5)
Instance.new("UIListLayout", Content).Padding = UDim.new(0,6)

-- Tabs
function Library:CreateTab(name)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1,-10,0,30)
    Btn.Text = name
    Btn.BackgroundColor3 = Library.Theme.Element
    Instance.new("UICorner", Btn)

    local Frame = Instance.new("Frame", Content)
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundTransparency = 1
    Frame.Visible = false
    Instance.new("UIListLayout", Frame).Padding = UDim.new(0,6)

    Btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Content:GetChildren()) do if v:IsA("Frame") then v.Visible=false end end
        Frame.Visible=true
    end)

    local Tab = {}

    function Tab:AddButton(txt,cb)
        local B=Instance.new("TextButton",Frame)
        B.Size=UDim2.new(1,0,0,35)
        B.Text=txt
        B.BackgroundColor3=Library.Theme.Element
        Instance.new("UICorner",B)
        B.MouseButton1Click:Connect(function() if cb then cb() end end)
    end

    function Tab:AddToggle(txt,flag,cb)
        local T=Instance.new("TextButton",Frame)
        T.Size=UDim2.new(1,0,0,35)
        T.BackgroundColor3=Library.Theme.Element
        Instance.new("UICorner",T)
        Library.Flags[flag]=false
        local function refresh() T.Text=txt..":"..(Library.Flags[flag] and"ON"or"OFF") end
        refresh()
        T.MouseButton1Click:Connect(function()
            Library.Flags[flag]=not Library.Flags[flag]
            refresh()
            if cb then cb(Library.Flags[flag]) end
        end)
    end

    function Tab:AddSlider(txt,flag,min,max,cb)
        local FrameS=Instance.new("Frame",Frame)
        FrameS.Size=UDim2.new(1,0,0,50)
        FrameS.BackgroundColor3=Library.Theme.Element
        Instance.new("UICorner",FrameS)

        local Val=min
        Library.Flags[flag]=Val

        local Label=Instance.new("TextLabel",FrameS)
        Label.Size=UDim2.new(1,0,0.5,0)
        Label.BackgroundTransparency=1

        local Bar=Instance.new("Frame",FrameS)
        Bar.Size=UDim2.new(1,-10,0,6)
        Bar.Position=UDim2.new(0,5,1,-10)
        Bar.BackgroundColor3=Color3.fromRGB(60,60,70)

        local Fill=Instance.new("Frame",Bar)
        Fill.Size=UDim2.new(0,0,1,0)
        Fill.BackgroundColor3=Library.Theme.Accent

        local dragging=false
        Bar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
        UIS.InputChanged:Connect(function(i)
            if dragging then
                local pos=(i.Position.X-Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X
                pos=math.clamp(pos,0,1)
                Fill.Size=UDim2.new(pos,0,1,0)
                Val=math.floor((min+(max-min)*pos))
                Library.Flags[flag]=Val
                Label.Text=txt..":"..Val
                if cb then cb(Val) end
            end
        end)
    end

    function Tab:AddDropdown(txt,list,flag,cb)
        local Container = Instance.new("Frame", Frame)
        Container.Size = UDim2.new(1,0,0,35)
        Container.BackgroundTransparency = 1

        local MainBtn = Instance.new("TextButton", Container)
        MainBtn.Size = UDim2.new(1,0,0,35)
        MainBtn.BackgroundColor3 = Library.Theme.Element
        MainBtn.Text = txt..": Select"
        MainBtn.TextColor3 = Library.Theme.Text
        Instance.new("UICorner", MainBtn)

        local DropFrame = Instance.new("Frame", Container)
        DropFrame.Position = UDim2.new(0,0,0,35)
        DropFrame.Size = UDim2.new(1,0,0,0)
        DropFrame.BackgroundColor3 = Library.Theme.Element
        DropFrame.ClipsDescendants = true
        Instance.new("UICorner", DropFrame)

        local UIList = Instance.new("UIListLayout", DropFrame)
        UIList.Padding = UDim.new(0,2)

        local Open = false
        local Selected = nil

        local function toggleDropdown()
            Open = not Open
            local size = Open and math.min(#list*32,120) or 0
            TweenService:Create(DropFrame, TweenInfo.new(0.25), {Size = UDim2.new(1,0,0,size)}):Play()
        end

        MainBtn.MouseButton1Click:Connect(toggleDropdown)

        -- Scroll support
        local Scroll = Instance.new("ScrollingFrame", DropFrame)
        Scroll.Size = UDim2.new(1,0,1,0)
        Scroll.CanvasSize = UDim2.new(0,0,0,#list*32)
        Scroll.ScrollBarThickness = 4
        Scroll.BackgroundTransparency = 1

        local ScrollLayout = Instance.new("UIListLayout", Scroll)
        ScrollLayout.Padding = UDim.new(0,2)

        for _,v in ipairs(list) do
            local Opt = Instance.new("TextButton", Scroll)
            Opt.Size = UDim2.new(1,0,0,30)
            Opt.Text = v
            Opt.BackgroundColor3 = Color3.fromRGB(45,45,55)
            Opt.TextColor3 = Library.Theme.Text
            Instance.new("UICorner", Opt)

            Opt.MouseButton1Click:Connect(function()
                Selected = v
                Library.Flags[flag] = v
                MainBtn.Text = txt..": "..v
                toggleDropdown()
                if cb then cb(v) end
            end)
        end

        -- Close when clicking outside
        UIS.InputBegan:Connect(function(input)
            if Open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not Container:IsAncestorOf(input.Target) then
                    toggleDropdown()
                end
            end
        end)
    end)

        for _,v in pairs(list) do
            local Opt=Instance.new("TextButton",ListFrame)
            Opt.Size=UDim2.new(1,0,0,30)
            Opt.Text=v
            Opt.MouseButton1Click:Connect(function()
                Library.Flags[flag]=v
                Btn.Text=txt..":"..v
                ListFrame.Visible=false
                if cb then cb(v) end
            end)
        end
    end

    return Tab
end

-- Notification
function Library:Notify(text)
    local N=Instance.new("TextLabel",ScreenGui)
    N.Size=UDim2.new(0,200,0,40)
    N.Position=UDim2.new(1,-210,1,-50)
    N.Text=text
    N.BackgroundColor3=Library.Theme.Element
    Instance.new("UICorner",N)

    TweenService:Create(N,TweenInfo.new(0.3),{Position=UDim2.new(1,-210,1,-100)}):Play()
    task.delay(3,function() N:Destroy() end)
end

-- Config Save
function Library:SaveConfig()
    return HttpService:JSONEncode(Library.Flags)
end

function Library:LoadConfig(str)
    local data=HttpService:JSONDecode(str)
    for k,v in pairs(data) do Library.Flags[k]=v end
end

-- Toggle UI
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible=not Main.Visible
end)

return Library
