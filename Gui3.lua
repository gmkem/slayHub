--[[ 
    SLAYLIB: GRAND MASTER EDITION V3.1 (STABLE)
    - Fix: Toggle Logic & Error Handling
    - Move: Notifications to Bottom-Right
    - Optimized for Mobile & High-End Projects
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SlayLib = {
    Theme = {
        Main = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(0, 160, 255),
        Outline = Color3.fromRGB(45, 45, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 165),
    }
}
SlayLib.__index = SlayLib

-- // Utility Functions \\ --
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function Round(obj, radius)
    Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = obj})
end

local function Stroke(obj, color, thickness)
    Create("UIStroke", {
        Color = color or SlayLib.Theme.Outline,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = obj
    })
end

-- // Notification System (Moved to Bottom Right) \\ --
local NotifGui = Create("ScreenGui", {Name = "SlayNotif", Parent = LocalPlayer:WaitForChild("PlayerGui")})
local NotifContainer = Create("Frame", {
    Size = UDim2.new(0, 260, 1, -20),
    Position = UDim2.new(1, -270, 0, 10),
    BackgroundTransparency = 1,
    Parent = NotifGui
})
Create("UIListLayout", {
    VerticalAlignment = Enum.VerticalAlignment.Bottom, -- ย้ายไปล่างสุด
    Padding = UDim.new(0, 10),
    Parent = NotifContainer
})

function SlayLib:Notification(title, desc)
    local n = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), -- เริ่มจาก 0 เพื่อขยายขึ้น
        BackgroundColor3 = SlayLib.Theme.Main,
        ClipsDescendants = true,
        Parent = NotifContainer
    })
    Round(n, 8)
    Stroke(n, SlayLib.Theme.Accent)

    local t = Create("TextLabel", {Text = "  " .. title, Size = UDim2.new(1, 0, 0, 25), TextColor3 = SlayLib.Theme.Accent, Font = "GothamBold", TextSize = 13, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = n})
    local d = Create("TextLabel", {Text = "  " .. desc, Size = UDim2.new(1, 0, 0, 35), Position = UDim2.fromOffset(0, 25), TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 11, TextXAlignment = "Left", TextWrapped = true, BackgroundTransparency = 1, Parent = n})

    -- สไลด์ขึ้นมาจากข้างล่าง
    n:TweenSize(UDim2.new(1, 0, 0, 65), "Out", "Quart", 0.4, true)
    
    task.delay(4, function()
        n:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quart", 0.4, true)
        task.wait(0.4)
        n:Destroy()
    end)
end

-- // Library UI Creation \\ --
function SlayLib.new(config)
    local self = setmetatable({}, SlayLib)
    config = config or {Name = "SLAYLIB V3.1"}
    
    self.Gui = Create("ScreenGui", {Name = "SlayLib_UI", Parent = LocalPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false})
    
    self.Main = Create("Frame", {
        Size = UDim2.fromOffset(580, 380),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = SlayLib.Theme.Main,
        Parent = self.Gui
    })
    Round(self.Main, 10)
    Stroke(self.Main)

    -- Sidebar & Tab Logic
    self.Sidebar = Create("Frame", {Size = UDim2.new(0, 160, 1, 0), BackgroundColor3 = SlayLib.Theme.Secondary, BackgroundTransparency = 0.5, Parent = self.Main})
    Round(self.Sidebar, 10)

    self.TabHolder = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -110), Position = UDim2.fromOffset(0, 50), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = self.Sidebar})
    Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = "Center", Parent = self.TabHolder})

    self.PageHolder = Create("Frame", {Size = UDim2.new(1, -170, 1, -20), Position = UDim2.fromOffset(165, 10), BackgroundTransparency = 1, Parent = self.Main})

    -- Draggable Function (Main Window)
    local drag, dragInput, dragStart, startPos
    self.Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true dragStart = i.Position startPos = self.Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag then local delta = i.Position - dragStart self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

    return self
end

function SlayLib:CreateTab(name)
    local tab = {}
    local TabBtn = Create("TextButton", {Size = UDim2.new(0.9, 0, 0, 35), BackgroundColor3 = SlayLib.Theme.Accent, BackgroundTransparency = 1, Text = name, TextColor3 = SlayLib.Theme.TextDark, Font = "GothamSemibold", TextSize = 13, Parent = self.TabHolder})
    Round(TabBtn, 6)

    local Page = Create("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, Parent = self.PageHolder})
    local Layout = Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center", Parent = Page})
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 10) end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.PageHolder:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.TabHolder:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextDark}):Play() end end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, TextColor3 = SlayLib.Theme.Text}):Play()
    end)

    if #self.TabHolder:GetChildren() == 2 then Page.Visible = true TabBtn.BackgroundTransparency = 0.8 TabBtn.TextColor3 = SlayLib.Theme.Text end

    -- // FIXED TOGGLE ELEMENT \\ --
    function tab:CreateToggle(txt, def, cb)
        local toggled = def or false
        local f = Create("Frame", {Size = UDim2.new(0.98, 0, 0, 42), BackgroundColor3 = SlayLib.Theme.Secondary, Parent = Page})
        Round(f) Stroke(f)

        local l = Create("TextLabel", {Text = "  " .. txt, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left", Parent = f})
        
        local box = Create("Frame", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(20,20,25), Parent = f})
        Round(box, 10) Stroke(box)
        
        local p = Create("Frame", {Size = UDim2.fromOffset(16, 16), Position = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = toggled and SlayLib.Theme.Accent or SlayLib.Theme.TextDark, Parent = box})
        Round(p, 8)

        -- แก้ปัญหาการคลิกแล้ว Error
        local function FireToggle()
            toggled = not toggled
            local targetPos = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
            local targetColor = toggled and SlayLib.Theme.Accent or SlayLib.Theme.TextDark
            
            TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.BackOut), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
            
            -- ป้องกัน Error หากไม่ได้ใส่ Callback
            if cb and type(cb) == "function" then
                local success, err = pcall(function() cb(toggled) end)
                if not success then warn("[SlayLib Error]: " .. err) end
            end
        end

        -- รองรับการกดทั้งที่ตัว Toggle และตัว Frame
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                FireToggle()
            end
        end)
    end

    function tab:CreateButton(txt, cb)
        local b = Create("TextButton", {Size = UDim2.new(0.98, 0, 0, 40), BackgroundColor3 = SlayLib.Theme.Secondary, Text = "  " .. txt, TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left", Parent = Page})
        Round(b) Stroke(b)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
    end

    return tab
end

return SlayLib
