local SlayLibExtra = {}

-- Define the new, refined color palette and constants
local Palette = {
    BG_DARK = Color3.fromRGB(18, 18, 18),         -- Main Background Frame
    BG_CARD = Color3.fromRGB(24, 24, 24),         -- Element/Tab Background
    ACCENT = Color3.fromRGB(0, 191, 255),         -- Vibrant Cyan/Deep Sky Blue
    TEXT_MAIN = Color3.fromRGB(255, 255, 255),    -- White text
    TEXT_SECONDARY = Color3.fromRGB(160, 160, 160),-- Gray secondary text
    STROKE_COLOR = Color3.fromRGB(35, 35, 35),    -- Subtle Border/Switch Track Color
    CORNER_RADIUS = 8,                            -- Global Corner Radius
    ELEMENT_HEIGHT = 45,                          -- Standard element height
    TAB_WIDTH = 130
}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris") 
local task = task 

-- Notification Constants
local NotifWidth = 320
local NotifHeight = 70
local NotifFadeTime = 0.35
local NotifVisibleTime = 4.0

-- Notification Status Mapping (using the new palette)
local StatusMapping = {
    Info = {
        Color = Palette.ACCENT, 
        Icon = "rbxassetid://10632598818" -- Info icon (i)
    },
    Success = {
        Color = Color3.fromRGB(0, 170, 0), -- Green
        Icon = "rbxassetid://10632598687" -- Checkmark icon
    },
    Warning = {
        Color = Color3.fromRGB(255, 170, 0), -- Orange/Yellow
        Icon = "rbxassetid://10632599540" -- Warning icon (!)
    },
    Error = {
        Color = Color3.fromRGB(200, 50, 50), -- Red
        Icon = "rbxassetid://10632599187" -- X / Error icon
    }
}

-- Global Notification System (Integrated into the library)
local NotificationQueue = {}
local ActiveNotifications = {} 
local Camera = workspace:WaitForChild("Camera")

local function UpdateNotificationPositions()
    local currentYOffset = 20 
    
    -- Loop from the bottom (highest index) to the top
    for i = #ActiveNotifications, 1, -1 do
        local NotifFrame = ActiveNotifications[i]
        local targetY = -NotifFrame.Size.Y.Offset - currentYOffset
        local targetPosition = UDim2.new(1, -NotifWidth - 20, 1, targetY)

        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPosition
        }):Play()

        currentYOffset = currentYOffset + NotifFrame.Size.Y.Offset + 10 -- 10 is spacing
    end
end

local function ProcessQueue()
    if #NotificationQueue > 0 then
        local nextNotifData = table.remove(NotificationQueue, 1)
        task.spawn(function()
            -- Re-call Alert to show the next notification
            SlayLibExtra:Alert(nextNotifData.status, nextNotifData.title, nextNotifData.message, nextNotifData.duration)
        end)
    end
end

local function DismissNotification(NotifFrame, autoDismiss)
    local index = table.find(ActiveNotifications, NotifFrame)
    if not index then 
        if NotifFrame and NotifFrame.Parent then NotifFrame:Destroy() end
        return 
    end

    local fadeTime = NotifFadeTime
    
    -- Start simultaneous fade-out for all elements
    local tweens = {}
    local function applyFade(instance)
        local transparencyProps = {}
        if instance:IsA("Frame") or instance:IsA("TextButton") or instance:IsA("ImageButton") or instance:IsA("UIStroke") then
            if instance:IsA("UIStroke") then
                transparencyProps.Transparency = 1 
            else
                transparencyProps.BackgroundTransparency = 1
            end
        end
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            transparencyProps.TextTransparency = 1
        end
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            transparencyProps.ImageTransparency = 1
        end
        
        if next(transparencyProps) then
            local t = TweenService:Create(instance, TweenInfo.new(fadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), transparencyProps)
            table.insert(tweens, t)
            t:Play()
        end

        for _, child in instance:GetChildren() do
            applyFade(child)
        end
    end

    applyFade(NotifFrame)

    task.wait(fadeTime) -- Wait for the entire fade duration

    table.remove(ActiveNotifications, index)
    Debris:AddItem(NotifFrame, 0.1) 

    UpdateNotificationPositions()
    task.spawn(ProcessQueue)
end

