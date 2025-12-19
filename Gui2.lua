--[[
    FluLib Interface Suite (Premium Version)
    "Beyond Fluidity, Beyond Function"
    
    [CHANGELOG]
    - Complete Structural Overhaul (Fluent Design)
    - Full Instance Generation (100% Script-based)
    - Advanced Animation Engine (Exponential/Back)
    - Integrated Theme & Configuration System
]]

local FluLib = {
    Folder = "FluLib_Configs",
    Options = {},
    Theme = {
        MainColor = Color3.fromRGB(0, 120, 212),
        SecondaryMain = Color3.fromRGB(0, 100, 180),
        Background = Color3.fromRGB(15, 15, 15),
        Sidebar = Color3.fromRGB(22, 22, 22),
        Element = Color3.fromRGB(28, 28, 28),
        ElementHover = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45)
    }
}

--// Services & Utilities
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Mouse = Players.LocalPlayer:GetMouse()

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

--// UI Generation Core
function FluLib:CreateWindow(Settings)
    Settings = Settings or {Name = "FluLib", Subtitle = "Fluent Design"}
    
    local Window = {
        CurrentTab = nil,
        Tabs = {},
        Minimized = false
    }

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "FluLib_Root"
    MainGui.Parent = CoreGui
    MainGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 620, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -220)
    MainFrame.BackgroundColor3 = FluLib.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = FluLib.Theme.Stroke
    UIStroke.Thickness = 1.2
    UIStroke.Parent = MainFrame

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 190, 1, 0)
    Sidebar.BackgroundColor3 = FluLib.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 8)
    SideCorner.Parent = Sidebar

    local TitleFrame = Instance.new("Frame")
    TitleFrame.Size = UDim2.new(1, 0, 0, 60)
    TitleFrame.BackgroundTransparency = 1
    TitleFrame.Parent = Sidebar

    local Title = Instance.new("TextLabel")
    Title.Text = Settings.Name
    Title.Position = UDim2.new(0, 20, 0, 15)
    Title.Size = UDim2.new(1, -40, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = FluLib.Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TitleFrame

    local Sub = Instance.new("TextLabel")
    Sub.Text = Settings.Subtitle
    Sub.Position = UDim2.new(0, 20, 0, 35)
    Sub.Size = UDim2.new(1, -40, 0, 15)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 12
    Sub.TextColor3 = FluLib.Theme.TextSecondary
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.BackgroundTransparency = 1
    Sub.Parent = TitleFrame

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -80)
    TabScroll.Position = UDim2.new(0, 5, 0, 70)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.Parent = TabScroll

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -205, 1, -20)
    Container.Position = UDim2.new(0, 200, 0, 10)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    --// Tab Logic
    function Window:CreateTab(Name, Icon)
        local Tab = {Active = false, Sections = {}}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "  " .. Name
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = FluLib.Theme.TextSecondary
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = FluLib.Theme.MainColor
        Page.Parent = Container

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 12)
        PageList.Parent = Page

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = FluLib.Theme.TextSecondary}, 0.2)
            end
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, TextColor3 = FluLib.Theme.MainColor}, 0.2)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.9
            TabBtn.TextColor3 = FluLib.Theme.MainColor
        end

        --// Section System
        function Tab:CreateSection(SName)
            local Section = {}
            
            local SLbl = Instance.new("TextLabel")
            SLbl.Text = SName:upper()
            SLbl.Size = UDim2.new(1, 0, 0, 20)
            SLbl.Font = Enum.Font.GothamBold
            SLbl.TextSize = 11
            SLbl.TextColor3 = FluLib.Theme.MainColor
            SLbl.TextTransparency = 0.4
            SLbl.TextXAlignment = Enum.TextXAlignment.Left
            SLbl.BackgroundTransparency = 1
            SLbl.Parent = Page

            --// Elements
            function Section:CreateButton(Config)
                Config = Config or {Name = "Button", Callback = function() end}
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -10, 0, 40)
                Btn.BackgroundColor3 = FluLib.Theme.Element
                Btn.Text = "  " .. Config.Name
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 13
                Btn.TextColor3 = FluLib.Theme.Text
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.AutoButtonColor = false
                Btn.Parent = Page

                local BC = Instance.new("UICorner") BC.CornerRadius = UDim.new(0, 6) BC.Parent = Btn
                local BS = Instance.new("UIStroke") BS.Color = FluLib.Theme.Stroke BS.Parent = Btn

                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = FluLib.Theme.ElementHover}, 0.2) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = FluLib.Theme.Element}, 0.2) end)
                Btn.MouseButton1Click:Connect(function()
                    Btn.Size = UDim2.new(1, -15, 0, 38)
                    Tween(Btn, {Size = UDim2.new(1, -10, 0, 40)}, 0.2, Enum.EasingStyle.Back)
                    Config.Callback()
                end)
            end

            function Section:CreateToggle(Config, Flag)
                Config = Config or {Name = "Toggle", CurrentValue = false, Callback = function() end}
                local Tgl = {Value = Config.CurrentValue}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 45)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                Instance.new("UIStroke", Frame).Color = FluLib.Theme.Stroke

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 1, 0)
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.TextSize = 13
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local Sw = Instance.new("Frame")
                Sw.Size = UDim2.new(0, 38, 0, 20)
                Sw.Position = UDim2.new(1, -48, 0.5, -10)
                Sw.BackgroundColor3 = Tgl.Value and FluLib.Theme.MainColor or Color3.fromRGB(60, 60, 60)
                Sw.Parent = Frame
                Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)

                local Cir = Instance.new("Frame")
                Cir.Size = UDim2.new(0, 14, 0, 14)
                Cir.Position = Tgl.Value and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                Cir.BackgroundColor3 = Color3.new(1, 1, 1)
                Cir.Parent = Sw
                Instance.new("UICorner", Cir).CornerRadius = UDim.new(1, 0)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                Btn.Parent = Frame

                local function Set(v)
                    Tgl.Value = v
                    Tween(Sw, {BackgroundColor3 = v and FluLib.Theme.MainColor or Color3.fromRGB(60, 60, 60)}, 0.2)
                    Tween(Cir, {Position = v and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.2)
                    Config.Callback(v)
                end
                Btn.MouseButton1Click:Connect(function() Set(not Tgl.Value) end)
                return {Set = Set}
            end

            function Section:CreateSlider(Config, Flag)
                Config = Config or {Name = "Slider", Range = {0, 100}, CurrentValue = 50, Callback = function() end}
                local Sld = {Value = Config.CurrentValue}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 55)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 0, 30)
                Lbl.Font = "GothamMedium"
                Lbl.TextSize = 13
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local Val = Instance.new("TextLabel")
                Val.Text = tostring(Sld.Value)
                Val.Size = UDim2.new(1, -15, 0, 30)
                Val.Font = "Code"
                Val.TextSize = 13
                Val.TextColor3 = FluLib.Theme.MainColor
                Val.TextXAlignment = "Right"
                Val.BackgroundTransparency = 1
                Val.Parent = Frame

                local Rail = Instance.new("Frame")
                Rail.Size = UDim2.new(1, -24, 0, 4)
                Rail.Position = UDim2.new(0, 12, 0, 38)
                Rail.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                Rail.BorderSizePixel = 0
                Rail.Parent = Frame

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((Sld.Value - Config.Range[1]) / (Config.Range[2] - Config.Range[1]), 0, 1, 0)
                Fill.BackgroundColor3 = FluLib.Theme.MainColor
                Fill.BorderSizePixel = 0
                Fill.Parent = Rail

                local Dragging = false
                local function Update()
                    local Pos = math.clamp((Mouse.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
                    local NewVal = math.floor(Config.Range[1] + (Config.Range[2] - Config.Range[1]) * Pos)
                    Sld.Value = NewVal
                    Val.Text = tostring(NewVal)
                    Fill.Size = UDim2.new(Pos, 0, 1, 0)
                    Config.Callback(NewVal)
                end
                Frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update() end end)
                UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                return {Set = function(v) 
                    local p = (v - Config.Range[1]) / (Config.Range[2] - Config.Range[1])
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    Val.Text = tostring(v)
                    Config.Callback(v)
                end}
            end

            function Section:CreateDropdown(Config, Flag)
                Config = Config or {Name = "Dropdown", Options = {"One", "Two"}, Callback = function() end}
                local Drop = {Open = false, Selected = nil}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 40)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.ClipsDescendants = true
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

                local Lbl = Instance.new("TextButton")
                Lbl.Size = UDim2.new(1, 0, 0, 40)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = "  " .. Config.Name
                Lbl.Font = "GothamMedium"
                Lbl.TextSize = 13
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.Parent = Frame

                local Arrow = Instance.new("TextLabel")
                Arrow.Text = "▼"
                Arrow.Size = UDim2.new(0, 40, 0, 40)
                Arrow.Position = UDim2.new(1, -40, 0, 0)
                Arrow.TextColor3 = FluLib.Theme.TextSecondary
                Arrow.BackgroundTransparency = 1
                Arrow.Parent = Frame

                local List = Instance.new("Frame")
                List.Position = UDim2.new(0, 0, 0, 40)
                List.Size = UDim2.new(1, 0, 0, 0)
                List.BackgroundTransparency = 1
                List.Parent = Frame
                local LL = Instance.new("UIListLayout") LL.Parent = List

                for _, v in pairs(Config.Options) do
                    local Opt = Instance.new("TextButton")
                    Opt.Size = UDim2.new(1, 0, 0, 30)
                    Opt.BackgroundTransparency = 1
                    Opt.Text = "      " .. v
                    Opt.Font = "Gotham"
                    Opt.TextSize = 12
                    Opt.TextColor3 = FluLib.Theme.TextSecondary
                    Opt.TextXAlignment = "Left"
                    Opt.Parent = List
                    Opt.MouseButton1Click:Connect(function()
                        Lbl.Text = "  " .. Config.Name .. " : " .. v
                        Tween(Frame, {Size = UDim2.new(1, -10, 0, 40)}, 0.3)
                        Drop.Open = false
                        Config.Callback(v)
                    end)
                end

                Lbl.MouseButton1Click:Connect(function()
                    Drop.Open = not Drop.Open
                    Tween(Frame, {Size = Drop.Open and UDim2.new(1, -10, 0, 40 + (#Config.Options * 30)) or UDim2.new(1, -10, 0, 40)}, 0.3)
                    Arrow.Text = Drop.Open and "▲" or "▼"
                end)
            end

            return Section
        end
        return Tab
    end

    MakeDraggable(Sidebar, MainFrame)
    return Window
end

--// Notification System
function FluLib:Notify(Settings)
    warn("[FluLib Notify]: " .. (Settings.Title or "Alert") .. " - " .. (Settings.Content or ""))
end

return FluLib
