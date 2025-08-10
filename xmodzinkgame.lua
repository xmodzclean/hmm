--!nonstrict

--[[
	@author Jorsan
]]
--// F8 Toggle Air Freeze
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local isFrozen = false
local savedPosition = nil
local freezeConnection = nil

local function freezePlayer()
    savedPosition = hrp.CFrame
    local targetPos = savedPosition + Vector3.new(0, 40, 0)
    hrp.CFrame = CFrame.new(targetPos.Position)
    
    humanoid.PlatformStand = true  -- Prevents movement
    freezeConnection = game:GetService("RunService").Heartbeat:Connect(function()
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = CFrame.new(targetPos.Position) -- Keep in place
    end)
    isFrozen = true
end

local function unfreezePlayer()
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    humanoid.PlatformStand = false
    if savedPosition then
        hrp.CFrame = savedPosition
    end
    isFrozen = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.G then
        if not isFrozen then
            freezePlayer()
        else
            unfreezePlayer()
        end
    end
end)

-- Put this in StarterPlayerScripts as a LocalScript
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local featureEnabled = false

-- Toggle feature with F4
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        featureEnabled = not featureEnabled
        print("Teleport-into-player feature is now", featureEnabled and "ENABLED" or "DISABLED")
    end
end)

-- Find nearest player (excluding yourself)
local function findNearestPlayer()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart

    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local distance = (hrp.Position - targetHRP.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end

    return nearestPlayer
end

-- Teleport inside & follow for 3 seconds
Mouse.Button1Down:Connect(function()
    if not featureEnabled then return end

    local nearestPlayer = findNearestPlayer()
    if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = nearestPlayer.Character.HumanoidRootPart

        -- Instantly teleport inside them
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetHRP.CFrame
        print("Teleported inside", nearestPlayer.Name, "and linking for 3 seconds...")

        -- Link movement for 3 seconds
        local startTime = tick()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not nearestPlayer.Character or not nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                connection:Disconnect()
                return
            end

            local elapsed = tick() - startTime
            if elapsed >= 3 then
                connection:Disconnect()
                print("Link ended.")
                return
            end

            -- Stay inside the player
            LocalPlayer.Character.HumanoidRootPart.CFrame = nearestPlayer.Character.HumanoidRootPart.CFrame
        end)
    else
        print("No players found to teleport to!")
    end
end)

local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

UserInputService.InputBegan:Connect(function(input, isProcessed)
	if not isProcessed then
		if input.KeyCode == Enum.KeyCode.E then
			humanoid.WalkSpeed = 100
		end
	end
end)
-- XmodzProject Mod Menu
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
-- Slap cooldown system
-- Global Slap Cooldown System
local slapCooldown = 14 -- seconds
local canSlap = true
local slapButtons = {} -- Table to track all slap buttons

-- CONFIGURATION
local TOGGLE_KEY = Enum.KeyCode.Delete
local MENU_TITLE = "XmodzProject"
local ACCENT_COLOR = Color3.fromRGB(140, 50, 200)
local BG_COLOR = Color3.fromRGB(25, 25, 35)

-- Create GUI
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "XmodzProjectMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame with Cool Animation
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = BG_COLOR
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false

-- Modern Rounded Corners with Animated Border
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local border = Instance.new("UIStroke")
border.Color = ACCENT_COLOR
border.Thickness = 2
border.Transparency = 0.5
border.Parent = mainFrame

-- Header with Gradient and Animation
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = BG_COLOR
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerGradient = Instance.new("UIGradient")
headerGradient.Rotation = 90
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT_COLOR),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 40, 160)),
    ColorSequenceKeypoint.new(1, BG_COLOR)
})
headerGradient.Parent = header

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Title with Text Glow
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = MENU_TITLE
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeColor3 = ACCENT_COLOR
title.TextStrokeTransparency = 0.7
title.Parent = header

-- Close Button with Hover Animation
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.AnchorPoint = Vector2.new(0.5, 0.5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.AutoButtonColor = false

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- Close Button Hover Effects
closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(220, 70, 70),
        Size = UDim2.new(0, 32, 0, 32)
    }):Play()
end)

closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Size = UDim2.new(0, 30, 0, 30)
    }):Play()
end)

closeButton.Parent = header

-- Search Box with Cool Animation
local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -20, 0, 35)
searchBox.Position = UDim2.new(0, 10, 0, 60)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderText = "Search players..."
searchBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
searchBox.Text = ""
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 15)
searchPadding.PaddingRight = UDim.new(0, 15)
searchPadding.Parent = searchBox

searchBox.Parent = mainFrame

-- Function Buttons Container
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -20, 0, 35)
buttonContainer.Position = UDim2.new(0, 10, 0, 100)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.Padding = UDim.new(0, 5)
buttonLayout.Parent = buttonContainer

-- Refresh Button with Animation
local refreshButton = Instance.new("TextButton")
refreshButton.Name = "RefreshButton"
refreshButton.Size = UDim2.new(0.25, -10, 1, 0)
refreshButton.BackgroundColor3 = ACCENT_COLOR
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.Text = "Refresh"
refreshButton.TextSize = 14
refreshButton.Font = Enum.Font.GothamBold
refreshButton.AutoButtonColor = false

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 6)
refreshCorner.Parent = refreshButton

refreshButton.MouseEnter:Connect(function()
    TweenService:Create(refreshButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(160, 70, 220),
        Size = UDim2.new(0.25, -5, 1, 0)
    }):Play()
end)

refreshButton.MouseLeave:Connect(function()
    TweenService:Create(refreshButton, TweenInfo.new(0.2), {
        BackgroundColor3 = ACCENT_COLOR,
        Size = UDim2.new(0.25, -10, 1, 0)
    }):Play()
end)

refreshButton.Parent = buttonContainer

