--[[
    ================================================================================
    SLAYLIB X - THE MEGA EXTENDED SOURCE (UNABRIDGED)
    ================================================================================
    - UI Version: 5.5.0
    - Logic: Full Detailed Implementation (Derived from Luna/Material concepts)
    - Fixes: Tab overlap, Notify pop-up, Transparent blur loading, Closing glitch.
    ================================================================================
]]

local SlayLib = {
    Folder = "SlayLib_Storage",
    Options = {},
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(10, 10, 10),
        Sidebar = Color3.fromRGB(15, 15, 15),
        Element = Color3.fromRGB(22, 22, 22),
        ElementHover = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 170),
        Stroke = Color3.fromRGB(40, 40, 40),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 165, 0),
        Error = Color3.fromRGB(255, 65, 65),
    },
    Connections = {},
    Icons = {
        Logo = "rbxassetid://13589839447",
        Chevron = "rbxassetid://10734895530",
        Circle = "rbxassetid://10734895856"
    }
}

--// SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

--// UTILITIES (FULL DETAILED LOGIC)
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

-- ระบบ Drag ที่เขียนแบบละเอียด (ดักจับ Delta และรองรับ Mobile 100%)
local function MakeDraggable(UIElement, DragHandle)
    local Dragging, DragInput, DragStart, StartPos
    
    local function Update(input)
        local Delta = input.Position - DragStart
        UIElement.Position = UDim2.new(
            StartPos.X.Scale, 
            StartPos.X.Offset + Delta.X, 
            StartPos.Y.Scale, 
            StartPos.Y.Offset + Delta.Y
        )
    end

    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = UIElement.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    DragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

--// NOTIFICATION POP-UP (STACKABLE LOGIC)
function SlayLib:Notify(Config)
    Config = Config or {Title = "SlayLib X", Content = "Notification Test", Duration = 5}
    
    local Holder = CoreGui:FindFirstChild("SlayNotificationProvider")
    if not Holder then
        Holder = Create("Frame", {
            Name = "SlayNotificationProvider", Parent = CoreGui, BackgroundTransparency = 1,
            Size = UDim2.new(0, 320, 1, -40), Position = UDim2.new(1, -330, 0, 20)
        })
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 12)})
    end

    local Notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Sidebar,
        ClipsDescendants = true, Parent = Holder, Transparency = 1
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Notif})
    local Stroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.6, Parent = Notif, Transparency = 1})

    local Accent = Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = Notif
    })
    Create("UICorner", {Parent = Accent})

    local TitleLabel = Create("TextLabel", {
        Text = Config.Title, Size = UDim2.new(1, -50, 0, 25), Position = UDim2.new(0, 15, 0, 8),
        Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.Theme.MainColor,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Notif
    })
    
    local ContentLabel = Create("TextLabel", {
        Text = Config.Content, Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 26),
        Font = "Gotham", TextSize = 12, TextColor3 = SlayLib.Theme.Text,
        TextXAlignment = "Left", TextWrapped = true, BackgroundTransparency = 1, Parent = Notif
    })

    -- Entrance Animation
    Tween(Notif, {Size = UDim2.new(1, 0, 0, 65), Transparency = 0}, 0.5, Enum.EasingStyle.Back)
    Tween(Stroke, {Transparency = 0}, 0.5)

    task.delay(Config.Duration, function()
        Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), Transparency = 1}, 0.5)
        Tween(Stroke, {Transparency = 1}, 0.5)
        task.wait(0.5)
        Notif:Destroy()
    end)
end

