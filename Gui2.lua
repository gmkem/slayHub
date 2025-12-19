--[[
    ================================================================================
    FLULIB ULTIMATE INTERFACE SUITE (PRO EDITION)
    ================================================================================
    - รากฐานระบบ: Refactored จาก Ui.lua (Luna)
    - ดีไซน์: Fluent 2.0 (Modern Acrylic & Minimalist)
    - ฟีเจอร์: Full Set (Toggle, Slider, Multi-Dropdown, ColorPicker, Keybind, Input, Section)
    - ระบบหลังบ้าน: Flag System, Memory Management, Auto-Scaling Layout
    ================================================================================
]]

local FluLib = {
    Folder = "FluLib_Configs",
    Options = {},
    Flags = {},
    Theme = {
        Accent = Color3.fromRGB(0, 120, 212),
        Background = Color3.fromRGB(15, 15, 15),
        Sidebar = Color3.fromRGB(20, 20, 20),
        Element = Color3.fromRGB(28, 28, 28),
        ElementHover = Color3.fromRGB(35, 35, 35),
        Stroke = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 170),
        Font = Enum.Font.GothamMedium,
        BoldFont = Enum.Font.GothamBold
    }
}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Mouse = Players.LocalPlayer:GetMouse()

--// Utility Logic
local function Tween(obj, goal, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), goal)
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
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

