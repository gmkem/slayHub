local SlayLib = {
    Folder = "SlayLib_Configs",
    Flags = {},
    Elements = {},
    Theme = {
        Main = Color3.fromRGB(140, 90, 255),
        BG = Color3.fromRGB(12, 12, 14),
        Side = Color3.fromRGB(18, 18, 22),
        Element = Color3.fromRGB(25, 25, 30),
        Stroke = Color3.fromRGB(45, 45, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 180)
    }
}

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

--// Utility Logic
local function Tween(obj, goal, time)
    return TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart), goal):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// 1. NOTIFICATION SYSTEM
function SlayLib:Notify(Config)
    Config = Config or {Title = "SYSTEM", Content = "Message", Duration = 3}
    local NotifGui = CoreGui:FindFirstChild("SlayNotifs") or Instance.new("ScreenGui", CoreGui)
    NotifGui.Name = "SlayNotifs"
    
    local Holder = NotifGui:FindFirstChild("Holder") or Instance.new("Frame", NotifGui)
    if not NotifGui:FindFirstChild("Holder") then
        Holder.Name = "Holder"; Holder.Size = UDim2.new(0, 300, 1, 0); Holder.Position = UDim2.new(1, -310, 0, 0); Holder.BackgroundTransparency = 1
        local Layout = Instance.new("UIListLayout", Holder); Layout.VerticalAlignment = "Bottom"; Layout.Padding = UDim.new(0, 10)
    end

    local Box = Instance.new("Frame", Holder)
    Box.Size = UDim2.new(1, 0, 0, 0); Box.BackgroundColor3 = SlayLib.Theme.BG; Box.ClipsDescendants = true
    local Corner = Instance.new("UICorner", Box); local Stroke = Instance.new("UIStroke", Box); Stroke.Color = SlayLib.Theme.Main
    
    local Ttl = Instance.new("TextLabel", Box); Ttl.Size = UDim2.new(1, -20, 0, 25); Ttl.Position = UDim2.new(0, 10, 0, 5); Ttl.Text = Config.Title; Ttl.TextColor3 = SlayLib.Theme.Main; Ttl.Font = "GothamBold"; Ttl.BackgroundTransparency = 1; Ttl.TextXAlignment = "Left"
    local Cnt = Instance.new("TextLabel", Box); Cnt.Size = UDim2.new(1, -20, 0, 40); Cnt.Position = UDim2.new(0, 10, 0, 25); Cnt.Text = Config.Content; Cnt.TextColor3 = Color3.new(1,1,1); Cnt.Font = "Gotham"; Cnt.TextWrapped = true; Cnt.BackgroundTransparency = 1; Cnt.TextXAlignment = "Left"; Cnt.TextSize = 12

    task.spawn(function()
        Tween(Box, {Size = UDim2.new(1, 0, 0, 70)}, 0.4)
        task.wait(Config.Duration)
        Tween(Box, {Size = UDim2.new(1, 0, 0, 0)}, 0.4)
        task.wait(0.4); Box:Destroy()
    end)
end

--// 2. LOADING SCREEN
local function ShowLoading()
    local LoadGui = Instance.new("ScreenGui", CoreGui)
    local Main = Instance.new("Frame", LoadGui); Main.Size = UDim2.new(1, 0, 1, 0); Main.BackgroundColor3 = Color3.new(0,0,0)
    local Logo = Instance.new("TextLabel", Main); Logo.Size = UDim2.new(0, 200, 0, 50); Logo.Position = UDim2.new(0.5, -100, 0.5, -25); Logo.Text = "SLAYLIB X"; Logo.TextColor3 = SlayLib.Theme.Main; Logo.Font = "GothamBold"; Logo.TextSize = 40; Logo.BackgroundTransparency = 1
    
    local Bar = Instance.new("Frame", Main); Bar.Size = UDim2.new(0, 0, 0, 2); Bar.Position = UDim2.new(0.5, -100, 0.5, 30); Bar.BackgroundColor3 = SlayLib.Theme.Main
    
    Tween(Bar, {Size = UDim2.new(0, 200, 0, 2)}, 1.5)
    task.wait(1.8)
    Tween(Main, {BackgroundTransparency = 1}, 0.5)
    Tween(Logo, {TextTransparency = 1}, 0.5)
    Tween(Bar, {BackgroundTransparency = 1}, 0.5)
    task.wait(0.5); LoadGui:Destroy()
end

