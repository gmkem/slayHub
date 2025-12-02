--[[ 
   SlayLib.lua
   Ultimate Roblox GUI Library
   Author: คุณ Ohvn Bdon
--]]

local SlayLib = {}
SlayLib.__index = SlayLib

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Default theme
SlayLib.Theme = {
    MainColor = Color3.fromRGB(255, 215, 0), -- Gold
    Background = Color3.fromRGB(30, 30, 30), -- Dark
    Accent = Color3.fromRGB(50,50,50),
    TextColor = Color3.fromRGB(255,255,255)
}

-- Utils
local function Create(class,parent,props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- Dragging
function SlayLib:EnableDragging(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,startPos.Y.Scale,startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Notification
function SlayLib:Notification(title,text,duration,color)
    local screen = PlayerGui:FindFirstChild("SlayLibScreen") or Create("ScreenGui",PlayerGui,{Name="SlayLibScreen"})
    local notifFrame = Create("Frame",screen,{
        Size=UDim2.new(0,250,0,50),
        Position=UDim2.new(1,-260,1,-60),
        BackgroundColor3=color or self.Theme.MainColor,
        AnchorPoint=Vector2.new(1,1),
        ClipsDescendants=true,
        BorderSizePixel=0
    })
    local notifText = Create("TextLabel",notifFrame,{
        Size=UDim2.new(1,0,1,0),
        Text=title.."\n"..text,
        TextColor3=self.Theme.TextColor,
        BackgroundTransparency=1,
        Font=Enum.Font.GothamBold,
        TextSize=14,
        TextWrapped=true
    })
    notifFrame:TweenPosition(UDim2.new(1,-260,1,-70),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
    delay(duration or 3,function()
        notifFrame:TweenPosition(UDim2.new(1,-260,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,0.3,true)
        wait(0.3)
        notifFrame:Destroy()
    end)
end

-- Loader animation
function SlayLib:Loader(title)
    local screen = PlayerGui:FindFirstChild("SlayLibScreen") or Create("ScreenGui",PlayerGui,{Name="SlayLibScreen"})
    local frame = Create("Frame",screen,{
        Size=UDim2.new(0,300,0,100),
        Position=UDim2.new(0.5,-150,0.5,-50),
        BackgroundColor3=self.Theme.Background,
        BorderSizePixel=0,
        ClipsDescendants=true
    })
    local label = Create("TextLabel",frame,{
        Text=title or "Loading...",
        TextColor3=self.Theme.MainColor,
        Font=Enum.Font.GothamBold,
        TextSize=22,
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1
    })
    local progress = Create("Frame",frame,{
        Size=UDim2.new(0,0,0,5),
        Position=UDim2.new(0,0,1,-5),
        BackgroundColor3=self.Theme.MainColor
    })
    for i=0,1,0.02 do
        progress.Size = UDim2.new(i,0,0,5)
        wait(0.02)
    end
    wait(0.2)
    frame:Destroy()
end

-- Create Window
function SlayLib:CreateWindow(info)
    self:Loader("SlayLib Initializing...")
    local screen = PlayerGui:FindFirstChild("SlayLibScreen") or Create("ScreenGui",PlayerGui,{Name="SlayLibScreen"})
    local mainFrame = Create("Frame",screen,{
        Size=UDim2.new(0,400,0,300),
        Position=UDim2.new(0.5,-200,0.5,-150),
        BackgroundColor3=self.Theme.Background,
        BorderSizePixel=0
    })
    self:EnableDragging(mainFrame)

    local title = Create("TextLabel",mainFrame,{
        Size=UDim2.new(1,0,0,30),
        Text=info.Name or "SlayLib",
        BackgroundTransparency=1,
        TextColor3=self.Theme.MainColor,
        Font=Enum.Font.GothamBold,
        TextSize=18
    })

    local tabsFolder = Create("Folder",mainFrame,{Name="Tabs"})
    mainFrame.TabsFolder = tabsFolder

    local windowObj = {}
    function windowObj:CreateTab(name)
        local tabFrame = Create("Frame",mainFrame,{
            Size=UDim2.new(1,0,1,-30),
            Position=UDim2.new(0,0,0,30),
            BackgroundTransparency=1,
            Visible=false
        })
        tabFrame.Name = name
        tabsFolder[name] = tabFrame

        -- Tab button
        local btn = Create("TextButton",title,{
            Text=name,
            Size=UDim2.new(0,100,1,0),
            Position=UDim2.new(0,#tabsFolder:GetChildren()*100,0,0),
            BackgroundTransparency=0.5,
            BackgroundColor3=self.Theme.Accent,
            TextColor3=self.Theme.TextColor
        })
        btn.MouseButton1Click:Connect(function()
            for _,v in pairs(tabsFolder:GetChildren()) do if v:IsA("Frame") then v.Visible=false end end
            tabFrame.Visible = true
        end)

        local tabObj = {}
        function tabObj:CreateButton(info)
            local b = Create("TextButton",tabFrame,{
                Text=info.Name,
                Size=UDim2.new(0,120,0,30),
                Position=UDim2.new(0,10,#tabFrame:GetChildren()*35,0),
                BackgroundColor3=self.Theme.MainColor,
                TextColor3=self.Theme.TextColor
            })
            b.MouseButton1Click:Connect(info.Callback)
        end
        function tabObj:CreateToggle(info)
            local b = Create("TextButton",tabFrame,{
                Text=info.Name.." : "..tostring(info.Default),
                Size=UDim2.new(0,150,0,30),
                Position=UDim2.new(0,10,#tabFrame:GetChildren()*35,0),
                BackgroundColor3=self.Theme.Accent,
                TextColor3=self.Theme.TextColor
            })
            local toggled = info.Default or false
            b.MouseButton1Click:Connect(function()
                toggled = not toggled
                b.Text = info.Name.." : "..tostring(toggled)
                info.Callback(toggled)
            end)
        end
        function tabObj:CreateSlider(info)
            local sliderFrame = Create("Frame",tabFrame,{
                Size=UDim2.new(0,150,0,30),
                Position=UDim2.new(0,10,#tabFrame:GetChildren()*35,0),
                BackgroundColor3=self.Theme.Accent
            })
            local label = Create("TextLabel",sliderFrame,{
                Size=UDim2.new(0.5,0,1,0),
                Text=info.Name..": "..tostring(info.Default or 0),
                BackgroundTransparency=1,
                TextColor3=self.Theme.TextColor,
                Font=Enum.Font.GothamBold,
                TextSize=14
            })
            local slider = Create("Frame",sliderFrame,{
                Size=UDim2.new(0.5,0,1,0),
                Position=UDim2.new(0.5,0,0,0),
                BackgroundColor3=self.Theme.MainColor
            })
            -- Slider dragging
            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local function move(input)
                        local x = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X,0,sliderFrame.AbsoluteSize.X)
                        slider.Size = UDim2.new(0,x,1,0)
                        local val = math.floor((x/sliderFrame.AbsoluteSize.X)*(info.Max or 100))
                        label.Text = info.Name..": "..val
                        info.Callback(val)
                    end
                    local conn
                    conn = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            conn:Disconnect()
                        end
                    end)
                    local moveConn
                    moveConn = UserInputService.InputChanged:Connect(function(i)
                        if i == input or i.UserInputType == Enum.UserInputType.MouseMovement then
                            move(i)
                        end
                    end)
                end
            end)
        end
        function tabObj:CreateDropdown(info)
            local dd = Create("TextButton",tabFrame,{
                Text=info.Name,
                Size=UDim2.new(0,150,0,30),
                Position=UDim2.new(0,10,#tabFrame:GetChildren()*35,0),
                BackgroundColor3=self.Theme.Accent,
                TextColor3=self.Theme.TextColor
            })
            local open = false
            local ddFrame = Create("Frame",tabFrame,{
                Size=UDim2.new(0,150,0,#info.Options*30),
                Position=UDim2.new(0,10,#tabFrame:GetChildren()*35+30,0),
                BackgroundColor3=self.Theme.Background,
                Visible=false
            })
            for i,opt in pairs(info.Options) do
                local btn = Create("TextButton",ddFrame,{
                    Text=opt,
                    Size=UDim2.new(1,0,0,30),
                    Position=UDim2.new(0,0,(i-1)*30,0),
                    BackgroundColor3=self.Theme.MainColor,
                    TextColor3=self.Theme.TextColor
                })
                btn.MouseButton1Click:Connect(function()
                    info.Callback(opt)
                    ddFrame.Visible = false
                end)
            end
            dd.MouseButton1Click:Connect(function()
                open = not open
                ddFrame.Visible = open
            end)
        end
        function tabObj:CreateTextBox(info)
            local tb = Create("TextBox",tabFrame,{
                Text=info.Placeholder or "",
                Size=UDim2.new(0,150,0,30),
                Position=UDim2.new(0,10,#tabFrame:GetChildren()*35,0),
                BackgroundColor3=self.Theme.Accent,
                TextColor3=self.Theme.TextColor,
                ClearTextOnFocus=false
            })
            tb.FocusLost:Connect(function(enter)
                if enter then
                    info.Callback(tb.Text)
                end
            end)
        end
        return tabObj
    end
    return windowObj
end

return SlayLib