--[[
    Toddyhub - Vulnerability Test Suite
    Uso: SOMENTE no seu próprio jogo (Studio / lugar privado)
    Objetivo: auditar o que um exploit client-side consegue fazer,
              para depois corrigir no servidor.
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local StarterGui        = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

--=====================================================================
-- CONFIGURAÇÃO
--=====================================================================
local CONFIG = {
    Visual          = false,
    Aimbot          = false,
    AutoAttack      = false,
    SpeedHack       = false,
    SpeedValue      = 60,
    Noclip          = false,
    AttackRange     = 10,
    AimbotFOV       = 300,
    UpdateRate      = 0.1,
}

--=====================================================================
-- ESTADO
--=====================================================================
local State = {
    ESPObjects      = {},
    OriginalSpeed   = 16,
    NoclipConns     = {},
    LastAttack      = 0,
    AttackCooldown  = 0.6,
    LockedTarget    = nil,
    LockedWasMurder = false,
    Heroes          = {},   -- [Player] = true
}

--=====================================================================
-- HELPERS
--=====================================================================
local function getCharacter(player)
    return player.Character
end

local function getRoot(player)
    local char = getCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(player)
    local char = getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isSheriffGun(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n = tool.Name:lower()
    return (n:find("gun") ~= nil) or (n:find("sheriff") ~= nil)
end

local function isHoldingSheriffGun(player)
    local char = player.Character
    if not char then return false end
    return isSheriffGun(char:FindFirstChildOfClass("Tool"))
end

local function isTargetValid(player)
    if not player then return false end
    if player == LocalPlayer then return false end
    if not player.Parent then return false end
    if not Players:FindFirstChild(player.Name) then return false end
    local hum = getHumanoid(player)
    if not hum or hum.Health <= 0 then return false end
    local root = getRoot(player)
    if not root then return false end
    return true
end

local function getRole(player)
    local char = player.Character
    if not char then return nil end

    if State.Heroes[player] then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or not isHoldingSheriffGun(player) then
            State.Heroes[player] = nil
        else
            return "Hero"
        end
    end

    local attr = char:GetAttribute("Role")
    if attr then return attr end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") or n:find("murder") then return "Murder" end
                if n:find("gun")   or n:find("sheriff") then return "Sheriff" end
            end
        end
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local n = tool.Name:lower()
        if n:find("knife") or n:find("murder") then return "Murder" end
        if n:find("gun")   or n:find("sheriff") then return "Sheriff" end
    end

    return "Innocent"
end

local function isHoldingWeapon(player)
    local char = player.Character
    if not char then return false end
    return char:FindFirstChildOfClass("Tool") ~= nil
end

local function getMyRole()
    return getRole(LocalPlayer)
end

--=====================================================================
-- SCAN DE HERÓIS
--=====================================================================
local function scanHeroes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end

        if not State.Heroes[p] then
            local baseRole = char:GetAttribute("Role")
            if (baseRole == nil or baseRole == "Innocent") and isHoldingSheriffGun(p) then
                State.Heroes[p] = true
            end
        end
    end
end

--=====================================================================
-- MÓDULO: VISUAL
--=====================================================================
local Visual = {}
Visual.objects = {}

function Visual:create(player)
    if self.objects[player] then return end
    local char = player.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "Toddyhub_ESP"
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Toddyhub_Name"
    billboard.Size = UDim2.new(0, 150, 0, 40)              -- menor
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)         -- mais perto
    billboard.AlwaysOnTop = true
    billboard.Adornee = char

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.3                     -- sombra leve
    label.Font = Enum.Font.GothamBold
    label.TextScaled = false                               -- sem escala automática
    label.TextSize = 14                                    -- tamanho fixo menor
    label.Text = player.Name
    label.Parent = billboard

    billboard.Parent = char

    local conn = player.CharacterAdded:Connect(function(newChar)
        if self.objects[player] then
            self.objects[player].highlight.Adornee = newChar
            self.objects[player].billboard.Adornee = newChar
            self.objects[player].highlight.Parent = newChar
            self.objects[player].billboard.Parent = newChar
        end
    end)

    self.objects[player] = {
        highlight = highlight,
        billboard = billboard,
        label = label,
        conn = conn,
    }
end

function Visual:remove(player)
    if not self.objects[player] then return end
    local o = self.objects[player]
    if o.highlight then o.highlight:Destroy() end
    if o.billboard then o.billboard:Destroy() end
    if o.conn then o.conn:Disconnect() end
    self.objects[player] = nil
end

function Visual:setEnabled(enabled)
    self.enabled = enabled
    if enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then self:create(p) end
        end
    else
        for p, _ in pairs(self.objects) do self:remove(p) end
    end
end

function Visual:refresh()
    for player, o in pairs(self.objects) do
        if not o.highlight or not o.label then continue end

        local role = getRole(player) or "?"
        local color = Color3.fromRGB(200, 200, 200)
        if role == "Murder" then color = Color3.fromRGB(255, 60, 60)
        elseif role == "Sheriff" then color = Color3.fromRGB(80, 160, 255)
        elseif role == "Hero" then color = Color3.fromRGB(180, 100, 255)
        elseif role == "Innocent" then color = Color3.fromRGB(80, 255, 80) end

        o.label.Text = string.format("%s\n[%s]", player.Name, role)
        o.label.TextColor3 = color

        if isHoldingWeapon(player) then
            o.highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
            o.highlight.FillColor = Color3.fromRGB(255, 100, 0)
        else
            o.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            o.highlight.FillColor = color
        end
    end
end

--=====================================================================
-- MÓDULO: AIMBOT
--=====================================================================
local Aimbot = {}

function Aimbot:findMurderTarget()
    local myRoot = getRoot(LocalPlayer)
    if not myRoot then return nil end

    local closest, closestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if isTargetValid(p) and getRole(p) == "Murder" then
            local root = getRoot(p)
            local dist = (root.Position - myRoot.Position).Magnitude
            if dist < closestDist and dist <= CONFIG.AimbotFOV then
                closest, closestDist = p, dist
            end
        end
    end
    return closest
end

function Aimbot:ensureTarget()
    local t = State.LockedTarget
    if t and isTargetValid(t) and getRole(t) == "Murder" then
        return t
    end
    State.LockedTarget = self:findMurderTarget()
    return State.LockedTarget
end

function Aimbot:update()
    if getMyRole() ~= "Murder" then
        State.LockedTarget = nil
        return
    end

    local myHum = getHumanoid(LocalPlayer)
    if not myHum or myHum.Health <= 0 then
        State.LockedTarget = nil
        return
    end

    local target = self:ensureTarget()
    if not target then return end

    local root = getRoot(target)
    if not root then return end

    Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position)
end

--=====================================================================
-- MÓDULO: AUTO ATTACK
--=====================================================================
local AutoAttack = {}

function AutoAttack:fire(target)
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

function AutoAttack:update()
    if getMyRole() ~= "Murder" then return end
    local myRoot = getRoot(LocalPlayer)
    if not myRoot then return end

    local now = tick()
    if now - State.LastAttack < State.AttackCooldown then return end

    local target = State.LockedTarget
    if target and isTargetValid(target) then
        local root = getRoot(target)
        if root then
            local dist = (root.Position - myRoot.Position).Magnitude
            if dist <= CONFIG.AttackRange then
                State.LastAttack = now
                self:fire(target)
                return
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local root = getRoot(p)
        local hum  = getHumanoid(p)
        if root and hum and hum.Health > 0 then
            local dist = (root.Position - myRoot.Position).Magnitude
            if dist <= CONFIG.AttackRange then
                State.LastAttack = now
                self:fire(p)
                break
            end
        end
    end
end

--=====================================================================
-- MÓDULO: SPEED HACK
--=====================================================================
local SpeedHack = {}

function SpeedHack:apply()
    local hum = getHumanoid(LocalPlayer)
    if not hum then return end
    if not self._original then self._original = hum.WalkSpeed end
    hum.WalkSpeed = CONFIG.SpeedValue
end

function SpeedHack:restore()
    local hum = getHumanoid(LocalPlayer)
    if hum and self._original then
        hum.WalkSpeed = self._original
        self._original = nil
    end
end

--=====================================================================
-- MÓDULO: NOCLIP
--=====================================================================
local Noclip = {}

function Noclip:enable()
    if self._conn then return end
    self._conn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

function Noclip:disable()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
end

--=====================================================================
-- LOOP PRINCIPAL
--=====================================================================
Players.PlayerAdded:Connect(function(p)
    if Visual.enabled and p ~= LocalPlayer then
        p.CharacterAdded:Wait()
        task.wait(0.2)
        Visual:create(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    Visual:remove(p)
    State.Heroes[p] = nil
    if State.LockedTarget == p then
        State.LockedTarget = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if CONFIG.SpeedHack then SpeedHack:apply() end
    if CONFIG.Noclip then Noclip:enable() end
    State.LockedTarget = nil
end)

task.spawn(function()
    while true do
        task.wait(CONFIG.UpdateRate)

        scanHeroes()

        if CONFIG.Visual then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not Visual.objects[p] then
                    Visual:create(p)
                end
            end
            Visual:refresh()
        end

        if CONFIG.Aimbot     then Aimbot:update() end
        if CONFIG.AutoAttack then AutoAttack:update() end
        if CONFIG.SpeedHack  then SpeedHack:apply() end
    end
end)

--=====================================================================
-- UI (Toddyhub)
--=====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToddyhubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ---------- Botão flutuante "+" (ROXO VIVO) ----------
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 20, 0, 100)
OpenButton.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "+"
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 30
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui

local cornerOpen = Instance.new("UICorner")
cornerOpen.CornerRadius = UDim.new(1, 0)
cornerOpen.Parent = OpenButton

-- ---------- Frame principal (PRETO) ----------
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 260, 0, 300)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = Frame

