--[[
    SLAYLIB GRAND MASTER V5 - [PART 1: CORE ENGINE]
    Line Count Target: 2000+
    Features: Responsive Engine, Theme System, Drag Logic, Animation Suite
]]

local SlayLib = {
    Flags = {},
    Options = {},
    Threads = {},
    Theme = {
        Main = Color3.fromRGB(15, 15, 20),
        Sidebar = Color3.fromRGB(20, 20, 26),
        Accent = Color3.fromRGB(0, 160, 255),
        Element = Color3.fromRGB(26, 26, 32),
        Stroke = Color3.fromRGB(45, 45, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 170),
        Title = "SlayLib Masterpiece"
    },
    Components = {}
}

-- [Services]
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [Internal Functions: UI Creation]
local function Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

local function ApplyDecor(obj, radius, strokeColor)
    local corner = Create("UICorner", {CornerRadius = UDim.new(0, radius or 6), Parent = obj})
    local stroke = nil
    if strokeColor then
        stroke = Create("UIStroke", {
            Color = strokeColor,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = obj
        })
    end
    return corner, stroke
end

-- [Internal Functions: Animation]
local function Tween(obj, info, goal)
    local t = TS:Create(obj, info, goal)
    t:Play()
    return t
end

-- [Advanced Draggable Logic: Mobile & PC Optimized]
local function MakeDraggable(obj, handler)
    handler = handler or obj
    local dragStart, startPos, dragging
    
    handler.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Tween(obj, TweenInfo.new(0.15, Enum.EasingStyle.QuartOut), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

-- [Core System: Configuration Management]
function SlayLib:SetTheme(themeName, color)
    if self.Theme[themeName] then
        self.Theme[themeName] = color
        -- Logic สำหรับ Update สี UI ทั้งหมดที่รันอยู่ (จะเพิ่มใน Part ถัดไป)
    end
end

-- [The Window Constructor]
function SlayLib.new(options)
    local self = setmetatable({}, {__index = SlayLib})
    options = options or {}
    self.Title = options.Name or "SLAYER MASTER V5"
    
    -- Main ScreenGui
    self.Gui = Create("ScreenGui", {
        Name = "SlayLib_V5",
        Parent = CoreGui,
        IgnoreGuiInset = true,
        DisplayOrder = 100
    })
    
    -- Floating Toggle (The Ninja Icon)
    self.ToggleBtn = Create("ImageButton", {
        Size = UDim2.fromOffset(42, 42),
        Position = UDim2.new(0, 15, 0.45, 0),
        BackgroundColor3 = self.Theme.Main,
        Image = "rbxassetid://13160451101", -- Default Icon
        Parent = self.Gui
    })
    ApplyDecor(self.ToggleBtn, 21, self.Theme.Accent)
    MakeDraggable(self.ToggleBtn)

    -- Main Window (Compact Professional Size: 500x320)
    self.Main = Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.fromOffset(500, 320),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Main,
        ClipsDescendants = true,
        Parent = self.Gui
    })
    ApplyDecor(self.Main, 10, self.Theme.Stroke)
    MakeDraggable(self.Main)

    -- Ninja Button Logic
    self.ToggleBtn.Activated:Connect(function()
        self.Main.Visible = not self.Main.Visible
        if self.Main.Visible then
            self.Main:TweenScale(Vector2.new(1, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.3, true)
        end
    end)

    -- Sidebar Container
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 145, 1, 0),
        BackgroundColor3 = self.Theme.Sidebar,
        Parent = self.Main
    })
    ApplyDecor(self.Sidebar, 10)

    -- Window Title
    self.TitleLabel = Create("TextLabel", {
        Text = self.Title,
        Size = UDim2.new(1, 0, 0, 50),
        TextColor3 = self.Theme.Accent,
        Font = "GothamBold",
        TextSize = 14,
        BackgroundTransparency = 1,
        Parent = self.Sidebar
    })

    -- Tab Container (Scrollable)
    self.TabHolder = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -110),
        Position = UDim2.fromOffset(0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = self.Sidebar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 4), HorizontalAlignment = "Center", Parent = self.TabHolder})

    -- Page Container
    self.PageHolder = Create("Frame", {
        Size = UDim2.new(1, -155, 1, -20),
        Position = UDim2.fromOffset(150, 10),
        BackgroundTransparency = 1,
        Parent = self.Main
    })

    -- [User Profile Mini]
    local User = Create("Frame", {
        Size = UDim2.new(0.9, 0, 0, 45),
        Position = UDim2.new(0.05, 0, 1, -55),
        BackgroundColor3 = self.Theme.Element,
        Parent = self.Sidebar
    })
    ApplyDecor(User, 8, self.Theme.Stroke)
    
    local Avatar = Create("ImageLabel", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromOffset(6, 6),
        Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, "HeadShot", "Size420x420"),
        BackgroundTransparency = 1,
        Parent = User
    })
    ApplyDecor(Avatar, 16)
    
    Create("TextLabel", {
        Text = LocalPlayer.DisplayName,
        Position = UDim2.fromOffset(42, 0),
        Size = UDim2.new(1, -45, 1, 0),
        TextColor3 = self.Theme.Text,
        Font = "GothamSemibold",
        TextSize = 11,
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        Parent = User
    })

    return self
