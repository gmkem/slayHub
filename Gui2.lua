local SlayLib = {
	Folder = "SlayLib_Config",
	Settings = {},
	Flags = {},
	Signals = {},
	Elements = {},
	Theme = {
		MainColor = Color3.fromRGB(120, 80, 255),
		Background = Color3.fromRGB(12, 12, 12),
		Sidebar = Color3.fromRGB(18, 18, 18),
		Element = Color3.fromRGB(25, 25, 25),
		ElementHover = Color3.fromRGB(32, 32, 32),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 180),
		Stroke = Color3.fromRGB(45, 45, 45),
		NotificationColor = Color3.fromRGB(120, 80, 255),
		Success = Color3.fromRGB(0, 255, 127),
		Warning = Color3.fromRGB(255, 165, 0),
		Error = Color3.fromRGB(255, 65, 65),
	},
	Icons = {
		Logofull = "rbxassetid://116729461256827",
		Logo = "rbxassetid://71428791657528",
		Check = "rbxassetid://10734895530",
		Chevron = "rbxassetid://10734895856",
		Search = "rbxassetid://10734897102",
		Folder = "rbxassetid://10734897484"
	}
}

--// Services Initialization
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

--// Environment Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)

--// [ADDED] ANTI RE-EXECUTE SYSTEM (ระบบล้างของเก่าก่อนรันใหม่)
for _, obj in pairs(Parent:GetChildren()) do
	if obj.Name == "SlayLib_X_Engine" or obj.Name == "SlayLoadingEnv" or obj.Name == "SlayNotifFinal" then
		obj:Destroy()
	end
end
if Lighting:FindFirstChild("SlayBlur") then Lighting.SlayBlur:Destroy() end
if Lighting:FindFirstChild("Blur") then Lighting.Blur:Destroy() end

--// Folder Management (Config)
if not isfolder(SlayLib.Folder) then
	makefolder(SlayLib.Folder)
end

--// [NEW] List every saved config's name (without folder/extension), used by
--// the popup config manager. Wrapped in pcall since listfiles behaves
--// slightly differently across executors.
function SlayLib:ListConfigs()
	local names = {}
	local ok, files = pcall(listfiles, SlayLib.Folder)
	if ok and files then
		for _, path in ipairs(files) do
			local fileName = path:match("([^/\\]+)%.json$")
			if fileName then
				table.insert(names, fileName)
			end
		end
	end
	table.sort(names)
	return names
end

--// UTILITY FUNCTIONS (THE BRAIN)
local function Create(class, props)
	local obj = Instance.new(class)
	for i, v in pairs(props) do
		obj[i] = v
	end
	return obj
end

--// [FIX] Deep-merge defaults so partially-filled Props tables never leave
--// required fields (like Callback) nil. This prevents "attempt to call a
--// nil value" errors when a user only passes Name/Flag and skips Callback.
local function MergeDefaults(props, defaults)
	props = props or {}
	for k, v in pairs(defaults) do
		local function DeepCopy(t)
	local new = {}
	for k,v in pairs(t) do
		new[k] = (type(v) == "table") and DeepCopy(v) or v
	end
	return new
end

local function MergeDefaults(props, defaults)
	props = props or {}
	for k, v in pairs(defaults) do
		if props[k] == nil then
			props[k] = (type(v) == "table") and DeepCopy(v) or v
		end
	end
	return props
end
	end
	return props
end

local function GetTweenInfo(time, style, dir)
	return TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
end

local function Tween(obj, goal, time, style, dir)
	local t = TweenService:Create(obj, GetTweenInfo(time, style, dir), goal)
	t:Play()
	return t
end

--// [NEW] THEME SWITCHER SYSTEM
-- A handful of ready-made accent colors. SlayLib:SetTheme("Blue") (or pass a
-- raw Color3) updates SlayLib.Theme.MainColor/NotificationColor and live
-- re-colors every registered instance. Anything created with a color that
-- should follow the theme calls RegisterThemed(instance, "Property") once.
SlayLib.ThemePresets = {
	Purple = Color3.fromRGB(120, 80, 255),
	Blue   = Color3.fromRGB(70, 140, 255),
	Red    = Color3.fromRGB(255, 70, 70),
	Green  = Color3.fromRGB(60, 200, 120),
	Orange = Color3.fromRGB(255, 150, 60),
	Pink   = Color3.fromRGB(255, 90, 170),
}
SlayLib.ThemePresetOrder = {"Purple", "Blue", "Red", "Green", "Orange", "Pink"}
SlayLib.ThemeRegistry = {}

local function RegisterThemed(instance, prop)
	table.insert(SlayLib.ThemeRegistry, {Instance = instance, Prop = prop})
	return instance
end

function SlayLib:SetTheme(nameOrColor)
	local color
	if typeof(nameOrColor) == "Color3" then
		color = nameOrColor
	else
		color = SlayLib.ThemePresets[nameOrColor]
	end
	if not color then return end

	SlayLib.Theme.MainColor = color
	SlayLib.Theme.NotificationColor = color

	for i = #SlayLib.ThemeRegistry, 1, -1 do
		local entry = SlayLib.ThemeRegistry[i]
		if entry.Instance and entry.Instance.Parent then
			Tween(entry.Instance, {[entry.Prop] = color}, 0.3)
		else
			-- Clean up references to destroyed instances so this list
			-- doesn't grow forever across tab/window rebuilds.
			table.remove(SlayLib.ThemeRegistry, i)
		end
	end
end

--// [NEW] TOOLTIP SYSTEM
-- Attach a small floating tooltip to any GuiObject: AttachTooltip(frame, "Explanation text")
local SlayTooltipGui = nil
local function AttachTooltip(GuiObject, Text)
	if not Text or Text == "" then return end

	if not SlayTooltipGui or not SlayTooltipGui.Parent then
		SlayTooltipGui = Create("ScreenGui", {
			Name = "SlayTooltipGui", Parent = game:GetService("CoreGui"),
			DisplayOrder = 99998, IgnoreGuiInset = true
		})
	end

	local TipFrame = Create("Frame", {
		Name = "Tip", Visible = false, BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 500, Parent = SlayTooltipGui
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TipFrame})
	local TipStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1, Transparency = 0.4, Parent = TipFrame})
	RegisterThemed(TipStroke, "Color")
	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), Parent = TipFrame
	})
	Create("TextLabel", {
		Text = Text, Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = Color3.fromRGB(230, 230, 230), BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 501, Parent = TipFrame
	})

	GuiObject.MouseEnter:Connect(function()
		TipFrame.Visible = true
	end)
	GuiObject.MouseMoved:Connect(function(x, y)
		TipFrame.Position = UDim2.new(0, x + 16, 0, y + 16)
	end)
	GuiObject.MouseLeave:Connect(function()
		TipFrame.Visible = false
	end)
	GuiObject.AncestryChanged:Connect(function(_, parent)
	if not parent and TipFrame then
		TipFrame:Destroy()
		TipFrame = nil
	end
end)

end

--// SMART TEXT SCALING LOGIC
local function ApplyTextLogic(label, content, maxSize)
	label.Text = content
	label.TextWrapped = true
	label.TextSize = maxSize or 14

	local function Adjust()
		if label.TextBounds.X > label.AbsoluteSize.X or label.TextBounds.Y > label.AbsoluteSize.Y then
			label.TextScaled = true
		else
			label.TextScaled = false
		end
	end

	label:GetPropertyChangedSignal("AbsoluteSize"):Connect(Adjust)
	Adjust()
