-- โหลด SlayLib X
local SlayLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/gmkem/slayHub/refs/heads/main/Gui2.lua"))()
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

------------------------------------------------------------
-- 🌀 FLY (ต้นฉบับของคุณ ไม่แตะต้อง)
------------------------------------------------------------
local flying, speedMultiplier, tpwalking = false, 1, false
local ctrl, lastctrl = {f=0,b=0,l=0,r=0}, {f=0,b=0,l=0,r=0}

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
	elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
	elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
	elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
end)
UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
	elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
	elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
	elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
end)

local function ToggleFly()
	local char = Player.Character
	if not char or not char:FindFirstChild("Humanoid") then return end
	local hum = char.Humanoid
	if flying then
		flying = false
		tpwalking = false
		hum.PlatformStand = false
		char.Animate.Disabled = false
		for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(s,true) end
		hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else
		flying = true
		char.Animate.Disabled = true
		for _, a in next, hum:GetPlayingAnimationTracks() do a:AdjustSpeed(0) end
		for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(s,false) end
		hum:ChangeState(Enum.HumanoidStateType.Swimming)
		hum.PlatformStand = true

		task.spawn(function()
			local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
			local bg = Instance.new("BodyGyro",torso)
			bg.P, bg.maxTorque = 9e4, Vector3.new(9e9,9e9,9e9)
			local bv = Instance.new("BodyVelocity",torso)
			bv.maxForce = Vector3.new(9e9,9e9,9e9)
			local currentSpeed, baseSpeed = 0, 10
			while flying and char.Parent and hum.Health>0 do
				RunService.RenderStepped:Wait()
				local appliedSpeed = baseSpeed * speedMultiplier
				if (ctrl.l+ctrl.r)~=0 or (ctrl.f+ctrl.b)~=0 then
					currentSpeed = math.min(currentSpeed+1, appliedSpeed)
					bv.velocity = ((workspace.CurrentCamera.CFrame.LookVector*(ctrl.f+ctrl.b))+
						((workspace.CurrentCamera.CFrame*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).Position)-
						workspace.CurrentCamera.CFrame.Position))*currentSpeed
					lastctrl={f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
				elseif currentSpeed~=0 then
					currentSpeed = math.max(currentSpeed-2,0)
					bv.velocity = ((workspace.CurrentCamera.CFrame.LookVector*(lastctrl.f+lastctrl.b))+
						((workspace.CurrentCamera.CFrame*CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).Position)-
						workspace.CurrentCamera.CFrame.Position))*currentSpeed
				else bv.velocity=Vector3.new(0,0,0) end
				bg.cframe = workspace.CurrentCamera.CFrame*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*currentSpeed/appliedSpeed),0,0)
			end
			bg:Destroy() bv:Destroy()
		end)

		task.spawn(function()
			tpwalking = true
			while tpwalking and char.Parent and hum.Parent do
				RunService.Heartbeat:Wait()
				if hum.MoveDirection.Magnitude>0 then
					for i=1,speedMultiplier do
						char:TranslateBy(hum.MoveDirection*(1/5))
					end
				end
			end
		end)
	end
end
local function SetSpeed(v) speedMultiplier=v end
local function MoveVertical(a)
	local r=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if r then r.CFrame=r.CFrame*CFrame.new(0,a,0) end
end

------------------------------------------------------------
-- 🕶 INVISIBLE (ต้นฉบับของคุณ)
------------------------------------------------------------
local Character, Humanoid, RootPart
local Parts, InvisibleActive, Connections = {}, false, {}
local function UpdateCharacter()
	Character = Player.Character or Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
	Parts = {}
	for _, p in pairs(Character:GetDescendants()) do
		if p:IsA("BasePart") and p.Transparency==0 then table.insert(Parts,p) end
	end
end
local function ToggleInvisible(state)
	InvisibleActive = state~=nil and state or not InvisibleActive
	for _, p in pairs(Parts) do p.Transparency = InvisibleActive and .5 or 0 end
end
Connections[1]=Player:GetMouse().KeyDown:Connect(function(k)
	if k=="g" then ToggleInvisible(); SlayLib.Flags["InvisibleToggle"]=InvisibleActive end
end)
Connections[2]=RunService.Heartbeat:Connect(function()
	if InvisibleActive and RootPart and Humanoid then
		local oC=RootPart.CFrame; local oO=Humanoid.CameraOffset
		local hC=oC*CFrame.new(0,-200000,0)
		RootPart.CFrame=hC
		Humanoid.CameraOffset=hC:ToObjectSpace(CFrame.new(oC.Position)).Position
		RunService.RenderStepped:Wait()
		RootPart.CFrame=oC
		Humanoid.CameraOffset=oO
	end
end)
Player.CharacterAdded:Connect(function()
	InvisibleActive=false; SlayLib.Flags["InvisibleToggle"]=false; UpdateCharacter()
end)
UpdateCharacter()