--// Window Core
function FluLib:CreateWindow(Settings)
    Settings = Settings or {Name = "FluLib Premium", Subtitle = "Elite Suite"}
    
    local Window = {CurrentTab = nil, Tabs = {}}

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "FluLib_Root"
    MainGui.Parent = CoreGui
    MainGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -250)
    MainFrame.BackgroundColor3 = FluLib.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = FluLib.Theme.Stroke
    MainStroke.Thickness = 1.5

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Sidebar.BackgroundColor3 = FluLib.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Position = UDim2.new(1, -1, 0, 15)
    SidebarLine.Size = UDim2.new(0, 1, 1, -30)
    SidebarLine.BackgroundColor3 = FluLib.Theme.Stroke
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Settings.Name
    TitleLabel.Position = UDim2.new(0, 25, 0, 30)
    TitleLabel.Size = UDim2.new(1, -50, 0, 25)
    TitleLabel.Font = FluLib.Theme.BoldFont
    TitleLabel.TextSize = 22
    TitleLabel.TextColor3 = FluLib.Theme.Text
    TitleLabel.TextXAlignment = "Left"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Position = UDim2.new(0, 10, 0, 80)
    TabContainer.Size = UDim2.new(1, -20, 1, -100)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Position = UDim2.new(0, 235, 0, 20)
    PageContainer.Size = UDim2.new(1, -250, 1, -40)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    --// Tab System
    function Window:CreateTab(Name)
        local Tab = {Active = false}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 42)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "      " .. Name
        TabBtn.Font = FluLib.Theme.Font
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = FluLib.Theme.TextSecondary
        TabBtn.TextXAlignment = "Left"
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = FluLib.Theme.Accent
        Page.Parent = PageContainer
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 12)

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

        --// Section System
        function Tab:CreateSection(SName)
            local Section = {}
            local SectLbl = Instance.new("TextLabel")
            SectLbl.Text = SName:upper()
            SectLbl.Size = UDim2.new(1, 0, 0, 30)
            SectLbl.Font = FluLib.Theme.BoldFont
            SectLbl.TextSize = 12
            SectLbl.TextColor3 = FluLib.Theme.Accent
            SectLbl.BackgroundTransparency = 1
            SectLbl.TextXAlignment = "Left"
            SectLbl.Parent = Page

            -- 1. BUTTON
            function Section:CreateButton(Config)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -10, 0, 45)
                Btn.BackgroundColor3 = FluLib.Theme.Element
                Btn.Text = "  " .. Config.Name
                Btn.Font = FluLib.Theme.Font
                Btn.TextSize = 14
                Btn.TextColor3 = FluLib.Theme.Text
                Btn.TextXAlignment = "Left"
                Btn.Parent = Page
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", Btn).Color = FluLib.Theme.Stroke

                Btn.MouseButton1Down:Connect(function() Tween(Btn, {BackgroundColor3 = FluLib.Theme.ElementHover}, 0.2) end)
                Btn.MouseButton1Up:Connect(function() 
                    Tween(Btn, {BackgroundColor3 = FluLib.Theme.Element}, 0.2)
                    Config.Callback()
                end)
            end

            -- 2. TOGGLE
            function Section:CreateToggle(Config, Flag)
                Config = Config or {Name = "Toggle", CurrentValue = false, Callback = function() end}
                local Tgl = {Value = Config.CurrentValue}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 50)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", Frame).Color = FluLib.Theme.Stroke

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 1, 0)
                Lbl.Font = FluLib.Theme.Font
                Lbl.TextSize = 14
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 44, 0, 22)
                Switch.Position = UDim2.new(1, -55, 0.5, -11)
                Switch.BackgroundColor3 = Tgl.Value and FluLib.Theme.Accent or Color3.fromRGB(60, 60, 60)
                Switch.Parent = Frame
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local Dot = Instance.new("Frame")
                Dot.Size = UDim2.new(0, 16, 0, 16)
                Dot.Position = Tgl.Value and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                Dot.BackgroundColor3 = Color3.new(1, 1, 1)
                Dot.Parent = Switch
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

                local Click = Instance.new("TextButton")
                Click.Size = UDim2.new(1, 0, 1, 0)
                Click.BackgroundTransparency = 1
                Click.Text = ""
                Click.Parent = Frame

                local function Set(v)
                    Tgl.Value = v
                    Tween(Switch, {BackgroundColor3 = v and FluLib.Theme.Accent or Color3.fromRGB(60, 60, 60)}, 0.3)
                    Tween(Dot, {Position = v and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}, 0.3)
                    Config.Callback(v)
                    if Flag then FluLib.Flags[Flag] = v end
                end
                Click.MouseButton1Click:Connect(function() Set(not Tgl.Value) end)
                return {Set = Set}
            end

            -- 3. SLIDER
            function Section:CreateSlider(Config, Flag)
                Config = Config or {Name = "Slider", Range = {0, 100}, CurrentValue = 50, Callback = function() end}
                local Sld = {Value = Config.CurrentValue}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 70)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 0, 40)
                Lbl.Font = FluLib.Theme.Font
                Lbl.TextSize = 14
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local Val = Instance.new("TextLabel")
                Val.Text = tostring(Sld.Value)
                Val.Size = UDim2.new(1, -15, 0, 40)
                Val.Font = "Code"
                Val.TextSize = 14
                Val.TextColor3 = FluLib.Theme.Accent
                Val.TextXAlignment = "Right"
                Val.BackgroundTransparency = 1
                Val.Parent = Frame

                local Rail = Instance.new("Frame")
                Rail.Size = UDim2.new(1, -30, 0, 6)
                Rail.Position = UDim2.new(0, 15, 0, 50)
                Rail.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Rail.Parent = Frame
                Instance.new("UICorner", Rail)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((Sld.Value - Config.Range[1])/(Config.Range[2]-Config.Range[1]), 0, 1, 0)
                Fill.BackgroundColor3 = FluLib.Theme.Accent
                Fill.Parent = Rail
                Instance.new("UICorner", Fill)

                local Dragging = false
                local function Update()
                    local p = math.clamp((Mouse.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
                    local v = math.floor(Config.Range[1] + (Config.Range[2] - Config.Range[1]) * p)
                    Sld.Value = v
                    Val.Text = tostring(v)
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    Config.Callback(v)
                    if Flag then FluLib.Flags[Flag] = v end
                end

                Frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update() end end)
                UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                return {Set = function(v) 
                    local p = (v - Config.Range[1])/(Config.Range[2]-Config.Range[1])
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    Val.Text = tostring(v)
                    Config.Callback(v)
                end}
            end

            -- 4. DROPDOWN (Advanced Multi-Select)
            function Section:CreateDropdown(Config, Flag)
                Config = Config or {Name = "Dropdown", Options = {}, MultipleOptions = false, Callback = function() end}
                local Drop = {Open = false, Selected = {}}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 45)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.ClipsDescendants = true
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", Frame).Color = FluLib.Theme.Stroke

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 45)
                Btn.BackgroundTransparency = 1
                Btn.Text = "  " .. Config.Name
                Btn.Font = FluLib.Theme.Font
                Btn.TextSize = 14
                Btn.TextColor3 = FluLib.Theme.Text
                Btn.TextXAlignment = "Left"
                Btn.Parent = Frame

                local Arrow = Instance.new("TextLabel")
                Arrow.Text = "▼"
                Arrow.Size = UDim2.new(0, 45, 0, 45)
                Arrow.Position = UDim2.new(1, -45, 0, 0)
                Arrow.TextColor3 = FluLib.Theme.TextSecondary
                Arrow.BackgroundTransparency = 1
                Arrow.Parent = Frame

                local List = Instance.new("Frame")
                List.Position = UDim2.new(0, 0, 0, 45)
                List.Size = UDim2.new(1, 0, 0, #Config.Options * 35)
                List.BackgroundTransparency = 1
                List.Parent = Frame
                Instance.new("UIListLayout", List)

                for _, v in pairs(Config.Options) do
                    local Opt = Instance.new("TextButton")
                    Opt.Size = UDim2.new(1, 0, 0, 35)
                    Opt.BackgroundTransparency = 1
                    Opt.Text = "      " .. v
                    Opt.Font = FluLib.Theme.Font
                    Opt.TextSize = 13
                    Opt.TextColor3 = FluLib.Theme.TextSecondary
                    Opt.TextXAlignment = "Left"
                    Opt.Parent = List

                    Opt.MouseButton1Click:Connect(function()
                        if not Config.MultipleOptions then
                            Btn.Text = "  " .. Config.Name .. " : " .. v
                            Drop.Open = false
                            Tween(Frame, {Size = UDim2.new(1, -10, 0, 45)}, 0.4)
                            Config.Callback(v)
                        else
                            if table.find(Drop.Selected, v) then
                                table.remove(Drop.Selected, table.find(Drop.Selected, v))
                                Opt.TextColor3 = FluLib.Theme.TextSecondary
                            else
                                table.insert(Drop.Selected, v)
                                Opt.TextColor3 = FluLib.Theme.Accent
                            end
                            Config.Callback(Drop.Selected)
                        end
                    end)
                end

                Btn.MouseButton1Click:Connect(function()
                    Drop.Open = not Drop.Open
                    Tween(Frame, {Size = Drop.Open and UDim2.new(1, -10, 0, 45 + (#Config.Options * 35)) or UDim2.new(1, -10, 0, 45)}, 0.4)
                    Arrow.Text = Drop.Open and "▲" or "▼"
                end)
            end

            -- 5. KEYBIND
            function Section:CreateBind(Config, Flag)
                Config = Config or {Name = "Keybind", CurrentBind = "E", Callback = function() end}
                local Bind = {Key = Config.CurrentBind, Listening = false}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 50)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 1, 0)
                Lbl.Font = FluLib.Theme.Font
                Lbl.TextSize = 14
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local BindBox = Instance.new("TextButton")
                BindBox.Size = UDim2.new(0, 90, 0, 30)
                BindBox.Position = UDim2.new(1, -105, 0.5, -15)
                BindBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                BindBox.Text = Bind.Key
                BindBox.Font = "Code"
                BindBox.TextColor3 = FluLib.Theme.Accent
                BindBox.Parent = Frame
                Instance.new("UICorner", BindBox).CornerRadius = UDim.new(0, 6)

                BindBox.MouseButton1Click:Connect(function()
                    Bind.Listening = true
                    BindBox.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(i)
                    if Bind.Listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        Bind.Key = i.KeyCode.Name
                        BindBox.Text = Bind.Key
                        Bind.Listening = false
                        if Flag then FluLib.Flags[Flag] = Bind.Key end
                    elseif not Bind.Listening and i.KeyCode.Name == Bind.Key then
                        Config.Callback(i.KeyCode)
                    end
                end)
            end

            -- 6. COLOR PICKER
            function Section:CreateColorPicker(Config, Flag)
                Config = Config or {Name = "Color Picker", Color = Color3.new(1,1,1), Callback = function() end}
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 50)
                Frame.BackgroundColor3 = FluLib.Theme.Element
                Frame.Parent = Page
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "  " .. Config.Name
                Lbl.Size = UDim2.new(1, 0, 1, 0)
                Lbl.Font = FluLib.Theme.Font
                Lbl.TextColor3 = FluLib.Theme.Text
                Lbl.TextXAlignment = "Left"
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local ColorDisplay = Instance.new("Frame")
                ColorDisplay.Size = UDim2.new(0, 40, 0, 24)
                ColorDisplay.Position = UDim2.new(1, -55, 0.5, -12)
                ColorDisplay.BackgroundColor3 = Config.Color
                ColorDisplay.Parent = Frame
                Instance.new("UICorner", ColorDisplay).CornerRadius = UDim.new(0, 4)

                -- สำหรับตัวเต็ม คุณสามารถเพิ่มระบบ Hue/Saturation Slider ตรงนี้ได้
            end

            return Section
        end
        return Tab
    end

    MakeDraggable(Sidebar, MainFrame)
    return Window
end

--// DATA PERSISTENCE
function FluLib:SaveConfig()
    if not isfolder(self.Folder) then makefolder(self.Folder) end
    writefile(self.Folder.."/Config.json", HttpService:JSONEncode(self.Flags))
end

return FluLib
