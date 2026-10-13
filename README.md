# TM Last Epoch Co-op Mod

Version **1.0.7** / protocol **20**, with customized LE HUD **1.0.0**.

## Game directory layout

Copy the original DLL files into these locations, relative to your Last Epoch game folder:

```
<game folder>/
  Update-And-Launch.cmd
  Update-And-Launch.ps1
  Mods/
    LastEpochLAN.dll
    LastEpoch_Hud.dll
  UserLibs/
    LastEpochLAN.Core.dll
```

The repository contains the original DLLs in those directories. They are also available individually from [Release v1.0.7](https://github.com/cielthephantom2/LastEpoch/releases/tag/v1.0.7), without a ZIP or installer.

## Automatic update and launch

Place `Update-And-Launch.cmd` and `Update-And-Launch.ps1` together in the game folder, then double-click the CMD file. It checks the latest stable GitHub Release, downloads only changed mod DLLs, verifies SHA256 and assembly identity/version, backs up previous files, and starts the game in offline mode.

The updater replaces only the three mod DLLs in `Mods/` and `UserLibs/`. It requires internet access and an existing MelonLoader/LE HUD installation. It stops if the game is running, an update fails, or the game build is unsupported. A failed write restores previous DLLs before exiting. Existing saves, player settings and Gift journals are untouched.

Backups are stored in `TM-Coop-Backups/`; download staging and update status are stored in `TM-Coop-Updater/`. No GitHub login is required on a player's PC.

For a launcher stored elsewhere:

```powershell
.\Update-And-Launch.ps1 -GamePath 'D:\SteamLibrary\steamapps\common\Last Epoch'
```

`-NoLaunch` checks/applies updates without starting the game.

## Installation

Requires Last Epoch Steam build 25816319 / Unity 6000.4.8f1, MelonLoader 0.7.3 x64, and LE HUD resources already installed. Close the game before replacing files, and update both Host and Guest.

F4 opens the co-op panel and displays the mod version. F3 opens customized LE HUD settings on the Host.

This repository does not include the game, MelonLoader, saves, player configuration, or Gift journals.

## Status

Development build. Release 1.0.7 fixes stale Guest target identities in native AI/health registries after map travel. Build and 189 managed checks pass, along with an inactive native cleanup fixture. Actual two-PC map travel and post-fix FPS remain unverified.

Customized LE HUD is based on LastEpoch_Hud by Ash.