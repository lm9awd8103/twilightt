--// Twilight Hub //--
-- tower of jump hub, by twilight
-- ui: windui 1.6.66 (pinned, newer versions break my stuff)
-- v3.2 FIXED: cleanup BEFORE WindUI load (orphaned ScreenGui handle killed CreateWindow),
-- fresh module per attempt, 1 CreateWindow per module, bounded waits, async ControlModule.

local VER = "1.6.66"

-- services first. WindUI is loaded AFTER cleanup (order matters, see STEP 1).
local cloneref = (cloneref or clonereference or clone_ref)
local function cref(o) if cloneref and o then local ok, r = pcall(cloneref, o) if ok and r then return r end end return o end
local players = cref(game:GetService("Players"))
local rs = cref(game:GetService("ReplicatedStorage"))
local uis = cref(game:GetService("UserInputService"))
local runSvc = cref(game:GetService("RunService"))
local lp = players.LocalPlayer
if not lp then
    local t0 = os.clock()
    while not players.LocalPlayer and os.clock() - t0 < 15 do task.wait() end
    lp = players.LocalPlayer
end
if not lp then warn("[Twilight] no LocalPlayer") return end

-- STEP 1: cleanup BEFORE loading WindUI.
-- WindUI grabs its ScreenGui handle when the module runs; deleting GUIs after
-- that orphans the handle and every CreateWindow dies with:
--   "Window is not a valid member of ScreenGui WindUI".
-- A 2nd CreateWindow on the same module (esp. after a Destroy) dies the same way.
-- So: destroy old refs, delete WindUI* guis, verify clean, THEN load.
local function windCount()
    local n = 0
    pcall(function()
        local h = (gethui and gethui()) or game:GetService("CoreGui")
        for _, c in ipairs(h:GetChildren()) do
            if c.Name and c.Name:sub(1, 6) == "WindUI" then n = n + 1 end
        end
    end)
    return n
end
local function cleanupWait(timeoutS)
    pcall(function()
        if _G.TwilightWindow and type(_G.TwilightWindow.Destroy) == "function" then
            pcall(function() _G.TwilightWindow:Destroy() end)
        end
    end)
    _G.TwilightWindow = nil
    _G.TwilightUI = nil
    pcall(function()
        local h = nil
        if gethui then h = gethui()
        elseif get_hidden_gui then h = get_hidden_gui()
        elseif get_hidden_ui then h = get_hidden_ui() end
        if not h then h = game:GetService("CoreGui") end
        for _, c in ipairs(h:GetChildren()) do
            if c.Name and c.Name:sub(1, 6) == "WindUI" then pcall(function() c:Destroy() end) end
        end
    end)
    local t0 = os.clock()
    while os.clock() - t0 < (timeoutS or 6) do
        if windCount() == 0 then return true end
        task.wait(0.5)
    end
    return windCount() == 0
end
cleanupWait(6)

-- bounded wait: game loaded + character exists. never hangs forever anymore.
do
    local t0 = os.clock()
    while (not game:IsLoaded()) and os.clock() - t0 < 20 do task.wait() end
    if not lp.Character then
        local done = false
        local conn
        conn = lp.CharacterAdded:Connect(function() done = true if conn then conn:Disconnect() end end)
        local t1 = os.clock()
        while not lp.Character and not done and os.clock() - t1 < 15 do task.wait() end
        if conn then pcall(function() conn:Disconnect() end) end
    end
    local t2 = os.clock()
    while lp.Character and not lp.Character:FindFirstChild("HumanoidRootPart") and os.clock() - t2 < 10 do task.wait() end
end

-- game name for the title
local gname = "Tower of Jump"
pcall(function()
    gname = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

-- STEP 2: load a FRESH WindUI module (only now, after cleanup is verified).
local function loadFreshWind()
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/download/" .. VER .. "/main.lua",
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    }
    local lastErr = "unknown"
    for _, u in ipairs(urls) do
        local ok, src = pcall(function() return game:HttpGet(u) end)
        if ok and type(src) == "string" and #src > 1000 then
            local fn, lerr = loadstring(src)
            if fn then
                local ok2, lib = pcall(fn)
                if ok2 and lib then return lib end
                lastErr = "module ran but errored: " .. tostring(lib):sub(1, 150)
            else
                lastErr = "compile failed: " .. tostring(lerr):sub(1, 150)
            end
        else
            lastErr = "HttpGet failed: " .. u .. " (" .. tostring(src):sub(1, 80) .. ")"
        end
    end
    return nil, lastErr
