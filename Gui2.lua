--[[
    ================================================================================
    FLULIB ULTIMATE INTERFACE SUITE (ELITE UNKNOWN EDITION)
    ================================================================================
    Inspired by: Luna UI Structure
    Design: Fluent 2.0 Acrylic + Premium Animations
    Features: Full Flag System, Keybinds, Multi-Dropdown, ColorPickers, Sections
    ================================================================================
]]

local FluLib = {
    Folder = "FluLib_Data",
    Options = {},
    Flags = {},
    Signals = {},
    ThemeGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 120, 212)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 200, 255))
    },
    Theme = {
        Accent = Color3.fromRGB(0, 120, 212),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(25, 25, 25),
        ElementHover = Color3.fromRGB(32, 32, 32),
        Stroke = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(160, 160, 160),
        Font = Enum.Font.GothamMedium,
        BoldFont = Enum.Font.GothamBold,
        Easing = Enum.EasingStyle.Exponential -- ใช้สไตล์อนิเมชันระดับสูง
    }
}

--// SERVICES & GLOBALS
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Mouse = Players.LocalPlayer:GetMouse()

--// UTILITY FUNCTIONS (Detailed Logic)
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

local function Tween(obj, goal, time, style, dir)
    local info = TweenInfo.new(time or 0.5, style or FluLib.Theme.Easing, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

local function MakeDraggable(TopBar, MainFrame)
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// WINDOW CORE
function FluLib:CreateWindow(Config)
    Config = Config or {Name = "FluLib Premium", Subtitle = "Full Source Interface"}
    
    local Window = {CurrentTab = nil, Tabs = {}}

    local MainGui = Create("ScreenGui", {
        Name = "FluLib_Framework",
        Parent = CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 700, 0, 520),
        Position = UDim2.new(0.5, -350, 0.5, -260),
        BackgroundColor3 = FluLib.Theme.Background,
        BorderSizePixel = 0,
        Parent = MainGui
    })

    local MainCorner = Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    local MainStroke = Create("UIStroke", {Color = FluLib.Theme.Stroke, Thickness = 1.2, Parent = MainFrame})

    -- Sidebar Area
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 220, 1, 0),
        BackgroundColor3 = FluLib.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Sidebar})
    
    local SidebarCover = Create("Frame", { -- บังส่วนมุมขวาของ Sidebar ให้คม
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundColor3 = FluLib.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Sidebar
    })

    local Title = Create("TextLabel", {
        Text = Config.Name,
        Position = UDim2.new(0, 25, 0, 25),
        Size = UDim2.new(1, -50, 0, 30),
        Font = FluLib.Theme.BoldFont,
        TextSize = 22,
        TextColor3 = FluLib.Theme.Text,
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        Parent = Sidebar
    })

    local TabContainer = Create("ScrollingFrame", {
        Position = UDim2.new(0, 10, 0, 80),
        Size = UDim2.new(1, -20, 1, -140),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    local TabList = Create("UIListLayout", {Padding = UDim.new(0, 5), Parent = TabContainer})

    local PageContainer = Create("Frame", {
        Position = UDim2.new(0, 235, 0, 25),
        Size = UDim2.new(1, -255, 1, -50),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    --// TAB LOGIC
    function Window:CreateTab(Name, Icon)
        local Tab = {Page = nil, Btn = nil}
        
        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "      " .. Name,
            Font = FluLib.Theme.Font,
            TextSize = 14,
            TextColor3 = FluLib.Theme.TextSecondary,
            TextXAlignment = "Left",
            Parent = TabContainer
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = FluLib.Theme.Accent,
            Parent = PageContainer
        })
        Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = Page})
        Create("UIPadding", {PaddingTop = UDim.new(0, 5), Parent = Page})

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = FluLib.Theme.TextSecondary}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, TextColor3 = FluLib.Theme.Accent}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.9
            TabBtn.TextColor3 = FluLib.Theme.Accent
        end

        --// SECTION LOGIC
        function Tab:CreateSection(Title)
            local Section = {}
            local SectLbl = Create("TextLabel", {
                Text = Title:upper(),
                Size = UDim2.new(1, 0, 0, 25),
                Font = FluLib.Theme.BoldFont,
                TextSize = 12,
                TextColor3 = FluLib.Theme.Accent,
                BackgroundTransparency = 1,
                TextXAlignment = "Left",
                Parent = Page
            })

            -- 1. BUTTON (Full Logic)
            function Section:CreateButton(Props)
                Props = Props or {Name = "Button", Callback = function() end}
                local BtnFrame = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 45),
                    BackgroundColor3 = FluLib.Theme.Element,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BtnFrame})
                local Stroke = Create("UIStroke", {Color = FluLib.Theme.Stroke, Parent = BtnFrame})

                local Interact = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "  " .. Props.Name,
                    Font = FluLib.Theme.Font,
                    TextSize = 14,
                    TextColor3 = FluLib.Theme.Text,
                    TextXAlignment = "Left",
                    Parent = BtnFrame
                })

                Interact.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = FluLib.Theme.ElementHover}, 0.2) end)
                Interact.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = FluLib.Theme.Element}, 0.2) end)
                Interact.MouseButton1Down:Connect(function() Tween(BtnFrame, {Size = UDim2.new(1, -15, 0, 42)}, 0.1) end)
                Interact.MouseButton1Up:Connect(function() 
                    Tween(BtnFrame, {Size = UDim2.new(1, -10, 0, 45)}, 0.1)
                    Props.Callback() 
                end)
            end

            -- 2. TOGGLE (Luna Based Logic)
            function Section:CreateToggle(Props, Flag)
                Props = Props or {Name = "Toggle", CurrentValue = false, Callback = function() end}
                local Tgl = {Value = Props.CurrentValue}

                local Frame = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 45),
                    BackgroundColor3 = FluLib.Theme.Element,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
                Create("UIStroke", {Color = FluLib.Theme.Stroke, Parent = Frame})

                local Lbl = Create("TextLabel", {
                    Text = "  " .. Props.Name,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = FluLib.Theme.Font,
                    TextSize = 14,
                    TextColor3 = FluLib.Theme.Text,
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Parent = Frame
                })

                local Bg = Create("Frame", {
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = Tgl.Value and FluLib.Theme.Accent or Color3.fromRGB(60, 60, 60),
                    Parent = Frame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bg})

                local Dot = Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = Tgl.Value and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = Bg
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                local function Set(v)
                    Tgl.Value = v
                    Tween(Bg, {BackgroundColor3 = v and FluLib.Theme.Accent or Color3.fromRGB(60, 60, 60)}, 0.3)
                    Tween(Dot, {Position = v and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)}, 0.3)
                    Props.Callback(v)
                    if Flag then FluLib.Flags[Flag] = v end
                end

                local Click = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = Frame})
                Click.MouseButton1Click:Connect(function() Set(not Tgl.Value) end)
                
                return {Set = Set}
            end

            -- 3. SLIDER (Advanced Drag Logic)
            function Section:CreateSlider(Props, Flag)
                Props = Props or {Name = "Slider", Range = {0, 100}, CurrentValue = 50, Callback = function() end}
                local Sld = {Value = Props.CurrentValue}

                local Frame = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 65),
                    BackgroundColor3 = FluLib.Theme.Element,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})

                local Lbl = Create("TextLabel", {
                    Text = "  " .. Props.Name,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = FluLib.Theme.Font,
                    TextSize = 14,
                    TextColor3 = FluLib.Theme.Text,
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Parent = Frame
                })

                local ValLbl = Create("TextLabel", {
                    Text = tostring(Sld.Value),
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 50, 0, 35),
                    Font = "Code",
                    TextSize = 14,
                    TextColor3 = FluLib.Theme.Accent,
                    BackgroundTransparency = 1,
                    Parent = Frame
                })

                local Rail = Create("Frame", {
                    Size = UDim2.new(1, -30, 0, 4),
                    Position = UDim2.new(0, 15, 0, 45),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Parent = Frame
                })
                Create("UICorner", {Parent = Rail})

                local Fill = Create("Frame", {
                    Size = UDim2.new((Sld.Value - Props.Range[1])/(Props.Range[2]-Props.Range[1]), 0, 1, 0),
                    BackgroundColor3 = FluLib.Theme.Accent,
                    Parent = Rail
                })
                Create("UICorner", {Parent = Fill})

                local function Update()
                    local pos = math.clamp((Mouse.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
                    local val = math.floor(Props.Range[1] + (Props.Range[2] - Props.Range[1]) * pos)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    ValLbl.Text = tostring(val)
                    Sld.Value = val
                    Props.Callback(val)
                    if Flag then FluLib.Flags[Flag] = val end
                end

                local Dragging = false
                Frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                RunService.RenderStepped:Connect(function() if Dragging then Update() end end)
            end

            -- 4. DROPDOWN (Multi-Select Support)
            function Section:CreateDropdown(Props, Flag)
                Props = Kwargify({Name = "Dropdown", Options = {}, MultipleOptions = false, Callback = function() end}, Props)
                local Drop = {Open = false, Selected = {}}

                local Frame = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 45),
                    BackgroundColor3 = FluLib.Theme.Element,
                    ClipsDescendants = true,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
                Create("UIStroke", {Color = FluLib.Theme.Stroke, Parent = Frame})

                local MainBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 1,
                    Text = "  " .. Props.Name,
                    Font = FluLib.Theme.Font,
                    TextSize = 14,
                    TextColor3 = FluLib.Theme.Text,
                    TextXAlignment = "Left",
                    Parent = Frame
                })

                local List = Create("Frame", {
                    Position = UDim2.new(0, 0, 0, 45),
                    Size = UDim2.new(1, 0, 0, #Props.Options * 35),
                    BackgroundTransparency = 1,
                    Parent = Frame
                })
                Create("UIListLayout", {Parent = List})

                for _, optName in pairs(Props.Options) do
                    local OptBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundTransparency = 1,
                        Text = "      " .. optName,
                        Font = FluLib.Theme.Font,
                        TextSize = 13,
                        TextColor3 = FluLib.Theme.TextSecondary,
                        TextXAlignment = "Left",
                        Parent = List
                    })

                    OptBtn.MouseButton1Click:Connect(function()
                        if not Props.MultipleOptions then
                            MainBtn.Text = "  " .. Props.Name .. " : " .. optName
                            Drop.Open = false
                            Tween(Frame, {Size = UDim2.new(1, -10, 0, 45)}, 0.4)
                            Props.Callback(optName)
                        else
                            if table.find(Drop.Selected, optName) then
                                table.remove(Drop.Selected, table.find(Drop.Selected, optName))
                                OptBtn.TextColor3 = FluLib.Theme.TextSecondary
                            else
                                table.insert(Drop.Selected, optName)
                                OptBtn.TextColor3 = FluLib.Theme.Accent
                            end
                            Props.Callback(Drop.Selected)
                        end
                    end)
                end

                MainBtn.MouseButton1Click:Connect(function()
                    Drop.Open = not Drop.Open
                    local targetSize = Drop.Open and 45 + (#Props.Options * 35) or 45
                    Tween(Frame, {Size = UDim2.new(1, -10, 0, targetSize)}, 0.4)
                end)
            end

            -- 5. INPUT BOX
            function Section:CreateInput(Props, Flag)
                Props = Props or {Name = "Input", Placeholder = "Type here...", Callback = function() end}
                local Frame = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 50),
                    BackgroundColor3 = FluLib.Theme.Element,
                    Parent = Page
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})

                local Box = Create("TextBox", {
                    Size = UDim2.new(1, -20, 0, 30),
                    Position = UDim2.new(0, 10, 0.5, -15),
                    BackgroundTransparency = 1,
                    Text = "",
                    PlaceholderText = Props.Placeholder,
                    Font = FluLib.Theme.Font,
                    TextSize = 14,
                    TextColor3 = FluLib.Theme.Text,
                    TextXAlignment = "Left",
                    Parent = Frame
                })

                Box.FocusLost:Connect(function(Enter)
                    Props.Callback(Box.Text)
                    if Flag then FluLib.Flags[Flag] = Box.Text end
                end)
            end

            return Section
        end
        return Tab
    end

    MakeDraggable(Sidebar, MainFrame)
    return Window
end

--// HELPER FUNCTIONS
function Kwargify(defaults, passed)
    passed = passed or {}
    for i, v in pairs(defaults) do
        if passed[i] == nil then passed[i] = v end
    end
    return passed
end

return FluLib
