--[[
    ================================================================================
    SLAYLIB X - PROFESSIONAL INTERFACE SUITE (UNABRIDGED VERSION)
    ================================================================================
    - Build: 5.1.0 (Full Source)
    - Optimization: PC, Mobile, Tablet
    - Features: Loading Screen, Advanced Notifications, Draggable Floating Toggle, 
      Theme Engine, Custom Icons, Memory Management.
    ================================================================================
]]

local SlayLib = {
    Folder = "SlayLib_Configs",
    Options = {},
    Flags = {},
    Themes = {
        Default = {
            MainColor = Color3.fromRGB(120, 80, 255),
            Background = Color3.fromRGB(10, 10, 10),
            Sidebar = Color3.fromRGB(15, 15, 15),
            Element = Color3.fromRGB(20, 20, 20),
            ElementHover = Color3.fromRGB(28, 28, 28),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(180, 180, 180),
            Stroke = Color3.fromRGB(40, 40, 40),
            Success = Color3.fromRGB(0, 255, 127),
            Error = Color3.fromRGB(255, 65, 65),
            Info = Color3.fromRGB(65, 165, 255),
            Warning = Color3.fromRGB(255, 165, 0)
        }
    },
    ActiveTheme = nil,
    Signals = {}
}

--// SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

--// INITIALIZATION
SlayLib.ActiveTheme = SlayLib.Themes.Default

--// UTILITY FUNCTIONS (FULL LOGIC)
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

local function Tween(obj, goal, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), goal)
    t:Play()
    return t
end

-- ระบบ Drag ที่เสถียรที่สุดสำหรับทุกแพลตฟอร์ม
local function MakeDraggable(UIElement, DragHandle)
    local Dragging, DragInput, DragStart, StartPos
    
    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = UIElement.Position
            
            local Connection
            Connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    if Connection then Connection:Disconnect() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            UIElement.Position = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
            )
        end
    end)
end

--// NOTIFICATION ENGINE (PRO VERSION)
function SlayLib:Notify(Config)
    Config = Config or {Title = "Notification", Content = "Message Content", Type = "Info", Duration = 5}
    
    local Holder = CoreGui:FindFirstChild("SlayNotifContainer")
    if not Holder then
        Holder = Create("Frame", {
            Name = "SlayNotifContainer",
            Parent = CoreGui,
            Size = UDim2.new(0, 320, 1, 0),
            Position = UDim2.new(1, -330, 0, 30),
            BackgroundTransparency = 1
        })
        Create("UIListLayout", {
            Parent = Holder,
            VerticalAlignment = "Top",
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    end

    local NotifFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), -- เริ่มต้นที่ 0 เพื่ออนิเมชัน
        BackgroundColor3 = SlayLib.ActiveTheme.Sidebar,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Holder
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = NotifFrame})
    local Stroke = Create("UIStroke", {
        Color = SlayLib.ActiveTheme[Config.Type] or SlayLib.ActiveTheme.MainColor,
        Thickness = 1.8,
        Parent = NotifFrame
    })

    local AccentBar = Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = Stroke.Color,
        Parent = NotifFrame
    })
    Create("UICorner", {Parent = AccentBar})

    local Title = Create("TextLabel", {
        Text = Config.Title,
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 15, 0, 8),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = SlayLib.ActiveTheme.Text,
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        Parent = NotifFrame
    })

    local Content = Create("TextLabel", {
        Text = Config.Content,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 26),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = SlayLib.ActiveTheme.TextSecondary,
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        Parent = NotifFrame
    })

    -- Animation
    Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 60)}, 0.5, Enum.EasingStyle.Back)
    
    task.delay(Config.Duration, function()
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.5)
        task.wait(0.5)
        NotifFrame:Destroy()
    end)
end

