-- XmodzProject Mod Menu
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- CONFIGURATION
local TOGGLE_KEY = Enum.KeyCode.Insert
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

-- Animated Glow Effect
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.Size = UDim2.new(1, 40, 1, 40)
glow.Position = UDim2.new(0, -20, 0, -20)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = ACCENT_COLOR
glow.ImageTransparency = 0.8
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 276, 276)
glow.Parent = mainFrame

-- Pulsing Animation for Glow
local pulseIn = TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
    ImageTransparency = 0.6
})
local pulseOut = TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
    ImageTransparency = 0.8
})

pulseIn.Completed:Connect(function()
    pulseOut:Play()
end)
pulseOut.Completed:Connect(function()
    pulseIn:Play()
end)
pulseIn:Play()

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

-- Search Box Focus Animation
searchBox.Focused:Connect(function()
    TweenService:Create(searchBox, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Position = UDim2.new(0, 5, 0, 60),
        Size = UDim2.new(1, -10, 0, 35)
    }):Play()
end)

searchBox.FocusLost:Connect(function()
    TweenService:Create(searchBox, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(1, -20, 0, 35)
    }):Play()
end)

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
refreshButton.Size = UDim2.new(0.33, -10, 1, 0)
refreshButton.BackgroundColor3 = ACCENT_COLOR
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.Text = "Refresh"
refreshButton.TextSize = 14
refreshButton.Font = Enum.Font.GothamBold
refreshButton.AutoButtonColor = false

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 6)
refreshCorner.Parent = refreshButton

-- Refresh Button Hover Effect
refreshButton.MouseEnter:Connect(function()
    TweenService:Create(refreshButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(160, 70, 220),
        Size = UDim2.new(0.33, -5, 1, 0)
    }):Play()
end)

refreshButton.MouseLeave:Connect(function()
    TweenService:Create(refreshButton, TweenInfo.new(0.2), {
        BackgroundColor3 = ACCENT_COLOR,
        Size = UDim2.new(0.33, -10, 1, 0)
    }):Play()
end)

refreshButton.Parent = buttonContainer

-- Freecam Button with Animation
local freecamButton = Instance.new("TextButton")
freecamButton.Name = "FreecamButton"
freecamButton.Size = UDim2.new(0.33, -10, 1, 0)
freecamButton.BackgroundColor3 = Color3.fromRGB(60, 150, 200)
freecamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
freecamButton.Text = "Freecam: OFF"
freecamButton.TextSize = 14
freecamButton.Font = Enum.Font.GothamBold
freecamButton.AutoButtonColor = false

local freecamCorner = Instance.new("UICorner")
freecamCorner.CornerRadius = UDim.new(0, 6)
freecamCorner.Parent = freecamButton

-- Freecam Button Hover Effect
freecamButton.MouseEnter:Connect(function()
    TweenService:Create(freecamButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(80, 170, 220),
        Size = UDim2.new(0.33, -5, 1, 0)
    }):Play()
end)

freecamButton.MouseLeave:Connect(function()
    TweenService:Create(freecamButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(60, 150, 200),
        Size = UDim2.new(0.33, -10, 1, 0)
    }):Play()
end)

freecamButton.Parent = buttonContainer

-- ESP Toggle Button with Animation
local espButton = Instance.new("TextButton")
espButton.Name = "ESPButton"
espButton.Size = UDim2.new(0.33, -10, 1, 0)
espButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Text = "ESP: OFF"
espButton.TextSize = 14
espButton.Font = Enum.Font.GothamBold
espButton.AutoButtonColor = false

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espButton

-- ESP Button Hover Effect
espButton.MouseEnter:Connect(function()
    TweenService:Create(espButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(220, 120, 70),
        Size = UDim2.new(0.33, -5, 1, 0)
    }):Play()
end)

espButton.MouseLeave:Connect(function()
    TweenService:Create(espButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(200, 100, 50),
        Size = UDim2.new(0.33, -10, 1, 0)
    }):Play()
end)

espButton.Parent = buttonContainer

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

-- Improved Freecam System with ZQSD Movement
local freecamEnabled = false
local freecamController = nil
local freecamConnections = {}

