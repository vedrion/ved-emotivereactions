Config = {}

-- ╔══════════════════════════════════════════════════════╗
-- ║                   General Settings                   ║
-- ╚══════════════════════════════════════════════════════╝

-- Set the minimum level of logs you want to see in the console
Config.LogLevel = 'debug' -- Options: "debug", "info", "none"

--[[ 

 +--------+-----------------------------------------------+
 | Level  | What It Shows                                 |
 +--------+-----------------------------------------------+
 | debug  | Logs detailed information for troubleshooting |
 | info   | Logs only important events                    |
 | none   | Disables all logging                          |
 +--------+-----------------------------------------------+
 Use "debug" for development, "info" or "none" for live servers.

]]

-- Detection mode for emote triggering.
Config.DetectionMode = 'command'

--   'command': Emotes are triggered manually via a command (e.g., /react wave).
--   'loop': Emotes are detected automatically by periodically checking player animations.
--    Note: 'loop' mode may impact performance on servers with many players due to frequent checks.

-- Command name for triggering emotes in 'command' mode.
Config.EmoteCommand = 'react'

-- Example: If set to 'react', use /react wave to trigger the 'wave' emote.
-- Must be a valid command name (lowercase, no spaces).

-- Delay (in seconds) between each NPC reaction when multiple NPCs are reacting.
Config.NPCReactionDelay = 0.5

-- Lower values make reactions feel more simultaneous but may cause performance issues.
-- Recommended range: 0.1 to 1.0 seconds.

-- ╔══════════════════════════════════════════════════════╗
-- ║               Loop Detection Settings                ║
-- ╚══════════════════════════════════════════════════════╝

-- Interval (in ms) for checking player animations in 'loop' mode.
Config.LoopDetectionInterval = 1000

--   Lower values: More frequent checks, faster detection, but higher performance impact.
--   Higher values: Less frequent checks, better performance, but slower detection.
--   Recommended range: 500 to 2000 ms.

-- Minimum cooldown (in seconds) to prevent re-triggering the same animation in 'loop' mode.
Config.MinCooldownForAnimation = 15

-- Should be longer than the animation duration to avoid double triggers.
-- Example: If an animation lasts 10 seconds, set this to at least 11 seconds.

-- Default duration (in ms) for looping animations when 'loopDuration' is set to -1.
Config.DefaultLoopDuration = 10000

-- Used as a fallback for emotes with 'loop = true' and no specific 'loopDuration'.
-- Example: 10000 ms = 10 seconds.

-- Automatically clear animations after they finish playing.
Config.ClearAnimationAfterPlay = true

--   true: Stops the animation after a single play or after the specified loop duration.
--   false: Allows the animation to continue looping indefinitely (not recommended).
--   Note: Set to 'true' to prevent animations from running longer than intended.

-- ╔══════════════════════════════════════════════════════╗
-- ║               Emote Behavior Settings                ║
-- ╚══════════════════════════════════════════════════════╝

-- Global cooldown (in seconds) for emote detection.
Config.GlobalCooldown = 5

-- Prevents players from triggering emotes too quickly, regardless of the emote's cooldown.
-- Recommended range: 3 to 10 seconds.

-- Maximum number of NPCs that can react to a single emote trigger.
Config.MaxNPCs = 2

-- Limits performance impact in crowded areas.
-- Recommended range: 2 to 5 NPCs.

-- Range (in meters) within which NPCs will react to the player's emote.
Config.ReactionRange = 7.0

-- Higher values allow more distant NPCs to react but may feel less realistic.
-- Recommended range: 5.0 to 20.0 meters.

-- Ignore NPCs that are hostile or fleeing.
Config.IgnoreHostile = true

--   true: NPCs in combat or fleeing will not react to emotes.
--   false: All NPCs within range can react, even if hostile.
--   Recommended: Set to 'true' for more realistic behavior.

-- Display mode for NPC reaction text.
Config.TextDisplayMode = 'both'

--[[ 

 +--------+-----------------------------------------------+
 | Option | What It Shows                                 |
 +--------+-----------------------------------------------+
 | 3d     | Displays text above the NPCs head             |
 | chat   | Displays text in the chat window              |
 | both   | Displays text in both 3D and chat             |
 +--------+-----------------------------------------------+

]]

-- Cooldown (in seconds) for NPCs before they can react again.
Config.NPCCooldown = 10

-- Prevents the same NPC from reacting repeatedly in a short time.
-- Recommended range: 5 to 20 seconds.

-- ╔══════════════════════════════════════════════════════╗
-- ║               Notification Settings                  ║
-- ╚══════════════════════════════════════════════════════╝

