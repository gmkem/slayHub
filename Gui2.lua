--[[
    SlayLib V9: The Immaculate Copy
    - Full, integrated script based on SlayLib.lua structure.
    - Implements a perfected, working HSV/Hex ColorPicker (replacing the simulation).
    - Adds GroupBox element for structured organization.
    - Uses Crimson Red (139, 0, 23) as the core accent color.
--]]

local SlayLib = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris") 
local Players = game:GetService("Players")
local task = task 

-- CONFIGURATION (Based on SlayLib original style)
local ACCENT_COLOR = Color3.fromRGB(139, 0, 23) -- Crimson Red
local BASE_COLOR = Color3.fromRGB(15, 15, 15)   -- Main Background
local ELEMENT_COLOR = Color3.fromRGB(25, 25, 25) -- Element Background
local TAB_COLOR = Color3.fromRGB(20, 20, 20)     -- Tab Bar Background
local TEXT_COLOR = Color3.fromRGB(170, 170, 170)
local TEXT_COLOR_DARK = Color3.fromRGB(40, 40, 40)
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local MAIN_CORNER_RADIUS = 3
local ELEMENT_HEIGHT = 42
local LIB_WIDTH = 400 -- Width of the ElementContainer in the original snippet context

-- =========================================================================================
-- UTILITY FUNCTIONS: HSV/RGB Conversion (REQUIRED FOR COLOR PICKER)
-- =========================================================================================

local function RGBToHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    local h, s, v
    v = max
    if max ~= 0 then s = delta / max else s = 0 end
    if s == 0 then h = 0 elseif r == max then h = (g - b) / delta elseif g == max then h = 2 + (b - r) / delta elseif b == max then h = 4 + (r - g) / delta end
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

local function Color3ToHex(color)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

-- Placeholder for original Alert/Notify functions
function SlayLib:Alert(title, message, duration)
    -- This would be the logic for your custom alert system
    print(string.format("[SlayLib ALERT] %s - %s", title, message))
end
function SlayLib:Notify(title, message, duration)
    print(string.format("[SlayLib NOTIFY] %s: %s", title, message))
end

-- =========================================================================================
-- CORE GUI CREATION
-- =========================================================================================