-- Freecam Button with Animation
local freecamButton = Instance.new("TextButton")
freecamButton.Name = "FreecamButton"
freecamButton.Size = UDim2.new(0.25, -10, 1, 0)
freecamButton.BackgroundColor3 = Color3.fromRGB(60, 150, 200)
freecamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
freecamButton.Text = "Freecam: OFF"
freecamButton.TextSize = 14
freecamButton.Font = Enum.Font.GothamBold
freecamButton.AutoButtonColor = false

local freecamCorner = Instance.new("UICorner")
freecamCorner.CornerRadius = UDim.new(0, 6)
freecamCorner.Parent = freecamButton

freecamButton.MouseEnter:Connect(function()
    TweenService:Create(freecamButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(80, 170, 220),
        Size = UDim2.new(0.25, -5, 1, 0)
    }):Play()
end)

freecamButton.MouseLeave:Connect(function()
    TweenService:Create(freecamButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(60, 150, 200),
        Size = UDim2.new(0.25, -10, 1, 0)
    }):Play()
end)

freecamButton.Parent = buttonContainer

-- ESP Toggle Button with Animation
local espButton = Instance.new("TextButton")
espButton.Name = "ESPButton"
espButton.Size = UDim2.new(0.25, -10, 1, 0)
espButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Text = "ESP: OFF"
espButton.TextSize = 14
espButton.Font = Enum.Font.GothamBold
espButton.AutoButtonColor = false

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espButton

espButton.MouseEnter:Connect(function()
    TweenService:Create(espButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(220, 120, 70),
        Size = UDim2.new(0.25, -5, 1, 0)
    }):Play()
end)

espButton.MouseLeave:Connect(function()
    TweenService:Create(espButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(200, 100, 50),
        Size = UDim2.new(0.25, -10, 1, 0)
    }):Play()
end)

espButton.Parent = buttonContainer

-- Speed Button with Animation
local speedButton = Instance.new("TextButton")
speedButton.Name = "SpeedButton"
speedButton.Size = UDim2.new(0.25, -10, 1, 0)
speedButton.BackgroundColor3 = Color3.fromRGB(80, 180, 120)
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Text = "Speed: OFF"
speedButton.TextSize = 14
speedButton.Font = Enum.Font.GothamBold
speedButton.AutoButtonColor = false

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedButton

speedButton.MouseEnter:Connect(function()
    TweenService:Create(speedButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(100, 200, 140),
        Size = UDim2.new(0.25, -5, 1, 0)
    }):Play()
end)

speedButton.MouseLeave:Connect(function()
    TweenService:Create(speedButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(80, 180, 120),
        Size = UDim2.new(0.25, -10, 1, 0)
    }):Play()
end)

speedButton.Parent = buttonContainer

-- Player List Container
local playerListContainer = Instance.new("Frame")
playerListContainer.Name = "PlayerListContainer"
playerListContainer.Size = UDim2.new(1, -20, 1, -170)
playerListContainer.Position = UDim2.new(0, 10, 0, 150)
playerListContainer.BackgroundTransparency = 1
playerListContainer.Parent = mainFrame

-- Scroll Frame with Smooth Scrolling
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.ScrollBarImageColor3 = ACCENT_COLOR
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = playerListContainer

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- Spectate System
local originalCameraSubject = workspace.CurrentCamera.CameraSubject
local currentlySpectating = nil

-- Freecam System
local freecamEnabled = false
local freecamController = nil
local freecamConnections = {}

local function enableFreecam()
    if freecamEnabled then return end
    
    freecamController = Instance.new("Part")
    freecamController.Anchored = true
    freecamController.Transparency = 1
    freecamController.CanCollide = false
    freecamController.Size = Vector3.new(1, 1, 1)
    freecamController.CFrame = workspace.CurrentCamera.CFrame
    freecamController.Parent = workspace
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid.AutoRotate = false
        end
    end
    
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    workspace.CurrentCamera.CameraSubject = freecamController
    freecamEnabled = true
    freecamButton.Text = "Freecam: ON"
    
    local speed = 1
    local moveVector = Vector3.new(0, 0, 0)
    
    freecamConnections.inputBegan = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            speed = 2
        end
    end)
    
    freecamConnections.inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            speed = 1
        end
    end)
    
    freecamConnections.heartbeat = RunService.Heartbeat:Connect(function(dt)
        moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + freecamController.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - freecamController.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - freecamController.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + freecamController.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector + Vector3.new(0, -1, 0)
        end
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * speed * 20 * dt
            freecamController.CFrame = freecamController.CFrame + moveVector
        end
        
        local mouseDelta = UserInputService:GetMouseDelta()
        if mouseDelta.Magnitude > 0 then
            local lookX = mouseDelta.X * 0.0015
            local lookY = mouseDelta.Y * 0.0015
            
            local currentCF = freecamController.CFrame
            freecamController.CFrame = currentCF * CFrame.Angles(0, -lookX, 0) * CFrame.Angles(lookY, 0, 0)
        end
    end)
end

local function disableFreecam()
    if not freecamEnabled then return end
    
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject = originalCameraSubject
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    
    for _, conn in pairs(freecamConnections) do
        conn:Disconnect()
    end
    freecamConnections = {}
    
    if freecamController then
        freecamController:Destroy()
        freecamController = nil
    end
    
    freecamEnabled = false
    freecamButton.Text = "Freecam: OFF"
end

freecamButton.MouseButton1Click:Connect(function()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end)

-- Speed Boost System
local speedBoostEnabled = false
local originalWalkSpeed = 16

speedButton.MouseButton1Click:Connect(function()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if speedBoostEnabled then
                humanoid.WalkSpeed = originalWalkSpeed
                speedButton.Text = "Speed: OFF"
                speedBoostEnabled = false
            else
                originalWalkSpeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = 100
                speedButton.Text = "Speed: ON"
                speedBoostEnabled = true
            end
        end
    end
end)

player.CharacterAdded:Connect(function(character)
    if speedBoostEnabled then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed =100
    end
end)

-- ESP System
local espEnabled = false
local nameTags = {}

