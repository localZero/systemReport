-----------------------------------------------------
-- connection 
-----------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
zer = {}
Tunnel.bindInterface("systemReport", zer)
-----------------------------------------------------
-- prepare 
-----------------------------------------------------
vRP._prepare('zer/give', 'INSERT INTO systemreport(id, motivo) VALUES(@id, @motivo)')
vRP.prepare("zer/push", "SELECT * FROM systemreport WHERE id = @id ")

function zer.ds(user_id)
    local rows = vRP.query("zer/push", {
        id = user_id
    })
    if rows ~= nil then
        for k, v in pairs(rows) do
            return #rows
        end
    end
    return "0"
end

function zer.giveM(id, motivo)
    vRP.execute('zer/give', {
        id = id,
        motivo = motivo
    })
end

RegisterCommand('history', function(source, args, rawCommand)
    if args[1] then
        if vRP.hasPermission(user_id, "nc.permissao") then
            local ds = zer.ds(args[1])
            print(ds)
            TriggerClientEvent("Notify", source, "sucesso",
                               "O passaporte ' .. args[1] .. ' possui atualmente: <b>' .. ds .. '</b> de denuncias.")
        end
    end
end)
-----------------------------------------------------
-- variables 
-----------------------------------------------------
RegisterCommand('report', function(source, args, rawCommand)
    local source = source
    local user_id = vRP.getUserId(source)
    if args[1] then
        local fcoords = vRP.prompt(source, "Descreva com detalhes a sua denuncia : ", "")
        if fcoords == "" then
            return
        end
        local id = user_id
        zer.giveM(args[1], fcoords)
        local ds = zer.ds(args[1])
        sendToDiscord(16711680,
                      "```ID : " .. id .. "```\n```ID DENUNCIADO : " .. args[1] .. "```\n```MOTIVO DA DENUNCIA : " ..
                          fcoords .. "```\n ```TOTAL DE DENUNCIAS DO INDIVIDUO : " .. ds .. "```",
                      "Registro de Denuncias")
        TriggerClientEvent("Notify", source, "sucesso",
                           "Voce reportou o passaport <b>" .. args[1] .. "</b> com sucesso.")
    end
end)

function sendToDiscord(color, message, title)
    local embed = {
        {
            ["color"] = "16711680",
            ["title"] = "**" .. title .. "**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Made By Zero"
            }
        }
    }

    PerformHttpRequest('SEU_LINK', function(err, text, headers) end, 'POST', json.encode({
        username = name,
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end