end

--// DRAGGING SYSTEM
local function RegisterDrag(Frame, Handle)
	local Dragging = false
	local DragInput, DragStart, StartPos

	Handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPos = Frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	Handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Dragging and input == DragInput then
			local Delta = input.Position - DragStart
			Frame.Position = UDim2.new(
				StartPos.X.Scale,
				StartPos.X.Offset + Delta.X,
				StartPos.Y.Scale,
				StartPos.Y.Offset + Delta.Y
			)
		end
	end)
end

--// NOTIFICATION ENGINE (PROXIMITY BASED)
function SlayLib:Notify(Config)
	-- [FIX] Merge with defaults instead of "Config or {...}" so partial
	-- tables (e.g. {Title = "Hi"}) don't leave Duration/Type nil, which
	-- previously caused the progress bar duration to desync from the
	-- actual auto-close wait time.
	Config = MergeDefaults(Config, {Title = "SYSTEM", Content = "Message Content", Duration = 6, Type = "Neutral"})

	local NotifColor = SlayLib.Theme.MainColor
	if Config.Type == "Success" then NotifColor = SlayLib.Theme.Success
	elseif Config.Type == "Error" then NotifColor = SlayLib.Theme.Error
	elseif Config.Type == "Warning" then NotifColor = SlayLib.Theme.Warning end

	-- [FIX] Always use a dedicated, always-on-top ScreenGui for notifications.
	-- The old code sometimes parented notifications inside "SlayLib_X_Engine"
	-- (DisplayOrder 0) instead of "SlayNotifFinal" (DisplayOrder 9999),
	-- which made notifications randomly render behind other UI.
	local ParentGui = game:GetService("CoreGui"):FindFirstChild("SlayNotifFinal")
	if not ParentGui then
		ParentGui = Create("ScreenGui", {Name = "SlayNotifFinal", Parent = game:GetService("CoreGui"), DisplayOrder = 9999})
	end

	local Holder = ParentGui:FindFirstChild("NotifHolder") or Create("Frame", {
		Name = "NotifHolder", Parent = ParentGui, BackgroundTransparency = 1,
		Size = UDim2.new(0, 320, 1, -40), Position = UDim2.new(1, -330, 0, 20)
	})

	if not Holder:FindFirstChild("UIListLayout") then
		Create("UIListLayout", {
			Parent = Holder,
			VerticalAlignment = "Bottom",
			HorizontalAlignment = "Right",
			Padding = UDim.new(0, 10),
			SortOrder = "LayoutOrder"
		})
	end

	local NotifFrame = Create("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		GroupTransparency = 1,
		ClipsDescendants = true,
		Parent = Holder
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = NotifFrame})

	local Stroke = Create("UIStroke", {
		Color = NotifColor,
		Transparency = 0.6,
		Thickness = 1.4,
		Parent = NotifFrame
	})

	local TextArea = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = "Y",
		Parent = NotifFrame
	})
	Create("UIListLayout", {Parent = TextArea, Padding = UDim.new(0, 4), SortOrder = "LayoutOrder"})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 26),
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		Parent = TextArea
	})

	local TitleLabel = Create("TextLabel", {
		Text = Config.Title:upper(), Font = "GothamBold", TextSize = 13,
		TextColor3 = NotifColor, BackgroundTransparency = 1, TextXAlignment = "Left",
		Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, Parent = TextArea
	})

	local ContentLabel = Create("TextLabel", {
		Text = Config.Content, Font = "GothamMedium", TextSize = 12,
		TextColor3 = Color3.fromRGB(220, 220, 220), BackgroundTransparency = 1,
		TextXAlignment = "Left", TextWrapped = true, Size = UDim2.new(1, 0, 0, 14),
		AutomaticSize = "Y", LayoutOrder = 2, Parent = TextArea
	})

	local BarContainer = Create("Frame", {
		Name = "BarContainer",
		Size = UDim2.new(1, -32, 0, 3),
		Position = UDim2.new(0.5, 0, 1, -12),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Parent = NotifFrame
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarContainer})

	local BarFill = Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = NotifColor,
		BorderSizePixel = 0,
		Parent = BarContainer
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarFill})

	task.spawn(function()
		-- [FIX] Add a timeout guard so a notification never gets stuck forever
		-- if TextArea somehow never reports a size (e.g. destroyed mid-flight).
		local waited = 0
		repeat
			task.wait()
			waited += task.wait()
		until TextArea.AbsoluteSize.Y > 0 or waited > 2 or not NotifFrame.Parent
		if not NotifFrame.Parent then return end

		local FinalHeight = TextArea.AbsoluteSize.Y

		Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, FinalHeight), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Quart)
		Tween(BarFill, {Size = UDim2.new(0, 0, 1, 0)}, Config.Duration, Enum.EasingStyle.Linear)

		task.wait(Config.Duration)
		if not NotifFrame.Parent then return end

		local ExitTween = Tween(NotifFrame, {GroupTransparency = 1}, 0.4, Enum.EasingStyle.Quart)
		Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.5)

		ExitTween.Completed:Connect(function()
			if NotifFrame then NotifFrame:Destroy() end
		end)
	end)
end

--// LOADING SEQUENCE (HIGH FIDELITY)
local function ExecuteFinalSovereign()
	local TweenService = game:GetService("TweenService")
	local Lighting = game:GetService("Lighting")
	local Debris = game:GetService("Debris")

	local Screen = Instance.new("ScreenGui")
	Screen.Name = "SLAY_SOVEREIGN_FIXED"
	Screen.IgnoreGuiInset = true
	Screen.DisplayOrder = 999999
	Screen.ScreenInsets = Enum.ScreenInsets.None
	Screen.Parent = game:GetService("CoreGui")

	local Blur = Instance.new("BlurEffect", Lighting)
	Blur.Size = 0

	local MainFrame = Instance.new("Frame", Screen)
	MainFrame.Size = UDim2.new(1, 0, 1, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.BorderSizePixel = 0
	MainFrame.BackgroundTransparency = 1

	local Hub = Instance.new("Frame", MainFrame)
	Hub.AnchorPoint = Vector2.new(0.5, 0.5)
	Hub.Position = UDim2.new(0.5, 0, 0.5, 0)
	Hub.Size = UDim2.new(0, 400, 0, 400)
	Hub.BackgroundTransparency = 1

	local Logo = Instance.new("ImageLabel", Hub)
	Logo.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
	Logo.Size = UDim2.new(0, 0, 0, 0)
	Logo.Image = SlayLib.Icons.Logofull
	Logo.BackgroundTransparency = 1
	Logo.ImageTransparency = 1

	task.spawn(function()
		TweenService:Create(MainFrame, TweenInfo.new(0.7), {BackgroundTransparency = 0.05}):Play()
		TweenService:Create(Blur, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {Size = 35}):Play()

		for i = 1, 3 do
			local sw = Instance.new("Frame", Hub)
			sw.AnchorPoint = Vector2.new(0.5, 0.5)
			sw.Position = UDim2.new(0.5, 0, 0.5, 0)
			sw.Size = UDim2.new(0, 0, 0, 0)
			sw.BackgroundColor3 = SlayLib.Theme.MainColor
			sw.BackgroundTransparency = 0.5
			Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

			TweenService:Create(sw, TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 1000, 0, 1000),
				BackgroundTransparency = 1
			}):Play()
			Debris:AddItem(sw, 1.2)
			task.wait(0.18)
		end

		TweenService:Create(Logo, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 260, 0, 260),
			ImageTransparency = 0
		}):Play()
	end)

	local Status = Instance.new("TextLabel", MainFrame)
	Status.AnchorPoint = Vector2.new(0.5, 0.5)
	Status.Position = UDim2.new(0.5, 0, 0.84, 0)
	Status.Size = UDim2.new(0, 500, 0, 20)
	Status.Font = Enum.Font.Code
	Status.TextColor3 = SlayLib.Theme.MainColor
	Status.TextSize = 14
	Status.BackgroundTransparency = 1
	Status.TextTransparency = 1
	Status.Text = "READY"

	TweenService:Create(Status, TweenInfo.new(0.8), {TextTransparency = 0.2}):Play()
	task.wait(2.5)

	pcall(function()
		local FinalInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		TweenService:Create(Logo, FinalInfo, {
			Size = UDim2.new(0, 2, 0, 2000),
			ImageTransparency = 1
		}):Play()

		local FinalCollapse = TweenService:Create(MainFrame, FinalInfo, {
			Size = UDim2.new(1.5, 0, 0, 0),
			Position = UDim2.new(-0.25, 0, 0.5, 0),
			BackgroundTransparency = 1
		})

		FinalCollapse:Play()
		TweenService:Create(Blur, TweenInfo.new(0.6), {Size = 0}):Play()

		FinalCollapse.Completed:Connect(function()
			Screen:Destroy()
			if Blur then Blur:Destroy() end
		end)
	end)

	task.delay(6, function()
		if Screen and Screen.Parent then Screen:Destroy() end
		if Blur and Blur.Parent then Blur:Destroy() end
	end)
