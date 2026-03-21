--[[
    SlayLib - Custom Edition
    Theme: Dark Frosted Glass
    Features: Multi-tabs, Smooth Animations, Mobile Support, User Identity
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SlayLib = {}
SlayLib.__index = SlayLib

-- Configuration
local Theme = {
    Main = Color3.fromRGB(25, 25, 30),
    Secondary = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(0, 160, 255),
    Text = Color3.fromRGB(240, 240, 245),
    TextDark = Color3.fromRGB(160, 160, 165),
    Stroke = Color3.fromRGB(65, 65, 75),
    Ripple = Color3.fromRGB(255, 255, 255)
}

-- Utility: Apply Rounded Corners & Stroke
local function AddDecor(obj, radius, strokeColor)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
    
    if strokeColor then
        local stroke = Instance.new("UIStroke")
        stroke.Color = strokeColor
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = obj
    end
end

-- Utility: Smooth Draggable
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.QuadOut), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function SlayLib.new(hubName)
    local self = setmetatable({}, SlayLib)
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SlayLib_GUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    self.Gui = ScreenGui

    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(580, 380)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BackgroundTransparency = 0.25 -- Glass effect
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    AddDecor(MainFrame, 10, Theme.Stroke)
    MakeDraggable(MainFrame)

    -- Sidebar Area
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Secondary
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.Parent = MainFrame
    AddDecor(Sidebar, 10)

    -- Hub Name
    local Title = Instance.new("TextLabel")
    Title.Text = hubName:upper()
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.Parent = Sidebar

    -- Tab Scrolling Frame
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -120)
    TabScroll.Position = UDim2.fromOffset(0, 55)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = TabScroll
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.fromOffset(0, TabList.AbsoluteContentSize.Y)
    end)

    -- User Status Section
    local UserInfo = Instance.new("Frame")
    UserInfo.Size = UDim2.new(0.9, 0, 0, 50)
    UserInfo.Position = UDim2.new(0.05, 0, 1, -60)
    UserInfo.BackgroundColor3 = Theme.Main
    UserInfo.BackgroundTransparency = 0.4
    UserInfo.Parent = Sidebar
    AddDecor(UserInfo, 8, Theme.Stroke)

    local UserImage = Instance.new("ImageLabel")
    UserImage.Size = UDim2.fromOffset(38, 38)
    UserImage.Position = UDim2.fromOffset(6, 6)
    UserImage.Image = game:GetService("Players"):GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    UserImage.BackgroundTransparency = 1
    UserImage.Parent = UserInfo
    AddDecor(UserImage, 19)

    local UserName = Instance.new("TextLabel")
    UserName.Text = LocalPlayer.DisplayName
    UserName.Size = UDim2.new(1, -55, 1, 0)
    UserName.Position = UDim2.fromOffset(50, 0)
    UserName.TextColor3 = Theme.Text
    UserName.TextSize = 12
    UserName.Font = Enum.Font.GothamSemibold
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.BackgroundTransparency = 1
    UserName.Parent = UserInfo

    -- Pages Container
    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, -170, 1, -10)
    Pages.Position = UDim2.fromOffset(165, 5)
    Pages.BackgroundTransparency = 1
    Pages.Parent = MainFrame

    self.MainFrame = MainFrame
    self.Pages = Pages
    self.TabScroll = TabScroll
    self.CurrentTab = nil

    return self
end