-- Framework for displaying notifications to players.
Config.NotificationFramework = 'qb' -- Options: 'qb', 'esx', 'oxlib', 'none'

-- ╔══════════════════════════════════════════════════════╗
-- ║                Admin and Rate Limiting               ║
-- ╚══════════════════════════════════════════════════════╝

-- Players with this permission can trigger emotes without rate limit restrictions.
Config.AdminPermission = 'ved.emotivereactions.bypass' -- Permission identifier

--[[ Add this to your server.cfg file (optional):
 +--------+-----------------------------------------------+
 | add_ace group.admin ved.emotivereactions.bypass allow  |
 +--------+-----------------------------------------------+
]]

-- Rate limiting settings to prevent emote spam.
-- Helps maintain server performance by limiting how often players can trigger emotes.
Config.RateLimit = {
    maxEmotes = 5, -- Maximum number of emotes a player can trigger within the reset period.
    resetTime = 60 -- Time (in seconds) before the emote counter resets.
}

-- ╔══════════════════════════════════════════════════════╗
-- ║                  Reaction Zones                      ║
-- ╚══════════════════════════════════════════════════════╝

-- Define areas where NPC reaction chances are modified.
-- Each zone increases or decreases the likelihood of NPCs reacting.
Config.ReactionZones = {
    {
        coords = vector3(0.0, 0.0, 0.0), -- Center coordinates of the zone (x, y, z).
        radius = 50.0, -- Radius of the zone (in meters).
        chanceMultiplier = 1.5 -- Multiplier for NPC reaction chance (e.g., 1.5 = 50% more likely).
    }
    -- Add more zones here
}

-- ╔══════════════════════════════════════════════════════╗
-- ║                  Emote Reactions                     ║
-- ╚══════════════════════════════════════════════════════╝

-- Configuration for emotes and their corresponding NPC reactions.
-- Each emote defines how the player and NPCs animate, reaction chances, and text.
Config.EmoteReactions = {
    wave = {
        playerAnimDict = 'friends@frj@ig_1', -- Animation dictionary for the player's emote.
        playerAnimName = 'wave_a', -- Animation name for the player's emote.
        npcAnimDict = 'friends@frj@ig_1', -- Animation dictionary for the NPC's reaction.
        npcAnimName = 'wave_b', -- Animation name for the NPC's reaction.
        chance = 0.6, -- Chance (0.0 to 1.0) that an NPC will react to this emote.
        facePlayer = true, -- If true, NPC turns to face the player before reacting.
        cooldown = 5, -- Cooldown (in seconds) for this specific emote.
        loop = false, -- If false, the animation plays once and stops.
        loopDuration = -1, -- Duration (in ms) for looping (ignored if loop = false).
        enableReactionText = true, -- If true, NPCs display reaction text; if false, text is disabled.
        reactionTexts = { -- List of reaction texts for NPCs (randomly selected).
            'Hey, nice to see you!',
            'Yo, what\'s up?',
            'Hello there!',
            'That\'s the spirit!',
            'Keep on waving!',
            'Thanks for the love!'
            
            -- Add more reaction texts here
        }
    },
    salute3 = {
        playerAnimDict = 'anim@mp_player_intuppersalute',
        playerAnimName = 'idle_a',
        npcAnimDict = 'anim@mp_player_intuppersalute',
        npcAnimName = 'idle_a',
        chance = 0.3,
        facePlayer = true,
        cooldown = 5,
        loop = true,
        loopDuration = 8000, -- Loops for 8 seconds.
        enableReactionText = true,
        reactionTexts = {
            'Respect!',
            'Salute, soldier!',
            'Salute returned with pride!',
            'Looking sharp, soldier!',
            'Keep showing respect!',
            'Thanks for the salute, buddy!'
        }
    },
    dance = {
        playerAnimDict = 'anim@amb@nightclub@dancers@podium_dancers@',
        playerAnimName = 'hi_dance_facedj_17_v2_male^5',
        npcAnimDict = 'anim@amb@nightclub@dancers@podium_dancers@',
        npcAnimName = 'hi_dance_facedj_17_v2_male^5',
        chance = 0.6,
        facePlayer = true,
        cooldown = 5,
        loop = true,
        loopDuration = -1, -- Uses Config.DefaultLoopDuration
        enableReactionText = false, -- No reaction text for this emote
        reactionTexts = {
            'Dance time!',
            'Dancing to the beat!',
            'Let\'s dance!',
            'Keep on dancing!',
            'Dance, dance, dance!',
            'Life is better in dance shoes!'
        }
    }
}