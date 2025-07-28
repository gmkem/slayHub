--// GuiLib.lua : Fully featured custom GUI Library
local GuiLib = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = instance
end

local function tween(obj, props, duration)
	TweenService:Create(obj, TweenInfo.new(duration or 0.3), props):Play()
end

function GuiLib.CreateWindow(title, size, theme)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GuiLibUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = size or UDim2.new(0, 400, 0, 300)
	Main.Position = UDim2.new(0.5, -200, 0.5, -150)
	Main.BackgroundColor3 = theme and theme.Background or Color3.fromRGB(255, 255, 255)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true
	Main.Parent = ScreenGui
	createCorner(Main, 10)

	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundTransparency = 1
	Header.Text = title or "Window"
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 18
	Header.TextColor3 = theme and theme.HeaderText or Color3.fromRGB(255,255,255)
	Header.Parent = Main

	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.BackgroundTransparency = 1
	Content.Size = UDim2.new(1, -20, 1, -60)
	Content.Position = UDim2.new(0, 10, 0, 50)
	Content.Parent = Main

	local UIList = Instance.new("UIListLayout")
	UIList.Padding = UDim.new(0, 8)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Parent = Content

	return {
		Gui = ScreenGui,
		Main = Main,
		Content = Content,
		Theme = theme,
		AddButton = function(self, text, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 40)
			Btn.Text = text
			Btn.BackgroundColor3 = self.Theme and self.Theme.Button or Color3.fromRGB(240,240,240)
			Btn.TextColor3 = self.Theme and self.Theme.ButtonText or Color3.fromRGB(0,0,0)
			Btn.Font = Enum.Font.Gotham
			Btn.TextSize = 14
			Btn.Parent = self.Content
			createCorner(Btn, 6)

			Btn.MouseButton1Click:Connect(function()
				callback()
			end)
		end,

		AddToggle = function(self, text, default, callback)
			local Toggle = Instance.new("TextButton")
			Toggle.Size = UDim2.new(1, 0, 0, 40)
			Toggle.Text = "[OFF] "..text
			Toggle.BackgroundColor3 = self.Theme and self.Theme.Toggle or Color3.fromRGB(240,240,240)
			Toggle.TextColor3 = self.Theme and self.Theme.ToggleText or Color3.fromRGB(0,0,0)
			Toggle.Font = Enum.Font.Gotham
			Toggle.TextSize = 14
			Toggle.Parent = self.Content
			createCorner(Toggle, 6)

			local state = default or false
			Toggle.MouseButton1Click:Connect(function()
				state = not state
				Toggle.Text = (state and "[ON] " or "[OFF] ") .. text
				callback(state)
			end)
		end,

		AddDropdown = function(self, text, options, callback)
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 40)
			Frame.BackgroundTransparency = 1
			Frame.Parent = self.Content

			local Dropdown = Instance.new("TextButton")
			Dropdown.Size = UDim2.new(1, 0, 0, 40)
			Dropdown.Text = text .. " ▼"
			Dropdown.BackgroundColor3 = self.Theme and self.Theme.Dropdown or Color3.fromRGB(230,230,230)
			Dropdown.TextColor3 = self.Theme and self.Theme.DropdownText or Color3.fromRGB(0,0,0)
			Dropdown.Font = Enum.Font.Gotham
			Dropdown.TextSize = 14
			Dropdown.Parent = Frame
			createCorner(Dropdown, 6)

			local Open = false
			local OptionHolder = Instance.new("Frame")
			OptionHolder.Size = UDim2.new(1, 0, 0, 0)
			OptionHolder.Position = UDim2.new(0, 0, 1, 0)
			OptionHolder.BackgroundTransparency = 1
			OptionHolder.ClipsDescendants = true
			OptionHolder.Parent = Frame

			local Layout = Instance.new("UIListLayout")
			Layout.Parent = OptionHolder

			Dropdown.MouseButton1Click:Connect(function()
				Open = not Open
				Dropdown.Text = text .. (Open and " ▲" or " ▼")
				OptionHolder:TweenSize(UDim2.new(1, 0, 0, Open and #options * 30 or 0), "Out", "Quad", 0.25, true)
			end)

			for _, opt in ipairs(options) do
				local Option = Instance.new("TextButton")
				Option.Size = UDim2.new(1, 0, 0, 30)
				Option.Text = opt
				Option.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Option.TextColor3 = Color3.fromRGB(0,0,0)
				Option.Font = Enum.Font.Gotham
				Option.TextSize = 14
				Option.Parent = OptionHolder
				Option.MouseButton1Click:Connect(function()
					callback(opt)
					Open = false
					Dropdown.Text = text .. " ▼"
					OptionHolder:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.25, true)
				end)
			end
		end
	}
end

return GuiLib
