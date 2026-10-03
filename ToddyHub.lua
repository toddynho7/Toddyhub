--[[
    Toddynhohub 2.01 - Loader
    Baixa as 12 partes do Pastebin e executa
]]

local links = {
    'https://pastebin.com/raw/gkqnLFGc',
    'https://pastebin.com/raw/V1PzyDQb',
    'https://pastebin.com/raw/usaNx6CJ',
    'https://pastebin.com/raw/YKZqpVpC',
    'https://pastebin.com/raw/pH2U61VL',
    'https://pastebin.com/raw/391n89st',
    'https://pastebin.com/raw/mt0L3xid',
    'https://pastebin.com/raw/EC7U6V8u',
    'https://pastebin.com/raw/jrbpiJhs',
    'https://pastebin.com/raw/CEgNcQhx',
    'https://pastebin.com/raw/RnadMuVX',
    'https://pastebin.com/raw/jsWdGhZx',
}

local codigo = ''
for i, url in ipairs(links) do
    local ok, parte = pcall(function() return game:HttpGet(url) end)
    if ok and parte then
        codigo = codigo .. parte .. '\n'
        print('✅ Parte ' .. i .. ': ' .. #parte .. ' chars')
    else
        warn('❌ Falha na parte ' .. i .. ': ' .. url)
    end
end

print('📦 Total: ' .. #codigo .. ' caracteres')
loadstring(codigo)()
