--[[
    SlayLib.lua
    Pure UI Library (final fixed)
    Author: Ohvn Bdon
--]]

local SlayLib = {}
SlayLib.__index = SlayLib

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme
SlayLib.Theme = {
	MainColor = Color3.fromRGB(255,215,0),
	Background = Color3.fromRGB(25,25,25),
	Accent = Color3.fromRGB(50,50,50),
	Text = Color3.fromRGB(255,255,255)
}

-- Utility
local function Create(class,parent,props)
	local obj = Instance.new(class)
	for k,v in pairs(props or {}) do obj[k]=v end
	obj.Parent = parent
	return obj
end

-- Dragging
function SlayLib:EnableDragging(frame)
	local dragToggle, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragToggle then
			update(input)
		end
	end)
end

-- Notification
function SlayLib:Notification(title,text,duration,color)
	local screen = PlayerGui:FindFirstChild("SlayLibScreen") or Create("ScreenGui",PlayerGui,{Name="SlayLibScreen",ResetOnSpawn=false})
	local frame = Create("Frame",screen,{
		Size=UDim2.new(0,250,0,60),
		Position=UDim2.new(1,-260,1,-80),
		AnchorPoint=Vector2.new(1,1),
		BackgroundColor3=color or self.Theme.MainColor,
		BorderSizePixel=0
	})
	Create("UICorner",frame,{CornerRadius=UDim.new(0,8)})
	Create("TextLabel",frame,{
		Text=title.."\n"..text,
		TextColor3=self.Theme.Text,
		BackgroundTransparency=1,
		Font=Enum.Font.GothamBold,
		TextWrapped=true,
		TextSize=14,
		Size=UDim2.new(1,-8,1,-8),
		Position=UDim2.new(0,4,0,4),
		TextXAlignment=Enum.TextXAlignment.Left
	})
	TweenService:Create(frame,TweenInfo.new(0.3),{Position=UDim2.new(1,-260,1,-120)}):Play()
	task.delay(duration or 3,function()
		TweenService:Create(frame,TweenInfo.new(0.3),{BackgroundTransparency=1,Position=UDim2.new(1,-260,1,0)}):Play()
		task.wait(0.3)
		frame:Destroy()
	end)
end

-- Loader animation
function SlayLib:Loader(title)
	local screen = PlayerGui:FindFirstChild("SlayLibScreen") or Create("ScreenGui",PlayerGui,{Name="SlayLibScreen",ResetOnSpawn=false})
	local frame = Create("Frame",screen,{
		Size=UDim2.new(0,280,0,90),
		Position=UDim2.new(0.5,-140,0.5,-45),
		BackgroundColor3=self.Theme.Background,
		BorderSizePixel=0
	})
	Create("UICorner",frame,{CornerRadius=UDim.new(0,10)})
	local label = Create("TextLabel",frame,{
		Text=title or "SlayLib Loading...",
		Font=Enum.Font.GothamBold,
		TextColor3=self.Theme.MainColor,
		TextScaled=true,
		BackgroundTransparency=1,
		Size=UDim2.new(1,0,1,0)
	})
	local bar = Create("Frame",frame,{
		Size=UDim2.new(0,0,0,6),
		Position=UDim2.new(0,0,1,-6),
		BackgroundColor3=self.Theme.MainColor
	})
	for i=0,1,0.025 do
		bar.Size = UDim2.new(i,0,0,6)
		task.wait(0.02)
	end
	frame:Destroy()
end

