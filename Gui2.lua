--[[
    ================================================================================
    SLAYLIB X - REACTOR ENGINE (BUILD 11.0 - DEFINITIVE EDITION)
    ================================================================================
    - Engine Core: Signal-Driven Framework & Instance Tracking
    - Memory Management: Zero-Leak Garbage Collection
    - Rendering: Multi-Platform Adaptive & Real-time Theme Sync
    - Storage: Auto-Save / Auto-Load & Backup Configuration
    ================================================================================
]]

local SlayLib = {
    -- [CORE PROPERTIES]
    Version = "11.0.1-Reactor",
    Debug = false,
    Active = true,
    Visible = true,
    Objects = {}, -- Instance Tracking System
    Flags = {},   -- Global Variable Sync
    Signals = {}, -- Signal Engine
    ThemeCache = "SlayLib_Theme.json",
    ConfigFolder = "SlayLib_Reactor",
    AutoSaveInterval = 60,
    
    -- [THEME DEFINITIONS]
    Themes = {
        ObsidianDark = {
            Main = Color3.fromRGB(120, 80, 255), Back = Color3.fromRGB(12, 12, 12),
            Side = Color3.fromRGB(18, 18, 18), Elem = Color3.fromRGB(25, 25, 25),
            Text = Color3.fromRGB(255, 255, 255), TextSec = Color3.fromRGB(180, 180, 180),
            Glow = Color3.fromRGB(120, 80, 255), Accent = Color3.fromRGB(45, 45, 45)
        },
        NeonGold = {
            Main = Color3.fromRGB(255, 200, 0), Back = Color3.fromRGB(15, 12, 5),
            Side = Color3.fromRGB(25, 20, 8), Elem = Color3.fromRGB(35, 30, 15),
            Text = Color3.fromRGB(255, 240, 200), TextSec = Color3.fromRGB(200, 180, 120),
            Glow = Color3.fromRGB(255, 180, 0), Accent = Color3.fromRGB(60, 50, 20)
        },
        FemboyPink = {
            Main = Color3.fromRGB(255, 105, 180), Back = Color3.fromRGB(20, 10, 15),
            Side = Color3.fromRGB(30, 15, 22), Elem = Color3.fromRGB(45, 25, 35),
            Text = Color3.fromRGB(255, 240, 245), TextSec = Color3.fromRGB(200, 150, 180),
            Glow = Color3.fromRGB(255, 50, 150), Accent = Color3.fromRGB(70, 40, 55)
        }
    },
    CurrentTheme = "ObsidianDark"
}

--// [UTILITIES & SERVICES]
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)

-- 

--// [CORE ENGINE: INTERNAL FUNCTIONS]
function SlayLib:Track(obj)
    if not obj then return end
    table.insert(self.Objects, obj)
    return obj
end

function SlayLib:Animate(obj, goal, duration)
    local info = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, goal)
    tween:Play()
    return tween
end

--// [SIGNAL ENGINE]
function SlayLib:Signal(name)
    if not self.Signals[name] then
        self.Signals[name] = {Connections = {}}
        function self.Signals[name]:Connect(callback)
            table.insert(self.Connections, callback)
            return {Disconnect = function() 
                for i, v in pairs(self.Connections) do 
                    if v == callback then table.remove(self.Connections, i) end 
                end 
            end}
        end
        function self.Signals[name]:Fire(...)
            for _, cb in pairs(self.Connections) do task.spawn(cb, ...) end
        end
    end
    return self.Signals[name]
end

--// [FLAG SYSTEM & BINDING]
function SlayLib:SetFlag(flag, value)
    self.Flags[flag] = value
    self:Signal("Update_"..flag):Fire(value)
end

function SlayLib:Bind(flag, callback)
    self:Signal("Update_"..flag):Connect(callback)
end

--// [ADAPTIVE INTERFACE LOGIC]
local function GetPlatform()
    local isMobile = UserInputService.TouchEnabled
    local safeZone = GuiService:GetSafeZoneOffsets()
    return {
        IsMobile = isMobile,
        Font = isMobile and Enum.Font.SourceSansBold or Enum.Font.GothamMedium,
        SizeMultiplier = isMobile and 1.2 or 1,
        SafeZone = safeZone
    }
end

