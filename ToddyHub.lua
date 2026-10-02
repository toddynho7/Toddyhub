--==================================================================
-- ToddyHub — teste 100% local (sem internet, sem GitHub)
-- Autor: Toddynho
--==================================================================

--==================================================================
-- CONFIGURAÇÃO — mexa só aqui
--==================================================================
local CONFIG = {
owner      = "Toddynho",
repo       = "ToddyHub",
branch     = "main",
logPrefix  = "[ToddyHub] ",

dryRun            = false,  -- true = só mostra o conteúdo; false = executa  
validateBeforeRun = true,   -- mostra tamanho, hash e 1ª linha  
blockObfuscated   = true,   -- recusa conteúdo que pareça ofuscado  

-- Qual script do catálogo local rodar (veja Catálogo abaixo)  
scriptName        = "boas_vindas",

}

--==================================================================
-- CATÁLOGO LOCAL — no teste real isso viria do GitHub
-- Cada chave é o "nome do script"; o valor é o conteúdo
--==================================================================
local Catálogo = {

boas_vindas = [==[

-- boas_vindas.lua
print("[boas_vindas] Ola do ToddyHub!")
print("[boas_vindas] PlaceId: " .. tostring(game.PlaceId))
print("[boas_vindas] JobId: "   .. tostring(game.JobId))
]==],

info_jogador = [==[

-- info_jogador.lua
local plr = game:GetService("Players").LocalPlayer
print("[info_jogador] Nome: "     .. tostring(plr and plr.Name))
print("[info_jogador] UserId: "   .. tostring(plr and plr.UserId))
print("[info_jogador] DisplayName: " .. tostring(plr and plr.DisplayName))
]==],

contador = [==[

-- contador.lua
local n = 0
for i = 1, 5 do
n = n + i
print("[contador] passo " .. i .. " -> soma parcial " .. n)
end
print("[contador] total: " .. n)
]==],

-- Exemplo de script ofuscado (pra ver a proteção agir)  
suspeito = [==[

-- Luraph Obfuscator v14.8
local _ = string.char(104,101,108,108,111)
local __ = string.pack("<I4", 12345)
print(_)
]==],
}

--==================================================================
-- MÓDULO 1: log
--==================================================================
local Log = {}
function Log.info(m)  print(CONFIG.logPrefix .. "INFO  " .. tostring(m)) end
function Log.warn(m)  warn(CONFIG.logPrefix .. "WARN  " .. tostring(m)) end
function Log.error(m) warn(CONFIG.logPrefix .. "ERROR " .. tostring(m)) end

--==================================================================
-- MÓDULO 2: fingerprint djb2 (identificação, não é criptografia)
--==================================================================
local function djb2(str)
local h = 5381
for i = 1, #str do
h = ((h * 33) + string.byte(str, i)) % 2^32
end
return string.format("%08x", h)
end

--==================================================================
-- MÓDULO 3: inspeção do conteúdo
--==================================================================
local Inspect = {}

function Inspect.report(body)
Log.info("tamanho: " .. #body .. " bytes")
Log.info("fingerprint djb2: " .. djb2(body))
if CONFIG.validateBeforeRun then
local first = body:match("^[^\n]*") or ""
Log.info("primeira linha: " .. first:sub(1, 120))
end
return true
end

function Inspect.looksObfuscated(body)
if not CONFIG.blockObfuscated then return false end
local markers = {
"Luraph", "Obfuscator",
"string%.pack", "string%.char",
}
local hits = 0
for _, m in ipairs(markers) do
if body:find(m) then hits = hits + 1 end
end
return hits >= 2
end

--==================================================================
-- MÓDULO 4: runner
--==================================================================
local Runner = {}

function Runner.run(name, body)
Log.info("--- executando: " .. name .. " ---")

if CONFIG.dryRun then  
    Log.warn("dryRun=true -> nao executo. Conteudo abaixo:")  
    print(body)  
    return  
end  

if Inspect.looksObfuscated(body) then  
    Log.error("conteudo parece ofuscado; abortando por seguranca")  
    return  
end  

local chunk, err = loadstring(body, "@" .. name .. ".lua")  
if not chunk then  
    Log.error("erro de compilacao: " .. tostring(err))  
    return  
end  

local ok, rerr = pcall(chunk)  
if not ok then  
    Log.error("runtime: " .. tostring(rerr))  
else  
    Log.info("ok")  
end

end

--==================================================================
-- MÓDULO 5: catálogo
--==================================================================
local Catalog = {}

function Catalog.get(name)
return Catálogo[name]
end

function Catalog.list()
local names = {}
for k in pairs(Catálogo) do table.insert(names, k) end
table.sort(names)
return names
end

--==================================================================
-- ENTRYPOINT
--==================================================================
local function main()
Log.info("ToddyHub v0.1 — owner=" .. CONFIG.owner)
Log.info("scripts disponiveis: " .. table.concat(Catalog.list(), ", "))

local name = CONFIG.scriptName  
local body = Catalog.get(name)  
if not body then  
    Log.error("script nao encontrado no catalogo: " .. tostring(name))  
    return  
end  

Inspect.report(body)  
Runner.run(name, body)

end

main()
