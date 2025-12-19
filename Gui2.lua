--[[
    FluLib Interface Suite (Professional Version)
    A high-performance, script-generated UI Library 
    Inspired by Fluent Design & Luna UI
]]

local FluLib = {
    Folder = "FluLib_Configs",
    Options = {},
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(0, 120, 212),
        SecondaryMain = Color3.fromRGB(0, 100, 180),
        Background = Color3.fromRGB(15, 15, 15),
        Sidebar = Color3.fromRGB(22, 22, 22),
        Element = Color3.fromRGB(28, 28, 28),
        ElementHover = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45),
        Gradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 212)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 212))
        }
    }
}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Mouse = Players.LocalPlayer:GetMouse()

--// Utility Functions
local function Tween(obj, goal, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Exponential, dir or Enum.EasingDirection.Out), goal)
    t:Play()
    return t
end

local function MakeDraggable(TopBar, MainFrame)
    local Dragging, DragInput, DragStart, StartPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)
end

--// UI Creation Core
function FluLib:CreateWindow(Settings)
    Settings = Settings or {Name = "FluLib", Subtitle = "Interface Suite", LogoID = 0}
    
    local Window = {CurrentTab = nil, Tabs = {}, Minimized = false, Closed = false}

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "FluLib_UI"
    MainGui.Parent = CoreGui
    MainGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 650, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -240)
    MainFrame.BackgroundColor3 = FluLib.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = FluLib.Theme.Stroke
    MainStroke.Thickness = 1.2

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 210, 1, 0)
    Sidebar.BackgroundColor3 = FluLib.Theme.Sidebar
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local TitleFrame = Instance.new("Frame")
    TitleFrame.Size = UDim2.new(1, 0, 0, 70)
    TitleFrame.BackgroundTransparency = 1
    TitleFrame.Parent = Sidebar

    local Title = Instance.new("TextLabel")
    Title.Text = Settings.Name
    Title.Position = UDim2.new(0, 25, 0, 20)
    Title.Size = UDim2.new(1, -50, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = FluLib.Theme.Text
    Title.TextXAlignment = "Left"
    Title.BackgroundTransparency = 1
    Title.Parent = TitleFrame

    local Sub = Instance.new("TextLabel")
    Sub.Text = Settings.Subtitle
    Sub.Position = UDim2.new(0, 25, 0, 42)
    Sub.Size = UDim2.new(1, -50, 0, 15)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 12
    Sub.TextColor3 = FluLib.Theme.TextSecondary
    Sub.TextXAlignment = "Left"
    Sub.BackgroundTransparency = 1
    Sub.Parent = TitleFrame

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -100)
    TabScroll.Position = UDim2.new(0, 5, 0, 80)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Sidebar
    local TabList = Instance.new("UIListLayout", TabScroll)
    TabList.Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -230, 1, -30)
    Container.Position = UDim2.new(0, 220, 0, 15)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    -- Tab Logic
    function Window:CreateTab(Name, Icon)
        local Tab = {Active = false, Page = nil}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "      " .. Name
        TabBtn.Font = "GothamMedium"
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = FluLib.Theme.TextSecondary
        TabBtn.TextXAlignment = "Left"
        TabBtn.Parent = TabScroll
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = FluLib.Theme.MainColor
        Page.Parent = Container
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 15)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = FluLib.Theme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, TextColor3 = FluLib.Theme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.9
            TabBtn.TextColor3 = FluLib.Theme.MainColor
        end

        -- Section logic
        function Tab:CreateSection(SName)
            local Section = {}
            local SLbl = Instance.new("TextLabel")
            SLbl.Text = SName:upper()
            SLbl.Size = UDim2.new(1, 0, 0, 25)
            SLbl.Font = "GothamBold"
            SLbl.TextSize = 12
            SLbl.TextColor3 = FluLib.Theme.MainColor
            SLbl.BackgroundTransparency = 1
            SLbl.TextXAlignment = "Left"
            SLbl.Parent = Page

            --// ELEMENT: BUTTON
            function Section:CreateButton(Config)
                Config = Config or {Name = "Button", Callback = function() end}
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Size = UDim2.new(1, -10, 0, 45)
                BtnFrame.BackgroundColor3 = FluLib.Theme.Element
                BtnFrame.Text = "  " .. Config.Name
                BtnFrame.Font = "GothamMedium"
                BtnFrame.TextSize = 14
                BtnFrame.TextColor3 = FluLib.Theme.Text
                BtnFrame.TextXAlignment = "Left"
                BtnFrame.AutoButtonColor = false
                BtnFrame.Parent = Page
                Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 7)
                Instance.new("UIStroke", BtnFrame).Color = FluLib.Theme.Stroke

                BtnFrame.MouseButton1Down:Connect(function()
                    Tween(BtnFrame, {Size = UDim2.new(1, -15, 0, 42)}, 0.1)
                end)
                BtnFrame.MouseButton1Up:Connect(function()
                    Tween(BtnFrame, {Size = UDim2.new(1, -10, 0, 45)}, 0.2, Enum.EasingStyle.Back)
                    Config.Callback()
                end)
            end

            --// ELEMENT: TOGGLE
            function Section:CreateToggle(Config, Flag)
                Config = Config or {Name = "Toggle", CurrentValue = false, Callback = function() end}
                local Tgl = {Value = Config.CurrentValue}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 50)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                Instance.new("UIStroke", Frame).Color = FluLib.Theme.Stroke

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 1, 0)
                Lbl.Font = "GothamMedium"
                Lbl.TextSize = 14
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 44, 0, 22)
                Switch.Position = UDim2.new(1, -54, 0.5, -11)
                Switch.BackgroundColor3 = Tgl.Value and FluLib.Theme.MainColor or Color3.fromRGB(60, 60, 60)
                Switch.Parent = Frame
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 16, 0, 16)
                Circle.Position = Tgl.Value and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                Circle.BackgroundColor3 = Color3.new(1, 1, 1)
                Circle.Parent = Switch
                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

                local Click = Instance.new("TextButton")
                Click.Size = UDim2.new(1, 0, 1, 0)
                Click.BackgroundTransparency = 1
                Click.Text = ""
                Click.Parent = Frame

                local function Set(v)
                    Tgl.Value = v
                    Tween(Switch, {BackgroundColor3 = v and FluLib.Theme.MainColor or Color3.fromRGB(60, 60, 60)}, 0.3)
                    Tween(Circle, {Position = v and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}, 0.3)
                    Config.Callback(v)
                    if Flag then FluLib.Flags[Flag] = v end
                end
                Click.MouseButton1Click:Connect(function() Set(not Tgl.Value) end)
                return {Set = Set}
            end

            --// ELEMENT: SLIDER
            function Section:CreateSlider(Config, Flag)
                Config = Kwargify({Name = "Slider", Range = {0, 100}, CurrentValue = 50, Callback = function() end}, Config)
                local Sld = {Value = Config.CurrentValue}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 65)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 0, 35)
                Lbl.Font = "GothamMedium"
                Lbl.TextSize = 14
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local Val = Instance.new("TextBox")
                Val.Text = tostring(Sld.Value)
                Val.Size = UDim2.new(0, 50, 0, 25)
                Val.Position = UDim2.new(1, -60, 0, 5)
                Val.Font = "Code"
                Val.TextSize = 14
                Val.TextColor3 = FluLib.Theme.MainColor
                Val.BackgroundTransparency = 1
                Val.Parent = Frame

                local Rail = Instance.new("Frame")
                Rail.Size = UDim2.new(1, -30, 0, 5)
                Rail.Position = UDim2.new(0, 15, 0, 45)
                Rail.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Rail.Parent = Frame
                Instance.new("UICorner", Rail)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((Sld.Value - Config.Range[1]) / (Config.Range[2] - Config.Range[1]), 0, 1, 0)
                Fill.BackgroundColor3 = FluLib.Theme.MainColor
                Fill.Parent = Rail
                Instance.new("UICorner", Fill)

                local Dragging = false
                local function Update()
                    local NewPos = math.clamp((Mouse.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
                    local NewVal = math.floor(Config.Range[1] + (Config.Range[2] - Config.Range[1]) * NewPos)
                    Sld.Value = NewVal
                    Val.Text = tostring(NewVal)
                    Fill.Size = UDim2.new(NewPos, 0, 1, 0)
                    Config.Callback(NewVal)
                end
                
                Rail.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update() end end)
                UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                return {Set = function(v) 
                    local p = (v - Config.Range[1]) / (Config.Range[2] - Config.Range[1])
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    Val.Text = tostring(v)
                    Config.Callback(v)
                end}
            end

            --// ELEMENT: DROPDOWN
            function Section:CreateDropdown(Config, Flag)
                Config = Config or {Name = "Dropdown", Options = {}, MultipleOptions = false, Callback = function() end}
                local Drop = {Open = false, Selected = {}}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 45)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.ClipsDescendants = true
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                Instance.new("UIStroke", Frame).Color = FluLib.Theme.Stroke

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 45)
                Btn.BackgroundTransparency = 1
                Btn.Text = "  " .. Config.Name
                Btn.Font = "GothamMedium"
                Btn.TextSize = 14
                Btn.TextColor3 = FluLib.Theme.Text
                Btn.TextXAlignment = "Left"
                Btn.Parent = Frame

                local List = Instance.new("Frame")
                List.Position = UDim2.new(0, 0, 0, 45)
                List.Size = UDim2.new(1, 0, 0, #Config.Options * 35)
                List.BackgroundTransparency = 1
                List.Parent = Frame
                Instance.new("UIListLayout", List)

                for _, v in pairs(Config.Options) do
                    local Opt = Instance.new("TextButton")
                    Opt.Size = UDim2.new(1, 0, 0, 35)
                    Opt.BackgroundTransparency = 1
                    Opt.Text = "      " .. v
                    Opt.Font = "Gotham"
                    Opt.TextSize = 13
                    Opt.TextColor3 = FluLib.Theme.TextSecondary
                    Opt.TextXAlignment = "Left"
                    Opt.Parent = List

                    Opt.MouseButton1Click:Connect(function()
                        if not Config.MultipleOptions then
                            Btn.Text = "  " .. Config.Name .. " : " .. v
                            Drop.Open = false
                            Tween(Frame, {Size = UDim2.new(1, -10, 0, 45)}, 0.3)
                            Config.Callback(v)
                        else
                            -- Multi-select Logic
                            if table.find(Drop.Selected, v) then
                                table.remove(Drop.Selected, table.find(Drop.Selected, v))
                                Opt.TextColor3 = FluLib.Theme.TextSecondary
                            else
                                table.insert(Drop.Selected, v)
                                Opt.TextColor3 = FluLib.Theme.MainColor
                            end
                            Config.Callback(Drop.Selected)
                        end
                    end)
                end

                Btn.MouseButton1Click:Connect(function()
                    Drop.Open = not Drop.Open
                    Tween(Frame, {Size = Drop.Open and UDim2.new(1, -10, 0, 45 + (#Config.Options * 35)) or UDim2.new(1, -10, 0, 45)}, 0.4)
                end)
            end

            --// ELEMENT: KEYBIND
            function Section:CreateBind(Config, Flag)
                Config = Config or {Name = "Keybind", CurrentBind = "E", Callback = function() end}
                local Key = Config.CurrentBind

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 50)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 1, 0)
                Lbl.Font = "GothamMedium"
                Lbl.TextSize = 14
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local BindBox = Instance.new("TextButton")
                BindBox.Size = UDim2.new(0, 70, 0, 30)
                BindBox.Position = UDim2.new(1, -85, 0.5, -15)
                BindBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                BindBox.Text = Key
                BindBox.TextColor3 = FluLib.Theme.MainColor
                BindBox.Font = "Code"
                BindBox.Parent = Frame
                Instance.new("UICorner", BindBox).CornerRadius = UDim.new(0, 5)

                local Listening = false
                BindBox.MouseButton1Click:Connect(function()
                    Listening = true
                    BindBox.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(i)
                    if Listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        Key = i.KeyCode.Name
                        BindBox.Text = Key
                        Listening = false
                        Config.Callback(i.KeyCode)
                    elseif not Listening and i.KeyCode.Name == Key then
                        Config.Callback(i.KeyCode)
                    end
                end)
            end

            return Section
        end
        return Tab
    end

    MakeDraggable(Sidebar, MainFrame)
    return Window
end

--// HELPERS
function Kwargify(Default, Given)
    if not Given then return Default end
    for i, v in pairs(Default) do
        if Given[i] == nil then Given[i] = v end
    end
    return Given
end

return FluLib
