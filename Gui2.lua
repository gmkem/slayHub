--[[
    ================================================================================
    SLAYLIB X - ULTIMATE CROSS-PLATFORM EDITION
    ================================================================================
    - UI Name: SlayLib X
    - Platform: PC / Mobile / Tablet (Full Support)
    - Logic: Full Detailed Script (No Snippets)
    ================================================================================
]]

local SlayLib = {
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(10, 10, 10),
        Sidebar = Color3.fromRGB(15, 15, 15),
        Element = Color3.fromRGB(22, 22, 22),
        ElementHover = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 170),
        Stroke = Color3.fromRGB(45, 45, 45),
        Success = Color3.fromRGB(0, 255, 127),
        Error = Color3.fromRGB(255, 65, 65),
        Info = Color3.fromRGB(65, 165, 255),
        Warning = Color3.fromRGB(255, 165, 0)
    },
    Icons = {
        Logo = "rbxassetid://13589839447",
        Check = "rbxassetid://10134203511",
        Warn = "rbxassetid://10134199120",
        Err = "rbxassetid://10134198184",
        Info = "rbxassetid://10134202165"
    }
}

--// SERVICES
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
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

--// ADVANCED DRAG SYSTEM (Stable for Mobile/PC)
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
                    Connection:Disconnect()
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

--// NOTIFICATION SYSTEM
function SlayLib:Notify(Config)
    Config = Config or {Title = "SlayLib X", Content = "Notification Test", Type = "Info", Duration = 4}
    
    local Holder = CoreGui:FindFirstChild("SlayNotifications") or Create("Frame", {
        Name = "SlayNotifications", Parent = CoreGui, BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -310, 0, 20)
    })
    if not Holder:FindFirstChild("UIListLayout") then
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Top", Padding = UDim.new(0, 10)})
    end

    local Notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Sidebar,
        ClipsDescendants = true, Parent = Holder
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notif})
    local Stroke = Create("UIStroke", {Color = SlayLib.Theme[Config.Type] or SlayLib.Theme.MainColor, Thickness = 1.4, Parent = Notif})

    local Icon = Create("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0, 14),
        Image = SlayLib.Icons[Config.Type] or SlayLib.Icons.Info, ImageColor3 = SlayLib.Theme[Config.Type],
        BackgroundTransparency = 1, Parent = Notif
    })

    local T = Create("TextLabel", {
        Text = Config.Title, Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 40, 0, 6),
        Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.Theme.Text,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Notif
    })

    local C = Create("TextLabel", {
        Text = Config.Content, Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 40, 0, 23),
        Font = "Gotham", TextSize = 12, TextColor3 = SlayLib.Theme.TextSecondary,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Notif
    })

    Tween(Notif, {Size = UDim2.new(1, 0, 0, 50)}, 0.4)
    task.delay(Config.Duration, function()
        Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
        task.wait(0.4) Notif:Destroy()
    end)
end

