--==================================================
-- HITBOX VIEWER | FULL UI
-- For your own Roblox Studio experience
-- Place in StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- SETTINGS
local hitboxSize = Vector3.new(4, 5, 2)
local hitboxColor = Color3.fromRGB(0, 255, 120)
local transparency = 0.35
local hitboxEnabled = true
local toggleKey = Enum.KeyCode.RightControl

local hitboxes = {}
local connections = {}
local waitingForKey = false

-- CLEANUP
local function removeHitbox(character)
    local box = hitboxes[character]
    if box then
        box:Destroy()
        hitboxes[character] = nil
    end
end

local function clearHitboxes()
    for character, box in pairs(hitboxes) do
        if box then
            box:Destroy()
        end
        hitboxes[character] = nil
    end
end

-- HITBOX
local function addHitbox(player, character)
    removeHitbox(character)

    if player == LocalPlayer or not hitboxEnabled then
        return
    end

    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root or not root.Parent then
        return
    end

    if player == LocalPlayer or not hitboxEnabled then
        return
    end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "OtherPlayerHitbox"
    box.Adornee = root
    box.Size = hitboxSize
    box.Color3 = hitboxColor
    box.Transparency = transparency
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Parent = root

    hitboxes[character] = box
end

local function updateHitboxes()
    for character, box in pairs(hitboxes) do
        if box and box.Parent and character.Parent then
            box.Size = hitboxSize
            box.Color3 = hitboxColor
            box.Transparency = transparency
        else
            hitboxes[character] = nil
        end
    end
end

local function setupPlayer(player)
    if player == LocalPlayer then
        return
    end

    if connections[player] then
        for _, connection in ipairs(connections[player]) do
            connection:Disconnect()
        end
    end

    connections[player] = {
        player.CharacterAdded:Connect(function(character)
            task.spawn(addHitbox, player, character)
        end),

        player.CharacterRemoving:Connect(function(character)
            removeHitbox(character)
        end)
    }

    if player.Character then
        task.spawn(addHitbox, player, player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeHitbox(player.Character)
    end

    if connections[player] then
        for _, connection in ipairs(connections[player]) do
            connection:Disconnect()
        end
        connections[player] = nil
    end
end)

--==================================================
-- UI
--==================================================

local oldGui = PlayerGui:FindFirstChild("HitboxControlUI")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "HitboxControlUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(300, 465)
main.Position = UDim2.new(0, 25, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 23, 31)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(65, 80, 100)
mainStroke.Thickness = 1
mainStroke.Parent = main

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 62)
header.BackgroundColor3 = Color3.fromRGB(29, 35, 47)
header.BorderSizePixel = 0
header.Active = true
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 28)
title.Position = UDim2.fromOffset(14, 6)
title.BackgroundTransparency = 1
title.Text = "HITBOX VIEWER"
title.TextColor3 = Color3.fromRGB(0, 255, 160)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 18)
subtitle.Position = UDim2.fromOffset(14, 33)
subtitle.BackgroundTransparency = 1
subtitle.Text = "OTHER PLAYERS ONLY"
subtitle.TextColor3 = Color3.fromRGB(155, 170, 190)
subtitle.TextSize = 10
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- BUTTON HELPER
local function makeButton(parent, text, position, size, callback, bg, textColor)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = bg or Color3.fromRGB(43, 51, 67)
    button.TextColor3 = textColor or Color3.fromRGB(245, 247, 255)
    button.Text = text
    button.TextSize = 12
    button.Font = Enum.Font.GothamMedium
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    button.Activated:Connect(callback)
    return button
end

local function makeLabel(text, y, color3)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -28, 0, 22)
    label.Position = UDim2.fromOffset(14, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color3 or Color3.fromRGB(225, 232, 245)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = main
    return label
end

-- OPEN / CLOSE UI
local openButton

local closeButton = makeButton(
    header, "X", UDim2.new(1, -43, 0, 12),
    UDim2.fromOffset(30, 30), function()
        main.Visible = false
        openButton.Visible = true
    end, Color3.fromRGB(190, 55, 70)
)

openButton = makeButton(
    gui, "☰  HITBOX", UDim2.new(0, 20, 0.5, 0),
    UDim2.fromOffset(115, 40), function()
        main.Visible = true
        openButton.Visible = false
    end, Color3.fromRGB(0, 145, 100)
)
openButton.Visible = false

local function toggleUI()
    main.Visible = not main.Visible
    openButton.Visible = not main.Visible
end

-- DRAG UI WITH MOUSE OR TOUCH
local dragging = false
local dragStart
local startPosition
local dragInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input == dragInput
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- HITBOX ON / OFF
local toggleButton

toggleButton = makeButton(
    main, "HITBOX : ON", UDim2.fromOffset(14, 72),
    UDim2.new(1, -28, 0, 32), function()
        hitboxEnabled = not hitboxEnabled

        if hitboxEnabled then
            toggleButton.Text = "HITBOX : ON"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 135, 90)

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    task.spawn(addHitbox, player, player.Character)
                end
            end
        else
            toggleButton.Text = "HITBOX : OFF"
            toggleButton.BackgroundColor3 = Color3.fromRGB(110, 48, 58)
            clearHitboxes()
        end
    end, Color3.fromRGB(0, 135, 90)
)

