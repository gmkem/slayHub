--[[
    ================================================================================
    SLAYLIB X - ZERO BUG & ULTIMATE STABILITY EDITION (2025)
    ================================================================================
]]

local SlayLib = {
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(24, 24, 24),
        ElementHover = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45),
    }
}

--// Services & Variables
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ตรวจสอบ Executor หรือ Studio
local Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)

--// Helper Functions (ป้องกันการเกิดบัค)
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function ApplyTween(obj, goal, time)
    local tInfo = TweenInfo.new(time or 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tInfo, goal)
    tween:Play()
    return tween
end

-- ระบบคุมตัวอักษรไม่ให้ล้น (Smart Text Scale)
local function SmartText(label, text, size)
    label.Text = text
    label.TextWrapped = true
    label.TextSize = size
    -- ถ้าข้อความยาวเกินไป จะลดขนาดฟอนต์อัตโนมัติ
    if #text > 30 then
        label.TextSize = size - 2
    elseif #text > 50 then
        label.TextSize = size - 4
    end
end

--// Notification System (Fixed & Stackable)
function SlayLib:Notify(Config)
    Config = Config or {Title = "SlayLib X", Content = "Notification Content", Duration = 5}
    
    local Holder = Parent:FindFirstChild("SlayNotifyHolder")
    if not Holder then
        Holder = Create("Frame", {
            Name = "SlayNotifyHolder", Parent = Parent, BackgroundTransparency = 1,
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
    SmartText(Title, Config.Title, 14)

    local Content = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 28),
        Font = "Gotham", TextColor3 = SlayLib.Theme.Text,
        BackgroundTransparency = 1, TextXAlignment = "Left", AutomaticSize = "Y", Parent = Notif
    })
    SmartText(Content, Config.Content, 12)

    ApplyTween(Notif, {Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 0}, 0.5)
    ApplyTween(Stroke, {Transparency = 0}, 0.5)

    task.delay(Config.Duration, function()
        ApplyTween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.5)
        ApplyTween(Stroke, {Transparency = 1}, 0.5)
        task.wait(0.5) Notif:Destroy()
    end)
end

--// New Smooth Loading (Blur & Animation)
local function StartLoading()
    local LoadingGui = Create("ScreenGui", {Parent = Parent, Name = "SlayLoading"})
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    ApplyTween(Blur, {Size = 24}, 1)

    local Logo = Create("ImageLabel", {
        Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0.5, -50, 0.5, -50),
        Image = "rbxassetid://13589839447", ImageColor3 = SlayLib.Theme.MainColor,
        BackgroundTransparency = 1, Parent = LoadingGui, ImageTransparency = 1
    })
    
    ApplyTween(Logo, {ImageTransparency = 0, Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0.5, -60, 0.5, -60)}, 0.8)
    task.wait(2)
    ApplyTween(Logo, {ImageTransparency = 1}, 0.5)
    ApplyTween(Blur, {Size = 0}, 0.8)
    task.wait(0.8)
    LoadingGui:Destroy() Blur:Destroy()
end

