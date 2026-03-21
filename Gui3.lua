--[[
  ROBLOX GUI LIBRARY - "DARK GLASS" THEME (V2)
  This version mimics the visual structure of the provided image (Central header icon, specific colors).
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local UILibrary = {}
UILibrary.__index = UILibrary

-- --- THEME CONFIGURATION --- (Based on the image)
local Theme = {
    -- Main background (Simulated dark glass with a hint of purple/blue)
    Background = Color3.fromRGB(35, 35, 40), 
    
    -- Lighter gray for interactive elements
    Interactive = Color3.fromRGB(55, 55, 60), 
    InteractiveOn = Color3.fromRGB(110, 110, 120), -- For toggles
    
    -- Text colors
    Text = Color3.fromRGB(220, 220, 225),
    TextSub = Color3.fromRGB(170, 170, 175),
    
    -- Accent colors (Based on the image)
    TitleTextColor = Color3.fromRGB(180, 180, 180),
    IconBorderColor = Color3.fromRGB(0, 160, 255), -- Blue border for icon
    CloseButtonColor = Color3.fromRGB(200, 50, 50), -- Red
    
    -- User Info Colors
    UserStatusBg = Color3.fromRGB(45, 45, 50),
    UserNameColor = Color3.fromRGB(240, 240, 240),
}

-- --- INTERNAL UTIL FUNCTIONS ---

local function applyUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

-- Function to create the frosted glass effect simulation
local function createFrostedBackground(parent)
    local bgFrame = Instance.new("Frame")
    bgFrame.Name = "DarkGlassEffect"
    bgFrame.Size = UDim2.fromScale(1, 1)
    bgFrame.BackgroundColor3 = Theme.Background
    bgFrame.BackgroundTransparency = 0.5 -- Adjusted for translucency
    bgFrame.ZIndex = -1 -- Place below all other UI
    bgFrame.Parent = parent
    applyUICorner(bgFrame, 10)
    return bgFrame
end

-- --- MAIN LIBRARY OBJECT CREATION ---

function UILibrary.new(title)
    local self = setmetatable({}, UILibrary)

    -- 1. Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkGlassMenu_V2"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui = screenGui

    -- 2. Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(600, 420) -- Slightly taller for new layout
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- For shadow
    mainFrame.BackgroundTransparency = 1 -- Hide parent color, use effect frame
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    applyUICorner(mainFrame, 10)
    self.MainFrame = mainFrame

    -- 3. Apply Background Effect Frame (Translucent)
    createFrostedBackground(mainFrame)

    -- --- HEADER / TOP BAR AREA (Mimicking the image) ---

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -20, 0, 40) -- Padding 10 on each side
    header.Position = UDim2.fromOffset(10, 5)
    header.BackgroundTransparency = 1
    header.Parent = mainFrame

    -- Title Label (Right aligned based on image placement)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Text = title or "Dark Glass Menu"
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Theme.TitleTextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Right
    titleLabel.Size = UDim2.new(1, -100, 1, 0) -- Leave space for close button
    titleLabel.Position = UDim2.fromOffset(0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansSemibold
    titleLabel.Parent = header

    -- Central Icon
    local iconFrame = Instance.new("ImageLabel")
    iconFrame.Name = "CentralIcon"
    iconFrame.Size = UDim2.fromOffset(45, 45) -- Slightly larger for presence
    iconFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- PERFECT CENTER
    iconFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    iconFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    iconFrame.Image = "rbxassetid://13160451101" -- Default ninja icon (replace if needed)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = mainFrame
    applyUICorner(iconFrame, 22.5) -- Make circle

    -- Blue border around the icon
    local iconBorder = Instance.new("UIStroke")
    iconBorder.Color = Theme.IconBorderColor
    iconBorder.Thickness = 2
    iconBorder.Parent = iconFrame

    -- Close Button (Red)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Size = UDim2.fromOffset(28, 28)
    closeButton.Position = UDim2.new(1, -5, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Theme.CloseButtonColor
    closeButton.Parent = header
    applyUICorner(closeButton, 14) -- Circle

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)


    -- --- SIDE BAR AND CONTENT CONTAINER ---

    -- The dividing vertical line
    local dividerLine = Instance.new("Frame")
    dividerLine.Name = "Divider"
    dividerLine.Size = UDim2.new(0, 1, 1, -60) -- Leave space for header/userstatus
    dividerLine.Position = UDim2.fromOffset(150, 50)
    dividerLine.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    dividerLine.BackgroundTransparency = 0.8
    dividerLine.Parent = mainFrame

    -- Side Bar for Tabs
    local sideBar = Instance.new("ScrollingFrame")
    sideBar.Name = "SideBar"
    sideBar.Size = UDim2.new(0, 140, 1, -110) -- Leave space for header and user info
    sideBar.Position = UDim2.fromOffset(10, 50)
    sideBar.BackgroundTransparency = 1
    sideBar.ScrollBarThickness = 0 -- Hide scrollbar for clean look
    sideBar.Parent = mainFrame
    self.SideBar = sideBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = sideBar

    -- Content Container (Right Side)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -160, 1, -60)
    contentContainer.Position = UDim2.fromOffset(160, 50)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    self.ContentContainer = contentContainer


    -- --- USER STATUS AREA (Bottom of SideBar) ---

    local userStatusFrame = Instance.new("Frame")
    userStatusFrame.Name = "UserStatusFrame"
    userStatusFrame.Size = UDim2.new(0, 140, 0, 50)
    userStatusFrame.Position = UDim2.new(0, 10, 1, -60)
    userStatusFrame.BackgroundColor3 = Theme.UserStatusBg
    userStatusFrame.BorderSizePixel = 0
    userStatusFrame.ClipsDescendants = true
    userStatusFrame.Parent = mainFrame
    applyUICorner(userStatusFrame, 10)

    local userAvatar = Instance.new("ImageLabel")
    userAvatar.Name = "Avatar"
    userAvatar.Size = UDim2.fromOffset(40, 40)
    userAvatar.Position = UDim2.fromOffset(5, 5)
    userAvatar.BackgroundColor3 = Color3.fromRGB(0,0,0)
    userAvatar.BackgroundTransparency = 1
    userAvatar.Parent = userStatusFrame
    applyUICorner(userAvatar, 20) -- Circle

    -- Fetch Avatar Thumbnail
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
    userName.TextColor3 = Theme.UserNameColor
    userName.TextSize = 14
    userName.TextTruncate = Enum.TextTruncate.AtEnd -- For long names
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Size = UDim2.new(1, -55, 1, 0)
    userName.Position = UDim2.fromOffset(50, 0)
    userName.BackgroundTransparency = 1
    userName.Font = Enum.Font.SourceSans
    userName.Parent = userStatusFrame

    self.Tabs = {}
    self.CurrentTab = nil

    return self
end

-- --- TAB AND ELEMENT CREATION METHODS (Same logic as V1, just style updates) ---

function UILibrary:CreateTab(name)
    local tab = {}
    tab.Library = self

    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "_TabButton"
    tabButton.Text = name
    tabButton.TextColor3 = Theme.TextSub
    tabButton.TextSize = 14
    tabButton.Size = UDim2.new(1, 0, 0, 30)
    tabButton.BackgroundColor3 = Theme.Interactive
    tabButton.BackgroundTransparency = 1 -- Default to transparent
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Parent = self.SideBar
    applyUICorner(tabButton, 6)

    -- Tab Content ScrollFrame
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "_Content"
    tabContent.Size = UDim2.fromScale(1, 1)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 2
    tabContent.ScrollBarImageColor3 = Theme.Interactive
    tabContent.Visible = false -- Hidden initially
    tabContent.Parent = self.ContentContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent

    tab.Content = tabContent
    tab.Button = tabButton

    -- Select Tab Logic
    local function selectTab()
        if self.CurrentTab then
            self.CurrentTab.Content.Visible = false
            self.CurrentTab.Button.TextColor3 = Theme.TextSub
            self.CurrentTab.Button.BackgroundTransparency = 1
        end
        self.CurrentTab = tab
        tabContent.Visible = true
        tabButton.TextColor3 = Theme.Text
        tabButton.BackgroundTransparency = 0.8 -- Highlight
    end

    tabButton.MouseButton1Click:Connect(selectTab)

    -- Select first tab by default
    if not self.CurrentTab then
        selectTab()
    end

    -- --- ELEMENT CREATION --- (CreateButton, CreateToggle, CreateSlider, CreateDropdown remain the same as V1)

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
        applyUICorner(button, 6)

        button.MouseButton1Click:Connect(function()
            -- Click animation
            local tween = TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.InteractiveOn})
            tween:Play()
            tween.Completed:Wait()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Interactive}):Play()

            if callback then callback() end
        end)
    end

    -- (Add CreateToggle, CreateSlider, CreateDropdown functions from V1 here if you need them. 
    --  They are omitted for length, as they work exactly the same way but with updated theme colors.)

    table.insert(self.Tabs, tab)
    return tab
end

return UILibrary
