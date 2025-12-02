-- SlayLib GUI Library
-- Author: You
-- สไตล์: หรูหรา, รองรับมือถือ, draggable, เปิด/ปิด UI

local SlayLib = {}
SlayLib.__index = SlayLib

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme default
SlayLib.Theme = {
    Primary = Color3.fromRGB(255, 105, 180), -- สีชมพู
    Secondary = Color3.fromRGB(50,50,50),
    TextColor = Color3.fromRGB(255,255,255),
}

-- Create main window
function SlayLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SlayLibUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,400,0,500)
    MainFrame.Position = UDim2.new(0.5,-200,0.5,-250)
    MainFrame.BackgroundColor3 = self.Theme.Secondary
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Name = "MainFrame"

    -- Draggable
    MainFrame.Active = true
    MainFrame.Draggable = true

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,0,0,50)
    TitleLabel.BackgroundColor3 = self.Theme.Primary
    TitleLabel.Text = title or "SlayLib"
    TitleLabel.TextColor3 = self.Theme.TextColor
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 24
    TitleLabel.Parent = MainFrame

    -- Tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1,0,1,-50)
    TabContainer.Position = UDim2.new(0,0,0,50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    -- Return window object
    local window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        Tabs = {},
        Notifications = {},
    }
    setmetatable(window, self)
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
function SlayLib:AddToggle(tab, name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    ToggleFrame.BackgroundTransparency = 0.2
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
    ToggleFrame.Position = UDim2.new(0,10,0, #tab:GetChildren()*45)
    ToggleFrame.Parent = tab

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7,0,1,0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 18
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.25,0,0.6,0)
    Button.Position = UDim2.new(0.7,0,0.2,0)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.BackgroundColor3 = Color3.fromRGB(100,100,100)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 16
    Button.Parent = ToggleFrame

    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        Button.Text = toggled and "ON" or "OFF"
        if callback then callback(toggled) end
    end)
end

-- Notification
function SlayLib:Notify(text, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0,200,0,50)
    notif.Position = UDim2.new(1,-220,1,-60 - (#self.Notifications*60))
    notif.BackgroundColor3 = self.Theme.Primary
    notif.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = notif

    table.insert(self.Notifications, notif)

    task.delay(duration, function()
        notif:Destroy()
        table.remove(self.Notifications,1)
    end)
end

return SlayLib