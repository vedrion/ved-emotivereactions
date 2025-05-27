# Emotive Reactions

A simple and fun script for FiveM servers that lets players trigger emotes, and NPCs react with animations and randomized text replies. Great for making roleplay more interactive and customizable.

## Preview

![Preview](https://imgur.com/U9JNFEy.png)

## Installation

### 1. 📥 Download the Script

Clone or download this repository to your computer.

### 2. 📂 Add to Server Resources

Move the downloaded folder to the `resources` directory of your FiveM server.

### 3. 🛠️ Update `server.cfg`

- Open your `server.cfg` file, located in your server's main directory.
- Add `ensure ved-emotivereactions` to ensure the script starts with your server.

### 4. Admin Permissions (Optional)

Admins can bypass rate limits by assigning the `ved.emotivereactions.bypass` permission via ACE:

--> Add to `server.cfg`:

```fix
add_ace group.admin ved.emotivereactions.bypass allow
```

## 📝 Note

The script is completely standalone but allows optional notification support. To enable it, simply set your preferred framework or notification system in the config file under `Config.NotificationFramework`.

- If you're using ox_lib notifications, make sure to uncomment `@ox_lib/init.lua` in the fxmanifest.lua.

- For custom notification support, go to `client/utils.lua` and add your notification export there.

## Changelog

**Version 1.0.0**

#### **[ Initial Release ]**

## Features

- ✅ Trigger emotes via command (configurable) or automatic loop detection.

- ✅ Built-in rate limiting to prevent spam (admin bypass supported).

- ✅ Includes built-in safety checks to prevent misuse, such as:

  - Ignores hostile or fleeing NPCs

  - Configurable NPC reaction range

  - Global and per-emote cooldowns

  - Limits the number of reacting NPCs

- ✅ Supports looping animations with adjustable durations.

- ✅ Reaction zones to adjust NPC reaction chances.

- ✅ NPCs react with animations and optional text.

- ✅ Emotes are fully customizable with options for:

  - Looping behavior

  - Trigger probability

  - Animation settings

  - Cooldown durations

  - Randomized text responses

  - NPCs face the player during reactions

## Configurations

Everything in this script is fully customizable through the `config.lua` file. I’ve added clear and detailed comments for every setting to make customization easy, even if you have no coding experience. Make sure to check the [config.lua](https://github.com/vedrion/ved-emotivereactions/blob/main/config.lua) file to explore all available options and adjust the script exactly how you want.

## Emote Configuration

To ensure emotes are properly recognized by the script, all emotes must be defined within the `config.lua` file. This configuration enables precise control over which emotes are available to players and allows for easy customization.

- You can add as many emotes as necessary

- Only emotes listed in the config file will be recognized

- Each emote must include a valid animation dictionary and name

- Make sure the animation data matches the format used by your emote system

### Example Emote Configuration

```lua
Config.EmoteReactions = {
    wave = {
        playerAnimDict = 'friends@frj@ig_1',
        playerAnimName = 'wave_a',
        npcAnimDict = 'friends@frj@ig_1',
        npcAnimName = 'wave_b',
        chance = 0.6,
        facePlayer = true,
        cooldown = 5,
        loop = false,
        loopDuration = -1,
        enableReactionText = true,
        reactionTexts = { 'Hello there!', 'Yo, what\'s up?' }
    }
}
```

## Contributing

Feel free to fork this repository and create a pull request for any improvements or features!

## License

This project is licensed under the MIT License.
