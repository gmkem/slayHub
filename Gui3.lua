--[[
    SLAYLIB: REDEFINED (PRO PROJECT EDITION)
    - Zero Lag Layout Engine
    - Advanced Component Logic
    - Dynamic UI Toggling & Mobile Support
    - Professional Glassmorphism V3
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SlayLib = {
    Elements = {},
    Flags = {},
    Themes = {
        Background = Color3.fromRGB(13, 13, 15),
        Sidebar = Color3.fromRGB(18, 18, 22),
        Accent = Color3.fromRGB(0, 160, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 140, 145),
        Element = Color3.fromRGB(25, 25, 30),
        Stroke = Color3.fromRGB(40, 40, 45)
    }
}

-- // UI Creation Helpers \\ --
local function Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

local function ApplyStyle(obj, radius, stroke)
    Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = obj})
    if stroke then
        Create("UIStroke", {Color = SlayLib.Themes.Stroke, Thickness = 1, Parent = obj})
    end
end

local function MakeDraggable(obj, handler)
    handler = handler or obj
    local dragging, dragInput, dragStart, startPos
    handler.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.QuadOut), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- // Notification Engine \\ --
local NotificationGui = Create("ScreenGui", {Name = "SlayNotifs", Parent = CoreGui})
local NotifHolder = Create("Frame", {Size = UDim2.new(0, 280, 1, -20), Position = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Parent = NotificationGui})
Create("UIListLayout", {VerticalAlignment = "Bottom", Padding = UDim.new(0, 10), Parent = NotifHolder})

function SlayLib:Notify(title, msg, dur)
    local n = Create("Frame", {Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = SlayLib.Themes.Background, Parent = NotifHolder})
    ApplyStyle(n, 10, true)
    
    local bar = Create("Frame", {Size = UDim2.new(0, 4, 1, -20), Position = UDim2.fromOffset(8, 10), BackgroundColor3 = SlayLib.Themes.Accent, Parent = n})
    ApplyStyle(bar, 2)

    Create("TextLabel", {Text = title, Position = UDim2.fromOffset(20, 10), Size = UDim2.new(1, -30, 0, 20), TextColor3 = SlayLib.Themes.Accent, Font = "GothamBold", TextSize = 14, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = n})
    Create("TextLabel", {Text = msg, Position = UDim2.fromOffset(20, 30), Size = UDim2.new(1, -30, 0, 30), TextColor3 = SlayLib.Themes.Text, Font = "Gotham", TextSize = 12, TextXAlignment = "Left", TextWrapped = true, BackgroundTransparency = 1, Parent = n})

    n.Position = UDim2.fromScale(-1.2, 0)
    TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.BackOut), {Position = UDim2.fromScale(0, 0)}):Play()
    task.delay(dur or 4, function()
        TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.QuadIn), {Position = UDim2.fromScale(-1.2, 0)}):Play()
        task.wait(0.5) n:Destroy()
    end)
end

-- // Core Framework \\ --
function SlayLib.new(projName)
    local self = setmetatable({}, {__index = SlayLib})
    
    self.Gui = Create("ScreenGui", {Name = "SlayLib_Redefined", Parent = CoreGui, IgnoreGuiInset = true})
    
    -- Mobile Toggle
    local Toggle = Create("ImageButton", {Size = UDim2.fromOffset(45, 45), Position = UDim2.new(0.05, 0, 0.2, 0), BackgroundColor3 = SlayLib.Themes.Background, Image = "rbxassetid://13160451101", Parent = self.Gui})
    ApplyStyle(Toggle, 22, true)
    MakeDraggable(Toggle)
    
    -- Main Window
    local Main = Create("Frame", {Size = UDim2.fromOffset(600, 400), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = SlayLib.Themes.Background, Parent = self.Gui})
    ApplyStyle(Main, 12, true)
    MakeDraggable(Main)
    self.Main = Main

    Toggle.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main:TweenSize(UDim2.fromOffset(600, 400), "Out", "Back", 0.3, true)
        end
    end)

    -- Layout
    local Sidebar = Create("Frame", {Size = UDim2.new(0, 170, 1, 0), BackgroundColor3 = SlayLib.Themes.Sidebar, Parent = Main})
    ApplyStyle(Sidebar, 12)
    
    Create("TextLabel", {Text = projName, Size = UDim2.new(1, 0, 0, 60), TextColor3 = SlayLib.Themes.Accent, Font = "GothamBold", TextSize = 18, BackgroundTransparency = 1, Parent = Sidebar})

    self.TabContainer = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -120), Position = UDim2.fromOffset(0, 60), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar})
    Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = "Center", Parent = self.TabContainer})

    self.PageContainer = Create("Frame", {Size = UDim2.new(1, -185, 1, -20), Position = UDim2.fromOffset(180, 10), BackgroundTransparency = 1, Parent = Main})

    -- User Stats
    local User = Create("Frame", {Size = UDim2.new(0.9, 0, 0, 45), Position = UDim2.new(0.05, 0, 1, -55), BackgroundColor3 = SlayLib.Themes.Element, Parent = Sidebar})
    ApplyStyle(User, 8, true)
    local Avatar = Create("ImageLabel", {Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(6, 6), Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, "HeadShot", "Size420x420"), BackgroundTransparency = 1, Parent = User})
    ApplyStyle(Avatar, 16)
    Create("TextLabel", {Text = LocalPlayer.DisplayName, Position = UDim2.fromOffset(45, 0), Size = UDim2.new(1, -50, 1, 0), TextColor3 = SlayLib.Themes.Text, Font = "GothamSemibold", TextSize = 12, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = User})

    return self
