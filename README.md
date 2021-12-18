# FS22_EnhancedVehicle
This is a Mod for Farming Simulator 22. It adds a track assistant and a "snap driving direction" feature, differential locks, wheel drive modes and improved hydraulics controls to your vehicle. It also shows more vehicle details on the HUD.

**ATTENTION: Key bindings changed during development. If you can't access a mod function: check your key bindings and rebind the function.**

**WARNING: Work-in-progress. This is a dev version - it might contain bugs. Please report unusual issues.**

**NOTE: The only source of truth is: https://github.com/ZhooL/FS22_EnhancedVehicle. The second valid download location is: https://www.modhoster.de/mods/enhancedvehicle-9a59d5c5-c65c-49ce-a1a9-5681a023381b. All other download locations are not validated by me - so handle with care.**

**NOTE2: I implemented the track assistant only because no proper GPS/GuidanceSteering was released when development started.**

*(c) 2018-2021 by Majo76 (formerly ZhooL). Be so kind to credit me when using this mod or the source code (or parts of it) somewhere.*  
License: https://creativecommons.org/licenses/by-nc-sa/4.0/

## Known bugs
* Probably a lot...

## Default Keybindings
| Key | Action |
| --  | --     |
| <kbd>Ctrl</kbd>+<kbd>Num /</kbd> | opens the config dialog to adjust various settings |
| <kbd>R Ctrl</kbd>+<kbd>End</kbd> | snap to current driving direction or current track |
| <kbd>R Shift</kbd>+<kbd>End</kbd> | snap to previous driving direction or track (=resume old direction)|
| <kbd>R Ctrl</kbd>+<kbd>Home</kbd> | reverse snap/track direction (180°) (= turnover)|
| <kbd>R Shift</kbd>+<kbd>Home</kbd> | turn on/off visualization of driving direction (Helplines/Hilfslinien)|
| <kbd>R Ctrl</kbd>+<kbd>Num 1</kbd> | turn on/off visualization of track layout|
| <kbd>R Ctrl</kbd>+<kbd>Num 2</kbd> | re-calculate track layout (e.g. direction changed or work width changed)|
| <kbd>R Ctrl</kbd>+<kbd>Num 4</kbd> | decrease the number of turnover tracks|
| <kbd>R Ctrl</kbd>+<kbd>Num 6</kbd> | increase the number of turnover tracks|
| <kbd>R Shift</kbd>+<kbd>Num 4</kbd> | move track layout to the left|
| <kbd>R Shift</kbd>+<kbd>Num 6</kbd> | move track layout to the right|
| <kbd>R Ctrl</kbd>+<kbd>Num -</kbd> | move track offset line to the left|
| <kbd>R Ctrl</kbd>+<kbd>Num +</kbd> | move track offset line to the right|
| <kbd>R Ctrl</kbd>+<kbd>PageUp</kbd> | increase snap/track direction by 90° |
| <kbd>R Ctrl</kbd>+<kbd>PageDown</kbd> | decrease snap/track direction by 90° |
| <kbd>R Shift</kbd>+<kbd>PageUp</kbd> | increase snap/track direction by 1° |
| <kbd>R Shift</kbd>+<kbd>PageDown</kbd> | decrease snap/track direction by 1° |
| <kbd>R Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>PageUp</kbd> | increase snap/track direction by 45° |
| <kbd>R Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>PageDown</kbd> | decrease snap/track direction by 45° |
| <kbd>R Ctrl</kbd>+<kbd>Num 7</kbd> | enable/disable front axle differential lock |
| <kbd>R Ctrl</kbd>+<kbd>Num 8</kbd> | enable/disable back axle differential lock |
| <kbd>R Ctrl</kbd>+<kbd>Num 9</kbd> | switch wheel drive mode between 4WD (four wheel drive) or 2WD (two wheel drive) |
| <kbd>L Alt</kbd>+<kbd>1</kbd> | rear attached devices up/down |
| <kbd>L Alt</kbd>+<kbd>2</kbd> | rear attached devices on/off |
| <kbd>L Alt</kbd>+<kbd>3</kbd> | front attached devices up/down |
| <kbd>L Alt</kbd>+<kbd>4</kbd> | front attached devices on/off |

## What this mod does
* When the game starts, it changes all "motorized" and "controllable" vehicles on the map to default settings: wheel drive mode to "all-wheel (4WD)" and deactivation of both differentials.
* Press <kbd>Ctrl</kbd>+<kbd>Numpad /</kbd> to open the config dialog.
* Press <kbd>R Ctrl</kbd>+<kbd>End</kbd> to keep your vehicle driving in the current direction.
  * Press <kbd>R Ctrl</kbd>+<kbd>Home</kbd> to reverse snap direction (useful after turn around at end of field)
* Press <kbd>R Ctrl</kbd>+<kbd>Numpad 1</kbd> to enable the track assistant
  * If you now enable snap mode the vehicle will drive on the current marked track
  * Press <kbd>R Ctrl</kbd>+<kbd>Numpad 4/6</kbd> to adjust the turnover track number (from -5 to 5)
  * Configure headland behavior in configuration menu
* On HUD it displays:
  * (When snap/track is enabled) The current snap to angle and current track and turnover number(
  * Damage values in % for controlled vehicle and all its attachments.
  * Fuel fill level for Diesel/AdBlue/Electric/Methane and the current fuel usage rate<sup>1</sup>.
  * The current status of the differential locks and wheel drive mode.
  * The current engine RPM and temperature<sup>1</sup>.
  * The current mass of the vehicle and the total mass of vehicle and all its attachments and loads.
* Keybindings can be changed in the game options menu.

**<sup>1</sup> In multiplayer games, all clients, except the host, won't display the fuel usage rate and engine temperature correctly due to GIANTS Engine fail**

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
