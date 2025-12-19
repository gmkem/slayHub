--[[
    ================================================================================
    SLAYLIB X - THE COMPLETE UNABRIDGED ULTIMATE EDITION
    ================================================================================
    - Build: 6.0.0 (Final Source)
    - Optimization: Anti-Lag, Memory Management, Multi-Device Support
    - Features: 
        * Auto-Scaling Text (ป้องกันข้อความล้น)
        * Multi-line Support (รองรับข้อความยาว)
        * Smooth Blur Loading (ไร้พื้นหลัง)
        * Stackable Pop-up Notifications
        * Executor & Studio Environment Check
    ================================================================================
]]

local SlayLib = {
    Folder = "SlayLib_Data",
    Options = {},
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(10, 10, 10),
        Sidebar = Color3.fromRGB(15, 15, 15),
        Element = Color3.fromRGB(22, 22, 22),
        ElementHover = Color3.fromRGB(28, 28, 28),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(40, 40, 40),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 165, 0),
        Error = Color3.fromRGB(255, 65, 65),
    },
    Signals = {}
}

--// SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

--// ENVIRONMENT CHECK (Logic from Ui.lua)
local isStudio = RunService:IsStudio()
local ParentObj = isStudio and Player.PlayerGui or CoreGui

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

-- ระบบจัดการข้อความ (ป้องกันข้อความล้น)
local function SetTextConfig(label, text, isTitle)
    label.Text = text
    label.TextWrapped = true
    if isTitle then
        label.TextScaled = false
        label.TextSize = 14
        -- ถ้าข้อความยาวไปให้ลดขนาดลง (Auto-scaling logic)
        if #text > 25 then
            label.TextSize = 11
        elseif #text > 40 then
            label.TextScaled = true
        end
    else
        label.TextSize = 12
    end
end

-- ระบบลาก (Advanced Dragging)
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

--// NOTIFICATION SYSTEM (STACKABLE & AUTO-LAYOUT)
function SlayLib:Notify(Config)
    Config = Config or {Title = "Notification", Content = "Message", Duration = 5}
    
    local Holder = ParentObj:FindFirstChild("SlayNotifyContainer")
    if not Holder then
        Holder = Create("Frame", {
            Name = "SlayNotifyContainer", Parent = ParentObj, BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 1, -20), Position = UDim2.new(1, -310, 0, 10)
        })
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 10)})
    end

    local Notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Sidebar,
        ClipsDescendants = true, Parent = Holder, BackgroundTransparency = 1
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notif})
    local Stroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.5, Parent = Notif, Transparency = 1})

    local Title = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5),
        Font = "GothamBold", TextColor3 = SlayLib.Theme.MainColor,
        BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Notif
    })
    SetTextConfig(Title, Config.Title, true)

    local Content = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 25),
        Font = "Gotham", TextColor3 = SlayLib.Theme.Text,
        BackgroundTransparency = 1, TextXAlignment = "Left", AutomaticSize = "Y", Parent = Notif
    })
    SetTextConfig(Content, Config.Content, false)

    -- Entrance
    Tween(Notif, {Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)
    Tween(Stroke, {Transparency = 0}, 0.5)

    task.delay(Config.Duration, function()
        Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.5)
        Tween(Stroke, {Transparency = 1}, 0.5)
        task.wait(0.5) Notif:Destroy()
    end)
end

--// LOADING SCREEN (NO BG, BLUR ONLY)
local function StartLoading()
    local LoadingGui = Create("ScreenGui", {Parent = ParentObj, Name = "SlayLoad"})
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    
    local Holder = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 200), Position = UDim2.new(0.5, -100, 0.5, -100),
        BackgroundTransparency = 1, Parent = LoadingGui
    })
    local Logo = Create("ImageLabel", {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.4, 0),
        Image = "rbxassetid://13589839447", BackgroundTransparency = 1, 
        ImageColor3 = SlayLib.Theme.MainColor, Parent = Holder
    })
    local BarBg = Create("Frame", {
        Size = UDim2.new(0, 180, 0, 3), Position = UDim2.new(0.5, -90, 0.7, 0),
        BackgroundColor3 = Color3.fromRGB(40,40,40), Parent = Holder, BackgroundTransparency = 1
    })
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = BarBg
    })

    Tween(Blur, {Size = 25}, 1)
    Tween(Logo, {Size = UDim2.new(0, 110, 0, 110), Position = UDim2.new(0.5, -55, 0.4, -55)}, 1, Enum.EasingStyle.Elastic)
    Tween(BarBg, {BackgroundTransparency = 0}, 0.5)

    for i = 1, 100 do
        task.wait(0.015)
        BarFill.Size = UDim2.new(i/100, 0, 1, 0)
    end

    Tween(Blur, {Size = 0}, 0.8)
    Tween(Logo, {ImageTransparency = 1}, 0.5)
    Tween(BarBg, {BackgroundTransparency = 1}, 0.5)
    task.wait(0.8)
    LoadingGui:Destroy() Blur:Destroy()
end

