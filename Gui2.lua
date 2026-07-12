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
	if obj.Name == "SlayLib_X_Engine" or obj.Name == "SlayLoadingEnv" or obj.Name == "SlayNotifFinal"
		or obj.Name == "SlayTooltipGui" or obj.Name == "SlayConfigPopup" or obj.Name == "SlayKeySystem" then
		obj:Destroy()
	end
end
if Lighting:FindFirstChild("SlayBlur") then Lighting.SlayBlur:Destroy() end
if Lighting:FindFirstChild("Blur") then Lighting.Blur:Destroy() end
if Lighting:FindFirstChild("SlayKeyBlur") then Lighting.SlayKeyBlur:Destroy() end

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

--// [NEW] AUTOLOAD MARKER
-- A tiny separate file that just holds the name of the config to load
-- automatically next time CreateWindow runs. Kept apart from the configs
-- themselves so it's trivial to read before anything else has to happen.
local AUTOLOAD_MARKER = SlayLib.Folder .. "/_autoload.txt"

function SlayLib:SetAutoloadConfig(Name)
	pcall(function()
		if Name then
			writefile(AUTOLOAD_MARKER, Name)
		elseif isfile(AUTOLOAD_MARKER) then
			delfile(AUTOLOAD_MARKER)
		end
	end)
end

function SlayLib:GetAutoloadConfig()
	if not isfile(AUTOLOAD_MARKER) then return nil end
	local ok, name = pcall(readfile, AUTOLOAD_MARKER)
	if ok and name and name ~= "" then
		return name
	end
	return nil
end

--// [NEW] DYNAMIC TEXT SYSTEM
-- SlayLib:FormatDynamic("Uptime: {uptime} | {fps} FPS") replaces every
-- {placeholder} with a live value. Built-ins: {uptime} {time} {date} {fps}
-- {ping} {player}. Add your own anywhere: SlayLib.DynamicVars.Gold = function()
-- return tostring(getGold()) end, then use "{Gold}" in any Paragraph/Watermark
-- text (with Props.Dynamic = true so it keeps refreshing).
SlayLib._StartTime = os.clock()
SlayLib.DynamicVars = {}

local _fpsSamples = {}
RunService.Heartbeat:Connect(function(dt)
	if dt and dt > 0 then
		table.insert(_fpsSamples, 1 / dt)
		if #_fpsSamples > 30 then table.remove(_fpsSamples, 1) end
	end
end)

SlayLib.DynamicVars.uptime = function()
	local total = math.floor(os.clock() - SlayLib._StartTime)
	local h, m, s = math.floor(total / 3600), math.floor((total % 3600) / 60), total % 60
	if h > 0 then return string.format("%02d:%02d:%02d", h, m, s) end
	return string.format("%02d:%02d", m, s)
