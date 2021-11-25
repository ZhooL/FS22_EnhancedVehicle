# FS22_EnhancedVehicle
This is a Mod for Farming Simulator 22. It adds a basic "snap driving direction" mode, differential locks, wheel drive modes and improved hydraulics controls to your vehicle. It also shows more vehicle details on the HUD.

**NOTE: The only source of truth is: https://github.com/ZhooL/FS22_EnhancedVehicle. The second valid download location is: (still to be defined). All other download locations are not validated by me - so handle with care.**

**NOTE2: I implemented the "basic snap direction feature" only because no proper GPS/GuidanceSteering is released yet. Feature may be removed if other mods provide this functionality in a better way.**

*(c) 2018-2021 by Majo76 (formerly ZhooL). Be so kind to credit me when using this mod or the source code (or parts of it) somewhere.*  
License: https://creativecommons.org/licenses/by-nc-sa/4.0/

## Default Keybindings
| Key | Action |
| --  | --     |
| <kbd>R Ctrl</kbd>+<kbd>End</kbd> | snap current driving direction |
| <kbd>R Shift</kbd>+<kbd>End</kbd> | snap previous driving direction (=resume old direction)|
| <kbd>R Ctrl</kbd>+<kbd>PageUp</kbd> | increase snap direction by 45° |
| <kbd>R Ctrl</kbd>+<kbd>PageDown</kbd> | decrease snap direction by 45° |
| <kbd>R Shift</kbd>+<kbd>PageUp</kbd> | increase snap direction by 1° |
| <kbd>R Shift</kbd>+<kbd>PageDown</kbd> | decrease snap direction by 1° |
| <kbd>R Ctrl</kbd>+<kbd>R Shift</kbd>+<kbd>PageUp</kbd> | increase snap direction by 22.5° |
| <kbd>R Ctrl</kbd>+<kbd>R Shift</kbd>+<kbd>PageDown</kbd> | decrease snap direction by 22.5° |
| <kbd>R Ctrl</kbd>+<kbd>Num 7</kbd> | enable/disable front axle differential lock |
| <kbd>R Ctrl</kbd>+<kbd>Num 8</kbd> | enable/disable back axle differential lock |
| <kbd>R Ctrl</kbd>+<kbd>Num 9</kbd> | switch wheel drive mode between 4WD (four wheel drive) or 2WD (two wheel drive) |
| <kbd>R Ctrl</kbd>+<kbd>Num /</kbd> | reset mods HUD elements to its default position<br>use this if you messed up the config or changed the GUI scale |
| <kbd>R Ctrl</kbd>+<kbd>Num *</kbd> | reload XML config from disk to show modifications immediately without restarting the complete game |
| <kbd>R Ctrl</kbd>+<kbd>Home</kbd> | toggle damage/fuel display on/off |
| <kbd>L Alt</kbd>+<kbd>1</kbd> | rear attached devices up/down |
| <kbd>L Alt</kbd>+<kbd>2</kbd> | rear attached devices on/off |
| <kbd>L Alt</kbd>+<kbd>3</kbd> | front attached devices up/down |
| <kbd>L Alt</kbd>+<kbd>4</kbd> | front attached devices on/off |

## What this mod does
* When the game starts, it changes all "motorized" and "controllable" vehicles on the map to default settings: wheel drive mode to "all-wheel (4WD)" and deactivation of both differentials.
* Press <kbd>R Ctrl</kbd>+<kbd>End</kbd> to keep your vehicle driving in the current direction.
* On HUD it displays:
  * Damage values in % for controlled vehicle and all its attachments.
  * Fuel fill level for Diesel/AdBlue/Electric/Methane and the current fuel usage rate<sup>1</sup>.
  * The current status of the differential locks and wheel drive mode.
  * The current engine RPM and temperature<sup>1</sup>.
  * The current mass of the vehicle and the total mass<sup>1</sup> of vehicle and all its attachments and loads.
* Keybindings can be changed in the game options menu.

**<sup>1</sup> In multiplayer games, all clients, except the host, won't display the fuel usage rate, engine temperature and mass correctly due to GIANTS Engine fail**

## What this mod doesn't (fully) do
* Work on consoles. Buy a PC for proper gaming.

# The rest
**Make Strohablage great again!**  
* Twitch: https://www.twitch.tv/Majo76__
* Discord: https://d.majo76.de
* Instagram: https://www.instagram.com/Majo76__/
* Twitter: https://www.twitter.com/Majo76_
* HomePage: https://www.majo76.de
* GitHub: https://github.com/ZhooL/FS22_EnhancedVehicle
