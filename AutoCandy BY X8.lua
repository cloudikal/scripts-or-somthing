local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

if _G.LarpcandyDisconnect then
    pcall(_G.LarpcandyDisconnect)
    _G.LarpcandyDisconnect = nil
end
if _G.LarpcandyCycleConn then
    pcall(function() _G.LarpcandyCycleConn:Disconnect() end)
    _G.LarpcandyCycleConn = nil
end

local cachedHalloweenService = nil
local cachedHalloweenConfig = nil
local cachedHalloweenScenes = nil

local function getHalloweenService()
    if cachedHalloweenService then return cachedHalloweenService end
    for _, inst in ipairs(getinstances()) do
        local okName, name = pcall(function() return inst.Name end)
        if okName and name == "HalloweenServiceClient" and inst:IsA("ModuleScript") then
            local ok, srv = pcall(require, inst)
            if ok and srv then
                cachedHalloweenService = srv
                return srv
            end
        end
    end
    return nil
end

local function getHalloweenConfig()
    if cachedHalloweenConfig then return cachedHalloweenConfig end
    for _, inst in ipairs(getinstances()) do
        local okName, name = pcall(function() return inst.Name end)
        if okName and name == "HalloweenConfig" and inst:IsA("ModuleScript") then
            local ok, cfg = pcall(require, inst)
            if ok and cfg then
                cachedHalloweenConfig = cfg
                return cfg
            end
        end
    end
    return nil
end

local function getHalloweenScenes()
    if cachedHalloweenScenes then return cachedHalloweenScenes end
    for _, inst in ipairs(getinstances()) do
        local okName, name = pcall(function() return inst.Name end)
        if okName and name == "HalloweenScenes" and inst:IsA("ModuleScript") then
            local ok, scn = pcall(require, inst)
            if ok and scn then
                cachedHalloweenScenes = scn
                return scn
            end
        end
    end
    return nil
end

local function getRereUI()
    local r = _G.LarpkuranRereUI or _G.LarpcandyRereUI
    if r and r.Internal and (r.Internal._errored or (r.Internal._cycleCoroutine and coroutine.status(r.Internal._cycleCoroutine) == "dead")) then
        if r.Shutdown then pcall(r.Shutdown) end
        r = nil
        _G.LarpcandyRereUI = nil
    end
    if not r then
        if _G.LarpkuranRere and _G.LarpkuranRere.RenderPerks then
            local ok, up = pcall(debug.getupvalue, _G.LarpkuranRere.RenderPerks, 1)
            if ok and up and up.Window then r = up end
        end
    end
    if not r then
        local src = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/745cd0bd9c0ad11d679a926dce51935742dcb230/src/rere-beta.lua")
        r = loadstring(src)()
        local targetGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        r.Init(targetGui, false)
        _G.LarpcandyRereUI = r
    end
    return r
end

local Rere = getRereUI()
assert(Rere, "Failed to load Rere UI library")

pcall(function()
    local grayTheme = table.clone(Rere.TemplateConfig.colorDark)
    for name, value in pairs(grayTheme) do
        if typeof(value) == "Color3" then
            local gray = value.R * 0.2126 + value.G * 0.7152 + value.B * 0.0722
            grayTheme[name] = Color3.new(gray, gray, gray)
        end
    end
    grayTheme.WindowBgColor = Color3.fromRGB(24, 24, 28)
    grayTheme.TitleBgActiveColor = Color3.fromRGB(36, 36, 42)
    grayTheme.FrameBgColor = Color3.fromRGB(48, 48, 56)
    grayTheme.FrameBgHoveredColor = Color3.fromRGB(72, 72, 82)
    grayTheme.FrameBgActiveColor = Color3.fromRGB(90, 90, 102)
    grayTheme.ButtonColor = Color3.fromRGB(60, 60, 70)
    grayTheme.ButtonHoveredColor = Color3.fromRGB(80, 80, 95)
    grayTheme.ButtonActiveColor = Color3.fromRGB(100, 100, 120)
    grayTheme.HeaderColor = Color3.fromRGB(50, 50, 60)
    grayTheme.HeaderHoveredColor = Color3.fromRGB(70, 70, 82)
    grayTheme.HeaderActiveColor = Color3.fromRGB(85, 85, 100)
    grayTheme.TabColor = Color3.fromRGB(38, 38, 46)
    grayTheme.TabHoveredColor = Color3.fromRGB(60, 60, 72)
    grayTheme.TabActiveColor = Color3.fromRGB(75, 75, 90)
    grayTheme.CheckMarkColor = Color3.fromRGB(255, 160, 50)
    grayTheme.SliderGrabColor = Color3.fromRGB(200, 140, 50)
    grayTheme.SliderGrabActiveColor = Color3.fromRGB(255, 170, 60)
    Rere.UpdateGlobalConfig(grayTheme)
end)

