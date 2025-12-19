--[[
    ================================================================================
    SLAYLIB X - THE ULTIMATE UNABRIDGED VERSION (FIXED & EXTENDED)
    ================================================================================
]]

local SlayLib = {
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(25, 25, 25),
        ElementHover = Color3.fromRGB(32, 32, 32),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45)
    }
}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

--// Utility Functions
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
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
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

--// NOTIFICATION POP-UP SYSTEM
function SlayLib:Notify(Config)
    Config = Config or {Title = "SlayLib X", Content = "Notification Content", Duration = 5}
    
    local Holder = CoreGui:FindFirstChild("SlayNotifyHolder")
    if not Holder then
        Holder = Create("Frame", {
            Name = "SlayNotifyHolder", Parent = CoreGui, BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -310, 0, 0)
        })
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 10)})
        Create("UIPadding", {Parent = Holder, PaddingBottom = UDim.new(0, 20)})
    end

    local Notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = SlayLib.Theme.Sidebar,
        Position = UDim2.new(2, 0, 0, 0), Parent = Holder -- Start off-screen
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Notif})
    Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.5, Parent = Notif})

    local T = Create("TextLabel", {
        Text = Config.Title, Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5),
        Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.Theme.MainColor,
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Notif
    })
    local C = Create("TextLabel", {
        Text = Config.Content, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 25),
        Font = "Gotham", TextSize = 12, TextColor3 = SlayLib.Theme.Text,
        TextXAlignment = "Left", TextWrapped = true, BackgroundTransparency = 1, Parent = Notif
    })

    Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
    
    task.delay(Config.Duration, function()
        Tween(Notif, {Position = UDim2.new(2, 0, 0, 0)}, 0.5)
        task.wait(0.5) Notif:Destroy()
    end)
end

--// LOADING ENGINE (FIXED: NO BACKGROUND, BLUR ONLY)
local function StartLoading()
    local LoadingGui = Create("ScreenGui", {Parent = CoreGui, Name = "SlayLoad"})
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    Tween(Blur, {Size = 24}, 1)

    local Holder = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 200), Position = UDim2.new(0.5, -100, 0.5, -100),
        BackgroundTransparency = 1, Parent = LoadingGui
    })
    
    local Logo = Create("ImageLabel", {
        Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0.5, -50, 0.4, -50),
        Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = Holder,
        ImageTransparency = 1
    })
    
    local BarBg = Create("Frame", {
        Size = UDim2.new(0, 180, 0, 4), Position = UDim2.new(0.5, -90, 0.7, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Holder, BackgroundTransparency = 1
    })
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor,
        Parent = BarBg, BackgroundTransparency = 1
    })
    Create("UICorner", {Parent = BarBg}) Create("UICorner", {Parent = BarFill})

    -- อนิเมชันค่อยๆ โผล่
    Tween(Logo, {ImageTransparency = 0}, 1)
    Tween(BarBg, {BackgroundTransparency = 0}, 1)
    Tween(BarFill, {BackgroundTransparency = 0}, 1)

    for i = 1, 100 do
        task.wait(0.02)
        BarFill.Size = UDim2.new(i/100, 0, 1, 0)
    end

    Tween(Logo, {ImageTransparency = 1, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.4, 0)}, 0.8)
    Tween(BarBg, {BackgroundTransparency = 1}, 0.5)
    Tween(BarFill, {BackgroundTransparency = 1}, 0.5)
    Tween(Blur, {Size = 0}, 0.8)
    task.wait(0.8)
    LoadingGui:Destroy() Blur:Destroy()
end