------------------------------------------------------------
-- 🚶♂️ NOCLIP (ใหม่)
------------------------------------------------------------
local NoclipActive = false
local NoclipConnection
local function ToggleNoclip(state)
	NoclipActive = state
	if NoclipActive then
		NoclipConnection = RunService.Stepped:Connect(function()
			if Player.Character then
				for _, part in pairs(Player.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection=nil end
		if Player.Character then
			for _, part in pairs(Player.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end

------------------------------------------------------------
-- 📜 GUI ส่วนหลัก
------------------------------------------------------------
local Window = SlayLib:CreateWindow({Name="SlayHub X (Brookhaven)"})
------------------------------------------------------------
-- ✈️ Flight Tab
------------------------------------------------------------
local FlyTab = Window:CreateTab("Flight", SlayLib.Icons.Icon)
local FlySec = FlyTab:CreateSection("Flight Controls")
FlySec:CreateToggle({Name="Fly", CurrentValue=false, Flag="FlyToggle", Callback=ToggleFly})
FlySec:CreateSlider({Name="Fly Speed", Min=1, Max=50, Def=1, Flag="FlySpeed", Callback=SetSpeed})
FlySec:CreateButton({Name="Up", Callback=function() MoveVertical(5) end})
FlySec:CreateButton({Name="Down", Callback=function() MoveVertical(-5) end})
FlySec:CreateToggle({Name="Noclip", CurrentValue=false, Flag="NoclipToggle", Callback=ToggleNoclip})

------------------------------------------------------------
-- 🕶 Invisible Tab
------------------------------------------------------------
local InvTab = Window:CreateTab("Invisible", SlayLib.Icons.Icon)
local InvSec = InvTab:CreateSection("Invisible Controls")
InvSec:CreateToggle({Name="Enable Invisible", CurrentValue=false, Flag="InvisibleToggle", Callback=ToggleInvisible})

------------------------------------------------------------
-- 🎥 TP & POV Tab
------------------------------------------------------------
local TPTab = Window:CreateTab("TP & POV", SlayLib.Icons.Icon)
local TPSec = TPTab:CreateSection("Teleport & Camera")
local TargetPlayer = nil
local PlayerDropdown

local function RefreshPlayers()
	local list = {"None"}
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= Player then table.insert(list, plr.Name) end
	end
	return list
end

PlayerDropdown = TPSec:CreateDropdown({
	Name="Select Player", Options=RefreshPlayers(), Flag="TargetPlayer",
	Callback=function(val) TargetPlayer = game.Players:FindFirstChild(val) end
})
TPSec:CreateButton({Name="Teleport", Callback=function()
	if TargetPlayer and TargetPlayer.Character and Player.Character then
		Player.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
	end
end})
TPSec:CreateToggle({
	Name="POV View", CurrentValue=false, Flag="POVToggle",
	Callback=function(val)
		if val and TargetPlayer and TargetPlayer.Character then
			workspace.CurrentCamera.CameraSubject = TargetPlayer.Character.Humanoid
		else
			workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid
		end
	end
})
task.spawn(function()
	while true do task.wait(5)
		if PlayerDropdown and PlayerDropdown.SetOptions then
			pcall(function() PlayerDropdown:SetOptions(RefreshPlayers()) end)
		end
	end
end)

------------------------------------------------------------
-- ⚙️ Stats Tab
------------------------------------------------------------
local StatsTab = Window:CreateTab("Stats", SlayLib.Icons.Icon)
local StatsSec = StatsTab:CreateSection("Run & Jump")
StatsSec:CreateSlider({Name="Run Speed", Min=16, Max=200, Def=16, Flag="RunSpeed",
	Callback=function(v) if Player.Character then Player.Character.Humanoid.WalkSpeed=v end end})
StatsSec:CreateSlider({Name="Jump Power", Min=50, Max=500, Def=50, Flag="JumpPower",
	Callback=function(v) if Player.Character then Player.Character.Humanoid.JumpPower=v end end})

------------------------------------------------------------
-- 🌀 Spin Tab
------------------------------------------------------------
local SpinTab = Window:CreateTab("Spin", SlayLib.Icons.Icon)
local SpinSec = SpinTab:CreateSection("Spin Settings")
local SpinActive, SpinAxis, SpinSpeed = false, "Y", 10
SpinSec:CreateToggle({Name="Enable Spin", CurrentValue=false, Flag="SpinToggle", Callback=function(v) SpinActive=v end})
SpinSec:CreateDropdown({Name="Axis", Options={"X","Y","Z"}, Flag="SpinAxis", Callback=function(v) SpinAxis=v end})
SpinSec:CreateSlider({Name="Spin Speed", Min=1, Max=50, Def=10, Flag="SpinSpeed", Callback=function(v) SpinSpeed=v end})

------------------------------------------------------------
-- 👁 ESP Tab
------------------------------------------------------------
local ESPTab = Window:CreateTab("ESP", SlayLib.Icons.Icon)
local ESPSec = ESPTab:CreateSection("ESP Controls")
local ESPActive = false
local ESPObjects = {}
ESPSec:CreateToggle({Name="Enable ESP", CurrentValue=false, Flag="ESPActive", Callback=function(v) ESPActive=v end})

RunService.Heartbeat:Connect(function()
	-- Spin
	if SpinActive and Player.Character and Player.Character.PrimaryPart then
		local cf = Player.Character.PrimaryPart.CFrame
		if SpinAxis=="X" then cf = cf*CFrame.Angles(math.rad(SpinSpeed),0,0)
		elseif SpinAxis=="Y" then cf = cf*CFrame.Angles(0,math.rad(SpinSpeed),0)
		elseif SpinAxis=="Z" then cf = cf*CFrame.Angles(0,0,math.rad(SpinSpeed)) end
		Player.Character:SetPrimaryPartCFrame(cf)
	end
	-- ESP
	for _, b in pairs(ESPObjects) do b:Destroy() end
	ESPObjects = {}
	if ESPActive then
		for _, plr in pairs(game.Players:GetPlayers()) do
			if plr~=Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local box = Instance.new("BoxHandleAdornment")
				box.Adornee = plr.Character.HumanoidRootPart
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Size = plr.Character.HumanoidRootPart.Size + Vector3.new(1,2,1)
				box.Color3 = Color3.fromRGB(255,100,100)
				box.Transparency = 0.3
				box.Parent = workspace
				table.insert(ESPObjects, box)
			end
		end
	end
end)

local MusicTab = Window:CreateTab("Music Player(GamePass request)", SlayLib.Icons.Music)
local MusicSection = MusicTab:CreateSection("Song Controls")

-- รายชื่อเพลง
local MusicList = {
["ABSTRACTION - DIGITAL CIRCUS x UNDERTALE"] = "72578000237018",
["No. 1 Party Anthem"] = "70879716541062",
["[OLD] NO MORE GAMES - Sonic.exe: OUTCOME MEMORIES UST"] = "139781718376707",
["Break Through It All - Sonic Frontiers"] = "139788058102161",
["The Sol Still Burns - SONIC.exe: OUTCOME MEMORIES OST"] = "137670056405666",
["Undefeatable"] = "136329518348869",
["JUST BE COMPETENT (Official Audio)"] = "110651018137568",
["Eggman's theme (Symphonic Metal BANGER!)"] = "76853383234673",
["Gold Protocol - Admin (MCSM)"] = "87431288194586",
["The Call of the Void With Lyrics"] = "107069205009368",
["The Doomsday Zone - Sonic & Knuckles (Metal Cover)"] = "75580951258795",
["Hazbin Hotel - VOX DEI (Clean Version)"] = "107745876473216",
["Rewrite Sonic - The Cool Part"] = "115825289572003",
["[GREEN SANS] - Totally Serious (Cover)"] = "139557403263839",
["Like Him"] = "138935753661239",
["Unknown From M. E. (Theme of Knuckles)"] = "80268400430998",
["New World (Meowl Solo Theme)"] = "112422814015294",
["Special Stage (Re-Imagined) - Sonic CD"] = "88431702564669",
["Beyond Absolution (Silver Solo theme)"] = "74003134453163",
["TV Girl - Taking What's Not Yours"] = "92656254451056",
["2011X - RUNAWAY (Lyric Video)"] = "108684911625070",
["SONIC RUSH RERUN - Announcement Trailer"] = "72164706972317",
["DON'T BLINK feat. Johnny Gioeli"] = "116014462048083",
["Step! Mio Honda - 1st Place 8th"] = "136622291453668",
["omega lms ust V2 \"stronger than the empire\""] = "86260813781684",
["(Sonic.EXE: The Disaster UST) Forever Imperfect"] = "122950985409556",
["DEAD OR ALIVE (ft. @hxperxhxper)"] = "96612490665727",
["This Comes From Inside (JJOZIAH JERSEY REMIX)"] = "113721650174963",
["OUTCOME MEMORIES: 2011X CHASE THEME REMAKE"] = "87861202992235",
["Release the Ghouls!"] = "96836381174339",
["RELEASE THE GHOULS [W/LYRICS]"] = "84414874913437",
["Furnace Chase theme outcome memories"] = "98068606490631",
["OM UST - \"STATIC IN MY SOUL\""] = "85456762790093",
["Furnace vs Metal Sonic Outcome memories"] = "107158533296035",
["Friday Night Funkin Hazy River OST - Release"] = "126389990231010",
["Gravity - Hazbin Hotel"] = "119604320238341",
["Mio Honda & Crush 40 - Step! x I Am... All Of Me"] = "137818861774128",
["Once A Flower (feat. Dyno_19)"] = "136927516818761",
["Inkwell Dreams"] = "110500844723222",
["WARRIOR'S RAGE - Feel The Fury REMIX"] = "124187335750668",
["SURGE outcome memories solo theme"] = "86410890912839",
["Shadow the Hedgehog Opening Theme - I Am... All of Me"] = "101807473608803",
["Friends No More: Round 2 Remix W/ Lyrics"] = "124014185883154",
["[UNDERTALE 10TH ANNIVERSARY] - Last Goodbye COVER"] = "124438586314654",
["LOVELY"] = "83249167878053",
["Pizza Tower OST - Bye Bye There!"] = "107275060938810",
["russelbuck - Just Be Competent"] = "81662170223359",
["Dreams of An Absolution -Theme of Silver"] = "118665243574073",
["Friends No More REMIX - OUTCOME MEMORIES UST"] = "140722528152072",
["Eh Eh Eh + A Sansational Battle"] = "116130725206445",
["VHS Sans - Phase 2 [Better Start Running]"] = "77864171477864",
["Six Bones - Theme Battle"] = "88132094616293",
["Pixies - Where Is My Mind?"] = "133704468344078",
["Tainted Ambition | N!Alphatale Error!404"] = "126555816998742",
["The Rerun- Ep. 2: DROP AND ROLL"] = "108231695715986",
["ALL THE SMOKE (Omega LMS) Outcome Memories UST"] = "135846891464418",
["Undertale Disbelief - \"Striking The Demon Down\""] = "71531197736810",
["Bullet For My Valentine - \"Hand Of Blood\""] = "118881737018775",
["Battle Against A True Hero"] = "113460747779575",
["Charlie's inferno X Terrible things x porifera atoll"] = "119082892795380",
["Escape Key - Spamton NEO LMS"] = "79638652415956",
["BURNED ~ THE LAST ATTRACTION"] = "137485425182136",
["Friends No More: Round 1"] = "123435420382015",
["Big Misser"] = "110813778084596",
["Battle with Infinite - First Bout"] = "93146753590336",
["Banana Bus Breakdown WITH LYRICS"] = "122212195950798",
["undertale all or nothing (cover)"] = "102197341363550",
["rewrite round 2"] = "78718597841506",
["noob crossing my road (fnf)"] = "122967388049997",
["Sonic meshup x one bounce"] = "116811147459973",
["The Living Tombstone - \"Step On Up\""] = "90567474079856",
["Peggy Suave - Posin"] = "104852678653822",
["(BPM & Key match song)"] = "126944671950653",
["twelfth hour (Niko chase theme UST)"] = "97436541502357",
["Steven Universe: The Movie"] = "125151280444304",
["Once Upon a Time (UNDERTALE)"] = "125940439370480",
["DAISIES (A Hazbin Hotel Song)"] = "81639912608282",
["Undertale - Finale (Remaster)"] = "117064854285259",
["We Rep Blaze - EUPHONIC RUSH"] = "100734124370501",
["Spoken For (FLAVOR FOLEY)"] = "98319510804613",
["Sonic Adventure 2 - Live and Learn (Orchestral)"] = "91093261242988",
["Find Your Flame"] = "138816921246278",
["iced sans (thick of it megalovania)"] = "104220043377862",
["too slow by awe"] = "75102582014627",
["FIRE JASON (lyric cover)"] = "101453655055931",
["I'm Here"] = "104450444237475",
["Freedom Fighter's Last Stand"] = "125292677750656",
["(Sonic.EXE: The Disaster UST) Freedom Fighter's Last Stand"] = "125292677750656",
["TERRIBLE THINGS - Springtrap AI Cover"] = "137298859833752",
["\"Confronting the nightmare.\" - SONIC.EXE THE DISASTER [TAILS THEME]"] = "92202424051913",
["Madness & Chaos"] = "93463381175348",
["[SCRAPPED] END CHASE - SONIC.exe: OUTCOME MEMORIES OST"] = "115237589402676",
["elmo bad time UST"] = "121679477899395",
["the dark truth (deltarune chapter 2)"] = "107481941660802",
["In Your Dreams - (BEING REPURPOSED)"] = "111110394133627",
["Dangerous Forest (Forest Kolossos Chase Theme) - Outcome Memories OST"] = "129960958293893",
["Spongeswap | BIBULUS II"] = "88318286438691",
["[YTPMV] - Power Of \"ONE\" (Full version)"] = "83064184245778",
["[Dusttale Remix] SharaX - Dust"] = "121834609649719",
["Five Nights at Freddy's 3 (feat. EileMonty & Orko) - Burn in Fire The Living Tombstone"] = "74786603084060",
["\"ITS TOO LATE!\" Metal Sonic x Power slide by Phonkha"] = "95800798699842",
["FNF - Bite [Fernan Mix] Fan Made - Bite FERNAN MIX"] = "82589156727915",
["SONIC AND THE BLACK KNIGHT \"KNIGHT OF THE WIND\" ANIMATED LYRICS"] = "120347761467743",
["Niko chase theme (rouge machine UST)"] = "122371368156881",
["dusttale (damage-maniac)"] = "115611675838801",
["Devesto remix chase theme (die of death)"] = "139556929438403",
["admin noli chase theme (extended version with lms and voice lines)"] = "132710965389150",
["a fiction battle ground ultimate music"] = "112820671704731",
["forced grin sans"] = "81947250575875",
["hello John Doe chase theme (extended+lms)"] = "94447273330790",
["SONIC.EXE OST"] = "119445403924391",
["Pizza Tower OST - It's Pizza Time!"] = "140369940356538",
["bug (pjsk ver) off-sale"] = "112112103954879",
["Zako (Neru) off-sale"] = "126560495348500",
["Antenna 39 (Miku) off-sale"] = "132743867525376",
["artful chase theme"] = "120708605460824",
["retry now (Miku) off-sale"] = "138854554847689",
["MY TOY (Teto Miku) off-sale"] = "120103644342632",
["intergalactic bound"] = "131089843973451",
["vicious cycle (redseas07)"] = "97465841713968",
["Welcome Home Cycles! (ft. @churgneygurgney9895)"] = "101940783449523",
["ALL I AM // The Amazing Digital Circus Song"] = "122515036753396",
["FREDDY, YOU'RE SUPPOSED TO BE ON LOCKDOWN"] = "120859693736569",
["DROP & ROLL WITH LYRICS | FT: @SmuggleHimself"] = "90092639719350",
["alien alien (Tokino Sora)"] = "127857482263373",
["moribund. (redseas07)"] = "85622367928962",
["SIU / suck it up (Miku)"] = "85002617757622",
["The Disappearance of Hatsune Miku"] = "114275401310005",
["Cyber Punk Dead Boy (pjsk ver)"] = "91932304812725",
["Q & A (Teto)"] = "81426094771599",
["Ken Ashcorp - Absolute Territory"] = "131636789227929",
["\"HARD DRIVE\" - UNDERTALE METTATON SONG"] = "121164830925790",
["MY REVERE (redseas07)"] = "88925806514029",
["paparazzi murder party (GUMI)"] = "127351672050980",
["Gooseworx - Your new home (slowed + reverb)"] = "71186345039796",
["AVM Ep 16. Note Block - Green's jam"] = "138073482984048",
["Valiant Hero (Extended Version)"] = "123859651949368",
["Pigstep (AvM Remix)"] = "115186232513506",
["Roar - Christmas Kids"] = "133161179473195",
["Live To Live"] = "90826379782488",
["THE REDEMPTION OF A DIVA (midsaken UST)"] = "73651878009906",
["cordless_melting_hope.mp4"] = "108430956098237",
["Okaasan"] = "132592438230915",
["Take A Slice - Glass Animals (Remix)"] = "117616291752805",
["Otsukai gassoukyoku off-sale"] = "120039038546739",
["royal papyrus theme"] = "82495373534336",
["I forgot what this is a Roblox boss battle theme"] = "132973051194444",
["swagger sans theme (remix)"] = "83622672194764",
["dusttrust finality"] = "120152518829959",
["reflection noli chase theme"] = "105672607463477",
["black apple (nightmare sans theme)"] = "86216204969159",
["glory (ultrakill)"] = "95062442542567",
["dio time stop singing"] = "121447814279816",
["golden sin sans/dio megalovania"] = "139545337829395",
["green sans phase 3"] = "82759922305667",
["valiant hero extended remix"] = "116511450345822",
["bo en every day [Daycore - Slowed Down]"] = "73080191532359",
["Placing the blame\" by SELF"] = "134738150011857",
["JoJo's Bizarre Adventures Steel Ball Run Opening Full (Holy Steel)"] = "134858716786983",
["Miraidempa - Unslept Slowed"] = "107785474019043",
["Release The Ghouls!"] = "82151689758165",
["Friends.exe OST: Final Boss"] = "78126757799070",
["I Can't wait (GUMI)"] = "117483005811411",
["SnowMix (Miku)"] = "122896400057895",
["unslept - miraidempa (nightcore)"] = "98186128530166",
["JoJo's Bizarre Adventures Steel Ball Run Opening Full (normal speed)"] = "130150428243105",
["[OLD] NO MORE GAMES - Sonic.exe: OUTCOME MEMORIES UST"] = "109902534300444",
["green sans phase 1"] = "99894551717130",
["fatal error sans"] = "102795952873806",
["Flowey's Face off (Longer Version)"] = "123828779629596",
["Igaku Arrange (feat. Kasane Teto)"] = "91880667600012",
["INFINITE DEATH (Yi Xi)"] = "120266574441906",
["SELF-PACED (feat. @DJAwesomeYT)"] = "101683683425410",
["BERDLY BRAIN (ft. Kasane Teto and Deltarune)"] = "139924511923380",
["egoist/flower"] = "116022890197942",
["Fanyu/Zhisheng"] = "130447758799972",
["Baka Tsuushin/Chisei MV"] = "78210245382106",
["Broken Heart (original) by @alanbecker"] = "72953508400388",
["Minecraft In Game Music - calm1"] = "91986879922479",
["Overclocked (Teto)"] = "118677898609583",
["A Sardine Grows from the Soil"] = "76569697234957",
["PLEAD WITH LYRICS (007n7 VS COOlkidd Last Man Standing Theme) [FORSAKEN] [Lyrical Shorts]"] = "113265542312403",
["TheFatRat - Jackpot"] = "108531350726198",
["Tokai Teio Ballin but full version"] = "137409529549092",
["TheFatRat - Fly Away feat. Anjulie"] = "105059799927487",
["Sunshine | Geometry Dash"] = "90876419172142",["Midnight winter"] = "115590187881251", ["บางระจัน [thai song]"] = "126380171075625",
    ["เอ็มออนิว [thai song]"] = "126370769732812",
    ["วันนา [thai song]"] = "132318869423796",
    ["1 of 1 [thai song]"] = "105201227602807",
    ["ไก่นา [thai song]"] = "109317279967858",
    ["อาบัง [thai song]"] = "111958264066412",
    ["สระอู [thai song]"] = "11126428529322",
    ["ได้โปรด [thai song]"] = "117674034798266",
    ["LUSS - หยอก หยอก [thai song]"] = "134866197449676",
    ["เพลงอินเดียแดนซ์ [thai song]"] = "107636869435674",
    ["แดนซ์เกิน [thai song]"] = "106217103879147",
    ["แดนซ์โยก [thai song]"] = "77149919429733",
    ["จังหวะเร่าร้อน [thai song]"] = "127542582435883",
    ["แดนซ์เวียดนาม [thai song]"] = "87726330432189",
    ["ให้คุณเป็นดวงจันทร์ [thai song]"] = "81933610232830",
    ["nope you too late i already died (sped up) [thai song]"] = "91853707949855",
    ["เด็กอินเตอร์ [thai song]"] = "146532368547",
    ["สตาร์บัค [thai song]"] = "75809575049778",
    ["แปลได้ว่าอะไรดำๆ [thai song]"] = "121374695318782",
    ["จื่อบ่ [thai song]"] = "115126970355796",
    ["เพลงไรไม่รู้ (พี่เอาไอดีมาจากไหน) [thai song]"] = "120017030311480",
    ["ไอหน้าฮี [thai song]"] = "8012653373",
    ["บทสวด อรหัง [thai song]"] = "120247155085176",
    ["เพลงไรไม่รู้ลืม [thai song]"] = "73221624548171",
    ["จีน [thai song]"] = "99960601736776",
    ["aloneแดนซ์ [thai song]"] = "109149632133821",
    ["summertime sadness แดนซ์ [thai song]"] = "107887768910692",
    ["เก่า [thai song]"] = "78715697950477",
    ["ฟังดูง่ายๆๆ [thai song]"] = "131307405424060",
    ["Nope you too late i already died (full) [thai song]"] = "96044624734197",
    ["วันนา (อีกชุด) [thai song]"] = "128153179827416",
    ["ซูเปอร์เบส [thai song]"] = "78596441510872",
    ["พี่นัตตี้ [thai song]"] = "129988226070628",
    ["ไม่รู้ชื่อ [thai song]"] = "138765729162919",
    ["อีเคเฟรอ [thai song]"] = "125902207303673",
    ["คุบุคะคุบุ [thai song]"] = "114343063324644",
    ["เมียมีเมียพี่ต้องมา [thai song]"] = "98523490642599",
    ["เจาะๆ [thai song]"] = "105782298953735",
    ["dancin aaron smith [thai song]"] = "94857177466145",
    ["KANI$ โยกย้าย แดนซ์ [thai song]"] = "81244086617866",
    ["Youngtarr เด็กอินเตอร์ [thai song]"] = "99634905807786",
    ["SHOGUN Good boyfriends ever [thai song]"] = "98403758775264",
    ["Quintinn need that FT.simon [thai song]"] = "101969962395526",
    ["GH Away From You [thai song]"] = "127465391801768",
    ["WWJ จีบอยู่เผื่อไม่รู้ [thai song]"] = "80279608102503",
    ["คำแพง [thai song]"] = "102060169918209",
    ["เย็นชา สกายพาส [thai song]"] = "75299143897290",
    ["แอ่นระแนง cover gxrmarny [thai song]"] = "99714417757861",
    ["ฝนมากี่ฝน แช่ม [thai song]"] = "133053991574717",
    ["ภูมิแพ้กรุงเทพ [thai song]"] = "105282378977201",
    ["ทูตสวรรค์ที่มาพร้อมลูกซอง [thai song]"] = "128163802550385",
    ["เพลงจีนรีมิกซ์ [thai song]"] = "132049153370517",
    ["ฟ้ารักพ่อ x ยังโอม [thai song]"] = "87698396766637",
    ["ขี้หึง [thai song]"] = "110242046166829",
    ["มักอ้ายหลายเด้อ [thai song]"] = "70913368474500",
    ["แดนซ์ของแทร่ [thai song]"] = "135909717667883",
    ["นาคห่วงแฟน (ธีรเดช สหเพชร) [thai song]"] = "106433358101841",
    ["HRK - ใจผูก...เจ็บ [thai song]"] = "93246537399095",
    ["จากตรงนี้ที่เคยสวยงาม [thai song]"] = "104048341641021",
    ["Symphony No.9 4th Mvt [thai song]"] = "1837476763",
    ["Symphony No.25 In G Minor 1st Mov. [thai song]"] = "1843533739",
    ["เมาคลีล่าสัตว์ [thai song]"] = "132714655451652",
    ["sing [thai song]"] = "123756660035621",
    ["มานี่มา [thai song]"] = "112666582385808",
    ["เสียงกวน [thai song]"] = "85039047299073",
    ["ILLSLICK ถ้าเธอต้องเลือก [thai song]"] = "129087259637558",
    ["โครตดัง [thai song]"] = "8177236266",
    ["ฝรั่งฟรีไมค์ [thai song]"] = "127576709158393",
    ["dark red [thai song]"] = "87373439541502",
    ["สดุดีจอมราชา [thai song]"] = "130083028057611",
    ["เพลงชาติไทย [thai song]"] = "11344899770989",
    ["สรรเสริญ [thai song]"] = "109064312551741",
    ["7:55 ก่อนเพลงชาติ [thai song]"] = "89351482093378",  ["Unnamed [thai song] 1"] = "118314578679702",
    ["Unnamed [thai song] 2"] = "112422814015294",
    ["Unnamed [thai song] 3"] = "138935753661239",
    ["Unnamed [thai song] 4"] = "121239777513594",
    ["Unnamed [thai song] 5"] = "138083623184370",
    ["Unnamed [thai song] 6"] = "101312888985491",
    ["Unnamed [thai song] 7"] = "107067591265680",
    ["Unnamed [thai song] 8"] = "112333545042399",
    ["Unnamed [thai song] 9"] = "121690279003988",
    ["Unnamed [thai song] 10"] = "99421411270011",
    ["Unnamed [thai song] 11"] = "97085865756405",
    ["Unnamed [thai song] 12"] = "75226917358556",
    ["Unnamed [thai song] 13"] = "123871565356517",
    ["Unnamed [thai song] 14"] = "127536192254037",
    ["Unnamed [thai song] 15"] = "81122165966323",
    ["Unnamed [thai song] 16"] = "114037018959872",
    ["Unnamed [thai song] 17"] = "77937235792395",
    ["Unnamed [thai song] 18"] = "97998042800362",
    ["Unnamed [thai song] 19"] = "82475562998551",
    ["Unnamed [thai song] 20"] = "73989721978244",
    ["Unnamed [thai song] 21"] = "140450531514710",
    ["Unnamed [thai song] 22"] = "86367285840389",
    ["Unnamed [thai song] 23"] = "97785104909396",
    ["Unnamed [thai song] 24"] = "106818741846127",
    ["Unnamed [thai song] 25"] = "92289753665477",
    ["Unnamed [thai song] 26"] = "129361636027177",
    ["Unnamed [thai song] 27"] = "73859601978760",
    ["Unnamed [thai song] 28"] = "75286443923155",
    ["Unnamed [thai song] 29"] = "96081372716764",
    ["Unnamed [thai song] 30"] = "140199383961640",
    ["Unnamed [thai song] 31"] = "85606540666879",
    ["Unnamed [thai song] 32"] = "88456027979484",
    ["Unnamed [thai song] 33"] = "109540315798643",
    ["Unnamed [thai song] 34"] = "72586044568845",
    ["Unnamed [thai song] 35"] = "91007045451630",
    ["Unnamed [thai song] 36"] = "81287858635000",
    ["Unnamed [thai song] 37"] = "108483365019009",
    ["Unnamed [thai song] 38"] = "82974986293713",
    ["Unnamed [thai song] 39"] = "128522268959634",
    ["Unnamed [thai song] 40"] = "110788401793874",
    ["Unnamed [thai song] 41"] = "126380171075625",
    ["Unnamed [thai song] 42"] = "98360514812928",
    ["Unnamed [thai song] 43"] = "72100681595673",
    ["Unnamed [thai song] 44"] = "107153597511796",
    ["เทสดี [thai song]"] = "90395651800162",
    ["ไหนเทอลองเป็นแฟน [thai song]"] = "126809580291801",
    ["ไอ้ตัวเล็ก [thai song]"] = "80798853706087",
    ["วรโชติ [thai song]"] = "84498981825126",
    ["อย่าตีกันเน้อ [thai song]"] = "135779256287952",
    ["ทหารแบกปูน [thai song]"] = "100955936377577",
    ["หมดแรงรัก [thai song]"] = "111964640591545",
    ["คนธรรมดา [thai song]"]= "129513958237400",
    ["ยังต้า [thai song]"] = "83271233590423",
    ["Unnamed [thai song] 54"] = "84637782975942",
    ["เขามีความต้องเจ้า [thai song]"] = "102060169918209",
    ["เด็กอินเตอร์ [thai song]"] = "99634905807786",
    ["ด็อกเตอร์แบงค์ [thai song]"] = "111958264066412",
    ["มาได้จังหวะ ธามไท [thai song]"] = "121451761893453",
    ["รจนา Nita [thai song]"] = "133959454170046",
    ["ไรเฟิร์น Rifle [thai song]"] = "109010917526993",
    ["เมร่อน แดนซ์ [thai song]"] = "103208352220929",
    ["จอมขวัญ โก๊ะนิพนธ์ [thai song]"] = "134536090608617",
    ["คิมิโนโตะ Sprite ft.youngohm ver.live [thai song]"] = "81466715493876",
    ["ที่รักใจเย็น Yented cover Pray4Pls x Mafxurth! x LERMTON [thai song]"] = "95732360463603",
["EENIE MEENIE x DANZA KUDURO [thai song]"] = "94677274916350",
    ["บูมซากาลากาบูม [thai song]"] = "76516561571913",
    ["AKU DONG [thai song]"] = "119254319180287",
    ["อินยัวอาย [thai song]"] = "74758860515324",
    ["yesเค [thai song]"] = "78954682326720",
    ["เอวลอย [thai song]"] = "133264081361349",
    ["คอนวีคอนแวน [thai song]"] = "102572315485834",
    ["เลดี้เบียร์ [thai song]"] = "114056884370316",
    ["whine up [thai song]"] = "86987612038693",
    ["ตังค์ไม่ออกบอกเมา [thai song]"] = "96972693020663",
    ["คิดถึงจังวะ [thai song]"] = "90351002394284",
    ["มักแล้ว [thai song]"] = "83822846210154",
    ["เวก้าผับ [thai song]"] = "104192224479469",
    ["คำแพงแดนต์ [thai song]"] = "129094836473103",
    ["มูฟแดท v2 [thai song]"] = "107571001738028",
    ["enak [thai song]"] = "140380438039459",
    ["ลืมชื่อ 2 [thai song]"] = "132820291139725",
    ["ระยองฮิ [thai song]"] = "83919005919466",
    ["ลืมชื่อ 3 [thai song]"] = "120255584589934",
    ["ลืมชื่อ 4 [thai song]"] = "98057205717847",
    ["เรี้ยมเร้เรไร [thai song]"] = "132269954228136",
    ["ปาปิชูโล [thai song]"] = "116927362046941",
    ["เฉา [thai song]"] = "6403015474",
    ["ลีน่า [thai song]"] = "2022106417",
    ["ชั้นสูง [thai song]"] = "2022106417",
    ["ซูู๋ [thai song]"] = "7613820014",
    ["เหงียว [thai song]"] = "8842446965",
    ["ช้าง [thai song]"] = "4776398821",
    ["งง [thai song]"] = "8092840675",
    ["oh [thai song]"] = "4496966777",
    ["sky [thai song]"] = "7029099738",
    ["ชิปปี้ [thai song]"] = "16190783444",
    ["มวย [thai song]"] = "1837213982",
    ["เพลงเรื้อนดังจัด [thai song]"] = "4776398821",
    ["เฉาก๊วยชากังราว [thai song]"] = "6443075967",
    ["เจอคุณที่ไหนผมเล่นคุณแน่ [thai song]"] = "7604551267",
    ["หัวเราะบ้าคลั่ง [thai song]"] = "7558247326",
    ["ไปคุยกับรากมะม่วง [thai song]"] = "7373860637",
    ["พูดไม่พูด [thai song]"] = "8991869195",
    ["เกมดีคุณภาพดี [thai song]"] = "7740600611",
    ["อย่าๆๆ [thai song]"] = "8670083387",
    ["UwU [thai song]"] = "9127269097",
    ["เพลงไทย [thai song]"] = "1838606588",
    ["into [thai song]"] = "9047105108",
    ["into 2 [thai song]"] = "1844529267",
    ["เพลงอีสาน [thai song]"] = "1835604467",
    ["Gay [thai song]"] = "18841893567",
    ["ฮั่นเเน่ [thai song]"] = "7521779250",
    ["-- SPRITE x GUYGEEGEE - ปิ้ว ปิ้ว [thai song]"] = "8162876107",
    ["-- ลูกอม - วัชราวลี [thai song]"] = "8157248378",
    ["-- padoru padoru [thai song]"] = "8180089905",
    ["-- Jungji - Me&you l prod. snorkatje [thai song]"] = "8157343830",
    ["-- ไม่บอกเธอ - Bedroom Audio [thai song]"] = "8150409590",
    ["-- Sunkissed - Urworld [thai song]"] = "8157250183",
    ["-- ZOHAN - วัยรุ่นฟีฟาย [thai song]"] = "8150262398",
    ["dejavu [thai song]"] = "16831106636",
    ["chaseing cloud [thai song]"] = "5410082097",
    ["โกโกวา [thai song]"] = "7738210779",
    ["เพลงร็อค [thai song]"] = "9038254566",
    ["DJ [thai song]"] = "8260658079",
    ["EDM [thai song]"] = "5410085763",
    ["มวยไทย [thai song]"] = "1837213982",
    ["ด่าโปร [thai song]"] = "2948576192",
    ["ไทย [thai song]"] = "1840692534",
    ["ไทย2 [thai song]"] = "1835604508",
    ["ไทย3 [thai song]"] = "1835605155",
    ["ตาย [thai song]"] = "12222242",
    ["เบบี้ [thai song]"] = "1838998127",
    ["เบบี้2 [thai song]"] = "1847418299",
    ["แก่ร้อง [thai song]"] = "135488453",
    ["niki [thai song]"] = "6202951039",
    ["ty [thai song]"] = "118939739460633",
    ["เศร้า [thai song]"] = "135308045",
    ["บูส [thai song]"] = "17422168798",
    ["ท่อ [thai song]"] = "6729922069",
    ["ฮันนีมูนที่พัทยา (Pattaya Honeymoon) [thai song]"] = "123041581144867",
    ["วันของเรา (Slow Down) [thai song]"] = "105542779699783",
    ["ดิ่งไปกับเธอ Deep in the Blue [thai song]"] = "120063018283904",
    ["วันสบายริมทะเล (Beach Day) [thai song]"] = "116275201837825",
    ["สายลมที่หัวหิน (Hua Hin Breeze) [thai song]"] = "96635112875488",
    ["พัทยา...รักที่ไม่ลืม (Pattaya Love) [thai song]"] = "109200570567041",
    ["เพลงเพราะ [thai song]"] = "136258168575085",
    ["เพลงเพราะเขมร [thai song]"] = "135635055015326",
    ["เพลงเพราะเขมร 2 [thai song]"] = "78886704133381",
    ["ความรักร้อนแรงเพราะ [thai song]"] = "130511853703728",
    ["เพลงอีสานไทย [thai song]"] = "1838606588",
    ["พรุ่งนี้ขอลาบวชลูกทุ่ง [thai song]"] = "106433358101841",
    ["เพลงฝรั่งเพราะ [thai song]"] = "1835852359",
    ["แว่นมานี่มา [thai song]"] = "117978935542058",
    ["ให้บุญนำพา [thai song]"] = "121401175748107",
    ["นครดารา [thai song]"] = "121982159714181",
    ["เจิดจรัส [thai song]"] = "125608934117962",
    ["จกเห็ด [thai song]"] = "82067744446912",
    ["แดนซ์ฟอเอเว้อยัง [thai song]"] = "88218150900826",
    ["แดนซ์ดิสแมว [thai song]"] = "82268015602309",
    ["ฝนเทลงมา แดนซ์ [thai song]"] = "100358962904805",
    ["ไฟเยอร์ [thai song]"] = "90060121064394",
    ["กุหลาบ แดนซ์ [thai song]"] = "134041350719923",
    ["โตมาชิกูลู แดนซ์ [thai song]"] = "122234561521914",
    ["Love Story แดนซ์ [thai song]"] = "107341259483191",
    ["แดนซ์3ช่า [thai song]"] = "77083021272651",
    ["Feel Only Love แดนซ์ [thai song]"] = "104177688386014",
    ["เพลงเขมรแดนซ์ [thai song]"] = "129147630761109",
    ["Ya Odna แดนซ์ [thai song]"] = "77759116439066",
    ["อีกแล้ว meyou [thai song]"] = "122153509991644",
    ["เพลงแดนซ์ เขมร shot fired [thai song]"] = "128758628542494",
    ["รำอินโด [thai song]"] = "131823605746880",
    ["นอนจับมือกันครั้งแรก [thai song]"] = "121276605541778",
    ["very very small [thai song]"] = "133168271786456",
    ["ไม่เคยเปลี่ยน [thai song]"] = "88786570916778",
    ["wish cover [thai song]"] = "93403889102174",
    ["อ้อนแอ้น น่ารักดี [thai song]"] = "89457828122770",
    ["ตามบายครับ [thai song]"] = "87501744252147",
    ["กอด qler [thai song]"] = "106741004338953",
    ["18 TINE [thai song]"] = "128326685025032",
    ["เรื่องเดิมๆ [thai song]"] = "89896691032128",
    ["citadel bait 15 วิ ดัง [thai song]"] = "88915151739785",
    ["under my skin [thai song]"] = "99637556855125",
    ["bad boy nightcore [thai song]"] = "74879185449500",
    ["UNDERGROUND CULT - LET EM ROTT [thai song]"] = "118225359190317",
    ["i cant handle change hoodtrap - @prodwhite_ [thai song]"] = "73685038553576",
    ["ปลากระป๋องโรซ่า แดนซ์ยกล้อ [thai song]"] = "123136051174687",
    ["7 นาทีแดนซ์ [thai song]"] = "103250610928975",
    ["bubble gum clairo [thai song]"] = "140424585532023",
    ["p4rkr drama [thai song]"] = "85953515558394",
    ["รักฉันไหม [thai song]"] = "83560804637366",
    ["บ่าวกรรมกร [thai song]"] = "135262236244950",
}

local SongOptions = {}
for name in pairs(MusicList) do
    table.insert(SongOptions, name)
end

-- สร้างดรอปดาวน์เลือกเพลง
local SelectedSongName = nil
local SelectedSongID = nil

local Dropdown = MusicSection:CreateDropdown({
    Name = "เลือกเพลง",
    Options = SongOptions,
    Flag = "MusicDropdown",
    Callback = function(selected)
        SelectedSongName = selected
        SelectedSongID = MusicList[selected]
    end
})

-- ปุ่มเล่นเพลง
MusicSection:CreateButton({
    Name = "Play",
    Callback = function()
        if not SelectedSongID then
            SlayLib:Notify({
                Title="Music Player",
                Content="กรุณาเลือกเพลงก่อนเล่น!",
                Type="Warning",
                Duration=4
            })
            return
        end

        -- ส่ง Remote ทั้ง 3 ตัวพร้อมกัน
        local songID = SelectedSongID
        local args1 = {"PickingScooterMusicText", songID, [4] = true}
        local args2 = {"ToolMusicText", songID, [4] = true}
        local args3 = {"PickingHorseMusicText", songID, [4] = true}

        local RE = game:GetService("ReplicatedStorage"):WaitForChild("RE")
        RE:WaitForChild("1NoMoto1rVehicle1s"):FireServer(unpack(args1))
        RE:WaitForChild("PlayerToolEvent"):FireServer(unpack(args2))
        RE:WaitForChild("1Hors1eRemot1e"):FireServer(unpack(args3))

        -- แจ้งเตือนว่าเล่นเพลงอะไร
        SlayLib:Notify({
            Title="กำลังเล่นเพลง",
            Content=SelectedSongName.." (ID: "..songID..")",
            Type="Success",
            Duration=6
        })
    end
})

-- ปุ่มใหม่: Play House Music (ใช้เพลงจาก Dropdown)
MusicSection:CreateButton({
    Name = "Play House Music",
    Callback = function()
        local selectedSong = SlayLib.Flags["SelectSong"]  -- ดึงเพลงจาก Dropdown
        if not selectedSong or selectedSong == "" then
            SlayLib:Notify({
                Title = "No Song Selected",
                Content = "กรุณาเลือกเพลงก่อนเล่น House Music",
                Type = "Warning",
                Duration = 5
            })
            return
        end
        
        local args = {
            "PickHouseMusicText",
            songID, -- ใช้ ID ที่เลือกจาก Dropdown
            [4] = true
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Player1sHous1e"):FireServer(unpack(args))
        
        SlayLib:Notify({
            Title="กำลังเล่นเพลง",
            Content=SelectedSongName.." (ID: "..songID..")",
            Type="Success",
            Duration=6
        })
    end
})

------------------------------------------------------------
-- Notify
------------------------------------------------------------
SlayLib:Notify({
	Title="All-in-One Script",
	Content="Loaded successfully with Fly, Invisible, Noclip, POV, TP, Spin, ESP, and Stats!",
	Type="Success",
	Duration=6
})

_G.a = Connections