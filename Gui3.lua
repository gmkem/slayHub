--[[ 
    SLAYLIB: GRAND MASTER EDITION
    Professional High-End UI Library for Roblox
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SlayLib = {
    Flags = {},
    Theme = {
        Main = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(0, 160, 255),
        Outline = Color3.fromRGB(45, 45, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 165),
        TopBar = Color3.fromRGB(30, 30, 35)
    }
}
SlayLib.__index = SlayLib

-- // Internal Utilities \\ --
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function Round(obj, radius)
    local c = Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = obj})
    return c
end

local function Stroke(obj, color, thickness, trans)
    local s = Create("UIStroke", {
        Color = color or SlayLib.Theme.Outline,
        Thickness = thickness or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = obj
    })
    return s
end

local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Click:Connect(function()
        local r = Create("Frame", {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.fromOffset(Mouse.X - obj.AbsolutePosition.X, Mouse.Y - obj.AbsolutePosition.Y),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.8,
            Parent = obj
        })
        Round(r, 1000)
        TweenService:Create(r, TweenInfo.new(0.5, Enum.EasingStyle.QuadOut), {
            Size = UDim2.fromOffset(obj.AbsoluteSize.X * 2, obj.AbsoluteSize.X * 2),
            Position = UDim2.fromOffset(obj.AbsoluteSize.X/2 - obj.AbsoluteSize.X, obj.AbsoluteSize.Y/2 - obj.AbsoluteSize.X),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.5, function() r:Destroy() end)
    end)
end

-- // Core Logic \\ --
function SlayLib.new(config)
    local self = setmetatable({}, SlayLib)
    config = config or {Name = "SLAYLIB GM", LoadingText = "Initializing Engine..."}
    
    -- Screen GUI
    self.Gui = Create("ScreenGui", {Name = "SlayLib_GrandMaster", Parent = LocalPlayer:WaitForChild("PlayerGui"), IgnoreGuiInset = true})
    
    -- Main Window
    self.Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(620, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = SlayLib.Theme.Main,
        BackgroundTransparency = 0.1,
        Parent = self.Gui
    })
    Round(self.Main, 12)
    Stroke(self.Main)

    -- Floating Toggle Button (For Mobile)
    local ToggleBtn = Create("ImageButton", {
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(0, 20, 0.5, 0),
        BackgroundColor3 = SlayLib.Theme.Secondary,
        Image = "rbxassetid://13160451101",
        Parent = self.Gui
    })
    Round(ToggleBtn, 25)
    Stroke(ToggleBtn, SlayLib.Theme.Accent, 2)
    
    -- Draggable Toggle
    local draggingBtn, dragStartBtn, startPosBtn
    ToggleBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingBtn = true dragStartBtn = i.Position startPosBtn = ToggleBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if draggingBtn then local delta = i.Position - dragStartBtn ToggleBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingBtn = false end end)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        self.Main.Visible = not self.Main.Visible
        if self.Main.Visible then
            self.Main:TweenSize(UDim2.fromOffset(620, 420), "Out", "Back", 0.3, true)
        end
    end)

    -- Content Area
    self.Sidebar = Create("Frame", {Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = SlayLib.Theme.Secondary, BackgroundTransparency = 0.5, Parent = self.Main})
    Round(self.Sidebar, 12)
    
    local Title = Create("TextLabel", {
        Text = config.Name,
        Size = UDim2.new(1, 0, 0, 50),
        TextColor3 = SlayLib.Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BackgroundTransparency = 1,
        Parent = self.Sidebar
    })

    self.TabHolder = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -120),
        Position = UDim2.fromOffset(0, 60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = self.Sidebar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = "Center", Parent = self.TabHolder})

    self.PageHolder = Create("Frame", {Size = UDim2.new(1, -195, 1, -20), Position = UDim2.fromOffset(185, 10), BackgroundTransparency = 1, Parent = self.Main})

    -- User Profile
    local Profile = Create("Frame", {Size = UDim2.new(0.9, 0, 0, 50), Position = UDim2.new(0.05, 0, 1, -60), BackgroundColor3 = SlayLib.Theme.Main, Parent = self.Sidebar})
    Round(Profile, 10)
    Stroke(Profile)
    
    local Avatar = Create("ImageLabel", {Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(7, 7), BackgroundTransparency = 1, Parent = Profile})
    Avatar.Image = game:GetService("Players"):GetUserThumbnailAsync(LocalPlayer.UserId, "HeadShot", "Size420x420")
    Round(Avatar, 18)
    
    Create("TextLabel", {Text = LocalPlayer.DisplayName, Size = UDim2.new(1, -55, 1, 0), Position = UDim2.fromOffset(50, 0), TextColor3 = SlayLib.Theme.Text, Font = "GothamSemibold", TextSize = 12, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Profile})

    -- Draggable Main
    local drag, dragInput, dragStart, startPos
    self.Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true dragStart = i.Position startPos = self.Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag then local delta = i.Position - dragStart self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

    return self
end

