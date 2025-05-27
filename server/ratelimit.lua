local rateLimits = {}

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

function CheckRateLimit(src, playerId)

    log('debug', ('Checking rate limit for player %s'):format(src, playerId), 'cyan')

    -- Check admin permission
    if IsPlayerAceAllowed(src, Config.AdminPermission) then
        log('debug', ('Admin bypassed rate limit (%s)'):format(playerId), 'yellow')
        return true
    end

    if not rateLimits[playerId] then
        rateLimits[playerId] = { count = 0, lastReset = os.time() }
    end

    if os.time() - rateLimits[playerId].lastReset > Config.RateLimit.resetTime then
        rateLimits[playerId] = { count = 0, lastReset = os.time() }
        log('debug', ('Rate limit reset for player %s'):format(playerId), 'green')
    end

    if rateLimits[playerId].count >= Config.RateLimit.maxEmotes then
        log('info', ('Player %s hit rate limit (%d/%d)'):format(playerId, rateLimits[playerId].count, Config.RateLimit.maxEmotes), 'red')
        return false
    end

    rateLimits[playerId].count = rateLimits[playerId].count + 1
    log('debug', ('Player %s emote count: %d/%d'):format(playerId, rateLimits[playerId].count, Config.RateLimit.maxEmotes), 'cyan')
    return true
end