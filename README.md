# TM Last Epoch Co-op Mod

Offline LAN co-op mod for Last Epoch. Current build: **1.0.7**, protocol **20**, with customized LE HUD **1.0.0**.

Download the mod ZIP from [Releases](https://github.com/cielthephantom2/LastEpoch/releases).

## Installation

Requires Last Epoch Steam build 25816319 / Unity 6000.4.8f1, MelonLoader 0.7.3 x64, and the LE HUD resources already installed.

Close the game, extract the ZIP into its game directory, and update both Host and Guest:

- `Mods/LastEpochLAN.dll`
- `Mods/LastEpoch_Hud.dll`
- `UserLibs/LastEpochLAN.Core.dll`

F4 opens the co-op panel and displays the mod version. F3 opens customized LE HUD settings on the Host.

The download contains only mod DLLs. It does not include the game, MelonLoader, saves, player configuration, or Gift journals.

## Status

Development build. Release 1.0.7 fixes stale Guest target identities in native AI/health registries after map travel. Build and 189 managed checks pass, along with an inactive native cleanup fixture. Actual two-PC map travel and post-fix FPS remain unverified.

Customized LE HUD is based on LastEpoch_Hud by Ash.