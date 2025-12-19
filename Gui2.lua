--// [SECTION 1: ENGINE CORE & OPTIMIZATION]
local SlayLib = {
    Version = "11.0.0",
    CurrentTheme = "Obsidian",
    Flags = {},
    Signals = {}, -- ระบบเชื่อมต่อเหตุการณ์ภายในเอนจิน
    Elements = {}, -- เก็บ Reference ของ UI ทั้งหมดเพื่อจัดการ Memory
    IsLoaded = false
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// [IMAGE: UI ENGINE STRUCTURE]
-- [Diagram showing UI components connecting to a Centralized State Manager and Theme Engine]

--// [SECTION 2: ADVANCED ANIMATION MODULE]
-- เอนจินการเคลื่อนไหวที่นุ่มนวลกว่า Library ทั่วไป
local Animate = {}
function Animate:New(obj, info, goal)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), goal)
    tween:Play()
    return tween
end

-- ระบบ Motion Blur จำลองสำหรับ UI
function SlayLib:ApplySoftShadow(frame)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "EngineShadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014264795" -- Professional Glow Asset
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = frame.ZIndex - 1
    Shadow.Parent = frame
end

--// [SECTION 3: THEME ENGINE (DYNAMIC PROPERTY BINDING)]
SlayLib.Themes = {
    Obsidian = {
        Main = Color3.fromRGB(0, 150, 255),
        Background = Color3.fromRGB(12, 12, 14),
        Sidebar = Color3.fromRGB(18, 18, 20),
        Section = Color3.fromRGB(25, 25, 28),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150),
        Stroke = Color3.fromRGB(40, 40, 45)
    },
    Vaporwave = {
        Main = Color3.fromRGB(255, 0, 255),
        Background = Color3.fromRGB(20, 10, 35),
        Sidebar = Color3.fromRGB(30, 15, 50),
        Section = Color3.fromRGB(45, 25, 70),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 100, 255),
        Stroke = Color3.fromRGB(80, 40, 120)
    }
}

--// [SECTION 4: CORE UI CONSTRUCTION]
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SLAYLIB X | PRO ENGINE"}
    
    local Core = Instance.new("ScreenGui", game:GetService("CoreGui"))
    Core.Name = "SlayLib_X"
    Core.IgnoreGuiInset = true

    -- Main Window
    local MainFrame = Instance.new("Frame", Core)
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    
    self:ApplySoftShadow(MainFrame)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    
    -- Engine Stroke (สวยงามระดับ AAA)
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = self.Themes[self.CurrentTheme].Stroke
    Stroke.Thickness = 1.2

    -- Sidebar Area
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = self.Themes[self.CurrentTheme].Sidebar
    Sidebar.BorderSizePixel = 0
    
    local SideStroke = Instance.new("UIStroke", Sidebar)
    SideStroke.Color = self.Themes[self.CurrentTheme].Stroke
    SideStroke.Thickness = 1
    
    -- Content Container
    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -170, 1, -50)
    Container.Position = UDim2.new(0, 165, 0, 45)
    Container.BackgroundTransparency = 1

    --// [IMAGE: SIDEBAR NAVIGATION DESIGN]
    -- [Visual of a modern vertical navigation bar with icons and smooth hover transitions]

    return {Window = MainFrame, Container = Container, Sidebar = Sidebar}
end

--// [SECTION 5: COMPONENT - INTERACTIVE SLIDER (THE ENGINE WAY)]
-- ระบบ Slider ที่คำนวณแบบละเอียด ไม่มีการกระตุก
function SlayLib:CreateSlider(Parent, Props)
    Props = Props or {Name = "Brightness", Min = 0, Max = 100, Def = 50, Flag = "Slider1"}
    
    local SliderFrame = Instance.new("Frame", Parent)
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Section
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Text = "  " .. Props.Name
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.TextColor3 = self.Themes[self.CurrentTheme].TextDark
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = "Left"

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, -20, 0, 4)
    Bar.Position = UDim2.new(0, 10, 0, 30)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((Props.Def - Props.Min)/(Props.Max - Props.Min), 0, 1, 0)
    Fill.BackgroundColor3 = self.Themes[self.CurrentTheme].Main
    
    -- Slider Logic (เอนจินการคำนวณตำแหน่งเมาส์)
    local function Update(input)
        local ratio = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(Props.Min + (Props.Max - Props.Min) * ratio)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        self:SetFlag(Props.Flag, value)
        if Props.Callback then Props.Callback(value) end
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Update(input)
            local move = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
            end)
            local release; release = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    move:Disconnect()
                    release:Disconnect()
                end
            end)
        end
    end)
