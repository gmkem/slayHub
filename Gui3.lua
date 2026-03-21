--[[
    SlayLib - Ultimate Custom Edition V3
    "The Peak of Roblox UI Libraries"
    - Fully Draggable (Main & Toggle Button)
    - Mobile Support (100%)
    - Integrated Notification System
    - Dynamic Content Scaling
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SlayLib = {}
SlayLib.__index = SlayLib

-- Configuration & Themes
local Theme = {
    Main = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(0, 160, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 155),
    Stroke = Color3.fromRGB(60, 60, 70),
    Success = Color3.fromRGB(46, 204, 113),
}

-- // Utility Functions \\ --
local function AddDecor(obj, radius, strokeColor, strokeTrans)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
    
    if strokeColor then
        local stroke = Instance.new("UIStroke")
        stroke.Color = strokeColor
        stroke.Thickness = 1
        stroke.Transparency = strokeTrans or 0
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = obj
        return stroke
    end
end

local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.QuadOut), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- // Notification System \\ --
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "SlayNotif"
NotifGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 1, 0)
NotifContainer.Position = UDim2.new(1, -260, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local NotifList = Instance.new("UIListLayout")
NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
NotifList.Padding = UDim.new(0, 10)
NotifList.Parent = NotifContainer

function SlayLib:Notify(title, desc, duration)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Theme.Main
    frame.BackgroundTransparency = 0.2
    frame.Parent = NotifContainer
    AddDecor(frame, 8, Theme.Accent)
    
    local t = Instance.new("TextLabel")
    t.Text = " " .. title
    t.Size = UDim2.new(1, 0, 0, 25)
    t.TextColor3 = Theme.Accent
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.BackgroundTransparency = 1
    t.Parent = frame
    
    local d = Instance.new("TextLabel")
    d.Text = " " .. desc
    d.Size = UDim2.new(1, 0, 1, -25)
    d.Position = UDim2.fromOffset(0, 25)
    d.TextColor3 = Theme.Text
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.BackgroundTransparency = 1
    d.Parent = frame

    frame.Position = UDim2.fromScale(1.5, 0)
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.BackOut), {Position = UDim2.fromScale(0, 0)}):Play()
    
    task.delay(duration or 3, function()
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.QuadIn), {Position = UDim2.fromScale(1.5, 0)}):Play()
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- // Library Constructor \\ --
function SlayLib.new(hubName)
    local self = setmetatable({}, SlayLib)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SlayLib_Ultimate"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    self.Gui = ScreenGui

    -- Open/Close Button (Toggle Button)
    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name = "SlayToggle"
    ToggleBtn.Size = UDim2.fromOffset(45, 45)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
    ToggleBtn.BackgroundColor3 = Theme.Main
    ToggleBtn.Image = "rbxassetid://13160451101" -- Ninja Icon
    ToggleBtn.Parent = ScreenGui
    AddDecor(ToggleBtn, 22.5, Theme.Accent)
    MakeDraggable(ToggleBtn)

    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(580, 380)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    AddDecor(MainFrame, 10, Theme.Stroke)
    MakeDraggable(MainFrame)

    -- Handle Toggle Click
    ToggleBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        local targetScale = MainFrame.Visible and 1 or 0
        MainFrame:TweenSize(MainFrame.Visible and UDim2.fromOffset(580, 380) or UDim2.fromOffset(0,0), "Out", "Quart", 0.3, true)
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 165, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Secondary
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.Parent = MainFrame
    AddDecor(Sidebar, 10)

    local Title = Instance.new("TextLabel")
    Title.Text = hubName:upper()
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.Parent = Sidebar

    -- Tab Scrolling
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -130)
    TabScroll.Position = UDim2.fromOffset(0, 60)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = TabScroll

    -- User Status (Bottom)
    local UserInfo = Instance.new("Frame")
    UserInfo.Size = UDim2.new(0.9, 0, 0, 50)
    UserInfo.Position = UDim2.new(0.05, 0, 1, -60)
    UserInfo.BackgroundColor3 = Theme.Main
    UserInfo.BackgroundTransparency = 0.4
    UserInfo.Parent = Sidebar
    AddDecor(UserInfo, 8, Theme.Stroke)

    local UserImage = Instance.new("ImageLabel")
    UserImage.Size = UDim2.fromOffset(36, 36)
    UserImage.Position = UDim2.fromOffset(7, 7)
    UserImage.Image = game:GetService("Players"):GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    UserImage.BackgroundTransparency = 1
    UserImage.Parent = UserInfo
    AddDecor(UserImage, 18)

    local UserName = Instance.new("TextLabel")
    UserName.Text = LocalPlayer.DisplayName
    UserName.Size = UDim2.new(1, -55, 1, 0)
    UserName.Position = UDim2.fromOffset(50, 0)
    UserName.TextColor3 = Theme.Text
    UserName.TextSize = 12
    UserName.Font = Enum.Font.GothamSemibold
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.BackgroundTransparency = 1
    UserName.Parent = UserInfo

    -- Container for Pages
    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, -175, 1, -20)
    Pages.Position = UDim2.fromOffset(170, 10)
    Pages.BackgroundTransparency = 1
    Pages.Parent = MainFrame

    self.MainFrame = MainFrame
    self.Pages = Pages
    self.TabScroll = TabScroll

    return self