-- ---------- Título (VERMELHO) ----------
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
Title.BorderSizePixel = 0
Title.Text = "Toddyhub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = Title

-- ---------- Botão de minimizar (PRETO ABSOLUTO) ----------
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 28, 0, 22)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 4)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Text = "_"
MinimizeBtn.ZIndex = 5
MinimizeBtn.Parent = Title

MinimizeBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    OpenButton.Position = Frame.Position
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Frame.Position = OpenButton.Position
    OpenButton.Visible = false
    Frame.Visible = true
end)

-- ---------- Toggles ----------
local function makeToggle(y, text, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. text
    btn.Parent = Frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local function refresh()
        if getter() then
            btn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
            btn.Text = "  [ON]  " .. text
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.Text = "  [OFF] " .. text
        end
    end

    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        refresh()
    end)

    refresh()
    return btn
end

local y = 40
makeToggle(y, "Visual (ESP + Tag + Arma)", function() return CONFIG.Visual end,     function(v) CONFIG.Visual = v; Visual:setEnabled(v) end); y = y + 36
makeToggle(y, "Aimbot (só Murder)",        function() return CONFIG.Aimbot end,     function(v) CONFIG.Aimbot = v; if not v then State.LockedTarget = nil end end); y = y + 36
makeToggle(y, "Ataque Auto (Murder)",      function() return CONFIG.AutoAttack end, function(v) CONFIG.AutoAttack = v end); y = y + 36
makeToggle(y, "Speed Hack",                function() return CONFIG.SpeedHack end,  function(v) CONFIG.SpeedHack = v; if v then SpeedHack:apply() else SpeedHack:restore() end end); y = y + 36
makeToggle(y, "Noclip",                    function() return CONFIG.Noclip end,     function(v) CONFIG.Noclip = v; if v then Noclip:enable() else Noclip:disable() end end); y = y + 36

Frame.Size = UDim2.new(0, 260, 0, y + 50)

-- ---------- Botão de pânico (ROXO VIVO) ----------
local panic = Instance.new("TextButton")
panic.Size = UDim2.new(1, -20, 0, 28)
panic.Position = UDim2.new(0, 10, 0, y + 6)
panic.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
panic.BorderSizePixel = 0
panic.TextColor3 = Color3.new(1, 1, 1)
panic.Font = Enum.Font.GothamBold
panic.Text = "DESLIGAR TUDO"
panic.Parent = Frame

local panicCorner = Instance.new("UICorner")
panicCorner.CornerRadius = UDim.new(0, 6)
panicCorner.Parent = panic

panic.MouseButton1Click:Connect(function()
    for k in pairs(CONFIG) do
        if type(CONFIG[k]) == "boolean" then CONFIG[k] = false end
    end
    Visual:setEnabled(false)
    SpeedHack:restore()
    Noclip:disable()
    State.LockedTarget = nil
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Toddyhub", Text = "Todas as funções desligadas.", Duration = 2
        })
    end)
end)

print("[Toddyhub] Carregado. Use apenas no seu próprio jogo.")