local function createNameTag(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DisplayNameESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = humanoidRootPart
    billboard.LightInfluence = 1
    billboard.MaxDistance = 1000
    billboard.Parent = character

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "DisplayNameLabel"
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 18
    nameLabel.Parent = billboard

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Text = "@"..player.Name
    usernameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    usernameLabel.TextStrokeTransparency = 0.7
    usernameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    usernameLabel.Position = UDim2.new(0, 0, 0.6, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 14
    usernameLabel.Parent = billboard

    nameTags[player] = billboard

    local function cleanUp()
        if billboard and billboard.Parent then
            billboard:Destroy()
            nameTags[player] = nil
        end
    end

    player.CharacterRemoving:Connect(cleanUp)
    
    local localPlayer = Players.LocalPlayer
    local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local localRoot = localCharacter:WaitForChild("HumanoidRootPart")

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent or not humanoidRootPart or not localRoot then
            connection:Disconnect()
            return
        end
        
        local distance = (humanoidRootPart.Position - localRoot.Position).Magnitude
        local textSize = math.clamp(22 - (distance / 30), 12, 22)
        nameLabel.TextSize = textSize
        usernameLabel.TextSize = textSize - 4
    end)
end

local function enableESP()
    if espEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if player.Character then
                createNameTag(player)
            end
            player.CharacterAdded:Connect(function()
                createNameTag(player)
            end)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            if player ~= Players.LocalPlayer then
                createNameTag(player)
            end
        end)
    end)
    
    espEnabled = true
    espButton.Text = "ESP: ON"
end

local function disableESP()
    if not espEnabled then return end
    
    for player, billboard in pairs(nameTags) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    
    nameTags = {}
    espEnabled = false
    espButton.Text = "ESP: OFF"
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
    local entry = Instance.new("Frame")
    entry.Name = player.Name
    entry.Size = UDim2.new(1, 0, 0, 70)
    entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    entry.BackgroundTransparency = 0.3
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entry

    entry.MouseEnter:Connect(function()
        TweenService:Create(entry, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        }):Play()
    end)
    
    entry.MouseLeave:Connect(function()
        TweenService:Create(entry, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        }):Play()
    end)
    
    -- Player Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 45, 0, 45)
    avatar.Position = UDim2.new(0, 8, 0.5, -22.5)
    avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    avatar.BorderSizePixel = 0
    avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar
    
    local avatarBorder = Instance.new("UIStroke")
    avatarBorder.Color = ACCENT_COLOR
    avatarBorder.Thickness = 2
    avatarBorder.Parent = avatar
    
    -- Player Display Name
    local displayNameLabel = Instance.new("TextLabel")
    displayNameLabel.Name = "DisplayNameLabel"
    displayNameLabel.Size = UDim2.new(0.6, -60, 0.5, -5)
    displayNameLabel.Position = UDim2.new(0, 60, 0, 5)
    displayNameLabel.BackgroundTransparency = 1
    displayNameLabel.Text = player.DisplayName
    displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    displayNameLabel.TextSize = 16
    displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayNameLabel.Font = Enum.Font.GothamBold
    
    -- Player Username (smaller)
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Size = UDim2.new(0.6, -60, 0.5, -5)
    usernameLabel.Position = UDim2.new(0, 60, 0.5, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@"..player.Name
    usernameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    usernameLabel.TextSize = 12
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Font = Enum.Font.Gotham
    
    -- Button Container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(0.4, -10, 1, -10)
    buttonContainer.Position = UDim2.new(0.6, 0, 0.5, -20)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = entry
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.Padding = UDim.new(0, 5)
    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.Parent = buttonContainer
    
    -- Teleport Button
    local teleportButton = Instance.new("TextButton")
    teleportButton.Name = "TeleportButton"
    teleportButton.Size = UDim2.new(0, 60, 0, 25)
    teleportButton.BackgroundColor3 = ACCENT_COLOR
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Text = "TP"
    teleportButton.TextSize = 12
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.AutoButtonColor = false
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 5)
    teleportCorner.Parent = teleportButton
    
    -- Spectate Button
    local spectateButton = Instance.new("TextButton")
    spectateButton.Name = "SpectateButton"
    spectateButton.Size = UDim2.new(0, 60, 0, 25)
    spectateButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    spectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spectateButton.Text = "Spectate"
    spectateButton.TextSize = 12
    spectateButton.Font = Enum.Font.GothamBold
    spectateButton.AutoButtonColor = false
    
    local spectateCorner = Instance.new("UICorner")
    spectateCorner.CornerRadius = UDim.new(0, 5)
    spectateCorner.Parent = spectateButton
    
    -- Cuff Button
    local cuffButton = Instance.new("TextButton")
    cuffButton.Name = "CuffButton"
    cuffButton.Size = UDim2.new(0, 60, 0, 25)
    cuffButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    cuffButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cuffButton.Text = "Cuff"
    cuffButton.TextSize = 12
    cuffButton.Font = Enum.Font.GothamBold
    cuffButton.AutoButtonColor = false
    
    local cuffCorner = Instance.new("UICorner")
    cuffCorner.CornerRadius = UDim.new(0, 5)
    cuffCorner.Parent = cuffButton
    
    -- Slap Button with Global Cooldown
local slapButton = Instance.new("TextButton")
slapButton.Name = "SlapButton"
slapButton.Size = UDim2.new(0, 60, 0, 25)
slapButton.BackgroundColor3 = canSlap and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(100, 100, 100)
slapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
slapButton.Text = canSlap and "Slap" or "Cooldown"
slapButton.TextSize = 12
slapButton.Font = Enum.Font.GothamBold
slapButton.AutoButtonColor = false

local slapCorner = Instance.new("UICorner")
slapCorner.CornerRadius = UDim.new(0, 5)
slapCorner.Parent = slapButton

-- Store reference to this button
table.insert(slapButtons, slapButton)

