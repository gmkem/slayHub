-- SlayLib Library
local SlayLib = {}
SlayLib.__index = SlayLib

-- Roblox Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

-- GUI Parent
local function GetParent()
    if gethui then return gethui() end
    return CoreGui
end
local GuiParent = GetParent()

-- Default Theme
SlayLib.Theme = {
    Background = Color3.fromRGB(15,15,25),
    Container = Color3.fromRGB(25,25,40),
    Element = Color3.fromRGB(35,35,55),
    ElementHover = Color3.fromRGB(50,50,75),
    Accent = Color3.fromRGB(255,100,200),
    Text = Color3.fromRGB(255,255,255)
}

-- Utility: Create Instance
function SlayLib:Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k]=v end
    return obj
end

-- Utility: Draggable
function SlayLib:MakeDraggable(frame)
    local dragging, dragInput, startPos, mouseStart = false,nil,nil,nil
    local function update(input)
        local delta = input.Position - mouseStart
        frame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging = true
            mouseStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input==dragInput and dragging then update(input) end
    end)
end

-- Create Window
function SlayLib:CreateWindow(title)
    local window = self:Create("ScreenGui",{Parent=GuiParent,Name=title})
    local main = self:Create("Frame",{
        Parent = window,
        Size = UDim2.new(0,420,0,360),
        Position = UDim2.new(0.5,-210,0.5,-180),
        BackgroundColor3 = self.Theme.Background,
        Active = true,
        Draggable = true
    })
    local header = self:Create("TextLabel",{
        Parent = main,
        Size = UDim2.new(1,0,0,35),
        Text = title,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        BackgroundTransparency = 1
    })
    main.Header = header

    local tabsHolder = self:Create("Frame",{
        Parent = main,
        Size = UDim2.new(1,0,1,-35),
        Position = UDim2.new(0,0,0,35),
        BackgroundTransparency = 1
    })
    main.TabsHolder = tabsHolder

    self:MakeDraggable(main)
    window.Main = main
    return window
end