--// MAIN WINDOW
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib X"}
    task.spawn(StartLoading)

    local Window = {Enabled = true, CurrentTab = nil}
    local MainGui = Create("ScreenGui", {Name = "SlayLib_Core", Parent = ParentObj, IgnoreGuiInset = true})

    -- Toggle Button
    local TBtn = Create("Frame", {
        Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0.05, 0, 0.15, 0),
        BackgroundColor3 = SlayLib.Theme.MainColor, Parent = MainGui
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TBtn})
    local TClick = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = TBtn})
    Create("ImageLabel", {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15), Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = TBtn})

    -- Main Frame
    local MainFrame = Create("Frame", {
        Size = UDim2.new(0, 600, 0, 420), Position = UDim2.new(0.5, -300, 0.5, -210),
        BackgroundColor3 = SlayLib.Theme.Background, Parent = MainGui, ClipsDescendants = true
    })
    local CanvasGroup = Create("CanvasGroup", { -- ใช้ CanvasGroup เพื่อความสมูทในการจางหายตอนปิด
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    local MStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 2, Parent = MainFrame})

    -- Sidebar (แยกส่วน Header เพื่อไม่ให้ชื่อ Tab ทับ Title)
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 190, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = CanvasGroup
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})

    local TitleArea = Create("Frame", {Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = Sidebar})
    local Title = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0),
        Font = "GothamBold", TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left",
        BackgroundTransparency = 1, Parent = TitleArea
    })
    SetTextConfig(Title, Config.Name, true)

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -85), Position = UDim2.new(0, 5, 0, 75),
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar
    })
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 5)})

    -- Page Container
    local PageContainer = Create("Frame", {
        Size = UDim2.new(1, -210, 1, -20), Position = UDim2.new(0, 200, 0, 10),
        BackgroundTransparency = 1, Parent = CanvasGroup
    })

    -- Closing Logic (Fixed Glitch)
    TClick.MouseButton1Click:Connect(function()
        Window.Enabled = not Window.Enabled
        if Window.Enabled then
            MainFrame.Visible = true
            Tween(CanvasGroup, {GroupTransparency = 0}, 0.4)
            Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 420)}, 0.5, Enum.EasingStyle.Back)
        else
            Tween(CanvasGroup, {GroupTransparency = 1}, 0.3)
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
            task.delay(0.5, function() if not Window.Enabled then MainFrame.Visible = false end end)
        end
    end)

    --// TAB SYSTEM
    function Window:CreateTab(Name)
        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
            Text = "   " .. Name, Font = "GothamMedium", TextSize = 14,
            TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = TabScroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Visible = false, ScrollBarThickness = 2, AutomaticCanvasSize = "Y", Parent = PageContainer
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 12)})

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.1, TextColor3 = SlayLib.Theme.MainColor}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.1
            TabBtn.TextColor3 = SlayLib.Theme.MainColor
        end

        function Tab:CreateSection(SName)
            local Sect = {}
            local SLbl = Create("TextLabel", {
                Text = SName:upper(), Size = UDim2.new(1, 0, 0, 20),
                Font = "GothamBold", TextSize = 11, TextColor3 = SlayLib.Theme.MainColor,
                BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page
            })

            -- 1. TOGGLE
            function Sect:CreateToggle(Props)
                local Tgl = {Value = Props.CurrentValue or false}
                local TFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TFrame})
                
                local L = Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text,
                    Font = "GothamMedium", TextXAlignment = "Left", Parent = TFrame
                })
                SetTextConfig(L, Props.Name, true)

                local Sw = Create("Frame", {
                    Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -52, 0.5, -11),
                    BackgroundColor3 = Tgl.Value and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60), Parent = TFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Sw})
                local Dot = Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = Tgl.Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Color3.new(1,1,1), Parent = Sw
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                TFrame:Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                    Tgl.Value = not Tgl.Value
                    Tween(Sw, {BackgroundColor3 = Tgl.Value and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60)}, 0.3)
                    Tween(Dot, {Position = Tgl.Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.3)
                    Props.Callback(Tgl.Value)
                end)
            end

            -- 2. PARAGRAPH (รองรับข้อความยาวพิเศษ)
            function Sect:CreateParagraph(Props)
                local PFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Element,
                    AutomaticSize = "Y", Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = PFrame})
                Create("UIPadding", {Parent = PFrame, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
                
                local Title = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20), Font = "GothamBold", 
                    TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, 
                    TextXAlignment = "Left", Parent = PFrame
                })
                SetTextConfig(Title, Props.Title or "Information", true)

                local Desc = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0), Font = "Gotham", 
                    TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1,
                    TextXAlignment = "Left", AutomaticSize = "Y", Parent = PFrame
                })
                SetTextConfig(Desc, Props.Content or "No content provided.", false)
            end

            -- 3. INPUT (กล่องข้อความ)
            function Sect:CreateInput(Props)
                local IFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = IFrame})
                
                local L = Create("TextLabel", {
                    Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text,
                    Font = "GothamMedium", TextXAlignment = "Left", Parent = IFrame
                })
                SetTextConfig(L, Props.Name, true)

                local Box = Create("TextBox", {
                    Size = UDim2.new(0, 160, 0, 30), Position = UDim2.new(1, -170, 0.5, -15),
                    BackgroundColor3 = Color3.fromRGB(35,35,35), Text = "", PlaceholderText = Props.Placeholder or "Type...",
                    TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 13, Parent = IFrame
                })
                Create("UICorner", {Parent = Box})
                Box.FocusLost:Connect(function() Props.Callback(Box.Text) end)
            end

            -- 4. BUTTON
            function Sect:CreateButton(Props)
                local B = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element,
                    TextColor3 = SlayLib.Theme.Text, Font = "GothamBold", Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = B})
                SetTextConfig(B, Props.Name, true)
                B.MouseButton1Click:Connect(Props.Callback)
            end

            return Sect
        end
        return Tab
    end

    MakeDraggable(MainFrame, TitleArea)
    MakeDraggable(TBtn, TBtn)
    return Window
end

return SlayLib
