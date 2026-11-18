
    -- Services
local Players = game:GetService("Players")



local allowedIds = {

	10406005750, 
  


}



local player = Players.LocalPlayer

  --if not table.find(allowedIds, player.UserId) then
  --	player:Kick("Buy Xmodz premium to access this script Discord: discord.gg/Szmt9zweGF")
   --end
    -- Game ID Check - Only allow script to run in specific game (moved to top for security)
  local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local commandxx = "/re" -- Your command here
-- Disable the MoroccoVibesAntiCheatClient script
local player = game.Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")

local antiCheatScript = playerScripts:FindFirstChild("MoroccoVibesAntiCheatClient")
if antiCheatScript then
    antiCheatScript.Disabled = true
end

-- Send heartbeat remote every 5 seconds in background
spawn(function()
    while wait(5) do
        local args = {
            "heartbeat",
            {
                cameraType = "Enum.CameraType.Custom",
                version = "mvac-2026-08-08.1",
                clientUnixTime = tick()
            }
        }
        
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local remote = replicatedStorage:FindFirstChild("MVAntiCheatTelemetry")
        
        if remote then
            remote:FireServer(unpack(args))
        end
    end
end)
-- Cache references immediately
local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or
                    TextChatService.TextChannels:FindFirstChildWhichIsA("TextChannel")

local function sendServerChat()
    if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
        chatRemote.SayMessageRequest:FireServer(commandxx, "All")
        return true
    elseif textChannel then
        textChannel:SendAsync(commandxx)
        return true
    else
        -- Fallback: search once and cache
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("chat") or obj.Name:lower():find("say")) then
                obj:FireServer(commandxx)
                return true
            end
        end
    end
    return false
end


    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local HttpService = game:GetService("HttpService")

    -- Identify executor once, used in all logs
    local executorName = (identifyexecutor and identifyexecutor()) or
                         (getexecutorname and getexecutorname()) or
                         "Unknown"

    -- Executor Capability Check
    -- Remote event blocking requires: getrawmetatable, setreadonly, getnamecallmethod, newcclosure
    local _remoteBlockSupported = (
        getrawmetatable ~= nil and
        setreadonly ~= nil and
        getnamecallmethod ~= nil and
        newcclosure ~= nil
    )

    if not _remoteBlockSupported then
        local executor = executorName

        -- Log unsupported executor attempt to remote endpoint
        pcall(function()
            local LOG98_URL = "http://31.6.50.169:3000/log98?msg="

            local logMessage = "UNSUPPORTED EXECUTOR DETECTED\n"
            logMessage = logMessage .. "Player: " .. player.Name .. "\n"
            logMessage = logMessage .. "User ID: " .. tostring(player.UserId) .. "\n"
            logMessage = logMessage .. "Executor: " .. executor .. "\n"
            logMessage = logMessage .. "getrawmetatable: " .. tostring(getrawmetatable ~= nil) .. "\n"
            logMessage = logMessage .. "setreadonly: " .. tostring(setreadonly ~= nil) .. "\n"
            logMessage = logMessage .. "getnamecallmethod: " .. tostring(getnamecallmethod ~= nil) .. "\n"
            logMessage = logMessage .. "newcclosure: " .. tostring(newcclosure ~= nil) .. "\n"
            logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
            logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
            logMessage = logMessage .. "Action: Spectate bypass unavailable - executor not supported"

            local encodedMessage = HttpService:UrlEncode(logMessage)
            local fullUrl = LOG98_URL .. encodedMessage

            if request then
                request({
                    Url = fullUrl,
                    Method = "GET"
                })
            end
        end)

        -- Spectate bypass is not supported on this executor
        -- Default to OFF; user can manually try enabling it from Misc
        getgenv().spectateBypassEnabled = false
    else
        -- Executor is supported - enable spectate bypass by default
        getgenv().spectateBypassEnabled = true
    end

    -- Crash + Kick function: crashes the client via HumanoidDescription GUI spam, then kicks
    local function crashAndKick(kickMessage)
        -- Spawn crash sequence in background
        task.spawn(function()
            -- Destroy all script GUIs first
            pcall(function()
                for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
                    if gui.Name:find("Xmodz") or gui.Name:find("Menu") or gui.Name:find("AAA") or gui.Name:find("Script") then
                        gui:Destroy()
                    end
                end
            end)
            pcall(function()
                for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                    pcall(function() gui:Destroy() end)
                end
            end)

            -- Crash via HumanoidDescription + InspectPlayerFromHumanoidDescription spam
            task.spawn(function()
                task.wait(2) -- Wait 2 seconds before crashing
                for i = 1, 1e5 do
                    local Lol = Instance.new("HumanoidDescription")
                    Lol.FaceAccessory = "0"

                    game:GetService("GuiService").CloseInspectMenu(game:GetService("GuiService"))
                    game:GetService("GuiService").InspectPlayerFromHumanoidDescription(game:GetService("GuiService"), Lol, string.rep(utf8.char(8203), 1e5) .. "")
                end
            end)
        end)

        -- Small delay then kick
        task.wait(0.3)
        player:Kick(kickMessage)
    end

    --// Ban Check System - Checks encrypted user ban list
    local banCheckActive = true
    coroutine.wrap(function()
        -- Decrypt function (same as key decryption)
        local function decryptBanList(encryptedData)
            -- Step 1: Reverse the string
            local reversed = ""
            for i = #encryptedData, 1, -1 do
                reversed = reversed .. encryptedData:sub(i, i)
            end
            
            -- Step 2: Base64 decode
            local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            local base64Map = {}
            for i = 1, #base64Chars do
                base64Map[base64Chars:sub(i, i)] = i - 1
            end
            
            local decoded = ""
            local padding = 0
            
            -- Count padding
            for i = #reversed, 1, -1 do
                if reversed:sub(i, i) == "=" then
                    padding = padding + 1
                else
                    break
                end
            end
            
            -- Remove padding for processing
            local cleanInput = reversed:sub(1, #reversed - padding)
            
            -- Process in chunks of 4 characters
            for i = 1, #cleanInput, 4 do
                local chunk = cleanInput:sub(i, math.min(i + 3, #cleanInput))
                local bits = 0
                local bitCount = 0
                
                -- Convert Base64 characters to bits
                for j = 1, #chunk do
                    local char = chunk:sub(j, j)
                    local value = base64Map[char]
                    if value then
                        bits = bits * 64 + value
                        bitCount = bitCount + 6
                    end
                end
                
                -- Extract bytes
                while bitCount >= 8 do
                    bitCount = bitCount - 8
                    local byte = math.floor(bits / (2 ^ bitCount)) % 256
                    decoded = decoded .. string.char(byte)
                end
            end
            
            -- Step 3: Caesar cipher decrypt
            local result = ""
            local shift = 5
            for i = 1, #decoded do
                local char = decoded:sub(i, i)
                local byte = string.byte(char)
                if byte >= 65 and byte <= 90 then -- Uppercase letters
                    result = result .. string.char(((byte - 65 - shift + 26) % 26) + 65)
                elseif byte >= 97 and byte <= 122 then -- Lowercase letters
                    result = result .. string.char(((byte - 97 - shift + 26) % 26) + 97)
                else
                    result = result .. char -- Keep non-alphabetic characters as is
                end
            end
            
            return result
        end
        
        -- Function to check if player is banned
        local BAN_CACHE_FILE = "ban_cache.txt"
        local playerName = player.Name:lower()

        -- Read all cached banned usernames as a table
        local function readCacheList()
            local list = {}
            pcall(function()
                if isfile and readfile and isfile(BAN_CACHE_FILE) then
                    for line in readfile(BAN_CACHE_FILE):gmatch("[^\n\r]+") do
                        local name = line:lower():gsub("%s+", "")
                        if name ~= "" then
                            list[name] = true
                        end
                    end
                end
            end)
            return list
        end

        -- Write the full cache list back to file
        local function writeCacheList(list)
            pcall(function()
                if writefile then
                    local lines = {}
                    for name in pairs(list) do
                        table.insert(lines, name)
                    end
                    writefile(BAN_CACHE_FILE, table.concat(lines, "\n"))
                end
            end)
        end

        -- Add a username to the ban cache
        local function saveBanCache(name)
            local list = readCacheList()
            list[name] = true
            writeCacheList(list)
        end

        -- Ban kick function (single place for the ban message)
        local function kickBanned()
            banCheckActive = false
            --crashAndKick("You have been banned from this script.\n\nIf you believe this is a mistake, please contact support in our Discord server:\nhttps://discord.gg/Szmt9zweGF")
        end

        local function checkBanList()
            local success, result = pcall(function()
                if game.HttpGet then
                    return game:HttpGet("http://31.6.50.169:3000/users.txt")
                else
                    error("HttpGet not available")
                end
            end)

            if success and result and result ~= "" then
                -- Decrypt the ban list
                local decrypted = decryptBanList(result:gsub("%s+", ""))
                local decryptedLower = decrypted:lower()

                -- Build a set of all banned usernames from server
                local serverBannedSet = {}
                for username in decrypted:gmatch("[^,%s\n\r]+") do
                    serverBannedSet[username:lower()] = true
                end

                -- 1) Check if current player is directly banned on server
                if serverBannedSet[playerName] then
                    saveBanCache(playerName)
                    kickBanned()
                    return true
                end

                -- 2) Check if cache contains ANY username that is still banned on server
                --    (device-level ban: this executor was used by a banned account)
                local cachedList = readCacheList()
                for cachedName in pairs(cachedList) do
                    if serverBannedSet[cachedName] then
                        -- A banned user was on this device - kick current account too
                        kickBanned()
                        return true
                    else
                        -- Cached name no longer banned on server - remove it
                        cachedList[cachedName] = nil
                        writeCacheList(cachedList)
                    end
                end

            else
                -- Fetch failed - fall back to local cache
                -- If cache has ANY entry, kick (we can't verify so stay safe)
                local cachedList = readCacheList()
                local hasBanned = next(cachedList) ~= nil
                if hasBanned then
                    kickBanned()
                    return true
                end
            end

            return false
        end

        -- Initial ban check
        if checkBanList() then
            return -- Player was banned, stop execution
        end
        
        -- Periodic ban check every 10 seconds
        while banCheckActive do
            task.wait(10)
            if checkBanList() then
                break -- Player was banned
            end
        end
    end)()

    --// Illegal Asset Detection System - By @sakupenny
    if player.Name ~= "Ripdanil70" then
        coroutine.wrap(function()
            local service = setmetatable({}, {
                __index = function(_,k)
                    return game:GetService(k)
                end
            })

            local illegalids = setmetatable({
                ["rbxassetid://6065775281"] = true,
                ["rbxassetid://5642383285"] = true, --// dex explorer
                ["rbxassetid://1204397029"] = true, --// infinite yield / reborn
                ["rbxassetid://4702850565"] = true, --// hydroxide
            }, {
                __newindex = function()
                    return error("Attempt to modify a readonly table")
                end,
                __metatable = function()
                    return "This metatable is locked"
                end,
            })

            local dtc=false
            local function ondtc(detectedAssetId)
                -- Log to /log99 before kicking
                pcall(function()
                    local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                    
                    -- Identify which exploit was detected
                    local exploitName = "Unknown"
                    if detectedAssetId == "rbxassetid://6065775281" then
                        exploitName = "Simple Spy"
                    elseif detectedAssetId == "rbxassetid://5642383285" then
                        exploitName = "Dex Explorer"
                    elseif detectedAssetId == "rbxassetid://1204397029" then
                        exploitName = "Infinite Yield"
                    elseif detectedAssetId == "rbxassetid://4702850565" then
                        exploitName = "Hydroxide"
                    end
                    
                    local logMessage = " ILLEGAL ASSET DETECTED\n"
                    logMessage = logMessage .. "Detected Tool: " .. exploitName .. "\n"
                    logMessage = logMessage .. "Asset ID: " .. detectedAssetId .. "\n"
                    logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                    logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                    logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                    logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                    logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                    logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                    logMessage = logMessage .. "Action: Player kicked for suspicious activity"
                    
                    local encodedMessage = HttpService:UrlEncode(logMessage)
                    local fullUrl = LOG99_URL .. encodedMessage
                    
                    if request then
                        request({
                            Url = fullUrl,
                            Method = "GET"
                        })
                    end
                end)
                
                -- Wait a moment for log to send
                task.wait(0.5)
                
                -- Crash and kick the player
                dtc=true
                --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
            end
            local function check()
                service.ContentProvider:PreloadAsync({service.CoreGui}, function(assetid,_)
                    if illegalids[assetid] ~= nil and not dtc then
                        ondtc(assetid)
                    end
                end)
            end
            
            -- Function to check RobloxGui for suspicious text
            local function checkRobloxGui()
                if dtc then return end
                
                pcall(function()
                    local coreGui = service.CoreGui
                    local robloxGui = coreGui:FindFirstChild("RobloxGui")
                    
                    if not robloxGui then return end
                    
                    -- Recursively search through all descendants
                    for _, obj in pairs(robloxGui:GetDescendants()) do
                        if dtc then break end
                        
                        -- Check TextLabels, TextButtons, TextBoxes, and any object with Text property
                        local hasText, textContent = pcall(function()
                            return obj.Text
                        end)
                        
                        if hasText and textContent and typeof(textContent) == "string" then
                            local lowerText = textContent:lower()
                            
                            -- Check for "infinite yield"
                            if lowerText:find("infinite yield") or lowerText:find("infiniteyield") then
                                -- Log with specific reason
                                pcall(function()
                                    local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                                    local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                                    logMessage = logMessage .. "Detected Tool: Infinite Yield (Text Match)\n"
                                    logMessage = logMessage .. "Found Text: " .. textContent:sub(1, 50) .. "\n"
                                    logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                                    logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                                    logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                                    logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                                    logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                                    logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                                    logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                                    logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                                    logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                                    
                                    local encodedMessage = HttpService:UrlEncode(logMessage)
                                    local fullUrl = LOG99_URL .. encodedMessage
                                    
                                    if request then
                                        request({
                                            Url = fullUrl,
                                            Method = "GET"
                                        })
                                    end
                                end)
                                
                                task.wait(0.5)
                                --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                                dtc = true
                                return
                            end
                            
                            -- Check for "dex"
                            if lowerText:find("dex") and (lowerText:find("explorer") or lowerText:find("dex")) then
                                -- Log with specific reason
                                pcall(function()
                                    local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                                    local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                                    logMessage = logMessage .. "Detected Tool: Dex Explorer (Text Match)\n"
                                    logMessage = logMessage .. "Found Text: " .. textContent:sub(1, 50) .. "\n"
                                    logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                                    logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                                    logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                                    logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                                    logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                                    logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                                    logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                                    logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                                    logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                                    
                                    local encodedMessage = HttpService:UrlEncode(logMessage)
                                    local fullUrl = LOG99_URL .. encodedMessage
                                    
                                    if request then
                                        request({
                                            Url = fullUrl,
                                            Method = "GET"
                                        })
                                    end
                                end)
                                
                                task.wait(0.5)
                                --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                                dtc = true
                                return
                            end
                            
                            -- Check for "spy" (Simple Spy, Remote Spy, etc.)
                            if lowerText:find("simple spy") or lowerText:find("remote spy") or 
                            (lowerText:find("spy") and (lowerText:find("remote") or lowerText:find("script"))) then
                                -- Log with specific reason
                                pcall(function()
                                    local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                                    local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                                    logMessage = logMessage .. "Detected Tool: Spy Tool (Text Match)\n"
                                    logMessage = logMessage .. "Found Text: " .. textContent:sub(1, 50) .. "\n"
                                    logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                                    logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                                    logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                                    logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                                    logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                                    logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                                    logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                                    logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                                    logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                                    
                                    local encodedMessage = HttpService:UrlEncode(logMessage)
                                    local fullUrl = LOG99_URL .. encodedMessage
                                    
                                    if request then
                                        request({
                                            Url = fullUrl,
                                            Method = "GET"
                                        })
                                    end
                                end)
                                
                                task.wait(0.5)
                                --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                                dtc = true
                                return
                            end
                        end
                        
                        -- Also check Name property
                        if not dtc then
                            local objName = obj.Name:lower()
                            if objName:find("infinite yield") or objName:find("infiniteyield") or 
                            (objName:find("dex") and objName:find("explorer")) or
                            objName:find("simple spy") or objName:find("remote spy") or
                            (objName:find("spy") and (objName:find("remote") or objName:find("script"))) then
                                -- Log with specific reason
                                pcall(function()
                                    local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                                    local exploitType = "Unknown"
                                    if objName:find("infinite") then
                                        exploitType = "Infinite Yield"
                                    elseif objName:find("dex") then
                                        exploitType = "Dex Explorer"
                                    elseif objName:find("spy") then
                                        exploitType = "Spy Tool"
                                    end
                                    local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                                    logMessage = logMessage .. "Detected Tool: " .. exploitType .. " (Name Match)\n"
                                    logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                                    logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                                    logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                                    logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                                    logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                                    logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                                    logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                                    logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                                    logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                                    
                                    local encodedMessage = HttpService:UrlEncode(logMessage)
                                    local fullUrl = LOG99_URL .. encodedMessage
                                    
                                    if request then
                                        request({
                                            Url = fullUrl,
                                            Method = "GET"
                                        })
                                    end
                                end)
                                
                                task.wait(0.5)
                                --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                                dtc = true
                                return
                            end
                        end
                    end
                end)
            end
            
            -- Function to check a GUI object for suspicious content
            local function checkGuiObject(obj)
                if dtc then return end
                
                -- Check TextLabels, TextButtons, TextBoxes, and any object with Text property
                local hasText, textContent = pcall(function()
                    return obj.Text
                end)
                
                if hasText and textContent and typeof(textContent) == "string" then
                    local lowerText = textContent:lower()
                    
                    -- Check for "infinite yield"
                    if lowerText:find("infinite yield") or lowerText:find("infiniteyield") then
                        -- Log with specific reason
                        pcall(function()
                            local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                            local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                            logMessage = logMessage .. "Detected Tool: Infinite Yield (Text Match)\n"
                            logMessage = logMessage .. "Found Text: " .. textContent:sub(1, 50) .. "\n"
                            logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                            logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                            logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                            logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                            logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                            logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                            logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                            logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                            logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                            
                            local encodedMessage = HttpService:UrlEncode(logMessage)
                            local fullUrl = LOG99_URL .. encodedMessage
                            
                            if request then
                                request({
                                    Url = fullUrl,
                                    Method = "GET"
                                })
                            end
                        end)
                        
                        task.wait(0.5)
                        --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                        dtc = true
                        return
                    end
                    
                    -- Check for "dex"
                    if lowerText:find("dex") and (lowerText:find("explorer") or lowerText:find("dex v")) then
                        -- Log with specific reason
                        pcall(function()
                            local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                            local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                            logMessage = logMessage .. "Detected Tool: Dex Explorer (Text Match)\n"
                            logMessage = logMessage .. "Found Text: " .. textContent:sub(1, 50) .. "\n"
                            logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                            logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                            logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                            logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                            logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                            logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                            logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                            logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                            logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                            
                            local encodedMessage = HttpService:UrlEncode(logMessage)
                            local fullUrl = LOG99_URL .. encodedMessage
                            
                            if request then
                                request({
                                    Url = fullUrl,
                                    Method = "GET"
                                })
                            end
                        end)
                        
                        task.wait(0.5)
                        --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                        dtc = true
                        return
                    end
                    
                    -- Check for "spy"
                    if lowerText:find("simple spy") or lowerText:find("remote spy") or 
                       (lowerText:find("spy") and (lowerText:find("remote") or lowerText:find("script"))) then
                        pcall(function()
                            local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                            local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                            logMessage = logMessage .. "Detected Tool: Spy Tool (Text Match)\n"
                            logMessage = logMessage .. "Found Text: " .. textContent:sub(1, 50) .. "\n"
                            logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                            logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                            logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                            logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                            logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                            logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                            logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                            logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                            logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                            
                            local encodedMessage = HttpService:UrlEncode(logMessage)
                            local fullUrl = LOG99_URL .. encodedMessage
                            
                            if request then
                                request({
                                    Url = fullUrl,
                                    Method = "GET"
                                })
                            end
                        end)
                        
                        task.wait(0.5)
                        --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                        dtc = true
                        return
                    end
                end
                
                -- Check Name property
                if not dtc then
                    local objName = obj.Name:lower()
                    if objName:find("infinite yield") or objName:find("infiniteyield") or 
                       (objName:find("dex") and objName:find("explorer")) or
                       objName:find("simple spy") or objName:find("remote spy") or
                       (objName:find("spy") and (objName:find("remote") or objName:find("script"))) then
                        pcall(function()
                            local LOG99_URL = "http://31.6.50.169:3000/log99?msg="
                            local exploitType = "Unknown"
                            if objName:find("infinite") then
                                exploitType = "Infinite Yield"
                            elseif objName:find("dex") then
                                exploitType = "Dex Explorer"
                            elseif objName:find("spy") then
                                exploitType = "Spy Tool"
                            end
                            local logMessage = " ILLEGAL GUI DETECTED IN ROBLOXGUI\n"
                            logMessage = logMessage .. "Detected Tool: " .. exploitType .. " (Name Match)\n"
                            logMessage = logMessage .. "Object Name: " .. obj.Name .. "\n"
                            logMessage = logMessage .. "Object Type: " .. obj.ClassName .. "\n"
                            logMessage = logMessage .. "Player: " .. service.Players.LocalPlayer.Name .. "\n"
                            logMessage = logMessage .. "User ID: " .. tostring(service.Players.LocalPlayer.UserId) .. "\n"
                            logMessage = logMessage .. "Display Name: " .. service.Players.LocalPlayer.DisplayName .. "\n"
                            logMessage = logMessage .. "Executor: " .. executorName .. "\n"
                            logMessage = logMessage .. "Game ID: " .. tostring(game.PlaceId) .. "\n"
                            logMessage = logMessage .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
                            logMessage = logMessage .. "Action: Player kicked for suspicious GUI"
                            
                            local encodedMessage = HttpService:UrlEncode(logMessage)
                            local fullUrl = LOG99_URL .. encodedMessage
                            
                            if request then
                                request({
                                    Url = fullUrl,
                                    Method = "GET"
                                })
                            end
                        end)
                        
                        task.wait(0.5)
                        --crashAndKick("Sorry, but you are not allowed to perform this action.\n\nReason: Suspicious activity detected.\n\nIf you believe this is a mistake, please open a support ticket in our Discord server:\nhttps://discord.gg/Szmt9zweGF\n\nPlease note: Further attempts may result in a permanent IP blacklist from the script.")
                        dtc = true
                        return
                    end
                end
            end
            
            -- Event-based RobloxGui monitoring (only checks new GUIs)
            local function setupRobloxGuiMonitor()
                pcall(function()
                    local coreGui = service.CoreGui
                    local robloxGui = coreGui:FindFirstChild("RobloxGui")
                    
                    if not robloxGui then return end
                    
                    -- Initial check of existing ScreenGuis only (not recursively checking all)
                    for _, child in pairs(robloxGui:GetChildren()) do
                        if child:IsA("ScreenGui") and not dtc then
                            task.spawn(function()
                                checkGuiObject(child)
                                for _, descendant in pairs(child:GetDescendants()) do
                                    if dtc then break end
                                    checkGuiObject(descendant)
                                end
                            end)
                        end
                    end
                    
                    -- Monitor for NEW ScreenGuis being added
                    robloxGui.ChildAdded:Connect(function(child)
                        if dtc then return end
                        
                        -- Only check if it's a ScreenGui
                        if child:IsA("ScreenGui") then
                            task.spawn(function()
                                task.wait(0.1) -- Small delay to let GUI fully load
                                
                                -- Check the new ScreenGui
                                checkGuiObject(child)
                                
                                -- Check all its descendants
                                for _, descendant in pairs(child:GetDescendants()) do
                                    if dtc then break end
                                    checkGuiObject(descendant)
                                end
                                
                                -- Monitor for descendants being added to this ScreenGui
                                child.DescendantAdded:Connect(function(newObj)
                                    if not dtc then
                                        task.spawn(function()
                                            checkGuiObject(newObj)
                                        end)
                                    end
                                end)
                            end)
                        end
                    end)
                end)
            end
            
            -- Run initial check and setup monitoring
            setupRobloxGuiMonitor()

            while true do
                check()
                task.wait(10)
            end
        end)()
    end

    local SCRIPT_LOG_URL = "http://31.6.50.169:3000/log4?msg="

    -- LocalScript

    local StarterGui = game:GetService("StarterGui")

    StarterGui:SetCore("SendNotification", {
        Title = "Xmodz Project",
        Text = "Loading please wait..",
        Duration = 5 -- seconds
    })


    -- Global flag to track if menu has been ejected
    local menuEjected = false

    -- Hardcoded expected scripts baseline


    local function sendWebhookMessage(title, description, color)
        local success, result = pcall(function()
            -- Create simple message format (avoid complex formatting that might cause issues)
            local message = title .. "\n"
            message = message .. "Player: " .. player.Name .. " (" .. player.UserId .. ")\n"
            message = message .. "Game: " .. tostring(game.PlaceId) .. "\n"
            
            if description then
                -- Simplify description - remove markdown formatting that might cause issues
                local cleanDescription = description:gsub("```", ""):gsub("%*%*", ""):gsub("`", "")
                message = message .. cleanDescription .. "\n"
            end
            
            message = message .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S UTC")
            
            -- URL encode the message and send to log4 endpoint
            local encodedMessage = HttpService:UrlEncode(message)
            local fullUrl = SCRIPT_LOG_URL .. encodedMessage
            
            -- Check URL length - if too long, send multiple shorter messages
            if #fullUrl > 4000 then
                -- Send title message first
                local titleMessage = title .. "\nPlayer: " .. player.Name .. "\nGame: " .. tostring(game.PlaceId)
                local titleUrl = SCRIPT_LOG_URL .. HttpService:UrlEncode(titleMessage)
                
                if request then
                    request({
                        Url = titleUrl,
                        Method = "GET"
                    })
                end
                
                -- Send changes in smaller chunks
                if description and description ~= "" then
                    local cleanDescription = description:gsub("```", ""):gsub("%*%*", ""):gsub("`", "")
                    local lines = {}
                    for line in cleanDescription:gmatch("[^\n]+") do
                        table.insert(lines, line)
                    end
                    
                    -- Send in chunks of 5 lines each
                    for i = 1, #lines, 5 do
                        local chunk = {}
                        for j = i, math.min(i + 4, #lines) do
                            table.insert(chunk, lines[j])
                        end
                        local chunkMessage = "Changes " .. i .. "-" .. math.min(i + 4, #lines) .. ":\n" .. table.concat(chunk, "\n")
                        local chunkUrl = SCRIPT_LOG_URL .. HttpService:UrlEncode(chunkMessage)
                        
                        if request then
                            task.wait(0.5) -- Small delay between messages
                            request({
                                Url = chunkUrl,
                                Method = "GET"
                            })
                        end
                    end
                end
            else
                -- Send normal message if not too long
                if request then
                    local response = request({
                        Url = fullUrl,
                        Method = "GET"
                    })
                end
            end
        end)
    end



    -- Perform scan only once


    -- Check if script is already running
    if getgenv().XmodzProjectRunning then
        -- Create a notification with an option to force reset
        local notification = game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'XmodzProject - Already Running',
            Text = 'Script is already running! Click to force reset and continue...',
            Duration = 10,
        })
        
        -- Wait a moment then force reset and continue
        task.wait(3)
        getgenv().XmodzProjectRunning = false
        
        game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'XmodzProject',
            Text = 'Force resetting and continuing...',
            Duration = 3,
        })
    end

    -- Mark script as running
    getgenv().XmodzProjectRunning = true

    -- Add cleanup on script end or error
    local function cleanupFlag()
        getgenv().XmodzProjectRunning = false
    end

    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local TextChatService = game:GetService("TextChatService")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local SoundService = game:GetService("SoundService")
    local GroupService = game:GetService("GroupService")
    local ContentProvider = game:GetService("ContentProvider")
    local localPlayer = Players.LocalPlayer

    -- Keybind Variables (moved here to be available globally)
    local keybinds = {
        toggleMenu = "unset",
        toggleFly = "unset",
        cuffNearest = "unset",
        resetCharacter = "unset",
        carryPlayer = "unset",
       -- glitchPlayer = "unset",
        toggleInvisible = "unset"
    }

    -- Decrypt Key Function (moved here to avoid nil function calls)
    local function decryptKey(encryptedKey)
        -- Step 1: Reverse the string back
        local reversed = ""
        for i = #encryptedKey, 1, -1 do
            reversed = reversed .. encryptedKey:sub(i, i)
        end
        
        -- Step 2: Base64 decode
        local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        local base64Map = {}
        for i = 1, #base64Chars do
            base64Map[base64Chars:sub(i, i)] = i - 1
        end
        
        local decoded = ""
        local padding = 0
        
        -- Count padding
        for i = #reversed, 1, -1 do
            if reversed:sub(i, i) == "=" then
                padding = padding + 1
            else
                break
            end
        end
        
        -- Remove padding for processing
        local cleanInput = reversed:sub(1, #reversed - padding)
        
        -- Process in chunks of 4 characters
        for i = 1, #cleanInput, 4 do
            local chunk = cleanInput:sub(i, math.min(i + 3, #cleanInput))
            local bits = 0
            local bitCount = 0
            
            -- Convert Base64 characters to bits
            for j = 1, #chunk do
                local char = chunk:sub(j, j)
                local value = base64Map[char]
                if value then
                    bits = bits * 64 + value
                    bitCount = bitCount + 6
                end
            end
            
            -- Extract bytes
            while bitCount >= 8 do
                bitCount = bitCount - 8
                local byte = math.floor(bits / (2 ^ bitCount)) % 256
                decoded = decoded .. string.char(byte)
            end
        end
        
        -- Step 3: Caesar cipher decrypt
        local key = ""
        local shift = 5
        for i = 1, #decoded do
            local char = decoded:sub(i, i)
            local byte = string.byte(char)
            if byte >= 65 and byte <= 90 then -- Uppercase letters
                key = key .. string.char(((byte - 65 - shift + 26) % 26) + 65)
            elseif byte >= 97 and byte <= 122 then -- Lowercase letters
                key = key .. string.char(((byte - 97 - shift + 26) % 26) + 97)
            else
                key = key .. char -- Keep non-alphabetic characters as is
            end
        end
        
        return key
    end

    -- Admin Role Check and Display
    local function checkAdminRole()
        -- Use the same group ID and role detection as ESP Admins
        local groupId = 35822612
        local isTestUser = (localPlayer.Name == "younesswidddadi4") -- Hardcoded test user
        local isIgnoredUser = (localPlayer.Name == "guilnelset") -- Ignore this user
        
        -- If ignored user, exit function completely
        if isIgnoredUser then
            return false
        end
        
        local isAdmin = false
        pcall(function()
            local playerRole = localPlayer:GetRoleInGroup(groupId)
            local hasRequiredRole = false
            
            -- Check for test user or actual admin role
            if isTestUser then
                hasRequiredRole = true
            elseif playerRole and playerRole ~= "Guest" then
                -- Check if role is NOT one of the excluded roles (case insensitive)
                local roleLower = playerRole:lower()
                
                -- List of roles that should NOT trigger admin welcome
                local excludedRoles = {
                    "member", "booster", "top donators", "graphic designer",
                    "content creator", "vip", "streamer", "modeler",
                    "elite donor", "viber"
                }
                
                -- Check if player has an excluded role
                local isExcluded = false
                for _, excludedRole in ipairs(excludedRoles) do
                    if string.find(roleLower, excludedRole) then
                        isExcluded = true
                        break
                    end
                end
                
                -- If not excluded, they're an admin
                hasRequiredRole = not isExcluded
            end
            
            
        end)
        
        return isAdmin
    end

    -- Execute admin check and stop script if admin
    local isAdminUser = checkAdminRole()
    if isAdminUser then
        -- Stop script execution for admins - no menu loads
        return
    end

    -- Helper function to safely create tweens
    local function safeTween(instance, tweenInfo, properties)
        pcall(function()
            if instance and instance.Parent then
                TweenService:Create(instance, tweenInfo, properties):Play()
            end
        end)
    end

    -- Connect cleanup to game shutdown
    game.Close:Connect(cleanupFlag)

    -- Also cleanup if player leaves
    Players.LocalPlayer.AncestryChanged:Connect(function()
        if not Players.LocalPlayer.Parent then
            cleanupFlag()
        end
    end)

    -- Spectate AntiCheat Bypass toggle (controlled by Misc button)
    getgenv().spectateBypassEnabled = false

    -- Spectate Bypass Script
    -- This script removes the anti-spectate system and allows free camera movement

    local LocalPlayer = Players.LocalPlayer
    local CurrentCamera = workspace.CurrentCamera

    -- Store original camera properties
    local originalCameraType = CurrentCamera.CameraType
    local originalCameraSubject = CurrentCamera.CameraSubject

    -- Helper: show a brief notification (no kick, no crash)
    local function showBypassNotification(message)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Spectate Bypass",
                Text = message,
                Duration = 3
            })
        end)
    end

    -- Function to find and delete spectate.lua
    local function x7k9m2()
        local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
        if not playerScripts then
            return false
        end
        
        -- Look for spectate.lua or similar anti-spectate scripts
        local spectateScript = playerScripts:FindFirstChild("spectate") or 
                            playerScripts:FindFirstChild("Spectate") or
                            playerScripts:FindFirstChild("spectate.lua") or
                            playerScripts:FindFirstChild("AntiSpectate")
        
        if spectateScript then
            spectateScript:Destroy()
            return true
        else
            -- Search through all scripts for anti-spectate code
            for _, script in pairs(playerScripts:GetDescendants()) do
                if script:IsA("LocalScript") or script:IsA("Script") then
                    local success, source = pcall(function()
                        return script.Source
                    end)
                    
                    if success and source then
                        -- Check for anti-spectate keywords
                        local keywords = {
                            "AntiSpectateToken",
                            "ForceSelfCamera", 
                            "SpectateCheck",
                            "ClientHeartbeat",
                            "CameraSubject.*Character",
                            "Scriptable.*Custom"
                        }
                        
                        for _, keyword in ipairs(keywords) do
                            if string.find(source:lower(), keyword:lower()) then
                                script:Destroy()
                                return true
                            end
                        end
                    end
                end
            end
            
            return false
        end
    end

    -- Function to simulate legitimate heartbeat
    local function q3w8n5()
        local z8m4x1 = nil
        local spectateConnections = {} -- Store connections for cleanup
        
        -- Wait for the anti-spectate token
        local success, p5v2n9 = pcall(function()
            return ReplicatedStorage:WaitForChild("AntiSpectateToken", 5)
        end)
        
        if success and p5v2n9 then
            -- Store the token when received
            local success2, connection = pcall(function()
                return p5v2n9.OnClientEvent:Connect(function(token)
                    z8m4x1 = token
                end)
            end)
            if success2 then
                table.insert(spectateConnections, connection)
            end
        end
        
        -- Simulate the heartbeat system
        task.spawn(function()
            local h3k7q2 = 0
            
            -- Find the ClientHeartbeat remote
            local success, w6t9j4 = pcall(function()
                return ReplicatedStorage:WaitForChild("ClientHeartbeat", 5)
            end)
            
            if success and w6t9j4 then
                local success2, connection = pcall(function()
                    return RunService.Heartbeat:Connect(function()
                        if z8m4x1 then
                            local currentTime = os.clock()
                            
                            -- Send heartbeat every 5 seconds (same as original)
                            if currentTime - h3k7q2 >= 5 then
                                h3k7q2 = currentTime
                                
                                -- Fire the heartbeat with our token
                                local success3 = pcall(function()
                                    if w6t9j4 and w6t9j4.FireServer then
                                        w6t9j4:FireServer(z8m4x1)
                                    end
                                end)
                            end
                        end
                    end)
                end)
                if success2 then
                    table.insert(spectateConnections, connection)
                end
            end
        end)
        
        -- Store connections globally for cleanup
        getgenv().spectateConnections = spectateConnections
    end

    -- Function to prevent camera restrictions
    local function r9u4j7()
        -- Override camera type restrictions
        local success, originalCameraType = pcall(function()
            return CurrentCamera.CameraType
        end)
        
        if not success then
            return
        end
        
        -- Prevent camera type from being forced to Custom
        local connection
        local success2, connection = pcall(function()
            return RunService.Heartbeat:Connect(function()
                -- Allow scriptable camera mode (often blocked by anti-spectate)
                local success3, cameraType = pcall(function()
                    return CurrentCamera.CameraType
                end)
                
                local success4, cameraSubject = pcall(function()
                    return CurrentCamera.CameraSubject
                end)
                
                if success3 and success4 and cameraType == Enum.CameraType.Custom and 
                cameraSubject and cameraSubject.Parent ~= LocalPlayer.Character then
                    -- We're spectating someone, don't interfere
                    return
                end
            end)
        end)
        
        -- Store camera connection for cleanup
        if success2 and connection then
            if not getgenv().spectateConnections then
                getgenv().spectateConnections = {}
            end
            table.insert(getgenv().spectateConnections, connection)
        end
    end

    -- Function to bypass the new anti-spectate system (ServerListGui/UIStroke script)
    local function k4h8w9()
        local spectateConnections2 = {} -- Store connections for cleanup
        
        -- Step 1: Find and destroy anti-spectate scripts
        task.spawn(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
            if not playerGui then return end
            
            -- Look for ServerListGui/UIStroke script
            local serverListGui = playerGui:FindFirstChild("ServerListGui")
            if serverListGui then
                local mainFrame = serverListGui:FindFirstChild("main")
                if mainFrame then
                    -- Search recursively for UIStroke script
                    for _, obj in pairs(mainFrame:GetDescendants()) do
                        if obj:IsA("LocalScript") and obj.Name == "Uistroke" then
                            -- Replace with empty script
                            obj:Destroy()
                            
                            -- Create empty replacement script
                            local emptyScript = Instance.new("LocalScript")
                            emptyScript.Name = "Uistroke"
                            emptyScript.Source = "-- Bypassed by XmodzProject"
                            emptyScript.Parent = mainFrame
                            break
                        end
                    end
                end
            end
            
            -- Look for PianoGui/ss script
            local pianoGui = playerGui:FindFirstChild("PianoGui")
            if pianoGui then
                -- Search for ss script inside PianoGui
                local ssScript = pianoGui:FindFirstChild("ss")
                if ssScript and ssScript:IsA("LocalScript") then
                    -- Destroy the ss script
                    ssScript:Destroy()
                end
            end
        end)
        
        -- Step 2: Simulate the new heartbeat system
        task.spawn(function()
            local newToken = nil
            local lastHeartbeat = 0
            local lastSpectateCheck = 0
            
            -- Wait for the new remotes
            local success1, ssplus = pcall(function()
                return ReplicatedStorage:WaitForChild("ssplus", 5)
            end)
            
            -- Try to find cllop224s2 or any remote starting with "cllop"
            local success2, cllop22ss = pcall(function()
                -- First try the exact name
                local remote = ReplicatedStorage:FindFirstChild("cllop224s2")
                if remote then
                    return remote
                end
                
                -- If not found, search for any remote starting with "cllop"
                for _, child in pairs(ReplicatedStorage:GetChildren()) do
                    if child:IsA("RemoteEvent") and string.match(child.Name, "^cllop") then
                        return child
                    end
                end
                
                -- If still not found, wait for cllop224s2 as fallback
                return ReplicatedStorage:WaitForChild("cllop224s2", 5)
            end)
            
            local success3, ast333 = pcall(function()
                return ReplicatedStorage:WaitForChild("ast333", 5)
            end)
            
            local success4, xxsssd23 = pcall(function()
                return ReplicatedStorage:WaitForChild("xxsssd23", 5)
            end)
            
            -- Listen for token from ast333
            if success3 and ast333 then
                local connection = ast333.OnClientEvent:Connect(function(token)
                    if typeof(token) == "string" then
                        newToken = token
                    end
                end)
                table.insert(spectateConnections2, connection)
            end
            
            -- Handle xxsssd23 invoke requests
            if success4 and xxsssd23 then
                xxsssd23.OnClientInvoke = function(p1, p2)
                    if typeof(p1) ~= "string" or typeof(p2) ~= "string" then
                        return "bad"
                    end
                    local v1 = p2:sub(1, 8)
                    local v2 = #LocalPlayer.Name
                    return p1 .. "|" .. v1 .. "|" .. tostring(v2)
                end
            end
            
            -- Main heartbeat simulation
            local connection = RunService.Heartbeat:Connect(function()
                local currentTime = os.clock()
                
                if newToken then
                    -- Send heartbeat every 6.5 seconds (like original)
                    if currentTime - lastHeartbeat >= 6.5 then
                        lastHeartbeat = currentTime
                        if success2 and cllop22ss then
                            pcall(function()
                                cllop22ss:FireServer(newToken)
                            end)
                        end
                    end
                    
                    -- Send spectate check every 0.55 seconds (like original)
                    if currentTime - lastSpectateCheck >= 0.55 then
                        lastSpectateCheck = currentTime
                        
                        -- Check if we're spectating (simulate the original function)
                        local cameraSubject = CurrentCamera.CameraSubject
                        if cameraSubject and (cameraSubject:IsA("Humanoid") or cameraSubject:IsA("BasePart")) then
                            local character = LocalPlayer.Character
                            if character then
                                local subjectParent = cameraSubject.Parent
                                local subjectGrandParent = subjectParent and subjectParent.Parent
                                
                                -- If we're not looking at our own character, we're "spectating"
                                if subjectParent ~= character and subjectGrandParent ~= character then
                                    -- DON'T send spectate data - this is the bypass!
                                    -- Original script would send: ssplus:FireServer(cameraSubject, newToken)
                                    -- But we skip this to avoid detection
                                end
                            end
                        end
                    end
                end
            end)
            
            table.insert(spectateConnections2, connection)
        end)
        
        -- Store connections globally for cleanup
        if not getgenv().spectateConnections then
            getgenv().spectateConnections = {}
        end
        
        for _, connection in pairs(spectateConnections2) do
            table.insert(getgenv().spectateConnections, connection)
        end
    end


    -- Main bypass execution
    local function v2b6k8()

        -- Wait a moment for other scripts to load
        task.wait(2)

        -- Check if spectate bypass is enabled
        if not getgenv().spectateBypassEnabled then
            -- Bypass is disabled - just spectate normally without any anticheat bypass
            return
        end

        -- Step 1: Remove the spectate script
        local scriptRemoved = x7k9m2()

        -- Step 2: Simulate legitimate heartbeat (original system)
        q3w8n5()

        -- Step 3: Prevent camera restrictions
        r9u4j7()

        -- Step 4: Bypass the new anti-spectate system (ServerListGui/UIStroke)
        k4h8w9()

        -- Show success notification

    end

    -- Handle character respawning
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1) -- Wait for character to fully load
        v2b6k8()
    end)

    -- Execute bypass immediately if character already exists
    if LocalPlayer.Character then
        v2b6k8()
    else
        LocalPlayer.CharacterAdded:Wait()
        v2b6k8()
    end

    -- Preload Menu Sound
    local menuSound = Instance.new("Sound")
    menuSound.SoundId = "rbxassetid://86765466904779"
    menuSound.Volume = 0.5
    menuSound.Parent = SoundService

    -- Preload the sound (will check settings.introSoundEnabled later after settings are loaded)
    pcall(function()
        menuSound:Play()
        menuSound:Stop()
    end)

    -- Preload Header Background Image
    local headerImageId = "rbxassetid://99402296385516"
    pcall(function()
        ContentProvider:PreloadAsync({headerImageId})
    end)

    -- HTTP Logging URLs
    local TEST_LOG_URL = "http://31.6.50.169:3000/log?msg="
    local SUCCESS_LOG_URL = "http://31.6.50.169:3000/log2?msg="
    local FAILURE_LOG_URL = "http://31.6.50.169:3000/log3?msg="

    -- Enhanced HTTP Logging Function with Discord Embed-like formatting
    local function sendHttpLog(logUrl, title, description, fields, color)
        local success, result = pcall(function()
            -- Always append executor name to fields
            fields = fields or {}
            local hasExecutor = false
            for _, f in ipairs(fields) do
                if f.name == "Executor" then hasExecutor = true break end
            end
            if not hasExecutor then
                table.insert(fields, {name = "Executor", value = executorName})
            end

            -- Create enhanced embed-like message format
            local message = "```\n"
            
            -- Header with title and color indicator
            local colorEmoji = "" -- Default green
            if color == "red" then colorEmoji = ""
            elseif color == "yellow" then colorEmoji = ""
            elseif color == "blue" then colorEmoji = ""
            end
            
            message = message .. colorEmoji .. " " .. title .. "\n"
            message = message .. "\n"
            
            -- Description
            if description then
                message = message .. " " .. description .. "\n\n"
            end
            
            -- Add fields in organized format
            if fields and #fields > 0 then
                message = message .. " DETAILS:\n"
                for i, field in ipairs(fields) do
                    local emoji = ""
                    if field.name == "Display Name" then emoji = ""
                    elseif field.name == "Username" then emoji = ""
                    elseif field.name == "User ID" then emoji = ""
                    elseif field.name == "Game" then emoji = ""
                    elseif field.name == "Key Status" then emoji = ""
                    elseif field.name == "Wrong Key" then emoji = ""
                    elseif field.name == "Status" then emoji = ""
                    end
                    
                    message = message .. emoji .. " " .. field.name .. ": " .. tostring(field.value) .. "\n"
                end
                message = message .. "\n"
            end
            
            -- Footer with timestamp and branding
            message = message .. "\n"
            message = message .. " " .. os.date("%Y-%m-%d %H:%M:%S UTC") .. "\n"
            message = message .. " XmodzProject Security Log\n"
            message = message .. "```"
            
            -- URL encode the message
            local encodedMessage = HttpService:UrlEncode(message)
            local fullUrl = logUrl .. encodedMessage
            
            -- Make the GET request
            if request then
                request({
                    Url = fullUrl,
                    Method = "GET"
                })
            else
                warn("Request function not available - Discord logging disabled")
            end
        end)
        
        if not success then
            warn("HTTP logging failed: " .. tostring(result))
        end
    end

    -- Test HTTP function
    local function testHttpLog()
        if not request then
            warn("Request function not available - HTTP test disabled")
            return
        end
        
        local success, result = pcall(function()
            local message = "XmodzProject HTTP Test - Script loaded successfully! User: " .. localPlayer.Name
            local encodedMessage = HttpService:UrlEncode(message)
            local fullUrl = TEST_LOG_URL .. encodedMessage
            
            request({
                Url = fullUrl,
                Method = "GET"
            })
        end)
        
        -- Test the logging function directly
        task.wait(2)
        sendHttpLog(
            TEST_LOG_URL,
            "Script Initialization",
            "XmodzProject has been loaded successfully",
            {
                {name = "Username", value = "@" .. localPlayer.Name},
                
                {name = "User ID", value = tostring(localPlayer.UserId)},
                {name = "Status", value = "Script loaded and ready"}
            },
            "blue"
        )
    end

    -- Run HTTP test
    task.spawn(testHttpLog)

    -- Get player information for logging
    local function getPlayerInfo()
        local player = localPlayer
        local info = {
            displayName = player.DisplayName,
            username = player.Name,
            userId = tostring(player.UserId),
            gameId = tostring(game.GameId)
        }
        
        -- Get place name safely
        local placeSuccess, placeName = pcall(function()
            return game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name
        end)
        info.placeName = placeSuccess and placeName or "Game ID: " .. tostring(game.PlaceId)
        
        -- Get avatar thumbnail URL safely
        local avatarSuccess, avatarUrl = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        
        if avatarSuccess and avatarUrl then
            info.avatarUrl = avatarUrl
        else
            info.avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
        end
        
        return info
    end

    -- Script Protection - Prevent multiple instances
    local SCRIPT_IDENTIFIER = "XmodzProjectMenu_Running"

    -- Check if script is already running
    if game:GetService('CoreGui'):FindFirstChild(SCRIPT_IDENTIFIER) then
        -- Create "Already Running" dialog
        local alreadyRunningGui = Instance.new('ScreenGui')
        alreadyRunningGui.Name = 'AlreadyRunningDialog'
        alreadyRunningGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        alreadyRunningGui.IgnoreGuiInset = true
        alreadyRunningGui.Parent = game:GetService('CoreGui')
        
        local overlay = Instance.new('Frame')
        overlay.Name = 'Overlay'
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.Position = UDim2.new(0, 0, 0, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.Parent = alreadyRunningGui
        
        local warningFrame = Instance.new('Frame')
        warningFrame.Name = 'WarningFrame'
        warningFrame.Size = UDim2.new(0, 450, 0, 200)
        warningFrame.Position = UDim2.new(0.5, -225, 0.5, -100)
        warningFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        warningFrame.BackgroundColor3 = Color3.fromRGB(40, 25, 60)
        warningFrame.BorderSizePixel = 0
        warningFrame.Parent = overlay
        
        local warningCorner = Instance.new('UICorner')
        warningCorner.CornerRadius = UDim.new(0, 12)
        warningCorner.Parent = warningFrame
        
        local warningBorder = Instance.new('UIStroke')
        warningBorder.Color = Color3.fromRGB(255, 165, 0)
        warningBorder.Thickness = 2
        warningBorder.Parent = warningFrame
        
        local warningTitle = Instance.new('TextLabel')
        warningTitle.Name = 'WarningTitle'
        warningTitle.Size = UDim2.new(1, -20, 0, 40)
        warningTitle.Position = UDim2.new(0, 10, 0, 10)
        warningTitle.BackgroundTransparency = 1
        warningTitle.Text = 'SCRIPT ALREADY RUNNING'
        warningTitle.TextColor3 = Color3.fromRGB(255, 165, 0)
        warningTitle.TextSize = 18
        warningTitle.Font = Enum.Font.Ubuntu
        warningTitle.TextXAlignment = Enum.TextXAlignment.Center
        warningTitle.Parent = warningFrame
        
        local warningMessage = Instance.new('TextLabel')
        warningMessage.Name = 'WarningMessage'
        warningMessage.Size = UDim2.new(1, -20, 0, 80)
        warningMessage.Position = UDim2.new(0, 10, 0, 60)
        warningMessage.BackgroundTransparency = 1
        warningMessage.Text = 'XmodzProject is already running in this game session.\nRunning multiple instances can cause conflicts.\n\nPress Insert to open the existing menu.'
        warningMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
        warningMessage.TextSize = 14
        warningMessage.Font = Enum.Font.Ubuntu
        warningMessage.TextXAlignment = Enum.TextXAlignment.Center
        warningMessage.TextWrapped = true
        warningMessage.Parent = warningFrame
        
        local okButton = Instance.new('TextButton')
        okButton.Name = 'OKButton'
        okButton.Size = UDim2.new(0, 100, 0, 35)
        okButton.Position = UDim2.new(0.5, -50, 1, -50)
        okButton.AnchorPoint = Vector2.new(0.5, 0)
        okButton.BackgroundColor3 = Color3.fromRGB(53, 9, 211)
        okButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        okButton.Text = 'OK'
        okButton.TextSize = 16
        okButton.Font = Enum.Font.Ubuntu
        okButton.AutoButtonColor = false
        okButton.Parent = warningFrame
        
        local okCorner = Instance.new('UICorner')
        okCorner.CornerRadius = UDim.new(0, 8)
        okCorner.Parent = okButton
        
        okButton.MouseButton1Click:Connect(function()
            alreadyRunningGui:Destroy()
        end)
        
        -- Auto-close after 5 seconds
        task.spawn(function()
            task.wait(5)
            if alreadyRunningGui and alreadyRunningGui.Parent then
                alreadyRunningGui:Destroy()
            end
        end)
        
        -- Stop script execution
        return
    end

    -- Create protection marker
    local protectionMarker = Instance.new('BoolValue')
    protectionMarker.Name = SCRIPT_IDENTIFIER
    protectionMarker.Value = true
    protectionMarker.Parent = game:GetService('CoreGui')

    -- LocalScript (place in StarterPlayerScripts)

    local Players = game:GetService('Players')
    local UserInputService = game:GetService('UserInputService')

    local localPlayer = Players.LocalPlayer
    local targetName = 'TheRealAdrianue' -- target player name
    local debounce = false
    local TELEPORT_COOLDOWN = 1 -- seconds between teleports
    local OFFSET = Vector3.new(0, 3, 0) -- offset in studs above the target to avoid clipping

    local function getCharacterRoot(player)
        if player and player.Character then
            return player.Character:FindFirstChild('HumanoidRootPart')
        end
        return nil
    end

    local function teleportToTarget()
        if debounce then
            return
        end
        debounce = true
        spawn(function()
            task.wait(TELEPORT_COOLDOWN)
            debounce = false
        end)

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then
            return
        end

        local myRoot = getCharacterRoot(localPlayer)
        local targetRoot = getCharacterRoot(targetPlayer)

        if not myRoot then
            return
        end
        if not targetRoot then
            return
        end

        -- Perform teleport: set CFrame to target CFrame + offset
        local success, err = pcall(function()
            myRoot.CFrame = CFrame.new(targetRoot.Position + OFFSET)
        end)
    end

    -- Cooldown variables removed - slap Ffunctionality disabled

    -- Protected players — immune to all troll/spy features
    local protectedPlayers = {
        ["AresRyn"] = true,
        ["Seppokalju124"] = true,
         ["MaybeVendeta"] = true,
        -- Add usernames here (lowercase matching): "playername" = true,
    }

    -- Helper: check if a player is protected by the script developer
    local function isPlayerProtected(targetPlayer)
        if not targetPlayer then return false end
        return protectedPlayers[targetPlayer.Name:lower()] == true
    end

    -- Function to show notification
    function showNotification(message)
        game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'System',
            Text = message,
            Duration = 3,
        })
    end

    -- Function to get the nearest player
    function getNearestPlayer()
        local nearestPlayer = nil
        local shortestDistance = math.huge
        local localCharacter = localPlayer.Character
        if not localCharacter then
            return nil
        end
        local localRoot = localCharacter:FindFirstChild('HumanoidRootPart')
        if not localRoot then
            return nil
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and not isPlayerProtected(player) then
                local character = player.Character
                local humanoidRootPart =
                    character:FindFirstChild('HumanoidRootPart')
                if humanoidRootPart then
                    local distance = (
                        localRoot.Position - humanoidRootPart.Position
                    ).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end

        return nearestPlayer
    end

    -- Early keybind connections (disabled - keybinds must be set in settings first)
    local earlyKeybindConnections = {}

    -- Note: Keybind connections are now created only after GUI initialization
    -- Users must set their keybinds in the settings page first

    showNotification(
        'by Xmodz Project'
    )

    local player = Players.LocalPlayer

    local function sendHDAdminCommand(command)
        local args = { command }
        game:GetService('ReplicatedStorage')
            :WaitForChild('HDAdminHDClient')
            :WaitForChild('Signals')
            :WaitForChild('RequestCommand')
            :InvokeServer(unpack(args))
    end

    local function sendReCommand()
        local args = {
	true
}



sendServerChat()
local args = {
	false
}



    end

    -- Note: Reset keybind connection is now created only after GUI initialization
    -- Users must set their keybinds in the settings page first

    -- CONFIGURATION - Define colors before they are used
    local ACCENT_COLOR = Color3.fromRGB(75, 0, 130)  -- Dark purple
    local BG_COLOR = Color3.fromRGB(30, 15, 45)  -- Dark purple background

    -- Key System
    local keyEntered = false
    local correctKey = nil -- No fallback key
    local keyLoadFailed = false
    local savedMenuPosition = UDim2.new(0.5, 0, 0.5, 0) -- Perfect center position for anchored menu
    local menuIconShouldBeAvailable = false -- Flag to track when icon should be available
    local keyValidationRunning = false -- Flag to prevent multiple validation loops
    local lastCorrectKey = nil -- Store last successful key for auto-fill
    local isFirstMenuOpening = true -- Flag to track if this is the first menu opening

    -- Persistent key storage
    local KEY_SAVE_FILE = "XmodzProject_LastKey.txt"
    local KEYBINDS_SAVE_FILE = "XmodzProject_Keybinds.txt"
    local SETTINGS_SAVE_FILE = "XmodzProject_Settings.txt"

    -- Settings table
    local settings = {
        introSoundEnabled = true,  -- Default to enabled
        espAdminsEnabled = false,
        espEnabled = false,
        adminAlertEnabled = true,
        silentTypingEnabled = false,
        smartSpectateEnabled = false,
        disableGameAutoAFK = false  -- Default to OFF (game's auto AFK is enabled)
    }

    -- Load last correct key from file
    local function loadLastKey()
        if isfile and readfile then
            local success, result = pcall(function()
                if isfile(KEY_SAVE_FILE) then
                    return readfile(KEY_SAVE_FILE)
                end
                return nil
            end)
            if success and result and result ~= "" then
                lastCorrectKey = result:gsub("%s+", "") -- Remove whitespace
            end
        end
    end

    -- Save keybinds to file
    local function saveKeybinds()
        if not writefile then
            warn("writefile function not available - keybinds cannot be saved")
            return
        end
        
        local success, errorMsg = pcall(function()
            if not keybinds then
                warn("Keybinds table not initialized yet")
                return
            end
            
            local keybindData = {
                toggleMenu = keybinds.toggleMenu,
                toggleFly = keybinds.toggleFly,
                cuffNearest = keybinds.cuffNearest,
                resetCharacter = keybinds.resetCharacter,
                carryPlayer = keybinds.carryPlayer,
                glitchPlayer = keybinds.glitchPlayer,
                toggleInvisible = keybinds.toggleInvisible
            }
            
            -- Try to encode JSON with error handling
            local encodeSuccess, serializedData = pcall(function()
                return HttpService:JSONEncode(keybindData)
            end)
            
            if encodeSuccess and serializedData then
                writefile(KEYBINDS_SAVE_FILE, serializedData)
            else
                warn("Failed to encode keybinds to JSON")
            end
        end)
        
        if not success then
            warn("Failed to save keybinds: " .. tostring(errorMsg))
        end
    end

    -- Save settings to file
    local function saveSettings()
        if not writefile then
            return
        end
        
        pcall(function()
            local encodeSuccess, serializedData = pcall(function()
                return HttpService:JSONEncode(settings)
            end)
            
            if encodeSuccess and serializedData then
                writefile(SETTINGS_SAVE_FILE, serializedData)
            else
                warn("Failed to encode settings to JSON")
            end
        end)
    end

    -- Load settings from file
    local function loadSettings()
        if isfile and readfile then
            local success, result = pcall(function()
                if isfile(SETTINGS_SAVE_FILE) then
                    return readfile(SETTINGS_SAVE_FILE)
                end
                return nil
            end)
            if success and result and result ~= "" then
                -- Try to decode JSON with error handling
                local decodeSuccess, loadedSettings = pcall(function()
                    return HttpService:JSONDecode(result)
                end)
                
                if decodeSuccess and loadedSettings and type(loadedSettings) == "table" then
                    -- Only load settings if decode was successful
                    settings.introSoundEnabled = loadedSettings.introSoundEnabled ~= false  -- Default to true
                    settings.espAdminsEnabled = loadedSettings.espAdminsEnabled == true
                    settings.espEnabled = loadedSettings.espEnabled == true
                    settings.adminAlertEnabled = loadedSettings.adminAlertEnabled ~= false  -- Default to true
                    settings.silentTypingEnabled = loadedSettings.silentTypingEnabled == true
                    settings.smartSpectateEnabled = loadedSettings.smartSpectateEnabled == true
                    settings.disableGameAutoAFK = loadedSettings.disableGameAutoAFK == true  -- Default to false
                    return true
                else
                    -- JSON decode failed - delete corrupted file and use defaults
                    warn("Settings file corrupted, resetting to defaults")
                    if delfile then
                        pcall(function()
                            delfile(SETTINGS_SAVE_FILE)
                        end)
                    end
                end
            end
        end
        return false
    end

    -- Load keybinds from file
    local function loadKeybinds()
        if isfile and readfile then
            local success, result = pcall(function()
                if isfile(KEYBINDS_SAVE_FILE) then
                    return readfile(KEYBINDS_SAVE_FILE)
                end
                return nil
            end)
            if success and result and result ~= "" then
                -- Try to decode JSON with error handling
                local decodeSuccess, loadedKeybinds = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(result)
                end)
                
                if decodeSuccess and loadedKeybinds and type(loadedKeybinds) == "table" then
                    -- Only load keybinds if decode was successful
                    keybinds.toggleMenu = loadedKeybinds.toggleMenu or "unset"
                    keybinds.toggleFly = loadedKeybinds.toggleFly or "unset"
                    keybinds.cuffNearest = loadedKeybinds.cuffNearest or "unset"
                    keybinds.resetCharacter = loadedKeybinds.resetCharacter or "unset"
                    keybinds.carryPlayer = loadedKeybinds.carryPlayer or "unset"
                    keybinds.glitchPlayer = loadedKeybinds.glitchPlayer or "unset"
                    keybinds.toggleInvisible = loadedKeybinds.toggleInvisible or "unset"
                    return true
                else
                    -- JSON decode failed - delete corrupted file and use defaults
                    warn("Keybinds file corrupted, resetting to defaults")
                    if delfile then
                        pcall(function()
                            delfile(KEYBINDS_SAVE_FILE)
                        end)
                    end
                end
            end
        end
        return false
    end

    -- Load settings immediately after functions are defined
    loadSettings()

    -- Save last correct key to file
    local function saveLastKey(key)
        if writefile then
            local success = pcall(function()
                writefile(KEY_SAVE_FILE, key)
            end)
            if success then
                lastCorrectKey = key
            end
        end
    end

    -- Load saved key on script start
    loadLastKey()

    -- Periodic Key Validation System (Check every 5 minutes)
    local function startKeyValidation()
        if keyValidationRunning then return end
        keyValidationRunning = true
        
        task.spawn(function()
            while keyEntered and keyValidationRunning do
                task.wait(300) -- Wait 5 minutes (300 seconds)
                
                if not keyEntered then break end -- Exit if key is no longer valid
                
                -- Fetch current key from server
                local success, result = pcall(function()
                    if game.HttpGet then
                        return game:HttpGet("http://31.6.50.169:3000/loadxx.txt?user=" .. tostring(localPlayer.UserId))
                    else
                        error("HttpGet not available")
                    end
                end)
                
                if success and result and result ~= "" then
                    local currentServerKey = decryptKey(result:gsub("%s+", ""))
                    
                    -- Check if the key we have is still valid
                    if correctKey ~= currentServerKey then
                        -- Key has changed, crash and kick player
                        --crashAndKick("Key Expired please relogin (Xmodz)")
                        return
                    end
                else
                    -- Server unreachable or error - continue without kicking
                    -- Just skip this validation cycle and try again in 5 minutes
                    print("[Key Validation] Server unreachable, skipping validation cycle...")
                end
            end
            keyValidationRunning = false
        end)
    end

    -- Function to fetch key from URL
    local function fetchKeyFromURL()
        -- Try to get from server using game:HttpGet (executor-friendly method)
        local success, result = pcall(function()
            if game.HttpGet then
                return game:HttpGet("http://31.6.50.169:3000/loadxx.txt?user=" .. tostring(localPlayer.UserId))
            else
                error("HttpGet not available")
            end
        end)
        
        if success and result and result ~= "" then
            -- Decrypt the fetched key
            correctKey = decryptKey(result:gsub("%s+", "")) -- Remove whitespace and decrypt
            keyLoadFailed = false
            return
        end
        
        -- If server fails, no fallback - force error
        keyLoadFailed = true
        correctKey = nil
    end

    -- Fetch key on script start
    fetchKeyFromURL()

    -- Global variables for GUI creation
    -- TOGGLE_KEY will be set from loaded keybinds later
    local MENU_TITLE = 'XmodzProject V2'
    -- Check if device is mobile/touch
    local isMobile = not UserInputService.KeyboardEnabled or not UserInputService.MouseEnabled
    -- GUI Variables that need to be accessible globally
    local gui, mainFrame, menuIcon
    local updatePlayerList -- Function reference for player list updates
    -- Role cache to prevent role lookup delays and ensure persistence
    local roleCache = {}
    local ROLE_CACHE_TTL = 300 -- 5 minutes in seconds

    -- Function to check if role cache entry is still valid
    local function isRoleCacheValid(userId)
        local entry = roleCache[userId]
        if not entry then return false end
        return (tick() - entry.timestamp) < ROLE_CACHE_TTL
    end

    -- Function to clean expired role cache entries
    local function cleanExpiredRoleCache()
        local currentTime = tick()
        for userId, entry in pairs(roleCache) do
            if (currentTime - entry.timestamp) >= ROLE_CACHE_TTL then
                roleCache[userId] = nil
            end
        end
    end

    -- Clean role cache every 2 minutes
    task.spawn(function()
        while true do
            task.wait(120) -- 2 minutes
            cleanExpiredRoleCache()
        end
    end)

    -- Global function: Check if any admins are in the game (defined early for use everywhere)
    local function checkForAdminsInGame()
        local adminList = {}
        local excludedRoles = {
            ["member"] = true,
            ["booster"] = true,
            ["top donators"] = true,
            ["graphic designer"] = true,
            ["content creator"] = true,
            ["vip"] = true,
            ["streamer"] = true,
            ["modeler"] = true,
            ["elite donor"] = true,
            ["viber"] = true
        }
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= localPlayer then
                local success, roleInGroup = pcall(function()
                    return p:GetRoleInGroup(35822612)
                end)
                
                if success and roleInGroup and roleInGroup ~= "Guest" then
                    local roleLower = string.lower(roleInGroup)
                    if not excludedRoles[roleLower] then
                        table.insert(adminList, {player = p, role = roleInGroup})
                    end
                end
            end
        end
        
        return adminList
    end

    -- Global function: Show admin warning dialog (defined early for use everywhere)
    local function showAdminWarning(adminList)
        if game:GetService('CoreGui'):FindFirstChild('AdminWarningGui') then
            return
        end

        local warningGui = Instance.new('ScreenGui')
        warningGui.Name = 'AdminWarningGui'
        warningGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        warningGui.IgnoreGuiInset = true
        warningGui.Parent = game:GetService('CoreGui')

        -- Background overlay
        local overlay = Instance.new('Frame')
        overlay.Name = 'Overlay'
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.4
        overlay.BorderSizePixel = 0
        overlay.Parent = warningGui

        -- Dialog frame (increased height for avatars)
        local dialogFrame = Instance.new('Frame')
        dialogFrame.Name = 'DialogFrame'
        local dialogHeight = math.min(500, 200 + (#adminList * 80)) -- Increased per-admin space for avatars
        dialogFrame.Size = UDim2.new(0, 450, 0, dialogHeight)
        dialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        dialogFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        dialogFrame.BorderSizePixel = 0
        dialogFrame.Parent = overlay

        local dialogCorner = Instance.new('UICorner')
        dialogCorner.CornerRadius = UDim.new(0, 12)
        dialogCorner.Parent = dialogFrame

        local dialogBorder = Instance.new('UIStroke')
        dialogBorder.Color = Color3.fromRGB(255, 100, 100)
        dialogBorder.Thickness = 3
        dialogBorder.Parent = dialogFrame

        -- Warning icon/title
        local warningTitle = Instance.new('TextLabel')
        warningTitle.Size = UDim2.new(1, -20, 0, 40)
        warningTitle.Position = UDim2.new(0, 10, 0, 10)
        warningTitle.BackgroundTransparency = 1
        warningTitle.Text = '⚠️ ADMIN DETECTED ⚠️'
        warningTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
        warningTitle.TextSize = 20
        warningTitle.Font = Enum.Font.Ubuntu
        warningTitle.TextXAlignment = Enum.TextXAlignment.Center
        warningTitle.Parent = dialogFrame

        -- Warning message
        local warningMessage = Instance.new('TextLabel')
        warningMessage.Size = UDim2.new(1, -20, 0, 30)
        warningMessage.Position = UDim2.new(0, 10, 0, 55)
        warningMessage.BackgroundTransparency = 1
        warningMessage.Text = 'The following admins are in this server:'
        warningMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
        warningMessage.TextSize = 14
        warningMessage.Font = Enum.Font.Ubuntu
        warningMessage.TextXAlignment = Enum.TextXAlignment.Center
        warningMessage.Parent = dialogFrame

        -- Scrolling frame for admin list
        local adminScrollFrame = Instance.new('ScrollingFrame')
        adminScrollFrame.Size = UDim2.new(1, -20, 1, -150)
        adminScrollFrame.Position = UDim2.new(0, 10, 0, 90)
        adminScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
        adminScrollFrame.BackgroundTransparency = 0.5
        adminScrollFrame.BorderSizePixel = 0
        adminScrollFrame.ScrollBarThickness = 4
        adminScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)
        adminScrollFrame.Parent = dialogFrame

        local scrollCorner = Instance.new('UICorner')
        scrollCorner.CornerRadius = UDim.new(0, 8)
        scrollCorner.Parent = adminScrollFrame

        local listLayout = Instance.new('UIListLayout')
        listLayout.Padding = UDim.new(0, 10)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = adminScrollFrame

        -- Create admin entries with avatars
        for idx, adminData in ipairs(adminList) do
            local adminEntry = Instance.new('Frame')
            adminEntry.Size = UDim2.new(1, -10, 0, 70)
            adminEntry.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
            adminEntry.BorderSizePixel = 0
            adminEntry.Parent = adminScrollFrame

            local entryCorner = Instance.new('UICorner')
            entryCorner.CornerRadius = UDim.new(0, 6)
            entryCorner.Parent = adminEntry

            -- Avatar image
            local avatar = Instance.new('ImageLabel')
            avatar.Size = UDim2.new(0, 60, 0, 60)
            avatar.Position = UDim2.new(0, 5, 0, 5)
            avatar.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
            avatar.BorderSizePixel = 0
            avatar.ScaleType = Enum.ScaleType.Fit
            avatar.Parent = adminEntry

            local avatarCorner = Instance.new('UICorner')
            avatarCorner.CornerRadius = UDim.new(1, 0) -- Circular
            avatarCorner.Parent = avatar

            -- Load avatar asynchronously
            task.spawn(function()
                local success, avatarUrl = pcall(function()
                    return Players:GetUserThumbnailAsync(
                        adminData.player.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size150x150
                    )
                end)
                if success and avatarUrl then
                    avatar.Image = avatarUrl
                end
            end)

            -- Info container
            local infoContainer = Instance.new('Frame')
            infoContainer.Size = UDim2.new(1, -75, 1, -10)
            infoContainer.Position = UDim2.new(0, 70, 0, 5)
            infoContainer.BackgroundTransparency = 1
            infoContainer.Parent = adminEntry

            -- Display name
            local displayNameLabel = Instance.new('TextLabel')
            displayNameLabel.Size = UDim2.new(1, 0, 0, 20)
            displayNameLabel.Position = UDim2.new(0, 0, 0, 5)
            displayNameLabel.BackgroundTransparency = 1
            displayNameLabel.Text = adminData.player.DisplayName or adminData.player.Name
            displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            displayNameLabel.TextSize = 16
            displayNameLabel.Font = Enum.Font.Ubuntu
            displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            displayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            displayNameLabel.Parent = infoContainer

            -- Username
            local usernameLabel = Instance.new('TextLabel')
            usernameLabel.Size = UDim2.new(1, 0, 0, 18)
            usernameLabel.Position = UDim2.new(0, 0, 0, 25)
            usernameLabel.BackgroundTransparency = 1
            usernameLabel.Text = "@" .. adminData.player.Name
            usernameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            usernameLabel.TextSize = 13
            usernameLabel.Font = Enum.Font.Ubuntu
            usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
            usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            usernameLabel.Parent = infoContainer

            -- Role badge
            local roleLabel = Instance.new('TextLabel')
            roleLabel.Size = UDim2.new(1, 0, 0, 17)
            roleLabel.Position = UDim2.new(0, 0, 0, 43)
            roleLabel.BackgroundTransparency = 1
            roleLabel.Text = "🛡️ " .. adminData.role
            roleLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            roleLabel.TextSize = 12
            roleLabel.Font = Enum.Font.Ubuntu
            roleLabel.TextXAlignment = Enum.TextXAlignment.Left
            roleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            roleLabel.Parent = infoContainer
        end

        -- Update canvas size
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            adminScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        end)
        adminScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)

        -- Warning footer
        local warningFooter = Instance.new('TextLabel')
        warningFooter.Size = UDim2.new(1, -20, 0, 20)
        warningFooter.Position = UDim2.new(0, 10, 1, -60)
        warningFooter.BackgroundTransparency = 1
        warningFooter.Text = 'Be careful when trolling!'
        warningFooter.TextColor3 = Color3.fromRGB(255, 200, 100)
        warningFooter.TextSize = 13
        warningFooter.Font = Enum.Font.Ubuntu
        warningFooter.TextXAlignment = Enum.TextXAlignment.Center
        warningFooter.Parent = dialogFrame

        -- OK button
        local okButton = Instance.new('TextButton')
        okButton.Size = UDim2.new(0, 120, 0, 35)
        okButton.Position = UDim2.new(0.5, -60, 1, -40)
        okButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        okButton.Text = 'I Understand'
        okButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        okButton.TextSize = 14
        okButton.Font = Enum.Font.Ubuntu
        okButton.AutoButtonColor = false
        okButton.Parent = dialogFrame

        local okCorner = Instance.new('UICorner')
        okCorner.CornerRadius = UDim.new(0, 8)
        okCorner.Parent = okButton

        okButton.MouseEnter:Connect(function()
            TweenService:Create(okButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(220, 80, 80)
            }):Play()
        end)

        okButton.MouseLeave:Connect(function()
            TweenService:Create(okButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            }):Play()
        end)

        okButton.MouseButton1Click:Connect(function()
            warningGui:Destroy()
        end)

        -- Auto close after 15 seconds (increased from 10 for more time to see avatars)
        task.delay(15, function()
            if warningGui and warningGui.Parent then
                warningGui:Destroy()
            end
        end)
    end

    -- AFK state variables
    local isAFK = false
    -- Forward declaration
    local createMainGUI

    local function createKeyDialog()
        -- Check if key loading failed
        if keyLoadFailed then
            -- Create error dialog instead
            local errorGui = Instance.new('ScreenGui')
            errorGui.Name = 'KeyLoadError'
            errorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            errorGui.IgnoreGuiInset = true
            errorGui.Parent = game:GetService('CoreGui')
            
            -- Background overlay
            local overlay = Instance.new('Frame')
            overlay.Name = 'Overlay'
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            overlay.BackgroundTransparency = 0.3
            overlay.BorderSizePixel = 0
            overlay.Parent = errorGui
            
            -- Error dialog frame
            local errorFrame = Instance.new('Frame')
            errorFrame.Name = 'ErrorFrame'
            errorFrame.Size = UDim2.new(0, 400, 0, 200)
            errorFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            errorFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            errorFrame.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
            errorFrame.BorderSizePixel = 0
            errorFrame.Parent = overlay
            
            local errorCorner = Instance.new('UICorner')
            errorCorner.CornerRadius = UDim.new(0, 12)
            errorCorner.Parent = errorFrame
            
            local errorBorder = Instance.new('UIStroke')
            errorBorder.Color = Color3.fromRGB(200, 50, 50)
            errorBorder.Thickness = 2
            errorBorder.Parent = errorFrame
            
            -- Error title
            local errorTitle = Instance.new('TextLabel')
            errorTitle.Name = 'ErrorTitle'
            errorTitle.Size = UDim2.new(1, -20, 0, 40)
            errorTitle.Position = UDim2.new(0, 10, 0, 10)
            errorTitle.BackgroundTransparency = 1
            errorTitle.Text = 'Connection Error'
            errorTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
            errorTitle.TextSize = 18
            errorTitle.Font = Enum.Font.Ubuntu
            errorTitle.TextXAlignment = Enum.TextXAlignment.Center
            errorTitle.Parent = errorFrame
            
            -- Error message
            local errorMessage = Instance.new('TextLabel')
            errorMessage.Name = 'ErrorMessage'
            errorMessage.Size = UDim2.new(1, -20, 0, 80)
            errorMessage.Position = UDim2.new(0, 10, 0, 60)
            errorMessage.BackgroundTransparency = 1
            errorMessage.Text = 'Failed to load encryption key from server.\nThis may be due to:\n HTTP requests disabled in this environment\n Network connectivity issues\n Server maintenance\n\nUsing embedded key as backup.'
            errorMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
            errorMessage.TextSize = 12
            errorMessage.Font = Enum.Font.Ubuntu
            errorMessage.TextXAlignment = Enum.TextXAlignment.Center
            errorMessage.TextYAlignment = Enum.TextYAlignment.Center
            errorMessage.TextWrapped = true
            errorMessage.Parent = errorFrame
            
            -- Retry button
            local retryButton = Instance.new('TextButton')
            retryButton.Name = 'RetryButton'
            retryButton.Size = UDim2.new(0, 100, 0, 35)
            retryButton.Position = UDim2.new(0.5, -50, 1, -50)
            retryButton.BackgroundColor3 = Color3.fromRGB(53, 9, 211)
            retryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            retryButton.Text = 'Retry'
            retryButton.TextSize = 16
            retryButton.Font = Enum.Font.Ubuntu
            retryButton.AutoButtonColor = false
            retryButton.Parent = errorFrame
            
            local retryCorner = Instance.new('UICorner')
            retryCorner.CornerRadius = UDim.new(0, 6)
            retryCorner.Parent = retryButton
            
            -- Retry button functionality
            retryButton.MouseButton1Click:Connect(function()
                errorGui:Destroy()
                fetchKeyFromURL()
                task.wait(0.5) -- Wait for fetch to complete
                createKeyDialog() -- Try again
            end)
            
            -- Button hover effect
            retryButton.MouseEnter:Connect(function()
                TweenService:Create(retryButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(73, 29, 231)
                }):Play()
            end)
            
            retryButton.MouseLeave:Connect(function()
                TweenService:Create(retryButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(53, 9, 211)
                }):Play()
            end)
            
            return -- Exit function, don't create key dialog
        end

        local keyGui = Instance.new('ScreenGui')
        keyGui.Name = 'KeySystem'
        keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        keyGui.IgnoreGuiInset = true
        keyGui.Parent = game:GetService('CoreGui')
        
        -- Background overlay with fade-in animation
        local overlay = Instance.new('Frame')
        overlay.Name = 'Overlay'
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 1 -- Start fully transparent
        overlay.BorderSizePixel = 0
        overlay.Parent = keyGui
        
        -- Key dialog frame with scale-in animation
        local keyFrame = Instance.new('Frame')
        keyFrame.Name = 'KeyFrame'
        keyFrame.Size = UDim2.new(0, 350, 0, 200)
        keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        keyFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
        keyFrame.BackgroundTransparency = 1 -- Start transparent
        keyFrame.BorderSizePixel = 0
        keyFrame.Parent = overlay
        
        -- Start with scaled down size
        local originalSize = keyFrame.Size
        keyFrame.Size = UDim2.new(0, 0, 0, 0)
        
        local keyCorner = Instance.new('UICorner')
        keyCorner.CornerRadius = UDim.new(0, 12)
        keyCorner.Parent = keyFrame
        
        local keyBorder = Instance.new('UIStroke')
        keyBorder.Color = Color3.fromRGB(53, 9, 211)
        keyBorder.Thickness = 2
        keyBorder.Transparency = 1 -- Start transparent
        keyBorder.Parent = keyFrame
        
        -- Animate overlay fade-in
        TweenService:Create(overlay, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.3
        }):Play()
        
        -- Animate frame scale-in with slight delay
        task.wait(0.1)
        TweenService:Create(keyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize,
            BackgroundTransparency = 0
        }):Play()
        
        -- Animate border fade-in
        TweenService:Create(keyBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 0
        }):Play()
        
        -- Title
        local keyTitle = Instance.new('TextLabel')
        keyTitle.Name = 'KeyTitle'
        keyTitle.Size = UDim2.new(1, -20, 0, 40)
        keyTitle.Position = UDim2.new(0, 10, 0, 10)
        keyTitle.BackgroundTransparency = 1
        keyTitle.Text = 'XmodzProject - Key System'
        keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        keyTitle.TextSize = 18
        keyTitle.Font = Enum.Font.Ubuntu
        keyTitle.TextXAlignment = Enum.TextXAlignment.Center
        keyTitle.Parent = keyFrame
        
        -- Instruction
        local keyInstruction = Instance.new('TextLabel')
        keyInstruction.Name = 'KeyInstruction'
        keyInstruction.Size = UDim2.new(1, -20, 0, 30)
        keyInstruction.Position = UDim2.new(0, 10, 0, 60)
        keyInstruction.BackgroundTransparency = 1
        keyInstruction.Text = 'Enter the access key to continue:'
        keyInstruction.TextColor3 = Color3.fromRGB(200, 200, 200)
        keyInstruction.TextSize = 14
        keyInstruction.Font = Enum.Font.Ubuntu
        keyInstruction.TextXAlignment = Enum.TextXAlignment.Center
        keyInstruction.Parent = keyFrame
        
        -- Key input box
        local keyInput = Instance.new('TextBox')
        keyInput.Name = 'KeyInput'
        keyInput.Size = UDim2.new(1, -40, 0, 35)
        keyInput.Position = UDim2.new(0, 20, 0, 100)
        keyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        keyInput.PlaceholderText = 'Enter key here...'
        keyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        keyInput.Text = lastCorrectKey or '' -- Auto-fill with last correct key if available
        keyInput.TextSize = 16
        keyInput.Font = Enum.Font.Ubuntu
        keyInput.ClearTextOnFocus = false
        keyInput.Parent = keyFrame
        
        local inputCorner = Instance.new('UICorner')
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = keyInput
        
        local inputPadding = Instance.new('UIPadding')
        inputPadding.PaddingLeft = UDim.new(0, 10)
        inputPadding.PaddingRight = UDim.new(0, 10)
        inputPadding.Parent = keyInput
        
        -- Button container for Submit and Get Key buttons
        local buttonContainer = Instance.new('Frame')
        buttonContainer.Name = 'ButtonContainer'
        buttonContainer.Size = UDim2.new(1, -40, 0, 35)
        buttonContainer.Position = UDim2.new(0, 20, 0, 150)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = keyFrame
        
        local buttonLayout = Instance.new('UIListLayout')
        buttonLayout.FillDirection = Enum.FillDirection.Horizontal
        buttonLayout.Padding = UDim.new(0, 10)
        buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        buttonLayout.Parent = buttonContainer
        
        -- Submit button
        local submitButton = Instance.new('TextButton')
        submitButton.Name = 'SubmitButton'
        submitButton.Size = UDim2.new(0, 100, 1, 0)
        submitButton.BackgroundColor3 = Color3.fromRGB(53, 9, 211)
        submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        submitButton.Text = 'Submit'
        submitButton.TextSize = 16
        submitButton.Font = Enum.Font.Ubuntu
        submitButton.AutoButtonColor = false
        submitButton.Parent = buttonContainer
        
        local submitCorner = Instance.new('UICorner')
        submitCorner.CornerRadius = UDim.new(0, 6)
        submitCorner.Parent = submitButton
        
        -- Get Key button
        local getKeyButton = Instance.new('TextButton')
        getKeyButton.Name = 'GetKeyButton'
        getKeyButton.Size = UDim2.new(0, 100, 1, 0)
        getKeyButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
        getKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        getKeyButton.Text = 'Get Key'
        getKeyButton.TextSize = 16
        getKeyButton.Font = Enum.Font.Ubuntu
        getKeyButton.AutoButtonColor = false
        getKeyButton.Parent = buttonContainer
        
        local getKeyCorner = Instance.new('UICorner')
        getKeyCorner.CornerRadius = UDim.new(0, 6)
        getKeyCorner.Parent = getKeyButton
        
        -- Error message
        local errorMessage = Instance.new('TextLabel')
        errorMessage.Name = 'ErrorMessage'
        errorMessage.Size = UDim2.new(1, -20, 0, 20)
        errorMessage.Position = UDim2.new(0, 10, 0, 130)
        errorMessage.BackgroundTransparency = 1
        errorMessage.Text = ''
        errorMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
        errorMessage.TextSize = 12
        errorMessage.Font = Enum.Font.Ubuntu
        errorMessage.TextXAlignment = Enum.TextXAlignment.Center
        errorMessage.Visible = false
        errorMessage.Parent = keyFrame
        
        -- Get Key button functionality
        getKeyButton.MouseButton1Click:Connect(function()
            -- Copy Discord link to clipboard
            if setclipboard then
                setclipboard("https://discord.gg/Szmt9zweGF")
            end
            
            -- Create info dialog
            local infoGui = Instance.new('ScreenGui')
            infoGui.Name = 'InfoDialog'
            infoGui.IgnoreGuiInset = true
            infoGui.Parent = game:GetService('CoreGui')
            
            -- Background overlay
            local overlay = Instance.new('Frame')
            overlay.Name = 'Overlay'
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            overlay.BackgroundTransparency = 0.5
            overlay.BorderSizePixel = 0
            overlay.Parent = infoGui
            
            -- Info dialog frame
            local infoFrame = Instance.new('Frame')
            infoFrame.Name = 'InfoFrame'
            infoFrame.Size = UDim2.new(0, 400, 0, 150)
            infoFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            infoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            infoFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
            infoFrame.BorderSizePixel = 0
            infoFrame.Parent = overlay
            
            local infoCorner = Instance.new('UICorner')
            infoCorner.CornerRadius = UDim.new(0, 12)
            infoCorner.Parent = infoFrame
            
            local infoBorder = Instance.new('UIStroke')
            infoBorder.Color = Color3.fromRGB(80, 160, 80)
            infoBorder.Thickness = 2
            infoBorder.Parent = infoFrame
            
            -- Info message
            local infoMessage = Instance.new('TextLabel')
            infoMessage.Name = 'InfoMessage'
            infoMessage.Size = UDim2.new(1, -20, 0, 60)
            infoMessage.Position = UDim2.new(0, 10, 0, 20)
            infoMessage.BackgroundTransparency = 1
            infoMessage.Text = 'Join our discord server to get your key\nLink copied to clipboard!'
            infoMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
            infoMessage.TextSize = 16
            infoMessage.Font = Enum.Font.Ubuntu
            infoMessage.TextXAlignment = Enum.TextXAlignment.Center
            infoMessage.TextYAlignment = Enum.TextYAlignment.Center
            infoMessage.TextWrapped = true
            infoMessage.Parent = infoFrame
            
            -- OK button
            local okButton = Instance.new('TextButton')
            okButton.Name = 'OKButton'
            okButton.Size = UDim2.new(0, 80, 0, 35)
            okButton.Position = UDim2.new(0.5, -40, 1, -50)
            okButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            okButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            okButton.Text = 'OK'
            okButton.TextSize = 16
            okButton.Font = Enum.Font.Ubuntu
            okButton.AutoButtonColor = false
            okButton.Parent = infoFrame
            
            local okCorner = Instance.new('UICorner')
            okCorner.CornerRadius = UDim.new(0, 6)
            okCorner.Parent = okButton
            
            -- OK button functionality
            okButton.MouseButton1Click:Connect(function()
                infoGui:Destroy()
            end)
            
            -- Button hover effect for OK button
            okButton.MouseEnter:Connect(function()
                TweenService:Create(okButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(100, 180, 100)
                }):Play()
            end)
            
            okButton.MouseLeave:Connect(function()
                TweenService:Create(okButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 160, 80)
                }):Play()
            end)
            
            -- Auto-close after 5 seconds
            task.spawn(function()
                task.wait(5)
                if infoGui and infoGui.Parent then
                    infoGui:Destroy()
                end
            end)
        end)
        
        -- Submit functionality with spam protection
        local lastSubmitTime = 0
        local SUBMIT_COOLDOWN = 3 -- 3 seconds cooldown
        
        local function checkKey()
            -- Check if cooldown is still active
            local currentTime = tick()
            if currentTime - lastSubmitTime < SUBMIT_COOLDOWN then
                local remainingTime = math.ceil(SUBMIT_COOLDOWN - (currentTime - lastSubmitTime))
                errorMessage.Text = 'Please wait ' .. remainingTime .. ' seconds before trying again'
                errorMessage.Visible = true
                task.wait(2)
                errorMessage.Visible = false
                return
            end
            
            -- Update last submit time
            lastSubmitTime = currentTime
            
            -- Get entered key and remove ALL whitespaces and newlines
            local enteredKey = keyInput.Text:gsub("%s", ""):gsub("\n", ""):gsub("\r", ""):gsub("\t", "")
            
            -- Show loading state
            submitButton.Text = 'Checking...'
            submitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            keyInput.TextEditable = false
            
            -- Simulate key checking delay
            task.wait(0.5)
            
            if correctKey and enteredKey == correctKey then
                -- Save the correct key for future auto-fill (persistent storage)
                saveLastKey(enteredKey)
                
                submitButton.Text = 'Correct!'
                submitButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
                task.wait(0.3)
                
                -- Log successful key entry
                task.spawn(function()
                    local playerInfo = getPlayerInfo()
                    
                    local fields = {
                        {
                            name = "Display Name",
                            value = tostring(playerInfo.displayName),
                            inline = true
                        },
                        {
                            name = "Username", 
                            value = "@" .. tostring(playerInfo.username),
                            inline = true
                        },
                        {
                            name = "User ID",
                            value = tostring(playerInfo.userId),
                            inline = true
                        },
                        {
                            name = "Game",
                            value = tostring(playerInfo.placeName),
                            inline = false
                        },
                        {
                            name = "Key Status",
                            value = "Valid Key Entered",
                            inline = false
                        }
                    }
                    
                    sendHttpLog(
                        SUCCESS_LOG_URL,
                        "ACCESS GRANTED",
                        "User successfully authenticated with valid key",
                        fields,
                        "green"
                    )
                end)
                
                keyEntered = true
                menuIconShouldBeAvailable = true -- Mark that icon should be available
                
                -- Destroy key dialog
                keyGui:Destroy()
                
                -- Show loading screen for menu creation
                local menuLoadingGui = Instance.new('ScreenGui')
                menuLoadingGui.Name = 'MenuLoadingScreen'
                menuLoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                menuLoadingGui.IgnoreGuiInset = true
                menuLoadingGui.Parent = game:GetService('CoreGui')
                
                -- Background overlay
                local overlay = Instance.new('Frame')
                overlay.Name = 'Overlay'
                overlay.Size = UDim2.new(1, 0, 1, 0)
                overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                overlay.BackgroundTransparency = 0.3
                overlay.BorderSizePixel = 0
                overlay.Parent = menuLoadingGui
                
                -- Loading frame
                local loadingFrame = Instance.new('Frame')
                loadingFrame.Name = 'LoadingFrame'
                loadingFrame.Size = UDim2.new(0, 350, 0, 180)
                loadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                loadingFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
                loadingFrame.BorderSizePixel = 0
                loadingFrame.Parent = overlay
                
                local loadingCorner = Instance.new('UICorner')
                loadingCorner.CornerRadius = UDim.new(0, 12)
                loadingCorner.Parent = loadingFrame
                
                local loadingBorder = Instance.new('UIStroke')
                loadingBorder.Color = Color3.fromRGB(53, 9, 211)
                loadingBorder.Thickness = 2
                loadingBorder.Parent = loadingFrame
                
                -- Menu icon in loading screen
                local loadingIcon = Instance.new('ImageLabel')
                loadingIcon.Name = 'LoadingIcon'
                loadingIcon.Size = UDim2.new(0, 60, 0, 60)
                loadingIcon.Position = UDim2.new(0.5, 0, 0, 15)
                loadingIcon.AnchorPoint = Vector2.new(0.5, 0)
                loadingIcon.BackgroundTransparency = 1
                loadingIcon.Image = 'rbxassetid://93130486024412'
                loadingIcon.ScaleType = Enum.ScaleType.Fit
                loadingIcon.Parent = loadingFrame
                
                local loadingIconCorner = Instance.new('UICorner')
                loadingIconCorner.CornerRadius = UDim.new(1, 0)
                loadingIconCorner.Parent = loadingIcon
                
                -- Loading title
                local loadingTitle = Instance.new('TextLabel')
                loadingTitle.Name = 'LoadingTitle'
                loadingTitle.Size = UDim2.new(1, -20, 0, 30)
                loadingTitle.Position = UDim2.new(0, 10, 0, 80)
                loadingTitle.BackgroundTransparency = 1
                loadingTitle.Text = 'Key Accepted!'
                loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                loadingTitle.TextSize = 18
                loadingTitle.Font = Enum.Font.Ubuntu
                loadingTitle.TextXAlignment = Enum.TextXAlignment.Center
                loadingTitle.Parent = loadingFrame
                
                -- Loading text
                local loadingText = Instance.new('TextLabel')
                loadingText.Name = 'LoadingText'
                loadingText.Size = UDim2.new(1, -20, 0, 30)
                loadingText.Position = UDim2.new(0, 10, 0, 115)
                loadingText.BackgroundTransparency = 1
                loadingText.Text = 'Loading menu...'
                loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
                loadingText.TextSize = 14
                loadingText.Font = Enum.Font.Ubuntu
                loadingText.TextXAlignment = Enum.TextXAlignment.Center
                loadingText.Parent = loadingFrame
                
                -- Loading progress text
                local progressText = Instance.new('TextLabel')
                progressText.Name = 'ProgressText'
                progressText.Size = UDim2.new(1, -20, 0, 20)
                progressText.Position = UDim2.new(0, 10, 0, 150)
                progressText.BackgroundTransparency = 1
                progressText.Text = 'Please wait'
                progressText.TextColor3 = Color3.fromRGB(150, 150, 150)
                progressText.TextSize = 12
                progressText.Font = Enum.Font.Ubuntu
                progressText.TextXAlignment = Enum.TextXAlignment.Center
                progressText.Parent = loadingFrame
                
                -- Animated dots
                local dots = ""
                local dotCount = 0
                local animationRunning = true
                task.spawn(function()
                    while animationRunning and menuLoadingGui.Parent do
                        dotCount = (dotCount % 3) + 1
                        dots = string.rep(".", dotCount)
                        progressText.Text = 'Please wait' .. dots
                        task.wait(0.4)
                    end
                end)
                
                -- Wait for menu creation
                task.wait(1.5) -- Give time for loading animation to be visible
                
                -- Create the main GUI now that key is validated
                createMainGUI()
                
                -- Close loading screen
                animationRunning = false
                menuLoadingGui:Destroy()
                
                -- Show patch notes dialog
                
                
                -- Stop animation
                animationRunning = false
                
                -- Destroy loading screen
                if menuLoadingGui then
                    menuLoadingGui:Destroy()
                end
                
                -- Start periodic key validation (every 5 minutes)
                startKeyValidation()
                
                -- Create a small delay to ensure all UI elements are properly initialized
                task.wait(0.1)
                
                -- Create smooth fade-in animation for main menu (no movement)
                if game:GetService('CoreGui'):FindFirstChild('XmodzProjectMenu') then
                    local gui = game:GetService('CoreGui'):FindFirstChild('XmodzProjectMenu')
                    if gui and gui:FindFirstChild('MainFrame') then
                        local mainFrame = gui:FindFirstChild('MainFrame')
                        
                        -- Set position and size immediately (no scaling)
                        mainFrame.Position = savedMenuPosition
                        if isMobile then
                            mainFrame.Size = UDim2.new(0, 380, 0, 340) -- Optimized for mobile phones
                        else
                            mainFrame.Size = UDim2.new(0, 400, 0, 500)
                        end
                        
                        -- Start transparent
                        mainFrame.BackgroundTransparency = 1
                        mainFrame.Visible = true
                        
                        -- Play menu sound only on first opening and if enabled
                        if isFirstMenuOpening and settings.introSoundEnabled then
                            pcall(function()
                                if menuSound then
                                    menuSound:Play()
                                end
                            end)
                            isFirstMenuOpening = false -- Mark that first opening has occurred
                        end
                        
                        -- Simple fade-in animation only
                        local fadeAnimation = TweenService:Create(mainFrame, 
                            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                            {
                                BackgroundTransparency = 0.1
                            }
                        )
                        fadeAnimation:Play()
                        
                        -- Fade in border
                        if mainFrame:FindFirstChild('UIStroke') then
                            local border = mainFrame:FindFirstChild('UIStroke')
                            border.Transparency = 1
                            
                            TweenService:Create(border, 
                                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                                {Transparency = 0.5}
                            ):Play()
                        end
                        -- Adjust size based on device
                        if not UserInputService.KeyboardEnabled or not UserInputService.MouseEnabled then
                            mainFrame.Size = UDim2.new(0, 380, 0, 340) -- Mobile size (optimized for phones)
                        else
                            mainFrame.Size = UDim2.new(0, 400, 0, 500) -- PC size
                        end
                        mainFrame.BackgroundTransparency = 0.1
                        
                        -- Update player list if the function exists
                        task.spawn(function()
                            if updatePlayerList then
                                updatePlayerList("")
                            end
                        end)
                    end
                end
                
                -- Set menu icon to be hidden since menu is open
                if game:GetService('CoreGui'):FindFirstChild('XmodzProjectMenu') then
                    local gui = game:GetService('CoreGui'):FindFirstChild('XmodzProjectMenu')
                    if gui:FindFirstChild('MenuIcon') then
                        gui.MenuIcon.Visible = false -- Hidden because menu is open
                    end
                end
            else
                -- Show error dialog for incorrect key
                local errorDialogGui = Instance.new('ScreenGui')
                errorDialogGui.Name = 'IncorrectKeyDialog'
                errorDialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                errorDialogGui.IgnoreGuiInset = true
                errorDialogGui.Parent = game:GetService('CoreGui')
                
                -- Background overlay
                local errorOverlay = Instance.new('Frame')
                errorOverlay.Name = 'Overlay'
                errorOverlay.Size = UDim2.new(1, 0, 1, 0)
                errorOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                errorOverlay.BackgroundTransparency = 0.5
                errorOverlay.BorderSizePixel = 0
                errorOverlay.Parent = errorDialogGui
                
                -- Error dialog frame
                local errorDialogFrame = Instance.new('Frame')
                errorDialogFrame.Name = 'ErrorDialogFrame'
                errorDialogFrame.Size = UDim2.new(0, 400, 0, 280)
                errorDialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                errorDialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                errorDialogFrame.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
                errorDialogFrame.BorderSizePixel = 0
                errorDialogFrame.Parent = errorOverlay
                
                local errorDialogCorner = Instance.new('UICorner')
                errorDialogCorner.CornerRadius = UDim.new(0, 12)
                errorDialogCorner.Parent = errorDialogFrame
                
                local errorDialogBorder = Instance.new('UIStroke')
                errorDialogBorder.Color = Color3.fromRGB(200, 50, 50)
                errorDialogBorder.Thickness = 2
                errorDialogBorder.Parent = errorDialogFrame
                
                -- Error icon (X)
            
                -- Error title
                local errorTitle = Instance.new('TextLabel')
                errorTitle.Name = 'ErrorTitle'
                errorTitle.Size = UDim2.new(1, -20, 0, 35)
                errorTitle.Position = UDim2.new(0, 10, 0, 70)
                errorTitle.BackgroundTransparency = 1
                errorTitle.Text = 'Incorrect Key'
                errorTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
                errorTitle.TextSize = 20
                errorTitle.Font = Enum.Font.Ubuntu
                errorTitle.TextXAlignment = Enum.TextXAlignment.Center
                errorTitle.Parent = errorDialogFrame
                
                -- Error message
                local errorMessageText = Instance.new('TextLabel')
                errorMessageText.Name = 'ErrorMessage'
                errorMessageText.Size = UDim2.new(1, -30, 0, 70)
                errorMessageText.Position = UDim2.new(0, 15, 0, 110)
                errorMessageText.BackgroundTransparency = 1
                errorMessageText.Text = 'The key you entered is invalid.\nPlease join our Discord server to get the correct key:'
                errorMessageText.TextColor3 = Color3.fromRGB(220, 220, 220)
                errorMessageText.TextSize = 13
                errorMessageText.Font = Enum.Font.Ubuntu
                errorMessageText.TextXAlignment = Enum.TextXAlignment.Center
                errorMessageText.TextWrapped = true
                errorMessageText.Parent = errorDialogFrame
                
                -- Discord link display
                local discordLinkBox = Instance.new('Frame')
                discordLinkBox.Name = 'DiscordLinkBox'
                discordLinkBox.Size = UDim2.new(1, -40, 0, 30)
                discordLinkBox.Position = UDim2.new(0, 20, 0, 185)
                discordLinkBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                discordLinkBox.BorderSizePixel = 0
                discordLinkBox.Parent = errorDialogFrame
                
                local discordLinkCorner = Instance.new('UICorner')
                discordLinkCorner.CornerRadius = UDim.new(0, 6)
                discordLinkCorner.Parent = discordLinkBox
                
                local discordLinkText = Instance.new('TextLabel')
                discordLinkText.Name = 'DiscordLink'
                discordLinkText.Size = UDim2.new(1, -10, 1, 0)
                discordLinkText.Position = UDim2.new(0, 5, 0, 0)
                discordLinkText.BackgroundTransparency = 1
                discordLinkText.Text = 'https://discord.gg/Szmt9zweGF'
                discordLinkText.TextColor3 = Color3.fromRGB(100, 150, 255)
                discordLinkText.TextSize = 12
                discordLinkText.Font = Enum.Font.Ubuntu
                discordLinkText.TextXAlignment = Enum.TextXAlignment.Center
                discordLinkText.Parent = discordLinkBox
                
                -- Button container
                local buttonContainer = Instance.new('Frame')
                buttonContainer.Name = 'ButtonContainer'
                buttonContainer.Size = UDim2.new(1, -40, 0, 35)
                buttonContainer.Position = UDim2.new(0, 20, 0, 230)
                buttonContainer.BackgroundTransparency = 1
                buttonContainer.Parent = errorDialogFrame
                
                local buttonLayout = Instance.new('UIListLayout')
                buttonLayout.FillDirection = Enum.FillDirection.Horizontal
                buttonLayout.Padding = UDim.new(0, 10)
                buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                buttonLayout.Parent = buttonContainer
                
                -- Copy Discord button
                local copyDiscordButton = Instance.new('TextButton')
                copyDiscordButton.Name = 'CopyDiscordButton'
                copyDiscordButton.Size = UDim2.new(0, 165, 1, 0)
                copyDiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Discord blurple
                copyDiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                copyDiscordButton.Text = 'Copy Discord Link'
                copyDiscordButton.TextSize = 14
                copyDiscordButton.Font = Enum.Font.Ubuntu
                copyDiscordButton.AutoButtonColor = false
                copyDiscordButton.Parent = buttonContainer
                
                local copyDiscordCorner = Instance.new('UICorner')
                copyDiscordCorner.CornerRadius = UDim.new(0, 6)
                copyDiscordCorner.Parent = copyDiscordButton
                
                -- Retry button
                local retryButton = Instance.new('TextButton')
                retryButton.Name = 'RetryButton'
                retryButton.Size = UDim2.new(0, 165, 1, 0)
                retryButton.BackgroundColor3 = Color3.fromRGB(53, 9, 211)
                retryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                retryButton.Text = 'Retry'
                retryButton.TextSize = 14
                retryButton.Font = Enum.Font.Ubuntu
                retryButton.AutoButtonColor = false
                retryButton.Parent = buttonContainer
                
                local retryCorner = Instance.new('UICorner')
                retryCorner.CornerRadius = UDim.new(0, 6)
                retryCorner.Parent = retryButton
                
                -- Copy Discord button functionality
                copyDiscordButton.MouseButton1Click:Connect(function()
                    -- Copy link to clipboard
                    if setclipboard then
                        setclipboard("https://discord.gg/Szmt9zweGF")
                        copyDiscordButton.Text = 'Copied!'
                        task.wait(1.5)
                        if copyDiscordButton then
                            copyDiscordButton.Text = 'Copy Discord Link'
                        end
                    end
                end)
                
                -- Retry button functionality
                retryButton.MouseButton1Click:Connect(function()
                    errorDialogGui:Destroy()
                    -- Reset the key input state
                    keyInput.Text = ''
                    keyInput.TextEditable = true
                    submitButton.Text = 'Submit'
                    submitButton.BackgroundColor3 = Color3.fromRGB(53, 9, 211)
                    errorMessage.Visible = false
                end)
                
                -- Button hover effects
                copyDiscordButton.MouseEnter:Connect(function()
                    TweenService:Create(copyDiscordButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(108, 121, 255)
                    }):Play()
                end)
                
                copyDiscordButton.MouseLeave:Connect(function()
                    TweenService:Create(copyDiscordButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(88, 101, 242)
                    }):Play()
                end)
                
                retryButton.MouseEnter:Connect(function()
                    TweenService:Create(retryButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(73, 29, 231)
                    }):Play()
                end)
                
                retryButton.MouseLeave:Connect(function()
                    TweenService:Create(retryButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(53, 9, 211)
                    }):Play()
                end)
                
                -- Log failed key attempt
                task.spawn(function()
                    local playerInfo = getPlayerInfo()
                    
                    local fields = {
                        {
                            name = "Display Name",
                            value = tostring(playerInfo.displayName),
                            inline = true
                        },
                        {
                            name = "Username", 
                            value = "@" .. tostring(playerInfo.username),
                            inline = true
                        },
                        {
                            name = "User ID",
                            value = tostring(playerInfo.userId),
                            inline = true
                        },
                        {
                            name = "Game",
                            value = tostring(playerInfo.placeName),
                            inline = false
                        },
                        {
                            name = "Wrong Key",
                            value = "`" .. tostring(enteredKey) .. "`",
                            inline = false
                        },
                        {
                            name = "Status",
                            value = "Invalid key attempt detected",
                            inline = false
                        }
                    }
                    
                    sendHttpLog(
                        FAILURE_LOG_URL,
                        "ACCESS DENIED",
                        "Failed authentication attempt detected",
                        fields,
                        "red"
                    )
                end)
                
                keyInput.Text = ''
            end
        end
        
        submitButton.MouseButton1Click:Connect(checkKey)
        keyInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                checkKey()
            end
        end)
        
        -- Button hover effects
        submitButton.MouseEnter:Connect(function()
            TweenService:Create(submitButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(73, 29, 231)
            }):Play()
        end)
        
        submitButton.MouseLeave:Connect(function()
            TweenService:Create(submitButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(53, 9, 211)
            }):Play()
        end)
        
        getKeyButton.MouseEnter:Connect(function()
            TweenService:Create(getKeyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(100, 180, 100)
            }):Play()
        end)
        
        getKeyButton.MouseLeave:Connect(function()
            TweenService:Create(getKeyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            }):Play()
        end)
    end

    -- Show key dialog on script start

    -- Global variables for GUI creation
    -- TOGGLE_KEY will be set from loaded keybinds later
    local MENU_TITLE = 'XmodzProject V4.2 [🍀PITY]'
    -- Check if device is mobile/touch
    local isMobile = not UserInputService.KeyboardEnabled or not UserInputService.MouseEnabled
    -- GUI Variables that need to be accessible globally
    local gui, mainFrame, menuIcon
    local updatePlayerList -- Function reference for player list updates

    -- AFK System Functions
    -- AFK functionality is now handled through the main menu only

    -- Function to create the main GUI (only called after successful key entry)
    function createMainGUI()
    -- XmodzProject Mod Menu

    -- Global variables for stats display
    local totalPlayersLabel, totalAdminsLabel

    -- CONFIGURATION

    -- Colors already defined above

    -- Open Discord invite when menu opens
    task.spawn(function()
        pcall(function()
            local HttpService = game:GetService("HttpService")
            request({
                Url = "http://127.0.0.1:6463/rpc?v=1",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Origin"] = "https://discord.com"
                },
                Body = HttpService:JSONEncode({
                    cmd = "INVITE_BROWSER",
                    args = {
                        code = "Szmt9zweGF"
                    },
                    nonce = HttpService:GenerateGUID(false)
                })
            })
        end)
    end)

    -- Create GUI

    local player = Players.LocalPlayer

    gui = Instance.new('ScreenGui')

    gui.Name = 'XmodzProjectMenu'

    gui.ResetOnSpawn = false

    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    gui.Parent = game:GetService('CoreGui')

    -- Create Menu Icon (always visible when menu is closed)
    menuIcon = Instance.new('ImageButton')
    menuIcon.Name = 'MenuIcon'
    menuIcon.Size = UDim2.new(0, 60, 0, 60)
    menuIcon.Position = UDim2.new(0, 20, 0, 20)
    menuIcon.BackgroundTransparency = 1 -- Fully transparent background
    menuIcon.BorderSizePixel = 0
    menuIcon.Image = 'rbxassetid://93130486024412'
    menuIcon.ScaleType = Enum.ScaleType.Fit
    menuIcon.AutoButtonColor = false
    menuIcon.Visible = false -- Will be set correctly after creation

    -- Make menu icon circular
    local iconCorner = Instance.new('UICorner')
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = menuIcon



    menuIcon.Parent = gui

    -- Menu Icon Dragging (Touch and Mouse Support)
    local iconDragging = false
    local iconHasDragged = false -- Track if actual dragging occurred
    local iconDragInput, iconDragStart, iconStartPos
    local DRAG_THRESHOLD = 5 -- Pixels to move before considering it a drag

    local function updateIconInput(input)
        local delta = input.Position - iconDragStart
        menuIcon.Position = UDim2.new(
            iconStartPos.X.Scale,
            iconStartPos.X.Offset + delta.X,
            iconStartPos.Y.Scale,
            iconStartPos.Y.Offset + delta.Y
        )
        
        -- Check if we've moved enough to consider this a drag
        if delta.Magnitude > DRAG_THRESHOLD then
            iconHasDragged = true
        end
    end

    menuIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = true
            iconHasDragged = false -- Reset drag flag
            iconDragStart = input.Position
            iconStartPos = menuIcon.Position

            -- Pulse animation when dragging starts
            TweenService:Create(menuIcon, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 65, 0, 65),
            }):Play()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    iconDragging = false
                    TweenService:Create(menuIcon, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, 60, 0, 60),
                    }):Play()
                    
                    -- Small delay to ensure drag state is properly set before click event
                    task.wait(0.1)
                    iconHasDragged = false
                end
            end)
        end
    end)

    menuIcon.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            iconDragInput = input
        end
    end)

    -- Menu Icon Hover Effects
    menuIcon.MouseEnter:Connect(function()
        TweenService:Create(iconBorder, TweenInfo.new(0.2), {
            Transparency = 0,
            Thickness = 3
        }):Play()
        TweenService:Create(menuIcon, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 65, 0, 65)
        }):Play()
    end)

    menuIcon.MouseLeave:Connect(function()
        if not iconDragging and not iconHasDragged then
            TweenService:Create(iconBorder, TweenInfo.new(0.2), {
                Transparency = 0.3,
                Thickness = 2
            }):Play()
            TweenService:Create(menuIcon, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 60, 0, 60)
            }):Play()
        end
    end)

    -- Check if device is mobile/touch
    local isMobile = not UserInputService.KeyboardEnabled or not UserInputService.MouseEnabled

    -- Main Frame with Enhanced Animations

    mainFrame = Instance.new('Frame')

    mainFrame.Name = 'MainFrame'

    -- Adjust menu size based on device
    if isMobile then
        mainFrame.Size = UDim2.new(0, 380, 0, 340) -- Optimized for mobile phones
    else
        mainFrame.Size = UDim2.new(0, 400, 0, 500) -- Original size for PC
    end

    mainFrame.Position = savedMenuPosition

    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

    mainFrame.BackgroundColor3 = BG_COLOR

    mainFrame.BackgroundTransparency = 0.1

    mainFrame.BorderSizePixel = 0

    mainFrame.ClipsDescendants = true

    mainFrame.Visible = false

    -- Modern Rounded Corners with Animated Border

    local corner = Instance.new('UICorner')

    corner.CornerRadius = UDim.new(0, 12)

    corner.Parent = mainFrame

    local border = Instance.new('UIStroke')

    border.Color = ACCENT_COLOR

    border.Thickness = 2

    border.Transparency = 0.5

    border.Parent = mainFrame

    -- Add subtle shadow effect
    local shadow = Instance.new('Frame')
    shadow.Name = 'Shadow'
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = mainFrame

    local shadowCorner = Instance.new('UICorner')
    shadowCorner.CornerRadius = UDim.new(0, 14)
    shadowCorner.Parent = shadow

    -- Header with Gradient and Animation

    local header = Instance.new('Frame')

    header.Name = 'Header'

    -- Adjust header height for mobile
    if isMobile then
        header.Size = UDim2.new(1, 0, 0, 60) -- Smaller header for mobile
    else
        header.Size = UDim2.new(1, 0, 0, 70) -- Original size for PC
    end

    header.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White background for image visibility

    header.BackgroundTransparency = 1 -- Make background transparent to show image

    header.BorderSizePixel = 0

    header.Parent = mainFrame

    -- Header background image
    local headerImage = Instance.new('ImageLabel')
    headerImage.Name = 'HeaderImage'
    headerImage.Size = UDim2.new(1, 0, 1, 0)
    headerImage.Position = UDim2.new(0, 0, 0, 0)
    headerImage.BackgroundTransparency = 1
    headerImage.Image = 'rbxassetid://99402296385516'
    headerImage.ScaleType = Enum.ScaleType.Stretch
    headerImage.ZIndex = 0
    headerImage.Parent = header

    local headerCorner = Instance.new('UICorner')

    headerCorner.CornerRadius = UDim.new(0, 12)

    headerCorner.Parent = header

    -- Apply corner to image as well
    local headerImageCorner = Instance.new('UICorner')
    headerImageCorner.CornerRadius = UDim.new(0, 12)
    headerImageCorner.Parent = headerImage

    -- Title with Text Glow

    local title = Instance.new('TextLabel')

    title.Name = 'Title'

    title.Size = UDim2.new(0.6, 0, 0.6, 0)

    title.Position = UDim2.new(0, 15, 0, 0)

    title.BackgroundTransparency = 1

    title.Text = MENU_TITLE

    title.TextColor3 = Color3.fromRGB(255, 255, 255)

    title.TextSize = 20

    title.Font = Enum.Font.Ubuntu

    title.TextXAlignment = Enum.TextXAlignment.Left

    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Black stroke for shadow effect

    title.TextStrokeTransparency = 0 -- Fully visible stroke for shadow

    title.Parent = header

    -- Add UIStroke for additional shadow depth
    local titleStroke = Instance.new('UIStroke')
    titleStroke.Color = Color3.fromRGB(0, 0, 0) -- Black shadow
    titleStroke.Thickness = 3 -- Shadow thickness
    titleStroke.Transparency = 0.5 -- Semi-transparent shadow
    titleStroke.Parent = title

    -- Logo with Custom Image

    local logo = Instance.new('ImageLabel')

    logo.Name = 'Logo'

    logo.Size = UDim2.new(0, 30, 0, 30)

    logo.Position = UDim2.new(1, -40, 0, 5)

    logo.BackgroundTransparency = 1

    logo.Image = 'rbxassetid://784337615567'

    logo.Parent = header

    -- Discord Text below title (clickable)

    local discordText = Instance.new('TextButton')

    discordText.Name = 'DiscordText'

    discordText.Size = UDim2.new(0.6, 0, 0.4, 0)

    discordText.Position = UDim2.new(0, 15, 0.6, 0)

    discordText.BackgroundTransparency = 1

    -- Check if player is on PC to show keybind info
    if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        discordText.Text = 'discord : https://discord.gg/Szmt9zweGF (click to copy)'
        discordText.Size = UDim2.new(1, -50, 0.4, 0) -- Make wider to fit keybind text
        discordText.TextSize = isMobile and 10 or 12 -- Smaller text on mobile
    else
        discordText.Text = 'discord : https://discord.gg/Szmt9zweGF (click to copy)'
        discordText.Size = UDim2.new(0.6, 0, 0.4, 0) -- Keep original size for mobile/console
        discordText.TextSize = isMobile and 10 or 12 -- Smaller text on mobile
    end

    discordText.TextColor3 = Color3.fromRGB(180, 180, 180)

    discordText.Font = Enum.Font.Ubuntu

    discordText.TextXAlignment = Enum.TextXAlignment.Left

    discordText.Parent = header

    -- Discord link click functionality
    discordText.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://discord.gg/Szmt9zweGF")
            -- Show notification that link was copied
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title = 'Discord Link',
                Text = 'Link copied to clipboard!',
                Duration = 2,
            })
        end
    end)

    -- Discord text hover effect
    discordText.MouseEnter:Connect(function()
        TweenService:Create(discordText, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(53, 9, 211)
        }):Play()
    end)

    discordText.MouseLeave:Connect(function()
        TweenService:Create(discordText, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(180, 180, 180)
        }):Play()
    end)

    -- Close Button with Hover Animation

    local closeButton = Instance.new('ImageButton')

    closeButton.Name = 'CloseButton'

    closeButton.Size = UDim2.new(0, 30, 0, 30)

    closeButton.Position = UDim2.new(1, -35, 0.5, -15)

    closeButton.AnchorPoint = Vector2.new(0.5, 0.5)

    closeButton.BackgroundTransparency = 1 -- Make background transparent to show icon

    closeButton.Image = 'rbxassetid://14895360837'
    
    closeButton.ScaleType = Enum.ScaleType.Fit

    closeButton.AutoButtonColor = false

    -- Close Button Hover Effects (size only, no background color)

    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 35, 0, 35),
        }):Play()
    end)

    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 30, 0, 30),
        }):Play()
    end)

    closeButton.Parent = header

    -- Category Tabs System
    local tabContainer = Instance.new('Frame')
    tabContainer.Name = 'TabContainer'
    tabContainer.Size = UDim2.new(1, -20, 0, 40)
    tabContainer.Position = UDim2.new(0, 10, 0, isMobile and 70 or 80)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabLayout = Instance.new('UIListLayout')
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContainer

    -- Tab Variables
    local currentTab = "Main"
    local contentPages = {}

    -- Create Tab Function
    local function createTab(name, isDefault)
        local tab = Instance.new('TextButton')
        tab.Name = name .. 'Tab'
        tab.Size = UDim2.new(0, 80, 1, 0)
        tab.BackgroundColor3 = isDefault and ACCENT_COLOR or Color3.fromRGB(60, 60, 70)
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.Text = name
        tab.TextSize = isMobile and 11 or 13
        tab.Font = Enum.Font.Ubuntu
        tab.AutoButtonColor = false
        tab.Parent = tabContainer
        
        local tabCorner = Instance.new('UICorner')
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tab
        
        return tab
    end

    -- Create Tabs
    local mainTab = createTab("Main", true)
    mainTab.LayoutOrder = 1
    local miscTab = createTab("Misc", false)
    miscTab.LayoutOrder = 2
    local trollTab = createTab("Troll", false)
    trollTab.LayoutOrder = 3
    local settingsTab = createTab("Settings", false)
    settingsTab.LayoutOrder = 4

    -- Tab Content Container
    local contentContainer = Instance.new('Frame')
    contentContainer.Name = 'ContentContainer'
    contentContainer.Size = UDim2.new(1, -20, 1, -130)
    contentContainer.Position = UDim2.new(0, 10, 0, isMobile and 120 or 130)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame

    -- Tab Switching Function with Optimized Fade Animations
    local function switchTab(tabName)
        if not tabName then return end
        
        currentTab = tabName
        
        -- Update tab appearances with smooth transition
        local tabs = {mainTab, miscTab, trollTab, settingsTab}
        for _, tab in pairs(tabs) do
            if tab and tab.Text == tabName then
                TweenService:Create(tab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = ACCENT_COLOR
                }):Play()
            elseif tab then
                TweenService:Create(tab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                }):Play()
            end
        end
        
        -- Simple and fast page switching without complex animations
        if contentPages then
            for _, page in pairs(contentPages) do
                if page then
                    if page.Name == tabName .. "Page" then
                        -- Show selected page with simple fade-in
                        page.Visible = true
                        page.BackgroundTransparency = 1
                        TweenService:Create(page, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 1
                        }):Play()
                    else
                        -- Hide other pages immediately for performance
                        page.Visible = false
                    end
                end
            end
            
            -- Fallback for direct access
            if contentPages[tabName] then
                contentPages[tabName].Visible = true
            end
        end
    end
    getgenv().switchTab = switchTab

    -- Search Box with Cool Animation

    local searchBox = Instance.new('TextBox')

    searchBox.Name = 'SearchBox'

    searchBox.Size = UDim2.new(1, -20, 0, isMobile and 25 or 30)

    -- Adjust position to be in the Main tab
    searchBox.Position = UDim2.new(0, 10, 0, 5)

    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)

    searchBox.PlaceholderText = 'Search players...'

    searchBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)

    searchBox.Text = ''

    searchBox.TextSize = isMobile and 12 or 14

    searchBox.Font = Enum.Font.Ubuntu

    searchBox.ClearTextOnFocus = false

    local searchCorner = Instance.new('UICorner')

    searchCorner.CornerRadius = UDim.new(0, 8)

    searchCorner.Parent = searchBox

    local searchPadding = Instance.new('UIPadding')

    searchPadding.PaddingLeft = UDim.new(0, 15)

    searchPadding.PaddingRight = UDim.new(0, 15)

    searchPadding.Parent = searchBox

    -- Create Content Pages

    -- Main Page (Players List)
    local mainPage = Instance.new('Frame')
    mainPage.Name = 'MainPage'
    mainPage.Size = UDim2.new(1, 0, 1, 0)
    mainPage.BackgroundTransparency = 1
    mainPage.Parent = contentContainer

    searchBox.Parent = mainPage

    -- Player Stats Display (Total Players and Admins)
    local statsContainer = Instance.new('Frame')
    statsContainer.Name = 'StatsContainer'
    statsContainer.Size = UDim2.new(1, -20, 0, 20)
    statsContainer.Position = UDim2.new(0, 10, 0, isMobile and 30 or 35)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = mainPage

    totalPlayersLabel = Instance.new('TextLabel')
    totalPlayersLabel.Name = 'TotalPlayersLabel'
    totalPlayersLabel.Size = UDim2.new(0.5, -5, 1, 0)
    totalPlayersLabel.Position = UDim2.new(0, 0, 0, 0)
    totalPlayersLabel.BackgroundTransparency = 1
    totalPlayersLabel.Text = 'Players: 0'
    totalPlayersLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    totalPlayersLabel.TextSize = isMobile and 11 or 12
    totalPlayersLabel.Font = Enum.Font.Ubuntu
    totalPlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
    totalPlayersLabel.Parent = statsContainer

    totalAdminsLabel = Instance.new('TextLabel')
    totalAdminsLabel.Name = 'TotalAdminsLabel'
    totalAdminsLabel.Size = UDim2.new(0.5, -5, 1, 0)
    totalAdminsLabel.Position = UDim2.new(0.5, 5, 0, 0)
    totalAdminsLabel.BackgroundTransparency = 1
    totalAdminsLabel.Text = 'Admins: 0'
    totalAdminsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    totalAdminsLabel.TextSize = isMobile and 11 or 12
    totalAdminsLabel.Font = Enum.Font.Ubuntu
    totalAdminsLabel.TextXAlignment = Enum.TextXAlignment.Right
    totalAdminsLabel.Parent = statsContainer

    -- Function Buttons Container (in Main page)

    local buttonContainer = Instance.new('Frame')

    buttonContainer.Name = 'ButtonContainer'

    buttonContainer.Size = UDim2.new(1, -20, 0, isMobile and 25 or 30)

    -- Position below stats container
    buttonContainer.Position = UDim2.new(0, 10, 0, isMobile and 55 or 60)

    buttonContainer.BackgroundTransparency = 1

    buttonContainer.Parent = mainPage

    local buttonLayout = Instance.new('UIListLayout')

    buttonLayout.FillDirection = Enum.FillDirection.Horizontal

    buttonLayout.Padding = UDim.new(0, 5)

    buttonLayout.Parent = buttonContainer

    -- Refresh Button with Animation

    local refreshButton = Instance.new('TextButton')

    refreshButton.Name = 'RefreshButton'

    refreshButton.Size = UDim2.new(0.33, -3, 1, 0)

    refreshButton.BackgroundColor3 = ACCENT_COLOR

    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    refreshButton.Text = 'Refresh'

    refreshButton.TextSize = isMobile and 12 or 14

    refreshButton.Font = Enum.Font.Ubuntu

    refreshButton.AutoButtonColor = false

    local refreshCorner = Instance.new('UICorner')

    refreshCorner.CornerRadius = UDim.new(0, 6)

    refreshCorner.Parent = refreshButton

    refreshButton.MouseEnter:Connect(function()
        TweenService:Create(refreshButton, TweenInfo.new(0.2), {

            BackgroundColor3 = Color3.fromRGB(73, 29, 231),

            Size = UDim2.new(0.33, -1, 1, 0),
        }):Play()
    end)

    refreshButton.MouseLeave:Connect(function()
        TweenService:Create(refreshButton, TweenInfo.new(0.2), {

            BackgroundColor3 = ACCENT_COLOR,

            Size = UDim2.new(0.33, -3, 1, 0),
        }):Play()
    end)

    refreshButton.Parent = buttonContainer

    -- AFK Button with Animation (between refresh and fly)

    local afkButton = Instance.new('TextButton')

    afkButton.Name = 'AFKButton'

    afkButton.Size = UDim2.new(0.33, -3, 1, 0)

    afkButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- Red when OFF

    afkButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    afkButton.Text = 'AFK: OFF'

    afkButton.TextSize = isMobile and 12 or 14

    afkButton.Font = Enum.Font.Ubuntu

    afkButton.AutoButtonColor = false

    local afkCorner = Instance.new('UICorner')

    afkCorner.CornerRadius = UDim.new(0, 6)

    afkCorner.Parent = afkButton

    afkButton.MouseEnter:Connect(function()
        if afkButton and afkButton.Parent then
            local hoverColor = isAFK and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(220, 80, 80)
            TweenService:Create(afkButton, TweenInfo.new(0.2), {
                BackgroundColor3 = hoverColor,
                Size = UDim2.new(0.33, -1, 1, 0),
            }):Play()
        end
    end)

    afkButton.MouseLeave:Connect(function()
        if afkButton and afkButton.Parent then
            local normalColor = isAFK and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
            TweenService:Create(afkButton, TweenInfo.new(0.2), {
                BackgroundColor3 = normalColor,
                Size = UDim2.new(0.33, -3, 1, 0),
            }):Play()
        end
    end)

    -- AFK Button Click Function
    local function toggleAFK()
        isAFK = not isAFK
        
        if isAFK then
            if afkButton and afkButton.Parent then
                afkButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60) -- Green when ON
                afkButton.Text = 'AFK: ON'
            end
            
            -- Send true to server when enabling AFK
            local args = {true}
            spawn(function()
                local success, errorMessage = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("AFK THINGY"):WaitForChild("AFKEvent"):FireServer(unpack(args))
                end)
                
                if not success then
                    warn("Failed to send AFK event: " .. tostring(errorMessage))
                end
            end)
        else
            if afkButton and afkButton.Parent then
                afkButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- Red when OFF
                afkButton.Text = 'AFK: OFF'
            end
            
            -- Send false to server when disabling AFK
            local args = {false}
            spawn(function()
                local success, errorMessage = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("AFK THINGY"):WaitForChild("AFKEvent"):FireServer(unpack(args))
                end)
                
                if not success then
                    warn("Failed to send AFK event: " .. tostring(errorMessage))
                end
            end)
        end
    end

    afkButton.MouseButton1Click:Connect(toggleAFK)

    afkButton.Parent = buttonContainer

    -- Fly Button with Animation (moved to Main page for easy access)

    local flyButton = Instance.new('TextButton')

    flyButton.Name = 'FlyButton'

    flyButton.Size = UDim2.new(0.33, -3, 1, 0)

    flyButton.BackgroundColor3 = Color3.fromRGB(80, 180, 120)

    flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    flyButton.Text = 'Fly: OFF'

    flyButton.TextSize = isMobile and 12 or 14

    flyButton.Font = Enum.Font.Ubuntu

    flyButton.AutoButtonColor = false

    local flyCorner = Instance.new('UICorner')

    flyCorner.CornerRadius = UDim.new(0, 6)

    flyCorner.Parent = flyButton

    flyButton.MouseEnter:Connect(function()
        TweenService:Create(flyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(100, 200, 140),
            Size = UDim2.new(0.33, -1, 1, 0),
        }):Play()
    end)

    flyButton.MouseLeave:Connect(function()
        TweenService:Create(flyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 180, 120),
            Size = UDim2.new(0.33, -3, 1, 0),
        }):Play()
    end)

    flyButton.Parent = buttonContainer

    -- Player List Container (now in Main page)

    local playerListContainer = Instance.new('Frame')

    playerListContainer.Name = 'PlayerListContainer'

    -- Adjust for new layout without speed controls
    if isMobile then
        playerListContainer.Size = UDim2.new(1, -20, 1, -100) -- Adjusted size for more spacing
        playerListContainer.Position = UDim2.new(0, 10, 0, 95) -- More spacing from categories
    else
        playerListContainer.Size = UDim2.new(1, -20, 1, -105) -- Adjusted size for more spacing
        playerListContainer.Position = UDim2.new(0, 10, 0, 100) -- More spacing from categories
    end

    playerListContainer.BackgroundTransparency = 1

    playerListContainer.Parent = mainPage

    -- Mobile Fly Controls (only visible when flying on mobile)
    local mobileControls = Instance.new('Frame')
    mobileControls.Name = 'MobileFlyControls'
    mobileControls.Size = UDim2.new(0, 120, 0, 200)
    mobileControls.Position = UDim2.new(1, -130, 1, -210)
    mobileControls.BackgroundTransparency = 1
    mobileControls.Visible = false
    mobileControls.Parent = screenGui

    -- Up button
    local upButton = Instance.new('TextButton')
    upButton.Name = 'FlyUpButton'
    upButton.Size = UDim2.new(1, 0, 0.4, -5)
    upButton.Position = UDim2.new(0, 0, 0, 0)
    upButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    upButton.Text = ' UP'
    upButton.TextSize = 14
    upButton.Font = Enum.Font.Ubuntu
    upButton.BorderSizePixel = 0
    local upCorner = Instance.new('UICorner')
    upCorner.CornerRadius = UDim.new(0, 6)
    upCorner.Parent = upButton
    upButton.Parent = mobileControls

    -- Down button
    local downButton = Instance.new('TextButton')
    downButton.Name = 'FlyDownButton'
    downButton.Size = UDim2.new(1, 0, 0.4, -5)
    downButton.Position = UDim2.new(0, 0, 0.6, 5)
    downButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    downButton.Text = ' DOWN'
    downButton.TextSize = 14
    downButton.Font = Enum.Font.Ubuntu
    downButton.BorderSizePixel = 0
    local downCorner = Instance.new('UICorner')
    downCorner.CornerRadius = UDim.new(0, 6)
    downCorner.Parent = downButton
    downButton.Parent = mobileControls

    -- Mobile fly control variables
    local mobileUpPressed = false
    local mobileDownPressed = false

    -- Touch events for vertical mobile controls only
    upButton.TouchTap:Connect(function() end) -- Prevent default behavior
    upButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileUpPressed = true
            upButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
    upButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileUpPressed = false
            upButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)

    downButton.TouchTap:Connect(function() end) -- Prevent default behavior
    downButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDownPressed = true
            downButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
    downButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDownPressed = false
            downButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)

    -- Scroll Frame with Smooth Scrolling

    local scrollFrame = Instance.new('ScrollingFrame')

    scrollFrame.Name = 'ScrollFrame'

    scrollFrame.Size = UDim2.new(1, 0, 1, 0)

    scrollFrame.BackgroundTransparency = 1

    scrollFrame.ScrollBarThickness = 5

    scrollFrame.ScrollBarImageColor3 = ACCENT_COLOR

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    scrollFrame.Parent = playerListContainer

    local listLayout = Instance.new('UIListLayout')

    listLayout.Padding = UDim.new(0, 8)

    listLayout.Parent = scrollFrame

    -- Store the main page in content pages
    contentPages["Main"] = mainPage

    -- Misc Page (ESP and other misc features)
    local miscPage = Instance.new('ScrollingFrame')
    miscPage.Name = 'MiscPage'
    miscPage.Size = UDim2.new(1, 0, 1, 0)
    miscPage.BackgroundTransparency = 1
    miscPage.Visible = false
    miscPage.ScrollBarThickness = 4
    miscPage.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    miscPage.CanvasSize = UDim2.new(0, 0, 0, 0) -- Start with no canvas size
    miscPage.Parent = contentContainer

    -- Add UIListLayout to misc page for automatic sizing
    local miscLayout = Instance.new('UIListLayout')
    miscLayout.Padding = UDim.new(0, 10)
    miscLayout.SortOrder = Enum.SortOrder.LayoutOrder
    miscLayout.Parent = miscPage

    -- Update canvas size when content changes
    miscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = miscLayout.AbsoluteContentSize.Y
        if contentHeight > 0 then
            miscPage.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
        end
    end)

    -- ESP Button in Misc page
    local espButton = Instance.new('TextButton')
    espButton.Name = 'ESPButton'
    espButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    espButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black color
    espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espButton.Text = 'ESP: OFF'
    espButton.TextSize = isMobile and 12 or 14
    espButton.Font = Enum.Font.Ubuntu
    espButton.LayoutOrder = 1
    espButton.AutoButtonColor = false
    espButton.Parent = miscPage

    local espCorner = Instance.new('UICorner')
    espCorner.CornerRadius = UDim.new(0, 6)
    espCorner.Parent = espButton

    espButton.MouseEnter:Connect(function()
        TweenService:Create(espButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray hover
        }):Play()
    end)

    espButton.MouseLeave:Connect(function()
        local targetColor = espEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        TweenService:Create(espButton, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor -- Return to appropriate state color
        }):Play()
    end)

    -- ESP Button Click Handler
    espButton.MouseButton1Click:Connect(function()
        if espEnabled then
            disableESP()
            espButton.Text = 'ESP: OFF'
            espButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black when OFF
            settings.espEnabled = false
            saveSettings()
        else
            enableESP()
            espButton.Text = 'ESP: ON'
            espButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray when ON
            settings.espEnabled = true
            saveSettings()
        end
    end)

    -- ESP Admins Button in Misc page
    local espAdminsEnabled = false
    local adminTags = {}
    local adminESPConnection = nil
    local adminESPConnections = {} -- Store character connections for cleanup

    local espAdminsButton = Instance.new('TextButton')
    espAdminsButton.Name = 'ESPAdminsButton'
    espAdminsButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    espAdminsButton.Position = UDim2.new(0, 10, 0, isMobile and 50 or 55)
    espAdminsButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black color
    espAdminsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espAdminsButton.Text = 'ESP Admins: OFF'
    espAdminsButton.TextSize = isMobile and 12 or 14
    espAdminsButton.Font = Enum.Font.Ubuntu
    espAdminsButton.AutoButtonColor = false
    espAdminsButton.Parent = miscPage

    local espAdminsCorner = Instance.new('UICorner')
    espAdminsCorner.CornerRadius = UDim.new(0, 6)
    espAdminsCorner.Parent = espAdminsButton

    espAdminsButton.MouseEnter:Connect(function()
        TweenService:Create(espAdminsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray hover
        }):Play()
    end)

    espAdminsButton.MouseLeave:Connect(function()
        local targetColor = espAdminsEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        TweenService:Create(espAdminsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor -- Return to appropriate state color
        }):Play()
    end)

    -- ESP Admins Functions
    local function createAdminTag(player)
        -- Clean up any existing tag for this player first
        if adminTags[player] and adminTags[player].Parent then
            adminTags[player]:Destroy()
            adminTags[player] = nil
        end
        
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild('HumanoidRootPart', 5) -- 5 second timeout
        
        -- If HumanoidRootPart doesn't exist within 5 seconds, return early
        if not humanoidRootPart then
            warn("HumanoidRootPart not found for admin player: " .. player.Name)
            return
        end

        -- Get player's role in group 35822612
        local success, roleInGroup = pcall(function()
            return player:GetRoleInGroup(35822612)
        end)
        
        if success and roleInGroup and roleInGroup ~= "Guest" then
            -- Check if role contains required words (case insensitive) or is one of the excluded roles
            local roleLower = roleInGroup:lower()
            
            -- List of roles that should NOT be marked as admin
            local excludedRoles = {
                "member", "booster", "top donators", "graphic designer",
                "content creator", "vip", "streamer", "modeler",
                "elite donor", "viber"
            }
            
            -- Check if player has an excluded role
            local isExcluded = false
            for _, excludedRole in ipairs(excludedRoles) do
                if string.find(roleLower, excludedRole) then
                    isExcluded = true
                    break
                end
            end
            
            -- Only create tag if role is NOT excluded (meaning it's an admin role)
            local hasRequiredRole = not isExcluded and roleInGroup ~= "Guest"
            
            if hasRequiredRole then
                local billboard = Instance.new('BillboardGui')
                billboard.Name = 'AdminESP'
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.Adornee = humanoidRootPart
                billboard.LightInfluence = 1
                billboard.MaxDistance = 1000
                billboard.Parent = character

                -- Only show role, bigger text
                local roleLabel = Instance.new('TextLabel')
                roleLabel.Name = 'AdminRoleLabel'
                roleLabel.Text = '[' .. roleInGroup .. ']'
                roleLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red color for admin roles
                roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                roleLabel.TextStrokeTransparency = 0.3
                roleLabel.Size = UDim2.new(1, 0, 1, 0) -- Full size for bigger text
                roleLabel.Position = UDim2.new(0, 0, 0, 0)
                roleLabel.BackgroundTransparency = 1
                roleLabel.Font = Enum.Font.Ubuntu
                roleLabel.TextSize = 20 -- Bigger text
                roleLabel.Parent = billboard

                adminTags[player] = billboard
                
                -- Clean up when character is removed
                local cleanupConnection = player.CharacterRemoving:Connect(function()
                    if adminTags[player] and adminTags[player].Parent then
                        adminTags[player]:Destroy()
                        adminTags[player] = nil
                    end
                end)
            end
        end
    end

    local function enableAdminESP()
        if espAdminsEnabled then
            return
        end

        -- Clear any existing admin tags first
        for player, billboard in pairs(adminTags) do
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
        end
        adminTags = {}
        
        -- Clear existing connections
        for player, playerConnections in pairs(adminESPConnections) do
            for _, connection in ipairs(playerConnections) do
                connection:Disconnect()
            end
        end
        adminESPConnections = {}

        -- Create admin tags for all current players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                -- Connect CharacterAdded for existing players to handle respawns
                local characterConnection = player.CharacterAdded:Connect(function()
                    if espAdminsEnabled then
                        task.spawn(function()
                            createAdminTag(player)
                        end)
                    end
                end)
                
                adminESPConnections[player] = adminESPConnections[player] or {}
                table.insert(adminESPConnections[player], characterConnection)
                
                -- Create tag if they already have a character
                if player.Character then
                    task.spawn(function()
                        createAdminTag(player)
                    end)
                end
            end
        end

        -- Connect events for new players
        adminESPConnection = Players.PlayerAdded:Connect(function(player)
            local newPlayerConnection = player.CharacterAdded:Connect(function()
                if espAdminsEnabled then
                    task.spawn(function()
                        createAdminTag(player)
                    end)
                end
            end)
            
            adminESPConnections[player] = adminESPConnections[player] or {}
            table.insert(adminESPConnections[player], newPlayerConnection)
            
            if player.Character then
                task.spawn(function()
                    createAdminTag(player)
                end)
            end
        end)

        espAdminsEnabled = true
        espAdminsButton.Text = 'ESP Admins: ON'
        espAdminsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray when ON
    end

    local function disableAdminESP()
        if not espAdminsEnabled then
            return
        end

        -- Remove all admin tags
        for player, billboard in pairs(adminTags) do
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
        end
        adminTags = {}

        -- Disconnect all character connections
        for player, playerConnections in pairs(adminESPConnections) do
            for _, connection in ipairs(playerConnections) do
                connection:Disconnect()
            end
        end
        adminESPConnections = {}

        -- Disconnect main PlayerAdded connection
        if adminESPConnection then
            adminESPConnection:Disconnect()
            adminESPConnection = nil
        end

        espAdminsEnabled = false
        espAdminsButton.Text = 'ESP Admins: OFF'
        espAdminsButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black when OFF
    end

    -- ESP Admins Button Click Handler
    espAdminsButton.MouseButton1Click:Connect(function()
        if espAdminsEnabled then
            disableAdminESP()
            espAdminsButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black when OFF
            settings.espAdminsEnabled = false
            saveSettings()
        else
            enableAdminESP()
            espAdminsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray when ON
            settings.espAdminsEnabled = true
            saveSettings()
        end
    end)

    -- Clean up admin tags when players leave
    Players.PlayerRemoving:Connect(function(player)
        if adminTags[player] then
            if adminTags[player].Parent then
                adminTags[player]:Destroy()
            end
            adminTags[player] = nil
        end
        
        -- Clean up connections for this player
        if adminESPConnections[player] then
            for _, connection in ipairs(adminESPConnections[player]) do
                connection:Disconnect()
            end
            adminESPConnections[player] = nil
        end
    end)

    -- Admin Alert Button in Misc page
    local adminAlertEnabled = true
    local adminAlertButton = Instance.new('TextButton')
    adminAlertButton.Name = 'AdminAlertButton'
    adminAlertButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    adminAlertButton.Position = UDim2.new(0, 10, 0, isMobile and 100 or 110)
    adminAlertButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray color (ON by default)
    adminAlertButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    adminAlertButton.Text = 'Admin Alert: ON'
    adminAlertButton.TextSize = isMobile and 12 or 14
    adminAlertButton.Font = Enum.Font.Ubuntu
    adminAlertButton.AutoButtonColor = false

    local adminAlertCorner = Instance.new('UICorner')
    adminAlertCorner.CornerRadius = UDim.new(0, 6)
    adminAlertCorner.Parent = adminAlertButton

    adminAlertButton.MouseEnter:Connect(function()
        TweenService:Create(adminAlertButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray hover
        }):Play()
    end)

    adminAlertButton.MouseLeave:Connect(function()
        local targetColor = adminAlertEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        TweenService:Create(adminAlertButton, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor -- Return to appropriate state color
        }):Play()
    end)

    adminAlertButton.Parent = miscPage

    -- Function to create admin join notification
    local function createAdminNotification(player, role)
        local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        
        -- Play admin join sound with improved cleanup
        pcall(function()
            local adminJoinSound = Instance.new("Sound")
            adminJoinSound.SoundId = "rbxassetid://6753645454"
            adminJoinSound.Volume = 0.7
            adminJoinSound.Parent = SoundService
            
            -- Auto-cleanup on completion
            local cleanupConnection
            cleanupConnection = adminJoinSound.Ended:Connect(function()
                if cleanupConnection then
                    cleanupConnection:Disconnect()
                    cleanupConnection = nil
                end
                if adminJoinSound.Parent then
                    adminJoinSound:Destroy()
                end
            end)
            
            adminJoinSound:Play()
            
            -- Backup cleanup with shorter timeout
            task.spawn(function()
                task.wait(5) -- Reduced from 10 to 5 seconds
                if adminJoinSound.Parent then
                    if cleanupConnection then
                        cleanupConnection:Disconnect()
                        cleanupConnection = nil
                    end
                    adminJoinSound:Destroy()
                end
            end)
        end)
        
        -- Create notification GUI
        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "AdminJoinNotification"
        notificationGui.ResetOnSpawn = false
        notificationGui.Parent = PlayerGui
        
        -- Create notification frame
        local notificationFrame = Instance.new("Frame")
        notificationFrame.Size = UDim2.new(0, 300, 0, 80)
        notificationFrame.Position = UDim2.new(1, 0, 0, 20) -- Start off-screen
        notificationFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        notificationFrame.BorderSizePixel = 0
        notificationFrame.Parent = notificationGui
        
        -- Corner radius
        local notificationCorner = Instance.new("UICorner")
        notificationCorner.CornerRadius = UDim.new(0, 8)
        notificationCorner.Parent = notificationFrame
        
        -- Player avatar
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 50, 0, 50)
        avatar.Position = UDim2.new(0, 15, 0.5, -25)
        avatar.BackgroundTransparency = 1 -- Make background transparent
        avatar.BorderSizePixel = 0
        avatar.Image = Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
        avatar.Parent = notificationFrame
        
        -- Avatar corner
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatar
        
        -- Admin text
        local adminText = Instance.new("TextLabel")
        adminText.Size = UDim2.new(0, 220, 0, 25)
        adminText.Position = UDim2.new(0, 75, 0, 10)
        adminText.BackgroundTransparency = 1
        adminText.Text = "An admin has joined"
        adminText.TextColor3 = Color3.fromRGB(255, 100, 100)
        adminText.TextSize = 16
        adminText.Font = Enum.Font.GothamBold
        adminText.TextXAlignment = Enum.TextXAlignment.Left
        adminText.Parent = notificationFrame
        
        -- Player name and role
        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.new(0, 220, 0, 20)
        nameText.Position = UDim2.new(0, 75, 0, 35)
        nameText.BackgroundTransparency = 1
        nameText.Text = player.DisplayName .. " [" .. role .. "]"
        nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameText.TextSize = 14
        nameText.Font = Enum.Font.Ubuntu
        nameText.TextXAlignment = Enum.TextXAlignment.Left
        nameText.Parent = notificationFrame
        
        -- Slide in animation
        TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -320, 0, 20)
        }):Play()
        
        -- Auto-hide after 5 seconds
        task.wait(5)
        
        -- Slide out animation
        local slideOut = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 20)
        })
        slideOut:Play()
        
        slideOut.Completed:Connect(function()
            notificationGui:Destroy()
        end)
    end

    -- Admin Alert functionality
    local adminAlertConnection
    local function enableAdminAlert()
        -- Don't return early if already enabled - ensure connection is set up
        if adminAlertConnection then
            -- Disconnect existing connection if any
            adminAlertConnection:Disconnect()
        end
        
        adminAlertConnection = Players.PlayerAdded:Connect(function(player)
            -- Check if player has admin role
            task.spawn(function()
                local success, roleInGroup = pcall(function()
                    return player:GetRoleInGroup(35822612)
                end)
                
                if success and roleInGroup and roleInGroup ~= "Guest" then
                    -- Use EXCLUSION LIST approach (same as ESP Admins and main tab)
                    local roleLower = roleInGroup:lower()
                    
                    -- List of roles that should NOT be marked as admin
                    local excludedRoles = {
                        "member", "booster", "top donators", "graphic designer",
                        "content creator", "vip", "streamer", "modeler",
                        "elite donor", "viber"
                    }
                    
                    -- Check if player has an excluded role
                    local isExcluded = false
                    for _, excludedRole in ipairs(excludedRoles) do
                        if string.find(roleLower, excludedRole) then
                            isExcluded = true
                            break
                        end
                    end
                    
                    -- Mark as admin if NOT excluded
                    local hasRequiredRole = not isExcluded
                    
                    if hasRequiredRole then
                        -- Show notification
                        spawn(function()
                            createAdminNotification(player, roleInGroup)
                        end)
                    end
                end
            end)
        end)
        
        adminAlertEnabled = true
        adminAlertButton.Text = 'Admin Alert: ON'
        adminAlertButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray when ON
    end

    local function disableAdminAlert()
        if not adminAlertEnabled then
            return
        end
        
        if adminAlertConnection then
            adminAlertConnection:Disconnect()
            adminAlertConnection = nil
        end
        
        adminAlertEnabled = false
        adminAlertButton.Text = 'Admin Alert: OFF'
        adminAlertButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black when OFF
    end

    -- Admin Alert Button Click Handler
    adminAlertButton.MouseButton1Click:Connect(function()
        if adminAlertEnabled then
            disableAdminAlert()
            adminAlertButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black when OFF
            settings.adminAlertEnabled = false
            saveSettings()
        else
            enableAdminAlert()
            adminAlertButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray when ON
            settings.adminAlertEnabled = true
            saveSettings()
        end
    end)

    -- Auto-enable admin alert based on saved settings
    if settings.adminAlertEnabled then
        enableAdminAlert()
    end

    -- Country ESP Button in Misc page
    local countryESPEnabled = false
    local countryESPConnection = nil
    local countryESPConnections = {}

    local countryESPButton = Instance.new('TextButton')
    countryESPButton.Name = 'CountryESPButton'
    countryESPButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    countryESPButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    countryESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    countryESPButton.Text = 'ESP Country: OFF'
    countryESPButton.TextSize = isMobile and 12 or 14
    countryESPButton.Font = Enum.Font.Ubuntu
    countryESPButton.AutoButtonColor = false
    countryESPButton.Parent = miscPage

    local countryESPCorner = Instance.new('UICorner')
    countryESPCorner.CornerRadius = UDim.new(0, 6)
    countryESPCorner.Parent = countryESPButton

    countryESPButton.MouseEnter:Connect(function()
        TweenService:Create(countryESPButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)

    countryESPButton.MouseLeave:Connect(function()
        local targetColor = countryESPEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        TweenService:Create(countryESPButton, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor
        }):Play()
    end)

    -- Country ESP Functions
    -- Function to deeply clone a BillboardGui with ALL properties
    local function deepCloneBillboard(sourceBillboard)
        if not sourceBillboard then return nil end
        
        -- Create a deep copy using Clone() which copies ALL properties and children
        local newBillboard = sourceBillboard:Clone()
        
        -- Ensure it's a BillboardGui
        if not newBillboard:IsA("BillboardGui") then
            newBillboard:Destroy()
            return nil
        end
        
        -- Reset any properties that might cause issues
        newBillboard.Parent = nil
        newBillboard.Adornee = nil
        
        -- Make sure Size and Offset are proper
        if newBillboard.Size == UDim2.new(0, 0, 0, 0) then
            newBillboard.Size = UDim2.new(0, 150, 0, 40)
        end
        
        if newBillboard.StudsOffset == Vector3.new(0, 0, 0) then
            newBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
        end
        
        -- Make sure it stays on top
        newBillboard.AlwaysOnTop = true
        
        -- Ensure we have a TextLabel
        local textLabel = newBillboard:FindFirstChild("TextLabel")
        if not textLabel then
            -- Create one if it doesn't exist
            textLabel = Instance.new("TextLabel")
            textLabel.Name = "TextLabel"
            textLabel.Parent = newBillboard
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextScaled = true
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        end
        
        return newBillboard
    end

    -- Function to get the NameBillboard from a player's head
    local function getNameBillboard(player)
        if not player or not player.Character then
            return nil
        end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then
            return nil
        end
        
        -- Check if NameBillboard exists
        local billboard = head:FindFirstChild("NameBillboard")
        if billboard and billboard:IsA("BillboardGui") then
            return billboard
        end
        
        return nil
    end

    -- Function to create a new NameBillboard from another player's (cloning with ALL properties)
    local function createNameBillboardFromOther(targetPlayer)
        -- Find any other player that has a NameBillboard
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= targetPlayer and player.Character then
                local existingBillboard = getNameBillboard(player)
                if existingBillboard then
                    -- Deep clone with ALL properties
                    local newBillboard = deepCloneBillboard(existingBillboard)
                    return newBillboard
                end
            end
        end
        return nil
    end

    -- Function to add flag to a player's name tag
    local function addFlagToPlayer(player)
        if not player then return end
        if player == localPlayer then return end -- Skip local player
        
        -- Wait for character
        if not player.Character then
            local success = pcall(function()
                player.CharacterAdded:Wait()
            end)
            if not success then return end
        end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then return end
        
        -- Try to get existing NameBillboard
        local billboard = getNameBillboard(player)
        local wasCloned = false
        
        -- If no billboard, try to create one from another player
        if not billboard then
            billboard = createNameBillboardFromOther(player)
            
            if billboard then
                wasCloned = true
                -- Parent it to the player's head (preserves all properties)
                billboard.Parent = head
                billboard.Adornee = head
                
                -- Wait a moment for the billboard to be ready
                task.wait(0.1)
            else
                -- If we still can't find one, create a basic one from scratch
                billboard = Instance.new("BillboardGui")
                billboard.Name = "NameBillboard"
                billboard.Parent = head
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 150, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "TextLabel"
                textLabel.Parent = billboard
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextScaled = true
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            end
        end
        
        -- Now add the flag to the text
        local textLabel = billboard:FindFirstChild("TextLabel")
        if not textLabel then return end
        
        -- Get the flag from attributes
        local flag = player:GetAttribute("CountryFlag")
        
        -- Get display name
        local displayName = player.DisplayName or player.Name
        
        -- Update the text with flag
        if flag and flag ~= "" then
            textLabel.Text = displayName .. " " .. flag
        else
            textLabel.Text = displayName
        end
    end

    -- Function to update all existing players
    local function updateAllPlayers()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                task.spawn(function()
                    addFlagToPlayer(player)
                end)
            end
        end
    end

    local function enableCountryESP()
        if countryESPEnabled then
            return
        end

        -- Clear existing connections
        for player, playerConnections in pairs(countryESPConnections) do
            for _, connection in ipairs(playerConnections) do
                connection:Disconnect()
            end
        end
        countryESPConnections = {}

        -- Add flags for all current players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                -- Connect CharacterAdded for existing players to handle respawns
                local characterConnection = player.CharacterAdded:Connect(function()
                    if countryESPEnabled then
                        task.spawn(function()
                            addFlagToPlayer(player)
                        end)
                    end
                end)
                
                countryESPConnections[player] = countryESPConnections[player] or {}
                table.insert(countryESPConnections[player], characterConnection)
                
                -- Add flag if they already have a character
                if player.Character then
                    task.spawn(function()
                        addFlagToPlayer(player)
                    end)
                end
            end
        end

        -- Connect events for new players
        countryESPConnection = Players.PlayerAdded:Connect(function(player)
            local newPlayerConnection = player.CharacterAdded:Connect(function()
                if countryESPEnabled then
                    task.spawn(function()
                        addFlagToPlayer(player)
                    end)
                end
            end)
            
            countryESPConnections[player] = countryESPConnections[player] or {}
            table.insert(countryESPConnections[player], newPlayerConnection)
            
            if player.Character then
                task.spawn(function()
                    addFlagToPlayer(player)
                end)
            end
        end)

        -- Update all players again after a short delay
        task.wait(1)
        updateAllPlayers()

        -- Keep checking for new players or name changes
        task.wait(2)
        updateAllPlayers()

        countryESPEnabled = true
        countryESPButton.Text = 'ESP Country: ON'
        countryESPButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end

    local function disableCountryESP()
        if not countryESPEnabled then
            return
        end

        -- Disconnect all character connections
        for player, playerConnections in pairs(countryESPConnections) do
            for _, connection in ipairs(playerConnections) do
                connection:Disconnect()
            end
        end
        countryESPConnections = {}

        -- Disconnect main PlayerAdded connection
        if countryESPConnection then
            countryESPConnection:Disconnect()
            countryESPConnection = nil
        end

        -- Reset all player name tags to original
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local billboard = head:FindFirstChild("NameBillboard")
                    if billboard then
                        local textLabel = billboard:FindFirstChild("TextLabel")
                        if textLabel then
                            local displayName = player.DisplayName or player.Name
                            textLabel.Text = displayName
                        end
                    end
                end
            end
        end

        countryESPEnabled = false
        countryESPButton.Text = 'ESP Country: OFF'
        countryESPButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end

    -- Country ESP Button Click Handler
    countryESPButton.MouseButton1Click:Connect(function()
        if countryESPEnabled then
            disableCountryESP()
            countryESPButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            settings.countryESPEnabled = false
            saveSettings()
        else
            enableCountryESP()
            countryESPButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            settings.countryESPEnabled = true
            saveSettings()
        end
    end)

    -- Clean up country ESP when players leave
    Players.PlayerRemoving:Connect(function(player)
        -- Clean up connections for this player
        if countryESPConnections[player] then
            for _, connection in ipairs(countryESPConnections[player]) do
                connection:Disconnect()
            end
            countryESPConnections[player] = nil
        end
    end)

    -- Spoof Tools Button in Misc page
    local spoofToolsButton = Instance.new('TextButton')
    spoofToolsButton.Name = 'SpoofToolsButton'
    spoofToolsButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    spoofToolsButton.Position = UDim2.new(0, 10, 0, isMobile and 180 or 200)
    spoofToolsButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black color
    spoofToolsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spoofToolsButton.Text = 'Spoof Tools'
    spoofToolsButton.TextSize = isMobile and 12 or 14
    spoofToolsButton.Font = Enum.Font.Ubuntu
    spoofToolsButton.AutoButtonColor = false

    local spoofToolsCorner = Instance.new('UICorner')
    spoofToolsCorner.CornerRadius = UDim.new(0, 6)
    spoofToolsCorner.Parent = spoofToolsButton

    spoofToolsButton.MouseEnter:Connect(function()
        TweenService:Create(spoofToolsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray hover
        }):Play()
    end)

    spoofToolsButton.MouseLeave:Connect(function()
        TweenService:Create(spoofToolsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black
        }):Play()
    end)

    spoofToolsButton.Parent = miscPage

    -- Anti Void Fall removed per user request
    -- Bypass Safezone removed per user request

    -- Smart Spectate Toggle in Misc page
    smartSpectateEnabled = false
    currentSpectateTarget = nil
    spectateConnection = nil
    characterSpawnConnection = nil

    local smartSpectateButton = Instance.new('TextButton')
    smartSpectateButton.Name = 'SmartSpectateButton'
    smartSpectateButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    smartSpectateButton.Position = UDim2.new(0, 10, 0, isMobile and 260 or 290)
    smartSpectateButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    smartSpectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    smartSpectateButton.Text = 'Smart Spectate: OFF'
    smartSpectateButton.TextSize = isMobile and 12 or 14
    smartSpectateButton.Font = Enum.Font.Ubuntu
    smartSpectateButton.AutoButtonColor = false
    smartSpectateButton.Parent = miscPage

    local smartSpectateCorner = Instance.new('UICorner')
    smartSpectateCorner.CornerRadius = UDim.new(0, 6)
    smartSpectateCorner.Parent = smartSpectateButton

    smartSpectateButton.MouseEnter:Connect(function()
        TweenService:Create(smartSpectateButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)

    smartSpectateButton.MouseLeave:Connect(function()
        local targetColor = smartSpectateEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        TweenService:Create(smartSpectateButton, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor
        }):Play()
    end)

    -- Function to send AFK remote
    function sendAFKRemote(afkState)
        spawn(function()
            local success, errorMessage = pcall(function()
                local args = {afkState}
                game:GetService("ReplicatedStorage"):WaitForChild("AFK THINGY"):WaitForChild("AFKEvent"):FireServer(unpack(args))
            end)
            if not success then
                warn("Failed to send AFK event: " .. tostring(errorMessage))
            end
        end)
    end

    -- Function to start spectating with camera tracking
    function startSmartSpectate(player)
        if not player or currentSpectateTarget == player then return end
        
        -- Stop any existing spectate
        stopSmartSpectate()
        
        currentSpectateTarget = player
        sendAFKRemote(true) -- Send AFK when starting spectate
        
        -- Function to attach camera to player
        local function attachCamera()
            pcall(function()
                if currentSpectateTarget and currentSpectateTarget.Character and currentSpectateTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local camera = workspace.CurrentCamera
                    local humanoid = currentSpectateTarget.Character:FindFirstChildOfClass("Humanoid")
                    if camera and humanoid then
                        camera.CameraSubject = humanoid
                        camera.CameraType = Enum.CameraType.Follow
                    end
                end
            end)
        end
        
        -- Attach camera initially
        attachCamera()
        
        -- Monitor for character respawns
        if characterSpawnConnection then
            characterSpawnConnection:Disconnect()
        end
        
        if currentSpectateTarget then
            characterSpawnConnection = currentSpectateTarget.CharacterAdded:Connect(function()
                task.wait(0.1) -- Small delay to ensure character is fully loaded
                attachCamera()
            end)
        end
        
        -- Monitor camera changes
        if spectateConnection then
            spectateConnection:Disconnect()
        end
        
        spectateConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if currentSpectateTarget and currentSpectateTarget.Character and currentSpectateTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local camera = workspace.CurrentCamera
                    local humanoid = currentSpectateTarget.Character:FindFirstChildOfClass("Humanoid")
                    if camera and humanoid and camera.CameraSubject ~= humanoid then
                        attachCamera()
                    end
                end
            end)
        end)
    end

    -- Function to stop spectating
    function stopSmartSpectate()
        pcall(function()
            if currentSpectateTarget then
                sendAFKRemote(false) -- Send non-AFK when stopping spectate
                currentSpectateTarget = nil
            end
            
            if spectateConnection then
                spectateConnection:Disconnect()
                spectateConnection = nil
            end
            
            if characterSpawnConnection then
                characterSpawnConnection:Disconnect()
                characterSpawnConnection = nil
            end
            
            -- Reset camera to player
            local camera = workspace.CurrentCamera
            if camera and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                camera.CameraSubject = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                camera.CameraType = Enum.CameraType.Custom
            end
        end)
    end

    smartSpectateButton.MouseButton1Click:Connect(function()
        smartSpectateEnabled = not smartSpectateEnabled

        if smartSpectateEnabled then
            smartSpectateButton.Text = 'Smart Spectate: ON'
            smartSpectateButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray when ON
            settings.smartSpectateEnabled = true
            saveSettings()
        else
            smartSpectateButton.Text = 'Smart Spectate: OFF'
            smartSpectateButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            stopSmartSpectate() -- Stop any active spectate when disabled
            settings.smartSpectateEnabled = false
            saveSettings()
        end
    end)

    -- Spectate AntiCheat Bypass Toggle in Misc page
    -- Only functional when executor supports it; otherwise shows "Executor Not Supported"
    local spectateBypassButton = Instance.new('TextButton')
    spectateBypassButton.Name = 'SpectateBypassButton'
    spectateBypassButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    spectateBypassButton.Position = UDim2.new(0, 10, 0, isMobile and 300 or 335)
    spectateBypassButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    spectateBypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spectateBypassButton.Text = 'Spectate AntiCheat: OFF'
    spectateBypassButton.TextSize = isMobile and 12 or 14
    spectateBypassButton.Font = Enum.Font.Ubuntu
    spectateBypassButton.AutoButtonColor = false
    spectateBypassButton.Parent = miscPage

    local spectateBypassCorner = Instance.new('UICorner')
    spectateBypassCorner.CornerRadius = UDim.new(0, 6)
    spectateBypassCorner.Parent = spectateBypassButton

    spectateBypassButton.MouseEnter:Connect(function()
        TweenService:Create(spectateBypassButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)

    spectateBypassButton.MouseLeave:Connect(function()
        local targetColor
        if getgenv().spectateBypassEnabled then
            targetColor = Color3.fromRGB(80, 80, 80)
        elseif _remoteBlockSupported == false then
            targetColor = Color3.fromRGB(50, 30, 30)
        else
            targetColor = Color3.fromRGB(30, 30, 30)
        end
        TweenService:Create(spectateBypassButton, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor
        }):Play()
    end)

    spectateBypassButton.MouseButton1Click:Connect(function()
        if _remoteBlockSupported == false then
            -- Executor not supported - notify but do NOT kick
            showBypassNotification("Executor not supported - bypass unavailable")
            spectateBypassButton.Text = 'Spectate AntiCheat: NOT SUPPORTED'
            return
        end

        local newState = not getgenv().spectateBypassEnabled
        getgenv().spectateBypassEnabled = newState

        if newState then
            spectateBypassButton.Text = 'Spectate AntiCheat: ON'
            spectateBypassButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            -- Re-run the bypass logic to activate connections
            v2b6k8()
        else
            spectateBypassButton.Text = 'Spectate AntiCheat: OFF'
            spectateBypassButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            -- Clean up any existing bypass connections so they stop
            if getgenv().spectateConnections then
                for _, connection in pairs(getgenv().spectateConnections) do
                    pcall(function() connection:Disconnect() end)
                end
                getgenv().spectateConnections = {}
            end
        end
    end)

    -- Bypass Safezone removed per user request

    -- Invisible feature removed per user request

    -- Anti Cuff removed per user request

    -- Anti Cuff removed per user request

    -- Anti VC Ban Button in Misc page
 --   local antiVcBanButton = Instance.new('TextButton')
 --   antiVcBanButton.Name = 'AntiVcBanButton'
 --   antiVcBanButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
 --   antiVcBanButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
 --   antiVcBanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
 --   antiVcBanButton.Text = 'Anti VC Ban'
 --   antiVcBanButton.TextSize = isMobile and 12 or 14
 --   antiVcBanButton.Font = Enum.Font.Ubuntu
 --   antiVcBanButton.AutoButtonColor = false
 --   antiVcBanButton.Parent = miscPage
--
 --   local antiVcBanCorner = Instance.new('UICorner')
 --   antiVcBanCorner.CornerRadius = UDim.new(0, 6)
 --   antiVcBanCorner.Parent = antiVcBanButton
--
 --   antiVcBanButton.MouseEnter:Connect(function()
 --       TweenService:Create(antiVcBanButton, TweenInfo.new(0.2), {
 --           BackgroundColor3 = Color3.fromRGB(50, 50, 50)
 --       }):Play()
 --   end)
--
 --   antiVcBanButton.MouseLeave:Connect(function()
 --       TweenService:Create(antiVcBanButton, TweenInfo.new(0.2), {
 --           BackgroundColor3 = Color3.fromRGB(30, 30, 30)
 --       }):Play()
 --   end)
--
 --   antiVcBanButton.MouseButton1Click:Connect(function()
 --       task.spawn(function()
 --           antiVcBanButton.Text = 'Loading...'
 --           antiVcBanButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
 --           
 --           local success, err = pcall(function()
 --               loadstring(game:HttpGet("https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/vcbypass.lua"))()
 --           end)
 --           
 --           task.wait(0.5)
 --           if success then
 --               antiVcBanButton.Text = 'Anti VC Ban ✓'
 --               antiVcBanButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
 --               task.wait(2)
 --               antiVcBanButton.Text = 'Anti VC Ban'
 --               antiVcBanButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
 --           else
 --               antiVcBanButton.Text = 'Failed!'
 --               antiVcBanButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
 --               task.wait(2)
 --               antiVcBanButton.Text = 'Anti VC Ban'
 --               antiVcBanButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
 --           end
 --       end)
 --   end)

  local hitboxExpanderEnabled = false
  local hitboxVisualEnabled = false
  local hitboxConnection = nil
  local hitboxVisualContainer = nil
  
  local hitboxExpanderButton = Instance.new('TextButton')
  hitboxExpanderButton.Name = 'HitboxExpanderButton'
  hitboxExpanderButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
  hitboxExpanderButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
  hitboxExpanderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  hitboxExpanderButton.Text = 'Hitbox Expander: OFF'
  hitboxExpanderButton.TextSize = isMobile and 12 or 14
  hitboxExpanderButton.Font = Enum.Font.Ubuntu
  hitboxExpanderButton.AutoButtonColor = false
  hitboxExpanderButton.Parent = miscPage
 
  local hitboxExpanderCorner = Instance.new('UICorner')
  hitboxExpanderCorner.CornerRadius = UDim.new(0, 6)
  hitboxExpanderCorner.Parent = hitboxExpanderButton
 
  hitboxExpanderButton.MouseEnter:Connect(function()
      TweenService:Create(hitboxExpanderButton, TweenInfo.new(0.2), {
          BackgroundColor3 = Color3.fromRGB(50, 50, 50)
      }):Play()
  end)
 
  hitboxExpanderButton.MouseLeave:Connect(function()
      local targetColor = hitboxExpanderEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
      TweenService:Create(hitboxExpanderButton, TweenInfo.new(0.2), {
          BackgroundColor3 = targetColor
      }):Play()
  end)
 
  hitboxExpanderButton.MouseButton1Click:Connect(function()
      hitboxExpanderEnabled = not hitboxExpanderEnabled
      
      if hitboxExpanderEnabled then
          hitboxExpanderButton.Text = 'Hitbox Expander: ON'
          hitboxExpanderButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
          
          -- Start hitbox expansion
          _G.HeadSize = 50
          _G.Disabled = true
          
          hitboxConnection = game:GetService('RunService').RenderStepped:Connect(function()
              if _G.Disabled then
                  for _, v in next, game:GetService('Players'):GetPlayers() do
                      if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                          pcall(function()
                              if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                                  v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                                  v.Character.HumanoidRootPart.CanCollide = false
                                  
                                  -- Apply visual effect if enabled
                                  if hitboxVisualEnabled then
                                      v.Character.HumanoidRootPart.Transparency = 0.7
                                      v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue")
                                      v.Character.HumanoidRootPart.Material = "Neon"
                                  else
                                      v.Character.HumanoidRootPart.Transparency = 1
                                  end
                              end
                          end)
                      end
                  end
              end
          end)
          
          -- Create visual toggle container as separate element in miscPage
          -- Get the position of hitboxExpanderButton in the list
          local buttonPosition = 0
          for i, child in ipairs(miscPage:GetChildren()) do
              if child == hitboxExpanderButton then
                  buttonPosition = i
                  break
              end
          end
          
          hitboxVisualContainer = Instance.new('Frame')
          hitboxVisualContainer.Name = 'HitboxVisualContainer'
          hitboxVisualContainer.Size = UDim2.new(1, -40, 0, 0) -- Start with 0 height for animation
          hitboxVisualContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
          hitboxVisualContainer.BorderSizePixel = 0
          hitboxVisualContainer.BackgroundTransparency = 1 -- Start transparent
          hitboxVisualContainer.ClipsDescendants = true
          hitboxVisualContainer.Parent = miscPage
          
          -- Set all items' LayoutOrder to maintain position and insert visual container right after button
          local orderIndex = 1
          for i, child in ipairs(miscPage:GetChildren()) do
              if child:IsA("GuiObject") and child ~= hitboxVisualContainer then
                  child.LayoutOrder = orderIndex
                  orderIndex = orderIndex + 1
                  -- Insert visual container right after hitbox button
                  if child == hitboxExpanderButton then
                      hitboxVisualContainer.LayoutOrder = orderIndex
                      orderIndex = orderIndex + 1
                  end
              end
          end
          
          local visualContainerCorner = Instance.new('UICorner')
          visualContainerCorner.CornerRadius = UDim.new(0, 4)
          visualContainerCorner.Parent = hitboxVisualContainer
          
          -- Add padding to indent the visual toggle
          local visualPadding = Instance.new('UIPadding')
          visualPadding.PaddingLeft = UDim.new(0, 30)
          visualPadding.Parent = hitboxVisualContainer
          
          -- Animate container appearing
          TweenService:Create(hitboxVisualContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
              Size = UDim2.new(1, -40, 0, isMobile and 28 or 32),
              BackgroundTransparency = 0
          }):Play()
          
          -- Label for the toggle
          local visualLabel = Instance.new('TextLabel')
          visualLabel.Name = 'VisualLabel'
          visualLabel.Size = UDim2.new(0.65, 0, 1, 0)
          visualLabel.Position = UDim2.new(0, 0, 0, 0)
          visualLabel.BackgroundTransparency = 1
          visualLabel.Text = 'Visual Color'
          visualLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
          visualLabel.TextSize = isMobile and 10 or 11
          visualLabel.Font = Enum.Font.Ubuntu
          visualLabel.TextXAlignment = Enum.TextXAlignment.Left
          visualLabel.Parent = hitboxVisualContainer
          
          -- Enable visual color by default
          hitboxVisualEnabled = true
          
          -- Create switch background
          local switchBg = Instance.new('Frame')
          switchBg.Name = 'SwitchBg'
          switchBg.Size = UDim2.new(0, isMobile and 36 or 40, 0, isMobile and 18 or 20)
          switchBg.Position = UDim2.new(1, isMobile and -5 or -10, 0.5, 0)
          switchBg.AnchorPoint = Vector2.new(1, 0.5)
          switchBg.BackgroundColor3 = Color3.fromRGB(50, 150, 255) -- Start as ON (blue)
          switchBg.BorderSizePixel = 0
          switchBg.Parent = hitboxVisualContainer
          
          local switchBgCorner = Instance.new('UICorner')
          switchBgCorner.CornerRadius = UDim.new(1, 0)
          switchBgCorner.Parent = switchBg
          
          -- Create switch knob (start in ON position - right side)
          local switchKnob = Instance.new('Frame')
          switchKnob.Name = 'SwitchKnob'
          switchKnob.Size = UDim2.new(0, isMobile and 14 or 16, 0, isMobile and 14 or 16)
          switchKnob.Position = UDim2.new(1, -2, 0.5, 0) -- Start on the right (ON position)
          switchKnob.AnchorPoint = Vector2.new(1, 0.5)
          switchKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
          switchKnob.BorderSizePixel = 0
          switchKnob.Parent = switchBg
          
          local switchKnobCorner = Instance.new('UICorner')
          switchKnobCorner.CornerRadius = UDim.new(1, 0)
          switchKnobCorner.Parent = switchKnob
          
          -- Make the entire container clickable
          local visualClickButton = Instance.new('TextButton')
          visualClickButton.Name = 'VisualClickButton'
          visualClickButton.Size = UDim2.new(1, 0, 1, 0)
          visualClickButton.BackgroundTransparency = 1
          visualClickButton.Text = ''
          visualClickButton.Parent = hitboxVisualContainer
          
          visualClickButton.MouseEnter:Connect(function()
              if hitboxVisualContainer and hitboxVisualContainer.Parent then
                  TweenService:Create(hitboxVisualContainer, TweenInfo.new(0.2), {
                      BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                  }):Play()
              end
          end)
          
          visualClickButton.MouseLeave:Connect(function()
              if hitboxVisualContainer and hitboxVisualContainer.Parent then
                  TweenService:Create(hitboxVisualContainer, TweenInfo.new(0.2), {
                      BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                  }):Play()
              end
          end)
          
          visualClickButton.MouseButton1Click:Connect(function()
              hitboxVisualEnabled = not hitboxVisualEnabled
              
              if hitboxVisualEnabled then
                  -- Animate switch to ON
                  if switchBg and switchBg.Parent then
                      TweenService:Create(switchBg, TweenInfo.new(0.2), {
                          BackgroundColor3 = Color3.fromRGB(50, 150, 255)
                      }):Play()
                  end
                  if switchKnob and switchKnob.Parent then
                      TweenService:Create(switchKnob, TweenInfo.new(0.2), {
                          Position = UDim2.new(1, -2, 0.5, 0),
                          AnchorPoint = Vector2.new(1, 0.5)
                      }):Play()
                  end
              else
                  -- Animate switch to OFF
                  if switchBg and switchBg.Parent then
                      TweenService:Create(switchBg, TweenInfo.new(0.2), {
                          BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                      }):Play()
                  end
                  if switchKnob and switchKnob.Parent then
                      TweenService:Create(switchKnob, TweenInfo.new(0.2), {
                          Position = UDim2.new(0, 2, 0.5, 0),
                          AnchorPoint = Vector2.new(0, 0.5)
                      }):Play()
                  end
                  
                  -- Reset transparency for all players when visual is turned off
                  for _, v in next, game:GetService('Players'):GetPlayers() do
                      if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                          pcall(function()
                              if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                                  v.Character.HumanoidRootPart.Transparency = 1
                              end
                          end)
                      end
                  end
              end
          end)
          
      else
          hitboxExpanderButton.Text = 'Hitbox Expander: OFF'
          hitboxExpanderButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
          
          -- Stop hitbox expansion
          _G.Disabled = false
          if hitboxConnection then
              pcall(function()
                  hitboxConnection:Disconnect()
              end)
              hitboxConnection = nil
          end
          
          -- Remove visual toggle container
          if hitboxVisualContainer then
              pcall(function()
                  hitboxVisualContainer:Destroy()
              end)
              hitboxVisualContainer = nil
          end
          
          -- Reset all hitboxes and visuals
          for _, v in next, game:GetService('Players'):GetPlayers() do
              if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                  pcall(function()
                      if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                          v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                          v.Character.HumanoidRootPart.Transparency = 1
                          v.Character.HumanoidRootPart.CanCollide = false
                      end
                  end)
              end
          end
          
          hitboxVisualEnabled = false
      end
  end)
 
    -- Initialize Silent Typing Feature
    local function initializeSilentTyping()
        local silentTypingEnabled = settings.silentTypingEnabled or false
        local typingUIScript = nil

        local silentTypingButton = Instance.new('TextButton')
        silentTypingButton.Name = 'SilentTypingButton'
        silentTypingButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
        silentTypingButton.BackgroundColor3 = silentTypingEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        silentTypingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        silentTypingButton.Text = silentTypingEnabled and 'Silent Typing: ON' or 'Silent Typing: OFF'
        silentTypingButton.TextSize = isMobile and 12 or 14
        silentTypingButton.Font = Enum.Font.Ubuntu
        silentTypingButton.AutoButtonColor = false
        silentTypingButton.Parent = miscPage

        local silentTypingCorner = Instance.new('UICorner')
        silentTypingCorner.CornerRadius = UDim.new(0, 6)
        silentTypingCorner.Parent = silentTypingButton

        silentTypingButton.MouseEnter:Connect(function()
            TweenService:Create(silentTypingButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)

        silentTypingButton.MouseLeave:Connect(function()
            local targetColor = silentTypingEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
            TweenService:Create(silentTypingButton, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor
            }):Play()
        end)

        local function toggleSilentTyping()
            silentTypingEnabled = not silentTypingEnabled
            
            if silentTypingEnabled then
                pcall(function()
                    local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
                    if playerScripts then
                        typingUIScript = playerScripts:FindFirstChild("TypeBubbleClient", true)
                        if typingUIScript and typingUIScript:IsA("LocalScript") then
                            typingUIScript.Enabled = false
                        end
                    end
                end)
                
                silentTypingButton.Text = 'Silent Typing: ON'
                silentTypingButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                settings.silentTypingEnabled = true
                saveSettings()
            else
                pcall(function()
                    if typingUIScript and typingUIScript:IsA("LocalScript") then
                        typingUIScript.Enabled = true
                    end
                end)
                
                silentTypingButton.Text = 'Silent Typing: OFF'
                silentTypingButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                settings.silentTypingEnabled = false
                saveSettings()
            end
        end

        silentTypingButton.MouseButton1Click:Connect(function()
            toggleSilentTyping()
        end)
        
        -- Apply saved state on load
        if silentTypingEnabled then
            pcall(function()
                local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
                if playerScripts then
                    typingUIScript = playerScripts:FindFirstChild("TypeBubbleClient", true)
                    if typingUIScript and typingUIScript:IsA("LocalScript") then
                        typingUIScript.Enabled = false
                    end
                end
            end)
        end
    end

    -- Initialize Mute Boombox Feature
    local function initializeMuteBoombox()
        local muteBoomboxEnabled = false
        local boomboxMuteConnections = {}
        local originalVolumes = {} -- Store original volumes to restore

        local muteBoomboxButton = Instance.new('TextButton')
        muteBoomboxButton.Name = 'MuteBoomboxButton'
        muteBoomboxButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
        muteBoomboxButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        muteBoomboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        muteBoomboxButton.Text = 'Mute Boombox: OFF'
        muteBoomboxButton.TextSize = isMobile and 12 or 14
        muteBoomboxButton.Font = Enum.Font.Ubuntu
        muteBoomboxButton.AutoButtonColor = false
        muteBoomboxButton.Parent = miscPage

        local muteBoomboxCorner = Instance.new('UICorner')
        muteBoomboxCorner.CornerRadius = UDim.new(0, 6)
        muteBoomboxCorner.Parent = muteBoomboxButton

        muteBoomboxButton.MouseEnter:Connect(function()
            TweenService:Create(muteBoomboxButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)

        muteBoomboxButton.MouseLeave:Connect(function()
            local targetColor = muteBoomboxEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
            TweenService:Create(muteBoomboxButton, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor
            }):Play()
        end)

        local function muteBoomboxSound(sound)
            if not sound or not sound:IsA("Sound") then return end
            if not originalVolumes[sound] then
                originalVolumes[sound] = sound.Volume
            end
            sound.Volume = 0
        end

        local function unmuteBoomboxSound(sound)
            if not sound or not sound:IsA("Sound") then return end
            if originalVolumes[sound] then
                sound.Volume = originalVolumes[sound]
                originalVolumes[sound] = nil
            end
        end

        local function monitorPlayerBoombox(player)
            if player == localPlayer then return end
            
            local function checkCharacter(character)
                if not character then return end
                
                -- Monitor for boombox being added
                local boomboxAddedConnection = character.ChildAdded:Connect(function(child)
                    if muteBoomboxEnabled and child.Name == "BoomBox" and child:IsA("Tool") then
                        task.wait(0.1)
                        local handle = child:FindFirstChild("Handle")
                        if handle then
                            local sound = handle:FindFirstChild("Sound")
                            if sound then
                                muteBoomboxSound(sound)
                            end
                            
                            -- Monitor for sound being added to handle
                            local soundAddedConnection = handle.ChildAdded:Connect(function(grandchild)
                                if muteBoomboxEnabled and grandchild:IsA("Sound") then
                                    task.wait(0.05)
                                    muteBoomboxSound(grandchild)
                                end
                            end)
                            table.insert(boomboxMuteConnections, soundAddedConnection)
                        end
                    end
                end)
                table.insert(boomboxMuteConnections, boomboxAddedConnection)
                
                -- Check existing boombox
                local existingBoombox = character:FindFirstChild("BoomBox")
                if existingBoombox then
                    local handle = existingBoombox:FindFirstChild("Handle")
                    if handle then
                        local sound = handle:FindFirstChild("Sound")
                        if sound then
                            muteBoomboxSound(sound)
                        end
                    end
                end
            end
            
            if player.Character then
                checkCharacter(player.Character)
            end
            
            local charAddedConnection = player.CharacterAdded:Connect(function(character)
                if muteBoomboxEnabled then
                    checkCharacter(character)
                end
            end)
            table.insert(boomboxMuteConnections, charAddedConnection)
        end

        local function startMutingBoomboxes()
            -- Monitor all existing players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    monitorPlayerBoombox(player)
                    
                    -- Mute existing boomboxes
                    if player.Character then
                        local boombox = player.Character:FindFirstChild("BoomBox")
                        if boombox then
                            local handle = boombox:FindFirstChild("Handle")
                            if handle then
                                local sound = handle:FindFirstChild("Sound")
                                if sound then
                                    muteBoomboxSound(sound)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Monitor new players joining
            local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
                if muteBoomboxEnabled then
                    monitorPlayerBoombox(player)
                end
            end)
            table.insert(boomboxMuteConnections, playerAddedConnection)
        end

        local function stopMutingBoomboxes()
            -- Restore all muted volumes
            for sound, originalVolume in pairs(originalVolumes) do
                pcall(function()
                    if sound and sound.Parent then
                        sound.Volume = originalVolume
                    end
                end)
            end
            originalVolumes = {}
            
            -- Disconnect all connections
            for _, connection in ipairs(boomboxMuteConnections) do
                pcall(function()
                    if connection then
                        connection:Disconnect()
                    end
                end)
            end
            boomboxMuteConnections = {}
        end

        local function toggleMuteBoombox()
            muteBoomboxEnabled = not muteBoomboxEnabled
            
            if muteBoomboxEnabled then
                startMutingBoomboxes()
                muteBoomboxButton.Text = 'Mute Boombox: ON'
                muteBoomboxButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            else
                stopMutingBoomboxes()
                muteBoomboxButton.Text = 'Mute Boombox: OFF'
                muteBoomboxButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end
        end

        muteBoomboxButton.MouseButton1Click:Connect(function()
            toggleMuteBoombox()
        end)
    end

    -- Initialize ESP Boombox Feature
    local function initializeESPBoombox()
        local espBoomboxEnabled = false
        local boomboxESPConnections = {}
        local boomboxESPGuis = {}

        local espBoomboxButton = Instance.new('TextButton')
        espBoomboxButton.Name = 'ESPBoomboxButton'
        espBoomboxButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
        espBoomboxButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        espBoomboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        espBoomboxButton.Text = 'ESP Boombox ID: OFF'
        espBoomboxButton.TextSize = isMobile and 12 or 14
        espBoomboxButton.Font = Enum.Font.Ubuntu
        espBoomboxButton.AutoButtonColor = false
        espBoomboxButton.Parent = miscPage

        local espBoomboxCorner = Instance.new('UICorner')
        espBoomboxCorner.CornerRadius = UDim.new(0, 6)
        espBoomboxCorner.Parent = espBoomboxButton

        espBoomboxButton.MouseEnter:Connect(function()
            TweenService:Create(espBoomboxButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)

        espBoomboxButton.MouseLeave:Connect(function()
            local targetColor = espBoomboxEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
            TweenService:Create(espBoomboxButton, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor
            }):Play()
        end)

        local function createBoomboxESP(player, boombox)
            pcall(function()
                if not player.Character then return end
                local head = player.Character:FindFirstChild("Head")
                if not head then return end
                
                local handle = boombox:FindFirstChild("Handle")
                if not handle then return end
                
                local sound = handle:FindFirstChild("Sound")
                if not sound or not sound:IsA("Sound") then return end
                
                -- Remove any existing ESP for this player
                local existingESP = head:FindFirstChild("BoomboxESP_" .. player.Name)
                if existingESP then
                    existingESP:Destroy()
                end
                
                local soundId = sound.SoundId
                local numericId = soundId:match("rbxassetid://(%d+)") or soundId:match("(%d+)")
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "BoomboxESP_" .. player.Name
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 200, 0, 80)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Active = false  -- Prevent billboard from blocking clicks
                billboard.Parent = head
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                frame.BackgroundTransparency = 0.3
                frame.BorderSizePixel = 0
                frame.Active = false  -- Prevent frame from blocking clicks
                frame.Parent = billboard
                
                local frameCorner = Instance.new("UICorner")
                frameCorner.CornerRadius = UDim.new(0, 8)
                frameCorner.Parent = frame
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, -10, 0, 20)
                nameLabel.Position = UDim2.new(0, 5, 0, 5)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.DisplayName or player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                nameLabel.TextSize = 14
                nameLabel.Font = Enum.Font.Ubuntu
                nameLabel.TextXAlignment = Enum.TextXAlignment.Center
                nameLabel.Parent = frame
                
                local idLabel = Instance.new("TextLabel")
                idLabel.Name = "IDLabel"
                idLabel.Size = UDim2.new(1, -10, 0, 18)
                idLabel.Position = UDim2.new(0, 5, 0, 25)
                idLabel.BackgroundTransparency = 1
                idLabel.Text = "ID: " .. (numericId or "Unknown")
                idLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                idLabel.TextSize = 12
                idLabel.Font = Enum.Font.Ubuntu
                idLabel.TextXAlignment = Enum.TextXAlignment.Center
                idLabel.Parent = frame
                
                -- Monitor sound ID changes
                local soundChangedConnection
                soundChangedConnection = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
                    if espBoomboxEnabled and idLabel and idLabel.Parent then
                        local newSoundId = sound.SoundId
                        numericId = newSoundId:match("rbxassetid://(%d+)") or newSoundId:match("(%d+)")  -- Update the upvalue
                        idLabel.Text = "ID: " .. (numericId or "Unknown")
                    end
                end)
                
                local copyButton = Instance.new("TextButton")
                copyButton.Size = UDim2.new(0, 80, 0, 22)
                copyButton.Position = UDim2.new(0.5, -40, 1, -27)
                copyButton.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
                copyButton.Text = "Copy ID"
                copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                copyButton.TextSize = 11
                copyButton.Font = Enum.Font.Ubuntu
                copyButton.AutoButtonColor = false
                copyButton.Active = true
                copyButton.ZIndex = 10
                copyButton.Parent = frame
                
                local copyCorner = Instance.new("UICorner")
                copyCorner.CornerRadius = UDim.new(0, 6)
                copyCorner.Parent = copyButton
                
                -- Use task.spawn to avoid yield issues
                copyButton.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        if setclipboard and numericId then
                            setclipboard(numericId)
                            copyButton.Text = "Copied!"
                            copyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                            task.wait(1)
                            if copyButton and copyButton.Parent then
                                copyButton.Text = "Copy ID"
                                copyButton.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
                            end
                        else
                            copyButton.Text = "No Clipboard"
                            task.wait(1)
                            if copyButton and copyButton.Parent then
                                copyButton.Text = "Copy ID"
                            end
                        end
                    end)
                end)
                
                copyButton.MouseEnter:Connect(function()
                    TweenService:Create(copyButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(95, 20, 150)
                    }):Play()
                end)
                
                copyButton.MouseLeave:Connect(function()
                    TweenService:Create(copyButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(75, 0, 130)
                    }):Play()
                end)
                
                table.insert(boomboxESPGuis, billboard)
                
                -- Clean up when boombox is removed
                boombox.AncestryChanged:Connect(function()
                    if not boombox:IsDescendantOf(workspace) then
                        if soundChangedConnection then
                            soundChangedConnection:Disconnect()
                        end
                        billboard:Destroy()
                    end
                end)
                
                -- Clean up when ESP is disabled
                billboard.AncestryChanged:Connect(function()
                    if not billboard.Parent and soundChangedConnection then
                        soundChangedConnection:Disconnect()
                    end
                end)
            end)
        end

        local function monitorPlayerBoomboxESP(player)
            local function checkCharacter(character)
                if not character then return end
                
                local boomboxAddedConnection = character.ChildAdded:Connect(function(child)
                    if espBoomboxEnabled and child.Name == "BoomBox" and child:IsA("Tool") then
                        task.wait(0.1)
                        createBoomboxESP(player, child)
                    end
                end)
                table.insert(boomboxESPConnections, boomboxAddedConnection)
                
                local existingBoombox = character:FindFirstChild("BoomBox")
                if existingBoombox then
                    createBoomboxESP(player, existingBoombox)
                end
            end
            
            if player.Character then
                checkCharacter(player.Character)
            end
            
            local charAddedConnection = player.CharacterAdded:Connect(function(character)
                if espBoomboxEnabled then
                    checkCharacter(character)
                end
            end)
            table.insert(boomboxESPConnections, charAddedConnection)
        end

        local function startBoomboxESP()
            for _, player in pairs(Players:GetPlayers()) do
                monitorPlayerBoomboxESP(player)
                
                if player.Character then
                    local boombox = player.Character:FindFirstChild("BoomBox")
                    if boombox then
                        createBoomboxESP(player, boombox)
                    end
                end
            end
            
            local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
                if espBoomboxEnabled then
                    monitorPlayerBoomboxESP(player)
                end
            end)
            table.insert(boomboxESPConnections, playerAddedConnection)
        end

        local function stopBoomboxESP()
            for _, connection in ipairs(boomboxESPConnections) do
                pcall(function()
                    if connection then
                        connection:Disconnect()
                    end
                end)
            end
            boomboxESPConnections = {}
            
            for _, gui in ipairs(boomboxESPGuis) do
                pcall(function()
                    if gui then
                        gui:Destroy()
                    end
                end)
            end
            boomboxESPGuis = {}
        end

        local function toggleESPBoombox()
            espBoomboxEnabled = not espBoomboxEnabled
            
            if espBoomboxEnabled then
                startBoomboxESP()
                espBoomboxButton.Text = 'ESP Boombox ID: ON'
                espBoomboxButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            else
                stopBoomboxESP()
                espBoomboxButton.Text = 'ESP Boombox ID: OFF'
                espBoomboxButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end
        end

        espBoomboxButton.MouseButton1Click:Connect(function()
            toggleESPBoombox()
        end)
    end

    -- Call initialization functions
    initializeSilentTyping()
    initializeMuteBoombox()
    initializeESPBoombox()
    
    -- Intro Sound Toggle in Misc page
    local introSoundButton = Instance.new('TextButton')
    introSoundButton.Name = 'IntroSoundButton'
    introSoundButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    introSoundButton.BackgroundColor3 = settings.introSoundEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
    introSoundButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    introSoundButton.Text = settings.introSoundEnabled and 'Intro Sound: ON' or 'Intro Sound: OFF'
    introSoundButton.TextSize = isMobile and 12 or 14
    introSoundButton.Font = Enum.Font.Ubuntu
    introSoundButton.AutoButtonColor = false
    introSoundButton.Parent = miscPage

    local introSoundCorner = Instance.new('UICorner')
    introSoundCorner.CornerRadius = UDim.new(0, 6)
    introSoundCorner.Parent = introSoundButton

    introSoundButton.MouseEnter:Connect(function()
        TweenService:Create(introSoundButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)

    introSoundButton.MouseLeave:Connect(function()
        local targetColor = settings.introSoundEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        TweenService:Create(introSoundButton, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor
        }):Play()
    end)

    introSoundButton.MouseButton1Click:Connect(function()
        settings.introSoundEnabled = not settings.introSoundEnabled
        introSoundButton.Text = settings.introSoundEnabled and 'Intro Sound: ON' or 'Intro Sound: OFF'
        introSoundButton.BackgroundColor3 = settings.introSoundEnabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        saveSettings()
    end)

    -- Disable Game Auto AFK Toggle in Misc page
    local function initializeDisableGameAutoAFK()
        local disableGameAutoAFKButton = Instance.new('TextButton')
        disableGameAutoAFKButton.Name = 'DisableGameAutoAFKButton'
        disableGameAutoAFKButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
        disableGameAutoAFKButton.BackgroundColor3 = settings.disableGameAutoAFK and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
        disableGameAutoAFKButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        disableGameAutoAFKButton.Text = settings.disableGameAutoAFK and 'Disable Game Auto AFK: ON' or 'Disable Game Auto AFK: OFF'
        disableGameAutoAFKButton.TextSize = isMobile and 12 or 14
        disableGameAutoAFKButton.Font = Enum.Font.Ubuntu
        disableGameAutoAFKButton.AutoButtonColor = false
        disableGameAutoAFKButton.Parent = miscPage

        local disableGameAutoAFKCorner = Instance.new('UICorner')
        disableGameAutoAFKCorner.CornerRadius = UDim.new(0, 6)
        disableGameAutoAFKCorner.Parent = disableGameAutoAFKButton

        disableGameAutoAFKButton.MouseEnter:Connect(function()
            TweenService:Create(disableGameAutoAFKButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)

        disableGameAutoAFKButton.MouseLeave:Connect(function()
            local targetColor = settings.disableGameAutoAFK and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
            TweenService:Create(disableGameAutoAFKButton, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor
            }):Play()
        end)

        local function applyAFKState()
            local afkScript = localPlayer.PlayerScripts:FindFirstChild("AFK CLIENT")
            if afkScript then
                afkScript.Enabled = not settings.disableGameAutoAFK
            end
        end

        disableGameAutoAFKButton.MouseButton1Click:Connect(function()
            settings.disableGameAutoAFK = not settings.disableGameAutoAFK
            disableGameAutoAFKButton.Text = settings.disableGameAutoAFK and 'Disable Game Auto AFK: ON' or 'Disable Game Auto AFK: OFF'
            disableGameAutoAFKButton.BackgroundColor3 = settings.disableGameAutoAFK and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
            applyAFKState()
            saveSettings()
        end)

        -- Apply saved state on load
        task.spawn(function()
            task.wait(1) -- Wait for PlayerScripts to load
            applyAFKState()
        end)
    end

    initializeDisableGameAutoAFK()

    -- Function to search and equip tools
    local function spoofTools()
        local foundTools = {} -- Track found tool names to avoid duplicates
        
        -- Function to remove Aura/Aurra GUI elements from a tool
        local function cleanToolGUIs(tool)
            local function recursiveCleanup(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("ScreenGui") or child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                        local childName = string.lower(child.Name)
                        if childName == "aurra" or string.find(childName, "aura") then
                            child:Destroy()
                        else
                            recursiveCleanup(child) -- Check children of GUI elements
                        end
                    elseif child:GetChildren() and #child:GetChildren() > 0 then
                        recursiveCleanup(child) -- Recursively check all descendants
                    end
                end
            end
            
            recursiveCleanup(tool)
        end
        
        local function searchForTools(parent, depth)
            if depth > 3 then return end -- Prevent infinite recursion
            
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("Tool") then
                    local toolName = string.lower(child.Name)
                    
                    -- Skip tools containing "spit", "aura", or "carry", and avoid duplicates
                    if not string.find(toolName, "spit") and 
                    not string.find(toolName, "aura") and 
                    not string.find(toolName, "carry") and 
                    not foundTools[child.Name] then
                        
                        foundTools[child.Name] = true
                        
                        -- Clone and clean the tool
                        local clonedTool = child:Clone()
                        
                        -- Clean any Aura/Aurra GUI elements from the cloned tool
                        cleanToolGUIs(clonedTool)
                        
                        -- Equip the cleaned tool
                        clonedTool.Parent = Players.LocalPlayer.Backpack
                    end
                elseif child:IsA("Folder") or child:IsA("Model") then
                    -- Recursively search folders and models
                    searchForTools(child, depth + 1)
                end
            end
        end
        
        -- Search in workspace
        searchForTools(workspace, 0)
        
        -- Search in ReplicatedStorage
        searchForTools(game:GetService("ReplicatedStorage"), 0)
        
        -- Search in all players (their backpacks and characters)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                -- Search backpack
                searchForTools(player.Backpack, 0)
                
                -- Search character
                if player.Character then
                    searchForTools(player.Character, 0)
                end
            end
        end
        
        local toolCount = 0
        for _ in pairs(foundTools) do
            toolCount = toolCount + 1
        end
        
        -- Visual feedback
        spoofToolsButton.Text = 'Tools Spoofed! (' .. toolCount .. ')'
        task.wait(2)
        spoofToolsButton.Text = 'Spoof Tools'
    end

    -- Spoof Tools Button Click Handler
    spoofToolsButton.MouseButton1Click:Connect(function()
        spawn(function()
            spoofTools()
        end)
    end)

    -- Carry Player Function (with auto-equip) - Using body part method
local function carryNearestPlayer()
    local character = localPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    -- Try to get CarryFriend tool
    local tool = character:FindFirstChild("CarryFriend")
    if not tool then
        local backpack = localPlayer:FindFirstChild("Backpack")
        if backpack then
            local bpTool = backpack:FindFirstChild("CarryFriend")
            if bpTool then
                humanoid:EquipTool(bpTool)
                task.wait(0.15)
                tool = character:FindFirstChild("CarryFriend")
            end
        end
    end

    -- If CarryFriend tool is not available, exit
    if not tool then
        game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'CarryFriend Required',
            Text = 'You need the CarryFriend tool to carry players!',
            Duration = 3,
        })
        return
    end

    local remote = tool:FindFirstChild("Carry")
    if not remote then
        return
    end

    -- Find nearest player within 20 studs (max carry distance)
    local nearest = nil
    local nearestCharacter = nil
    local shortest = 20

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (root.Position - targetRoot.Position).Magnitude
                if distance < shortest then
                    shortest = distance
                    nearest = plr
                    nearestCharacter = plr.Character
                end
            end
        end
    end

    if nearest and nearestCharacter then
        -- Find the RightUpperLeg body part (or fallback to other parts)
        local targetPart = nearestCharacter:FindFirstChild("RightUpperLeg") or
                          nearestCharacter:FindFirstChild("LeftUpperLeg") or
                          nearestCharacter:FindFirstChild("RightLowerLeg") or
                          nearestCharacter:FindFirstChild("LeftLowerLeg") or
                          nearestCharacter:FindFirstChild("HumanoidRootPart")
        
        if not targetPart then
            return
        end

        -- Use body part method with PointerOnly
        local args = {
            "Carry",
            targetPart,
            "PointerOnly"
        }
        remote:FireServer(unpack(args))
    else
        return
    end
end
    -- Glitch Player Function (carry, teleport up, uncarry, return) - NEW APPROACH
function glitchNearestPlayer()
    local character = localPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    -- PRIORITY 1: Check if CarryFriend is equipped
    local carryFriend = character:FindFirstChild("CarryFriend")
    
    -- If not equipped, try to equip it
    if not carryFriend then
        local backpack = localPlayer:FindFirstChild("Backpack")
        if backpack then
            local tool = backpack:FindFirstChild("CarryFriend")
            if tool then
                humanoid:EquipTool(tool)
                task.wait(0.15)
                carryFriend = character:FindFirstChild("CarryFriend")
            end
        end
    end

    -- PRIORITY 2: If CarryFriend not available, check for cuffs
    local useCarry = false
    local useCuff = false
    local carryRemote = nil
    local cuffObject = nil
    local cuffRemote = nil

    if carryFriend then
        carryRemote = carryFriend:FindFirstChild("Carry")
        if carryRemote then
            useCarry = true
        end
    end

    -- If CarryFriend method not available, try cuffs
    if not useCarry then
        cuffObject = character:FindFirstChild('Cuffs')
        if not cuffObject then
            -- Search for any object containing "Cuff" in the name
            for _, child in pairs(character:GetChildren()) do
                if string.find(child.Name:lower(), 'cuff') then
                    cuffObject = child
                    break
                end
            end
        end
        
        if cuffObject then
            cuffRemote = cuffObject:FindFirstChild('RemoteEvent')
            if cuffRemote then
                useCuff = true
            end
        end
    end

    -- If neither method is available, show notification and return
    if not useCarry and not useCuff then
        return
    end

    -- Find nearest player within 150 studs
    local nearest = nil
    local nearestCharacter = nil
    local shortest = 150

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (root.Position - targetRoot.Position).Magnitude
                if distance < shortest then
                    shortest = distance
                    nearest = plr
                    nearestCharacter = plr.Character
                end
            end
        end
    end

    if not nearest or not nearestCharacter then
        return
    end

    -- Save original position
    local originalCFrame = root.CFrame

    -- Execute glitch based on available method
    if useCarry then
        -- METHOD 1: CarryFriend method (PRIORITY) - Body part approach
        -- Find the RightUpperLeg body part (or fallback to other parts)
        local targetPart = nearestCharacter:FindFirstChild("RightUpperLeg") or
                          nearestCharacter:FindFirstChild("LeftUpperLeg") or
                          nearestCharacter:FindFirstChild("RightLowerLeg") or
                          nearestCharacter:FindFirstChild("LeftLowerLeg") or
                          nearestCharacter:FindFirstChild("HumanoidRootPart")
        
        if not targetPart then return end

        -- Carry using body part with PointerOnly
        local carryArgs = {
            "Carry",
            targetPart,
            "PointerOnly"
        }
        carryRemote:FireServer(unpack(carryArgs))
        task.wait(0.2)

        -- Teleport high (into sky)
        root.CFrame = CFrame.new(0, 10000000, 0)
        task.wait(1.9)

        -- Uncarry
        carryRemote:FireServer(
            "Uncarry",
            nil,
            "PointerOnly"
        )
        task.wait(0.1)

        -- Return to original position
        root.CFrame = originalCFrame

    elseif useCuff then
        -- METHOD 2: Cuff method (BACKUP)
        -- Use HumanoidRootPart with PointerOnly parameter
        local targetPart = nearestCharacter:FindFirstChild('HumanoidRootPart')
        if not targetPart then return end

        -- Cuff the player with new approach
        local cuffArgs = {
            'Cuff',
            targetPart, -- HumanoidRootPart
            'PointerOnly'
        }
        cuffRemote:FireServer(unpack(cuffArgs))
        task.wait(0.2)

        -- Teleport high (into sky)
        root.CFrame = CFrame.new(0, 10000000, 0)
        task.wait(0.2)

        -- Uncuff the player with new approach
        local uncuffArgs = {
            'Uncuff',
            targetPart, -- HumanoidRootPart
            'PointerOnly'
        }
        cuffRemote:FireServer(unpack(uncuffArgs))
        task.wait(0.1)

        -- Return to original position
        root.CFrame = originalCFrame
    end
end

    contentPages["Misc"] = miscPage
    
    -- Load saved ESP states and apply them
    task.spawn(function()
        task.wait(0.5) -- Small delay to ensure everything is loaded
        if settings.espEnabled then
            enableESP()
            espButton.Text = 'ESP: ON'
            espButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
        if settings.espAdminsEnabled then
            enableAdminESP()
            espAdminsButton.Text = 'ESP Admins: ON'
            espAdminsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
        if settings.smartSpectateEnabled then
            smartSpectateEnabled = true
            smartSpectateButton.Text = 'Smart Spectate: ON'
            smartSpectateButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)

    -- Troll Page (Target System Features) - Wrapped in do block to avoid local limit
    local trollPage
    do
        trollPage = Instance.new('ScrollingFrame')
        trollPage.Name = 'TrollPage'
        trollPage.Size = UDim2.new(1, 0, 1, 0)
        trollPage.BackgroundTransparency = 1
        trollPage.Visible = false
        trollPage.ScrollBarThickness = 4
        trollPage.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        trollPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        trollPage.Parent = contentContainer

        -- Add UIListLayout to troll page for automatic sizing
        local trollLayout = Instance.new('UIListLayout')
        trollLayout.Padding = UDim.new(0, 10)
        trollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        trollLayout.Parent = trollPage

        -- Update canvas size when content changes
        trollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentHeight = trollLayout.AbsoluteContentSize.Y
            if contentHeight > 0 then
                trollPage.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
            end
        end)

        -- Target System Variables
        local CurrentTarget = nil
        local TalkConnection = nil

        -- Helper Functions for Target System
        local function FindPlayer(searchText)
            if searchText == "" then
                return nil
            end
            
            local searchLower = searchText:lower():match("^%s*(.-)%s*$")
            
            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    local nameLower = targetPlayer.Name:lower()
                    local displayLower = targetPlayer.DisplayName:lower()
                    
                    if nameLower:sub(1, #searchLower) == searchLower or 
                       displayLower:sub(1, #searchLower) == searchLower then
                        return targetPlayer
                    end
                end
            end
            
            return nil
        end

        local function GetCharacter(targetPlayer)
            return targetPlayer.Character
        end

    local function GetRoot(targetPlayer)
        local character = GetCharacter(targetPlayer)
        if character and character:FindFirstChild("HumanoidRootPart") then
            return character.HumanoidRootPart
        end
    end

    local function TeleportTo(target)
        pcall(function()
            local myRoot = GetRoot(player)
            if myRoot then
                myRoot.CFrame = CFrame.new(target.Position) + Vector3.new(0, 0.5, 0)
            end
        end)
    end

    -- Safe Teleport Function (like vr7 - teleports over 30 frames)
    local function SafeTeleportTo(x, y, z)
        pcall(function()
            task.spawn(function()
                for i = 1, 30 do
                    task.wait()
                    local root = GetRoot(player)
                    if root then
                        root.Velocity = Vector3.new(0, 0, 0)
                        root.CFrame = CFrame.new(x, y, z)
                    end
                end
            end)
        end)
    end

    -- Animation Functions
    local function PlayAnim(animId, timePos, speed, keepEnabled)
        pcall(function()
            if not keepEnabled then
                player.Character.Animate.Disabled = false
            end
            
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
                
                player.Character.Animate.Disabled = true
                
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. animId
                
                local track = humanoid:LoadAnimation(anim)
                track:Play()
                track.TimePosition = timePos or 0
                track:AdjustSpeed(speed or 1)
                
                track.Stopped:Connect(function()
                    player.Character.Animate.Disabled = false
                    anim:Destroy()
                end)
            end
        end)
    end

    local function StopAnim()
        pcall(function()
            player.Character.Animate.Disabled = false
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
        end)
    end

    local function CheckAnim(animId)
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId:match(tostring(animId)) then
                    return true
                end
            end
        end
        return false
    end

    -- Helper function to stop all troll features
    local function StopAllTrollFeatures()
        _G.ViewActive = false
        _G.FlingActive = false
        _G.FocusActive = false
        _G.JerkActive = false
        _G.BenxActive = false
        _G.HeadSitActive = false
        _G.StandActive = false
        _G.FuckActive = false
        _G.BackpackActive = false
    end

    -- Target Selection Container
    local targetContainer = Instance.new('Frame')
    targetContainer.Name = 'TargetContainer'
    targetContainer.Size = UDim2.new(1, -20, 0, 120)
    targetContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    targetContainer.BorderSizePixel = 0
    targetContainer.LayoutOrder = 1
    targetContainer.Parent = trollPage

    local targetContainerCorner = Instance.new('UICorner')
    targetContainerCorner.CornerRadius = UDim.new(0, 8)
    targetContainerCorner.Parent = targetContainer

    -- Target Title
    local targetTitle = Instance.new('TextLabel')
    targetTitle.Name = 'TargetTitle'
    targetTitle.Size = UDim2.new(1, -20, 0, 25)
    targetTitle.Position = UDim2.new(0, 10, 0, 5)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Text = ' Target Selection'
    targetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetTitle.TextSize = isMobile and 13 or 15
    targetTitle.Font = Enum.Font.GothamBold
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Parent = targetContainer

    -- Target Image
    local TargetImage = Instance.new('ImageLabel')
    TargetImage.Name = 'TargetImage'
    TargetImage.Size = UDim2.new(0, 60, 0, 60)
    TargetImage.Position = UDim2.new(0, 10, 0, 35)
    TargetImage.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    TargetImage.Image = 'rbxassetid://10818605405'
    TargetImage.Parent = targetContainer

    local imageCorner = Instance.new('UICorner')
    imageCorner.CornerRadius = UDim.new(0, 8)
    imageCorner.Parent = TargetImage

    -- Target Input
    local TargetInput = Instance.new('TextBox')
    TargetInput.Name = 'TargetInput'
    TargetInput.Size = UDim2.new(0, isMobile and 160 or 200, 0, 30)
    TargetInput.Position = UDim2.new(0, 80, 0, 35)
    TargetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    TargetInput.PlaceholderText = 'Enter username...'
    TargetInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    TargetInput.Text = ''
    TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetInput.TextSize = isMobile and 11 or 13
    TargetInput.Font = Enum.Font.Gotham
    TargetInput.Parent = targetContainer

    local inputCorner = Instance.new('UICorner')
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = TargetInput

    -- Target Info Label
    local TargetInfo = Instance.new('TextLabel')
    TargetInfo.Name = 'TargetInfo'
    TargetInfo.Size = UDim2.new(0, isMobile and 160 or 200, 0, 30)
    TargetInfo.Position = UDim2.new(0, 80, 0, 70)
    TargetInfo.BackgroundTransparency = 1
    TargetInfo.Text = 'No target selected'
    TargetInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
    TargetInfo.TextSize = isMobile and 9 or 11
    TargetInfo.Font = Enum.Font.Gotham
    TargetInfo.TextXAlignment = Enum.TextXAlignment.Left
    TargetInfo.TextYAlignment = Enum.TextYAlignment.Top
    TargetInfo.Parent = targetContainer

    -- Click Target Button
    local ClickTargetButton = Instance.new('TextButton')
    ClickTargetButton.Name = 'ClickTargetButton'
    ClickTargetButton.Size = UDim2.new(0, isMobile and 60 or 70, 0, 30)
    ClickTargetButton.Position = UDim2.new(1, isMobile and -70 or -80, 0, 35)
    ClickTargetButton.BackgroundColor3 = ACCENT_COLOR
    ClickTargetButton.Text = ' Click'
    ClickTargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClickTargetButton.TextSize = isMobile and 10 or 12
    ClickTargetButton.Font = Enum.Font.GothamBold
    ClickTargetButton.Parent = targetContainer

    local clickCorner = Instance.new('UICorner')
    clickCorner.CornerRadius = UDim.new(0, 6)
    clickCorner.Parent = ClickTargetButton

    -- Clear Target Button
    local ClearTargetButton = Instance.new('TextButton')
    ClearTargetButton.Name = 'ClearTargetButton'
    ClearTargetButton.Size = UDim2.new(0, isMobile and 60 or 70, 0, 30)
    ClearTargetButton.Position = UDim2.new(1, isMobile and -70 or -80, 0, 70)
    ClearTargetButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    ClearTargetButton.Text = ' Clear'
    ClearTargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClearTargetButton.TextSize = isMobile and 10 or 12
    ClearTargetButton.Font = Enum.Font.GothamBold
    ClearTargetButton.Parent = targetContainer

    local clearCorner = Instance.new('UICorner')
    clearCorner.CornerRadius = UDim.new(0, 6)
    clearCorner.Parent = ClearTargetButton

    -- Update Target Function
    local function UpdateTarget(targetPlayer)
        if targetPlayer then
            CurrentTarget = targetPlayer
            TargetInput.Text = targetPlayer.Name
            TargetInfo.Text = string.format(
                'UserID: %d\nDisplay: %s',
                targetPlayer.UserId,
                targetPlayer.DisplayName
            )
            
            pcall(function()
                local thumbType = Enum.ThumbnailType.HeadShot
                local thumbSize = Enum.ThumbnailSize.Size420x420
                local content, isReady = Players:GetUserThumbnailAsync(targetPlayer.UserId, thumbType, thumbSize)
                TargetImage.Image = content
            end)
            
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title = ' Target System',
                Text = 'Target: ' .. targetPlayer.Name,
                Duration = 2
            })
        end
    end
    getgenv().UpdateTarget = UpdateTarget

    -- Target Input Handler
    TargetInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local foundPlayer = FindPlayer(TargetInput.Text)
            if foundPlayer then
                UpdateTarget(foundPlayer)
            else
                game:GetService('StarterGui'):SetCore('SendNotification', {
                    Title = ' Target System',
                    Text = 'Player not found!',
                    Duration = 2
                })
            end
        end
    end)

    -- Click Target Tool
    ClickTargetButton.MouseButton1Click:Connect(function()
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool.Name == 'ClickTarget' then
                tool:Destroy()
            end
        end
        
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool.Name == 'ClickTarget' then
                tool:Destroy()
            end
        end
        
        local tool = Instance.new('Tool')
        tool.Name = 'ClickTarget'
        tool.RequiresHandle = false
        tool.TextureId = 'rbxassetid://13769558274'
        tool.ToolTip = 'Click on a player to target them'
        
        tool.Activated:Connect(function()
            local mouse = player:GetMouse()
            local target = mouse.Target
            local targetPlayer = nil
            
            if target and target.Parent then
                if target.Parent:IsA('Model') then
                    targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                elseif target.Parent:IsA('Accessory') and target.Parent.Parent then
                    targetPlayer = Players:GetPlayerFromCharacter(target.Parent.Parent)
                end
                
                if targetPlayer and targetPlayer ~= player then
                    UpdateTarget(targetPlayer)
                end
            end
        end)
        
        tool.Parent = player.Backpack
        
        game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = ' Target System',
            Text = 'Click Target tool equipped!',
            Duration = 2
        })
    end)

    -- Clear Target Handler
    ClearTargetButton.MouseButton1Click:Connect(function()
        CurrentTarget = nil
        TargetInput.Text = ''
        TargetInfo.Text = 'No target selected'
        TargetImage.Image = 'rbxassetid://10818605405'
        
        _G.LoopTeleporting = false
        _G.RepeatTalkActive = false
        StopAllTrollFeatures()
        
        if TalkConnection then
            TalkConnection:Disconnect()
            TalkConnection = nil
        end
        
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        workspace.FallenPartsDestroyHeight = -500
        StopAnim()
        
        pcall(function()
            player.Character:FindFirstChildOfClass('Humanoid').Sit = false
        end)
        
        game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = ' Target System',
            Text = 'All features stopped',
            Duration = 2
        })
    end)

    -- Troll Features Container
    local trollFeaturesTitle = Instance.new('TextLabel')
    trollFeaturesTitle.Name = 'TrollFeaturesTitle'
    trollFeaturesTitle.Size = UDim2.new(1, -20, 0, 30)
    trollFeaturesTitle.BackgroundTransparency = 1
    trollFeaturesTitle.Text = ' Troll Features'
    trollFeaturesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    trollFeaturesTitle.TextSize = isMobile and 13 or 15
    trollFeaturesTitle.Font = Enum.Font.GothamBold
    trollFeaturesTitle.TextXAlignment = Enum.TextXAlignment.Left
    trollFeaturesTitle.LayoutOrder = 2
    trollFeaturesTitle.Parent = trollPage

    -- Declare button variables
    local ViewButton, VoiceSpectateButton, TeleportButton
    local JerkButton, BenxButton, HeadSitButton, StandButton
    local FuckButton, BackpackButton

    -- Helper function to reset all button colors
    local function ResetTrollButtonColors()
        if ViewButton then
            ViewButton.BackgroundColor3 = ACCENT_COLOR
            ViewButton.Text = ' Spectate'
        end
        if VoiceSpectateButton then
            VoiceSpectateButton.BackgroundColor3 = ACCENT_COLOR
            VoiceSpectateButton.Text = ' Voice Spectate'
        end
        if JerkButton then
            JerkButton.BackgroundColor3 = ACCENT_COLOR
            JerkButton.Text = ' Jerk'
        end
        if BenxButton then
            BenxButton.BackgroundColor3 = ACCENT_COLOR
            BenxButton.Text = ' Benx'
        end
        if HeadSitButton then
            HeadSitButton.BackgroundColor3 = ACCENT_COLOR
            HeadSitButton.Text = ' Head Sit'
        end
        if StandButton then
            StandButton.BackgroundColor3 = ACCENT_COLOR
            StandButton.Text = ' Blowjob'
        end
        if FuckButton then
            FuckButton.BackgroundColor3 = ACCENT_COLOR
            FuckButton.Text = ' Get fucked'
        end
        if BackpackButton then
            BackpackButton.BackgroundColor3 = ACCENT_COLOR
            BackpackButton.Text = ' Backpack'
        end
    end

    -- Create Troll Buttons
    -- 2-column grid container for troll buttons
    local trollButtonsContainer = Instance.new('Frame')
    trollButtonsContainer.Name = 'TrollButtonsContainer'
    trollButtonsContainer.BackgroundTransparency = 1
    trollButtonsContainer.Size = UDim2.new(1, -20, 0, 0)
    trollButtonsContainer.AutomaticSize = Enum.AutomaticSize.Y
    trollButtonsContainer.LayoutOrder = 3
    trollButtonsContainer.Parent = trollPage

    local trollButtonsGrid = Instance.new('UIGridLayout')
    trollButtonsGrid.CellSize = UDim2.new(0.5, -6, 0, isMobile and 35 or 40)
    trollButtonsGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    trollButtonsGrid.SortOrder = Enum.SortOrder.LayoutOrder
    trollButtonsGrid.FillDirection = Enum.FillDirection.Horizontal
    trollButtonsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    trollButtonsGrid.Parent = trollButtonsContainer

    -- Button Creator Function
    local function CreateTrollButton(name, text, layoutOrder, callback)
        local button = Instance.new('TextButton')
        button.Name = name
        button.Size = UDim2.new(1, 0, 1, 0) -- controlled by UIGridLayout
        button.BackgroundColor3 = ACCENT_COLOR
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = isMobile and 12 or 14
        button.Font = Enum.Font.GothamBold
        button.AutoButtonColor = false
        button.LayoutOrder = layoutOrder
        button.Parent = trollButtonsContainer
        
        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            if button.BackgroundColor3 ~= Color3.fromRGB(250, 100, 100) then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(math.min(ACCENT_COLOR.R * 255 + 30, 255)/255, 
                                                      math.min(ACCENT_COLOR.G * 255 + 30, 255)/255, 
                                                      math.min(ACCENT_COLOR.B * 255 + 30, 255)/255)
                }):Play()
            end
        end)
        
        button.MouseLeave:Connect(function()
            if button.BackgroundColor3 ~= Color3.fromRGB(250, 100, 100) then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = ACCENT_COLOR
                }):Play()
            end
        end)
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end

    -- Store disabled scripts for Troll tab spectate features
    local trollDisabledScripts = {}
    
    -- Scripts to exclude from disabling (whitelist)
    local trollExcludedScripts = {
           ["MainMenuController"] = true,
        ["ServerListBtn"] = true,
        ["InviteIcon"] = true,
        ["Rotate"] = true
    }

    -- Helper: show the developer-protection warning dialog
    local function showProtectedWarning()
        -- Destroy any existing protected warning dialog first
        if game:GetService('CoreGui'):FindFirstChild('ProtectedWarningGui') then
            return
        end

        local DISCORD_LINK = 'https://discord.gg/Szmt9zweGF'

        local warningGui = Instance.new('ScreenGui')
        warningGui.Name = 'ProtectedWarningGui'
        warningGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        warningGui.IgnoreGuiInset = true
        warningGui.Parent = game:GetService('CoreGui')

        -- Background overlay
        local overlay = Instance.new('Frame')
        overlay.Name = 'Overlay'
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.Position = UDim2.new(0, 0, 0, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.3
        overlay.BorderSizePixel = 0
        overlay.Parent = warningGui

        -- Dialog frame
        local dialogFrame = Instance.new('Frame')
        dialogFrame.Name = 'DialogFrame'
        dialogFrame.Size = UDim2.new(0, 420, 0, 220)
        dialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        dialogFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 35)
        dialogFrame.BorderSizePixel = 0
        dialogFrame.Parent = overlay

        local dialogCorner = Instance.new('UICorner')
        dialogCorner.CornerRadius = UDim.new(0, 12)
        dialogCorner.Parent = dialogFrame

        local dialogBorder = Instance.new('UIStroke')
        dialogBorder.Color = Color3.fromRGB(180, 60, 200)
        dialogBorder.Thickness = 2
        dialogBorder.Parent = dialogFrame

        -- Title
        local title = Instance.new('TextLabel')
        title.Name = 'Title'
        title.Size = UDim2.new(1, -20, 0, 35)
        title.Position = UDim2.new(0, 10, 0, 12)
        title.BackgroundTransparency = 1
        title.Text = 'Protected Player'
        title.TextColor3 = Color3.fromRGB(220, 120, 255)
        title.TextSize = 18
        title.Font = Enum.Font.Ubuntu
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = dialogFrame

        -- Message
        local message = Instance.new('TextLabel')
        message.Name = 'Message'
        message.Size = UDim2.new(1, -30, 0, 80)
        message.Position = UDim2.new(0, 15, 0, 52)
        message.BackgroundTransparency = 1
        message.Text = 'You cannot target this player as he/she is protected by the script developer.\n\nYou can also buy this protection from our Discord server:'
        message.TextColor3 = Color3.fromRGB(220, 220, 230)
        message.TextSize = 13
        message.Font = Enum.Font.Ubuntu
        message.TextXAlignment = Enum.TextXAlignment.Center
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.TextWrapped = true
        message.Parent = dialogFrame

        -- Discord link label
        local linkLabel = Instance.new('TextLabel')
        linkLabel.Name = 'LinkLabel'
        linkLabel.Size = UDim2.new(1, -30, 0, 20)
        linkLabel.Position = UDim2.new(0, 15, 0, 130)
        linkLabel.BackgroundTransparency = 1
        linkLabel.Text = DISCORD_LINK
        linkLabel.TextColor3 = Color3.fromRGB(88, 169, 255)
        linkLabel.TextSize = 12
        linkLabel.Font = Enum.Font.Ubuntu
        linkLabel.TextXAlignment = Enum.TextXAlignment.Center
        linkLabel.TextWrapped = true
        linkLabel.Parent = dialogFrame

        -- OK button
        local okButton = Instance.new('TextButton')
        okButton.Name = 'OKButton'
        okButton.Size = UDim2.new(0, 90, 0, 32)
        okButton.Position = UDim2.new(0.5, -100, 1, -50)
        okButton.BackgroundColor3 = Color3.fromRGB(53, 9, 211)
        okButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        okButton.Text = 'OK'
        okButton.TextSize = 15
        okButton.Font = Enum.Font.Ubuntu
        okButton.AutoButtonColor = false
        okButton.Parent = dialogFrame

        local okCorner = Instance.new('UICorner')
        okCorner.CornerRadius = UDim.new(0, 6)
        okCorner.Parent = okButton

        okButton.MouseEnter:Connect(function()
            TweenService:Create(okButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(73, 29, 231)
            }):Play()
        end)

        okButton.MouseLeave:Connect(function()
            TweenService:Create(okButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(53, 9, 211)
            }):Play()
        end)

        okButton.MouseButton1Click:Connect(function()
            warningGui:Destroy()
        end)

        -- Copy Link button
        local copyButton = Instance.new('TextButton')
        copyButton.Name = 'CopyLinkButton'
        copyButton.Size = UDim2.new(0, 110, 0, 32)
        copyButton.Position = UDim2.new(0.5, 20, 1, -50)
        copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyButton.Text = 'Copy Link'
        copyButton.TextSize = 15
        copyButton.Font = Enum.Font.Ubuntu
        copyButton.AutoButtonColor = false
        copyButton.Parent = dialogFrame

        local copyCorner = Instance.new('UICorner')
        copyCorner.CornerRadius = UDim.new(0, 6)
        copyCorner.Parent = copyButton

        copyButton.MouseEnter:Connect(function()
            TweenService:Create(copyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            }):Play()
        end)

        copyButton.MouseLeave:Connect(function()
            TweenService:Create(copyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            }):Play()
        end)

        copyButton.MouseButton1Click:Connect(function()
            pcall(function()
                setclipboard(DISCORD_LINK)
            end)
            -- Brief "Copied!" feedback
            copyButton.Text = 'Copied!'
            task.delay(1.5, function()
                if copyButton and copyButton.Parent then
                    copyButton.Text = 'Copy Link'
                end
            end)
        end)

        -- Click overlay to dismiss
        overlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                warningGui:Destroy()
            end
        end)
    end
    
    -- Function to disable scripts before spectating (Troll tab version)
    local function disableTrollPlayerScripts()
        trollDisabledScripts = {} -- Clear previous data
        
        -- Disable scripts in PlayerScripts
        if player:FindFirstChild("PlayerScripts") then
            for _, obj in ipairs(player.PlayerScripts:GetDescendants()) do
                if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Enabled then
                    -- Skip excluded scripts
                    if not trollExcludedScripts[obj.Name] then
                        table.insert(trollDisabledScripts, obj)
                        obj.Enabled = false
                    end
                end
            end
        end
        
        -- Disable scripts in PlayerGui
        if player:FindFirstChild("PlayerGui") then
            for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
                if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Enabled then
                    -- Skip excluded scripts
                    if not trollExcludedScripts[obj.Name] then
                        table.insert(trollDisabledScripts, obj)
                        obj.Enabled = false
                    end
                end
            end
        end
        
        -- Disable scripts in Character
        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Enabled then
                    -- Skip excluded scripts
                    if not trollExcludedScripts[obj.Name] then
                        table.insert(trollDisabledScripts, obj)
                        obj.Enabled = false
                    end
                end
            end
        end
    end
    
    -- Function to re-enable scripts after unspectating (Troll tab version)
    local function enableTrollPlayerScripts()
        for _, scriptObj in ipairs(trollDisabledScripts) do
            if scriptObj and scriptObj.Parent then -- Check if script still exists
                scriptObj.Enabled = true
            end
        end
        trollDisabledScripts = {} -- Clear the list
    end

    -- Remote Event Blocker (blocks all FireServer calls while spectating)
    -- Note: executor support is already guaranteed by the top-of-script capability check
    local _trollRemoteBlocked = false
    local _trollOldNamecall = nil
    local _trollRemoteHookSupported = true

    local function blockRemoteEvents()
        if not _trollRemoteHookSupported then return end
        if _trollRemoteBlocked then return end
        pcall(function()
            local mt = getrawmetatable(game)
            _trollOldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    return -- block all outgoing remote calls
                end
                return _trollOldNamecall(self, ...)
            end)
            setreadonly(mt, true)
            _trollRemoteBlocked = true
        end)
    end

    local function unblockRemoteEvents()
        if not _trollRemoteHookSupported then return end
        if not _trollRemoteBlocked then return end
        pcall(function()
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__namecall = _trollOldNamecall
            setreadonly(mt, true)
            _trollOldNamecall = nil
            _trollRemoteBlocked = false
        end)
    end

    -- View Target Button
    -- Spectate Target Button (using same logic as main tab)
    ViewButton = CreateTrollButton('SpectateButton', ' Spectate', 3, function()
        if CurrentTarget then
            if not _G.SpectateActive then
                -- Check if target is protected
                if isPlayerProtected(CurrentTarget) then
                    showProtectedWarning()
                    return
                end

                _G.SpectateActive = true
                ViewButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                ViewButton.Text = ' Unspectate'

                -- Only disable scripts if spectate bypass is enabled
                if getgenv().spectateBypassEnabled then
                    disableTrollPlayerScripts()
                    blockRemoteEvents()
                end

                -- Set camera subject
                pcall(function()
                    local camera = workspace.CurrentCamera
                    if camera and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild('Humanoid') then
                        camera.CameraSubject = CurrentTarget.Character.Humanoid
                    end
                end)

                -- Monitor target respawn
                task.spawn(function()
                    while _G.SpectateActive and CurrentTarget do
                        pcall(function()
                            if CurrentTarget.Character then
                                local humanoid = CurrentTarget.Character:FindFirstChildOfClass('Humanoid')
                                if humanoid and workspace.CurrentCamera then
                                    workspace.CurrentCamera.CameraSubject = humanoid
                                end
                            end
                        end)
                        task.wait(0.5)
                    end

                    -- Re-enable all scripts when stopped
                    if getgenv().spectateBypassEnabled then
                        enableTrollPlayerScripts()
                        unblockRemoteEvents()
                    end
                end)
            else
                _G.SpectateActive = false
                ViewButton.BackgroundColor3 = ACCENT_COLOR
                ViewButton.Text = ' Spectate'

                -- Re-enable scripts
                if getgenv().spectateBypassEnabled then
                    enableTrollPlayerScripts()
                    unblockRemoteEvents()
                end

                -- Restore camera
                workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild('Humanoid')
            end
        end
    end)

    -- Voice Spectate Button (Focus camera while under target)
    VoiceSpectateButton = CreateTrollButton('VoiceSpectateButton', ' Voice Spectate', 4, function()
        if CurrentTarget then
            -- Check if target is protected
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end

            if not _G.VoiceSpectateActive then
                StopAllTrollFeatures()
                ResetTrollButtonColors()
                
                _G.VoiceSpectateActive = true
                VoiceSpectateButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                VoiceSpectateButton.Text = ' Stop'

                -- CurrentTarget is already a Player object
                local targetPlayer = CurrentTarget
                
                -- Verify target is still valid
                if not targetPlayer or not targetPlayer.Parent then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Error",
                        Text = "Target not found!",
                        Duration = 3
                    })
                    _G.VoiceSpectateActive = false
                    VoiceSpectateButton.BackgroundColor3 = ACCENT_COLOR
                    VoiceSpectateButton.Text = ' Voice Spectate'
                    return
                end

                -- Disable all scripts (respecting whitelist)
                disableTrollPlayerScripts()

                -- Block all outgoing remote events while voice spectating
                blockRemoteEvents()

                -- Make local character invisible (save original transparencies)
                local _vsOriginalTransparency = {}
                pcall(function()
                    if player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                _vsOriginalTransparency[part] = part.Transparency
                                part.Transparency = 1
                            elseif part:IsA("Decal") or part:IsA("Texture") then
                                _vsOriginalTransparency[part] = part.Transparency
                                part.Transparency = 1
                            elseif part:IsA("SpecialMesh") or part:IsA("BlockMesh") then
                                -- meshes on parts are handled via parent BasePart above
                            end
                        end
                        -- Also hide the HumanoidRootPart
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            _vsOriginalTransparency[hrp] = hrp.Transparency
                            hrp.Transparency = 1
                        end
                    end
                end)
                getgenv()._vsOriginalTransparency = _vsOriginalTransparency

                -- Save old position
                getgenv().VoiceSpectateOldCF = player.Character.HumanoidRootPart.Position

                game.StarterGui:SetCore("SendNotification", {
                    Title = "Voice Spectate",
                    Text = "Following " .. targetPlayer.Name,
                    Duration = 3
                })

                spawn(function()
                    while _G.VoiceSpectateActive do
                        pcall(function()
                            local targetChar = GetCharacter(targetPlayer)
                            local root = GetRoot(player)
                            
                            if targetChar and root and targetChar:FindFirstChild("Head") then
                                -- Position under target's head with 180 degree rotation
                                root.CFrame = targetChar.Head.CFrame * CFrame.new(0, -20, 0) * CFrame.Angles(math.rad(180), 0, 0)
                                
                                -- Set camera to target
                                if targetChar:FindFirstChild("Humanoid") then
                                    workspace.CurrentCamera.CameraSubject = targetChar.Humanoid
                                end
                            end
                        end)
                        task.wait()
                    end

                    -- Restore camera and teleport back
                    pcall(function()
                        local root = GetRoot(player)
                        if root and root.Parent:FindFirstChild("Humanoid") then
                            workspace.CurrentCamera.CameraSubject = root.Parent.Humanoid
                        end

                        if getgenv().VoiceSpectateOldCF then
                            -- Use safe teleport to prevent death from falling
                            SafeTeleportTo(getgenv().VoiceSpectateOldCF.X, getgenv().VoiceSpectateOldCF.Y, getgenv().VoiceSpectateOldCF.Z)
                            task.wait(0.1)
                            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                    end)
                    
                    -- Re-enable all scripts
                    enableTrollPlayerScripts()
                    -- Unblock remote events
                    unblockRemoteEvents()
                    -- Restore character visibility
                    pcall(function()
                        local saved = getgenv()._vsOriginalTransparency
                        if saved then
                            for part, orig in pairs(saved) do
                                if part and part.Parent then
                                    part.Transparency = orig
                                end
                            end
                            getgenv()._vsOriginalTransparency = nil
                        end
                    end)
                end)
            else
                _G.VoiceSpectateActive = false
                VoiceSpectateButton.BackgroundColor3 = ACCENT_COLOR
                VoiceSpectateButton.Text = ' Voice Spectate'
                
                -- Re-enable scripts
                enableTrollPlayerScripts()
                
                -- Unblock remote events
                unblockRemoteEvents()
                
                -- Restore character visibility
                pcall(function()
                    local saved = getgenv()._vsOriginalTransparency
                    if saved then
                        for part, orig in pairs(saved) do
                            if part and part.Parent then
                                part.Transparency = orig
                            end
                        end
                        getgenv()._vsOriginalTransparency = nil
                    end
                end)
            end
        end
    end)

    -- Jerk On Target Button
    JerkButton = CreateTrollButton('JerkButton', ' Jerk', 5, function()
        if CurrentTarget then
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end
            if not _G.JerkActive then
                StopAllTrollFeatures()
                ResetTrollButtonColors()
                
                _G.JerkActive = true
                JerkButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                JerkButton.Text = ' Stop'
                
                task.spawn(function()
                    workspace.FallenPartsDestroyHeight = 0 / 0
                    
                    task.spawn(function()
                        while _G.JerkActive do
                            pcall(function()
                                local myHumanoid = player.Character:FindFirstChildOfClass('Humanoid')
                                if myHumanoid and myHumanoid.Health > 0 then
                                    if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
                                        PlayAnim(698251653, 0.6, 0.4, true)
                                        task.wait(0.16)
                                    else
                                        PlayAnim(72042024, 0.675, 1, true)
                                        task.wait(0.4)
                                    end
                                end
                            end)
                            task.wait()
                        end
                        StopAnim()
                    end)
                    
                    while _G.JerkActive and CurrentTarget do
                        pcall(function()
                            local targetRoot = GetRoot(CurrentTarget)
                            local myRoot = GetRoot(player)
                            local myHumanoid = player.Character:FindFirstChildOfClass('Humanoid')
                            
                            if targetRoot and myRoot and myHumanoid and myHumanoid.Health > 0 then
                                myHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                                if not myHumanoid.Sit then
                                    myHumanoid.Sit = true
                                end
                                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 1, -3) * CFrame.Angles(0, math.pi, 0)
                                myRoot.Velocity = Vector3.new(0, 0, 0)
                            end
                        end)
                        task.wait()
                    end
                    
                    workspace.FallenPartsDestroyHeight = -500
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            else
                _G.JerkActive = false
                JerkButton.BackgroundColor3 = ACCENT_COLOR
                JerkButton.Text = ' Jerk'
                workspace.FallenPartsDestroyHeight = -500
                StopAnim()
                pcall(function()
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            end
        end
    end)

    -- Benx Target Button
    BenxButton = CreateTrollButton('BenxButton', ' Benx', 6, function()
        if CurrentTarget then
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end
            if not _G.BenxActive then
                StopAllTrollFeatures()
                ResetTrollButtonColors()
                
                _G.BenxActive = true
                BenxButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                BenxButton.Text = ' Stop'
                
                task.spawn(function()
                    workspace.FallenPartsDestroyHeight = 0 / 0
                    
                    while _G.BenxActive and CurrentTarget do
                        pcall(function()
                            local targetChar = CurrentTarget.Character
                            local targetTorso = targetChar and (targetChar:FindFirstChild('Torso') or targetChar:FindFirstChild('UpperTorso'))
                            local myRoot = GetRoot(player)
                            local myHumanoid = player.Character:FindFirstChildOfClass('Humanoid')
                            
                            if targetTorso and myRoot and myHumanoid then
                                myRoot.Velocity = Vector3.new()
                                local offset = math.sin(tick() * 20) * 0.6
                                myRoot.CFrame = targetTorso.CFrame * CFrame.new(0, 0, 2 + offset)
                                
                                if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
                                    if not CheckAnim('5918726674') then
                                        PlayAnim(5918726674, 0, 2)
                                    end
                                elseif not myHumanoid.Sit or not CheckAnim('148840371') then
                                    if myHumanoid.Sit and not CheckAnim('148840371') then
                                        PlayAnim(148840371, 0, 3.7)
                                    end
                                end
                                
                                myHumanoid.Sit = true
                                myRoot.CFrame = targetTorso.CFrame * CFrame.new(0, 0, 1)
                                myRoot.Velocity = Vector3.new(0, 0, 0)
                            end
                        end)
                        task.wait()
                    end
                    
                    workspace.FallenPartsDestroyHeight = -500
                    StopAnim()
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            else
                _G.BenxActive = false
                BenxButton.BackgroundColor3 = ACCENT_COLOR
                BenxButton.Text = ' Benx'
                workspace.FallenPartsDestroyHeight = -500
                StopAnim()
                pcall(function()
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            end
        end
    end)

    -- Head Sit Target Button
    HeadSitButton = CreateTrollButton('HeadSitButton', ' Head Sit', 7, function()
        if CurrentTarget then
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end
            if not _G.HeadSitActive then
                StopAllTrollFeatures()
                ResetTrollButtonColors()
                
                _G.HeadSitActive = true
                HeadSitButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                HeadSitButton.Text = ' Stop'
                
                task.spawn(function()
                    while _G.HeadSitActive and CurrentTarget do
                        pcall(function()
                            local targetHead = CurrentTarget.Character:FindFirstChild('Head')
                            local myRoot = GetRoot(player)
                            local myHumanoid = player.Character:FindFirstChildOfClass('Humanoid')
                            
                            if targetHead and myRoot and myHumanoid then
                                myHumanoid.Sit = true
                                myRoot.CFrame = targetHead.CFrame * CFrame.new(0, 2, 0)
                                myRoot.Velocity = Vector3.new(0, 0, 0)
                            end
                        end)
                        task.wait()
                    end
                    
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            else
                _G.HeadSitActive = false
                HeadSitButton.BackgroundColor3 = ACCENT_COLOR
                HeadSitButton.Text = ' Head Sit'
                pcall(function()
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            end
        end
    end)

    -- Stand Target Button
    StandButton = CreateTrollButton('StandButton', ' Blowjob', 8, function()
        if CurrentTarget then
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end
            if not _G.StandActive then
                StopAllTrollFeatures()
                ResetTrollButtonColors()
                
                _G.StandActive = true
                StandButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                StandButton.Text = ' Stop'
                
                task.spawn(function()
                    for _, track in pairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end
                    
                    local offsetY = -2
                    local speed = 0.3
                    
                    while _G.StandActive and CurrentTarget do
                        task.wait(0.01)
                        pcall(function()
                            local targetHead = CurrentTarget.Character:FindFirstChild('Head')
                            local myRoot = GetRoot(player)
                            local myHumanoid = player.Character:FindFirstChildOfClass('Humanoid')
                            
                            if targetHead and myRoot and myHumanoid then
                                myHumanoid.Sit = true
                                myRoot.CFrame = targetHead.CFrame * CFrame.new(0, 0.7, offsetY) * CFrame.Angles(0, math.rad(180), 0)
                                myRoot.Velocity = Vector3.new(0, 0, 0)
                                
                                offsetY = offsetY + speed
                                if offsetY >= -1 or offsetY <= -2 then
                                    speed = -speed
                                end
                            end
                        end)
                    end
                    
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            else
                _G.StandActive = false
                StandButton.BackgroundColor3 = ACCENT_COLOR
                StandButton.Text = ' Blowjob'
                pcall(function()
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            end
        end
    end)

    -- Fuck Target Button
    FuckButton = CreateTrollButton('FuckButton', ' Get fucked', 9, function()
        if CurrentTarget then
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end
            if not _G.FuckActive then
                StopAllTrollFeatures()
                ResetTrollButtonColors()
                
                _G.FuckActive = true
                FuckButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                FuckButton.Text = ' Stop'
                
                task.spawn(function()
                    for _, track in pairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end
                    
                    local offsetY = -1
                    local offsetZ = -2
                    local speedZ = 0.1
                    
                    while _G.FuckActive and CurrentTarget do
                        pcall(function()
                            local targetTorso = CurrentTarget.Character:FindFirstChild('Torso') or CurrentTarget.Character:FindFirstChild('UpperTorso')
                            local myRoot = GetRoot(player)
                            local myHumanoid = player.Character:FindFirstChildOfClass('Humanoid')
                            
                            if targetTorso and myRoot and myHumanoid then
                                if targetTorso.Name == 'Torso' then
                                    offsetY = -0.75
                                end
                                
                                myHumanoid.Sit = true
                                myRoot.CFrame = targetTorso.CFrame * CFrame.new(0, offsetY, offsetZ) * CFrame.Angles(math.rad(270), 0, 0)
                                myRoot.Velocity = Vector3.new(0, 0, 0)
                                
                                offsetZ = offsetZ + speedZ
                                if offsetZ >= -1 or offsetZ <= -2 then
                                    speedZ = -speedZ
                                end
                            end
                        end)
                        task.wait()
                    end
                    
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            else
                _G.FuckActive = false
                FuckButton.BackgroundColor3 = ACCENT_COLOR
                FuckButton.Text = ' Get fucked'
                pcall(function()
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            end
        end
    end)

    -- Backpack Target Button
    BackpackButton = CreateTrollButton('BackpackButton', ' Backpack', 10, function()
        if CurrentTarget then
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end
            if not _G.BackpackActive then
                StopAllTrollFeatures()
                ResetTrollButtonColors()
                
                _G.BackpackActive = true
                BackpackButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
                BackpackButton.Text = ' Stop'
                
                task.spawn(function()
                    while _G.BackpackActive and CurrentTarget do
                        pcall(function()
                            local targetRoot = GetRoot(CurrentTarget)
                            local myRoot = GetRoot(player)
                            local myHumanoid = player.Character:FindFirstChildOfClass('Humanoid')
                            
                            if targetRoot and myRoot and myHumanoid then
                                myHumanoid.Sit = true
                                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(0, -3, 0)
                                myRoot.Velocity = Vector3.new(0, 0, 0)
                            end
                        end)
                        task.wait()
                    end
                    
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            else
                _G.BackpackActive = false
                BackpackButton.BackgroundColor3 = ACCENT_COLOR
                BackpackButton.Text = ' Backpack'
                pcall(function()
                    player.Character:FindFirstChildOfClass('Humanoid').Sit = false
                end)
            end
        end
    end)

    -- Teleport Button (Last button)
    TeleportButton = CreateTrollButton('TeleportButton', ' Teleport', 11, function()
        if CurrentTarget then
            if isPlayerProtected(CurrentTarget) then
                showProtectedWarning()
                return
            end
            TeleportTo(GetRoot(CurrentTarget))
        end
    end)

        contentPages["Troll"] = trollPage
    end -- End of do block for troll page

    -- Settings Page (Keybinds and configuration)
    local settingsPage = Instance.new('ScrollingFrame')
    settingsPage.Name = 'SettingsPage'
    settingsPage.Size = UDim2.new(1, 0, 1, 0)
    settingsPage.BackgroundTransparency = 1
    settingsPage.Visible = false
    settingsPage.ScrollBarThickness = 4
    settingsPage.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    settingsPage.CanvasSize = UDim2.new(0, 0, 0, 0) -- Start with no canvas size
    settingsPage.Parent = contentContainer

    -- Add UIListLayout to settings page for automatic sizing
    local settingsLayout = Instance.new('UIListLayout')
    settingsLayout.Padding = UDim.new(0, 10)
    settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    settingsLayout.Parent = settingsPage

    -- Update canvas size when content changes
    settingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = settingsLayout.AbsoluteContentSize.Y
        if contentHeight > 0 then
            settingsPage.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 200) -- Increased padding to 200 for more scroll space
        end
    end)

    -- Settings Title
    local settingsTitle = Instance.new('TextLabel')
    settingsTitle.Name = 'SettingsTitle'
    settingsTitle.Size = UDim2.new(1, -20, 0, 30)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = 'Settings & Keybinds'
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = isMobile and 14 or 16
    settingsTitle.Font = Enum.Font.Ubuntu
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.LayoutOrder = 1
    settingsTitle.Parent = settingsPage

    -- Keybinds Container
    local keybindsContainer = Instance.new('Frame')
    keybindsContainer.Name = 'KeybindsContainer'
    keybindsContainer.Size = UDim2.new(1, -20, 0, 200) -- Fixed height instead of relative
    keybindsContainer.BackgroundTransparency = 1
    keybindsContainer.LayoutOrder = 3
    keybindsContainer.Parent = settingsPage

    local keybindsLayout = Instance.new('UIListLayout')
    keybindsLayout.Padding = UDim.new(0, 10)
    keybindsLayout.Parent = keybindsContainer

    -- Load saved keybinds
    local keybindsLoaded = loadKeybinds()

    -- Only save keybinds if loading failed to create default file
    if not keybindsLoaded then
        task.wait(0.1) -- Small delay to ensure keybinds table is fully initialized
        saveKeybinds()
    end

    -- Update key variables based on loaded keybinds (global variables)
    TOGGLE_KEY = (keybinds.toggleMenu ~= "unset") and Enum.KeyCode[keybinds.toggleMenu] or nil
    FLY_TOGGLE_KEY = (keybinds.toggleFly ~= "unset") and Enum.KeyCode[keybinds.toggleFly] or nil
    CUFF_KEY = (keybinds.cuffNearest ~= "unset") and Enum.KeyCode[keybinds.cuffNearest] or nil
    RESET_KEY = (keybinds.resetCharacter ~= "unset") and Enum.KeyCode[keybinds.resetCharacter] or nil
    CARRY_KEY = (keybinds.carryPlayer ~= "unset") and Enum.KeyCode[keybinds.carryPlayer] or nil
  GLITCH_KEY = (keybinds.glitchPlayer ~= "unset") and Enum.KeyCode[keybinds.glitchPlayer] or nil
    INVISIBLE_KEY = (keybinds.toggleInvisible ~= "unset") and Enum.KeyCode[keybinds.toggleInvisible] or nil

    -- Keybind Functions
    local function cuffNearestPlayer()
        local nearestPlayer = getNearestPlayer()
        if nearestPlayer then
            if isPlayerProtected(nearestPlayer) then
                showProtectedWarning()
                return
            end
            
            -- Target HumanoidRootPart directly (new approach)
            local targetPart = nearestPlayer.Character and nearestPlayer.Character:FindFirstChild('HumanoidRootPart')
            if targetPart then
                -- Check for cuff object (exact name first, then any containing "Cuff")
                local cuffObject = nil
                if localPlayer.Character then
                    cuffObject = localPlayer.Character:FindFirstChild('Cuffs')
                    if not cuffObject then
                        -- Search for any object containing "Cuff" in the name (like CuffsCat)
                        for _, child in pairs(localPlayer.Character:GetChildren()) do
                            if string.find(child.Name:lower(), 'cuff') then
                                cuffObject = child
                                break
                            end
                        end
                    end
                end
                
                if cuffObject then
                    -- New approach: Use HumanoidRootPart with PointerOnly parameter
                    local args = {
                        'Cuff',
                        targetPart, -- HumanoidRootPart
                        'PointerOnly'
                    }
                    local remoteEvent = cuffObject:FindFirstChild('RemoteEvent')
                    if remoteEvent then
                        remoteEvent:FireServer(unpack(args))
                    end
                else
                    -- Show notification that handcuffs must be equipped
                    game:GetService('StarterGui'):SetCore('SendNotification', {
                        Title = 'Handcuffs Required',
                        Text = 'You must have the handcuffs equipped to cuff players!',
                        Duration = 3,
                    })
                end
            end
        end
    end

    local function resetCharacter()
        task.spawn(sendReCommand)
    end

    -- Function to create keybind setting
    local function createKeybindSetting(name, currentKey, description, onUpdate)
        local settingFrame = Instance.new('Frame')
        settingFrame.Name = name .. 'Setting'
        settingFrame.Size = UDim2.new(1, 0, 0, isMobile and 40 or 45)
        settingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        settingFrame.Parent = keybindsContainer
        
        local settingCorner = Instance.new('UICorner')
        settingCorner.CornerRadius = UDim.new(0, 8)
        settingCorner.Parent = settingFrame
        
        local settingPadding = Instance.new('UIPadding')
        settingPadding.PaddingLeft = UDim.new(0, 15)
        settingPadding.PaddingRight = UDim.new(0, 15)
        settingPadding.PaddingTop = UDim.new(0, 5)
        settingPadding.PaddingBottom = UDim.new(0, 5)
        settingPadding.Parent = settingFrame
        
        local descLabel = Instance.new('TextLabel')
        descLabel.Name = 'Description'
        descLabel.Size = UDim2.new(0.6, 0, 1, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        descLabel.TextSize = isMobile and 12 or 14
        descLabel.Font = Enum.Font.Ubuntu
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = settingFrame
        
        local keyButton = Instance.new('TextButton')
        keyButton.Name = 'KeyButton'
        keyButton.Size = UDim2.new(0.35, 0, 0.8, 0)
        keyButton.Position = UDim2.new(0.65, 0, 0.1, 0)
        keyButton.BackgroundColor3 = ACCENT_COLOR
        keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        keyButton.Text = currentKey
        keyButton.TextSize = isMobile and 11 or 13
        keyButton.Font = Enum.Font.Ubuntu
        keyButton.AutoButtonColor = false
        keyButton.Parent = settingFrame
        
        local keyCorner = Instance.new('UICorner')
        keyCorner.CornerRadius = UDim.new(0, 6)
        keyCorner.Parent = keyButton
        
        -- Keybind changing functionality with long-click to unset
        local waitingForKey = false
        local clickStartTime = 0
        local longClickThreshold = 1.0 -- 1 second for long click
        
        keyButton.MouseButton1Down:Connect(function()
            clickStartTime = tick()
        end)
        
        keyButton.MouseButton1Up:Connect(function()
            local clickDuration = tick() - clickStartTime
            
            if clickDuration >= longClickThreshold then
                -- Long click detected - unset the keybind
                keyButton.Text = "unset"
                keyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Gray color for unset
                
                -- Update the keybind to unset
                if onUpdate then
                    onUpdate("unset", nil)
                end
            elseif not waitingForKey then
                -- Normal click - change keybind
                waitingForKey = true
                keyButton.Text = "Press any key..."
                keyButton.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
                        local keyName = string.gsub(tostring(input.KeyCode), "Enum.KeyCode.", "")
                        keyButton.Text = keyName
                        keyButton.BackgroundColor3 = ACCENT_COLOR
                        waitingForKey = false
                        connection:Disconnect()
                        
                        -- Update the keybind
                        if onUpdate then
                            onUpdate(keyName, input.KeyCode)
                        end
                    end
                end)
            end
        end)
        
        return settingFrame
    end

    -- Create keybind settings (will be created later after all functions are defined)
    if not isMobile then
        -- Settings will be created after reconnectKeybinds function is defined
    else
        -- Mobile buttons - ALL keybinds as buttons (no title)
        -- Helper function to create mobile button
        local function createMobileButton(name, text, onClick)
            local button = Instance.new('TextButton')
            button.Name = name
            button.Size = UDim2.new(1, -20, 0, 32)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = text
            button.TextSize = 12
            button.Font = Enum.Font.Ubuntu
            button.AutoButtonColor = false
            button.Parent = keybindsContainer
            
            local corner = Instance.new('UICorner')
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = button
            
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                }):Play()
            end)
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                }):Play()
            end)
            button.MouseButton1Click:Connect(onClick)
            
            return button
        end
        
        -- Toggle Fly Mobile Button
        createMobileButton('FlyMobileButton', 'Toggle Fly', function()
            if toggleFly then
                toggleFly()
            end
        end)
        
        -- Carry Player Mobile Button
        createMobileButton('CarryMobileButton', 'Carry Nearest Player', function()
            if carryNearestPlayer then
                carryNearestPlayer()
            end
        end)
        
        -- Glitch Player Mobile Button
     createMobileButton('GlitchMobileButton', 'Glitch Nearest Player', function()
         if glitchNearestPlayer then
              glitchNearestPlayer()
        end
     end)
        
        -- Cuff Nearest Mobile Button
        createMobileButton('CuffMobileButton', 'Cuff Nearest Player', function()
            if cuffNearestPlayer then
                cuffNearestPlayer()
            end
        end)
        
        -- Reset Character Mobile Button (VIP)
        createMobileButton('ResetMobileButton', 'Reset Character (VIP)', function()
            if resetCharacter then
                resetCharacter()
            end
        end)
    end

    -- Panic Button (for both mobile and desktop)
    local panicButton = Instance.new('TextButton')
    panicButton.Name = 'PanicButton'
    panicButton.Size = UDim2.new(1, -20, 0, isMobile and 30 or 35)
    panicButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black color initially
    panicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    panicButton.Text = 'PANIC'
    panicButton.TextSize = isMobile and 12 or 14
    panicButton.Font = Enum.Font.Ubuntu
    panicButton.AutoButtonColor = false
    panicButton.LayoutOrder = 0 -- Make it the first item
    panicButton.Parent = settingsPage

    local panicCorner = Instance.new('UICorner')
    panicCorner.CornerRadius = UDim.new(0, 6)
    panicCorner.Parent = panicButton

    -- Panic button hover effects
    panicButton.MouseEnter:Connect(function()
        TweenService:Create(panicButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- Red on hover
        }):Play()
    end)

    panicButton.MouseLeave:Connect(function()
        TweenService:Create(panicButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Back to black
        }):Play()
    end)

    -- Add keybind instruction text for PC players only
    if not isMobile then
        local keybindInstruction = Instance.new('TextLabel')
        keybindInstruction.Name = 'KeybindInstruction'
        keybindInstruction.Size = UDim2.new(1, -20, 0, 20)
        keybindInstruction.BackgroundTransparency = 1
        keybindInstruction.Text = "Long click any keybind button to unset it"
        keybindInstruction.TextColor3 = Color3.fromRGB(150, 150, 150)
        keybindInstruction.TextSize = 12
        keybindInstruction.Font = Enum.Font.Ubuntu
        keybindInstruction.TextXAlignment = Enum.TextXAlignment.Center
        keybindInstruction.LayoutOrder = 0.5 -- Between panic button and fly speed
        keybindInstruction.Parent = settingsPage
    end

    -- Fly Speed Setting (above panic button)
    -- Fly System Variables
    local flying = false
    local flySpeed = 130
    local maxSpeed = 5000
    local minSpeed = 10

    local flySpeedSetting = Instance.new('Frame')
    flySpeedSetting.Name = 'FlySpeedSetting'
    flySpeedSetting.Size = UDim2.new(1, -20, 0, 40)
    flySpeedSetting.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    flySpeedSetting.LayoutOrder = 2 -- Put it after title and panic button
    flySpeedSetting.Parent = settingsPage

    local flySpeedCorner = Instance.new('UICorner')
    flySpeedCorner.CornerRadius = UDim.new(0, 8)
    flySpeedCorner.Parent = flySpeedSetting

    -- Fly Speed Label
    local flySpeedLabel = Instance.new('TextLabel')
    flySpeedLabel.Name = 'FlySpeedLabel'
    flySpeedLabel.Size = UDim2.new(0.5, -10, 1, 0)
    flySpeedLabel.Position = UDim2.new(0, 10, 0, 0)
    flySpeedLabel.BackgroundTransparency = 1
    flySpeedLabel.Text = 'Fly Speed:'
    flySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    flySpeedLabel.TextSize = 14
    flySpeedLabel.Font = Enum.Font.Ubuntu
    flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    flySpeedLabel.Parent = flySpeedSetting

    -- Fly Speed Controls Container
    local flySpeedControls = Instance.new('Frame')
    flySpeedControls.Name = 'FlySpeedControls'
    flySpeedControls.Size = UDim2.new(0.5, -10, 1, -10)
    flySpeedControls.Position = UDim2.new(0.5, 0, 0, 5)
    flySpeedControls.BackgroundTransparency = 1
    flySpeedControls.Parent = flySpeedSetting

    local flySpeedLayout = Instance.new('UIListLayout')
    flySpeedLayout.FillDirection = Enum.FillDirection.Horizontal
    flySpeedLayout.Padding = UDim.new(0, 5)
    flySpeedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    flySpeedLayout.Parent = flySpeedControls

    -- Speed Decrease Button
    local speedDownButton = Instance.new('TextButton')
    speedDownButton.Name = 'SpeedDownButton'
    speedDownButton.Size = UDim2.new(0, 30, 1, 0)
    speedDownButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedDownButton.Text = '-'
    speedDownButton.TextSize = 14
    speedDownButton.Font = Enum.Font.Ubuntu
    speedDownButton.AutoButtonColor = false
    speedDownButton.Parent = flySpeedControls

    local speedDownCorner = Instance.new('UICorner')
    speedDownCorner.CornerRadius = UDim.new(0, 4)
    speedDownCorner.Parent = speedDownButton

    -- Speed Display Label (editable textbox)
    local speedLabel = Instance.new('TextBox')
    speedLabel.Name = 'SpeedLabel'
    speedLabel.Size = UDim2.new(0, 50, 1, 0)
    speedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    speedLabel.Text = '130'
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Ubuntu
    speedLabel.TextXAlignment = Enum.TextXAlignment.Center
    speedLabel.PlaceholderText = "Speed"
    speedLabel.Parent = flySpeedControls

    local speedLabelCorner = Instance.new('UICorner')
    speedLabelCorner.CornerRadius = UDim.new(0, 4)
    speedLabelCorner.Parent = speedLabel

    -- Speed Increase Button
    local speedUpButton = Instance.new('TextButton')
    speedUpButton.Name = 'SpeedUpButton'
    speedUpButton.Size = UDim2.new(0, 30, 1, 0)
    speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedUpButton.Text = '+'
    speedUpButton.TextSize = 14
    speedUpButton.Font = Enum.Font.Ubuntu
    speedUpButton.AutoButtonColor = false
    speedUpButton.Parent = flySpeedControls

    local speedUpCorner = Instance.new('UICorner')
    speedUpCorner.CornerRadius = UDim.new(0, 4)
    speedUpCorner.Parent = speedUpButton

    -- Speed Control Functions
    local function updateSpeedLabel()
        speedLabel.Text = tostring(flySpeed)
    end

    -- Direct speed editing functionality
    speedLabel.FocusLost:Connect(function(enterPressed)
        local inputText = speedLabel.Text
        local newSpeed = tonumber(inputText)
        
        if newSpeed and newSpeed >= minSpeed and newSpeed <= maxSpeed then
            flySpeed = newSpeed
            speedLabel.Text = tostring(flySpeed)
        else
            speedLabel.Text = tostring(flySpeed) -- Reset to current speed if invalid
        end
    end)

    speedUpButton.MouseButton1Click:Connect(function()
        flySpeed = math.clamp(flySpeed + 30, minSpeed, maxSpeed)
        updateSpeedLabel()
    end)

    speedDownButton.MouseButton1Click:Connect(function()
        flySpeed = math.clamp(flySpeed - 30, minSpeed, maxSpeed)
        updateSpeedLabel()
    end)

    panicButton.MouseEnter:Connect(function()
        TweenService:Create(panicButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        }):Play()
    end)

    panicButton.MouseLeave:Connect(function()
        TweenService:Create(panicButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        }):Play()
    end)

    -- Function to create panic confirmation dialog
    local function createPanicDialog()
        local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        
        -- Create dialog GUI
        local dialogGui = Instance.new("ScreenGui")
        dialogGui.Name = "PanicDialog"
        dialogGui.ResetOnSpawn = false
        dialogGui.IgnoreGuiInset = true
        dialogGui.Parent = PlayerGui
        
        -- Create overlay
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.Parent = dialogGui
        
        -- Create dialog frame
        local dialogFrame = Instance.new("Frame")
        dialogFrame.Size = UDim2.new(0, 400, 0, 200)
        dialogFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
        dialogFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dialogFrame.BorderSizePixel = 0
        dialogFrame.Parent = dialogGui
        
        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 8)
        dialogCorner.Parent = dialogFrame
        
        -- Warning title
        local warningTitle = Instance.new("TextLabel")
        warningTitle.Size = UDim2.new(1, -20, 0, 30)
        warningTitle.Position = UDim2.new(0, 10, 0, 10)
        warningTitle.BackgroundTransparency = 1
        warningTitle.Text = "Are you sure?"
        warningTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
        warningTitle.TextSize = 18
        warningTitle.Font = Enum.Font.GothamBold
        warningTitle.TextXAlignment = Enum.TextXAlignment.Center
        warningTitle.Parent = dialogFrame
        
        -- Warning text
        local warningText = Instance.new("TextLabel")
        warningText.Size = UDim2.new(1, -20, 0, 80)
        warningText.Position = UDim2.new(0, 10, 0, 50)
        warningText.BackgroundTransparency = 1
        warningText.Text = "This will completely remove and delete the menu!\n\nThis action cannot be undone!"
        warningText.TextColor3 = Color3.fromRGB(255, 255, 255)
        warningText.TextSize = 14
        warningText.Font = Enum.Font.Ubuntu
        warningText.TextWrapped = true
        warningText.TextXAlignment = Enum.TextXAlignment.Center
        warningText.TextYAlignment = Enum.TextYAlignment.Center
        warningText.Parent = dialogFrame
        
        -- Button container
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -40, 0, 40)
        buttonContainer.Position = UDim2.new(0, 20, 1, -50)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = dialogFrame
        
        -- Cancel button
        local cancelButton = Instance.new("TextButton")
        cancelButton.Size = UDim2.new(0.45, 0, 1, 0)
        cancelButton.Position = UDim2.new(0, 0, 0, 0)
        cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        cancelButton.Text = "Cancel"
        cancelButton.TextSize = 14
        cancelButton.Font = Enum.Font.Ubuntu
        cancelButton.Parent = buttonContainer
        
        local cancelCorner = Instance.new("UICorner")
        cancelCorner.CornerRadius = UDim.new(0, 6)
        cancelCorner.Parent = cancelButton
        
        -- Confirm button
        local confirmButton = Instance.new("TextButton")
        confirmButton.Size = UDim2.new(0.45, 0, 1, 0)
        confirmButton.Position = UDim2.new(0.55, 0, 0, 0)
        confirmButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmButton.Text = "EJECT MENU"
        confirmButton.TextSize = 14
        confirmButton.Font = Enum.Font.GothamBold
        confirmButton.Parent = buttonContainer
        
        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 6)
        confirmCorner.Parent = confirmButton
        
        -- Cancel button functionality
        cancelButton.MouseButton1Click:Connect(function()
            dialogGui:Destroy()
        end)
        
        -- Confirm button functionality
        confirmButton.MouseButton1Click:Connect(function()
            -- Show debug notification
            pcall(function()
                game:GetService('StarterGui'):SetCore('SendNotification', {
                    Title = 'XmodzProject',
                    Text = 'Ejecting menu...',
                    Duration = 2,
                })
            end)
            
            -- Execute panic mode
            executeEjectSequence()
            dialogGui:Destroy()
        end)
    end

    -- Function to execute the eject sequence
    function executeEjectSequence()
        -- Set ejected flag to prevent keybind functionality
        menuEjected = true
        
        -- Reset running flag immediately to ensure it's always reset
        getgenv().XmodzProjectRunning = false
        
        -- Disable all keybinds immediately to prevent interference
        pcall(function()
            -- Disconnect early keybind connections
            if earlyKeybindConnections then
                for keybindName, connection in pairs(earlyKeybindConnections) do
                    if connection and connection.Disconnect then
                        connection:Disconnect()
                    end
                end
                earlyKeybindConnections = {}
            end
            
            -- Disconnect main keybind connections
            if keybindConnections then
                for keybindName, connection in pairs(keybindConnections) do
                    if connection and connection.Disconnect then
                        connection:Disconnect()
                    end
                end
                keybindConnections = {}
            end
        end)
        
        -- First, properly disable ESP systems through normal functions
        pcall(function()
            if espEnabled then
                disableESP()
            end
        end)
        
        pcall(function()
            if espAdminsEnabled then
                disableAdminESP()
            end
        end)
        
        pcall(function()
            if adminAlertEnabled then
                disableAdminAlert()
            end
        end)
        
        -- Disable fly if enabled
        pcall(function()
            if flying or flyEnabled then
                disableFly()
            end
        end)
        
        -- Then force clear any remaining ESP elements (backup cleanup)
        pcall(function()
            -- Force clear all regular ESP tags (in case some remained)
            for player, billboard in pairs(nameTags) do
                if billboard and billboard.Parent then
                    billboard:Destroy()
                end
            end
            nameTags = {}
            espEnabled = false
        end)
        
        pcall(function()
            -- Force clear all admin ESP tags (in case some remained)
            for player, billboard in pairs(adminTags) do
                if billboard and billboard.Parent then
                    billboard:Destroy()
                end
            end
            adminTags = {}
            espAdminsEnabled = false
        end)
        
        pcall(function()
            -- Force clear any lingering ESP elements in workspace (comprehensive cleanup)
            
            -- Method 1: Clean through character HumanoidRootPart
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = player.Character.HumanoidRootPart
                    -- Remove any ESP billboards
                    for _, child in pairs(rootPart:GetChildren()) do
                        if child:IsA("BillboardGui") and (
                            child.Name == "NameESP" or 
                            child.Name == "AdminESP" or 
                            child.Name == "DisplayNameESP" or
                            string.find(child.Name:lower(), "esp") or
                            string.find(child.Name:lower(), "tag")
                        ) then
                            child:Destroy()
                        end
                    end
                end
            end
            
            -- Method 2: Search entire workspace for any remaining ESP elements
            local function recursiveCleanup(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("BillboardGui") and (
                        child.Name == "NameESP" or 
                        child.Name == "AdminESP" or 
                        child.Name == "DisplayNameESP" or
                        string.find(child.Name:lower(), "esp") or
                        string.find(child.Name:lower(), "tag")
                    ) then
                        child:Destroy()
                    elseif child:GetChildren() and #child:GetChildren() > 0 then
                        recursiveCleanup(child)
                    end
                end
            end
            
            recursiveCleanup(workspace)
        end)
        
        -- Disable fly system
        pcall(function()
            if flyEnabled then
                disableFly()
            end
        end)
        
        -- Disconnect all input connections with error handling
        pcall(function()
            -- Disconnect flight connection
            if flightConnection then
                flightConnection:Disconnect()
                flightConnection = nil
            end
        end)
        
        pcall(function()
            -- Disconnect admin ESP connection
            if adminESPConnection then
                adminESPConnection:Disconnect()
                adminESPConnection = nil
            end
        end)
        
        pcall(function()
            -- Disconnect admin alert connection  
            if adminAlertConnection then
                adminAlertConnection:Disconnect()
                adminAlertConnection = nil
            end
        end)
        
        pcall(function()
            -- Clear all ESP connections
            if connections then
                for player, playerConnections in pairs(connections) do
                    if type(playerConnections) == "table" then
                        for _, connection in pairs(playerConnections) do
                            if connection and connection.Disconnect then
                                connection:Disconnect()
                            end
                        end
                    end
                end
                connections = {}
            end
        end)
        
        pcall(function()
            -- Disconnect spectate bypass connections
            if getgenv().spectateConnections then
                for _, connection in pairs(getgenv().spectateConnections) do
                    if connection and connection.Disconnect then
                        connection:Disconnect()
                    end
                end
                getgenv().spectateConnections = {}
            end
        end)
        
        -- Destroy panic button
        pcall(function()
            if panicButton then
                panicButton:Destroy()
            end
        end)
        
        -- Destroy all GUI components with error handling
        pcall(function()
            if gui and gui.Parent then
                gui:Destroy()
            end
        end)
        
        pcall(function()
            if menuIcon and menuIcon.Parent then
                menuIcon:Destroy()
            end
        end)
        
        pcall(function()
            if menuIcon and menuIcon.Parent then
                menuIcon:Destroy()
            end
        end)
        
        -- Remove protection marker to allow script to run again
        pcall(function()
            local protectionMarker = game:GetService('CoreGui'):FindFirstChild(SCRIPT_IDENTIFIER)
            if protectionMarker then
                protectionMarker:Destroy()
            end
        end)
        
        -- Clear all global variables
        gui = nil
        mainFrame = nil
        menuIcon = nil
        
        -- Show final notification
        pcall(function()
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title = 'XmodzProject',
                Text = 'Menu has been completely ejected and destroyed! You can now run the script again.',
                Duration = 3,
            })
        end)
    end

    -- Panic button click handler
    panicButton.MouseButton1Click:Connect(function()
        createPanicDialog()
    end)

    contentPages["Settings"] = settingsPage

    -- Tab Click Handlers (after all content pages are created)
    if mainTab then
        mainTab.MouseButton1Click:Connect(function()
            if switchTab then
                switchTab("Main")
            end
        end)
    end

    if miscTab then
        miscTab.MouseButton1Click:Connect(function()
            if switchTab then
                switchTab("Misc")
            end
        end)
    end

    if trollTab then
        trollTab.MouseButton1Click:Connect(function()
            if switchTab then
                switchTab("Troll")
            end
        end)
    end

    if settingsTab then
        settingsTab.MouseButton1Click:Connect(function()
            if switchTab then
                switchTab("Settings")
            end
        end)
    end

    -- Spectate System

    local originalCameraSubject = workspace.CurrentCamera.CameraSubject

    local currentlySpectating = nil
    local spectatePlayerList = {} -- List of players for navigation
    local currentSpectateIndex = 1

    -- Store disabled scripts info when spectating
    local disabledScripts = {}

    -- Spectate UI Elements
    local spectateUI = Instance.new('ScreenGui')
    spectateUI.Name = 'SpectateControls'
    spectateUI.ResetOnSpawn = false
    spectateUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    spectateUI.Enabled = false
    spectateUI.Parent = gui

    -- Spectate info bar
    local spectateInfoBar = Instance.new('Frame')
    spectateInfoBar.Name = 'SpectateInfoBar'
    spectateInfoBar.Size = UDim2.new(0, 300, 0, 60) -- Increased height for 2 lines
    spectateInfoBar.Position = UDim2.new(0.5, -150, 0, 20)
    spectateInfoBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    spectateInfoBar.BackgroundTransparency = 0.3
    spectateInfoBar.BorderSizePixel = 0
    spectateInfoBar.Parent = spectateUI

    local spectateBarCorner = Instance.new('UICorner')
    spectateBarCorner.CornerRadius = UDim.new(0, 8)
    spectateBarCorner.Parent = spectateInfoBar

    -- Currently spectating label (multiline)
    local spectateLabel = Instance.new('TextLabel')
    spectateLabel.Name = 'SpectateLabel'
    spectateLabel.Size = UDim2.new(1, -100, 1, 0)
    spectateLabel.Position = UDim2.new(0, 50, 0, 0)
    spectateLabel.BackgroundTransparency = 1
    spectateLabel.Text = 'Spectating: Player\n@username'
    spectateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    spectateLabel.TextSize = 14
    spectateLabel.Font = Enum.Font.Ubuntu
    spectateLabel.TextXAlignment = Enum.TextXAlignment.Center
    spectateLabel.TextYAlignment = Enum.TextYAlignment.Center
    spectateLabel.TextWrapped = true
    spectateLabel.Parent = spectateInfoBar

    -- Left arrow button
    local leftArrowButton = Instance.new('TextButton')
    leftArrowButton.Name = 'LeftArrow'
    leftArrowButton.Size = UDim2.new(0, 40, 0, 30)
    leftArrowButton.Position = UDim2.new(0, 5, 0.5, -15)
    leftArrowButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    leftArrowButton.Text = '<'
    leftArrowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftArrowButton.TextSize = 18
    leftArrowButton.Font = Enum.Font.Ubuntu
    leftArrowButton.AutoButtonColor = false
    leftArrowButton.Parent = spectateInfoBar

    local leftArrowCorner = Instance.new('UICorner')
    leftArrowCorner.CornerRadius = UDim.new(0, 6)
    leftArrowCorner.Parent = leftArrowButton

    -- Right arrow button
    local rightArrowButton = Instance.new('TextButton')
    rightArrowButton.Name = 'RightArrow'
    rightArrowButton.Size = UDim2.new(0, 40, 0, 30)
    rightArrowButton.Position = UDim2.new(1, -45, 0.5, -15)
    rightArrowButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    rightArrowButton.Text = '>'
    rightArrowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightArrowButton.TextSize = 18
    rightArrowButton.Font = Enum.Font.Ubuntu
    rightArrowButton.AutoButtonColor = false
    rightArrowButton.Parent = spectateInfoBar

    local rightArrowCorner = Instance.new('UICorner')
    rightArrowCorner.CornerRadius = UDim.new(0, 6)
    rightArrowCorner.Parent = rightArrowButton

    -- Exit spectate button
    local exitSpectateButton = Instance.new('TextButton')
    exitSpectateButton.Name = 'ExitSpectate'
    exitSpectateButton.Size = UDim2.new(0, 100, 0, 35)
    exitSpectateButton.Position = UDim2.new(0.5, -50, 0, 90) -- Adjusted for taller info bar
    exitSpectateButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    exitSpectateButton.Text = 'Exit Spectate'
    exitSpectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exitSpectateButton.TextSize = 14
    exitSpectateButton.Font = Enum.Font.Ubuntu
    exitSpectateButton.AutoButtonColor = false
    exitSpectateButton.Parent = spectateUI

    local exitSpectateCorner = Instance.new('UICorner')
    exitSpectateCorner.CornerRadius = UDim.new(0, 6)
    exitSpectateCorner.Parent = exitSpectateButton

    -- Hover effects for spectate controls
    leftArrowButton.MouseEnter:Connect(function()
        TweenService:Create(leftArrowButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        }):Play()
    end)
    leftArrowButton.MouseLeave:Connect(function()
        TweenService:Create(leftArrowButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        }):Play()
    end)

    rightArrowButton.MouseEnter:Connect(function()
        TweenService:Create(rightArrowButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        }):Play()
    end)
    rightArrowButton.MouseLeave:Connect(function()
        TweenService:Create(rightArrowButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        }):Play()
    end)

    exitSpectateButton.MouseEnter:Connect(function()
        TweenService:Create(exitSpectateButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        }):Play()
    end)
    exitSpectateButton.MouseLeave:Connect(function()
        TweenService:Create(exitSpectateButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        }):Play()
    end)

    -- Scripts to exclude from disabling (whitelist)
    local excludedScripts = {
        ["ServerListBtn"] = true,
        ["InviteIcon"] = true,
        ["Rotate"] = true
    }

    -- Function to disable scripts before spectating
    local function disablePlayerScripts()
        disabledScripts = {} -- Clear previous data
        
        -- Disable scripts in PlayerScripts
        if player:FindFirstChild("PlayerScripts") then
            for _, obj in ipairs(player.PlayerScripts:GetDescendants()) do
                if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Enabled then
                    -- Skip excluded scripts
                    if not excludedScripts[obj.Name] then
                        table.insert(disabledScripts, obj)
                        obj.Enabled = false
                    end
                end
            end
        end
        
        -- Disable scripts in PlayerGui
        if player:FindFirstChild("PlayerGui") then
            for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
                if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Enabled then
                    -- Skip excluded scripts
                    if not excludedScripts[obj.Name] then
                        table.insert(disabledScripts, obj)
                        obj.Enabled = false
                    end
                end
            end
        end
        
        -- Disable scripts in Character
        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Enabled then
                    -- Skip excluded scripts
                    if not excludedScripts[obj.Name] then
                        table.insert(disabledScripts, obj)
                        obj.Enabled = false
                    end
                end
            end
        end
    end

    -- Function to re-enable scripts after unspectating
    local function enablePlayerScripts()
        for _, scriptObj in ipairs(disabledScripts) do
            if scriptObj and scriptObj.Parent then -- Check if script still exists
                scriptObj.Enabled = true
            end
        end
        disabledScripts = {} -- Clear the list
    end

    -- Spectate monitoring connections
    local spectateMonitorConnections = {}

    -- Function to stop spectating and clean up (MOVED BEFORE IT'S USED)
    local function stopSpectating()
        if not currentlySpectating then return end
        
        -- Stop smart spectate first if it's enabled
        if smartSpectateEnabled then
            pcall(function()
                stopSmartSpectate()
            end)
        end
        
        -- Disconnect all monitoring connections first
        for _, connection in ipairs(spectateMonitorConnections) do
            pcall(function()
                if connection then
                    connection:Disconnect()
                end
            end)
        end
        spectateMonitorConnections = {}
        
        -- Hide spectate UI
        spectateUI.Enabled = false
        
        -- Restore camera to local player with multiple attempts
        local attempts = 0
        local maxAttempts = 3
        
        while attempts < maxAttempts do
            local success = pcall(function()
                local camera = workspace.CurrentCamera
                if camera then
                    -- Force camera back to local player
                    if localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid') then
                        camera.CameraSubject = localPlayer.Character.Humanoid
                        camera.CameraType = Enum.CameraType.Custom
                        camera.CFrame = localPlayer.Character.Head.CFrame * CFrame.new(0, 0, 5)
                    else
                        -- Fallback to workspace if character doesn't exist
                        camera.CameraSubject = workspace
                        camera.CameraType = Enum.CameraType.Custom
                    end
                end
            end)
            
            if success then
                break
            end
            attempts = attempts + 1
            task.wait(0.1)
        end

        -- Re-enable scripts only if bypass was enabled
        if getgenv().spectateBypassEnabled then
            pcall(function()
                enablePlayerScripts()
            end)
        end
        
        -- Update all spectate buttons in the player list
        pcall(function()
            if scrollFrame then
                for _, btn in ipairs(scrollFrame:GetDescendants()) do
                    if btn:IsA("TextButton") and btn.Name == 'SpectateButton' then
                        btn.Text = 'Spectate'
                        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                    end
                end
            end
        end)
        
        -- Clear state
        currentlySpectating = nil
        spectatePlayerList = {}
        currentSpectateIndex = 1
    end

    -- Function to build spectate player list
    local function buildSpectatePlayerList()
        spectatePlayerList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                table.insert(spectatePlayerList, p)
            end
        end
        return spectatePlayerList
    end

    -- Function to spectate specific player
    local function spectatePlayerByIndex(index)
        -- Always rebuild the player list to ensure it's current
        buildSpectatePlayerList()
        
        if #spectatePlayerList == 0 then
            -- No players to spectate, stop spectating
            if smartSpectateEnabled then
                stopSmartSpectate()
            end
            stopSpectating()
            return
        end
        
        -- Adjust index to wrap around
        currentSpectateIndex = index
        if currentSpectateIndex > #spectatePlayerList then
            currentSpectateIndex = 1
        elseif currentSpectateIndex < 1 then
            currentSpectateIndex = #spectatePlayerList
        end
        
        local targetPlayer = spectatePlayerList[currentSpectateIndex]
        
        -- Validate target player
        if not targetPlayer then
            if smartSpectateEnabled then
                stopSmartSpectate()
            end
            stopSpectating()
            return
        end
        
        -- Check if player has a valid character
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") then
            -- Skip to next valid player
            local attempts = 0
            while attempts < #spectatePlayerList do
                currentSpectateIndex = currentSpectateIndex + 1
                if currentSpectateIndex > #spectatePlayerList then
                    currentSpectateIndex = 1
                end
                
                targetPlayer = spectatePlayerList[currentSpectateIndex]
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                    break
                end
                
                attempts = attempts + 1
            end
            
            -- If still no valid player found, stop spectating
            if attempts >= #spectatePlayerList then
                if smartSpectateEnabled then
                    stopSmartSpectate()
                end
                stopSpectating()
                return
            end
        end
        
        -- Start spectating with appropriate method
        if smartSpectateEnabled then
            -- Use smart spectate for this player
            startSmartSpectate(targetPlayer)
        else
            -- Update camera to spectate target normally
            pcall(function()
                local camera = workspace.CurrentCamera
                if camera and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject = targetPlayer.Character.Humanoid
                    camera.CameraType = Enum.CameraType.Custom
                end
            end)
        end
        
        -- Get display name and username
        local displayName = targetPlayer.DisplayName or targetPlayer.Name
        local username = "@" .. targetPlayer.Name
        
        -- Update label with proper format
        spectateLabel.Text = "Spectating: " .. displayName .. "\n" .. username
        currentlySpectating = targetPlayer
        
        -- Update monitoring for new target
        startSpectateMonitoring(targetPlayer)
    end

    -- Arrow button functions
    leftArrowButton.MouseButton1Click:Connect(function()
        pcall(function()
            spectatePlayerByIndex(currentSpectateIndex - 1)
        end)
    end)

    rightArrowButton.MouseButton1Click:Connect(function()
        pcall(function()
            spectatePlayerByIndex(currentSpectateIndex + 1)
        end)
    end)

    -- Exit spectate button function
    exitSpectateButton.MouseButton1Click:Connect(function()
        pcall(function()
            -- Stop smart spectate if enabled
            if smartSpectateEnabled then
                stopSmartSpectate()
            end
            stopSpectating()
        end)
    end)

    -- Function to start monitoring spectated player
    local function startSpectateMonitoring(targetPlayer)
        -- Clear previous connections
        for _, connection in ipairs(spectateMonitorConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        spectateMonitorConnections = {}
        
        -- Monitor for player leaving
        local leftConnection = targetPlayer.AncestryChanged:Connect(function()
            if not targetPlayer:IsDescendantOf(game) then
                -- Player left the game
                game:GetService('StarterGui'):SetCore('SendNotification', {
                    Title = 'Spectate',
                    Text = targetPlayer.Name .. ' left the game',
                    Duration = 3,
                })
                stopSpectating()
            end
        end)
        table.insert(spectateMonitorConnections, leftConnection)
        
        -- Monitor for character respawn
        local respawnConnection = targetPlayer.CharacterAdded:Connect(function(newCharacter)
            if currentlySpectating == targetPlayer then
                -- Wait for humanoid to load
                local humanoid = newCharacter:WaitForChild("Humanoid", 5)
                if humanoid then
                    -- Re-spectate the new character
                    local camera = workspace.CurrentCamera
                    if camera then
                        camera.CameraSubject = humanoid
                    end
                end
            end
        end)
        table.insert(spectateMonitorConnections, respawnConnection)
        
        -- Monitor for character removal (death/reset before respawn)
        if targetPlayer.Character then
            local characterRemoving = targetPlayer.Character.AncestryChanged:Connect(function()
                if targetPlayer.Character and not targetPlayer.Character:IsDescendantOf(workspace) then
                    -- Character was removed, wait for respawn
                    -- The CharacterAdded connection above will handle the re-spectate
                end
            end)
            table.insert(spectateMonitorConnections, characterRemoving)
        end
    end

    -- Fly System (Improved from fly.lua)

    local bodyVelocity, bodyGyro
    local flightConnection

    local function initialRise(character)
        local riseSpeed = 10
        local startTime = tick()
        local riseTime = 0.1

        while tick() - startTime < riseTime do
            bodyVelocity.Velocity = Vector3.new(0, riseSpeed, 0)
            RunService.RenderStepped:Wait()
        end
    end

    local function startFly()
        if flying then return end
        flying = true

        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")
        
        -- Stop any current animations (like jumping) without breaking the humanoid
        if humanoid then
            -- Get all currently playing animation tracks and stop them
            local animator = humanoid:FindFirstChild("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    if track.Name:lower():find("jump") or track.Name:lower():find("fall") then
                        track:Stop()
                    end
                end
            end
            
            humanoid.PlatformStand = true
        else
            character.Humanoid.PlatformStand = true
        end

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = character.HumanoidRootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        bodyGyro.CFrame = character.HumanoidRootPart.CFrame
        bodyGyro.Parent = character.HumanoidRootPart

        initialRise(character)
        
        -- Show mobile controls if on mobile
        if UserInputService.TouchEnabled and mobileControls then
            mobileControls.Visible = true
        end

        flightConnection = RunService.RenderStepped:Connect(function()
            if flying then
                local cam = workspace.CurrentCamera
                local move = Vector3.new(0, 0, 0)
                
                -- Ensure humanoid stays in PlatformStand state while flying
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid and not humanoid.PlatformStand then
                    humanoid.PlatformStand = true
                end
                
                -- Desktop controls (WASD + R/F + Space)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.R) then move = move + cam.CFrame.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.F) then move = move - cam.CFrame.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + cam.CFrame.UpVector end
                
                -- Mobile controls (Use Roblox joystick)
                if UserInputService.TouchEnabled then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        local moveVector = humanoid.MoveDirection
                        if moveVector.Magnitude > 0 then
                            -- Convert humanoid move direction to camera-relative 3D movement
                            local flatCameraForward = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
                            local flatCameraRight = cam.CFrame.RightVector * Vector3.new(1, 0, 1)
                            
                            flatCameraForward = flatCameraForward.Unit
                            flatCameraRight = flatCameraRight.Unit
                            
                            move = move + (flatCameraForward * -moveVector.Z) + (flatCameraRight * moveVector.X)
                        end
                    end
                    
                    -- Mobile vertical controls (only UP/DOWN buttons)
                    if mobileUpPressed then
                        move = move + Vector3.new(0, 1, 0)
                    end
                    if mobileDownPressed then
                        move = move + Vector3.new(0, -1, 0)
                    end
                end

                if move.Magnitude > 0 then
                    bodyVelocity.Velocity = move.Unit * flySpeed
                else
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end

                -- Camera-based orientation
                bodyGyro.CFrame = cam.CFrame
            end
        end)
    end

    local function stopFly()
        if not flying then return end
        flying = false

        local character = player.Character or player.CharacterAdded:Wait()
        character.Humanoid.PlatformStand = false

        if flightConnection then
            flightConnection:Disconnect()
            flightConnection = nil
        end

        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        -- Hide mobile controls
        if mobileControls then
            mobileControls.Visible = false
            mobileUpPressed = false
            mobileDownPressed = false
            upButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            downButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end

    local function toggleFly()
        if flying then
            stopFly()
            flyButton.Text = 'Fly: OFF'
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 180, 120)
        else
            startFly()
            flyButton.Text = 'Fly: ON'
            flyButton.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
        end
    end

    flyButton.MouseButton1Click:Connect(toggleFly)

    -- Keybind settings will be created at the end after all functions are defined

    player.CharacterAdded:Connect(function(character)
        if flying then
            stopFly()
            flyButton.Text = 'Fly: OFF'
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 180, 120)
        end
    end)

    -- ESP System

    local espEnabled = false
    local nameTags = {}
    local connections = {} -- Store connections for proper cleanup

    local function createNameTag(player)
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild('HumanoidRootPart', 5) -- 5 second timeout
        
        -- If HumanoidRootPart doesn't exist within 5 seconds, return early
        if not humanoidRootPart then
            warn("HumanoidRootPart not found for player: " .. player.Name)
            return
        end

        local billboard = Instance.new('BillboardGui')
        billboard.Name = 'DisplayNameESP'
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Adornee = humanoidRootPart
        billboard.LightInfluence = 1
        billboard.MaxDistance = 1000
        billboard.Parent = character

        local nameLabel = Instance.new('TextLabel')
        nameLabel.Name = 'DisplayNameLabel'
        nameLabel.Text = player.DisplayName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.Ubuntu
        nameLabel.TextSize = 18
        nameLabel.Parent = billboard

        local usernameLabel = Instance.new('TextLabel')
        usernameLabel.Name = 'UsernameLabel'
        usernameLabel.Text = '@' .. player.Name
        usernameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        usernameLabel.TextStrokeTransparency = 0.7
        usernameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        usernameLabel.Position = UDim2.new(0, 0, 0.6, 0)
        usernameLabel.BackgroundTransparency = 1
        usernameLabel.Font = Enum.Font.Ubuntu
        usernameLabel.TextSize = 14
        usernameLabel.Parent = billboard

        nameTags[player] = billboard

        -- Store cleanup connections
        local cleanUpConnection = player.CharacterRemoving:Connect(function()
            if nameTags[player] and nameTags[player].Parent then
                nameTags[player]:Destroy()
                nameTags[player] = nil
            end
        end)

        connections[player] = connections[player] or {}
        table.insert(connections[player], cleanUpConnection)

        local localPlayer = Players.LocalPlayer
        local localCharacter = localPlayer.Character
            or localPlayer.CharacterAdded:Wait()
        local localRoot = localCharacter:WaitForChild('HumanoidRootPart')

        local heartbeatConnection = RunService.Heartbeat:Connect(function()
            if
                not espEnabled
                or not character
                or not character.Parent
                or not humanoidRootPart
                or not localRoot
            then
                if heartbeatConnection and heartbeatConnection.Disconnect then
                    heartbeatConnection:Disconnect()
                end
                return
            end

            local distance = (humanoidRootPart.Position - localRoot.Position).Magnitude
            local textSize = math.clamp(22 - (distance / 30), 12, 22)
            nameLabel.TextSize = textSize
            usernameLabel.TextSize = textSize - 4
        end)

        connections[player] = connections[player] or {}
        table.insert(connections[player], heartbeatConnection)
    end

    local function enableESP()
        if espEnabled then
            return
        end

        -- Clear any existing nameTags first
        for player, billboard in pairs(nameTags) do
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
        end
        nameTags = {}

        -- Clear existing connections
        for player, playerConnections in pairs(connections) do
            for _, connection in ipairs(playerConnections) do
                connection:Disconnect()
            end
        end
        connections = {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                if player.Character then
                    createNameTag(player)
                end

                local characterAddedConnection = player.CharacterAdded:Connect(
                    function()
                        createNameTag(player)
                    end
                )

                connections[player] = connections[player] or {}
                table.insert(connections[player], characterAddedConnection)
            end
        end

        local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            local newPlayerConnection = player.CharacterAdded:Connect(function()
                if player ~= Players.LocalPlayer then
                    createNameTag(player)
                end
            end)

            connections[player] = connections[player] or {}
            table.insert(connections[player], newPlayerConnection)
        end)

        connections['PlayerAdded'] = { playerAddedConnection }

        espEnabled = true
        espButton.Text = 'ESP: ON'
        espButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Gray when ON
    end

    local function disableESP()
        if not espEnabled then
            return
        end

        -- Destroy all nameTags
        for player, billboard in pairs(nameTags) do
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
        end
        nameTags = {}

        -- Disconnect all connections
        for player, playerConnections in pairs(connections) do
            for _, connection in ipairs(playerConnections) do
                connection:Disconnect()
            end
        end
        connections = {}

        espEnabled = false
        espButton.Text = 'ESP: OFF'
        espButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Black when OFF
    end

    espButton.MouseButton1Click:Connect(function()
        if espEnabled then
            disableESP()
        else
            enableESP()
        end
    end)

    -- Function to Create Player Entry with Cuff/Slap Buttons

    local function createPlayerEntry(player)
        local entry = Instance.new('Frame')

        entry.Name = player.Name

        entry.Size = UDim2.new(1, 0, 0, 70)

        -- Black background for protected/dev-protected players
        local isProtected = isPlayerProtected(player)
        if isProtected then
            entry.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
            entry.BackgroundTransparency = 0.1
        else
            entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            entry.BackgroundTransparency = 0.3
        end

        local entryCorner = Instance.new('UICorner')

        entryCorner.CornerRadius = UDim.new(0, 8)

        entryCorner.Parent = entry

        entry.MouseEnter:Connect(function()
            if not entry or not entry.Parent then return end
            if isProtected then
                TweenService:Create(entry, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(25, 15, 15),
                }):Play()
            else
                TweenService:Create(entry, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                }):Play()
            end
        end)

        entry.MouseLeave:Connect(function()
            if not entry or not entry.Parent then return end
            if isProtected then
                TweenService:Create(entry, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(15, 10, 10),
                }):Play()
            else
                TweenService:Create(entry, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                }):Play()
            end
        end)

        -- Player Avatar

        local avatar = Instance.new('ImageLabel')

        avatar.Name = 'Avatar'

        avatar.Size = UDim2.new(0, 45, 0, 45)

        avatar.Position = UDim2.new(0, 8, 0.5, -22.5)

        avatar.BackgroundTransparency = 1 -- Make background transparent

        avatar.BorderSizePixel = 0

        avatar.Image = Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )

        local avatarCorner = Instance.new('UICorner')

        avatarCorner.CornerRadius = UDim.new(1, 0)

        avatarCorner.Parent = avatar

        local avatarBorder = Instance.new('UIStroke')

        avatarBorder.Color = ACCENT_COLOR

        avatarBorder.Thickness = 2

        avatarBorder.Parent = avatar

        -- Player Display Name + Username

        local displayNameLabel = Instance.new('TextLabel')

        displayNameLabel.Name = 'DisplayNameLabel'

        displayNameLabel.Size = UDim2.new(0.6, -65, 0.5, -5)

        displayNameLabel.Position = UDim2.new(0, 60, 0, 5)

        displayNameLabel.BackgroundTransparency = 1

        displayNameLabel.RichText = true

        -- Check for admin role in group 35822612 and update display name
        local displayNameText = player.DisplayName .. ' <font color="#8888aa">@' .. player.Name .. '</font>'
        
        -- Check cache first (with TTL validation)
        if isRoleCacheValid(player.UserId) then
            local roleData = roleCache[player.UserId]
            displayNameText = player.DisplayName .. ' [' .. roleData.role .. '] <font color="#8888aa">@' .. player.Name .. '</font>'
            displayNameLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red color for admin
        else
            -- If not in cache or expired, fetch role asynchronously
            task.spawn(function()
                local success, roleInGroup = pcall(function()
                    return player:GetRoleInGroup(35822612)
                end)
                
                if success and roleInGroup and roleInGroup ~= "Guest" then
                    -- Use EXCLUSION LIST approach (same as ESP Admins)
                    local roleLower = roleInGroup:lower()
                    
                    -- List of roles that should NOT be marked as admin
                    local excludedRoles = {
                        "member", "booster", "top donators", "graphic designer",
                        "content creator", "vip", "streamer", "modeler",
                        "elite donor", "viber"
                    }
                    
                    -- Check if player has an excluded role
                    local isExcluded = false
                    for _, excludedRole in ipairs(excludedRoles) do
                        if string.find(roleLower, excludedRole) then
                            isExcluded = true
                            break
                        end
                    end
                    
                    -- Mark as admin if NOT excluded
                    local hasRequiredRole = not isExcluded
                    
                    if hasRequiredRole then
                        -- Cache the role with timestamp
                        roleCache[player.UserId] = {
                            role = roleInGroup, 
                            timestamp = tick()
                        }
                        
                        -- Update display name and color (admin takes priority over friend)
                        if displayNameLabel and displayNameLabel.Parent then
                            local newDisplayNameText = player.DisplayName .. ' [' .. roleInGroup .. '] <font color="#8888aa">@' .. player.Name .. '</font>'
                            displayNameLabel.Text = newDisplayNameText
                            displayNameLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red color for admin (highest priority)
                        end
                        
                        -- Update admin stats
                        updatePlayerStats()
                    end
                end
            end)
        end

        displayNameLabel.Text = displayNameText

        -- Set initial color based on role/friend status
        local function updatePlayerColor()
            -- Priority: Admin (red) > Friend (blue) > Default (white)
            if roleCache[player.UserId] then
                displayNameLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red color for admin roles
            else
                -- Check if player is a friend
                local success, friendStatus = pcall(function()
                    return Players.LocalPlayer:IsFriendsWith(player.UserId)
                end)
                
                if success and friendStatus then
                    displayNameLabel.TextColor3 = Color3.fromRGB(100, 150, 255) -- Blue color for friends
                else
                    displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White for regular players
                end
            end
        end
        
        -- Apply initial color
        updatePlayerColor()

        displayNameLabel.TextSize = 14

        displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left

        displayNameLabel.Font = Enum.Font.Ubuntu

        -- Button Container

        local buttonContainer = Instance.new('Frame')

        buttonContainer.Name = 'ButtonContainer'

        buttonContainer.Size = UDim2.new(0.4, -10, 1, -10)

        buttonContainer.Position = UDim2.new(0.6, 0, 0.5, -20)

        buttonContainer.BackgroundTransparency = 1

        buttonContainer.Parent = entry

        local buttonLayout = Instance.new('UIListLayout')

        buttonLayout.FillDirection = Enum.FillDirection.Horizontal

        buttonLayout.Padding = UDim.new(0, 5)

        buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

        buttonLayout.Parent = buttonContainer

        -- Teleport Button

        local teleportButton = Instance.new('TextButton')

        teleportButton.Name = 'TeleportButton'

        teleportButton.Size = UDim2.new(0, 60, 0, 25)

        teleportButton.BackgroundColor3 = ACCENT_COLOR

        teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)

        teleportButton.Text = 'TP'

        teleportButton.TextSize = 12

        teleportButton.Font = Enum.Font.Ubuntu

        teleportButton.AutoButtonColor = false

        local teleportCorner = Instance.new('UICorner')

        teleportCorner.CornerRadius = UDim.new(0, 5)

        teleportCorner.Parent = teleportButton

        -- Spectate Button

        local spectateButton = Instance.new('TextButton')

        spectateButton.Name = 'SpectateButton'

        spectateButton.Size = UDim2.new(0, 60, 0, 25)

        spectateButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)

        spectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)

        spectateButton.Text = 'Spectate'

        spectateButton.TextSize = 12

        spectateButton.Font = Enum.Font.Ubuntu

        spectateButton.AutoButtonColor = false

        local spectateCorner = Instance.new('UICorner')

        spectateCorner.CornerRadius = UDim.new(0, 5)

        spectateCorner.Parent = spectateButton

        -- Cuff Button

        local cuffButton = Instance.new('TextButton')

        cuffButton.Name = 'CuffButton'

        cuffButton.Size = UDim2.new(0, 60, 0, 25)

        cuffButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)

        cuffButton.TextColor3 = Color3.fromRGB(255, 255, 255)

        cuffButton.Text = 'Cuff'

        cuffButton.TextSize = 12

        cuffButton.Font = Enum.Font.Ubuntu

        cuffButton.AutoButtonColor = false

        local cuffCorner = Instance.new('UICorner')

        cuffCorner.CornerRadius = UDim.new(0, 5)

        cuffCorner.Parent = cuffButton

        -- Troll Button

        local trollButton = Instance.new('TextButton')

        trollButton.Name = 'TrollButton'

        trollButton.Size = UDim2.new(0, 60, 0, 25)

        trollButton.BackgroundColor3 = Color3.fromRGB(120, 40, 200)

        trollButton.TextColor3 = Color3.fromRGB(255, 255, 255)

        trollButton.Text = 'Troll'

        trollButton.TextSize = 12

        trollButton.Font = Enum.Font.Ubuntu

        trollButton.AutoButtonColor = false

        local trollBtnCorner = Instance.new('UICorner')

        trollBtnCorner.CornerRadius = UDim.new(0, 5)

        trollBtnCorner.Parent = trollButton

        -- Modified Button Hover Effects

        local function setupButtonHover(button, normalColor, hoverColor)
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {

                    BackgroundColor3 = hoverColor,

                    Size = UDim2.new(0, 62, 0, 27),
                }):Play()
            end)

            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {

                    BackgroundColor3 = normalColor,

                    Size = UDim2.new(0, 60, 0, 25),
                }):Play()
            end)
        end

        setupButtonHover(teleportButton, ACCENT_COLOR, Color3.fromRGB(73, 29, 231))

        setupButtonHover(
            spectateButton,
            Color3.fromRGB(80, 80, 100),
            Color3.fromRGB(100, 100, 120)
        )

        setupButtonHover(
            cuffButton,
            Color3.fromRGB(200, 150, 50),
            Color3.fromRGB(220, 170, 70)
        )

        setupButtonHover(
            trollButton,
            Color3.fromRGB(120, 40, 200),
            Color3.fromRGB(140, 60, 220)
        )

        -- Teleport Functionality

        teleportButton.MouseButton1Click:Connect(function()
            -- Check if target is protected
            if isPlayerProtected(player) then
                showProtectedWarning()
                return
            end

            if
                player.Character
                and player.Character:FindFirstChild('HumanoidRootPart')
            then
                local localChar = Players.LocalPlayer.Character

                if localChar and localChar:FindFirstChild('HumanoidRootPart') then
                    localChar.HumanoidRootPart.CFrame =
                        player.Character.HumanoidRootPart.CFrame
                end
            end
        end)

        -- Spectate Functionality

        spectateButton.MouseButton1Click:Connect(function()
            pcall(function()
                if player and player.Character and player.Character:FindFirstChild('Humanoid') then
                    if currentlySpectating == player then
                        -- Stop spectating
                        if smartSpectateEnabled then
                            stopSmartSpectate()
                        end
                        stopSpectating()
                    else
                        -- Check if target is protected
                        if isPlayerProtected(player) then
                            showProtectedWarning()
                            return
                        end

                        -- Stop any other spectate first
                        if currentlySpectating then
                            if smartSpectateEnabled then
                                stopSmartSpectate()
                            end
                            stopSpectating()
                        end

                        -- Only disable scripts if spectate bypass is enabled
                        if getgenv().spectateBypassEnabled then
                            disablePlayerScripts()
                        end

                        -- Build player list and find current player index
                        buildSpectatePlayerList()
                        for i, p in ipairs(spectatePlayerList) do
                            if p == player then
                                currentSpectateIndex = i
                                break
                            end
                        end

                        -- Start spectating
                        if smartSpectateEnabled then
                            startSmartSpectate(player)
                        else
                            local camera = workspace.CurrentCamera
                            if camera and player.Character and player.Character.Humanoid then
                                camera.CameraSubject = player.Character.Humanoid
                            end
                        end

                        -- Show spectate UI
                        spectateUI.Enabled = true
                        
                        -- Get display name and username for label
                        local displayName = player.DisplayName or player.Name
                        local username = "@" .. player.Name
                        spectateLabel.Text = "Spectating: " .. displayName .. "\n" .. username

                        spectateButton.Text = 'Unspectate'
                        spectateButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                        currentlySpectating = player

                        -- Start monitoring the spectated player
                        startSpectateMonitoring(player)
                    end
                end
            end)
        end)

        -- Cuff Functionality

        cuffButton.MouseButton1Click:Connect(function()
            -- Check if target is protected
            if isPlayerProtected(player) then
                showProtectedWarning()
                return
            end

            if
                player.Character and (player.Character:FindFirstChild('UpperTorso') or player.Character:FindFirstChild('Torso'))
            then
                local localChar = Players.LocalPlayer.Character
                if not localChar or not localChar:FindFirstChild('HumanoidRootPart') then
                    return
                end
                
                local targetRoot = player.Character:FindFirstChild('HumanoidRootPart')
                if not targetRoot then
                    return
                end
                
                local localRoot = localChar:FindFirstChild('HumanoidRootPart')
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                
                -- Check for cuff object before proceeding with any cuff action
                local cuffObject = nil
                if localChar then
                    cuffObject = localChar:FindFirstChild('Cuffs')
                    if not cuffObject then
                        -- Search for any object containing "Cuff" in the name
                        for _, child in pairs(localChar:GetChildren()) do
                            if string.find(child.Name:lower(), 'cuff') then
                                cuffObject = child
                                break
                            end
                        end
                    end
                end
                
                if not cuffObject then
                    -- Show notification that handcuffs must be equipped
                    game:GetService('StarterGui'):SetCore('SendNotification', {
                        Title = 'Handcuffs Required',
                        Text = 'You must have the handcuffs equipped to cuff players!',
                        Duration = 3,
                    })
                    return
                end
                
                -- If player is too far, show notification dialog
                if distance > 10 then
                    -- Create warning dialog
                    local distanceWarningGui = Instance.new('ScreenGui')
                    distanceWarningGui.Name = 'DistanceWarningDialog'
                    distanceWarningGui.IgnoreGuiInset = true
                    distanceWarningGui.Parent = game:GetService('CoreGui')
                    
                    -- Background overlay
                    local overlay = Instance.new('Frame')
                    overlay.Name = 'Overlay'
                    overlay.Size = UDim2.new(1, 0, 1, 0)
                    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    overlay.BackgroundTransparency = 0.5
                    overlay.BorderSizePixel = 0
                    overlay.Parent = distanceWarningGui
                    
                    -- Dialog frame
                    local dialogFrame = Instance.new('Frame')
                    dialogFrame.Name = 'DialogFrame'
                    dialogFrame.Size = UDim2.new(0, 400, 0, 180)
                    dialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                    dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                    dialogFrame.BackgroundColor3 = Color3.fromRGB(40, 25, 60)
                    dialogFrame.BorderSizePixel = 0
                    dialogFrame.Parent = overlay
                    
                    local dialogCorner = Instance.new('UICorner')
                    dialogCorner.CornerRadius = UDim.new(0, 12)
                    dialogCorner.Parent = dialogFrame
                    
                    local dialogBorder = Instance.new('UIStroke')
                    dialogBorder.Color = Color3.fromRGB(200, 150, 50)
                    dialogBorder.Thickness = 2
                    dialogBorder.Parent = dialogFrame
                    
                    -- Warning title
                    local warningTitle = Instance.new('TextLabel')
                    warningTitle.Name = 'WarningTitle'
                    warningTitle.Size = UDim2.new(1, -20, 0, 30)
                    warningTitle.Position = UDim2.new(0, 10, 0, 10)
                    warningTitle.BackgroundTransparency = 1
                    warningTitle.Text = 'Player Too Far'
                    warningTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
                    warningTitle.TextSize = 18
                    warningTitle.Font = Enum.Font.Ubuntu
                    warningTitle.TextXAlignment = Enum.TextXAlignment.Center
                    warningTitle.Parent = dialogFrame
                    
                    -- Warning message
                    local warningMessage = Instance.new('TextLabel')
                    warningMessage.Name = 'WarningMessage'
                    warningMessage.Size = UDim2.new(1, -20, 0, 60)
                    warningMessage.Position = UDim2.new(0, 10, 0, 50)
                    warningMessage.BackgroundTransparency = 1
                    warningMessage.Text = 'Player is too far to cuff (' .. math.floor(distance) .. ' studs away).\nDo you want to force teleport and cuff?'
                    warningMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
                    warningMessage.TextSize = 14
                    warningMessage.Font = Enum.Font.Ubuntu
                    warningMessage.TextXAlignment = Enum.TextXAlignment.Center
                    warningMessage.TextWrapped = true
                    warningMessage.Parent = dialogFrame
                    
                    -- Button container
                    local buttonContainer = Instance.new('Frame')
                    buttonContainer.Name = 'ButtonContainer'
                    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
                    buttonContainer.Position = UDim2.new(0, 10, 1, -50)
                    buttonContainer.BackgroundTransparency = 1
                    buttonContainer.Parent = dialogFrame
                    
                    local buttonLayout = Instance.new('UIListLayout')
                    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
                    buttonLayout.Padding = UDim.new(0, 10)
                    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    buttonLayout.Parent = buttonContainer
                    
                    -- No button
                    local noButton = Instance.new('TextButton')
                    noButton.Name = 'NoButton'
                    noButton.Size = UDim2.new(0, 80, 1, 0)
                    noButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    noButton.Text = 'No'
                    noButton.TextSize = 16
                    noButton.Font = Enum.Font.Ubuntu
                    noButton.AutoButtonColor = false
                    noButton.Parent = buttonContainer
                    
                    local noCorner = Instance.new('UICorner')
                    noCorner.CornerRadius = UDim.new(0, 8)
                    noCorner.Parent = noButton
                    
                    -- Yes button
                    local yesButton = Instance.new('TextButton')
                    yesButton.Name = 'YesButton'
                    yesButton.Size = UDim2.new(0, 80, 1, 0)
                    yesButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
                    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    yesButton.Text = 'Yes'
                    yesButton.TextSize = 16
                    yesButton.Font = Enum.Font.Ubuntu
                    yesButton.AutoButtonColor = false
                    yesButton.Parent = buttonContainer
                    
                    local yesCorner = Instance.new('UICorner')
                    yesCorner.CornerRadius = UDim.new(0, 8)
                    yesCorner.Parent = yesButton
                    
                    -- Button functionality
                    noButton.MouseButton1Click:Connect(function()
                        distanceWarningGui:Destroy()
                    end)
                    
                    yesButton.MouseButton1Click:Connect(function()
                        distanceWarningGui:Destroy()
                        
                        -- Proceed with teleport and cuff
                        local originalPosition = localRoot.CFrame
                        
                        -- Teleport to target
                        localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 0, -3)
                        task.wait(0.1) -- Small delay to ensure teleport completes
                        
                        -- Check for both R15 (UpperTorso) and R6 (Torso) compatibility
                        local torsoTarget = player.Character:FindFirstChild('UpperTorso') or player.Character:FindFirstChild('Torso')
                        if torsoTarget then
                            -- Check for cuff object (exact name first, then any containing "Cuff")
                            local cuffObject = nil
                            if localChar then
                                cuffObject = localChar:FindFirstChild('Cuffs')
                                if not cuffObject then
                                    -- Search for any object containing "Cuff" in the name
                                    for _, child in pairs(localChar:GetChildren()) do
                                        if string.find(child.Name:lower(), 'cuff') then
                                            cuffObject = child
                                            break
                                        end
                                    end
                                end
                            end
                            
                            if cuffObject then
                                local args = {
                                    'Cuff',
                                    torsoTarget,
                                }
                                local remoteEvent = cuffObject:FindFirstChild('RemoteEvent')
                                if remoteEvent then
                                    remoteEvent:FireServer(unpack(args))
                                end
                            else
                                -- Show notification that handcuffs must be equipped
                                game:GetService('StarterGui'):SetCore('SendNotification', {
                                    Title = 'Handcuffs Required',
                                    Text = 'You must have the handcuffs equipped to cuff players!',
                                    Duration = 3,
                                })
                            end
                        end
                        
                        -- Wait a moment for the cuff action to complete, then teleport back
                        task.wait(0.3)
                        if localRoot and localRoot.Parent then
                            localRoot.CFrame = originalPosition
                        end
                    end)
                    
                    -- Button hover effects
                    noButton.MouseEnter:Connect(function()
                        TweenService:Create(noButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(100, 100, 120)
                        }):Play()
                    end)
                    
                    noButton.MouseLeave:Connect(function()
                        TweenService:Create(noButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                        }):Play()
                    end)
                    
                    yesButton.MouseEnter:Connect(function()
                        TweenService:Create(yesButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(220, 170, 70)
                        }):Play()
                    end)
                    
                    yesButton.MouseLeave:Connect(function()
                        TweenService:Create(yesButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(200, 150, 50)
                        }):Play()
                    end)
                else
                    -- Player is close enough, proceed with normal cuffing
                    -- Check for both R15 (UpperTorso) and R6 (Torso) compatibility
                    local torsoTarget = player.Character:FindFirstChild('UpperTorso') or player.Character:FindFirstChild('Torso')
                    if torsoTarget then
                        -- Check for cuff object (exact name first, then any containing "Cuff")
                        local cuffObject = nil
                        if localChar then
                            cuffObject = localChar:FindFirstChild('Cuffs')
                            if not cuffObject then
                                -- Search for any object containing "Cuff" in the name
                                for _, child in pairs(localChar:GetChildren()) do
                                    if string.find(child.Name:lower(), 'cuff') then
                                        cuffObject = child
                                        break
                                    end
                                end
                            end
                        end
                        
                        if cuffObject then
                            local args = {
                                'Cuff',
                                torsoTarget,
                            }
                            local remoteEvent = cuffObject:FindFirstChild('RemoteEvent')
                            if remoteEvent then
                                remoteEvent:FireServer(unpack(args))
                            end
                        else
                            -- Show notification that handcuffs must be equipped
                            game:GetService('StarterGui'):SetCore('SendNotification', {
                                Title = 'Handcuffs Required',
                                Text = 'You must have the handcuffs equipped to cuff players!',
                                Duration = 3,
                            })
                        end
                    end
                end
            end
        end)

        -- Add elements to entry

        avatar.Parent = entry

        displayNameLabel.Parent = entry

        teleportButton.Parent = buttonContainer

        spectateButton.Parent = buttonContainer

        cuffButton.Parent = buttonContainer

        -- Troll Button Click Handler

        trollButton.MouseButton1Click:Connect(function()
            -- Check for admins before switching to troll tab
            local adminsInGame = checkForAdminsInGame()
            if #adminsInGame > 0 then
                showAdminWarning(adminsInGame)
            end
            
            if getgenv().UpdateTarget then
                getgenv().UpdateTarget(player)
            end
            if getgenv().switchTab then
                getgenv().switchTab('Troll')
            end
        end)

        trollButton.Parent = buttonContainer

        buttonContainer.Parent = entry

        -- Add smooth fade-in animation when entry is created
        entry.BackgroundTransparency = 1
        entry.Size = UDim2.new(1, 0, 0, 0) -- Start with 0 height
        
        -- Animate entry appearance with simplified logic
        task.spawn(function()
            -- First animate the entry frame size and background
            local sizeAnimation = TweenService:Create(entry, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 70),
                BackgroundTransparency = 0.3
            })
            
            sizeAnimation:Play()
            sizeAnimation.Completed:Wait()
            
            -- Simple fade in for all elements
            for _, child in pairs(entry:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    child.TextTransparency = 1
                    TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
                elseif child:IsA("ImageLabel") then
                    child.ImageTransparency = 1
                    TweenService:Create(child, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
                end
            end
        end)

        return entry
    end

    -- Function to Update Player List

    -- Player List Update Debouncing
    local lastPlayerListUpdate = 0
    local PLAYER_LIST_DEBOUNCE = 0.5 -- 500ms minimum between updates
    local playerListEntries = {} -- Track existing player entries

    -- Function to add a single player to the list
    function addPlayerToList(player, searchTerm)
        searchTerm = searchTerm and string.lower(searchTerm) or ''
        
        -- Check if player should be shown based on search
        if player ~= Players.LocalPlayer then
            local playerName = string.lower(player.Name)
            local displayName = string.lower(player.DisplayName)
            
            if string.find(playerName, searchTerm) or string.find(displayName, searchTerm) then
                -- Check if player entry already exists
                if playerListEntries[player.UserId] then
                    return -- Player already in list
                end
                
                -- Check if player is a friend
                local isFriend = false
                local success, friendStatus = pcall(function()
                    return Players.LocalPlayer:IsFriendsWith(player.UserId)
                end)
                
                if success and friendStatus then
                    isFriend = true
                end
                
                -- Create the player entry
                local entry = createPlayerEntry(player)
                entry.Parent = scrollFrame
                playerListEntries[player.UserId] = entry
                
                -- Reorder if needed - friends should be at the top
                if isFriend then
                    -- Move to top among friends
                    local children = scrollFrame:GetChildren()
                    local friendCount = 0
                    
                    -- Count existing friends
                    for _, child in ipairs(children) do
                        if child:IsA('Frame') and child ~= entry then
                            local childUserId = nil
                            for userId, entryFrame in pairs(playerListEntries) do
                                if entryFrame == child then
                                    childUserId = userId
                                    break
                                end
                            end
                            
                            if childUserId then
                                local childPlayer = Players:GetPlayerByUserId(childUserId)
                                if childPlayer then
                                    local childSuccess, childFriendStatus = pcall(function()
                                        return Players.LocalPlayer:IsFriendsWith(childUserId)
                                    end)
                                    
                                    if childSuccess and childFriendStatus then
                                        friendCount = friendCount + 1
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Set layout order to be at top
                    entry.LayoutOrder = friendCount
                end
                
                -- Update stats
                updatePlayerStats()
            end
        end
    end

    -- Function to remove a player from the list
    function removePlayerFromList(player)
        if playerListEntries[player.UserId] then
            local entry = playerListEntries[player.UserId]
            
            -- Add smooth fade-out animation before removing
            task.spawn(function()
                -- Fade out all child elements first
                for _, child in pairs(entry:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        task.spawn(function()
                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                                    TextTransparency = 1
                                }):Play()
                            end
                            
                            if child:IsA("ImageLabel") then
                                TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                                    ImageTransparency = 1
                                }):Play()
                            end
                            
                            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                                BackgroundTransparency = 1
                            }):Play()
                        end)
                    end
                end
                
                -- Then animate the main entry frame
                task.wait(0.1) -- Small delay before starting main animation
                local sizeAnimation = TweenService:Create(entry, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1
                })
                
                sizeAnimation:Play()
                sizeAnimation.Completed:Wait()
                
                -- Finally destroy the entry
                entry:Destroy()
            end)
            
            playerListEntries[player.UserId] = nil
            
            -- Update stats
            updatePlayerStats()
        end
    end

    -- Function to check if a player should be visible based on search
    function shouldPlayerBeVisible(player, searchTerm)
        if not searchTerm or searchTerm == "" then return true end
        
        searchTerm = string.lower(searchTerm)
        local playerName = string.lower(player.Name)
        local displayName = string.lower(player.DisplayName)
        
        return string.find(playerName, searchTerm) or string.find(displayName, searchTerm)
    end

    function updatePlayerList(searchTerm)
        -- Debounce frequent updates
        local currentTime = tick()
        if currentTime - lastPlayerListUpdate < PLAYER_LIST_DEBOUNCE then
            return
        end
        lastPlayerListUpdate = currentTime
        
        searchTerm = searchTerm and string.lower(searchTerm) or ''

        -- Clear existing entries
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA('Frame') then
                child:Destroy()
            end
        end
        playerListEntries = {} -- Clear tracking

        -- Separate players into friends and non-friends
        local friends = {}
        local nonFriends = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                if shouldPlayerBeVisible(player, searchTerm) then
                    -- Check if player is a friend
                    local isFriend = false
                    local success, friendStatus = pcall(function()
                        return Players.LocalPlayer:IsFriendsWith(player.UserId)
                    end)
                    
                    if success and friendStatus then
                        table.insert(friends, player)
                    else
                        table.insert(nonFriends, player)
                    end
                end
            end
        end
        
        -- Add friends first, then non-friends
        for _, player in ipairs(friends) do
            local entry = createPlayerEntry(player)
            entry.Parent = scrollFrame
            playerListEntries[player.UserId] = entry
        end
        
        for _, player in ipairs(nonFriends) do
            local entry = createPlayerEntry(player)
            entry.Parent = scrollFrame
            playerListEntries[player.UserId] = entry
        end
        
        -- Update player stats
        updatePlayerStats()
    end

    -- Function to update player statistics with debouncing
    local lastStatsUpdate = 0
    local STATS_UPDATE_DEBOUNCE = 1 -- 1 second minimum between updates

    function updatePlayerStats()
        local currentTime = tick()
        if currentTime - lastStatsUpdate < STATS_UPDATE_DEBOUNCE then
            return -- Skip if too recent
        end
        lastStatsUpdate = currentTime
        
        local totalPlayers = #Players:GetPlayers() - 1 -- Exclude local player
        local totalAdmins = 0
        
        -- Count admins by checking group roles
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                -- Check if player has cached admin role
                if isRoleCacheValid(player.UserId) then
                    totalAdmins = totalAdmins + 1
                else
                    -- Check role asynchronously if not cached
                    task.spawn(function()
                        local success, roleInGroup = pcall(function()
                            return player:GetRoleInGroup(35822612)
                        end)
                        
                        if success and roleInGroup and roleInGroup ~= "Guest" then
                            local roleLower = roleInGroup:lower()
                            local hasRequiredRole = string.find(roleLower, "support") or 
                                                string.find(roleLower, "owner") or 
                                                string.find(roleLower, "developer")
                            
                            if hasRequiredRole then
                                roleCache[player.UserId] = {
                                    role = roleInGroup, 
                                    timestamp = tick()
                                }
                                -- Update stats after async check
                                task.wait(0.1)
                                updatePlayerStats()
                            end
                        end
                    end)
                end
            end
        end
        
        -- Update the labels
        if totalPlayersLabel then
            totalPlayersLabel.Text = 'Players: ' .. totalPlayers
        end
        
        if totalAdminsLabel then
            totalAdminsLabel.Text = 'Admins: ' .. totalAdmins
        end
        
        -- Async role checking for unknown players (background task)
        task.spawn(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and not isRoleCacheValid(player.UserId) then
                    local success, roleInGroup = pcall(function()
                        return player:GetRoleInGroup(35822612)
                    end)
                    
                    if success and roleInGroup and roleInGroup ~= "Guest" then
                        -- Use EXCLUSION LIST approach (same as ESP Admins and main tab)
                        local roleLower = roleInGroup:lower()
                        
                        -- List of roles that should NOT be marked as admin
                        local excludedRoles = {
                            "member", "booster", "top donators", "graphic designer",
                            "content creator", "vip", "streamer", "modeler",
                            "elite donor", "viber"
                        }
                        
                        -- Check if player has an excluded role
                        local isExcluded = false
                        for _, excludedRole in ipairs(excludedRoles) do
                            if string.find(roleLower, excludedRole) then
                                isExcluded = true
                                break
                            end
                        end
                        
                        -- Mark as admin if NOT excluded
                        local hasRequiredRole = not isExcluded
                        
                        if hasRequiredRole then
                            roleCache[player.UserId] = {
                                role = roleInGroup,
                                timestamp = tick()
                            }
                            
                            -- Update stats again after discovering new admin
                            task.wait(0.5)
                            updatePlayerStats()
                            break -- Only process one at a time to avoid spam
                        end
                    end
                    
                    task.wait(0.1) -- Small delay between requests
                end
            end
        end)
    end

    -- Initial Player List Load

    updatePlayerList()

    -- Refresh Button Click

    refreshButton.MouseButton1Click:Connect(function()
        updatePlayerList(searchBox.Text)
    end)

    -- Search Functionality

    local searchDebounceTime = 0
    searchBox:GetPropertyChangedSignal('Text'):Connect(function()
        local currentTime = tick()
        searchDebounceTime = currentTime
        
        spawn(function()
            wait(0.3) -- Debounce delay
            if searchDebounceTime == currentTime then
                -- For search, we need to refresh the entire list to show/hide players
                updatePlayerList(searchBox.Text)
            end
        end)
    end)

    -- Automatic Player List Updates

    Players.PlayerAdded:Connect(function(player)
        -- Listen for when this player's character respawns
        player.CharacterAdded:Connect(function()
            if mainFrame.Visible then
                task.wait(0.5) -- Small delay to ensure character is fully loaded
                addPlayerToList(player, searchBox.Text)
            end
        end)
        
        if mainFrame.Visible then
            addPlayerToList(player, searchBox.Text)
        end
    end)

    -- Also handle existing players' respawns
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            player.CharacterAdded:Connect(function()
                if mainFrame.Visible then
                    task.wait(0.5)
                    addPlayerToList(player, searchBox.Text)
                end
            end)
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        -- Clean up role cache
        if roleCache[player.UserId] then
            roleCache[player.UserId] = nil
        end
        
        if mainFrame.Visible then
            removePlayerFromList(player)
        end
    end)

    -- Draggable Menu (Touch and Mouse Support)

    local dragging = false
    local dragInput, dragStart, startPos
    local dragTween = nil -- Store current drag tween for smooth interruption

    local function updateInput(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        -- Cancel previous tween for immediate responsiveness
        if dragTween then
            dragTween:Cancel()
        end
        
        -- For very small movements, update position immediately for maximum responsiveness
        local deltaSize = math.abs(delta.X) + math.abs(delta.Y)
        if deltaSize < 5 then
            mainFrame.Position = newPosition
        else
            -- For larger movements, use ultra-smooth minimal tweening
            dragTween = TweenService:Create(mainFrame, TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                Position = newPosition
            })
            dragTween:Play()
        end
        
        savedMenuPosition = newPosition -- Save position for next time
    end

    -- Make the entire mainFrame draggable
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            -- Pulse animation when dragging starts
            TweenService:Create(mainFrame, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.15,
            }):Play()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    
                    -- Cancel any ongoing drag tween
                    if dragTween then
                        dragTween:Cancel()
                        dragTween = nil
                    end
                    
                    -- Smooth settling animation when drag ends
                    local settleAnimation = TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1,
                    })
                    settleAnimation:Play()
                    
                    -- Add a subtle bounce effect to the final position for polish
                    local currentPos = mainFrame.Position
                    local bounceAnimation = TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = currentPos
                    })
                    bounceAnimation:Play()
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        elseif input == iconDragInput and iconDragging then
            updateIconInput(input)
        end
    end)

    -- Toggle Menu (No Animation)

    local function toggleMenu()
        if not keyEntered then
            createKeyDialog()
            return
        end
        
        if not mainFrame then
            return
        end

        if not mainFrame.Visible then
            -- Opening animation - fade in only
            mainFrame.Visible = true
            
            -- Hide menu icon when menu is open (but ensure it's ready for next close)
            if keyEntered and menuIcon and menuIcon.Parent then -- Only hide if key system is passed AND icon exists
                menuIcon.Visible = false
            end
            
            -- Set position and size immediately (no scaling animation)
            mainFrame.Position = savedMenuPosition
            if isMobile then
                mainFrame.Size = UDim2.new(0, 380, 0, 340) -- Optimized for mobile phones
            else
                mainFrame.Size = UDim2.new(0, 400, 0, 500)
            end
            
            -- Start transparent and fade in
            mainFrame.BackgroundTransparency = 1
            
            -- Fade in animation only
            local fadeAnimation = TweenService:Create(mainFrame, 
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {
                    BackgroundTransparency = 0.1
                }
            )
            fadeAnimation:Play()
            
            -- Fade in border
            if mainFrame:FindFirstChild('UIStroke') then
                local border = mainFrame:FindFirstChild('UIStroke')
                border.Transparency = 1
                
                TweenService:Create(border, 
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Transparency = 0.5}
                ):Play()
            end
        else
            -- Closing animation - fade out only
            -- Save current position before closing
            savedMenuPosition = mainFrame.Position
            
            -- Show menu icon when menu is closed (only if key was entered)
            if keyEntered and menuIcon and menuIcon.Parent then -- Check if both key is entered AND icon exists
                menuIcon.Visible = true
            end
            
            -- Fade out animation only (no scaling)
            local fadeOutAnimation = TweenService:Create(
                mainFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    BackgroundTransparency = 1
                }
            )
            
            -- Fade out border
            if mainFrame:FindFirstChild('UIStroke') then
                local border = mainFrame:FindFirstChild('UIStroke')
                
                TweenService:Create(border, 
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Transparency = 1}
                ):Play()
            end
            
            -- Hide after fade animation completes
            fadeOutAnimation.Completed:Connect(function()
                mainFrame.Visible = false
            end)
            
            fadeOutAnimation:Play()
        end
    end

    -- Close Button

    closeButton.MouseButton1Click:Connect(function()
        toggleMenu()
    end)

    -- Menu Icon Click to Toggle (defined here after toggleMenu function exists)
    menuIcon.MouseButton1Click:Connect(function()
        -- Only toggle if not currently dragging AND didn't just finish dragging
        if not iconDragging and not iconHasDragged then
            toggleMenu()
        end
    end)

    -- Update icon visibility after all setup is complete
    if menuIcon then
        menuIcon.Visible = menuIconShouldBeAvailable and (not mainFrame or not mainFrame.Visible)
    end

    -- Key Bind (DELETE Key)
    local keybindConnections = {} -- Store all keybind connections for cleanup

    -- Only connect keybinds if they are set (not "unset")
    if TOGGLE_KEY then
        keybindConnections.toggleMenu = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == TOGGLE_KEY and not menuEjected then
                toggleMenu()
            end
        end)
    end

    -- Dynamic Key Toggle for Fly
    if FLY_TOGGLE_KEY then
        keybindConnections.toggleFly = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == FLY_TOGGLE_KEY and not menuEjected then
                toggleFly()
            end
        end)
    end

    -- Dynamic Key Toggle for Cuff Nearest (only for non-mobile)
    if not isMobile and CUFF_KEY then
        keybindConnections.cuffNearest = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == CUFF_KEY and not menuEjected then
                cuffNearestPlayer()
            end
        end)
    end

    -- Dynamic Key Toggle for Reset Character (only for non-mobile)
    if not isMobile and RESET_KEY then
        keybindConnections.resetCharacter = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == RESET_KEY and not menuEjected then
                resetCharacter()
            end
        end)
    end

    -- Dynamic Key Toggle for Carry Player
    if CARRY_KEY then
        keybindConnections.carryPlayer = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == CARRY_KEY and not menuEjected then
                carryNearestPlayer()
            end
        end)
    end

    -- Dynamic Key Toggle for Glitch Player
    if GLITCH_KEY then
        keybindConnections.glitchPlayer = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == GLITCH_KEY and not menuEjected then
                glitchNearestPlayer()
            end
        end)
    end
    --    end)
   -- end

    -- Dynamic Key Toggle for Invisible
    if INVISIBLE_KEY then
        keybindConnections.toggleInvisible = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == INVISIBLE_KEY and not menuEjected then
                toggleInvisible()
            end
        end)
    end

    -- Click to Uncarry (single click when holding CarryFriend tool)
    keybindConnections.clickUncarry = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Only handle mouse/touch clicks
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local character = localPlayer.Character
            if not character then return end
            
            -- Check if we're holding a tool with "carry" in its name
            local tool = character:FindFirstChildOfClass("Tool")
            if not tool then return end
            
            local toolName = tool.Name:lower()
            if not toolName:find("carry") then return end
            
            -- Get the carry remote
            local carryRemote = tool:FindFirstChild("Carry")
            if not carryRemote then return end
            
            -- Single click uncarry - no delay, no double-click check
            carryRemote:FireServer(
                "Uncarry",
                nil,
                "PointerOnly"
            )
            
            -- Optional: small notification
            pcall(function()
                game:GetService('StarterGui'):SetCore('SendNotification', {
                    Title = 'Uncarry',
                    Text = 'Released player',
                    Duration = 1,
                })
            end)
        end
    end)

    -- Ensure original camera is saveda

    local function onCharacterAdded(character)
        originalCameraSubject = character:WaitForChild('Humanoid')
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    -- Add main frame to GUI

    mainFrame.Parent = gui

    -- Initialize with Main tab selected
    if contentPages and contentPages["Main"] then
        switchTab("Main")
    end

    -- Handle character respawning for AFK system
    Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1) -- Small delay to ensure PlayerGui exists
        
        -- Reset AFK state to false when character respawns
        if isAFK then
            isAFK = false
            
            -- Only update button if it exists
            if afkButton and afkButton.Parent then
                afkButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- Red when OFF
                afkButton.Text = 'AFK: OFF'
            end
            
            -- Send false to server since character is no longer AFK after respawn
            local args = {false}
            spawn(function()
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("AFK THINGY"):WaitForChild("AFKEvent"):FireServer(unpack(args))
                end)
            end)
        end
    end)

    -- Function to reconnect keybinds after changes (defined at the very end when all functions are available)
    local function reconnectKeybinds()
        -- Disconnect existing keybind connections
        if keybindConnections then
            for keybindName, connection in pairs(keybindConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            keybindConnections = {}
        end
        
        -- Reconnect only if keys are set (not "unset") and menu not ejected
        if TOGGLE_KEY then
            keybindConnections.toggleMenu = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == TOGGLE_KEY and not menuEjected then
                    toggleMenu()
                end
            end)
        end

        if FLY_TOGGLE_KEY then
            keybindConnections.toggleFly = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == FLY_TOGGLE_KEY and not menuEjected then
                    toggleFly()
                end
            end)
        end

        if not isMobile and CUFF_KEY then
            keybindConnections.cuffNearest = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == CUFF_KEY and not menuEjected then
                    cuffNearestPlayer()
                end
            end)
        end

        if not isMobile and RESET_KEY then
            keybindConnections.resetCharacter = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == RESET_KEY and not menuEjected then
                    resetCharacter()
                end
            end)
        end

        if CARRY_KEY then
            keybindConnections.carryPlayer = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == CARRY_KEY and not menuEjected then
                    carryNearestPlayer()
                end
            end)
        end

      if GLITCH_KEY then
            keybindConnections.glitchPlayer = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == GLITCH_KEY and not menuEjected then
                    glitchNearestPlayer()
                end
            end)
      end

        if INVISIBLE_KEY then
            keybindConnections.toggleInvisible = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == INVISIBLE_KEY and not menuEjected then
                    toggleInvisible()
                end
            end)
        end
    end

    -- Create keybind settings now that all functions are defined
    if not isMobile then
        createKeybindSetting("ToggleMenu", keybinds.toggleMenu, "Toggle Menu", function(keyName, keyCode)
            keybinds.toggleMenu = keyName
            TOGGLE_KEY = (keyName ~= "unset") and keyCode or nil
            saveKeybinds()
            reconnectKeybinds()
        end)

        createKeybindSetting("ToggleFly", keybinds.toggleFly, "Toggle Fly", function(keyName, keyCode)
            keybinds.toggleFly = keyName
            FLY_TOGGLE_KEY = (keyName ~= "unset") and keyCode or nil
            saveKeybinds()
            reconnectKeybinds()
        end)

        createKeybindSetting("CuffNearest", keybinds.cuffNearest, "Cuff Nearest Player", function(keyName, keyCode)
            keybinds.cuffNearest = keyName
            CUFF_KEY = (keyName ~= "unset") and keyCode or nil
            saveKeybinds()
            reconnectKeybinds()
        end)

        createKeybindSetting("ResetCharacter", keybinds.resetCharacter, "Reset Character (VIP)", function(keyName, keyCode)
            keybinds.resetCharacter = keyName
            RESET_KEY = (keyName ~= "unset") and keyCode or nil
            saveKeybinds()
            reconnectKeybinds()
        end)

        createKeybindSetting("CarryPlayer", keybinds.carryPlayer, "Carry Nearest Player", function(keyName, keyCode)
            keybinds.carryPlayer = keyName
            CARRY_KEY = (keyName ~= "unset") and keyCode or nil
            saveKeybinds()
            reconnectKeybinds()
        end)

     createKeybindSetting("GlitchPlayer", keybinds.glitchPlayer, "Glitch Nearest Player", function(keyName, keyCode)
           keybinds.glitchPlayer = keyName
         GLITCH_KEY = (keyName ~= "unset") and keyCode or nil
         saveKeybinds()
       reconnectKeybinds()
     end)
    end

    -- Initialize keybind connections now that all functions are defined
    reconnectKeybinds()

    end -- End of createMainGUI function

    -- Loading Screen Function
    local function showLoadingScreen()
        local loadingGui = Instance.new('ScreenGui')
        loadingGui.Name = 'LoadingScreen'
        loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        loadingGui.IgnoreGuiInset = true
        loadingGui.Parent = game:GetService('CoreGui')
        
        -- Background overlay
        local overlay = Instance.new('Frame')
        overlay.Name = 'Overlay'
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.3
        overlay.BorderSizePixel = 0
        overlay.Parent = loadingGui
        
        -- Loading frame
        local loadingFrame = Instance.new('Frame')
        loadingFrame.Name = 'LoadingFrame'
        loadingFrame.Size = UDim2.new(0, 300, 0, 150)
        loadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        loadingFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
        loadingFrame.BorderSizePixel = 0
        loadingFrame.Parent = overlay
        
        local loadingCorner = Instance.new('UICorner')
        loadingCorner.CornerRadius = UDim.new(0, 12)
        loadingCorner.Parent = loadingFrame
        
        local loadingBorder = Instance.new('UIStroke')
        loadingBorder.Color = Color3.fromRGB(53, 9, 211)
        loadingBorder.Thickness = 2
        loadingBorder.Parent = loadingFrame
        
        -- Loading title
        local loadingTitle = Instance.new('TextLabel')
        loadingTitle.Name = 'LoadingTitle'
        loadingTitle.Size = UDim2.new(1, -20, 0, 40)
        loadingTitle.Position = UDim2.new(0, 10, 0, 20)
        loadingTitle.BackgroundTransparency = 1
        loadingTitle.Text = 'XmodzProject'
        loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadingTitle.TextSize = 20
        loadingTitle.Font = Enum.Font.Ubuntu
        loadingTitle.TextXAlignment = Enum.TextXAlignment.Center
        loadingTitle.Parent = loadingFrame
        
        -- Loading text
        local loadingText = Instance.new('TextLabel')
        loadingText.Name = 'LoadingText'
        loadingText.Size = UDim2.new(1, -20, 0, 30)
        loadingText.Position = UDim2.new(0, 10, 0, 70)
        loadingText.BackgroundTransparency = 1
        loadingText.Text = 'Initializing...'
        loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
        loadingText.TextSize = 14
        loadingText.Font = Enum.Font.Ubuntu
        loadingText.TextXAlignment = Enum.TextXAlignment.Center
        loadingText.Parent = loadingFrame
        
        -- Loading spinner/dots animation
        local dots = ""
        local dotCount = 0
        task.spawn(function()
            while loadingGui.Parent do
                dotCount = (dotCount % 3) + 1
                dots = string.rep(".", dotCount)
                loadingText.Text = 'Initializing' .. dots
                task.wait(0.5)
            end
        end)
        
        return loadingGui
    end

    -- Show loading screen
    local loadingScreen = showLoadingScreen()

    -- Wait for initialization (simulating the delay)
    task.wait(0.5)

    -- Destroy loading screen before showing key dialog
    if loadingScreen then
        loadingScreen:Destroy()
    end

    -- Only show key dialog on script start (GUI creation happens after successful key entry)
    createKeyDialog()