--// Window Core (The Frame)
function SlayLib:CreateWindow(Settings)
    Settings = Settings or {Name = "SlayLib X"}
    task.spawn(StartLoading)

    local Window = {Visible = true, CurrentTab = nil}
    local MainGui = Create("ScreenGui", {Name = "SlayLib_GUI", Parent = Parent})

    -- Floating Button
    local TBtn = Create("Frame", {
        Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.05, 0, 0.1, 0),
        BackgroundColor3 = SlayLib.Theme.MainColor, Parent = MainGui
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TBtn})
    local TIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15),
        Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = TBtn
    })
    local TClick = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = TBtn})

    -- Main Frame (Using CanvasGroup for smooth fade)
    local MainFrame = Create("CanvasGroup", {
        Size = UDim2.new(0, 580, 0, 400), Position = UDim2.new(0.5, -290, 0.5, -200),
        BackgroundColor3 = SlayLib.Theme.Background, Parent = MainGui, GroupTransparency = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 2, Parent = MainFrame})

    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})

    -- Header (Fixed Title)
    local Title = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 60), Position = UDim2.new(0, 20, 0, 0),
        Font = "GothamBold", TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left",
        BackgroundTransparency = 1, Parent = Sidebar
    })
    SmartText(Title, Settings.Name, 18)

    local TabScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -70), Position = UDim2.new(0, 5, 0, 65),
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar
    })
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 5)})

    local PageContainer = Create("Frame", {
        Size = UDim2.new(1, -200, 1, -20), Position = UDim2.new(0, 190, 0, 10),
        BackgroundTransparency = 1, Parent = MainFrame
    })

    -- Drag Logic
    local function MakeDraggable(UI, Handle)
        local Dragging, DragInput, DragStart, StartPos
        Handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true; DragStart = input.Position; StartPos = UI.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local Delta = input.Position - DragStart
                UI.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            end
        end)
        Handle.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
    end
    MakeDraggable(MainFrame, Sidebar)
    MakeDraggable(TBtn, TBtn)

    -- Toggle GUI
    TClick.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            ApplyTween(MainFrame, {GroupTransparency = 0}, 0.3)
        else
            ApplyTween(MainFrame, {GroupTransparency = 1}, 0.3)
            task.delay(0.3, function() if not Window.Visible then MainFrame.Visible = false end end)
        end
    end)

    --// Tab Builder
    function Window:CreateTab(Name)
        local Tab = {}
        local TBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
            Text = "   " .. Name, Font = "GothamMedium", TextSize = 14,
            TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = TabScroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Visible = false, ScrollBarThickness = 2, AutomaticCanvasSize = "Y", Parent = PageContainer
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10)})

        TBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Window.CurrentTab.Btn.TextColor3 = SlayLib.Theme.TextSecondary
                Window.CurrentTab.Btn.BackgroundTransparency = 1
            end
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.TextColor3 = SlayLib.Theme.MainColor
            TBtn.BackgroundTransparency = 0.9
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.TextColor3 = SlayLib.Theme.MainColor
            TBtn.BackgroundTransparency = 0.9
        end

        function Tab:CreateSection(SectName)
            local Section = {}
            Create("TextLabel", {
                Text = SectName:upper(), Size = UDim2.new(1, 0, 0, 20),
                Font = "GothamBold", TextSize = 11, TextColor3 = SlayLib.Theme.MainColor,
                BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page
            })

            -- Button Element
            function Section:CreateButton(Props)
                local B = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = SlayLib.Theme.Element,
                    TextColor3 = SlayLib.Theme.Text, Font = "GothamMedium", Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = B})
                SmartText(B, Props.Name, 14)
                B.MouseButton1Click:Connect(Props.Callback)
            end

            -- Toggle Element
            function Section:CreateToggle(Props)
                local Tgl = {Value = Props.CurrentValue or false}
                local TFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TFrame})
                
                local L = Create("TextLabel", {Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", Font = "GothamMedium", Parent = TFrame})
                SmartText(L, Props.Name, 14)

                local Sw = Create("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1,-46,0.5,-9), BackgroundColor3 = Tgl.Value and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60), Parent = TFrame})
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Sw})
                local Dot = Create("Frame", {Size = UDim2.new(0,14,0,14), Position = Tgl.Value and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3 = Color3.new(1,1,1), Parent = Sw})
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Dot})

                TFrame:Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                    Tgl.Value = not Tgl.Value
                    ApplyTween(Sw, {BackgroundColor3 = Tgl.Value and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60)}, 0.2)
                    ApplyTween(Dot, {Position = Tgl.Value and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}, 0.2)
                    Props.Callback(Tgl.Value)
                end)
            end

            -- Paragraph Element (รองรับข้อความยาวมาก)
            function Section:CreateParagraph(Props)
                local PFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Element, AutomaticSize = "Y", Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = PFrame})
                Create("UIPadding", {Parent = PFrame, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
                
                local Title = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Font = "GothamBold", TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = PFrame})
                SmartText(Title, Props.Title or "Info", 14)

                local Desc = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y", Font = "Gotham", TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = PFrame})
                SmartText(Desc, Props.Content or "Content", 12)
            end

            return Section
        end
        return Tab
    end

    return Window
end

return SlayLib