end
SlayLib.DynamicVars.time = function() return os.date("%H:%M:%S") end
SlayLib.DynamicVars.date = function() return os.date("%Y-%m-%d") end
SlayLib.DynamicVars.fps = function()
	if #_fpsSamples == 0 then return "0" end
	local sum = 0
	for _, v in ipairs(_fpsSamples) do sum += v end
	return tostring(math.floor(sum / #_fpsSamples))
end
SlayLib.DynamicVars.ping = function()
	local ok, val = pcall(function()
		return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
	end)
	return ok and tostring(val) or "?"
end
SlayLib.DynamicVars.player = function() return LocalPlayer.Name end

function SlayLib:FormatDynamic(template)
	if type(template) ~= "string" then return template end
	local ok, result = pcall(function()
		return (template:gsub("{(%w+)}", function(key)
			local fn = SlayLib.DynamicVars[key]
			if not fn then return "{" .. key .. "}" end
			local ok2, val = pcall(fn)
			if ok2 and val ~= nil then return tostring(val) end
			return "{" .. key .. "}"
		end))
	end)
	return ok and result or template
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
--// [UPGRADE] Table-type defaults (e.g. Options = {"Option 1"}) are now
--// deep-copied per call instead of shared by reference — otherwise every
--// element created without its own Options table would silently share (and
--// could mutate) the exact same table as every other element using that
--// default.
local function DeepCopy(t)
	local new = {}
	for k, v in pairs(t) do
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

--// [NEW] DEBUG MODE
-- Set SlayLib.Debug = true to get warn() output for internal issues that are
-- otherwise silently handled (e.g. a Dropdown Options entry that isn't a
-- string/number/boolean). Off by default so normal use stays quiet.
SlayLib.Debug = false
local function DebugWarn(msg)
	if SlayLib.Debug then
		warn("[SlayLib] " .. tostring(msg))
	end
end

--// [NEW] DEPENDENT VISIBILITY
-- Any element's Props can include DependsOn = <another element's Obj> and
-- optionally DependsValue (default true). The element's container is then
-- shown/hidden automatically whenever the depended-on Toggle/Dropdown
-- changes, and set correctly right away based on its current value.
local function BindVisibility(Container, DependsOn, DependsValue)
	if not DependsOn or not DependsOn.Changed then return end
	if DependsValue == nil then DependsValue = true end

	local function Apply(v)
		Container.Visible = (v == DependsValue)
	end
	table.insert(DependsOn.Changed, Apply)

	if DependsOn.Flag and SlayLib.Flags[DependsOn.Flag] ~= nil then
		Apply(SlayLib.Flags[DependsOn.Flag])
	end
end

--// [NEW] HOVER FEEDBACK
-- Subtle background tween between Theme.Element and Theme.ElementHover (a
-- theme color that existed but was never actually used anywhere before).
-- Gives every interactive row a bit of life on desktop/mouse without
-- affecting touch devices (MouseEnter/MouseLeave simply never fire there).
local function ApplyHover(Container)
	Container.MouseEnter:Connect(function()
		Tween(Container, {BackgroundColor3 = SlayLib.Theme.ElementHover}, 0.15)
	end)
	Container.MouseLeave:Connect(function()
		Tween(Container, {BackgroundColor3 = SlayLib.Theme.Element}, 0.15)
	end)
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
		if not parent then TipFrame:Destroy() end
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
local function RegisterDrag(Frame, Handle, OnEnd)
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
					-- [NEW] Lets callers (e.g. window/toggle position memory) react
					-- once a drag finishes, without needing their own InputEnded plumbing.
					if OnEnd then OnEnd(Frame.Position) end
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
	-- [FIX] Default Duration lowered from 6s to 3s per feedback: a forgotten
	-- Duration used to seem like it barely flashed on screen before this fix
	-- (see MergeDefaults history above) — 3s now reads as a deliberate, quick
	-- toast rather than a glitch.
	Config = MergeDefaults(Config, {Title = "SYSTEM", Content = "Message Content", Duration = 3, Type = "Neutral"})

	local NotifColor = SlayLib.Theme.MainColor
	local Glyph = "•"
	if Config.Type == "Success" then NotifColor = SlayLib.Theme.Success; Glyph = "✓"
	elseif Config.Type == "Error" then NotifColor = SlayLib.Theme.Error; Glyph = "✕"
	elseif Config.Type == "Warning" then NotifColor = SlayLib.Theme.Warning; Glyph = "!" end

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

	-- [REDESIGN] Nicer notification card: solid dark card with a thin colored
	-- accent bar on the left, a circular icon badge with a glyph matching
	-- Type (✓/✕/!/•), title + message stacked next to it, and a slim
	-- countdown bar along the bottom.
	local NotifFrame = Create("CanvasGroup", {
		Size = UDim2.new(0.001, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(24, 24, 27),
		GroupTransparency = 1,
		ClipsDescendants = true,
		Parent = Holder
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = NotifFrame})
	Create("UIStroke", {Color = NotifColor, Transparency = 0.55, Thickness = 1, Parent = NotifFrame})

	local AccentBar = Create("Frame", {
		Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = NotifColor, BorderSizePixel = 0, ZIndex = 2, Parent = NotifFrame
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = AccentBar})

	local Row = Create("Frame", {
		Size = UDim2.new(1, -16, 0, 0), Position = UDim2.new(0, 16, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 2, Parent = NotifFrame
	})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 18),
		PaddingRight = UDim.new(0, 14), Parent = Row
	})
	Create("UIListLayout", {
		Parent = Row, FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local IconBadge = Create("Frame", {
		Size = UDim2.new(0, 28, 0, 28), BackgroundColor3 = NotifColor, BackgroundTransparency = 0.82,
		ZIndex = 3, Parent = Row
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = IconBadge})
	Create("TextLabel", {
		Text = Glyph, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = NotifColor,
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 4, Parent = IconBadge
	})

	local TextColumn = Create("Frame", {
		Size = UDim2.new(1, -38, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, ZIndex = 3, Parent = Row
	})
	Create("UIListLayout", {Parent = TextColumn, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder})

	Create("TextLabel", {
		Text = Config.Title:upper(), Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = NotifColor, BackgroundTransparency = 1, TextXAlignment = "Left",
		Size = UDim2.new(1, 0, 0, 16), ZIndex = 4, Parent = TextColumn
	})
	Create("TextLabel", {
		Text = Config.Content, Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = Color3.fromRGB(215, 215, 215), BackgroundTransparency = 1,
		TextXAlignment = "Left", TextWrapped = true, Size = UDim2.new(1, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 4, Parent = TextColumn
	})

	local BarContainer = Create("Frame", {
		Size = UDim2.new(1, -16, 0, 3), Position = UDim2.new(0.5, 0, 1, -6),
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = 2, Parent = NotifFrame
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarContainer})
	local BarFill = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = NotifColor, BorderSizePixel = 0, ZIndex = 3, Parent = BarContainer
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarFill})

	-- [FIX] Removed the old manual "wait until TextArea reports a height"
	-- timing hack entirely — AutomaticSize already gives the correct height
	-- the instant the labels are created, so entrance/exit only needs to
	-- animate width + fade, which is both simpler and impossible to get
	-- stuck at height 0.
	Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 0}, 0.35, Enum.EasingStyle.Back)
	Tween(BarFill, {Size = UDim2.new(0, 0, 1, 0)}, Config.Duration, Enum.EasingStyle.Linear)

	task.spawn(function()
		task.wait(Config.Duration)
		if not NotifFrame.Parent then return end
		local ExitTween = Tween(NotifFrame, {Size = UDim2.new(0.001, 0, 0, 0), GroupTransparency = 1}, 0.3, Enum.EasingStyle.Quart)
		ExitTween.Completed:Connect(function()
			if NotifFrame then NotifFrame:Destroy() end
		end)
	end)
end

--// [NEW] KEY SYSTEM
-- SlayLib:CreateKeySystem(Config, OnSuccess) shows a blocking key-entry
-- popup before the rest of your script runs. Put everything that should be
-- gated behind the key (including SlayLib:CreateWindow) inside OnSuccess.
--
-- Config fields (all optional except when Enabled is true you'll want at
-- least one of Keys/KeyURL/Validator, otherwise nothing will ever validate):
--   Enabled       (bool, default true)  — set false to skip the whole thing;
--                  OnSuccess just runs immediately, no key needed at all.
--   Title         (string) — popup heading
--   Subtitle      (string) — short instruction line
--   Note          (string, optional) — small print under the buttons
--   Keys          (array<string>, optional) — static valid keys, works fully offline
--   KeyURL        (string, optional) — URL returning valid keys as plain text
--                  (comma/whitespace/newline separated), fetched via game:HttpGet
--   GetKeyURL     (string, optional) — shows a "Get Key" button that copies
--                  this link to the clipboard
--   SaveKey       (bool, default true) — remember a valid key locally so the
--                  popup is skipped on future runs as long as it's still valid
--   CaseSensitive (bool, default true)
--   Validator     (function(key) -> boolean, optional) — custom check, runs
--                  before Keys/KeyURL; return true to accept immediately
function SlayLib:CreateKeySystem(Config, OnSuccess)
	Config = MergeDefaults(Config, {
		Enabled = true,
		Title = "Key System",
		Subtitle = "Enter your key to continue",
		Note = nil,
		Keys = {},
		KeyURL = nil,
		GetKeyURL = nil,
		SaveKey = true,
		CaseSensitive = true,
		Validator = nil
	})
	OnSuccess = OnSuccess or function() end

	if not Config.Enabled then
		OnSuccess()
		return
	end

	local KEY_FILE = SlayLib.Folder .. "/_key.txt"

	local function Normalize(k)
		k = tostring(k or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if not Config.CaseSensitive then k = k:lower() end
		return k
	end

	local function CheckAgainstList(list, inputKey)
		local norm = Normalize(inputKey)
		for _, k in ipairs(list) do
			if Normalize(k) == norm then return true end
		end
		return false
	end

	local function ValidateKey(inputKey)
		if inputKey == nil or inputKey == "" then return false end

		if Config.Validator then
			local ok, result = pcall(Config.Validator, inputKey)
			if ok and result then return true end
		end

		if Config.KeyURL then
			local ok, body = pcall(function()
				return game:HttpGet(Config.KeyURL)
			end)
			if ok and body then
				local list = {}
				for k in body:gmatch("[^,%s]+") do
					table.insert(list, k)
				end
				if CheckAgainstList(list, inputKey) then return true end
			else
				DebugWarn("KeySystem: failed to fetch KeyURL — " .. tostring(body))
			end
		end

		if #Config.Keys > 0 and CheckAgainstList(Config.Keys, inputKey) then
			return true
		end

		return false
	end

	-- A still-valid saved key skips the popup entirely.
	if Config.SaveKey and isfile(KEY_FILE) then
		local ok, saved = pcall(readfile, KEY_FILE)
		if ok and saved and saved ~= "" and ValidateKey(saved) then
			OnSuccess()
			return
		end
	end

	local ExistingGui = game:GetService("CoreGui"):FindFirstChild("SlayKeySystem")
	if ExistingGui then ExistingGui:Destroy() end

	local KeyGui = Create("ScreenGui", {
		Name = "SlayKeySystem", Parent = game:GetService("CoreGui"),
		DisplayOrder = 999998, IgnoreGuiInset = true
	})

	local KeyBlur = Instance.new("BlurEffect", game:GetService("Lighting"))
	KeyBlur.Name = "SlayKeyBlur"
	KeyBlur.Size = 0
	Tween(KeyBlur, {Size = 20}, 0.6)

	local Dim = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, ZIndex = 1, Parent = KeyGui
	})
	Tween(Dim, {BackgroundTransparency = 0.4}, 0.4)

	local Panel = Create("Frame", {
		Size = UDim2.new(0, 320, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.45, 0),
		BackgroundColor3 = Color3.fromRGB(18, 18, 20), ZIndex = 2, Parent = KeyGui
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Panel})
	local PanelStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.2, Transparency = 0.4, Parent = Panel})
	RegisterThemed(PanelStroke, "Color")
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 24), PaddingBottom = UDim.new(0, 24),
		PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 22), Parent = Panel
	})
	Create("UIListLayout", {
		Parent = Panel, Padding = UDim.new(0, 12),
		HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder
	})

	local LogoImg = Create("ImageLabel", {
		Size = UDim2.new(0, 44, 0, 44), Image = SlayLib.Icons.Logo,
		ImageColor3 = SlayLib.Theme.MainColor, BackgroundTransparency = 1,
		ZIndex = 3, LayoutOrder = 1, Parent = Panel
	})
	RegisterThemed(LogoImg, "ImageColor3")

	Create("TextLabel", {
		Text = Config.Title, Font = Enum.Font.GothamBold, TextSize = 18,
		TextColor3 = SlayLib.Theme.Text, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22), ZIndex = 3, LayoutOrder = 2, Parent = Panel
	})

	Create("TextLabel", {
		Text = Config.Subtitle, Font = Enum.Font.Gotham, TextSize = 13,
		TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1,
		TextWrapped = true, Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 3, LayoutOrder = 3, Parent = Panel
	})

	local InputBox = Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(26, 26, 29),
		Text = "", PlaceholderText = "Enter key...", TextColor3 = SlayLib.Theme.MainColor,
		Font = Enum.Font.Code, TextSize = 14, ZIndex = 3, LayoutOrder = 4, Parent = Panel,
		ClearTextOnFocus = false
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = InputBox})
	local InputStroke = Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.5, Parent = InputBox})
	RegisterThemed(InputBox, "TextColor3")

	local ErrorLbl = Create("TextLabel", {
		Text = "", Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = SlayLib.Theme.Error, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16), ZIndex = 3, LayoutOrder = 5, Parent = Panel, Visible = false
	})

	local BtnRow = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, ZIndex = 3, LayoutOrder = 6, Parent = Panel
	})
	Create("UIListLayout", {
		Parent = BtnRow, FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder
	})

	local hasGetKey = Config.GetKeyURL ~= nil
	local SubmitBtn = Create("TextButton", {
		Size = hasGetKey and UDim2.new(0.62, -4, 1, 0) or UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = SlayLib.Theme.MainColor, Text = "Submit", Font = Enum.Font.GothamBold,
		TextSize = 14, TextColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = BtnRow, AutoButtonColor = false
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SubmitBtn})
	RegisterThemed(SubmitBtn, "BackgroundColor3")

	if hasGetKey then
		local GetKeyBtn = Create("TextButton", {
			Size = UDim2.new(0.38, -4, 1, 0), BackgroundColor3 = Color3.fromRGB(35, 35, 38),
			Text = "Get Key", Font = Enum.Font.GothamBold, TextSize = 13,
			TextColor3 = SlayLib.Theme.Text, ZIndex = 3, Parent = BtnRow, AutoButtonColor = false
		})
		Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = GetKeyBtn})
		GetKeyBtn.MouseButton1Click:Connect(function()
			local ok = pcall(function() setclipboard(Config.GetKeyURL) end)
			SlayLib:Notify({
				Title = "Key System",
				Content = ok and "Link copied to clipboard!" or ("Copy this: " .. Config.GetKeyURL),
				Type = ok and "Success" or "Warning", Duration = 4
			})
		end)
	end

	if Config.Note then
		Create("TextLabel", {
			Text = Config.Note, Font = Enum.Font.Gotham, TextSize = 11,
			TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1,
			TextWrapped = true, Size = UDim2.new(1, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 3, LayoutOrder = 7, Parent = Panel
		})
	end

	local Checking = false
	local function AttemptSubmit()
		if Checking then return end
		local key = InputBox.Text
		if key == "" then
			ErrorLbl.Text = "Please enter a key"
			ErrorLbl.Visible = true
			return
		end

		Checking = true
		SubmitBtn.Text = "Checking..."
		ErrorLbl.Visible = false

		task.spawn(function()
			local valid = ValidateKey(key)
			Checking = false
			SubmitBtn.Text = "Submit"

			if valid then
				if Config.SaveKey then
					pcall(writefile, KEY_FILE, key)
				end
				Tween(Dim, {BackgroundTransparency = 1}, 0.3)
				Tween(KeyBlur, {Size = 0}, 0.3)
				task.wait(0.3)
				KeyGui:Destroy()
				KeyBlur:Destroy()
				OnSuccess()
			else
				ErrorLbl.Text = "Invalid key. Try again."
				ErrorLbl.Visible = true
				Tween(InputStroke, {Color = SlayLib.Theme.Error, Transparency = 0}, 0.1)
				task.wait(0.6)
				Tween(InputStroke, {Color = SlayLib.Theme.Stroke, Transparency = 0.5}, 0.3)
			end
		end)
	end

	SubmitBtn.MouseButton1Click:Connect(AttemptSubmit)
	InputBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then AttemptSubmit() end
	end)
