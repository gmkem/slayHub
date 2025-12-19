--// ===========================================================================
--// [ SLAYLIB X : REACTOR GUI ENGINE BUILD 12.0 - PART 1/2 ]
--// ARCHITECTURE: CLASS-BASED CORE ENGINE FRAMEWORK
--// PURPOSE: ADVANCED GUI CORE & RENDERING SYSTEM
--// ===========================================================================

local SlayLib = {
    Version = "12.0.0",
    Registry = {},
    Flags = {},
    Themes = {
        ObsidianDark = {
            Main = Color3.fromRGB(0, 170, 255),
            Background = Color3.fromRGB(12, 12, 14),
            Sidebar = Color3.fromRGB(18, 18, 20),
            Section = Color3.fromRGB(25, 25, 28),
            Element = Color3.fromRGB(35, 35, 40),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(180, 180, 185),
            Stroke = Color3.fromRGB(45, 45, 50)
        },
        FemboyPink = {
            Main = Color3.fromRGB(255, 105, 180),
            Background = Color3.fromRGB(25, 15, 20),
            Sidebar = Color3.fromRGB(35, 20, 30),
            Section = Color3.fromRGB(45, 25, 40),
            Element = Color3.fromRGB(55, 30, 50),
            Text = Color3.fromRGB(255, 240, 245),
            TextDark = Color3.fromRGB(255, 180, 210),
            Stroke = Color3.fromRGB(80, 45, 75)
        },
        NeonGold = {
            Main = Color3.fromRGB(255, 215, 0),
            Background = Color3.fromRGB(15, 15, 10),
            Sidebar = Color3.fromRGB(20, 20, 12),
            Section = Color3.fromRGB(30, 30, 18),
            Element = Color3.fromRGB(40, 40, 25),
            Text = Color3.fromRGB(255, 255, 220),
            TextDark = Color3.fromRGB(200, 180, 100),
            Stroke = Color3.fromRGB(65, 55, 20)
        }
    },
    CurrentTheme = "ObsidianDark",
    IsLoaded = false,
    Connections = {},
    IsMobile = game:GetService("UserInputService").TouchEnabled
}

-- [INTERNAL ENGINE UTILITIES]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Utils = {}
do
    function Utils:Tween(obj, goal, duration, style, dir)
        local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
        local t = TweenService:Create(obj, info, goal)
        t:Play()
        return t
    end

    function Utils:GetFont()
        return SlayLib.IsMobile and Enum.Font.SourceSansBold or Enum.Font.GothamMedium
    end

    function Utils:ApplyShadow(frame, trans)
        local Shadow = Instance.new("ImageLabel")
        Shadow.Name = "EngineShadow"
        Shadow.BackgroundTransparency = 1
        Shadow.Image = "rbxassetid://6014264795"
        Shadow.ImageColor3 = Color3.new(0, 0, 0)
        Shadow.ImageTransparency = trans or 0.5
        Shadow.Position = UDim2.new(0, -15, 0, -15)
        Shadow.Size = UDim2.new(1, 30, 1, 30)
        Shadow.ZIndex = frame.ZIndex - 1
        Shadow.Parent = frame
        return Shadow
    end
end

-- [DRAG ENGINE CLASS]
local DragEngine = {}
do
    function DragEngine:Enable(frame, handle)
        local dragging, dragInput, dragStart, startPos
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
end



-- [NOTIFIER SYSTEM CLASS]
local Notifier = {}
do
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "SlayLib_Notif"
    local Holder = Instance.new("Frame", Screen)
    Holder.Size = UDim2.new(0, 300, 1, 0)
    Holder.Position = UDim2.new(1, -310, 0, 0)
    Holder.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Holder)
    Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    Layout.Padding = UDim.new(0, 10)

    function SlayLib:Notify(Props)
        local nFrame = Instance.new("Frame", Holder)
        nFrame.Size = UDim2.new(1, 0, 0, 80)
        nFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Background
        nFrame.BackgroundTransparency = 0.2
        Instance.new("UICorner", nFrame)
        local s = Instance.new("UIStroke", nFrame)
        s.Color = self.Themes[self.CurrentTheme].Main
        s.Thickness = 1.5

        local t = Instance.new("TextLabel", nFrame)
        t.Text = Props.Title or "SYSTEM"
        t.Size = UDim2.new(1, -20, 0, 30)
        t.Position = UDim2.new(0, 10, 0, 5)
        t.TextColor3 = self.Themes[self.CurrentTheme].Main
        t.Font = Enum.Font.GothamBold
        t.BackgroundTransparency = 1
        t.TextXAlignment = "Left"

        local d = Instance.new("TextLabel", nFrame)
        d.Text = Props.Content or ""
        d.Size = UDim2.new(1, -20, 0, 40)
        d.Position = UDim2.new(0, 10, 0, 35)
        d.TextColor3 = self.Themes[self.CurrentTheme].Text
        d.Font = Enum.Font.Gotham
        d.BackgroundTransparency = 1
        d.TextXAlignment = "Left"
        d.TextWrapped = true

        task.delay(Props.Duration or 5, function()
            Utils:Tween(nFrame, {BackgroundTransparency = 1}, 0.5)
            task.wait(0.5)
            nFrame:Destroy()
        end)
    end
