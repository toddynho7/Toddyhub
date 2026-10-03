local links = {
    'https://pastebin.com/raw/hZysC6V5', -- 1 FIX2
    'https://pastebin.com/raw/V1PzyDQb', -- 2
    'https://pastebin.com/raw/usaNx6CJ', -- 3
    'https://pastebin.com/raw/YKZqpVpC', -- 4
    'https://pastebin.com/raw/jdGZNNfV', -- 5
    'https://pastebin.com/raw/UTcmBeZm', -- 6
    'https://pastebin.com/raw/prTiXBx6', -- 7
    'https://pastebin.com/raw/CkFKBhmS', -- 8
    'https://pastebin.com/raw/jrbpiJhs', -- 9
    'https://pastebin.com/raw/CEgNcQhx', -- 10A
    'https://pastebin.com/raw/HAPUdLQF', -- 10B
    'https://pastebin.com/raw/xYxTQW9s', -- 10C
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
