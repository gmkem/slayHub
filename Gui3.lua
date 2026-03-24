--[[
    SLAYLIB V2 - APEX PREDATOR (GRAND EDITION)
    PART 1: FOUNDATION & ENGINE
    User: Flukito (Fluke)
    Status: 10/10 Polish & Anti-Duplicate
]]

local SlayLib = {
    Flags = {},
    Elements = {},
    Folder = "SlayLib_V2",
    Theme = {
        Main = Color3.fromRGB(140, 90, 255),
        BG = Color3.fromRGB(15, 15, 17),
        Sidebar = Color3.fromRGB(20, 20, 23),
        Element = Color3.fromRGB(28, 28, 32),
        Stroke = Color3.fromRGB(45, 45, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 165)
    }
}

--// [1] ANTI-REEXECUTE (ระบบล้าง GUI เก่าก่อนเริ่มใหม่)
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

for _, oldUI in pairs(CoreGui:GetChildren()) do
    if oldUI.Name == "SlayApex_Root" then
        oldUI:Destroy()
    end
end

--// [2] UTILS ENGINE (แยกฟังก์ชันเพื่อเพิ่มจำนวนบรรทัดและระเบียบ)
local Utils = {}
do
    function Utils:Tween(obj, goal, t)
        local info = TweenInfo.new(
            t or 0.3, 
            Enum.EasingStyle.Quart, 
            Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(obj, info, goal)
        tween:Play()
        return tween
    end

    function Utils:Ripple(obj)
        task.spawn(function()
            local Circle = Instance.new("ImageLabel")
            Circle.Parent = obj
            Circle.BackgroundColor3 = Color3.new(1, 1, 1)
            Circle.BackgroundTransparency = 0.8
            Circle.ZIndex = 10
            Circle.Image = "rbxassetid://266543268"
            Circle.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
            Circle.Size = UDim2.new(0, 0, 0, 0)
            Circle.AnchorPoint = Vector2.new(0.5, 0.5)
            
            Utils:Tween(Circle, {
                Size = UDim2.new(0, 200, 0, 200), 
                ImageTransparency = 1
            }, 0.5)
            
            task.wait(0.5)
            Circle:Destroy()
        end)
    end
end

--// [3] MAIN WINDOW SYSTEM
function SlayLib:CreateWindow(Config)
    Config = Config or {}
    Config.Name = Config.Name or "SLAY APEX"
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Closed = false
    }

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "SlayApex_Root"
    Screen.IgnoreGuiInset = true
    Screen.DisplayOrder = 100
    Screen.Parent = CoreGui

    -- CanvasGroup สำหรับคุม Animation ทั้งแผง (ปิดพร้อมกัน)
    local Main = Instance.new("CanvasGroup")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 580, 0, 380)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = SlayLib.Theme.BG
    Main.GroupTransparency = 1
    Main.ClipsDescendants = true
    Main.Parent = Screen
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = SlayLib.Theme.Stroke
    MainStroke.Thickness = 1.2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = Main

    -- อนิเมชั่นตอนเปิด (Fade In + Pop Up)
    Main.Size = UDim2.new(0, 540, 0, 340)
    Utils:Tween(Main, {
        GroupTransparency = 0, 
        Size = UDim2.new(0, 580, 0, 380)
    }, 0.5)

    -- Sidebar Area
    local Side = Instance.new("Frame")
    Side.Name = "Sidebar"
    Side.Size = UDim2.new(0, 170, 1, 0)
    Side.BackgroundColor3 = SlayLib.Theme.Sidebar
    Side.BorderSizePixel = 0
    Side.Parent = Main

    local Logo = Instance.new("TextLabel")
    Logo.Name = "Logo"
    Logo.Text = Config.Name
    Logo.Size = UDim2.new(1, 0, 0, 50)
    Logo.Position = UDim2.new(0, 0, 0, 5)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextColor3 = SlayLib.Theme.Main
    Logo.TextSize = 17
    Logo.BackgroundTransparency = 1
    Logo.Parent = Side

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 55)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Side

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer

    -- Page Area (Container)
    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Size = UDim2.new(1, -185, 1, -20)
    Pages.Position = UDim2.new(0, 178, 0, 10)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    --// ระบบ Toggle UI ด้วยปุ่ม Insert
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Insert then
            Window.Closed = not Window.Closed
            if Window.Closed then
                Utils:Tween(Main, {
                    GroupTransparency = 1, 
                    Size = UDim2.new(0, 540, 0, 340)
                }, 0.3)
                task.wait(0.3)
                Main.Visible = false
            else
                Main.Visible = true
                Utils:Tween(Main, {
                    GroupTransparency = 0, 
                    Size = UDim2.new(0, 580, 0, 380)
                }, 0.3)
            end
        end
    end)

