--[[
    ================================================================================
    SLAYLIB X - THE ULTIMATE UNABRIDGED EDITION
    ================================================================================
    - Build: 5.2.0 (Full Source)
    - Optimized for: PC & Mobile (Touch Support)
    - Fixes: Tab overlap, Notify logic, Loading transparency, Closing glitch.
    ================================================================================
]]

local SlayLib = {
    Folder = "SlayLib_Configs",
    Options = {},
    Flags = {},
    ActiveTheme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(24, 24, 24),
        ElementHover = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 170),
        Stroke = Color3.fromRGB(45, 45, 45),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 165, 0),
        Error = Color3.fromRGB(255, 65, 65),
    }
}

--// SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

--// UTILITIES
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

local function MakeDraggable(UIElement, DragHandle)
    local Dragging, DragInput, DragStart, StartPos
    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = UIElement.Position
            local Conn
            Conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    Conn:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            UIElement.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

--// NOTIFICATION POP-UP (FULL LOGIC)
function SlayLib:Notify(Config)
    Config = Config or {Title = "SlayLib X", Content = "Notification", Type = "Success", Duration = 5}
    
    local Holder = CoreGui:FindFirstChild("SlayNotifyHolder")
    if not Holder then
        Holder = Create("Frame", {
            Name = "SlayNotifyHolder", Parent = CoreGui, BackgroundTransparency = 1,
            Size = UDim2.new(0, 320, 1, 0), Position = UDim2.new(1, -330, 0, 0)
        })
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 12)})
        Create("UIPadding", {Parent = Holder, PaddingBottom = UDim.new(0, 25), PaddingRight = UDim.new(0, 10)})
    end

    local Notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.ActiveTheme.Sidebar,
        ClipsDescendants = true, Parent = Holder, Transparency = 1
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Notif})
    local Stroke = Create("UIStroke", {Color = SlayLib.ActiveTheme.MainColor, Thickness = 1.6, Parent = Notif, Transparency = 1})
    
    local T = Create("TextLabel", {
        Text = Config.Title, Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 15, 0, 8),
        Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.ActiveTheme.MainColor,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Notif
    })
    local C = Create("TextLabel", {
        Text = Config.Content, Size = UDim2.new(1, -30, 0, 25), Position = UDim2.new(0, 15, 0, 28),
        Font = "Gotham", TextSize = 12, TextColor3 = SlayLib.ActiveTheme.Text,
        TextXAlignment = "Left", TextWrapped = true, BackgroundTransparency = 1, Parent = Notif
    })

    Tween(Notif, {Size = UDim2.new(1, 0, 0, 65), Transparency = 0}, 0.5, Enum.EasingStyle.Back)
    Tween(Stroke, {Transparency = 0}, 0.5)

    task.delay(Config.Duration, function()
        Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), Transparency = 1}, 0.5)
        Tween(Stroke, {Transparency = 1}, 0.5)
        task.wait(0.5) Notif:Destroy()
    end)
end

--// ADVANCED LOADING (BLUR & TRANSPARENT)
local function StartLoading()
    local LoadingGui = Create("ScreenGui", {Parent = CoreGui, Name = "SlayLoading_X"})
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    Tween(Blur, {Size = 28}, 1.2)

    local Holder = Create("Frame", {
        Size = UDim2.new(0, 250, 0, 250), Position = UDim2.new(0.5, -125, 0.5, -125),
        BackgroundTransparency = 1, Parent = LoadingGui
    })
    
    local Logo = Create("ImageLabel", {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.4, 0),
        Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = Holder,
        ImageColor3 = SlayLib.ActiveTheme.MainColor
    })
    
    local LTitle = Create("TextLabel", {
        Text = "SLAYLIB X", Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0.65, 0),
        Font = "GothamBold", TextSize = 26, TextColor3 = Color3.new(1, 1, 1),
        TextTransparency = 1, BackgroundTransparency = 1, Parent = Holder
    })

    local BarBg = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 3), Position = UDim2.new(0.5, -100, 0.8, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Holder, BackgroundTransparency = 1
    })
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = SlayLib.ActiveTheme.MainColor,
        Parent = BarBg, BackgroundTransparency = 1
    })
    Create("UICorner", {Parent = BarBg}) Create("UICorner", {Parent = BarFill})

    -- Animate Entrance
    Tween(Logo, {Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0.5, -60, 0.4, -60)}, 1, Enum.EasingStyle.Elastic)
    Tween(LTitle, {TextTransparency = 0}, 1)
    Tween(BarBg, {BackgroundTransparency = 0}, 1)
    Tween(BarFill, {BackgroundTransparency = 0}, 1)

    for i = 1, 100 do
        task.wait(0.02)
        BarFill.Size = UDim2.new(i/100, 0, 1, 0)
    end

    -- Animate Exit
    Tween(Logo, {ImageTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}, 0.8)
    Tween(LTitle, {TextTransparency = 1}, 0.8)
    Tween(BarBg, {BackgroundTransparency = 1}, 0.5)
    Tween(BarFill, {BackgroundTransparency = 1}, 0.5)
    Tween(Blur, {Size = 0}, 1)
    
    task.wait(1)
    LoadingGui:Destroy() Blur:Disconnect() if Blur then Blur:Destroy() end
