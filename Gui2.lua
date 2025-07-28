-- ShadowCore Library v1.0
local ShadowCore = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- สร้างหน้าจอ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowCoreUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- Theme settings
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(255, 80, 80),
    Border = Color3.fromRGB(40, 40, 50),
    Font = Enum.Font.GothamSemibold
}

-- ฟังก์ชันสร้างหน้าต่างหลัก
function ShadowCore:CreateWindow(title)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 420, 0, 320)
    Main.Position = UDim2.new(0.5, -210, 0.5, -160)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderColor3 = Theme.Accent
    Main.BorderSizePixel = 2
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Text = "⚡ " .. title
    Title.Font = Theme.Font
    Title.TextSize = 20
    Title.TextColor3 = Theme.Accent
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -10, 0, 30)
    Title.Position = UDim2.new(0, 5, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Main

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 1, -40)
    Container.Position = UDim2.new(0, 5, 0, 35)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local UIList = Instance.new("UIListLayout", Container)
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local api = {}

    function api:Toggle(text, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundColor3 = Theme.Border
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Container

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Text = "☐ " .. text
        ToggleBtn.Font = Theme.Font
        ToggleBtn.TextSize = 16
        ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
        ToggleBtn.BackgroundTransparency = 1
        ToggleBtn.Size = UDim2.new(1, -10, 1, 0)
        ToggleBtn.Position = UDim2.new(0, 5, 0, 0)
        ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ToggleBtn.Parent = ToggleFrame

        local toggled = false

        ToggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            ToggleBtn.Text = (toggled and "☑ " or "☐ ") .. text
            if callback then
                pcall(callback, toggled)
            end
        end)
    end

    function api:Dropdown(name, items, callback)
        local DropFrame = Instance.new("Frame")
        DropFrame.Size = UDim2.new(1, 0, 0, 30)
        DropFrame.BackgroundColor3 = Theme.Border
        DropFrame.BorderSizePixel = 0
        DropFrame.Parent = Container

        local DropBtn = Instance.new("TextButton")
        DropBtn.Text = "⏷ " .. name
        DropBtn.Font = Theme.Font
        DropBtn.TextSize = 16
        DropBtn.TextColor3 = Color3.new(1, 1, 1)
        DropBtn.BackgroundTransparency = 1
        DropBtn.Size = UDim2.new(1, -10, 1, 0)
        DropBtn.Position = UDim2.new(0, 5, 0, 0)
        DropBtn.TextXAlignment = Enum.TextXAlignment.Left
        DropBtn.Parent = DropFrame

        local Opened = false
        local Options = {}

        local function ToggleDropdown()
            if Opened then
                for _, opt in ipairs(Options) do
                    opt:Destroy()
                end
                Options = {}
                DropFrame.Size = UDim2.new(1, 0, 0, 30)
                DropBtn.Text = "⏷ " .. name
                Opened = false
            else
                for _, item in ipairs(items) do
                    local Option = Instance.new("TextButton")
                    Option.Size = UDim2.new(1, -20, 0, 25)
                    Option.Position = UDim2.new(0, 10, 0, 30 + #Options * 25)
                    Option.Text = "↳ " .. item
                    Option.TextSize = 14
                    Option.Font = Theme.Font
                    Option.TextColor3 = Color3.new(1, 1, 1)
                    Option.BackgroundColor3 = Theme.Background
                    Option.BorderColor3 = Theme.Accent
                    Option.Parent = DropFrame
                    table.insert(Options, Option)

                    Option.MouseButton1Click:Connect(function()
                        DropBtn.Text = "⏷ " .. item
                        callback(item)
                        ToggleDropdown()
                    end)
                end
                DropFrame.Size = UDim2.new(1, 0, 0, 30 + #Options * 25)
                DropBtn.Text = "⏶ " .. name
                Opened = true
            end
        end

        DropBtn.MouseButton1Click:Connect(ToggleDropdown)
    end

    return api
end

return ShadowCore