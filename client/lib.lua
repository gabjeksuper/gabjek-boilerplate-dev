
local hasLib = (GetResourceState('ox_lib') == 'started') and Config.UseOxLib
local hasTarget = (GetResourceState('ox_target') == 'started') and Config.UseOxTarget

RegisterCommand('devmenu', function()
    if hasLib and lib and lib.registerContext then
        local options = {
            { title = L('menu_self_notify'), event = 'gbd:nui:self_notify' },
            { title = L('menu_progress'), event = 'gbd:nui:progress' },
            { title = L('menu_player_list'), event = 'gbd:nui:player_list' },
            { title = L('menu_tp'), event = 'gbd:nui:tp' },
            { title = L('menu_give_item'), event = 'gbd:nui:give_item' },
            { title = L('menu_give_money'), event = 'gbd:nui:give_money' },
        }
        lib.registerContext({ id = 'gbd_menu', title = L('menu_title'), options = options })
        lib.showContext('gbd_menu')
    end
end, false)

AddEventHandler('gbd:nui:self_notify', function(data) TriggerEvent('gbd:clientRoute', 'self_notify', data) end)
AddEventHandler('gbd:nui:progress', function(data) TriggerEvent('gbd:clientRoute', 'progress', data) end)
AddEventHandler('gbd:nui:player_list', function() TriggerEvent('gbd:clientRoute', 'player_list', {}) end)

AddEventHandler('gbd:nui:tp', function()
    if hasLib and lib and Config.Teleports then
        local opts = {}
        for k,_ in pairs(Config.Teleports) do opts[#opts+1] = { title = k, args = { location = k } } end
        lib.registerContext({ id = 'gbd_tp', title = L('choose_location'), options = opts })
        lib.showContext('gbd_tp')
    end
end)

AddEventHandler('gbd:nui:give_item', function()
    if hasLib and lib then
        local input = lib.inputDialog(L('choose_item'), {
            { type = 'input', label = 'item', required = true },
            { type = 'number', label = 'count', default = 1, required = true }
        })
        if input then TriggerEvent('gbd:clientRoute', 'admin_giveitem', { item = input[1], count = input[2] }) end
    end
end)

AddEventHandler('gbd:nui:give_money', function()
    if hasLib and lib then
        local input = lib.inputDialog(L('choose_money'), {
            { type = 'select', label = 'account', options = { {label='cash', value='cash'}, {label='bank', value='bank'} }, required = true },
            { type = 'number', label = 'amount', default = 100, required = true }
        })
        if input then TriggerEvent('gbd:clientRoute', 'admin_givemoney', { account = input[1], amount = input[2] }) end
    end
end)

RegisterNetEvent('gbd:receivePlayerList', function(list)
    if hasLib and lib then
        local opts = {}
        for _,p in ipairs(list or {}) do opts[#opts+1] = { title = ('[%s] %s'):format(p.id, p.name) } end
        lib.registerContext({ id = 'gbd_players', title = L('menu_player_list'), options = opts })
        lib.showContext('gbd_players')
    end
end)

CreateThread(function()
    if hasTarget and Config.TargetDemo then
        local ped = PlayerPedId()
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'gbd:selfnotify',
                icon = 'fa-solid fa-bell',
                label = L('menu_self_notify'),
                onSelect = function()
                    TriggerEvent('gbd:clientRoute', 'self_notify', { message = L('notify_ok') })
                end
            }
        })
    end
end)

exports('OpenPanel', function() ExecuteCommand('panel') end)