-- [[ ส่วนต่อไปคือฟังก์ชัน CreateTab และการสร้าง Elements ย่อย ]]
    --// [4] TAB & PAGE ENGINE
    function Window:CreateTab(Name, IconID)
        local Tab = {
            Active = false,
            Button = nil,
            Page = nil,
            Sections = {}
        }

        -- Tab Button Construction
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = Name .. "_Tab"
        TabBtn.Size = UDim2.new(0, 150, 0, 36)
        TabBtn.BackgroundColor3 = SlayLib.Theme.Main
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabBtn

        local TabTitle = Instance.new("TextLabel")
        TabTitle.Name = "Title"
        TabTitle.Size = UDim2.new(1, 0, 1, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = Name
        TabTitle.TextColor3 = SlayLib.Theme.TextDark
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 13
        TabTitle.Parent = TabBtn

        -- Page Construction
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = SlayLib.Theme.Main
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = Pages

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 10)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.Parent = Page

        -- Auto Canvas Size
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end)

        Tab.Page = Page
        Tab.Button = TabBtn

        -- Tab Click Logic
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                Utils:Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
                Utils:Tween(t.Button.Title, {TextColor3 = SlayLib.Theme.TextDark}, 0.2)
            end
            Page.Visible = true
            Utils:Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.2)
            Utils:Tween(TabTitle, {TextColor3 = SlayLib.Theme.Main}, 0.2)
        end)

        --// [5] SECTION CREATION (FIXED STRUCTURE)
        function Tab:CreateSection(SectionName)
            local Section = { Elements = {} }

            local SecFrame = Instance.new("Frame")
            SecFrame.Name = SectionName .. "_Section"
            SecFrame.Size = UDim2.new(1, -5, 0, 25)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Page

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Name = "Title"
            SecTitle.Size = UDim2.new(1, 0, 1, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Text = string.upper(SectionName)
            SecTitle.TextColor3 = SlayLib.Theme.Main
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 11
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Parent = SecFrame

            --// [ELEMENT: BUTTON]
            function Section:CreateButton(Text, Callback)
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Name = Text .. "_Button"
                BtnFrame.Size = UDim2.new(1, -10, 0, 38)
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
                BtnStroke.Thickness = 1
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

                BtnFrame.MouseEnter:Connect(function()
                    Utils:Tween(BtnStroke, {Color = SlayLib.Theme.Main}, 0.2)
                end)

                BtnFrame.MouseLeave:Connect(function()
                    Utils:Tween(BtnStroke, {Color = SlayLib.Theme.Stroke}, 0.2)
                end)

                BtnFrame.MouseButton1Click:Connect(function()
                    Utils:Ripple(BtnFrame)
                    task.spawn(Callback)
                end)
            end

            --// [ELEMENT: TOGGLE]
            function Section:CreateToggle(Text, Flag, Callback)
                local Toggle = { State = false }
                SlayLib.Flags[Flag] = false

                local TglFrame = Instance.new("TextButton")
                TglFrame.Name = Text .. "_Toggle"
                TglFrame.Size = UDim2.new(1, -10, 0, 42)
                TglFrame.BackgroundColor3 = SlayLib.Theme.Element
                TglFrame.AutoButtonColor = false
                TglFrame.Text = ""
                TglFrame.Parent = Page

                local TglCorner = Instance.new("UICorner")
                TglCorner.CornerRadius = UDim.new(0, 8)
                TglCorner.Parent = TglFrame

                local TglTitle = Instance.new("TextLabel")
                TglTitle.Size = UDim2.new(1, -60, 1, 0)
                TglTitle.Position = UDim2.new(0, 12, 0, 0)
                TglTitle.BackgroundTransparency = 1
                TglTitle.Text = Text
                TglTitle.TextColor3 = SlayLib.Theme.TextDark
                TglTitle.Font = Enum.Font.GothamMedium
                TglTitle.TextSize = 13
                TglTitle.TextXAlignment = Enum.TextXAlignment.Left
                TglTitle.Parent = TglFrame

                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 34, 0, 18)
                Box.Position = UDim2.new(1, -45, 0.5, 0)
                Box.AnchorPoint = Vector2.new(0, 0.5)
                Box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                Box.Parent = TglFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(1, 0)
                BoxCorner.Parent = Box

                local Dot = Instance.new("Frame")
                Dot.Size = UDim2.new(0, 12, 0, 12)
                Dot.Position = UDim2.new(0, 3, 0.5, 0)
                Dot.AnchorPoint = Vector2.new(0, 0.5)
                Dot.BackgroundColor3 = Color3.new(1, 1, 1)
                Dot.Parent = Box

                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(1, 0)
                DotCorner.Parent = Dot

                local function Set(Val)
                    Toggle.State = Val
                    SlayLib.Flags[Flag] = Val
                    Utils:Tween(Box, {BackgroundColor3 = Val and SlayLib.Theme.Main or Color3.fromRGB(45, 45, 50)}, 0.2)
                    Utils:Tween(Dot, {Position = Val and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.2)
                    Utils:Tween(TglTitle, {TextColor3 = Val and SlayLib.Theme.Text or SlayLib.Theme.TextDark}, 0.2)
                    task.spawn(Callback, Val)
                end

                TglFrame.MouseButton1Click:Connect(function()
                    Set(not Toggle.State)
                end)

                return Toggle
            end

            -- [[ ส่วนที่คัดออกเพื่อรอส่งต่อ: Slider, Dropdown และตอนจบของ Script ]]
            --// [ELEMENT: SLIDER]
            function Section:CreateSlider(Text, Flag, Min, Max, Dec, Default, Callback)
                local Slider = { Value = Default or Min }
                SlayLib.Flags[Flag] = Slider.Value

                local SldFrame = Instance.new("Frame")
                SldFrame.Name = Text .. "_Slider"
                SldFrame.Size = UDim2.new(1, -10, 0, 50)
                SldFrame.BackgroundColor3 = SlayLib.Theme.Element
                SldFrame.BorderSizePixel = 0
                SldFrame.Parent = Page

                local SldCorner = Instance.new("UICorner")
                SldCorner.CornerRadius = UDim.new(0, 8)
                SldCorner.Parent = SldFrame

                local SldTitle = Instance.new("TextLabel")
                SldTitle.Name = "Title"
                SldTitle.Size = UDim2.new(1, -100, 0, 30)
                SldTitle.Position = UDim2.new(0, 12, 0, 2)
                SldTitle.BackgroundTransparency = 1
                SldTitle.Text = Text
                SldTitle.TextColor3 = SlayLib.Theme.Text
                SldTitle.Font = Enum.Font.GothamMedium
                SldTitle.TextSize = 13
                SldTitle.TextXAlignment = Enum.TextXAlignment.Left
                SldTitle.Parent = SldFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "Value"
                ValueLabel.Size = UDim2.new(0, 60, 0, 30)
                ValueLabel.Position = UDim2.new(1, -72, 0, 2)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(Slider.Value)
                ValueLabel.TextColor3 = SlayLib.Theme.Main
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextSize = 13
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SldFrame

                local SliderBar = Instance.new("TextButton")
                SliderBar.Name = "Bar"
                SliderBar.Size = UDim2.new(1, -24, 0, 6)
                SliderBar.Position = UDim2.new(0, 12, 1, -14)
                SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                SliderBar.BorderSizePixel = 0
                SliderBar.Text = ""
                SliderBar.AutoButtonColor = false
                SliderBar.Parent = SldFrame

                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = SliderBar

                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new((Slider.Value - Min) / (Max - Min), 0, 1, 0)
                SliderFill.BackgroundColor3 = SlayLib.Theme.Main
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill

                local function Update(Input)
                    local Pos = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local Val = (Max - Min) * Pos + Min
                    
                    if Dec then
                        Val = string.format("%." .. Dec .. "f", Val)
                    else
                        Val = math.floor(Val)
                    end
                    
                    Slider.Value = Val
                    SlayLib.Flags[Flag] = Val
                    ValueLabel.Text = tostring(Val)
                    Utils:Tween(SliderFill, {Size = UDim2.new(Pos, 0, 1, 0)}, 0.1)
                    task.spawn(Callback, Val)
                end

                local Dragging = false
                SliderBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Update(Input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(Input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)

                return Slider
            end

            --// [ELEMENT: DROPDOWN]
            function Section:CreateDropdown(Text, Flag, Options, Default, Callback)
                local Dropdown = { Value = Default or Options[1], Options = Options, Open = false }
                SlayLib.Flags[Flag] = Dropdown.Value

                local DrpFrame = Instance.new("Frame")
                DrpFrame.Name = Text .. "_Dropdown"
                DrpFrame.Size = UDim2.new(1, -10, 0, 42)
                DrpFrame.BackgroundColor3 = SlayLib.Theme.Element
                DrpFrame.ClipsDescendants = true
                DrpFrame.Parent = Page

                local DrpCorner = Instance.new("UICorner")
                DrpCorner.CornerRadius = UDim.new(0, 8)
                DrpCorner.Parent = DrpFrame

                local DrpBtn = Instance.new("TextButton")
                DrpBtn.Size = UDim2.new(1, 0, 0, 42)
                DrpBtn.BackgroundTransparency = 1
                DrpBtn.Text = ""
                DrpBtn.Parent = DrpFrame

                local DrpTitle = Instance.new("TextLabel")
                DrpTitle.Size = UDim2.new(1, -40, 1, 0)
                DrpTitle.Position = UDim2.new(0, 12, 0, 0)
                DrpTitle.BackgroundTransparency = 1
                DrpTitle.Text = Text .. " : " .. tostring(Dropdown.Value)
                DrpTitle.TextColor3 = SlayLib.Theme.Text
                DrpTitle.Font = Enum.Font.GothamMedium
                DrpTitle.TextSize = 13
                DrpTitle.TextXAlignment = Enum.TextXAlignment.Left
                DrpTitle.Parent = DrpBtn

                local OptionHolder = Instance.new("Frame")
                OptionHolder.Name = "Holder"
                OptionHolder.Size = UDim2.new(1, -10, 0, 0)
                OptionHolder.Position = UDim2.new(0, 5, 0, 45)
                OptionHolder.BackgroundTransparency = 1
                OptionHolder.Parent = DrpFrame

                local OptionLayout = Instance.new("UIListLayout")
                OptionLayout.Padding = UDim.new(0, 4)
                OptionLayout.Parent = OptionHolder

                local function Refresh()
                    for _, v in pairs(OptionHolder:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end

                    for _, opt in pairs(Dropdown.Options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, 0, 0, 32)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                        OptBtn.Text = opt
                        OptBtn.TextColor3 = SlayLib.Theme.TextDark
                        OptBtn.Font = "Gotham"
                        OptBtn.TextSize = 12
                        OptBtn.Parent = OptionHolder
                        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6)

                        OptBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value = opt
                            SlayLib.Flags[Flag] = opt
                            DrpTitle.Text = Text .. " : " .. opt
                            Dropdown.Open = false
                            Utils:Tween(DrpFrame, {Size = UDim2.new(1, -10, 0, 42)}, 0.3)
                            task.spawn(Callback, opt)
                        end)
                    end
                end

                DrpBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    if Dropdown.Open then
                        Refresh()
                        local Size = 48 + (#Dropdown.Options * 36)
                        Utils:Tween(DrpFrame, {Size = UDim2.new(1, -10, 0, math.min(Size, 200))}, 0.3)
                    else
                        Utils:Tween(DrpFrame, {Size = UDim2.new(1, -10, 0, 42)}, 0.3)
                    end
                end)

                return Dropdown
            end

            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

return SlayLib
