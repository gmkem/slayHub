--[[
    SLAYLIB: GRAND MASTER EDITION (PROJECT REBORN)
    Base Concept: Luna / Rayfield
    Optimized for: Mobile & PC
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SlayLib = {
    Options = {},
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(15, 15, 20),
        Sidebar = Color3.fromRGB(22, 22, 28),
        Accent = Color3.fromRGB(0, 160, 255),
        Element = Color3.fromRGB(28, 28, 35),
        Stroke = Color3.fromRGB(45, 45, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 170)
    }
}

-- // Utility Logic \\ --
local function Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

local function AddDecor(obj, radius, hasStroke)
    Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = obj})
    if hasStroke then
        Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Parent = obj})
    end
end

local function MakeDraggable(obj, target)
    target = target or obj
    local dragging, dragInput, dragStart, startPos
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    target.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- // Core Framework \\ --
function SlayLib.new(hubTitle)
    local self = setmetatable({}, {__index = SlayLib})
    
    -- Main Gui
    self.Gui = Create("ScreenGui", {Name = "SlayLib_Pro", Parent = CoreGui, IgnoreGuiInset = true})
    
    -- Mobile Toggle (The Ninja Icon)
    local Toggle = Create("ImageButton", {
        Size = UDim2.fromOffset(48, 48),
        Position = UDim2.new(0, 20, 0.5, -24),
        BackgroundColor3 = SlayLib.Theme.Background,
        Image = "rbxassetid://13160451101",
        Parent = self.Gui
    })
    AddDecor(Toggle, 24, true)
    MakeDraggable(Toggle)
    
    -- Main Window
    local Main = Create("Frame", {
        Size = UDim2.fromOffset(620, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = SlayLib.Theme.Background,
        ClipsDescendants = true,
        Parent = self.Gui
    })
    AddDecor(Main, 10, true)
    MakeDraggable(Main)
    self.Main = Main

    Toggle.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main:TweenScale(1, "Out", "Back", 0.3, true)
        end
    end)

    -- Layout Sections
    local Sidebar = Create("Frame", {Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = Main})
    AddDecor(Sidebar, 10)

    local Title = Create("TextLabel", {
        Text = hubTitle,
        Size = UDim2.new(1, 0, 0, 65),
        TextColor3 = SlayLib.Theme.Accent,
        Font = "GothamBold",
        TextSize = 20,
        BackgroundTransparency = 1,
        Parent = Sidebar
    })

    self.TabHolder = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -130),
        Position = UDim2.fromOffset(0, 65),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = "Center", Parent = self.TabHolder})

    self.PageHolder = Create("Frame", {
        Size = UDim2.new(1, -195, 1, -20),
        Position = UDim2.fromOffset(185, 10),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- Footer Profile
    local UserFrame = Create("Frame", {Size = UDim2.new(0.9, 0, 0, 50), Position = UDim2.new(0.05, 0, 1, -60), BackgroundColor3 = SlayLib.Theme.Element, Parent = Sidebar})
    AddDecor(UserFrame, 8, true)
    local Avatar = Create("ImageLabel", {Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(7, 7), Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, "HeadShot", "Size420x420"), BackgroundTransparency = 1, Parent = UserFrame})
    AddDecor(Avatar, 18)
    Create("TextLabel", {Text = LocalPlayer.DisplayName, Position = UDim2.fromOffset(50, 0), Size = UDim2.new(1, -55, 1, 0), TextColor3 = SlayLib.Theme.Text, Font = "GothamSemibold", TextSize = 12, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = UserFrame})

    return self
end

function SlayLib:CreateTab(name)
    local tab = {Elements = {}}
    
    local TabBtn = Create("TextButton", {
        Size = UDim2.new(0.9, 0, 0, 42),
        BackgroundColor3 = SlayLib.Theme.Accent,
        BackgroundTransparency = 1,
        Text = "    " .. name,
        TextColor3 = SlayLib.Theme.TextDark,
        Font = "GothamSemibold",
        TextSize = 13,
        TextXAlignment = "Left",
        Parent = self.TabHolder
    })
    AddDecor(TabBtn, 8)

    local Page = Create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = SlayLib.Theme.Accent,
        Parent = self.PageHolder
    })
    local Layout = Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = "Center", Parent = Page})
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 20)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.PageHolder:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.TabHolder:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextDark}):Play() end end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, TextColor3 = SlayLib.Theme.Text}):Play()
    end)

    -- Auto-select first tab
    if #self.TabHolder:GetChildren() == 2 then 
        Page.Visible = true 
        TabBtn.BackgroundTransparency = 0.8 
        TabBtn.TextColor3 = SlayLib.Theme.Text
    end

    -- // Elements \\ --

    function tab:CreateButton(txt, cb)
        local b = Create("TextButton", {Size = UDim2.new(0.98, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Text = "  " .. txt, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 14, TextXAlignment = "Left", AutoButtonColor = false, Parent = Page})
        AddDecor(b, 8, true)
        b.MouseButton1Click:Connect(cb)
        -- Ripple Effect
        b.MouseButton1Down:Connect(function()
            local r = Create("Frame", {Size = UDim2.fromOffset(0,0), Position = UDim2.fromOffset(Mouse.X - b.AbsolutePosition.X, Mouse.Y - b.AbsolutePosition.Y), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8, Parent = b})
            AddDecor(r, 100)
            TweenService:Create(r, TweenInfo.new(0.5), {Size = UDim2.fromOffset(400, 400), Position = UDim2.fromOffset(-200, -200), BackgroundTransparency = 1}):Play()
            task.delay(0.5, function() r:Destroy() end)
        end)
    end

    function tab:CreateToggle(txt, def, cb)
        local state = def
        local t = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
        AddDecor(t, 8, true)
        Create("TextLabel", {Text = "  " .. txt, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 14, TextXAlignment = "Left", Parent = t})
        
        local bg = Create("Frame", {Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -55, 0.5, -11), BackgroundColor3 = Color3.fromRGB(15,15,20), Parent = t})
        AddDecor(bg, 11, true)
        local ind = Create("Frame", {Size = UDim2.fromOffset(18, 18), Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = state and SlayLib.Theme.Accent or SlayLib.Theme.TextDark, Parent = bg})
        AddDecor(ind, 9)

        t.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                state = not state
                TweenService:Create(ind, TweenInfo.new(0.25, Enum.EasingStyle.BackOut), {Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = state and SlayLib.Theme.Accent or SlayLib.Theme.TextDark}):Play()
                cb(state)
            end
        end)
    end

    function tab:CreateSlider(txt, min, max, def, cb)
        local s = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 65), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
        AddDecor(s, 8, true)
        Create("TextLabel", {Text = "  " .. txt, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", Parent = s, TextXAlignment = "Left"})
        local valL = Create("TextLabel", {Text = tostring(def) .. " ", Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Accent, Font = "GothamBold", Parent = s, TextXAlignment = "Right"})
        
        local tray = Create("Frame", {Size = UDim2.new(0.94, 0, 0, 6), Position = UDim2.new(0.03, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(15,15,20), Parent = s})
        AddDecor(tray, 3, true)
        local fill = Create("Frame", {Size = UDim2.fromScale((def-min)/(max-min), 1), BackgroundColor3 = SlayLib.Theme.Accent, Parent = tray})
        AddDecor(fill, 3)

        local function update()
            local p = math.clamp((Mouse.X - tray.AbsolutePosition.X) / tray.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * p)
            fill.Size = UDim2.fromScale(p, 1)
            valL.Text = tostring(val) .. " "
            cb(val)
        end
        tray.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then local c c = RunService.RenderStepped:Connect(update) UserInputService.InputEnded:Connect(function(i2) if i2.UserInputType == Enum.UserInputType.MouseButton1 or i2.UserInputType == Enum.UserInputType.Touch then c:Disconnect() end end) end end)
    end

    function tab:CreateKeybind(txt, def, cb)
        local currentBind = def
        local f = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
        AddDecor(f, 8, true)
        Create("TextLabel", {Text = "  " .. txt, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", Parent = f, TextXAlignment = "Left"})
        
        local bBox = Create("TextButton", {Text = currentBind.Name, Size = UDim2.fromOffset(80, 25), Position = UDim2.new(1, -90, 0.5, -12), BackgroundColor3 = SlayLib.Theme.Background, TextColor3 = SlayLib.Theme.Accent, Font = "GothamBold", Parent = f})
        AddDecor(bBox, 6, true)
        
        bBox.MouseButton1Click:Connect(function()
            bBox.Text = "..."
            local input = UserInputService.InputBegan:Wait()
            if input.UserInputType == Enum.UserInputType.Keyboard then
                bBox.Text = input.KeyCode.Name
                currentBind = input.KeyCode
            end
        end)
        UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == currentBind then cb() end end)
    end

    return tab
end

return SlayLib