end

-- STEP 3: create the window. ONE CreateWindow per module object, a fresh module
-- per attempt, cleanup + wait between attempts. max 3 tries.
local WindUI, win = nil, nil
local lastCreateErr = ""
local function createArgs(theme)
    local a = {
        Title = "Twilight Hub | " .. gname,
        Icon = "moon",
        Author = "made by cursed",
        Folder = "TwilightHub",
        Size = UDim2.fromOffset(580, 460),
        MinSize = Vector2.new(560, 350),
        MaxSize = Vector2.new(850, 560),
        ToggleKey = Enum.KeyCode.RightShift,
        Transparent = true,
        Resizable = true,
        SideBarWidth = 200,
        ScrollBarEnabled = false,
        OpenButton = {
            Title = "Twilight Hub",
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
        },
    }
    if theme then a.Theme = theme end
    return a
end
for attempt = 1, 3 do
    local lib, lerr = loadFreshWind()
    if not lib then
        lastCreateErr = lerr or "load failed"
        warn("[Twilight] WindUI load failed: " .. tostring(lastCreateErr))
        break
    end
    local theme = (attempt == 1) and "Violet" or (attempt == 2 and "Dark" or nil)
    local ok, res = pcall(function() return lib:CreateWindow(createArgs(theme)) end)
    if ok and res and type(res.Tab) == "function" then
        WindUI, win = lib, res
        break
    end
    lastCreateErr = tostring(res):sub(1, 250)
    warn("[Twilight] CreateWindow attempt " .. attempt .. " (" .. tostring(theme) .. ") failed: " .. lastCreateErr)
    cleanupWait(4)
    task.wait(1)
end
if not win then
    warn("[Twilight] all CreateWindow attempts failed. last: " .. tostring(lastCreateErr))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Twilight Hub",
            Text = "Window failed to create. Rejoin and run once.",
            Duration = 6,
        })
    end)
    return
end

_G.TwilightWindow = win
_G.TwilightUI = WindUI
-- shared refs so the file also runs fine in pieces (same behavior either way)
_G.TW_LP = lp _G.TW_RS = rs _G.TW_UIS = uis _G.TW_Players = players

-- only show the little pill when hub is closed (all guarded: internals changed in 1.6.65+)
pcall(function()
    if win.IsOpenButtonEnabled ~= nil then win.IsOpenButtonEnabled = true end
end)
pcall(function()
    if win.OnClose then
        win:OnClose(function()
            task.spawn(function()
                task.wait(0.35)
                pcall(function()
                    if win.Closed and win.OpenButtonMain then win.OpenButtonMain:Visible(true) end
                end)
            end)
        end)
    end
end)
pcall(function()
    if win.OnOpen then
        win:OnOpen(function()
            pcall(function()
                if win.OpenButtonMain then win.OpenButtonMain:Visible(false) end
            end)
        end)
    end
end)

-- kill the fullscreen/x buttons, keep just minimize (-) -- best effort only
task.spawn(function()
    task.wait(0.8)
    pcall(function()
        if win.UIElements and win.UIElements.Main and win.UIElements.Main.Main
            and win.UIElements.Main.Main.Topbar and win.UIElements.Main.Main.Topbar.Right then
            win.UIElements.Main.Main.Topbar.Right.Visible = true
        end
    end)
    pcall(function()
        for _, b in pairs(win.TopBarButtons or {}) do
            if b and b.Object then
                if b.Name == "Minimize" then b.Object.Visible = true else b.Object.Visible = false end
            end
        end
    end)
    pcall(function()
        if not win.Closed and win.OpenButtonMain then win.OpenButtonMain:Visible(false) end
    end)
end)

-- helpers
local function gethrp()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function gethum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function getwins()
    local ls = lp:FindFirstChild("leaderstats")
    local w = ls and ls:FindFirstChild("Wins")
    return w and w.Value or 0
end

-- instant win, touches the win pad then puts u back
local function dowin(goBack)
    local h = gethrp()
    if not h then return false end
    local spot = h.CFrame
    h.CFrame = CFrame.new(32, 224, 142) -- win pad
    task.wait(0.7)
    if goBack ~= false then
        local h2 = gethrp()
        if h2 then h2.CFrame = spot end
    end
    return true