--// WINDOW CORE
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib X"}
    StartLoading()

    local Window = {Enabled = true, CurrentTab = nil}
    local MainGui = Create("ScreenGui", {Name = "SlayLibX_Core", Parent = CoreGui, IgnoreGuiInset = true})

    -- Floating Button
    local TBtn = Create("Frame", {
        Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0.05, 0, 0.1, 0),
        BackgroundColor3 = SlayLib.Theme.MainColor, Parent = MainGui
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TBtn})
    local TIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15),
        Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = TBtn
    })
    local TClick = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = TBtn})

    -- Main Frame (Fixed Title Overlapping)
    local MainFrame = Create("Frame", {
        Size = UDim2.new(0, 580, 0, 400), Position = UDim2.new(0.5, -290, 0.5, -200),
        BackgroundColor3 = SlayLib.Theme.Background, Parent = MainGui, ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    local MStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1.5, Parent = MainFrame})

    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})

    local Title = Create("TextLabel", {
        Text = Config.Name, Size = UDim2.new(1, 0, 0, 60), Font = "GothamBold",
        TextSize = 18, TextColor3 = SlayLib.Theme.Text, Parent = Sidebar, BackgroundTransparency = 1
    })

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -80), Position = UDim2.new(0, 5, 0, 70),
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar
    })
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 5)})

    local PageContainer = Create("Frame", {
        Size = UDim2.new(1, -200, 1, -20), Position = UDim2.new(0, 190, 0, 10),
        BackgroundTransparency = 1, Parent = MainFrame
    })

    -- Toggle GUI Logic (Fixed Fade Glitch)
    TClick.MouseButton1Click:Connect(function()
        Window.Enabled = not Window.Enabled
        if Window.Enabled then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 580, 0, 400), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1}, 0.5)
            task.delay(0.5, function() if not Window.Enabled then MainFrame.Visible = false end end)
        end
    end)

    --// TAB SYSTEM
    function Window:CreateTab(Name)
        local Tab = {Page = nil}
        local Btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
            Text = "  " .. Name, Font = "GothamMedium", TextSize = 14,
            TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = TabScroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Btn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Visible = false, ScrollBarThickness = 2, Parent = PageContainer,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = "Y" -- AUTO LAYOUT
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10)})
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 10)})

        Btn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = Btn}
            Page.Visible = true
            Tween(Btn, {BackgroundTransparency = 0.1, TextColor3 = SlayLib.Theme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = Btn}
            Page.Visible = true
            Btn.BackgroundTransparency = 0.1
            Btn.TextColor3 = SlayLib.Theme.MainColor
        end

        function Tab:CreateSection(SectName)
            local Section = {}
            Create("TextLabel", {
                Text = SectName:upper(), Size = UDim2.new(1, 0, 0, 20),
                Font = "GothamBold", TextSize = 11, TextColor3 = SlayLib.Theme.MainColor,
                BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page
            })

            -- 1. TOGGLE
            function Section:CreateToggle(Props)
                local State = Props.CurrentValue or false
                local TFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TFrame})
                
                local L = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", Font = "GothamMedium", Parent = TFrame})
                
                local Sw = Create("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = State and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60), Parent = TFrame})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Sw})
                local Dot = Create("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1), Parent = Sw})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                local Click = Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = TFrame})
                Click.MouseButton1Click:Connect(function()
                    State = not State
                    Tween(Sw, {BackgroundColor3 = State and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60)}, 0.3)
                    Tween(Dot, {Position = State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.3)
                    Props.Callback(State)
                end)
            end

            -- 2. INPUT BOX (NEW)
            function Section:CreateInput(Props)
                local IFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = IFrame})
                
                local L = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(0, 100, 1, 0), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", Font = "GothamMedium", Parent = IFrame})
                
                local Box = Create("TextBox", {
                    Size = UDim2.new(0, 150, 0, 30), Position = UDim2.new(1, -160, 0.5, -15),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35), Text = "", PlaceholderText = Props.Placeholder or "Type...",
                    TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 12, Parent = IFrame
                })
                Create("UICorner", {Parent = Box})
                Box.FocusLost:Connect(function() Props.Callback(Box.Text) end)
            end

            -- 3. BUTTON
            function Section:CreateButton(Props)
                local B = Create("TextButton", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = SlayLib.Theme.Element, Text = Props.Name, TextColor3 = SlayLib.Theme.Text, Font = "GothamMedium", Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = B})
                B.MouseButton1Click:Connect(Props.Callback)
            end

            return Section
        end
        return Tab
    end

    MakeDraggable(MainFrame, Sidebar)
    MakeDraggable(TBtn, TBtn)
    return Window
end

return SlayLib