-- Create Tab
function SlayLib:CreateTab(window,name)
    local tabBtn = self:Create("TextButton",{
        Parent = window.Main.Header,
        Size = UDim2.new(0,100,1,0),
        Position = UDim2.new(0, (#window.Main.Header:GetChildren()-1)*100,0,0),
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundColor3 = self.Theme.Element,
        TextColor3 = self.Theme.Text,
        BorderSizePixel = 0
    })
    local content = self:Create("Frame",{
        Parent = window.Main.TabsHolder,
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = self.Theme.Container,
        Visible = false
    })
    tabBtn.MouseButton1Click:Connect(function()
        for _,v in ipairs(window.Main.TabsHolder:GetChildren()) do
            if v:IsA("Frame") then v.Visible=false end
        end
        content.Visible=true
    end)
    return content
end

-- Button
function SlayLib:CreateButton(parent,text,callback)
    local btn = self:Create("TextButton",{
        Parent=parent,
        Size=UDim2.new(1,-20,0,30),
        Position=UDim2.new(0,10,0,30*(#parent:GetChildren())),
        Text=text,
        BackgroundColor3=self.Theme.Element,
        TextColor3=self.Theme.Text,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    })
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Toggle
function SlayLib:CreateToggle(parent,text,callback)
    local frame = self:Create("Frame",{
        Parent=parent,
        Size=UDim2.new(1,-20,0,30),
        Position=UDim2.new(0,10,0,30*(#parent:GetChildren())),
        BackgroundColor3=self.Theme.Element
    })
    local label = self:Create("TextLabel",{
        Parent=frame,
        Size=UDim2.new(0.7,0,1,0),
        Text=text,
        BackgroundTransparency=1,
        TextColor3=self.Theme.Text,
        Font=Enum.Font.Gotham,
        TextSize=14
    })
    local btn = self:Create("TextButton",{
        Parent=frame,
        Size=UDim2.new(0.3,0,1,0),
        Position=UDim2.new(0.7,0,0,0),
        Text="OFF",
        BackgroundColor3=self.Theme.Accent,
        TextColor3=self.Theme.Text,
        BorderSizePixel=0
    })
    local toggled=false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.Text = toggled and "ON" or "OFF"
        callback(toggled)
    end)
    return frame
end

-- Slider
function SlayLib:CreateSlider(parent,text,min,max,callback)
    local frame = self:Create("Frame",{
        Parent=parent,
        Size=UDim2.new(1,-20,0,30),
        Position=UDim2.new(0,10,0,30*(#parent:GetChildren())),
        BackgroundColor3=self.Theme.Element
    })
    local label = self:Create("TextLabel",{
        Parent=frame,
        Size=UDim2.new(0.5,0,1,0),
        Text=text,
        BackgroundTransparency=1,
        TextColor3=self.Theme.Text,
        Font=Enum.Font.Gotham,
        TextSize=14
    })
    local slider = self:Create("Frame",{
        Parent=frame,
        Size=UDim2.new(0.5,0,0.5,0),
        Position=UDim2.new(0.5,0,0.25,0),
        BackgroundColor3=self.Theme.Accent
    })
    local dragging=false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X - slider.AbsolutePosition.X
            local percent = math.clamp(mouseX/slider.AbsoluteSize.X,0,1)
            slider.Size = UDim2.new(percent,0,0.5,0)
            local value = min + (max-min)*percent
            callback(value)
        end
    end)
    return frame
end

-- TextBox
function SlayLib:CreateTextBox(parent,placeholder,callback)
    local box = self:Create("TextBox",{
        Parent=parent,
        Size=UDim2.new(1,-20,0,30),
        Position=UDim2.new(0,10,0,30*(#parent:GetChildren())),
        Text=placeholder,
        TextColor3=self.Theme.Text,
        BackgroundColor3=self.Theme.Element,
        BorderSizePixel=0,
        Font=Enum.Font.Gotham,
        TextSize=14
    })
    box.FocusLost:Connect(function(enter)
        if enter then callback(box.Text) end
    end)
    return box
end

-- Dropdown
function SlayLib:CreateDropdown(parent,options,callback)
    local dropdown = self:Create("TextButton",{
        Parent=parent,
        Size=UDim2.new(1,-20,0,30),
        Position=UDim2.new(0,10,0,30*(#parent:GetChildren())),
        Text="Select",
        BackgroundColor3=self.Theme.Element,
        TextColor3=self.Theme.Text,
        BorderSizePixel=0,
        Font=Enum.Font.GothamBold,
        TextSize=16
    })
    local list = self:Create("Frame",{
        Parent=parent,
        Size=UDim2.new(1,-20,0,#options*25),
        Position=UDim2.new(0,10,0,30*(#parent:GetChildren())+30),
        BackgroundColor3=self.Theme.Container,
        Visible=false
    })
    for i,opt in ipairs(options) do
        local item = self:Create("TextButton",{
            Parent=list,
            Size=UDim2.new(1,0,0,25),
            Position=UDim2.new(0,0,0,25*(i-1)),
            Text=opt,
            BackgroundColor3=self.Theme.Element,
            TextColor3=self.Theme.Text,
            Font=Enum.Font.Gotham,
            TextSize=14,
            BorderSizePixel=0
        })
        item.MouseButton1Click:Connect(function()
            dropdown.Text=opt
            list.Visible=false
            callback(opt)
        end)
    end
    dropdown.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
    end)
    return dropdown
end

-- Notification
function SlayLib:Notify(text,duration)
    duration = duration or 3
    local notif = self:Create("Frame",{
        Parent=GuiParent,
        Size=UDim2.new(0,200,0,50),
        Position=UDim2.new(1,-210,1,-60),
        BackgroundColor3=self.Theme.Element
    })
    local label = self:Create("TextLabel",{
        Parent=notif,
        Size=UDim2.new(1,0,1,0),
        Text=text,
        TextColor3=self.Theme.Text,
        BackgroundTransparency=1,
        Font=Enum.Font.GothamBold,
        TextSize=14
    })
    notif:TweenPosition(UDim2.new(1,-210,1,-120),"Out","Quad",0.5,true)
    delay(duration,function()
        notif:TweenPosition(UDim2.new(1,-210,1,-60),"In","Quad",0.5,true)
        wait(0.5)
        notif:Destroy()
    end)
end

return SlayLib