-- Slap Functionality with Global Cooldown
slapButton.MouseButton1Click:Connect(function()
    if not canSlap then return end
    
    if player.Character then
        -- Start global cooldown
        canSlap = false
        local startTime = os.time()
        
        -- Update all slap buttons
        for _, btn in ipairs(slapButtons) do
            btn.Text = tostring(slapCooldown)
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
        
        -- Perform the slap
        local args = {
            player.Character,
            65, -- Damage value
            "rbxassetid://6575995124" -- Sound or effect asset
        }
        
        if game:GetService("ReplicatedStorage"):FindFirstChild("Events") and 
           game:GetService("ReplicatedStorage").Events:FindFirstChild("Bat") then
            game:GetService("ReplicatedStorage").Events.Bat:FireServer(unpack(args))
        end
        
        -- Start cooldown timer
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local elapsed = os.time() - startTime
            local remaining = slapCooldown - elapsed
            
            if remaining <= 0 then
                -- Cooldown complete
                canSlap = true
                for _, btn in ipairs(slapButtons) do
                    btn.Text = "Slap"
                    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                end
                connection:Disconnect()
            else
                -- Update all buttons
                for _, btn in ipairs(slapButtons) do
                    btn.Text = tostring(math.floor(remaining))
                end
            end
        end)
    end
end)
-- Modified Button Hover Effects
local function setupButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        if button.Name == "SlapButton" and not canSlap then return end
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor,
            Size = UDim2.new(0, 62, 0, 27)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if button.Name == "SlapButton" and not canSlap then 
            button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            return 
        end
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = normalColor,
            Size = UDim2.new(0, 60, 0, 25)
        }):Play()
    end)
end
-- Clean up slap button reference when player leaves
player.AncestryChanged:Connect(function(_, parent)
    if not parent then
        for i, btn in ipairs(slapButtons) do
            if btn.Parent and btn.Parent.Parent and btn.Parent.Parent.Name == player.Name then
                table.remove(slapButtons, i)
                break
            end
        end
    end
end)
    
    setupButtonHover(teleportButton, ACCENT_COLOR, Color3.fromRGB(160, 70, 220))
    setupButtonHover(spectateButton, Color3.fromRGB(80, 80, 100), Color3.fromRGB(100, 100, 120))
    setupButtonHover(cuffButton, Color3.fromRGB(200, 150, 50), Color3.fromRGB(220, 170, 70))
    setupButtonHover(slapButton, Color3.fromRGB(200, 50, 50), Color3.fromRGB(220, 70, 70))
    
    -- Teleport Functionality
    teleportButton.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local localChar = Players.LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                localChar.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        end
    end)
    
    -- Spectate Functionality
    spectateButton.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if currentlySpectating == player then
                workspace.CurrentCamera.CameraSubject = originalCameraSubject
                spectateButton.Text = "Spectate"
                spectateButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                currentlySpectating = nil
            else
                if currentlySpectating then
                    for _, btn in ipairs(scrollFrame:GetDescendants()) do
                        if btn.Name == "SpectateButton" and btn.Text == "Stop Spectate" then
                            btn.Text = "Spectate"
                            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                        end
                    end
                end
                
                workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                spectateButton.Text = "Stop Spectate"
                spectateButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                currentlySpectating = player
            end
        end
    end)
    
    -- Cuff Functionality
    cuffButton.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("UpperTorso") then
            local args = {
                "Cuff",
                player.Character:WaitForChild("UpperTorso")
            }
            
            -- Check if cuffs exist in local player's character
            local localChar = Players.LocalPlayer.Character
            if localChar and localChar:FindFirstChild("Cuffs") then
                localChar:FindFirstChild("Cuffs"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
            end
        end
    end)
    
    -- Slap Functionality with Cooldown
slapButton.MouseButton1Click:Connect(function()
    if not canSlap then return end
    
    if player.Character then
        -- Disable slapping during cooldown
        canSlap = false
        slapCooldownStart = os.time()
        slapButton.Text = "Cooldown"
        slapButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        -- Perform the slap
        local args = {
            player.Character,
            65, -- Damage value
            "rbxassetid://6575995124" -- Sound or effect asset
        }
        
        if game:GetService("ReplicatedStorage"):FindFirstChild("Events") and 
           game:GetService("ReplicatedStorage").Events:FindFirstChild("Bat") then
            game:GetService("ReplicatedStorage").Events.Bat:FireServer(unpack(args))
        end
        
        -- Start cooldown timer
        local startTime = os.time()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local elapsed = os.time() - startTime
            local remaining = slapCooldown - elapsed
            
            if remaining <= 0 then
                -- Cooldown complete
                canSlap = true
                slapButton.Text = "Slap"
                slapButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                connection:Disconnect()
            else
                -- Update cooldown display
                slapButton.Text = tostring(math.floor(remaining))
            end
        end)
    end
end)
    
    -- Add elements to entry
    avatar.Parent = entry
    displayNameLabel.Parent = entry
    usernameLabel.Parent = entry
    teleportButton.Parent = buttonContainer
    spectateButton.Parent = buttonContainer
    cuffButton.Parent = buttonContainer
    slapButton.Parent = buttonContainer
    buttonContainer.Parent = entry
    
    return entry
end

-- Function to Update Player List
local function updatePlayerList(searchTerm)
    searchTerm = searchTerm and string.lower(searchTerm) or ""
    
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if string.find(string.lower(player.Name), searchTerm) or 
               string.find(string.lower(player.DisplayName), searchTerm) then
                local entry = createPlayerEntry(player)
                entry.Parent = scrollFrame
            end
        end
    end
end

-- Initial Player List Load
updatePlayerList()

-- Refresh Button Click
refreshButton.MouseButton1Click:Connect(function()
    updatePlayerList(searchBox.Text)
end)

-- Search Functionality
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayerList(searchBox.Text)
end)

-- Draggable Menu
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        -- Pulse animation when dragging starts
        TweenService:Create(header, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.2
        }):Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(header, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                }):Play()
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Toggle Menu with Cool Animation
local function toggleMenu()
    mainFrame.Visible = not mainFrame.Visible
    
    if mainFrame.Visible then
        -- Reset position to center with animation
        mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        
        local openAnim = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 400, 0, 500),
            BackgroundTransparency = 0.1
        })
        
        openAnim:Play()
        openAnim.Completed:Wait()
        updatePlayerList(searchBox.Text)
    else
        -- Close animation
        local closeAnim = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        
        closeAnim:Play()
    end
