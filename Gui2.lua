local SlayLib = {
    Folder = "SlayLib_Config",
    Settings = {},
    Flags = {},
    Signals = {},
    ThemeObjects = {}, -- สำหรับระบบ Real-time Theme Update
    Theme = {
        MainColor = Color3.fromRGB(120, 80, 255),
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(25, 25, 25),
        ElementHover = Color3.fromRGB(32, 32, 32),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Stroke = Color3.fromRGB(45, 45, 45),
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

--// Environment Variables
local LocalPlayer = Players.LocalPlayer
local Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)

--// Folder Management
if not isfolder(SlayLib.Folder) then makefolder(SlayLib.Folder) end

--// UTILITY FUNCTIONS
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function Tween(obj, goal, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), goal)
    t:Play()
    return t
end

local function ApplyTextLogic(label, content, maxSize)
    label.Text = content
    label.TextWrapped = true
    label.TextSize = maxSize or 14
    local function Adjust()  
        label.TextScaled = (label.TextBounds.X > label.AbsoluteSize.X or label.TextBounds.Y > label.AbsoluteSize.Y)
    end  
    label:GetPropertyChangedSignal("AbsoluteSize"):Connect(Adjust)  
    Adjust()
end

--// THEME ENGINE (REAL-TIME UPDATE)
function SlayLib:UpdateTheme(NewColor)
    self.Theme.MainColor = NewColor
    for obj, type in pairs(self.ThemeObjects) do
        if obj and obj.Parent then
            if type == "Background" then Tween(obj, {BackgroundColor3 = NewColor}, 0.3)
            elseif type == "Text" then Tween(obj, {TextColor3 = NewColor}, 0.3)
            elseif type == "Stroke" then Tween(obj, {Color = NewColor}, 0.3)
            elseif type == "Image" then Tween(obj, {ImageColor3 = NewColor}, 0.3) end
        else
            self.ThemeObjects[obj] = nil
        end
    end
end

--// NEW NOTIFICATION SYSTEM (STACKABLE)
function SlayLib:Notify(Config)
    Config = Config or {Title = "Notification", Content = "Message", Duration = 5, Type = "Neutral"}
    
    local Holder = Parent:FindFirstChild("SlayNotificationProvider")  
    if not Holder then  
        Holder = Create("Frame", {  
            Name = "SlayNotificationProvider", Parent = Parent, BackgroundTransparency = 1,  
            Size = UDim2.new(0, 320, 1, -40), Position = UDim2.new(1, -330, 0, 20)  
        })  
        Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 10)})  
    end  

    local NotifColor = SlayLib.Theme.MainColor
    if Config.Type == "Success" then NotifColor = SlayLib.Theme.Success  
    elseif Config.Type == "Error" then NotifColor = SlayLib.Theme.Error  
    elseif Config.Type == "Warning" then NotifColor = SlayLib.Theme.Warning end  

    local NotifFrame = Create("Frame", {  
        Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Sidebar,  
        ClipsDescendants = true, Parent = Holder, BackgroundTransparency = 1  
    })  
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = NotifFrame})  
    local Stroke = Create("UIStroke", {Color = NotifColor, Thickness = 1.8, Parent = NotifFrame})
    
    local TitleLabel = Create("TextLabel", {  
        Size = UDim2.new(1, -30, 0, 25), Position = UDim2.new(0, 15, 0, 8),  
        Font = "GothamBold", TextColor3 = NotifColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = NotifFrame  
    })  
    ApplyTextLogic(TitleLabel, Config.Title, 14)  

    local ContentLabel = Create("TextLabel", {  
        Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 28),  
        Font = "Gotham", TextColor3 = SlayLib.Theme.Text, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = NotifFrame  
    })  
    ApplyTextLogic(ContentLabel, Config.Content, 12)  

    Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 75), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)  

    task.delay(Config.Duration, function()  
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.5)  
        task.wait(0.5) NotifFrame:Destroy()  
    end)
end