--// LOADING SCREEN (HIGH-END DESIGN)
local function StartLoading()
    local LoadingGui = Create("ScreenGui", {Parent = CoreGui, Name = "SlayLoading"})
    local Bg = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        Parent = LoadingGui
    })
    
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    Tween(Blur, {Size = 25}, 1)

    local Logo = Create("ImageLabel", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.45, 0),
        Image = "rbxassetid://13589839447",
        BackgroundTransparency = 1,
        Parent = Bg
    })
    Tween(Logo, {Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0.5, -60, 0.45, -60)}, 1, Enum.EasingStyle.Elastic)

    local Text = Create("TextLabel", {
        Text = "SLAYLIB X PREMIER",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0.58, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = Color3.new(1, 1, 1),
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Parent = Bg
    })
    Tween(Text, {TextTransparency = 0}, 1)

    local BarBg = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 4),
        Position = UDim2.new(0.5, -150, 0.65, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Parent = Bg
    })
    Create("UICorner", {Parent = BarBg})
    
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = SlayLib.ActiveTheme.MainColor,
        Parent = BarBg
    })
    Create("UICorner", {Parent = BarFill})

    -- Animation Sequence
    for i = 1, 100 do
        task.wait(0.02)
        BarFill.Size = UDim2.new(i/100, 0, 1, 0)
    end

    Tween(Bg, {BackgroundTransparency = 1}, 0.8)
    Tween(Logo, {ImageTransparency = 1}, 0.8)
    Tween(Text, {TextTransparency = 1}, 0.8)
    Tween(BarBg, {BackgroundTransparency = 1}, 0.8)
    Tween(BarFill, {BackgroundTransparency = 1}, 0.8)
    Tween(Blur, {Size = 0}, 0.8)
    
    task.wait(0.8)
    LoadingGui:Destroy()
    Blur:Destroy()
end

