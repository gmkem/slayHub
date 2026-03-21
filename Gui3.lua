local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SlayLib = {
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

local function Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

local function AddDecor(obj, radius, hasStroke)
    Create("UICorner", {CornerRadius = UDim.new(0, radius or 6), Parent = obj})
    if hasStroke then
        Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Parent = obj})
    end
end

-- // Fixed Draggable Logic for Mobile \\ --
local function MakeDraggable(obj, target)
    target = target or obj
    local dragging, dragInput, dragStart, startPos
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    target.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function SlayLib.new(hubTitle)
    local self = setmetatable({}, {__index = SlayLib})
    self.Gui = Create("ScreenGui", {Name = "SlayLib_Fixed", Parent = CoreGui, IgnoreGuiInset = true})
    
    -- Compact Ninja Button
    local Toggle = Create("ImageButton", {
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0, 10, 0.4, 0),
        BackgroundColor3 = SlayLib.Theme.Background,
        Image = "rbxassetid://13160451101",
        Parent = self.Gui
    })
    AddDecor(Toggle, 20, true)
    MakeDraggable(Toggle)
    
    -- Compact Window (500x320)
    local Main = Create("Frame", {
        Size = UDim2.fromOffset(500, 320),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = SlayLib.Theme.Background,
        Parent = self.Gui,
        Visible = true
    })
    AddDecor(Main, 8, true)
    MakeDraggable(Main)
    self.Main = Main

    Toggle.Activated:Connect(function()
        Main.Visible = not Main.Visible
    end)

    local Sidebar = Create("Frame", {Size = UDim2.new(0, 140, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = Main})
    AddDecor(Sidebar, 8)

    Create("TextLabel", {
        Text = hubTitle,
        Size = UDim2.new(1, 0, 0, 40),
        TextColor3 = SlayLib.Theme.Accent,
        Font = "GothamBold",
        TextSize = 14,
        BackgroundTransparency = 1,
        Parent = Sidebar
    })

    self.TabHolder = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.fromOffset(0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 4), HorizontalAlignment = "Center", Parent = self.TabHolder})

    self.PageHolder = Create("Frame", {
        Size = UDim2.new(1, -150, 1, -20),
        Position = UDim2.fromOffset(145, 10),
        BackgroundTransparency = 1,
        Parent = Main
    })

    return self
end

function SlayLib:CreateTab(name)
    local tab = {}
    local TabBtn = Create("TextButton", {
        Size = UDim2.new(0.9, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = SlayLib.Theme.TextDark,
        Font = "GothamSemibold",
        TextSize = 12,
        Parent = self.TabHolder
    })
    AddDecor(TabBtn, 4)

    local Page = Create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 0,
        Parent = self.PageHolder
    })
    local Layout = Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center", Parent = Page})
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.Activated:Connect(function()
        for _, v in pairs(self.PageHolder:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.TabHolder:GetChildren()) do
            if v:IsA("TextButton") then v.BackgroundTransparency = 1 v.TextColor3 = SlayLib.Theme.TextDark end
        end
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.BackgroundColor3 = SlayLib.Theme.Accent
        TabBtn.TextColor3 = SlayLib.Theme.Text
    end)

    if #self.TabHolder:GetChildren() == 2 then 
        Page.Visible = true TabBtn.BackgroundTransparency = 0.8 TabBtn.TextColor3 = SlayLib.Theme.Text 
    end

    -- // FIXED TOGGLE \\ --
    function tab:CreateToggle(txt, def, cb)
        local state = def
        local t = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 38), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
        AddDecor(t, 6, true)
        
        local label = Create("TextLabel", {
            Text = "  " .. txt, 
            Size = UDim2.fromScale(1, 1), 
            TextColor3 = SlayLib.Theme.Text, 
            Font = "Gotham", 
            TextSize = 12, 
            TextXAlignment = "Left", 
            BackgroundTransparency = 1, 
            Parent = t
        })
        
        local bg = Create("Frame", {
            Size = UDim2.fromOffset(34, 18), 
            Position = UDim2.new(1, -44, 0.5, -9), 
            BackgroundColor3 = Color3.fromRGB(15, 15, 20), 
            Parent = t
        })
        AddDecor(bg, 9, true)
        
        local dot = Create("Frame", {
            Size = UDim2.fromOffset(14, 14), 
            Position = state and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2), 
            BackgroundColor3 = state and SlayLib.Theme.Accent or SlayLib.Theme.TextDark, 
            Parent = bg
        })
        AddDecor(dot, 7)

        -- Fixed Activation
        local btn = Create("TextButton", {
            Size = UDim2.fromScale(1, 1), 
            BackgroundTransparency = 1, 
            Text = "", 
            Parent = t
        })

        btn.Activated:Connect(function()
            state = not state
            TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.QuartOut), {
                Position = state and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2),
                BackgroundColor3 = state and SlayLib.Theme.Accent or SlayLib.Theme.TextDark
            }):Play()
            cb(state)
        end)
    end

    function tab:CreateButton(txt, cb)
        local b = Create("TextButton", {Size = UDim2.new(0.98, 0, 0, 38), BackgroundColor3 = SlayLib.Theme.Element, Text = txt, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 12, Parent = Page})
        AddDecor(b, 6, true)
        b.Activated:Connect(cb)
    end

    return tab
end

return SlayLib
