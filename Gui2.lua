local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- UI Base
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SlayHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 350)
Main.Position = UDim2.new(0.5, -250, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
Main.BorderSizePixel = 0
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Active = true
Main.Draggable = true
Main.Name = "MainUI"

-- TitleBar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(140, 200, 255)
TitleBar.Name = "TitleBar"

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "SlayHub ☁️"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- Toggle UI Visibility Button
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 30)
ToggleBtn.Position = UDim2.new(0, 20, 0, 100)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(140, 200, 255)
ToggleBtn.Text = "☁ Show/Hide"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.BorderSizePixel = 0

ToggleBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

-- Tab Buttons Holder
local TabList = Instance.new("Frame", Main)
TabList.Size = UDim2.new(0, 120, 1, -36)
TabList.Position = UDim2.new(0, 0, 0, 36)
TabList.BackgroundColor3 = Color3.fromRGB(180, 220, 255)

-- Tab Content Holder
local ContentFrame = Instance.new("Frame", Main)
ContentFrame.Size = UDim2.new(1, -120, 1, -36)
ContentFrame.Position = UDim2.new(0, 120, 0, 36)
ContentFrame.BackgroundColor3 = Color3.fromRGB(235, 245, 255)
ContentFrame.Name = "Content"

-- Module Table
local SlayHub = {}
local Tabs = {}

function SlayHub:CreateTab(tabName)
	local tabBtn = Instance.new("TextButton", TabList)
	tabBtn.Size = UDim2.new(1, 0, 0, 30)
	tabBtn.Text = tabName
	tabBtn.Font = Enum.Font.Gotham
	tabBtn.TextColor3 = Color3.new(0.2, 0.2, 0.2)
	tabBtn.BackgroundColor3 = Color3.fromRGB(170, 210, 255)
	tabBtn.BorderSizePixel = 0

	local content = Instance.new("ScrollingFrame", ContentFrame)
	content.Visible = false
	content.Size = UDim2.new(1, 0, 1, 0)
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.ScrollBarThickness = 6
	content.Name = tabName
	content.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout", content)
	layout.Padding = UDim.new(0, 6)

	tabBtn.MouseButton1Click:Connect(function()
		for _, v in pairs(ContentFrame:GetChildren()) do
			if v:IsA("ScrollingFrame") then v.Visible = false end
		end
		content.Visible = true
	end)

	local tab = {}

	function tab:AddButton(text, callback)
		local btn = Instance.new("TextButton", content)
		btn.Size = UDim2.new(1, -12, 0, 30)
		btn.Text = text
		btn.Font = Enum.Font.Gotham
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
		btn.BorderSizePixel = 0
		btn.MouseButton1Click:Connect(callback)
	end

	function tab:AddToggle(text, default, callback)
		local state = default
		local toggle = Instance.new("TextButton", content)
		toggle.Size = UDim2.new(1, -12, 0, 30)
		toggle.Text = text .. ": " .. (state and "ON" or "OFF")
		toggle.Font = Enum.Font.Gotham
		toggle.TextColor3 = Color3.new(1, 1, 1)
		toggle.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
		toggle.BorderSizePixel = 0

		toggle.MouseButton1Click:Connect(function()
			state = not state
			toggle.Text = text .. ": " .. (state and "ON" or "OFF")
			callback(state)
		end)
	end

	function tab:AddDropdown(title, options, callback)
		local dropdownOpen = false
		local container = Instance.new("Frame", content)
		container.Size = UDim2.new(1, -12, 0, 30)
		container.BackgroundColor3 = Color3.fromRGB(100, 170, 255)

		local main = Instance.new("TextButton", container)
		main.Size = UDim2.new(1, 0, 1, 0)
		main.Text = title
		main.Font = Enum.Font.Gotham
		main.TextColor3 = Color3.new(1, 1, 1)
		main.BackgroundTransparency = 1

		local dropFrame = Instance.new("Frame", container)
		dropFrame.Size = UDim2.new(1, 0, 0, #options * 25)
		dropFrame.Position = UDim2.new(0, 0, 1, 0)
		dropFrame.Visible = false
		dropFrame.BackgroundColor3 = Color3.fromRGB(130, 200, 255)

		local dropLayout = Instance.new("UIListLayout", dropFrame)

		for _, option in ipairs(options) do
			local opt = Instance.new("TextButton", dropFrame)
			opt.Size = UDim2.new(1, 0, 0, 25)
			opt.Text = option
			opt.BackgroundTransparency = 1
			opt.Font = Enum.Font.Gotham
			opt.TextColor3 = Color3.new(1, 1, 1)

			opt.MouseButton1Click:Connect(function()
				callback(option)
				dropFrame.Visible = false
				dropdownOpen = false
			end)
		end

		main.MouseButton1Click:Connect(function()
			dropdownOpen = not dropdownOpen
			dropFrame.Visible = dropdownOpen
		end)
	end

	function tab:AddSlider(name, min, max, default, callback)
		local holder = Instance.new("Frame", content)
		holder.Size = UDim2.new(1, -12, 0, 40)
		holder.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, 0, 0.5, 0)
		label.Text = name .. ": " .. default
		label.Font = Enum.Font.Gotham
		label.TextColor3 = Color3.new(0, 0, 0)
		label.BackgroundTransparency = 1

		local slider = Instance.new("TextButton", holder)
		slider.Position = UDim2.new(0, 0, 0.5, 0)
		slider.Size = UDim2.new(1, 0, 0.5, -2)
		slider.Text = ""
		slider.BackgroundColor3 = Color3.fromRGB(120, 180, 255)

		local value = default
		slider.MouseButton1Down:Connect(function()
			local conn
			conn = mouse.Move:Connect(function()
				local pct = math.clamp((mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * pct)
				label.Text = name .. ": " .. value
				callback(value)
			end)
			UserInputService.InputEnded:Wait()
			conn:Disconnect()
		end)
	end

	table.insert(Tabs, tab)
	return tab
end

return SlayHub