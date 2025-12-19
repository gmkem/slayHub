--[[
    ================================================================================
    SLAYLIB X - THE DEFINITIVE STABLE EDITION (REBUILT FROM SCRATCH)
    ================================================================================
    - Fix: Toggle Logic / Loading Sequence / Tab Overlap / Missing Modules
    - Features: Auto-Scaling Text / Safe Area Title / Full Unabridged Logic
    ================================================================================
]]

local SlayLib = {
    Options = {},
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45),
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

local Parent = (RunService:IsStudio() and Players.LocalPlayer.PlayerGui or CoreGui)

--// Essential Functions
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function Tween(obj, goal, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal):Play()
end

local function MakeDraggable(UI, Handle)
    local Dragging, DragInput, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = UI.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            UI.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    Handle.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

--// Notification System (Stable Stack)
function SlayLib:Notify(Config)
    Config = Config or {Title = "Notification", Content = "Content", Duration = 5}
    local Holder = Parent:FindFirstChild("SlayNotifyHolder") or Create("Frame", {Name = "SlayNotifyHolder", Parent = Parent, BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, -20), Position = UDim2.new(1, -310, 0, 10)})
    if not Holder:FindFirstChild("UIListLayout") then Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 8)}) end

    local Notif = Create("Frame", {Size = UDim2.new(1, 0, 0, 65), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = Holder, ClipsDescendants = true})
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notif})
    Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.5, Parent = Notif})

    local T = Create("TextLabel", {Text = Config.Title, Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5), Font = "GothamBold", TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Notif})
    local C = Create("TextLabel", {Text = Config.Content, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 28), Font = "Gotham", TextColor3 = SlayLib.Theme.Text, BackgroundTransparency = 1, TextXAlignment = "Left", TextWrapped = true, Parent = Notif})

    task.delay(Config.Duration, function() Notif:Destroy() end)
end