end

-- [[ SLAYLIB GRAND MASTER V5 - PART 2: TAB & COMPONENTS ]]

-- [Tab Management System]
function SlayLib:CreateTab(name, icon)
    local tab = {
        Elements = {},
        Active = false
    }
    
    -- Tab Button in Sidebar
    local TabBtn = Create("TextButton", {
        Name = name .. "_Tab",
        Size = UDim2.new(0.9, 0, 0, 38),
        BackgroundTransparency = 1,
        Text = "    " .. name,
        TextColor3 = self.Theme.TextDark,
        Font = "GothamSemibold",
        TextSize = 12,
        TextXAlignment = "Left",
        Parent = self.TabHolder
    })
    local _, TabStroke = ApplyDecor(TabBtn, 6, self.Theme.Accent)
    TabStroke.Enabled = false
    
    -- Icon for Tab (If provided)
    if icon then
        local TabIcon = Create("ImageLabel", {
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(0, 8, 0.5, -9),
            Image = icon,
            BackgroundTransparency = 1,
            ImageColor3 = self.Theme.TextDark,
            Parent = TabBtn
        })
    end

    -- The Page for this Tab
    local Page = Create("ScrollingFrame", {
        Name = name .. "_Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 1.5,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.PageHolder
    })
    
    local PageLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = "Center",
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Page
    })

    -- Auto-Canvas Scaling
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0, PageLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Tab Switching Logic
    TabBtn.Activated:Connect(function()
        for _, p in pairs(self.PageHolder:GetChildren()) do p.Visible = false end
        for _, b in pairs(self.TabHolder:GetChildren()) do
            if b:IsA("TextButton") then
                Tween(b, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = self.Theme.TextDark})
                if b:FindFirstChild("UIStroke") then b.UIStroke.Enabled = false end
            end
        end
        
        Page.Visible = true
        Tween(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.85, TextColor3 = self.Theme.Text})
        TabStroke.Enabled = true
    end)

    -- Default Selection (First Tab)
    if #self.TabHolder:GetChildren() == 2 then -- UIListLayout counts as 1
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.85
        TabBtn.TextColor3 = self.Theme.Text
        TabStroke.Enabled = true
    end

    -- // COMPONENT: SECTION \\ --
    function tab:CreateSection(text)
        local SectionFrame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 25),
            BackgroundTransparency = 1,
            Parent = Page
        })
        
        local Title = Create("TextLabel", {
            Text = text:upper(),
            Size = UDim2.fromScale(1, 1),
            TextColor3 = SlayLib.Theme.Accent,
            Font = "GothamBold",
            TextSize = 10,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = SectionFrame
        })
        
        local Line = Create("Frame", {
            Size = UDim2.new(1, - (Title.TextBounds.X + 10), 0, 1),
            Position = UDim2.new(0, Title.TextBounds.X + 8, 0.5, 0),
            BackgroundColor3 = SlayLib.Theme.Stroke,
            BackgroundTransparency = 0.5,
            Parent = SectionFrame
        })
    end

    -- // COMPONENT: BUTTON \\ --
    function tab:CreateButton(config, callback)
        local btn_text = config.Name or "Button"
        local b = Create("TextButton", {
            Size = UDim2.new(0.96, 0, 0, 38),
            BackgroundColor3 = SlayLib.Theme.Element,
            Text = "  " .. btn_text,
            TextColor3 = SlayLib.Theme.Text,
            Font = "Gotham",
            TextSize = 13,
            TextXAlignment = "Left",
            AutoButtonColor = false,
            Parent = Page
        })
        ApplyDecor(b, 6, SlayLib.Theme.Stroke)
        
        local Icon = Create("ImageLabel", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(1, -26, 0.5, -8),
            Image = "rbxassetid://13160451101", -- Click Icon
            ImageColor3 = SlayLib.Theme.TextDark,
            BackgroundTransparency = 1,
            Parent = b
        })

        b.MouseEnter:Connect(function() Tween(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 42)}) end)
        b.MouseLeave:Connect(function() Tween(b, TweenInfo.new(0.2), {BackgroundColor3 = SlayLib.Theme.Element}) end)
        
        b.Activated:Connect(function()
            -- Ripple Effect Logic
            local circle = Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 0.8,
                Position = UDim2.fromOffset(Mouse.X - b.AbsolutePosition.X, Mouse.Y - b.AbsolutePosition.Y),
                Parent = b
            })
            ApplyDecor(circle, 100)
            Tween(circle, TweenInfo.new(0.5), {Size = UDim2.fromOffset(400, 400), Position = UDim2.fromOffset(-200, -200), BackgroundTransparency = 1})
            task.delay(0.5, function() circle:Destroy() end)
            
            callback()
        end)
    end

    -- // COMPONENT: TOGGLE \\ --
    function tab:CreateToggle(config, callback)
        local t_name = config.Name or "Toggle"
        local state = config.CurrentValue or false
        
        local t_frame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 40),
            BackgroundColor3 = SlayLib.Theme.Element,
            Parent = Page
        })
        ApplyDecor(t_frame, 6, SlayLib.Theme.Stroke)
        
        local label = Create("TextLabel", {
            Text = "  " .. t_name,
            Size = UDim2.fromScale(1, 1),
            TextColor3 = SlayLib.Theme.Text,
            Font = "Gotham",
            TextSize = 13,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = t_frame
        })
        
        local toggle_bg = Create("Frame", {
            Size = UDim2.fromOffset(36, 18),
            Position = UDim2.new(1, -46, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            Parent = t_frame
        })
        ApplyDecor(toggle_bg, 10, SlayLib.Theme.Stroke)
        
        local dot = Create("Frame", {
            Size = UDim2.fromOffset(14, 14),
            Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
            BackgroundColor3 = state and SlayLib.Theme.Accent or SlayLib.Theme.TextDark,
            Parent = toggle_bg
        })
        ApplyDecor(dot, 10)

        local hidden_btn = Create("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            Parent = t_frame
        })

        hidden_btn.Activated:Connect(function()
            state = not state
            Tween(dot, TweenInfo.new(0.25, Enum.EasingStyle.QuartOut), {
                Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
                BackgroundColor3 = state and SlayLib.Theme.Accent or SlayLib.Theme.TextDark
            })
            callback(state)
        end)
    end

    return tab