end

--// MAIN WINDOW CONSTRUCTOR
function SlayLib:CreateWindow(Config)
	Config = MergeDefaults(Config, {Name = "SlayLib X"})

	ExecuteFinalSovereign()
	SlayLib.ThemeRegistry = {}

	local OldUI = game:GetService("CoreGui"):FindFirstChild("SlayLib_X_Engine")
	if OldUI then OldUI:Destroy() end

	local Window = { Toggled = true, Tabs = {}, CurrentTab = nil }

	local CoreGuiFrame = Create("ScreenGui", {
		Name = "SlayLib_X_Engine",
		Parent = game:GetService("CoreGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Size = UDim2.new(0, 620, 0, 440),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(18, 18, 20),
		Parent = CoreGuiFrame,
		ZIndex = 5,
		ClipsDescendants = true,
		Visible = true
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
	local MainStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.2, Transparency = 0.4, Parent = MainFrame})
	RegisterThemed(MainStroke, "Color")

	-- [FIX] REMOVED the entire duplicate/legacy sidebar block that used to
	-- exist here (a second "Sidebar" frame at width 155 with its own Title,
	-- "ContainerHolder" and "Divider"). It was dead leftover code from an
	-- earlier version and was being rendered UNDERNEATH the real sidebar
	-- built below, wasting memory and occasionally showing a ghost title/
	-- divider behind the real UI. The FloatingToggle (minimize button) is
	-- kept since it's a real, independent feature.

	-- [FLOATING TOGGLE]
	local FloatingToggle = Create("Frame", {
		Name = "FloatingToggle",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(0.05, 0, 0.15, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 27),
		Parent = CoreGuiFrame,
		ZIndex = 100
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingToggle})
	local FloatToggleStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 2, Parent = FloatingToggle})
	RegisterThemed(FloatToggleStroke, "Color")

	local ToggleIcon = Create("ImageLabel", {
		Size = UDim2.new(0, 26, 0, 26),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = SlayLib.Icons.Logo,
		ImageColor3 = SlayLib.Theme.MainColor,
		BackgroundTransparency = 1,
		Parent = FloatingToggle
	})
	RegisterThemed(ToggleIcon, "ImageColor3")

	local ToggleButton = Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		Parent = FloatingToggle
	})

	RegisterDrag(FloatingToggle, FloatingToggle)

	ToggleButton.MouseButton1Click:Connect(function()
		Window.Toggled = not Window.Toggled
		if Window.Toggled then
			MainFrame.Visible = true
			MainFrame:TweenSize(UDim2.new(0, 620, 0, 440), "Out", "Back", 0.35, true)
		else
			MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quart", 0.3, true)
			task.delay(0.3, function()
				if not Window.Toggled then MainFrame.Visible = false end
			end)
		end
	end)

	-- [1] SIDEBAR (the single, real sidebar implementation)
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 200, 1, -12),
		Position = UDim2.new(0, 6, 0, 6),
		BackgroundColor3 = SlayLib.Theme.Sidebar,
		ZIndex = 10,
		Parent = MainFrame
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})

	local SideHeader = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundTransparency = 1,
		ZIndex = 11,
		Parent = Sidebar
	})
	local LibIcon = Create("ImageLabel", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 18, 0, 19),
		Image = SlayLib.Icons.Logo,
		BackgroundTransparency = 1,
		ImageColor3 = SlayLib.Theme.MainColor,
		ZIndex = 12,
		Parent = SideHeader
	})
	local LibTitle = Create("TextLabel", {
		Size = UDim2.new(1, -65, 1, 0),
		Position = UDim2.new(0, 58, 0, 0),
		Font = "GothamBold",
		TextSize = 17,
		TextColor3 = SlayLib.Theme.Text,
		TextXAlignment = "Left",
		BackgroundTransparency = 1,
		ZIndex = 12,
		Parent = SideHeader
	})
	ApplyTextLogic(LibTitle, Config.Name, 17)

	-- [NEW] GLOBAL SEARCH BAR
	-- Filters the tab list by tab name AND by the name of any element inside
	-- a tab (toggles, sliders, buttons, etc). If a search matches an element
	-- in a tab that isn't currently open, that tab is opened automatically
	-- and the matching element is briefly highlighted.
	local SearchBox = Create("Frame", {
		Name = "SearchBox",
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 72),
		BackgroundColor3 = Color3.fromRGB(30, 30, 32),
		ZIndex = 11,
		Parent = Sidebar
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SearchBox})
	local SearchStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1, Transparency = 0.7, Parent = SearchBox})
	RegisterThemed(SearchStroke, "Color")

	local SearchGlass = Create("ImageLabel", {
		Size = UDim2.new(0, 13, 0, 13),
		Position = UDim2.new(0, 9, 0.5, -6.5),
		Image = SlayLib.Icons.Search,
		ImageColor3 = SlayLib.Theme.TextSecondary,
		BackgroundTransparency = 1,
		ZIndex = 12,
		Parent = SearchBox
	})

	local SearchInput = Create("TextBox", {
		Size = UDim2.new(1, -32, 1, 0),
		Position = UDim2.new(0, 28, 0, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = SlayLib.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 12,
		Parent = SearchBox
	})

	local TabScroll = Create("ScrollingFrame", {
		Name = "TabScroll",
		Size = UDim2.new(1, -10, 1, -118),
		Position = UDim2.new(0, 5, 0, 108),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ZIndex = 11,
		Parent = Sidebar,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	local TabLayout = Create("UIListLayout", {
		Parent = TabScroll,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = "Center",
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	-- [2] CONTENT AREA
	local PageContainer = Create("Frame", {
		Name = "PageContainer",
		Size = UDim2.new(1, -225, 1, -20),
		Position = UDim2.new(0, 215, 0, 10),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = MainFrame
	})

	RegisterDrag(MainFrame, SideHeader)

	-- [NEW] Briefly flashes an element's border to draw the eye to it after a search jump.
	local function HighlightFrame(Frame)
		local Flash = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 2, Transparency = 0, Parent = Frame})
		RegisterThemed(Flash, "Color")
		Tween(Flash, {Transparency = 1}, 1.1, Enum.EasingStyle.Quad)
		task.delay(1.2, function()
			if Flash then Flash:Destroy() end
		end)
	end

	-- [NEW] SEARCH BAR LOGIC
	SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(SearchInput.Text)

		if query == "" then
			for _, t in ipairs(Window.Tabs) do
				t.TabBtn.Visible = true
			end
			return
		end

		local JumpTarget, JumpTab

		for _, t in ipairs(Window.Tabs) do
			local tabNameMatch = string.find(string.lower(t.Name), query, 1, true) ~= nil
			local elementMatch = nil

			for _, item in ipairs(t.SearchItems) do
				if item.Name and string.find(string.lower(tostring(item.Name)), query, 1, true) then
					elementMatch = item
					break
				end
			end

			t.TabBtn.Visible = tabNameMatch or (elementMatch ~= nil)

			if not JumpTarget and elementMatch and not tabNameMatch then
				JumpTarget, JumpTab = elementMatch, t
			end
		end

		-- If the only reason a tab matched is because an element inside it
		-- matched (not the tab's own name), open that tab and scroll/flash
		-- the matching element so the user doesn't have to hunt for it.
		if JumpTarget and Window.CurrentTab and Window.CurrentTab.Page ~= JumpTab.Page then
			JumpTab.Activate()
			task.defer(function()
				local frame = JumpTarget.Frame
				if frame and frame.Parent then
					JumpTab.Page.CanvasPosition = Vector2.new(0, math.max(0, frame.AbsolutePosition.Y - JumpTab.Page.AbsolutePosition.Y - 20))
					HighlightFrame(frame)
				end
			end)
		end
	end)

	--// [TAB CREATOR LOGIC]
	function Window:CreateTab(Name, IconID)
		local Tab = {Active = false}
		local SearchItems = {} -- [NEW] populated by every element this tab creates, used by the search bar

		local TabBtn = Create("TextButton", {
			Size = UDim2.new(1, -10, 0, 38),
			BackgroundColor3 = SlayLib.Theme.MainColor,
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 15,
			Parent = TabScroll
		})
		Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

		local TabLbl = Create("TextLabel", {
			Text = Name,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 35, 0, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = SlayLib.Theme.TextSecondary,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextWrapped = true,
			LineHeight = 1.0,
			BackgroundTransparency = 1,
			ZIndex = 16,
			Parent = TabBtn
		})

		task.defer(function()
			local TextService = game:GetService("TextService")
			local bounds = TextService:GetTextSize(Name, 13, Enum.Font.GothamMedium, Vector2.new(95, math.huge))
			if bounds.X > 95 then
				TabLbl.TextSize = 11
			end
		end)

		local TabIcon = Create("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 10, 0.5, -9),
			Image = IconID or SlayLib.Icons.Folder,
			ImageColor3 = SlayLib.Theme.TextSecondary,
			BackgroundTransparency = 1,
			ZIndex = 16,
			Parent = TabBtn
		})

		local Page = Create("ScrollingFrame", {
			Name = Name .. "_Page",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = SlayLib.Theme.MainColor,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 20,
			ClipsDescendants = false,
			Parent = PageContainer
		})

		local PagePadding = Create("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
			Parent = Page
		})

		local PageList = Create("UIListLayout", {
			Parent = Page,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		-- [FIX/NEW] Pulled out of the click connection so the search bar can
		-- also jump to this tab programmatically, not just a mouse click.
		local function ActivateTab()
			if Window.CurrentTab then
				Window.CurrentTab.Page.Visible = false
				Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1}, 0.2)
				Tween(Window.CurrentTab.Lbl, {TextColor3 = SlayLib.Theme.TextSecondary}, 0.2)
				Tween(Window.CurrentTab.Icon, {ImageColor3 = SlayLib.Theme.TextSecondary}, 0.2)
			end
			Window.CurrentTab = {Page = Page, Btn = TabBtn, Lbl = TabLbl, Icon = TabIcon}
			Page.Visible = true
			Tween(TabBtn, {BackgroundTransparency = 0.85, BackgroundColor3 = SlayLib.Theme.MainColor}, 0.2)
			Tween(TabLbl, {TextColor3 = SlayLib.Theme.MainColor}, 0.2)
			Tween(TabIcon, {ImageColor3 = SlayLib.Theme.MainColor}, 0.2)
		end

		TabBtn.MouseButton1Click:Connect(ActivateTab)

		if not Window.CurrentTab then
			Window.CurrentTab = {Page = Page, Btn = TabBtn, Lbl = TabLbl, Icon = TabIcon}
			Page.Visible = true
			TabBtn.BackgroundTransparency = 0.85
			TabBtn.BackgroundColor3 = SlayLib.Theme.MainColor
			TabLbl.TextColor3 = SlayLib.Theme.MainColor
			TabIcon.ImageColor3 = SlayLib.Theme.MainColor
		end

		-- [NEW] Register this tab so the global search bar can filter/jump to it.
		-- (Window.Tabs existed before but was never actually populated.)
		table.insert(Window.Tabs, {
			Name = Name, TabBtn = TabBtn, Page = Page,
			Activate = ActivateTab, SearchItems = SearchItems
		})

		-- // [SECTION CREATOR]
		function Tab:CreateSection(SName)
			local Section = {}
			local SectFrame = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundTransparency = 1,
				ZIndex = 26,
				Parent = Page
			})
			local SectLbl = Create("TextLabel", {
				Text = SName:upper(),
				Size = UDim2.new(1, 0, 1, 0),
				Font = "GothamBold",
				TextSize = 12,
				TextColor3 = SlayLib.Theme.MainColor,
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
				ZIndex = 27,
				Parent = SectFrame
			})
			RegisterThemed(SectLbl, "TextColor3")

			-- 1. TOGGLE
			function Section:CreateToggle(Props)
				-- [FIX] Merge defaults per-field instead of "Props or {...}"
				-- so a call like CreateToggle({Name="X", Flag="Y"}) no longer
				-- crashes on click with "attempt to call a nil value" because
				-- Callback was nil.
				Props = MergeDefaults(Props, {Name = "Toggle", CurrentValue = false, Flag = "Toggle_1", Callback = function() end, Tooltip = nil})
				local TState = Props.CurrentValue
				SlayLib.Flags[Props.Flag] = TState

				local TContainer = Create("Frame", {
					Name = Props.Name .. "_Toggle",
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundColor3 = SlayLib.Theme.Element,
					ZIndex = 25,
					Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TContainer})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = TContainer})
				AttachTooltip(TContainer, Props.Tooltip)
				table.insert(SearchItems, {Name = Props.Name, Frame = TContainer})

				local TLbl = Create("TextLabel", {
					Size = UDim2.new(1, -70, 1, 0),
					Position = UDim2.new(0, 15, 0, 0),
					Font = "GothamMedium",
					TextSize = 14,
					TextColor3 = SlayLib.Theme.Text,
					TextXAlignment = "Left",
					BackgroundTransparency = 1,
					ZIndex = 26,
					Parent = TContainer
				})
				ApplyTextLogic(TLbl, Props.Name, 14)

				local Switch = Create("Frame", {
					Size = UDim2.new(0, 38, 0, 20),
					Position = UDim2.new(1, -50, 0.5, -10),
					BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 45),
					ZIndex = 27,
					Parent = TContainer
				})
				Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})

				local Dot = Create("Frame", {
					Size = UDim2.new(0, 14, 0, 14),
					Position = TState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex = 28,
					Parent = Switch
				})
				Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

				local ClickArea = Create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 30,
					Parent = TContainer
				})

				ClickArea.MouseButton1Click:Connect(function()
					TState = not TState
					SlayLib.Flags[Props.Flag] = TState
					Tween(Switch, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 45)}, 0.2)
					Tween(Dot, {Position = TState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.2)
					task.spawn(Props.Callback, TState)
				end)

				local Obj = {}

				function Obj:Set(v)
					TState = v
					SlayLib.Flags[Props.Flag] = v
					Switch.BackgroundColor3 = v and SlayLib.Theme.MainColor or Color3.fromRGB(45,45,45)
					Dot.Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
				end

				Obj.Flag = Props.Flag
				table.insert(SlayLib.Elements, Obj)

				return Obj
			end

			-- 2. SLIDER
			function Section:CreateSlider(Props)
				Props = MergeDefaults(Props, {Name = "Slider", Min = 0, Max = 100, Def = 50, Flag = "Slider_1", Callback = function() end, Tooltip = nil})

				-- [FIX] Guard against Max == Min (or Max < Min), which used to
				-- cause a divide-by-zero -> NaN -> broken UDim2/fill size.
				if Props.Max <= Props.Min then
					Props.Max = Props.Min + 1
				end

				local Value = math.clamp(Props.Def, Props.Min, Props.Max)
				SlayLib.Flags[Props.Flag] = Value

				local SContainer = Create("Frame", {
					Size = UDim2.new(1, 0, 0, 65),
					BackgroundColor3 = SlayLib.Theme.Element,
					ZIndex = 25,
					Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SContainer})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = SContainer})
				AttachTooltip(SContainer, Props.Tooltip)
				table.insert(SearchItems, {Name = Props.Name, Frame = SContainer})

				local SLbl = Create("TextLabel", {
					Size = UDim2.new(1, -100, 0, 35),
					Position = UDim2.new(0, 15, 0, 5),
					Font = "GothamMedium",
					TextSize = 14,
					TextColor3 = SlayLib.Theme.Text,
					TextXAlignment = "Left",
					BackgroundTransparency = 1,
					ZIndex = 26,
					Parent = SContainer
				})
				SLbl.Text = Props.Name

				local ValInput = Create("TextBox", {
					Text = tostring(Value),
					Size = UDim2.new(0, 45, 0, 20),
					Position = UDim2.new(1, -60, 0, 10),
					Font = "Code",
					TextSize = 12,
					TextColor3 = SlayLib.Theme.MainColor,
					BackgroundColor3 = Color3.fromRGB(20, 20, 20),
					ZIndex = 27,
					Parent = SContainer
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ValInput})
				RegisterThemed(ValInput, "TextColor3")

				local Bar = Create("Frame", {
					Size = UDim2.new(1, -30, 0, 4),
					Position = UDim2.new(0, 15, 0, 48),
					BackgroundColor3 = Color3.fromRGB(45, 45, 45),
					ZIndex = 27,
					Parent = SContainer
				})
				Create("UICorner", {Parent = Bar})

				local Fill = Create("Frame", {
					Size = UDim2.new(math.clamp((Value - Props.Min)/(Props.Max - Props.Min), 0, 1), 0, 1, 0),
					BackgroundColor3 = SlayLib.Theme.MainColor,
					ZIndex = 28,
					Parent = Bar
				})
				Create("UICorner", {Parent = Fill})
				RegisterThemed(Fill, "BackgroundColor3")

				local SliderBtn = Create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 30,
					Parent = Bar
				})

				local function SetValue(v, ignoreInput)
					Value = math.clamp(v, Props.Min, Props.Max)
					local range = math.max(Props.Max - Props.Min, 1)
