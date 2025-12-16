--[[
    SlayLibX - The Hardcore and Unbreakable GUI Library
    Blueprint: SlayLib.lua
    Theme: Dark / Crimson Accent
    Improvements:
    1. Robust Notification System (Fixes ImageTransparency error on Frames).
    2. Added GroupBox/Sub-Section element.
    3. Formalized object structure for easier extension and control.
]]

local SlayLibX = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local task = task

-- Core Configuration
local ACCENT_COLOR = Color3.fromRGB(139, 0, 23) -- Crimson Red
local BASE_COLOR = Color3.fromRGB(20, 20, 20)
local ELEMENT_COLOR = Color3.fromRGB(25, 25, 25)

-- =========================================================================================
-- !!! 1. NOTIFICATION SYSTEM V8 (ROBUST AND UNBREAKABLE FADE) !!!
-- =========================================================================================

local NotificationQueue = {}
local ActiveNotifications = {}
local NotificationSpacing = 10
local NotificationFadeTime = 0.3
local NotificationVisibleTime = 3.5
local NotificationWidth = 350
local NotificationHeight = 65
local NotificationZIndex = 10
local NotifInnerColor = Color3.fromRGB(25, 25, 25)

local StatusMapping = {
    Info = {Color = Color3.fromRGB(0, 150, 255), Icon = "rbxassetid://10632598818"}, 
    Success = {Color = Color3.fromRGB(0, 170, 0), Icon = "rbxassetid://10632598687"}, 
    Warning = {Color = Color3.fromRGB(255, 170, 0), Icon = "rbxassetid://10632599540"}, 
    Error = {Color = Color3.fromRGB(200, 50, 50), Icon = "rbxassetid://10632599187"}
}

local function UpdateNotificationPositions()
    local currentYOffset = 20
    for i = 1, #ActiveNotifications do
        local NotifFrame = ActiveNotifications[i]
        local targetY = -NotifFrame.Size.Y.Offset - currentYOffset
        local targetPosition = UDim2.new(1, -NotificationWidth - 20, 1, targetY)

        TweenService:Create(NotifFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPosition
        }):Play()

        currentYOffset = currentYOffset + NotifFrame.Size.Y.Offset + NotificationSpacing
    end
end

local function ProcessQueue()
    if #NotificationQueue > 0 and #ActiveNotifications < 10 then -- Limit active notifs to 10
        local nextNotifData = table.remove(NotificationQueue, 1)
        task.spawn(function()
            SlayLibX.ShowNotification(nextNotifData)
        end)
    end
end

local function DismissNotification(NotifFrame)
    local index = table.find(ActiveNotifications, NotifFrame)
    if not index then 
        if NotifFrame and NotifFrame.Parent then NotifFrame:Destroy() end
        return 
    end
    
    local fadeTime = NotificationFadeTime
    local tweens = {}
    
    -- *** ROBUST FADE LOGIC FIX ***
    -- Ensures we only tween properties that exist on the specific UI class.
    local function applyFade(instance)
        local transparencyProps = {}
        local isTweenable = false

        if instance:IsA("GuiObject") and (not instance:IsA("ImageLabel") and not instance:IsA("ImageButton")) then
            transparencyProps.BackgroundTransparency = 1
            isTweenable = true
        end
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            transparencyProps.TextTransparency = 1
            isTweenable = true
        end
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            transparencyProps.ImageTransparency = 1
            isTweenable = true
        end
        if instance:IsA("UIStroke") then
            transparencyProps.Transparency = 1
            isTweenable = true
        end

        if isTweenable then
            local t = TweenService:Create(instance, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), transparencyProps)
            table.insert(tweens, t)
            t:Play()
        end

        for _, child in instance:GetChildren() do
            applyFade(child)
        end
    end
    
    applyFade(NotifFrame)
    -- Wait for all fade tweens to complete
    task.wait(fadeTime) 

    table.remove(ActiveNotifications, index)
    Debris:AddItem(NotifFrame, 0.1) 

    UpdateNotificationPositions()
    task.spawn(ProcessQueue)