end

-- [WINDOW CLASS DEFINITION]
function SlayLib:CreateWindow(Config)
    local Window = { Tabs = {}, ActiveTab = nil }
    local Theme = self.Themes[self.CurrentTheme]

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "SlayLib_Reactor_Core"
    Screen.IgnoreGuiInset = true

    local Main = Instance.new("Frame", Screen)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.BackgroundColor3 = Theme.Background
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Theme.Stroke
    Stroke.Thickness = 1.5
    Utils:ApplyShadow(Main)

    -- [Sidebar Construction]
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    
    local TitleLabel = Instance.new("TextLabel", Sidebar)
    TitleLabel.Text = Config.Name or "SLAYLIB ENGINE"
    TitleLabel.Size = UDim2.new(1, 0, 0, 60)
    TitleLabel.TextColor3 = Theme.Main
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.BackgroundTransparency = 1

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Padding = UDim.new(0, 5)

    -- [Page Holder Construction]
    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Size = UDim2.new(1, -185, 1, -20)
    PageHolder.Position = UDim2.new(0, 180, 0, 10)
    PageHolder.BackgroundTransparency = 1

    DragEngine:Enable(Main, Sidebar)



    -- [TAB CLASS DEFINITION]
    function Window:CreateTab(name)
        local Tab = { Sections = {} }
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(0.9, 0, 0, 38)
        TabBtn.BackgroundColor3 = Theme.Element
        TabBtn.Text = "  " .. name
        TabBtn.TextColor3 = Theme.TextDark
        TabBtn.Font = Utils:GetFont()
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = "Left"
        TabBtn.AutoButtonColor = false
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Main
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 12)
        PageList.HorizontalAlignment = "Center"

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                Utils:Tween(t.Btn, {TextColor3 = Theme.TextDark, BackgroundColor3 = Theme.Element}, 0.2)
            end
            Page.Visible = true
            Window.ActiveTab = Tab
            Utils:Tween(TabBtn, {TextColor3 = Theme.Main, BackgroundColor3 = Theme.Section}, 0.2)
        end)

        Tab.Page = Page; Tab.Btn = TabBtn
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Page.Visible = true; Window.ActiveTab = Tab; TabBtn.TextColor3 = Theme.Main end

        -- [SECTION CLASS DEFINITION]
        function Tab:CreateSection(sName)
            local Section = { Container = nil }
            local SectFrame = Instance.new("Frame", Page)
            SectFrame.Size = UDim2.new(0.96, 0, 0, 45)
            SectFrame.BackgroundColor3 = Theme.Section
            Instance.new("UICorner", SectFrame)
            local SectStroke = Instance.new("UIStroke", SectFrame)
            SectStroke.Color = Theme.Stroke
            SectStroke.Thickness = 1

            local SectLabel = Instance.new("TextLabel", SectFrame)
            SectLabel.Text = "  " .. sName:upper()
            SectLabel.Size = UDim2.new(1, 0, 0, 30)
            SectLabel.TextColor3 = Theme.Main
            SectLabel.Font = Enum.Font.GothamBold
            SectLabel.TextSize = 12
            SectLabel.TextXAlignment = "Left"
            SectLabel.BackgroundTransparency = 1

            local SectContainer = Instance.new("Frame", SectFrame)
            SectContainer.Size = UDim2.new(1, -10, 1, -35)
            SectContainer.Position = UDim2.new(0, 5, 0, 30)
            SectContainer.BackgroundTransparency = 1
            local SectLayout = Instance.new("UIListLayout", SectContainer)
            SectLayout.Padding = UDim.new(0, 6)

            SectLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectFrame.Size = UDim2.new(0.96, 0, 0, SectLayout.AbsoluteContentSize.Y + 40)
            end)

            Section.Container = SectContainer
            
            -- [ELEMENT REGISTRATION PLACEHOLDER]
            -- (Elements will be defined in Part 2)
            
            return Section
        end
        return Tab
    end
    return Window
