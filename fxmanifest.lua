fx_version 'cerulean'
game 'gta5'

author 'Ved'
description 'Trigger emote reactions with NPC responses'
version '1.0.0'

-- Website: https://ved.tebex.io/
-- GitHub: https://github.com/vedrion
-- Discord: https://discord.gg/DscAtV7r6J

shared_scripts {
    'config.lua',
    -- '@ox_lib/init.lua' -- Only required if using ox_lib
}

client_scripts {
    'client/main.lua',
    'client/utils.lua',
    'client/emote_detection.lua'
}

server_scripts {
    'server/main.lua',
    'server/ratelimit.lua'
}

lua54 'yes'