--// WINDOW CORE
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib X"}
    
    local Window = {Visible = true, CurrentTab = nil}

    local MainGui = Create("ScreenGui", {Name = "SlayLib_X", Parent = CoreGui, IgnoreGuiInset = true})

    -- 1. INTRO / LOADING SCREEN
    local LoadingFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        ZIndex = 10, Parent = MainGui
    })
    local Blur = Create("BlurEffect", {Size = 20, Parent = game:GetService("Lighting")})
    
    local LoadLogo = Create("ImageLabel", {
        Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0.5, -50, 0.5, -70),
        Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = LoadingFrame
    })
    
    local LoadTitle = Create("TextLabel", {
        Text = "SLAYLIB X", Size = UDim2.new(0, 200, 0, 30), Position = UDim2.new(0.5, -100, 0.5, 40),
        Font = "GothamBold", TextSize = 24, TextColor3 = SlayLib.Theme.Text,
        BackgroundTransparency = 1, Parent = LoadingFrame
    })

    local BarBg = Create("Frame", {
        Size = UDim2.new(0, 250, 0, 4), Position = UDim2.new(0.5, -125, 0.5, 80),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30), Parent = LoadingFrame
    })
    Create("UICorner", {Parent = BarBg})
    
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor,
        Parent = BarBg
    })
    Create("UICorner", {Parent = BarFill})

    -- Loading Animation
    task.spawn(function()
        Tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 2.5)
        task.wait(2.7)
        Tween(LoadingFrame, {BackgroundTransparency = 1}, 0.5)
        Tween(LoadLogo, {ImageTransparency = 1}, 0.5)
        Tween(LoadTitle, {TextTransparency = 1}, 0.5)
        Tween(BarBg, {BackgroundTransparency = 1}, 0.5)
        Tween(BarFill, {BackgroundTransparency = 1}, 0.5)
        Tween(Blur, {Size = 0}, 0.5)
        task.wait(0.5)
        LoadingFrame:Destroy() Blur:Destroy()
        SlayLib:Notify({Title = "Loaded Successfully", Content = "Welcome to SlayLib X!", Type = "Success"})
    end)

    -- 2. FLOATING TOGGLE BUTTON (Circular & Draggable)
    local ToggleBtn = Create("Frame", {
        Name = "SlayToggle", Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.05, 0, 0.15, 0), -- ย้ายลงมาให้กดง่ายขึ้น
        BackgroundColor3 = SlayLib.Theme.MainColor, Parent = MainGui
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})
    Create("UIStroke", {Color = Color3.new(1,1,1), Thickness = 2, Transparency = 0.8, Parent = ToggleBtn})
    
    local TIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 35, 0, 35), Position = UDim2.new(0.5, -17, 0.5, -17),
        Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = ToggleBtn
    })
    
    local TClick = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = ToggleBtn
    })

    -- 3. MAIN GUI FRAME
    local MainFrame = Create("Frame", {
        Size = UDim2.new(0, 560, 0, 400), Position = UDim2.new(0.5, -280, 0.5, -200),
        BackgroundColor3 = SlayLib.Theme.Background, Parent = MainGui,
        ClipsDescendants = true, Visible = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1.5, Parent = MainFrame})

    -- Sidebar
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})

    local LogoBox = Create("ImageLabel", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 15, 0, 15),
        Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = Sidebar
    })
    
    local LogoTitle = Create("TextLabel", {
        Text = "SLAYLIB X", Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0, 50, 0, 15),
        Font = "GothamBold", TextSize = 18, TextColor3 = SlayLib.Theme.Text,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Sidebar
    })

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -70), Position = UDim2.new(0, 5, 0, 60),
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 6), Parent = TabScroll})

    local PageContainer = Create("Frame", {
        Size = UDim2.new(1, -200, 1, -30), Position = UDim2.new(0, 190, 0, 15),
        BackgroundTransparency = 1, Parent = MainFrame
    })

    -- Toggle Logic
    TClick.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 560, 0, 400), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5)
            task.delay(0.5, function() MainFrame.Visible = false end)
        end
    end)

    -- Tab System
    function Window:CreateTab(Name)
        local Tab = {}
        local TBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
            Text = "      " .. Name, Font = "GothamMedium", TextSize = 14,
            TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = TabScroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Visible = false, ScrollBarThickness = 2, Parent = PageContainer
        })
        Create("UIListLayout", {Padding = UDim.new(0, 12), Parent = Page})

        TBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            Tween(TBtn, {BackgroundTransparency = 0.1, TextColor3 = SlayLib.Theme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.BackgroundTransparency = 0.1
            TBtn.TextColor3 = SlayLib.Theme.MainColor
        end

        function Tab:CreateSection(Title)
            local Section = {}
            Create("TextLabel", {
                Text = Title:upper(), Size = UDim2.new(1, 0, 0, 25), Font = "GothamBold",
                TextSize = 11, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1,
                TextXAlignment = "Left", Parent = Page
            })

            -- TOGGLE
            function Section:CreateToggle(Props, Flag)
                Props = Props or {Name = "Toggle", Callback = function() end}
                local State = false
                local TFrame = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 48), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TFrame})
                
                local L = Create("TextLabel", {
                    Text = "  " .. Props.Name, Size = UDim2.new(1, 0, 1, 0), Font = "GothamMedium",
                    TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left",
                    BackgroundTransparency = 1, Parent = TFrame
                })

                local Sw = Create("Frame", {
                    Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -52, 0.5, -11),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50), Parent = TFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Sw})

                local D = Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Color3.new(1, 1, 1), Parent = Sw
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = D})

                local Click = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = TFrame})
                Click.MouseButton1Click:Connect(function()
                    State = not State
                    Tween(Sw, {BackgroundColor3 = State and SlayLib.Theme.MainColor or Color3.fromRGB(50, 50, 50)}, 0.3)
                    Tween(D, {Position = State and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.3)
                    Props.Callback(State)
                    if Flag then SlayLib.Flags[Flag] = State end
                end)
            end

            -- SLIDER
            function Section:CreateSlider(Props, Flag)
                Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Callback = function() end}
                local Val = Props.Def
                local SFrame = Create("Frame", {Size = UDim2.new(1, -10, 0, 65), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SFrame})

                local L = Create("TextLabel", {
                    Text = "  " .. Props.Name, Size = UDim2.new(1, 0, 0, 35), Font = "GothamMedium",
                    TextColor3 = SlayLib.Theme.Text, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = SFrame
                })

                local VL = Create("TextLabel", {
                    Text = tostring(Val), Size = UDim2.new(1, -15, 0, 35), Font = "Code",
                    TextColor3 = SlayLib.Theme.MainColor, TextXAlignment = "Right", BackgroundTransparency = 1, Parent = SFrame
                })

                local R = Create("Frame", {
                    Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 48),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45), Parent = SFrame
                })
                local F = Create("Frame", {
                    Size = UDim2.new((Val-Props.Min)/(Props.Max-Props.Min), 0, 1, 0),
                    BackgroundColor3 = SlayLib.Theme.MainColor, Parent = R
                })
                Create("UICorner", {Parent = R}) Create("UICorner", {Parent = F})

                local Dragging = false
                local function Update()
                    local P = math.clamp((Mouse.X - R.AbsolutePosition.X) / R.AbsoluteSize.X, 0, 1)
                    local NV = math.floor(Props.Min + (Props.Max - Props.Min) * P)
                    F.Size = UDim2.new(P, 0, 1, 0)
                    VL.Text = tostring(NV)
                    Props.Callback(NV)
                    if Flag then SlayLib.Flags[Flag] = NV end
                end

                SFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                RunService.RenderStepped:Connect(function() if Dragging then Update() end end)
            end

            -- BUTTON
            function Section:CreateButton(Props)
                local B = Create("TextButton", {
                    Size = UDim2.new(1, -10, 0, 45), BackgroundColor3 = SlayLib.Theme.Element,
                    Text = Props.Name, Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text, Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = B})
                B.MouseButton1Down:Connect(function() Tween(B, {BackgroundColor3 = SlayLib.Theme.ElementHover}, 0.2) end)
                B.MouseButton1Up:Connect(function() Tween(B, {BackgroundColor3 = SlayLib.Theme.Element}, 0.2) Props.Callback() end)
            end

            return Section
        end
        return Tab
    end

    -- Enable Dragging for Main GUI and Toggle Button
    MakeDraggable(MainFrame, Sidebar)
    MakeDraggable(ToggleBtn, ToggleBtn)

    return Window
end

return SlayLib
