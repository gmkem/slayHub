--[[
    SLAYLIB V2 - ULTIMATE UI FRAMEWORK (PART 1)
    Developed for: Flukito (Fluke)
    Version: 2.1.0 (Grand Edition)
    Theme: Cyber-Neon / Glassmorphism
]]

local SlayLib = {
    Folder = "SlayLib_Config",
    Settings = {},
    Flags = {},
    Elements = {},
    Signals = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(25, 25, 25),
        ElementHover = Color3.fromRGB(32, 32, 32),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45),
        NotificationColor = Color3.fromRGB(120, 80, 255),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 165, 0),
        Error = Color3.fromRGB(255, 65, 65),
    },
    Icons = {
        Logofull = "rbxassetid://116729461256827",
        Logo = "rbxassetid://71428791657528",
        Check = "rbxassetid://10734895530",
        Chevron = "rbxassetid://10734895856",
        Search = "rbxassetid://10734942201",
        Home = "rbxassetid://10734882772",
        Settings = "rbxassetid://10734950056"
    }
}

--// [ SERVICES ]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// [ INITIALIZE FOLDER ]
if not isfolder(SlayLib.Folder) then
    makefolder(SlayLib.Folder)
end

--// [ UTILS MODULE ]
local Utils = {}
do
    function Utils:Tween(Object, Properties, Duration, Style, Direction)
        local Info = TweenInfo.new(Duration or 0.3, Style or Enum.EasingStyle.Quart, Direction or Enum.EasingDirection.Out)
        local Animation = TweenService:Create(Object, Info, Properties)
        Animation:Play()
        return Animation
    end

    function Utils:GetTextSize(Text, Size, Font, AbsoluteSize)
        return TextService:GetTextSize(Text, Size, Font, Vector2.new(AbsoluteSize, 10000))
    end

    function Utils:MakeDraggable(Frame, Handle)
        local Dragging = nil
        local DragInput = nil
        local DragStart = nil
        local StartPos = nil

        local function Update(Input)
            local Delta = Input.Position - DragStart
            local NewPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            Frame.Position = NewPos
        end

        Handle.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPos = Frame.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        Handle.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                DragInput = Input
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if Input == DragInput and Dragging then
                Update(Input)
            end
        end)
    end
    
    function Utils:Ripple(obj)
        task.spawn(function()
            local Circle = Instance.new("ImageLabel")
            Circle.Name = "Ripple"
            Circle.Parent = obj
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.BackgroundTransparency = 0.8
            Circle.ZIndex = 10
            Circle.Image = "rbxassetid://266543268"
            Circle.AnchorPoint = Vector2.new(0.5, 0.5)
            Circle.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
            Circle.Size = UDim2.new(0, 0, 0, 0)
            Circle.ImageTransparency = 0.6
            
            Utils:Tween(Circle, {Size = UDim2.new(0, 300, 0, 300), ImageTransparency = 1}, 0.5)
            task.wait(0.5)
            Circle:Destroy()
        end)
    end
end

--// [ NOTIFICATION SYSTEM ]
function SlayLib:Notify(Props)
    Props = Props or {}
    local TitleText = Props.Title or "SlayLib V2"
    local ContentText = Props.Content or "Successfully executed!"
    local Duration = Props.Duration or 3
    local Type = Props.Type or "Info"

    local NotifyGui = CoreGui:FindFirstChild("SlayNotifications")
    if not NotifyGui then
        NotifyGui = Instance.new("ScreenGui")
        NotifyGui.Name = "SlayNotifications"
        NotifyGui.DisplayOrder = 100
        NotifyGui.Parent = CoreGui
    end

    local Holder = NotifyGui:FindFirstChild("Holder")
    if not Holder then
        Holder = Instance.new("Frame")
        Holder.Name = "Holder"
        Holder.Size = UDim2.new(0, 300, 1, -40)
        Holder.Position = UDim2.new(1, -310, 0, 20)
        Holder.BackgroundTransparency = 1
        Holder.Parent = NotifyGui
        
        local Layout = Instance.new("UIListLayout")
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = Holder
    end

    local Main = Instance.new("Frame")
    Main.Name = "Notification"
    Main.Size = UDim2.new(1, 0, 0, 0)
    Main.BackgroundColor3 = SlayLib.Theme.Background
    Main.ClipsDescendants = true
    Main.Parent = Holder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Main

    local Stroke = Instance.new("UIStroke")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Color = (Type == "Success" and SlayLib.Theme.Success) or (Type == "Error" and SlayLib.Theme.Error) or SlayLib.Theme.MainColor
    Stroke.Thickness = 1.5
    Stroke.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = SlayLib.Theme.MainColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Main

    local Content = Instance.new("TextLabel")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 0, 30)
    Content.Position = UDim2.new(0, 10, 0, 30)
    Content.BackgroundTransparency = 1
    Content.Text = ContentText
    Content.TextColor3 = SlayLib.Theme.Text
    Content.Font = Enum.Font.Gotham
    Content.TextSize = 12
    Content.TextWrapped = true
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.Parent = Main

    Utils:Tween(Main, {Size = UDim2.new(1, 0, 0, 70)}, 0.4)
    
    task.spawn(function()
        task.wait(Duration)
        Utils:Tween(Main, {Size = UDim2.new(1, 0, 0, 0)}, 0.4)
        task.wait(0.4)
        Main:Destroy()
    end)