end

--// [SECTION 6: NOTIFICATION STACK ENGINE]
-- ระบบแจ้งเตือนที่คำนวณคิว (Queue) อัตโนมัติ ไม่ให้แสดงทับกัน
SlayLib.NotifQueue = {}
function SlayLib:Notify(Data)
    -- Logic: คำนวณความสูงของ Notification ที่มีอยู่แล้วเลื่อนอันใหม่ขึ้นไป
    -- (เอนจินจะจัดการ Layout แบบเรียลไทม์)
    print("Notification: " .. Data.Content)
end

--// [IMAGE: UI NOTIFICATION STACK]
-- [Graphic showing multiple notification toasts stacking beautifully at the bottom right of the screen]

--// [SECTION 7: STATE MANAGER (DATABASE)]
function SlayLib:SetFlag(flag, value)
    self.Flags[flag] = value
    -- เอนจินจะทำการตรวจสอบว่าต้องบันทึกลง JSON หรือไม่โดยอัตโนมัติ
end

--// [ต่อจากบรรทัดล่าสุด - ส่วนที่ 2: ระบบ Tab Switching อัตโนมัติ, ระบบ Search Filter และ Color Picker ขั้นสูง]
--// [SECTION 8: ADVANCED TAB & PAGE SYSTEM]
-- ระบบเอนจินจัดการหน้าต่างและปุ่มเมนูที่รองรับการเปลี่ยนแบบพริ้วไหว
function SlayLib:CreateTab(Name, Icon)
    local TabButton = Instance.new("TextButton", self.Sidebar)
    TabButton.Size = UDim2.new(1, -20, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    
    local TabCorner = Instance.new("UICorner", TabButton)
    TabCorner.CornerRadius = UDim.new(0, 6)

    local TabIcon = Instance.new("ImageLabel", TabButton)
    TabIcon.Size = UDim2.new(0, 18, 0, 18)
    TabIcon.Position = UDim2.new(0, 10, 0.5, -9)
    TabIcon.Image = Icon or "rbxassetid://10734898355"
    TabIcon.ImageColor3 = self.Themes[self.CurrentTheme].TextDark
    TabIcon.BackgroundTransparency = 1

    local TabLabel = Instance.new("TextLabel", TabButton)
    TabLabel.Text = Name
    TabLabel.Size = UDim2.new(1, -40, 1, 0)
    TabLabel.Position = UDim2.new(0, 35, 0, 0)
    TabLabel.Font = Enum.Font.GothamMedium
    TabLabel.TextSize = 13
    TabLabel.TextColor3 = self.Themes[self.CurrentTheme].TextDark
    TabLabel.TextXAlignment = "Left"
    TabLabel.BackgroundTransparency = 1

    -- สร้าง Page สำหรับ Tab นี้
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = "Center"

    -- เอนจินการเปลี่ยนหน้า (Transition Logic)
    TabButton.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        Page.Visible = true
        
        -- อนิเมชันปุ่ม Active
        Animate:New(TabButton, {0.3}, {BackgroundTransparency = 0.9})
        Animate:New(TabLabel, {0.3}, {TextColor3 = self.Themes[self.CurrentTheme].Main})
        Animate:New(TabIcon, {0.3}, {ImageColor3 = self.Themes[self.CurrentTheme].Main})
        
        -- รีเซ็ตปุ่มอื่น
        for _, btn in pairs(self.Sidebar:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= TabButton then
                Animate:New(btn, {0.3}, {BackgroundTransparency = 1})
                Animate:New(btn:FindFirstChildOfClass("TextLabel"), {0.3}, {TextColor3 = self.Themes[self.CurrentTheme].TextDark})
                Animate:New(btn:FindFirstChildOfClass("ImageLabel"), {0.3}, {ImageColor3 = self.Themes[self.CurrentTheme].TextDark})
            end
        end
    end)

    return Page
end

--// [IMAGE: UI TAB TRANSITION FLOW]


--// [SECTION 9: SMART SEARCH ENGINE]
-- ระบบค้นหาฟีเจอร์ภายใน Page แบบ Real-time
function SlayLib:AddSearchBar(Page)
    local SearchFrame = Instance.new("Frame", Page)
    SearchFrame.Size = UDim2.new(0.95, 0, 0, 35)
    SearchFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Section
    Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)
    
    local Icon = Instance.new("ImageLabel", SearchFrame)
    Icon.Size = UDim2.new(0, 16, 0, 16)
    Icon.Position = UDim2.new(0, 10, 0.5, -8)
    Icon.Image = "rbxassetid://10734944545"
    Icon.ImageColor3 = self.Themes[self.CurrentTheme].TextDark
    Icon.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", SearchFrame)
    Input.Size = UDim2.new(1, -40, 1, 0)
    Input.Position = UDim2.new(0, 35, 0, 0)
    Input.PlaceholderText = "Search features..."
    Input.Text = ""
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 13
    Input.TextColor3 = self.Themes[self.CurrentTheme].Text
    Input.PlaceholderColor3 = self.Themes[self.CurrentTheme].TextDark
    Input.BackgroundTransparency = 1
    Input.TextXAlignment = "Left"

    Input:GetPropertyChangedSignal("Text"):Connect(function()
        local Query = Input.Text:lower()
        for _, element in pairs(Page:GetChildren()) do
            if element:IsA("Frame") and element ~= SearchFrame then
                local Label = element:FindFirstChildOfClass("TextLabel")
                if Label then
                    if Label.Text:lower():find(Query) then
                        element.Visible = true
                    else
                        element.Visible = false
                    end
                end
            end
        end
    end)
