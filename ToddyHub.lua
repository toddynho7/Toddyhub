--[[ ToddynHub Loader FINAL ]]

_G.ToddynHubLoaded = nil

for _, obj in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if obj.Name == "ToddynHub" then obj:Destroy() end
end

task.wait(0.3)

local links = {
    'https://gist.githubusercontent.com/wandinhozin-ship-it/605a460ba68b3a1b3eb1c25fb9eb006f/raw/78c4a68489421f8fff69066a3f0744501545e747/p1.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/af8a8c5f3cfc5668db60a73e99a0768f/raw/436054e93c7a35419cc8f41bd7e7081028122ef9/P2.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/1eab38c548a580b808399a15f8eb4661/raw/6c3507f3f7e0801d7281bbd539ae91f753ba1598/p3.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/9a3844fe5f30fc900ce8548bec092159/raw/7b68de361cc02c7975dfbd1a5b0704667069ab59/p4.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/de9c00b631c74aedaa41f6c7a017b87b/raw/3576e281d5935733bff6245900471f0ad395b5c1/p5.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/6438c001232bb3ef2489a221225c9b04/raw/1303ea3294fe88e2e99c736296334bbdbf4ce008/p6.lua',
    'https://gist.githubusercontent.com/wandinhozin-ship-it/8a37abde0d4828199b0abc6a8f84afee/raw/b1705265b4ccb41237cbc368346c3186ecb51cf7/p7.lua',
}

-- Ambiente compartilhado entre todos os pastes
local env = setmetatable({}, { __index = _G })

for i, url in ipairs(links) do
    local ok, c = pcall(function() return game:HttpGet(url) end)
    if ok and c then
        local f, err = loadstring(c)
        if f then
            setfenv(f, env)
            local ok2, err2 = pcall(f)
            if not ok2 then
                print("Erro paste " .. i .. ": " .. tostring(err2))
            end
        else
            print("Compile erro " .. i .. ": " .. tostring(err))
        end
    end
    task.wait(0.1)
end

-- PATCH: Window:Notify se faltar
if env.Window and not env.Window.Notify then
    env.Window.Notify = function(self, title, desc, duration)
        local SG = env.ScreenGui
        local TH = env.Theme
        local newF = env.new
        local cornerF = env.corner
        local strokeF = env.stroke

        local nh = SG:FindFirstChild("NotifyHolder")
        if not nh then
            nh = newF("Frame", {
                Name = "NotifyHolder",
                Size = UDim2.fromOffset(260, 400),
                Position = UDim2.new(1, -280, 0, 60),
                BackgroundTransparency = 1,
                Parent = SG,
            })
            newF("UIListLayout", {
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = nh,
            })
        end

        local n = newF("Frame", {
            Size = UDim2.new(1, 0, 0, 55),
            BackgroundColor3 = TH.Surface,
            BorderSizePixel = 0,
            Parent = nh,
        })
        cornerF(n, 8)
        strokeF(n, TH.Accent, 1)
        newF("TextLabel", {
            Size = UDim2.new(1, -16, 0, 18),
            Position = UDim2.fromOffset(12, 8),
            BackgroundTransparency = 1,
            Text = title or "Aviso",
            TextColor3 = TH.Text, TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = n,
        })
        newF("TextLabel", {
            Size = UDim2.new(1, -16, 0, 16),
            Position = UDim2.fromOffset(12, 28),
            BackgroundTransparency = 1,
            Text = desc or "",
            TextColor3 = TH.TextDim, TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = n,
        })
        task.delay(duration or 3, function()
            if n and n.Parent then
                for j = 0, 10 do
                    if n.Parent then n.BackgroundTransparency = j / 10 end
                    task.wait(0.02)
                end
                if n.Parent then n:Destroy() end
            end
        end)
    end
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "ToddynHub",
    Text = "Carregado! Toggles devem funcionar",
    Duration = 8,
})
