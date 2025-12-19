--[[
    ================================================================================
    SLAYLIB X - PREMIER CROSS-PLATFORM INTERFACE
    ================================================================================
    - รองรับ: PC / Mobile (Scaling & Touch Friendly)
    - ฟีเจอร์: 
        * Circular Toggle Button (ลากได้ + มีโลโก้)
        * SlayLib Notification System (แบ่งประเภท Success, Info, Warning, Error)
        * Theme Switching Engine
        * Drag System (รองรับทั้งเมาส์และนิ้วสัมผัส)
        * Mobile Optimization (ขนาดกะทัดรัดแต่กดง่าย)
    ================================================================================
]]

local SlayLib = {
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(10, 10, 10),
        Sidebar = Color3.fromRGB(15, 15, 15),
        Element = Color3.fromRGB(22, 22, 22),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(40, 40, 40),
        Success = Color3.fromRGB(80, 255, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(80, 180, 255)
    },
    Icons = {
        Logo = "rbxassetid://13589839447", -- ใส่ ID โโลโก้คุณตรงนี้
        Success = "rbxassetid://10134203511",
        Warning = "rbxassetid://10134199120",
        Error = "rbxassetid://10134198184",
        Info = "rbxassetid://10134202165"
    }
}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

--// Utility Functions
local function Tween(obj, goal, time, style, dir)
    local info = TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

local function MakeDraggable(UIElement, DragHandle)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local Delta = input.Position - DragStart
        UIElement.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = UIElement.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
end

--// Notification System
function SlayLib:Notify(Config)
    Config = Config or {Title = "Notification", Content = "Message", Type = "Info", Duration = 5}
    
    local NotifyHolder = CoreGui:FindFirstChild("SlayNotifyHolder")
    if not NotifyHolder then
        NotifyHolder = Instance.new("Frame")
        NotifyHolder.Name = "SlayNotifyHolder"
        NotifyHolder.Size = UDim2.new(0, 300, 1, 0)
        NotifyHolder.Position = UDim2.new(1, -310, 0, 20)
        NotifyHolder.BackgroundTransparency = 1
        NotifyHolder.Parent = CoreGui
        local List = Instance.new("UIListLayout", NotifyHolder)
        List.VerticalAlignment = "Top"
        List.Padding = UDim.new(0, 10)
    end

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 0) -- Start small for animation
    Notif.BackgroundColor3 = SlayLib.Theme.Sidebar
    Notif.BorderSizePixel = 0
    Notif.ClipsDescendants = true
    Notif.Parent = NotifyHolder
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Notif)
    Stroke.Color = SlayLib.Theme[Config.Type] or SlayLib.Theme.MainColor
    Stroke.Thickness = 1.2

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 10, 0, 13)
    Icon.Image = SlayLib.Icons[Config.Type] or SlayLib.Icons.Info
    Icon.ImageColor3 = SlayLib.Theme[Config.Type] or SlayLib.Theme.MainColor
    Icon.BackgroundTransparency = 1
    Icon.Parent = Notif

    local Title = Instance.new("TextLabel")
    Title.Text = Config.Title
    Title.Size = UDim2.new(1, -50, 0, 20)
    Title.Position = UDim2.new(0, 40, 0, 5)
    Title.Font = "GothamBold"
    Title.TextSize = 14
    Title.TextColor3 = SlayLib.Theme.Text
    Title.TextXAlignment = "Left"
    Title.BackgroundTransparency = 1
    Title.Parent = Notif

    local Content = Instance.new("TextLabel")
    Content.Text = Config.Content
    Content.Size = UDim2.new(1, -50, 0, 20)
    Content.Position = UDim2.new(0, 40, 0, 22)
    Content.Font = "Gotham"
    Content.TextSize = 12
    Content.TextColor3 = SlayLib.Theme.TextSecondary
    Content.TextXAlignment = "Left"
    Content.BackgroundTransparency = 1
    Content.Parent = Notif

    Tween(Notif, {Size = UDim2.new(1, 0, 0, 50)}, 0.4)
    
    task.delay(Config.Duration, function()
        Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1}, 0.4)
        task.wait(0.4)
        Notif:Destroy()
    end)
end

