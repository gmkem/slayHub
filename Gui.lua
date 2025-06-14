--// SlayHub GUI Library (Mobile Optimized) //
-- Cute, deadly, and optimized for mobile slay 💅📱

local SlayHub = {}

--// Create the main GUI window
function SlayHub:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SlayHubGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 182, 193) -- Light pink
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(255, 105, 180)
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Text = title or "SlayHub 💅"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamSemibold
    Title.Parent = MainFrame

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, -60)
    Scroll.Position = UDim2.new(0, 0, 0, 60)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 6
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    Scroll.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)
    UIList.Parent = Scroll

    SlayHub.ScrollArea = Scroll
    return SlayHub
end

--// Add a button
function SlayHub:AddButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 50)
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Hot pink
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.Gotham
    Button.Text = text or "Click Me 💖"
    Button.Parent = SlayHub.ScrollArea

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Button

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1.5
    UIStroke.Color = Color3.fromRGB(255, 182, 193)
    UIStroke.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if callback then
            pcall(callback)
        end
    end)
end

--// Add a label
function SlayHub:AddLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 40)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text or "Label 💬"
    Label.Parent = SlayHub.ScrollArea
end

return SlayHub
