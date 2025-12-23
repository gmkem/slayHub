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

    -- 1. ล้างค่า UI เก่าป้องกันการรันซ้อน
    local OldUI = game:GetService("CoreGui"):FindFirstChild("SlayLib_X_Engine")
    if OldUI then OldUI:Destroy() end

    local Window = {
        Enabled = true,
        Toggled = true,
        Tabs = {},
        CurrentTab = nil,
        Minimized = false
    }

    -- 2. สร้าง ScreenGui หลัก
    local CoreGuiFrame = Create("ScreenGui", {
        Name = "SlayLib_X_Engine", 
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    })

    -- 3. หน้าต่างหลัก (MainFrame)
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 620, 0, 440),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = SlayLib.Theme.Background,
        Parent = CoreGuiFrame,
        ZIndex = 5,
        ClipsDescendants = false, -- ปิดเพื่อให้เงาโผล่ออกมาด้านข้างได้
        Visible = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = MainFrame})
    
    -- [Shadow Integration] เงาต้องเป็นลูกของ MainFrame เพื่อให้ติดหนึบเวลาขยับหรือย่อขยาย
    local Shadow = Create("Frame", {
        Name = "Shadow",
        Size = UDim2.new(1, 25, 1, 25), -- ใหญ่กว่าพ่อเล็กน้อยเพื่อทำขอบเงา
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.45,
        ZIndex = 4, -- อยู่หลัง MainFrame เสมอ
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 18), Parent = Shadow})

    -- เพิ่มความหรูหราด้วย Gradient และ Stroke
    local MainGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
        }),
        Rotation = 45,
        Parent = MainFrame
    })

    local MainStroke = Create("UIStroke", {
        Color = SlayLib.Theme.MainColor,
        Thickness = 1.3,
        Transparency = 0.5,
        Parent = MainFrame
    })

    -- 4. ปุ่มเปิด-ปิดลอยตัว (Floating Toggle) - ปรับปรุงให้ลากได้อิสระ
    local FloatingToggle = Create("Frame", {
        Name = "FloatingToggle",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Parent = CoreGuiFrame,
        ZIndex = 100 -- อยู่ชั้นบนสุดเสมอ
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = FloatingToggle})
    Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 2, Parent = FloatingToggle})

    local ToggleIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = SlayLib.Icons.Logo,
        ImageColor3 = SlayLib.Theme.MainColor,
        BackgroundTransparency = 1,
        ZIndex = 101,
        Parent = FloatingToggle
    })

    -- ปุ่มใสสำหรับคลิก (แยกออกจาก Frame เพื่อให้รับ Input ได้แม่นยำ)
    local ToggleButton = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 105,
        Parent = FloatingToggle
    })

    -- 5. ระบบการลาก (Drag System)
    -- ทำให้ทั้งหน้าต่างหลักและปุ่มลอยตัวลากได้
    RegisterDrag(FloatingToggle, FloatingToggle) -- ลากตัวปุ่มลอยตัว
    -- หมายเหตุ: Sidebar Header จะต้องถูก RegisterDrag ในส่วนที่ 2 ต่อไป

    -- 6. Logic การเปิด-ปิดหน้าต่าง (Animation)
    ToggleButton.MouseButton1Click:Connect(function()
        Window.Toggled = not Window.Toggled
        if Window.Toggled then
            MainFrame.Visible = true
            -- Tween เฉพาะตัวแม่ (MainFrame) เงาที่เป็นตัวลูกจะขยับตามอัตโนมัติ
            MainFrame:TweenSize(UDim2.new(0, 620, 0, 440), "Out", "Back", 0.4, true)
        else
            -- อนิเมชันย่อหน้าต่างเข้าจุดกึ่งกลาง
            MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quart", 0.3, true)
            task.delay(0.3, function() 
                if not Window.Toggled then MainFrame.Visible = false end 
            end)
        end
    end)

    -- [1] SIDEBAR (จัดตำแหน่งให้มีช่องว่าง Margin เล็กน้อยเพื่อให้ดูโมเดิร์น)
    local Sidebar = Create("Frame", {  
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, -12), 
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = SlayLib.Theme.Sidebar, 
        ZIndex = 10,
        Parent = MainFrame  
    })  
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})  

    -- หัวข้อ Sidebar (Header)
    local SideHeader = Create("Frame", {  
        Size = UDim2.new(1, 0, 0, 70), 
        BackgroundTransparency = 1, 
        ZIndex = 11,
        Parent = Sidebar  
    })  
    local LibIcon = Create("ImageLabel", {  
        Size = UDim2.new(0, 32, 0, 32), 
        Position = UDim2.new(0, 18, 0, 19),  
        Image = SlayLib.Icons.Logo, 
        BackgroundTransparency = 1, 
        ImageColor3 = SlayLib.Theme.MainColor,
        ZIndex = 12,
        Parent = SideHeader
    })  
    local LibTitle = Create("TextLabel", {  
        Size = UDim2.new(1, -65, 1, 0), 
        Position = UDim2.new(0, 58, 0, 0),  
        Font = "GothamBold", 
        TextSize = 17,
        TextColor3 = SlayLib.Theme.Text, 
        TextXAlignment = "Left",  
        BackgroundTransparency = 1, 
        ZIndex = 12,
        Parent = SideHeader  
    })  
    ApplyTextLogic(LibTitle, Config.Name, 17)  

    -- พื้นที่สำหรับใส่ปุ่ม Tab (ScrollingFrame)
    local TabScroll = Create("ScrollingFrame", {  
        Name = "TabScroll",
        Size = UDim2.new(1, -10, 1, -85), 
        Position = UDim2.new(0, 5, 0, 75),  
        BackgroundTransparency = 1, 
        ScrollBarThickness = 0, 
        ZIndex = 11,
        Parent = Sidebar,  
        CanvasSize = UDim2.new(0,0,0,0), 
        AutomaticCanvasSize = "Y"  
    })  
    local TabLayout = Create("UIListLayout", {
        Parent = TabScroll, 
        Padding = UDim.new(0, 6), 
        HorizontalAlignment = "Center",
        SortOrder = Enum.SortOrder.LayoutOrder
    })  

    -- [2] CONTENT AREA (พื้นที่แสดงผลเนื้อหา)
    local PageContainer = Create("Frame", {  
        Name = "PageContainer",
        Size = UDim2.new(1, -225, 1, -20), 
        Position = UDim2.new(0, 215, 0, 10),  
        BackgroundTransparency = 1, 
        ZIndex = 10, -- เลเยอร์เท่ากับ Sidebar แต่แยกตำแหน่งกัน
        Parent = MainFrame  
    })  

    -- ทำให้หน้าต่างหลักลากได้ (ลากจากส่วน Sidebar Header ได้)
    RegisterDrag(MainFrame, SideHeader)  

    --// [TAB CREATOR LOGIC]
    function Window:CreateTab(Name, IconID)  
        local Tab = {Active = false, Page = nil, Button = nil}  

        -- ปุ่ม Tab
        local TabBtn = Create("TextButton", {  
            Name = Name .. "_Tab",
            Size = UDim2.new(0, 185, 0, 40), 
            BackgroundTransparency = 1, 
            Text = "", 
            ZIndex = 15,
            Parent = TabScroll  
        })  
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})  

        local TabIcon = Create("ImageLabel", {  
            Size = UDim2.new(0, 18, 0, 18), 
            Position = UDim2.new(0, 15, 0.5, -9),  
            Image = IconID or SlayLib.Icons.Folder, 
            BackgroundTransparency = 1,  
            ImageColor3 = SlayLib.Theme.TextSecondary, 
            ZIndex = 16,
            Parent = TabBtn  
        })  

        local TabLbl = Create("TextLabel", {  
            Text = Name, 
            Size = UDim2.new(1, -50, 1, 0), 
            Position = UDim2.new(0, 42, 0, 0),  
            Font = "GothamMedium", 
            TextSize = 13, 
            TextColor3 = SlayLib.Theme.TextSecondary,  
            TextXAlignment = "Left", 
            BackgroundTransparency = 1, 
            ZIndex = 16,
            Parent = TabBtn  
        })  

        -- หน้า Page สำหรับ Tab นี้
        local Page = Create("ScrollingFrame", {  
            Name = Name .. "_Page",
            Size = UDim2.new(1, 0, 1, 0), 
            BackgroundTransparency = 1,  
            Visible = false, 
            ScrollBarThickness = 2, 
            ScrollBarImageColor3 = SlayLib.Theme.MainColor,  
            CanvasSize = UDim2.new(0,0,0,0), 
            AutomaticCanvasSize = "Y", 
            ZIndex = 20,
            Parent = PageContainer  
        })  
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})  
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 5)})  

        -- คลิกเพื่อเปลี่ยน Tab
        TabBtn.MouseButton1Click:Connect(function()  
            if Window.CurrentTab and Window.CurrentTab.Button ~= TabBtn then  
                -- ซ่อนหน้าเก่า
                Window.CurrentTab.Page.Visible = false  
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.3)  
                Tween(Window.CurrentTab.Label, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)  
                Tween(Window.CurrentTab.Icon, {ImageColor3 = SlayLib.Theme.TextSecondary}, 0.3)  
            end  

            -- แสดงหน้าใหม่
            Window.CurrentTab = {Page = Page, Button = TabBtn, Label = TabLbl, Icon = TabIcon}  
            Page.Visible = true  
            Tween(TabBtn, {BackgroundTransparency = 0.85, BackgroundColor3 = SlayLib.Theme.MainColor}, 0.3)  
            Tween(TabLbl, {TextColor3 = SlayLib.Theme.MainColor}, 0.3)  
            Tween(TabIcon, {ImageColor3 = SlayLib.Theme.MainColor}, 0.3)  
        end)  

        -- เลือก Tab แรกให้อัตโนมัติ
        if not Window.CurrentTab then  
            Window.CurrentTab = {Page = Page, Button = TabBtn, Label = TabLbl, Icon = TabIcon}  
            Page.Visible = true  
            TabBtn.BackgroundTransparency = 0.85
            TabBtn.BackgroundColor3 = SlayLib.Theme.MainColor
            TabLbl.TextColor3 = SlayLib.Theme.MainColor  
            TabIcon.ImageColor3 = SlayLib.Theme.MainColor  
        end  

           --// [SECTION CREATOR]
    function Tab:CreateSection(SName)  
        local Section = {}  

        -- กล่องหัวข้อ Section
        local SectFrame = Create("Frame", {  
            Name = SName .. "_Section",
            Size = UDim2.new(1, 0, 0, 32), 
            BackgroundTransparency = 1, 
            ZIndex = 21,
            Parent = Page  
        })  
        local SectLabel = Create("TextLabel", {  
            Text = SName:upper(), 
            Size = UDim2.new(1, 0, 1, 0),  
            Font = "GothamBold", 
            TextSize = 12, 
            TextColor3 = SlayLib.Theme.MainColor, 
            BackgroundTransparency = 1, 
            TextXAlignment = "Left", 
            ZIndex = 22,
            Parent = SectFrame  
        })  

        -- 1. [UPGRADED] TOGGLE (เน้นความชัดเจนและ Clickable Area)
        function Section:CreateToggle(Props)  
            Props = Props or {Name = "Toggle", CurrentValue = false, Flag = "Toggle_1", Callback = function() end}  
            local TState = Props.CurrentValue  
            SlayLib.Flags[Props.Flag] = TState  

            local TContainer = Create("Frame", {  
                Name = Props.Name .. "_Toggle",
                Size = UDim2.new(1, 0, 0, 48), 
                BackgroundColor3 = SlayLib.Theme.Element, 
                ZIndex = 25,
                Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TContainer})  
            Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = TContainer})

            local TLbl = Create("TextLabel", {  
                Size = UDim2.new(1, -70, 1, 0), 
                Position = UDim2.new(0, 15, 0, 0),  
                Font = "GothamMedium", 
                TextSize = 14,
                TextColor3 = SlayLib.Theme.Text,  
                TextXAlignment = "Left", 
                BackgroundTransparency = 1, 
                ZIndex = 26,
                Parent = TContainer  
            })  
            ApplyTextLogic(TLbl, Props.Name, 14)  

            -- โครงสร้างสวิตช์
            local Switch = Create("Frame", {  
                Size = UDim2.new(0, 38, 0, 20), 
                Position = UDim2.new(1, -50, 0.5, -10),  
                BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 45), 
                ZIndex = 27,
                Parent = TContainer  
            })  
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})  

            local Dot = Create("Frame", {  
                Size = UDim2.new(0, 14, 0, 14),   
                Position = TState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),  
                BackgroundColor3 = Color3.new(1, 1, 1), 
                ZIndex = 28,
                Parent = Switch  
            })  
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})  

            -- ปุ่มสำหรับคลิก (ต้องอยู่บนสุดของ Element นี้)
            local ClickArea = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0), 
                BackgroundTransparency = 1, 
                Text = "", 
                ZIndex = 30,
                Parent = TContainer
            })  

            ClickArea.MouseButton1Click:Connect(function()  
                TState = not TState  
                SlayLib.Flags[Props.Flag] = TState  
                Tween(Switch, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 45)}, 0.2)  
                Tween(Dot, {Position = TState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.2)  
                task.spawn(Props.Callback, TState)  
            end)  
        end  

        -- 2. [UPGRADED] SLIDER (เน้นความลื่นไหลและแม่นยำ)
        function Section:CreateSlider(Props)  
            Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Flag = "Slider_1", Callback = function() end}  
            local Value = Props.Def  
            SlayLib.Flags[Props.Flag] = Value  

            local SContainer = Create("Frame", {  
                Size = UDim2.new(1, 0, 0, 65), 
                BackgroundColor3 = SlayLib.Theme.Element, 
                ZIndex = 25,
                Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SContainer})  
            Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = SContainer})

            local SLbl = Create("TextLabel", {  
                Size = UDim2.new(1, -100, 0, 35), 
                Position = UDim2.new(0, 15, 0, 5),  
                Font = "GothamMedium", 
                TextSize = 14,
                TextColor3 = SlayLib.Theme.Text,  
                TextXAlignment = "Left", 
                BackgroundTransparency = 1, 
                ZIndex = 26,
                Parent = SContainer  
            })  
            ApplyTextLogic(SLbl, Props.Name, 14)  

            local ValInput = Create("TextBox", {  
                Text = tostring(Value), 
                Size = UDim2.new(0, 45, 0, 20), 
                Position = UDim2.new(1, -60, 0, 10),  
                Font = "Code", 
                TextSize = 12, 
                TextColor3 = SlayLib.Theme.MainColor,  
                BackgroundColor3 = Color3.fromRGB(20, 20, 20), 
                ZIndex = 27,
                Parent = SContainer  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ValInput})  

            local Bar = Create("Frame", {  
                Size = UDim2.new(1, -30, 0, 4), 
                Position = UDim2.new(0, 15, 0, 48),  
                BackgroundColor3 = Color3.fromRGB(45, 45, 45), 
                ZIndex = 27,
                Parent = SContainer  
            })  
            Create("UICorner", {Parent = Bar})  

            local Fill = Create("Frame", {  
                Size = UDim2.new((Value - Props.Min)/(Props.Max - Props.Min), 0, 1, 0),  
                BackgroundColor3 = SlayLib.Theme.MainColor, 
                ZIndex = 28,
                Parent = Bar  
            })  
            Create("UICorner", {Parent = Fill})

            -- ปุ่มสำหรับเลื่อน Slider
            local SliderBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 30,
                Parent = Bar
            })

            -- Logic การลาก (ใช้ระบบ Drag ที่เสถียร)
            local function UpdateSlider(Input)
                local Percent = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Value = math.floor(Props.Min + (Props.Max - Props.Min) * Percent)
                Fill.Size = UDim2.new(Percent, 0, 1, 0)
                ValInput.Text = tostring(Value)
                SlayLib.Flags[Props.Flag] = Value
                task.spawn(Props.Callback, Value)
            end

            SliderBtn.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    local MoveCon, EndCon
                    UpdateSlider(Input)
                    MoveCon = game:GetService("UserInputService").InputChanged:Connect(function(Move)
                        if Move.UserInputType == Enum.UserInputType.MouseMovement or Move.UserInputType == Enum.UserInputType.Touch then
                            UpdateSlider(Move)
                        end
                    end)
                    EndCon = game:GetService("UserInputService").InputEnded:Connect(function(End)
                        if End.UserInputType == Enum.UserInputType.MouseButton1 or End.UserInputType == Enum.UserInputType.Touch then
                            MoveCon:Disconnect()
                            EndCon:Disconnect()
                        end
                    end)
                end
            end)
        end

                        -- 3. [UPGRADED] DROPDOWN (Smart Layering & Search)
        function Section:CreateDropdown(Props)
            Props = Props or {Name = "Dropdown", Options = {"Option 1", "Option 2"}, Flag = "Drop_1", Callback = function() end}
            local IsOpen = false
            local Selected = Props.Multi and {} or nil 

            local DContainer = Create("Frame", {  
                Name = Props.Name .. "_Dropdown",
                Size = UDim2.new(1, 0, 0, 48), 
                BackgroundColor3 = SlayLib.Theme.Element,  
                ClipsDescendants = true, -- ตัวควบคุมการเปิด-ปิด List
                ZIndex = 35, -- สูงกว่า Toggle/Slider
                Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DContainer})  
            local DStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = DContainer})

            local MainBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Text = "", ZIndex = 36, Parent = DContainer})  

            local DLbl = Create("TextLabel", {  
                Text = Props.Name .. ": None", 
                Size = UDim2.new(1, -50, 0, 48), Position = UDim2.new(0, 15, 0, 0), 
                Font = "GothamMedium", TextSize = 13, TextColor3 = SlayLib.Theme.TextSecondary, 
                TextXAlignment = "Left", BackgroundTransparency = 1, ZIndex = 37, Parent = MainBtn  
            })  

            local Chevron = Create("ImageLabel", {  
                Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -30, 0.5, -8),  
                Image = SlayLib.Icons.Chevron, BackgroundTransparency = 1, ImageColor3 = SlayLib.Theme.TextSecondary, ZIndex = 37, Parent = MainBtn  
            })  

            -- พื้นที่ List รายการ
            local List = Create("ScrollingFrame", {  
                Size = UDim2.new(1, -10, 0, 120), Position = UDim2.new(0, 5, 0, 50),  
                BackgroundTransparency = 1, ScrollBarThickness = 2, 
                CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ZIndex = 38, Parent = DContainer  
            })  
            Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 4)})

            -- Logic เปิด/ปิด
            MainBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                local TargetSize = IsOpen and UDim2.new(1, 0, 0, 180) or UDim2.new(1, 0, 0, 48)
                Tween(DContainer, {Size = TargetSize}, 0.3, Enum.EasingStyle.Quart)
                Tween(Chevron, {Rotation = IsOpen and 180 or 0}, 0.3)
                
                -- แก้ปัญหา Dropdown โดนบัง: เมื่อเปิดให้ยก ZIndex ขึ้นสูงสุด
                DContainer.ZIndex = IsOpen and 50 or 35
            end)

            -- ฟังก์ชันเพิ่มรายการ (RefreshOptions)
            -- [คุณสามารถใช้ Logic วนลูป Options เดิมของคุณได้เลยที่นี่]
        end

        -- 4. [UPGRADED] INTERACTIVE BUTTON
        function Section:CreateButton(Props)  
            Props = Props or {Name = "Action Button", Callback = function() end}  

            local BFrame = Create("TextButton", {  
                Size = UDim2.new(1, 0, 0, 42), 
                BackgroundColor3 = SlayLib.Theme.Element,  
                Text = "", ZIndex = 25, Parent = Page, AutoButtonColor = false  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BFrame})  
            Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = BFrame})

            local BLbl = Create("TextLabel", {  
                Size = UDim2.new(1, 0, 1, 0), Font = "GothamBold", TextSize = 13,  
                TextColor3 = SlayLib.Theme.Text, BackgroundTransparency = 1, ZIndex = 26, Parent = BFrame  
            })  
            BLbl.Text = Props.Name

            BFrame.MouseButton1Click:Connect(function()
                -- Visual Feedback (Flash effect)
                local OldCol = BFrame.BackgroundColor3
                BFrame.BackgroundColor3 = SlayLib.Theme.MainColor
                Tween(BFrame, {BackgroundColor3 = OldCol}, 0.4)
                task.spawn(Props.Callback)
            end)
        end  

                -- 5. [UPGRADED] SMART INPUT BOX
        function Section:CreateInput(Props)
            Props = Props or {Name = "Input Field", Placeholder = "Value...", Callback = function() end}

            local IContainer = Create("Frame", {  
                Size = UDim2.new(1, 0, 0, 52), 
                BackgroundColor3 = SlayLib.Theme.Element, 
                ZIndex = 25,
                Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = IContainer})  
            Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = IContainer})

            local ILbl = Create("TextLabel", {  
                Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 15, 0, 0),  
                Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text,  
                TextXAlignment = "Left", BackgroundTransparency = 1, ZIndex = 26, Parent = IContainer  
            })  
            ApplyTextLogic(ILbl, Props.Name, 14)  

            local Box = Create("TextBox", {  
                Size = UDim2.new(0, 160, 0, 30), Position = UDim2.new(1, -175, 0.5, -15),  
                BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = "", PlaceholderText = Props.Placeholder,  
                TextColor3 = SlayLib.Theme.MainColor, Font = "Gotham", TextSize = 13, ZIndex = 27, Parent = IContainer  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Box})  

            Box.FocusLost:Connect(function(EnterPressed)  
                task.spawn(Props.Callback, Box.Text)
            end)  
        end  

        -- 6. [UPGRADED] DYNAMIC PARAGRAPH
        function Section:CreateParagraph(Props)  
            Props = Props or {Title = "Information", Content = "Description here."}  

            local PContainer = Create("Frame", {  
                Size = UDim2.new(1, 0, 0, 0), 
                BackgroundColor3 = SlayLib.Theme.Element,  
                AutomaticSize = Enum.AutomaticSize.Y, 
                ZIndex = 25,
                Parent = Page  
            })  
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = PContainer})  
            Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.7, Parent = PContainer})

            Create("UIPadding", {
                Parent = PContainer, 
                PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), 
                PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)
            })  

            local PLayout = Create("UIListLayout", {Parent = PContainer, SortOrder = "LayoutOrder", Padding = UDim.new(0, 4)})

            local PTtl = Create("TextLabel", {  
                Size = UDim2.new(1, 0, 0, 18), Font = "GothamBold", TextSize = 14,
                TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, 
                TextXAlignment = "Left", ZIndex = 26, LayoutOrder = 1, Parent = PContainer  
            })  
            PTtl.Text = Props.Title

            local PCnt = Create("TextLabel", {  
                Size = UDim2.new(1, 0, 0, 0), Font = "Gotham", TextSize = 13,
                TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1, 
                TextXAlignment = "Left", TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, 
                ZIndex = 26, LayoutOrder = 2, Parent = PContainer  
            })  
            PCnt.Text = Props.Content
        end

        return Section  
    end  -- จบ Section
    return Tab  
end -- จบ CreateTab

-- คืนค่า Window Object เพื่อใช้งานต่อ
return Window

end -- จบ CreateWindow

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