local SlayLib = {
    Folder = "SlayLib_Config",
    Flags = {},
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
    Icons = { Logo = "rbxassetid://13589839447", Chevron = "rbxassetid://10734895856", Folder = "rbxassetid://10734897484" }
}

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Parent = (RunService:IsStudio() and game:GetService("Players").LocalPlayer.PlayerGui or CoreGui)

--// Folder Management
if not isfolder(SlayLib.Folder) then makefolder(SlayLib.Folder) end

--// Utilities
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function Tween(obj, goal, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal):Play()
end

--// [CORE] Notify
function SlayLib:Notify(Config)
    Config = Config or {Title = "System", Content = "Message", Duration = 3, Type = "Neutral"}
    local Holder = Parent:FindFirstChild("SlayNotifications") or Create("Frame", {Name = "SlayNotifications", Parent = Parent, BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, -40), Position = UDim2.new(1, -310, 0, 20)})
    if not Holder:FindFirstChild("UIListLayout") then Create("UIListLayout", {Parent = Holder, VerticalAlignment = "Bottom", Padding = UDim.new(0, 10)}) end
    
    local NotifColor = self.Theme[Config.Type] or self.Theme.MainColor
    local Frame = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y", BackgroundColor3 = self.Theme.Sidebar, Parent = Holder, ClipsDescendants = true})
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
    Create("UIStroke", {Color = NotifColor, Thickness = 2, Parent = Frame})
    
    local Content = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y", BackgroundTransparency = 1, Parent = Frame})
    Create("UIPadding", {PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), Parent = Content})
    Create("UIListLayout", {Parent = Content, Padding = UDim.new(0, 4)})
    
    Create("TextLabel", {Text = Config.Title, Font = "GothamBold", TextSize = 14, TextColor3 = NotifColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = "Left", Parent = Content})
    Create("TextLabel", {Text = Config.Content, Font = "Gotham", TextSize = 12, TextColor3 = self.Theme.Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y", TextWrapped = true, TextXAlignment = "Left", Parent = Content})

    task.delay(Config.Duration, function() if Frame then Frame:Destroy() end end)
end

--// [CORE] Window
function SlayLib:CreateWindow(Config)
    local Main = Create("Frame", {Size = UDim2.new(0, 620, 0, 440), Position = UDim2.new(0.5, -310, 0.5, -220), BackgroundColor3 = self.Theme.Background, Parent = Create("ScreenGui", {Parent = Parent})})
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Main})
    
    local Sidebar = Create("Frame", {Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = self.Theme.Sidebar, Parent = Main})
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
    
    local TabScroll = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -20), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar, AutomaticCanvasSize = "Y"})
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})

    local Container = Create("Frame", {Size = UDim2.new(1, -200, 1, -20), Position = UDim2.new(0, 190, 0, 10), BackgroundTransparency = 1, Parent = Main})
    
    local Window = {CurrentTab = nil}

    function Window:CreateTab(Name)
        local Tab = {}
        local Page = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, Parent = Container, AutomaticCanvasSize = "Y"})
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10)})
        
        local TabBtn = Create("TextButton", {Size = UDim2.new(0, 160, 0, 40), Text = Name, BackgroundColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextColor3 = SlayLib.Theme.TextSecondary, Font = "GothamMedium", Parent = TabScroll})
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then Window.CurrentTab.Page.Visible = false Window.CurrentTab.Btn.BackgroundTransparency = 1 end
            Window.CurrentTab = {Page = Page, Btn = TabBtn}
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.2
        end)
        if not Window.CurrentTab then TabBtn.MouseButton1Click() end

        function Tab:CreateSection(SName)
            local Section = {}
            Create("Frame", {Size = UDim2.new(1, 0, 0, 5), BackgroundTransparency = 1, Parent = Page}) -- Spacer
            local SectLabel = Create("TextLabel", {Text = SName:upper(), Size = UDim2.new(1, 0, 0, 20), Font = "GothamBold", TextSize = 12, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Page})

            -- Paragraph
            function Section:CreateParagraph(P)
                local Box = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y", BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {Parent = Box})
                local List = Create("UIListLayout", {Parent = Box, Padding = UDim.new(0, 4)})
                Create("UIPadding", {PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), Parent = Box})
                Create("TextLabel", {Text = P.Title, Size = UDim2.new(1, 0, 0, 20), Font = "GothamBold", TextSize = 14, TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Box})
                Create("TextLabel", {Text = P.Content, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y", Font = "Gotham", TextSize = 13, TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1, TextWrapped = true, TextXAlignment = "Left", Parent = Box})
            end

            -- Toggle
            function Section:CreateToggle(P)
                local TState = SlayLib.Flags[P.Flag] or P.CurrentValue or false
                local Box = Create("TextButton", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = SlayLib.Theme.Element, Text = "  "..P.Name, Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", Parent = Page})
                Create("UICorner", {Parent = Box})
                local Ind = Create("Frame", {Size = UDim2.new(0, 35, 0, 18), Position = UDim2.new(1, -50, 0.5, -9), BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60), Parent = Box})
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Ind})
                
                Box.MouseButton1Click:Connect(function()
                    TState = not TState
                    SlayLib.Flags[P.Flag] = TState
                    Tween(Ind, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(60,60,60)})
                    P.Callback(TState)
                end)
            end

            -- Slider
            function Section:CreateSlider(P)
                local Value = SlayLib.Flags[P.Flag] or P.Def or 50
                local Box = Create("Frame", {Size = UDim2.new(1, 0, 0, 65), BackgroundColor3 = SlayLib.Theme.Element, Parent = Page})
                Create("UICorner", {Parent = Box})
                local Tl = Create("TextLabel", {Text = "  "..P.Name.." : "..Value, Size = UDim2.new(1, 0, 0, 35), Font = "Gotham", TextSize = 14, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left", BackgroundTransparency = 1, Parent = Box})
                local Bar = Create("Frame", {Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 45), BackgroundColor3 = Color3.fromRGB(45,45,45), Parent = Box})
                local Fill = Create("Frame", {Size = UDim2.new((Value-P.Min)/(P.Max-P.Min), 0, 1, 0), BackgroundColor3 = SlayLib.Theme.MainColor, Parent = Bar})
                
                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local move = UserInputService.InputChanged:Connect(function(m)
                            if m.UserInputType == Enum.UserInputType.MouseMovement then
                                local p = math.clamp((m.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                                Value = math.floor(P.Min + (P.Max-P.Min)*p)
                                Tl.Text = "  "..P.Name.." : "..Value
                                Fill.Size = UDim2.new(p, 0, 1, 0)
                                SlayLib.Flags[P.Flag] = Value
                                P.Callback(Value)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(e) if e.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
                    end
                end)
            end

            return Section
        end
        return Tab
    end
    return Window
end

--// Config Logic
function SlayLib:Save(Name)
    local Success, Data = pcall(function() return HttpService:JSONEncode(self.Flags) end)
    if Success then writefile(self.Folder.."/"..Name..".json", Data) end
end

function SlayLib:Load(Name)
    local Path = self.Folder.."/"..Name..".json"
    if isfile(Path) then self.Flags = HttpService:JSONDecode(readfile(Path)) end
end

return SlayLib