end

-- Close Button
closeButton.MouseButton1Click:Connect(function()
    toggleMenu()
end)

-- Key Bind (DELETE Key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        toggleMenu()
    end
end)

-- Ensure original camera is saveda
local function onCharacterAdded(character)
    originalCameraSubject = character:WaitForChild("Humanoid")
end

if player.Character then
    onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Add main frame to GUI
mainFrame.Parent = gui

-- Toggle Infinite Jump with F1
local UIS = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
local InfiniteJumpEnabled = false

-- Toggle when F1 is pressed
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
		InfiniteJumpEnabled = not InfiniteJumpEnabled
		print("Infinite Jump: " .. tostring(InfiniteJumpEnabled))
	end
end)

-- Infinite Jump logic
UIS.JumpRequest:Connect(function()
	if InfiniteJumpEnabled then
		Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

local targetPosition = Vector3.new(-110.6603012084961, 1023.0537109375, 148.5098419189453)
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore if typing in chat
    if input.KeyCode == Enum.KeyCode.F2 then
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(targetPosition)
        end
    end
end)

-- Libraries
local Maid = loadstring(game:HttpGet('https://raw.githubusercontent.com/Quenty/NevermoreEngine/refs/heads/main/src/maid/src/Shared/Maid.lua'))()
local Signal = loadstring(game:HttpGet('https://raw.githubusercontent.com/stravant/goodsignal/refs/heads/master/src/init.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- @class RedLightGreenLight
local RedLightGreenLight = {}
RedLightGreenLight.__index = RedLightGreenLight

function RedLightGreenLight.new(UIManager)
    local self = setmetatable({}, RedLightGreenLight)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    self._Maid:GiveTask(function()
        self._IsGreenLight = nil
        self._LastRootPartCFrame = nil
    end)

    return self
end

function RedLightGreenLight:Start()
    local Client = Players.LocalPlayer
    local TrafficLightImage = Client.PlayerGui:WaitForChild("ImpactFrames"):WaitForChild("TrafficLightEmpty")

    self._IsGreenLight = TrafficLightImage.Image == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image

    local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
    self._LastRootPartCFrame = RootPart and RootPart.CFrame
    
    self._Maid:GiveTask(ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(EffectsData)
        if EffectsData.EffectName ~= "TrafficLight" then return end

        self._IsGreenLight = EffectsData.GreenLight == true

        local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
        self._LastRootPartCFrame = RootPart and RootPart.CFrame
    end))

    local OriginalNamecall
    OriginalNamecall = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(Instance, ...)
        local Args = {...}

        if getnamecallmethod() == "FireServer" and Instance.ClassName == "RemoteEvent" and Instance.Name == "rootCFrame" then
            if self._UIManager:GetToggleValue("RedLightGodMode") and self._IsGreenLight == false and self._LastRootPartCFrame then
                -- Send cached CFrame data when it's red light
                Args[1] = self._LastRootPartCFrame
                return OriginalNamecall(Instance, unpack(Args))
            end
        end

        return OriginalNamecall(Instance, ...)
    end))

    self._Maid:GiveTask(function()
        hookfunction(getrawmetatable(game).__namecall, OriginalNamecall)
    end)

    warn("RLGL feature started!")
end

function RedLightGreenLight:Destroy()
    warn("RLGL feature destroyed!")
    self._Maid:Destroy()
end

-- @class Dalgona
local Dalgona = {}
Dalgona.__index = Dalgona

function Dalgona.new(UIManager)
    local self = setmetatable({}, Dalgona)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function Dalgona:Start()
    local DalgonaClientModule = game.ReplicatedStorage.Modules.Games.DalgonaClient

    local function CompleteDalgona()
        --[[
            Search for the callback of RunService.RenderStepped
             containing an upvalue used to keep track of the amount of successful clicks
             for the Dalgona challenge.

            Setting this upvalue (amount of successful clicks) to a large number
             will allow it to pass the Dalgona challenge checks.
        ]]

        if not self._UIManager:GetToggleValue("DalgonaAuto") then return end

        for _, Value in ipairs(getreg()) do
            if typeof(Value) == "function" and islclosure(Value) then
                if getfenv(Value).script == DalgonaClientModule then
                    if getinfo(Value).nups == 73 then
                        setupvalue(Value, 31, 9e9)
                        break
                    end
                end
            end
        end
    end
    
    local OriginalDalgonaFunction
    OriginalDalgonaFunction = hookfunction(require(DalgonaClientModule), function(...)
        task.delay(3, CompleteDalgona)        
        return OriginalDalgonaFunction(...)
    end)

    self._Maid:GiveTask(function()
        hookfunction(require(DalgonaClientModule), OriginalDalgonaFunction)
        self._UIManager.Toggles.DalgonaAuto:OnChanged(function() end)
    end)
    
    self._UIManager.Toggles.DalgonaAuto:OnChanged(CompleteDalgona)
    
    warn("Dalgona feature started!")
end

function Dalgona:Destroy()
    warn("Dalgona feature destroyed!")
    self._Maid:Destroy()
end

-- @class TugOfWar
local TugOfWar = {}
TugOfWar.__index = TugOfWar

function TugOfWar.new(UIManager)
    local self = setmetatable({}, TugOfWar)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function TugOfWar:Start()
    local TemporaryReachedBindableRemote = ReplicatedStorage.Remotes.TemporaryReachedBindable
    
    local PULL_RATE = 0.025
    local VALID_PULL_DATA = {
        ["PerfectQTE"] = true
    }

    self._Maid:GiveTask(task.spawn(function()
        while task.wait(PULL_RATE) do
            if self._UIManager:GetToggleValue("TugOfWarAuto") then
                TemporaryReachedBindableRemote:FireServer(VALID_PULL_DATA)
            end
        end
    end))

    warn("TugOfWar feature started!")
end

