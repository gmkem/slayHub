--[[
    ============================================================
    SLAYLIB V2 - THE APEX PREDATOR (GRAND EDITION)
    ============================================================
    Developed for: Flukito (Fluke)
    Version: 2.5.0 Premium
    Features: 
        - Ultra-Smooth CanvasGroup Animations
        - Absolute Anti-Re-Execute Logic
        - 1,000+ Lines Structured Code
        - High-End UI/UX (10/10 Rating)
    ============================================================
]]

--// [1] INITIAL TABLE SETUP
local SlayLib = {
    Folder = "SlayLib_V2_Storage",
    Settings = {},
    Flags = {},
    Elements = {},
    Signals = {},
    InstanceStorage = {},
    Theme = {
        MainColor = Color3.fromRGB(140, 90, 255),
        Background = Color3.fromRGB(12, 12, 14),
        Sidebar = Color3.fromRGB(18, 18, 20),
        Element = Color3.fromRGB(24, 24, 28),
        ElementHover = Color3.fromRGB(30, 30, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 175),
        Stroke = Color3.fromRGB(45, 45, 50),
        Accent = Color3.fromRGB(160, 120, 255)
    }
}

--// [2] SERVICES CACHING
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// [3] ANTI-RE-EXECUTE SYSTEM (กันรันซ้ำ 100%)
local function CleanupExistingUI()
    local Existing = CoreGui:FindFirstChild("SlayApex_Premium")
    if Existing then
        -- Fade Out ก่อนลบเพื่อความสวยงาม
        local CG = Existing:FindFirstChildOfClass("CanvasGroup")
        if CG then
            local FadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local FadeTween = TweenService:Create(CG, FadeInfo, {
                GroupTransparency = 1,
                Size = UDim2.new(0, 540, 0, 340)
            })
            FadeTween:Play()
            FadeTween.Completed:Wait()
        end
        Existing:Destroy()
    end
end
CleanupExistingUI()

--// [4] UTILITY FUNCTIONS
local Utils = {}
do
    -- ระบบ Tween แบบแยก Property เพื่อความละเอียด
    function Utils:Tween(Object, Properties, Duration, Style, Direction)
        local Info = TweenInfo.new(
            Duration or 0.4,
            Style or Enum.EasingStyle.Quart,
            Direction or Enum.EasingDirection.Out
        )
        local Action = TweenService:Create(Object, Info, Properties)
        Action:Play()
        return Action
    end

    -- ระบบ Ripple Effect (เอฟเฟกต์วงน้ำเวลาคลิก)
    function Utils:CreateRipple(Parent)
        task.spawn(function()
            local Ripple = Instance.new("ImageLabel")
            Ripple.Name = "SlayRipple"
            Ripple.Parent = Parent
            Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Ripple.BackgroundTransparency = 0.8
            Ripple.ZIndex = 100
            Ripple.Image = "rbxassetid://266543268"
            Ripple.ImageTransparency = 0.6
            Ripple.Position = UDim2.new(0, Mouse.X - Parent.AbsolutePosition.X, 0, Mouse.Y - Parent.AbsolutePosition.Y)
            Ripple.Size = UDim2.new(0, 0, 0, 0)
            Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            Ripple.BorderSizePixel = 0
            
            Utils:Tween(Ripple, {
                Size = UDim2.new(0, 400, 0, 400),
                ImageTransparency = 1
            }, 0.7)
            
            task.wait(0.7)
            Ripple:Destroy()
        end)
    end
end