--// DRAGGING SYSTEM
local function RegisterDrag(Frame, Handle)
    local Dragging, DragInput, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
            Dragging = true DragStart = input.Position StartPos = Frame.Position  
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)  
        end  
    end)  
    UserInputService.InputChanged:Connect(function(input)  
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
            local Delta = input.Position - DragStart  
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)  
        end  
    end)
end

--// MAIN WINDOW CONSTRUCTOR
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib Ultimate"}

    local Window = {Toggled = true, CurrentTab = nil}
    local CoreGuiFrame = Create("ScreenGui", {Name = "SlayLib_X_Engine", Parent = Parent})  

    local FloatingToggle = Create("Frame", {  
        Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.02, 0, 0.15, 0),  
        BackgroundColor3 = SlayLib.Theme.MainColor, Parent = CoreGuiFrame, ZIndex = 100 
    })  
    SlayLib.ThemeObjects[FloatingToggle] = "Background"
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingToggle})  
    local ToggleBtn = Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = FloatingToggle})

    local MainFrame = Create("Frame", {  
        Size = UDim2.new(0, 620, 0, 440), Position = UDim2.new(0.5, -310, 0.5, -220),  
        BackgroundColor3 = SlayLib.Theme.Background, Parent = CoreGuiFrame, ClipsDescendants = true  
    })  
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})  
    local MainStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 2, Parent = MainFrame})

    local Sidebar = Create("Frame", {Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = SlayLib.Theme.Sidebar, Parent = MainFrame})  
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})  

    local LibTitle = Create("TextLabel", {  
        Size = UDim2.new(1, -20, 0, 60), Position = UDim2.new(0, 20, 0, 0),  
        Font = "GothamBold", TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Sidebar  
    })  
    ApplyTextLogic(LibTitle, Config.Name, 18)  

    local TabScroll = Create("ScrollingFrame", {  
        Size = UDim2.new(1, 0, 1, -70), Position = UDim2.new(0, 0, 0, 70),  
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y"  
    })  
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})  

    local PageContainer = Create("Frame", {  
        Size = UDim2.new(1, -220, 1, -20), Position = UDim2.new(0, 210, 0, 10), BackgroundTransparency = 1, Parent = MainFrame  
    })  

    ToggleBtn.MouseButton1Click:Connect(function()  
        Window.Toggled = not Window.Toggled  
        Tween(MainFrame, {Size = Window.Toggled and UDim2.new(0, 620, 0, 440) or UDim2.new(0,0,0,0)}, 0.5)  
    end)  
    RegisterDrag(MainFrame, LibTitle) RegisterDrag(FloatingToggle, FloatingToggle)

    function Window:CreateTab(Name, IconID)  
        local Tab = {Page = nil}  
        local TabBtn = Create("TextButton", {Size = UDim2.new(0, 180, 0, 40), BackgroundColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, Text = "", Parent = TabScroll})  
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})  
        
        local TabLbl = Create("TextLabel", {Text = Name, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 40, 0, 0), Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.TextSecondary, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TabBtn})  
        local TabIcon = Create("ImageLabel", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 12, 0.5, -10), Image = IconID or SlayLib.Icons.Folder, BackgroundTransparency = 1, ImageColor3 = SlayLib.Theme.TextSecondary, Parent = TabBtn})  

        local Page = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", Parent = PageContainer})  
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10)})  

        TabBtn.MouseButton1Click:Connect(function()  
            if Window.CurrentTab then  
                Window.CurrentTab.Page.Visible = false  
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1}, 0.3)  
                Tween(Window.CurrentTab.Lbl, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.3)  
            end  
            Window.CurrentTab = {Page = Page, Btn = TabBtn, Lbl = TabLbl}  
            Page.Visible = true  
            Tween(TabBtn, {BackgroundTransparency = 0.2}, 0.3)  
            Tween(TabLbl, {TextColor3 = SlayLib.Theme.Text}, 0.3)  
        end)  
        if not Window.CurrentTab then TabBtn.MouseButton1Click() end

        function Tab:CreateSection(SName)  
            local Section = {}  
            local SectLabel = Create("TextLabel", {Text = SName:upper(), Size = UDim2.new(1, 0, 0, 20), Font = "GothamBold", TextSize = 12, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page})  
            SlayLib.ThemeObjects[SectLabel] = "Text"

            -- 1. TOGGLE
            function Section:CreateToggle(Props)
                local TState = Props.CurrentValue or false
                local TContainer = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TContainer})
                local TLbl = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1, -60, 1, 0), Font = "Gotham", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = TContainer})
                local Switch = Create("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60), Parent = TContainer})
                if TState then SlayLib.ThemeObjects[Switch] = "Background" end
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
                local Dot = Create("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = TState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1), Parent = Switch})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})
                
                Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = TContainer}).MouseButton1Click:Connect(function()
                    TState = not TState
                    SlayLib.Flags[Props.Flag] = TState
                    if TState then SlayLib.ThemeObjects[Switch] = "Background" else SlayLib.ThemeObjects[Switch] = nil end
                    Tween(Switch, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60)}, 0.2)
                    Tween(Dot, {Position = TState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                    Props.Callback(TState)
                end)
            end

            -- 2. COLOR PICKER (VISUAL & REAL-TIME)
            function Section:CreateColorPicker(Props)
                local Color = Props.Default or SlayLib.Theme.MainColor
                local IsTheme = Props.IsThemePicker or false
                
                local CPContainer = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CPContainer})
                local CLbl = Create("TextLabel", {Text = "  "..Props.Name, Size = UDim2.new(1, -60, 1, 0), Font = "Gotham", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = CPContainer})
                
                local ColorDisp = Create("Frame", {Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -40, 0.5, -10), BackgroundColor3 = Color, Parent = CPContainer})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorDisp})
                if IsTheme then SlayLib.ThemeObjects[ColorDisp] = "Background" end

                local PickerOpen = false
                local PickerFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = SlayLib.Theme.Element, ClipsDescendants = true, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = PickerFrame})

                -- RGB Slider (Simple version for reliability)
                local HueBar = Create("ImageLabel", {
                    Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 10),
                    Image = "rbxassetid://2320468862", Parent = PickerFrame
                })
                local HueDot = Create("Frame", {Size = UDim2.new(0, 4, 1, 4), Position = UDim2.new(0.5, 0, 0, -2), BackgroundColor3 = Color3.new(1,1,1), Parent = HueBar})

                local function Update(input)
                    local percent = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                    local newCol = Color3.fromHSV(percent, 0.8, 1)
                    HueDot.Position = UDim2.new(percent, -2, 0, -2)
                    ColorDisp.BackgroundColor3 = newCol
                    if IsTheme then SlayLib:UpdateTheme(newCol) end
                    if Props.Flag then SlayLib.Flags[Props.Flag] = newCol end
                    Props.Callback(newCol)
                end

                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local conn; conn = UserInputService.InputChanged:Connect(function(msg)
                            if msg.UserInputType == Enum.UserInputType.MouseMovement then Update(msg) end
                        end)
                        UserInputService.InputEnded:Connect(function(msg) if msg.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end end)
                        Update(input)
                    end
                end)

                Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = CPContainer}).MouseButton1Click:Connect(function()
                    PickerOpen = not PickerOpen
                    Tween(PickerFrame, {Size = PickerOpen and UDim2.new(1, 0, 0, 35) or UDim2.new(1, 0, 0, 0)}, 0.3)
                end)
            end

            -- 3. BUTTON
            function Section:CreateButton(Props)
                local Btn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = SlayLib.Theme.Element, Text = Props.Name, Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.Theme.Text, Parent = Page})
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Btn})
                Btn.MouseButton1Click:Connect(Props.Callback)
            end

            return Section  
        end  
        return Tab  
    end  
    return Window
end

--// CONFIG SAVE/LOAD
function SlayLib:SaveConfig(Name)
    local Data = HttpService:JSONEncode(SlayLib.Flags)
    writefile(SlayLib.Folder.."/"..Name..".json", Data)
    SlayLib:Notify({Title = "System", Content = "Config Saved!", Type = "Success"})
end

return SlayLib