--// Main Window
function SlayLib:CreateWindow(Settings)
    Settings = Settings or {Name = "SlayLib X"}
    
    local Window = {Visible = true, CurrentTab = nil}
    local MainGui = Create("ScreenGui", {Name = "SlayLib_Core", Parent = Parent, ResetOnSpawn = false})

    -- 1. Loading Screen (Wait for Finish)
    local LoadFrame = Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 999, Parent = MainGui})
    local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})
    local Logo = Create("ImageLabel", {Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0.5, -60, 0.5, -60), Image = "rbxassetid://13589839447", BackgroundTransparency = 1, ImageColor3 = SlayLib.Theme.MainColor, Parent = LoadFrame, ImageTransparency = 1})
    
    -- 2. Main Frame (Initially Hidden)
    local MainFrame = Create("Frame", {Size = UDim2.new(0, 600, 0, 420), Position = UDim2.new(0.5, -300, 0.5, -210), BackgroundColor3 = SlayLib.Theme.Background, Visible = false, Parent = MainGui})
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 2, Parent = MainFrame})

    -- 3. Floating Button
    local ToggleBtn = Create("TextButton", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.05, 0, 0.1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Text = "", Parent = MainGui})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})
    Create("ImageLabel", {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15), Image = "rbxassetid://13589839447", BackgroundTransparency = 1, Parent = ToggleBtn})
    MakeDraggable(ToggleBtn, ToggleBtn)

    -- Sidebar & Header (Title Isolation)
    local Sidebar = Create("Frame", {Size = UDim2.new(0, 190, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame})
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
    
    local Header = Create("Frame", {Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = Sidebar})
    local LibTitle = Create("TextLabel", {Text = Settings.Name, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0), Font = "GothamBold", TextSize = 18, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Header})

    local TabScroll = Create("ScrollingFrame", {Size = UDim2.new(1, -10, 1, -80), Position = UDim2.new(0, 5, 0, 75), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar})
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 6), HorizontalAlignment = "Center"})

    local PageContainer = Create("Frame", {Size = UDim2.new(1, -210, 1, -20), Position = UDim2.new(0, 200, 0, 10), BackgroundTransparency = 1, Parent = MainFrame})

    -- Toggle Logic (Fixed)
    ToggleBtn.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        MainFrame.Visible = Window.Visible
    end)

    -- Start Loading Sequence
    task.spawn(function()
        Tween(Blur, {Size = 24}, 0.5)
        Tween(Logo, {ImageTransparency = 0}, 0.5)
        task.wait(1.5)
        Tween(Blur, {Size = 0}, 0.5)
        Tween(Logo, {ImageTransparency = 1}, 0.5)
        task.wait(0.5)
        LoadFrame:Destroy()
        MainFrame.Visible = true
    end)

    --// Tab System
    function Window:CreateTab(Name)
        local Tab = {}
        local TBtn = Create("TextButton", {Size = UDim2.new(0, 170, 0, 40), BackgroundColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, Text = "  " .. Name, Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = TabScroll})
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TBtn})

        local Page = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, AutomaticCanvasSize = "Y", Parent = PageContainer})
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10)})

        TBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Window.CurrentTab.Btn.BackgroundTransparency = 1
                Window.CurrentTab.Btn.TextColor3 = SlayLib.Theme.TextSecondary
            end
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.BackgroundTransparency = 0.1
            TBtn.TextColor3 = SlayLib.Theme.MainColor
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.BackgroundTransparency = 0.1
            TBtn.TextColor3 = SlayLib.Theme.MainColor
        end

        function Tab:CreateSection(SName)
            local Sect = {}
            Create("TextLabel", {Text = SName:upper(), Size = UDim2.new(1, 0, 0, 25), Font = "GothamBold", TextSize = 11, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page})

            -- 1. Toggle
            function Sect:CreateToggle(Props)
                local Tgl = {State = Props.CurrentValue or false}
                local Frame = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
                local L = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1, 0, 1, 0), Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Frame})
                
                local SwBg = Create("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Tgl.State and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60), Parent = Frame})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwBg})
                local Dot = Create("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = Tgl.State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1), Parent = SwBg})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = Frame}).MouseButton1Click:Connect(function()
                    Tgl.State = not Tgl.State
                    Tween(SwBg, {BackgroundColor3 = Tgl.State and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60)}, 0.2)
                    Tween(Dot, {Position = Tgl.State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.2)
                    Props.Callback(Tgl.State)
                end)
            end

            -- 2. Slider
            function Sect:CreateSlider(Props)
                local SFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SFrame})
                local L = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1, 0, 0, 30), Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = SFrame})
                local V = Create("TextLabel", {Text = tostring(Props.Def), Size = UDim2.new(1, -15, 0, 30), Font = "Code", TextSize = 13, TextColor3 = SlayLib.Theme.MainColor, TextXAlignment = "Right", BackgroundTransparency = 1, Parent = SFrame})
                
                local Bar = Create("Frame", {Size = UDim2.new(1, -30, 0, 5), Position = UDim2.new(0, 15, 0, 42), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Parent = SFrame})
                local Fill = Create("Frame", {Size = UDim2.new((Props.Def - Props.Min)/(Props.Max - Props.Min), 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = Bar})
                
                local function Update()
                    local P = math.clamp((Mouse.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local Val = math.floor(Props.Min + (Props.Max - Props.Min) * P)
                    Fill.Size = UDim2.new(P, 0, 1, 0)
                    V.Text = tostring(Val)
                    Props.Callback(Val)
                end
                Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local move = UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then Update() end end) local ended; ended = UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect(); ended:Disconnect() end end) end end)
            end

            -- 3. Dropdown
            function Sect:CreateDropdown(Props)
                local IsOpen = false
                local DFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, ClipsDescendants = true, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DFrame})
                local L = Create("TextButton", {Text = "  "..Props.Name, Size = UDim2.new(1, 0, 0, 45), Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = DFrame})
                local List = Create("Frame", {Size = UDim2.new(1, 0, 0, #Props.Options * 35), Position = UDim2.new(0, 0, 0, 45), BackgroundTransparency = 1, Parent = DFrame})
                Create("UIListLayout", {Parent = List})

                for _, opt in pairs(Props.Options) do
                    local O = Create("TextButton", {Text = "    "..tostring(opt), Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Font = "Gotham", TextSize = 13, TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = List})
                    O.MouseButton1Click:Connect(function() L.Text = "  "..Props.Name..": "..tostring(opt); IsOpen = false; Tween(DFrame, {Size = UDim2.new(1, 0, 0, 45)}); Props.Callback(opt) end)
                end

                L.MouseButton1Click:Connect(function() IsOpen = not IsOpen; Tween(DFrame, {Size = IsOpen and UDim2.new(1, 0, 0, 45 + List.Size.Y.Offset) or UDim2.new(1, 0, 0, 45)}) end)
            end

            -- 4. Button
            function Sect:CreateButton(Props)
                local B = Create("TextButton", {Text = Props.Name, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = SlayLib.Theme.Element, Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.Theme.Text, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = B})
                B.MouseButton1Click:Connect(Props.Callback)
            end

            -- 5. Paragraph (Smart Multi-line)
            function Sect:CreateParagraph(Props)
                local P = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Element, AutomaticSize = "Y", Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = P})
                local T = Create("TextLabel", {Text = Props.Title or "Info", Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5), Font = "GothamBold", TextSize = 13, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = P})
                local C = Create("TextLabel", {Text = Props.Content or "", Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 25), Font = "Gotham", TextSize = 12, TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1, TextXAlignment = "Left", TextWrapped = true, AutomaticSize = "Y", Parent = P})
                Create("UIPadding", {Parent = P, PaddingBottom = UDim.new(0, 10)})
            end

            return Sect
        end
        return Tab
    end

    MakeDraggable(MainFrame, Header)
    return Window
end

return SlayLib
