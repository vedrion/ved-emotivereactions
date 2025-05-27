-- Website: https://ved.tebex.io/
-- GitHub: https://github.com/vedrion
-- Discord: https://discord.gg/DscAtV7r6J

RegisterServerEvent('ved-emotivereactions:validateEmote')
AddEventHandler('ved-emotivereactions:validateEmote', function(emote, playerCoords)
    local src = source
    local playerId = GetPlayerIdentifier(src, 0)

    log('debug', ('Received validateEmote event from player %s: emote=%s, coords=%s'):format(playerId, tostring(emote), tostring(playerCoords)), 'cyan')

    if type(emote) ~= 'string' or type(playerCoords) ~= 'vector3' then
        log('info', ('Invalid data from player %s: emote=%s, coords=%s'):format(playerId, tostring(emote), tostring(playerCoords)), 'red')
        TriggerClientEvent('ved-emotivereactions:notify', src, 'Invalid emote data.')
        return
    end

    if not Config.EmoteReactions then
        log('error', 'Config.EmoteReactions is not defined or loaded', 'red')
        TriggerClientEvent('ved-emotivereactions:notify', src, 'Error: Emote configuration not loaded.')
        return
    end

    if not Config.EmoteReactions[emote] then
        log('info', ('Player %s attempted invalid emote: %s. Available emotes: %s'):format(playerId, emote, table.concat(Keys(Config.EmoteReactions), ', ')), 'red')
        TriggerClientEvent('ved-emotivereactions:notify', src, 'Emote not recognized: ' .. emote)
        return
    end

    if not CheckRateLimit(src, playerId) then
        log('info', ('Player %s blocked by rate limit'):format(playerId), 'yellow')
        TriggerClientEvent('ved-emotivereactions:notify', src, 'Please wait before using another emote.')
        return
    end

    log('debug', ('Validated emote %s for player %s, triggering reaction'):format(emote, playerId), 'cyan')
    TriggerClientEvent('ved-emotivereactions:triggerReaction', src, emote, playerCoords)
end)

function Keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end