end

-- [[ SLAYLIB GRAND MASTER V5 - PART 3: ADVANCED COMPONENTS ]]

    -- // COMPONENT: SLIDER \\ --
    function tab:CreateSlider(config, callback)
        local s_name = config.Name or "Slider"
        local min = config.Min or 0
        local max = config.Max or 100
        local default = config.CurrentValue or min
        local precise = config.Precise or false -- ทศนิยมหรือไม่
        
        local s_frame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 55),
            BackgroundColor3 = SlayLib.Theme.Element,
            Parent = Page
        })
        ApplyDecor(s_frame, 6, SlayLib.Theme.Stroke)
        
        local label = Create("TextLabel", {
            Text = "  " .. s_name,
            Size = UDim2.new(1, 0, 0, 30),
            TextColor3 = SlayLib.Theme.Text,
            Font = "Gotham",
            TextSize = 13,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = s_frame
        })
        
        local val_label = Create("TextLabel", {
            Text = tostring(default) .. " ",
            Size = UDim2.new(1, 0, 0, 30),
            TextColor3 = SlayLib.Theme.Accent,
            Font = "GothamBold",
            TextSize = 13,
            TextXAlignment = "Right",
            BackgroundTransparency = 1,
            Parent = s_frame
        })
        
        local tray = Create("Frame", {
            Size = UDim2.new(0.94, 0, 0, 6),
            Position = UDim2.new(0.03, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            Parent = s_frame
        })
        ApplyDecor(tray, 3, SlayLib.Theme.Stroke)
        
        local fill = Create("Frame", {
            Size = UDim2.fromScale(math.clamp((default - min) / (max - min), 0, 1), 1),
            BackgroundColor3 = SlayLib.Theme.Accent,
            Parent = tray
        })
        ApplyDecor(fill, 3)

        -- Slider Logic
        local function UpdateSlider()
            local percent = math.clamp((Mouse.X - tray.AbsolutePosition.X) / tray.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            
            if not precise then
                value = math.floor(value)
            else
                value = math.floor(value * 10) / 10
            end
            
            fill.Size = UDim2.fromScale(percent, 1)
            val_label.Text = tostring(value) .. " "
            callback(value)
        end

        tray.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local connection
                connection = RunService.RenderStepped:Connect(UpdateSlider)
                
                local release_conn
                release_conn = UIS.InputEnded:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                        connection:Disconnect()
                        release_conn:Disconnect()
                    end
                end)
            end
        end)
    end

    -- // COMPONENT: DROPDOWN (Enhanced) \\ --
    function tab:CreateDropdown(config, callback)
        local d_name = config.Name or "Dropdown"
        local options = config.Options or {}
        local current = config.CurrentOption or "Select..."
        local expanded = false
        
        local d_frame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 40),
            BackgroundColor3 = SlayLib.Theme.Element,
            ClipsDescendants = true,
            Parent = Page
        })
        ApplyDecor(d_frame, 6, SlayLib.Theme.Stroke)
        
        local main_btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            Text = "  " .. d_name .. " : " .. tostring(current),
            TextColor3 = SlayLib.Theme.Text,
            Font = "Gotham",
            TextSize = 13,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = d_frame
        })
        
        local arrow = Create("ImageLabel", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(1, -26, 0.5, -8),
            Image = "rbxassetid://13160451101", -- Arrow Icon
            ImageColor3 = SlayLib.Theme.TextDark,
            BackgroundTransparency = 1,
            Rotation = 0,
            Parent = d_frame
        })

        local option_holder = Create("Frame", {
            Size = UDim2.new(1, 0, 0, #options * 32),
            Position = UDim2.fromOffset(0, 40),
            BackgroundTransparency = 1,
            Parent = d_frame
        })
        Create("UIListLayout", {Parent = option_holder})

        main_btn.Activated:Connect(function()
            expanded = not expanded
            Tween(d_frame, TweenInfo.new(0.4, Enum.EasingStyle.QuartOut), {
                Size = expanded and UDim2.new(0.96, 0, 0, 40 + (#options * 32)) or UDim2.new(0.96, 0, 0, 40)
            })
            Tween(arrow, TweenInfo.new(0.3), {Rotation = expanded and 180 or 0})
        end)

        for _, opt_name in pairs(options) do
            local opt_btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 32),
                Text = "      " .. tostring(opt_name),
                TextColor3 = SlayLib.Theme.TextDark,
                Font = "Gotham",
                TextSize = 12,
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                Parent = option_holder
            })
            
            opt_btn.MouseEnter:Connect(function() Tween(opt_btn, TweenInfo.new(0.2), {TextColor3 = SlayLib.Theme.Accent}) end)
            opt_btn.MouseLeave:Connect(function() Tween(opt_btn, TweenInfo.new(0.2), {TextColor3 = SlayLib.Theme.TextDark}) end)
            
            opt_btn.Activated:Connect(function()
                main_btn.Text = "  " .. d_name .. " : " .. tostring(opt_name)
                expanded = false
                Tween(d_frame, TweenInfo.new(0.4, Enum.EasingStyle.QuartOut), {Size = UDim2.new(0.96, 0, 0, 40)})
                Tween(arrow, TweenInfo.new(0.3), {Rotation = 0})
                callback(opt_name)
            end)
        end
    end

    -- // COMPONENT: INPUT (Box) \\ --
    function tab:CreateInput(config, callback)
        local i_name = config.Name or "Input"
        local placeholder = config.Placeholder or "Type here..."
        
        local i_frame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 40),
            BackgroundColor3 = SlayLib.Theme.Element,
            Parent = Page
        })
        ApplyDecor(i_frame, 6, SlayLib.Theme.Stroke)
        
        Create("TextLabel", {
            Text = "  " .. i_name,
            Size = UDim2.new(0.4, 0, 1, 0),
            TextColor3 = SlayLib.Theme.Text,
            Font = "Gotham",
            TextSize = 13,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = i_frame
        })
        
        local box = Create("TextBox", {
            Size = UDim2.new(0.5, 0, 0, 24),
            Position = UDim2.new(1, -10, 0.5, -12),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            Text = "",
            PlaceholderText = placeholder,
            TextColor3 = SlayLib.Theme.Text,
            PlaceholderColor3 = SlayLib.Theme.TextDark,
            Font = "Gotham",
            TextSize = 12,
            Parent = i_frame
        })
        ApplyDecor(box, 4, SlayLib.Theme.Stroke)

        box.FocusLost:Connect(function(enter)
            if enter then
                callback(box.Text)
                if config.ClearTextAfterFocusLost then
                    box.Text = ""
                end
            end
        end)
    end

