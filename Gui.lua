-- SlayLib Full Mobile GUI (ปรับแก้)
local SlayLib = {}
SlayLib.__index = SlayLib

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme
SlayLib.Theme = {
    Primary = Color3.fromRGB(255,105,180),
    Secondary = Color3.fromRGB(40,40,40),
    Accent = Color3.fromRGB(255,182,193),
    TextColor = Color3.fromRGB(255,255,255)
}

-- Helper
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

-- Add Toggle Switch
function SlayLib:AddToggle(tab,name,callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-40,0,40)
    frame.Position = UDim2.new(0,20,0,#tab:GetChildren()*50)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.1
    frame.Parent = tab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = SlayLib.Theme.Accent
    stroke.Thickness = 1
    stroke.Parent = frame

    -- Label
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.7,0,1,0)
    label.Position = UDim2.new(0,10,0,0)
    label.TextColor3 = SlayLib.Theme.TextColor
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Switch
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0,50,0,25)
    switchBg.Position = UDim2.new(0.75,0,0.5,-12)
    switchBg.BackgroundColor3 = Color3.fromRGB(100,100,100)
    switchBg.Parent = frame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1,0)
    switchCorner.Parent = switchBg

    local switchButton = Instance.new("Frame")
    switchButton.Size = UDim2.new(0,23,0,23)
    switchButton.Position = UDim2.new(0,1,0,1)
    switchButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
    switchButton.Parent = switchBg

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1,0)
    buttonCorner.Parent = switchButton

    -- Toggle logic
    local toggled = false
    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            local goal = {}
            if toggled then
                goal.Position = UDim2.new(1,-24,0,1)
                switchBg.BackgroundColor3 = SlayLib.Theme.Primary
            else
                goal.Position = UDim2.new(0,1,0,1)
                switchBg.BackgroundColor3 = Color3.fromRGB(100,100,100)
            end
            TweenService:Create(switchButton,TweenInfo.new(0.2),goal):Play()
            if callback then callback(toggled) end
        end
    end)
end

-- สามารถปรับ Slider, Dropdown, TextBox ให้มี spacing แบบเดียวกันได้
-- ตัวอย่าง Notification
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