--// 3. MAIN WINDOW
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SlayLib X"}
    ShowLoading()

    local MainGui = Instance.new("ScreenGui", CoreGui)
    MainGui.Name = "SlayV2_Main"

    -- Floating Toggle
    local Tgl = Instance.new("TextButton", MainGui); Tgl.Size = UDim2.new(0, 50, 0, 50); Tgl.Position = UDim2.new(0.05, 0, 0.1, 0); Tgl.BackgroundColor3 = SlayLib.Theme.BG; Tgl.Text = "S"; Tgl.TextColor3 = SlayLib.Theme.Main; Tgl.Font = "GothamBold"; Tgl.TextSize = 24
    Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0); local TS = Instance.new("UIStroke", Tgl); TS.Color = SlayLib.Theme.Main; TS.Thickness = 2; MakeDraggable(Tgl, Tgl)

    -- Main Window
    local Main = Instance.new("Frame", MainGui); Main.Size = UDim2.new(0, 580, 0, 380); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = SlayLib.Theme.BG; Main.Visible = true
    Instance.new("UICorner", Main); local MS = Instance.new("UIStroke", Main); MS.Color = SlayLib.Theme.Stroke
    
    Tgl.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 160, 1, 0); Sidebar.BackgroundColor3 = SlayLib.Theme.Side; Instance.new("UICorner", Sidebar)
    local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -180, 1, -20); Container.Position = UDim2.new(0, 170, 0, 10); Container.BackgroundTransparency = 1
    
    MakeDraggable(Main, Sidebar)

    local Tabs = {First = nil}
    function Tabs:CreateTab(Name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(0, 140, 0, 35); TabBtn.Position = UDim2.new(0, 10, 0, 60 + (#Sidebar:GetChildren()*40)); TabBtn.BackgroundColor3 = SlayLib.Theme.Element; TabBtn.Text = Name; TabBtn.TextColor3 = SlayLib.Theme.TextSecondary; TabBtn.Font = "GothamMedium"; Instance.new("UICorner", TabBtn)
        
        local Page = Instance.new("ScrollingFrame", Container); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0
        local Layout = Instance.new("UIListLayout", Page); Layout.Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            Page.Visible = true
        end)

        if not Tabs.First then Tabs.First = true; Page.Visible = true; TabBtn.TextColor3 = SlayLib.Theme.Main end

        local Elements = {}

        -- BUTTON
        function Elements:CreateButton(Text, Callback)
            local B = Instance.new("TextButton", Page); B.Size = UDim2.new(1, -5, 0, 40); B.BackgroundColor3 = SlayLib.Theme.Element; B.Text = "  " .. Text; B.TextColor3 = Color3.new(1,1,1); B.Font = "GothamMedium"; B.TextXAlignment = "Left"; Instance.new("UICorner", B); local s = Instance.new("UIStroke", B); s.Color = SlayLib.Theme.Stroke
            B.MouseButton1Click:Connect(Callback)
        end

        -- TOGGLE
        function Elements:CreateToggle(Text, Flag, Callback)
            SlayLib.Flags[Flag] = false
            local T = Instance.new("TextButton", Page); T.Size = UDim2.new(1, -5, 0, 40); T.BackgroundColor3 = SlayLib.Theme.Element; T.Text = "  " .. Text; T.TextColor3 = Color3.new(1,1,1); T.Font = "GothamMedium"; T.TextXAlignment = "Left"; Instance.new("UICorner", T)
            local Box = Instance.new("Frame", T); Box.Size = UDim2.new(0, 35, 0, 18); Box.Position = UDim2.new(1, -45, 0.5, -9); Box.BackgroundColor3 = Color3.fromRGB(50,50,50); Instance.new("UICorner", Box).CornerRadius = UDim.new(1,0)
            local Dot = Instance.new("Frame", Box); Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

            T.MouseButton1Click:Connect(function()
                SlayLib.Flags[Flag] = not SlayLib.Flags[Flag]
                Tween(Box, {BackgroundColor3 = SlayLib.Flags[Flag] and SlayLib.Theme.Main or Color3.fromRGB(50,50,50)}, 0.2)
                Tween(Dot, {Position = SlayLib.Flags[Flag] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                Callback(SlayLib.Flags[Flag])
            end)
        end

        -- SLIDER
        function Elements:CreateSlider(Text, Min, Max, Def, Flag, Callback)
            SlayLib.Flags[Flag] = Def
            local S = Instance.new("Frame", Page); S.Size = UDim2.new(1, -5, 0, 50); S.BackgroundColor3 = SlayLib.Theme.Element; Instance.new("UICorner", S)
            local Lab = Instance.new("TextLabel", S); Lab.Size = UDim2.new(1, 0, 0, 25); Lab.Text = "  " .. Text .. " : " .. Def; Lab.TextColor3 = Color3.new(1,1,1); Lab.BackgroundTransparency = 1; Lab.TextXAlignment = "Left"
            local Bar = Instance.new("Frame", S); Bar.Size = UDim2.new(1, -20, 0, 4); Bar.Position = UDim2.new(0, 10, 0, 35); Bar.BackgroundColor3 = Color3.fromRGB(50,50,50)
            local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((Def-Min)/(Max-Min), 0, 1, 0); Fill.BackgroundColor3 = SlayLib.Theme.Main

            local function Update(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(Min + (Max-Min)*pos)
                Fill.Size = UDim2.new(pos, 0, 1, 0); Lab.Text = "  " .. Text .. " : " .. val; SlayLib.Flags[Flag] = val; Callback(val)
            end
            Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Update(i) end end)
        end

        return Elements
    end
    return Tabs
end

return SlayLib