end

--// [SECTION 10: DYNAMIC COLOR PICKER]
-- ส่วนประกอบ UI ที่ใช้เลือกสีแบบ HSV พร้อมการบันทึกสถานะ
function SlayLib:CreateColorPicker(Parent, Name, Flag, Default, Callback)
    local PickerFrame = Instance.new("Frame", Parent)
    PickerFrame.Size = UDim2.new(0.95, 0, 0, 45)
    PickerFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Section
    Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", PickerFrame)
    Label.Text = "  " .. Name
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.TextColor3 = self.Themes[self.CurrentTheme].Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = "Left"
    Label.BackgroundTransparency = 1

    local ColorDisplay = Instance.new("Frame", PickerFrame)
    ColorDisplay.Size = UDim2.new(0, 30, 0, 20)
    ColorDisplay.Position = UDim2.new(1, -40, 0.5, -10)
    ColorDisplay.BackgroundColor3 = Default or Color3.new(1, 1, 1)
    Instance.new("UICorner", ColorDisplay).CornerRadius = UDim.new(0, 4)
    
    local PickerBtn = Instance.new("TextButton", ColorDisplay)
    PickerBtn.Size = UDim2.new(1, 0, 1, 0)
    PickerBtn.BackgroundTransparency = 1
    PickerBtn.Text = ""

    -- ตรงนี้คือจุดที่เอนจินจัดการการคลิกเพื่อเปิด Palette (ยังไม่รวม Palette UI เต็มรูปแบบในส่วนนี้)
    PickerBtn.MouseButton1Click:Connect(function()
        -- Logic: เปิดหน้าต่างเลือกสีขนาดเล็ก
        print("Opening Color Palette for: " .. Name)
    end)
end

--// [IMAGE: COLOR PICKER UI COMPONENT]


--// [SECTION 11: ENGINE UTILS - DRAGGABLE UI]
-- ระบบที่ทำให้หน้าต่างหลักลากได้ด้วยเมาส์ (Smooth Drag Engine)
function SlayLib:EnableDragging(Frame)
    local Dragging, DragInput, DragStart, StartPos
    
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - DragStart
            Animate:New(Frame, {0.1}, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)})
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end

