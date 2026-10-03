local links = {
    'https://pastebin.com/raw/jpjhAMRq',
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
    'https://pastebin.com/raw/xYxTQW9s',
}

local codigo = ''
for i, url in ipairs(links) do
    local ok, parte = pcall(function() return game:HttpGet(url) end)
    if ok and parte then
        codigo = codigo .. parte .. '\n'
        print('OK ' .. i .. ': ' .. #parte .. ' chars')
    else
        warn('FALHA ' .. i)
    end
end

print('Total: ' .. #codigo)
loadstring(codigo)()