function TugOfWar:Destroy()
    warn("TugOfWar feature destroyed!")
    self._Maid:Destroy()
end

-- @class GlassBridge
local GlassBridge = {}
GlassBridge.__index = GlassBridge

function GlassBridge.new(UIManager)
    local self = setmetatable({}, GlassBridge)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function GlassBridge:Start()
    local GlassHolder = workspace.GlassBridge.GlassHolder

    local function SetupGlassPart(GlassPart)
        local CanEnableGlassBridgeESP = self._UIManager:GetToggleValue("GlassBridgeESP")
        if not CanEnableGlassBridgeESP then
            GlassPart.Color = Color3.fromRGB(106, 106, 106)
            GlassPart.Transparency = 0.45
            GlassPart.Material = Enum.Material.SmoothPlastic
        else
            -- Game owner is quite funny :skull:
            local Color = GlassPart:GetAttribute("exploitingisevil") and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
            GlassPart.Color = Color
            GlassPart.Transparency = 0
            GlassPart.Material = Enum.Material.Neon
        end
    end
    
    self._UIManager.Toggles.GlassBridgeESP:OnChanged(function()
        for _, PanelPair in ipairs(GlassHolder:GetChildren()) do
            for _, Panel in ipairs(PanelPair:GetChildren()) do
                local GlassPart = Panel:FindFirstChild("glasspart")
                if GlassPart then
                    task.defer(SetupGlassPart, GlassPart)
                end
            end
        end
    end)

    self._Maid:GiveTask(GlassHolder.DescendantAdded:Connect(function(Descendant)
        if Descendant.Name == "glasspart" and Descendant:IsA("BasePart") then
            task.defer(SetupGlassPart, Descendant)
        end
    end))

    self._Maid:GiveTask(function()
        self._UIManager.Toggles.GlassBridgeESP:OnChanged(function() end)
    end)

    warn("GlassBridge feature started!")
end

function GlassBridge:Destroy()
    warn("GlassBridge feature destroyed!")
    self._Maid:Destroy()
end

-- @class Mingle
local Mingle = {}
Mingle.__index = Mingle

function Mingle.new(UIManager)
    local self = setmetatable({}, Mingle)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function Mingle:Start()
    local Client = game:GetService("Players").LocalPlayer

    local CharacterMaid = Maid.new()
    self._Maid:GiveTask(CharacterMaid)

    local function OnCharacterAdded(Character)
        CharacterMaid:DoCleaning()

        local function OnRemoteForQTEAdded(RemoteForQTE)
            CharacterMaid:GiveTask(task.spawn(function()
                while task.wait(0.5) do
                    if not RemoteForQTE then break end
                    if not RemoteForQTE.Parent then break end

                    if self._UIManager:GetToggleValue("MinglePowerHoldAuto") then
                        RemoteForQTE:FireServer()
                    end
                end
            end))
        end

        local function OnChildAdded(Object)
            if Object.ClassName == "RemoteEvent" and Object.Name == "RemoteForQTE" then
                OnRemoteForQTEAdded(Object)
            end
        end

        CharacterMaid:GiveTask(Character.ChildAdded:Connect(OnChildAdded))
        for _, Object in ipairs(Character:GetChildren()) do
            task.spawn(OnChildAdded, Object)
        end
    end

    self._Maid:GiveTask(Client.CharacterAdded:Connect(OnCharacterAdded))
    if Client.Character then
        task.spawn(OnCharacterAdded, Client.Character)
    end

    warn("Mingle feature started!")
end

function Mingle:Destroy()
    warn("Mingle feature destroyed!")
    self._Maid:Destroy()
end

-- @class HideAndSeek
local HideAndSeek = {}
HideAndSeek.__index = HideAndSeek

function HideAndSeek.new(UIManager)
    local self = setmetatable({}, HideAndSeek)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    -- Credits to Kiriot for the ESP lib
    self._ESP = loadstring(game:HttpGet('https://kiriot22.com/releases/ESP.lua'))()
    
    return self
end

function HideAndSeek:Start()
    local ROLES_DATA = {
        IsHider = {Name = "Hider", Color = Color3.fromRGB(0, 255, 230), Flag = "Hiders"},
        IsHunter = {Name = "Hunter", Color = Color3.fromRGB(251, 0, 0), Flag = "Hunters"}
    }

    local Client = game:GetService("Players").LocalPlayer
    local BoxObjects = {}

    local function OnPlayerAdded(Player)
        if Player == Client then return end
        
        local PlayerMaid = Maid.new()
        self._Maid:GiveTask(PlayerMaid)

        local CharacterMaid = Maid.new()
        PlayerMaid:GiveTask(CharacterMaid)
        
        local function OnCharacterAdded(Character)
            CharacterMaid:DoCleaning()
            local RootPart = Character:WaitForChild("HumanoidRootPart")
            
            local function OnRoleAdded(Role)
                local RoleData = ROLES_DATA[Role]

                table.insert(BoxObjects, self._ESP:Add(Character, {
                    Name = "Role: " .. RoleData.Name .. " | " .. "Player Name: " .. Player.Name,
                    Color = RoleData.Color,
                    PrimaryPart = RootPart,
                    IsEnabled = RoleData.Flag,
                }))
            end

            for _, Attribute in ipairs({"IsHider", "IsHunter"}) do
                CharacterMaid:GiveTask(Player:GetAttributeChangedSignal(Attribute):Connect(function()
                    if Player:GetAttribute(Attribute) ~= true then return end
                    OnRoleAdded(Attribute)
                end))
                if Player:GetAttribute(Attribute) == true then
                    task.spawn(OnRoleAdded, Attribute)
                end
            end
        end

        PlayerMaid:GiveTask(Player.AncestryChanged:Connect(function(_, NewParent)
            if NewParent then return end
            PlayerMaid:Destroy()
        end))

        PlayerMaid:GiveTask(Player.CharacterAdded:Connect(OnCharacterAdded))
        if Player.Character then
            task.spawn(OnCharacterAdded, Player.Character)
        end
    end
    
    self._Maid:GiveTask(Players.PlayerAdded:Connect(OnPlayerAdded))
    for _, Player in ipairs(Players:GetPlayers()) do
        task.spawn(OnPlayerAdded, Player)
    end
    
    self._UIManager.Toggles.HiderESP:OnChanged(function() 
        self._ESP.Hiders = self._UIManager:GetToggleValue("HiderESP")
    end)

    self._UIManager.Toggles.HunterESP:OnChanged(function() 
        self._ESP.Hunters = self._UIManager:GetToggleValue("HunterESP")
    end)

    self._Maid:GiveTask(function()
        for _, Box in ipairs(BoxObjects) do
            Box:Remove()
        end
        table.clear(BoxObjects)

        self._ESP:Toggle(false)

        self._UIManager.Toggles.HiderESP:OnChanged(function() end)
        self._UIManager.Toggles.HunterESP:OnChanged(function() end)
    end)
   
    self._ESP.Players = true
    self._ESP:Toggle(true)

    warn("HideAndSeek feature started!")
