-- SlayLib v1.0 (Full GUI Library)
-- Author: You
-- สไตล์: หรูหรา, draggable, เปิด/ปิด UI, mobile friendly

local SlayLib = {}
SlayLib.__index = SlayLib

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Default Theme
SlayLib.Theme = {
    Primary = Color3.fromRGB(255,105,180),
    Secondary = Color3.fromRGB(35,35,35),
    TextColor = Color3.fromRGB(255,255,255),
    Accent = Color3.fromRGB(255,182,193)
}

-- Helper Functions
local function createLabel(text,parent,size,position,font,txtSize)
    local lbl = Instance.new("TextLabel")
    lbl.Size = size
    lbl.Position = position
    lbl.Text = text
    lbl.TextColor3 = SlayLib.Theme.TextColor
    lbl.BackgroundTransparency = 1
    lbl.Font = font or Enum.Font.Gotham
    lbl.TextSize = txtSize or 18
    lbl.Parent = parent
    return lbl
end

local function createButton(text,parent,size,pos)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = SlayLib.Theme.Accent
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = parent
    return btn
end

-- Create Window
function SlayLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SlayLibUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,420,0,520)
    MainFrame.Position = UDim2.new(0.5,-210,0.5,-260)
    MainFrame.BackgroundColor3 = self.Theme.Secondary
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Name = "MainFrame"
    MainFrame.Active = true
    MainFrame.Draggable = true

    -- Title
    local TitleLabel = createLabel(title or "SlayLib",MainFrame,UDim2.new(1,0,0,50),UDim2.new(0,0,0,0),Enum.Font.GothamBold,24)
    TitleLabel.BackgroundColor3 = self.Theme.Primary
    TitleLabel.BackgroundTransparency = 0

    -- Tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1,0,1,-50)
    TabContainer.Position = UDim2.new(0,0,0,50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    -- UI visibility toggle
    local Visible = true
    local toggleBtn = createButton("Toggle UI",ScreenGui,UDim2.new(0,100,0,30),UDim2.new(0,10,0,10))
    toggleBtn.MouseButton1Click:Connect(function()
        Visible = not Visible
        MainFrame.Visible = Visible
    end)

    local window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        Tabs = {},
        Notifications = {},
        Visibility = Visible
    }
    setmetatable(window,self)
    return window
end

-- Add Tab
function SlayLib:AddTab(window, tabName)
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,0,1,0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = true
    TabFrame.Parent = window.TabContainer
    window.Tabs[tabName] = TabFrame
    return TabFrame
end

-- Add Toggle
function SlayLib:AddToggle(tab,name,callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1,-20,0,40)
    ToggleFrame.BackgroundTransparency = 0.2
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
    ToggleFrame.Position = UDim2.new(0,10,0,#tab:GetChildren()*45)
    ToggleFrame.Parent = tab

    local Label = createLabel(name,ToggleFrame,UDim2.new(0.7,0,1,0),UDim2.new(0,0,0,0))
    local Button = createButton("OFF",ToggleFrame,UDim2.new(0.25,0,0.6,0),UDim2.new(0.7,0,0.2,0))
    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        Button.Text = toggled and "ON" or "OFF"
        if callback then callback(toggled) end
    end)
end

-- Add Slider
function SlayLib:AddSlider(tab,name,min,max,default,callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1,-20,0,50)
    SliderFrame.Position = UDim2.new(0,10,0,#tab:GetChildren()*55)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
    SliderFrame.Parent = tab

    createLabel(name,SliderFrame,UDim2.new(0.5,0,0.5,0),UDim2.new(0,5,0,5))

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0.6,0,0.2,0)
    Bar.Position = UDim2.new(0.35,0,0.4,0)
    Bar.BackgroundColor3 = self.Theme.Accent
    Bar.Parent = SliderFrame

    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local relX = math.clamp(mouse.X - SliderFrame.AbsolutePosition.X,0,SliderFrame.AbsoluteSize.X*0.6)
            Bar.Size = UDim2.new(0,relX,0.2,0)
            local val = math.floor((relX/(SliderFrame.AbsoluteSize.X*0.6))*(max-min)+min)
            if callback then callback(val) end
        end
    end)
end

-- Add Dropdown
function SlayLib:AddDropdown(tab,name,options,callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1,-20,0,40)
    DropFrame.Position = UDim2.new(0,10,0,#tab:GetChildren()*45)
    DropFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
    DropFrame.Parent = tab

    local Label = createLabel(name,DropFrame,UDim2.new(0.6,0,1,0),UDim2.new(0,5,0,0))
    local Btn = createButton("Select",DropFrame,UDim2.new(0.35,0,0.7,0),UDim2.new(0.65,0,0.15,0))
    local open = false

    local OptionFrame = Instance.new("Frame")
    OptionFrame.Size = UDim2.new(0.35,0,#options*30,0)
    OptionFrame.Position = UDim2.new(0.65,0,1,0)
    OptionFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    OptionFrame.Visible = false
    OptionFrame.Parent = DropFrame

    for i,opt in ipairs(options) do
        local OptBtn = createButton(opt,OptionFrame,UDim2.new(1,0,0,30),UDim2.new(0,0,0,(i-1)*30))
        OptBtn.MouseButton1Click:Connect(function()
            Btn.Text = opt
            OptionFrame.Visible = false
            if callback then callback(opt) end
        end)
    end

    Btn.MouseButton1Click:Connect(function()
        open = not open
        OptionFrame.Visible = open
    end)
end

-- Add TextBox
function SlayLib:AddTextBox(tab,name,callback)
    local BoxFrame = Instance.new("Frame")
    BoxFrame.Size = UDim2.new(1,-20,0,40)
    BoxFrame.Position = UDim2.new(0,10,0,#tab:GetChildren()*45)
    BoxFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
    BoxFrame.Parent = tab

    createLabel(name,BoxFrame,UDim2.new(0.4,0,1,0),UDim2.new(0,5,0,0))
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.55,0,0.7,0)
    TextBox.Position = UDim2.new(0.45,0,0.15,0)
    TextBox.BackgroundColor3 = Color3.fromRGB(80,80,80)
    TextBox.TextColor3 = Color3.fromRGB(255,255,255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 16
    TextBox.PlaceholderText = "Enter text..."
    TextBox.Parent = BoxFrame

    TextBox.FocusLost:Connect(function(enter)
        if enter and callback then callback(TextBox.Text) end
    end)
end

-- Notifications
function SlayLib:Notify(text,duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0,200,0,50)
    notif.Position = UDim2.new(1,-220,1,-60 - (#self.Notifications*60))
    notif.BackgroundColor3 = self.Theme.Primary
    notif.Parent = PlayerGui

    local label = createLabel(text,notif,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0))
    table.insert(self.Notifications,notif)

    task.delay(duration,function()
        notif:Destroy()
        table.remove(self.Notifications,1)
    end)
end

return SlayLib