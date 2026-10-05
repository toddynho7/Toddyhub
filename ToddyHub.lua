--[[ ToddynHub - Loader Final ]]

_G.ToddynHubLoaded = nil
_G.ToddynHubToggleSet = nil

local function limpar()
    local locais = { game:GetService("CoreGui") }
    if gethui then table.insert(locais, gethui()) end
    if game.Players.LocalPlayer then
        local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then table.insert(locais, pg) end
    end
    for _, gui in ipairs(locais) do
        pcall(function()
            for _, obj in ipairs(gui:GetChildren()) do
                if obj.Name == "ToddynHub" or obj.Name == "ESP_Drawings" then
                    obj:Destroy()
                end
            end
        end)
    end
end

limpar()
task.wait(0.3)

local links = {
    'https://gist.githubusercontent.com/toddynho7/8c2524dfbd6d3f62098462a1c968e136/raw/fc127952ebff1ab28584cb3e99e3328c0fa81fc7/t1.lua',
    'https://gist.githubusercontent.com/toddynho7/f4c46e4bdbfefd438e7b2105571b618b/raw/d7146f83cf5a3b4feb726075ae8875ba2e340e5a/t1b.lua',
    'https://gist.githubusercontent.com/toddynho7/3d05260726dba317b04789a9bdabab20/raw/355aebd4183d0ce4608da62fbe1cda72728a1f28/t2a.lua',
    'https://gist.githubusercontent.com/toddynho7/1285658cf5ee018f55e8b8021d542025/raw/0e337fc25208d84a861ee5073723c1dbba30836a/t2b.lua',
    'https://gist.githubusercontent.com/toddynho7/55218d591ddd12e1f721ab37008c87c4/raw/f8a0e4632863281575297bdd02c6565a4af24f78/t3.lua',
    'https://gist.githubusercontent.com/toddynho7/740c7a1c662049cbd6076fb68bb41d20/raw/3fc3e1a0579dda4a6657ef3accb7c57e8edddc0a/t4a.lua',
    'https://gist.githubusercontent.com/toddynho7/5fde5f48fbd6a860bf3bf570ab64223e/raw/3844d6444b5934c4036ce11f112115bb7aa3423a/t4b.lua',
}

for i, url in ipairs(links) do
    local ok, c = pcall(function() return game:HttpGet(url) end)
    if ok and c then
        local f, err = loadstring(c)
        if f then
            local ok2, err2 = pcall(f)
            if not ok2 then
                print("Erro paste " .. i .. ": " .. tostring(err2))
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Erro " .. i,
                    Text = tostring(err2):sub(1, 130),
                    Duration = 15,
                })
            end
        else
            print("Compile erro " .. i .. ": " .. tostring(err))
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Compile " .. i,
                Text = tostring(err):sub(1, 130),
                Duration = 15,
            })
        end
    end
    task.wait(0.1)
end

task.wait(1)

local function acharHubGui()
    local locais = { game:GetService("CoreGui") }
    if gethui then table.insert(locais, gethui()) end
    if game.Players.LocalPlayer then
        local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then table.insert(locais, pg) end
    end
    for _, gui in ipairs(locais) do
        if gui then
            local hub = gui:FindFirstChild("ToddynHub")
            if hub then return hub end
        end
    end
    return nil
end

local hubGui = acharHubGui()
if not hubGui then return end

local mainFrame = hubGui:FindFirstChild("MainFrame")
if not mainFrame then return end

local UIS = game:GetService("UserInputService")

local vp = workspace.CurrentCamera.ViewportSize
local w = math.min(vp.X - 20, 460)
local h = math.min(vp.Y - 100, 360)

mainFrame.Size = UDim2.fromOffset(w, h)
mainFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)

local tabBar = mainFrame:FindFirstChild("TabBar")
local content = mainFrame:FindFirstChild("Content")

if tabBar and content then
    local tabW = 90
    tabBar.Size = UDim2.new(0, tabW, 1, -50)
    tabBar.Position = UDim2.fromOffset(6, 44)
    content.Size = UDim2.new(1, -(tabW + 20), 1, -56)
    content.Position = UDim2.fromOffset(tabW + 12, 50)
end

for _, obj in ipairs(hubGui:GetDescendants()) do
    if obj:IsA("ScrollingFrame") then
        obj.CanvasSize = UDim2.new(0, 0, 0, 0)
        obj.AutomaticCanvasSize = Enum.AutomaticSize.Y
        obj.ScrollingEnabled = true
        obj.ScrollBarThickness = 8
        obj.ScrollBarImageColor3 = Color3.fromRGB(200, 140, 255)
        obj.ScrollBarImageTransparency = 0
        obj.ElasticBehavior = Enum.ElasticBehavior.Never
        obj.Active = true
        obj.ClipsDescendants = true
    end
end

local titleBar = mainFrame:FindFirstChild("TitleBar")
if titleBar then
    titleBar.Active = true
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local toggleBtn = hubGui:FindFirstChild("MenuToggle")
if toggleBtn and not _G.ToddynHubToggleSet then
    _G.ToddynHubToggleSet = true
    local menuOpen = true
    local dragToggle = false
    local dragToggleStart, dragTogglePos

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragToggleStart = input.Position
            dragTogglePos = toggleBtn.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragToggleStart
            if delta.Magnitude > 5 then
                toggleBtn.Position = UDim2.new(
                    dragTogglePos.X.Scale, dragTogglePos.X.Offset + delta.X,
                    dragTogglePos.Y.Scale, dragTogglePos.Y.Offset + delta.Y
                )
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                local delta = input.Position - dragToggleStart
                if delta.Magnitude < 5 then
                    menuOpen = not menuOpen
                    mainFrame.Visible = menuOpen
                end
                dragToggle = false
            end
        end
    end)
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "ToddynHub",
    Text = "Carregado!",
    Duration = 6,
})
