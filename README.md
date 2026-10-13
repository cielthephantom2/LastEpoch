# TM Last Epoch Co-op Mod

Version **1.0.7** / protocol **20**, with customized LE HUD **1.0.0**.

## Game directory layout

Copy the original DLL files into these locations, relative to your Last Epoch game folder:

```
<game folder>/
├── Mods/
│   ├── LastEpochLAN.dll
│   └── LastEpoch_Hud.dll
└── UserLibs/
    └── LastEpochLAN.Core.dll
```

The repository contains the original DLLs in those directories. They are also available individually from [Release v1.0.7](https://github.com/cielthephantom2/LastEpoch/releases/tag/v1.0.7), without a ZIP or installer.

## Installation

Requires Last Epoch Steam build 25816319 / Unity 6000.4.8f1, MelonLoader 0.7.3 x64, and LE HUD resources already installed. Close the game before replacing files, and update both Host and Guest.

F4 opens the co-op panel and displays the mod version. F3 opens customized LE HUD settings on the Host.

This repository does not include the game, MelonLoader, saves, player configuration, or Gift journals.

## Status

Development build. Release 1.0.7 fixes stale Guest target identities in native AI/health registries after map travel. Build and 189 managed checks pass, along with an inactive native cleanup fixture. Actual two-PC map travel and post-fix FPS remain unverified.

Customized LE HUD is based on LastEpoch_Hud by Ash.