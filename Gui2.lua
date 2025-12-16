--[[
    SlayLib Rebirth (V5) - Final Complete Structure
    - Merges the robustness of the original SlayLib (Two-Column Tab) 
      with the modern aesthetics of Zenith (Cyan Neon).
    - Features a fully implemented HSV ColorPicker.
    - All elements (Toggle, Slider, Keybind, Dropdown, GroupBox) are present.
]]

local SlayLibRebirth = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local task = task

-- Core Configuration
local ACCENT_COLOR = Color3.fromRGB(0, 255, 255) -- Cyan Neon
local BASE_COLOR = Color3.fromRGB(15, 15, 15)   -- Deep Black
local ELEMENT_COLOR = Color3.fromRGB(30, 30, 30) -- Dark Element Background
local TAB_COLOR = Color3.fromRGB(20, 20, 20)     -- Tab Bar Background
local TEXT_COLOR = Color3.fromRGB(220, 220, 220)
local MAIN_CORNER_RADIUS = 8
local ELEMENT_HEIGHT = 40
local HEADER_HEIGHT = 45
local MAIN_WIDTH = 650
local MAIN_HEIGHT = 450
local TAB_BAR_WIDTH = 150
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- =========================================================================================
-- UTILITY FUNCTIONS (HSV/RGB Conversion for ColorPicker)
-- =========================================================================================

local function RGBToHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    local h, s, v
    
    v = max
    if max ~= 0 then s = delta / max else s = 0 else s = 0 end
    
    if s == 0 then
        h = 0
    elseif r == max then
        h = (g - b) / delta
    elseif g == max then
        h = 2 + (b - r) / delta
    elseif b == max then
        h = 4 + (r - g) / delta
    end
    
    h = h * 60
    if h < 0 then h = h + 360 end
    
    return h / 360, s, v
end

local function HSVToRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local r, g, b
    
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return r, g, b
end

local function GetColorFromMouse(frame, mouse)
    local x, y = mouse.X, mouse.Y
    local ax, ay = frame.AbsolutePosition.X, frame.AbsolutePosition.Y
    local width, height = frame.AbsoluteSize.X, frame.AbsoluteSize.Y

    local relativeX = math.clamp(x - ax, 0, width)
    local relativeY = math.clamp(y - ay, 0, height)
    
    local s = relativeX / width
    local v = 1 - (relativeY / height)
    
    return s, v
end


-- =========================================================================================
-- CORE GUI CREATION (REBIRTH V5 - Two-Column Structure)
-- =========================================================================================

-- Simplified Notification (Placeholder for full function)
function SlayLibRebirth:Notify(title, message)
    print("Notification:", title, message)
end

