local SlayLib = {
Folder = "SlayLib_Config",
Settings = {},
Flags = {},
Signals = {},
Theme = {
MainColor = Color3.fromRGB(120, 80, 255),
Background = Color3.fromRGB(12, 12, 12),
Sidebar = Color3.fromRGB(18, 18, 18),
Element = Color3.fromRGB(25, 25, 25),
ElementHover = Color3.fromRGB(32, 32, 32),
Text = Color3.fromRGB(255, 255, 255),
TextSecondary = Color3.fromRGB(180, 180, 180),
Stroke = Color3.fromRGB(45, 45, 45),
NotificationColor = Color3.fromRGB(120, 80, 255),
Success = Color3.fromRGB(0, 255, 127),
Warning = Color3.fromRGB(255, 165, 0),
Error = Color3.fromRGB(255, 65, 65),
},
Icons = {
Logo = "rbxassetid://13589839447",
Check = "rbxassetid://10734895530",
Chevron = "rbxassetid://10734895856",
Search = "rbxassetid://10734897102",
Folder = "rbxassetid://10734897484"
}
}

--// Services Initialization
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

--// Environment Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)

--// Folder Management (Config)
if not isfolder(SlayLib.Folder) then
makefolder(SlayLib.Folder)
end

--// UTILITY FUNCTIONS (THE BRAIN)
local function Create(class, props)
local obj = Instance.new(class)
for i, v in pairs(props) do
obj[i] = v
end
return obj
end

local function GetTweenInfo(time, style, dir)
return TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
end

local function Tween(obj, goal, time, style, dir)
local t = TweenService:Create(obj, GetTweenInfo(time, style, dir), goal)
t:Play()
return t
end

--// SMART TEXT SCALING LOGIC
local function ApplyTextLogic(label, content, maxSize)
label.Text = content
label.TextWrapped = true
label.TextSize = maxSize or 14

local function Adjust()  
    if label.TextBounds.X > label.AbsoluteSize.X or label.TextBounds.Y > label.AbsoluteSize.Y then  
        label.TextScaled = true  
    else  
        label.TextScaled = false  
    end  
end  

label:GetPropertyChangedSignal("AbsoluteSize"):Connect(Adjust)  
Adjust()

end

--// DRAGGING SYSTEM (PRO VERSION)
local function RegisterDrag(Frame, Handle)
local Dragging = false
local DragInput, DragStart, StartPos

Handle.InputBegan:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
        Dragging = true  
        DragStart = input.Position  
        StartPos = Frame.Position  

        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then  
                Dragging = false  
            end  
        end)  
    end  
end)  

Handle.InputChanged:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then  
        DragInput = input  
    end  
end)  

UserInputService.InputChanged:Connect(function(input)  
    if input == DragInput and Dragging then  
        local Delta = input.Position - DragStart  
        Frame.Position = UDim2.new(  
            StartPos.X.Scale,   
            StartPos.X.Offset + Delta.X,   
            StartPos.Y.Scale,   
            StartPos.Y.Offset + Delta.Y  
        )  
    end  
end)

end

