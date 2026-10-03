--[[ ToddynHub - Loader Final ]]

_G.ToddynHubLoaded = nil

-- Limpa instâncias antigas
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
    'https://gist.githubusercontent.com/wandinhozin-ship-it/e97b35e08485575e31a5b4e7d10b79a3/raw/0f4314a4698aa07eb6cb19faed5b9a115e3ac842/t1.lua', -- Parte 1: Base + UI
    'https://gist.githubusercontent.com/wandinhozin-ship-it/c070c993fe57b15311404ab4320de653/raw/274f573a06e40426fe2af64cb50ba8ef9c4bb134/t1.lua', -- Parte 2: Murder/Sheriff/Innocent
    'https://gist.githubusercontent.com/wandinhozin-ship-it/55218d591ddd12e1f721ab37008c87c4/raw/f8a0e4632863281575297bdd02c6565a4af24f78/t3.lua', -- Parte 3: Utility/Local/Farm
    'https://gist.githubusercontent.com/wandinhozin-ship-it/58becd71fbfa8432429242baeaf05f05/raw/eee69f7e569f5b8b7ef74533090602f0c6b536ed/t4.lua', -- Parte 4: ESP/Visuals/Settings/Final
}

for i, url in ipairs(links) do
    local ok, c = pcall(function() return game:HttpGet(url) end)
    if ok and c then
        local f, err = loadstring(c)
        if f then
            local ok2, err2 = pcall(f)
            if not ok2 then
                print("Erro paste " .. i .. ": " .. tostring(err2))
            end
        else
            print("Compile erro " .. i .. ": " .. tostring(err))
        end
    else
        print("Download falhou: " .. i)
    end
    task.wait(0.1)
end

task.wait(1)

-- ═══════════════════════════════
-- PATCH: Procura o ScreenGui em qualquer lugar
-- ═══════════════════════════════
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
if not hubGui then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ToddynHub", Text = "Erro: janela nao criada", Duration = 10,
    })
    return
end

local mainFrame = hubGui:FindFirstChild("MainFrame")
if not mainFrame then return end

local UIS = game:GetService("UserInputService")

-- ═══════════════════════════════
-- PATCH 1: Redimensionar + ajustar TabBar
-- ═══════════════════════════════
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

-- ═══════════════════════════════
-- PATCH 2: Scroll em todas as abas
-- ═══════════════════════════════
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

-- ═══════════════════════════════
-- PATCH 3: Drag na janela
-- ═══════════════════════════════
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

-- ═══════════════════════════════
-- PATCH 4: Botão anime (drag + abrir/fechar)
-- ═══════════════════════════════
local toggleBtn = hubGui:FindFirstChild("MenuToggle")
if toggleBtn then
    local menuOpen = true
    local dragToggle = false
    local dragToggleStart, dragTogglePos

    -- Remove conexões antigas de clique
    for _, conn in ipairs(getconnections(toggleBtn.MouseButton1Click)) do
        pcall(function() conn:Disconnect() end)
    end

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
    Text = "Carregado! Panic: END",
    Duration = 6,
})