end

function SlayLib:CreateTab(name)
    local tab = {}
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.9, 0, 0, 38)
    TabBtn.BackgroundColor3 = Theme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Theme.TextDark
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    TabBtn.Parent = self.TabScroll
    AddDecor(TabBtn, 6)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.fromScale(1, 1)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Parent = self.Pages
    
    local PageList = Instance.new("UIListLayout")
    PageList.Padding = UDim.new(0, 10)
    PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageList.Parent = Page

    -- Auto-resize Canvas
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0, PageList.AbsoluteContentSize.Y + 20)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Pages:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        for _, v in pairs(self.TabScroll:GetChildren()) do
            if v:IsA("TextButton") then 
                TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}):Play()
            end
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, TextColor3 = Theme.Text}):Play()
    end)

    if #self.TabScroll:GetChildren() == 2 then
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.TextColor3 = Theme.Text
    end

    -- // Elements \\ --

    function tab:CreateButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.96, 0, 0, 40)
        btn.BackgroundColor3 = Theme.Secondary
        btn.BackgroundTransparency = 0.4
        btn.Text = "  " .. text
        btn.TextColor3 = Theme.Text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = Page
        AddDecor(btn, 6, Theme.Stroke, 0.5)

        btn.MouseButton1Click:Connect(function()
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.fromOffset(0, 0)
            ripple.Position = UDim2.fromOffset(Mouse.X - btn.AbsolutePosition.X, Mouse.Y - btn.AbsolutePosition.Y)
            ripple.BackgroundColor3 = Theme.Text
            ripple.BackgroundTransparency = 0.8
            ripple.Parent = btn
            AddDecor(ripple, 150)
            TweenService:Create(ripple, TweenInfo.new(0.5), {Size = UDim2.fromOffset(350, 350), BackgroundTransparency = 1}):Play()
            task.delay(0.5, function() ripple:Destroy() end)
            callback()
        end)
    end

    function tab:CreateToggle(text, default, callback)
        local toggled = default or false
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.96, 0, 0, 42)
        f.BackgroundColor3 = Theme.Secondary
        f.BackgroundTransparency = 0.4
        f.Parent = Page
        AddDecor(f, 6, Theme.Stroke, 0.5)

        local l = Instance.new("TextLabel")
        l.Text = "  " .. text
        l.Size = UDim2.fromScale(1, 1)
        l.BackgroundTransparency = 1
        l.TextColor3 = Theme.Text
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = Enum.Font.Gotham
        l.Parent = f

        local b = Instance.new("Frame")
        b.Size = UDim2.fromOffset(40, 20)
        b.Position = UDim2.new(1, -50, 0.5, -10)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        b.Parent = f
        AddDecor(b, 10, Theme.Stroke)

        local i = Instance.new("Frame")
        i.Size = UDim2.fromOffset(16, 16)
        i.Position = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
        i.BackgroundColor3 = toggled and Theme.Accent or Theme.TextDark
        i.Parent = b
        AddDecor(i, 8)

        f.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggled = not toggled
                local targetX = toggled and 22 or 2
                TweenService:Create(i, TweenInfo.new(0.25, Enum.EasingStyle.BackOut), {Position = UDim2.fromOffset(targetX, 2), BackgroundColor3 = toggled and Theme.Accent or Theme.TextDark}):Play()
                callback(toggled)
            end
        end)
    end

    function tab:CreateSlider(text, min, max, default, callback)
        local s = Instance.new("Frame")
        s.Size = UDim2.new(0.96, 0, 0, 60)
        s.BackgroundColor3 = Theme.Secondary
        s.BackgroundTransparency = 0.4
        s.Parent = Page
        AddDecor(s, 6, Theme.Stroke, 0.5)

        local l = Instance.new("TextLabel")
        l.Text = "  " .. text
        l.Size = UDim2.new(1, 0, 0, 35)
        l.BackgroundTransparency = 1
        l.TextColor3 = Theme.Text
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = Enum.Font.Gotham
        l.Parent = s

        local vL = Instance.new("TextLabel")
        vL.Text = tostring(default) .. " "
        vL.Size = UDim2.new(1, 0, 0, 35)
        vL.BackgroundTransparency = 1
        vL.TextColor3 = Theme.Accent
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.Font = Enum.Font.GothamBold
        vL.Parent = s

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0.92, 0, 0, 6)
        bar.Position = UDim2.new(0.04, 0, 0, 45)
        bar.BackgroundColor3 = Color3.fromRGB(30,30,35)
        bar.Parent = s
        AddDecor(bar, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale(math.clamp((default - min) / (max - min), 0, 1), 1)
        fill.BackgroundColor3 = Theme.Accent
        fill.Parent = bar
        AddDecor(fill, 3)

        local function update()
            local p = math.clamp((Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * p)
            fill.Size = UDim2.fromScale(p, 1)
            vL.Text = tostring(val) .. " "
            callback(val)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local conn
                conn = RunService.RenderStepped:Connect(update)
                UserInputService.InputEnded:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                        conn:Disconnect()
                    end
                end)
            end
        end)
    end

    function tab:CreateDropdown(text, options, callback)
        local expanded = false
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0.96, 0, 0, 40)
        d.BackgroundColor3 = Theme.Secondary
        d.BackgroundTransparency = 0.4
        d.ClipsDescendants = true
        d.Parent = Page
        AddDecor(d, 6, Theme.Stroke, 0.5)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundTransparency = 1
        btn.Text = "  " .. text .. " : " .. (options[1] or "None")
        btn.TextColor3 = Theme.Text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.Parent = d

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, #options * 32)
        container.Position = UDim2.fromOffset(0, 40)
        container.BackgroundTransparency = 1
        container.Parent = d
        Instance.new("UIListLayout", container)

        btn.MouseButton1Click:Connect(function()
            expanded = not expanded
            TweenService:Create(d, TweenInfo.new(0.4, Enum.EasingStyle.QuartOut), {Size = expanded and UDim2.new(0.96, 0, 0, 40 + (#options * 32)) or UDim2.fromOffset(d.AbsoluteSize.X, 40)}):Play()
        end)

        for _, v in pairs(options) do
            local o = Instance.new("TextButton")
            o.Size = UDim2.new(1, 0, 0, 32)
            o.BackgroundTransparency = 1
            o.Text = "      " .. v
            o.TextColor3 = Theme.TextDark
            o.TextXAlignment = Enum.TextXAlignment.Left
            o.Font = Enum.Font.Gotham
            o.Parent = container
            o.MouseButton1Click:Connect(function()
                btn.Text = "  " .. text .. " : " .. v
                expanded = false
                TweenService:Create(d, TweenInfo.new(0.4), {Size = UDim2.new(0.96, 0, 0, 40)}):Play()
                callback(v)
            end)
        end
    end

    return tab
end

return SlayLib