--// NOTIFICATION ENGINE (PROXIMITY BASED)
function SlayLib:Notify(Config)
    Config = Config or {Title = "Notification", Content = "Message", Duration = 5, Type = "Neutral"}
    
    -- 1. Setup Container
    local NotifGui = Parent:FindFirstChild("SlayNotifGui") or Create("ScreenGui", {
        Name = "SlayNotifGui", Parent = Parent, DisplayOrder = 9999, ResetOnSpawn = false
    })

    local Holder = NotifGui:FindFirstChild("NotifHolder") or Create("Frame", {
        Name = "NotifHolder", Parent = NotifGui, BackgroundTransparency = 1,
        Size = UDim2.new(0, 280, 1, -60), Position = UDim2.new(1, -300, 0, 30)
    })
    
    if not Holder:FindFirstChild("UIListLayout") then
        Create("UIListLayout", {
            Parent = Holder, VerticalAlignment = "Top", HorizontalAlignment = "Right", -- เปลี่ยนเป็น Top เพื่อให้ใหม่รันจากบนลงล่าง
            Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder
        })
    end

    -- 2. Theme Configuration
    local NotifColor = SlayLib.Theme.MainColor
    if Config.Type == "Success" then NotifColor = SlayLib.Theme.Success
    elseif Config.Type == "Error" then NotifColor = SlayLib.Theme.Error
    elseif Config.Type == "Warning" then NotifColor = SlayLib.Theme.Warning end

    -- 3. Notification Unit (ใช้ CanvasGroup เพื่อคุมความโปร่งใสเบ็ดเสร็จ)
    local NotifFrame = Create("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, 0), -- เริ่มที่ความสูง 0
        BackgroundColor3 = Color3.fromRGB(15, 15, 15), -- สีดำลึกแบบ Sidebar
        BackgroundTransparency = 0.2,
        GroupTransparency = 1, -- เริ่มที่จางหาย
        ClipsDescendants = true,
        Parent = Holder
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = NotifFrame})
    
    -- ขอบเงาเบาๆ (Shadow Stroke)
    Create("UIStroke", {
        Color = NotifColor, Transparency = 0.6, Thickness = 1.2, 
        ApplyStrokeMode = "Border", Parent = NotifFrame
    })

    -- แถบสีสถานะแบบมินิมอล (จุดกลมเล็กๆ แทนขีดหนา)
    local StatusDot = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 12, 0, 15),
        BackgroundColor3 = NotifColor, Parent = NotifFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = StatusDot})

    -- เนื้อหาข้อความ
    local TextArea = Create("Frame", {
        Size = UDim2.new(1, -35, 0, 0), Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1, AutomaticSize = "Y", Parent = NotifFrame
    })
    Create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12), Parent = TextArea})
    Create("UIListLayout", {Parent = TextArea, Padding = UDim.new(0, 2)})

    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16), Font = "GothamBold", TextSize = 13,
        TextColor3 = NotifColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = TextArea,
        Text = Config.Title:upper() -- ตัวพิมพ์ใหญ่เพื่อให้ดูเป็น UI System
    })

    local ContentLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), Font = "GothamMedium", TextSize = 11,
        TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1, 
        TextXAlignment = "Left", TextWrapped = true, AutomaticSize = "Y", Parent = TextArea,
        Text = Config.Content
    })

    -- 4. Animation Engine (Smooth & Fast)
    task.spawn(function()
        -- รอคำนวณขนาดที่แท้จริง
        local RealHeight = TextArea.AbsoluteSize.Y
        
        -- Slide In และขยายพร้อมกัน
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, RealHeight), GroupTransparency = 0}, 0.45, Enum.EasingStyle.Quart)
        
        -- เพิ่มลูกเล่นแสงกระพริบที่จุดสถานะ
        local Glow = Create("Frame", {
            Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 12, 0, 15),
            BackgroundColor3 = NotifColor, BackgroundTransparency = 0.5, Parent = NotifFrame
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Glow})
        Tween(Glow, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 5, 0, 8), BackgroundTransparency = 1}, 0.8):Completed:Connect(function() Glow:Destroy() end)
    end)

    -- 5. Auto-Destroy Sequence
    task.delay(Config.Duration, function()
        if NotifFrame then
            -- หายไปแบบจางและย่อขนาด (แก้ปัญหาเศษค้าง)
            local Close = Tween(NotifFrame, {GroupTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            Close.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end
    end)
end




--// LOADING SEQUENCE (HIGH FIDELITY)
local function ExecuteLoadingSequence()
local Screen = Create("ScreenGui", {Name = "SlayLoadingEnv", Parent = Parent})
local Blur = Create("BlurEffect", {Size = 0, Parent = Lighting})

local Holder = Create("Frame", {  
    Size = UDim2.new(0, 400, 0, 400), Position = UDim2.new(0.5, -200, 0.5, -200),  
    BackgroundTransparency = 1, Parent = Screen  
})  

local Logo = Create("ImageLabel", {  
    Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.45, 0),  
    Image = SlayLib.Icons.Logo, ImageColor3 = SlayLib.Theme.MainColor,  
    BackgroundTransparency = 1, Parent = Holder  
})  

local InfoLabel = Create("TextLabel", {  
    Text = "INITIALIZING CORE COMPONENTS...", Size = UDim2.new(1, 0, 0, 20),  
    Position = UDim2.new(0, 0, 0.75, 0), Font = "Code", TextSize = 12,  
    TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, Parent = Holder,  
    TextTransparency = 1  
})  

local BarBg = Create("Frame", {  
    Size = UDim2.new(0, 250, 0, 4), Position = UDim2.new(0.5, -125, 0.7, 0),  
    BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Holder, BackgroundTransparency = 1  
})  
local BarFill = Create("Frame", {  
    Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = BarBg  
})  
Create("UICorner", {Parent = BarBg}) Create("UICorner", {Parent = BarFill})  

-- Sequence Start  
Tween(Blur, {Size = 28}, 1)  
Tween(Logo, {Size = UDim2.new(0, 140, 0, 140), Position = UDim2.new(0.5, -70, 0.45, -70)}, 1.2, Enum.EasingStyle.Elastic)  
task.wait(0.6)  
Tween(InfoLabel, {TextTransparency = 0}, 0.5)  
Tween(BarBg, {BackgroundTransparency = 0}, 0.5)  

local Steps = {"Authenticating...", "Loading UI Elements...", "Applying Themes...", "Ready!"}  
for i, step in ipairs(Steps) do  
    InfoLabel.Text = step:upper()  
    Tween(BarFill, {Size = UDim2.new(i/#Steps, 0, 1, 0)}, 0.4)  
    task.wait(math.random(4, 8) / 10)  
end  

-- Fade Out  
Tween(Logo, {ImageTransparency = 1, Size = UDim2.new(0, 160, 0, 160), Position = UDim2.new(0.5, -80, 0.45, -80)}, 0.6)  
Tween(InfoLabel, {TextTransparency = 1}, 0.4)  
Tween(BarBg, {BackgroundTransparency = 1}, 0.4)  
Tween(BarFill, {BackgroundTransparency = 1}, 0.4)  
Tween(Blur, {Size = 0}, 0.8)  

task.wait(0.8)  
Screen:Destroy()  
Blur:Destroy()

end

--// MAIN WINDOW CONSTRUCTOR
function SlayLib:CreateWindow(Config)
Config = Config or {Name = "SlayLib Ultimate"}

-- Force Loading  
ExecuteLoadingSequence()  

local Window = {  
    Enabled = true,  
    Toggled = true,  
    Tabs = {},  
    CurrentTab = nil,  
    Minimized = false  
}  

local CoreGuiFrame = Create("ScreenGui", {Name = "SlayLib_X_Engine", Parent = Parent, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})  

-- 1. FLOATING TOGGLE ICON (Always accessible)  
local FloatingToggle = Create("Frame", {  
    Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0.05, 0, 0.2, 0),  
    BackgroundColor3 = SlayLib.Theme.MainColor, Parent = CoreGuiFrame,  
    ZIndex = 50  
})  
Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingToggle})  
Create("UIStroke", {Color = Color3.new(1,1,1), Thickness = 2, Transparency = 0.7, Parent = FloatingToggle})  
local ToggleIcon = Create("ImageLabel", {  
    Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0.5, -16, 0.5, -16),  
    Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = FloatingToggle  
})  
local ToggleButton = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = FloatingToggle})  