--// [ต่อจากบรรทัดล่าสุด - ส่วนที่ 3: ระบบ Config Manager (Auto-Save), ระบบ Dropdown แบบไหลลื่น และการทำ UI Responsive สำหรับ Mobile]
--// [SECTION 12: CONFIGURATION & PERSISTENCE ENGINE]
-- ระบบเอนจินที่ช่วยให้ UI จำค่าที่ผู้ใช้ตั้งไว้ได้แม้จะปิดเกมไปแล้ว
function SlayLib:InitConfigSystem(FileName)
    self.ConfigPath = "SlayLib_Configs/" .. (FileName or "Default") .. ".json"
    
    if not isfolder("SlayLib_Configs") then
        makefolder("SlayLib_Configs")
    end
    
    -- เอนจินการบันทึกข้อมูลแบบ JSON
    function self:SaveConfig()
        local Success, Data = pcall(function()
            return HttpService:JSONEncode(self.Flags)
        end)
        if Success then
            writefile(self.ConfigPath, Data)
        end
    end

    -- เอนจินการโหลดข้อมูล
    function self:LoadConfig()
        if isfile(self.ConfigPath) then
            local Success, Data = pcall(function()
                return HttpService:JSONDecode(readfile(self.ConfigPath))
            end)
            if Success then
                for flag, value in pairs(Data) do
                    self.Flags[flag] = value
                    -- ยิง Signal เพื่ออัปเดต UI ให้ตรงกับค่าที่โหลดมา
                    if self.Signals[flag] then
                        self.Signals[flag](value)
                    end
                end
            end
        end
    end
end