--// LOADING ENGINE (TRANSPARENT BLUR)
local function RunLoadingEffect()
    local LoadGui = Create("ScreenGui", {Name = "SlayLoader", Parent = CoreGui})
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    
    local Holder = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 300), Position = UDim2.new(0.5, -150, 0.5, -150),
        BackgroundTransparency = 1, Parent = LoadGui
    })

    local Logo = Create("ImageLabel", {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.45, 0),
        Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = Holder,
        ImageColor3 = SlayLib.Theme.MainColor
    })

    local BarBg = Create("Frame", {
        Size = UDim2.new(0, 220, 0, 4), Position = UDim2.new(0.5, -110, 0.7, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Holder, BackgroundTransparency = 1
    })
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor,
        Parent = BarBg, BackgroundTransparency = 1
    })
    Create("UICorner", {Parent = BarBg}) Create("UICorner", {Parent = BarFill})

    -- Step 1: Fade In & Blur
    Tween(Blur, {Size = 25}, 1)
    Tween(Logo, {Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0.5, -60, 0.45, -60)}, 1.2, Enum.EasingStyle.Elastic)
    task.wait(0.5)
    Tween(BarBg, {BackgroundTransparency = 0}, 0.5)
    Tween(BarFill, {BackgroundTransparency = 0}, 0.5)

    -- Step 2: Progress Simulation
    for i = 1, 100 do
        BarFill.Size = UDim2.new(i/100, 0, 1, 0)
        task.wait(math.random(1, 5)/100)
    end

    -- Step 3: Fade Out
    Tween(Logo, {ImageTransparency = 1, Size = UDim2.new(0, 150, 0, 150), Position = UDim2.new(0.5, -75, 0.45, -75)}, 0.6)
    Tween(BarBg, {BackgroundTransparency = 1}, 0.4)
    Tween(BarFill, {BackgroundTransparency = 1}, 0.4)
    Tween(Blur, {Size = 0}, 0.8)
    
    task.wait(0.8)
    LoadGui:Destroy()
    Blur:Destroy()
end

