--[[
    ToddynHub - Loader v2
    Baixa as 12 partes do Pastebin e executa
]]

local links = {
    -- 1: Base + Janela + Watermark
    'https://pastebin.com/raw/sC36W60v',
    -- 2: AddTab/Section/Toggle/Button
    'https://pastebin.com/raw/V1PzyDQb',
    -- 3: Slider/Dropdown
    'https://pastebin.com/raw/usaNx6CJ',
    -- 4: ColorPicker/Keybind
    'https://pastebin.com/raw/YKZqpVpC',
    -- 5: Config + Abas novas + Settings Instagram
    'https://pastebin.com/raw/jdGZNNfV',
    -- 6: Murder + Kill Aura
    'https://pastebin.com/raw/UTcmBeZm',
    -- 7: Sheriff + Botao Anime
    'https://pastebin.com/raw/prTiXBx6',
    -- 8: Innocent + Utilitarios (Fling/Noclip/ServerHop)
    'https://pastebin.com/raw/CkFKBhmS',
    -- 9: Anti-Fling + Void Hide + Modifiers
    'https://pastebin.com/raw/jrbpiJhs',
    -- 10A: Aura + Kill Effect
    'https://pastebin.com/raw/CEgNcQhx',
    -- 10B: ESP (aba propria)
    'https://pastebin.com/raw/HAPUdLQF',
    -- 10C: Minimap + Farm + Botao Menu + Final
    'https://pastebin.com/raw/xYxTQW9s',
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