end


function SlayLibX.ShowNotification(notifData)
    local statusData = StatusMapping[notifData.status]
    local duration = math.clamp(notifData.duration, 1, 10)

    -- 1. Create UI Instances (using similar aesthetics from blueprint)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "SlayNotif_"..notifData.status
    NotifFrame.Parent = game.CoreGui 
    NotifFrame.BackgroundColor3 = NotifInnerColor 
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Size = UDim2.new(0, NotificationWidth, 0, NotificationHeight)
    NotifFrame.ZIndex = NotificationZIndex 
    NotifFrame.BackgroundTransparency = 0 
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 5)
    notifCorner.Parent = NotifFrame
    
    local notifAccentLine = Instance.new("Frame")
    notifAccentLine.Name = "AccentLine"
    notifAccentLine.Parent = NotifFrame
    notifAccentLine.BackgroundColor3 = statusData.Color 
    notifAccentLine.Size = UDim2.new(0, 7, 1, 0)
    notifAccentLine.Position = UDim2.new(0, 0, 0, 0)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = NotifFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 15, 0, 0)
    ContentFrame.Size = UDim2.new(1, -30, 1, 0)

    local ContentList = Instance.new("UIListLayout")
    ContentList.Parent = ContentFrame
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 2)
    
    -- Icon & Title
    local TopRow = Instance.new("Frame")
    TopRow.Parent = ContentFrame
    TopRow.BackgroundTransparency = 1
    TopRow.Size = UDim2.new(1, 0, 0, 25)
    local notifIcon = Instance.new("ImageLabel")
    notifIcon.Parent = TopRow
    notifIcon.BackgroundTransparency = 1
    notifIcon.Image = statusData.Icon
    notifIcon.ImageColor3 = statusData.Color
    notifIcon.Position = UDim2.new(0, 0, 0.5, 0)
    notifIcon.AnchorPoint = Vector2.new(0, 0.5)
    notifIcon.Size = UDim2.new(0, 20, 0, 20)
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Parent = TopRow
    notifTitle.BackgroundTransparency = 1
    notifTitle.Position = UDim2.new(0, 25, 0, 0)
    notifTitle.Size = UDim2.new(1, -25, 1, 0)
    notifTitle.Font = Enum.Font.GothamSemibold
    notifTitle.Text = notifData.title
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextSize = 15
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Message
    local notifMessage = Instance.new("TextLabel")
    notifMessage.Parent = ContentFrame
    notifMessage.BackgroundTransparency = 1
    notifMessage.Size = UDim2.new(1, -25, 0, 20) 
    notifMessage.Font = Enum.Font.Gotham
    notifMessage.Text = notifData.message
    notifMessage.TextColor3 = Color3.fromRGB(170, 170, 170) 
    notifMessage.TextSize = 13
    notifMessage.TextXAlignment = Enum.TextXAlignment.Left
    notifMessage.TextWrapped = true

    -- Dismiss Button (X)
    local DismissButton = Instance.new("TextButton")
    DismissButton.Parent = NotifFrame
    DismissButton.BackgroundTransparency = 1
    DismissButton.Position = UDim2.new(1, -15, 0, 0)
    DismissButton.Size = UDim2.new(0, 15, 0, 15)
    DismissButton.Text = "✕"
    DismissButton.TextColor3 = Color3.fromRGB(100, 100, 100)
    DismissButton.TextSize = 18
    DismissButton.Font = Enum.Font.GothamSemibold
    DismissButton.MouseButton1Click:Connect(function()
        DismissNotification(NotifFrame)
    end)
    
    -- Setup & Animation
    NotifFrame.Position = UDim2.new(1.1, 0, 1, -NotificationHeight - 20) 
    table.insert(ActiveNotifications, 1, NotifFrame) 
    
    TweenService:Create(NotifFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -NotificationWidth - 20, 1, NotifFrame.Position.Y.Offset),
    }):Play()

    UpdateNotificationPositions()

    task.delay(duration, function()
        if table.find(ActiveNotifications, NotifFrame) then
            DismissNotification(NotifFrame)
        end
    end)
