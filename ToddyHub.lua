--[[ ToddynHub Loader v7 + Patch ]]

_G.ToddynHubLoaded = nil
_G.Toddynho201Loaded = nil

for _, obj in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if obj.Name == "ToddynHub" or obj.Name == "ToddynhoHub201" then
        obj:Destroy()
    end
end

task.wait(0.3)

local links = {
    'https://gist.githubusercontent.com/wandinhozin-ship-it/75720b82be70cc7c55ea057ce58371db/raw/59f41c8001afd3140a28d146d4b129b7aa96b1ea/paste1a1fix.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/447859b8f71e93d939903c4a2da7dc9d/raw/1a0415925b51dae23ec0e62ff83af5ad24bd685b/Paste1a2.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/b20f0056b1da0569ddb578ca7c3dc970/raw/5f38bed9776039b04326fac74b9c82ae4cc08b5f/paste1b.lua',
    'https://pastebin.com/raw/V1PzyDQb',
    'https://pastebin.com/raw/usaNx6CJ',
    'https://pastebin.com/raw/YKZqpVpC',
    'https://pastebin.com/raw/jdGZNNfV',
    'https://pastebin.com/raw/UTcmBeZm',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/b9c29b311c02b2ae44c15742f76ac950/raw/c1173148fbbf0a88ad8ef6ac8a9287c38cb3640b/paste7.lua',
    'https://pastebin.com/raw/CkFKBhmS',
    'https://pastebin.com/raw/jrbpiJhs',
    'https://pastebin.com/raw/CEgNcQhx',
    'https://pastebin.com/raw/HAPUdLQF',
    'https://pastebin.com/raw/cwaPzq3F',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/172a788aa667c0d105f73f2fcc19257f/raw/922359ce57dd24387641a1561d11c4a923e6aca1/12a1.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/d1949357d78a0d6fb6d18c2f298a81c5/raw/ac3a4a3ed04b3a05ca2edee537230b71f4127d0f/12a2.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/172286377b9ba2bc402f20a14aea8965/raw/70914f055ce9eaacd087d606037411759952c5a3/12a3.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/31135c9ae2b8228a455e1650e7ea4b0f/raw/ea7af368e557579fa2587414394fc3875ba95d9e/12a4.lua',
}

local total = ''
for i, url in ipairs(links) do
    local ok, c = pcall(function() return game:HttpGet(url) end)
    if ok and c then total = total .. c .. '\n' end
    task.wait(0.1)
end

-- Converte "local function" top-level em global (libera registradores)
local resultado = {}
for linha in total:gmatch("([^\n]*)") do
    if linha:match("^local%s+function%s+") then
        linha = linha:gsub("^local%s+function%s+", "function ")
    end
    table.insert(resultado, linha)
end
total = table.concat(resultado, "\n")

local f, err = loadstring(total)
if not f then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Compile error", Text = tostring(err):sub(1, 140), Duration = 20,
    })
    return
end

local ok, err2 = pcall(f)
if not ok then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Runtime error", Text = tostring(err2):sub(1, 140), Duration = 20,
    })
    return
end

-- ⚡ PATCH: Redimensiona + ativa scroll + compacta componentes
task.wait(1)

local hubGui
for _, obj in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if obj.Name == "ToddynHub" then hubGui = obj break end
end

if hubGui then
    local mainFrame = hubGui:FindFirstChild("MainFrame")
    if mainFrame then
        local vp = workspace.CurrentCamera.ViewportSize
        local w = math.min(vp.X - 15, 480)
        local h = math.min(vp.Y - 80, 400)
        mainFrame.Size = UDim2.fromOffset(w, h)
        mainFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
        
        local tabBar = mainFrame:FindFirstChild("TabBar")
        local content = mainFrame:FindFirstChild("Content")
        if tabBar and content then
            local tabW = math.min(90, w * 0.20)
            tabBar.Size = UDim2.new(0, tabW, 1, -58)
            tabBar.Position = UDim2.fromOffset(6, 50)
            content.Size = UDim2.new(1, -(tabW + 16), 1, -62)
            content.Position = UDim2.fromOffset(tabW + 10, 54)
        end
    end

    for _, obj in ipairs(hubGui:GetDescendants()) do
        if obj:IsA("ScrollingFrame") then
            obj.ScrollBarThickness = 6
            obj.ScrollBarImageColor3 = Color3.fromRGB(200, 140, 255)
            obj.ScrollingEnabled = true
            obj.AutomaticCanvasSize = Enum.AutomaticSize.Y
            obj.CanvasSize = UDim2.new(0, 0, 0, 0)
            obj.ElasticBehavior = Enum.ElasticBehavior.Never
        end
        if obj:IsA("Frame") and obj.Parent and obj.Parent:IsA("ScrollingFrame") then
            local y = obj.Size.Y.Offset
            if y == 50 then obj.Size = UDim2.new(1, 0, 0, 40)
            elseif y == 60 then obj.Size = UDim2.new(1, 0, 0, 48)
            elseif y == 44 then obj.Size = UDim2.new(1, 0, 0, 38)
            elseif y == 26 then obj.Size = UDim2.new(1, 0, 0, 22)
            end
        end
    end
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ ToddynHub carregado",
    Text = "UI ajustada + scroll ativo",
    Duration = 8,
})