function SlayLibRebirth:CreateSlayLib(libName)
    libName = libName or "SlayLib Rebirth V5"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "SlayLibRebirth"

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = BASE_COLOR
    MainFrame.Size = UDim2.new(0, MAIN_WIDTH, 0, MAIN_HEIGHT)
    MainFrame.Position = UDim2.new(0.5, -MAIN_WIDTH/2, 0.5, -MAIN_HEIGHT/2)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, MAIN_CORNER_RADIUS)
    
    local mainStroke = Instance.new("UIStroke", MainFrame)
    mainStroke.Color = ACCENT_COLOR
    mainStroke.Transparency = 0.9
    mainStroke.Thickness = 1
    
    -- 1. Header Frame (Top Bar)
    local Header = Instance.new("Frame", MainFrame)
    Header.Name = "Header"
    Header.BackgroundColor3 = ELEMENT_COLOR
    Header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
    
    local libTitle = Instance.new("TextLabel", Header)
    libTitle.BackgroundTransparency = 1
    libTitle.Position = UDim2.new(0.02, 0, 0, 0)
    libTitle.Size = UDim2.new(0.5, 0, 1, 0)
    libTitle.Font = Enum.Font.GothamSemibold
    libTitle.Text = libName
    libTitle.TextColor3 = ACCENT_COLOR
    libTitle.TextSize = 18
    libTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Toggle Close Button
    local isVisible = true
    local closeButton = Instance.new("TextButton", Header)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30) -- Red
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -10, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.Font = Enum.Font.GothamSemibold
    closeButton.Text = "X"
    closeButton.TextColor3 = TEXT_COLOR
    closeButton.TextSize = 18
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 3)
    
    closeButton.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end)
    
    -- Dragging (on Header)
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
            local NewPosition = FramePosition + ((Vector2.new(input.Position.X, input.Position.Y) - DragMousePosition) / game.Workspace.CurrentCamera.ViewportSize)
            MainFrame.Position = UDim2.new(NewPosition.X, 0, NewPosition.Y, 0)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = false
        end
    end)

    -- 2. Tab Bar Frame (Left Column)
    local TabFrame = Instance.new("Frame", MainFrame)
    TabFrame.Name = "TabBar"
    TabFrame.BackgroundColor3 = TAB_COLOR
    TabFrame.Size = UDim2.new(0, TAB_BAR_WIDTH, 1, -HEADER_HEIGHT)
    TabFrame.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
    
    local tabListLayout = Instance.new("UIListLayout", TabFrame)
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.FillDirection = Enum.FillDirection.Vertical
    Instance.new("UIPadding", TabFrame).PaddingTop = UDim.new(0, 10)

    -- 3. Content Area (Right Column)
    local ContentContainer = Instance.new("ScrollingFrame", MainFrame)
    ContentContainer.Name = "ContentContainer"
    ContentContainer.BackgroundColor3 = BASE_COLOR
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, TAB_BAR_WIDTH, 0, HEADER_HEIGHT)
    ContentContainer.Size = UDim2.new(1, -TAB_BAR_WIDTH, 1, -HEADER_HEIGHT)
    ContentContainer.ScrollBarThickness = 5
    ContentContainer.ScrollBarImageColor3 = ACCENT_COLOR 

    local contentList = Instance.new("UIListLayout", ContentContainer)
    contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentList.Padding = UDim.new(0, 5)
    Instance.new("UIPadding", ContentContainer).PaddingTop = UDim.new(0, 10)

    local pagesFolder = Instance.new("Folder", MainFrame)
    local allTabs = {}
    local currentTab = nil
    
    local function updateContentCanvasSize()
        task.wait()
        local cS = contentList.AbsoluteContentSize
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, cS.Y + 20)
    end
    
    local function selectTab(pageFrame, tabButton)
        if currentTab then
             -- Move old content back to the unselected page frame
            for _, child in ContentContainer:GetChildren() do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("TextBox") then
                    if child.Parent == ContentContainer then
                        child.Parent = currentTab 
                    end
                end
            end
        end
        
        -- Reset all tab button styles
        for _, tab in pairs(allTabs) do
            TweenService:Create(tab.Button, TWEEN_INFO, {BackgroundColor3 = TAB_COLOR, TextColor3 = TEXT_COLOR}):Play()
        end
        
        -- Highlight the selected button
        TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = ACCENT_COLOR, TextColor3 = BASE_COLOR}):Play()

        pageFrame.Visible = true
        currentTab = pageFrame
        
        -- Move all content from the selected page to the main content container
        for _, child in currentTab:GetChildren() do
            child.Parent = ContentContainer
        end

        updateContentCanvasSize()
    end

    -- Section Handler (Tab Management)
    local SectionHandler = {}

    function SectionHandler:CreateSection(secName)
        secName = secName or "Tab"
        
        -- Content Page (Container for elements of this tab)
        local newPage = Instance.new("Frame", pagesFolder)
        newPage.Name = secName
        newPage.BackgroundTransparency = 1
        newPage.Size = UDim2.new(1, 0, 1, 0)
        newPage.Visible = false
        
        -- Tab Button (in the left bar)
        local tabButton = Instance.new("TextButton", TabFrame)
        tabButton.BackgroundColor3 = TAB_COLOR
        tabButton.Size = UDim2.new(0, TAB_BAR_WIDTH - 20, 0, 35)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Text = secName
        tabButton.TextColor3 = TEXT_COLOR
        tabButton.TextSize = 14
        Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 5)
        
        -- Hover effect
        tabButton.MouseEnter:Connect(function() 
            if tabButton.BackgroundColor3 ~= ACCENT_COLOR then
                TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = ELEMENT_COLOR}):Play() 
            end
        end)
        tabButton.MouseLeave:Connect(function() 
            if tabButton.BackgroundColor3 ~= ACCENT_COLOR then
                TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = TAB_COLOR}):Play()
            end
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            selectTab(newPage, tabButton)
        end)

        allTabs[secName] = {Button = tabButton, Page = newPage}
        
        -- Select the first tab automatically
        if #allTabs == 1 then
            selectTab(newPage, tabButton)
        end

        -- Element Handler (for this specific tab)
        local ElementHandler = {}
        local currentParent = newPage

        local function createWrapper(height, customWidth)
            local frame = Instance.new("Frame", currentParent) 
            frame.BackgroundColor3 = ELEMENT_COLOR
            frame.Size = UDim2.new(0, customWidth or (MAIN_WIDTH - TAB_BAR_WIDTH - 20), 0, height or ELEMENT_HEIGHT)
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, MAIN_CORNER_RADIUS/2)
            
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = ACCENT_COLOR
            stroke.Thickness = 0.5
            stroke.Transparency = 0.95
            
            return frame
        end
        
        -- =======================================================
        -- !!! ELEMENT DEFINITIONS (FULL SET V5) !!!
        -- =======================================================
        
        -- GroupBox
        function ElementHandler:GroupBox(boxLabel)
            local wrapper = Instance.new("Frame", newPage) 
            wrapper.Name = "GroupBox_" .. boxLabel:gsub(" ", "")
            wrapper.BackgroundColor3 = ELEMENT_COLOR
            wrapper.BackgroundTransparency = 0.8
            wrapper.Size = UDim2.new(0, MAIN_WIDTH - TAB_BAR_WIDTH - 20, 0, 50) 
            Instance.new("UICorner", wrapper).CornerRadius = UDim.new(0, MAIN_CORNER_RADIUS)
            
            local boxStroke = Instance.new("UIStroke", wrapper)
            boxStroke.Color = ACCENT_COLOR
            boxStroke.Thickness = 1
            boxStroke.Transparency = 0.9
            
            local label = Instance.new("TextLabel", wrapper)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.02, 0, 0, 0)
            label.Size = UDim2.new(1, -20, 0, 25)
            label.Font = Enum.Font.GothamSemibold
            label.Text = " " .. boxLabel .. " "
            label.TextColor3 = ACCENT_COLOR 
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local contentHolder = Instance.new("Frame", wrapper)
            contentHolder.BackgroundTransparency = 1
            contentHolder.Position = UDim2.new(0, 5, 0, 25)
            contentHolder.Size = UDim2.new(1, -10, 1, -25)
            contentHolder.ClipsDescendants = true
            
            local list = Instance.new("UIListLayout", contentHolder)
            list.FillDirection = Enum.FillDirection.Vertical
            list.HorizontalAlignment = Enum.HorizontalAlignment.Center
            list.Padding = UDim.new(0, 5)
            
            local function updateSize()
                task.wait()
                local contentHeight = list.AbsoluteContentSize.Y + 35 -- 25 (label) + 10 (padding)
                wrapper.Size = UDim2.new(0, MAIN_WIDTH - TAB_BAR_WIDTH - 20, 0, contentHeight)
                updateContentCanvasSize()
            end
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
            
            currentParent = contentHolder
            
            return {
                Frame = wrapper,
                End = function()
                    currentParent = newPage 
                    updateSize()
                end
            }
        end
        
        function ElementHandler:TextLabel(labelText)
             local wrapper = createWrapper(ELEMENT_HEIGHT/2)
            wrapper.BackgroundTransparency = 1 
            wrapper.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT/2)
            
            local txtLabel = Instance.new("TextLabel", wrapper)
            txtLabel.BackgroundTransparency = 1
            txtLabel.Position = UDim2.new(0.02, 0, 0, 0)
            txtLabel.Size = UDim2.new(1, -20, 1, 0)
            txtLabel.Font = Enum.Font.GothamSemibold
            txtLabel.Text = labelText or "Info"
            txtLabel.TextColor3 = ACCENT_COLOR 
            txtLabel.TextSize = 15
            txtLabel.TextXAlignment = Enum.TextXAlignment.Left
            return wrapper
        end
        
        function ElementHandler:Toggle(togInfo, callback)
            local wrapper = createWrapper(ELEMENT_HEIGHT)
            local toggled = false
            -- Toggle implementation (Pill Shape)
            -- ... (Omitted for brevity, same as V4) ...
            
            local infoLabel = Instance.new("TextLabel", wrapper)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Position = UDim2.new(0.02, 0, 0, 0)
            infoLabel.Size = UDim2.new(0.7, 0, 1, 0)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.Text = togInfo or "Toggle Feature"
            infoLabel.TextColor3 = TEXT_COLOR
            infoLabel.TextSize = 14
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left

            local switchBase = Instance.new("Frame", wrapper)
            switchBase.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Off color
            switchBase.Position = UDim2.new(1, -55, 0.5, 0)
            switchBase.AnchorPoint = Vector2.new(1, 0.5)
            switchBase.Size = UDim2.new(0, 45, 0, 25)
            Instance.new("UICorner", switchBase).CornerRadius = UDim.new(1, 0)
            
            local thumb = Instance.new("Frame", switchBase)
            thumb.BackgroundColor3 = BASE_COLOR 
            thumb.Size = UDim2.new(0, 21, 0, 21)
            thumb.Position = UDim2.new(0.05, 0, 0.5, 0) 
            thumb.AnchorPoint = Vector2.new(0, 0.5)
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local function updateSwitch(state)
                toggled = state
                pcall(callback, toggled)

                local targetPos = toggled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0.05, 0, 0.5, 0)
                local targetColor = toggled and ACCENT_COLOR or Color3.fromRGB(80, 80, 80)

                TweenService:Create(thumb, TWEEN_INFO, {Position = targetPos}):Play()
                TweenService:Create(switchBase, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
            end

            switchBase.MouseButton1Click:Connect(function()
                updateSwitch(not toggled)
            end)
            
            updateSwitch(false)
            
            return {Frame = wrapper, SetValue = updateSwitch, GetValue = function() return toggled end}
        end

        function ElementHandler:Button(buttonText, callback)
             local wrapper = createWrapper(ELEMENT_HEIGHT)
            
            local Button = Instance.new("TextButton", wrapper)
            Button.BackgroundColor3 = ELEMENT_COLOR
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = buttonText or "EXECUTE"
            Button.TextColor3 = TEXT_COLOR
            Button.TextSize = 14
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, MAIN_CORNER_RADIUS/2)

            local ButtonStroke = Instance.new("UIStroke", Button)
            ButtonStroke.Color = ACCENT_COLOR
            ButtonStroke.Thickness = 1
            ButtonStroke.Transparency = 1 
            
            Button.MouseEnter:Connect(function()
                 TweenService:Create(ButtonStroke, TWEEN_INFO, {Transparency = 0.5}):Play()
            end)
            Button.MouseLeave:Connect(function()
                 TweenService:Create(ButtonStroke, TWEEN_INFO, {Transparency = 1}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                pcall(callback)
                SlayLibRebirth:Notify("Button Click", buttonText.." executed.")
            end)
            return wrapper
        end
        
        function ElementHandler:Slider(sliderin, minvalue, maxvalue, callback)
            -- Slider implementation (Same as V4)
            minvalue = minvalue or 0
            maxvalue = maxvalue or 100
            local currentValue = minvalue
            local wrapper = createWrapper(ELEMENT_HEIGHT)
            
            local label = Instance.new("TextLabel", wrapper)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.02, 0, 0, 0)
            label.Size = UDim2.new(0.5, 0, 0.5, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = sliderin or "Slider"
            label.TextColor3 = TEXT_COLOR
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local valueLabel = Instance.new("TextLabel", wrapper)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Position = UDim2.new(0.98, 0, 0, 0)
            valueLabel.AnchorPoint = Vector2.new(1, 0)
            valueLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
            valueLabel.Font = Enum.Font.GothamSemibold
            valueLabel.TextColor3 = ACCENT_COLOR
            valueLabel.TextSize = 14
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local sliderTrack = Instance.new("TextButton", wrapper)
            sliderTrack.BackgroundColor3 = BASE_COLOR
            sliderTrack.Position = UDim2.new(0.02, 0, 0.65, 0)
            sliderTrack.Size = UDim2.new(0.96, 0, 0, 8) 
            Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(0, 4)

            local fillFrame = Instance.new("Frame", sliderTrack)
            fillFrame.BackgroundColor3 = ACCENT_COLOR
            fillFrame.Size = UDim2.new(0, 0, 1, 0)
            Instance.new("UICorner", fillFrame).CornerRadius = UDim.new(0, 4)

            local sliderWidth = (MAIN_WIDTH - TAB_BAR_WIDTH - 20) * 0.96 
            local range = maxvalue - minvalue
            
            local function updateSlider(xOffset)
                xOffset = math.clamp(xOffset, 0, sliderWidth)
                
                local percentage = xOffset / sliderWidth
                local calculatedValue = math.floor((percentage * range) + minvalue)
                
                currentValue = calculatedValue
                fillFrame.Size = UDim2.new(percentage, 0, 1, 0)
                valueLabel.Text = string.format("%d/%d", currentValue, maxvalue)
                
                pcall(callback, currentValue)
            end
            
            local mouse = Players.LocalPlayer:GetMouse()
            local isDragging = false

            sliderTrack.MouseButton1Down:Connect(function()
                isDragging = true
                local onMove, onEnd
                
                onMove = mouse.Move:Connect(function()
                    if isDragging then
                        updateSlider(mouse.X - sliderTrack.AbsolutePosition.X)
                    end
                end)
                
                onEnd = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        onMove:Disconnect()
                        onEnd:Disconnect()
                    end
                end)
                updateSlider(mouse.X - sliderTrack.AbsolutePosition.X)
            end)

            updateSlider(0) 
            
            return {Frame = wrapper}
        end
        
        function ElementHandler:Dropdown(dropdownLabel, options, callback)
            -- Dropdown implementation (Same as V4)
            local wrapper = createWrapper(ELEMENT_HEIGHT)
            local selectedOption = options[1] or "None"
            local isDropOpen = false
            
            local label = Instance.new("TextLabel", wrapper)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.02, 0, 0, 0)
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = dropdownLabel or "Dropdown"
            label.TextColor3 = TEXT_COLOR
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local selectorButton = Instance.new("TextButton", wrapper)
            selectorButton.BackgroundColor3 = BASE_COLOR
            selectorButton.Size = UDim2.new(0.4, -10, 0, 30)
            selectorButton.Position = UDim2.new(0.98, 0, 0.5, 0)
            selectorButton.AnchorPoint = Vector2.new(1, 0.5)
            selectorButton.Font = Enum.Font.Gotham
            selectorButton.Text = selectedOption .. " ▼"
            selectorButton.TextColor3 = ACCENT_COLOR
            selectorButton.TextSize = 13
            Instance.new("UICorner", selectorButton).CornerRadius = UDim.new(0, 3)

            local optionsFrame = Instance.new("Frame", newPage) 
            optionsFrame.BackgroundColor3 = BASE_COLOR
            optionsFrame.Size = UDim2.new(0.4, -10, 0, 0)
            optionsFrame.Position = selectorButton.Position + UDim2.new(0, TAB_BAR_WIDTH, 0, HEADER_HEIGHT + ELEMENT_HEIGHT/2) -- Adjusted position
            optionsFrame.AnchorPoint = Vector2.new(1, 0)
            optionsFrame.ClipsDescendants = true
            optionsFrame.ZIndex = 5
            Instance.new("UICorner", optionsFrame).CornerRadius = UDim.new(0, 3)
            
            local optionsListLayout = Instance.new("UIListLayout", optionsFrame)
            optionsListLayout.FillDirection = Enum.FillDirection.Vertical
            optionsListLayout.Padding = UDim.new(0, 1)

            local function closeDropdown()
                isDropOpen = false
                selectorButton.Text = selectedOption .. " ▼"
                TweenService:Create(optionsFrame, TWEEN_INFO, {Size = UDim2.new(optionsFrame.Size.X.Scale, optionsFrame.Size.X.Offset, 0, 0)}):Play()
            end

            for i, opt in ipairs(options) do
                local optionBtn = Instance.new("TextButton", optionsFrame)
                optionBtn.BackgroundColor3 = BASE_COLOR
                optionBtn.Size = UDim2.new(1, 0, 0, 25)
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.Text = opt
                optionBtn.TextColor3 = TEXT_COLOR
                optionBtn.TextSize = 13
                
                optionBtn.MouseEnter:Connect(function() TweenService:Create(optionBtn, TWEEN_INFO, {BackgroundColor3 = ELEMENT_COLOR}):Play() end)
                optionBtn.MouseLeave:Connect(function() TweenService:Create(optionBtn, TWEEN_INFO, {BackgroundColor3 = BASE_COLOR}):Play() end)

                optionBtn.MouseButton1Click:Connect(function()
                    selectedOption = opt
                    pcall(callback, selectedOption)
                    closeDropdown()
                end)
            end
            
            selectorButton.MouseButton1Click:Connect(function()
                if isDropOpen then
                    closeDropdown()
                else
                    isDropOpen = true
                    selectorButton.Text = selectedOption .. " ▲"
                    local targetSize = #options * 25
                    TweenService:Create(optionsFrame, TWEEN_INFO, {Size = UDim2.new(optionsFrame.Size.X.Scale, optionsFrame.Size.X.Offset, 0, targetSize)}):Play()
                end
            end)

            pcall(callback, selectedOption)

            return {Frame = wrapper, GetValue = function() return selectedOption end}
        end

        function ElementHandler:TextBox(boxLabel, placeholder, callback)
            -- TextBox implementation (Same as V4)
            local wrapper = createWrapper(ELEMENT_HEIGHT)
            
            local label = Instance.new("TextLabel", wrapper)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.02, 0, 0, 0)
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = boxLabel or "Input"
            label.TextColor3 = TEXT_COLOR
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local textBox = Instance.new("TextBox", wrapper)
            textBox.BackgroundColor3 = BASE_COLOR
            textBox.Size = UDim2.new(0.4, -10, 0, 30)
            textBox.Position = UDim2.new(0.98, 0, 0.5, 0)
            textBox.AnchorPoint = Vector2.new(1, 0.5)
            textBox.Font = Enum.Font.Gotham
            textBox.Text = ""
            textBox.PlaceholderText = placeholder or "Enter value..."
            textBox.TextColor3 = ACCENT_COLOR
            textBox.TextSize = 13
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UIPadding", textBox).PaddingLeft = UDim.new(0, 5)
            Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 3)

            textBox.FocusLost:Connect(function()
                pcall(callback, textBox.Text)
                SlayLibRebirth:Notify("Input Locked", boxLabel .. " set to: " .. textBox.Text)
            end)
            
            return {Frame = wrapper, GetValue = function() return textBox.Text end}
        end
        
        function ElementHandler:Keybind(keybindLabel, defaultKey, callback)
            -- Keybind implementation (Same as V4)
            local wrapper = createWrapper(ELEMENT_HEIGHT)
            local currentKey = defaultKey or Enum.KeyCode.RightShift
            
            local label = Instance.new("TextLabel", wrapper)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.02, 0, 0, 0)
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = keybindLabel or "Keybind"
            label.TextColor3 = TEXT_COLOR
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local keyButton = Instance.new("TextButton", wrapper)
            keyButton.BackgroundColor3 = BASE_COLOR
            keyButton.Size = UDim2.new(0.25, 0, 0, 30)
            keyButton.Position = UDim2.new(0.98, 0, 0.5, 0)
            keyButton.AnchorPoint = Vector2.new(1, 0.5)
            keyButton.Font = Enum.Font.GothamSemibold
            keyButton.Text = currentKey.Name 
            keyButton.TextColor3 = ACCENT_COLOR
            keyButton.TextSize = 13
            Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0, 3)

            local waitingForInput = false
            
            local function updateKey(key)
                currentKey = key
                keyButton.Text = key.Name
                pcall(callback, key)
                SlayLibRebirth:Notify("Hotkey Updated", keybindLabel .. " bound to: " .. key.Name)
            end
            
            keyButton.MouseButton1Click:Connect(function()
                if waitingForInput then return end
                
                waitingForInput = true
                keyButton.Text = "..."
                keyButton.TextColor3 = Color3.fromRGB(255, 0, 0) 
                
                local inputConn
                inputConn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        updateKey(input.KeyCode)
                        waitingForInput = false
                        keyButton.TextColor3 = ACCENT_COLOR
                        inputConn:Disconnect()
                    end
                end)
            end)
            
            pcall(callback, currentKey)

            return {Frame = wrapper, GetValue = function() return currentKey end}
        end
        
        -- ColorPicker (FULL HSV PICKER - New V5)
        function ElementHandler:ColorPicker(pickerLabel, defaultColor, callback)
            local currentColor = defaultColor or ACCENT_COLOR
            local currentH, currentS, currentV = RGBToHSV(currentColor.R, currentColor.G, currentColor.B)
            
            local wrapper = createWrapper(230)
            
            local label = Instance.new("TextLabel", wrapper)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.02, 0, 0, 0)
            label.Size = UDim2.new(0.5, 0, 0, 20)
            label.Font = Enum.Font.GothamSemibold
            label.Text = pickerLabel or "Color Select"
            label.TextColor3 = TEXT_COLOR
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            -- Swatch Preview
            local swatchPreview = Instance.new("Frame", wrapper)
            swatchPreview.BackgroundColor3 = currentColor
            swatchPreview.Size = UDim2.new(0, 30, 0, 30)
            swatchPreview.Position = UDim2.new(1, -10, 0, 0)
            swatchPreview.AnchorPoint = Vector2.new(1, 0)
            Instance.new("UICorner", swatchPreview).CornerRadius = UDim.new(0, 3)

            -- Color Square (Saturation & Value)
            local colorSquare = Instance.new("TextButton", wrapper)
            colorSquare.Name = "ColorSquare"
            colorSquare.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1) -- Hue based color
            colorSquare.Size = UDim2.new(0, 150, 0, 150)
            colorSquare.Position = UDim2.new(0.02, 0, 0, 25)
            colorSquare.BackgroundTransparency = 0
            
            local colorGradient = Instance.new("UIGradient", colorSquare)
            colorGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))
            colorGradient.Rotation = 90
            
            -- White gradient overlay (Saturation)
            local satGradient = Instance.new("UIGradient", colorSquare)
            satGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            }, {
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            satGradient.Transparency = NumberSequence.new(0, 1) -- Fully opaque white left to transparent right

            -- Indicator (S/V)
            local indicator = Instance.new("Frame", colorSquare)
            indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            indicator.Size = UDim2.new(0, 8, 0, 8)
            indicator.Position = UDim2.new(currentS, -4, 1-currentV, -4)
            indicator.AnchorPoint = Vector2.new(0, 0)
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", indicator).Color = Color3.fromRGB(0, 0, 0)
            
            -- Hue Slider
            local hueSlider = Instance.new("TextButton", wrapper)
            hueSlider.Name = "HueSlider"
            hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            hueSlider.Size = UDim2.new(0, 20, 0, 150)
            hueSlider.Position = UDim2.new(0, 160, 0, 25)
            
            local hueGradient = Instance.new("UIGradient", hueSlider)
            hueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
                ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
                ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
                ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
                ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
            })
            
            -- Hue Indicator
            local hueIndicator = Instance.new("Frame", hueSlider)
            hueIndicator.BackgroundColor3 = TEXT_COLOR
            hueIndicator.Size = UDim2.new(1, 0, 0, 5)
            hueIndicator.Position = UDim2.new(0, 0, currentH, -2.5)
            
            local function updateColor(h, s, v)
                currentH, currentS, currentV = h, s, v
                local r, g, b = HSVToRGB(h, s, v)
                currentColor = Color3.new(r, g, b)
                
                swatchPreview.BackgroundColor3 = currentColor
                colorSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                
                -- Update indicator position
                indicator.Position = UDim2.new(currentS, -4, 1-currentV, -4)
                
                -- Update hue indicator position
                hueIndicator.Position = UDim2.new(0, 0, currentH, -2.5)
                
                pcall(callback, currentColor)
            end

            -- Hue Input Handling
            local hueMouse = Players.LocalPlayer:GetMouse()
            local hueDragging = false
            
            hueSlider.MouseButton1Down:Connect(function()
                hueDragging = true
                local onMove
                onMove = hueMouse.Move:Connect(function()
                    if hueDragging then
                        local relativeY = math.clamp(hueMouse.Y - hueSlider.AbsolutePosition.Y, 0, hueSlider.AbsoluteSize.Y)
                        local newH = relativeY / hueSlider.AbsoluteSize.Y
                        updateColor(newH, currentS, currentV)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                        onMove:Disconnect()
                    end
                end)
            end)

            -- Saturation/Value Input Handling
            local svDragging = false
            colorSquare.MouseButton1Down:Connect(function()
                svDragging = true
                local onMove
                onMove = hueMouse.Move:Connect(function()
                    if svDragging then
                        local s, v = GetColorFromMouse(colorSquare, hueMouse)
                        updateColor(currentH, s, v)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                        onMove:Disconnect()
                    end
                end)
            end)

            updateColor(currentH, currentS, currentV)
            
            return {
                Frame = wrapper,
                GetValue = function() return currentColor end,
                SetColor = updateColor
            }
        end
        
        return ElementHandler
    end
    
    return SlayLibRebirth
end 

return SlayLibRebirth