--// MAIN WINDOW FACTORY
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib X Premium"}
    task.spawn(RunLoadingEffect)

    local Window = {Enabled = true, CurrentTab = nil, Minimize = false}
    local MainGui = Create("ScreenGui", {Name = "SlayLib_X_Core", Parent = CoreGui, IgnoreGuiInset = true})

    -- 1. FLOATING TOGGLE BUTTON (DRAGGABLE & COOL)
    local ToggleFrame = Create("Frame", {
        Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0.05, 0, 0.2, 0),
        BackgroundColor3 = SlayLib.Theme.MainColor, Parent = MainGui, ZIndex = 100
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleFrame})
    Create("UIStroke", {Color = Color3.new(1,1,1), Thickness = 2, Transparency = 0.7, Parent = ToggleFrame})
    
    local ToggleIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 35, 0, 35), Position = UDim2.new(0.5, -17, 0.5, -17),
        Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = ToggleFrame
    })
    
    local ToggleBtn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = ToggleFrame})

    -- 2. MAIN FRAME (DETAILED HIERARCHY)
    local MainFrame = Create("Frame", {
        Size = UDim2.new(0, 620, 0, 440), Position = UDim2.new(0.5, -310, 0.5, -220),
        BackgroundColor3 = SlayLib.Theme.Background, Parent = MainGui, ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = MainFrame})
    local MainStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 2, Parent = MainFrame})

    -- Sidebar Area
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = Sidebar})

    -- Header (แยกออกมาเพื่อไม่ให้ทับกับ Scroll)
    local SideHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 80), BackgroundTransparency = 1, Parent = Sidebar
    })
    local SideLogo = Create("ImageLabel", {
        Size = UDim2.new(0, 35, 0, 35), Position = UDim2.new(0, 20, 0, 25),
        Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = SideHeader
    })
    local SideTitle = Create("TextLabel", {
        Text = Config.Name, Size = UDim2.new(1, -70, 0, 80), Position = UDim2.new(0, 65, 0, 0),
        Font = "GothamBold", TextSize = 20, TextColor3 = SlayLib.Theme.Text,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = SideHeader
    })

    -- Tab Scroller
    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -100), Position = UDim2.new(0, 5, 0, 90),
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar
    })
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 8), HorizontalAlignment = "Center"})

    -- Page Area
    local PageContainer = Create("Frame", {
        Size = UDim2.new(1, -230, 1, -40), Position = UDim2.new(0, 215, 0, 20),
        BackgroundTransparency = 1, Parent = MainFrame
    })

    -- Toggle Logic (Smooth Fade & Size)
    ToggleBtn.MouseButton1Click:Connect(function()
        Window.Enabled = not Window.Enabled
        if Window.Enabled then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 440), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1}, 0.5)
            task.delay(0.5, function() if not Window.Enabled then MainFrame.Visible = false end end)
        end
    end)

    --// TAB CREATOR (FULL LOGIC)
    function Window:CreateTab(Name)
        local Tab = {Page = nil, Btn = nil}
        
        local TBtn = Create("TextButton", {
            Size = UDim2.new(0, 180, 0, 45), BackgroundColor3 = SlayLib.Theme.MainColor,
            BackgroundTransparency = 1, Text = "      " .. Name, Font = "GothamMedium",
            TextSize = 14, TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left",
            Parent = TabScroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = SlayLib.Theme.MainColor,
            AutomaticCanvasSize = "Y", CanvasSize = UDim2.new(0,0,0,0), Parent = PageContainer
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 12)})
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 5)})

        TBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            Tween(TBtn, {BackgroundTransparency = 0.15, TextColor3 = SlayLib.Theme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.BackgroundTransparency = 0.15
            TBtn.TextColor3 = SlayLib.Theme.MainColor
        end

        --// SECTION CREATOR
        function Tab:CreateSection(SectName)
            local Section = {}
            
            local SectLabel = Create("TextLabel", {
                Text = SectName:upper(), Size = UDim2.new(1, 0, 0, 25),
                Font = "GothamBold", TextSize = 12, TextColor3 = SlayLib.Theme.MainColor,
                BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page
            })

            -- 1. TOGGLE
            function Section:CreateToggle(Props)
                Props = Props or {Name = "Toggle", CurrentValue = false, Callback = function() end}
                local TState = Props.CurrentValue
                
                local TFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TFrame})
                
                local Lbl = Create("TextLabel", {
                    Text = "   " .. Props.Name, Size = UDim2.new(1, 0, 1, 0),
                    Font = "GothamMedium", TextSize = 15, TextColor3 = SlayLib.Theme.Text,
                    TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TFrame
                })

                local Switch = Create("Frame", {
                    Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -60, 0.5, -12),
                    BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(50, 50, 50), Parent = TFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})

                local Dot = Create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18), 
                    Position = TState and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9),
                    BackgroundColor3 = Color3.new(1, 1, 1), Parent = Switch
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                local Click = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = TFrame})
                
                Click.MouseButton1Click:Connect(function()
                    TState = not TState
                    Tween(Switch, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(50, 50, 50)}, 0.3)
                    Tween(Dot, {Position = TState and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)}, 0.3)
                    Props.Callback(TState)
                end)
            end

            -- 2. SLIDER
            function Section:CreateSlider(Props)
                Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Callback = function() end}
                local SFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SFrame})
                
                local Lbl = Create("TextLabel", {
                    Text = "   " .. Props.Name, Size = UDim2.new(1, 0, 0, 40),
                    Font = "GothamMedium", TextSize = 15, TextColor3 = SlayLib.Theme.Text,
                    TextXAlignment = "Left", BackgroundTransparency = 1, Parent = SFrame
                })
                
                local ValLbl = Create("TextLabel", {
                    Text = tostring(Props.Def), Size = UDim2.new(1, -20, 0, 40),
                    Font = "Code", TextSize = 14, TextColor3 = SlayLib.Theme.MainColor,
                    TextXAlignment = "Right", BackgroundTransparency = 1, Parent = SFrame
                })

                local Bar = Create("Frame", {
                    Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 50),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45), Parent = SFrame
                })
                Create("UICorner", {Parent = Bar})
                local Fill = Create("Frame", {
                    Size = UDim2.new((Props.Def - Props.Min)/(Props.Max - Props.Min), 0, 1, 0),
                    BackgroundColor3 = SlayLib.Theme.MainColor, Parent = Bar
                })
                Create("UICorner", {Parent = Fill})

                local function Update()
                    local Percent = math.clamp((Mouse.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local Value = math.floor(Props.Min + (Props.Max - Props.Min) * Percent)
                    Fill.Size = UDim2.new(Percent, 0, 1, 0)
                    ValLbl.Text = tostring(Value)
                    Props.Callback(Value)
                end

                SFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local MoveCon, EndCon
                        Update()
                        MoveCon = UserInputService.InputChanged:Connect(function(move)
                            if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                                Update()
                            end
                        end)
                        EndCon = UserInputService.InputEnded:Connect(function(ended)
                            if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
                                MoveCon:Disconnect() EndCon:Disconnect()
                            end
                        end)
                    end
                end)
            end

            -- 3. INPUT BOX
            function Section:CreateInput(Props)
                Props = Props or {Name = "Input", Placeholder = "Type here...", Callback = function() end}
                local IFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = IFrame})
                
                local Lbl = Create("TextLabel", {
                    Text = "   " .. Props.Name, Size = UDim2.new(0, 120, 1, 0),
                    Font = "GothamMedium", TextSize = 15, TextColor3 = SlayLib.Theme.Text,
                    TextXAlignment = "Left", BackgroundTransparency = 1, Parent = IFrame
                })

                local Box = Create("TextBox", {
                    Size = UDim2.new(0, 180, 0, 32), Position = UDim2.new(1, -195, 0.5, -16),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35), Text = "", PlaceholderText = Props.Placeholder,
                    TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 14, Parent = IFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Box})
                Box.FocusLost:Connect(function() Props.Callback(Box.Text) end)
            end

            -- 4. BUTTON
            function Section:CreateButton(Props)
                Props = Props or {Name = "Button", Callback = function() end}
                local Btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = SlayLib.Theme.Element,
                    Text = Props.Name, Font = "GothamMedium", TextSize = 15, TextColor3 = SlayLib.Theme.Text,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Btn})
                
                Btn.MouseButton1Down:Connect(function() Tween(Btn, {BackgroundColor3 = SlayLib.Theme.ElementHover}, 0.2) end)
                Btn.MouseButton1Up:Connect(function() 
                    Tween(Btn, {BackgroundColor3 = SlayLib.Theme.Element}, 0.2) 
                    Props.Callback() 
                end)
            end

            -- 5. DROPDOWN (FULL LOGIC)
            function Section:CreateDropdown(Props)
                Props = Props or {Name = "Dropdown", Options = {}, Callback = function() end}
                local IsOpen = false
                
                local DFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element,
                    ClipsDescendants = true, Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = DFrame})

                local MainBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1,
                    Text = "   " .. Props.Name, Font = "GothamMedium", TextSize = 15,
                    TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", Parent = DFrame
                })
                
                local Icon = Create("ImageLabel", {
                    Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(1, -40, 0.5, -12),
                    Image = SlayLib.Icons.Chevron, BackgroundTransparency = 1, Parent = DFrame
                })

                local List = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, #Props.Options * 40), Position = UDim2.new(0, 0, 0, 52),
                    BackgroundTransparency = 1, Parent = DFrame
                })
                Create("UIListLayout", {Parent = List})

                for _, opt in pairs(Props.Options) do
                    local OBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
                        Text = "        " .. tostring(opt), Font = "Gotham", TextSize = 14,
                        TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = List
                    })
                    OBtn.MouseButton1Click:Connect(function()
                        MainBtn.Text = "   " .. Props.Name .. ": " .. tostring(opt)
                        IsOpen = false
                        Tween(DFrame, {Size = UDim2.new(1, 0, 0, 52)}, 0.4)
                        Tween(Icon, {Rotation = 0}, 0.4)
                        Props.Callback(opt)
                    end)
                end

                MainBtn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    local Target = IsOpen and 52 + (#Props.Options * 40) or 52
                    Tween(DFrame, {Size = UDim2.new(1, 0, 0, Target)}, 0.4)
                    Tween(Icon, {Rotation = IsOpen and 180 or 0}, 0.4)
                end)
            end

            return Section
        end
        return Tab
    end

    -- Enable Dragging
    MakeDraggable(MainFrame, SideHeader)
    MakeDraggable(ToggleFrame, ToggleFrame)

    return Window
end

return SlayLib