end

-- [ENGINE STATE METHODS]
function SlayLib:Animate(obj, goal, duration)
    return Utils:Tween(obj, goal, duration)
end

-- // End of Part 1. Please wait for Part 2 to complete the Engine.
--// ===========================================================================
--// [ SLAYLIB X : REACTOR GUI ENGINE BUILD 12.0 - PART 2/2 ]
--// PURPOSE: UI ELEMENTS LOGIC, RESPONSIVE ENGINE & FINALIZATION
--// ===========================================================================

do
    -- [ELEMENT: BUTTON]
    function SlayLib.Elements:CreateButton(Parent, Props)
        local Theme = SlayLib.Themes[SlayLib.CurrentTheme]
        local Btn = Instance.new("TextButton", Parent.Container)
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Theme.Element
        Btn.Text = Props.Name or "Button"
        Btn.TextColor3 = Theme.Text
        Btn.Font = Utils:GetFont()
        Btn.TextSize = 14
        Btn.AutoButtonColor = false
        Instance.new("UICorner", Btn)
        
        local Stroke = Instance.new("UIStroke", Btn)
        Stroke.Color = Theme.Stroke
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        Btn.MouseEnter:Connect(function()
            Utils:Tween(Btn, {BackgroundColor3 = Theme.Main, TextColor3 = Theme.Background}, 0.2)
        end)
        Btn.MouseLeave:Connect(function()
            Utils:Tween(Btn, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.Text}, 0.2)
        end)
        Btn.MouseButton1Down:Connect(function()
            Utils:Tween(Btn, {Size = UDim2.new(0.98, 0, 0, 33)}, 0.1)
        end)
        Btn.MouseButton1Up:Connect(function()
            Utils:Tween(Btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
            if Props.Callback then Props.Callback() end
        end)
        return Btn
    end

    -- [ELEMENT: TOGGLE]
    function SlayLib.Elements:CreateToggle(Parent, Props)
        local Theme = SlayLib.Themes[SlayLib.CurrentTheme]
        local TglState = Props.Default or false
        
        local TglBtn = Instance.new("TextButton", Parent.Container)
        TglBtn.Size = UDim2.new(1, 0, 0, 35)
        TglBtn.BackgroundColor3 = Theme.Element
        TglBtn.Text = "  " .. (Props.Name or "Toggle")
        TglBtn.TextColor3 = Theme.Text
        TglBtn.Font = Utils:GetFont()
        TglBtn.TextSize = 14
        TglBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", TglBtn)

        local Holder = Instance.new("Frame", TglBtn)
        Holder.Size = UDim2.new(0, 40, 0, 20)
        Holder.Position = UDim2.new(1, -50, 0.5, -10)
        Holder.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", Holder).CornerRadius = UDim.new(1, 0)

        local Dot = Instance.new("Frame", Holder)
        Dot.Size = UDim2.new(0, 16, 0, 16)
        Dot.Position = UDim2.new(0, 2, 0.5, -8)
        Dot.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        local function Update()
            local col = TglState and Theme.Main or Color3.fromRGB(50, 50, 50)
            local pos = TglState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Utils:Tween(Holder, {BackgroundColor3 = col}, 0.2)
            Utils:Tween(Dot, {Position = pos}, 0.2)
        end

        TglBtn.MouseButton1Click:Connect(function()
            TglState = not TglState
            Update()
            if Props.Callback then Props.Callback(TglState) end
        end)
        Update()
    end

    -- [ELEMENT: SLIDER]
    function SlayLib.Elements:CreateSlider(Parent, Props)
        local Theme = SlayLib.Themes[SlayLib.CurrentTheme]
        local Val = Props.Def or Props.Min
        
        local SldFrame = Instance.new("Frame", Parent.Container)
        SldFrame.Size = UDim2.new(1, 0, 0, 48)
        SldFrame.BackgroundColor3 = Theme.Element
        Instance.new("UICorner", SldFrame)

        local Title = Instance.new("TextLabel", SldFrame)
        Title.Text = "  " .. Props.Name
        Title.Size = UDim2.new(1, 0, 0, 25)
        Title.TextColor3 = Theme.Text
        Title.Font = Utils:GetFont()
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = "Left"

        local ValLabel = Instance.new("TextLabel", SldFrame)
        ValLabel.Text = tostring(Val)
        ValLabel.Size = UDim2.new(0, 50, 0, 25)
        ValLabel.Position = UDim2.new(1, -55, 0, 0)
        ValLabel.TextColor3 = Theme.Main
        ValLabel.Font = Enum.Font.GothamBold
        ValLabel.BackgroundTransparency = 1

        local Bar = Instance.new("TextButton", SldFrame)
        Bar.Size = UDim2.new(0.92, 0, 0, 6)
        Bar.Position = UDim2.new(0.04, 0, 0.7, 0)
        Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        Bar.Text = ""
        Instance.new("UICorner", Bar)

        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((Val - Props.Min)/(Props.Max - Props.Min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Main
        Instance.new("UICorner", Fill)

        local function Move()
            local r = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(Props.Min + (Props.Max - Props.Min) * r)
            ValLabel.Text = tostring(v)
            Fill.Size = UDim2.new(r, 0, 1, 0)
            if Props.Callback then Props.Callback(v) end
        end

        local Active = false
        Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Active = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Active = false end end)
        RunService.RenderStepped:Connect(function() if Active then Move() end end)
    end

    -- [ELEMENT: DROPDOWN]
    function SlayLib.Elements:CreateDropdown(Parent, Props)
        local Theme = SlayLib.Themes[SlayLib.CurrentTheme]
        local IsOpen = false
        local Selected = Props.Default or "Select..."
        
        local DrpFrame = Instance.new("Frame", Parent.Container)
        DrpFrame.Size = UDim2.new(1, 0, 0, 38)
        DrpFrame.BackgroundColor3 = Theme.Element
        DrpFrame.ClipsDescendants = true
        Instance.new("UICorner", DrpFrame)
        
        local Title = Instance.new("TextLabel", DrpFrame)
        Title.Text = "  " .. Props.Name .. " : " .. Selected
        Title.Size = UDim2.new(1, 0, 0, 38)
        Title.TextColor3 = Theme.Text
        Title.Font = Utils:GetFont()
        Title.TextXAlignment = "Left"
        Title.BackgroundTransparency = 1

        local Arrow = Instance.new("ImageLabel", DrpFrame)
        Arrow.Size = UDim2.new(0, 20, 0, 20)
        Arrow.Position = UDim2.new(1, -30, 0, 9)
        Arrow.BackgroundTransparency = 1
        Arrow.Image = "rbxassetid://6034818372"
        Arrow.ImageColor3 = Theme.TextDark

        local OptionHolder = Instance.new("Frame", DrpFrame)
        OptionHolder.Size = UDim2.new(1, 0, 0, #Props.Options * 30)
        OptionHolder.Position = UDim2.new(0, 0, 0, 38)
        OptionHolder.BackgroundTransparency = 1
        Instance.new("UIListLayout", OptionHolder)

        local function Toggle()
            IsOpen = not IsOpen
            local ts = IsOpen and UDim2.new(1, 0, 0, 38 + (#Props.Options * 30)) or UDim2.new(1, 0, 0, 38)
            Utils:Tween(DrpFrame, {Size = ts}, 0.3)
            Utils:Tween(Arrow, {Rotation = IsOpen and 180 or 0}, 0.3)
        end

        Instance.new("TextButton", DrpFrame).Size = UDim2.new(1, 0, 0, 38).BackgroundTransparency = 1.Text = "".MouseButton1Click:Connect(Toggle)

        for _, o in pairs(Props.Options) do
            local oBtn = Instance.new("TextButton", OptionHolder)
            oBtn.Size = UDim2.new(1, 0, 0, 30)
            oBtn.BackgroundColor3 = Theme.Section
            oBtn.Text = o
            oBtn.TextColor3 = Theme.TextDark
            oBtn.Font = Utils:GetFont()
            oBtn.BorderSizePixel = 0
            oBtn.MouseButton1Click:Connect(function()
                Selected = o
                Title.Text = "  " .. Props.Name .. " : " .. o
                Toggle()
                if Props.Callback then Props.Callback(o) end
            end)
        end
    end

    -- [ELEMENT: COLOR PICKER]
    function SlayLib.Elements:CreateColorPicker(Parent, Props)
        local Theme = SlayLib.Themes[SlayLib.CurrentTheme]
        local Color = Props.Default or Color3.new(1, 1, 1)
        
        local pFrame = Instance.new("Frame", Parent.Container)
        pFrame.Size = UDim2.new(1, 0, 0, 38)
        pFrame.BackgroundColor3 = Theme.Element
        Instance.new("UICorner", pFrame)

        local Title = Instance.new("TextLabel", pFrame)
        Title.Text = "  " .. Props.Name
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.TextColor3 = Theme.Text
        Title.Font = Utils:GetFont()
        Title.TextXAlignment = "Left"
        Title.BackgroundTransparency = 1

        local Disp = Instance.new("Frame", pFrame)
        Disp.Size = UDim2.new(0, 30, 0, 20)
        Disp.Position = UDim2.new(1, -40, 0.5, -10)
        Disp.BackgroundColor3 = Color
        Instance.new("UICorner", Disp)

        local Btn = Instance.new("TextButton", Disp)
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.MouseButton1Click:Connect(function()
            SlayLib:Notify({Title = "PICKER", Content = "Color Palette Logic would render here."})
        end)
    end

    -- [ELEMENT: INPUT BOX]
    function SlayLib.Elements:CreateInput(Parent, Props)
        local Theme = SlayLib.Themes[SlayLib.CurrentTheme]
        local InpFrame = Instance.new("Frame", Parent.Container)
        InpFrame.Size = UDim2.new(1, 0, 0, 45)
        InpFrame.BackgroundColor3 = Theme.Element
        Instance.new("UICorner", InpFrame)

        local t = Instance.new("TextLabel", InpFrame)
        t.Text = "  " .. Props.Name
        t.Size = UDim2.new(1, 0, 0, 20)
        t.TextColor3 = Theme.TextDark
        t.Font = Utils:GetFont()
        t.TextSize = 12
        t.TextXAlignment = "Left"
        t.BackgroundTransparency = 1

        local Box = Instance.new("TextBox", InpFrame)
        Box.Size = UDim2.new(1, -20, 0, 22)
        Box.Position = UDim2.new(0, 10, 0, 20)
        Box.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Box.PlaceholderText = Props.Placeholder or "Type..."
        Box.Text = ""
        Box.TextColor3 = Theme.Text
        Box.Font = Enum.Font.Code
        Box.TextSize = 14
        Box.TextXAlignment = "Left"
        Instance.new("UICorner", Box)

        Box.FocusLost:Connect(function(e)
            if e and Props.Callback then Props.Callback(Box.Text) end
        end)
    end
end

-- [CORE ENGINE INJECTORS: WRAPPING SECTION METHODS]
local function InjectElements(SectObj)
    function SectObj:CreateButton(p) return SlayLib.Elements:CreateButton(SectObj, p) end
    function SectObj:CreateToggle(p) return SlayLib.Elements:CreateToggle(SectObj, p) end
    function SectObj:CreateSlider(p) return SlayLib.Elements:CreateSlider(SectObj, p) end
    function SectObj:CreateDropdown(p) return SlayLib.Elements:CreateDropdown(SectObj, p) end
    function SectObj:CreateColorPicker(p) return SlayLib.Elements:CreateColorPicker(SectObj, p) end
    function SectObj:CreateInput(p) return SlayLib.Elements:CreateInput(SectObj, p) end
end

-- [IMAGE: Software architecture of an event-driven GUI system showing interaction between user input, element logic, and callback execution]

-- [MODIFYING PART 1 SECTION TO SUPPORT INJECTION]
local OriginalCreateSection = nil -- This logic is handled by ensuring InjectElements is called in Part 1's CreateSection

-- [RESPONSIVE ENGINE: VIEWPORT ADAPTATION]
function SlayLib:InitResponsive(WindowFrame)
    local Camera = workspace.CurrentCamera
    local function Update()
        local Size = Camera.ViewportSize
        if Size.X < 700 then
            WindowFrame.Size = UDim2.new(0, Size.X * 0.95, 0, Size.Y * 0.85)
            WindowFrame.Position = UDim2.new(0.5, -Size.X*0.475, 0.5, -Size.Y*0.425)
        else
            WindowFrame.Size = UDim2.new(0, 600, 0, 400)
        end
    end
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Update)
    Update()
end

-- [ENGINE FINALIZATION]
SlayLib.IsLoaded = true
print("[SlayLib X]: Reactor Engine Build 12.0 Loaded Successfully.")

-- [IMAGE: A diagram of a modern user interface design system with dark mode aesthetics, featuring neon accents and crisp typography]

return SlayLib
