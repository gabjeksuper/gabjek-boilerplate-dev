
local hasMySQL = (GetResourceState('oxmysql') == 'started') and (Config and Config.UseOxMySQL)
local TOKENS = {}

local function token()
    return ('%d.%d.%d'):format(os.time(), math.random(100000,999999), GetGameTimer() or 0)
end

local function rate(src, key)
    local conf = (Config and Config.RateLimits and Config.RateLimits[key]) or nil
    if not conf then return true end
    local ok = Util.RateLimit(('%s:%s'):format(key, tostring(src)), conf.max, conf.window)
    if not ok and src and src ~= 0 then TriggerClientEvent('gbd:notify', src, L('rate_limited')) end
    return ok
end

RegisterNetEvent('gbd:requestToken', function()
    local src = source
    local t = token()
    TOKENS[src] = t
    TriggerClientEvent('gbd:setToken', src, t)
end)

local function addLog(src, action, message)
    if not hasMySQL or not (MySQL and MySQL.insert) then return end
    local name = Bridge and Bridge.GetName and Bridge.GetName(src) or (GetPlayerName(src) or ('player_'..src))
    local text = Util.SanitizeText(tostring(message or ''), 200)
    pcall(function()
        MySQL.insert('INSERT INTO boilerplate_logs (player, action, message) VALUES (?, ?, ?)', { name, action, text })
    end)
end

local function tpToPreset(src, key)
    local p = Config and Config.Teleports and Config.Teleports[key]
    if not p then return end
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        SetEntityCoords(ped, p.x + 0.0, p.y + 0.0, p.z + 0.0, false, false, false, false)
        SetEntityHeading(ped, (p.h or 0.0) + 0.0)
    end
end

local function clampItemCount(n) n = tonumber(n) or 1 if n < 1 then n = 1 end if n > (Config.Limits.ItemCountMax or 10) then n = Config.Limits.ItemCountMax end return n end
local function clampMoney(n) n = math.floor(tonumber(n) or 0) if n < 0 then n = 0 end if n > (Config.Limits.MoneyPerAction or 10000) then n = Config.Limits.MoneyPerAction end return n end

local ROUTES = {
    self_notify = {
        perm = nil,
        fn = function(src, data)
            local msg = Util.SanitizeText((data and data.message) or L('notify_ok'), 120)
            TriggerClientEvent('gbd:notify', src, msg)
            addLog(src, 'self_notify', msg)
        end
    },
    progress = {
        perm = nil,
        fn = function(src, data)
            TriggerClientEvent('gbd:notify', src, L('done'))
        end
    },
    player_list = {
        perm = 'gbd.admin',
        fn = function(src, data)
            local list = {}
            for _, id in ipairs(GetPlayers()) do
                local pid = tonumber(id)
                list[#list+1] = { id = pid, name = Bridge.GetName and Bridge.GetName(pid) or (GetPlayerName(pid) or ('player_'..pid)) }
            end
            TriggerClientEvent('gbd:receivePlayerList', src, list)
        end
    },
    admin_announce = {
        perm = 'gbd.admin',
        fn = function(src, data)
            local msg = Util.SanitizeText((data and data.message) or '', 200)
            if msg == '' then return end
            TriggerClientEvent('chat:addMessage', -1, { args = { L('announce_prefix'), msg } })
            addLog(src, 'admin_announce', msg)
        end
    },
    admin_tp = {
        perm = 'gbd.admin',
        fn = function(src, data)
            local loc = (data and data.location) or ''
            tpToPreset(src, tostring(loc))
            addLog(src, 'admin_tp', loc)
        end
    },
    admin_giveitem = {
        perm = 'gbd.admin',
        fn = function(src, data)
            local item = Util.SanitizeText((data and data.item) or '', 50)
            local count = clampItemCount((data and data.count) or 1)
            if item == '' then return end
            Bridge.AddItem(src, item, count, nil)
            addLog(src, 'admin_giveitem', item..' x'..tostring(count))
        end
    },
    admin_givemoney = {
        perm = 'gbd.admin',
        fn = function(src, data)
            local account = (data and data.account) or 'cash'
            if account ~= 'cash' and account ~= 'bank' then account = 'cash' end
            local amount = clampMoney((data and data.amount) or 0)
            if amount <= 0 then return end
            Bridge.AddMoney(src, account, amount, 'gbd')
            addLog(src, 'admin_givemoney', account..' '..tostring(amount))
        end
    },
}

RegisterNetEvent('gbd:route', function(action, payload, t)
    local src = source
    if not rate(src, 'route') then return end
    if not t or TOKENS[src] ~= t then return end
    local r = ROUTES[action]
    if not r or type(r.fn) ~= 'function' then return end
    if r.perm and src ~= 0 and not IsPlayerAceAllowed(src, r.perm) then
        TriggerClientEvent('gbd:notify', src, L('no_permission'))
        return
    end
    local ok, err = pcall(r.fn, src, payload or {})
    if not ok then print(('[gbd] route %s error: %s'):format(tostring(action), tostring(err))) end
end)

RegisterCommand('announce', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'gbd.announce') then
        TriggerClientEvent('gbd:notify', source, L('no_permission')); return
    end
    if not rate(source, 'announce') then return end
    local msg = Util.SanitizeText(table.concat(args, ' '), 200)
    if msg == '' then return end
    TriggerClientEvent('chat:addMessage', -1, { args = { L('announce_prefix'), msg } })
end, true)

RegisterCommand('gbd:diag', function(source, _)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'gbd.diag') then
        TriggerClientEvent('gbd:notify', source, L('no_permission')); return
    end
    local report = {
        ox_lib = GetResourceState('ox_lib'),
        ox_target = GetResourceState('ox_target'),
        ox_inventory = GetResourceState('ox_inventory'),
        oxmysql = GetResourceState('oxmysql'),
        es_extended = GetResourceState('es_extended'),
        qb_core = GetResourceState('qb-core'),
        qbx_core = GetResourceState('qbx-core'),
        locale = Config and Config.Locale
    }
    print('[gbd] DIAG ' .. Util.ToJSON(report))
    if source ~= 0 then TriggerClientEvent('gbd:notify', source, L('diag_ok')) end
end, true)

AddEventHandler('playerDropped', function() TOKENS[source] = nil end)

CreateThread(function()
    if hasMySQL and MySQL and MySQL.query then
        pcall(function()
            MySQL.query([[
                CREATE TABLE IF NOT EXISTS boilerplate_logs (
                    id INT NOT NULL AUTO_INCREMENT,
                    player VARCHAR(64) NOT NULL,
                    action VARCHAR(32),
                    message TEXT,
                    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    PRIMARY KEY (id)
                )
            ]])
        end)
    end
end)

exports('Notify', function(src, msg)
    TriggerClientEvent('gbd:notify', src, Util.SanitizeText(tostring(msg or ''), 120))
end)

exports('HasFramework', function()
    if GetResourceState('es_extended') == 'started' then return 'ESX' end
    if GetResourceState('qb-core') == 'started' then return 'QBCORE' end
    if GetResourceState('qbx-core') == 'started' or GetResourceState('qbox') == 'started' then return 'QBOX' end
    return 'STANDALONE'
end)
