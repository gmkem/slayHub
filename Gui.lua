local SlayLib = {}

function SlayLib:CreateSlayLib(libName)
    libName = libName or "SlayLib"
    local isClosed = false

    local ScreenGui = Instance.new("ScreenGui")
    
    -- UI Instances (briefly defined for completeness)
    local MainWhiteFrame = Instance.new("Frame")
    local mainCorner = Instance.new("UICorner")
    local MainWhiteFrame_2 = Instance.new("Frame")
    local mainCorner_2 = Instance.new("UICorner")
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
    local Debris = game:GetService("Debris") -- ADDED: Debris service for notification management

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

    -- General Properties and Theme Changes (Unchanged)
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainWhiteFrame.Name = "MainWhiteFrame"
    MainWhiteFrame.Parent = ScreenGui
    MainWhiteFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Darker base
    MainWhiteFrame.BackgroundTransparency = 0.2 -- **Slight Transparency Change**
    MainWhiteFrame.BorderSizePixel = 0
    MainWhiteFrame.ClipsDescendants = true
    MainWhiteFrame.Position = UDim2.new(0.236969739, 0, 0.360436916, 0)
    MainWhiteFrame.Size = UDim2.new(0, 528, 0, 310)

    mainCorner.CornerRadius = UDim.new(0, 3)
    mainCorner.Name = "mainCorner"
    mainCorner.Parent = MainWhiteFrame

    MainWhiteFrame_2.Name = "MainWhiteFrame"
    MainWhiteFrame_2.Parent = MainWhiteFrame
    MainWhiteFrame_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Main content background
    MainWhiteFrame_2.BackgroundTransparency = 0.1 -- **Slight Transparency Change**
    MainWhiteFrame_2.BorderSizePixel = 0
    MainWhiteFrame_2.ClipsDescendants = true
    MainWhiteFrame_2.Position = UDim2.new(0.0113636367, 0, 0, 0)
    MainWhiteFrame_2.Size = UDim2.new(0, 525, 0, 310)

    mainCorner_2.CornerRadius = UDim.new(0, 3)
    mainCorner_2.Name = "mainCorner"
    mainCorner_2.Parent = MainWhiteFrame_2

    tabFrame.Name = "tabFrame"
    tabFrame.Parent = MainWhiteFrame_2
    tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Tab frame background
    tabFrame.BorderColor3 = Color3.fromRGB(50, 50, 50) -- Darker border
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
        isClosed = not isClosed
        if isClosed then
            closeLib.Image = "rbxassetid://5165666242"
            TweenService:Create(closeLib, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                Rotation = 360
            }):Play()
            MainWhiteFrame:TweenSize(UDim2.new(0, 424,0, 58), "In", "Linear", 0.12)
            TweenService:Create(MainWhiteFrame_2, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                BackgroundTransparency = 1
            }):Play()
        else
            closeLib.Image = "rbxassetid://4988112250"
            TweenService:Create(closeLib, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                Rotation = 0
            }):Play()
            MainWhiteFrame:TweenSize(UDim2.new(0, 528,0, 310), "In", "Linear", 0.12)
            TweenService:Create(MainWhiteFrame_2, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                BackgroundTransparency = 0.1 -- Use the new transparency value
            }):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                BackgroundTransparency = 0.2 -- Use the new transparency value
            }):Play()
        end
    end)

    elementContainer.Name = "elementContainer"
    elementContainer.Parent = MainWhiteFrame_2
    elementContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28) -- Element container background
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


    -- *** Notification System Configuration V4 (Integrated) ***
    local NotificationQueue = {}
    local ActiveNotifications = {} -- Store references to currently visible notification frames
    local NotificationSpacing = 10 -- Space between stacked notifications (in pixels)
    local NotificationFadeTime = 0.5 -- Tween time for appearing/disappearing/moving
    local NotificationVisibleTime = 4 -- Default duration before auto-dismiss (seconds)
    local NotificationWidth = 350 
    local NotificationHeight = 80
    local NotificationMaxCount = 5 -- Maximum simultaneous notifications
    local NotificationZIndex = 10 -- ZIndex for notifications (high value)

    -- Icon/Color mapping for different statuses
    local StatusMapping = {
        Info = {
            Color = Color3.fromRGB(0, 150, 255), -- Blue
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

    local function UpdateNotificationPositions()
        local currentYOffset = 20 -- Start offset from the bottom (pixels)
        
        -- Loop through active notifications from oldest to newest (bottom to top)
        for i = #ActiveNotifications, 1, -1 do
            local NotifFrame = ActiveNotifications[i]
            local targetY = -NotifFrame.Size.Y.Offset - currentYOffset
            local targetPosition = UDim2.new(1, -NotificationWidth - 20, 1, targetY)

            -- Tween the position smoothly
            TweenService:Create(NotifFrame, TweenInfo.new(NotificationFadeTime * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = targetPosition
            }):Play()

            -- Calculate offset for the next notification
            currentYOffset = currentYOffset + NotifFrame.Size.Y.Offset + NotificationSpacing
        end
    end

    local function DismissNotification(NotifFrame, autoDismiss)
        -- Find the index of the frame to remove
        local index = table.find(ActiveNotifications, NotifFrame)
        if not index then return end

        -- 1. Tween Out (Fade out and slide slightly right)
        local fadeTime = autoDismiss and NotificationFadeTime or NotificationFadeTime * 0.5
        local outTween = TweenService:Create(NotifFrame, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1.1, 0, NotifFrame.Position.Y.Offset, NotifFrame.Position.Y.Offset),
            BackgroundTransparency = 1,
        })
        
        outTween:Play()
        outTween.Completed:Wait() -- Wait for the tween to finish

        -- 2. Remove from active list and destroy
        table.remove(ActiveNotifications, index)
        NotifFrame:Destroy()

        -- 3. Update the positions of all remaining notifications
        UpdateNotificationPositions()
        
        -- 4. Process the next item in the queue (if any)
        task.spawn(function()
            local firstInQueue = NotificationQueue[1]
            if firstInQueue then
                table.remove(NotificationQueue, 1)
                task.spawn(function()
                    ShowNotification(firstInQueue)
                end)
            end
        end)
    end
    
    local function ShowNotification(notifData)
        local statusData = StatusMapping[notifData.status]
        local duration = math.clamp(notifData.duration, 1, 10)
        
        -- Check if there are too many active notifications 
        if #ActiveNotifications >= NotificationMaxCount then
            -- If max reached, add to the end of the queue
            table.insert(NotificationQueue, notifData)
            return
        end

        -- 1. Create UI Instances
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "SlayNotif_"..notifData.status
        NotifFrame.Parent = ScreenGui 
        NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Dark Background
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Size = UDim2.new(0, NotificationWidth, 0, NotificationHeight)
        NotifFrame.ZIndex = NotificationZIndex 
        
        -- Corner
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 5)
        notifCorner.Parent = NotifFrame

        -- Accent Line
        local notifAccentLine = Instance.new("Frame")
        notifAccentLine.Name = "AccentLine"
        notifAccentLine.Parent = NotifFrame
        notifAccentLine.BackgroundColor3 = statusData.Color 
        notifAccentLine.Size = UDim2.new(0, 5, 1, 0)
        notifAccentLine.Position = UDim2.new(0, 0, 0, 0)
        
        -- Icon
        local notifIcon = Instance.new("ImageLabel")
        notifIcon.Name = "StatusIcon"
        notifIcon.Parent = NotifFrame
        notifIcon.BackgroundTransparency = 1
        notifIcon.Image = statusData.Icon
        notifIcon.ImageColor3 = statusData.Color
        notifIcon.Position = UDim2.new(0, 15, 0.5, 0)
        notifIcon.AnchorPoint = Vector2.new(0, 0.5)
        notifIcon.Size = UDim2.new(0, 30, 0, 30)

        -- Title
        local notifTitle = Instance.new("TextLabel")
        notifTitle.Name = "Title"
        notifTitle.Parent = NotifFrame
        notifTitle.BackgroundTransparency = 1.000
        notifTitle.Position = UDim2.new(0, 50, 0, 0)
        notifTitle.Size = UDim2.new(0, NotificationWidth - 100, 0, 30)
        notifTitle.Font = Enum.Font.GothamSemibold
        notifTitle.Text = notifData.title
        notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifTitle.TextSize = 15.000
        notifTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Message
        local notifMessage = Instance.new("TextLabel")
        notifMessage.Name = "Message"
        notifMessage.Parent = NotifFrame
        notifMessage.BackgroundTransparency = 1.000
        notifMessage.Position = UDim2.new(0, 50, 0, 25)
        notifMessage.Size = UDim2.new(0, NotificationWidth - 100, 0, 45)
        notifMessage.Font = Enum.Font.Gotham
        notifMessage.Text = notifData.message
        notifMessage.TextColor3 = Color3.fromRGB(170, 170, 170) 
        notifMessage.TextSize = 13.000
        notifMessage.TextXAlignment = Enum.TextXAlignment.Left
        notifMessage.TextWrapped = true
        
        -- Dismiss Button (X)
        local DismissButton = Instance.new("TextButton")
        DismissButton.Name = "Dismiss"
        DismissButton.Parent = NotifFrame
        DismissButton.BackgroundTransparency = 1
        DismissButton.Position = UDim2.new(1, -25, 0, 0)
        DismissButton.Size = UDim2.new(0, 25, 0, 25)
        DismissButton.Text = "✕"
        DismissButton.TextColor3 = Color3.fromRGB(100, 100, 100)
        DismissButton.TextSize = 18
        DismissButton.Font = Enum.Font.GothamSemibold

        DismissButton.MouseButton1Click:Connect(function()
            DismissNotification(NotifFrame, false) -- Manual dismiss
        end)
        
        -- 2. Initial Setup (Start off-screen right)
        NotifFrame.Position = UDim2.new(1.1, 0, 1, -NotificationHeight - 20) 
        
        -- 3. Add to active list
        table.insert(ActiveNotifications, 1, NotifFrame) -- Insert at the beginning (top of the stack)

        -- 4. Update all positions (this will move all existing notifs up and this one to the bottom)
        UpdateNotificationPositions()

        -- 5. Auto-Dismiss timer
        task.delay(duration, function()
            -- Check if it's still in the active list before dismissing
            if table.find(ActiveNotifications, NotifFrame) then
                DismissNotification(NotifFrame, true) -- Auto dismiss
            end
        end)
    end
    
    -- Public Alert function V4
    function SlayLib:Alert(status, title, message, duration)
        local validStatus = StatusMapping[status] and status or "Info"

        local newNotif = {
            status = validStatus,
            title = title or validStatus.." Message",
            message = message or "A message from SlayLib.",
            duration = duration or NotificationVisibleTime
        }
        
        ShowNotification(newNotif)
    end

    -- Legacy Notify function directs to Info Alert
    function SlayLib:Notify(title, message, duration)
        self:Alert("Info", title, message, duration)
    end
    -- *** End of Notification System V4 ***


    local SectionHandler = {}

    function SectionHandler:CreateSection(secName)
        secName = secName or "Tab"
        
        -- Tab Button Instances
        local tabBtn = Instance.new("TextButton")
        local mainCorner_3 = Instance.new("UICorner")

        tabBtn.Name = "tabBtn"..secName
        tabBtn.Parent = tabFrame
        tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Tab button background (unselected)
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

        -- New Section Frame Instances
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
        newPage.ScrollBarImageColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson**
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

            for i,v in next, tabFrame:GetChildren() do
                if v:IsA("TextButton") then
                    UpdateSize()
                    TweenService:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Tab unselected color
                    }):Play()
                end
            end
            TweenService:Create(tabBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{
                BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Selected Tab)**
            }):Play()
            
            -- **ADDED NOTIFICATION**
            SlayLib:Alert("Info", "Tab Selected", "Switched to tab: "..secName, 2.5) 
        end)

        local ElementHandler = {}

        function ElementHandler:TextLabel(labelText)
            labelText = labelText or ""

            local labelFrame = Instance.new("Frame")
            local mainCorner = Instance.new("UICorner")
            local txtLabel = Instance.new("TextLabel")

            labelFrame.Name = "labelFrame"
            labelFrame.Parent = newPage
            labelFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Element Background
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
            textButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Element Background
            textButtonFrame.Position = UDim2.new(0.0147058824, 0, 0.0246913582, 0)
            textButtonFrame.Size = UDim2.new(0, 394, 0, 42)

            mainCorner.CornerRadius = UDim.new(0, 3)
            mainCorner.Name = "mainCorner"
            mainCorner.Parent = textButtonFrame

            TextButton.Parent = textButtonFrame
            TextButton.BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Button)**
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
            textButtonInfo.TextColor3 = Color3.fromRGB(170, 170, 170) -- Slightly lighter gray text
            textButtonInfo.TextSize = 14.000
            textButtonInfo.TextXAlignment = Enum.TextXAlignment.Right

            TextButton.MouseButton1Click:Connect(function()
                pcall(callback) -- ADDED pcall for stability
                -- **ADDED NOTIFICATION**
                SlayLib:Alert("Success", "Button Clicked", buttonText.." triggered action.", 2) 
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
                toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Element Background
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
                toggleInfo.TextColor3 = Color3.fromRGB(170, 170, 170) -- Slightly lighter gray text
                toggleInfo.TextSize = 14.000
                toggleInfo.TextXAlignment = Enum.TextXAlignment.Right

                toggleInerFrame.Name = "toggleInerFrame"
                toggleInerFrame.Parent = toggleFrame
                toggleInerFrame.BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Track)**
                toggleInerFrame.Position = UDim2.new(0.0177664906, 0, 0.166666672, 0)
                toggleInerFrame.Size = UDim2.new(0, 27, 0, 27)

                mainCorner_2.CornerRadius = UDim.new(0, 3)
                mainCorner_2.Name = "mainCorner"
                mainCorner_2.Parent = toggleInerFrame

                toggleInnerFrame1.Name = "toggleInnerFrame1"
                toggleInnerFrame1.Parent = toggleInerFrame
                toggleInnerFrame1.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Inner track part
                
                -- FIXED POSITION: Centered the inner track for better visual in the outer track
                toggleInnerFrame1.Position = UDim2.new(0.411347508, 0, 0.0370370373, 0) 
                toggleInnerFrame1.Size = UDim2.new(0, 25, 0, 25)

                mainCorner_3.CornerRadius = UDim.new(0, 3)
                mainCorner_3.Name = "mainCorner"
                mainCorner_3.Parent = toggleInnerFrame1

                toggleBtn.Name = "toggleBtn"
                toggleBtn.Parent = toggleInnerFrame1
                toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Toggle button (unselected)
                
                -- FIXED POSITION: Start position (left)
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
                toggleBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    pcall(callback, toggled) -- ADDED pcall for stability
                    local newPosition = toggled and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0) -- Target position
                    
                    if toggled then
                        TweenService:Create(toggleBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{
                            BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Toggle selected)**
                        }):Play()
                        -- **ADDED NOTIFICATION**
                        SlayLib:Alert("Success", "Toggle Activated", togInfo.." is now **ON**", 2) 
                    else
                        TweenService:Create(toggleBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{
                            BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Toggle unselected color
                        }):Play()
                        -- **ADDED NOTIFICATION**
                        SlayLib:Alert("Info", "Toggle Deactivated", togInfo.." is now **OFF**", 2) 
                    end 
                    
                    -- Tween position
                    TweenService:Create(toggleBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{
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
                    sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Element Background
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
                    sliderInfo.TextColor3 = Color3.fromRGB(170, 170, 170) -- Slightly lighter gray text
                    sliderInfo.TextSize = 14.000
                    sliderInfo.TextXAlignment = Enum.TextXAlignment.Right

                    sliderValue.Name = "sliderValue"
                    sliderValue.Parent = sliderFrame
                    sliderValue.BackgroundTransparency = 1.000
                    sliderValue.Position = UDim2.new(0.395939082, 0, 0.285714298, 0)
                    sliderValue.Size = UDim2.new(0, 68, 0, 17)
                    sliderValue.Font = Enum.Font.GothamSemibold
                    sliderValue.Text = minvalue.."/"..maxvalue
                    sliderValue.TextColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Value)**
                    sliderValue.TextSize = 14.000
                    sliderValue.TextXAlignment = Enum.TextXAlignment.Left

                    sliderBtn.Name = "sliderBtn"
                    sliderBtn.Parent = sliderFrame
                    sliderBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33) -- Slider track color
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
                    sliderMainFrm.BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Fill)**
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
                                    -- **ADDED NOTIFICATION**
                                    SlayLib:Alert("Info", "Slider Changed", sliderin.." set to: "..Value, 2) 
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
                            keybindFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Element Background
                            keybindFrame.Position = UDim2.new(0.0147058824, 0, 0.0246913582, 0)
                            keybindFrame.Size = UDim2.new(0, 394, 0, 42)

                            mainCorner.CornerRadius = UDim.new(0, 3)
                            mainCorner.Name = "mainCorner"
                            mainCorner.Parent = keybindFrame

                            TextButton.Parent = keybindFrame
                            TextButton.BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Button)**
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
                            keybindinfo.TextColor3 = Color3.fromRGB(170, 170, 170) -- Slightly lighter gray text
                            keybindinfo.TextSize = 14.000
                            keybindinfo.TextXAlignment = Enum.TextXAlignment.Right

                            TextButton.MouseButton1Click:connect(function(e) 
                                TextButton.Text = ". . ."
                                local a, b = game:GetService('UserInputService').InputBegan:wait();
                                if a.KeyCode.Name ~= "Unknown" then
                                    TextButton.Text = a.KeyCode.Name
                                    oldKey = a.KeyCode.Name;
                                    -- **ADDED NOTIFICATION**
                                    SlayLib:Alert("Info", "Keybind Set", keInfo.." set to: "..oldKey, 2) 
                                end
                            end)

                            game:GetService("UserInputService").InputBegan:connect(function(current, ok) 
                                if not ok then 
                                    if current.KeyCode.Name == oldKey then 
                                        pcall(callback) -- ADDED pcall for stability
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
                                textBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Element Background
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
                                textboxInfo.TextColor3 = Color3.fromRGB(170, 170, 170) -- Slightly lighter gray text
                                textboxInfo.TextSize = 14.000
                                textboxInfo.TextXAlignment = Enum.TextXAlignment.Right

                                texboxInner.Name = "texboxInner"
                                texboxInner.Parent = textBoxFrame
                                texboxInner.BackgroundColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Border)**
                                texboxInner.Position = UDim2.new(0.017766498, 0, 0.166666672, 0)
                                texboxInner.Size = UDim2.new(0, 141, 0, 27)

                                mainCorner_2.CornerRadius = UDim.new(0, 3)
                                mainCorner_2.Name = "mainCorner"
                                mainCorner_2.Parent = texboxInner

                                textboxinneer.Name = "textboxinneer"
                                textboxinneer.Parent = texboxInner
                                textboxinneer.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Textbox inner background
                                textboxinneer.ClipsDescendants = true
                                
                                -- FIXED POSITION: Adjusted position for inner frame
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
                                -- FIXED SIZE/POSITION: Reduced size slightly to fit in inner frame and added offset
                                TextBox.Size = UDim2.new(1, -5, 1, -5) 
                                TextBox.Position = UDim2.new(0, 2, 0, 0) 
                                TextBox.Font = Enum.Font.GothamSemibold
                                TextBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90) -- Darker placeholder text
                                TextBox.PlaceholderText = placeHolderText1
                                TextBox.Text = ""
                                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                                TextBox.TextSize = 13.000
                                TextBox.TextWrapped = true
                                TextBox.TextXAlignment = Enum.TextXAlignment.Left -- Left align text for better input readability

                                UIListLayout_2.Parent = texboxInner
                                UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
                                UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

                                TextBox.FocusLost:Connect(function(EnterPressed)
                                    if not EnterPressed then return end
                                    pcall(callback, TextBox.Text) -- ADDED pcall for stability
                                    -- **ADDED NOTIFICATION**
                                    SlayLib:Alert("Info", "Textbox Submitted", textInfo.." submitted: "..TextBox.Text, 2.5) 
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
                                    dropDownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Slightly darker overall background for dropdown
                                    dropDownFrame.ClipsDescendants = true
                                    dropDownFrame.Position = UDim2.new(0.011029412, 0, 0.0205760058, 0)
                                    dropDownFrame.Size = UDim2.new(0, 394, 0, 42)

                                    mainCorner.CornerRadius = UDim.new(0, 3)
                                    mainCorner.Name = "mainCorner"
                                    mainCorner.Parent = dropDownFrame

                                    dropdownmain.Name = "dropdownmain"
                                    dropdownmain.Parent = dropDownFrame
                                    dropdownmain.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Dropdown main element background
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
                                    dropdownItem.TextColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Dropdown Info)**
                                    dropdownItem.TextSize = 14.000
                                    dropdownItem.TextXAlignment = Enum.TextXAlignment.Left

                                    ImageButton.Parent = dropdownmain
                                    ImageButton.BackgroundTransparency = 1.000
                                    ImageButton.Position = UDim2.new(0.89974618, 0, 0.238095239, 0)
                                    ImageButton.Size = UDim2.new(0, 27, 0, 21)
                                    ImageButton.Image = "rbxassetid://5165666242"
                                    ImageButton.ImageColor3 = Color3.fromRGB(139, 0, 23) -- **Accent Color: Crimson (Arrow)**
                                    ImageButton.MouseButton1Click:Connect(function()
                                        if isDropped then
                                            isDropped = false
                                            dropDownFrame:TweenSize(UDim2.new(0, 394, 0, 42), "In", "Quint", 0.10)
                                            TweenService:Create(ImageButton, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                                                Rotation = 0
                                            }):Play()
                                            task.wait(0.10) -- CHANGED wait to task.wait
                                            UpdateSize()
                                        else
                                            isDropped = true
                                            dropDownFrame:TweenSize(UDim2.new(0, 394, 0, DropYSize), "In", "Quint", 0.10)
                                            TweenService:Create(ImageButton, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                                                Rotation = 180
                                            }):Play()
                                            task.wait(0.10) -- CHANGED wait to task.wait
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
                                        optionBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 10) -- Option button color
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
                                            pcall(callback, v) -- ADDED pcall for stability
                                            dropdownItem.Text = dInfo..": "..v
                                            dropDownFrame:TweenSize(UDim2.new(0, 394, 0, 42), "In", "Quint", 0.10)
                                            task.wait(0.10) -- CHANGED wait to task.wait
                                            UpdateSize()
                                            TweenService:Create(ImageButton, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                                                Rotation = 0
                                            }):Play()
                                            isDropped = false
                                            -- **ADDED NOTIFICATION**
                                            SlayLib:Alert("Info", "Dropdown Selected", dInfo.." selected: "..v, 2.5) 
                                        end)
                                    end
        end

        -- === NEW ELEMENT 1: Separator (Unchanged, no notification needed) ===
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

        -- === NEW ELEMENT 2: ColorPicker (Simplified Swatch) ===
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
                local simulatedNewColor = Color3.fromHSV(math.random(), 1, 1) -- เปลี่ยนเป็นสีสุ่มเพื่อแสดงการทำงาน
                currentColor = simulatedNewColor
                colorSwatchButton.BackgroundColor3 = currentColor
                pcall(callback, currentColor) -- ADDED pcall for stability
                -- **ADDED NOTIFICATION**
                SlayLib:Alert("Info", "Color Changed", colorInfo.." color updated.", 2) 
            end)

            -- เรียกใช้ callback ทันทีด้วยสีเริ่มต้น
            pcall(callback, defaultColor)

            -- คืนค่าฟังก์ชันเพื่อให้อนุญาตให้สคริปต์ภายนอกตั้งค่าสีได้
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
