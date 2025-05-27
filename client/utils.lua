local npcCooldowns = {}

function log(level, message, color)
    if Config.LogLevel == 'debug' or (Config.LogLevel == 'info' and level == 'info') then
        local colors = {
            green = '^2',
            red = '^1',
            yellow = '^3',
            cyan = '^5',
            white = '^7'
        }
        local colorCode = colors[color] or colors.white
        print(('%s[ved-emotivereactions] [%s] %s^0'):format(colorCode, level, message))
    end
end

function SetPedOnNPCCooldown(ped)
    npcCooldowns[ped] = GetGameTimer() + Config.NPCCooldown * 1000
end

function IsPedOnNPCCooldown(ped)
    return npcCooldowns[ped] and GetGameTimer() < npcCooldowns[ped]
end

function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        local success
        repeat
            coroutine.yield(ped)
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end)
end

RegisterNetEvent('ved-emotivereactions:notify')
AddEventHandler('ved-emotivereactions:notify', function(message)
    if Config.NotificationFramework == 'qb' then
        exports['qb-core']:Notify(message, 'error', 5000)
    elseif Config.NotificationFramework == 'esx' then
        exports["esx_notify"]:Notify("error", 5000, message)
    elseif Config.NotificationFramework == 'oxlib' then
        exports['ox_lib']:notify({title = 'Emotive Reactions', description = message, type = 'error', length = 5000})
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(true, false)
    end
end)