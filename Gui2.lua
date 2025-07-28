--// ShadowCoreUI - Advanced Roblox UI Library
-- Author: ChatGPT x SlayHub Concept
-- Features: Auto layout, draggable windows, collapsible UI, categories, scroll support, styled components

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local ShadowCoreUI = {}
ShadowCoreUI.__index = ShadowCoreUI

--// Helper
local function createInstance(class, props)
    local inst = Instance.new(class)
    for i,v in pairs(props) do
        inst[i] = v
    end
    return inst
end

--// Base Styles
local Theme = {
    Background = Color3.fromRGB(25,25,25),
    Accent = Color3.fromRGB(85, 170, 255),
    Text = Color3.new(1,1,1),
    Secondary = Color3.fromRGB(40,40,40),
    Font = Enum.Font.Gotham
}

--// Create Main Window
function ShadowCoreUI:CreateWindow(title)
    title = title or "SlayHub"

    local screenGui = createInstance("ScreenGui", {
        Name = "ShadowCoreUI",
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    local mainFrame = createInstance("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, 450, 0, 400),
        Position = UDim2.new(0.5, -225, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = screenGui
    })

    local topbar = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Theme.Secondary,
        Text = title,
        Font = Theme.Font,
        TextColor3 = Theme.Text,
        TextSize = 18,
        Parent = mainFrame
    })

    -- Dragging
    local dragging, offset
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = input.Position - mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            mainFrame.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
        end
    end)

    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Collapse Button
    local toggleButton = createInstance("TextButton", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = "_",
        Font = Theme.Font,
        TextColor3 = Theme.Text,
        TextSize = 20,
        Parent = topbar
    })

    local contentFrame = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = mainFrame
    })

    createInstance("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = contentFrame
    })

    local collapsed = false
    toggleButton.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        contentFrame.Visible = not collapsed
    end)

    local window = setmetatable({}, ShadowCoreUI)
    window.Container = contentFrame
    return window
end

--// Category
function ShadowCoreUI:CreateCategory(title)
    local section = createInstance("Frame", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.Container
    })

    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Theme.Font,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Parent = section
    })

    return section
end

--// Toggle
function ShadowCoreUI:Toggle(name, callback)
    local button = createInstance("TextButton", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Text = name .. ": OFF",
        Font = Theme.Font,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Parent = self.Container
    })

    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = name .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

--// Button
function ShadowCoreUI:Button(name, callback)
    local btn = createInstance("TextButton", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = name,
        Font = Theme.Font,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Parent = self.Container
    })
    btn.MouseButton1Click:Connect(callback)
end

--// Dropdown
function ShadowCoreUI:Dropdown(title, items, callback)
    local box = createInstance("Frame", {
        Size = UDim2.new(1, -10, 0, 30 + #items * 28),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.Container
    })

    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = title,
        Font = Theme.Font,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Parent = box
    })

    for _, item in pairs(items) do
        local option = createInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 30 + ((_ - 1) * 28)),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Text = tostring(item),
            Font = Theme.Font,
            TextColor3 = Theme.Text,
            TextSize = 15,
            Parent = box
        })
        option.MouseButton1Click:Connect(function()
            callback(item)
        end)
    end
end

return ShadowCoreUI