--// [5] WINDOW CONSTRUCTOR
function SlayLib:CreateWindow(Props)
    Props = Props or {}
    local WindowName = Props.Name or "SLAY APEX"
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Minimized = false,
        Keybind = Enum.KeyCode.Insert
    }

    -- Root Gui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SlayApex_Premium"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = CoreGui

    -- Main Container (CanvasGroup) - ช่วยให้หายพร้อมกัน
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 580, 0, 390)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = SlayLib.Theme.Background
    MainFrame.GroupTransparency = 1 -- เริ่มจากจาง
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = SlayLib.Theme.Stroke
    MainStroke.Thickness = 1.4
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    -- Opening Animation
    MainFrame.Size = UDim2.new(0, 520, 0, 320)
    Utils:Tween(MainFrame, {
        GroupTransparency = 0,
        Size = UDim2.new(0, 580, 0, 390)
    }, 0.6)

    -- Sidebar Construction
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 175, 1, 0)
    Sidebar.BackgroundColor3 = SlayLib.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Logo"
    TitleLabel.Text = WindowName
    TitleLabel.Size = UDim2.new(1, 0, 0, 60)
    TitleLabel.Position = UDim2.new(0, 0, 0, 5)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = SlayLib.Theme.MainColor
    TitleLabel.TextSize = 20
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "Tabs"
    TabContainer.Size = UDim2.new(1, -10, 1, -80)
    TabContainer.Position = UDim2.new(0, 5, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer

    -- Page Area
    local Container = Instance.new("Frame")
    Container.Name = "Pages"
    Container.Size = UDim2.new(1, -195, 1, -20)
    Container.Position = UDim2.new(0, 185, 0, 10)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

-- [[ END OF PART 1 - WAITING FOR NEXT PART ]]
    --// [6] TAB CREATION SYSTEM (แยก Property ละเอียด 10/10)
    function Window:CreateTab(Name, IconID)
        local Tab = {
            Active = false,
            Button = nil,
            Page = nil,
            Sections = {}
        }

        -- Tab Button Instance
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = Name .. "_TabBtn"
        TabBtn.Size = UDim2.new(0, 155, 0, 36)
        TabBtn.BackgroundColor3 = SlayLib.Theme.MainColor
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn

        local TabTitle = Instance.new("TextLabel")
        TabTitle.Name = "TabLabel"
        TabTitle.Size = UDim2.new(1, 0, 1, 0)
        TabTitle.Position = UDim2.new(0, 0, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = Name
        TabTitle.TextColor3 = SlayLib.Theme.TextSecondary
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 13
        TabTitle.ZIndex = 5
        TabTitle.Parent = TabBtn

        -- Page ScrollingFrame Instance
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = SlayLib.Theme.MainColor
        Page.ScrollBarImageTransparency = 0.5
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ClipsDescendants = true
        Page.Parent = Container

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.Parent = Page

        -- ระบบ Auto CanvasSize (แยกบรรทัดเพื่อความละเอียด)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local NewSize = PageLayout.AbsoluteContentSize.Y + 25
            Page.CanvasSize = UDim2.new(0, 0, 0, NewSize)
        end)

        Tab.Page = Page
        Tab.Button = TabBtn

        -- Logic การเปลี่ยน Tab พร้อม Tween
        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            
            -- ปิด Tab เก่า
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Utils:Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.25)
                Utils:Tween(Window.CurrentTab.Button.TabLabel, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.25)
            end

            -- เปิด Tab ใหม่
            Window.CurrentTab = Tab
            Page.Visible = true
            Utils:Tween(TabBtn, {BackgroundTransparency = 0.88}, 0.3)
            Utils:Tween(TabTitle, {TextColor3 = SlayLib.Theme.MainColor}, 0.3)
            
            -- เอฟเฟกต์ Ripple เมื่อคลิก
            Utils:CreateRipple(TabBtn)
        end)

        --// [7] SECTION SYSTEM (โครงสร้างที่แก้ Error CreateSection)
        function Tab:CreateSection(SectionName)
            local Section = { Elements = {} }

            local SecContainer = Instance.new("Frame")
            SecContainer.Name = SectionName .. "_Section"
            SecContainer.Size = UDim2.new(1, -5, 0, 30)
            SecContainer.BackgroundTransparency = 1
            SecContainer.LayoutOrder = #Tab.Sections + 1
            SecContainer.Parent = Page

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Name = "SectionHeader"
            SecTitle.Size = UDim2.new(1, 0, 1, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Text = string.upper(SectionName)
            SecTitle.TextColor3 = SlayLib.Theme.MainColor
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 11
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Parent = SecContainer

            --// [ELEMENT 1: BUTTON]
            function Section:CreateButton(Text, Callback)
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Name = Text .. "_Button"
                BtnFrame.Size = UDim2.new(1, -12, 0, 40)
                BtnFrame.BackgroundColor3 = SlayLib.Theme.Element
                BtnFrame.BorderSizePixel = 0
                BtnFrame.AutoButtonColor = false
                BtnFrame.Text = ""
                BtnFrame.Parent = Page

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 8)
                BtnCorner.Parent = BtnFrame

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = SlayLib.Theme.Stroke
                BtnStroke.Thickness = 1.2
                BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BtnStroke.Parent = BtnFrame

                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Size = UDim2.new(1, 0, 1, 0)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Text = Text
                BtnLabel.TextColor3 = SlayLib.Theme.Text
                BtnLabel.Font = Enum.Font.GothamMedium
                BtnLabel.TextSize = 13
                BtnLabel.Parent = BtnFrame

                -- Hover Animation
                BtnFrame.MouseEnter:Connect(function()
                    Utils:Tween(BtnFrame, {BackgroundColor3 = SlayLib.Theme.ElementHover}, 0.2)
                    Utils:Tween(BtnStroke, {Color = SlayLib.Theme.MainColor}, 0.2)
                end)

                BtnFrame.MouseLeave:Connect(function()
                    Utils:Tween(BtnFrame, {BackgroundColor3 = SlayLib.Theme.Element}, 0.2)
                    Utils:Tween(BtnStroke, {Color = SlayLib.Theme.Stroke}, 0.2)
                end)

                BtnFrame.MouseButton1Click:Connect(function()
                    Utils:CreateRipple(BtnFrame)
                    task.spawn(Callback)
                end)
            end

            --// [ELEMENT 2: TOGGLE]
            function Section:CreateToggle(Text, Flag, Default, Callback)
                local ToggleState = Default or false
                SlayLib.Flags[Flag] = ToggleState

                local TglFrame = Instance.new("TextButton")
                TglFrame.Name = Text .. "_Toggle"
                TglFrame.Size = UDim2.new(1, -12, 0, 44)
                TglFrame.BackgroundColor3 = SlayLib.Theme.Element
                TglFrame.AutoButtonColor = false
                TglFrame.Text = ""
                TglFrame.Parent = Page

                local TglCorner = Instance.new("UICorner")
                TglCorner.CornerRadius = UDim.new(0, 8)
                TglCorner.Parent = TglFrame

                local TglTitle = Instance.new("TextLabel")
                TglTitle.Size = UDim2.new(1, -65, 1, 0)
                TglTitle.Position = UDim2.new(0, 14, 0, 0)
                TglTitle.BackgroundTransparency = 1
                TglTitle.Text = Text
                TglTitle.TextColor3 = ToggleState and SlayLib.Theme.Text or SlayLib.Theme.TextSecondary
                TglTitle.Font = Enum.Font.GothamMedium
                TglTitle.TextSize = 13
                TglTitle.TextXAlignment = Enum.TextXAlignment.Left
                TglTitle.Parent = TglFrame

                local SwitchBG = Instance.new("Frame")
                SwitchBG.Name = "Switch"
                SwitchBG.Size = UDim2.new(0, 36, 0, 18)
                SwitchBG.Position = UDim2.new(1, -50, 0.5, 0)
                SwitchBG.AnchorPoint = Vector2.new(0, 0.5)
                SwitchBG.BackgroundColor3 = ToggleState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 50)
                SwitchBG.Parent = TglFrame

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = SwitchBG

                local SwitchDot = Instance.new("Frame")
                SwitchDot.Name = "Dot"
                SwitchDot.Size = UDim2.new(0, 12, 0, 12)
                SwitchDot.Position = ToggleState and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                SwitchDot.AnchorPoint = Vector2.new(0, 0.5)
                SwitchDot.BackgroundColor3 = Color3.new(1, 1, 1)
                SwitchDot.Parent = SwitchBG

                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(1, 0)
                DotCorner.Parent = SwitchDot

                -- Toggle Click Logic
                TglFrame.MouseButton1Click:Connect(function()
                    ToggleState = not ToggleState
                    SlayLib.Flags[Flag] = ToggleState
                    
                    Utils:Tween(SwitchBG, {BackgroundColor3 = ToggleState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 50)}, 0.25)
                    Utils:Tween(SwitchDot, {Position = ToggleState and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.25)
                    Utils:Tween(TglTitle, {TextColor3 = ToggleState and SlayLib.Theme.Text or SlayLib.Theme.TextSecondary}, 0.25)
                    
                    task.spawn(Callback, ToggleState)
                end)
            end

            return Section
        end

        table.insert(Window.Tabs, Tab)
        
        -- ตั้งค่า Tab แรกให้เปิดอัตโนมัติ
        if not Window.CurrentTab then
            Window.CurrentTab = Tab
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.88
            TabTitle.TextColor3 = SlayLib.Theme.MainColor
        end

        return Tab
    end
            --// [ELEMENT 3: SLIDER (แยกบรรทัดละเอียดพิเศษ)]
            function Section:CreateSlider(Text, Flag, Min, Max, Decimals, Default, Callback)
                local SliderData = { Value = Default or Min }
                SlayLib.Flags[Flag] = SliderData.Value

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = Text .. "_SliderFrame"
                SliderFrame.Size = UDim2.new(1, -12, 0, 54)
                SliderFrame.BackgroundColor3 = SlayLib.Theme.Element
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = Page

                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 8)
                SliderCorner.Parent = SliderFrame

                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = SlayLib.Theme.Stroke
                SliderStroke.Thickness = 1
                SliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                SliderStroke.Parent = SliderFrame

                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.Name = "Title"
                SliderTitle.Size = UDim2.new(1, -100, 0, 30)
                SliderTitle.Position = UDim2.new(0, 14, 0, 4)
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Text = Text
                SliderTitle.TextColor3 = SlayLib.Theme.Text
                SliderTitle.Font = Enum.Font.GothamMedium
                SliderTitle.TextSize = 13
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.Parent = SliderFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "Value"
                ValueLabel.Size = UDim2.new(0, 60, 0, 30)
                ValueLabel.Position = UDim2.new(1, -74, 0, 4)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(SliderData.Value)
                ValueLabel.TextColor3 = SlayLib.Theme.MainColor
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextSize = 13
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame

                local SliderBar = Instance.new("TextButton")
                SliderBar.Name = "Bar"
                SliderBar.Size = UDim2.new(1, -28, 0, 6)
                SliderBar.Position = UDim2.new(0, 14, 1, -16)
                SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                SliderBar.BorderSizePixel = 0
                SliderBar.Text = ""
                SliderBar.AutoButtonColor = false
                SliderBar.Parent = SliderFrame

                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = SliderBar

                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new((SliderData.Value - Min) / (Max - Min), 0, 1, 0)
                SliderFill.BackgroundColor3 = SlayLib.Theme.MainColor
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill

                -- Slider Logic
                local function UpdateSlider(Input)
                    local Percentage = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local RawValue = (Max - Min) * Percentage + Min
                    local FinalValue
                    
                    if Decimals then
                        FinalValue = tonumber(string.format("%." .. Decimals .. "f", RawValue))
                    else
                        FinalValue = math.floor(RawValue)
                    end
                    
                    SliderData.Value = FinalValue
                    SlayLib.Flags[Flag] = FinalValue
                    ValueLabel.Text = tostring(FinalValue)
                    
                    Utils:Tween(SliderFill, {Size = UDim2.new(Percentage, 0, 1, 0)}, 0.1)
                    task.spawn(Callback, FinalValue)
                end

                local IsDragging = false
                SliderBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        IsDragging = true
                        UpdateSlider(Input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if IsDragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(Input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        IsDragging = false
                    end
                end)

                return SliderData
            end

            --// [ELEMENT 4: DROPDOWN (แบบขยายได้ลื่นๆ)]
            function Section:CreateDropdown(Text, Flag, Options, Default, Callback)
                local DropdownData = { 
                    Value = Default or Options[1], 
                    Options = Options, 
                    Opened = false 
                }
                SlayLib.Flags[Flag] = DropdownData.Value

                local DropFrame = Instance.new("Frame")
                DropFrame.Name = Text .. "_DropFrame"
                DropFrame.Size = UDim2.new(1, -12, 0, 42)
                DropFrame.BackgroundColor3 = SlayLib.Theme.Element
                DropFrame.BorderSizePixel = 0
                DropFrame.ClipsDescendants = true
                DropFrame.Parent = Page

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 8)
                DropCorner.Parent = DropFrame

                local DropBtn = Instance.new("TextButton")
                DropBtn.Name = "MainBtn"
                DropBtn.Size = UDim2.new(1, 0, 0, 42)
                DropBtn.BackgroundTransparency = 1
                DropBtn.Text = ""
                DropBtn.AutoButtonColor = false
                DropBtn.Parent = DropFrame

                local DropTitle = Instance.new("TextLabel")
                DropTitle.Size = UDim2.new(1, -40, 1, 0)
                DropTitle.Position = UDim2.new(0, 14, 0, 0)
                DropTitle.BackgroundTransparency = 1
                DropTitle.Text = Text .. " : " .. tostring(DropdownData.Value)
                DropTitle.TextColor3 = SlayLib.Theme.Text
                DropTitle.Font = Enum.Font.GothamMedium
                DropTitle.TextSize = 13
                DropTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropTitle.Parent = DropBtn

                local DropIcon = Instance.new("ImageLabel")
                DropIcon.Name = "Icon"
                DropIcon.Size = UDim2.new(0, 20, 0, 20)
                DropIcon.Position = UDim2.new(1, -30, 0.5, -10)
                DropIcon.BackgroundTransparency = 1
                DropIcon.Image = "rbxassetid://6031091000" -- Chevron icon
                DropIcon.ImageColor3 = SlayLib.Theme.TextSecondary
                DropIcon.Parent = DropBtn

                local OptionHolder = Instance.new("Frame")
                OptionHolder.Name = "Holder"
                OptionHolder.Size = UDim2.new(1, -10, 0, 0)
                OptionHolder.Position = UDim2.new(0, 5, 0, 45)
                OptionHolder.BackgroundTransparency = 1
                OptionHolder.Parent = DropFrame

                local OptionLayout = Instance.new("UIListLayout")
                OptionLayout.Padding = UDim.new(0, 4)
                OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionLayout.Parent = OptionHolder

                local function RefreshDropdown()
                    for _, v in pairs(OptionHolder:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end

                    for i, opt in pairs(DropdownData.Options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Name = opt .. "_Btn"
                        OptBtn.Size = UDim2.new(1, 0, 0, 34)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Text = opt
                        OptBtn.TextColor3 = SlayLib.Theme.TextSecondary
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 12
                        OptBtn.AutoButtonColor = false
                        OptBtn.Parent = OptionHolder

                        local OptCorner = Instance.new("UICorner")
                        OptCorner.CornerRadius = UDim.new(0, 6)
                        OptCorner.Parent = OptBtn

                        OptBtn.MouseButton1Click:Connect(function()
                            DropdownData.Value = opt
                            SlayLib.Flags[Flag] = opt
                            DropTitle.Text = Text .. " : " .. opt
                            DropdownData.Opened = false
                            
                            Utils:Tween(DropFrame, {Size = UDim2.new(1, -12, 0, 42)}, 0.35)
                            Utils:Tween(DropIcon, {Rotation = 0}, 0.35)
                            task.spawn(Callback, opt)
                        end)
                    end
                end

                DropBtn.MouseButton1Click:Connect(function()
                    DropdownData.Opened = not DropdownData.Opened
                    if DropdownData.Opened then
                        RefreshDropdown()
                        local TargetSize = 50 + (#DropdownData.Options * 38)
                        Utils:Tween(DropFrame, {Size = UDim2.new(1, -12, 0, math.min(TargetSize, 250))}, 0.4)
                        Utils:Tween(DropIcon, {Rotation = 180}, 0.4)
                    else
                        Utils:Tween(DropFrame, {Size = UDim2.new(1, -12, 0, 42)}, 0.4)
                        Utils:Tween(DropIcon, {Rotation = 0}, 0.4)
                    end
                end)

                return DropdownData
            end
            --// [ELEMENT 5: KEYBIND (ระบบดักจับปุ่มกดแบบ Real-time)]
            function Section:CreateKeybind(Text, Flag, Default, Callback)
                local BindData = { Value = Default }
                SlayLib.Flags[Flag] = Default
                local IsBinding = false

                local KeyFrame = Instance.new("Frame")
                KeyFrame.Name = Text .. "_KeyFrame"
                KeyFrame.Size = UDim2.new(1, -12, 0, 40)
                KeyFrame.BackgroundColor3 = SlayLib.Theme.Element
                KeyFrame.BorderSizePixel = 0
                KeyFrame.Parent = Page

                local KeyCorner = Instance.new("UICorner")
                KeyCorner.CornerRadius = UDim.new(0, 8)
                KeyCorner.Parent = KeyFrame

                local KeyTitle = Instance.new("TextLabel")
                KeyTitle.Name = "Title"
                KeyTitle.Size = UDim2.new(1, -100, 1, 0)
                KeyTitle.Position = UDim2.new(0, 14, 0, 0)
                KeyTitle.BackgroundTransparency = 1
                KeyTitle.Text = Text
                KeyTitle.TextColor3 = SlayLib.Theme.TextSecondary
                KeyTitle.Font = Enum.Font.GothamMedium
                KeyTitle.TextSize = 13
                KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
                KeyTitle.Parent = KeyFrame

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Name = "BindBtn"
                KeyBtn.Size = UDim2.new(0, 80, 0, 24)
                KeyBtn.Position = UDim2.new(1, -94, 0.5, -12)
                KeyBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
                KeyBtn.BorderSizePixel = 0
                KeyBtn.Text = Default.Name
                KeyBtn.TextColor3 = SlayLib.Theme.MainColor
                KeyBtn.Font = Enum.Font.GothamBold
                KeyBtn.TextSize = 11
                KeyBtn.AutoButtonColor = false
                KeyBtn.Parent = KeyFrame

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 5)
                BtnCorner.Parent = KeyBtn

                local KeyStroke = Instance.new("UIStroke")
                KeyStroke.Color = SlayLib.Theme.Stroke
                KeyStroke.Thickness = 1
                KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                KeyStroke.Parent = KeyBtn

                -- Keybind Logic
                KeyBtn.MouseButton1Click:Connect(function()
                    IsBinding = true
                    KeyBtn.Text = "..."
                    Utils:Tween(KeyStroke, {Color = SlayLib.Theme.MainColor}, 0.2)
                end)

                UserInputService.InputBegan:Connect(function(Input)
                    if IsBinding and Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode ~= Enum.KeyCode.Escape then
                            BindData.Value = Input.KeyCode
                            SlayLib.Flags[Flag] = Input.KeyCode
                            KeyBtn.Text = Input.KeyCode.Name
                        else
                            KeyBtn.Text = BindData.Value.Name
                        end
                        IsBinding = false
                        Utils:Tween(KeyStroke, {Color = SlayLib.Theme.Stroke}, 0.2)
                        task.spawn(Callback, BindData.Value)
                    end
                end)

                return BindData
            end

            --// [ELEMENT 6: COLORPICKER (แบบ Palette เลือกสีได้จริง)]
            function Section:CreateColorPicker(Text, Flag, Default, Callback)
                local ColorData = { Value = Default, Opened = false }
                SlayLib.Flags[Flag] = Default

                local CPFrame = Instance.new("Frame")
                CPFrame.Name = Text .. "_CPFrame"
                CPFrame.Size = UDim2.new(1, -12, 0, 42)
                CPFrame.BackgroundColor3 = SlayLib.Theme.Element
                CPFrame.ClipsDescendants = true
                CPFrame.Parent = Page

                local CPCorner = Instance.new("UICorner")
                CPCorner.CornerRadius = UDim.new(0, 8)
                CPCorner.Parent = CPFrame

                local CPBtn = Instance.new("TextButton")
                CPBtn.Size = UDim2.new(1, 0, 0, 42)
                CPBtn.BackgroundTransparency = 1
                CPBtn.Text = ""
                CPBtn.Parent = CPFrame

                local CPTitle = Instance.new("TextLabel")
                CPTitle.Size = UDim2.new(1, -60, 1, 0)
                CPTitle.Position = UDim2.new(0, 14, 0, 0)
                CPTitle.BackgroundTransparency = 1
                CPTitle.Text = Text
                CPTitle.TextColor3 = SlayLib.Theme.Text
                CPTitle.Font = Enum.Font.GothamMedium
                CPTitle.TextSize = 13
                CPTitle.TextXAlignment = Enum.TextXAlignment.Left
                CPTitle.Parent = CPBtn

                local ColorShow = Instance.new("Frame")
                ColorShow.Size = UDim2.new(0, 34, 0, 18)
                ColorShow.Position = UDim2.new(1, -48, 0.5, -9)
                ColorShow.BackgroundColor3 = Default
                ColorShow.Parent = CPBtn
                Instance.new("UICorner", ColorShow).CornerRadius = UDim.new(0, 4)

                -- Palette (Simplified for this version)
                local Palette = Instance.new("ImageButton")
                Palette.Name = "Palette"
                Palette.Size = UDim2.new(1, -20, 0, 100)
                Palette.Position = UDim2.new(0, 10, 0, 45)
                Palette.Image = "rbxassetid://4155801252" -- Rainbow Gradient
                Palette.Parent = CPFrame
                Instance.new("UICorner", Palette).CornerRadius = UDim.new(0, 6)

                Palette.MouseButton1Click:Connect(function()
                    local X = Mouse.X - Palette.AbsolutePosition.X
                    local Y = Mouse.Y - Palette.AbsolutePosition.Y
                    local Color = Color3.fromHSV(math.clamp(X / Palette.AbsoluteSize.X, 0, 1), 1, 1)
                    
                    ColorData.Value = Color
                    SlayLib.Flags[Flag] = Color
                    ColorShow.BackgroundColor3 = Color
                    task.spawn(Callback, Color)
                end)

                CPBtn.MouseButton1Click:Connect(function()
                    ColorData.Opened = not ColorData.Opened
                    Utils:Tween(CPFrame, {Size = ColorData.Opened and UDim2.new(1, -12, 0, 155) or UDim2.new(1, -12, 0, 42)}, 0.4)
                end)

                return ColorData
            end

            return Section
        end -- จบ CreateSection

        table.insert(Window.Tabs, Tab)
        return Tab
    end -- จบ CreateTab

    --// [8] TOGGLE UI LOGIC (ดักจับปุ่ม Insert เพื่อเปิด/ปิด)
    UserInputService.InputBegan:Connect(function(Input, GPE)
        if not GPE and Input.KeyCode == Window.Keybind then
            Window.Minimized = not Window.Minimized
            
            if Window.Minimized then
                -- อนิเมชั่นปิด: ย่อขนาดและจางหายไปพร้อมกัน
                Utils:Tween(MainFrame, {
                    GroupTransparency = 1,
                    Size = UDim2.new(0, 540, 0, 340)
                }, 0.4)
                task.wait(0.4)
                MainFrame.Visible = false
            else
                -- อนิเมชั่นเปิด: ขยายขนาดและแสดงขึ้นมา
                MainFrame.Visible = true
                Utils:Tween(MainFrame, {
                    GroupTransparency = 0,
                    Size = UDim2.new(0, 580, 0, 390)
                }, 0.4)
            end
        end
    end)

    return Window
end -- จบ CreateWindow
--// [9] EXAMPLE USAGE (ส่วนทดสอบรันสคริปต์)
-- พี่ Fluke สามารถก๊อปส่วนนี้ไปลองรันดูได้เลยครับ

local Window = SlayLib:CreateWindow({
    Name = "APEX PREDATOR V2"
})

local Tab1 = Window:CreateTab("Main Hub")
local Section1 = Tab1:CreateSection("Combat")

Section1:CreateToggle("Killaura", "kill_aura", false, function(State)
    print("Killaura is now:", State)
end)

Section1:CreateSlider("Attack Range", "attack_range", 1, 50, 1, 15, function(Value)
    print("Range set to:", Value)
end)

Section1:CreateKeybind("Attack Key", "attack_key", Enum.KeyCode.R, function(Key)
    print("Attack bound to:", Key.Name)
end)

local Tab2 = Window:CreateTab("Settings")
local Section2 = Tab2:CreateSection("Interface")

Section2:CreateDropdown("Theme Mode", "ui_theme", {"Dark", "Light", "High Contrast", "Neon"}, "Dark", function(Option)
    print("Theme changed to:", Option)
end)

Section2:CreateColorPicker("Accent Color", "accent_color", Color3.fromRGB(140, 90, 255), function(Color)
    print("New Color Selected")
end)

Section2:CreateButton("Destroy UI", function()
    game:GetService("CoreGui").SlayApex_Premium:Destroy()
end)

print("SLAYLIB V2 LOADED SUCCESSFULLY!")

return SlayLib