end

--// LOADING SEQUENCE (HIGH FIDELITY)
local function ExecuteFinalSovereign()
	local TweenService = game:GetService("TweenService")
	local Lighting = game:GetService("Lighting")
	local Debris = game:GetService("Debris")

	local TOTAL_DURATION = 2.6

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
	MainFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
	MainFrame.BorderSizePixel = 0
	MainFrame.BackgroundTransparency = 1

	-- [REDESIGN] Three-stop gradient that slowly drifts rotation the whole
	-- time the screen is up, instead of a flat/static background.
	local BGGradient = Instance.new("UIGradient", MainFrame)
	BGGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 6, 14)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 10, 26)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 8, 16))
	})
	BGGradient.Rotation = 20
	task.spawn(function()
		while MainFrame.Parent do
			TweenService:Create(BGGradient, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 110}):Play()
			task.wait(4)
			if not MainFrame.Parent then break end
			TweenService:Create(BGGradient, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 20}):Play()
			task.wait(4)
		end
	end)

	local Hub = Instance.new("Frame", MainFrame)
	Hub.AnchorPoint = Vector2.new(0.5, 0.5)
	Hub.Position = UDim2.new(0.5, 0, 0.5, 0)
	Hub.Size = UDim2.new(0, 400, 0, 400)
	Hub.BackgroundTransparency = 1

	-- [NEW] Orbit ring: a set of small dots arranged in a circle around the
	-- logo. They're all children of one holder frame, so continuously
	-- spinning the holder's Rotation spins the whole ring for free.
	local RingHolder = Instance.new("Frame", Hub)
	RingHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	RingHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
	RingHolder.Size = UDim2.new(0, 1, 0, 1)
	RingHolder.BackgroundTransparency = 1

	local DOT_COUNT, RING_RADIUS = 10, 150
	local Dots = {}
	for i = 1, DOT_COUNT do
		local angle = (i / DOT_COUNT) * math.pi * 2
		local dot = Instance.new("Frame", RingHolder)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Size = UDim2.new(0, 6, 0, 6)
		dot.Position = UDim2.new(0.5, math.cos(angle) * RING_RADIUS, 0.5, math.sin(angle) * RING_RADIUS)
		dot.BackgroundColor3 = SlayLib.Theme.MainColor
		dot.BackgroundTransparency = 1
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
		table.insert(Dots, dot)
	end

	task.spawn(function()
		-- Ring materializes dot by dot instead of popping in all at once.
		for _, dot in ipairs(Dots) do
			if not dot.Parent then break end
			TweenService:Create(dot, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
			task.wait(0.05)
		end
	end)

	task.spawn(function()
		while RingHolder.Parent do
			TweenService:Create(RingHolder, TweenInfo.new(4, Enum.EasingStyle.Linear), {Rotation = RingHolder.Rotation + 360}):Play()
			task.wait(4)
		end
	end)

	local Logo = Instance.new("ImageLabel", Hub)
	Logo.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
	Logo.Size = UDim2.new(0, 0, 0, 0)
	Logo.Image = SlayLib.Icons.Logofull
	Logo.BackgroundTransparency = 1
	Logo.ImageTransparency = 1
	Logo.ZIndex = 5

	-- Soft breathing glow around the logo while it's on screen.
	local LogoGlow = Instance.new("UIStroke", Logo)
	LogoGlow.Color = SlayLib.Theme.MainColor
	LogoGlow.Thickness = 3
	LogoGlow.Transparency = 1
	task.spawn(function()
		while Logo.Parent do
			TweenService:Create(LogoGlow, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {Transparency = 0.35}):Play()
			task.wait(0.9)
			if not Logo.Parent then break end
			TweenService:Create(LogoGlow, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {Transparency = 0.9}):Play()
			task.wait(0.9)
		end
	end)

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
	Status.Position = UDim2.new(0.5, 0, 0.83, 0)
	Status.Size = UDim2.new(0, 500, 0, 20)
	Status.Font = Enum.Font.Code
	Status.TextColor3 = SlayLib.Theme.MainColor
	Status.TextSize = 14
	Status.BackgroundTransparency = 1
	Status.TextTransparency = 1
	Status.Text = ""

	-- [REDESIGN] Progress bar now has a two-tone gradient fill (accent color
	-- fading into a lighter tint) instead of a flat color, plus a live
	-- percentage readout underneath synced to real elapsed time.
	local ProgressTrack = Instance.new("Frame", MainFrame)
	ProgressTrack.AnchorPoint = Vector2.new(0.5, 0.5)
	ProgressTrack.Position = UDim2.new(0.5, 0, 0.88, 0)
	ProgressTrack.Size = UDim2.new(0, 190, 0, 4)
	ProgressTrack.BackgroundColor3 = Color3.new(1, 1, 1)
	ProgressTrack.BackgroundTransparency = 0.9
	ProgressTrack.BorderSizePixel = 0
	Instance.new("UICorner", ProgressTrack).CornerRadius = UDim.new(1, 0)

	local ProgressFill = Instance.new("Frame", ProgressTrack)
	ProgressFill.Size = UDim2.new(0, 0, 1, 0)
	ProgressFill.BackgroundColor3 = SlayLib.Theme.MainColor
	ProgressFill.BorderSizePixel = 0
	Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)
	local ProgressGradient = Instance.new("UIGradient", ProgressFill)
	ProgressGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, SlayLib.Theme.MainColor),
		ColorSequenceKeypoint.new(1, SlayLib.Theme.MainColor:Lerp(Color3.new(1, 1, 1), 0.5))
	})
	TweenService:Create(ProgressFill, TweenInfo.new(TOTAL_DURATION, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()

	local PercentLabel = Instance.new("TextLabel", MainFrame)
	PercentLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	PercentLabel.Position = UDim2.new(0.5, 0, 0.93, 0)
	PercentLabel.Size = UDim2.new(0, 100, 0, 16)
	PercentLabel.BackgroundTransparency = 1
	PercentLabel.Font = Enum.Font.Code
	PercentLabel.TextSize = 11
	PercentLabel.TextColor3 = SlayLib.Theme.TextSecondary
	PercentLabel.TextTransparency = 1
	PercentLabel.Text = "0%"
	TweenService:Create(PercentLabel, TweenInfo.new(0.4), {TextTransparency = 0.35}):Play()

	local StartClock = os.clock()
	task.spawn(function()
		while PercentLabel.Parent do
			local pct = math.clamp(math.floor(((os.clock() - StartClock) / TOTAL_DURATION) * 100), 0, 100)
			PercentLabel.Text = pct .. "%"
			if pct >= 100 then break end
			task.wait(0.05)
		end
	end)

	local Phrases = {"INITIALIZING", "LOADING MODULES", "PREPARING INTERFACE", "READY"}
	local PerPhrase = TOTAL_DURATION / #Phrases
	for i, phrase in ipairs(Phrases) do
		Status.Text = phrase
		TweenService:Create(Status, TweenInfo.new(0.2), {TextTransparency = 0.15}):Play()
		task.wait(math.max(PerPhrase - 0.2, 0.05))
		TweenService:Create(Status, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
		task.wait(0.2)
	end

	pcall(function()
		local FinalInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		TweenService:Create(Logo, FinalInfo, {
			Size = UDim2.new(0, 2, 0, 2000),
			ImageTransparency = 1
		}):Play()

		-- [NEW] The ring spins up hard and collapses inward as part of the exit.
		TweenService:Create(RingHolder, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Rotation = RingHolder.Rotation + 180,
			Size = UDim2.new(0, 0, 0, 0)
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

	-- [FIX] Since the anti re-execute system destroys the old UI but this
	-- registry is a plain Lua table on SlayLib (not tied to any Instance),
	-- it would otherwise keep growing with dead entries every time the
	-- script is re-run. SetTheme already prunes dead entries lazily, but
	-- resetting here keeps it clean from the start of every fresh window.
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
		-- [FIX] Was a fixed 620x440 pixels, which is oversized on phone
		-- screens and forces constant dragging just to see past it. Now
		-- scales with the screen (78%/70%) but is clamped by the
		-- UISizeConstraint below so it never gets too small on a tiny phone
		-- or too huge on a desktop monitor.
		Size = UDim2.new(0.78, 0, 0.7, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(18, 18, 20),
		Parent = CoreGuiFrame,
		ZIndex = 5,
		ClipsDescendants = true,
		Visible = true
	})
	Create("UISizeConstraint", {MinSize = Vector2.new(400, 320), MaxSize = Vector2.new(560, 400), Parent = MainFrame})
	Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
	local MainStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1.2, Transparency = 0.4, Parent = MainFrame})
	RegisterThemed(MainStroke, "Color")

	-- [NEW] Remember the fully-open size once layout has settled so the
	-- minimize/restore tween below always restores to the correct
	-- (possibly clamped/scaled) size instead of a hardcoded pixel value.
	local OpenSize = MainFrame.Size

	-- [NEW] WINDOW / TOGGLE POSITION MEMORY
	-- Dragging the window or the floating toggle now persists the final
	-- position into SlayLib.Flags under reserved keys, which SaveConfig
	-- picks up automatically like any other flag. LoadConfig (or an
	-- autoloaded config, see below) re-applies it on the next run.
	local function RestoreFramePos(Frame, key)
		local saved = SlayLib.Flags[key]
		if type(saved) == "table" and saved.xs and saved.xo and saved.ys and saved.yo then
			Frame.Position = UDim2.new(saved.xs, saved.xo, saved.ys, saved.yo)
		end
	end
	local function SavePosFn(key)
		return function(pos)
			SlayLib.Flags[key] = {xs = pos.X.Scale, xo = pos.X.Offset, ys = pos.Y.Scale, yo = pos.Y.Offset}
		end
	end

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
		Size = UDim2.new(0, 46, 0, 46),
		Position = UDim2.new(0.05, 0, 0.15, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 27),
		Parent = CoreGuiFrame,
		ZIndex = 100
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingToggle})
	local FloatToggleStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 2, Parent = FloatingToggle})
	RegisterThemed(FloatToggleStroke, "Color")

	local ToggleIcon = Create("ImageLabel", {
		Size = UDim2.new(0, 24, 0, 24),
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

	RestoreFramePos(FloatingToggle, "_SlayLibTogglePos")
	RegisterDrag(FloatingToggle, FloatingToggle, SavePosFn("_SlayLibTogglePos"))

	ToggleButton.MouseButton1Click:Connect(function()
		Window.Toggled = not Window.Toggled
		if Window.Toggled then
			MainFrame.Visible = true
			MainFrame:TweenSize(OpenSize, "Out", "Back", 0.35, true)
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
		Size = UDim2.new(0, 170, 1, -12),
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
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		-- [FIX] "Never" stops the frame firmly at its scroll limits instead
		-- of rubber-banding past the edge and springing back, which was
		-- making the last tab hard to tap reliably.
		ElasticBehavior = Enum.ElasticBehavior.Never
	})
	local TabLayout = Create("UIListLayout", {
		Parent = TabScroll,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = "Center",
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	-- [2] CONTENT AREA
	-- [FIX] Offsets recalculated for the sidebar's new 170px width (was 200px).
	local PageContainer = Create("Frame", {
		Name = "PageContainer",
		Size = UDim2.new(1, -195, 1, -20),
		Position = UDim2.new(0, 185, 0, 10),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = MainFrame
	})

	RestoreFramePos(MainFrame, "_SlayLibWindowPos")
	RegisterDrag(MainFrame, SideHeader, SavePosFn("_SlayLibWindowPos"))

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
		if JumpTarget and Window.CurrentTab ~= nil and Window.CurrentTab.Page ~= JumpTab.Page then
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
			-- [FIX] Was bouncing/springing back right at the bottom of a long
			-- list, making the last button hard to reach reliably. "Never"
			-- makes scrolling stop firmly at the true end instead.
			ElasticBehavior = Enum.ElasticBehavior.Never,
			Parent = PageContainer
		})

		local PagePadding = Create("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 5),
			-- [FIX] Bumped from 5px to 24px: with almost no bottom padding,
			-- the very last element sat flush against the scroll limit, so
			-- combined with the elastic bounce there was effectively no way
			-- to comfortably see/tap it. This gives real breathing room.
			PaddingBottom = UDim.new(0, 24),
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
				-- [NEW] DependsOn/DependsValue: pass another element's Obj to
				-- hide/show this toggle automatically based on that element's value.
				Props = MergeDefaults(Props, {Name = "Toggle", CurrentValue = false, Flag = "Toggle_1", Callback = function() end, Tooltip = nil, DependsOn = nil, DependsValue = nil})
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
				ApplyHover(TContainer)

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

				local Obj = {Changed = {}}

				ClickArea.MouseButton1Click:Connect(function()
					TState = not TState
					SlayLib.Flags[Props.Flag] = TState
					Tween(Switch, {BackgroundColor3 = TState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 45)}, 0.2)
					Tween(Dot, {Position = TState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.2)
					task.spawn(Props.Callback, TState)
					for _, fn in ipairs(Obj.Changed) do task.spawn(fn, TState) end
				end)

				function Obj:Set(v)
					TState = v
					SlayLib.Flags[Props.Flag] = v
					Switch.BackgroundColor3 = v and SlayLib.Theme.MainColor or Color3.fromRGB(45,45,45)
					Dot.Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
					for _, fn in ipairs(Obj.Changed) do task.spawn(fn, v) end
				end

				Obj.Flag = Props.Flag
				table.insert(SlayLib.Elements, Obj)
				BindVisibility(TContainer, Props.DependsOn, Props.DependsValue)

				return Obj
			end

			-- 2. SLIDER
			function Section:CreateSlider(Props)
				Props = MergeDefaults(Props, {Name = "Slider", Min = 0, Max = 100, Def = 50, Flag = "Slider_1", Callback = function() end, Tooltip = nil, DependsOn = nil, DependsValue = nil})


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
				ApplyHover(SContainer)

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
				BindVisibility(SContainer, Props.DependsOn, Props.DependsValue)

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
					Tooltip = nil,
					DependsOn = nil,
					DependsValue = nil
				})

				local IsOpen = false
				-- [UPGRADE] Non-multi dropdowns with no explicit Default now start
				-- on the first option instead of always showing "None" (which
				-- previously meant SlayLib.Flags[Props.Flag] started as nil even
				-- though something was visually selectable).
				local Selected
				if Props.Multi then
					Selected = (type(Props.Default) == "table" and Props.Default) or {}
				else
					Selected = Props.Default or Props.Options[1]
				end
				local SearchText = ""

				-- [FIX] Declared here (before RefreshOptions/the option click
				-- handlers below) rather than at the end of the function, because
				-- those closures reference Obj.Changed — if Obj were declared
				-- later as a fresh `local Obj = {...}`, those closures would have
				-- already captured a nonexistent global `Obj` instead, erroring
				-- as soon as an option was clicked. Methods are attached to it
				-- further down once RefreshOptions/UpdateText exist.
				local Obj = {Changed = {}}

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
					CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ElasticBehavior = Enum.ElasticBehavior.Never, ZIndex = 38, Parent = DContainer
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

					-- [FIX] Defensive guard: if Props.Options somehow ends up as
					-- something other than a table (e.g. a stray Obj passed in by
					-- mistake elsewhere), iterating it would error or, worse, show
					-- garbage. Also skip any individual entry that isn't a plain
					-- string/number/boolean so a mistake never renders as
					-- "function: 0x..." in the list again.
					local optionsList = (type(Props.Options) == "table") and Props.Options or {}

					for _, option in pairs(optionsList) do
						local optType = type(option)
						if optType == "string" or optType == "number" or optType == "boolean" then
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
									for _, fn in ipairs(Obj.Changed) do task.spawn(fn, Selected) end
								end)
							end
						else
							DebugWarn("Dropdown '" .. tostring(Props.Name) .. "' got an Options entry of type '" .. optType .. "' — only string/number/boolean are shown. This usually means a colon-call passed the wrong argument (e.g. Dropdown:Refresh(list) works, but check nothing else is mutating Options directly).")
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

				-- [FIX] Attaching methods to the Obj declared earlier (see note
				-- above) instead of overwriting it with a fresh table literal —
				-- that would have orphaned the Changed list the click handlers
				-- above already captured a reference to.
				-- All methods take a leading `_` (self) param so they work
				-- correctly with colon-call syntax, e.g. Dropdown:Refresh(list).
				Obj.Refresh = function(_, NewOptions)
					if NewOptions then
						Props.Options = NewOptions
					end
					RefreshOptions()
					UpdateText()
				end

				Obj.SetOptions = function(_, NewOptions)
					Props.Options = NewOptions or {}
					RefreshOptions()
					UpdateText()
				end

				Obj.Set = function(_, Value)
					if Props.Multi then
						Selected = type(Value) == "table" and Value or {}
					else
						Selected = Value
					end

					UpdateText()
					RefreshOptions()

					SlayLib.Flags[Props.Flag] = Selected
					task.spawn(Props.Callback, Selected)
					for _, fn in ipairs(Obj.Changed) do task.spawn(fn, Selected) end
				end

				Obj.Get = function(_)
					return Selected
				end

				Obj.SetLimit = function(_, NewMax)
					Props.Max = NewMax
					UpdateText()
				end

				-- [NEW] Dropdown:BindToSignal(signal, mapFn?) — auto-refreshes the
				-- option list whenever `signal` fires, without the caller having
				-- to remember to call Refresh/SetOptions manually every time (e.g.
				-- an island/zone-changed signal that should repopulate a mob list).
				-- If mapFn is given, it receives the signal's arguments and must
				-- return the new options array; otherwise the signal's first
				-- argument is used directly as the options array.
				Obj.BindToSignal = function(_, signal, mapFn)
					if not signal or type(signal.Connect) ~= "function" then
						DebugWarn("Dropdown:BindToSignal got something that isn't a connectable signal")
						return
					end
					signal:Connect(function(...)
						local newList
						if mapFn then
							newList = mapFn(...)
						else
							newList = ...
						end
						if type(newList) == "table" then
							Obj:SetOptions(newList)
						else
							DebugWarn("Dropdown:BindToSignal's mapFn (or the signal itself) didn't produce a table of options")
						end
					end)
				end

				Obj.Flag = Props.Flag
				table.insert(SlayLib.Elements, Obj)
				BindVisibility(DContainer, Props.DependsOn, Props.DependsValue)

				return Obj
			end

			-- 4. BUTTON
			function Section:CreateButton(Props)
				Props = MergeDefaults(Props, {Name = "Action Button", Callback = function() end, Tooltip = nil, DependsOn = nil, DependsValue = nil})

				local BFrame = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = SlayLib.Theme.Element,
					Text = "", ZIndex = 25, Parent = Page, AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BFrame})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = BFrame})
				AttachTooltip(BFrame, Props.Tooltip)
				table.insert(SearchItems, {Name = Props.Name, Frame = BFrame})
				ApplyHover(BFrame)

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
				BindVisibility(BFrame, Props.DependsOn, Props.DependsValue)
			end

			-- 5. INPUT BOX
			function Section:CreateInput(Props)
				-- [FIX] Added Flag support (was completely missing before, so
				-- input values could never be part of SlayLib.Flags / saved
				-- configs) and a safe default Callback.
				Props = MergeDefaults(Props, {Name = "Input Field", Placeholder = "Value...", Flag = nil, Callback = function() end, Tooltip = nil, DependsOn = nil, DependsValue = nil})

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
				ApplyHover(IContainer)

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
				BindVisibility(IContainer, Props.DependsOn, Props.DependsValue)

				return Obj
			end

			-- 6. PARAGRAPH
			function Section:CreateParagraph(Props)
				-- [NEW] Dynamic = true makes {placeholder} tokens in Title/Content
				-- (e.g. "Uptime: {uptime}") resolve via SlayLib:FormatDynamic and
				-- keep refreshing every RefreshRate seconds.
				Props = MergeDefaults(Props, {Title = "Information", Content = "Description here.", DependsOn = nil, DependsValue = nil, Dynamic = false, RefreshRate = 1})

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

				local PCnt = Create("TextLabel", {
					Size = UDim2.new(1, 0, 0, 0), Font = "Gotham", TextSize = 13,
					TextColor3 = SlayLib.Theme.TextSecondary, BackgroundTransparency = 1,
					TextXAlignment = "Left", TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 26, LayoutOrder = 2, Parent = PContainer
				})

				local function Refresh()
					PTtl.Text = SlayLib:FormatDynamic(Props.Title)
					PCnt.Text = SlayLib:FormatDynamic(Props.Content)
				end
				Refresh()

				if Props.Dynamic then
					task.spawn(function()
						while PContainer.Parent do
							task.wait(Props.RefreshRate)
							if not PContainer.Parent then break end
							Refresh()
						end
					end)
				end

				BindVisibility(PContainer, Props.DependsOn, Props.DependsValue)

				local Obj = {}
				function Obj:Set(content, title)
					Props.Content = content
					if title then Props.Title = title end
					Refresh()
				end
				return Obj
			end

			-- 7. [NEW] THEME SWITCHER
			-- A row of color swatches. Clicking one calls SlayLib:SetTheme(name)
			-- which live-recolors every registered accent across the whole UI.
			function Section:CreateThemeSwitcher(Props)
				Props = MergeDefaults(Props, {Name = "Theme", DependsOn = nil, DependsValue = nil})

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
				BindVisibility(Container, Props.DependsOn, Props.DependsValue)
			end

			-- 8. [NEW] POPUP CONFIG SELECTOR
			-- Adds a "save as" row plus a "..." button that opens a modal
			-- popup listing every config saved via SlayLib:SaveConfig, with
			-- Load / Delete actions per entry, plus an "Auto" toggle to
			-- automatically load a chosen config the next time the script runs.
			function Section:CreateConfigManager(Props)
				Props = MergeDefaults(Props, {Name = "Config Manager", DependsOn = nil, DependsValue = nil})

				local Container = Create("Frame", {
					Size = UDim2.new(1, 0, 0, 90),
					BackgroundColor3 = SlayLib.Theme.Element,
					ZIndex = 25, Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Container})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = Container})
				table.insert(SearchItems, {Name = Props.Name, Frame = Container})

				local NameBox = Create("TextBox", {
					Size = UDim2.new(1, -140, 0, 30), Position = UDim2.new(0, 15, 0, 10),
					BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = "", PlaceholderText = "Config name...",
					TextColor3 = SlayLib.Theme.MainColor, Font = "Gotham", TextSize = 13, ZIndex = 26, Parent = Container
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = NameBox})
				RegisterThemed(NameBox, "TextColor3")

				local SaveBtn = Create("TextButton", {
					Size = UDim2.new(0, 58, 0, 30), Position = UDim2.new(1, -120, 0, 10),
					BackgroundColor3 = SlayLib.Theme.MainColor, Text = "Save", Font = "GothamBold", TextSize = 12,
					TextColor3 = Color3.new(1, 1, 1), ZIndex = 26, Parent = Container, AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SaveBtn})
				RegisterThemed(SaveBtn, "BackgroundColor3")

				local ManageBtn = Create("TextButton", {
					Size = UDim2.new(0, 54, 0, 30), Position = UDim2.new(1, -58, 0, 10),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40), Text = "...", Font = "GothamBold", TextSize = 16,
					TextColor3 = SlayLib.Theme.Text, ZIndex = 26, Parent = Container, AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ManageBtn})
				AttachTooltip(ManageBtn, "Browse saved configs")

				-- [NEW] Auto-load row: when on, the config name currently typed
				-- (or last saved) is written to a small marker file and loaded
				-- automatically the next time SlayLib:CreateWindow runs.
				local AutoLbl = Create("TextLabel", {
					Text = "Auto-load on start",
					Size = UDim2.new(1, -70, 0, 20), Position = UDim2.new(0, 15, 0, 54),
					Font = "Gotham", TextSize = 12, TextColor3 = SlayLib.Theme.TextSecondary,
					TextXAlignment = "Left", BackgroundTransparency = 1, ZIndex = 26, Parent = Container
				})

				local AutoState = (SlayLib:GetAutoloadConfig() ~= nil)
				local AutoSwitch = Create("Frame", {
					Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -49, 0, 53),
					BackgroundColor3 = AutoState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 45),
					ZIndex = 26, Parent = Container
				})
				Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = AutoSwitch})
				local AutoDot = Create("Frame", {
					Size = UDim2.new(0, 12, 0, 12),
					Position = AutoState and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
					BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 27, Parent = AutoSwitch
				})
				Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = AutoDot})
				local AutoClick = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 28, Parent = AutoSwitch})

				AutoClick.MouseButton1Click:Connect(function()
					if not AutoState then
						local nm = NameBox.Text
						if nm == "" then
							SlayLib:Notify({Title = "System", Content = "Type/save a config name first", Type = "Warning", Duration = 3})
							return
						end
						AutoState = true
						SlayLib:SetAutoloadConfig(nm)
						SlayLib:Notify({Title = "System", Content = "Will auto-load '" .. nm .. "' next time", Type = "Success", Duration = 3})
					else
						AutoState = false
						SlayLib:SetAutoloadConfig(nil)
						SlayLib:Notify({Title = "System", Content = "Auto-load disabled", Type = "Warning", Duration = 3})
					end
					Tween(AutoSwitch, {BackgroundColor3 = AutoState and SlayLib.Theme.MainColor or Color3.fromRGB(45, 45, 45)}, 0.2)
					Tween(AutoDot, {Position = AutoState and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}, 0.2)
				end)

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
						AutomaticCanvasSize = Enum.AutomaticSize.Y, ElasticBehavior = Enum.ElasticBehavior.Never,
						ZIndex = 3, LayoutOrder = 2, Parent = Panel
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
				BindVisibility(Container, Props.DependsOn, Props.DependsValue)
			end

			-- 9. [NEW] KEYBIND
			-- Shows a label + a small box displaying the currently bound key.
			-- Click the box, then press any keyboard key to (re)bind it. Once
			-- bound, pressing that key anywhere fires Callback(true) — held
			-- keys don't repeat-fire, this is an edge-triggered press event.
			function Section:CreateKeybind(Props)
				Props = MergeDefaults(Props, {Name = "Keybind", Default = nil, Flag = "Keybind_1", Callback = function() end, Tooltip = nil, DependsOn = nil, DependsValue = nil})

				local CurrentKey = Props.Default
				SlayLib.Flags[Props.Flag] = CurrentKey

				local KContainer = Create("Frame", {
					Name = Props.Name .. "_Keybind",
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundColor3 = SlayLib.Theme.Element,
					ZIndex = 25, Parent = Page
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KContainer})
				Create("UIStroke", {Color = SlayLib.Theme.Stroke, Thickness = 1, Transparency = 0.6, Parent = KContainer})
				AttachTooltip(KContainer, Props.Tooltip)
				table.insert(SearchItems, {Name = Props.Name, Frame = KContainer})
				ApplyHover(KContainer)

				local KLbl = Create("TextLabel", {
					Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0),
					Font = "GothamMedium", TextSize = 14, TextColor3 = SlayLib.Theme.Text,
					TextXAlignment = "Left", BackgroundTransparency = 1, ZIndex = 26, Parent = KContainer
				})
				ApplyTextLogic(KLbl, Props.Name, 14)

				local KeyBox = Create("TextButton", {
					Size = UDim2.new(0, 74, 0, 28), Position = UDim2.new(1, -86, 0.5, -14),
					BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = CurrentKey or "None",
					Font = "Code", TextSize = 12, TextColor3 = SlayLib.Theme.MainColor,
					ZIndex = 26, Parent = KContainer, AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeyBox})
				RegisterThemed(KeyBox, "TextColor3")

				local ListenConn = nil
				local GlobalConn = nil

				-- [NEW] The actual "does this bound key fire the callback" listener.
				-- Re-created every time the bind changes so it always checks
				-- against the current CurrentKey.
				local function RebindGlobalListener()
					if GlobalConn then GlobalConn:Disconnect() end
					if not CurrentKey then return end
					GlobalConn = UserInputService.InputBegan:Connect(function(input, processed)
						if processed then return end
						if input.KeyCode and input.KeyCode.Name == CurrentKey then
							task.spawn(Props.Callback, true)
						end
					end)
				end

				KeyBox.MouseButton1Click:Connect(function()
					if ListenConn then return end -- already listening for the next key
					KeyBox.Text = "..."
					ListenConn = UserInputService.InputBegan:Connect(function(input, processed)
						if input.UserInputType == Enum.UserInputType.Keyboard then
							CurrentKey = input.KeyCode.Name
							KeyBox.Text = CurrentKey
							SlayLib.Flags[Props.Flag] = CurrentKey
							RebindGlobalListener()
							ListenConn:Disconnect()
							ListenConn = nil
						end
					end)
				end)

				RebindGlobalListener()

				local Obj = {}
				function Obj:Set(keyName)
					CurrentKey = keyName
					KeyBox.Text = CurrentKey or "None"
					SlayLib.Flags[Props.Flag] = CurrentKey
					RebindGlobalListener()
				end
				Obj.Flag = Props.Flag
				table.insert(SlayLib.Elements, Obj)
				BindVisibility(KContainer, Props.DependsOn, Props.DependsValue)

				return Obj
			end

			return Section
		end -- จบ Section
		return Tab
	end -- จบ CreateTab

	-- [NEW] WATERMARK
	-- A small always-visible draggable pill, independent of tabs and of the
	-- main window's minimized state. Text supports {placeholder} tokens via
	-- the Dynamic Text System (e.g. "{player} | {fps} FPS | {uptime}").
	function Window:CreateWatermark(Props)
		Props = MergeDefaults(Props, {Text = "{player} | {fps} FPS | {uptime}", RefreshRate = 1})

		local WM = Create("Frame", {
			Name = "SlayWatermark",
			Size = UDim2.new(0, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.X,
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundColor3 = Color3.fromRGB(15, 15, 17),
			BackgroundTransparency = 0.08,
			ZIndex = 90,
			Parent = CoreGuiFrame
		})
		Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = WM})
		local WMStroke = Create("UIStroke", {Color = SlayLib.Theme.MainColor, Thickness = 1, Transparency = 0.5, Parent = WM})
		RegisterThemed(WMStroke, "Color")
		Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = WM})

		local WMLbl = Create("TextLabel", {
			Text = SlayLib:FormatDynamic(Props.Text),
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Enum.Font.Code, TextSize = 12, TextColor3 = SlayLib.Theme.Text,
			BackgroundTransparency = 1, ZIndex = 91, Parent = WM
		})

		RestoreFramePos(WM, "_SlayLibWatermarkPos")
		RegisterDrag(WM, WM, SavePosFn("_SlayLibWatermarkPos"))

		task.spawn(function()
			while WM.Parent do
				task.wait(Props.RefreshRate)
				if not WM.Parent then break end
				WMLbl.Text = SlayLib:FormatDynamic(Props.Text)
			end
		end)

		local Obj = {Instance = WM}
		function Obj:Set(text)
			Props.Text = text
			WMLbl.Text = SlayLib:FormatDynamic(Props.Text)
		end
		return Obj
	end

	-- [NEW] AUTOLOAD: if the user has enabled "Auto-load on start" in a
	-- Config Manager, load that config once the rest of this script's
	-- synchronous UI-building (all the CreateTab/CreateSection/Create*
	-- calls that normally happen right after CreateWindow returns) has had
	-- a chance to finish, since elements need to exist for their flags to
	-- be restorable. task.defer runs on the next resumption point, which in
	-- practice is right after that synchronous block completes.
	task.defer(function()
		local autoName = SlayLib:GetAutoloadConfig()
		if autoName then
			SlayLib:LoadConfig(autoName)
			-- LoadConfig only restores SlayLib.Elements (toggles/sliders/etc),
			-- not the window/toggle position, so reapply those explicitly.
			RestoreFramePos(MainFrame, "_SlayLibWindowPos")
			RestoreFramePos(FloatingToggle, "_SlayLibTogglePos")
		end
	end)

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
		writefile(FullPath, Data)
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
	local ok, DataOrErr = pcall(function()
		return HttpService:JSONDecode(readfile(FullPath))
	end)

	if not ok then
		SlayLib:Notify({Title = "System", Content = "Config file is corrupted!", Type = "Error", Duration = 4})
		return
	end

	-- [FIX] Guard against a JSON file that decodes to something other than
	-- a table (e.g. a bare string/number), which would otherwise error on
	-- the pairs() loop below.
	if type(DataOrErr) ~= "table" then
		SlayLib:Notify({Title = "System", Content = "Config file is invalid!", Type = "Error", Duration = 4})
		return
	end

	-- [FIX] Merge instead of replace: SlayLib.Flags = DataOrErr used to wipe
	-- out flags for any element not present in the saved file (e.g. loading
	-- an older config saved before a new toggle was added), leaving that
	-- element with no Flag entry at all instead of its current/default value.
	for k, v in pairs(DataOrErr) do
		SlayLib.Flags[k] = v
	end
	SlayLib:Notify({Title = "System", Content = "Config Loaded!", Type = "Success", Duration = 3})

	for _, el in pairs(SlayLib.Elements or {}) do
		local v = SlayLib.Flags[el.Flag]
		if v ~= nil and el.Set then
			el:Set(v)
		end
	end
end

-- [NEW] Used by the popup config manager's delete button.
function SlayLib:DeleteConfig(Name)
	local FullPath = SlayLib.Folder .. "/" .. Name .. ".json"
	local ok = pcall(function()
		if isfile(FullPath) then
			delfile(FullPath)
		end
	end)
	if ok then
		SlayLib:Notify({Title = "System", Content = "Config Deleted", Type = "Warning", Duration = 3})
	else
		SlayLib:Notify({Title = "System", Content = "Failed to delete config!", Type = "Error", Duration = 3})
	end
end

return SlayLib