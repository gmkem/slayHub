-- SlayLib Full GUI Library for Roblox Mobile
-- Author: You
-- Features: Tabs, Toggle, Slider, Dropdown, TextBox, Notifications, Theme, Drag, Mobile Friendly

local SlayLib = {}
SlayLib.__index = SlayLib

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Default Theme
SlayLib.Theme = {
    Primary = Color3.fromRGB(255,105,180),
    Secondary = Color3.fromRGB(40,40,40),
    Accent = Color3.fromRGB(255,182,193),
    TextColor = Color3.fromRGB(255,255,255)
}

-- Helper: Create Label
local function createLabel(text,parent,pos,size,font,txtSize)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = size
    lbl.Position = pos
    lbl.TextColor3 = SlayLib.Theme.TextColor
    lbl.BackgroundTransparency = 1
    lbl.Font = font or Enum.Font.Gotham
    lbl.TextSize = txtSize or 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- Helper: Create Button
local function createButton(text,parent,pos,size)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = SlayLib.Theme.Accent
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = SlayLib.Theme.Primary
    stroke.Thickness = 1
    stroke.Parent = btn

    return btn
end

-- Create Window
function SlayLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SlayLibUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,360,0,480)
    MainFrame.Position = UDim2.new(0.5,-180,0.5,-240)
    MainFrame.BackgroundColor3 = self.Theme.Secondary
    MainFrame.BackgroundTransparency = 0.25
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Name = "MainFrame"

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,12)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.Theme.Primary
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame

    -- Draggable
    MainFrame.Active = true
    MainFrame.Draggable = true

    -- Title
    local TitleLabel = createLabel(title or "SlayLib",MainFrame,UDim2.new(0,10,0,0),UDim2.new(1,-20,0,50),Enum.Font.GothamBold,24)

    -- Tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1,0,1,-50)
    TabContainer.Position = UDim2.new(0,0,0,50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    -- Toggle visibility button
    local toggleBtn = createButton("Toggle UI",ScreenGui,UDim2.new(0,10,0,10),UDim2.new(0,100,0,30))
    local visible = true
    toggleBtn.MouseButton1Click:Connect(function()
        visible = not visible
        MainFrame.Visible = visible
    end)

    local window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        Tabs = {},
        Notifications = {},
        Visibility = visible
    }
    setmetatable(window,self)
    return window
end

-- Add Tab
function SlayLib:AddTab(window,name)
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,0,1,0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = true
    TabFrame.Parent = window.TabContainer
    window.Tabs[name] = TabFrame
    return TabFrame
end

-- Add Toggle
function SlayLib:AddToggle(tab,name,callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-20,0,40)
    frame.Position = UDim2.new(0,10,0,#tab:GetChildren()*45)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.1
    frame.Parent = tab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = SlayLib.Theme.Accent
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = createLabel(name,frame,UDim2.new(0,10,0,0),UDim2.new(0.7,0,1,0))
    local btn = createButton("OFF",frame,UDim2.new(0.7,0,0.15,0),UDim2.new(0.25,0,0.7,0))
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.Text = toggled and "ON" or "OFF"
        if callback then callback(toggled) end
    end)
end

-- Add Slider
function SlayLib:AddSlider(tab,name,min,max,default,callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-20,0,50)
    frame.Position = UDim2.new(0,10,0,#tab:GetChildren()*55)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.1
    frame.Parent = tab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = SlayLib.Theme.Accent
    stroke.Thickness = 1
    stroke.Parent = frame

    createLabel(name,frame,UDim2.new(0,10,0,0),UDim2.new(0.5,0,0.5,0))

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.6,0,0.2,0)
    bar.Position = UDim2.new(0.35,0,0.4,0)
    bar.BackgroundColor3 = SlayLib.Theme.Accent
    bar.Parent = frame

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = LocalPlayer:GetMouse()
            local relX = math.clamp(mouse.X - frame.AbsolutePosition.X,0,frame.AbsoluteSize.X*0.6)
            bar.Size = UDim2.new(0,relX,0.2,0)
            local val = math.floor((relX/(frame.AbsoluteSize.X*0.6))*(max-min)+min)
            if callback then callback(val) end
        end
    end)
end

-- Add Dropdown
function SlayLib:AddDropdown(tab,name,options,callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-20,0,40)
    frame.Position = UDim2.new(0,10,0,#tab:GetChildren()*45)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.1
    frame.Parent = tab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = SlayLib.Theme.Accent
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = createLabel(name,frame,UDim2.new(0,10,0,0),UDim2.new(0.6,0,1,0))
    local btn = createButton("Select",frame,UDim2.new(0.65,0,0.15,0),UDim2.new(0.35,0,0.7,0))

    local open = false
    local optionFrame = Instance.new("Frame")
    optionFrame.Size = UDim2.new(0.35,0,#options*30,0)
    optionFrame.Position = UDim2.new(0.65,0,1,0)
    optionFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    optionFrame.Visible = false
    optionFrame.Parent = frame

    for i,opt in ipairs(options) do
        local optBtn = createButton(opt,optionFrame,UDim2.new(0,0,0,(i-1)*30),UDim2.new(1,0,0,30))
        optBtn.MouseButton1Click:Connect(function()
            btn.Text = opt
            optionFrame.Visible = false
            if callback then callback(opt) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        optionFrame.Visible = open
    end)
end

-- Add TextBox
function SlayLib:AddTextBox(tab,name,callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-20,0,40)
    frame.Position = UDim2.new(0,10,0,#tab:GetChildren()*45)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.1
    frame.Parent = tab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = SlayLib.Theme.Accent
    stroke.Thickness = 1
    stroke.Parent = frame

    createLabel(name,frame,UDim2.new(0,10,0,0),UDim2.new(0.4,0,1,0))
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.55,0,0.7,0)
    textBox.Position = UDim2.new(0.45,0,0.15,0)
    textBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
    textBox.TextColor3 = Color3.fromRGB(255,255,255)
    textBox.PlaceholderText = "Enter text..."
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 16
    textBox.Parent = frame

    textBox.FocusLost:Connect(function(enter)
        if enter and callback then callback(textBox.Text) end
    end)
end

-- Notification
function SlayLib:Notify(text,duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0,200,0,50)
    notif.Position = UDim2.new(1,-220,1,-60 - (#self.Notifications*60))
    notif.BackgroundColor3 = self.Theme.Primary
    notif.BackgroundTransparency = 0.2
    notif.Parent = PlayerGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Accent
    stroke.Thickness = 1
    stroke.Parent = notif

    local label = createLabel(text,notif,UDim2.new(0,10,0,0),UDim2.new(1,-20,1,0))
    table.insert(self.Notifications,notif)

    task.delay(duration,function()
        notif:Destroy()
        table.remove(self.Notifications,1)
    end)
end

return SlayLib