end

-- rewards gui uses Activated not Click (took me forever to figure out lol)
local function claimall()
    local n = 0
    local pg = lp:FindFirstChild("PlayerGui")
    local gui = pg and pg:FindFirstChild("RewardsGUI")
    if gui then
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("TextButton") and d.Name == "ClaimButton" then
                local ok, t = pcall(function() return d.Text end)
                if ok and t == "CLAIM" then
                    pcall(function()
                        if firesignal then firesignal(d.Activated)
                        elseif d.Activate then d:Activate() end
                    end)
                    n = n + 1
                end
            end
        end
    end
    return n
end

-- equip best = click Equip from lowest to highest, server only accepts owned ones
-- so u end up wearing the best halo/trail u actually own
local function equipbest(guiName)
    local pg = lp:FindFirstChild("PlayerGui")
    local gui = pg and pg:FindFirstChild(guiName)
    if not gui then return 0 end
    local btns = {}
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") and d.Name == "Equip" then
            local num = d.Parent and tonumber(tostring(d.Parent.Name):match("%d+"))
            if num and not btns[num] then btns[num] = d end
        end
    end
    local keys = {}
    for k in pairs(btns) do table.insert(keys, k) end
    table.sort(keys)
    for _, k in ipairs(keys) do
        pcall(function()
            if firesignal then firesignal(btns[k].MouseButton1Click)
            elseif btns[k].Activate then btns[k]:Activate() end
        end)
        task.wait(0.3)
    end
    return #keys
end

-- toggles
_G.TwilightFarm = false
_G.TwilightClaim = false
_G.TwilightNoclip = false
_G.TwilightFly = false
_G.TwilightFlySpeed = 60
_G.TwilightInfJump = false
_G.TwilightFarmDelay = 1.2
_G.TwilightESP = false
_G.TwilightAntiVoid = false
_G.TwilightAntiAFK = false

-- noclip
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.TwilightNoclip then
            local c = lp.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end
    end
end)

-- inf jump
pcall(function()
    uis.JumpRequest:Connect(function()
        if _G.TwilightInfJump then
            local h = gethum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

-- typing !stop in chat kills fly instantly
pcall(function()
    lp.Chatted:Connect(function(msg)
        if msg and msg:lower():sub(1, 5) == "!stop" then
            _G.TwilightFly = false
        end
    end)
end)

-- fly, exact port of cursed's logic: joystick via ControlModule, camera aims it
-- push forward = go. look up + forward = up, look down + forward = down
-- space = up, leftshift = down. type !stop in chat to kill it.
-- FIX: ControlModule loads async with timeout now, so a slow PlayerScripts
-- can never hang the whole hub before tabs are built. fly falls back to
-- Humanoid.MoveDirection when ControlModule isn't ready yet.
local ctrl = nil
task.spawn(function()
    pcall(function()
        local ps = lp:WaitForChild("PlayerScripts", 10)
        local pm = ps and ps:WaitForChild("PlayerModule", 10)
        local cm = pm and pm:WaitForChild("ControlModule", 10)
        if cm then ctrl = require(cm) end
    end)
end)
local function getflyparts(h)
    local bv = h:FindFirstChild("VelocityHandler")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "VelocityHandler"
        bv.MaxForce = Vector3.new(0, 0, 0)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = h
    end
    local bg = h:FindFirstChild("GyroHandler")
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "GyroHandler"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 1000
        bg.D = 50
        bg.Parent = h
    end
    return bv, bg
end
do local h = gethrp() if h then pcall(getflyparts, h) end end
pcall(function()
    lp.CharacterAdded:Connect(function(newChar)
        local h = newChar:WaitForChild("HumanoidRootPart", 10)
        if h then pcall(getflyparts, h) end
    end)
end)
pcall(function()
    runSvc.RenderStepped:Connect(function()
        local c = lp.Character
        local hh = c and c:FindFirstChildOfClass("Humanoid")
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not (c and hh and h) then return end
        local bv = h:FindFirstChild("VelocityHandler")
        local bg = h:FindFirstChild("GyroHandler")
        if not (bv and bg) then return end
        if _G.TwilightFly then
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            hh.PlatformStand = true
        else
            pcall(function()
                bv.MaxForce = Vector3.new(0, 0, 0)
                bg.MaxTorque = Vector3.new(0, 0, 0)
                hh.PlatformStand = false
            end)
            return
        end
        local camera = workspace.CurrentCamera
        if camera then pcall(function() bg.CFrame = camera.CFrame end) end
        local speed = tonumber(_G.TwilightFlySpeed) or 60
        local velocity = Vector3.new()
        local gotCtrl, direction = false, nil
        if ctrl and ctrl.GetMoveVector then
            local ok, mv = pcall(function() return ctrl:GetMoveVector() end)
            if ok and typeof(mv) == "Vector3" then gotCtrl, direction = true, mv end
        end
        if gotCtrl and camera then
            if direction.X ~= 0 then
                velocity = velocity + camera.CFrame.RightVector * (direction.X * speed)
            end
            if direction.Z ~= 0 then
                velocity = velocity - camera.CFrame.LookVector * (direction.Z * speed)
            end
        else
            -- fallback while ControlModule is still loading: Humanoid.MoveDirection (world space)
            local md = hh.MoveDirection
            if md.Magnitude > 0.01 then velocity = velocity + md * speed end
        end
        local okKey = pcall(function()
            if uis:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, speed, 0)
            elseif uis:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, speed, 0)
            end
        end)
        if not okKey then
            -- touch devices have no Space/Shift: look up + push forward = up
            if gotCtrl and camera and direction and math.abs(direction.Z) > 0.1 then
                local pitch = -camera.CFrame.LookVector.Y * -direction.Z
                if math.abs(pitch) > 0.25 then
                    velocity = velocity + Vector3.new(0, pitch * speed, 0)
                end
            end
        end
        pcall(function() bv.Velocity = velocity end)
    end)
end)