local Percent = (Value - Props.Min) / range

					Tween(Fill, {Size = UDim2.new(Percent, 0, 1, 0)}, 0.1)

					if not ignoreInput then
						ValInput.Text = tostring(Value)
					end

					SlayLib.Flags[Props.Flag] = Value
					task.spawn(Props.Callback, Value)
				end

				local function UpdateFromInput(Input)
					local Percent = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local NewVal = math.floor(Props.Min + (Props.Max - Props.Min) * Percent)
					SetValue(NewVal)
				end

				ValInput.FocusLost:Connect(function(EnterPressed)
					local NewVal = tonumber(ValInput.Text)
					if NewVal then
						SetValue(NewVal)
					else
						ValInput.Text = tostring(Value)
					end
				end)

				SliderBtn.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						local MoveCon, EndCon
						UpdateFromInput(Input)

						MoveCon = game:GetService("UserInputService").InputChanged:Connect(function(Move)
							if Move.UserInputType == Enum.UserInputType.MouseMovement or Move.UserInputType == Enum.UserInputType.Touch then
								UpdateFromInput(Move)
							end
						end)

						EndCon = game:GetService("UserInputService").InputEnded:Connect(function(End)
							if End.UserInputType == Enum.UserInputType.MouseButton1 or End.UserInputType == Enum.UserInputType.Touch then
								MoveCon:Disconnect()
								EndCon:Disconnect()
							end
						end)
					end
				end)

				local Obj = {}

				-- [FIX] Sliders previously had no :Set(), so SlayLib:LoadConfig
				-- silently skipped restoring slider values/visuals on load.
				function Obj:Set(v)
					SetValue(v)
				end

				Obj.Flag = Props.Flag
				table.insert(SlayLib.Elements, Obj)

				return Obj
			end

			-- 3. DROPDOWN
			function Section:CreateDropdown(Props)
				Props = MergeDefaults(Props, {
					Name = "Dropdown",
					Options = {"Option 1"},
					Flag = "Drop_1",
					Multi = false,
					Max = nil,
					Default = nil,
					Callback = function() end,
					Tooltip = nil
				})

				local IsOpen = false
				local Selected

