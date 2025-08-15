
Bridge = { Framework = 'STANDALONE', ESX = nil, QB = nil }

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Bridge.Framework = 'ESX'
        Bridge.ESX = (exports['es_extended'] and exports['es_extended']:getSharedObject()) or nil
        return
    end
    if GetResourceState('qb-core') == 'started' then
        Bridge.Framework = 'QBCORE'
        Bridge.QB = exports['qb-core']:GetCoreObject()
        return
    end
    if GetResourceState('qbx-core') == 'started' or GetResourceState('qbox') == 'started' then
        Bridge.Framework = 'QBOX'
        local exp = exports['qbx-core'] or exports['qbox']
        if exp and exp.GetCoreObject then Bridge.QB = exp:GetCoreObject() end
        return
    end
end)

function Bridge.GetName(src)
    if Bridge.Framework == 'ESX' then
        local x = Bridge.ESX and Bridge.ESX.GetPlayerFromId(src)
        return (x and x.getName()) or ('player_'..tostring(src))
    elseif Bridge.Framework == 'QBCORE' or Bridge.Framework == 'QBOX' then
        local x = Bridge.QB and Bridge.QB.Functions.GetPlayer(src)
        if x and x.PlayerData and x.PlayerData.charinfo then
            local c = x.PlayerData.charinfo
            return (string.format('%s %s', c.firstname or '', c.lastname or '')):gsub('%s+$','')
        end
        return ('player_'..tostring(src))
    else
        return ('player_'..tostring(src))
    end
end

function Bridge.AddMoney(src, account, amount, reason)
    amount = tonumber(amount) or 0
    if amount == 0 then return false end
    if Bridge.Framework == 'ESX' then
        local x = Bridge.ESX and Bridge.ESX.GetPlayerFromId(src)
        if not x then return false end
        if account == 'bank' and x.addAccountMoney then x.addAccountMoney('bank', amount, reason or 'gbd') else x.addMoney(amount) end
        return true
    elseif Bridge.Framework == 'QBCORE' or Bridge.Framework == 'QBOX' then
        local x = Bridge.QB and Bridge.QB.Functions.GetPlayer(src)
        if not x then return false end
        x.Functions.AddMoney(account or 'cash', amount, reason or 'gbd')
        return true
    else
        return true
    end
end

function Bridge.AddItem(src, item, count, meta)
    count = count or 1
    if GetResourceState('ox_inventory') == 'started' and (Config and Config.UseOxInventory) then
        return exports.ox_inventory:AddItem(src, item, count, meta)
    end
    if Bridge.Framework == 'ESX' then
        local x = Bridge.ESX and Bridge.ESX.GetPlayerFromId(src)
        if not x then return false end
        return x.addInventoryItem(item, count, meta)
    elseif Bridge.Framework == 'QBCORE' or Bridge.Framework == 'QBOX' then
        local x = Bridge.QB and Bridge.QB.Functions.GetPlayer(src)
        if not x then return false end
        return x.Functions.AddItem(item, count, false, meta)
    else
        return true
    end
end