local runtime = {
    AutoFarm = false,
    FarmMode = "Treat",
    Delay = 0.35,
    SafeReturn = true,
    AutoLoop = true,
    Running = false,
    Status = "Idle",
    Target = "-",
    Visited = 0,
    OriginCF = nil,
    WondersRunning = false,
    WondersStatus = "Idle",
    WaitNightForWonders = true,
    GutsRunning = false,
    GutsStatus = "Idle",
    CapSpeed = false
}

local wonderData = {
    {id = "Piano", name = "Music Room Piano", kanji = "音楽室のピアノ", pos = Vector3.new(140.3, -225.1, 52.3), sitePos = Vector3.new(136, -227.7, 51)},
    {id = "Stairs", name = "13th Step Stairs", kanji = "十三階段", pos = Vector3.new(175.0, -259.9, 51.5), sitePos = Vector3.new(175, -262.5, 53)},
    {id = "Hanako", name = "Hanako-san Toilet", kanji = "トイレの花子さん", pos = Vector3.new(91.6, -241.6, 52.6), sitePos = Vector3.new(90.6, -244.6, 52.4)},
    {id = "Model", name = "Anatomy Model", kanji = "動く人体模型", pos = Vector3.new(220.0, -258.6, 128.0), sitePos = Vector3.new(220, -261.9, 128)},
    {id = "Statue", name = "Running Statue", kanji = "走る二宮像", pos = Vector3.new(82.6, -262.4, 186.0), sitePos = Vector3.new(80, -258, 186)},
    {id = "Mirror", name = "3:33 Mirror", kanji = "三時三十三分の鏡", pos = Vector3.new(195.3, -250.6, 279.0), sitePos = Vector3.new(196.8, -253.5, 279)},
    {id = "Photo", name = "Spirit Photo", kanji = "心霊写真", pos = Vector3.new(63.4, -223.2, 40.2), sitePos = Vector3.new(63.4, -227.8, 40.2)},
    {id = "Eighth", name = "Eighth Wonder (3-C)", kanji = "八番目の不思議", pos = Vector3.new(199.4, -223.3, 178.1), sitePos = Vector3.new(206.6, -227.8, 178.6)}
}

local function getInGameTimeInfo()
    local cfg = getHalloweenConfig()
    local mins = cfg and cfg.Minutes and cfg.Minutes() or 720
    local hours = math.floor(mins / 60)
    local remainMins = math.floor(mins % 60)
    local isNight = mins < 360 or mins >= 1260
    local isMirrorTime = mins >= 213 and mins <= 360
    local untilNightMins = 0
    if not isNight then
        untilNightMins = math.max(0, 1260 - mins)
    end
    local untilNightSecs = math.floor(untilNightMins / 0.3)
    return {
        minutes = mins,
        hours = hours,
        remainMins = remainMins,
        isNight = isNight,
        isMirrorTime = isMirrorTime,
        untilNightSecs = untilNightSecs,
        formatted = string.format("%02d:%02d", hours, remainMins)
    }
end

local function getAvailableHouses()
    local ttFolder = Workspace:FindFirstChild("HalloweenTrickOrTreat")
    if not ttFolder then return {} end
    local list = {}
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.zero
    for _, house in ipairs(ttFolder:GetChildren()) do
        local doorstep = house:FindFirstChild("Doorstep")
        if doorstep then
            local treatPrompt = doorstep:FindFirstChild("TrickOrTreattreat")
            if treatPrompt and treatPrompt.Enabled and treatPrompt.ObjectText ~= "already papered" then
                local dist = (doorstep.Position - myPos).Magnitude
                table.insert(list, {
                    house = house,
                    doorstep = doorstep,
                    treatPrompt = treatPrompt,
                    trickPrompt = doorstep:FindFirstChild("TrickOrTreattrick"),
                    dist = dist
                })
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