-- [[ SLAYLIB GRAND MASTER V5 - PART 4: HIGH-END COMPONENTS ]]

    -- // COMPONENT: KEYBIND (Advanced) \\ --
    function tab:CreateKeybind(config, callback)
        local k_name = config.Name or "Keybind"
        local current_bind = config.CurrentBind or Enum.KeyCode.E
        local binding = false
        
        local k_frame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 40),
            BackgroundColor3 = SlayLib.Theme.Element,
            Parent = Page
        })
        ApplyDecor(k_frame, 6, SlayLib.Theme.Stroke)
        
        Create("TextLabel", {
            Text = "  " .. k_name,
            Size = UDim2.fromScale(1, 1),
            TextColor3 = SlayLib.Theme.Text,
            Font = "Gotham",
            TextSize = 13,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = k_frame
        })
        
        local bind_label = Create("TextButton", {
            Size = UDim2.fromOffset(80, 24),
            Position = UDim2.new(1, -10, 0.5, -12),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            Text = current_bind.Name,
            TextColor3 = SlayLib.Theme.Accent,
            Font = "GothamBold",
            TextSize = 11,
            Parent = k_frame
        })
        ApplyDecor(bind_label, 4, SlayLib.Theme.Stroke)

        bind_label.Activated:Connect(function()
            binding = true
            bind_label.Text = "..."
            local input_wait
            input_wait = UIS.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    current_bind = input.KeyCode
                    bind_label.Text = input.KeyCode.Name
                    binding = false
                    input_wait:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    -- เผื่ออยากดักจับคลิกเมาส์
                    binding = false
                    input_wait:Disconnect()
                    bind_label.Text = current_bind.Name
                end
            end)
        end)

        UIS.InputBegan:Connect(function(input, processed)
            if not processed and not binding and input.KeyCode == current_bind then
                callback(current_bind)
            end
        end)
    end

    -- // COMPONENT: COLOR PICKER (Advanced RGB) \\ --
    function tab:CreateColorPicker(config, callback)
        local cp_name = config.Name or "Color Picker"
        local current_color = config.Default or Color3.fromRGB(255, 255, 255)
        local expanded = false
        
        local cp_frame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 40),
            BackgroundColor3 = SlayLib.Theme.Element,
            ClipsDescendants = true,
            Parent = Page
        })
        ApplyDecor(cp_frame, 6, SlayLib.Theme.Stroke)
        
        local main_btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            Text = "  " .. cp_name,
            TextColor3 = SlayLib.Theme.Text,
            Font = "Gotham",
            TextSize = 13,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = cp_frame
        })

        local preview = Create("Frame", {
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.new(1, -10, 0.5, -12),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = current_color,
            Parent = cp_frame
        })
        ApplyDecor(preview, 4, SlayLib.Theme.Stroke)

        -- [Color Selection UI]
        local picker_container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 100),
            Position = UDim2.fromOffset(0, 40),
            BackgroundTransparency = 1,
            Parent = cp_frame
        })

        -- ง่ายต่อการใช้งานบนมือถือ: ใช้ Slider 3 ตัวสำหรับ R, G, B
        local function create_rgb_slider(color_name, pos_y, def_val)
            local slider = Create("Frame", {
                Size = UDim2.new(0.9, 0, 0, 25),
                Position = UDim2.new(0.05, 0, 0, pos_y),
                BackgroundTransparency = 1,
                Parent = picker_container
            })
            
            local fill_bg = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 4),
                Position = UDim2.new(0, 0, 0.5, -2),
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                Parent = slider
            })
            
            local fill = Create("Frame", {
                Size = UDim2.fromScale(def_val/255, 1),
                BackgroundColor3 = color_name == "R" and Color3.new(1,0,0) or (color_name == "G" and Color3.new(0,1,0) or Color3.new(0,0,1)),
                Parent = fill_bg
            })

            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local move_conn
                    move_conn = RunService.RenderStepped:Connect(function()
                        local p = math.clamp((Mouse.X - fill_bg.AbsolutePosition.X) / fill_bg.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.fromScale(p, 1)
                        
                        local r = color_name == "R" and p*255 or current_color.R*255
                        local g = color_name == "G" and p*255 or current_color.G*255
                        local b = color_name == "B" and p*255 or current_color.B*255
                        
                        current_color = Color3.fromRGB(r, g, b)
                        preview.BackgroundColor3 = current_color
                        callback(current_color)
                    end)
                    local release_conn
                    release_conn = UIS.InputEnded:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                            move_conn:Disconnect()
                            release_conn:Disconnect()
                        end
                    end)
                end
            end)
        end

        create_rgb_slider("R", 10, current_color.R*255)
        create_rgb_slider("G", 40, current_color.G*255)
        create_rgb_slider("B", 70, current_color.B*255)

        main_btn.Activated:Connect(function()
            expanded = not expanded
            Tween(cp_frame, TweenInfo.new(0.4), {
                Size = expanded and UDim2.new(0.96, 0, 0, 150) or UDim2.new(0.96, 0, 0, 40)
            })
        end)
    end

    -- // COMPONENT: PARAGRAPH (Text Display) \\ --
    function tab:CreateParagraph(config)
        local title = config.Title or "Info"
        local content = config.Content or ""
        
        local p_frame = Create("Frame", {
            Size = UDim2.new(0.96, 0, 0, 60), -- Dynamic size logic would be here
            BackgroundColor3 = SlayLib.Theme.Element,
            Parent = Page
        })
        ApplyDecor(p_frame, 6, SlayLib.Theme.Stroke)
        
        local t_label = Create("TextLabel", {
            Text = "  " .. title,
            Size = UDim2.new(1, 0, 0, 25),
            TextColor3 = SlayLib.Theme.Accent,
            Font = "GothamBold",
            TextSize = 12,
            TextXAlignment = "Left",
            BackgroundTransparency = 1,
            Parent = p_frame
        })
        
        local c_label = Create("TextLabel", {
            Text = "  " .. content,
            Size = UDim2.new(1, -10, 1, -25),
            Position = UDim2.fromOffset(0, 25),
            TextColor3 = SlayLib.Theme.TextDark,
            Font = "Gotham",
            TextSize = 11,
            TextXAlignment = "Left",
            TextYAlignment = "Top",
            TextWrapped = true,
            BackgroundTransparency = 1,
            Parent = p_frame
        })
    end

    return tab