-- SIZE
makeLabel("HITBOX SIZE / STUDS", 112)
local sizeLabel = makeLabel("", 136, Color3.fromRGB(0, 255, 160))

local function refreshSize()
    sizeLabel.Text = string.format(
        "X: %.0f    Y: %.0f    Z: %.0f",
        hitboxSize.X, hitboxSize.Y, hitboxSize.Z
    )
    updateHitboxes()
end

local function changeSize(axis, amount)
    local x, y, z = hitboxSize.X, hitboxSize.Y, hitboxSize.Z

    if axis == "X" then x = math.clamp(x + amount, 1, 20) end
    if axis == "Y" then y = math.clamp(y + amount, 1, 20) end
    if axis == "Z" then z = math.clamp(z + amount, 1, 20) end

    hitboxSize = Vector3.new(x, y, z)
    refreshSize()
end

for index, axis in ipairs({"X", "Y", "Z"}) do
    local x = 14 + (index - 1) * 90

    makeButton(main, axis .. " -", UDim2.fromOffset(x, 160),
        UDim2.fromOffset(80, 28), function()
            changeSize(axis, -1)
        end)

    makeButton(main, axis .. " +", UDim2.fromOffset(x, 192),
        UDim2.fromOffset(80, 28), function()
            changeSize(axis, 1)
        end)
end

-- COLORS
makeLabel("BOX COLOR", 229)

local palette = {
    {"GREEN", Color3.fromRGB(0, 255, 120)},
    {"RED", Color3.fromRGB(255, 65, 80)},
    {"BLUE", Color3.fromRGB(40, 170, 255)},
    {"PURPLE", Color3.fromRGB(180, 90, 255)},
    {"YELLOW", Color3.fromRGB(255, 220, 50)},
    {"WHITE", Color3.fromRGB(255, 255, 255)}
}

for index, item in ipairs(palette) do
    local column = (index - 1) % 3
    local row = math.floor((index - 1) / 3)

    makeButton(
        main, item[1],
        UDim2.fromOffset(14 + column * 90, 253 + row * 32),
        UDim2.fromOffset(80, 27),
        function()
            hitboxColor = item[2]
            updateHitboxes()
        end,
        item[2],
        (index == 5 or index == 6)
            and Color3.fromRGB(25, 25, 30)
            or Color3.fromRGB(255, 255, 255)
    )
end

-- TRANSPARENCY
local alphaLabel = makeLabel("", 321)

local function refreshTransparency()
    alphaLabel.Text = string.format(
        "TRANSPARENCY: %d%%",
        math.floor(transparency * 100 + 0.5)
    )
end

makeButton(main, "-", UDim2.fromOffset(175, 318),
    UDim2.fromOffset(40, 28), function()
        transparency = math.clamp(transparency - 0.1, 0, 1)
        refreshTransparency()
        updateHitboxes()
    end)

makeButton(main, "+", UDim2.fromOffset(222, 318),
    UDim2.fromOffset(40, 28), function()
        transparency = math.clamp(transparency + 0.1, 0, 1)
        refreshTransparency()
        updateHitboxes()
    end)

-- RESET
makeButton(main, "RESET SIZE", UDim2.fromOffset(14, 363),
    UDim2.fromOffset(126, 30), function()
        hitboxSize = Vector3.new(4, 5, 2)
        refreshSize()
    end, Color3.fromRGB(43, 65, 80))

makeButton(main, "RESET COLOR", UDim2.fromOffset(150, 363),
    UDim2.fromOffset(126, 30), function()
        hitboxColor = Color3.fromRGB(0, 255, 120)
        updateHitboxes()
    end, Color3.fromRGB(43, 65, 80))

-- CUSTOM TOGGLE KEY
makeLabel("UI TOGGLE KEY", 402)

local keyButton
keyButton = makeButton(
    main, "SET KEY: " .. toggleKey.Name,
    UDim2.fromOffset(14, 427),
    UDim2.new(1, -28, 0, 28), function()
        waitingForKey = true
        keyButton.Text = "PRESS A KEY..."
    end, Color3.fromRGB(65, 75, 100)
)

UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if waitingForKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            toggleKey = input.KeyCode
            keyButton.Text = "SET KEY: " .. toggleKey.Name
            waitingForKey = false
        end
        return
    end

    if input.KeyCode == toggleKey then
        toggleUI()
    end
end)

refreshSize()
refreshTransparency()