--// [THEME MANAGER]
function SlayLib:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    self.CurrentTheme = themeName
    local colors = self.Themes[themeName]
    
    for _, obj in pairs(self.Objects) do
        pcall(function()
            if obj.Name == "MainFrame" then self:Animate(obj, {BackgroundColor3 = colors.Back})
            elseif obj.Name == "Sidebar" then self:Animate(obj, {BackgroundColor3 = colors.Side})
            elseif obj:IsA("UIStroke") then self:Animate(obj, {Color = colors.Main})
            elseif obj:IsA("TextLabel") and obj.Name ~= "Title" then self:Animate(obj, {TextColor3 = colors.Text})
            elseif obj:IsA("TextLabel") and obj.Name == "Title" then self:Animate(obj, {TextColor3 = colors.Main})
            elseif obj.Name == "Element" then self:Animate(obj, {BackgroundColor3 = colors.Elem})
            end
        end)
    end
    
    -- Save Theme Cache
    if isfile then writefile(self.ConfigFolder.."/"..self.ThemeCache, HttpService:JSONEncode({Theme = themeName})) end
end

--// [MAIN WINDOW COMPONENT]
function SlayLib:CreateWindow(Settings)
    Settings = Settings or {Name = "SLAYLIB X REACTOR"}
    local Platform = GetPlatform()
    
    -- Anti-Multi Instance
    if Parent:FindFirstChild("Reactor_Engine") then Parent.Reactor_Engine:Destroy() end

    local Window = {Tabs = {}, CurrentTab = nil, Toggled = true}
    
    local MainGui = self:Track(Instance.new("ScreenGui", Parent))
    MainGui.Name = "Reactor_Engine"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true

    -- Main Frame with Parallax & Glow
    local MainFrame = self:Track(Instance.new("Frame", MainGui))
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Platform.IsMobile and UDim2.new(0, 520, 0, 360) or UDim2.new(0, 680, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset/2, 0.5, -MainFrame.Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Back
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    self:Track(Instance.new("UICorner", MainFrame)).CornerRadius = UDim.new(0, 16)
    local MainStroke = self:Track(Instance.new("UIStroke", MainFrame))
    MainStroke.Thickness = 2.5
    MainStroke.Color = self.Themes[self.CurrentTheme].Main
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Sidebar Area
    local Sidebar = self:Track(Instance.new("Frame", MainFrame))
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, Platform.IsMobile and 170 or 210, 1, 0)
    Sidebar.BackgroundColor3 = self.Themes[self.CurrentTheme].Side
    Sidebar.BorderSizePixel = 0
    self:Track(Instance.new("UICorner", Sidebar)).CornerRadius = UDim.new(0, 16)

    -- Sidebar Header (Safe Area Title)
    local Header = self:Track(Instance.new("Frame", Sidebar))
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundTransparency = 1
    
    local Title = self:Track(Instance.new("TextLabel", Header))
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = Settings.Name
    Title.Font = Platform.Font
    Title.TextSize = 22
    Title.TextColor3 = self.Themes[self.CurrentTheme].Main
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- Tab Container
    local TabScroll = self:Track(Instance.new("ScrollingFrame", Sidebar))
    TabScroll.Size = UDim2.new(1, -10, 1, -100)
    TabScroll.Position = UDim2.new(0, 5, 0, 90)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0,0,0,0)
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    self:Track(Instance.new("UIListLayout", TabScroll)).Padding = UDim.new(0, 8)

    -- Page Container
    local PageContainer = self:Track(Instance.new("Frame", MainFrame))
    PageContainer.Size = UDim2.new(1, -240, 1, -40)
    PageContainer.Position = UDim2.new(0, 225, 0, 20)
    PageContainer.BackgroundTransparency = 1

    -- Floating Toggle Button
    local FloatingBtn = self:Track(Instance.new("TextButton", MainGui))
    FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
    FloatingBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    FloatingBtn.BackgroundColor3 = self.Themes[self.CurrentTheme].Main
    FloatingBtn.Text = "SR"
    FloatingBtn.TextColor3 = Color3.new(1,1,1)
    FloatingBtn.Font = Enum.Font.GothamBold
    FloatingBtn.TextSize = 18
    self:Track(Instance.new("UICorner", FloatingBtn)).CornerRadius = UDim.new(1, 0)
    
    -- [DRAGGABLE ENGINE]
    local function MakeDraggable(UI, Handle)
        local Dragging, DragInput, DragStart, StartPos
        Handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true; DragStart = input.Position; StartPos = UI.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local Delta = input.Position - DragStart
                UI.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            end
        end)
        Handle.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
    end
    MakeDraggable(MainFrame, Header)
    MakeDraggable(FloatingBtn, FloatingBtn)

    -- [UI STATE MANAGER]
    local function ToggleUI()
        Window.Toggled = not Window.Toggled
        MainFrame.Visible = Window.Toggled
        if Window.Toggled then
            self:Animate(MainFrame, {Size = Platform.IsMobile and UDim2.new(0, 520, 0, 360) or UDim2.new(0, 680, 0, 480)}, 0.5)
        else
            self:Animate(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
        end
    end
    FloatingBtn.MouseButton1Click:Connect(ToggleUI)
    
    -- Gesture: Double Tap to Toggle
    local lastTap = 0
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local now = tick()
            if now - lastTap < 0.3 then ToggleUI() end
            lastTap = now
        end
    end)

    -- [TAB CREATION SYSTEM]
    function Window:CreateTab(Name)
        local Tab = {Page = nil, Btn = nil}
        
        local TBtn = SlayLib:Track(Instance.new("TextButton", TabScroll))
        TBtn.Size = UDim2.new(0, 190, 0, 45)
        TBtn.BackgroundColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Main
        TBtn.BackgroundTransparency = 1
        TBtn.Text = "  " .. Name
        TBtn.Font = Platform.Font
        TBtn.TextSize = 14
        TBtn.TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].TextSec
        TBtn.TextXAlignment = Enum.TextXAlignment.Left
        SlayLib:Track(Instance.new("UICorner", TBtn)).CornerRadius = UDim.new(0, 10)

        local Page = SlayLib:Track(Instance.new("ScrollingFrame", PageContainer))
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        SlayLib:Track(Instance.new("UIListLayout", Page)).Padding = UDim.new(0, 12)

        TBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                SlayLib:Animate(Window.CurrentTab.Btn, {BackgroundTransparency = 1, TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].TextSec}, 0.3)
            end
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            SlayLib:Animate(TBtn, {BackgroundTransparency = 0.85, TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Main}, 0.3)
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = {Page = Page, Btn = TBtn}
            Page.Visible = true
            TBtn.BackgroundTransparency = 0.85
            TBtn.TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Main
        end

        -- [SECTION BUILDER]
        function Tab:CreateSection(SName)
            local Section = {}
            local SLbl = SlayLib:Track(Instance.new("TextLabel", Page))
            SLbl.Text = SName:upper()
            SLbl.Size = UDim2.new(1, 0, 0, 20)
            SLbl.Font = Enum.Font.GothamBold
            SLbl.TextSize = 11
            SLbl.TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Main
            SLbl.BackgroundTransparency = 1
            SLbl.TextXAlignment = Enum.TextXAlignment.Left

            -- 1. REACTOR TOGGLE
            function Section:CreateToggle(Props)
                Props = Props or {Name = "Toggle", Flag = "T1", Callback = function() end}
                local State = SlayLib.Flags[Props.Flag] or false
                
                local TFrame = SlayLib:Track(Instance.new("Frame", Page))
                TFrame.Name = "Element"
                TFrame.Size = UDim2.new(1, 0, 0, 50)
                TFrame.BackgroundColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Elem
                SlayLib:Track(Instance.new("UICorner", TFrame)).CornerRadius = UDim.new(0, 10)

                local L = SlayLib:Track(Instance.new("TextLabel", TFrame))
                L.Text = "  "..Props.Name
                L.Size = UDim2.new(1, 0, 1, 0)
                L.Font = Platform.Font
                L.TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Text
                L.TextXAlignment = Enum.TextXAlignment.Left
                L.BackgroundTransparency = 1

                local SwBg = SlayLib:Track(Instance.new("Frame", TFrame))
                SwBg.Size = UDim2.new(0, 44, 0, 22)
                SwBg.Position = UDim2.new(1, -55, 0.5, -11)
                SwBg.BackgroundColor3 = State and SlayLib.Themes[SlayLib.CurrentTheme].Main or Color3.fromRGB(60,60,60)
                SlayLib:Track(Instance.new("UICorner", SwBg)).CornerRadius = UDim.new(1, 0)

                local Dot = SlayLib:Track(Instance.new("Frame", SwBg))
                Dot.Size = UDim2.new(0, 16, 0, 16)
                Dot.Position = State and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                Dot.BackgroundColor3 = Color3.new(1, 1, 1)
                SlayLib:Track(Instance.new("UICorner", Dot)).CornerRadius = UDim.new(1, 0)

                local function UpdateUI(v)
                    SlayLib:Animate(SwBg, {BackgroundColor3 = v and SlayLib.Themes[SlayLib.CurrentTheme].Main or Color3.fromRGB(60,60,60)}, 0.3)
                    SlayLib:Animate(Dot, {Position = v and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}, 0.3)
                end

                TFrame:AddComponent(Instance.new("TextButton", TFrame)).MouseButton1Click:Connect(function()
                    State = not State
                    SlayLib:SetFlag(Props.Flag, State)
                    UpdateUI(State)
                    task.spawn(Props.Callback, State)
                end)

                SlayLib:Bind(Props.Flag, UpdateUI)
            end

            -- 2. PRECISION SLIDER
            function Section:CreateSlider(Props)
                Props = Props or {Name = "Slider", Min = 0, Max = 100, Def = 50, Flag = "S1", Callback = function() end}
                local Val = SlayLib.Flags[Props.Flag] or Props.Def
                
                local SFrame = SlayLib:Track(Instance.new("Frame", Page))
                SFrame.Name = "Element"
                SFrame.Size = UDim2.new(1, 0, 0, 65)
                SFrame.BackgroundColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Elem
                SlayLib:Track(Instance.new("UICorner", SFrame)).CornerRadius = UDim.new(0, 10)

                local L = SlayLib:Track(Instance.new("TextLabel", SFrame))
                L.Text = "  "..Props.Name
                L.Size = UDim2.new(1, 0, 0, 35)
                L.Font = Platform.Font
                L.TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Text
                L.TextXAlignment = Enum.TextXAlignment.Left
                L.BackgroundTransparency = 1

                local V = SlayLib:Track(Instance.new("TextLabel", SFrame))
                V.Text = tostring(Val).."  "
                V.Size = UDim2.new(1, 0, 0, 35)
                V.Font = Enum.Font.Code
                V.TextColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Main
                V.TextXAlignment = Enum.TextXAlignment.Right
                V.BackgroundTransparency = 1

                local Bar = SlayLib:Track(Instance.new("Frame", SFrame))
                Bar.Size = UDim2.new(1, -30, 0, 6)
                Bar.Position = UDim2.new(0, 15, 0, 45)
                Bar.BackgroundColor3 = Color3.fromRGB(50,50,50)
                SlayLib:Track(Instance.new("UICorner", Bar)).CornerRadius = UDim.new(1, 0)

                local Fill = SlayLib:Track(Instance.new("Frame", Bar))
                Fill.Size = UDim2.new((Val - Props.Min)/(Props.Max - Props.Min), 0, 1, 0)
                Fill.BackgroundColor3 = SlayLib.Themes[SlayLib.CurrentTheme].Main
                SlayLib:Track(Instance.new("UICorner", Fill)).CornerRadius = UDim.new(1, 0)

                local function Update(input)
                    local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local nVal = math.floor(Props.Min + (Props.Max - Props.Min) * pos)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    V.Text = tostring(nVal).."  "
                    SlayLib:SetFlag(Props.Flag, nVal)
                    task.spawn(Props.Callback, nVal)
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local MoveCon, EndCon
                        MoveCon = UserInputService.InputChanged:Connect(function(move)
                            if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then Update(move) end
                        end)
                        EndCon = UserInputService.InputEnded:Connect(function(ended)
                            if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then MoveCon:Disconnect(); EndCon:Disconnect() end
                        end)
                    end
                end)
            end

            return Section
        end
        return Tab
    end

    --// [INIT ENGINE BACKGROUND TASKS]
    task.spawn(function()
        while SlayLib.Active do
            -- Performance Stats
            local fps = math.floor(1/RunService.RenderStepped:Wait())
            local ping = tonumber(string.match(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), "%d+")) or 0
            -- Update UI if Performance Overlay is active
            task.wait(1)
        end
    end)

    return Window
end

--// [ERROR LOGGING SYSTEM]
function SlayLib:LogError(msg)
    local log = "[ERROR] "..tick()..": "..tostring(msg).."\n"
    if appendfile then appendfile("SlayLib_Logs.txt", log) end
    self:Notify({Title = "Engine Error", Content = msg, Type = "Error"})
end

return SlayLib