local function executeFarmCycle(once)
    if runtime.Running then return end
    runtime.Running = true
    task.spawn(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and not runtime.OriginCF then
            runtime.OriginCF = hrp.CFrame
        end

        while runtime.Running and (runtime.AutoFarm or once) do
            local houses = getAvailableHouses()
            if #houses == 0 then
                runtime.Status = "Waiting for cooldown (0 ready)"
                runtime.Target = "All houses on cooldown"
                if once or not runtime.AutoLoop then
                    break
                end
                task.wait(5)
            else
                runtime.Status = "Farming " .. tostring(#houses) .. " houses..."
                for idx, entry in ipairs(houses) do
                    if not runtime.Running or (not runtime.AutoFarm and not once) then
                        break
                    end
                    local curChar = LocalPlayer.Character
                    local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                    if not curHrp then
                        runtime.Status = "Waiting for character respawn..."
                        task.wait(1)
                        break
                    end
                    runtime.Target = string.format("%s (%d/%d)", entry.house.Name, idx, #houses)
                    runtime.Status = "Teleporting to " .. entry.house.Name
                    curHrp.CFrame = entry.doorstep.CFrame + Vector3.new(0, 2.5, 0)
                    curHrp.AssemblyLinearVelocity = Vector3.zero
                    task.wait(runtime.Delay)
                    if runtime.FarmMode == "Trick" and entry.trickPrompt and entry.trickPrompt.Enabled then
                        runtime.Status = "Tricking " .. entry.house.Name
                        for _ = 1, 3 do
                            if entry.trickPrompt and entry.trickPrompt.Enabled then
                                fireproximityprompt(entry.trickPrompt)
                                task.wait(runtime.Delay)
                            end
                        end
                    elseif entry.treatPrompt and entry.treatPrompt.Enabled then
                        runtime.Status = "Treating " .. entry.house.Name
                        fireproximityprompt(entry.treatPrompt)
                        task.wait(runtime.Delay)
                    end
                    runtime.Visited = runtime.Visited + 1
                    task.wait(runtime.Delay)
                end
                if once then break end
                if runtime.SafeReturn and runtime.OriginCF then
                    local backChar = LocalPlayer.Character
                    local backHrp = backChar and backChar:FindFirstChild("HumanoidRootPart")
                    if backHrp then
                        backHrp.CFrame = runtime.OriginCF
                        backHrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end
                if not runtime.AutoLoop then break end
                runtime.Status = "Cycle complete. Waiting for cooldown..."
                task.wait(10)
            end
        end

        if runtime.SafeReturn and runtime.OriginCF then
            local endChar = LocalPlayer.Character
            local endHrp = endChar and endChar:FindFirstChild("HumanoidRootPart")
            if endHrp then
                endHrp.CFrame = runtime.OriginCF
                endHrp.AssemblyLinearVelocity = Vector3.zero
            end
        end

        runtime.Running = false
        runtime.AutoFarm = false
        runtime.Status = "Idle"
        runtime.Target = "-"
    end)
end

local function teleportToNearestHouse()
    local ready = getAvailableHouses()
    if ready[1] then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = ready[1].doorstep.CFrame + Vector3.new(0, 2.5, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function solveSingleWonder(wonderId, timeoutSecs)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "No character" end
    local wonderRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("HalloweenWonder")
    local hallowRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Halloween")
    if not wonderRemote then return false, "No HalloweenWonder remote" end

    local targetEntry = nil
    for _, w in ipairs(wonderData) do
        if w.id:lower() == wonderId:lower() then
            targetEntry = w
            break
        end
    end
    if not targetEntry then return false, "Unknown wonder" end

    local session = {
        Id = targetEntry.id,
        Done = false,
        Success = false,
        Locked = false,
        Reason = ""
    }

    local wonderConn, hallowConn
    wonderConn = wonderRemote.OnClientEvent:Connect(function(event, data)
        if typeof(event) ~= "string" or typeof(data) ~= "table" then return end
        if event == "Waiting" and data.Id == session.Id then
            task.wait(0.2)
            wonderRemote:FireServer("StartNow", {Id = session.Id})
        elseif event == "Start" and tostring(data.Id) == session.Id then
            if session.Id == "Piano" and typeof(data.Notes) == "table" then
                task.spawn(function()
                    task.wait(1.4)
                    wonderRemote:FireServer("Step", {Kind = "Answer", Notes = data.Notes, Round = 1})
                end)
            elseif session.Id == "Hanako" and data.Stall then
                task.spawn(function()
                    task.wait(1.2)
                    wonderRemote:FireServer("Step", {Kind = "Pick", Stall = tonumber(data.Stall) or 1})
                end)
            elseif session.Id == "Mirror" and data.Odd then
                task.spawn(function()
                    task.wait(1.2)
                    wonderRemote:FireServer("Step", {Kind = "Pick", Index = tonumber(data.Odd) or 1})
                end)
            elseif session.Id == "Photo" then
                task.spawn(function()
                    task.wait(2.2)
                    wonderRemote:FireServer("Step", {Kind = "Done"})
                end)
            elseif session.Id == "Statue" then
                task.spawn(function()
                    task.wait(1)
                    local curChar = LocalPlayer.Character
                    local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                    if curHrp and targetEntry.sitePos then
                        curHrp.CFrame = CFrame.new(targetEntry.sitePos + Vector3.new(0, 2.5, 0))
                        curHrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
            elseif session.Id == "Eighth" then
                task.spawn(function()
                    task.wait(2)
                    wonderRemote:FireServer("Step", {Kind = "Answer"})
                end)
            end
        elseif event == "Round" then
            if session.Id == "Piano" and typeof(data.Notes) == "table" then
                task.spawn(function()
                    task.wait(1.4)
                    local rnd = tonumber(data.Round) or 2
                    wonderRemote:FireServer("Step", {Kind = "Answer", Notes = data.Notes, Round = rnd})
                end)
            elseif session.Id == "Hanako" and data.Stall then
                task.spawn(function()
                    task.wait(1.2)
                    wonderRemote:FireServer("Step", {Kind = "Pick", Stall = tonumber(data.Stall) or 1})
                end)
            end
        elseif event == "Phase" and session.Id == "Statue" then
            if data.Phase == "Count" then
                task.spawn(function()
                    local curChar = LocalPlayer.Character
                    local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                    if curHrp and targetEntry.sitePos then
                        curHrp.CFrame = CFrame.new(targetEntry.sitePos + Vector3.new(0, 2.5, 0))
                        curHrp.AssemblyLinearVelocity = Vector3.zero
                    end
                    task.wait(0.3)
                    wonderRemote:FireServer("Step", {Kind = "Tap"})
                end)
            end
        elseif event == "Loose" and session.Id == "Model" then
            task.spawn(function()
                task.wait(0.5)
                local holders = data.Holders or {}
                local host = data.Host
                for organName, holderInst in pairs(holders) do
                    if typeof(holderInst) == "Instance" and holderInst:IsA("BasePart") then
                        local curChar = LocalPlayer.Character
                        local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                        if curHrp then
                            curHrp.CFrame = holderInst.CFrame + Vector3.new(0, 2, 0)
                            curHrp.AssemblyLinearVelocity = Vector3.zero
                        end
                        task.wait(0.3)
                        wonderRemote:FireServer("Step", {Kind = "Take", Organ = organName})
                        task.wait(0.3)
                        if host and host:IsA("BasePart") and curHrp then
                            curHrp.CFrame = host.CFrame + Vector3.new(0, 2, 0)
                            curHrp.AssemblyLinearVelocity = Vector3.zero
                        end
                        task.wait(0.3)
                        wonderRemote:FireServer("Step", {Kind = "Put"})
                        task.wait(0.3)
                    end
                end
            end)
        elseif event == "Elevator" and session.Id == "Stairs" then
            if data.State == "Open" then
                task.spawn(function()
                    task.wait(0.5)
                    local curChar = LocalPlayer.Character
                    local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                    if curHrp and typeof(data.Left) == "Instance" then
                        curHrp.CFrame = data.Left.CFrame + Vector3.new(0, 2, 0)
                        curHrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
            end
        elseif event == "End" then
            session.Done = true
            session.Success = (data.Success == true)
            session.Reason = tostring(data.Reason or "")
        end
    end)

    if hallowRemote then
        hallowConn = hallowRemote.OnClientEvent:Connect(function(event, data)
            if event == "WonderLocked" and typeof(data) == "table" and data.Id == session.Id then
                session.Done = true
                session.Locked = true
                session.Reason = tostring(data.Reason or "Locked")
            end
        end)
    end

    hrp.CFrame = CFrame.new(targetEntry.pos + Vector3.new(0, 2.5, 0))
    hrp.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.5)

    local folder = Workspace:FindFirstChild("HalloweenWonders")
    local model = folder and folder:FindFirstChild(targetEntry.id)
    local prompt = model and model:FindFirstChild("WonderPrompt", true)
    if prompt and prompt.Enabled then
        fireproximityprompt(prompt)
    else
        session.Done = true
        session.Reason = "Prompt disabled or missing"
    end

    local waitStart = os.clock()
    local limit = timeoutSecs or 25
    while not session.Done and (os.clock() - waitStart) < limit do
        task.wait(0.2)
    end

    if wonderConn then pcall(function() wonderConn:Disconnect() end) end
    if hallowConn then pcall(function() hallowConn:Disconnect() end) end

    return session.Success, session.Reason
end

local function interactWithWonder(wonderId)
    task.spawn(function()
        runtime.WondersStatus = "Solving " .. wonderId .. "..."
        local ok, reason = solveSingleWonder(wonderId, 25)
        if ok then
            runtime.WondersStatus = "Solved " .. wonderId .. "! (+300 Candy)"
        else
            runtime.WondersStatus = wonderId .. ": " .. (reason ~= "" and reason or "Failed")
        end
    end)
end

local function runAllWonders()
    if runtime.WondersRunning then return end
    runtime.WondersRunning = true
    task.spawn(function()
        local timeInfo = getInGameTimeInfo()
        if not timeInfo.isNight and not runtime.WaitNightForWonders then
            runtime.WondersStatus = string.format("Locked: Daytime (%s). Opens at 21:00 (Night in ~%ds)", timeInfo.formatted, timeInfo.untilNightSecs)
            runtime.WondersRunning = false
            return
        end
        while runtime.WondersRunning and not getInGameTimeInfo().isNight do
            local t = getInGameTimeInfo()
            runtime.WondersStatus = string.format("Waiting for Night... Time: %s (Opens in %ds)", t.formatted, t.untilNightSecs)
            task.wait(5)
        end
        if not runtime.WondersRunning then return end
        local srv = getHalloweenService()
        for idx, w in ipairs(wonderData) do
            if not runtime.WondersRunning then break end
            local snap = srv and srv.Snapshot
            local state = snap and snap.State or {}
            local wondersState = state.Wonders or {}
            local isDone = (w.id == "Eighth" and state.Eighth == true) or (wondersState[w.id] == true)
            if not isDone then
                if w.id == "Mirror" and not getInGameTimeInfo().isMirrorTime then
                    runtime.WondersStatus = "Skipping Mirror (Requires 3:33 AM window)..."
                    task.wait(1)
                elseif w.id == "Eighth" and not (state.SevenWonders == true or #wondersState >= 7) then
                    runtime.WondersStatus = "Skipping Eighth (Solve 7 Wonders first)..."
                    task.wait(1)
                else
                    runtime.WondersStatus = string.format("Auto-solving %s (%d/%d)...", w.name, idx, #wonderData)
                    local ok, reason = solveSingleWonder(w.id, 25)
                    if ok then
                        runtime.WondersStatus = string.format("Solved %s! (+300 Candy)", w.name)
                        task.wait(1.5)
                    else
                        runtime.WondersStatus = string.format("%s: %s", w.name, reason ~= "" and reason or "Failed")
                        task.wait(1.5)
                    end
                end
            end
        end
        runtime.WondersStatus = "All wonders cycle finished!"
        runtime.WondersRunning = false
        task.wait(3)
        if not runtime.WondersRunning then
            runtime.WondersStatus = "Idle"
        end
    end)
end

local function runGutsAutoTrial()
    if runtime.GutsRunning then
        runtime.GutsRunning = false
        runtime.GutsStatus = "Stopped"
        return
    end
    runtime.GutsRunning = true
    task.spawn(function()
        runtime.GutsStatus = "Starting Test of Guts..."
        local rem = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Halloween")
        if rem then
            rem:FireServer("Guts")
        end
        task.wait(1)
        local scn = getHalloweenScenes()
        local startTime = os.clock()
        while runtime.GutsRunning and os.clock() - startTime < 100 do
            local marker = scn and scn.GutsMarker
            if marker and marker.Target and typeof(marker.Target) == "Vector3" then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    hum.WalkSpeed = math.min(hum.WalkSpeed, 15.5)
                    local currentPos = hrp.Position
                    local targetPos = Vector3.new(marker.Target.X, currentPos.Y, marker.Target.Z)
                    local dist = (targetPos - currentPos).Magnitude
                    runtime.GutsStatus = string.format("Navigating to target (Dist: %.1f studs)...", dist)
                    if dist > 2 then
                        local dir = (targetPos - currentPos).Unit
                        local step = math.min(dist, 14.5 * 0.1)
                        hrp.CFrame = CFrame.new(currentPos + dir * step, targetPos)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    else
                        runtime.GutsStatus = "At marker! Waiting for phase update..."
                    end
                end
            else
                runtime.GutsStatus = "Waiting for Guts target marker..."
            end
            task.wait(0.1)
        end
        runtime.GutsStatus = "Guts trial completed or ended."
        runtime.GutsRunning = false
    end)
end

local uiState = {
    WindowOpen = Rere.State(true),
    WindowSize = Rere.State(Vector2.new(480, 580)),
    WindowPos = Rere.State(Vector2.new(30, 80)),
    AutoFarm = Rere.State(false),
    FarmModeIndex = Rere.State("Treat"),
    Delay = Rere.State(0.35),
    SafeReturn = Rere.State(true),
    AutoLoop = Rere.State(true),
    WaitNightForWonders = Rere.State(true),
    CapSpeed = Rere.State(false),
    Header1Uncollapsed = Rere.State(true),
    Header2Uncollapsed = Rere.State(true),
    Header3Uncollapsed = Rere.State(true),
    Header4Uncollapsed = Rere.State(false)
}

local rereDisconnect = Rere:Connect(function()
    if not uiState.WindowOpen:get() then return end
    local isMobile = UserInputService.TouchEnabled
    local win = Rere.Window({"Larpcandy", false, false, isMobile}, {isOpened = uiState.WindowOpen, size = uiState.WindowSize, position = uiState.WindowPos})
    if win and win.state and win.state.isOpened.value and win.state.isUncollapsed.value then
        local srv = getHalloweenService()
        local cfg = getHalloweenConfig()
        local snap = srv and srv.Snapshot
        local st = snap and snap.State or {}
        local candy = tonumber(st.Candy) or 0
        local earned = tonumber(st.Earned) or 0
        local hourEarned = tonumber(st.HourEarned) or 0
        local hourCap = (cfg and cfg.HourCap) or 2000
        local bonus = (cfg and cfg.CostumeBonus and cfg.CostumeBonus(st)) or 0
        local witching = (cfg and cfg.WitchingHour and cfg.WitchingHour()) or false
        local readyHouses = getAvailableHouses()
        local timeInfo = getInGameTimeInfo()

        Rere.Section({"LIVE CANDY STATUS"})
        Rere.TextColored({string.format("Candy: %d   |   Total Earned: %d", candy, earned), Color3.fromRGB(255, 170, 50)})
        Rere.Text({string.format("Hour Cap: %d / %d (%.1f%%)   |   Bonus: +%.0f%%", hourEarned, hourCap, (hourEarned / math.max(1, hourCap)) * 100, bonus * 100)})
        Rere.TextColored({string.format("Clock: %s (%s)   |   Wonders: %s", timeInfo.formatted, timeInfo.isNight and "NIGHT" or "DAY", timeInfo.isNight and "UNLOCKED (ACTIVE)" or string.format("LOCKED (Night in %ds)", timeInfo.untilNightSecs)), timeInfo.isNight and Color3.fromRGB(120, 240, 120) or Color3.fromRGB(240, 140, 80)})
        Rere.TextColored({string.format("Witching Hour: %s   |   Ready Houses: %d / 33", witching and "ACTIVE (2x CANDY!)" or "Inactive", #readyHouses), witching and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(160, 160, 160)})
        Rere.Separator()

        local h1 = Rere.CollapsingHeader({"1. Trick or Treat (Town Houses)"}, {isUncollapsed = uiState.Header1Uncollapsed})
        if h1.state.isUncollapsed.value then
            Rere.Checkbox({"Auto Farm Enabled"}, {isChecked = uiState.AutoFarm})
            if uiState.AutoFarm:get() ~= runtime.AutoFarm then
                runtime.AutoFarm = uiState.AutoFarm:get()
                if runtime.AutoFarm then
                    executeFarmCycle(false)
                else
                    runtime.Running = false
                    runtime.Status = "Stopped"
                end
            end
            Rere.SameLine()
            if Rere.Button({"Run Once"}).clicked() then
                executeFarmCycle(true)
            end
            if Rere.Button({"TP Nearest"}).clicked() then
                teleportToNearestHouse()
            end
            Rere.End()

            Rere.ComboArray({"Farm Mode"}, {index = uiState.FarmModeIndex}, {"Treat", "Trick"})
            runtime.FarmMode = uiState.FarmModeIndex:get()

            Rere.SliderNum({"Delay per House", 0.05, 0.1, 1.5, "%.2f s"}, {number = uiState.Delay})
            runtime.Delay = uiState.Delay:get()

            Rere.Checkbox({"Safe Return to Origin"}, {isChecked = uiState.SafeReturn})
            runtime.SafeReturn = uiState.SafeReturn:get()

            Rere.Checkbox({"Auto Loop on Cooldown"}, {isChecked = uiState.AutoLoop})
            runtime.AutoLoop = uiState.AutoLoop:get()

            Rere.Text({string.format("Status: %s", runtime.Status)})
            Rere.Text({string.format("Target: %s   |   Visited: %d", runtime.Target, runtime.Visited)})
        end
        Rere.End()
        Rere.Separator()

        local h2 = Rere.CollapsingHeader({"2. School Wonders (7+1 Wonders)"}, {isUncollapsed = uiState.Header2Uncollapsed})
        if h2.state.isUncollapsed.value then
            local curTime = getInGameTimeInfo()
            Rere.TextColored({string.format("School Wonders Status: %s", curTime.isNight and "UNLOCKED (Night Active)" or string.format("LOCKED: Opens at 21:00 (in %ds)", curTime.untilNightSecs)), curTime.isNight and Color3.fromRGB(120, 240, 120) or Color3.fromRGB(255, 120, 80)})
            Rere.Checkbox({"Wait for Night & Auto Solve"}, {isChecked = uiState.WaitNightForWonders})
            runtime.WaitNightForWonders = uiState.WaitNightForWonders:get()
            Rere.SameLine()
            if Rere.Button({runtime.WondersRunning and "Stop Auto Wonders" or "Auto Solve All Wonders"}).clicked() then
                if runtime.WondersRunning then
                    runtime.WondersRunning = false
                    runtime.WondersStatus = "Stopped"
                else
                    runAllWonders()
                end
            end
            if Rere.Button({"TP School Entry"}).clicked() then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(Vector3.new(140.3, -225.1, 52.3))
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
            Rere.End()
            Rere.Text({string.format("Progress: %s", runtime.WondersStatus)})
            Rere.Separator()
            local wondersState = st.Wonders or {}
            for _, w in ipairs(wonderData) do
                local done = (w.id == "Eighth" and st.Eighth == true) or (wondersState[w.id] == true)
                local tag = done and "[DONE]" or "[READY]"
                local label = string.format("%s %s (%s)", tag, w.name, w.kanji)
                local col = done and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(255, 200, 80)
                Rere.SameLine()
                Rere.TextColored({label, col})
                if Rere.Button({"Solve##" .. w.id}).clicked() then
                    interactWithWonder(w.id)
                end
                Rere.End()
            end
        end
        Rere.End()
        Rere.Separator()

        local h3 = Rere.CollapsingHeader({"3. Test of Guts (Kimodameshi / Shrine)"}, {isUncollapsed = uiState.Header3Uncollapsed})
        if h3.state.isUncollapsed.value then
            Rere.Text({"Carry candle & Ofuda to Shrine without running (>16.5 spd). Reward: 60 Candy."})
            Rere.SameLine()
            if Rere.Button({runtime.GutsRunning and "Stop Guts Trial" or "Start Auto Guts Trial"}).clicked() then
                runGutsAutoTrial()
            end
            if Rere.Button({"TP Shrine Start"}).clicked() then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(Vector3.new(14, -264.9, -175.6))
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
            Rere.End()

            Rere.Checkbox({"Speed Limiter (Lock WalkSpeed <= 15.5)"}, {isChecked = uiState.CapSpeed})
            runtime.CapSpeed = uiState.CapSpeed:get()

            Rere.Text({string.format("Guts Status: %s", runtime.GutsStatus)})
            local scn = getHalloweenScenes()
            local marker = scn and scn.GutsMarker
            if marker and marker.Target and typeof(marker.Target) == "Vector3" then
                Rere.TextColored({string.format("Target: %.1f, %.1f, %.1f", marker.Target.X, marker.Target.Y, marker.Target.Z), Color3.fromRGB(100, 255, 100)})
            else
                Rere.Text({"Target Marker: None (Not in trial)"})
            end
        end
        Rere.End()
        Rere.Separator()

        local h4 = Rere.CollapsingHeader({"Shop & Controls"}, {isUncollapsed = uiState.Header4Uncollapsed})
        if h4.state.isUncollapsed.value then
            local closesIn = snap and tonumber(snap.ClosesIn) or 0
            local countdown = (cfg and cfg.Countdown and cfg.Countdown(closesIn)) or "-"
            Rere.Text({string.format("Event Shop: %s   |   Closes In: %s", snap and snap.ShopOpen and "OPEN" or "CLOSED", countdown)})
            Rere.SameLine()
            if Rere.Button({"Toggle Event Shop GUI"}).clicked() then
                if srv then srv:Toggle() end
            end
            if Rere.Button({"Sync Event Data"}).clicked() then
                if srv and srv.Remote then srv.Remote:FireServer("Sync") end
            end
            Rere.End()
            Rere.Text({"Toggle Panel Keybind: Insert or RightControl"})
        end
        Rere.End()
    end
    Rere.End()
end)

_G.LarpcandyDisconnect = function()
    if rereDisconnect then pcall(rereDisconnect) end
    if _G.LarpcandyCycleConn then
        pcall(function() _G.LarpcandyCycleConn:Disconnect() end)
        _G.LarpcandyCycleConn = nil
    end
end

local interval, elapsed, sinceCycle = 1 / 30, 0, 0
_G.LarpcandyCycleConn = RunService.Heartbeat:Connect(function(deltaTime)
    elapsed += deltaTime
    sinceCycle += deltaTime
    if elapsed + 0.000001 < interval then return end
    local cycleDelta = sinceCycle
    sinceCycle = 0
    elapsed = math.max(0, elapsed - interval) % interval
    if Rere.Internal and Rere.Internal._cycle then
        pcall(Rere.Internal._cycle, cycleDelta)
    end
end)

pcall(Rere.ForceRefresh)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
        uiState.WindowOpen:set(not uiState.WindowOpen:get())
    end
end)

RunService.Heartbeat:Connect(function()
    if runtime.CapSpeed or runtime.GutsRunning then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed > 15.5 then
            hum.WalkSpeed = 15.5
        end
    end
end)

_G.Larpcandy = {
    StartFarm = function()
        uiState.AutoFarm:set(true)
        runtime.AutoFarm = true
        executeFarmCycle(false)
    end,
    StopFarm = function()
        uiState.AutoFarm:set(false)
        runtime.AutoFarm = false
        runtime.Running = false
    end,
    RunOnce = function()
        executeFarmCycle(true)
    end,
    TPNearest = teleportToNearestHouse,
    TPWonder = interactWithWonder,
    RunAllWonders = runAllWonders,
    StartGuts = runGutsAutoTrial,
    ToggleShop = function()
        local srv = getHalloweenService()
        if srv then srv:Toggle() end
    end,
    GetStatus = function()
        return {
            autoFarm = runtime.AutoFarm,
            farmStatus = runtime.Status,
            farmTarget = runtime.Target,
            visited = runtime.Visited,
            wondersStatus = runtime.WondersStatus,
            gutsStatus = runtime.GutsStatus
        }
    end,
    Close = function()
        if _G.LarpcandyDisconnect then
            pcall(_G.LarpcandyDisconnect)
            _G.LarpcandyDisconnect = nil
        end
        uiState.WindowOpen:set(false)
    end
}

_G.GakuranCandyHub = _G.Larpcandy
_G.GakuranLarpcandy = _G.Larpcandy
