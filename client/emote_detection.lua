local lastEmoteTime = 0
local isProcessing = false
local currentEmote = nil

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    log('info', 'Emote detection started with mode: ' .. tostring(Config.DetectionMode), 'yellow')
    -- log('info', ('Config loaded. Available emotes: %s'):format(table.concat(Keys(Config.EmoteReactions or {}), ', ')), 'yellow')
    log('info', ('Config loaded'), 'yellow')
end)

local function TriggerEmoteValidation(emote, playerCoords)
    log('debug', ('Attempting to process emote: %s, Player Coords: %s'):format(tostring(emote), tostring(playerCoords)), 'cyan')
    if not Config.EmoteReactions then
        log('error', 'Config.EmoteReactions is not defined or loaded', 'red')
        TriggerEvent('ved-emotivereactions:notify', 'Error: Emote configuration not loaded.')
        return
    end
    if Config.EmoteReactions[emote] then
        if not isProcessing and GetGameTimer() - lastEmoteTime > Config.GlobalCooldown * 1000 then
            local reaction = Config.EmoteReactions[emote]
            if Config.DetectionMode == 'command' then
                RequestAnimDict(reaction.playerAnimDict)
                while not HasAnimDictLoaded(reaction.playerAnimDict) do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(PlayerPedId(), reaction.playerAnimDict, reaction.playerAnimName, 8.0, -8.0, -1, 0, 0, false, false, false)
                log('debug', ('Playing player emote: %s, Dict: %s, Anim: %s'):format(emote, reaction.playerAnimDict, reaction.playerAnimName), 'cyan')
            end
            isProcessing = true
            lastEmoteTime = GetGameTimer()
            if Config.DetectionMode == 'loop' then
                currentEmote = emote
                log('debug', ('Set currentEmote to %s in loop mode'):format(currentEmote), 'cyan')
            end
            log('debug', ('Triggering server validation for emote: %s'):format(emote), 'cyan')
            TriggerServerEvent('ved-emotivereactions:validateEmote', emote, playerCoords)
            local cooldown = Config.DetectionMode == 'loop' and math.max(reaction.cooldown, Config.MinCooldownForAnimation) or reaction.cooldown
            log('debug', ('Applying cooldown of %d seconds for emote: %s'):format(cooldown, emote), 'cyan')

            -- Anim duration
            if Config.DetectionMode == 'loop' then
                local playerPed = PlayerPedId()
                local animDuration
                if not reaction.loop then
                    animDuration = 5000 -- 5 seconds
                    log('debug', ('Playing non-looping animation %s for %dms'):format(emote, animDuration), 'cyan')
                    Citizen.Wait(animDuration)
                    StopAnimTask(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 1.0)
                    ClearPedTasks(playerPed)
                    log('debug', ('Stopped non-looping animation %s after %dms'):format(emote, animDuration), 'cyan')
                else
                    animDuration = reaction.loopDuration >= 0 and reaction.loopDuration or Config.DefaultLoopDuration
                    log('debug', ('Looping animation %s for %dms'):format(emote, animDuration), 'cyan')
                    Citizen.Wait(animDuration)
                    if Config.ClearAnimationAfterPlay then
                        StopAnimTask(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 1.0)
                        ClearPedTasks(playerPed)
                        log('debug', ('Stopped looping animation %s after %dms'):format(emote, animDuration), 'cyan')
                    end
                end

                if IsEntityPlayingAnim(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 3) then
                    local maxDuration = 15000 -- 15 seconds max
                    local elapsed = 0
                    while elapsed < maxDuration do
                        if not IsEntityPlayingAnim(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 3) then
                            break
                        end
                        Citizen.Wait(1000)
                        elapsed = elapsed + 1000
                    end
                    if elapsed >= maxDuration then
                        StopAnimTask(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 1.0)
                        ClearPedTasks(playerPed)
                        log('debug', ('Force-stopped animation %s after exceeding max duration (%dms)'):format(emote, maxDuration), 'yellow')
                    end
                end
            end

            -- Apply the remaining cooldown
            local remainingCooldown = (cooldown * 1000) - (Config.DetectionMode == 'loop' and animDuration or 0)
            if remainingCooldown > 0 then
                log('debug', ('Waiting for remaining cooldown: %dms'):format(remainingCooldown), 'cyan')
                Citizen.Wait(remainingCooldown)
            else
                log('debug', ('No remaining cooldown needed'), 'cyan')
            end

            isProcessing = false
            if Config.DetectionMode == 'command' then
                StopAnimTask(PlayerPedId(), reaction.playerAnimDict, reaction.playerAnimName, 1.0)
                ClearPedTasks(PlayerPedId())
            end
            if Config.DetectionMode == 'loop' and currentEmote then
                local playerPed = PlayerPedId()
                local reaction = Config.EmoteReactions[currentEmote]
                if IsEntityPlayingAnim(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 3) then
                    log('debug', ('Animation %s still playing after cooldown, keeping currentEmote set'):format(currentEmote), 'yellow')
                    if Config.ClearAnimationAfterPlay then
                        StopAnimTask(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 1.0)
                        ClearPedTasks(playerPed)
                        log('debug', ('Cleared animation %s to prevent further looping'):format(currentEmote), 'cyan')
                        currentEmote = nil
                    end
                else
                    log('debug', ('Cleared currentEmote after cooldown - animation stopped'), 'cyan')
                    currentEmote = nil
                end
            end
        else
            log('debug', ('Emote %s ignored: isProcessing=%s, TimeSinceLast=%dms, GlobalCooldown=%ds'):format(emote, tostring(isProcessing), GetGameTimer() - lastEmoteTime, Config.GlobalCooldown), 'yellow')
            TriggerEvent('ved-emotivereactions:notify', 'Please wait before using another emote.')
        end
    else
        -- log('debug', ('Unrecognized emote: %s. Available emotes: %s'):format(tostring(emote), table.concat(Keys(Config.EmoteReactions or {}), ', ')), 'yellow')
        log('debug', ('Unrecognized emote'), 'yellow')
        TriggerEvent('ved-emotivereactions:notify', 'Emote not recognized: ' .. tostring(emote))
    end