-- 2. MAIN HUB FRAME  
local MainFrame = Create("Frame", {  
    Size = UDim2.new(0, 620, 0, 440), Position = UDim2.new(0.5, -310, 0.5, -220),  
    BackgroundColor3 = SlayLib.Theme.Background, Parent = CoreGuiFrame,  
    ClipsDescendants = true, Visible = true  
})  
Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = MainFrame})  
local MainStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 2, Parent = MainFrame})  

-- 3. SIDEBAR (ISOLATED)  
local Sidebar = Create("Frame", {  
    Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame  
})  
Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = Sidebar})  

-- Sidebar Header (Title Safety Area)  
local SideHeader = Create("Frame", {  
    Size = UDim2.new(1, 0, 0, 80), BackgroundTransparency = 1, Parent = Sidebar  
})  
local LibIcon = Create("ImageLabel", {  
    Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(0, 20, 0, 22),  
    Image = SlayLib.Icons.Logo, BackgroundTransparency = 1, Parent = SideHeader,  
    ImageColor3 = SlayLib.Theme.MainColor  
})  
local LibTitle = Create("TextLabel", {  
    Size = UDim2.new(1, -75, 1, 0), Position = UDim2.new(0, 65, 0, 0),  
    Font = "GothamBold", TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left",  
    BackgroundTransparency = 1, Parent = SideHeader  
})  
ApplyTextLogic(LibTitle, Config.Name, 20)  

