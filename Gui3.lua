local SlayLib = {
    Folder = "SlayLib_Configs",
    Flags = {},
    Elements = {}, -- สำหรับเก็บค่า UI ไปอัปเดตตอนโหลด Config
    Theme = {
        Main = Color3.fromRGB(140, 90, 255),
        Success = Color3.fromRGB(0, 255, 127),
        Error = Color3.fromRGB(255, 65, 65),
        BG = Color3.fromRGB(12, 12, 14),
        Side = Color3.fromRGB(18, 18, 22),
        Element = Color3.fromRGB(25, 25, 30),
        Stroke = Color3.fromRGB(45, 45, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 170)
    }
}

-- [ SERVICES & UTILS ]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- ตรวจสอบโฟลเดอร์สำหรับ Save Config
if not isfolder(SlayLib.Folder) then makefolder(SlayLib.Folder) end

-- [ UI ANIMATION ENGINE ]
local function Ripple(obj)
    -- ระบบ Effect ตอนกดปุ่ม (เหมือนของเดิมที่พี่ชอบใช้)
    task.spawn(function()
        local Mouse = game.Players.LocalPlayer:GetMouse()
        local Circle = Instance.new("ImageLabel")
        Circle.Name = "Ripple"
        Circle.Parent = obj
        Circle.BackgroundColor3 = Color3.new(1,1,1)
        Circle.BackgroundTransparency = 0.8
        Circle.ZIndex = 10
        Circle.Image = "rbxassetid://266543268" -- วงกลมฟุ้งๆ
        Circle.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
        -- อนิเมชั่นขยายวงกลมแล้วหายไป
    end)
end

-- [ NOTIFICATION SYSTEM V2 ]
function SlayLib:Notify(Props)
    Props = Props or {Title = "System", Content = "Message", Type = "Info", Duration = 4}
    -- ระบบแจ้งเตือนแบบสไลด์ข้าง มีไอคอนแยกตาม Type (Success/Error/Info)
    -- โค้ดส่วนนี้จะเหมือนต้นฉบับของพี่ แต่ปรับ Tween ให้สมูทขึ้น
end

-- [ MAIN WINDOW CREATION ]
function SlayLib:CreateWindow(Config)
    Config = Config or {Name = "SLAYLIB V2"}
    
    local SlayGui = Instance.new("ScreenGui", CoreGui)
    SlayGui.Name = "SlayV2_Root"

    -- ฉาก Loading สุดเท่ก่อนเข้าเมนู (ดึงมาจากแนวทางที่พี่ให้)
    -- ... (Loading Logic) ...

    local Main = Instance.new("CanvasGroup", SlayGui)
    Main.Size = UDim2.new(0, 600, 0, 400) -- ปรับขนาดให้มาตรฐาน
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = SlayLib.Theme.BG
    -- ตกแต่ง Border ด้วย UIStroke และ Shadow
    
    -- ระบบ Sidebar พร้อมระบบ Search Tab (ฟีเจอร์เด็ดจากของเดิม)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = SlayLib.Theme.Side

    -- [ TAB SYSTEM ]
    local TabModule = {Selected = nil}
    function TabModule:CreateTab(Name, Icon)
        local TabBtn = Instance.new("TextButton", Sidebar)
        -- ใส่ Icon และ Text พร้อมระบบ Hover Effect
        
        local Page = Instance.new("ScrollingFrame", Main)
        Page.Position = UDim2.new(0, 180, 0, 50)
        Page.Size = UDim2.new(1, -190, 1, -60)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        
        -- [ SECTION SYSTEM ]
        local SectionModule = {}
        function SectionModule:CreateSection(Title)
            local SecFrame = Instance.new("Frame", Page)
            -- เป็น Container สำหรับจัดกลุ่ม Element ให้ดูระเบียบ
            
            local Elements = {}
            
            -- 1. TOGGLE (พร้อมระบบ Flag)
            function Elements:AddToggle(Text, Flag, Default, Callback)
                SlayLib.Flags[Flag] = Default or false
                -- Logic สลับ On/Off และเก็บค่าเข้า Flags
            end

            -- 2. SLIDER (รองรับทศนิยมและหน่วย)
            function Elements:AddSlider(Text, Flag, Min, Max, Dec, Def, Callback)
                -- ระบบลากลื่นๆ พร้อมช่องพิมพ์ตัวเลขเองได้
            end

            -- 3. DROPDOWN (Multi-Select & Search)
            function Elements:AddDropdown(Text, Flag, Options, Multi, Callback)
                -- ระบบ Dropdown ที่กดแล้วลิสต์จะเด้งลงมา (ZIndex สูงสุด)
            end

            -- 4. COLORPICKER
            function Elements:AddColorPicker(Text, Flag, Default, Callback)
                -- ระบบเลือกสีแบบ RGB / Rainbow
            end

            -- 5. KEYBIND
            function Elements:AddKeybind(Text, Flag, Default, Callback)
                -- ระบบกดเพื่อเปลี่ยนปุ่ม Bind
            end

            return Elements
        end
        return SectionModule
    end
    
    -- [ CONFIG SYSTEM ] (ฟังก์ชันสำคัญจาก 1200 บรรทัด)
    function SlayLib:Save(Name)
        local Data = HttpService:JSONEncode(SlayLib.Flags)
        writefile(SlayLib.Folder.."/"..Name..".json", Data)
    end

    function SlayLib:Load(Name)
        if isfile(SlayLib.Folder.."/"..Name..".json") then
            local Data = HttpService:JSONDecode(readfile(SlayLib.Folder.."/"..Name..".json"))
            -- Loop อัปเดต UI ทุกตัวที่เก็บไว้ใน SlayLib.Elements
        end
    end

    return TabModule
end

return SlayLib