if Props.Multi then
	Selected = (type(Props.Default) == "table" and Props.Default) or {}
else
	Selected = Props.Default or Props.Options[1]
end
				local SearchText = ""

				local DContainer = Create("Frame", {
					Name = Props.Name .. "_Dropdown",
					Size = UDim2.new(1, 0, 0, 45),
					BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					BackgroundTransparency = 0.5,
					ClipsDescendants = true,
					ZIndex = 35,
					Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DContainer})
				local DStroke = Create("UIStroke", {Color = Color3.new(1,1,1), Thickness = 1, Transparency = 0.9, Parent = DContainer})
				AttachTooltip(DContainer, Props.Tooltip)
				table.insert(SearchItems, {Name = Props.Name, Frame = DContainer})

				local MainBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Text = "", ZIndex = 36, Parent = DContainer})

				local DLbl = Create("TextLabel", {
					Text = Props.Name .. ": None",
					Size = UDim2.new(1, -50, 0, 45),
					Position = UDim2.new(0, 15, 0, 0),
					Font = Enum.Font.GothamMedium,
					TextSize = 13,
					TextColor3 = SlayLib.Theme.TextSecondary,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextWrapped = true,
					LineHeight = 1.0,
					BackgroundTransparency = 1,
					ZIndex = 37,
					Parent = MainBtn
				})

				task.defer(function()
					local TextService = game:GetService("TextService")
					local bounds = TextService:GetTextSize(DLbl.Text, 13, Enum.Font.GothamMedium, Vector2.new(DLbl.AbsoluteSize.X, math.huge))
					if bounds.X > DLbl.AbsoluteSize.X then
						local ratio = DLbl.AbsoluteSize.X / bounds.X
						DLbl.TextSize = math.clamp(math.floor(13 * ratio), 11, 13)
					end
				end)

				local Chevron = Create("ImageLabel", {
					Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -30, 0.5, -7),
					Image = SlayLib.Icons.Chevron, BackgroundTransparency = 1,
					ImageColor3 = SlayLib.Theme.MainColor, ZIndex = 37, Parent = MainBtn
				})
				RegisterThemed(Chevron, "ImageColor3")

				local SearchInput = Create("TextBox", {
					Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 50),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					BackgroundTransparency = 0.5,
					PlaceholderText = "Search options...",
					Text = "",
					Font = "Gotham", TextSize = 12, TextColor3 = Color3.new(1,1,1),
					ZIndex = 38, Parent = DContainer,
					Visible = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SearchInput})

				local List = Create("ScrollingFrame", {
					Size = UDim2.new(1, -10, 0, 100), Position = UDim2.new(0, 5, 0, 90),
					BackgroundTransparency = 1, ScrollBarThickness = 0,
					CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 38, Parent = DContainer
				})
				Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 4)})

				local function GetSelectedCount()
					local count = 0
					if not Props.Multi then return 0 end
					for _, v in pairs(Selected) do if v then count = count + 1 end end
					return count
				end

				local function UpdateText()
					if Props.Multi then
						local Count = GetSelectedCount()
						local MaxStr = Props.Max and ("/" .. Props.Max) or ""
						DLbl.Text = tostring(Props.Name) .. ": " .. Count .. MaxStr .. " Selected"
					else
						DLbl.Text = tostring(Props.Name) .. ": " .. tostring(Selected or "None")
					end
				end

				local function RefreshOptions()
					for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end

					for _, option in pairs(Props.Options or {}) do
						local opt = tostring(option)
						if SearchText == "" or string.find(string.lower(opt), string.lower(SearchText)) then
							local Item = Create("TextButton", {
								Size = UDim2.new(1, 0, 0, 32),
								BackgroundColor3 = Color3.fromRGB(45, 45, 45),
								BackgroundTransparency = 0.8,
								Text = "  " .. opt,
								Font = "Gotham", TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 200),
								TextXAlignment = "Left", ZIndex = 39, Parent = List
							})
							Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Item})

							local function CheckHighlight()
								local IsActive = Props.Multi and Selected[opt] or Selected == opt
								Tween(Item, {
									BackgroundTransparency = IsActive and 0.4 or 0.8,
									TextColor3 = IsActive and SlayLib.Theme.MainColor or Color3.fromRGB(200, 200, 200)
								}, 0.2)
							end
							CheckHighlight()

							Item.MouseButton1Click:Connect(function()
								if Props.Multi then
									if not Selected[opt] and Props.Max and GetSelectedCount() >= Props.Max then
										Tween(DStroke, {Color = Color3.new(1, 0, 0)}, 0.1)
										task.wait(0.1)
										Tween(DStroke, {Color = SlayLib.Theme.MainColor}, 0.2)
										return
									end

									Selected = Selected or {}
Selected[opt] = not Selected[opt]
									CheckHighlight()
									task.spawn(Props.Callback, Selected)
								else
									Selected = opt
									IsOpen = false
									SearchInput.Visible = false
									Tween(DContainer, {Size = UDim2.new(1, 0, 0, 45)}, 0.3)
									Tween(Chevron, {Rotation = 0}, 0.3)
									DContainer.ZIndex = 35
									RefreshOptions()
									task.spawn(Props.Callback, Selected)
								end
								SlayLib.Flags[Props.Flag] = Selected
								UpdateText()
							end)
						end
					end
				end

				SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
					SearchText = SearchInput.Text
					RefreshOptions()
				end)

				MainBtn.MouseButton1Click:Connect(function()
					IsOpen = not IsOpen
					DContainer.ZIndex = IsOpen and 100 or 35
					SearchInput.Visible = IsOpen

					local TargetSize = IsOpen and UDim2.new(1, 0, 0, 200) or UDim2.new(1, 0, 0, 45)
					Tween(DContainer, {Size = TargetSize}, 0.4, Enum.EasingStyle.Quart)
					Tween(Chevron, {Rotation = IsOpen and 180 or 0}, 0.3)
					Tween(DStroke, {Transparency = IsOpen and 0.5 or 0.9, Color = IsOpen and SlayLib.Theme.MainColor or Color3.new(1,1,1)}, 0.3)

					if not IsOpen then
						SearchInput.Text = ""
					end
				end)

				RefreshOptions()
				UpdateText()
				SlayLib.Flags[Props.Flag] = Selected

				local Obj = {
					Refresh = function(NewOptions)
						if NewOptions then
							Props.Options = NewOptions
						end
						RefreshOptions()
						UpdateText()
					end,

					SetOptions = function(NewOptions)
						Props.Options = NewOptions or {}
						RefreshOptions()
						UpdateText()
					end,

					Set = function(_, Value)
						if Props.Multi then
							Selected = type(Value) == "table" and Value or {}
						else
							Selected = Value
						end

						UpdateText()
						RefreshOptions()

						SlayLib.Flags[Props.Flag] = Selected
						task.spawn(Props.Callback, Selected)
					end,

					Get = function()
						return Selected
					end,

					SetLimit = function(NewMax)
						Props.Max = NewMax
						UpdateText()
					end
				}

				Obj.Flag = Props.Flag
				table.insert(SlayLib.Elements, Obj)

				return Obj
			end

			-- 4. BUTTON
			function Section:CreateButton(Props)
				Props = MergeDefaults(Props, {Name = "Action Button", Callback = function() end, Tooltip = nil})

				local BFrame = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = SlayLib.Theme.Element,
					Text = "", ZIndex = 25, Parent = Page, AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BFrame})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = BFrame})
				AttachTooltip(BFrame, Props.Tooltip)
				table.insert(SearchItems, {Name = Props.Name, Frame = BFrame})

				local BLbl = Create("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0), Font = "GothamBold", TextSize = 13,
					TextColor3 = SlayLib.Theme.Text, BackgroundTransparency = 1, ZIndex = 26, Parent = BFrame
				})
				BLbl.Text = Props.Name

				BFrame.MouseButton1Click:Connect(function()
					local OldCol = BFrame.BackgroundColor3
					BFrame.BackgroundColor3 = SlayLib.Theme.MainColor
					Tween(BFrame, {BackgroundColor3 = OldCol}, 0.4)
					task.spawn(Props.Callback)
				end)
			end

			-- 5. INPUT BOX
			function Section:CreateInput(Props)
				-- [FIX] Added Flag support (was completely missing before, so
				-- input values could never be part of SlayLib.Flags / saved
				-- configs) and a safe default Callback.
				Props = MergeDefaults(Props, {Name = "Input Field", Placeholder = "Value...", Flag = nil, Callback = function() end, Tooltip = nil})

				local IContainer = Create("Frame", {
					Size = UDim2.new(1, 0, 0, 52),
					BackgroundColor3 = SlayLib.Theme.Element,
					ZIndex = 25,
					Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = IContainer})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = IContainer})
				AttachTooltip(IContainer, Props.Tooltip)
				table.insert(SearchItems, {Name = Props.Name, Frame = IContainer})

				local ILbl = Create("TextLabel", {
					Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 15, 0, 0),
					Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text,
					TextXAlignment = "Left", BackgroundTransparency = 1, ZIndex = 26, Parent = IContainer
				})
				ApplyTextLogic(ILbl, Props.Name, 14)

				local Box = Create("TextBox", {
					Size = UDim2.new(0, 160, 0, 30), Position = UDim2.new(1, -175, 0.5, -15),
					BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = "", PlaceholderText = Props.Placeholder,
					TextColor3 = SlayLib.Theme.MainColor, Font = "Gotham", TextSize = 13, ZIndex = 27, Parent = IContainer
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Box})
				RegisterThemed(Box, "TextColor3")

				if Props.Flag then
					SlayLib.Flags[Props.Flag] = Box.Text
				end

				Box.FocusLost:Connect(function(EnterPressed)
					if Props.Flag then
						SlayLib.Flags[Props.Flag] = Box.Text
					end
					task.spawn(Props.Callback, Box.Text)
				end)

				local Obj = {}
				function Obj:Set(v)
					Box.Text = tostring(v)
					if Props.Flag then
						SlayLib.Flags[Props.Flag] = Box.Text
					end
				end
				Obj.Flag = Props.Flag
				if Props.Flag then
					table.insert(SlayLib.Elements, Obj)
				end

				return Obj
			end

			-- 6. PARAGRAPH
			function Section:CreateParagraph(Props)
				Props = MergeDefaults(Props, {Title = "Information", Content = "Description here."})

				local PContainer = Create("Frame", {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundColor3 = SlayLib.Theme.Element,
					AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 25,
					Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = PContainer})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.7, Parent = PContainer})
				table.insert(SearchItems, {Name = Props.Title, Frame = PContainer})

				Create("UIPadding", {
					Parent = PContainer,
					PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15),
					PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)
				})

				local PLayout = Create("UIListLayout", {Parent = PContainer, SortOrder = "LayoutOrder", Padding = UDim.new(0, 4)})

				local PTtl = Create("TextLabel", {
					Size = UDim2.new(1, 0, 0, 18), Font = "GothamBold", TextSize = 14,
					TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1,
					TextXAlignment = "Left", ZIndex = 26, LayoutOrder = 1, Parent = PContainer
				})
				RegisterThemed(PTtl, "TextColor3")
				PTtl.Text = Props.Title

				local PCnt = Create("TextLabel", {
					Size = UDim2.new(1, 0, 0, 0), Font = "Gotham", TextSize = 13,
					TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1,
					TextXAlignment = "Left", TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 26, LayoutOrder = 2, Parent = PContainer
				})
				PCnt.Text = Props.Content
			end

			-- 7. [NEW] THEME SWITCHER
			-- A row of color swatches. Clicking one calls SlayLib:SetTheme(name)
			-- which live-recolors every registered accent across the whole UI.
			function Section:CreateThemeSwitcher(Props)
				Props = MergeDefaults(Props, {Name = "Theme"})

				local Container = Create("Frame", {
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundColor3 = SlayLib.Theme.Element,
					ZIndex = 25, Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Container})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = Container})
				table.insert(SearchItems, {Name = Props.Name, Frame = Container})

				local Lbl = Create("TextLabel", {
					Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(0, 15, 0, 0),
					Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text,
					TextXAlignment = "Left", BackgroundTransparency = 1, ZIndex = 26, Parent = Container
				})
				Lbl.Text = Props.Name

				local SwatchHolder = Create("Frame", {
					Size = UDim2.new(1, -115, 1, 0), Position = UDim2.new(0, 105, 0, 0),
					BackgroundTransparency = 1, ZIndex = 26, Parent = Container
				})
				Create("UIListLayout", {
					Parent = SwatchHolder, FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder
				})

				local Rings = {}
				for _, name in ipairs(SlayLib.ThemePresetOrder) do
					local color = SlayLib.ThemePresets[name]
					local Swatch = Create("TextButton", {
						Size = UDim2.new(0, 22, 0, 22), BackgroundColor3 = color, Text = "",
						ZIndex = 27, Parent = SwatchHolder, AutoButtonColor = false
					})
					Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Swatch})
					local Ring = Create("UIStroke", {
						Color = Color3.new(1, 1, 1), Thickness = 2,
						Transparency = (SlayLib.Theme.MainColor == color) and 0 or 1,
						Parent = Swatch
					})
					Rings[name] = Ring
					AttachTooltip(Swatch, name)

					Swatch.MouseButton1Click:Connect(function()
						SlayLib:SetTheme(name)
						for n, r in pairs(Rings) do
							Tween(r, {Transparency = (n == name) and 0 or 1}, 0.2)
						end
					end)
				end
			end

			-- 8. [NEW] POPUP CONFIG SELECTOR
			-- Adds a "save as" row plus a "..." button that opens a modal
			-- popup listing every config saved via SlayLib:SaveConfig, with
			-- Load / Delete actions per entry.
			function Section:CreateConfigManager(Props)
				Props = MergeDefaults(Props, {Name = "Config Manager"})

				local Container = Create("Frame", {
					Size = UDim2.new(1, 0, 0, 52),
					BackgroundColor3 = SlayLib.Theme.Element,
					ZIndex = 25, Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Container})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = Container})
				table.insert(SearchItems, {Name = Props.Name, Frame = Container})

				local NameBox = Create("TextBox", {
					Size = UDim2.new(1, -140, 0, 30), Position = UDim2.new(0, 15, 0.5, -15),
					BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = "", PlaceholderText = "Config name...",
					TextColor3 = SlayLib.Theme.MainColor, Font = "Gotham", TextSize = 13, ZIndex = 26, Parent = Container
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = NameBox})
				RegisterThemed(NameBox, "TextColor3")

				local SaveBtn = Create("TextButton", {
					Size = UDim2.new(0, 58, 0, 30), Position = UDim2.new(1, -120, 0.5, -15),
					BackgroundColor3 = SlayLib.Theme.MainColor, Text = "Save", Font = "GothamBold", TextSize = 12,
					TextColor3 = Color3.new(1, 1, 1), ZIndex = 26, Parent = Container, AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SaveBtn})
				RegisterThemed(SaveBtn, "BackgroundColor3")

				local ManageBtn = Create("TextButton", {
					Size = UDim2.new(0, 54, 0, 30), Position = UDim2.new(1, -58, 0.5, -15),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40), Text = "...", Font = "GothamBold", TextSize = 16,
					TextColor3 = SlayLib.Theme.Text, ZIndex = 26, Parent = Container, AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ManageBtn})
				AttachTooltip(ManageBtn, "Browse saved configs")

				SaveBtn.MouseButton1Click:Connect(function()
					local nm = NameBox.Text
					if nm == "" then
						SlayLib:Notify({Title = "System", Content = "Type a config name first", Type = "Warning", Duration = 3})
						return
					end
					SlayLib:SaveConfig(nm)
				end)

				local function OpenPopup()
					local Existing = game:GetService("CoreGui"):FindFirstChild("SlayConfigPopup")
					if Existing then Existing:Destroy() end

					local PopupGui = Create("ScreenGui", {
						Name = "SlayConfigPopup", Parent = game:GetService("CoreGui"),
						DisplayOrder = 99999, IgnoreGuiInset = true
					})

					local Dim = Create("Frame", {
						Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
						BackgroundTransparency = 1, ZIndex = 1, Parent = PopupGui
					})
					Tween(Dim, {BackgroundTransparency = 0.45}, 0.25)
					local CloseArea = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 1, Parent = Dim})

					local Panel = Create("Frame", {
						Size = UDim2.new(0, 300, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
						AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
						BackgroundColor3 = Color3.fromRGB(22, 22, 24), ZIndex = 2, Parent = PopupGui
					})
					Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Panel})
					local PanelStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.2, Transparency = 0.4, Parent = Panel})
					RegisterThemed(PanelStroke, "Color")
					Create("UIPadding", {
						PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
						PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = Panel
					})
					Create("UIListLayout", {Parent = Panel, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})

					local Header = Create("TextLabel", {
						Size = UDim2.new(1, 0, 0, 20), Text = "SAVED CONFIGS", Font = "GothamBold", TextSize = 13,
						TextColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1, TextXAlignment = "Left",
						LayoutOrder = 1, ZIndex = 3, Parent = Panel
					})
					RegisterThemed(Header, "TextColor3")

					local List = Create("ScrollingFrame", {
						Size = UDim2.new(1, 0, 0, 180), BackgroundTransparency = 1, ScrollBarThickness = 3,
						ScrollBarImageColor3 = SlayLib.Theme.MainColor, CanvasSize = UDim2.new(0, 0, 0, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3, LayoutOrder = 2, Parent = Panel
					})
					Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})

					local function RefreshList()
						for _, c in pairs(List:GetChildren()) do
							if c:IsA("Frame") then c:Destroy() end
						end

						local configs = SlayLib:ListConfigs()
						if #configs == 0 then
							Create("TextLabel", {
								Size = UDim2.new(1, 0, 0, 30), Text = "No saved configs yet", Font = "Gotham", TextSize = 12,
								TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1, ZIndex = 4, Parent = List
							})
							return
						end

						for _, cname in ipairs(configs) do
							local Row = Create("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(32, 32, 34), ZIndex = 4, Parent = List})
							Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Row})
							Create("TextLabel", {
								Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = cname,
								Font = "GothamMedium", TextSize = 12, TextColor3 = SlayLib.Theme.Text, TextXAlignment = "Left",
								BackgroundTransparency = 1, ZIndex = 5, Parent = Row
							})
							local LoadBtn = Create("TextButton", {
								Size = UDim2.new(0, 32, 0, 24), Position = UDim2.new(1, -72, 0.5, -12),
								BackgroundColor3 = SlayLib.Theme.MainColor, Text = "Load", TextSize = 10, Font = "GothamBold",
								TextColor3 = Color3.new(1, 1, 1), ZIndex = 5, Parent = Row, AutoButtonColor = false
							})
							Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = LoadBtn})
							RegisterThemed(LoadBtn, "BackgroundColor3")

							local DelBtn = Create("TextButton", {
								Size = UDim2.new(0, 32, 0, 24), Position = UDim2.new(1, -36, 0.5, -12),
								BackgroundColor3 = SlayLib.Theme.Error, Text = "Del", TextSize = 10, Font = "GothamBold",
								TextColor3 = Color3.new(1, 1, 1), ZIndex = 5, Parent = Row, AutoButtonColor = false
							})
							Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DelBtn})

							LoadBtn.MouseButton1Click:Connect(function()
								SlayLib:LoadConfig(cname)
							end)
							DelBtn.MouseButton1Click:Connect(function()
								SlayLib:DeleteConfig(cname)
								RefreshList()
							end)
						end
					end
					RefreshList()

					local CloseBtn = Create("TextButton", {
						Size = UDim2.new(1, 0, 0, 32), Text = "Close", Font = "GothamBold", TextSize = 13,
						BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = SlayLib.Theme.Text,
						ZIndex = 3, LayoutOrder = 3, Parent = Panel, AutoButtonColor = false
					})
					Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseBtn})

					local function ClosePopup()
						Tween(Dim, {BackgroundTransparency = 1}, 0.2)
						task.delay(0.2, function()
							if PopupGui then PopupGui:Destroy() end
						end)
					end
					CloseBtn.MouseButton1Click:Connect(ClosePopup)
					CloseArea.MouseButton1Click:Connect(ClosePopup)
				end

				ManageBtn.MouseButton1Click:Connect(OpenPopup)
			end

			return Section
		end -- จบ Section
		return Tab
	end -- จบ CreateTab

	return Window