-- anti void, spawns u back if u fall
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.TwilightAntiVoid then
            local h = gethrp()
            if h and h.Position.Y < -50 then
                h.CFrame = CFrame.new(32, 10, 35)
            end
        end
    end
end)

-- anti afk
task.spawn(function()
    while true do
        task.wait(60)
        if _G.TwilightAntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)

--// HOME TAB //--
local home = win:Tab({ Title = "Home", Icon = "house" })
if not home then warn("[Twilight] Home tab failed") return end

local p1 = home:Paragraph({ Title = "Player: loading...", Desc = "Username: loading..." })
local p2 = home:Paragraph({ Title = "Stats: loading...", Desc = "Character: loading..." })
local p3 = home:Paragraph({ Title = "Server: loading...", Desc = "Place: loading..." })

local function refresh()
    local info
    pcall(function() info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    pcall(function()
        p1:SetTitle("Username: @" .. lp.Name)
        p1:SetDesc("Name: " .. lp.DisplayName)
        p2:SetTitle("Wins: " .. tostring(getwins()))
        p2:SetDesc("Server: " .. (info and info.Name or "Tower of Jump"))
        p3:SetTitle("Players: " .. #players:GetPlayers())
        p3:SetDesc("Place: " .. game.PlaceId)
    end)
end
task.spawn(function() task.wait(1) pcall(refresh) end)
-- keep info fresh + rescues it if the first try ran too early
task.spawn(function()
    while true do task.wait(10) pcall(refresh) end
end)

home:Button({ Title = "Refresh Info", Callback = function() pcall(refresh) end })
home:Button({
    Title = "Copy JobId",
    Callback = function()
        if setclipboard then setclipboard(game.JobId) end
        WindUI:Notify({ Title = "Twilight", Content = "JobId copied", Duration = 2 })
    end,
})
-- NOTE: WindUI 1.6.x Toggle uses Value (not Default). Both passed for compat.
home:Toggle({ Title = "Player ESP (name + wins)", Flag = "ESP", Value = false, Default = false, Callback = function(v) _G.TwilightESP = v end })
home:Toggle({ Title = "Anti-AFK", Flag = "AntiAFK", Value = false, Default = false, Callback = function(v) _G.TwilightAntiAFK = v end })

-- esp loop
task.spawn(function()
    local tags = {}
    while true do
        task.wait(1)
        if _G.TwilightESP then
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("Head") then
                    local head = plr.Character.Head
                    if not tags[plr.Name] or tags[plr.Name].Parent == nil then
                        local w = (plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Wins")) and plr.leaderstats.Wins.Value or "?"
                        local b = Instance.new("BillboardGui")
                        b.Name = "TwilightESP"
                        b.Size = UDim2.new(0, 120, 0, 30)
                        b.StudsOffset = Vector3.new(0, 2.5, 0)
                        b.AlwaysOnTop = true
                        b.Parent = head
                        local t = Instance.new("TextLabel")
                        t.Size = UDim2.new(1, 0, 1, 0)
                        t.BackgroundTransparency = 1
                        t.Text = plr.DisplayName .. " (" .. tostring(w) .. "w)"
                        t.TextColor3 = Color3.fromRGB(0, 200, 255)
                        t.TextStrokeTransparency = 0.2
                        t.Font = Enum.Font.GothamBold
                        t.TextSize = 13
                        t.Parent = b
                        tags[plr.Name] = b
                    end
                end
            end
        else
            for _, o in pairs(tags) do pcall(function() o:Destroy() end) end
            tags = {}
        end
    end
end)

--// MAIN TAB //--
local main = win:Tab({ Title = "Main", Icon = "zap" })

main:Button({
    Title = "Instant Win",
    Desc = "touches the win pad, +1 win",
    Callback = function()
        dowin(true)
        task.wait(0.3)
        pcall(refresh)
        WindUI:Notify({ Title = "Twilight", Content = "Wins: " .. tostring(getwins()), Duration = 2 })
    end,
})
main:Toggle({
    Title = "Auto Farm Wins",
    Flag = "AutoFarm",
    Value = false,
    Default = false,
    Callback = function(v)
        _G.TwilightFarm = v
        if v then
            task.spawn(function()
                while _G.TwilightFarm do
                    pcall(function() dowin(false) end)
                    task.wait(_G.TwilightFarmDelay)
                    local h = gethrp()
                    if h then h.CFrame = h.CFrame + Vector3.new(0, 3, 0) end
                    task.wait(0.6)
                end
            end)
        end
    end,
})
main:Slider({
    Title = "Farm Delay",
    Flag = "FarmDelay",
    Step = 0.1,
    Value = { Min = 0.5, Max = 5, Default = 1.2 },
    Callback = function(v) _G.TwilightFarmDelay = v end,
})

main:Divider()
main:Paragraph({ Title = "Teleports", Desc = "where u wanna go" })
main:Button({ Title = "Spawn", Callback = function() local h = gethrp() if h then h.CFrame = CFrame.new(32, 4, 35) end end })
main:Button({
    Title = "WIN PAD (+1 win)",
    Desc = "this is the one that gives the win",
    Callback = function() local h = gethrp() if h then h.CFrame = CFrame.new(32, 226, 142) end end,
})
main:Button({
    Title = "Teleport to Winners Room",
    Desc = "step on its pad and it sends u to winners area",
    Callback = function() local h = gethrp() if h then h.CFrame = CFrame.new(32, 235, -26) end end,
})
main:Button({
    Title = "Copy My Position",
    Callback = function()
        local h = gethrp()
        if h and setclipboard then
            setclipboard(string.format("%.1f, %.1f, %.1f", h.Position.X, h.Position.Y, h.Position.Z))
            WindUI:Notify({ Title = "Twilight", Content = "Position copied", Duration = 2 })
        end
    end,
})

main:Divider()
main:Paragraph({ Title = "Teleport to player", Desc = "pick someone then hit the button under it" })
local tpTarget = nil
local function playernames()
    local t = {}
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= lp then table.insert(t, p.DisplayName .. " (@" .. p.Name .. ")") end
    end
    if #t == 0 then t = { "No other players" } end
    return t
end
local tpPick = main:Dropdown({
    Title = "Pick a player",
    Values = playernames(),
    AllowNone = true,
    Multi = false,
    Callback = function(v)
        if type(v) == "table" then tpTarget = v[1] else tpTarget = v end
    end,
})
main:Button({
    Title = "Refresh player list",
    Callback = function() pcall(function() tpPick:Refresh(playernames()) end) end,
})
main:Button({
    Title = "Teleport to selected player",
    Callback = function()
        if not tpTarget or tpTarget == "No other players" then
            WindUI:Notify({ Title = "Twilight", Content = "pick someone first", Duration = 2 })
            return
        end
        local uname = tpTarget:match("%(@([%w_]+)%)$")
        local target = uname and players:FindFirstChild(uname)
        local th = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local h = gethrp()
        if th and h then
            h.CFrame = th.CFrame + Vector3.new(0, 3, 0)
        else
            WindUI:Notify({ Title = "Twilight", Content = "cant find them (left?)", Duration = 2 })
        end
    end,
})

--// MOVEMENT TAB //--
local move = win:Tab({ Title = "Movement", Icon = "wind" })

move:Paragraph({
    Title = "How fly works",
    Desc = "turn it on, push joystick (or WASD) and look where u wanna go. look up = up, look down = down. space = up, shift = down. type !stop in chat to kill it.",
})
move:Toggle({ Title = "Fly", Flag = "Fly", Value = false, Default = false, Callback = function(v)
    _G.TwilightFly = v
    WindUI:Notify({ Title = "Twilight", Content = v and "Fly Enabled" or "Fly Disabled", Duration = 2 })
end })
move:Slider({
    Title = "Fly Speed",
    Flag = "FlySpeed",
    Step = 5,
    Value = { Min = 20, Max = 200, Default = 60 },
    Callback = function(v) _G.TwilightFlySpeed = v end,
})
move:Slider({
    Title = "WalkSpeed",
    Flag = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(v) local h = gethum() if h then h.WalkSpeed = v end end,
})
move:Slider({
    Title = "JumpPower",
    Flag = "JumpPower",
    Step = 1,
    Value = { Min = 50, Max = 300, Default = 50 },
    Callback = function(v) local h = gethum() if h then h.JumpPower = v end end,
})
move:Toggle({ Title = "Noclip", Flag = "Noclip", Value = false, Default = false, Callback = function(v) _G.TwilightNoclip = v end })
move:Toggle({ Title = "Infinite Jump", Flag = "InfJump", Value = false, Default = false, Callback = function(v) _G.TwilightInfJump = v end })
move:Toggle({ Title = "Anti-Void", Flag = "AntiVoid", Value = false, Default = false, Callback = function(v) _G.TwilightAntiVoid = v end })
move:Button({
    Title = "Reset Speed / Jump",
    Callback = function() local h = gethum() if h then h.WalkSpeed = 16 h.JumpPower = 50 end end,
})

--// MISC TAB //--
local misc = win:Tab({ Title = "Misc", Icon = "gift" })

misc:Button({
    Title = "Equip Best Halo",
    Desc = "puts on the best halo u own",
    Callback = function()
        task.spawn(function()
            equipbest("HaloGui")
            WindUI:Notify({ Title = "Twilight", Content = "Best halo equipped", Duration = 2 })
        end)
    end,
})
misc:Button({
    Title = "Equip Best Trail",
    Desc = "puts on the best trail u own",
    Callback = function()
        task.spawn(function()
            equipbest("TrailsGUI")
            WindUI:Notify({ Title = "Twilight", Content = "Best trail equipped", Duration = 2 })
        end)
    end,
})
misc:Toggle({
    Title = "Auto Equip Best (halo + trail)",
    Desc = "re-equips on respawn so u never lose em",
    Flag = "AutoCosmetic",
    Value = false,
    Default = false,
    Callback = function(v)
        _G.TwilightAutoCosmetic = v
        if v then
            task.spawn(function()
                equipbest("HaloGui")
                equipbest("TrailsGUI")
            end)
        end
    end,
})
pcall(function()
    lp.CharacterAdded:Connect(function()
        if _G.TwilightAutoCosmetic then
            task.wait(2)
            equipbest("HaloGui")
            equipbest("TrailsGUI")
        end
    end)
end)

misc:Button({
    Title = "Claim Rewards Now",
    Callback = function()
        local n = claimall()
        WindUI:Notify({ Title = "Twilight", Content = "Claimed " .. tostring(n), Duration = 2 })
    end,
})
misc:Toggle({
    Title = "Auto Claim Rewards",
    Flag = "AutoClaim",
    Value = false,
    Default = false,
    Callback = function(v)
        _G.TwilightClaim = v
        if v then
            task.spawn(function()
                while _G.TwilightClaim do pcall(claimall) task.wait(5) end
            end)
        end
    end,
})
misc:Divider()
misc:Button({
    Title = "Rejoin Server",
    Callback = function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) end,
})
misc:Button({
    Title = "Server Hop",
    Desc = "find a new server",
    Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end,
})
misc:Button({
    Title = "FPS Boost",
    Desc = "kills shadows n effects for fps",
    Callback = function()
        pcall(function()
            local l = game:GetService("Lighting")
            l.GlobalShadows = false
            l.FogEnd = 1e9
            for _, v in ipairs(l:GetChildren()) do
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then v.Enabled = false end
            end
            pcall(function()
                local ug = UserSettings and UserSettings():GetService("UserGameSettings")
                if ug then ug.SavedQualityLevel = Enum.SavedQualitySetting.Performance end
            end)
        end)
        WindUI:Notify({ Title = "Twilight", Content = "FPS Boost applied", Duration = 2 })
    end,
})

--// SETTINGS TAB //--
local settingsTab = win:Tab({ Title = "Settings", Icon = "settings" })
settingsTab:Toggle({
    Title = "Transparent Window",
    Flag = "TransparentUI",
    Value = true,
    Default = true,
    Callback = function(v) pcall(function() win:ToggleTransparency(v) end) end,
})
settingsTab:Dropdown({
    Title = "Theme",
    Flag = "ThemePick",
    Values = { "Violet", "Midnight", "Sky", "Indigo", "CottonCandy", "Emerald", "Dark", "Amber" },
    Value = "Violet",
    AllowNone = false,
    Callback = function(v)
        if type(v) == "table" then v = v[1] end
        pcall(function() WindUI:SetTheme(v) end)
    end,
})
-- NOTE: WindUI 1.6.x Keybind uses Value = "RightShift" (string), not Default = Enum.
settingsTab:Keybind({
    Title = "Toggle UI Key",
    Flag = "ToggleKey",
    Value = "RightShift",
    Default = Enum.KeyCode.RightShift,
    Callback = function(k)
        pcall(function()
            local code = k
            if type(k) == "string" then code = Enum.KeyCode[k] end
            if typeof(code) == "EnumItem" then win:SetToggleKey(code) end
        end)
    end,
})

settingsTab:Divider()
settingsTab:Paragraph({ Title = "Configs", Desc = "saves ur toggles n sliders" })

local cfgName = "default"
local nameInput = settingsTab:Input({
    Title = "Config Name",
    Value = "default",
    Placeholder = "config name...",
    Callback = function(v) if type(v) == "string" and #v > 0 then cfgName = v end end,
})
local cfgMgr = win.ConfigManager
local cfgList = nil
if cfgMgr and cfgMgr.AllConfigs then
    local ok, all = pcall(function() return cfgMgr:AllConfigs() end)
    cfgList = settingsTab:Dropdown({
        Title = "All Configs",
        Values = (ok and type(all) == "table" and #all > 0) and all or { "default" },
        AllowNone = true,
        Callback = function(v)
            if type(v) == "table" then v = v[1] end
            if type(v) == "string" then
                cfgName = v
                pcall(function() nameInput:Set(v) end)
            end
        end,
    })
    settingsTab:Button({
        Title = "Save Config",
        Callback = function()
            pcall(function()
                win.CurrentConfig = cfgMgr:CreateConfig(cfgName)
                if win.CurrentConfig and win.CurrentConfig.Save then
                    if win.CurrentConfig:Save() then
                        WindUI:Notify({ Title = "Twilight", Content = "Saved '" .. cfgName .. "'", Duration = 2 })
                    end
                end
            end)
            pcall(function() if cfgList and cfgList.Refresh then cfgList:Refresh(cfgMgr:AllConfigs()) end end)
        end,
    })
    settingsTab:Button({
        Title = "Load Config",
        Callback = function()
            pcall(function()
                win.CurrentConfig = cfgMgr:CreateConfig(cfgName)
                if win.CurrentConfig and win.CurrentConfig.Load then
                    if win.CurrentConfig:Load() then
                        WindUI:Notify({ Title = "Twilight", Content = "Loaded '" .. cfgName .. "'", Duration = 2 })
                    end
                end
            end)
        end,
    })
else
    settingsTab:Paragraph({ Title = "Configs unavailable", Desc = "this WindUI build has no ConfigManager" })
end

pcall(function() if win.SelectTab then win:SelectTab(1) end end)
pcall(function()
    WindUI:Notify({ Title = "Twilight Hub", Content = "Loaded! Press RightShift to toggle.", Duration = 3 })
end)
print("[Twilight] hub loaded OK")