-- Tab Scrolling Area (Will not overlap header)  
local TabScroll = Create("ScrollingFrame", {  
    Size = UDim2.new(1, -10, 1, -100), Position = UDim2.new(0, 5, 0, 90),  
    BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar,  
    CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y"  
})  
Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 8), HorizontalAlignment = "Center"})  

-- 4. CONTENT AREA  
local PageContainer = Create("Frame", {  
    Size = UDim2.new(1, -230, 1, -40), Position = UDim2.new(0, 215, 0, 20),  
    BackgroundTransparency = 1, Parent = MainFrame  
})  

-- Toggle Logic  
ToggleButton.MouseButton1Click:Connect(function()  
    Window.Toggled = not Window.Toggled  
    if Window.Toggled then  
        MainFrame.Visible = true  
        Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 440), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)  
    else  
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5)  
        task.delay(0.5, function() if not Window.Toggled then MainFrame.Visible = false end end)  
    end  
end)  

RegisterDrag(MainFrame, SideHeader)  
RegisterDrag(FloatingToggle, FloatingToggle)  

--// TAB CREATOR  
function Window:CreateTab(Name, IconID)  
    local Tab = {Active = false, Page = nil, Button = nil}  

    local TabBtn = Create("TextButton", {  
        Size = UDim2.new(0, 180, 0, 45), BackgroundColor3 = SlayLib.Theme.MainColor,  
        BackgroundTransparency = 1, Text = "", Parent = TabScroll  
    })  
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TabBtn})  

    local TabIcon = Create("ImageLabel", {  
        Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 15, 0.5, -10),  
        Image = IconID or SlayLib.Icons.Folder, BackgroundTransparency = 1,  
        ImageColor3 = SlayLib.Theme.TextSecondary, Parent = TabBtn  
    })  

    local TabLbl = Create("TextLabel", {  
        Text = Name, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 45, 0, 0),  
        Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.TextSecondary,  
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TabBtn  
    })  

    local Page = Create("ScrollingFrame", {  
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,  
        Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = SlayLib.Theme.MainColor,  
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", Parent = PageContainer  
    })  
    Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 12)})  
    Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 5)})  

    TabBtn.MouseButton1Click:Connect(function()  
        if Window.CurrentTab then  
            Window.CurrentTab.Page.Visible = false  
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.3)  
            Tween(Window.CurrentTab.Label, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)  
            Tween(Window.CurrentTab.Icon, {ImageColor3 = SlayLib.Theme.TextSecondary}, 0.3)  
        end  

        Window.CurrentTab = {Page = Page, Button = TabBtn, Label = TabLbl, Icon = TabIcon}  
        Page.Visible = true  
        Tween(TabBtn, {BackgroundTransparency = 0.15}, 0.3)  
        Tween(TabLbl, {TextColor3 = SlayLib.Theme.MainColor}, 0.3)  
        Tween(TabIcon, {ImageColor3 = SlayLib.Theme.MainColor}, 0.3)  
    end)  

    -- Auto-select first tab  
    if not Window.CurrentTab then  
        Window.CurrentTab = {Page = Page, Button = TabBtn, Label = TabLbl, Icon = TabIcon}  
        Page.Visible = true  
        TabBtn.BackgroundTransparency = 0.15  
        TabLbl.TextColor3 = SlayLib.Theme.MainColor  
        TabIcon.ImageColor3 = SlayLib.Theme.MainColor  
    end  

    --// SECTION CREATOR  
    function Tab:CreateSection(SName)  
        local Section = {}  

        local SectFrame = Create("Frame", {  
            Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = Page  
        })  
        local SectLabel = Create("TextLabel", {  
            Text = SName:upper(), Size = UDim2.new(1, 0, 1, 0),  
            Font = "GothamBold", TextSize = 12, TextColor3 = SlayLib.Theme.MainColor,  
            BackgroundTransparency = 1, TextXAlignment = "Left", Parent = SectFrame  
        })  

        -- 1. ADVANCED TOGGLE  
        function Section:CreateToggle(Props)  
            Props = Props or {Name = "Toggle", CurrentValue = false, Flag = "Toggle_1", Callback = function() end}  
            local TState = Props.CurrentValue  
            SlayLib.Flags[Props.Flag] = TState  

            local TContainer = Create("Frame", {  
                Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TContainer})  

            local TLbl = Create("TextLabel", {  
                Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 15, 0, 0),  
                Font = "GothamMedium", TextColor3 = SlayLib.Theme.Text,  
                TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TContainer  
            })  
            ApplyTextLogic(TLbl, Props.Name, 15)  

            local Switch = Create("Frame", {  
                Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -60, 0.5, -12),  
                BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(50, 50, 50), Parent = TContainer  
            })  
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})  

            local Dot = Create("Frame", {  
                Size = UDim2.new(0, 18, 0, 18),   
                Position = TState and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9),  
                BackgroundColor3 = Color3.new(1, 1, 1), Parent = Switch  
            })  
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})  

            local ClickArea = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = TContainer})  

            ClickArea.MouseButton1Click:Connect(function()  
                TState = not TState  
                SlayLib.Flags[Props.Flag] = TState  
                Tween(Switch, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(50, 50, 50)}, 0.3)  
                Tween(Dot, {Position = TState and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)}, 0.3)  
                task.spawn(Props.Callback, TState)  
            end)  
        end  

        -- 2. PRECISION SLIDER  
        function Section:CreateSlider(Props)  
            Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Flag = "Slider_1", Callback = function() end}  
            local Value = Props.Def  
            SlayLib.Flags[Props.Flag] = Value  

            local SContainer = Create("Frame", {  
                Size = UDim2.new(1, 0, 0, 75), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SContainer})  

            local SLbl = Create("TextLabel", {  
                Size = UDim2.new(1, -100, 0, 40), Position = UDim2.new(0, 15, 0, 5),  
                Font = "GothamMedium", TextColor3 = SlayLib.Theme.Text,  
                TextXAlignment = "Left", BackgroundTransparency = 1, Parent = SContainer  
            })  
            ApplyTextLogic(SLbl, Props.Name, 15)  

            local ValInput = Create("TextBox", {  
                Text = tostring(Value), Size = UDim2.new(0, 60, 0, 25), Position = UDim2.new(1, -75, 0, 12),  
                Font = "Code", TextSize = 14, TextColor3 = SlayLib.Theme.MainColor,  
                BackgroundColor3 = Color3.fromRGB(35,35,35), Parent = SContainer  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = ValInput})  

            local Bar = Create("Frame", {  
                Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 55),  
                BackgroundColor3 = Color3.fromRGB(45, 45, 45), Parent = SContainer  
            })  
            Create("UICorner", {Parent = Bar})  

            local Fill = Create("Frame", {  
                Size = UDim2.new((Value - Props.Min)/(Props.Max - Props.Min), 0, 1, 0),  
                BackgroundColor3 = SlayLib.Theme.MainColor, Parent = Bar  
            })  
            Create("UICorner", {Parent = Fill})  

            local function Update(Input)  
                local Percentage = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)  
                Value = math.floor(Props.Min + (Props.Max - Props.Min) * Percentage)  
                Fill.Size = UDim2.new(Percentage, 0, 1, 0)  
                ValInput.Text = tostring(Value)  
                SlayLib.Flags[Props.Flag] = Value  
                task.spawn(Props.Callback, Value)  
            end  

            Bar.InputBegan:Connect(function(input)  
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
                    Update(input)  
                    local MoveCon, EndCon  
                    MoveCon = UserInputService.InputChanged:Connect(function(move)  
                        if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then  
                            Update(move)  
                        end  
                    end)  
                    EndCon = UserInputService.InputEnded:Connect(function(ended)  
                        if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then  
                            MoveCon:Disconnect() EndCon:Disconnect()  
                        end  
                    end)  
                end  
            end)  

            ValInput.FocusLost:Connect(function()  
                local n = tonumber(ValInput.Text)  
                if n then  
                    Value = math.clamp(n, Props.Min, Props.Max)  
                    Fill.Size = UDim2.new((Value - Props.Min)/(Props.Max - Props.Min), 0, 1, 0)  
                    ValInput.Text = tostring(Value)  
                    task.spawn(Props.Callback, Value)  
                end  
            end)  
        end  

        -- 3. SEARCHABLE DROPDOWN  
        function Section:CreateDropdown(Props)  
            Props = Props or {Name = "Dropdown", Options = {"Option 1", "Option 2"}, Flag = "Drop_1", Callback = function() end}  
            local IsOpen = false  
            local Selected = Props.Options[1]  

            local DContainer = Create("Frame", {  
                Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element,  
                ClipsDescendants = true, Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = DContainer})  

            local MainBtn = Create("TextButton", {  
                Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1,  
                Text = "", Parent = DContainer  
            })  

            local DLbl = Create("TextLabel", {  
                Text = "  " .. Props.Name .. ": " .. Selected, Size = UDim2.new(1, -50, 0, 52),  
                Position = UDim2.new(0, 15, 0, 0), Font = "GothamMedium", TextSize = 14,  
                TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = MainBtn  
            })  

            local Chevron = Create("ImageLabel", {  
                Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -35, 0.5, -10),  
                Image = SlayLib.Icons.Chevron, BackgroundTransparency = 1, Parent = MainBtn  
            })  

            local List = Create("Frame", {  
                Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 55),  
                BackgroundTransparency = 1, Parent = DContainer  
            })  
            local ListLayout = Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 5)})  

            local function Refresh()  
                for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end  
                for _, opt in pairs(Props.Options) do  
                    local OBtn = Create("TextButton", {  
                        Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(30,30,30),  
                        Text = "   " .. tostring(opt), Font = "Gotham", TextSize = 13,  
                        TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", Parent = List  
                    })  
                    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = OBtn})  

                    OBtn.MouseButton1Click:Connect(function()  
                        Selected = opt  
                        DLbl.Text = "  " .. Props.Name .. ": " .. tostring(opt)  
                        IsOpen = false  
                        Tween(DContainer, {Size = UDim2.new(1, 0, 0, 52)}, 0.4)  
                        Tween(Chevron, {Rotation = 0}, 0.4)  
                        task.spawn(Props.Callback, opt)  
                    end)  
                end  
            end  

            Refresh()  

            MainBtn.MouseButton1Click:Connect(function()  
                IsOpen = not IsOpen  
                local Target = IsOpen and 60 + (#Props.Options * 40) or 52  
                Tween(DContainer, {Size = UDim2.new(1, 0, 0, math.min(Target, 300))}, 0.4)  
                Tween(Chevron, {Rotation = IsOpen and 180 or 0}, 0.4)  
            end)  

            function Section:UpdateDropdown(NewOptions)  
                Props.Options = NewOptions  
                Refresh()  
            end  
        end  

        -- 4. INTERACTIVE BUTTON  
        function Section:CreateButton(Props)  
            Props = Props or {Name = "Action Button", Callback = function() end}  

            local BFrame = Create("TextButton", {  
                Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = SlayLib.Theme.Element,  
                Text = "", Parent = Page, AutoButtonColor = false  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = BFrame})  

            local BLbl = Create("TextLabel", {  
                Size = UDim2.new(1, 0, 1, 0), Font = "GothamBold", TextSize = 14,  
                TextColor3 = SlayLib.Theme.Text, BackgroundTransparency = 1, Parent = BFrame  
            })  
            ApplyTextLogic(BLbl, Props.Name, 14)  

            BFrame.MouseEnter:Connect(function() Tween(BFrame, {BackgroundColor3 = SlayLib.Theme.ElementHover}, 0.2) end)  
            BFrame.MouseLeave:Connect(function() Tween(BFrame, {BackgroundColor3 = SlayLib.Theme.Element}, 0.2) end)  

            BFrame.MouseButton1Click:Connect(function()  
                local Circle = Create("Frame", {  
                    Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0),  
                    BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8, Parent = BFrame  
                })  
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Circle})  
                Tween(Circle, {Size = UDim2.new(1,0,2,0), Position = UDim2.new(0,0,-0.5,0), BackgroundTransparency = 1}, 0.5)  
                task.delay(0.5, function() Circle:Destroy() end)  
                task.spawn(Props.Callback)  
            end)  
        end  

        -- 5. SMART INPUT BOX  
        function Section:CreateInput(Props)  
            Props = Props or {Name = "Input Field", Placeholder = "Value...", Callback = function() end}  

            local IContainer = Create("Frame", {  
                Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = IContainer})  

            local ILbl = Create("TextLabel", {  
                Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 15, 0, 0),  
                Font = "GothamMedium", TextColor3 = SlayLib.Theme.Text,  
                TextXAlignment = "Left", BackgroundTransparency = 1, Parent = IContainer  
            })  
            ApplyTextLogic(ILbl, Props.Name, 15)  

            local Box = Create("TextBox", {  
                Size = UDim2.new(0, 180, 0, 32), Position = UDim2.new(1, -195, 0.5, -16),  
                BackgroundColor3 = Color3.fromRGB(35, 35, 35), Text = "", PlaceholderText = Props.Placeholder,  
                TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 14, Parent = IContainer,  
                ClipsDescendants = true  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Box})  

            Box.FocusLost:Connect(function(enter)  
                task.spawn(Props.Callback, Box.Text)  
            end)  
        end  

        -- 6. DYNAMIC PARAGRAPH (MULTILINE)  
                -- 6. DYNAMIC PARAGRAPH (แก้ไขให้สวยงามตามรูปตัวอย่าง)
        function Section:CreateParagraph(Props)  
            Props = Props or {Title = "Header", Content = "Your text goes here."}  

            -- กล่องหลักขยายตามเนื้อหาอัตโนมัติ (AutomaticSize = "Y")
            local PContainer = Create("Frame", {  
                Name = "Paragraph",
                Size = UDim2.new(1, 0, 0, 0), 
                BackgroundColor3 = SlayLib.Theme.Element,  
                AutomaticSize = Enum.AutomaticSize.Y, 
                Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = PContainer})  
            
            -- เว้นระยะห่างจากขอบกล่อง (เหมือนในรูปที่ 3)
            Create("UIPadding", {
                Parent = PContainer, 
                PaddingLeft = UDim.new(0, 15), 
                PaddingRight = UDim.new(0, 15), 
                PaddingTop = UDim.new(0, 12), 
                PaddingBottom = UDim.new(0, 12)
            })  

            -- ตัวจัดระเบียบให้ Title กับ Content เรียงต่อกัน ไม่ซ้อนทับกัน
            local Layout = Create("UIListLayout", {
                Parent = PContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5) -- ช่องว่างระหว่างหัวข้อกับเนื้อหา
            })

            -- ส่วนหัวข้อ (Title) สีม่วง
            local PTtl = Create("TextLabel", {  
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 20), 
                Font = "GothamBold", 
                TextSize = 14,
                TextColor3 = SlayLib.Theme.MainColor, 
                BackgroundTransparency = 1,  
                TextXAlignment = "Left", 
                LayoutOrder = 1,
                Parent = PContainer  
            })  
            PTtl.Text = Props.Title

            -- ส่วนเนื้อหา (Content) สีเทา และขยายบรรทัดอัตโนมัติ
            local PCnt = Create("TextLabel", {  
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0), 
                Font = "Gotham", 
                TextSize = 13,
                TextColor3 = SlayLib.Theme.TextSecondary, 
                BackgroundTransparency = 1,  
                TextXAlignment = "Left", 
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y, 
                LayoutOrder = 2,
                Parent = PContainer  
            })  
            PCnt.Text = Props.Content
        end


        return Section  
    end  
    return Tab  
end  

return Window

end

--// AUTO-SAVE LOGIC (GRAND ADDITION)
function SlayLib:SaveConfig(Name)
local FullPath = SlayLib.Folder .. "/" .. Name .. ".json"
local Data = HttpService:JSONEncode(SlayLib.Flags)
writefile(FullPath, Data)
SlayLib:Notify({Title = "System", Content = "Config Saved Successfully!", Type = "Success", Duration = 3})
end

function SlayLib:LoadConfig(Name)
local FullPath = SlayLib.Folder .. "/" .. Name .. ".json"
if isfile(FullPath) then
local Data = HttpService:JSONDecode(readfile(FullPath))
SlayLib.Flags = Data
SlayLib:Notify({Title = "System", Content = "Config Loaded!", Type = "Success", Duration = 3})
-- ในระบบจริงต้องวน Loop เพื่ออัปเดต UI ด้วย
end
end

return SlayLib