end

function HideAndSeek:Destroy()
    warn("HideAndSeek feature destroyed!")
    self._Maid:Destroy()
end

-- @class UIManager
local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local self = setmetatable({}, UIManager)
    
    self._Maid = Maid.new()
    self._Library = nil
    self._ThemeManager = nil
    self._Window = nil
    self._Tabs = {}
    
    self.IsDestroyed = false

    -- Load and initialize the UI
    self:_LoadLibrary()
    
    self.Toggles = getgenv().Toggles
    self.Options = getgenv().Options

    self:_CreateWindow()
    self:_SetupTabs()
    
    self._Maid:GiveTask(function()
        self.IsDestroyed = true

        -- Terminate the script
        shared._InkGameScriptState.Cleanup()

        -- Unload library
        self._Library:Unload()
        
        -- Clear references
        self._ThemeManager = nil
        self._Library = nil
        self._Window = nil
        self._Tabs = nil
        self.Toggles = nil
        self.Options = nil
    end)

    self._ThemeManager:ApplyTheme("Tokyo Night")
    
    return self
end

function UIManager:_LoadLibrary()
    self._Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkClpher/RBX-Scripts/refs/heads/main/UI-Libraries/LinoriaUI.luau'))()

    self._ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()
    self._ThemeManager:SetLibrary(self._Library)

    if not self._Library then
        error("Failed to load LinoriaLib")
    end
end

function UIManager:_CreateWindow()
    self._Window = self._Library:CreateWindow({
        Title = "Xmodz Project | discord.gg/xmodzproject | Ig : @xmodz.yt",
        Center = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2,
        Size = UDim2.new(0, 525, 0, 400)
    })
end

function UIManager:_SetupTabs()
    -- Create tabs
    self._Tabs = {
        Main = self._Window:AddTab("Main"),
        Player = self._Window:AddTab("Player"),
        Settings = self._Window:AddTab("Settings")
    }
    
    -- Setup tabs
    self:_SetupMainCheatsTab()
    self:_SetupPlayerTab()
    self:_SetupSettingsTab()
end

function UIManager:_SetupMainCheatsTab()
    local RoundCheatsGroup = self._Tabs.Main:AddLeftGroupbox("Round Cheats")
    
    -- Red Light Green Light God Mode
    RoundCheatsGroup:AddToggle("RedLightGodMode", {
        Text = "Red Light God Mode",
        Default = false,
        Tooltip = "Prevents you from being eliminated during Red Light Green Light"
    })
    
    -- Tug of War Auto Pull
    RoundCheatsGroup:AddToggle("TugOfWarAuto", {
        Text = "Tug of War Auto Pull",
        Default = false,
        Tooltip = "Automatically pulls during Tug of War game"
    })
    
    -- Dalgona Auto Complete
    RoundCheatsGroup:AddToggle("DalgonaAuto", {
        Text = "Dalgona Auto Complete",
        Default = false,
        Tooltip = "Automatically completes the Dalgona cookie challenge"
    })

    -- Mingle power hold minigame/QTE Auto solver
    RoundCheatsGroup:AddToggle("MinglePowerHoldAuto", {
        Text = "Mingle Auto Minigame Solver",
        Default = false,
        Tooltip = "Automatically completes the Mingle power hold minigame/QTE"
    })
    
    -- ESP/Visuals
    local VisualsGroup = self._Tabs.Main:AddRightGroupbox("Visuals")

    VisualsGroup:AddLabel("Hide And Seek")

    VisualsGroup:AddToggle("HiderESP", {
        Text = "Hider ESP",
        Default = false,
        Tooltip = "Visually shows where the hiders are located and their status"
    })

    VisualsGroup:AddToggle("HunterESP", {
        Text = "Hunter ESP",
        Default = false,
        Tooltip = "Visually shows where the hunters are located and their status"
    })

    VisualsGroup:AddDivider()
    VisualsGroup:AddLabel("Glass Bridge")
    
    VisualsGroup:AddToggle("GlassBridgeESP", {
        Text = "Glass Bridge ESP",
        Default = false,
        Tooltip = "Visually shows which glass panels are safe to step on"
    })
end