--// Window Core
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib X"}
    
    local Window = {Enabled = true, CurrentTab = nil}

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "SlayLib_X"
    MainGui.Parent = CoreGui
    MainGui.IgnoreGuiInset = true

    -- Circular Toggle Button (Mobile Friendly)
    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Name = "SlayToggle"
    ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
    ToggleBtn.BackgroundColor3 = SlayLib.Theme.MainColor
    ToggleBtn.Parent = MainGui
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    local ToggleIcon = Instance.new("ImageLabel", ToggleBtn)
    ToggleIcon.Size = UDim2.new(0, 30, 0, 30)
    ToggleIcon.Position = UDim2.new(0.5, -15, 0.5, -15)
    ToggleIcon.Image = SlayLib.Icons.Logo
    ToggleIcon.BackgroundTransparency = 1
    local ToggleClick = Instance.new("TextButton", ToggleBtn)
    ToggleClick.Size = UDim2.new(1, 0, 1, 0)
    ToggleClick.BackgroundTransparency = 1
    ToggleClick.Text = ""

    -- Main Container (Optimized for Mobile)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 380) -- ขนาดพอดีมือถือ
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = SlayLib.Theme.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MainGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = SlayLib.Theme.Stroke
    MainStroke.Thickness = 1.5

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = SlayLib.Theme.Sidebar
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local TitleLogo = Instance.new("ImageLabel", Sidebar)
    TitleLogo.Size = UDim2.new(0, 25, 0, 25)
    TitleLogo.Position = UDim2.new(0, 15, 0, 15)
    TitleLogo.Image = SlayLib.Icons.Logo
    TitleLogo.BackgroundTransparency = 1

    local TitleText = Instance.new("TextLabel", Sidebar)
    TitleText.Text = "SlayLib X"
    TitleText.Position = UDim2.new(0, 45, 0, 15)
    TitleText.Size = UDim2.new(0, 100, 0, 25)
    TitleText.Font = "GothamBold"
    TitleText.TextSize = 18
    TitleText.TextColor3 = SlayLib.Theme.Text
    TitleText.TextXAlignment = "Left"
    TitleText.BackgroundTransparency = 1

    local TabScroll = Instance.new("ScrollingFrame", Sidebar)
    TabScroll.Size = UDim2.new(1, -10, 1, -60)
    TabScroll.Position = UDim2.new(0, 5, 0, 55)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabScroll)
    TabList.Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 180, 0, 15)
    PageContainer.Size = UDim2.new(1, -195, 1, -30)
    PageContainer.BackgroundTransparency = 1

    -- Toggle Logic
    ToggleClick.MouseButton1Click:Connect(function()
        Window.Enabled = not Window.Enabled
        if Window.Enabled then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 380)}, 0.4, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.4)
            task.delay(0.4, function() MainFrame.Visible = false end)
        end
    end)

    function Window:CreateTab(Name)
        local Tab = {}
        local TabBtn = Instance.new("TextButton", TabScroll)
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "      " .. Name
        TabBtn.Font = "GothamMedium"
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = SlayLib.Theme.TextSecondary
        TabBtn.TextXAlignment = "Left"
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = SlayLib.Theme.MainColor
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.1, TextColor3 = SlayLib.Theme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.1
            TabBtn.TextColor3 = SlayLib.Theme.MainColor
        end

        function Tab:CreateSection(Title)
            local Section = {}
            local SectLbl = Instance.new("TextLabel", Page)
            SectLbl.Text = Title:upper()
            SectLbl.Size = UDim2.new(1, 0, 0, 20)
            SectLbl.Font = "GothamBold"
            SectLbl.TextSize = 11
            SectLbl.TextColor3 = SlayLib.Theme.MainColor
            SectLbl.BackgroundTransparency = 1
            SectLbl.TextXAlignment = "Left"

            -- TOGGLE
            function Section:CreateToggle(Props, Flag)
                Props = Props or {Name = "Toggle", Callback = function() end}
                local State = false
                local TglFrame = Instance.new("Frame", Page)
                TglFrame.Size = UDim2.new(1, -10, 0, 45)
                TglFrame.BackgroundColor3 = SlayLib.Theme.Element
                Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 7)
                
                local Lbl = Instance.new("TextLabel", TglFrame)
                Lbl.Text = "  " .. Props.Name
                Lbl.Size = UDim2.new(1, 0, 1, 0)
                Lbl.Font = "GothamMedium"
                Lbl.TextSize = 14
                Lbl.TextColor3 = SlayLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1

                local Switch = Instance.new("Frame", TglFrame)
                Switch.Size = UDim2.new(0, 40, 0, 20)
                Switch.Position = UDim2.new(1, -50, 0.5, -10)
                Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local Dot = Instance.new("Frame", Switch)
                Dot.Size = UDim2.new(0, 14, 0, 14)
                Dot.Position = UDim2.new(0, 3, 0.5, -7)
                Dot.BackgroundColor3 = Color3.new(1, 1, 1)
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

                local Click = Instance.new("TextButton", TglFrame)
                Click.Size = UDim2.new(1, 0, 1, 0)
                Click.BackgroundTransparency = 1
                Click.Text = ""

                Click.MouseButton1Click:Connect(function()
                    State = not State
                    Tween(Switch, {BackgroundColor3 = State and SlayLib.Theme.MainColor or Color3.fromRGB(50, 50, 50)}, 0.3)
                    Tween(Dot, {Position = State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.3)
                    Props.Callback(State)
                    if Flag then SlayLib.Flags[Flag] = State end
                end)
            end

            -- BUTTON
            function Section:CreateButton(Props)
                local Btn = Instance.new("TextButton", Page)
                Btn.Size = UDim2.new(1, -10, 0, 40)
                Btn.BackgroundColor3 = SlayLib.Theme.Element
                Btn.Text = Props.Name
                Btn.Font = "GothamMedium"
                Btn.TextSize = 14
                Btn.TextColor3 = SlayLib.Theme.Text
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 7)
                Btn.MouseButton1Click:Connect(Props.Callback)
            end

            -- SLIDER
            function Section:CreateSlider(Props, Flag)
                Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Callback = function() end}
                local Value = Props.Def
                local Frame = Instance.new("Frame", Page)
                Frame.Size = UDim2.new(1, -10, 0, 60)
                Frame.BackgroundColor3 = SlayLib.Theme.Element
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)

                local Lbl = Instance.new("TextLabel", Frame)
                Lbl.Text = "  " .. Props.Name
                Lbl.Size = UDim2.new(1, 0, 0, 30)
                Lbl.Font = "GothamMedium"
                Lbl.TextColor3 = SlayLib.Theme.Text
                Lbl.BackgroundTransparency = 1
                Lbl.TextXAlignment = "Left"

                local ValLbl = Instance.new("TextLabel", Frame)
                ValLbl.Text = tostring(Value)
                ValLbl.Size = UDim2.new(1, -15, 0, 30)
                ValLbl.Font = "Code"
                ValLbl.TextColor3 = SlayLib.Theme.MainColor
                ValLbl.TextXAlignment = "Right"
                ValLbl.BackgroundTransparency = 1

                local Rail = Instance.new("Frame", Frame)
                Rail.Size = UDim2.new(1, -30, 0, 5)
                Rail.Position = UDim2.new(0, 15, 0, 45)
                Rail.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Instance.new("UICorner", Rail)

                local Fill = Instance.new("Frame", Rail)
                Fill.Size = UDim2.new((Value-Props.Min)/(Props.Max-Props.Min), 0, 1, 0)
                Fill.BackgroundColor3 = SlayLib.Theme.MainColor
                Instance.new("UICorner", Fill)

                local Dragging = false
                local function Update()
                    local Pos = math.clamp((Mouse.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
                    local NewVal = math.floor(Props.Min + (Props.Max - Props.Min) * Pos)
                    Fill.Size = UDim2.new(Pos, 0, 1, 0)
                    ValLbl.Text = tostring(NewVal)
                    Props.Callback(NewVal)
                    if Flag then SlayLib.Flags[Flag] = NewVal end
                end

                Frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                RunService.RenderStepped:Connect(function() if Dragging then Update() end end)
            end

            -- DROPDOWN
            function Section:CreateDropdown(Props, Flag)
                Props = Props or {Name = "Dropdown", Options = {}, Callback = function() end}
                local Open = false
                local Frame = Instance.new("Frame", Page)
                Frame.Size = UDim2.new(1, -10, 0, 40)
                Frame.BackgroundColor3 = SlayLib.Theme.Element
                Frame.ClipsDescendants = true
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)

                local Btn = Instance.new("TextButton", Frame)
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.BackgroundTransparency = 1
                Btn.Text = "  " .. Props.Name
                Btn.Font = "GothamMedium"
                Btn.TextColor3 = SlayLib.Theme.Text
                Btn.TextXAlignment = "Left"

                local Container = Instance.new("Frame", Frame)
                Container.Position = UDim2.new(0, 0, 0, 40)
                Container.Size = UDim2.new(1, 0, 0, #Props.Options * 30)
                Container.BackgroundTransparency = 1
                Instance.new("UIListLayout", Container)

                for _, v in pairs(Props.Options) do
                    local Opt = Instance.new("TextButton", Container)
                    Opt.Size = UDim2.new(1, 0, 0, 30)
                    Opt.BackgroundTransparency = 1
                    Opt.Text = "      " .. v
                    Opt.Font = "Gotham"
                    Opt.TextColor3 = SlayLib.Theme.TextSecondary
                    Opt.TextXAlignment = "Left"
                    Opt.MouseButton1Click:Connect(function()
                        Btn.Text = "  " .. Props.Name .. " : " .. v
                        Open = false
                        Tween(Frame, {Size = UDim2.new(1, -10, 0, 40)}, 0.3)
                        Props.Callback(v)
                    end)
                end

                Btn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Tween(Frame, {Size = Open and UDim2.new(1, -10, 0, 40 + (#Props.Options * 30)) or UDim2.new(1, -10, 0, 40)}, 0.4)
                end)
            end

            return Section
        end
        return Tab
    end

    -- Draggable Elements
    MakeDraggable(MainFrame, Sidebar)
    MakeDraggable(ToggleBtn, ToggleBtn)
    
    return Window
end

-- ระบบเปลี่ยนธีม (Theme Engine)
function SlayLib:SetTheme(NewTheme)
    for i, v in pairs(NewTheme) do
        if SlayLib.Theme[i] then
            SlayLib.Theme[i] = v
        end
    end
end

return SlayLib