local function ShowNotification(notifData)
    local statusData = StatusMapping[notifData.status]
    local duration = math.clamp(notifData.duration, 1, 15)
    
    if #ActiveNotifications >= 10 then -- Limit active notifications
        table.insert(NotificationQueue, notifData)
        return
    end

    -- 1. Create UI Instances (Sleek, Modern Design)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "SlayNotif_"..notifData.status
    NotifFrame.Parent = game.CoreGui 
    NotifFrame.BackgroundColor3 = Palette.BG_CARD
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Size = UDim2.new(0, NotifWidth, 0, NotifHeight)
    NotifFrame.ZIndex = 10 
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, Palette.CORNER_RADIUS)
    notifCorner.Parent = NotifFrame

    -- Inner Stroke/Shadow (Subtle)
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Parent = NotifFrame
    notifStroke.Color = Color3.fromRGB(0, 0, 0)
    notifStroke.Transparency = 0.8
    notifStroke.Thickness = 1
    notifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Accent Line (Top)
    local notifAccentLine = Instance.new("Frame")
    notifAccentLine.Name = "AccentLine"
    notifAccentLine.Parent = NotifFrame
    notifAccentLine.BackgroundColor3 = statusData.Color 
    notifAccentLine.Size = UDim2.new(1, 0, 0, 4) -- Thin line at the top
    notifAccentLine.Position = UDim2.new(0, 0, 0, 0)
    
    -- Padding for content
    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = NotifFrame
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)

    -- Content Layout
    local contentList = Instance.new("UIListLayout")
    contentList.Parent = NotifFrame
    contentList.FillDirection = Enum.FillDirection.Vertical
    contentList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding = UDim.new(0, 4)

    -- Top Row (Icon & Title)
    local TopRow = Instance.new("Frame")
    TopRow.Name = "TopRow"
    TopRow.Parent = NotifFrame
    TopRow.BackgroundTransparency = 1
    TopRow.Size = UDim2.new(1, -30, 0, 18)
    
    local topRowList = Instance.new("UIListLayout")
    topRowList.Parent = TopRow
    topRowList.FillDirection = Enum.FillDirection.Horizontal
    topRowList.VerticalAlignment = Enum.VerticalAlignment.Center
    topRowList.Padding = UDim.new(0, 5)

    -- Icon
    local notifIcon = Instance.new("ImageLabel")
    notifIcon.Name = "StatusIcon"
    notifIcon.Parent = TopRow
    notifIcon.BackgroundTransparency = 1
    notifIcon.Image = statusData.Icon
    notifIcon.ImageColor3 = statusData.Color
    notifIcon.Size = UDim2.new(0, 18, 0, 18)

    -- Title
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Name = "Title"
    notifTitle.Parent = TopRow
    notifTitle.BackgroundTransparency = 1.000
    notifTitle.Size = UDim2.new(0, 1, 1, 0) 
    notifTitle.Font = Enum.Font.GothamSemibold
    notifTitle.Text = notifData.title
    notifTitle.TextColor3 = Palette.TEXT_MAIN
    notifTitle.TextSize = 14.000
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.LayoutOrder = 1

    -- Message
    local notifMessage = Instance.new("TextLabel")
    notifMessage.Name = "Message"
    notifMessage.Parent = NotifFrame
    notifMessage.BackgroundTransparency = 1.000
    notifMessage.Size = UDim2.new(1, -30, 0, 15) 
    notifMessage.Font = Enum.Font.Gotham
    notifMessage.Text = notifData.message
    notifMessage.TextColor3 = Palette.TEXT_SECONDARY 
    notifMessage.TextSize = 12.000
    notifMessage.TextXAlignment = Enum.TextXAlignment.Left
    notifMessage.TextYAlignment = Enum.TextYAlignment.Top
    notifMessage.TextWrapped = true
    
    -- Dismiss Button (X)
    local DismissButton = Instance.new("TextButton")
    DismissButton.Name = "Dismiss"
    DismissButton.Parent = NotifFrame
    DismissButton.BackgroundTransparency = 1
    DismissButton.Position = UDim2.new(1, -15, 0, 0)
    DismissButton.Size = UDim2.new(0, 15, 0, 15)
    DismissButton.Text = "✕"
    DismissButton.TextColor3 = Palette.TEXT_SECONDARY
    DismissButton.TextSize = 16
    DismissButton.Font = Enum.Font.GothamSemibold
    DismissButton.TextYAlignment = Enum.TextYAlignment.Top
    
    -- 2. Initial Setup 
    NotifFrame.Position = UDim2.new(1.1, 0, 1, -NotifHeight - 20) 
    
    -- 3. Add to active list 
    table.insert(ActiveNotifications, 1, NotifFrame) 

    -- 4. Animate In (From right)
    TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -NotifWidth - 20, 1, NotifFrame.Position.Y.Offset), 
    }):Play()

    -- 5. Update all positions
    UpdateNotificationPositions()

    -- 6. Connect dismiss
    DismissButton.MouseButton1Click:Connect(function()
        DismissNotification(NotifFrame, false) 
    end)
    
    -- 7. Auto-Dismiss timer
    task.delay(duration, function()
        if table.find(ActiveNotifications, NotifFrame) then
            DismissNotification(NotifFrame, true) 
        end
    end)
