--[[
  ROBLOX GUI LIBRARY - FROSTED GLASS THEME
  Features: Frosted background, multi-tabs, custom controls (button, toggle, dropdown, slider), user info.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local UILibrary = {}
UILibrary.__index = UILibrary

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(30, 30, 35), -- Dark base
    FrostedColor = Color3.fromRGB(50, 50, 55), -- Lighter gray for glass effect
    Accent = Color3.fromRGB(100, 100, 110), -- Secondary accent
    Text = Color3.fromRGB(220, 220, 225), -- Main text
    TextSub = Color3.fromRGB(180, 180, 185), -- Sub text
    Interactive = Color3.fromRGB(70, 70, 75), -- Hover/Interact color
    InteractiveOn = Color3.fromRGB(130, 130, 140), -- Toggle ON color
}

-- Utility: Apply Rounded Corners
local function applyUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

-- Utility: Create Frosted Glass Effect (Using Neon Part method as Blur effect is camera-only)
local function createFrostedGlass(parent)
    local folder = Instance.new("Folder")
    folder.Name = "FrostedGlass_Elements"
    folder.Parent = parent

    -- Basic UI background (will use semi-transparent frame for color)
    local bgFrame = Instance.new("Frame")
    bgFrame.Name = "GlassBackground"
    bgFrame.Size = UDim2.fromScale(1, 1)
    bgFrame.BackgroundColor3 = Theme.Background
    bgFrame.BackgroundTransparency = 0.5 -- Adjust translucency
    bgFrame.ZIndex = -1
    bgFrame.Parent = parent
    applyUICorner(bgFrame, 8)

    -- In-experience blurring requires complex ViewportFrame setup or Neon Parts trick.
    -- For simplicity in a 2D GUI, we stick with a translucent theme that MIMICS frosted glass visually.
    return bgFrame
end


function UILibrary.new(title)
    local self = setmetatable({}, UILibrary)

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title .. "_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(600, 400) -- PC size, will adjust for mobile
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    applyUICorner(mainFrame, 8)
    self.MainFrame = mainFrame

    -- Apply Frosted Effect
    createFrostedGlass(mainFrame)

    -- Top Bar (Drag handle)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Theme.Accent
    topBar.BackgroundTransparency = 0.8
    topBar.Parent = mainFrame
    applyUICorner(topBar, 8)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.fromOffset(10, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansSemibold
    titleLabel.Parent = topBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.TextColor3 = Theme.Text
    closeButton.TextSize = 20
    closeButton.Size = UDim2.fromOffset(30, 30)
    closeButton.Position = UDim2.new(1, -5, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
    closeButton.BackgroundTransparency = 0.2
    closeButton.Parent = topBar
    applyUICorner(closeButton, 15)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Make MainFrame Draggable
    local dragging, dragInput, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)


    -- Side Bar (Tabs)
    local sideBar = Instance.new("ScrollingFrame")
    sideBar.Name = "SideBar"
    sideBar.Size = UDim2.new(0, 150, 1, -40)
    sideBar.Position = UDim2.fromOffset(0, 40)
    sideBar.BackgroundColor3 = Theme.FrostedColor
    sideBar.BackgroundTransparency = 0.7
    sideBar.BorderSizePixel = 0
    sideBar.ScrollBarThickness = 2
    sideBar.Parent = mainFrame
    self.SideBar = sideBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = sideBar

    -- Tab Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -40)
    contentContainer.Position = UDim2.fromOffset(150, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    self.ContentContainer = contentContainer


    -- Mobile Scaling Adaptation
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        mainFrame.Size = UDim2.fromScale(0.9, 0.8) -- Use screen percentage
        sideBar.Size = UDim2.new(0, 100, 1, -40) -- Narrower sidebar
        contentContainer.Size = UDim2.new(1, -100, 1, -40)
        contentContainer.Position = UDim2.fromOffset(100, 40)
    end

    -- User Status Bar
    local userStatus = Instance.new("Frame")
    userStatus.Name = "UserStatus"
    userStatus.Size = UDim2.new(1, 0, 0, 50)
    userStatus.Position = UDim2.new(0, 0, 1, -50)
    userStatus.BackgroundColor3 = Theme.FrostedColor
    userStatus.BackgroundTransparency = 0.5
    userStatus.BorderSizePixel = 0
    userStatus.Parent = sideBar

    local userAvatar = Instance.new("ImageLabel")
    userAvatar.Name = "Avatar"
    userAvatar.Size = UDim2.fromOffset(40, 40)
    userAvatar.Position = UDim2.fromOffset(5, 5)
    userAvatar.BackgroundTransparency = 1
    userAvatar.Parent = userStatus
    applyUICorner(userAvatar, 20)

    -- Fetch Avatar
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = game:GetService("Players"):GetThumbnailAsync(userId, thumbType, thumbSize)
    if isReady then
        userAvatar.Image = content
    end

    local userName = Instance.new("TextLabel")
    userName.Name = "Username"
    userName.Text = LocalPlayer.Name
    userName.TextColor3 = Theme.Text
    userName.TextSize = 14
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Size = UDim2.new(1, -55, 1, 0)
    userName.Position = UDim2.fromOffset(50, 0)
    userName.BackgroundTransparency = 1
    userName.Font = Enum.Font.SourceSans
    userName.Parent = userStatus


    self.Tabs = {}
    self.CurrentTab = nil

    return self
end

-- Function to create a new Tab
function UILibrary:CreateTab(name)
    local tab = {}
    tab.Library = self

    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "_TabButton"
    tabButton.Text = name
    tabButton.TextColor3 = Theme.TextSub
    tabButton.TextSize = 16
    tabButton.Size = UDim2.new(0.9, 0, 0, 30)
    tabButton.BackgroundColor3 = Theme.Interactive
    tabButton.BackgroundTransparency = 0.8
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Parent = self.SideBar
    applyUICorner(tabButton, 4)

    -- Tab Content ScrollFrame
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "_Content"
    tabContent.Size = UDim2.fromScale(1, 1)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Theme.Accent
    tabContent.Visible = false
    tabContent.Parent = self.ContentContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent

    tab.Content = tabContent

    -- Select Tab Logic
    local function selectTab()
        if self.CurrentTab then
            self.CurrentTab.Content.Visible = false
            self.CurrentTab.Button.TextColor3 = Theme.TextSub
            self.CurrentTab.Button.BackgroundTransparency = 0.8
        end
        self.CurrentTab = tab
        tabContent.Visible = true
        tabButton.TextColor3 = Theme.Text
        tabButton.BackgroundTransparency = 0.2 -- Highlight
    end
    tab.Button = tabButton

    tabButton.MouseButton1Click:Connect(selectTab)

    -- Select first tab by default
    if not self.CurrentTab then
        selectTab()
    end

    -- Tab Functions for creating elements
    function tab:CreateButton(text, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "_Button"
        button.Text = text
        button.TextColor3 = Theme.Text
        button.TextSize = 14
        button.Size = UDim2.new(0.95, 0, 0, 30)
        button.BackgroundColor3 = Theme.Interactive
        button.Font = Enum.Font.SourceSans
        button.Parent = tabContent
        applyUICorner(button, 4)

        button.MouseButton1Click:Connect(function()
            -- Click animation
            local tween = TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent})
            tween:Play()
            tween.Completed:Wait()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Interactive}):Play()

            if callback then callback() end
        end)
    end

    function tab:CreateToggle(text, default, callback)
        local toggle = {State = default or false}

        local container = Instance.new("Frame")
        container.Name = text .. "_Toggle"
        container.Size = UDim2.new(0.95, 0, 0, 35)
        container.BackgroundTransparency = 1
        container.Parent = tabContent

        local label = Instance.new("TextLabel")
        label.Text = text
        label.TextColor3 = Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.fromOffset(5, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSans
        label.Parent = container

        local button = Instance.new("TextButton")
        button.Name = "ToggleButton"
        button.Text = ""
        button.Size = UDim2.fromOffset(50, 25)
        button.Position = UDim2.new(1, -55, 0.5, 0)
        button.AnchorPoint = Vector2.new(0, 0.5)
        button.BackgroundColor3 = toggle.State and Theme.InteractiveOn or Theme.Interactive
        button.Parent = container
        applyUICorner(button, 12)

        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.fromOffset(21, 21)
        indicator.Position = toggle.State and UDim2.fromOffset(26, 2) or UDim2.fromOffset(3, 2)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.Parent = button
        applyUICorner(indicator, 10)

        local function updateToggle()
            local targetPos = toggle.State and UDim2.fromOffset(26, 2) or UDim2.fromOffset(3, 2)
            local targetColor = toggle.State and Theme.InteractiveOn or Theme.Interactive
            TweenService:Create(indicator, TweenInfo.new(0.2), {Position = targetPos}):Play()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            if callback then callback(toggle.State) end
        end

        button.MouseButton1Click:Connect(function()
            toggle.State = not toggle.State
            updateToggle()
        end)

        return toggle
    end

    function tab:CreateDropdown(text, options, callback)
        local dropdown = {Options = options or {}, Selected = nil, Open = false}

        local container = Instance.new("Frame")
        container.Name = text .. "_Dropdown"
        container.Size = UDim2.new(0.95, 0, 0, 35)
        container.BackgroundTransparency = 1
        container.ClipsDescendants = false -- Important for dropdown list
        container.Parent = tabContent

        local button = Instance.new("TextButton")
        button.Name = "DropdownButton"
        button.Text = text .. ": " .. (options[1] or "None")
        button.TextColor3 = Theme.Text
        button.TextSize = 14
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundColor3 = Theme.Interactive
        button.Font = Enum.Font.SourceSans
        button.Position = UDim2.fromOffset(5, 0)
        button.Parent = container
        applyUICorner(button, 4)
        dropdown.Selected = options[1]


        local listContainer = Instance.new("ScrollingFrame")
        listContainer.Name = "List"
        listContainer.Size = UDim2.new(1, 0, 0, 0) -- Hidden initially
        listContainer.Position = UDim2.new(0, 0, 1, 3)
        listContainer.BackgroundColor3 = Theme.Background
        listContainer.BackgroundTransparency = 0.1
        listContainer.BorderSizePixel = 0
        listContainer.ScrollBarThickness = 2
        listContainer.Visible = false
        listContainer.Parent = button
        applyUICorner(listContainer, 4)

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = listContainer

        local function toggleDropdown()
            dropdown.Open = not dropdown.Open
            listContainer.Visible = dropdown.Open
            local targetHeight = dropdown.Open and math.min(#options * 25 + 5, 100) or 0
            TweenService:Create(listContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        end

        button.MouseButton1Click:Connect(toggleDropdown)

        for _, option in ipairs(options) do
            local optButton = Instance.new("TextButton")
            optButton.Name = option .. "_Option"
            optButton.Text = option
            optButton.TextColor3 = Theme.TextSub
            optButton.TextSize = 13
            optButton.Size = UDim2.new(0.95, 0, 0, 20)
            optButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            optButton.BackgroundTransparency = 1
            optButton.Font = Enum.Font.SourceSans
            optButton.Parent = listContainer

            optButton.MouseButton1Click:Connect(function()
                dropdown.Selected = option
                button.Text = text .. ": " .. option
                toggleDropdown()
                if callback then callback(option) end
            end)
        end

        return dropdown
    end

    function tab:CreateSlider(text, min, max, default, callback)
        local slider = {Value = default or min}

        local container = Instance.new("Frame")
        container.Name = text .. "_Slider"
        container.Size = UDim2.new(0.95, 0, 0, 50)
        container.BackgroundTransparency = 1
        container.Parent = tabContent

        local label = Instance.new("TextLabel")
        label.Text = text .. ": " .. slider.Value
        label.TextColor3 = Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.fromOffset(5, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSans
        label.Parent = container

        local bar = Instance.new("Frame")
        bar.Name = "Bar"
        bar.Size = UDim2.new(1, -10, 0, 10)
        bar.Position = UDim2.fromOffset(5, 25)
        bar.BackgroundColor3 = Theme.Interactive
        bar.Parent = container
        applyUICorner(bar, 5)

        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.fromScale((slider.Value - min) / (max - min), 1)
        fill.BackgroundColor3 = Theme.InteractiveOn
        fill.Parent = bar
        applyUICorner(fill, 5)

        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.Size = UDim2.fromOffset(16, 16)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = bar
        applyUICorner(knob, 8)


        local dragging = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            slider.Value = math.floor(min + (pos * (max - min)))
            label.Text = text .. ": " .. slider.Value
            fill.Size = UDim2.fromScale(pos, 1)
            knob.Position = UDim2.new(pos, 0, 0.5, 0)
            if callback then callback(slider.Value) end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)

        return slider
    end

    table.insert(self.Tabs, tab)
    return tab
end

-- Function to clean up UI (if needed)
function UILibrary:Destroy()
    if self.MainFrame and self.MainFrame.Parent then
        self.MainFrame.Parent:Destroy() -- Destroys ScreenGui
    end
end


return UILibrary