end

-- // SYSTEM: NOTIFICATION (Global) \\ --
local NotifGui = Create("ScreenGui", {Name = "SlayNotif", Parent = CoreGui})
local NotifContainer = Create("Frame", {
    Size = UDim2.new(0, 280, 1, -20),
    Position = UDim2.fromOffset(15, 15),
    BackgroundTransparency = 1,
    Parent = NotifGui
})
Create("UIListLayout", {VerticalAlignment = "Bottom", Padding = UDim.new(0, 8), Parent = NotifContainer})

function SlayLib:Notify(config)
    local title = config.Title or "Notification"
    local desc = config.Content or "Message content here"
    local duration = config.Duration or 5
    
    local n_frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundColor3 = self.Theme.Main,
        Parent = NotifContainer
    })
    ApplyDecor(n_frame, 8, self.Theme.Accent)
    
    local bar = Create("Frame", {
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundColor3 = self.Theme.Accent,
        Parent = n_frame
    })
    ApplyDecor(bar, 2)

    Create("TextLabel", {Text = title, Position = UDim2.fromOffset(20, 10), Size = UDim2.new(1, -30, 0, 20), TextColor3 = self.Theme.Accent, Font = "GothamBold", TextSize = 13, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = n_frame})
    Create("TextLabel", {Text = desc, Position = UDim2.fromOffset(20, 30), Size = UDim2.new(1, -30, 0, 25), TextColor3 = self.Theme.Text, Font = "Gotham", TextSize = 11, TextXAlignment = "Left", TextWrapped = true, BackgroundTransparency = 1, Parent = n_frame})

    -- Animation
    n_frame.Position = UDim2.fromScale(-1.2, 0)
    Tween(n_frame, TweenInfo.new(0.5, Enum.EasingStyle.BackOut), {Position = UDim2.fromScale(0, 0)})
    
    task.delay(duration, function()
        Tween(n_frame, TweenInfo.new(0.5, Enum.EasingStyle.QuadIn), {Position = UDim2.fromScale(-1.2, 0)})
        task.wait(0.5)
        n_frame:Destroy()
    end)