end
-- End of Notification System

function SlayLibExtra:CreateSlayLib(libName)
    libName = libName or "SlayLib Extra"
    local isClosed = false

    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainStroke = Instance.new("UIStroke")
    local TabFrame = Instance.new("Frame")
    local TabList = Instance.new("UIListLayout")
    local TabPadding = Instance.new("UIPadding")
    local Header = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("ImageButton")
    local ContentFrame = Instance.new("Frame")
    local ContentCorner = Instance.new("UICorner")
    local PagesFolder = Instance.new("Folder")

    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame (The whole window)
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Palette.BG_DARK
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
    MainFrame.Size = UDim2.new(0, 560, 0, 380) 

    MainCorner.CornerRadius = UDim.new(0, Palette.CORNER_RADIUS)
    MainCorner.Parent = MainFrame
    
    -- Outer Stroke for premium look
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(0, 0, 0)
    MainStroke.Transparency = 0.6
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Header (Top Bar for dragging and title)
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.BackgroundColor3 = Palette.ACCENT -- Accent Color
    Header.Size = UDim2.new(1, 0, 0, 35)

    -- Top Corners for Header
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, Palette.CORNER_RADIUS)
    HeaderCorner.CornerAxis = Enum.CornerAxis.Y
    HeaderCorner.Parent = Header
    
    TitleLabel.Name = "LibTitle"
    TitleLabel.Parent = Header
    TitleLabel.BackgroundTransparency = 1.000
    TitleLabel.Position = UDim2.new(0.01, 0, 0, 0)
    TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.Text = libName
    TitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0) -- Dark text on bright accent
    TitleLabel.TextSize = 16.000
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    CloseButton.Name = "CloseLib"
    CloseButton.Parent = Header
    CloseButton.BackgroundTransparency = 1.000
    CloseButton.Position = UDim2.new(1, -30, 0.5, 0)
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Image = "rbxassetid://4988112250" -- Close icon
    CloseButton.ImageColor3 = Color3.fromRGB(0, 0, 0)

    -- Dragging functionality (unchanged)
    local DragMousePosition
    local FramePosition
    local Draggable = false
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = true
            DragMousePosition = Vector2.new(input.Position.X, input.Position.Y)
            FramePosition = Vector2.new(MainFrame.Position.X.Scale, MainFrame.Position.Y.Scale)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Draggable == true then
            local NewPosition = FramePosition + ((Vector2.new(input.Position.X, input.Position.Y) - DragMousePosition) / Camera.ViewportSize)
            MainFrame.Position = UDim2.new(NewPosition.X, 0, NewPosition.Y, 0)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = false
        end
    end)
    
    -- Close/Open Logic
    CloseButton.MouseButton1Click:Connect(function()
        local Duration = 0.2
        if isClosed then
            isClosed = false
            CloseButton.Image = "rbxassetid://4988112250"
            MainFrame:TweenSize(UDim2.new(0, 560, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, Duration, true)
        else
            isClosed = true
            CloseButton.Image = "rbxassetid://5165666242" -- Arrow icon
            MainFrame:TweenSize(UDim2.new(0, 560, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, Duration, true)
        end
    end)

    -- Tab Frame (Left Panel)
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = MainFrame
    TabFrame.BackgroundColor3 = Palette.BG_CARD
    TabFrame.Position = UDim2.new(0, 0, 0, 35)
    TabFrame.Size = UDim2.new(0, Palette.TAB_WIDTH, 1, -35) 

    local TabFrameCorner = Instance.new("UICorner")
    TabFrameCorner.CornerRadius = UDim.new(0, Palette.CORNER_RADIUS)
    TabFrameCorner.CornerAxis = Enum.CornerAxis.X
    TabFrameCorner.Parent = TabFrame

    TabList.Name = "TabList"
    TabList.Parent = TabFrame
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)

    TabPadding.Name = "TabPadding"
    TabPadding.Parent = TabFrame
    TabPadding.PaddingTop = UDim.new(0, 10)
    
    -- Content Frame (Right Panel)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundColor3 = Palette.BG_DARK
    ContentFrame.Position = UDim2.new(0, Palette.TAB_WIDTH, 0, 35)
    ContentFrame.Size = UDim2.new(1, -Palette.TAB_WIDTH, 1, -35)

    ContentCorner.CornerRadius = UDim.new(0, Palette.CORNER_RADIUS)
    ContentCorner.Parent = ContentFrame

    PagesFolder.Parent = ContentFrame
    
    -- Public Alert/Notify functions are defined globally above
    
    local SectionHandler = {}

    function SectionHandler:CreateSection(secName)
        secName = secName or "Tab"
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        local TabCorner = Instance.new("UICorner")

        TabButton.Name = "TabBtn"..secName
        TabButton.Parent = TabFrame
        TabButton.BackgroundColor3 = Palette.BG_CARD
        TabButton.Size = UDim2.new(0, Palette.TAB_WIDTH - 20, 0, 35) -- Slightly wider button
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = secName
        TabButton.TextColor3 = Palette.TEXT_SECONDARY
        TabButton.TextSize = 14.000
        TabButton.AutoButtonColor = false

        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        -- Content Page
        local newPage = Instance.new("ScrollingFrame")
        local pageItemList = Instance.new("UIListLayout")
        local UIPadding = Instance.new("UIPadding")

        newPage.Name = "Page"..secName
        newPage.Parent = PagesFolder
        newPage.Active = true
        newPage.BackgroundTransparency = 1.000
        newPage.BorderSizePixel = 0
        newPage.Size = UDim2.new(1, 0, 1, 0)
        newPage.ScrollBarThickness = 5
        newPage.ScrollBarImageColor3 = Palette.ACCENT 
        newPage.Visible = false
        newPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = newPage
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)

        pageItemList.Name = "pageItemList"
        pageItemList.Parent = newPage
        pageItemList.FillDirection = Enum.FillDirection.Vertical
        pageItemList.HorizontalAlignment = Enum.HorizontalAlignment.Left
        pageItemList.SortOrder = Enum.SortOrder.LayoutOrder
        pageItemList.Padding = UDim.new(0, 8)

        local function UpdateCanvasSize()
            local cS = pageItemList.AbsoluteContentSize
            newPage.CanvasSize = UDim2.new(0, 0, 0, cS.Y + 20)
        end

        newPage.ChildAdded:Connect(UpdateCanvasSize)
        newPage.ChildRemoved:Connect(UpdateCanvasSize)
        pageItemList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
        UpdateCanvasSize()

        -- Tab Selection Logic
        TabButton.MouseButton1Click:Connect(function()
            for _, v in next, PagesFolder:GetChildren() do
                v.Visible = false
            end
            newPage.Visible = true
            
            local TabTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) 

            for _, v in next, TabFrame:GetChildren() do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TabTweenInfo,{
                        BackgroundColor3 = Palette.BG_CARD,
                        TextColor3 = Palette.TEXT_SECONDARY
                    }):Play()
                end
            end
            
            -- Highlight selected tab
            TweenService:Create(TabButton, TabTweenInfo,{
                BackgroundColor3 = Palette.ACCENT, 
                TextColor3 = Color3.fromRGB(0, 0, 0)
            }):Play()
            UpdateCanvasSize()
        end)

        local ElementHandler = {}
        
        -- Helper function for creating a standard container frame
        local function createContainer(parent)
            local container = Instance.new("Frame")
            container.Parent = parent
            container.BackgroundColor3 = Palette.BG_CARD
            container.Size = UDim2.new(1, 0, 0, Palette.ELEMENT_HEIGHT) 
            container.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = container
            
            return container
        end

        -- 1. TextLabel
        function ElementHandler:TextLabel(labelText)
            local container = createContainer(newPage)
            container.Size = UDim2.new(1, 0, 0, 30) 
            
            local label = Instance.new("TextLabel")
            label.Parent = container
            label.BackgroundTransparency = 1.000
            label.Position = UDim2.new(0.03, 0, 0, 0)
            label.Size = UDim2.new(0.94, 0, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = labelText or "Info Label"
            label.TextColor3 = Palette.TEXT_MAIN
            label.TextSize = 14.000
            label.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        -- 2. Separator
        function ElementHandler:Separator(separatorText)
            local sepFrame = Instance.new("Frame")
            sepFrame.Name = "Separator"
            sepFrame.Parent = newPage
            sepFrame.BackgroundTransparency = 1
            sepFrame.Size = UDim2.new(1, 0, 0, 25)

            local line = Instance.new("Frame")
            line.Name = "Line"
            line.Parent = sepFrame
            line.BackgroundColor3 = Palette.STROKE_COLOR
            line.Position = UDim2.new(0.5, 0, 0.5, 0)
            line.Size = UDim2.new(1, -10, 0, 1)
            line.AnchorPoint = Vector2.new(0.5, 0.5)

            if separatorText and separatorText ~= "" then
                local text = Instance.new("TextLabel")
                text.Name = "Text"
                text.Parent = sepFrame
                text.BackgroundColor3 = Palette.BG_DARK 
                text.Size = UDim2.new(0, 150, 1, 0)
                text.Position = UDim2.new(0.5, 0, 0.5, 0)
                text.AnchorPoint = Vector2.new(0.5, 0.5)
                text.Font = Enum.Font.GothamSemibold
                text.Text = " "..separatorText.." "
                text.TextColor3 = Palette.TEXT_SECONDARY
                text.TextSize = 12
            end
        end

        -- 3. TextButton
        function ElementHandler:Button(buttonText, callback)
            local container = createContainer(newPage)
            
            local Button = Instance.new("TextButton")
            Button.Parent = container
            Button.BackgroundColor3 = Palette.ACCENT
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = buttonText or "Execute"
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        -- 4. Toggle (Modern Pill Switch)
        function ElementHandler:Toggle(togInfo, callback)
            local container = createContainer(newPage)
            
            -- Info Label
            local label = Instance.new("TextLabel")
            label.Parent = container
            label.BackgroundTransparency = 1.000
            label.Position = UDim2.new(0.03, 0, 0, 0)
            label.Size = UDim2.new(0.8, 0, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = togInfo or "Toggle Feature"
            label.TextColor3 = Palette.TEXT_MAIN
            label.TextSize = 14.000
            label.TextXAlignment = Enum.TextXAlignment.Left

            -- Switch Track (Background)
            local switchTrack = Instance.new("Frame")
            switchTrack.Name = "SwitchTrack"
            switchTrack.Parent = container
            switchTrack.BackgroundColor3 = Palette.STROKE_COLOR -- Default Off Color
            switchTrack.Size = UDim2.new(0, 45, 0, 25)
            switchTrack.Position = UDim2.new(1, -10, 0.5, 0)
            switchTrack.AnchorPoint = Vector2.new(1, 0.5)
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(0, 12.5) -- Half of height
            trackCorner.Parent = switchTrack

            -- Switch Thumb (Circle)
            local switchThumb = Instance.new("Frame")
            switchThumb.Name = "SwitchThumb"
            switchThumb.Parent = switchTrack
            switchThumb.BackgroundColor3 = Palette.TEXT_MAIN
            switchThumb.Size = UDim2.new(0, 20, 0, 20)
            switchThumb.Position = UDim2.new(0, 2.5, 0.5, 0) -- Initial Off Position
            switchThumb.AnchorPoint = Vector2.new(0, 0.5)

            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(1, 0) -- Perfect circle
            thumbCorner.Parent = switchThumb

            local toggled = false
            local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local POS_ON = UDim2.new(1, -2.5, 0.5, 0)
            local POS_OFF = UDim2.new(0, 2.5, 0.5, 0)

            local function updateSwitch(state)
                toggled = state
                pcall(callback, toggled)

                local targetColor = toggled and Palette.ACCENT or Palette.STROKE_COLOR
                local targetPos = toggled and POS_ON or POS_OFF

                TweenService:Create(switchTrack, TWEEN_INFO, {
                    BackgroundColor3 = targetColor
                }):Play()

                TweenService:Create(switchThumb, TWEEN_INFO, {
                    Position = targetPos
                }):Play()
            end
            
            switchTrack.MouseButton1Click:Connect(function()
                updateSwitch(not toggled)
            end)
            
            updateSwitch(false) -- Initialize state
        end

        -- 5. Slider
        function ElementHandler:Slider(sliderin, minvalue, maxvalue, callback)
            minvalue = minvalue or 0
            maxvalue = maxvalue or 100
            local currentValue = minvalue
            callback = callback or function() end
            
            local container = createContainer(newPage)

            -- Info Label
            local label = Instance.new("TextLabel")
            label.Parent = container
            label.BackgroundTransparency = 1.000
            label.Position = UDim2.new(0.03, 0, 0, 0)
            label.Size = UDim2.new(0.5, 0, 0.5, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = sliderin or "Slider"
            label.TextColor3 = Palette.TEXT_MAIN
            label.TextSize = 14.000
            label.TextXAlignment = Enum.TextXAlignment.Left

            -- Value Label
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Parent = container
            valueLabel.BackgroundTransparency = 1.000
            valueLabel.Position = UDim2.new(1, -10, 0, 0)
            valueLabel.AnchorPoint = Vector2.new(1, 0)
            valueLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
            valueLabel.Font = Enum.Font.GothamSemibold
            valueLabel.Text = string.format("%.0f/%s", currentValue, maxvalue)
            valueLabel.TextColor3 = Palette.ACCENT
            valueLabel.TextSize = 14.000
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right

            -- Slider Track
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Name = "SliderTrack"
            sliderTrack.Parent = container
            sliderTrack.BackgroundColor3 = Palette.STROKE_COLOR
            sliderTrack.Position = UDim2.new(0.03, 0, 0.7, 0)
            sliderTrack.Size = UDim2.new(0.94, 0, 0, 5) -- Thin track
            sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = sliderTrack

            -- Fill Frame
            local fillFrame = Instance.new("Frame")
            fillFrame.Name = "Fill"
            fillFrame.Parent = sliderTrack
            fillFrame.BackgroundColor3 = Palette.ACCENT
            fillFrame.Size = UDim2.new(0, 0, 1, 0)
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fillFrame

            -- Thumb (Draggable handle)
            local thumb = Instance.new("Frame")
            thumb.Name = "Thumb"
            thumb.Parent = sliderTrack
            thumb.BackgroundColor3 = Palette.ACCENT
            thumb.Size = UDim2.new(0, 10, 0, 10)
            thumb.Position = UDim2.new(0, 0, 0.5, 0)
            thumb.AnchorPoint = Vector2.new(0.5, 0.5)

            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(1, 0)
            thumbCorner.Parent = thumb
            
            local isDragging = false
            
            local function updateSlider(xPos)
                local trackWidth = sliderTrack.AbsoluteSize.X
                local newX = math.clamp(xPos - sliderTrack.AbsolutePosition.X, 0, trackWidth)
                
                local ratio = newX / trackWidth
                
                -- Update current value
                currentValue = math.floor(minvalue + ratio * (maxvalue - minvalue))
                currentValue = math.clamp(currentValue, minvalue, maxvalue)
                
                -- Update UI
                fillFrame.Size = UDim2.new(ratio, 0, 1, 0)
                thumb.Position = UDim2.new(ratio, 0, 0.5, 0)
                valueLabel.Text = string.format("%.0f/%s", currentValue, maxvalue)
                
                pcall(callback, currentValue)
            end

            sliderTrack.MouseButton1Down:Connect(function()
                isDragging = true
                updateSlider(UserInputService:GetMouseLocation().X)
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)
            
            -- Initial setup based on minvalue
            task.spawn(function()
                updateSlider(sliderTrack.AbsolutePosition.X)
            end)
        end
        
        -- 6. KeyBind
        function ElementHandler:KeyBind(keInfo, defaultKey, callback)
            local currentKey = defaultKey and defaultKey.Name or "None"
            local isBinding = false
            callback = callback or function() end
            
            local container = createContainer(newPage)

            -- Info Label
            local label = Instance.new("TextLabel")
            label.Parent = container
            label.BackgroundTransparency = 1.000
            label.Position = UDim2.new(0.03, 0, 0, 0)
            label.Size = UDim2.new(0.8, 0, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = keInfo or "Keybind"
            label.TextColor3 = Palette.TEXT_MAIN
            label.TextSize = 14.000
            label.TextXAlignment = Enum.TextXAlignment.Left

            -- Key Button
            local KeyButton = Instance.new("TextButton")
            KeyButton.Parent = container
            KeyButton.BackgroundColor3 = Palette.STROKE_COLOR
            KeyButton.Size = UDim2.new(0, 70, 0, 25)
            KeyButton.Position = UDim2.new(1, -10, 0.5, 0)
            KeyButton.AnchorPoint = Vector2.new(1, 0.5)
            KeyButton.Font = Enum.Font.GothamSemibold
            KeyButton.Text = currentKey
            KeyButton.TextColor3 = Palette.TEXT_MAIN
            KeyButton.TextSize = 14.000
            KeyButton.AutoButtonColor = false
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = KeyButton

            local conn = nil

            KeyButton.MouseButton1Click:Connect(function()
                if isBinding then return end
                isBinding = true
                KeyButton.Text = "..."
                KeyButton.BackgroundColor3 = Palette.ACCENT
                
                if conn then conn:Disconnect() end
                
                conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.KeyCode.Name ~= "Unknown" and input.KeyCode ~= Enum.KeyCode.Mouse1 then
                        currentKey = input.KeyCode.Name
                        KeyButton.Text = currentKey
                        KeyButton.BackgroundColor3 = Palette.STROKE_COLOR
                        isBinding = false
                        conn:Disconnect()
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed) 
                if not gameProcessed then 
                    if input.KeyCode.Name == currentKey and not isBinding then 
                        pcall(callback)
                    end
                end
            end)
        end
        
        -- 7. TextBox
        function ElementHandler:TextBox(textInfo, placeHolderText1, callback)
            callback = callback or function() end
            
            local container = createContainer(newPage)

            -- Info Label
            local label = Instance.new("TextLabel")
            label.Parent = container
            label.BackgroundTransparency = 1.000
            label.Position = UDim2.new(0.03, 0, 0, 0)
            label.Size = UDim2.new(0.8, 0, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = textInfo or "Input Text"
            label.TextColor3 = Palette.TEXT_MAIN
            label.TextSize = 14.000
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Text Box Container
            local textboxContainer = Instance.new("Frame")
            textboxContainer.Parent = container
            textboxContainer.BackgroundColor3 = Palette.STROKE_COLOR
            textboxContainer.Size = UDim2.new(0, 150, 0, 25)
            textboxContainer.Position = UDim2.new(1, -10, 0.5, 0)
            textboxContainer.AnchorPoint = Vector2.new(1, 0.5)
            
            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 4)
            textboxCorner.Parent = textboxContainer
            
            -- Text Box Input
            local TextBox = Instance.new("TextBox")
            TextBox.Parent = textboxContainer
            TextBox.BackgroundTransparency = 1.000
            TextBox.Size = UDim2.new(1, -5, 1, -5) 
            TextBox.Position = UDim2.new(0, 2, 0, 0) 
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderColor3 = Palette.TEXT_SECONDARY
            TextBox.PlaceholderText = placeHolderText1 or "Type and press Enter"
            TextBox.Text = ""
            TextBox.TextColor3 = Palette.TEXT_MAIN
            TextBox.TextSize = 13.000
            TextBox.TextWrapped = true
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

            TextBox.FocusLost:Connect(function(EnterPressed)
                if not EnterPressed then return end
                pcall(callback, TextBox.Text)
                TextBox.Text = ""
            end)
        end 
        
        -- 8. Dropdown
        function ElementHandler:Dropdown(dInfo, list, callback)
            list = list or {}
            callback = callback or function() end
            local selectedText = dInfo or "Select Option"
            
            local isDropped = false
            local DropdownItemHeight = 30
            local DropYSize = Palette.ELEMENT_HEIGHT + (#list * DropdownItemHeight) + 5
            
            local dropDownFrame = Instance.new("Frame")
            dropDownFrame.Name = "dropDownFrame"
            dropDownFrame.Parent = newPage
            dropDownFrame.BackgroundColor3 = Palette.BG_CARD
            dropDownFrame.ClipsDescendants = true
            dropDownFrame.Size = UDim2.new(1, 0, 0, Palette.ELEMENT_HEIGHT) -- Initial size
            
            local mainCorner = Instance.new("UICorner")
            mainCorner.CornerRadius = UDim.new(0, 6)
            mainCorner.Parent = dropDownFrame

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.Parent = dropDownFrame
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 0) 

            -- Main Button/Display (Always visible)
            local dropdownMain = Instance.new("TextButton")
            dropdownMain.Name = "DropdownMain"
            dropdownMain.Parent = dropDownFrame
            dropdownMain.BackgroundColor3 = Palette.BG_CARD
            dropdownMain.Size = UDim2.new(1, 0, 0, Palette.ELEMENT_HEIGHT)
            dropdownMain.Font = Enum.Font.GothamSemibold
            dropdownMain.TextColor3 = Palette.TEXT_MAIN
            dropdownMain.TextSize = 14
            dropdownMain.TextXAlignment = Enum.TextXAlignment.Left
            dropdownMain.Text = "  "..selectedText
            
            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 6)
            dropCorner.Parent = dropdownMain

            -- Arrow Icon
            local ImageButton = Instance.new("ImageButton")
            ImageButton.Parent = dropdownMain
            ImageButton.BackgroundTransparency = 1.000
            ImageButton.Position = UDim2.new(1, -15, 0.5, 0)
            ImageButton.AnchorPoint = Vector2.new(1, 0.5)
            ImageButton.Size = UDim2.new(0, 15, 0, 15)
            ImageButton.Image = "rbxassetid://5165666242" -- Arrow pointing up
            ImageButton.ImageColor3 = Palette.ACCENT

            local DropdownTweenDuration = 0.2
            
            -- Options Frame (The list of items)
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "OptionsFrame"
            OptionsFrame.Parent = dropDownFrame
            OptionsFrame.BackgroundColor3 = Palette.BG_CARD
            OptionsFrame.Size = UDim2.new(1, 0, 0, DropYSize - Palette.ELEMENT_HEIGHT)
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Parent = OptionsFrame
            OptionsList.FillDirection = Enum.FillDirection.Vertical
            OptionsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
            
            -- Options
            for i, v in next, list do
                local optionBtn = Instance.new("TextButton")
                optionBtn.Name = "OptionBtn"..i
                optionBtn.Parent = OptionsFrame
                optionBtn.BackgroundColor3 = Palette.BG_CARD
                optionBtn.Size = UDim2.new(1, 0, 0, DropdownItemHeight)
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.Text = "  "..v
                optionBtn.TextColor3 = Palette.TEXT_SECONDARY
                optionBtn.TextSize = 14.000
                optionBtn.TextXAlignment = Enum.TextXAlignment.Left
                optionBtn.AutoButtonColor = false
                
                optionBtn.MouseEnter:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Palette.STROKE_COLOR}):Play()
                end)
                optionBtn.MouseLeave:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Palette.BG_CARD}):Play()
                end)

                optionBtn.MouseButton1Click:Connect(function()
                    pcall(callback, v)
                    dropdownMain.Text = "  "..dInfo..": "..v
                    isDropped = true 
                    dropdownMain:Click() 
                end)
            end

            dropdownMain.MouseButton1Click:Connect(function()
                if isDropped then
                    isDropped = false
                    dropDownFrame:TweenSize(UDim2.new(1, 0, 0, Palette.ELEMENT_HEIGHT), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, DropdownTweenDuration) 
                    TweenService:Create(ImageButton, TweenInfo.new(DropdownTweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{ 
                        Rotation = 0
                    }):Play()
                else
                    isDropped = true
                    dropDownFrame:TweenSize(UDim2.new(1, 0, 0, DropYSize), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, DropdownTweenDuration) 
                    TweenService:Create(ImageButton, TweenInfo.new(DropdownTweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),{ 
                        Rotation = 180
                    }):Play()
                end
            end)
        end
        
        -- 9. ColorPicker (Swatch)
        function ElementHandler:ColorPicker(colorInfo, defaultColor, callback)
            colorInfo = colorInfo or "Color Picker"
            defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
            callback = callback or function() end

            local container = createContainer(newPage)

            -- Info Label
            local colorInfoLabel = Instance.new("TextLabel")
            colorInfoLabel.Parent = container
            colorInfoLabel.BackgroundTransparency = 1.000
            colorInfoLabel.Position = UDim2.new(0.03, 0, 0, 0)
            colorInfoLabel.Size = UDim2.new(0.8, 0, 1, 0)
            colorInfoLabel.Font = Enum.Font.GothamSemibold
            colorInfoLabel.Text = colorInfo
            colorInfoLabel.TextColor3 = Palette.TEXT_MAIN
            colorInfoLabel.TextSize = 14.000
            colorInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

            -- Color Swatch Button (Display)
            local colorSwatchButton = Instance.new("TextButton")
            colorSwatchButton.Name = "ColorSwatch"
            colorSwatchButton.Parent = container
            colorSwatchButton.BackgroundColor3 = defaultColor
            colorSwatchButton.Position = UDim2.new(1, -10, 0.5, 0)
            colorSwatchButton.AnchorPoint = Vector2.new(1, 0.5)
            colorSwatchButton.Size = UDim2.new(0, 30, 0, 30)
            colorSwatchButton.Text = ""
            colorSwatchButton.AutoButtonColor = false

            local swatchCorner = Instance.new("UICorner")
            swatchCorner.CornerRadius = UDim.new(0, 6)
            swatchCorner.Parent = colorSwatchButton

            local currentColor = defaultColor

            colorSwatchButton.MouseButton1Click:Connect(function()
                -- SIMULATION: Random color selection for demonstration (as a real ColorPicker is complex)
                local simulatedNewColor = Color3.fromHSV(math.random(), 1, 1) 
                currentColor = simulatedNewColor
                colorSwatchButton.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
                SlayLibExtra:Alert("Info", "Color Changed", "Color has been updated.", 2)
            end)

            pcall(callback, defaultColor)

            -- Return a setter function
            return function(newColor)
                currentColor = newColor
                colorSwatchButton.BackgroundColor3 = newColor
                pcall(callback, newColor)
            end
        end

        return ElementHandler
    end
    
    return SectionHandler
end 

return SlayLibExtra