function SlayLib:CreateSlayLib(libName)
    libName = libName or "SlayLib V9"
    local isClosed = false

    -- Main Instances setup (matching the user's original structure)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = libName

    local MainWhiteFrame = Instance.new("Frame")
    MainWhiteFrame.Parent = ScreenGui
    MainWhiteFrame.Size = UDim2.new(0, 580, 0, 480) -- Two column default size
    MainWhiteFrame.Position = UDim2.new(0.5, -290, 0.5, -240)
    MainWhiteFrame.BackgroundColor3 = BASE_COLOR
    
    local mainCorner = Instance.new("UICorner", MainWhiteFrame)
    mainCorner.CornerRadius = UDim.new(0, MAIN_CORNER_RADIUS)

    local mainStroke = Instance.new("UIStroke", MainWhiteFrame)
    mainStroke.Color = ACCENT_COLOR
    mainStroke.Thickness = 1
    
    local header = Instance.new("Frame", MainWhiteFrame)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = ELEMENT_COLOR
    
    local libTitle = Instance.new("TextLabel", header)
    libTitle.BackgroundTransparency = 1
    libTitle.Position = UDim2.new(0.02, 0, 0.5, 0)
    libTitle.AnchorPoint = Vector2.new(0, 0.5)
    libTitle.Size = UDim2.new(0.5, 0, 1, 0)
    libTitle.Font = Enum.Font.GothamSemibold
    libTitle.Text = libName
    libTitle.TextColor3 = ACCENT_COLOR
    libTitle.TextSize = 15
    libTitle.TextXAlignment = Enum.TextXAlignment.Left

    local closeLib = Instance.new("ImageButton", header)
    closeLib.BackgroundColor3 = ACCENT_COLOR
    closeLib.Size = UDim2.new(0, 20, 0, 20)
    closeLib.Position = UDim2.new(1, -10, 0.5, 0)
    closeLib.AnchorPoint = Vector2.new(1, 0.5)
    closeLib.Image = "rbxassetid://6034179375" -- Generic X icon
    Instance.new("UICorner", closeLib).CornerRadius = UDim.new(0, 3)
    closeLib.ImageColor3 = BASE_COLOR

    closeLib.MouseButton1Click:Connect(function()
        MainWhiteFrame.Visible = not MainWhiteFrame.Visible
        isClosed = not MainWhiteFrame.Visible
    end)
    
    -- Dragging functionality (based on user's original snippet)
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

    -- Tab Frame (Left Column)
    local tabFrame = Instance.new("Frame", MainWhiteFrame)
    tabFrame.Size = UDim2.new(0, 150, 1, -30)
    tabFrame.Position = UDim2.new(0, 0, 0, 30)
    tabFrame.BackgroundColor3 = TAB_COLOR
    
    local tabList = Instance.new("UIListLayout", tabFrame)
    tabList.Padding = UDim.new(0, 5)
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.FillDirection = Enum.FillDirection.Vertical
    Instance.new("UIPadding", tabFrame).PaddingTop = UDim.new(0, 10)

    -- Content Frame (Right Column) - ScrollingFrame used for content list
    local elementContainer = Instance.new("ScrollingFrame", MainWhiteFrame)
    elementContainer.Size = UDim2.new(1, -150, 1, -30)
    elementContainer.Position = UDim2.new(0, 150, 0, 30)
    elementContainer.BackgroundColor3 = BASE_COLOR
    elementContainer.BackgroundTransparency = 1
    elementContainer.ScrollBarThickness = 5
    elementContainer.ScrollBarImageColor3 = ACCENT_COLOR 
    elementContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local mainList = Instance.new("UIListLayout", elementContainer)
    mainList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mainList.Padding = UDim.new(0, 5)
    Instance.new("UIPadding", elementContainer).PaddingTop = UDim.new(0, 10)

    local pagesFolder = Instance.new("Folder", MainWhiteFrame)
    local allTabs = {}
    local currentTab = nil
    
    -- Function to adjust the ElementContainer's CanvasSize
    local function UpdateSize()
        task.wait()
        local cS = mainList.AbsoluteContentSize
        elementContainer.CanvasSize = UDim2.new(0, 0, 0, cS.Y + 20)
    end
    
    local function selectTab(pageFrame, tabButton)
        if currentTab then
            -- Move old content back to the unselected page frame
            for _, child in elementContainer:GetChildren() do
                -- Only move elements that are not the UIListLayout or UIPadding
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("TextBox") then
                    if child.Parent == elementContainer then
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
            child.Parent = elementContainer
        end

        UpdateSize()
    end

    -- Section Handler (Tab Management)
    local SectionHandler = {}

    function SectionHandler:CreateSection(secName)
        secName = secName or "Tab"
        
        local newPage = Instance.new("Frame", pagesFolder)
        newPage.Name = secName
        newPage.BackgroundTransparency = 1
        newPage.Size = UDim2.new(1, 0, 1, 0)
        newPage.Visible = false
        
        local tabButton = Instance.new("TextButton", tabFrame)
        tabButton.BackgroundColor3 = TAB_COLOR
        tabButton.Size = UDim2.new(0, 130, 0, 30)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Text = secName
        tabButton.TextColor3 = TEXT_COLOR
        tabButton.TextSize = 14
        Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 3)
        
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
        
        if #allTabs == 1 then
            selectTab(newPage, tabButton)
        end

        local ElementHandler = {}
        local currentParent = newPage -- Tracks the current parent (Page or GroupBox)

        local function createWrapper(height)
            local frame = Instance.new("Frame", currentParent) 
            frame.BackgroundColor3 = ELEMENT_COLOR
            frame.Size = UDim2.new(1, 0, 0, height or ELEMENT_HEIGHT)
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 3)
            
            return frame
        end
        
        -- =======================================================
        -- ELEMENT DEFINITIONS (FULL SET V9)
        -- =======================================================
        
        -- NEW: GroupBox
        function ElementHandler:GroupBox(boxLabel)
            local wrapper = Instance.new("Frame", newPage) 
            wrapper.Name = "GroupBox_" .. boxLabel:gsub(" ", "")
            wrapper.BackgroundColor3 = BASE_COLOR
            wrapper.BackgroundTransparency = 0.8
            wrapper.Size = UDim2.new(1, 0, 0, 50) 
            Instance.new("UICorner", wrapper).CornerRadius = UDim.new(0, MAIN_CORNER_RADIUS)
            
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
                local contentHeight = list.AbsoluteContentSize.Y + 35 
                wrapper.Size = UDim2.new(1, 0, 0, contentHeight)
                UpdateSize() -- Call the page's UpdateSize
            end
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
            
            local previousParent = currentParent
            currentParent = contentHolder
            
            return {
                Frame = wrapper,
                End = function()
                    currentParent = previousParent 
                    updateSize()
                end
            }
        end
        
        function ElementHandler:Toggle(togInfo, callback)
            local wrapper = createWrapper(ELEMENT_HEIGHT)
            local toggled = false
            
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
            switchBase.BackgroundColor3 = TEXT_COLOR_DARK 
            switchBase.Position = UDim2.new(1, -50, 0.5, 0)
            switchBase.AnchorPoint = Vector2.new(1, 0.5)
            switchBase.Size = UDim2.new(0, 40, 0, 20)
            Instance.new("UICorner", switchBase).CornerRadius = UDim.new(1, 0)
            
            local thumb = Instance.new("Frame", switchBase)
            thumb.BackgroundColor3 = BASE_COLOR
            thumb.Size = UDim2.new(0, 16, 0, 16)
            thumb.Position = UDim2.new(0.05, 0, 0.5, 0) 
            thumb.AnchorPoint = Vector2.new(0, 0.5)
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local function updateSwitch(state)
                toggled = state
                pcall(callback, toggled)

                local targetPos = toggled and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0.05, 0, 0.5, 0)
                local targetColor = toggled and ACCENT_COLOR or TEXT_COLOR_DARK

                TweenService:Create(thumb, TWEEN_INFO, {Position = targetPos}):Play()
                TweenService:Create(switchBase, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
            end

            switchBase.MouseButton1Click:Connect(function()
                updateSwitch(not toggled)
            end)
            
            updateSwitch(false)
            
            return {Frame = wrapper, SetValue = updateSwitch, GetValue = function() return toggled end}
        end
        
        function ElementHandler:Slider(sliderin, minvalue, maxvalue, callback)
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

            local sliderWidth = wrapper.AbsoluteSize.X * 0.96 
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
            
            return {Frame = wrapper, GetValue = function() return currentValue end}
        end

        function ElementHandler:Dropdown(dropdownLabel, options, callback)
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
            selectorButton.Size = UDim2.new(0.4, 0, 0, 30)
            selectorButton.Position = UDim2.new(0.98, -5, 0.5, 0)
            selectorButton.AnchorPoint = Vector2.new(1, 0.5)
            selectorButton.Font = Enum.Font.Gotham
            selectorButton.Text = selectedOption .. " ▼"
            selectorButton.TextColor3 = ACCENT_COLOR
            selectorButton.TextSize = 13
            Instance.new("UICorner", selectorButton).CornerRadius = UDim.new(0, 3)

            -- Options Frame (Parented to ScreenGui to render over everything)
            local optionsFrame = Instance.new("Frame", ScreenGui) 
            optionsFrame.BackgroundColor3 = ELEMENT_COLOR
            optionsFrame.Size = UDim2.new(0.4, 0, 0, 0)
            optionsFrame.AnchorPoint = Vector2.new(1, 0)
            optionsFrame.ClipsDescendants = true
            optionsFrame.ZIndex = 5
            Instance.new("UICorner", optionsFrame).CornerRadius = UDim.new(0, 3)
            optionsFrame.Visible = false
            
            local optionsListLayout = Instance.new("UIListLayout", optionsFrame)
            optionsListLayout.FillDirection = Enum.FillDirection.Vertical
            optionsListLayout.Padding = UDim.new(0, 1)

            local function closeDropdown()
                isDropOpen = false
                selectorButton.Text = selectedOption .. " ▼"
                TweenService:Create(optionsFrame, TWEEN_INFO, {Size = UDim2.new(optionsFrame.Size.X.Scale, optionsFrame.Size.X.Offset, 0, 0)}):Play()
                task.wait(TWEEN_INFO.Time)
                optionsFrame.Visible = false
            end
            
            selectorButton.MouseButton1Click:Connect(function()
                if isDropOpen then
                    closeDropdown()
                else
                    local absPos = selectorButton.AbsolutePosition
                    local absSize = selectorButton.AbsoluteSize
                    
                    optionsFrame.Position = UDim2.new(0, absPos.X + absSize.X, 0, absPos.Y + absSize.Y + 1)
                    optionsFrame.Size = UDim2.new(0, absSize.X, 0, 0)
                    optionsFrame.AnchorPoint = Vector2.new(1, 0)

                    isDropOpen = true
                    optionsFrame.Visible = true
                    selectorButton.Text = selectedOption .. " ▲"
                    local targetSize = math.min(#options * 25, 200) -- Cap dropdown height
                    TweenService:Create(optionsFrame, TWEEN_INFO, {Size = UDim2.new(0, absSize.X, 0, targetSize)}):Play()
                end
            end)

            for i, opt in ipairs(options) do
                local optionBtn = Instance.new("TextButton", optionsFrame)
                optionBtn.BackgroundColor3 = BASE_COLOR
                optionBtn.Size = UDim2.new(1, 0, 0, 25)
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.Text = opt
                optionBtn.TextColor3 = TEXT_COLOR
                optionBtn.TextSize = 13
                
                optionBtn.MouseButton1Click:Connect(function()
                    selectedOption = opt
                    pcall(callback, selectedOption)
                    closeDropdown()
                end)
            end
            
            pcall(callback, selectedOption)

            return {Frame = wrapper, GetValue = function() return selectedOption end}
        end

        function ElementHandler:TextBox(boxLabel, placeholder, callback)
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
            textBox.Size = UDim2.new(0.4, 0, 0, 30)
            textBox.Position = UDim2.new(0.98, -5, 0.5, 0)
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
            end)
            
            return {Frame = wrapper, GetValue = function() return textBox.Text end}
        end
        
        function ElementHandler:Keybind(keybindLabel, defaultKey, callback)
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
            keyButton.Position = UDim2.new(0.98, -5, 0.5, 0)
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

        -- PERFECTED: ColorPicker (Full HSV & Hex)
        function ElementHandler:ColorPicker(colorInfo, defaultColor, callback)
            colorInfo = colorInfo or "Color Picker"
            defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
            callback = callback or function() end

            local BASE_HEIGHT = 42 
            local EXPANDED_HEIGHT = 250 

            local colorFrame = Instance.new("Frame", currentParent) 
            local mainCorner = Instance.new("UICorner", colorFrame)
            local colorInfoLabel = Instance.new("TextLabel", colorFrame)
            local colorSwatchButton = Instance.new("TextButton", colorFrame)
            local swatchCorner = Instance.new("UICorner", colorSwatchButton)
            
            -- Base Frame Setup
            colorFrame.Name = "colorFrame"
            colorFrame.BackgroundColor3 = ELEMENT_COLOR
            colorFrame.ClipsDescendants = true 
            colorFrame.Size = UDim2.new(1, 0, 0, BASE_HEIGHT)
            mainCorner.CornerRadius = UDim.new(0, 3)

            -- Info Label
            colorInfoLabel.BackgroundTransparency = 1.000
            colorInfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
            colorInfoLabel.Size = UDim2.new(0, 200, 0, BASE_HEIGHT)
            colorInfoLabel.Font = Enum.Font.GothamSemibold
            colorInfoLabel.Text = colorInfo
            colorInfoLabel.TextColor3 = TEXT_COLOR
            colorInfoLabel.TextSize = 14.000
            colorInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

            -- Color Swatch Button (Acts as a display and a click trigger)
            colorSwatchButton.Name = "ColorSwatch"
            colorSwatchButton.BackgroundColor3 = defaultColor
            colorSwatchButton.Position = UDim2.new(0.98, -5, 0.5, 0)
            colorSwatchButton.AnchorPoint = Vector2.new(1, 0.5)
            colorSwatchButton.Size = UDim2.new(0, 30, 0, 30)
            colorSwatchButton.Text = ""
            colorSwatchButton.AutoButtonColor = false
            swatchCorner.CornerRadius = UDim.new(0, 3)

            -- Functional Color Picker Logic
            local isExpanded = false
            local currentColor = defaultColor
            local currentH, currentS, currentV = RGBToHSV(defaultColor.R, defaultColor.G, defaultColor.B)
            
            -- Color Square (Saturation/Value)
            local colorSquare = Instance.new("TextButton", colorFrame)
            colorSquare.Name = "ColorSquare"
            colorSquare.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1) 
            colorSquare.Size = UDim2.new(0, 180, 0, 180)
            colorSquare.Position = UDim2.new(0.02, 0, 0, 45)
            colorSquare.BackgroundTransparency = 0
            colorSquare.AutoButtonColor = false
            colorSquare.ZIndex = 2
            Instance.new("UICorner", colorSquare).CornerRadius = UDim.new(0, 3) 
            
            local valGradient = Instance.new("UIGradient", colorSquare)
            valGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))
            valGradient.Rotation = 90
            
            local satGradient = Instance.new("UIGradient", colorSquare)
            satGradient.Transparency = NumberSequence.new(0, 1) 

            local indicator = Instance.new("Frame", colorSquare)
            indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            indicator.Size = UDim2.new(0, 8, 0, 8)
            indicator.Position = UDim2.new(currentS, -4, 1-currentV, -4)
            indicator.AnchorPoint = Vector2.new(0, 0)
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", indicator).Color = BASE_COLOR 

            -- Hue Slider
            local hueSlider = Instance.new("TextButton", colorFrame)
            hueSlider.Name = "HueSlider"
            hueSlider.Size = UDim2.new(0, 20, 0, 180)
            hueSlider.Position = UDim2.new(0, 200, 0, 45)
            hueSlider.BackgroundColor3 = BASE_COLOR 
            hueSlider.AutoButtonColor = false
            hueSlider.ZIndex = 2
            Instance.new("UICorner", hueSlider).CornerRadius = UDim.new(0, 3)

            local hueGradient = Instance.new("UIGradient", hueSlider)
            hueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(0.166, Color3.fromHSV(0.166, 1, 1)),
                ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                ColorSequenceKeypoint.new(0.666, Color3.fromHSV(0.666, 1, 1)),
                ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
            })
            
            local hueIndicator = Instance.new("Frame", hueSlider)
            hueIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
            hueIndicator.Size = UDim2.new(1, 0, 0, 5)
            hueIndicator.Position = UDim2.new(0, 0, currentH, -2.5)
            Instance.new("UICorner", hueIndicator).CornerRadius = UDim.new(1, 0)

            -- Hex Code Display
            local hexLabel = Instance.new("TextLabel", colorFrame)
            hexLabel.BackgroundTransparency = 1
            hexLabel.Position = UDim2.new(0.02, 0, 0, 225)
            hexLabel.Size = UDim2.new(0, 180, 0, 25)
            hexLabel.Font = Enum.Font.Code
            hexLabel.Text = Color3ToHex(currentColor)
            hexLabel.TextColor3 = TEXT_COLOR
            hexLabel.TextSize = 14
            hexLabel.TextXAlignment = Enum.TextXAlignment.Left

            local function updateColor(h, s, v)
                currentH, currentS, currentV = h, s, v
                local r, g, b = HSVToRGB(h, s, v)
                local newColor = Color3.new(r, g, b)
                
                currentColor = newColor
                colorSwatchButton.BackgroundColor3 = newColor
                colorSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                
                indicator.Position = UDim2.new(currentS, -4, 1-currentV, -4)
                hueIndicator.Position = UDim2.new(0, 0, currentH, -2.5)
                hexLabel.Text = Color3ToHex(newColor)
                
                pcall(callback, newColor)
            end
            
            local mouse = Players.LocalPlayer:GetMouse()
            local hueDragging, svDragging = false, false
            
            local function handleDragging(element, isHue)
                element.MouseButton1Down:Connect(function()
                    if not isExpanded then return end
                    if isHue then hueDragging = true else svDragging = true end

                    local conn = mouse.Move:Connect(function()
                        if isHue and hueDragging then
                            local relativeY = math.clamp(mouse.Y - element.AbsolutePosition.Y, 0, element.AbsoluteSize.Y)
                            local newH = relativeY / element.AbsoluteSize.Y
                            updateColor(newH, currentS, currentV)
                        elseif (not isHue) and svDragging then
                            local relativeX = math.clamp(mouse.X - element.AbsolutePosition.X, 0, element.AbsoluteSize.X)
                            local relativeY = math.clamp(mouse.Y - element.AbsolutePosition.Y, 0, element.AbsoluteSize.Y)
                            
                            local s = relativeX / element.AbsoluteSize.X
                            local v = 1 - (relativeY / element.AbsoluteSize.Y)
                            
                            updateColor(currentH, s, v)
                        end
                    end)
                    game:GetService("UserInputService").InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if isHue then hueDragging = false else svDragging = false end
                            conn:Disconnect()
                        end
                    end)
                    
                    if isHue then
                        local relativeY = math.clamp(mouse.Y - element.AbsolutePosition.Y, 0, element.AbsoluteSize.Y)
                        local newH = relativeY / element.AbsoluteSize.Y
                        updateColor(newH, currentS, currentV)
                    else
                        local relativeX = math.clamp(mouse.X - element.AbsolutePosition.X, 0, element.AbsoluteSize.X)
                        local relativeY = math.clamp(mouse.Y - element.AbsolutePosition.Y, 0, element.AbsoluteSize.Y)
                        local s = relativeX / element.AbsoluteSize.X
                        local v = 1 - (relativeY / element.AbsoluteSize.Y)
                        updateColor(currentH, s, v)
                    end
                end)
            end
            
            handleDragging(hueSlider, true)
            handleDragging(colorSquare, false)
            
            -- Expansion/Collapse Logic
            colorSwatchButton.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                
                local targetSize = isExpanded and UDim2.new(1, 0, 0, EXPANDED_HEIGHT) or UDim2.new(1, 0, 0, BASE_HEIGHT)
                
                TweenService:Create(colorFrame, TWEEN_INFO, {Size = targetSize}):Play()
                
                colorSquare.Visible = isExpanded
                hueSlider.Visible = isExpanded
                hexLabel.Visible = isExpanded
                
                task.wait(TWEEN_INFO.Time/2)
                UpdateSize()
            end)
            
            -- Initial state setup
            updateColor(currentH, currentS, currentV) 
            colorSquare.Visible = false
            hueSlider.Visible = false
            hexLabel.Visible = false
            
            pcall(callback, defaultColor)

            return function(newColor) -- Public Setter function
                local r, g, b = newColor.R, newColor.G, newColor.B
                local h, s, v = RGBToHSV(r, g, b)
                updateColor(h, s, v)
            end
        end
        
        return ElementHandler
    end
    
    return SectionHandler
end 


return SlayLib
