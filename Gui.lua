local SlayLib = {}

function SlayLib:CreateSlayLib(libName)
    libName = libName or "SlayLib"
    local isClosed = false

    local ScreenGui = Instance.new("ScreenGui")
    local MainWhiteFrame = Instance.new("Frame")
    local mainCorner = Instance.new("UICorner")
    local MainWhiteFrame_2 = Instance.new("Frame")
    local mainCorner_2 = Instance.new("UICorner")
    local mainStroke = Instance.new("UIStroke") -- ADDED: Subtle shadow/border
    local tabFrame = Instance.new("Frame")
    local tabList = Instance.new("UIListLayout")
    local tabPadd = Instance.new("UIPadding")
    local header = Instance.new("Frame")
    local mainCorner_4 = Instance.new("UICorner")
    local libTitle = Instance.new("TextLabel")
    local closeLib = Instance.new("ImageButton")
    local elementContainer = Instance.new("Frame")
    local mainCorner_5 = Instance.new("UICorner")
    local mainList = Instance.new("UIListLayout")
    local pagesFolder = Instance.new("Folder")

    -- Services
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris") 
    local task = task 

    local TopBar = header
    local Camera = workspace:WaitForChild("Camera")

    -- Dragging functionality (unchanged)
    local DragMousePosition
    local FramePosition
    local Draggable = false
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = true
            DragMousePosition = Vector2.new(input.Position.X, input.Position.Y)
            FramePosition = Vector2.new(MainWhiteFrame.Position.X.Scale, MainWhiteFrame.Position.Y.Scale)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Draggable == true then
            local NewPosition = FramePosition + ((Vector2.new(input.Position.X, input.Position.Y) - DragMousePosition) / Camera.ViewportSize)
            MainWhiteFrame.Position = UDim2.new(NewPosition.X, 0, NewPosition.Y, 0)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = false
        end
    end)

    -- General Properties and Theme Changes (Aesthetic Tweaks)
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainWhiteFrame.Name = "MainWhiteFrame"
    MainWhiteFrame.Parent = ScreenGui
    MainWhiteFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainWhiteFrame.BackgroundTransparency = 0.2
    MainWhiteFrame.BorderSizePixel = 0
    MainWhiteFrame.ClipsDescendants = true
    MainWhiteFrame.Position = UDim2.new(0.236969739, 0, 0.360436916, 0)
    MainWhiteFrame.Size = UDim2.new(0, 528, 0, 310)

    mainCorner.CornerRadius = UDim.new(0, 3)
    mainCorner.Name = "mainCorner"
    mainCorner.Parent = MainWhiteFrame

    MainWhiteFrame_2.Name = "MainWhiteFrame"
    MainWhiteFrame_2.Parent = MainWhiteFrame
    MainWhiteFrame_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainWhiteFrame_2.BackgroundTransparency = 0.1
    MainWhiteFrame_2.BorderSizePixel = 0
    MainWhiteFrame_2.ClipsDescendants = true
    MainWhiteFrame_2.Position = UDim2.new(0.0113636367, 0, 0, 0)
    MainWhiteFrame_2.Size = UDim2.new(0, 525, 0, 310)

    mainCorner_2.CornerRadius = UDim.new(0, 3)
    mainCorner_2.Name = "mainCorner"
    mainCorner_2.Parent = MainWhiteFrame_2
    
    -- Aesthetic Improvement: UIStroke (Outer Shadow/Border)
    mainStroke.Name = "mainStroke"
    mainStroke.Parent = MainWhiteFrame_2
    mainStroke.Color = Color3.fromRGB(0, 0, 0)
    mainStroke.Transparency = 0.7
    mainStroke.Thickness = 1
    mainStroke.LineJoinMode = Enum.LineJoinMode.Round 
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    tabFrame.Name = "tabFrame"
    tabFrame.Parent = MainWhiteFrame_2
    tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    tabFrame.ClipsDescendants = true
    tabFrame.Size = UDim2.new(0, 100, 0, 309)

    tabList.Name = "tabList"
    tabList.Parent = tabFrame
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 2)

    tabPadd.Name = "tabPadd"
    tabPadd.Parent = tabFrame
    tabPadd.PaddingRight = UDim.new(0, 2)
    tabPadd.PaddingTop = UDim.new(0, 5)

    header.Name = "header"
    header.Parent = MainWhiteFrame_2
    header.BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson**
    header.Position = UDim2.new(0.207619041, 0, 0.0258064512, 0)
    header.Size = UDim2.new(0, 408, 0, 43)

    mainCorner_4.CornerRadius = UDim.new(0, 3)
    mainCorner_4.Name = "mainCorner"
    mainCorner_4.Parent = header

    libTitle.Name = "libTitle"
    libTitle.Parent = header
    libTitle.BackgroundTransparency = 1.000
    libTitle.Position = UDim2.new(0.0294117648, 0, 0, 0)
    libTitle.Size = UDim2.new(0, 343, 0, 43)
    libTitle.Font = Enum.Font.GothamSemibold
    libTitle.Text = libName
    libTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    libTitle.TextSize = 18.000
    libTitle.TextXAlignment = Enum.TextXAlignment.Left

    closeLib.Name = "closeLib"
    closeLib.Parent = header
    closeLib.BackgroundTransparency = 1.000
    closeLib.Position = UDim2.new(0.91911763, 0, 0.209302321, 0)
    closeLib.Size = UDim2.new(0, 25, 0, 25)
    closeLib.Image = "rbxassetid://4988112250"
    closeLib.MouseButton1Click:Connect(function()
        local TweenDuration = 0.2 
        local RotationDuration = 0.15
        if isClosed then
            -- Open animation
            isClosed = false
            closeLib.Image = "rbxassetid://4988112250"
            TweenService:Create(closeLib, TweenInfo.new(RotationDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),{
                Rotation = 0
            }):Play()
            MainWhiteFrame:TweenSize(UDim2.new(0, 528,0, 310), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, TweenDuration, true)
            TweenService:Create(MainWhiteFrame_2, TweenInfo.new(TweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),{
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(TweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),{
                BackgroundTransparency = 0.2
            }):Play()
        else
            -- Close animation
            isClosed = true
            closeLib.Image = "rbxassetid://5165666242"
            TweenService:Create(closeLib, TweenInfo.new(RotationDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{
                Rotation = 360
            }):Play()
            MainWhiteFrame:TweenSize(UDim2.new(0, 424,0, 58), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, TweenDuration, true)
            TweenService:Create(MainWhiteFrame_2, TweenInfo.new(TweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(TweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{
                BackgroundTransparency = 1
            }):Play()
        end
    end)

    elementContainer.Name = "elementContainer"
    elementContainer.Parent = MainWhiteFrame_2
    elementContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    elementContainer.Position = UDim2.new(0.207619041, 0, 0.187096775, 0)
    elementContainer.Size = UDim2.new(0, 408, 0, 243)

    mainCorner_5.CornerRadius = UDim.new(0, 3)
    mainCorner_5.Name = "mainCorner"
    mainCorner_5.Parent = elementContainer

    mainList.Name = "mainList"
    mainList.Parent = MainWhiteFrame
    mainList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    mainList.SortOrder = Enum.SortOrder.LayoutOrder

    pagesFolder.Parent = elementContainer

-- *** SLAYLIB NOTIFICATION SYSTEM V8 (ULTIMATE EDITION) ***
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local NotificationQueue = {}
local ActiveNotifications = {} 

-- Configuration
local Config = {
    Spacing = 12,
    FadeTime = 0.4,
    VisibleTime = 4,
    Width = 340,
    InnerColor = Color3.fromRGB(20, 20, 20),
    AccentTransparency = 0.1,
}

-- New Modern Icon Set (Minimalist & HD)
local StatusMapping = {
    Info = {
        Color = Color3.fromRGB(50, 150, 255),
        Icon = "rbxassetid://10888251211" -- Modern Info
    },
    Success = {
        Color = Color3.fromRGB(75, 220, 110),
        Icon = "rbxassetid://10888319623" -- Modern Check
    },
    Warning = {
        Color = Color3.fromRGB(255, 180, 50),
        Icon = "rbxassetid://10888253138" -- Modern Warning
    },
    Error = {
        Color = Color3.fromRGB(255, 70, 70),
        Icon = "rbxassetid://10888317926" -- Modern Error
    }
}

local function UpdatePositions()
    local currentY = 25
    for i, frame in ipairs(ActiveNotifications) do
        local targetPos = UDim2.new(1, -Config.Width - 25, 1, -frame.Size.Y.Offset - currentY)
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()
        currentY = currentY + frame.Size.Y.Offset + Config.Spacing
    end
end

local function Dismiss(frame)
    local index = table.find(ActiveNotifications, frame)
    if not index then return end
    table.remove(ActiveNotifications, index)

    local tween = TweenService:Create(frame, TweenInfo.new(Config.FadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 1,
        Position = frame.Position + UDim2.new(0, 50, 0, 0) -- Slide out right
    })
    tween:Play()
    tween.Completed:Connect(function()
        frame:Destroy()
        UpdatePositions()
        -- Process Queue
        if #NotificationQueue > 0 then
            local nextData = table.remove(NotificationQueue, 1)
            SlayLib:Alert(nextData.status, nextData.title, nextData.message, nextData.duration)
        end
    end)
end

function ShowNotification(data)
    local theme = StatusMapping[data.status]
    
    -- Main Container (CanvasGroup for flawless fading)
    local Main = Instance.new("CanvasGroup")
    Main.Name = "SlayNotif"
    Main.Size = UDim2.new(0, Config.Width, 0, 65)
    Main.BackgroundColor3 = Config.InnerColor
    Main.BackgroundTransparency = 0.05
    Main.AutomaticSize = Enum.AutomaticSize.Y
    Main.GroupTransparency = 1
    Main.Parent = ScreenGui -- Ensure ScreenGui is defined in your main script

    -- Rounded Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = Main

    -- Subtle Border
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.92
    stroke.Parent = Main

    -- Left Accent Bar (Glow effect)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = theme.Color
    accent.BorderSizePixel = 0
    accent.Parent = Main
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent

    -- Content Wrapper
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -45, 1, 0)
    content.Position = UDim2.new(0, 15, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = Main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = content

    -- Header Row
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.Parent = content

    -- ICON (High Contrast)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Image = theme.Icon
    icon.ImageColor3 = theme.Color
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = header

    -- TITLE
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -28, 1, 0)
    title.Position = UDim2.new(0, 28, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = data.title:upper() -- Modern look
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- MESSAGE
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 0)
    msg.AutomaticSize = Enum.AutomaticSize.Y
    msg.BackgroundTransparency = 1
    msg.Text = data.message
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 13
    msg.TextColor3 = Color3.fromRGB(180, 180, 180)
    msg.TextWrapped = true
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Parent = content

    -- Close Button
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 20, 0, 20)
    close.Position = UDim2.new(1, -25, 0, 10)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    close.TextSize = 22
    close.Font = Enum.Font.GothamBold
    close.Parent = Main
    close.MouseButton1Click:Connect(function() Dismiss(Main) end)

    -- Animation Logic
    Main.Position = UDim2.new(1, 20, 1, -NotificationHeight - 25)
    table.insert(ActiveNotifications, 1, Main)
    UpdatePositions()

    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0
    }):Play()

    task.delay(data.duration, function()
        Dismiss(Main)
    end)