end

if Config.DetectionMode == 'command' then
    Citizen.CreateThread(function()
        if Config.EmoteCommand then
            RegisterCommand(Config.EmoteCommand, function(source, args)
                local emote = args[1]
                if not emote then
                    TriggerEvent('ved-emotivereactions:notify', 'Please provide an emote name.')
                    log('info', 'Emote command failed: No emote provided', 'yellow')
                    return
                end
                log('info', ('Emote command triggered: %s'):format(emote), 'yellow')
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                TriggerEmoteValidation(emote:lower(), playerCoords)
            end, false)

             TriggerEvent('chat:addSuggestion', '/' .. Config.EmoteCommand, 'Trigger an emote reaction', {
                { name = 'emote_name', help = 'The name of the emote to trigger' }
            })

        else
            log('error', 'Config.EmoteCommand not defined', 'red')
        end
    end)
end

if Config.DetectionMode == 'loop' then
    Citizen.CreateThread(function()
        log('info', ('Started loop-based emote detection. Checking animations every %dms'):format(Config.LoopDetectionInterval), 'yellow')
        while true do
            local sleep = Config.LoopDetectionInterval
            if not isProcessing then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local detectedEmote = nil
                for emote, reaction in pairs(Config.EmoteReactions) do
                    if IsEntityPlayingAnim(playerPed, reaction.playerAnimDict, reaction.playerAnimName, 3) then
                        detectedEmote = emote
                        break
                    end
                end
                if detectedEmote then
                    if detectedEmote == currentEmote then
                        log('debug', ('Emote %s already triggered, skipping re-detection'):format(detectedEmote), 'yellow')
                    elseif GetGameTimer() - lastEmoteTime > Config.GlobalCooldown * 1000 then
                        log('debug', ('Detected emote: %s, Dict: %s, Anim: %s'):format(detectedEmote, Config.EmoteReactions[detectedEmote].playerAnimDict, Config.EmoteReactions[detectedEmote].playerAnimName), 'cyan')
                        sleep = 100
                        TriggerEmoteValidation(detectedEmote, playerCoords)
                    else
                        log('debug', ('Emote %s detected but ignored due to cooldown: TimeSinceLast=%dms, GlobalCooldown=%ds'):format(detectedEmote, GetGameTimer() - lastEmoteTime, Config.GlobalCooldown), 'yellow')
                    end
                else
                    if currentEmote then
                        log('debug', ('Emote %s no longer playing, clearing currentEmote'):format(currentEmote), 'cyan')
                        currentEmote = nil
                    end
                end
            else
                log('debug', ('Loop skipped: isProcessing=%s'):format(tostring(isProcessing)), 'yellow')
            end
            Citizen.Wait(sleep)
        end
    end)
end

function Keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end