end

function SlayLibX:Alert(status, title, message, duration)
    local validStatus = StatusMapping[status] and status or "Info"
    local newNotif = {
        status = validStatus,
        title = title or validStatus.." Message",
        message = message or "A message from SlayLibX.",
        duration = duration or NotificationVisibleTime
    }

    if #ActiveNotifications >= 10 or #NotificationQueue >= 50 then 
        table.insert(NotificationQueue, newNotif)
    else
        SlayLibX.ShowNotification(newNotif)
    end
    
    task.spawn(ProcessQueue)
end

function SlayLibX:Notify(title, message, duration)
    self:Alert("Info", title, message, duration)
end

-- =========================================================================================
-- !!! 2. CORE GUI CREATION !!!
-- =========================================================================================

function SlayLibX:CreateSlayLib(libName)
    libName = libName or "SlayLibX | Hardcore"
    local isClosed = false
    
    -- Main Instances
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainWhiteFrame = Instance.new("Frame") -- Outer (for subtle shadow effect)
    MainWhiteFrame.Parent = ScreenGui
    MainWhiteFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainWhiteFrame.BackgroundTransparency = 0.2
    MainWhiteFrame.Size = UDim2.new(0, 528, 0, 310)
    MainWhiteFrame.Position = UDim2.new(0.25, 0, 0.3, 0)
    Instance.new("UICorner", MainWhiteFrame).CornerRadius = UDim.new(0, 3)

    local InnerFrame = Instance.new("Frame") -- Inner (main background)
    InnerFrame.Parent = MainWhiteFrame
    InnerFrame.BackgroundColor3 = BASE_COLOR
    InnerFrame.BackgroundTransparency = 0.1
    InnerFrame.Size = UDim2.new(0, 525, 0, 310)
    InnerFrame.Position = UDim2.new(0.0028, 0, 0, 0) -- Slight offset for outer frame visibility
    Instance.new("UICorner", InnerFrame).CornerRadius = UDim.new(0, 3)
    
    -- UI Stroke for Clean Border
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Parent = InnerFrame
    mainStroke.Color = ACCENT_COLOR
    mainStroke.Transparency = 0.8
    mainStroke.Thickness = 1
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Header (Draggable Area)
    local header = Instance.new("Frame")
    header.Parent = InnerFrame
    header.BackgroundColor3 = ACCENT_COLOR
    header.Position = UDim2.new(0.207619041, 0, 0.0258064512, 0)
    header.Size = UDim2.new(0, 408, 0, 43)
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 3)
    
    local libTitle = Instance.new("TextLabel")
    libTitle.Parent = header
    libTitle.BackgroundTransparency = 1
    libTitle.Position = UDim2.new(0.029, 0, 0, 0)
    libTitle.Size = UDim2.new(0, 343, 0, 43)
    libTitle.Font = Enum.Font.GothamSemibold
    libTitle.Text = libName
    libTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    libTitle.TextSize = 18
    libTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Tab System
    local tabFrame = Instance.new("Frame")
    tabFrame.Parent = InnerFrame
    tabFrame.BackgroundColor3 = ELEMENT_COLOR
    tabFrame.Size = UDim2.new(0, 100, 1, -1) -- Full height
    Instance.new("UIListLayout", tabFrame).Padding = UDim.new(0, 2)
    Instance.new("UIPadding", tabFrame).PaddingTop = UDim.new(0, 5)

    -- Element Container
    local elementContainer = Instance.new("Frame")
    elementContainer.Parent = InnerFrame
    elementContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    elementContainer.Position = UDim2.new(0.207619041, 0, 0.187096775, 0)
    elementContainer.Size = UDim2.new(0, 408, 0, 243)
    Instance.new("UICorner", elementContainer).CornerRadius = UDim.new(0, 3)
    
    local pagesFolder = Instance.new("Folder", elementContainer)
    pagesFolder.Name = "Pages"

    -- Close Button Logic
    local closeLib = Instance.new("ImageButton")
    closeLib.Parent = header
    closeLib.BackgroundTransparency = 1
    closeLib.Position = UDim2.new(0.919, 0, 0.2, 0)
    closeLib.Size = UDim2.new(0, 25, 0, 25)
    closeLib.Image = "rbxassetid://4988112250" -- Close (X) icon
    
    local TweenDuration = 0.2 
    closeLib.MouseButton1Click:Connect(function()
        if isClosed then
            isClosed = false
            closeLib.Image = "rbxassetid://4988112250"
            MainWhiteFrame:TweenSize(UDim2.new(0, 528, 0, 310), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, TweenDuration, true)
            TweenService:Create(InnerFrame, TweenInfo.new(TweenDuration),{BackgroundTransparency = 0.1}):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(TweenDuration),{BackgroundTransparency = 0.2}):Play()
        else
            isClosed = true
            closeLib.Image = "rbxassetid://5165666242" -- Open (Down Arrow/Chevron) icon
            MainWhiteFrame:TweenSize(UDim2.new(0, 424, 0, 58), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, TweenDuration, true)
            TweenService:Create(InnerFrame, TweenInfo.new(TweenDuration),{BackgroundTransparency = 1}):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(TweenDuration),{BackgroundTransparency = 1}):Play()
        end
    end)
    
    -- Dragging (using the blueprint's robust logic)
    local DragMousePosition
    local FramePosition
    local Draggable = false
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = true
            DragMousePosition = Vector2.new(input.Position.X, input.Position.Y)
            FramePosition = Vector2.new(MainWhiteFrame.Position.X.Scale, MainWhiteFrame.Position.Y.Scale)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Draggable == true then
            local NewPosition = FramePosition + ((Vector2.new(input.Position.X, input.Position.Y) - DragMousePosition) / game.Workspace.CurrentCamera.ViewportSize)
            MainWhiteFrame.Position = UDim2.new(NewPosition.X, 0, NewPosition.Y, 0)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = false
        end
    end)

    -- Section Handler (Tab Management)
    local SectionHandler = {}

    function SectionHandler:CreateSection(secName)
        secName = secName or "Tab"
        
        -- Tab Button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabFrame
        tabBtn.BackgroundColor3 = BASE_COLOR
        tabBtn.Size = UDim2.new(0, 95, 0, 32)
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Text = secName
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.TextSize = 14
        tabBtn.AutoButtonColor = false
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 3)

        -- Section Page
        local newPage = Instance.new("ScrollingFrame")
        newPage.Parent = pagesFolder
        newPage.BackgroundTransparency = 1
        newPage.BorderSizePixel = 0
        newPage.Size = UDim2.new(1, 0, 1, 0)
        newPage.ScrollBarThickness = 5
        newPage.ScrollBarImageColor3 = ACCENT_COLOR 
        newPage.Visible = false

        local pageItemList = Instance.new("UIListLayout")
        pageItemList.Parent = newPage
        pageItemList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageItemList.Padding = UDim.new(0, 3)
        Instance.new("UIPadding", newPage).PaddingTop = UDim.new(0, 5)

        local function UpdateCanvasSize()
            -- Ensures the CanvasSize always wraps the content
            task.wait() -- Allow layout to update
            local cS = pageItemList.AbsoluteContentSize
            newPage.CanvasSize = UDim2.new(0, 0, 0, cS.Y + 10)
        end

        newPage.ChildAdded:Connect(UpdateCanvasSize)
        newPage.ChildRemoved:Connect(UpdateCanvasSize)

        tabBtn.MouseButton1Click:Connect(function()
            for _, v in pagesFolder:GetChildren() do
                v.Visible = false
            end
            newPage.Visible = true
            UpdateCanvasSize()

            local TabTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) 

            for _, v in tabFrame:GetChildren() do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TabTweenInfo,{
                        BackgroundColor3 = BASE_COLOR
                    }):Play()
                end
            end
            TweenService:Create(tabBtn, TabTweenInfo,{
                BackgroundColor3 = ACCENT_COLOR
            }):Play()
        end)
        
        -- Element Handler (for this specific tab)
        local ElementHandler = {}

        -- Internal function to create the standard element wrapper
        local function createWrapper(height)
            local frame = Instance.new("Frame")
            frame.BackgroundColor3 = ELEMENT_COLOR
            frame.Size = UDim2.new(0, 394, 0, height or 42)
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 3)
            frame.Parent = newPage
            return frame
        end
        
        -- =======================================================
        -- !!! ELEMENT DEFINITIONS !!!
        -- =======================================================

        function ElementHandler:TextLabel(labelText)
            local wrapper = createWrapper(42)
            local txtLabel = Instance.new("TextLabel")
            txtLabel.Parent = wrapper
            txtLabel.BackgroundTransparency = 1
            txtLabel.Size = UDim2.new(1, 0, 1, 0)
            txtLabel.Font = Enum.Font.GothamSemibold
            txtLabel.Text = labelText or ""
            txtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            txtLabel.TextSize = 14
        end
        
        -- *NEW* GroupBox/Sub-Section for organization
        function ElementHandler:GroupBox(title)
            local wrapper = createWrapper(30)
            wrapper.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Slightly darker accent
            wrapper.Size = UDim2.new(0, 394, 0, 30)

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Parent = wrapper
            titleLabel.BackgroundTransparency = 1
            titleLabel.Size = UDim2.new(1, 0, 1, 0)
            titleLabel.Font = Enum.Font.GothamSemibold
            titleLabel.Text = " " .. (title or "Group")
            titleLabel.TextColor3 = ACCENT_COLOR
            titleLabel.TextSize = 15
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local contentFrame = Instance.new("Frame")
            contentFrame.Parent = newPage
            contentFrame.Name = "GroupBoxContent"
            contentFrame.BackgroundTransparency = 1
            contentFrame.Size = UDim2.new(0, 394, 0, 0) -- Will be resized by its own layout

            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = contentFrame
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.Padding = UDim.new(0, 3)

            -- Function to resize the content frame to fit its children
            local function updateGroupSize()
                task.wait()
                local cS = listLayout.AbsoluteContentSize
                contentFrame.Size = UDim2.new(0, 394, 0, cS.Y)
                UpdateCanvasSize()
            end
            
            contentFrame.ChildAdded:Connect(updateGroupSize)
            contentFrame.ChildRemoved:Connect(updateGroupSize)
            
            -- ElementHandler for the GroupBox's content
            local GroupElementHandler = {}
            for name, func in pairs(ElementHandler) do
                if name ~= "GroupBox" and name ~= "Separator" then -- Prevent nesting GroupBoxes or Separators
                    GroupElementHandler[name] = function(...)
                        local element = func(...)
                        if element.Parent == newPage then -- Relocate to contentFrame
                            element.Parent = contentFrame
                        end
                        return element
                    end
                end
            end
            
            return GroupElementHandler
        end

        function ElementHandler:TextButton(buttonText, buttonInfo, callback)
            local wrapper = createWrapper(42)
            
            local button = Instance.new("TextButton")
            button.Parent = wrapper
            button.BackgroundColor3 = ACCENT_COLOR 
            button.Position = UDim2.new(0.0177, 0, 0.166, 0)
            button.Size = UDim2.new(0, 141, 0, 27)
            button.Font = Enum.Font.GothamSemibold
            button.Text = buttonText or "Button"
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 14
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 3)

            local infoLabel = Instance.new("TextLabel")
            infoLabel.Parent = wrapper
            infoLabel.BackgroundTransparency = 1
            infoLabel.Position = UDim2.new(0.395, 0, 0.023, 0)
            infoLabel.Size = UDim2.new(0, 226, 0, 41)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.Text = buttonInfo or ""
            infoLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
            infoLabel.TextSize = 14
            infoLabel.TextXAlignment = Enum.TextXAlignment.Right

            button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            return wrapper
        end

        function ElementHandler:Toggle(togInfo, callback)
            local wrapper = createWrapper(42)
            local toggled = false
            
            local toggleInerFrame = Instance.new("Frame")
            toggleInerFrame.Parent = wrapper
            toggleInerFrame.BackgroundColor3 = ACCENT_COLOR 
            toggleInerFrame.Position = UDim2.new(0.0177, 0, 0.166, 0)
            toggleInerFrame.Size = UDim2.new(0, 27, 0, 27)
            Instance.new("UICorner", toggleInerFrame).CornerRadius = UDim.new(0, 3)

            local toggleInnerFrame1 = Instance.new("Frame")
            toggleInnerFrame1.Parent = toggleInerFrame
            toggleInnerFrame1.BackgroundColor3 = BASE_COLOR
            toggleInnerFrame1.Position = UDim2.new(0.017, 0, -0.018, 0)
            toggleInnerFrame1.Size = UDim2.new(0, 25, 0, 25)
            Instance.new("UICorner", toggleInnerFrame1).CornerRadius = UDim.new(0, 3)

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Parent = toggleInnerFrame1
            toggleBtn.BackgroundColor3 = BASE_COLOR
            toggleBtn.Size = UDim2.new(0, 23, 0, 23)
            toggleBtn.AutoButtonColor = false
            Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 3)
            
            -- Centering helper
            Instance.new("UIListLayout", toggleInnerFrame1).VerticalAlignment = Enum.VerticalAlignment.Center

            local infoLabel = Instance.new("TextLabel")
            infoLabel.Parent = wrapper
            infoLabel.BackgroundTransparency = 1
            infoLabel.Position = UDim2.new(0.395, 0, 0.023, 0)
            infoLabel.Size = UDim2.new(0, 226, 0, 41)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.Text = togInfo or ""
            infoLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
            infoLabel.TextSize = 14
            infoLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local ToggleTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            local function toggle(value)
                toggled = value
                local newPosition = toggled and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)

                TweenService:Create(toggleBtn, ToggleTweenInfo,{
                    BackgroundColor3 = toggled and ACCENT_COLOR or BASE_COLOR,
                    Position = newPosition
                }):Play()

                pcall(callback, toggled)
            end

            toggleBtn.MouseButton1Click:Connect(function()
                toggle(not toggled)
            end)

            return {
                Frame = wrapper,
                SetValue = toggle,
                GetValue = function() return toggled end
            }
        end
        
        function ElementHandler:Slider(sliderin, minvalue, maxvalue, callback)
            minvalue = minvalue or 0
            maxvalue = maxvalue or 100
            local wrapper = createWrapper(42)
            
            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Parent = wrapper
            sliderBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
            sliderBtn.BorderSizePixel = 0
            sliderBtn.Position = UDim2.new(0.0179, 0, 0.381, 0)
            sliderBtn.Size = UDim2.new(0, 141, 0, 10)
            sliderBtn.AutoButtonColor = false
            Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(0, 3)

            local sliderMainFrm = Instance.new("Frame")
            sliderMainFrm.Parent = sliderBtn
            sliderMainFrm.BackgroundColor3 = ACCENT_COLOR 
            sliderMainFrm.BorderSizePixel = 0
            sliderMainFrm.Size = UDim2.new(0, 0, 0, 10)
            Instance.new("UICorner", sliderMainFrm).CornerRadius = UDim.new(0, 5)

            local sliderValue = Instance.new("TextLabel")
            sliderValue.Parent = wrapper
            sliderValue.BackgroundTransparency = 1
            sliderValue.Position = UDim2.new(0.395, 0, 0.285, 0)
            sliderValue.Size = UDim2.new(0, 68, 0, 17)
            sliderValue.Font = Enum.Font.GothamSemibold
            sliderValue.TextColor3 = ACCENT_COLOR 
            sliderValue.TextSize = 14
            sliderValue.TextXAlignment = Enum.TextXAlignment.Left

            local sliderInfo = Instance.new("TextLabel")
            sliderInfo.Parent = wrapper
            sliderInfo.BackgroundTransparency = 1
            sliderInfo.Position = UDim2.new(0.570, 0, 0.023, 0)
            sliderInfo.Size = UDim2.new(0, 157, 0, 41)
            sliderInfo.Font = Enum.Font.GothamSemibold
            sliderInfo.Text = sliderin or "Slider Info"
            sliderInfo.TextColor3 = Color3.fromRGB(170, 170, 170)
            sliderInfo.TextSize = 14
            sliderInfo.TextXAlignment = Enum.TextXAlignment.Right
            
            local mouse = Players.LocalPlayer:GetMouse()
            local currentVal = minvalue
            local sliderWidth = sliderBtn.Size.X.Offset
            local range = maxvalue - minvalue
            
            local function updateValue(xOffset)
                xOffset = math.clamp(xOffset, 0, sliderWidth)
                sliderMainFrm.Size = UDim2.new(0, xOffset, 0, 10)
                
                local percentage = xOffset / sliderWidth
                local calculatedValue = math.floor((percentage * range) + minvalue)
                
                currentVal = calculatedValue
                sliderValue.Text = currentVal .. "/" .. maxvalue
                pcall(callback, currentVal)
            end
            
            -- Initial Value setup
            updateValue(0) 

            sliderBtn.MouseButton1Down:Connect(function()
                local moveConnection
                local releaseConnection
                
                local function onMove()
                    local xOffset = mouse.X - sliderBtn.AbsolutePosition.X
                    updateValue(xOffset)
                end
                
                moveConnection = mouse.Move:Connect(onMove)
                
                releaseConnection = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        moveConnection:Disconnect()
                        releaseConnection:Disconnect()
                    end
                end)
                
                onMove() -- Set initial value on click
            end)
            
            return {
                Frame = wrapper,
                SetValue = function(value) 
                    local clampedValue = math.clamp(value, minvalue, maxvalue)
                    local percentage = (clampedValue - minvalue) / range
                    local xOffset = percentage * sliderWidth
                    updateValue(xOffset)
                end,
                GetValue = function() return currentVal end
            }
        end

        function ElementHandler:Separator(separatorText)
            local wrapper = createWrapper(22)
            wrapper.BackgroundColor3 = Color3.fromRGB(28, 28, 28) -- Match Element Container
            
            local line = Instance.new("Frame")
            line.Parent = wrapper
            line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            line.Position = UDim2.new(0.5, 0, 0.5, 0)
            line.Size = UDim2.new(1, -20, 0, 1) -- Slightly thinner line
            line.AnchorPoint = Vector2.new(0.5, 0.5)

            local text = Instance.new("TextLabel")
            text.Parent = wrapper
            text.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            text.BackgroundTransparency = 0
            text.Size = UDim2.new(1, 0, 1, 0)
            text.Font = Enum.Font.GothamSemibold
            text.Text = "  " .. (separatorText or "") .. "  "
            text.TextColor3 = Color3.fromRGB(100, 100, 100)
            text.TextSize = 12
            text.TextXAlignment = Enum.TextXAlignment.Center

            -- If text is provided, mask the line with the background
            if separatorText and separatorText ~= "" then
                text.BackgroundTransparency = 0 
            else
                text.BackgroundTransparency = 1
            end
            return wrapper
        end

        return ElementHandler
    end
    
    -- Return the interface for creating tabs and the global Alert functions
    return SectionHandler
end 


return SlayLibX