end

-- [[ SLAYLIB GRAND MASTER V5 - FINAL TERMINATION & CONFIG LOGIC ]]

-- // SYSTEM: CONFIGURATION MANAGEMENT \\ --
-- ส่วนนี้ทำหน้าที่บันทึกค่า Flags ทั้งหมดลงในเครื่องของผู้ใช้
local FolderName = "SlayLib_Configs"

function SlayLib:SaveConfig(fileName)
    if not isfolder(FolderName) then makefolder(FolderName) end
    
    local data = {}
    for flag, value in pairs(self.Flags) do
        -- แปลงข้อมูลประเภทพิเศษให้กลายเป็นข้อมูลที่ JSON เข้าใจ
        if typeof(value) == "Color3" then
            data[flag] = {R = value.R, G = value.G, B = value.B, Type = "Color3"}
        elseif typeof(value) == "EnumItem" then
            data[flag] = {Value = tostring(value), Type = "Enum"}
        else
            data[flag] = value
        end
    end
    
    local success, err = pcall(function()
        writefile(FolderName .. "/" .. fileName .. ".json", HttpService:JSONEncode(data))
    end)
    
    if success then
        self:Notify({Title = "System", Content = "Configuration '"..fileName.."' saved successfully.", Duration = 3})
    else
        warn("SlayLib Save Error: " .. err)
    end