function SlayLib:CreateTab(name, icon)
    local tab = {Active = false}
    
    local TabBtn = Create("TextButton", {
        Size = UDim2.new(0.9, 0, 0, 40),
        BackgroundColor3 = SlayLib.Theme.Accent,
        BackgroundTransparency = 1,
        Text = "    " .. name,
        TextColor3 = SlayLib.Theme.TextDark,
        Font = "GothamSemibold",
        TextSize = 13,
        TextXAlignment = "Left",
        Parent = self.TabHolder
    })
    Round(TabBtn, 8)
    Ripple(TabBtn)

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

    -- Element Factory
    function tab:CreateButton(txt, cb)
        local b = Create("TextButton", {Size = UDim2.new(0.98, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Secondary, Text = "  " .. txt, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 14, TextXAlignment = "Left", AutoButtonColor = false, Parent = Page})
        Round(b)
        Stroke(b)
        Ripple(b)
        b.MouseButton1Click:Connect(cb)
    end

    function tab:CreateToggle(txt, def, cb)
        local toggled = def
        local f = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Secondary, Parent = Page})
        Round(f) Stroke(f)
        
        local l = Create("TextLabel", {Text = "  " .. txt, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 14, TextXAlignment = "Left", Parent = f})
        local box = Create("Frame", {Size = UDim2.fromOffset(44, 22), Position = UDim2.new(1, -55, 0.5, -11), BackgroundColor3 = Color3.fromRGB(20,20,25), Parent = f})
        Round(box, 11) Stroke(box)
        
        local p = Create("Frame", {Size = UDim2.fromOffset(18, 18), Position = toggled and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = toggled and SlayLib.Theme.Accent or SlayLib.Theme.TextDark, Parent = box})
        Round(p, 9)
        
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                toggled = not toggled
                TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.BackOut), {Position = toggled and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = toggled and SlayLib.Theme.Accent or SlayLib.Theme.TextDark}):Play()
                cb(toggled)
            end
        end)
    end

    function tab:CreateSlider(txt, min, max, def, cb)
        local s = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 65), BackgroundColor3 = SlayLib.Theme.Secondary, Parent = Page})
        Round(s) Stroke(s)
        local l = Create("TextLabel", {Text = "  " .. txt, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", Parent = s, TextXAlignment = "Left"})
        local vL = Create("TextLabel", {Text = tostring(def) .. " ", Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Accent, Font = "GothamBold", Parent = s, TextXAlignment = "Right"})
        
        local bar = Create("Frame", {Size = UDim2.new(0.94, 0, 0, 8), Position = UDim2.new(0.03, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(15,15,20), Parent = s})
        Round(bar, 4) Stroke(bar)
        local fill = Create("Frame", {Size = UDim2.fromScale((def-min)/(max-min), 1), BackgroundColor3 = SlayLib.Theme.Accent, Parent = bar})
        Round(fill, 4)
        
        local function update()
            local p = math.clamp((Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * p)
            fill.Size = UDim2.fromScale(p, 1)
            vL.Text = tostring(val) .. " "
            cb(val)
        end
        bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then local c c = RunService.RenderStepped:Connect(update) UserInputService.InputEnded:Connect(function(i2) if i2.UserInputType == Enum.UserInputType.MouseButton1 or i2.UserInputType == Enum.UserInputType.Touch then c:Disconnect() end end) end end)
    end

    function tab:CreateKeybind(txt, def, cb)
        local bind = def.Name
        local f = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Secondary, Parent = Page})
        Round(f) Stroke(f)
        Create("TextLabel", {Text = "  " .. txt, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", Parent = f, TextXAlignment = "Left"})
        
        local bBox = Create("TextButton", {Text = bind, Size = UDim2.fromOffset(80, 25), Position = UDim2.new(1, -90, 0.5, -12), BackgroundColor3 = SlayLib.Theme.Main, TextColor3 = SlayLib.Theme.Accent, Font = "GothamBold", Parent = f})
        Round(bBox) Stroke(bBox)
        
        bBox.MouseButton1Click:Connect(function()
            bBox.Text = "..."
            local i = UserInputService.InputBegan:Wait()
            if i.UserInputType == Enum.UserInputType.Keyboard then
                bBox.Text = i.KeyCode.Name
                bind = i.KeyCode
            end
        end)
        UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == bind then cb() end end)
    end

    if #self.TabHolder:GetChildren() == 2 then 
        Page.Visible = true 
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.TextColor3 = SlayLib.Theme.Text
    end

    return tab
end

-- // Notifications \\ --
function SlayLib:Notification(title, desc)
    local n = Create("Frame", {Size = UDim2.fromOffset(250, 70), Position = UDim2.new(1, 10, 0, 20), BackgroundColor3 = SlayLib.Theme.Main, Parent = self.Gui})
    Round(n) Stroke(n, SlayLib.Theme.Accent)
    Create("TextLabel", {Text = " " .. title, Size = UDim2.new(1, 0, 0, 30), TextColor3 = SlayLib.Theme.Accent, Font = "GothamBold", TextSize = 14, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = n})
    Create("TextLabel", {Text = " " .. desc, Size = UDim2.new(1, 0, 1, -30), Position = UDim2.fromOffset(0, 30), TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 12, TextXAlignment = "Left", TextWrapped = true, BackgroundTransparency = 1, Parent = n})
    
    n:TweenPosition(UDim2.new(1, -260, 0, 20), "Out", "Back", 0.5)
    task.delay(4, function()
        n:TweenPosition(UDim2.new(1, 10, 0, 20), "In", "Quad", 0.5)
        task.wait(0.5) n:Destroy()
    end)
end

return SlayLib