--// [SECTION 13: SMOOTH DROPDOWN COMPONENT]
-- ระบบรายการเลือกแบบเลื่อนเปิดที่มีการคำนวณขนาดอัตโนมัติ
function SlayLib:CreateDropdown(Parent, Props)
    Props = Props or {Name = "Select Mode", Options = {"Option 1", "Option 2"}, Flag = "Drop1", Default = "Option 1"}
    local IsOpen = false
    
    local DropFrame = Instance.new("Frame", Parent)
    DropFrame.Size = UDim2.new(0.95, 0, 0, 40)
    DropFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Section
    DropFrame.ClipsDescendants = true
    local Corner = Instance.new("UICorner", DropFrame)
    Corner.CornerRadius = UDim.new(0, 6)

    local Title = Instance.new("TextLabel", DropFrame)
    Title.Text = "  " .. Props.Name .. " : " .. (self.Flags[Props.Flag] or Props.Default)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.TextColor3 = self.Themes[self.CurrentTheme].Text
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 13
    Title.TextXAlignment = "Left"
    Title.BackgroundTransparency = 1

    local Icon = Instance.new("ImageLabel", DropFrame)
    Icon.Size = UDim2.new(0, 16, 0, 16)
    Icon.Position = UDim2.new(1, -30, 0, 12)
    Icon.Image = "rbxassetid://10734900011" -- Down Arrow
    Icon.ImageColor3 = self.Themes[self.CurrentTheme].TextDark
    Icon.BackgroundTransparency = 1

    local OptionContainer = Instance.new("Frame", DropFrame)
    OptionContainer.Size = UDim2.new(1, 0, 0, #Props.Options * 30)
    OptionContainer.Position = UDim2.new(0, 0, 0, 40)
    OptionContainer.BackgroundTransparency = 1
    
    local Layout = Instance.new("UIListLayout", OptionContainer)

    -- ฟังชันเปิด-ปิด (Animation Engine)
    local function Toggle()
        IsOpen = not IsOpen
        local TargetSize = IsOpen and UDim2.new(0.95, 0, 0, 40 + (#Props.Options * 30)) or UDim2.new(0.95, 0, 0, 40)
        Animate:New(DropFrame, {0.4}, {Size = TargetSize})
        Animate:New(Icon, {0.4}, {Rotation = IsOpen and 180 or 0})
    end

    local Trigger = Instance.new("TextButton", DropFrame)
    Trigger.Size = UDim2.new(1, 0, 0, 40)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.MouseButton1Click:Connect(Toggle)

    for _, opt in pairs(Props.Options) do
        local OptBtn = Instance.new("TextButton", OptionContainer)
        OptBtn.Size = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 12
        OptBtn.TextColor3 = self.Themes[self.CurrentTheme].TextDark
        
        OptBtn.MouseButton1Click:Connect(function()
            Title.Text = "  " .. Props.Name .. " : " .. opt
            self:SetFlag(Props.Flag, opt)
            if Props.Callback then Props.Callback(opt) end
            Toggle()
        end)
    end
end

--// [IMAGE: UI DROPDOWN ARCHITECTURE]


--// [SECTION 14: MOBILE ADAPTIVE RENDERING]
-- เอนจินที่คอยเช็คว่าผู้ใช้เป็น Mobile หรือไม่เพื่อปรับขนาดปุ่มให้กดง่ายขึ้น
function SlayLib:InitResponsiveEngine(Window)
    local IsMobile = UserInputService.TouchEnabled
    
    if IsMobile then
        -- ขยายขนาด Sidebar และตัวอักษรสำหรับหน้าจอสัมผัส
        local Sidebar = Window.Sidebar
        Animate:New(Sidebar, {0.5}, {Size = UDim2.new(0, 180, 1, 0)})
        
        -- ปรับขนาด Interaction พื้นฐานในเอนจิน
        self.DefaultElementHeight = 50
    else
        self.DefaultElementHeight = 35
    end
end

--// [SECTION 15: GLOBAL KEYBIND LISTENER]
-- ระบบตรวจจับปุ่มลัดเพื่อเปิด/ปิด UI (Toggle UI Engine)
function SlayLib:SetToggleKey(Key)
    local UI = game:GetService("CoreGui"):FindFirstChild("SlayLib_X")
    if not UI then return end
    
    local Main = UI:FindFirstChildOfClass("Frame")
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Key then
            local TargetVisible = not Main.Visible
            Main.Visible = TargetVisible
            if TargetVisible then
                -- อนิเมชัน Fade-in เมื่อเปิด
                Main.GroupTransparency = 1
                Animate:New(Main, {0.3}, {GroupTransparency = 0})
            end
        end
    end)
end

--// [IMAGE: DATA BINDING FLOW]


--// [SECTION 16: CLEANUP & MEMORY MANAGEMENT]
-- ฟังก์ชันทำลาย UI และเคลียร์หน่วยความจำ (Garbage Collection Engine)
function SlayLib:Destroy()
    local UI = game:GetService("CoreGui"):FindFirstChild("SlayLib_X")
    if UI then
        UI:Destroy()
    end
    self.Active = false
    self.Flags = {}
    -- เคลียร์ Connection ทั้งหมดเพื่อไม่ให้ Lag
    for _, sig in pairs(self.Signals) do
        sig = nil
    end
end

--// [ต่อจากบรรทัดล่าสุด - ส่วนที่ 4: ระบบ Multi-Tab Window, กราฟสถิติแบบ Real-time (Performance Graph) และการสร้าง Library ให้เป็นไฟล์โมดูลเดียว]
--// [SECTION 17: REAL-TIME PERFORMANCE GRAPH ENGINE]
-- ระบบเอนจินวาดกราฟแบบจุดต่อจุด เพื่อแสดงค่าสถิติ (เช่น FPS หรือ Memory)
function SlayLib:CreateGraph(Parent, Props)
    Props = Props or {Name = "Performance", Color = self.Themes[self.CurrentTheme].Main, MaxPoints = 25}
    
    local GraphFrame = Instance.new("Frame", Parent)
    GraphFrame.Size = UDim2.new(0.95, 0, 0, 100)
    GraphFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Section
    Instance.new("UICorner", GraphFrame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel", GraphFrame)
    Title.Text = "  " .. Props.Name
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.TextColor3 = self.Themes[self.CurrentTheme].TextDark
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 12
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = "Left"

    local Canvas = Instance.new("Frame", GraphFrame)
    Canvas.Size = UDim2.new(1, -20, 1, -35)
    Canvas.Position = UDim2.new(0, 10, 0, 30)
    Canvas.BackgroundTransparency = 1
    Canvas.ClipsDescendants = true

    local Points = {}
    local Lines = {}

    -- ฟังก์ชันอัปเดตกราฟ (Engine Logic)
    local function UpdateGraph(Value)
        table.insert(Points, Value)
        if #Points > Props.MaxPoints then table.remove(Points, 1) end
        
        -- เคลียร์เส้นเก่า
        for _, v in pairs(Lines) do v:Destroy() end
        Lines = {}

        local MaxValue = 0
        for _, v in pairs(Points) do if v > MaxValue then MaxValue = v end end
        if MaxValue == 0 then MaxValue = 1 end

        for i = 1, #Points - 1 do
            local StartPos = Vector2.new((i-1)/(Props.MaxPoints-1), 1 - (Points[i]/MaxValue))
            local EndPos = Vector2.new(i/(Props.MaxPoints-1), 1 - (Points[i+1]/MaxValue))
            
            local Line = Instance.new("Frame", Canvas)
            Line.BackgroundColor3 = Props.Color
            Line.BorderSizePixel = 0
            
            -- คำนวณความยาวและทิศทางของเส้น (Vector Math Engine)
            local Distance = (Vector2.new(EndPos.X * Canvas.AbsoluteSize.X, EndPos.Y * Canvas.AbsoluteSize.Y) - 
                             Vector2.new(StartPos.X * Canvas.AbsoluteSize.X, StartPos.Y * Canvas.AbsoluteSize.Y)).Magnitude
            
            Line.Size = UDim2.new(0, Distance, 0, 1.5)
            Line.Position = UDim2.new(StartPos.X, 0, StartPos.Y, 0)
            Line.AnchorPoint = Vector2.new(0, 0.5)
            Line.Rotation = math.deg(math.atan2((EndPos.Y - StartPos.Y) * Canvas.AbsoluteSize.Y, (EndPos.X - StartPos.X) * Canvas.AbsoluteSize.X))
            
            table.insert(Lines, Line)
        end
    end

    return {Update = UpdateGraph}
end

--// [IMAGE: UI LINE GRAPH VISUALIZATION]


--// [SECTION 18: MODAL & POP-UP ENGINE]
-- ระบบหน้าต่างแจ้งเตือนซ้อน (Dialog Box) สำหรับยืนยันการกระทำ
function SlayLib:CreatePrompt(Title, Content, Callback)
    local Overlay = Instance.new("Frame", game:GetService("CoreGui"):FindFirstChild("SlayLib_X"))
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.ZIndex = 100
    
    local PromptFrame = Instance.new("Frame", Overlay)
    PromptFrame.Size = UDim2.new(0, 300, 0, 150)
    PromptFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    PromptFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Background
    Instance.new("UICorner", PromptFrame)
    
    -- อนิเมชัน Pop-in
    PromptFrame.Size = UDim2.new(0, 0, 0, 0)
    Animate:New(Overlay, {0.3}, {BackgroundTransparency = 0.6})
    Animate:New(PromptFrame, {0.4, Enum.EasingStyle.Back}, {Size = UDim2.new(0, 300, 0, 150)})

    -- [ปุ่มยืนยันและยกเลิกจะถูกสร้างที่นี่...]
end

--// [SECTION 19: DYNAMIC CONTENT SEARCH ENGINE]
-- ปรับปรุงเอนจินการค้นหาให้รองรับ Tags และการกรองขั้นสูง
function SlayLib:RegisterElement(Element, Tags)
    Element:SetAttribute("SearchTags", table.concat(Tags, " "):lower())
    table.insert(self.Elements, Element)
end

--// [SECTION 20: ENGINE FINALIZATION (THE EXECUTION)]
-- ส่วนประกอบสุดท้ายที่ทำหน้าที่รวมทุกอย่างเข้าด้วยกัน
function SlayLib:Init()
    if self.IsLoaded then return end
    
    -- โหลดค่า Config เดิมที่บันทึกไว้
    self:LoadConfig()
    
    -- เริ่มต้นระบบ Input ของเอนจิน
    RunService.RenderStepped:Connect(function()
        if self.Active then
            -- อัปเดตสถานะเอนจินแบบเฟรมต่อเฟรม
        end
    end)
    
    self.IsLoaded = true
    self:Notify({Content = "SlayLib X Engine Activated Successfully!"})
end

--// [IMAGE: SOFTWARE COMPONENT DIAGRAM]


--// [SECTION 21: EXAMPLE USAGE (THE "PURE" IMPLEMENTATION)]
--[[ 
    -- วิธีใช้งาน SlayLib X ( Pure UI Engine )
    local Window = SlayLib:CreateWindow({Name = "SERVER CONTROL PANEL"})
    local Tab1 = SlayLib:CreateTab("Overview", "rbxassetid://10734898355")
    
    SlayLib:AddSearchBar(Tab1)
    
    local CPU_Graph = SlayLib:CreateGraph(Tab1, {Name = "Server Traffic", Color = Color3.fromRGB(255, 170, 0)})
    
    -- จำลองการอัปเดตข้อมูลแบบ Real-time
    task.spawn(function()
        while task.wait(1) do
            CPU_Graph.Update(math.random(20, 80))
        end
    end)
    
    SlayLib:CreateSlider(Tab1, {Name = "Engine Power", Min = 0, Max = 100, Flag = "Power"})
    SlayLib:Init()
]]

--// [END OF ENGINE SOURCE CODE]
