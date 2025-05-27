-- Website: https://ved.tebex.io/
-- GitHub: https://github.com/vedrion
-- Discord: https://discord.gg/DscAtV7r6J

local isReacting = false

RegisterNetEvent('ved-emotivereactions:triggerReaction')
AddEventHandler('ved-emotivereactions:triggerReaction', function(emote, playerCoords)
    if isReacting then
        log('debug', ('Ignoring duplicate trigger for emote: %s, NPCs are already reacting'):format(emote), 'yellow')
        return
    end

    local reaction = Config.EmoteReactions[emote]
    if not reaction then
        log('info', 'Invalid reaction data received for emote: ' .. tostring(emote), 'red')
        return
    end

    isReacting = true
    log('debug', ('Starting NPC reactions for emote: %s'):format(emote), 'cyan')

    local playerPed = PlayerPedId()
    local npcs = {}
    local nearbyPeds = EnumeratePeds()
    local count = 0

    for ped in nearbyPeds do
        if count >= Config.MaxNPCs then break end
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            if Config.IgnoreHostile and (IsPedInCombat(ped, playerPed) or IsPedFleeing(ped)) then
                log('debug', ('Skipping NPC %d: Hostile or fleeing'):format(ped), 'yellow')
                goto continue
            end
            local pedCoords = GetEntityCoords(ped)
            if #(playerCoords - pedCoords) <= Config.ReactionRange then
                if not IsPedOnNPCCooldown(ped) then
                    table.insert(npcs, ped)
                    count = count + 1
                else
                    log('debug', ('Skipping NPC %d: On cooldown'):format(ped), 'yellow')
                end
            end
        end
        ::continue::
    end

    log('debug', ('Found %d NPCs within range'):format(#npcs), 'cyan')
    local chanceMultiplier = 1.0
    for _, zone in ipairs(Config.ReactionZones) do
        if #(playerCoords - zone.coords) < zone.radius then
            chanceMultiplier = zone.chanceMultiplier or 1.0
            log('debug', ('In zone, multiplier: %f'):format(chanceMultiplier), 'cyan')
            break
        end
    end

    for i, ped in ipairs(npcs) do
        local reactionChance = reaction.chance * chanceMultiplier
        local randomValue = math.random()
        log('debug', ('NPC %d reaction chance: %f, random: %f'):format(ped, reactionChance, randomValue), 'cyan')
        if randomValue < reactionChance then
            if reaction.facePlayer then
                TaskTurnPedToFaceEntity(ped, playerPed, 1000)
                Citizen.Wait(1000)
                log('debug', ('NPC %d turning to face player'):format(ped), 'cyan')
            end
            RequestAnimDict(reaction.npcAnimDict)
            if not HasAnimDictLoaded(reaction.npcAnimDict) then
                log('info', ('Failed to load anim dict: %s'):format(reaction.npcAnimDict), 'red')
                Citizen.Wait(1000)
            end
            while not HasAnimDictLoaded(reaction.npcAnimDict) do
                Citizen.Wait(100)
            end
            TaskPlayAnim(ped, reaction.npcAnimDict, reaction.npcAnimName, 8.0, -8.0, 5000, 0, 0, false, false, false)
            log('debug', ('NPC %d playing anim: %s/%s'):format(ped, reaction.npcAnimDict, reaction.npcAnimName), 'cyan')

            if reaction.enableReactionText then
                local text = "Hey there!" -- Default text
                if reaction.reactionTexts and #reaction.reactionTexts > 0 then
                    text = reaction.reactionTexts[math.random(1, #reaction.reactionTexts)]
                else
                    log('error', ('No valid reaction texts for emote %s'):format(emote), 'red')
                end
                DisplayNPCText(ped, text)
            else
                log('debug', ('Reaction text disabled for emote %s'):format(emote), 'cyan')
            end
            SetPedOnNPCCooldown(ped)
            Citizen.Wait(5000)
            ClearPedTasks(ped)
            Citizen.Wait(math.floor(Config.NPCReactionDelay * 1000))
        else
            log('debug', ('NPC %d did not react due to chance failure'):format(ped), 'yellow')
        end
    end

    isReacting = false
    log('debug', ('Finished NPC reactions for emote: %s'):format(emote), 'cyan')
end)

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

function DisplayNPCText(ped, text)
    log('debug', ('Displaying text for ped %d: %s, mode: %s'):format(ped, text, Config.TextDisplayMode), 'cyan')
    if Config.TextDisplayMode:lower() == 'chat' or Config.TextDisplayMode:lower() == 'both' then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {'[NPC]', text}
        })
        log('debug', ('Chat message sent: %s'):format(text), 'cyan')
    end

    if Config.TextDisplayMode:lower() == '3d' or Config.TextDisplayMode:lower() == 'both' then
        local endTime = GetGameTimer() + 5000
        Citizen.CreateThread(function()
            while GetGameTimer() < endTime do
                if DoesEntityExist(ped) then
                    local coords = GetEntityCoords(ped)
                    local offset = vector3(0.0, 0.0, 1.0) -- Above NPC's head
                    DrawText3D(coords.x + offset.x, coords.y + offset.y, coords.z + offset.z, text)
                end
                Citizen.Wait(0)
            end
            log('debug', ('3D text display ended for ped %d'):format(ped), 'cyan')
        end)
    end
end