local function enableFreecam()
    if freecamEnabled then return end
    
    -- Save current camera state
    freecamController = Instance.new("Part")
    freecamController.Anchored = true
    freecamController.Transparency = 1
    freecamController.CanCollide = false
    freecamController.Size = Vector3.new(1, 1, 1)
    freecamController.CFrame = workspace.CurrentCamera.CFrame
    freecamController.Parent = workspace
    
    -- Freeze player
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid.AutoRotate = false
        end
    end
    
    -- Set camera to freecam
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    workspace.CurrentCamera.CameraSubject = freecamController
    freecamEnabled = true
    freecamButton.Text = "Freecam: ON"
    
    -- Movement controls (ZQSD)
    local speed = 1
    local moveVector = Vector3.new(0, 0, 0)
    
    -- Keyboard input handling
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
    
    -- Movement update
    freecamConnections.heartbeat = RunService.Heartbeat:Connect(function(dt)
        moveVector = Vector3.new(0, 0, 0)
        
        -- Z = Forward
        if UserInputService:IsKeyDown(Enum.KeyCode.Z) then
            moveVector = moveVector + freecamController.CFrame.LookVector
        end
        -- S = Backward
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - freecamController.CFrame.LookVector
        end
        -- Q = Left
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveVector = moveVector - freecamController.CFrame.RightVector
        end
        -- D = Right
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + freecamController.CFrame.RightVector
        end
        -- Space = Up
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        -- LeftControl = Down
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector + Vector3.new(0, -1, 0)
        end
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * speed * 20 * dt
            freecamController.CFrame = freecamController.CFrame + moveVector
        end
        
        -- Mouse look
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
    
    -- Restore original camera
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject = originalCameraSubject
    
    -- Unfreeze player
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    
    -- Cleanup connections
    for _, conn in pairs(freecamConnections) do
        conn:Disconnect()
    end
    freecamConnections = {}
    
    -- Remove controller
    if freecamController then
        freecamController:Destroy()
        freecamController = nil
    end
    
    freecamEnabled = false
    freecamButton.Text = "Freecam: OFF"
end

-- Freecam Toggle
freecamButton.MouseButton1Click:Connect(function()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end)

-- ESP System with Display Names
local espEnabled = false
local nameTags = {}

local function createNameTag(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Create billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DisplayNameESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = humanoidRootPart
    billboard.LightInfluence = 1
    billboard.MaxDistance = 1000
    billboard.Parent = character

    -- Display name label
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

    -- Username label (smaller)
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

    -- Store reference
    nameTags[player] = billboard

    -- Cleanup function
    local function cleanUp()
        if billboard and billboard.Parent then
            billboard:Destroy()
            nameTags[player] = nil
        end
    end

    player.CharacterRemoving:Connect(cleanUp)
    
    -- Distance-based scaling
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
    
    -- Create ESP for all players
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
    
    -- Handle new players
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
    
    -- Remove all name tags
    for player, billboard in pairs(nameTags) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    
    nameTags = {}
    espEnabled = false
    espButton.Text = "ESP: OFF"
end

-- ESP Toggle
espButton.MouseButton1Click:Connect(function()
    if espEnabled then
        disableESP()
    else
        enableESP()
    end
end)

-- Function to Create Player Entry (with Display Names)
local function createPlayerEntry(player)
    local entry = Instance.new("Frame")
    entry.Name = player.Name
    entry.Size = UDim2.new(1, 0, 0, 70)
    entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    entry.BackgroundTransparency = 0.3
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entry

    -- Entry hover effect
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
    teleportButton.Size = UDim2.new(0, 80, 0, 25)
    teleportButton.BackgroundColor3 = ACCENT_COLOR
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Text = "Teleport"
    teleportButton.TextSize = 12
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.AutoButtonColor = false
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 5)
    teleportCorner.Parent = teleportButton
    
    -- Spectate Button
    local spectateButton = Instance.new("TextButton")
    spectateButton.Name = "SpectateButton"
    spectateButton.Size = UDim2.new(0, 80, 0, 25)
    spectateButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    spectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spectateButton.Text = "Spectate"
    spectateButton.TextSize = 12
    spectateButton.Font = Enum.Font.GothamBold
    spectateButton.AutoButtonColor = false
    
    local spectateCorner = Instance.new("UICorner")
    spectateCorner.CornerRadius = UDim.new(0, 5)
    spectateCorner.Parent = spectateButton
    
    -- Button Hover Effects
    local function setupButtonHover(button, normalColor, hoverColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = hoverColor,
                Size = UDim2.new(0, 82, 0, 27)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = normalColor,
                Size = UDim2.new(0, 80, 0, 25)
            }):Play()
        end)
    end
    
    setupButtonHover(teleportButton, ACCENT_COLOR, Color3.fromRGB(160, 70, 220))
    setupButtonHover(spectateButton, Color3.fromRGB(80, 80, 100), Color3.fromRGB(100, 100, 120))
    
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
                -- Stop spectating
                workspace.CurrentCamera.CameraSubject = originalCameraSubject
                spectateButton.Text = "Spectate"
                spectateButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                currentlySpectating = nil
            else
                -- Stop any current spectating first
                if currentlySpectating then
                    for _, btn in ipairs(scrollFrame:GetDescendants()) do
                        if btn.Name == "SpectateButton" and btn.Text == "Stop Spectate" then
                            btn.Text = "Spectate"
                            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                        end
                    end
                end
                
                -- Start spectating new player
                workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                spectateButton.Text = "Stop Spectate"
                spectateButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                currentlySpectating = player
            end
        end
    end)
    
    -- Add elements to entry
    avatar.Parent = entry
    displayNameLabel.Parent = entry
    usernameLabel.Parent = entry
    teleportButton.Parent = buttonContainer
    spectateButton.Parent = buttonContainer
    buttonContainer.Parent = entry
    
    return entry
end

-- Function to Update Player List (with Search)
local function updatePlayerList(searchTerm)
    searchTerm = searchTerm and string.lower(searchTerm) or ""
    
    -- Clear current list
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add filtered players
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

-- Draggable Menu with Animation
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
