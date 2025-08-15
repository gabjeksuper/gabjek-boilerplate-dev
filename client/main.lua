
local TOKEN = nil
local hasLib = (GetResourceState('ox_lib') == 'started') and Config.UseOxLib
local PANEL_VISIBLE = false

RegisterKeyMapping('panel', 'Open Dev Panel', 'keyboard', Config.PanelKey or 'F6')
RegisterCommand('panel', function()
    PANEL_VISIBLE = not PANEL_VISIBLE
    SetNuiFocus(PANEL_VISIBLE, PANEL_VISIBLE)
    SendNUIMessage({ action = 'toggle', state = PANEL_VISIBLE, title = L('panel_title'), subtitle = L('panel_subtitle') })
    if PANEL_VISIBLE then TriggerServerEvent('gbd:requestToken') end
end, false)

RegisterNetEvent('gbd:setToken', function(tok) TOKEN = tok end)
RegisterNetEvent('gbd:clientRoute', function(action, data)
    if not TOKEN then TriggerServerEvent('gbd:requestToken'); return end
    TriggerServerEvent('gbd:route', action, data or {}, TOKEN)
end)

RegisterNetEvent('gbd:notify', function(msg)
    if hasLib and lib and lib.notify then
        lib.notify({ title = 'Boilerplate', description = tostring(msg), type = 'inform' })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(tostring(msg))
        EndTextCommandThefeedPostTicker(false, false)
    end
end)

RegisterNUICallback('close', function(_, cb)
    PANEL_VISIBLE = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('notify', function(data, cb)
    TriggerEvent('gbd:clientRoute', 'self_notify', data)
    cb({ ok = true })
end)

RegisterNUICallback('progress', function(_, cb)
    TriggerEvent('gbd:clientRoute', 'progress', {})
    cb({ ok = true })
end)