end

function SlayLib:CreateTab(name)
    local tab = {}
    
    local TabBtn = Create("TextButton", {Size = UDim2.new(0.9, 0, 0, 38), BackgroundTransparency = 1, Text = "  " .. name, TextColor3 = SlayLib.Themes.TextDark, Font = "GothamSemibold", TextSize = 13, TextXAlignment = "Left", Parent = self.TabContainer})
    ApplyStyle(TabBtn, 6)

    local Page = Create("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, Parent = self.PageContainer})
    local Layout = Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center", Parent = Page})
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 20) end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.PageContainer:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.TabContainer:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = SlayLib.Themes.TextDark}):Play() end end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, BackgroundColor3 = SlayLib.Themes.Accent, TextColor3 = SlayLib.Themes.Text}):Play()
    end)

    if #self.TabContainer:GetChildren() == 2 then
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.BackgroundColor3 = SlayLib.Themes.Accent
        TabBtn.TextColor3 = SlayLib.Themes.Text
    end

    -- // Element Systems \\ --

    function tab:CreateButton(txt, cb)
        local b = Create("TextButton", {Size = UDim2.new(0.98, 0, 0, 42), BackgroundColor3 = SlayLib.Themes.Element, Text = "  " .. txt, TextColor3 = SlayLib.Themes.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left", AutoButtonColor = false, Parent = Page})
        ApplyStyle(b, 6, true)
        b.MouseButton1Click:Connect(cb)
        -- Ripple Effect
        b.MouseButton1Click:Connect(function()
            local r = Create("Frame", {Size = UDim2.fromOffset(0,0), Position = UDim2.fromOffset(Mouse.X - b.AbsolutePosition.X, Mouse.Y - b.AbsolutePosition.Y), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8, Parent = b})
            ApplyStyle(r, 100)
            TweenService:Create(r, TweenInfo.new(0.5), {Size = UDim2.fromOffset(400, 400), Position = UDim2.fromOffset(-200, -200), BackgroundTransparency = 1}):Play()
            task.delay(0.5, function() r:Destroy() end)
        end)
    end

    function tab:CreateToggle(txt, def, cb)
        local state = def
        local t = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 42), BackgroundColor3 = SlayLib.Themes.Element, Parent = Page})
        ApplyStyle(t, 6, true)
        Create("TextLabel", {Text = "  " .. txt, Size = UDim2.fromScale(1, 1), TextColor3 = SlayLib.Themes.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = t})
        
        local bg = Create("Frame", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(15,15,20), Parent = t})
        ApplyStyle(bg, 10, true)
        local ind = Create("Frame", {Size = UDim2.fromOffset(16, 16), Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = state and SlayLib.Themes.Accent or SlayLib.Themes.TextDark, Parent = bg})
        ApplyStyle(ind, 8)

        t.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                state = not state
                TweenService:Create(ind, TweenInfo.new(0.2, Enum.EasingStyle.BackOut), {Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = state and SlayLib.Themes.Accent or SlayLib.Themes.TextDark}):Play()
                cb(state)
            end
        end)
    end

    function tab:CreateSlider(txt, min, max, def, cb)
        local s = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 55), BackgroundColor3 = SlayLib.Themes.Element, Parent = Page})
        ApplyStyle(s, 6, true)
        Create("TextLabel", {Text = "  " .. txt, Size = UDim2.new(1, 0, 0, 30), TextColor3 = SlayLib.Themes.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = s})
        local valL = Create("TextLabel", {Text = tostring(def) .. " ", Size = UDim2.new(1, 0, 0, 30), TextColor3 = SlayLib.Themes.Accent, Font = "GothamBold", TextSize = 13, TextXAlignment = "Right", BackgroundTransparency = 1, Parent = s})
        
        local tray = Create("Frame", {Size = UDim2.new(0.94, 0, 0, 6), Position = UDim2.new(0.03, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(15,15,20), Parent = s})
        ApplyStyle(tray, 3, true)
        local fill = Create("Frame", {Size = UDim2.fromScale((def-min)/(max-min), 1), BackgroundColor3 = SlayLib.Themes.Accent, Parent = tray})
        ApplyStyle(fill, 3)

        local function update()
            local p = math.clamp((Mouse.X - tray.AbsolutePosition.X) / tray.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * p)
            fill.Size = UDim2.fromScale(p, 1)
            valL.Text = tostring(val) .. " "
            cb(val)
        end
        tray.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then local c c = RunService.RenderStepped:Connect(update) UserInputService.InputEnded:Connect(function(i2) if i2.UserInputType == Enum.UserInputType.MouseButton1 or i2.UserInputType == Enum.UserInputType.Touch then c:Disconnect() end end) end end)
    end

    return tab
end

return SlayLib