function UIManager:_SetupPlayerTab()
    local PlayerSettings = self._Tabs.Player:AddLeftGroupbox("Player Modifications")

    -- NoClip Toggle
    PlayerSettings:AddToggle("EnableWalkSpeed", {
        Text = "Enable WalkSpeed",
        Default = false
    })

    -- WalkSpeed Changer
    PlayerSettings:AddSlider("WalkSpeed", {
        Text = "Walk Speed",
        Default = 16,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Compact = false,
        Suffix = " studs/s"
    })

    -- Add divider
    PlayerSettings:AddDivider()

    -- NoClip Toggle
    PlayerSettings:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false,
        Tooltip = "Walk through walls"
    })

    -- Setup character cheats
    local Client = Players.LocalPlayer
    local CharacterMaid = Maid.new()

    self._Maid:GiveTask(CharacterMaid)

    local function OnCharacterAdded(Character)
        CharacterMaid:DoCleaning()
        local Humanoid = Character:WaitForChild("Humanoid")
        
        local CachedBaseParts = {}
        for _, Object in ipairs(Character:GetDescendants()) do
            if Object:IsA("BasePart") then
                table.insert(CachedBaseParts, Object)
            end
        end

        CharacterMaid:GiveTask(Character.DescendantAdded:Connect(function(Descendant)
            if Descendant:IsA("BasePart") then
                table.insert(CachedBaseParts, Descendant)
            end
        end))
        
        local function ChangeWalkSpeed()
            if not self:GetToggleValue("EnableWalkSpeed") then return end
            local NewWalkSpeed = self:GetOptionValue("WalkSpeed")
            if not NewWalkSpeed then return end
        
            Humanoid.WalkSpeed = NewWalkSpeed
        end
        
        CharacterMaid:GiveTask(Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(ChangeWalkSpeed))

        local NoclippedBaseParts = {}
        CharacterMaid:GiveTask(RunService.Stepped:Connect(function()
            if not self:GetToggleValue("Noclip") then
                for BasePart, _ in NoclippedBaseParts do
                    NoclippedBaseParts[BasePart] = nil
                    BasePart.CanCollide = true
                end
                return
            end

            for _, BasePart in ipairs(CachedBaseParts) do
                if BasePart.CanCollide then
                    NoclippedBaseParts[BasePart] = true
                    BasePart.CanCollide = false
                end
            end
        end))
        
        CharacterMaid:GiveTask(function()
            table.clear(CachedBaseParts)
            for BasePart, _ in NoclippedBaseParts do
                NoclippedBaseParts[BasePart] = nil
                BasePart.CanCollide = true
            end
        end)

        self.Toggles.EnableWalkSpeed:OnChanged(ChangeWalkSpeed)
        self.Options.WalkSpeed:OnChanged(ChangeWalkSpeed)
    end

    self._Maid:GiveTask(function()
        self.Toggles.EnableWalkSpeed:OnChanged(function() end)
        self.Options.WalkSpeed:OnChanged(function() end)
    end)
    
    self._Maid:GiveTask(Client.CharacterAdded:Connect(OnCharacterAdded))
    
    if Client.Character then
        task.spawn(OnCharacterAdded, Client.Character)
    end
end

function UIManager:_SetupSettingsTab()
    local MenuSettings = self._Tabs.Settings:AddLeftGroupbox("Menu Settings")
    
    MenuSettings:AddButton({
        Text = "Unload/Destroy Script",
        Func = function()
            self:Destroy()
        end,
        Tooltip = "Completely removes and destroys the script"
    })
end

function UIManager:GetToggleValue(ToggleName)
    if self.Toggles and self.Toggles[ToggleName] then
        return self.Toggles[ToggleName].Value
    end
    return false
end

function UIManager:GetOptionValue(OptionName)
    if self.Options and self.Options[OptionName] then
        return self.Options[OptionName].Value
    end
    
    return nil
end

function UIManager:Notify(Text, Duration)
    if not self._Library then return end
    self._Library:Notify(Text, Duration)
end

function UIManager:Destroy()
    if self.IsDestroyed then return end
    self._Maid:Destroy()
    
    warn("UIManager destroyed successfully!")
end

-- Validate game
assert(game.GameId == 7008097940, "Invalid Game!")

-- Setup Global State
if not shared._InkGameScriptState then
    shared._InkGameScriptState = {
        IsScriptExecuted = false,
        IsScriptReady = false,
        ScriptReady = Signal.new(),
        Cleanup = function() end
    }
end

local GlobalScriptState = shared._InkGameScriptState

-- Handle script re-execution
if GlobalScriptState.IsScriptExecuted then
    if not GlobalScriptState.IsScriptReady then
        GlobalScriptState.ScriptReady:Wait()
        if GlobalScriptState.IsScriptReady then return end
    end
    GlobalScriptState.Cleanup()
end

GlobalScriptState.IsScriptExecuted = true

-- Main
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local UI = UIManager.new()
local GameState = workspace.Values

local CurrentRunningFeature = nil
local GameChangedConnection = nil

local Features = {
    ["RedLightGreenLight"] = RedLightGreenLight,
    ["Dalgona"] = Dalgona,
    ["TugOfWar"] = TugOfWar,
    ["GlassBridge"] = GlassBridge,
    ["Mingle"] = Mingle,
    ["HideAndSeek"] = HideAndSeek
}

local function CleanupCurrentFeature()
    if CurrentRunningFeature then
        CurrentRunningFeature:Destroy()
        CurrentRunningFeature = nil
    end
end

local function CurrentGameChanged()
    warn("Current game: " .. GameState.CurrentGame.Value)
    
    CleanupCurrentFeature()
    
    local Feature = Features[GameState.CurrentGame.Value]
    if not Feature then return end

    CurrentRunningFeature = Feature.new(UI)
    CurrentRunningFeature:Start()
end

-- Setup connections
GameChangedConnection = GameState.CurrentGame:GetPropertyChangedSignal("Value"):Connect(CurrentGameChanged)
CurrentGameChanged()

-- Global cleanup function
GlobalScriptState.Cleanup = function()
    CleanupCurrentFeature()
    
    if GameChangedConnection then
        GameChangedConnection:Disconnect()
        GameChangedConnection = nil
    end
    
    if not UI.IsDestroyed then
        UI:Destroy()
    end
    
    GlobalScriptState.IsScriptReady = false
    GlobalScriptState.IsScriptExecuted = false
end

-- Mark as ready
GlobalScriptState.IsScriptReady = true
GlobalScriptState.ScriptReady:Fire()

UI:Notify("Script executed successfully!", 4)
UI:Notify("Script authored by: Xmodz, enjoy!", 4)


local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- Force Roblox default cursor
UIS.MouseIconEnabled = true
mouse.Icon = ""



-- Keep checking every frame
RS.RenderStepped:Connect(function()
    UIS.MouseIconEnabled = true
    mouse.Icon = ""
end)
