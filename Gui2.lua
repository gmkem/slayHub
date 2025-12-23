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
Logofull = "rbxassetid://116729461256827",
Logo = "rbxassetid://71428791657528",
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

--// [ADDED] ANTI RE-EXECUTE SYSTEM (ระบบล้างของเก่าก่อนรันใหม่)
for _, obj in pairs(Parent:GetChildren()) do
    -- ตรวจสอบชื่อ ScreenGui ที่เราตั้งไว้ในโค้ด (Engine, Loading, Notification)
    if obj.Name == "SlayLib_X_Engine" or obj.Name == "SlayLoadingEnv" or obj.Name == "SlayNotifFinal" then
        obj:Destroy()
    end
end
-- ล้างเอฟเฟกต์ Blur ที่ค้างอยู่ใน Lighting
if Lighting:FindFirstChild("SlayBlur") then Lighting.SlayBlur:Destroy() end
if Lighting:FindFirstChild("Blur") then Lighting.Blur:Destroy() end

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
    Config = Config or {Title = "SYSTEM", Content = "Message Content", Duration = 6, Type = "Neutral"}
    
    local NotifColor = SlayLib.Theme.MainColor
    if Config.Type == "Success" then NotifColor = SlayLib.Theme.Success
    elseif Config.Type == "Error" then NotifColor = SlayLib.Theme.Error
    elseif Config.Type == "Warning" then NotifColor = SlayLib.Theme.Warning end

    -- Container Setup
    local NotifGui = Parent:FindFirstChild("SlayNotifFinal") or Create("ScreenGui", {Name = "SlayNotifFinal", Parent = Parent, DisplayOrder = 9999})
    local Holder = NotifGui:FindFirstChild("Holder") or Create("Frame", {
        Name = "Holder", Parent = NotifGui, BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, -40), Position = UDim2.new(1, -340, 0, 20)
    })
    if not Holder:FindFirstChild("UIListLayout") then
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", HorizontalAlignment = "Right", Padding = UDim.new(0, 10), SortOrder = "LayoutOrder"})
    end

    -- Main Frame
    local NotifFrame = Create("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = 0.1, GroupTransparency = 1, ClipsDescendants = true, Parent = Holder
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = NotifFrame})
    local Stroke = Create("UIStroke", {Color = NotifColor, Transparency = 0.5, Thickness = 2, Parent = NotifFrame})

    -- Text Area (เว้นระยะด้านล่างเพิ่มขึ้นเพื่อวางหลอดแบบ Floating)
    local TextArea = Create("Frame", {
        Size = UDim2.new(1, -45, 0, 0), Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1, AutomaticSize = "Y", Parent = NotifFrame
    })
    Create("UIListLayout", {Parent = TextArea, Padding = UDim.new(0, 4), SortOrder = "LayoutOrder"})
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 18), 
        PaddingBottom = UDim.new(0, 28), -- เพิ่มพื้นที่ด้านล่างให้หลอดลอยได้สวยๆ
        PaddingRight = UDim.new(0, 15), 
        Parent = TextArea
    })

    local TitleLabel = Create("TextLabel", {
        Text = Config.Title:upper(), Font = "GothamBold", TextSize = 14,
        TextColor3 = NotifColor, BackgroundTransparency = 1, TextXAlignment = "Left",
        Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, Parent = TextArea
    })

    local ContentLabel = Create("TextLabel", {
        Text = Config.Content, Font = "GothamMedium", TextSize = 12,
        TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1,
        TextXAlignment = "Left", TextWrapped = true, Size = UDim2.new(1, 0, 0, 14),
        AutomaticSize = "Y", LayoutOrder = 2, Parent = TextArea
    })

    -- [แก้จุดหลอดทะลุ] Progress Bar Container (ขยับให้ลอยขึ้นและกดยุบขอบ)
    local BarContainer = Create("Frame", {
        Name = "BarContainer",
        Size = UDim2.new(1, -24, 0, 4), -- สั้นลงกว่ากรอบหลักเพื่อไม่ให้ชนขอบ Stroke
        Position = UDim2.new(0, 12, 1, -12), -- ลอยขึ้นจากขอบล่าง 12 pixel
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ClipsDescendants = true, -- บังคับให้หลอดข้างในไม่ทะลุ
        Parent = NotifFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarContainer})

    local BarFill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new(1, 0, 1, 0), 
        BackgroundColor3 = NotifColor, 
        BorderSizePixel = 0,
        Parent = BarContainer
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarFill})

    -- Animation
    task.spawn(function()
        repeat task.wait() until TextArea.AbsoluteSize.Y > 30 
        local FinalHeight = TextArea.AbsoluteSize.Y
        
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, FinalHeight), GroupTransparency = 0}, 0.7, Enum.EasingStyle.Back)
        Tween(BarFill, {Size = UDim2.new(0, 0, 1, 0)}, Config.Duration, Enum.EasingStyle.Linear)
        
        task.wait(Config.Duration)
        
        local Out = Tween(NotifFrame, {GroupTransparency = 1, Position = UDim2.new(0, 60, 0, 0)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.5)
        
        Out.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

--// LOADING SEQUENCE (HIGH FIDELITY)
local function ExecuteFinalSovereign()
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local Debris = game:GetService("Debris")

    -- [1] SETUP (Force Fullscreen)
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "SLAY_SOVEREIGN_FIXED"
    Screen.IgnoreGuiInset = true
    Screen.DisplayOrder = 999999
    Screen.ScreenInsets = Enum.ScreenInsets.None
    Screen.Parent = game:GetService("CoreGui")

    local Blur = Instance.new("BlurEffect", Lighting)
    Blur.Size = 0

    local MainFrame = Instance.new("Frame", Screen)
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundTransparency = 1

    local Hub = Instance.new("Frame", MainFrame)
    Hub.AnchorPoint = Vector2.new(0.5, 0.5)
    Hub.Position = UDim2.new(0.5, 0, 0.5, 0)
    Hub.Size = UDim2.new(0, 400, 0, 400)
    Hub.BackgroundTransparency = 1

    local Logo = Instance.new("ImageLabel", Hub)
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
    Logo.Size = UDim2.new(0, 0, 0, 0)
    Logo.Image = SlayLib.Icons.Logofull
    Logo.BackgroundTransparency = 1
    Logo.ImageTransparency = 1

    -- --- 💥 [ฉากเปิด] 💥 ---
    task.spawn(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.7), {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(Blur, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {Size = 35}):Play()
        
        for i = 1, 3 do
            local sw = Instance.new("Frame", Hub)
            sw.AnchorPoint = Vector2.new(0.5, 0.5)
            sw.Position = UDim2.new(0.5, 0, 0.5, 0)
            sw.Size = UDim2.new(0, 0, 0, 0)
            sw.BackgroundColor3 = SlayLib.Theme.MainColor
            sw.BackgroundTransparency = 0.5
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
            
            -- แก้ไขจาก Exponential เป็น Quart เพื่อความเสถียรสูงสุด
            TweenService:Create(sw, TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 1000, 0, 1000),
                BackgroundTransparency = 1
            }):Play()
            Debris:AddItem(sw, 1.2)
            task.wait(0.18)
        end
        
        TweenService:Create(Logo, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 260, 0, 260),
            ImageTransparency = 0
        }):Play()
    end)

    -- [2] STATUS
    local Status = Instance.new("TextLabel", MainFrame)
    Status.AnchorPoint = Vector2.new(0.5, 0.5)
    Status.Position = UDim2.new(0.5, 0, 0.84, 0)
    Status.Size = UDim2.new(0, 500, 0, 20)
    Status.Font = Enum.Font.Code
    Status.TextColor3 = SlayLib.Theme.MainColor
    Status.TextSize = 14
    Status.BackgroundTransparency = 1
    Status.TextTransparency = 1
    Status.Text = "SYSTEM_READY"

    TweenService:Create(Status, TweenInfo.new(0.8), {TextTransparency = 0.2}):Play()
    task.wait(2.5)

    -- --- 🌪️ [ฉากปิด: THE VOID COMPRESSION] 🌪️ ---
    -- ใช้ระบบ Pcall เพื่อป้องกันสคริปต์ค้างถ้าเกิด Error
    pcall(function()
        local FinalInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        
        -- บีบโลโก้และพื้นหลังสวนทางกัน
        TweenService:Create(Logo, FinalInfo, {
            Size = UDim2.new(0, 2, 0, 2000),
            ImageTransparency = 1
        }):Play()

        local FinalCollapse = TweenService:Create(MainFrame, FinalInfo, {
            Size = UDim2.new(1.5, 0, 0, 0),
            Position = UDim2.new(-0.25, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        
        FinalCollapse:Play()
        TweenService:Create(Blur, TweenInfo.new(0.6), {Size = 0}):Play()
        
        FinalCollapse.Completed:Connect(function()
            Screen:Destroy()
            if Blur then Blur:Destroy() end
        end)
    end)

    -- [3] ABSOLUTE FAILSAFE (ตัวตัดไฟ)
    -- ถ้าผ่านไป 6 วินาทีแล้วหน้าจอยังไม่หาย ให้บังคับลบทิ้งทันทีไม่ว่าจะเกิดอะไรขึ้น
    task.delay(6, function()
        if Screen and Screen.Parent then Screen:Destroy() end
        if Blur and Blur.Parent then Blur:Destroy() end
    end)
end

--// MAIN WINDOW CONSTRUCTOR
function SlayLib:CreateWindow(Config)
Config = Config or {Name = "SlayLib Ultimate"}

-- Force Loading  
ExecuteUltimateLoadingSequence()  

local Window = {  
    Enabled = true,  
    Toggled = true,  
    Tabs = {},  
    CurrentTab = nil,  
    Minimized = false  
}  

local CoreGuiFrame = Create("ScreenGui", {Name = "SlayLib_X_Engine", Parent = Parent, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})  

-- 1. FLOATING TOGGLE BOX (Square Design & Draggable)
local FloatingToggle = Create("Frame", {  
    Name = "SlayFloatingToggle",
    Size = UDim2.new(0, 50, 0, 50), 
    Position = UDim2.new(0.05, 0, 0.2, 0),  
    BackgroundColor3 = Color3.fromRGB(20, 20, 20), -- พื้นหลังสีดำออกเทา
    Parent = CoreGuiFrame,  
    ZIndex = 50  
})  

-- ปรับขอบสี่เหลี่ยมให้มนเล็กน้อย (8px) เพื่อความสวยงามแบบโปร
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = FloatingToggle})  

-- ขอบสีฟ้าๆม่วงๆ (ใช้ MainColor จาก Theme)
local ToggleStroke = Create("UIStroke", {
    Color = SlayLib.Theme.MainColor, 
    Thickness = 2, 
    Transparency = 0.5, 
    Parent = FloatingToggle
})  

-- โลโก้แบบย่อ (SX) อยู่ตรงกลางสี่เหลี่ยม
local ToggleIcon = Create("ImageLabel", {  
    Size = UDim2.new(0, 42, 0, 42), 
    Position = UDim2.new(0.5, -21, 0.5, -21),  
    Image = SlayLib.Icons.Logo, 
    ImageColor3 = Color3.new(1, 1, 1), -- แสดงสีจริงของโลโก้
    BackgroundTransparency = 1, 
    Parent = FloatingToggle  
})  

-- ปุ่มสำหรับกด
local ToggleButton = Create("TextButton", {
    Size = UDim2.new(1, 0, 1, 0), 
    BackgroundTransparency = 1, 
    Text = "", 
    Parent = FloatingToggle
})

-- ทำให้ลากได้ (Draggable)
RegisterDrag(FloatingToggle, FloatingToggle)

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
    Props = Props or {
        Name = "Dropdown", 
        Options = {"Option 1", "Option 2"}, 
        Flag = "Drop_1", 
        Callback = function() end,
        Multi = false,
        Limit = nil -- ใส่ตัวเลขเพื่อจำกัด หรือไม่ต้องใส่เลยเพื่อ Unlimited
    }
    
    local IsOpen = false
    -- ถ้า Multi เป็น true และไม่มี Limit จะตั้งเป็น math.huge (ไม่จำกัด) อัตโนมัติ
    local SelectionLimit = Props.Multi and (Props.Limit or math.huge) or 1
    local Selected = Props.Multi and {} or nil 
    SlayLib.Flags[Props.Flag] = Selected

    -- Container Setup
    local DContainer = Create("Frame", {  
        Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = SlayLib.Theme.Element,  
        ClipsDescendants = true, Parent = Page  
    })  
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = DContainer})  
    local DStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1.5, Parent = DContainer})

    local MainBtn = Create("TextButton", {  
        Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Text = "", Parent = DContainer  
    })  

    local DLbl = Create("TextLabel", {  
        Text = "  " .. Props.Name .. ": None", 
        Size = UDim2.new(1, -50, 0, 52), Position = UDim2.new(0, 15, 0, 0), 
        Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.TextSecondary, 
        TextXAlignment = "Left", BackgroundTransparency = 1, Parent = MainBtn  
    })  

    local Chevron = Create("ImageLabel", {  
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -30, 0.5, -9),  
        Image = SlayLib.Icons.Chevron, BackgroundTransparency = 1, ImageColor3 = SlayLib.Theme.TextSecondary, Parent = MainBtn  
    })  

    -- Search System
    local SearchArea = Create("Frame", {
        Size = UDim2.new(1, -24, 0, 35), Position = UDim2.new(0, 12, 0, 55),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 0.5, Visible = false, Parent = DContainer
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SearchArea})
    
    local SearchInput = Create("TextBox", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "", PlaceholderText = "Search...",
        TextColor3 = SlayLib.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left", Parent = SearchArea
    })

    -- List System
    local List = Create("ScrollingFrame", {  
        Size = UDim2.new(1, -12, 0, 160), Position = UDim2.new(0, 6, 0, 100),  
        BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = SlayLib.Theme.MainColor,  
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", Visible = false, Parent = DContainer  
    })  
    Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 5)})
    local ListLayout = Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 5), SortOrder = "Name"})  

    -- [Smart Logic] ฟังก์ชันอัปเดตข้อความหน้า Dropdown
    local function UpdateDisplay()
        if Props.Multi then
            if #Selected == 0 then
                DLbl.Text = "  " .. Props.Name .. ": None"
                DLbl.TextColor3 = SlayLib.Theme.TextSecondary
            elseif #Selected > 3 then
                -- ถ้ายาวเกิน 3 อัน ให้ย่อเป็นจำนวนแทน
                DLbl.Text = "  " .. Props.Name .. ": Selected (" .. #Selected .. ")"
                DLbl.TextColor3 = SlayLib.Theme.MainColor
            else
                DLbl.Text = "  " .. Props.Name .. ": " .. table.concat(Selected, ", ")
                DLbl.TextColor3 = SlayLib.Theme.MainColor
            end
        else
            if not Selected then
                DLbl.Text = "  " .. Props.Name .. ": None"
                DLbl.TextColor3 = SlayLib.Theme.TextSecondary
            else
                DLbl.Text = "  " .. Props.Name .. ": " .. tostring(Selected)
                DLbl.TextColor3 = SlayLib.Theme.MainColor
            end
        end
    end

    local function RefreshOptions()  
        for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end  
        for _, opt in pairs(Props.Options) do  
            local IsItemSelected = Props.Multi and table.find(Selected, opt) or Selected == opt
            
            local OBtn = Create("TextButton", {  
                Name = tostring(opt), Size = UDim2.new(1, 0, 0, 35), 
                BackgroundColor3 = IsItemSelected and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30,30,30),  
                Text = "   " .. tostring(opt), Font = "Gotham", TextSize = 13,  
                TextColor3 = IsItemSelected and SlayLib.Theme.MainColor or SlayLib.Theme.TextSecondary, 
                TextXAlignment = "Left", Parent = List  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = OBtn})
            
            local OStroke = Create("UIStroke", {
                Color = SlayLib.Theme.MainColor, Thickness = 1.5, 
                Transparency = IsItemSelected and 0 or 1, Parent = OBtn
            })

            OBtn.MouseButton1Click:Connect(function()  
                if Props.Multi then
                    local index = table.find(Selected, opt)
                    if index then
                        table.remove(Selected, index)
                    else
                        if #Selected < SelectionLimit then
                            table.insert(Selected, opt)
                        else
                            SlayLib:Notify({Title = "Limit Reached", Content = "You can select up to "..SelectionLimit.." items.", Type = "Warning", Duration = 3})
                            return
                        end
                    end
                else
                    Selected = opt
                    IsOpen = false
                    Tween(DContainer, {Size = UDim2.new(1, 0, 0, 52)}, 0.4)  
                    Tween(Chevron, {Rotation = 0}, 0.4)  
                    task.delay(0.4, function() if not IsOpen then List.Visible = false SearchArea.Visible = false end end)
                end
                
                SlayLib.Flags[Props.Flag] = Selected
                UpdateDisplay()
                RefreshOptions() -- อัปเดตสีปุ่ม
                task.spawn(Props.Callback, Selected)  
            end)  
        end  
    end  

    -- Search Filter
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local InputText = SearchInput.Text:lower()
        for _, item in pairs(List:GetChildren()) do
            if item:IsA("TextButton") then
                item.Visible = (InputText == "" or item.Name:lower():find(InputText))
            end
        end
    end)

    RefreshOptions()  

    -- Open/Close Logic
    MainBtn.MouseButton1Click:Connect(function()  
        IsOpen = not IsOpen  
        if IsOpen then
            List.Visible = true
            SearchArea.Visible = true
            SearchInput.Text = "" 
            Tween(DContainer, {Size = UDim2.new(1, 0, 0, 275)}, 0.4, Enum.EasingStyle.Quart)  
            Tween(Chevron, {Rotation = 180}, 0.4)  
            Tween(DStroke, {Color = SlayLib.Theme.MainColor}, 0.3)
        else
            Tween(DContainer, {Size = UDim2.new(1, 0, 0, 52)}, 0.4)  
            Tween(Chevron, {Rotation = 0}, 0.4)  
            Tween(DStroke, {Color = SlayLib.Theme.Stroke}, 0.3)
            task.delay(0.4, function() if not IsOpen then List.Visible = false SearchArea.Visible = false end end)
        end
    end)  
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