end

function SlayLib:LoadConfig(fileName)
    local path = FolderName .. "/" .. fileName .. ".json"
    if isfile(path) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        
        if success then
            for flag, val in pairs(data) do
                -- ในขั้นตอนนี้ Library จะเก็บค่าไว้ใน Flags 
                -- คุณสามารถเขียน Logic เพิ่มเติมเพื่อ Update UI Elements ตามค่าที่โหลดมาได้ที่นี่
                self.Flags[flag] = val
            end
            self:Notify({Title = "System", Content = "Configuration '"..fileName.."' loaded.", Duration = 3})
        end
    end
end

-- // SYSTEM: CLEANUP & DESTROY \\ --
-- ฟังก์ชันสำหรับลบ UI ทั้งหมดออกจากหน่วยความจำอย่างปลอดภัย
function SlayLib:Destroy()
    if self.Gui then
        -- เล่นแอนิเมชั่นปิดก่อนลบ
        local closeTween = TS:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.QuartIn), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        })
        
        closeTween.Completed:Connect(function()
            self.Gui:Destroy()
            
            -- ยกเลิกการเชื่อมต่อ Events ทั้งหมดที่เก็บไว้ใน Threads/Connections
            for i, v in pairs(self.Connections) do
                if typeof(v) == "RBXScriptConnection" then
                    v:Disconnect()
                end
            end
            
            -- เคลียร์ตารางข้อมูล
            table.clear(self.Flags)
            table.clear(self.Connections)
        end)
        
        closeTween:Play()
    end
end

-- // FINAL EXPORT \\ --
-- ส่วนที่สำคัญที่สุด: คืนค่าตาราง SlayLib กลับไปเพื่อให้สคริปต์อื่นเรียกใช้ได้
return SlayLib