end

--// [ MAIN WINDOW CREATION ]
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib V2 | Premium Hub"}
    
    local Window = {
        ActiveTab = nil,
        Tabs = {},
        Minimized = false,
        Visible = true
    }

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "SlayV2_Main"
    MainGui.IgnoreGuiInset = true
    MainGui.ResetOnSpawn = false
    MainGui.DisplayOrder = 10
    MainGui.Parent = CoreGui

    --// MOBILE TOGGLE
    local TglBtn = Instance.new("TextButton")
    TglBtn.Name = "SlayToggle"
    TglBtn.Size = UDim2.new(0, 50, 0, 50)
    TglBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    TglBtn.BackgroundColor3 = SlayLib.Theme.Background
    TglBtn.BorderSizePixel = 0
    TglBtn.Text = ""
    TglBtn.AutoButtonColor = false
    TglBtn.Parent = MainGui

    local TglIcon = Instance.new("ImageLabel")
    TglIcon.Name = "Icon"
    TglIcon.Size = UDim2.new(0, 30, 0, 30)
    TglIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    TglIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    TglIcon.BackgroundTransparency = 1
    TglIcon.Image = SlayLib.Icons.Logo
    TglIcon.ImageColor3 = SlayLib.Theme.MainColor
    TglIcon.Parent = TglBtn

    local TglCorner = Instance.new("UICorner")
    TglCorner.CornerRadius = UDim.new(1, 0)
    TglCorner.Parent = TglBtn

    local TglStroke = Instance.new("UIStroke")
    TglStroke.Color = SlayLib.Theme.MainColor
    TglStroke.Thickness = 2
    TglStroke.Parent = TglBtn
    
    Utils:MakeDraggable(TglBtn, TglBtn)

    --// MAIN FRAME
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 420)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = SlayLib.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = SlayLib.Theme.Stroke
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    -- Toggle Logic
    TglBtn.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Utils:Tween(MainFrame, {GroupTransparency = 0, Size = UDim2.new(0, 650, 0, 420)}, 0.3)
        else
            Utils:Tween(MainFrame, {GroupTransparency = 1, Size = UDim2.new(0, 630, 0, 400)}, 0.3)
            task.wait(0.3)
            MainFrame.Visible = false
        end
    end)

    --// SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = SlayLib.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Name = "Line"
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BackgroundColor3 = SlayLib.Theme.Stroke
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    local LogoFrame = Instance.new("Frame")
    LogoFrame.Name = "LogoFrame"
    LogoFrame.Size = UDim2.new(1, 0, 0, 60)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = Sidebar

    local LogoFull = Instance.new("ImageLabel")
    LogoFull.Name = "LogoFull"
    LogoFull.Size = UDim2.new(0, 140, 0, 40)
    LogoFull.Position = UDim2.new(0.5, 0, 0.5, 0)
    LogoFull.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoFull.BackgroundTransparency = 1
    LogoFull.Image = SlayLib.Icons.Logofull
    LogoFull.ImageColor3 = SlayLib.Theme.MainColor
    LogoFull.Parent = LogoFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -120)
    TabContainer.Position = UDim2.new(0, 0, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.Parent = TabContainer

    --// PAGE CONTAINER
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, -190, 1, -10)
    PageContainer.Position = UDim2.new(0, 185, 0, 5)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    Utils:MakeDraggable(MainFrame, Sidebar)

    --// [ TAB CREATION MODULE ]
    function Window:CreateTab(Name, IconID)
        local Tab = {
            Name = Name,
            Active = false,
            Page = nil,
            Button = nil
        }

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = Name .. "_Tab"
        TabBtn.Size = UDim2.new(0, 160, 0, 38)
        TabBtn.BackgroundColor3 = SlayLib.Theme.Element
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabBtn

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 12, 0.5, 0)
        TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = IconID or SlayLib.Icons.Home
        TabIcon.ImageColor3 = SlayLib.Theme.TextSecondary
        TabIcon.Parent = TabBtn

        local TabTitle = Instance.new("TextLabel")
        TabTitle.Name = "Title"
        TabTitle.Size = UDim2.new(1, -45, 1, 0)
        TabTitle.Position = UDim2.new(0, 40, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = Name
        TabTitle.TextColor3 = SlayLib.Theme.TextSecondary
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 13
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = Name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = SlayLib.Theme.MainColor
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.Parent = Page

        Tab.Page = Page
        Tab.Button = TabBtn

        -- Tab Logic
        TabBtn.MouseEnter:Connect(function()
            if not Tab.Active then
                Utils:Tween(TabBtn, {BackgroundTransparency = 0.5}, 0.2)
                Utils:Tween(TabTitle, {TextColor3 = SlayLib.Theme.Text}, 0.2)
            end
        end)

        TabBtn.MouseLeave:Connect(function()
            if not Tab.Active then
                Utils:Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
                Utils:Tween(TabTitle, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.2)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Active = false
                t.Page.Visible = false
                Utils:Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
                Utils:Tween(t.Button.Title, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.2)
                Utils:Tween(t.Button.Icon, {ImageColor3 = SlayLib.Theme.TextSecondary}, 0.2)
            end
            Tab.Active = true
            Page.Visible = true
            Utils:Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
            Utils:Tween(TabTitle, {TextColor3 = SlayLib.Theme.MainColor}, 0.2)
            Utils:Tween(TabIcon, {ImageColor3 = SlayLib.Theme.MainColor}, 0.2)
        end)

        if #Window.Tabs == 0 then
            Tab.Active = true
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabTitle.TextColor3 = SlayLib.Theme.MainColor
            TabIcon.ImageColor3 = SlayLib.Theme.MainColor
        end

        table.insert(Window.Tabs, Tab)

        --// [ SECTION CREATION ]
        local SectionModule = {}
        
        function SectionModule:CreateSection(Title)
            local Section = {Elements = {}}

            local SecFrame = Instance.new("Frame")
            SecFrame.Name = Title .. "_Section"
            SecFrame.Size = UDim2.new(1, -10, 0, 35)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Page

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Name = "Title"
            SecTitle.Size = UDim2.new(1, -10, 1, 0)
            SecTitle.Position = UDim2.new(0, 5, 0, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Text = string.upper(Title)
            SecTitle.TextColor3 = SlayLib.Theme.MainColor
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 12
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Parent = SecFrame

            local SecLine = Instance.new("Frame")
            SecLine.Name = "Line"
            SecLine.Size = UDim2.new(1, -10, 0, 1)
            SecLine.Position = UDim2.new(0, 5, 1, 0)
            SecLine.BackgroundColor3 = SlayLib.Theme.Stroke
            SecLine.BorderSizePixel = 0
            SecLine.Parent = SecFrame

            -- [[ ส่วนนี้คือจุดที่คัดออกเพื่อรอส่งต่อครับ ]]
            -- [[ 1. ADD BUTTON ]]
            function SectionModule:AddButton(Text, Callback)
                local Button = {Name = Text}
                
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Name = Text .. "_Button"
                BtnFrame.Size = UDim2.new(1, -10, 0, 38)
                BtnFrame.BackgroundColor3 = SlayLib.Theme.Element
                BtnFrame.BorderSizePixel = 0
                BtnFrame.AutoButtonColor = false
                BtnFrame.Text = ""
                BtnFrame.Parent = Page

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 8)
                BtnCorner.Parent = BtnFrame

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BtnStroke.Color = SlayLib.Theme.Stroke
                BtnStroke.Thickness = 1
                BtnStroke.Parent = BtnFrame

                local BtnTitle = Instance.new("TextLabel")
                BtnTitle.Name = "Title"
                BtnTitle.Size = UDim2.new(1, -20, 1, 0)
                BtnTitle.Position = UDim2.new(0, 12, 0, 0)
                BtnTitle.BackgroundTransparency = 1
                BtnTitle.Text = Text
                BtnTitle.TextColor3 = SlayLib.Theme.Text
                BtnTitle.Font = Enum.Font.GothamMedium
                BtnTitle.TextSize = 13
                BtnTitle.TextXAlignment = Enum.TextXAlignment.Left
                BtnTitle.Parent = BtnFrame

                local BtnIcon = Instance.new("ImageLabel")
                BtnIcon.Name = "Icon"
                BtnIcon.Size = UDim2.new(0, 18, 0, 18)
                BtnIcon.Position = UDim2.new(1, -25, 0.5, 0)
                BtnIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                BtnIcon.BackgroundTransparency = 1
                BtnIcon.Image = "rbxassetid://10734899520"
                BtnIcon.ImageColor3 = SlayLib.Theme.TextSecondary
                BtnIcon.Parent = BtnFrame

                -- Hover Logic
                BtnFrame.MouseEnter:Connect(function()
                    Utils:Tween(BtnFrame, {BackgroundColor3 = SlayLib.Theme.ElementHover}, 0.2)
                    Utils:Tween(BtnStroke, {Color = SlayLib.Theme.MainColor}, 0.2)
                end)

                BtnFrame.MouseLeave:Connect(function()
                    Utils:Tween(BtnFrame, {BackgroundColor3 = SlayLib.Theme.Element}, 0.2)
                    Utils:Tween(BtnStroke, {Color = SlayLib.Theme.Stroke}, 0.2)
                end)

                BtnFrame.MouseButton1Down:Connect(function()
                    Utils:Ripple(BtnFrame)
                    Utils:Tween(BtnFrame, {Size = UDim2.new(1, -15, 0, 36)}, 0.1)
                end)

                BtnFrame.MouseButton1Up:Connect(function()
                    Utils:Tween(BtnFrame, {Size = UDim2.new(1, -10, 0, 38)}, 0.1)
                    task.spawn(Callback)
                end)

                return Button
            end

            -- [[ 2. ADD TOGGLE ]]
            function SectionModule:AddToggle(Text, Flag, Default, Callback)
                local Toggle = {Value = Default or false}
                SlayLib.Flags[Flag] = Toggle.Value

                local TglFrame = Instance.new("TextButton")
                TglFrame.Name = Text .. "_Toggle"
                TglFrame.Size = UDim2.new(1, -10, 0, 42)
                TglFrame.BackgroundColor3 = SlayLib.Theme.Element
                TglFrame.BorderSizePixel = 0
                TglFrame.AutoButtonColor = false
                TglFrame.Text = ""
                TglFrame.Parent = Page

                local TglCorner = Instance.new("UICorner")
                TglCorner.CornerRadius = UDim.new(0, 8)
                TglCorner.Parent = TglFrame

                local TglStroke = Instance.new("UIStroke")
                TglStroke.Color = SlayLib.Theme.Stroke
                TglStroke.Thickness = 1
                TglStroke.Parent = TglFrame

                local TglTitle = Instance.new("TextLabel")
                TglTitle.Name = "Title"
                TglTitle.Size = UDim2.new(1, -60, 1, 0)
                TglTitle.Position = UDim2.new(0, 12, 0, 0)
                TglTitle.BackgroundTransparency = 1
                TglTitle.Text = Text
                TglTitle.TextColor3 = SlayLib.Theme.TextSecondary
                TglTitle.Font = Enum.Font.GothamMedium
                TglTitle.TextSize = 13
                TglTitle.TextXAlignment = Enum.TextXAlignment.Left
                TglTitle.Parent = TglFrame

                local TglBg = Instance.new("Frame")
                TglBg.Name = "Bg"
                TglBg.Size = UDim2.new(0, 36, 0, 18)
                TglBg.Position = UDim2.new(1, -48, 0.5, 0)
                TglBg.AnchorPoint = Vector2.new(0, 0.5)
                TglBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                TglBg.Parent = TglFrame

                local TglBgCorner = Instance.new("UICorner")
                TglBgCorner.CornerRadius = UDim.new(1, 0)
                TglBgCorner.Parent = TglBg

                local TglDot = Instance.new("Frame")
                TglDot.Name = "Dot"
                TglDot.Size = UDim2.new(0, 12, 0, 12)
                TglDot.Position = UDim2.new(0, 3, 0.5, 0)
                TglDot.AnchorPoint = Vector2.new(0, 0.5)
                TglDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TglDot.Parent = TglBg

                local TglDotCorner = Instance.new("UICorner")
                TglDotCorner.CornerRadius = UDim.new(1, 0)
                TglDotCorner.Parent = TglDot

                -- Toggle Logic
                local function Set(State)
                    Toggle.Value = State
                    SlayLib.Flags[Flag] = State
                    if Toggle.Value then
                        Utils:Tween(TglBg, {BackgroundColor3 = SlayLib.Theme.MainColor}, 0.2)
                        Utils:Tween(TglDot, {Position = UDim2.new(1, -15, 0.5, 0)}, 0.2)
                        Utils:Tween(TglTitle, {TextColor3 = SlayLib.Theme.Text}, 0.2)
                    else
                        Utils:Tween(TglBg, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}, 0.2)
                        Utils:Tween(TglDot, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.2)
                        Utils:Tween(TglTitle, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.2)
                    end
                    task.spawn(Callback, Toggle.Value)
                end

                TglFrame.MouseButton1Click:Connect(function()
                    Set(not Toggle.Value)
                end)

                if Toggle.Value then Set(true) end
                
                function Toggle:Set(State) Set(State) end
                return Toggle
            end

            -- [[ 3. ADD SLIDER ]]
            function SectionModule:AddSlider(Text, Flag, Min, Max, Dec, Default, Callback)
                local Slider = {Value = Default or Min}
                SlayLib.Flags[Flag] = Slider.Value

                local SldFrame = Instance.new("Frame")
                SldFrame.Name = Text .. "_Slider"
                SldFrame.Size = UDim2.new(1, -10, 0, 50)
                SldFrame.BackgroundColor3 = SlayLib.Theme.Element
                SldFrame.BorderSizePixel = 0
                SldFrame.Parent = Page

                local SldCorner = Instance.new("UICorner")
                SldCorner.CornerRadius = UDim.new(0, 8)
                SldCorner.Parent = SldFrame

                local SldTitle = Instance.new("TextLabel")
                SldTitle.Name = "Title"
                SldTitle.Size = UDim2.new(1, -100, 0, 30)
                SldTitle.Position = UDim2.new(0, 12, 0, 0)
                SldTitle.BackgroundTransparency = 1
                SldTitle.Text = Text
                SldTitle.TextColor3 = SlayLib.Theme.Text
                SldTitle.Font = Enum.Font.GothamMedium
                SldTitle.TextSize = 13
                SldTitle.TextXAlignment = Enum.TextXAlignment.Left
                SldTitle.Parent = SldFrame

                local SldValueLabel = Instance.new("TextLabel")
                SldValueLabel.Name = "ValueLabel"
                SldValueLabel.Size = UDim2.new(0, 60, 0, 30)
                SldValueLabel.Position = UDim2.new(1, -72, 0, 0)
                SldValueLabel.BackgroundTransparency = 1
                SldValueLabel.Text = tostring(Slider.Value)
                SldValueLabel.TextColor3 = SlayLib.Theme.MainColor
                SldValueLabel.Font = Enum.Font.GothamBold
                SldValueLabel.TextSize = 13
                SldValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                SldValueLabel.Parent = SldFrame

                local SldBg = Instance.new("TextButton")
                SldBg.Name = "SldBg"
                SldBg.Size = UDim2.new(1, -24, 0, 4)
                SldBg.Position = UDim2.new(0, 12, 1, -12)
                SldBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                SldBg.BorderSizePixel = 0
                SldBg.Text = ""
                SldBg.AutoButtonColor = false
                SldBg.Parent = SldFrame

                local SldBgCorner = Instance.new("UICorner")
                SldBgCorner.CornerRadius = UDim.new(1, 0)
                SldBgCorner.Parent = SldBg

                local SldFill = Instance.new("Frame")
                SldFill.Name = "Fill"
                SldFill.Size = UDim2.new((Slider.Value - Min) / (Max - Min), 0, 1, 0)
                SldFill.BackgroundColor3 = SlayLib.Theme.MainColor
                SldFill.BorderSizePixel = 0
                SldFill.Parent = SldBg

                local SldFillCorner = Instance.new("UICorner")
                SldFillCorner.CornerRadius = UDim.new(1, 0)
                SldFillCorner.Parent = SldFill

                local SldCircle = Instance.new("Frame")
                SldCircle.Name = "Circle"
                SldCircle.Size = UDim2.new(0, 10, 0, 10)
                SldCircle.Position = UDim2.new(1, 0, 0.5, 0)
                SldCircle.AnchorPoint = Vector2.new(0.5, 0.5)
                SldCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SldCircle.Parent = SldFill

                local SldCircleCorner = Instance.new("UICorner")
                SldCircleCorner.CornerRadius = UDim.new(1, 0)
                SldCircleCorner.Parent = SldCircle

                -- Slider Logic
                local Dragging = false
                local function Update(Input)
                    local Pos = math.clamp((Input.Position.X - SldBg.AbsolutePosition.X) / SldBg.AbsoluteSize.X, 0, 1)
                    local Val = (Max - Min) * Pos + Min
                    
                    if Dec then
                        Val = string.format("%." .. Dec .. "f", Val)
                    else
                        Val = math.floor(Val)
                    end
                    
                    Slider.Value = Val
                    SlayLib.Flags[Flag] = Val
                    SldValueLabel.Text = tostring(Val)
                    Utils:Tween(SldFill, {Size = UDim2.new(Pos, 0, 1, 0)}, 0.1)
                    task.spawn(Callback, Val)
                end

                SldBg.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        Update(Input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        Update(Input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end)

                function Slider:Set(Val)
                    local Pos = math.clamp((Val - Min) / (Max - Min), 0, 1)
                    Slider.Value = Val
                    SlayLib.Flags[Flag] = Val
                    SldValueLabel.Text = tostring(Val)
                    Utils:Tween(SldFill, {Size = UDim2.new(Pos, 0, 1, 0)}, 0.1)
                    task.spawn(Callback, Val)
                end

                return Slider
            end

            -- [[ 4. ADD DROPDOWN ]]
            -- ต่อไปคือส่วนของ Dropdown ที่มีระบบ Search และการเลือกแบบ Multi-Select ซึ่งยาวมาก
            -- คัดออกเพื่อรอส่งต่อรอบถัดไปครับ...
            -- [[ 4. ADD DROPDOWN ]]
            function SectionModule:AddDropdown(Text, Flag, Options, Default, Callback)
                local Dropdown = {Value = Default or Options[1], Options = Options, Open = false}
                SlayLib.Flags[Flag] = Dropdown.Value

                local DrpFrame = Instance.new("Frame")
                DrpFrame.Name = Text .. "_Dropdown"
                DrpFrame.Size = UDim2.new(1, -10, 0, 42)
                DrpFrame.BackgroundColor3 = SlayLib.Theme.Element
                DrpFrame.ClipsDescendants = true
                DrpFrame.Parent = Page

                local DrpCorner = Instance.new("UICorner")
                DrpCorner.CornerRadius = UDim.new(0, 8)
                DrpCorner.Parent = DrpFrame

                local DrpStroke = Instance.new("UIStroke")
                DrpStroke.Color = SlayLib.Theme.Stroke
                DrpStroke.Thickness = 1
                DrpStroke.Parent = DrpFrame

                local DrpBtn = Instance.new("TextButton")
                DrpBtn.Name = "MainBtn"
                DrpBtn.Size = UDim2.new(1, 0, 0, 42)
                DrpBtn.BackgroundTransparency = 1
                DrpBtn.Text = ""
                DrpBtn.Parent = DrpFrame

                local DrpTitle = Instance.new("TextLabel")
                DrpTitle.Name = "Title"
                DrpTitle.Size = UDim2.new(1, -60, 1, 0)
                DrpTitle.Position = UDim2.new(0, 12, 0, 0)
                DrpTitle.BackgroundTransparency = 1
                DrpTitle.Text = Text .. " : " .. tostring(Dropdown.Value)
                DrpTitle.TextColor3 = SlayLib.Theme.Text
                DrpTitle.Font = Enum.Font.GothamMedium
                DrpTitle.TextSize = 13
                DrpTitle.TextXAlignment = Enum.TextXAlignment.Left
                DrpTitle.Parent = DrpBtn

                local DrpIcon = Instance.new("ImageLabel")
                DrpIcon.Name = "Icon"
                DrpIcon.Size = UDim2.new(0, 20, 0, 20)
                DrpIcon.Position = UDim2.new(1, -30, 0.5, 0)
                DrpIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                DrpIcon.BackgroundTransparency = 1
                DrpIcon.Image = SlayLib.Icons.Chevron
                DrpIcon.ImageColor3 = SlayLib.Theme.TextSecondary
                DrpIcon.Parent = DrpBtn

                local OptionHolder = Instance.new("Frame")
                OptionHolder.Name = "OptionHolder"
                OptionHolder.Size = UDim2.new(1, -10, 0, 0)
                OptionHolder.Position = UDim2.new(0, 5, 0, 45)
                OptionHolder.BackgroundTransparency = 1
                OptionHolder.Parent = DrpFrame

                local OptionLayout = Instance.new("UIListLayout")
                OptionLayout.Padding = UDim.new(0, 4)
                OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionLayout.Parent = OptionHolder

                local function RefreshOptions()
                    for _, v in pairs(OptionHolder:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end

                    for _, opt in pairs(Dropdown.Options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Name = opt .. "_Option"
                        OptBtn.Size = UDim2.new(1, 0, 0, 32)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Text = opt
                        OptBtn.TextColor3 = SlayLib.Theme.TextSecondary
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 12
                        OptBtn.Parent = OptionHolder

                        local OptCorner = Instance.new("UICorner")
                        OptCorner.CornerRadius = UDim.new(0, 6)
                        OptCorner.Parent = OptBtn

                        OptBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value = opt
                            SlayLib.Flags[Flag] = opt
                            DrpTitle.Text = Text .. " : " .. opt
                            Dropdown.Open = false
                            Utils:Tween(DrpFrame, {Size = UDim2.new(1, -10, 0, 42)}, 0.3)
                            Utils:Tween(DrpIcon, {Rotation = 0}, 0.3)
                            task.spawn(Callback, opt)
                        end)
                    end
                end

                DrpBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    if Dropdown.Open then
                        RefreshOptions()
                        local TargetSize = 45 + (#Dropdown.Options * 36)
                        Utils:Tween(DrpFrame, {Size = UDim2.new(1, -10, 0, math.min(TargetSize, 200))}, 0.3)
                        Utils:Tween(DrpIcon, {Rotation = 180}, 0.3)
                        DrpFrame.ClipsDescendants = false -- เพื่อให้เห็นลิสต์ถ้ามันยาว
                    else
                        Utils:Tween(DrpFrame, {Size = UDim2.new(1, -10, 0, 42)}, 0.3)
                        Utils:Tween(DrpIcon, {Rotation = 0}, 0.3)
                    end
                end)

                function Dropdown:Set(Val)
                    Dropdown.Value = Val
                    SlayLib.Flags[Flag] = Val
                    DrpTitle.Text = Text .. " : " .. Val
                    task.spawn(Callback, Val)
                end

                return Dropdown
            end

            -- [[ 5. ADD KEYBIND ]]
            function SectionModule:AddKeybind(Text, Flag, Default, Callback)
                local Keybind = {Value = Default or Enum.KeyCode.E, Binding = false}
                SlayLib.Flags[Flag] = Keybind.Value

                local KbFrame = Instance.new("Frame")
                KbFrame.Name = Text .. "_Keybind"
                KbFrame.Size = UDim2.new(1, -10, 0, 42)
                KbFrame.BackgroundColor3 = SlayLib.Theme.Element
                KbFrame.Parent = Page

                local KbCorner = Instance.new("UICorner"); KbCorner.CornerRadius = UDim.new(0, 8); KbCorner.Parent = KbFrame

                local KbTitle = Instance.new("TextLabel")
                KbTitle.Size = UDim2.new(1, -100, 1, 0); KbTitle.Position = UDim2.new(0, 12, 0, 0)
                KbTitle.BackgroundTransparency = 1; KbTitle.Text = Text; KbTitle.TextColor3 = SlayLib.Theme.Text
                KbTitle.Font = "GothamMedium"; KbTitle.TextSize = 13; KbTitle.TextXAlignment = "Left"; KbTitle.Parent = KbFrame

                local KbBtn = Instance.new("TextButton")
                KbBtn.Size = UDim2.new(0, 80, 0, 24); KbBtn.Position = UDim2.new(1, -92, 0.5, -12)
                KbBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); KbBtn.Text = Keybind.Value.Name
                KbBtn.TextColor3 = SlayLib.Theme.MainColor; KbBtn.Font = "GothamBold"; KbBtn.TextSize = 11; KbBtn.Parent = KbFrame
                Instance.new("UICorner", KbBtn).CornerRadius = UDim.new(0, 6)

                KbBtn.MouseButton1Click:Connect(function()
                    Keybind.Binding = true
                    KbBtn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(Input)
                    if Keybind.Binding and Input.UserInputType == Enum.UserInputType.Keyboard then
                        Keybind.Value = Input.KeyCode
                        SlayLib.Flags[Flag] = Input.KeyCode
                        KbBtn.Text = Input.KeyCode.Name
                        Keybind.Binding = false
                        task.spawn(Callback, Input.KeyCode)
                    end
                end)

                return Keybind
            end

            -- [[ 6. ADD COLORPICKER ]]
            function SectionModule:AddColorPicker(Text, Flag, Default, Callback)
                local CP = {Value = Default or Color3.fromRGB(255, 255, 255)}
                SlayLib.Flags[Flag] = CP.Value

                local CPFrame = Instance.new("Frame")
                CPFrame.Size = UDim2.new(1, -10, 0, 42); CPFrame.BackgroundColor3 = SlayLib.Theme.Element; CPFrame.Parent = Page
                Instance.new("UICorner", CPFrame).CornerRadius = UDim.new(0, 8)

                local CPTitle = Instance.new("TextLabel")
                CPTitle.Size = UDim2.new(1, -60, 1, 0); CPTitle.Position = UDim2.new(0, 12, 0, 0); CPTitle.BackgroundTransparency = 1
                CPTitle.Text = Text; CPTitle.TextColor3 = SlayLib.Theme.Text; CPTitle.Font = "GothamMedium"; CPTitle.TextSize = 13; CPTitle.TextXAlignment = "Left"; CPTitle.Parent = CPFrame

                local CPBox = Instance.new("TextButton")
                CPBox.Size = UDim2.new(0, 30, 0, 20); CPBox.Position = UDim2.new(1, -42, 0.5, -10)
                CPBox.BackgroundColor3 = CP.Value; CPBox.Text = ""; CPBox.Parent = CPFrame
                Instance.new("UICorner", CPBox).CornerRadius = UDim.new(0, 4)

                -- สำหรับ ColorPicker แบบเต็ม (Palette) จะต้องใช้โค้ดอีกประมาณ 150 บรรทัด
                -- ในที่นี้ผมทำระบบพื้นฐานให้ก่อนเพื่อให้โค้ดไม่ตัดครับ
                return CP
            end

            return SectionModule
        end
        return Tab
    end

    --// [ CONFIG SYSTEM LOGIC ]
    function SlayLib:Save(Name)
        local Data = HttpService:JSONEncode(SlayLib.Flags)
        local FilePath = SlayLib.Folder .. "/" .. Name .. ".json"
        writefile(FilePath, Data)
        SlayLib:Notify({Title = "Config", Content = "Saved to " .. Name, Type = "Success"})
    end

    function SlayLib:Load(Name)
        local FilePath = SlayLib.Folder .. "/" .. Name .. ".json"
        if isfile(FilePath) then
            local Data = HttpService:JSONDecode(readfile(FilePath))
            for i, v in pairs(Data) do
                SlayLib.Flags[i] = v
                -- Logic ในการอัปเดต UI จะต้องเชื่อมกับ Elements Table
            end
            SlayLib:Notify({Title = "Config", Content = "Loaded " .. Name, Type = "Success"})
        end
    end

    return Window
end

return SlayLib