function SlayLib:CreateTab(name)
    local tab = {}
    
    -- Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.9, 0, 0, 36)
    TabBtn.BackgroundColor3 = Theme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Theme.TextDark
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    TabBtn.Parent = self.TabScroll
    AddDecor(TabBtn, 6)

    -- Page Container
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.fromScale(1, 1)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Parent = self.Pages
    
    local PageList = Instance.new("UIListLayout")
    PageList.Padding = UDim.new(0, 8)
    PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Parent = Page
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0, PageList.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Pages:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        for _, v in pairs(self.TabScroll:GetChildren()) do
            if v:IsA("TextButton") then 
                TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}):Play()
            end
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, TextColor3 = Theme.Text}):Play()
    end)

    -- Auto-select first tab
    if #self.TabScroll:GetChildren() == 2 then -- 1 layout + 1 btn
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.TextColor3 = Theme.Text
    end

    -- // Elements \\ --

    function tab:CreateButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.96, 0, 0, 38)
        btn.BackgroundColor3 = Theme.Secondary
        btn.BackgroundTransparency = 0.3
        btn.Text = "  " .. text
        btn.TextColor3 = Theme.Text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = Page
        AddDecor(btn, 6, Theme.Stroke)

        btn.MouseButton1Click:Connect(function()
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.fromOffset(0, 0)
            ripple.Position = UDim2.fromOffset(Mouse.X - btn.AbsolutePosition.X, Mouse.Y - btn.AbsolutePosition.Y)
            ripple.BackgroundColor3 = Theme.Ripple
            ripple.BackgroundTransparency = 0.6
            ripple.Parent = btn
            AddDecor(ripple, 150)
            
            TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.QuadOut), {
                Size = UDim2.fromOffset(350, 350),
                Position = ripple.Position - UDim2.fromOffset(175, 175),
                BackgroundTransparency = 1
            }):Play()
            
            task.delay(0.5, function() ripple:Destroy() end)
            callback()
        end)
    end

    function tab:CreateToggle(text, default, callback)
        local toggled = default or false
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(0.96, 0, 0, 40)
        toggleFrame.BackgroundColor3 = Theme.Secondary
        toggleFrame.BackgroundTransparency = 0.3
        toggleFrame.Parent = Page
        AddDecor(toggleFrame, 6, Theme.Stroke)

        local label = Instance.new("TextLabel")
        label.Text = "  " .. text
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = toggleFrame

        local box = Instance.new("Frame")
        box.Size = UDim2.fromOffset(42, 22)
        box.Position = UDim2.new(1, -50, 0.5, -11)
        box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        box.Parent = toggleFrame
        AddDecor(box, 11, Theme.Stroke)

        local inner = Instance.new("Frame")
        inner.Size = UDim2.fromOffset(18, 18)
        inner.Position = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
        inner.BackgroundColor3 = toggled and Theme.Accent or Theme.TextDark
        inner.Parent = box
        AddDecor(inner, 9)

        toggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggled = not toggled
                local targetPos = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
                local targetColor = toggled and Theme.Accent or Theme.TextDark
                TweenService:Create(inner, TweenInfo.new(0.2, Enum.EasingStyle.BackOut), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
                callback(toggled)
            end
        end)
    end

    function tab:CreateSlider(text, min, max, default, callback)
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.96, 0, 0, 55)
        slider.BackgroundColor3 = Theme.Secondary
        slider.BackgroundTransparency = 0.3
        slider.Parent = Page
        AddDecor(slider, 6, Theme.Stroke)

        local label = Instance.new("TextLabel")
        label.Text = "  " .. text
        label.Size = UDim2.new(1, 0, 0, 30)
        label.BackgroundTransparency = 1
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = slider

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = tostring(default)
        valueLabel.Size = UDim2.new(1, -10, 0, 30)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Theme.Accent
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 13
        valueLabel.Parent = slider

        local tray = Instance.new("Frame")
        tray.Size = UDim2.new(0.92, 0, 0, 6)
        tray.Position = UDim2.new(0.04, 0, 0, 40)
        tray.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        tray.Parent = slider
        AddDecor(tray, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale(math.clamp((default - min) / (max - min), 0, 1), 1)
        fill.BackgroundColor3 = Theme.Accent
        fill.Parent = tray
        AddDecor(fill, 3)

        local dragging = false
        local function update()
            local percent = math.clamp((Mouse.X - tray.AbsolutePosition.X) / tray.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.fromScale(percent, 1)
            valueLabel.Text = tostring(value)
            callback(value)
        end

        tray.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update()
            end
        end)
    end

    function tab:CreateDropdown(text, list, callback)
        local dropped = false
        local dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(0.96, 0, 0, 40)
        dropFrame.BackgroundColor3 = Theme.Secondary
        dropFrame.BackgroundTransparency = 0.3
        dropFrame.ClipsDescendants = true
        dropFrame.Parent = Page
        AddDecor(dropFrame, 6, Theme.Stroke)

        local label = Instance.new("TextButton")
        label.Text = "  " .. text .. " : " .. (list[1] or "...")
        label.Size = UDim2.new(1, 0, 0, 40)
        label.BackgroundTransparency = 1
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = dropFrame

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, #list * 30)
        container.Position = UDim2.fromOffset(0, 40)
        container.BackgroundTransparency = 1
        container.Parent = dropFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Parent = container

        for _, v in pairs(list) do
            local opt = Instance.new("TextButton")
            opt.Size = UDim2.new(1, 0, 0, 30)
            opt.BackgroundTransparency = 1
            opt.Text = "      " .. v
            opt.TextColor3 = Theme.TextDark
            opt.Font = Enum.Font.Gotham
            opt.TextSize = 12
            opt.TextXAlignment = Enum.TextXAlignment.Left
            opt.Parent = container

            opt.MouseButton1Click:Connect(function()
                label.Text = "  " .. text .. " : " .. v
                dropped = false
                TweenService:Create(dropFrame, TweenInfo.new(0.3, Enum.EasingStyle.QuartOut), {Size = UDim2.new(0.96, 0, 0, 40)}):Play()
                callback(v)
            end)
        end

        label.MouseButton1Click:Connect(function()
            dropped = not dropped
            local targetSize = dropped and UDim2.new(0.96, 0, 0, 40 + (#list * 30)) or UDim2.new(0.96, 0, 0, 40)
            TweenService:Create(dropFrame, TweenInfo.new(0.3, Enum.EasingStyle.QuartOut), {Size = targetSize}):Play()
        end)
    end

    return tab
end

return SlayLib
