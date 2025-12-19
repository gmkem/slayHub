local SlayLib = {
    Folder = "SlayLib_Config",
    Settings = {},
    Flags = {},
    Signals = {},
    ThemeObjects = {}, -- ระบบใหม่สำหรับ Real-time Theme Update
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(25, 25, 25),
        ElementHover = Color3.fromRGB(32, 32, 32),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 165, 0),
        Error = Color3.fromRGB(255, 65, 65),
    },
    Icons = {
        Logo = "rbxassetid://13589839447",
        Check = "rbxassetid://10734895530",
        Chevron = "rbxassetid://10734895856",
        Search = "rbxassetid://10734897102",
        Folder = "rbxassetid://10734897484"
    }
}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--// Env
local LocalPlayer = Players.LocalPlayer
local Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)

--// Utils
if not isfolder(SlayLib.Folder) then makefolder(SlayLib.Folder) end

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function Tween(obj, goal, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), goal)
    t:Play()
    return t
end

local function ApplyTextLogic(label, content, maxSize)
    label.Text = content
    label.TextWrapped = true
    label.TextSize = maxSize or 14
    local function Adjust()  
        label.TextScaled = (label.TextBounds.X > label.AbsoluteSize.X or label.TextBounds.Y > label.AbsoluteSize.Y)
    end  
    label:GetPropertyChangedSignal("AbsoluteSize"):Connect(Adjust)  
    Adjust()
end

--// [SYSTEM] Theme Engine (New)
function SlayLib:UpdateTheme(NewColor)
    self.Theme.MainColor = NewColor
    for obj, type in pairs(self.ThemeObjects) do
        if obj and obj.Parent then
            if type == "Background" then Tween(obj, {BackgroundColor3 = NewColor}, 0.3)
            elseif type == "Text" then Tween(obj, {TextColor3 = NewColor}, 0.3)
            elseif type == "Stroke" then Tween(obj, {Color = NewColor}, 0.3)
            elseif type == "Image" then Tween(obj, {ImageColor3 = NewColor}, 0.3) end
        end
    end
end