-- Create Window
function SlayLib:CreateWindow(info)
	self:Loader("Initializing UI...")
	local screen = PlayerGui:FindFirstChild("SlayLibScreen") or Create("ScreenGui",PlayerGui,{Name="SlayLibScreen",ResetOnSpawn=false})
	local main = Create("Frame",screen,{
		Size=UDim2.new(0,420,0,310),
		Position=UDim2.new(0.5,-210,0.5,-155),
		BackgroundColor3=self.Theme.Background,
		BorderSizePixel=0
	})
	Create("UICorner",main,{CornerRadius=UDim.new(0,12)})
	self:EnableDragging(main)

	local title = Create("TextLabel",main,{
		Text=info.Name or "SlayLib",
		Font=Enum.Font.GothamBold,
		TextScaled=true,
		TextColor3=self.Theme.MainColor,
		BackgroundTransparency=1,
		Size=UDim2.new(1,0,0,40)
	})

	local tabButtons = Create("Frame",main,{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,40),BackgroundTransparency=1})
	local tabContainer = Create("Frame",main,{Size=UDim2.new(1,0,1,-76),Position=UDim2.new(0,0,0,76),BackgroundTransparency=1})
	local tabsFolder = Instance.new("Folder",tabContainer)
	tabsFolder.Name = "Tabs"

	local buttonLayout = Instance.new("UIListLayout",tabButtons)
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.Padding = UDim.new(0,4)

	local windowObj = {}
	function windowObj:CreateTab(name)
		local tabFrame = Create("Frame",tabsFolder,{
			Name=name,
			Size=UDim2.new(1,0,1,0),
			Visible=false,
			BackgroundTransparency=1
		})
		local layout = Instance.new("UIListLayout",tabFrame)
		layout.Padding = UDim.new(0,8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		local btn = Create("TextButton",tabButtons,{
			Text=name,
			Size=UDim2.new(0,100,1,0),
			BackgroundColor3=SlayLib.Theme.Accent,
			TextColor3=SlayLib.Theme.Text,
			Font=Enum.Font.GothamBold,
			TextScaled=true
		})
		Create("UICorner",btn,{CornerRadius=UDim.new(0,8)})
		btn.MouseButton1Click:Connect(function()
			for _,tab in pairs(tabsFolder:GetChildren()) do
				if tab:IsA("Frame") then tab.Visible=false end
			end
			tabFrame.Visible=true
		end)

		-- auto select first
		if #tabsFolder:GetChildren()==1 then
			tabFrame.Visible=true
		end

		local tabObj = {}

		function tabObj:CreateButton(info)
			local b = Create("TextButton",tabFrame,{
				Text=info.Name,
				Size=UDim2.new(0,200,0,36),
				BackgroundColor3=SlayLib.Theme.MainColor,
				TextColor3=SlayLib.Theme.Text,
				Font=Enum.Font.GothamBold,
				TextScaled=true
			})
			Create("UICorner",b,{CornerRadius=UDim.new(0,8)})
			b.MouseButton1Click:Connect(info.Callback)
		end

		function tabObj:CreateToggle(info)
			local f = Create("TextButton",tabFrame,{
				Text=info.Name.." : "..tostring(info.Default),
				Size=UDim2.new(0,200,0,36),
				BackgroundColor3=SlayLib.Theme.Accent,
				TextColor3=SlayLib.Theme.Text,
				Font=Enum.Font.GothamBold,
				TextScaled=true
			})
			Create("UICorner",f,{CornerRadius=UDim.new(0,8)})
			local val = info.Default or false
			f.MouseButton1Click:Connect(function()
				val = not val
				f.Text = info.Name.." : "..tostring(val)
				info.Callback(val)
			end)
		end

		function tabObj:CreateSlider(info)
			local frame = Create("Frame",tabFrame,{
				Size=UDim2.new(0,200,0,36),
				BackgroundColor3=SlayLib.Theme.Accent
			})
			Create("UICorner",frame,{CornerRadius=UDim.new(0,8)})
			local label = Create("TextLabel",frame,{
				Text=info.Name.." : "..tostring(info.Default or 0),
				BackgroundTransparency=1,
				Font=Enum.Font.GothamBold,
				TextColor3=SlayLib.Theme.Text,
				TextScaled=true,
				Size=UDim2.new(1,0,1,0)
			})
			local bar = Create("Frame",frame,{
				BackgroundColor3=SlayLib.Theme.MainColor,
				Size=UDim2.new((info.Default or 0)/(info.Max or 100),0,0.2,0),
				Position=UDim2.new(0,0,1,-6)
			})
			frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local function move(input)
						local x = math.clamp((input.Position.X - frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
						bar.Size = UDim2.new(x,0,0.2,0)
						local val = math.floor((x*(info.Max or 100)))
						label.Text = info.Name.." : "..val
						info.Callback(val)
					end
					local conn
					conn = UserInputService.InputChanged:Connect(function(i)
						if i.UserInputType==Enum.UserInputType.MouseMovement then
							move(i)
						end
					end)
					input.Changed:Connect(function()
						if input.UserInputState==Enum.UserInputState.End then conn:Disconnect() end
					end)
				end
			end)
		end

		function tabObj:CreateDropdown(info)
			local mainBtn = Create("TextButton",tabFrame,{
				Text=info.Name,
				Size=UDim2.new(0,200,0,36),
				BackgroundColor3=SlayLib.Theme.Accent,
				TextColor3=SlayLib.Theme.Text,
				Font=Enum.Font.GothamBold,
				TextScaled=true
			})
			Create("UICorner",mainBtn,{CornerRadius=UDim.new(0,8)})
			local open=false
			local dropFrame = Create("Frame",tabFrame,{
				Size=UDim2.new(0,200,0,#info.Options*30),
				Visible=false,
				BackgroundColor3=SlayLib.Theme.Background
			})
			local list = Instance.new("UIListLayout",dropFrame)
			list.Padding=UDim.new(0,4)
			for _,opt in pairs(info.Options) do
				local btn = Create("TextButton",dropFrame,{
					Text=opt,
					Size=UDim2.new(1,0,0,28),
					BackgroundColor3=SlayLib.Theme.MainColor,
					TextColor3=SlayLib.Theme.Text,
					Font=Enum.Font.GothamBold,
					TextScaled=true
				})
				btn.MouseButton1Click:Connect(function()
					mainBtn.Text=opt
					dropFrame.Visible=false
					info.Callback(opt)
				end)
			end
			mainBtn.MouseButton1Click:Connect(function()
				open=not open
				dropFrame.Visible=open
			end)
		end

		function tabObj:CreateTextBox(info)
			local box = Create("TextBox",tabFrame,{
				PlaceholderText=info.Placeholder or "",
				Text="",
				Size=UDim2.new(0,200,0,36),
				BackgroundColor3=SlayLib.Theme.Accent,
				TextColor3=SlayLib.Theme.Text,
				Font=Enum.Font.GothamBold,
				TextScaled=true
			})
			Create("UICorner",box,{CornerRadius=UDim.new(0,8)})
			box.FocusLost:Connect(function(enter)
				if enter then info.Callback(box.Text) end
			end)
		end

		return tabObj
	end

	return windowObj
end

return SlayLib