end -- จบ CreateWindow

--// AUTO-SAVE LOGIC
function SlayLib:SaveConfig(Name)
	-- [FIX] Wrapped in pcall: writefile can throw (invalid filename, disk
	-- issues, executor restrictions) which previously would hard-crash the
	-- whole script instead of just failing the save gracefully.
	local ok, err = pcall(function()
		local FullPath = SlayLib.Folder .. "/" .. Name .. ".json"
		local Data = HttpService:JSONEncode(SlayLib.Flags)
		pcall(function()
	writefile(FullPath, Data)
end)
	end)

	if ok then
		SlayLib:Notify({
			Title = "System",
			Content = "Config Saved Successfully!",
			Type = "Success",
			Duration = 3
		})
	else
		SlayLib:Notify({
			Title = "System",
			Content = "Failed to save config: " .. tostring(err),
			Type = "Error",
			Duration = 4
		})
	end
end

function SlayLib:LoadConfig(Name)
	local FullPath = SlayLib.Folder .. "/" .. Name .. ".json"

	if not isfile(FullPath) then
		SlayLib:Notify({Title = "System", Content = "Config not found!", Type = "Error", Duration = 3})
		return
	end

	-- [FIX] Wrapped in pcall: a corrupted/edited-by-hand JSON file used to
	-- throw inside JSONDecode and hard-crash the script instead of showing
	-- a clean error notification.
	local ok, data = pcall(function()
	return HttpService:JSONDecode(readfile(FullPath))
end)

	if not ok then
		SlayLib:Notify({Title = "System", Content = "Config file is corrupted!", Type = "Error", Duration = 4})
		return
	end

	if type(DataOrErr) ~= "table" then return end
	SlayLib:Notify({Title = "System", Content = "Config Loaded!", Type = "Success", Duration = 3})

	for k, v in pairs(DataOrErr) do
	SlayLib.Flags[k] = v
end

for _, el in ipairs(SlayLib.Elements or {}) do
	if el.Flag and el.Set then
		local value = SlayLib.Flags[el.Flag]
		if value ~= nil then
			el:Set(value)
		end
	end
end
end

-- [NEW] Used by the popup config manager's delete button.
function SlayLib:DeleteConfig(Name)
	local FullPath = SlayLib.Folder .. "/" .. Name .. ".json"
	local ok = pcall(function()
		if isfile(FullPath) then
			pcall(function()
	if isfile(FullPath) then
		delfile(FullPath)
	end
end)
		end
	end)
	if ok then
		SlayLib:Notify({Title = "System", Content = "Config Deleted", Type = "Warning", Duration = 3})
	else
		SlayLib:Notify({Title = "System", Content = "Failed to delete config!", Type = "Error", Duration = 3})
	end
end

return SlayLib