--// [SYSTEM] Notification Engine (Upgraded)
function SlayLib:Notify(Config)
    Config = Config or {Title = "Notification", Content = "Message", Duration = 5, Type = "Neutral"}
    local Holder = Parent:FindFirstChild("SlayNotificationProvider")  
    if not Holder then  
        Holder = Create("Frame", {Name = "SlayNotificationProvider", Parent = Parent, BackgroundTransparency = 1, Size = UDim2.new(0, 320, 1, -40), Position = UDim2.new(1, -330, 0, 20)})  
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 10)})  
    end  
    local NotifColor = (Config.Type == "Success" and self.Theme.Success) or (Config.Type == "Error" and self.Theme.Error) or (Config.Type == "Warning" and self.Theme.Warning) or self.Theme.MainColor
    
    local Frame = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = self.Theme.Sidebar, ClipsDescendants = true, Parent = Holder})
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Frame})
    local Stroke = Create("UIStroke", {Color = NotifColor, Thickness = 1.8, Parent = Frame})
    
    local Tl = Create("TextLabel", {Size = UDim2.new(1, -30, 0, 25), Position = UDim2.new(0, 15, 0, 8), Font = "GothamBold", TextColor3 = NotifColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Frame})
    ApplyTextLogic(Tl, Config.Title, 14)
    local Cl = Create("TextLabel", {Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 28), Font = "Gotham", TextColor3 = self.Theme.Text, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Frame})
    ApplyTextLogic(Cl, Config.Content, 12)

    Tween(Frame, {Size = UDim2.new(1, 0, 0, 75)}, 0.4, Enum.EasingStyle.Back)
    task.delay(Config.Duration, function()
        Tween(Frame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
        task.wait(0.4) Frame:Destroy()
    end)
end

--// [SYSTEM] Loading Sequence (Full Logic)
local function ExecuteLoadingSequence()
    local Screen = Create("ScreenGui", {Name = "SlayLoadingEnv", Parent = Parent})
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    local Holder = Create("Frame", {Size = UDim2.new(0, 400, 0, 400), Position = UDim2.new(0.5, -200, 0.5, -200), BackgroundTransparency = 1, Parent = Screen})
    local Logo = Create("ImageLabel", {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.45, 0), Image = SlayLib.Icons.Logo, ImageColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, Parent = Holder})
    local InfoLabel = Create("TextLabel", {Text = "INITIALIZING...", Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.75, 0), Font = "Code", TextSize = 12, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, Parent = Holder, TextTransparency = 1})
    local BarBg = Create("Frame", {Size = UDim2.new(0, 250, 0, 4), Position = UDim2.new(0.5, -125, 0.7, 0), BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Holder, BackgroundTransparency = 1})
    local BarFill = Create("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = BarBg})
    Create("UICorner", {Parent = BarBg}) Create("UICorner", {Parent = BarFill})

    Tween(Blur, {Size = 28}, 1)
    Tween(Logo, {Size = UDim2.new(0, 140, 0, 140), Position = UDim2.new(0.5, -70, 0.45, -70)}, 1.2, Enum.EasingStyle.Elastic)
    task.wait(0.6)
    Tween(InfoLabel, {TextTransparency = 0}, 0.5)
    Tween(BarBg, {BackgroundTransparency = 0}, 0.5)

    local Steps = {"AUTHENTICATING...", "LOADING ELEMENTS...", "APPLYING THEMES...", "READY!"}  
    for i, step in ipairs(Steps) do  
        InfoLabel.Text = step
        Tween(BarFill, {Size = UDim2.new(i/#Steps, 0, 1, 0)}, 0.4)  
        task.wait(math.random(4, 8) / 10)  
    end  

    Tween(Logo, {ImageTransparency = 1}, 0.6)
    Tween(Blur, {Size = 0}, 0.8)
    task.wait(0.8) Screen:Destroy() Blur:Destroy()
end

--// [SYSTEM] Dragging Logic
local function RegisterDrag(Frame, Handle)
    local Dragging, DragInput, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
            Dragging = true DragStart = input.Position StartPos = Frame.Position  
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)  
        end  
    end)  
    UserInputService.InputChanged:Connect(function(input)  
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
            local Delta = input.Position - DragStart  
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)  
        end  
    end)
end

--// [MAIN] WINDOW CONSTRUCTOR
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib Ultimate"}
    ExecuteLoadingSequence()

    local Window = {Toggled = true, CurrentTab = nil}
    local CoreGuiFrame = Create("ScreenGui", {Name = "SlayLib_X_Engine", Parent = Parent})  

    -- Floating Icon
    local FloatingToggle = Create("Frame", {Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0.05, 0, 0.2, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = CoreGuiFrame, ZIndex = 50})  
    SlayLib.ThemeObjects[FloatingToggle] = "Background"
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingToggle})  
    local ToggleIcon = Create("ImageLabel", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0.5, -16, 0.5, -16), Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = FloatingToggle})  
    local ToggleButton = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = FloatingToggle})  

    -- Main Hub
    local MainFrame = Create("Frame", {Size = UDim2.new(0, 620, 0, 440), Position = UDim2.new(0.5, -310, 0.5, -220), BackgroundColor3 = SlayLib.Theme.Background, Parent = CoreGuiFrame, ClipsDescendants = true})  
    Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = MainFrame})  
    local MainStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 2, Parent = MainFrame})

    local Sidebar = Create("Frame", {Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame})  
    Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = Sidebar})  

    local LibTitle = Create("TextLabel", {Size = UDim2.new(1, -20, 0, 80), Position = UDim2.new(0, 20, 0, 0), Font = "GothamBold", TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Sidebar})  
    ApplyTextLogic(LibTitle, Config.Name, 20)  

    local TabScroll = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -100), Position = UDim2.new(0, 0, 0, 90), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar, AutomaticCanvasSize = "Y"})  
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 8), HorizontalAlignment = "Center"})  

    local PageContainer = Create("Frame", {Size = UDim2.new(1, -230, 1, -40), Position = UDim2.new(0, 215, 0, 20), BackgroundTransparency = 1, Parent = MainFrame})  

    ToggleButton.MouseButton1Click:Connect(function()  
        Window.Toggled = not Window.Toggled  
        Tween(MainFrame, {Size = Window.Toggled and UDim2.new(0, 620, 0, 440) or UDim2.new(0,0,0,0), BackgroundTransparency = Window.Toggled and 0 or 1}, 0.5)  
    end)  
    RegisterDrag(MainFrame, LibTitle) RegisterDrag(FloatingToggle, FloatingToggle)

    --// TAB CREATOR
    function Window:CreateTab(Name, IconID)  
        local Tab = {}
        local TabBtn = Create("TextButton", {Size = UDim2.new(0, 180, 0, 45), BackgroundColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, Text = "", Parent = TabScroll})  
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TabBtn})  
        local TabLbl = Create("TextLabel", {Text = Name, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 45, 0, 0), Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TabBtn})  
        local TabIcon = Create("ImageLabel", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 15, 0.5, -10), Image = IconID or SlayLib.Icons.Folder, BackgroundTransparency = 1, ImageColor3 = SlayLib.Theme.TextSecondary, Parent = TabBtn})  

        local Page = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, Parent = PageContainer, AutomaticCanvasSize = "Y"})  
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 12)})  

        TabBtn.MouseButton1Click:Connect(function()  
            if Window.CurrentTab then  
                Window.CurrentTab.Page.Visible = false  
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1}, 0.3)  
                Tween(Window.CurrentTab.Lbl, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)  
            end  
            Window.CurrentTab = {Page = Page, Btn = TabBtn, Lbl = TabLbl}  
            Page.Visible = true  
            Tween(TabBtn, {BackgroundTransparency = 0.15}, 0.3)  
            Tween(TabLbl, {TextColor3 = SlayLib.Theme.MainColor}, 0.3)  
        end)  
        if not Window.CurrentTab then TabBtn.MouseButton1Click() end

        --// SECTION CREATOR
        function Tab:CreateSection(SName)  
            local Section = {}  
            local SectLabel = Create("TextLabel", {Text = SName:upper(), Size = UDim2.new(1, 0, 0, 30), Font = "GothamBold", TextSize = 12, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page})  
            SlayLib.ThemeObjects[SectLabel] = "Text"

            -- [1] TOGGLE
            function Section:CreateToggle(Props)
                local TState = Props.CurrentValue or false
                local TContainer = Create("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TContainer})
                local TLbl = Create("TextLabel", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 15, 0, 0), Font = "GothamMedium", TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TContainer})
                ApplyTextLogic(TLbl, Props.Name, 15)
                local Switch = Create("Frame", {Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -60, 0.5, -12), BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(50,50,50), Parent = TContainer})
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Switch})
                local Dot = Create("Frame", {Size = UDim2.new(0,18,0,18), Position = TState and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9), BackgroundColor3 = Color3.new(1,1,1), Parent = Switch})
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Dot})
                
                Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = TContainer}).MouseButton1Click:Connect(function()
                    TState = not TState
                    SlayLib.Flags[Props.Flag] = TState
                    Tween(Switch, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(50,50,50)}, 0.3)
                    Tween(Dot, {Position = TState and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)}, 0.3)
                    task.spawn(Props.Callback, TState)
                end)
            end

            -- [2] SLIDER
            function Section:CreateSlider(Props)
                local Value = Props.Def
                local SContainer = Create("Frame", {Size = UDim2.new(1, 0, 0, 75), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SContainer})
                local SLbl = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1, -100, 0, 40), Font = "GothamMedium", TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = SContainer})
                local Bar = Create("Frame", {Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 55), BackgroundColor3 = Color3.fromRGB(45,45,45), Parent = SContainer})
                local Fill = Create("Frame", {Size = UDim2.new((Value-Props.Min)/(Props.Max-Props.Min), 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = Bar})
                SlayLib.ThemeObjects[Fill] = "Background"
                
                local function Update(Input)
                    local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Value = math.floor(Props.Min + (Props.Max - Props.Min) * P)
                    Fill.Size = UDim2.new(P, 0, 1, 0)
                    task.spawn(Props.Callback, Value)
                end
                Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Update(i) end end)
            end

            -- [3] DROPDOWN
            function Section:CreateDropdown(Props)
                local IsOpen = false
                local DContainer = Create("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element, ClipsDescendants = true, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = DContainer})
                local DLbl = Create("TextLabel", {Text = "  " .. Props.Name, Size = UDim2.new(1, -50, 0, 52), Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = DContainer})
                
                Create("TextButton", {Size = UDim2.new(1,0,0,52), BackgroundTransparency = 1, Text = "", Parent = DContainer}).MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    Tween(DContainer, {Size = UDim2.new(1, 0, 0, IsOpen and 150 or 52)}, 0.4)
                end)
            end

            -- [4] NEW: COLOR PICKER (Real-time)
            function Section:CreateColorPicker(Props)
                local Color = Props.Default or SlayLib.Theme.MainColor
                local CPContainer = Create("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = CPContainer})
                local CLbl = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1, -60, 1, 0), Font = "Gotham", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = CPContainer})
                local ColorDisp = Create("Frame", {Size = UDim2.new(0, 35, 0, 22), Position = UDim2.new(1, -50, 0.5, -11), BackgroundColor3 = Color, Parent = CPContainer})
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ColorDisp})
                
                local PickerFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Element, ClipsDescendants = true, Parent = Page})
                local HueBar = Create("ImageLabel", {Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 10), Image = "rbxassetid://2320468862", Parent = PickerFrame})
                
                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local P = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                        local NewCol = Color3.fromHSV(P, 0.8, 1)
                        ColorDisp.BackgroundColor3 = NewCol
                        if Props.IsThemePicker then SlayLib:UpdateTheme(NewCol) end
                        task.spawn(Props.Callback, NewCol)
                    end
                end)
                
                Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = CPContainer}).MouseButton1Click:Connect(function()
                    Tween(PickerFrame, {Size = PickerFrame.Size.Y.Offset == 0 and UDim2.new(1, 0, 0, 35) or UDim2.new(1, 0, 0, 0)}, 0.3)
                end)
            end

            -- [5] BUTTON
            function Section:CreateButton(Props)
                local BFrame = Create("TextButton", {Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = SlayLib.Theme.Element, Text = Props.Name, Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.Theme.Text, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = BFrame})
                BFrame.MouseButton1Click:Connect(Props.Callback)
            end

            -- [6] INPUT
            function Section:CreateInput(Props)
                local IContainer = Create("Frame", {Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = IContainer})
                local Box = Create("TextBox", {Size = UDim2.new(0, 180, 0, 32), Position = UDim2.new(1, -195, 0.5, -16), BackgroundColor3 = Color3.fromRGB(35, 35, 35), PlaceholderText = Props.Placeholder, Text = "", TextColor3 = SlayLib.Theme.Text, Font = "Gotham", Parent = IContainer})
                Box.FocusLost:Connect(function() task.spawn(Props.Callback, Box.Text) end)
            end

            return Section  
        end  
        return Tab  
    end  
    return Window
end

--// AUTO-SAVE LOGIC
function SlayLib:SaveConfig(Name)
    local Data = HttpService:JSONEncode(SlayLib.Flags)
    writefile(SlayLib.Folder .. "/" .. Name .. ".json", Data)
    SlayLib:Notify({Title = "System", Content = "Config Saved!", Type = "Success"})
end

return SlayLib