end

-- API
function SlayLib:Alert(status, title, message, duration)
    local data = {
        status = status or "Info",
        title = title or "System",
        message = message or "",
        duration = duration or Config.VisibleTime
    }
    
    if #ActiveNotifications >= 8 then
        table.insert(NotificationQueue, data)
    else
        ShowNotification(data)
    end
end

    -- ... [Rest of the GUI code remains unchanged] ...
    
    local SectionHandler = {}

    function SectionHandler:CreateSection(secName)
        secName = secName or "Tab"
        
        -- Tab Button Instances (unchanged)
        local tabBtn = Instance.new("TextButton")
        local mainCorner_3 = Instance.new("UICorner")

        tabBtn.Name = "tabBtn"..secName
        tabBtn.Parent = tabFrame
        tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        tabBtn.BorderColor3 = Color3.fromRGB(50, 50, 50)
        tabBtn.Position = UDim2.new(0.0599999987, 0, 0.0323624611, 0)
        tabBtn.Size = UDim2.new(0, 95, 0, 32)
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Text = secName
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.TextSize = 14.000
        tabBtn.AutoButtonColor = false

        mainCorner_3.CornerRadius = UDim.new(0, 3)
        mainCorner_3.Name = "mainCorner"
        mainCorner_3.Parent = tabBtn

        -- New Section Frame Instances (unchanged)
        local newPage = Instance.new("ScrollingFrame")
        local pageItemList = Instance.new("UIListLayout")
        local UIPadding = Instance.new("UIPadding")

        newPage.Name = "newPage"..secName
        newPage.Parent = pagesFolder
        newPage.Active = true
        newPage.BackgroundTransparency = 1.000
        newPage.BorderSizePixel = 0
        newPage.Size = UDim2.new(1, 0, 1, 0)
        newPage.ScrollBarThickness = 5
        newPage.ScrollBarImageColor3 = Color3.fromRGB(139, 0, 23) 
        newPage.Visible = false

        pageItemList.Name = "pageItemList"
        pageItemList.Parent = newPage
        pageItemList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageItemList.SortOrder = Enum.SortOrder.LayoutOrder
        pageItemList.Padding = UDim.new(0, 3)

        UIPadding.Parent = newPage
        UIPadding.PaddingRight = UDim.new(0, 5)
        UIPadding.PaddingTop = UDim.new(0, 5)

        local function UpdateSize()
            local cS = pageItemList.AbsoluteContentSize

            TweenService:Create(newPage, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                CanvasSize = UDim2.new(0,cS.X,0,cS.Y + 10)
            }):Play()
        end

        newPage.ChildAdded:Connect(UpdateSize)
        newPage.ChildRemoved:Connect(UpdateSize)
        UpdateSize()

        tabBtn.MouseButton1Click:Connect(function()
            UpdateSize()
            for i,v in next, pagesFolder:GetChildren() do
                v.Visible = false
                UpdateSize()
            end
            newPage.Visible = true

            local TabTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) 

            for i,v in next, tabFrame:GetChildren() do
                if v:IsA("TextButton") then
                    UpdateSize()
                    TweenService:Create(v, TabTweenInfo,{
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    }):Play()
                end
            end
            TweenService:Create(tabBtn, TabTweenInfo,{
                BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Selected Tab)**
            }):Play()
        end)

        local ElementHandler = {}

        function ElementHandler:TextLabel(labelText)
            labelText = labelText or ""

            local labelFrame = Instance.new("Frame")
            local mainCorner = Instance.new("UICorner")
            local txtLabel = Instance.new("TextLabel")

            labelFrame.Name = "labelFrame"
            labelFrame.Parent = newPage
            labelFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            labelFrame.Position = UDim2.new(0.0367647074, 0, 0.0185185187, 0)
            labelFrame.Size = UDim2.new(0, 394, 0, 42)

            mainCorner.CornerRadius = UDim.new(0, 3)
            mainCorner.Name = "mainCorner"
            mainCorner.Parent = labelFrame

            txtLabel.Name = "txtLabel"
            txtLabel.Parent = labelFrame
            txtLabel.BackgroundTransparency = 1.000
            txtLabel.Position = UDim2.new(0, 0, 0.0238095243, 0)
            txtLabel.Size = UDim2.new(0, 395, 0, 41)
            txtLabel.Font = Enum.Font.GothamSemibold
            txtLabel.Text = labelText
            txtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            txtLabel.TextSize = 14.000
        end

        function ElementHandler:TextButton(buttonText, buttonInfo, callback)
            buttonText = buttonText or ""
            buttonInfo = buttonInfo or ""
            callback = callback or function() end

            local textButtonFrame = Instance.new("Frame")
            local mainCorner = Instance.new("UICorner")
            local TextButton = Instance.new("TextButton")
            local mainCorner_2 = Instance.new("UICorner")
            local textButtonInfo = Instance.new("TextLabel")

            textButtonFrame.Name = "textButtonFrame"
            textButtonFrame.Parent = newPage
            textButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            textButtonFrame.Position = UDim2.new(0.0147058824, 0, 0.0246913582, 0)
            textButtonFrame.Size = UDim2.new(0, 394, 0, 42)

            mainCorner.CornerRadius = UDim.new(0, 3)
            mainCorner.Name = "mainCorner"
            mainCorner.Parent = textButtonFrame

            TextButton.Parent = textButtonFrame
            TextButton.BackgroundColor3 = Color3.fromRGB(139, 0, 23) 
            TextButton.Position = UDim2.new(0.017766498, 0, 0.166666672, 0)
            TextButton.Size = UDim2.new(0, 141, 0, 27)
            TextButton.Font = Enum.Font.GothamSemibold
            TextButton.Text = buttonText
            TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextButton.TextSize = 14.000

            mainCorner_2.CornerRadius = UDim.new(0, 3)
            mainCorner_2.Name = "mainCorner"
            mainCorner_2.Parent = TextButton

            textButtonInfo.Name = "textButtonInfo"
            textButtonInfo.Parent = textButtonFrame
            textButtonInfo.BackgroundTransparency = 1.000
            textButtonInfo.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
            textButtonInfo.Size = UDim2.new(0, 226, 0, 41)
            textButtonInfo.Font = Enum.Font.GothamSemibold
            textButtonInfo.Text = buttonInfo
            textButtonInfo.TextColor3 = Color3.fromRGB(170, 170, 170)
            textButtonInfo.TextSize = 14.000
            textButtonInfo.TextXAlignment = Enum.TextXAlignment.Right

            TextButton.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

            function ElementHandler:Toggle(togInfo, callback)
                togInfo = togInfo or ""
                callback = callback or function() end

                local toggleFrame = Instance.new("Frame")
                local mainCorner = Instance.new("UICorner")
                local toggleInfo = Instance.new("TextLabel")
                local toggleInerFrame = Instance.new("Frame")
                local mainCorner_2 = Instance.new("UICorner")
                local toggleInnerFrame1 = Instance.new("Frame")
                local mainCorner_3 = Instance.new("UICorner")
                local toggleBtn = Instance.new("TextButton")
                local mainCorner_4 = Instance.new("UICorner")
                local UIListLayout = Instance.new("UIListLayout")
                local UIListLayout_2 = Instance.new("UIListLayout")

                toggleFrame.Name = "toggleFrame"
                toggleFrame.Parent = newPage
                toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                toggleFrame.Position = UDim2.new(0.0147058824, 0, 0.0246913582, 0)
                toggleFrame.Size = UDim2.new(0, 394, 0, 42)

                mainCorner.CornerRadius = UDim.new(0, 3)
                mainCorner.Name = "mainCorner"
                mainCorner.Parent = toggleFrame

                toggleInfo.Name = "toggleInfo"
                toggleInfo.Parent = toggleFrame
                toggleInfo.BackgroundTransparency = 1.000
                toggleInfo.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
                toggleInfo.Size = UDim2.new(0, 226, 0, 41)
                toggleInfo.Font = Enum.Font.GothamSemibold
                toggleInfo.Text = togInfo
                toggleInfo.TextColor3 = Color3.fromRGB(170, 170, 170)
                toggleInfo.TextSize = 14.000
                toggleInfo.TextXAlignment = Enum.TextXAlignment.Right

                toggleInerFrame.Name = "toggleInerFrame"
                toggleInerFrame.Parent = toggleFrame
                toggleInerFrame.BackgroundColor3 = Color3.fromRGB(139, 0, 23) 
                toggleInerFrame.Position = UDim2.new(0.0177664906, 0, 0.166666672, 0)
                toggleInerFrame.Size = UDim2.new(0, 27, 0, 27)

                mainCorner_2.CornerRadius = UDim.new(0, 3)
                mainCorner_2.Name = "mainCorner"
                mainCorner_2.Parent = toggleInerFrame

                toggleInnerFrame1.Name = "toggleInnerFrame1"
                toggleInnerFrame1.Parent = toggleInerFrame
                toggleInnerFrame1.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                
                toggleInnerFrame1.Position = UDim2.new(0.0177664906, 0, -0.0185185075, 0)
                toggleInnerFrame1.Size = UDim2.new(0, 25, 0, 25)

                mainCorner_3.CornerRadius = UDim.new(0, 3)
                mainCorner_3.Name = "mainCorner"
                mainCorner_3.Parent = toggleInnerFrame1

                toggleBtn.Name = "toggleBtn"
                toggleBtn.Parent = toggleInnerFrame1
                toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                
                toggleBtn.Position = UDim2.new(0, 0, 0, 0) 
                toggleBtn.Size = UDim2.new(0, 23, 0, 23)
                toggleBtn.Font = Enum.Font.GothamSemibold
                toggleBtn.Text = ""
                toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleBtn.TextSize = 14.000
                toggleBtn.AutoButtonColor = false

                mainCorner_4.CornerRadius = UDim.new(0, 3)
                mainCorner_4.Name = "mainCorner"
                mainCorner_4.Parent = toggleBtn

                UIListLayout.Parent = toggleInnerFrame1
                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                UIListLayout_2.Parent = toggleInerFrame
                UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
                UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

                local toggled = false
                local ToggleTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                
                toggleBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    pcall(callback, toggled)
                    local newPosition = toggled and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                    
                    if toggled then
                        TweenService:Create(toggleBtn, ToggleTweenInfo,{
                            BackgroundColor3 = Color3.fromRGB(139, 0, 23) 
                        }):Play()
                    else
                        TweenService:Create(toggleBtn, ToggleTweenInfo,{
                            BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                        }):Play()
                    end 
                    
                    TweenService:Create(toggleBtn, ToggleTweenInfo,{
                        Position = newPosition
                    }):Play()
                end)
            end

                function ElementHandler:Slider(sliderin, minvalue, maxvalue, callback)
                    minvalue = minvalue or 0
                    maxvalue = maxvalue or 500
                    callback = callback or function() end
                    sliderin = sliderin or "info ok"

                    local sliderFrame = Instance.new("Frame")
                    local mainCorner = Instance.new("UICorner")
                    local sliderInfo = Instance.new("TextLabel")
                    local sliderValue = Instance.new("TextLabel")
                    local sliderBtn = Instance.new("TextButton")
                    local sliderdragfrm = Instance.new("UIListLayout")
                    local sliderMainFrm = Instance.new("Frame")
                    local sliderlist = Instance.new("UIListLayout")
                    local mainCorner_2 = Instance.new("UICorner")
                    local mainCorner_3 = Instance.new("UICorner")

                    sliderFrame.Name = "sliderFrame"
                    sliderFrame.Parent = newPage
                    sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    sliderFrame.Position = UDim2.new(0.0147058824, 0, 0.0246913582, 0)
                    sliderFrame.Size = UDim2.new(0, 394, 0, 42)

                    mainCorner.CornerRadius = UDim.new(0, 3)
                    mainCorner.Name = "mainCorner"
                    mainCorner.Parent = sliderFrame

                    sliderInfo.Name = "sliderInfo"
                    sliderInfo.Parent = sliderFrame
                    sliderInfo.BackgroundTransparency = 1.000
                    sliderInfo.Position = UDim2.new(0.570575714, 0, 0.0238095243, 0)
                    sliderInfo.Size = UDim2.new(0, 157, 0, 41)
                    sliderInfo.Font = Enum.Font.GothamSemibold
                    sliderInfo.Text = sliderin
                    sliderInfo.TextColor3 = Color3.fromRGB(170, 170, 170)
                    sliderInfo.TextSize = 14.000
                    sliderInfo.TextXAlignment = Enum.TextXAlignment.Right

                    sliderValue.Name = "sliderValue"
                    sliderValue.Parent = sliderFrame
                    sliderValue.BackgroundTransparency = 1.000
                    sliderValue.Position = UDim2.new(0.395939082, 0, 0.285714298, 0)
                    sliderValue.Size = UDim2.new(0, 68, 0, 17)
                    sliderValue.Font = Enum.Font.GothamSemibold
                    sliderValue.Text = minvalue.."/"..maxvalue
                    sliderValue.TextColor3 = Color3.fromRGB(139, 0, 23) 
                    sliderValue.TextSize = 14.000
                    sliderValue.TextXAlignment = Enum.TextXAlignment.Left

                    sliderBtn.Name = "sliderBtn"
                    sliderBtn.Parent = sliderFrame
                    sliderBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
                    sliderBtn.BorderSizePixel = 0
                    sliderBtn.Position = UDim2.new(0.0179999992, 0, 0.381000012, 0)
                    sliderBtn.Size = UDim2.new(0, 141, 0, 10)
                    sliderBtn.AutoButtonColor = false
                    sliderBtn.Font = Enum.Font.SourceSans
                    sliderBtn.Text = ""
                    sliderBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                    sliderBtn.TextSize = 14.000

                    sliderdragfrm.Name = "sliderdragfrm"
                    sliderdragfrm.Parent = sliderBtn
                    sliderdragfrm.SortOrder = Enum.SortOrder.LayoutOrder
                    sliderdragfrm.VerticalAlignment = Enum.VerticalAlignment.Center

                    sliderMainFrm.Name = "sliderMainFrm"
                    sliderMainFrm.Parent = sliderBtn
                    sliderMainFrm.BackgroundColor3 = Color3.fromRGB(139, 0, 23) 
                    sliderMainFrm.BorderColor3 = Color3.fromRGB(139, 0, 23)
                    sliderMainFrm.BorderSizePixel = 0
                    sliderMainFrm.Size = UDim2.new(0, 0, 0, 10)

                    sliderlist.Name = "sliderlist"
                    sliderlist.Parent = sliderMainFrm
                    sliderlist.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    sliderlist.SortOrder = Enum.SortOrder.LayoutOrder
                    sliderlist.VerticalAlignment = Enum.VerticalAlignment.Center

                    mainCorner_2.CornerRadius = UDim.new(0, 5)
                    mainCorner_2.Name = "mainCorner"
                    mainCorner_2.Parent = sliderMainFrm
                    mainCorner_2.Archivable = false

                    mainCorner_3.CornerRadius = UDim.new(0, 3)
                    mainCorner_3.Name = "mainCorner"
                    mainCorner_3.Parent = sliderBtn

                    local mouse = game.Players.LocalPlayer:GetMouse()
                        local uis = game:GetService("UserInputService")
                        local Value;

                        sliderBtn.MouseButton1Down:Connect(function()
                            Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 141) * sliderMainFrm.AbsoluteSize.X) + tonumber(minvalue)) or 0
                            pcall(function()
                                callback(Value)
                            end)
                            sliderMainFrm.Size = UDim2.new(0, math.clamp(mouse.X - sliderBtn.AbsolutePosition.X, 0, 141), 0, 10) 

                            local moveconnection = mouse.Move:Connect(function()
                                sliderMainFrm.Size = UDim2.new(0, math.clamp(mouse.X - sliderBtn.AbsolutePosition.X, 0, 141), 0, 10)
                                Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 141) * sliderMainFrm.AbsoluteSize.X) + tonumber(minvalue))
                                sliderValue.Text = Value.."/"..maxvalue
                                pcall(function()
                                    callback(Value)
                                end)
                            end)
                            local releaseconnection = uis.InputEnded:Connect(function(Mouse)
                                if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
                                    sliderMainFrm.Size = UDim2.new(0, math.clamp(mouse.X - sliderBtn.AbsolutePosition.X, 0, 141), 0, 10)
                                    Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 141) * sliderMainFrm.AbsoluteSize.X) + tonumber(minvalue))
                                    sliderValue.Text = Value.."/"..maxvalue
                                    pcall(function()
                                        callback(Value)
                                    end)
                                    moveconnection:Disconnect()
                                    releaseconnection:Disconnect()
                                end
                            end)
                        end)
                    end

                        function ElementHandler:KeyBind(keInfo, firstt, callback)
                            local oldKey = firstt.Name
                            keInfo = keInfo or ""
                            callback = callback or function() end

                            local keybindFrame = Instance.new("Frame")
                            local mainCorner = Instance.new("UICorner")
                            local TextButton = Instance.new("TextButton")
                            local mainCorner_2 = Instance.new("UICorner")
                            local keybindinfo = Instance.new("TextLabel")

                            keybindFrame.Name = "keybindFrame"
                            keybindFrame.Parent = newPage
                            keybindFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                            keybindFrame.Position = UDim2.new(0.0147058824, 0, 0.0246913582, 0)
                            keybindFrame.Size = UDim2.new(0, 394, 0, 42)

                            mainCorner.CornerRadius = UDim.new(0, 3)
                            mainCorner.Name = "mainCorner"
                            mainCorner.Parent = keybindFrame

                            TextButton.Parent = keybindFrame
                            TextButton.BackgroundColor3 = Color3.fromRGB(139, 0, 23) 
                            TextButton.Position = UDim2.new(0.017766498, 0, 0.166666672, 0)
                            TextButton.Size = UDim2.new(0, 76, 0, 27)
                            TextButton.Font = Enum.Font.GothamSemibold
                            TextButton.Text = oldKey
                            TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                            TextButton.TextSize = 14.000

                            mainCorner_2.CornerRadius = UDim.new(0, 3)
                            mainCorner_2.Name = "mainCorner"
                            mainCorner_2.Parent = TextButton

                            keybindinfo.Name = "keybindinfo"
                            keybindinfo.Parent = keybindFrame
                            keybindinfo.BackgroundTransparency = 1.000
                            keybindinfo.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
                            keybindinfo.Size = UDim2.new(0, 226, 0, 41)
                            keybindinfo.Font = Enum.Font.GothamSemibold
                            keybindinfo.Text = keInfo
                            keybindinfo.TextColor3 = Color3.fromRGB(170, 170, 170)
                            keybindinfo.TextSize = 14.000
                            keybindinfo.TextXAlignment = Enum.TextXAlignment.Right

                            TextButton.MouseButton1Click:connect(function(e) 
                                TextButton.Text = ". . ."
                                local a, b = game:GetService('UserInputService').InputBegan:wait();
                                if a.KeyCode.Name ~= "Unknown" then
                                    TextButton.Text = a.KeyCode.Name
                                    oldKey = a.KeyCode.Name;
                                end
                            end)

                            game:GetService("UserInputService").InputBegan:connect(function(current, ok) 
                                if not ok then 
                                    if current.KeyCode.Name == oldKey then 
                                        pcall(callback)
                                    end
                                end
                            end)
                        end

                            function ElementHandler:TextBox(textInfo, placeHolderText1, callback)
                                textInfo = textInfo or ""
                                placeHolderText1 = placeHolderText1 or ""
                                callback = callback or function() end
                                local textBoxFrame = Instance.new("Frame")
                                local mainCorner = Instance.new("UICorner")
                                local textboxInfo = Instance.new("TextLabel")
                                local texboxInner = Instance.new("Frame")
                                local mainCorner_2 = Instance.new("UICorner")
                                local textboxinneer = Instance.new("Frame")
                                local mainCorner_3 = Instance.new("UICorner")
                                local UIListLayout = Instance.new("UIListLayout")
                                local TextBox = Instance.new("TextBox")
                                local UIListLayout_2 = Instance.new("UIListLayout")

                                --Properties:

                                textBoxFrame.Name = "textBoxFrame"
                                textBoxFrame.Parent = newPage
                                textBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                                textBoxFrame.Position = UDim2.new(0.0147058824, 0, 0.0246913582, 0)
                                textBoxFrame.Size = UDim2.new(0, 394, 0, 42)

                                mainCorner.CornerRadius = UDim.new(0, 3)
                                mainCorner.Name = "mainCorner"
                                mainCorner.Parent = textBoxFrame

                                textboxInfo.Name = "textboxInfo"
                                textboxInfo.Parent = textBoxFrame
                                textboxInfo.BackgroundTransparency = 1.000
                                textboxInfo.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
                                textboxInfo.Size = UDim2.new(0, 226, 0, 41)
                                textboxInfo.Font = Enum.Font.GothamSemibold
                                textboxInfo.Text = textInfo
                                textboxInfo.TextColor3 = Color3.fromRGB(170, 170, 170)
                                textboxInfo.TextSize = 14.000
                                textboxInfo.TextXAlignment = Enum.TextXAlignment.Right

                                texboxInner.Name = "texboxInner"
                                texboxInner.Parent = textBoxFrame
                                texboxInner.BackgroundColor3 = Color3.fromRGB(139, 0, 23) 
                                texboxInner.Position = UDim2.new(0.017766498, 0, 0.166666672, 0)
                                texboxInner.Size = UDim2.new(0, 141, 0, 27)

                                mainCorner_2.CornerRadius = UDim.new(0, 3)
                                mainCorner_2.Name = "mainCorner"
                                mainCorner_2.Parent = texboxInner

                                textboxinneer.Name = "textboxinneer"
                                textboxinneer.Parent = texboxInner
                                textboxinneer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                                textboxinneer.ClipsDescendants = true
                                
                                textboxinneer.Position = UDim2.new(0.00709219852, 0, 0.0370370373, 0) 
                                textboxinneer.Size = UDim2.new(0, 139, 0, 25)

                                mainCorner_3.CornerRadius = UDim.new(0, 3)
                                mainCorner_3.Name = "mainCorner"
                                mainCorner_3.Parent = textboxinneer

                                UIListLayout.Parent = textboxinneer
                                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                                TextBox.Parent = textboxinneer
                                TextBox.BackgroundTransparency = 1.000
                                TextBox.Size = UDim2.new(1, -5, 1, -5) 
                                TextBox.Position = UDim2.new(0, 2, 0, 0) 
                                TextBox.Font = Enum.Font.GothamSemibold
                                TextBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
                                TextBox.PlaceholderText = placeHolderText1
                                TextBox.Text = ""
                                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                                TextBox.TextSize = 13.000
                                TextBox.TextWrapped = true
                                TextBox.TextXAlignment = Enum.TextXAlignment.Left

                                UIListLayout_2.Parent = texboxInner
                                UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
                                UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

                                TextBox.FocusLost:Connect(function(EnterPressed)
                                    if not EnterPressed then return end
                                    pcall(callback, TextBox.Text)
                                    TextBox.Text = ""
                                end)
                            end 

                                function ElementHandler:Dropdown(dInfo, list, callback)
                                    dInfo = dInfo or ""
                                    list = list or {}
                                    callback = callback or function() end

                                    local isDropped = false

                                    local dropDownFrame = Instance.new("Frame")
                                    local mainCorner = Instance.new("UICorner")
                                    local dropdownmain = Instance.new("Frame")
                                    local mainCorner_2 = Instance.new("UICorner")
                                    local dropdownItem = Instance.new("TextLabel")
                                    local ImageButton = Instance.new("ImageButton")
                                    local UIListLayout = Instance.new("UIListLayout")

                                    local DropYSize = 42

                                    dropDownFrame.Name = "dropDownFrame"
                                    dropDownFrame.Parent = newPage
                                    dropDownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                                    dropDownFrame.ClipsDescendants = true
                                    dropDownFrame.Position = UDim2.new(0.011029412, 0, 0.0205760058, 0)
                                    dropDownFrame.Size = UDim2.new(0, 394, 0, 42)

                                    mainCorner.CornerRadius = UDim.new(0, 3)
                                    mainCorner.Name = "mainCorner"
                                    mainCorner.Parent = dropDownFrame

                                    dropdownmain.Name = "dropdownmain"
                                    dropdownmain.Parent = dropDownFrame
                                    dropdownmain.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                                    dropdownmain.Size = UDim2.new(0, 394, 0, 42)

                                    mainCorner_2.CornerRadius = UDim.new(0, 3)
                                    mainCorner_2.Name = "mainCorner"
                                    mainCorner_2.Parent = dropdownmain

                                    dropdownItem.Name = "dropdownItem"
                                    dropdownItem.Parent = dropdownmain
                                    dropdownItem.BackgroundTransparency = 1.000
                                    dropdownItem.Position = UDim2.new(0.0223523453, 0, 0, 0)
                                    dropdownItem.Size = UDim2.new(0, 291, 0, 41)
                                    dropdownItem.Font = Enum.Font.GothamSemibold
                                    dropdownItem.Text = dInfo
                                    dropdownItem.TextColor3 = Color3.fromRGB(139, 0, 23) 
                                    dropdownItem.TextSize = 14.000
                                    dropdownItem.TextXAlignment = Enum.TextXAlignment.Left

                                    ImageButton.Parent = dropdownmain
                                    ImageButton.BackgroundTransparency = 1.000
                                    ImageButton.Position = UDim2.new(0.89974618, 0, 0.238095239, 0)
                                    ImageButton.Size = UDim2.new(0, 27, 0, 21)
                                    ImageButton.Image = "rbxassetid://5165666242"
                                    ImageButton.ImageColor3 = Color3.fromRGB(139, 0, 23) 
                                    ImageButton.MouseButton1Click:Connect(function()
                                        local DropdownTweenDuration = 0.15
                                        local DropdownRotateDuration = 0.15
                                        if isDropped then
                                            isDropped = false
                                            dropDownFrame:TweenSize(UDim2.new(0, 394, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, DropdownTweenDuration) 
                                            TweenService:Create(ImageButton, TweenInfo.new(DropdownRotateDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{ 
                                                Rotation = 0
                                            }):Play()
                                            task.wait(DropdownTweenDuration)
                                            UpdateSize()
                                        else
                                            isDropped = true
                                            dropDownFrame:TweenSize(UDim2.new(0, 394, 0, DropYSize), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, DropdownTweenDuration) 
                                            TweenService:Create(ImageButton, TweenInfo.new(DropdownRotateDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),{ 
                                                Rotation = 180
                                            }):Play()
                                            task.wait(DropdownTweenDuration)
                                            UpdateSize()
                                        end
                                    end)


                                    UIListLayout.Parent = dropDownFrame
                                    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                                    UIListLayout.Padding = UDim.new(0, 5)

                                    for i,v in next, list do
                                        local optionBtn = Instance.new("TextButton")
                                        local mainCorner_3 = Instance.new("UICorner")

                                        optionBtn.Name = "optionBtn"
                                        optionBtn.Parent = dropDownFrame
                                        optionBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 10)
                                        optionBtn.Position = UDim2.new(0.0253807101, 0, 0.311258286, 0)
                                        optionBtn.Size = UDim2.new(0, 377, 0, 39)
                                        optionBtn.Font = Enum.Font.GothamSemibold
                                        optionBtn.Text = "   "..v
                                        optionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        optionBtn.TextSize = 14.000
                                        optionBtn.TextXAlignment = Enum.TextXAlignment.Left
                                        DropYSize = DropYSize + 48
                                        mainCorner_3.CornerRadius = UDim.new(0, 3)
                                        mainCorner_3.Name = "mainCorner"
                                        mainCorner_3.Parent = optionBtn

                                        optionBtn.MouseButton1Click:Connect(function()
                                            local DropdownTweenDuration = 0.15
                                            pcall(callback, v)
                                            dropdownItem.Text = dInfo..": "..v
                                            dropDownFrame:TweenSize(UDim2.new(0, 394, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, DropdownTweenDuration)
                                            task.wait(DropdownTweenDuration)
                                            UpdateSize()
                                            TweenService:Create(ImageButton, TweenInfo.new(DropdownTweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{ 
                                                Rotation = 0
                                            }):Play()
                                            isDropped = false
                                        end)
                                    end
        end

        function ElementHandler:Separator(separatorText)
            separatorText = separatorText or ""

            local sepFrame = Instance.new("Frame")
            local mainCorner = Instance.new("UICorner")
            local line = Instance.new("Frame")
            local text = Instance.new("TextLabel")

            sepFrame.Name = "Separator"
            sepFrame.Parent = newPage
            sepFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) 
            sepFrame.Size = UDim2.new(0, 394, 0, 22)

            mainCorner.CornerRadius = UDim.new(0, 3)
            mainCorner.Parent = sepFrame

            -- Thin line
            line.Name = "Line"
            line.Parent = sepFrame
            line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            line.Position = UDim2.new(0.01, 0, 0.5, 0)
            line.Size = UDim2.new(0, 386, 0, 1)
            line.AnchorPoint = Vector2.new(0, 0.5)

            -- Text (if provided)
            text.Name = "Text"
            text.Parent = sepFrame
            text.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            text.BackgroundTransparency = 1
            text.Size = UDim2.new(1, 0, 1, 0)
            text.Font = Enum.Font.GothamSemibold
            text.Text = separatorText
            text.TextColor3 = Color3.fromRGB(170, 170, 170)
            text.TextSize = 12
            text.TextXAlignment = Enum.TextXAlignment.Center
        end

        function ElementHandler:ColorPicker(colorInfo, defaultColor, callback)
            colorInfo = colorInfo or "Color Picker"
            defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
            callback = callback or function() end

            local colorFrame = Instance.new("Frame")
            local mainCorner = Instance.new("UICorner")
            local colorInfoLabel = Instance.new("TextLabel")
            local colorSwatchButton = Instance.new("TextButton")
            local swatchCorner = Instance.new("UICorner")

            colorFrame.Name = "colorFrame"
            colorFrame.Parent = newPage
            colorFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            colorFrame.Size = UDim2.new(0, 394, 0, 42)

            mainCorner.CornerRadius = UDim.new(0, 3)
            mainCorner.Parent = colorFrame

            -- Info Label
            colorInfoLabel.Parent = colorFrame
            colorInfoLabel.BackgroundTransparency = 1.000
            colorInfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
            colorInfoLabel.Size = UDim2.new(0, 200, 0, 41)
            colorInfoLabel.Font = Enum.Font.GothamSemibold
            colorInfoLabel.Text = colorInfo
            colorInfoLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
            colorInfoLabel.TextSize = 14.000
            colorInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

            -- Color Swatch Button (Acts as a display and a click trigger)
            colorSwatchButton.Name = "ColorSwatch"
            colorSwatchButton.Parent = colorFrame
            colorSwatchButton.BackgroundColor3 = defaultColor
            colorSwatchButton.Position = UDim2.new(0.965, 0, 0.5, 0)
            colorSwatchButton.AnchorPoint = Vector2.new(1, 0.5)
            colorSwatchButton.Size = UDim2.new(0, 30, 0, 30)
            colorSwatchButton.Text = ""
            colorSwatchButton.AutoButtonColor = false

            swatchCorner.CornerRadius = UDim.new(0, 3)
            swatchCorner.Parent = colorSwatchButton

            local currentColor = defaultColor

            colorSwatchButton.MouseButton1Click:Connect(function()
                -- *SIMULATION* (จำลองการเลือกสีใหม่):
                local simulatedNewColor = Color3.fromHSV(math.random(), 1, 1) 
                currentColor = simulatedNewColor
                colorSwatchButton.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
            end)

            pcall(callback, defaultColor)

            return function(newColor)
                currentColor = newColor
                colorSwatchButton.BackgroundColor3 = newColor
                pcall(callback, newColor)
            end
        end

        return ElementHandler
    end
    -- Return both SectionHandler and the new Alert/Notify functions
    return SectionHandler
end 


return SlayLib