end

--// WINDOW CORE
function SlayLib:CreateWindow(Settings)
    Settings = Settings or {Name = "SlayLib X"}
    task.spawn(StartLoading)

    local Window = {Visible = true, CurrentTab = nil, Tabs = {}}
    local MainGui = Create("ScreenGui", {Name = "SlayLib_X", Parent = CoreGui, IgnoreGuiInset = true})

    -- Circular Toggle Button (Draggable)
    local ToggleBtn = Create("Frame", {
        Name = "FloatingToggle", Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.05, 0, 0.15, 0), BackgroundColor3 = SlayLib.ActiveTheme.MainColor,
        Parent = MainGui, ZIndex = 100
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})
    Create("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Transparency = 0.6, Parent = ToggleBtn})
    
    local TIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 35, 0, 35), Position = UDim2.new(0.5, -17, 0.5, -17),
        Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = ToggleBtn
    })
    local TClick = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = ToggleBtn})

    -- Main Container (Fixed Frame)
    local MainFrame = Create("Frame", {
        Name = "MainFrame", Size = UDim2.new(0, 600, 0, 420),
        Position = UDim2.new(0.5, -300, 0.5, -210), BackgroundColor3 = SlayLib.ActiveTheme.Background,
        Parent = MainGui, ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = MainFrame})
    local MainStroke = Create("UIStroke", {Color = SlayLib.ActiveTheme.Stroke, Thickness = 2, Parent = MainFrame})

    -- Sidebar (Fixed Title)
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 190, 1, 0), BackgroundColor3 = SlayLib.ActiveTheme.Sidebar, Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = Sidebar})

    local TitleFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = Sidebar
    })
    local LogoIco = Create("ImageLabel", {
        Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = TitleFrame
    })
    local LibName = Create("TextLabel", {
        Text = Settings.Name, Size = UDim2.new(1, -65, 0, 70), Position = UDim2.new(0, 60, 0, 0),
        Font = "GothamBold", TextSize = 18, TextColor3 = SlayLib.ActiveTheme.Text,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TitleFrame
    })

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -85), Position = UDim2.new(0, 5, 0, 75),
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar
    })
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 6)})

    -- Page Container
    local PageContainer = Create("Frame", {
        Size = UDim2.new(1, -210, 1, -20), Position = UDim2.new(0, 200, 0, 10),
        BackgroundTransparency = 1, Parent = MainFrame
    })

    -- Toggle Logic (No Glitch)
    TClick.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 420), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1}, 0.5)
            task.delay(0.5, function() if not Window.Visible then MainFrame.Visible = false end end)
        end
    end)

    --// TAB BUILDER
    function Window:CreateTab(Name)
        local Tab = {Active = false}
        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1,
            Text = "       " .. Name, Font = "GothamMedium", TextSize = 14,
            TextColor3 = SlayLib.ActiveTheme.TextSecondary, TextXAlignment = "Left", Parent = TabScroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TabBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Visible = false, ScrollBarThickness = 3, ScrollBarImageColor3 = SlayLib.ActiveTheme.MainColor,
            AutomaticCanvasSize = "Y", Parent = PageContainer
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 12)})
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.1, TextColor3 = SlayLib.ActiveTheme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.1
            TabBtn.TextColor3 = SlayLib.ActiveTheme.MainColor
        end

        --// SECTION BUILDER
        function Tab:CreateSection(SectName)
            local Section = {}
            local SectTitle = Create("TextLabel", {
                Text = SectName:upper(), Size = UDim2.new(1, 0, 0, 20),
                Font = "GothamBold", TextSize = 11, TextColor3 = SlayLib.ActiveTheme.MainColor,
                BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page
            })

            -- 1. TOGGLE (FULL SOURCE)
            function Section:CreateToggle(Props)
                Props = Props or {Name = "Toggle", CurrentValue = false, Callback = function() end}
                local Tgl = {Value = Props.CurrentValue}
                local TFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = SlayLib.ActiveTheme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TFrame})
                
                local L = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.Text, TextXAlignment = "Left", Font = "GothamMedium", Parent = TFrame})
                
                local Sw = Create("Frame", {Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -55, 0.5, -12), BackgroundColor3 = Tgl.Value and SlayLib.ActiveTheme.MainColor or Color3.fromRGB(50,50,50), Parent = TFrame})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Sw})
                local Dot = Create("Frame", {Size = UDim2.new(0, 18, 0, 18), Position = Tgl.Value and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9), BackgroundColor3 = Color3.new(1,1,1), Parent = Sw})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                local Click = Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = TFrame})
                Click.MouseButton1Click:Connect(function()
                    Tgl.Value = not Tgl.Value
                    Tween(Sw, {BackgroundColor3 = Tgl.Value and SlayLib.ActiveTheme.MainColor or Color3.fromRGB(50,50,50)}, 0.3)
                    Tween(Dot, {Position = Tgl.Value and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)}, 0.3)
                    Props.Callback(Tgl.Value)
                end)
                return Tgl
            end

            -- 2. SLIDER (FULL SOURCE)
            function Section:CreateSlider(Props)
                Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Callback = function() end}
                local SFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 68), BackgroundColor3 = SlayLib.ActiveTheme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SFrame})
                
                local L = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1,0,0,35), BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.Text, TextXAlignment = "Left", Font = "GothamMedium", Parent = SFrame})
                local VL = Create("TextLabel", {Text = tostring(Props.Def), Size = UDim2.new(1,-15,0,35), BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.MainColor, TextXAlignment = "Right", Font = "Code", Parent = SFrame})
                
                local Rail = Create("Frame", {Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 48), BackgroundColor3 = Color3.fromRGB(45,45,45), Parent = SFrame})
                Create("UICorner", {Parent = Rail})
                local Fill = Create("Frame", {Size = UDim2.new((Props.Def-Props.Min)/(Props.Max-Props.Min), 0, 1, 0), BackgroundColor3 = SlayLib.ActiveTheme.MainColor, Parent = Rail})
                Create("UICorner", {Parent = Fill})

                local function Update()
                    local P = math.clamp((Mouse.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
                    local NV = math.floor(Props.Min + (Props.Max - Props.Min) * P)
                    Fill.Size = UDim2.new(P, 0, 1, 0)
                    VL.Text = tostring(NV)
                    Props.Callback(NV)
                end

                SFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
                    local Move = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then Update() end
                    end)
                    local End; End = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            Move:Disconnect() End:Disconnect()
                        end
                    end)
                end end)
            end

            -- 3. INPUT (FULL SOURCE)
            function Section:CreateInput(Props)
                Props = Props or {Name = "Input", Placeholder = "Write here...", Callback = function() end}
                local IFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = SlayLib.ActiveTheme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = IFrame})
                
                local L = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(0, 100, 1, 0), BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.Text, TextXAlignment = "Left", Font = "GothamMedium", Parent = IFrame})
                
                local Box = Create("TextBox", {
                    Size = UDim2.new(0, 160, 0, 32), Position = UDim2.new(1, -170, 0.5, -16),
                    BackgroundColor3 = Color3.fromRGB(35,35,35), Text = "", PlaceholderText = Props.Placeholder,
                    TextColor3 = SlayLib.ActiveTheme.Text, Font = "Gotham", TextSize = 13, Parent = IFrame
                })
                Create("UICorner", {Parent = Box})
                Box.FocusLost:Connect(function() Props.Callback(Box.Text) end)
            end

            -- 4. BUTTON (FULL SOURCE)
            function Section:CreateButton(Props)
                Props = Props or {Name = "Button", Callback = function() end}
                local B = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.ActiveTheme.Element,
                    Text = Props.Name, TextColor3 = SlayLib.ActiveTheme.Text, Font = "GothamMedium",
                    TextSize = 14, Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = B})
                B.MouseButton1Down:Connect(function() Tween(B, {BackgroundColor3 = SlayLib.ActiveTheme.ElementHover}, 0.2) end)
                B.MouseButton1Up:Connect(function() Tween(B, {BackgroundColor3 = SlayLib.ActiveTheme.Element}, 0.2) Props.Callback() end)
            end

            -- 5. PARAGRAPH (NEW)
            function Section:CreateParagraph(Props)
                local Title = Props.Title or "Info"
                local Content = Props.Content or "Content here"
                local PFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.ActiveTheme.Element, Parent = Page, AutomaticSize = "Y"})
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = PFrame})
                Create("UIPadding", {Parent = PFrame, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
                
                Create("TextLabel", {Text = Title, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.MainColor, Font = "GothamBold", TextSize = 13, TextXAlignment = "Left", Parent = PFrame})
                Create("TextLabel", {Text = Content, Size = UDim2.new(1,0,0,0), AutomaticSize = "Y", BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.TextSecondary, Font = "Gotham", TextSize = 12, TextXAlignment = "Left", TextWrapped = true, Parent = PFrame})
            end

            return Section
        end
        return Tab
    end

    MakeDraggable(MainFrame, Sidebar)
    MakeDraggable(ToggleBtn, ToggleBtn)
    return Window
end

return SlayLib