--// WINDOW FACTORY
function SlayLib:CreateWindow(Settings)
    Settings = Settings or {Name = "SlayLib X"}
    
    StartLoading() -- รันหน้าโหลดก่อนเข้า GUI

    local Window = {Visible = true, CurrentTab = nil, Tabs = {}}

    local MainGui = Create("ScreenGui", {
        Name = "SlayLib_Core",
        Parent = CoreGui,
        IgnoreGuiInset = true
    })

    -- Floating Toggle Button (แก้ไขตำแหน่งและระบบลาก)
    local ToggleBtn = Create("Frame", {
        Name = "MainToggle",
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        BackgroundColor3 = SlayLib.ActiveTheme.MainColor,
        Parent = MainGui,
        ZIndex = 100
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})
    local TStroke = Create("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Transparency = 0.5, Parent = ToggleBtn})
    
    local TIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(0.5, -17, 0.5, -17),
        Image = "rbxassetid://13589839447",
        BackgroundTransparency = 1,
        Parent = ToggleBtn
    })
    
    local TClick = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ToggleBtn
    })

    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = SlayLib.ActiveTheme.Background,
        ClipsDescendants = true,
        Parent = MainGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = MainFrame})
    local MainStroke = Create("UIStroke", {Color = SlayLib.ActiveTheme.Stroke, Thickness = 1.5, Parent = MainFrame})

    -- Sidebar Container
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 190, 1, 0),
        BackgroundColor3 = SlayLib.ActiveTheme.Sidebar,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Sidebar})

    local SideHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = Sidebar
    })

    local Logo = Create("ImageLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 20, 0, 15),
        Image = "rbxassetid://13589839447",
        BackgroundTransparency = 1,
        Parent = SideHeader
    })

    local Title = Create("TextLabel", {
        Text = Settings.Name,
        Size = UDim2.new(1, -60, 0, 30),
        Position = UDim2.new(0, 55, 0, 15),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = SlayLib.ActiveTheme.Text,
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        Parent = SideHeader
    })

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -80),
        Position = UDim2.new(0, 5, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})

    local PageContainer = Create("Frame", {
        Size = UDim2.new(1, -210, 1, -40),
        Position = UDim2.new(0, 200, 0, 20),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    --// TOGGLE LOGIC
    TClick.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 580, 0, 420)}, 0.5, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
            task.delay(0.5, function() MainFrame.Visible = false end)
        end
    end)

    --// TAB BUILDER
    function Window:CreateTab(Name, Icon)
        local Tab = {Page = nil, Btn = nil}
        
        local TBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = SlayLib.ActiveTheme.MainColor,
            BackgroundTransparency = 1,
            Text = "       " .. Name,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = SlayLib.ActiveTheme.TextSecondary,
            TextXAlignment = "Left",
            Parent = TabScroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = SlayLib.ActiveTheme.MainColor,
            Parent = PageContainer
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 12)})
        Create("UIPadding", {Parent = Page, PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10)})

        TBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.ActiveTheme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            Tween(TBtn, {BackgroundTransparency = 0.1, TextColor3 = SlayLib.ActiveTheme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.BackgroundTransparency = 0.1
            TBtn.TextColor3 = SlayLib.ActiveTheme.MainColor
        end

        --// SECTION BUILDER
        function Tab:CreateSection(Title)
            local Section = {}
            
            local SectHeader = Create("TextLabel", {
                Text = Title:upper(),
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = SlayLib.ActiveTheme.MainColor,
                BackgroundTransparency = 1,
                TextXAlignment = "Left",
                Parent = Page
            })

            -- 1. TOGGLE (FULL SOURCE)
            function Section:CreateToggle(Props, Flag)
                Props = Props or {Name = "Toggle", CurrentValue = false, Callback = function() end}
                local Tgl = {Value = Props.CurrentValue}

                local TFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = SlayLib.ActiveTheme.Element,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TFrame})
                local TStroke = Create("UIStroke", {Color = SlayLib.ActiveTheme.Stroke, Parent = TFrame})

                local Lbl = Create("TextLabel", {
                    Text = "  " .. Props.Name,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 15,
                    TextColor3 = SlayLib.ActiveTheme.Text,
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Parent = TFrame
                })

                local Bg = Create("Frame", {
                    Size = UDim2.new(0, 44, 0, 24),
                    Position = UDim2.new(1, -55, 0.5, -12),
                    BackgroundColor3 = Tgl.Value and SlayLib.ActiveTheme.MainColor or Color3.fromRGB(50, 50, 50),
                    Parent = TFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bg})

                local Dot = Create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = Tgl.Value and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = Bg
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                local Click = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = TFrame})
                
                local function Set(v)
                    Tgl.Value = v
                    Tween(Bg, {BackgroundColor3 = v and SlayLib.ActiveTheme.MainColor or Color3.fromRGB(50, 50, 50)}, 0.3)
                    Tween(Dot, {Position = v and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)}, 0.3)
                    Props.Callback(v)
                    if Flag then SlayLib.Flags[Flag] = v end
                end

                Click.MouseButton1Click:Connect(function() Set(not Tgl.Value) end)
                return {Set = Set}
            end

            -- 2. SLIDER (FULL SOURCE)
            function Section:CreateSlider(Props, Flag)
                Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Callback = function() end}
                local Sld = {Value = Props.Def}

                local SFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 65),
                    BackgroundColor3 = SlayLib.ActiveTheme.Element,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SFrame})

                local Lbl = Create("TextLabel", {
                    Text = "  " .. Props.Name,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 15,
                    TextColor3 = SlayLib.ActiveTheme.Text,
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Parent = SFrame
                })

                local ValLbl = Create("TextLabel", {
                    Text = tostring(Sld.Value),
                    Size = UDim2.new(1, -20, 0, 35),
                    Font = Enum.Font.Code,
                    TextSize = 14,
                    TextColor3 = SlayLib.ActiveTheme.MainColor,
                    TextXAlignment = "Right",
                    BackgroundTransparency = 1,
                    Parent = SFrame
                })

                local Rail = Create("Frame", {
                    Size = UDim2.new(1, -30, 0, 6),
                    Position = UDim2.new(0, 15, 0, 48),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    Parent = SFrame
                })
                Create("UICorner", {Parent = Rail})

                local Fill = Create("Frame", {
                    Size = UDim2.new((Sld.Value - Props.Min)/(Props.Max - Props.Min), 0, 1, 0),
                    BackgroundColor3 = SlayLib.ActiveTheme.MainColor,
                    Parent = Rail
                })
                Create("UICorner", {Parent = Fill})

                local function Update()
                    local P = math.clamp((Mouse.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
                    local NV = math.floor(Props.Min + (Props.Max - Props.Min) * P)
                    Fill.Size = UDim2.new(P, 0, 1, 0)
                    ValLbl.Text = tostring(NV)
                    Sld.Value = NV
                    Props.Callback(NV)
                    if Flag then SlayLib.Flags[Flag] = NV end
                end

                SFrame.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        local MoveCon, EndCon
                        Update()
                        MoveCon = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                Update()
                            end
                        end)
                        EndCon = UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                MoveCon:Disconnect()
                                EndCon:Disconnect()
                            end
                        end)
                    end
                end)
            end

            -- 3. BUTTON (FULL SOURCE)
            function Section:CreateButton(Props)
                Props = Props or {Name = "Button", Callback = function() end}
                local Btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = SlayLib.ActiveTheme.Element,
                    Text = Props.Name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 15,
                    TextColor3 = SlayLib.ActiveTheme.Text,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Btn})
                local BStroke = Create("UIStroke", {Color = SlayLib.ActiveTheme.Stroke, Parent = Btn})

                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = SlayLib.ActiveTheme.ElementHover}, 0.2) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = SlayLib.ActiveTheme.Element}, 0.2) end)
                Btn.MouseButton1Down:Connect(function() Tween(Btn, {Size = UDim2.new(1, -10, 0, 44)}, 0.1) end)
                Btn.MouseButton1Up:Connect(function() 
                    Tween(Btn, {Size = UDim2.new(1, 0, 0, 48)}, 0.1)
                    Props.Callback()
                end)
            end

            -- 4. DROPDOWN (FULL LOGIC)
            function Section:CreateDropdown(Props, Flag)
                Props = Props or {Name = "Dropdown", Options = {}, Callback = function() end}
                local Drop = {Open = false, Options = Props.Options}

                local DFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = SlayLib.ActiveTheme.Element,
                    ClipsDescendants = true,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = DFrame})
                
                local MainBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    Text = "  " .. Props.Name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 15,
                    TextColor3 = SlayLib.ActiveTheme.Text,
                    TextXAlignment = "Left",
                    Parent = DFrame
                })

                local Arrow = Create("TextLabel", {
                    Text = "▼",
                    Size = UDim2.new(0, 48, 0, 48),
                    Position = UDim2.new(1, -48, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = SlayLib.ActiveTheme.TextSecondary,
                    Parent = DFrame
                })

                local List = Create("Frame", {
                    Position = UDim2.new(0, 0, 0, 48),
                    Size = UDim2.new(1, 0, 0, #Props.Options * 35),
                    BackgroundTransparency = 1,
                    Parent = DFrame
                })
                Create("UIListLayout", {Parent = List})

                for _, v in pairs(Props.Options) do
                    local Opt = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundTransparency = 1,
                        Text = "      " .. tostring(v),
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = SlayLib.ActiveTheme.TextSecondary,
                        TextXAlignment = "Left",
                        Parent = List
                    })
                    Opt.MouseButton1Click:Connect(function()
                        MainBtn.Text = "  " .. Props.Name .. " : " .. tostring(v)
                        Drop.Open = false
                        Tween(DFrame, {Size = UDim2.new(1, 0, 0, 48)}, 0.4)
                        Arrow.Text = "▼"
                        Props.Callback(v)
                    end)
                end

                MainBtn.MouseButton1Click:Connect(function()
                    Drop.Open = not Drop.Open
                    local Target = Drop.Open and 48 + (#Props.Options * 35) or 48
                    Tween(DFrame, {Size = UDim2.new(1, 0, 0, Target)}, 0.4)
                    Arrow.Text = Drop.Open and "▲" or "▼"
                end)
            end

            return Section
        end
        return Tab
    end

    -- Setup Draggables
    MakeDraggable(MainFrame, Sidebar)
    MakeDraggable(ToggleBtn, ToggleBtn)

    return Window
end

--// MEMORY CLEANUP
function SlayLib:Destroy()
    local Root = CoreGui:FindFirstChild("SlayLib_Core")
    if Root then Root:Destroy() end
end

return SlayLib
