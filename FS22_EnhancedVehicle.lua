--
-- Mod: FS22_EnhancedVehicle
--
-- Author: Majo76
-- email: ls22@dark-world.de
-- @Date: 04.01.2022
-- @Version: 1.1.2.0

--[[
CHANGELOG

2022-01-04 - V1.1.2.0
* renamed "Handbremse" to "Feststellbremse"

2022-01-02 - V1.1.1.1
* bugfix working width calculation (again and again...)

2022-01-02 - V1.1.1.0
+ support for Fahrenheit in HUD temperature display
* fixed headland/end of field detection (thx Stephan-S from FS22_AutoDrive)
* small adjustment to steering force (during snap to track)
* bugfix for cruise control issues

2022-01-01 - V1.1.0.0
+ (re)added the parking brake due to high community demand ;-)
+ added option to auto-hide guide lines after x seconds after vehicle follows track
* bugfixes for analog controler input devices (thx "Kotlett")

2021-12-31 - V1.0.1.0
+ added key binding to move vehicle one track to the left/right (in direction of travel; no turning) (rctrl + insert/delete)
+ added config file option to show "spikes" on track lines also
* reworked work width calculation (again). should now detect more attachments.
* changing track layout (position, width, offset) is now much more "smooth" when holding key pressed
* bugfix for display of wrong track numbers when rotating a fake track (thx "Kotlett")

2021-12-30 - V1.0.0.0
+ re-added option to move track and diff HUD elements via config XML
* bugfix for flickering HUD on dedi server when someone switches through vehicles

2021-12-27 - V1.0.0.0-rc5
* bugfix for the HUD being shown in vehicles where it should not be visible

2021-12-27 - V1.0.0.0-rc4
* fixed a rare bug for snap feature not working as expected on dedicated servers (thx "a Bit Brutal")

2021-12-26 - V1.0.0.0-rc3
+ added configuration menu option for "number of visible tracks"
+ added key binding to quickly change headland distance (RShift+Numpad / or RShift+Numpad *)
* bugfix for not being able to steer when globally disabling track assistant when snap to track is enabled
* minor change in calculation of workwidth. should now also work if vehicle and attachments are not aligned in a straight line
* changed default width of "virtual tracks" from 4m to 6m

2021-12-25 - V1.0.0.0-rc2
+ added option to show dmg/fuel above the speedmeter (classic) or on the top-right below the gameinfo panel
* disable follow track when resetting track
* minor modifications on key bindings and actionEvent code

2021-12-23 - V1.0.0.0-rc1
* another bugfix for multiplayer

2021-12-23 - V0.9.9.9
* HUD bugfix for dedicated server

2021-12-23 - V0.9.9.8
* rewritten the complete HUD code. looks better, fits GUI scaling.
+ added key binding to quickly cycle through headland modes
- removed key binding for "resume previous snap direction"

2021-12-20 - V0.9.9.7
+ support to increase/decrease width of calculated tracks
+ added support for "fake" tracks. use this if you have no attachment but want tracks. press rctrl+numpad2 twice.
* bugfix for attachments on attachments
* minor fixes

2021-12-19 - V0.9.9.6
* fixed some logic code bugs
* modified track display above speedometer a bit

2021-12-18 - V0.9.9.5
+ added headland behavior. open configuration menu to configure headland behavior for each vehicle.

2021-12-16 - V0.9.9.4
* display track number even when guide lines are turned off
* changed appearance of track display a bit: #actualtrack -> turnover -> nexttrack
* next track number in game world is rendered in green

2021-12-14 - V0.9.9.3
+ added functionality to move track layout left/right (rctrl+numpad minus/numpad plus)
+ added functionality to move track offset line left/right (rshift+numpad minus/numpad plus)
* smaller bugfixes

2021-12-13 - V0.9.9.2
+ added simple "turn around" feature. (when tracks enabled) press rctrl+home to turn. select amount of tracks to turn left/right by rctrl+num4/num6
+ added a small track number display above the speedometer
+ added a "snap off" sound. Not happy with that yet; it's just the "snap on" sound in reverse
* reworked the complete track handling and display code
* changed default colors: green = active, white = inactive
* small bugfix for negative degree display

2021-12-10 - V0.9.9.1
* fixed track numbers
* improved track handling (can now rotate grid)

2021-12-09 - V0.9.9.0
+ verhicle can now auto steer into the track (press rStrg + End if grid mode is on)

2021-12-07 - V0.9.8.3
* reworked workwidth calculation
+ support for attachments with offset (e.g. plow)

2021-12-06 - V0.9.8.0
+ added grid to visualize tracks (on/off: strg + numpad 1 # recalculate: strg + numpad 2)

2021-12-05 - V0.9.7.0
+ added configuration dialog for mod settings (strg + numpad /)
+ merged "snap to angle" feature to adjust rounding precision
+ merged option to show damage values in "% left" instead of "% damage"
+ added background behind the snap angle display
+ added zoomFactor config variable in XML for zoom of snap angle display
+ added Portuguese translation (thanks to TheChoseOne900)
+ added French translation (thanks to aurelien2023)

2021-11-29 - V0.9.6.0
+ added visualization for snap feature (shift + home)

2021-11-27 - V0.9.5.0
* reworked snap steering behavior

2021-11-26 - V0.9.3.0
* multiplayer fix for snap feature

2021-11-25 - V0.9.2.0
+ added basic "keep current direction" feature

2021-11-25 - V0.9.1.0
* reworked default key bindings

2021-11-25 - V0.9.0.0
* first release for FS22
* !!! WARNING !!! This version of EV has different default key bindings compared to FS19 !!!
* adjusted this and that for FS22 engine changes
+ added fuel support for "electric" and "methane"
- removed all shuttle control related stuff
- removed all "feinstaub" related stuff

license: https://creativecommons.org/licenses/by-nc-sa/4.0/
]]--

local myName = "FS22_EnhancedVehicle"

FS22_EnhancedVehicle = {}
local FS22_EnhancedVehicle_mt = Class(FS22_EnhancedVehicle)

-- #############################################################################

function FS22_EnhancedVehicle:new(mission, modDirectory, modName, i18n, gui, inputManager, messageCenter)
  if debug > 1 then print("-> " .. myName .. ": new ") end

  local self = {}

  setmetatable(self, FS22_EnhancedVehicle_mt)

  self.mission       = mission
  self.modDirectory  = modDirectory
  self.modName       = modName
  self.i18n          = i18n
  self.gui           = gui
  self.inputManager  = inputManager
  self.messageCenter = messageCenter

  local modDesc = loadXMLFile("modDesc", modDirectory .. "modDesc.xml");
  self.version = getXMLString(modDesc, "modDesc.version");

  -- some global stuff - DONT touch
  FS22_EnhancedVehicle.hud = {}
  FS22_EnhancedVehicle.fS = g_currentMission.hud.speedMeter:scalePixelToScreenHeight(12)
  FS22_EnhancedVehicle.sections = { 'fuel', 'dmg', 'misc', 'rpm', 'temp', 'diff', 'track', 'park' }
  FS22_EnhancedVehicle.actions = {}
  FS22_EnhancedVehicle.actions.global =    { 'FS22_EnhancedVehicle_MENU' }
  FS22_EnhancedVehicle.actions.park =      { 'FS22_EnhancedVehicle_PARK',
                                             'FS22_EnhancedVehicle_PARK_ONOFF' }
  FS22_EnhancedVehicle.actions.snap =      { 'FS22_EnhancedVehicle_SNAP_ONOFF',
                                             'FS22_EnhancedVehicle_SNAP_REVERSE',
                                             'FS22_EnhancedVehicle_SNAP_LINES',
                                             'FS22_EnhancedVehicle_SNAP_GRID_ONOFF',
                                             'FS22_EnhancedVehicle_SNAP_GRID_RESET',
                                             'FS22_EnhancedVehicle_SNAP_TRACK',
                                             'FS22_EnhancedVehicle_SNAP_TRACKP',
                                             'FS22_EnhancedVehicle_SNAP_TRACKW',
                                             'FS22_EnhancedVehicle_SNAP_TRACKO',
                                             'FS22_EnhancedVehicle_SNAP_TRACKJ',
                                             'FS22_EnhancedVehicle_SNAP_HL_MODE',
                                             'FS22_EnhancedVehicle_SNAP_HL_DIST',
                                             'FS22_EnhancedVehicle_SNAP_ANGLE1',
                                             'FS22_EnhancedVehicle_SNAP_ANGLE2',
                                             'FS22_EnhancedVehicle_SNAP_ANGLE3',
                                             'AXIS_MOVE_SIDE_VEHICLE' }
  FS22_EnhancedVehicle.actions.diff  =     { 'FS22_EnhancedVehicle_FD',
                                             'FS22_EnhancedVehicle_RD',
                                             'FS22_EnhancedVehicle_BD',
                                             'FS22_EnhancedVehicle_DM' }
  FS22_EnhancedVehicle.actions.hydraulic = { 'FS22_EnhancedVehicle_AJ_REAR_UPDOWN',
                                             'FS22_EnhancedVehicle_AJ_REAR_ONOFF',
                                             'FS22_EnhancedVehicle_AJ_FRONT_UPDOWN',
                                             'FS22_EnhancedVehicle_AJ_FRONT_ONOFF' }

  -- for key press delay
  FS22_EnhancedVehicle.nextActionTime  = 0
  FS22_EnhancedVehicle.deltaActionTime = 500
  FS22_EnhancedVehicle.minActionTime   = 31.25

  -- some colors
  FS22_EnhancedVehicle.color = {
    black    = {       0,       0,       0, 1 },
    white    = {       1,       1,       1, 1 },
    red      = { 255/255,   0/255,   0/255, 1 },
    darkred  = { 128/255,   0/255,   0/255, 1 },
    green    = {   0/255, 255/255,   0/255, 1 },
    blue     = {   0/255,   0/255, 255/255, 1 },
    yellow   = { 255/255, 255/255,   0/255, 1 },
    gray     = { 128/255, 128/255, 128/255, 1 },
    lgray    = { 178/255, 178/255, 178/255, 1 },
    dmg      = { 255/255, 174/255,   0/255, 1 },
    fuel     = { 178/255, 214/255,  22/255, 1 },
    adblue   = {  48/255,  78/255, 249/255, 1 },
    electric = { 255/255, 255/255,   0/255, 1 },
    methane  = {   0/255, 198/255, 255/255, 1 },
    ls22blue = {   0/255, 198/255, 253/255, 1 },
  }

  FS22_EnhancedVehicle.hl_distances = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -12, -14, -16, -18, -20 }

  -- load sound effects
  if g_dedicatedServerInfo == nil then
    local file, id
    FS22_EnhancedVehicle.sounds = {}
    for _, id in ipairs({"diff_lock", "brake", "brakeOn", "brakeOff", "snap_on", "snap_off"}) do
      FS22_EnhancedVehicle.sounds[id] = createSample(id)
      file = self.modDirectory.."resources/"..id..".ogg"
      loadSample(FS22_EnhancedVehicle.sounds[id], file, false)
    end
  end

  return self
end

-- #############################################################################

function FS22_EnhancedVehicle:delete()
  if debug > 1 then print("-> " .. myName .. ": delete ") end

  -- delete our UI
  FS22_EnhancedVehicle.ui_menu:delete()

  -- delete our HUD
  FS22_EnhancedVehicle.ui_hud:delete()
end

-- #############################################################################

function FS22_EnhancedVehicle:onMissionLoaded(mission)
  if debug > 1 then print("-> " .. myName .. ": onMissionLoaded ") end

  g_gui:loadProfiles(self.modDirectory.."ui/guiProfiles.xml")
  FS22_EnhancedVehicle.ui_menu = FS22_EnhancedVehicle_UI.new()
  g_gui:loadGui(self.modDirectory.."ui/FS22_EnhancedVehicle_UI.xml", "FS22_EnhancedVehicle_UI", FS22_EnhancedVehicle.ui_menu)

  FS22_EnhancedVehicle.ui_hud = FS22_EnhancedVehicle_HUD:new(mission.hud.speedMeter, mission.hud.gameInfoDisplay, self.modDirectory)

  FS22_EnhancedVehicle.ui_hud:load()
end

-- #############################################################################

function FS22_EnhancedVehicle:loadMap()
  print("--> loaded FS22_EnhancedVehicle version " .. self.version .. " (by Majo76) <--");

  -- first set our current and default config to default values
  FS22_EnhancedVehicle:resetConfig()
  -- then read values from disk and "overwrite" current config
  lC:readConfig()
  -- then write current config (which is now a merge between default values and from disk)
  lC:writeConfig()
  -- and finally activate current config
  FS22_EnhancedVehicle:activateConfig()
end

-- #############################################################################

function FS22_EnhancedVehicle:unloadMap()
  print("--> unloaded FS22_EnhancedVehicle version " .. self.version .. " (by Majo76) <--");
end

-- #############################################################################

function FS22_EnhancedVehicle.installSpecializations(vehicleTypeManager, specializationManager, modDirectory, modName)
  if debug > 1 then print("-> " .. myName .. ": installSpecializations ") end

  specializationManager:addSpecialization("EnhancedVehicle", "FS22_EnhancedVehicle", Utils.getFilename("FS22_EnhancedVehicle.lua", modDirectory), nil)

  if specializationManager:getSpecializationByName("EnhancedVehicle") == nil then
    print("ERROR: unable to add specialization 'FS22_EnhancedVehicle'")
  else
    for typeName, typeDef in pairs(vehicleTypeManager.types) do
      if SpecializationUtil.hasSpecialization(Drivable,  typeDef.specializations) and
         SpecializationUtil.hasSpecialization(Enterable, typeDef.specializations) and
         SpecializationUtil.hasSpecialization(Motorized, typeDef.specializations) and
         not SpecializationUtil.hasSpecialization(Locomotive,     typeDef.specializations) and
         not SpecializationUtil.hasSpecialization(ConveyorBelt,   typeDef.specializations) and
         not SpecializationUtil.hasSpecialization(AIConveyorBelt, typeDef.specializations)
      then
        if debug > 1 then print("--> attached specialization 'EnhancedVehicle' to vehicleType '" .. tostring(typeName) .. "'") end
        vehicleTypeManager:addSpecialization(typeName, modName..".EnhancedVehicle")
      end
    end
  end
end

-- #############################################################################

function FS22_EnhancedVehicle.prerequisitesPresent(specializations)
  if debug > 1 then print("-> " .. myName .. ": prerequisites ") end

  return true
end

-- #############################################################################

function FS22_EnhancedVehicle.registerEventListeners(vehicleType)
  if debug > 1 then print("-> " .. myName .. ": registerEventListeners ") end

  for _,n in pairs( { "onLoad", "onPostLoad", "saveToXMLFile", "onUpdate", "onDraw", "onReadStream", "onWriteStream", "onRegisterActionEvents", "onEnterVehicle", "onLeaveVehicle", "onPostAttachImplement", "onPostDetachImplement" } ) do
    SpecializationUtil.registerEventListener(vehicleType, n, FS22_EnhancedVehicle)
  end
end

-- #############################################################################
-- ### function for others mods to enable/disable EnhancedVehicle functions
-- ###   name: differential, hydraulic, snap
-- ###  state: true or false

function FS22_EnhancedVehicle:functionEnable(name, state)
  if name == "differential" then
    lC:setConfigValue("global.functions", "diffIsEnabled", state)
    FS22_EnhancedVehicle.functionDiffIsEnabled = state
  end
  if name == "hydraulic" then
    lC:setConfigValue("global.functions", "hydraulicIsEnabled", state)
    FS22_EnhancedVehicle.functionHydraulicIsEnabled = state
  end
  if name == "snap" then
    lC:setConfigValue("global.functions", "snapIsEnabled", state)
    FS22_EnhancedVehicle.functionSnapIsEnabled = state
  end
  if name == "park" then
    lC:setConfigValue("global.functions", "parkingBrakeIsEnabled", state)
    FS22_EnhancedVehicle.functionParkingBrakeIsEnabled = state
  end
end

-- #############################################################################
-- ### function for others mods to get EnhancedVehicle functions status
-- ###   name: differential, hydraulic, snap
-- ###  returns true or false

function FS22_EnhancedVehicle:functionStatus(name)
  if name == "differential" then
    return(lC:getConfigValue("global.functions", "diffIsEnabled"))
  end
  if name == "hydraulic" then
    return(lC:getConfigValue("global.functions", "hydraulicIsEnabled"))
  end
  if name == "snap" then
    return(lC:getConfigValue("global.functions", "snapIsEnabled"))
  end
  if name == "park" then
    return(lC:getConfigValue("global.functions", "parkingBrakeIsEnabled"))
  end

  return(nil)
end

-- #############################################################################

function FS22_EnhancedVehicle:activateConfig()
  -- here we will "move" our config from the libConfig internal storage to the variables we actually use

  -- functions
  FS22_EnhancedVehicle.functionDiffIsEnabled         = lC:getConfigValue("global.functions", "diffIsEnabled")
  FS22_EnhancedVehicle.functionHydraulicIsEnabled    = lC:getConfigValue("global.functions", "hydraulicIsEnabled")
  FS22_EnhancedVehicle.functionSnapIsEnabled         = lC:getConfigValue("global.functions", "snapIsEnabled")
  FS22_EnhancedVehicle.functionParkingBrakeIsEnabled = lC:getConfigValue("global.functions", "parkingBrakeIsEnabled")

  -- globals
  FS22_EnhancedVehicle.showKeysInHelpMenu  = lC:getConfigValue("global.misc", "showKeysInHelpMenu")
  FS22_EnhancedVehicle.soundIsOn           = lC:getConfigValue("global.misc", "soundIsOn")

  -- snap
  FS22_EnhancedVehicle.snap = {}
  FS22_EnhancedVehicle.snap.snapToAngle = lC:getConfigValue("snap", "snapToAngle")
  FS22_EnhancedVehicle.snap.attachmentSpikeHeight = lC:getConfigValue("snap", "attachmentSpikeHeight")
  FS22_EnhancedVehicle.snap.trackSpikeHeight      = lC:getConfigValue("snap", "trackSpikeHeight")
  FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleMiddleLine  = lC:getConfigValue("snap", "distanceAboveGroundVehicleMiddleLine")
  FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine    = lC:getConfigValue("snap", "distanceAboveGroundVehicleSideLine")
  FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine = lC:getConfigValue("snap", "distanceAboveGroundAttachmentSideLine")

  FS22_EnhancedVehicle.snap.colorVehicleMiddleLine  = { lC:getConfigValue("snap.colorVehicleMiddleLine",  "red"), lC:getConfigValue("snap.colorVehicleMiddleLine",  "green"), lC:getConfigValue("snap.colorVehicleMiddleLine",  "blue") }
  FS22_EnhancedVehicle.snap.colorVehicleSideLine    = { lC:getConfigValue("snap.colorVehicleSideLine",    "red"), lC:getConfigValue("snap.colorVehicleSideLine",    "green"), lC:getConfigValue("snap.colorVehicleSideLine",    "blue") }
  FS22_EnhancedVehicle.snap.colorAttachmentSideLine = { lC:getConfigValue("snap.colorAttachmentSideLine", "red"), lC:getConfigValue("snap.colorAttachmentSideLine", "green"), lC:getConfigValue("snap.colorAttachmentSideLine", "blue") }

  -- track
  FS22_EnhancedVehicle.track = {}
  FS22_EnhancedVehicle.track.distanceAboveGround = lC:getConfigValue("track", "distanceAboveGround")
  FS22_EnhancedVehicle.track.numberOfTracks      = lC:getConfigValue("track", "numberOfTracks")
  FS22_EnhancedVehicle.track.hideLines           = lC:getConfigValue("track", "hideLines")
  FS22_EnhancedVehicle.track.hideLinesAfter      = lC:getConfigValue("track", "hideLinesAfter")
  FS22_EnhancedVehicle.track.hideLinesAfterValue = 0
  FS22_EnhancedVehicle.track.color = { lC:getConfigValue("track.color", "red"), lC:getConfigValue("track.color", "green"), lC:getConfigValue("track.color", "blue") }

  -- HUD stuff
  for _, section in pairs(FS22_EnhancedVehicle.sections) do
    FS22_EnhancedVehicle.hud[section] = {}
    FS22_EnhancedVehicle.hud[section].enabled  = lC:getConfigValue("hud."..section, "enabled")
    FS22_EnhancedVehicle.hud[section].fontSize = lC:getConfigValue("hud."..section, "fontSize")
    FS22_EnhancedVehicle.hud[section].offsetX  = lC:getConfigValue("hud."..section, "offsetX")
    FS22_EnhancedVehicle.hud[section].offsetY  = lC:getConfigValue("hud."..section, "offsetY")
  end
  FS22_EnhancedVehicle.hud.dmg.showAmountLeft = lC:getConfigValue("hud.dmg", "showAmountLeft")
  FS22_EnhancedVehicle.hud.dmgfuelPosition = lC:getConfigValue("hud", "dmgfuelPosition")
end

-- #############################################################################

function FS22_EnhancedVehicle:resetConfig(disable)
  if debug > 0 then print("-> " .. myName .. ": resetConfig ") end
  disable = false or disable

  -- start fresh
  lC:clearConfig()

  -- functions
  lC:addConfigValue("global.functions", "diffIsEnabled",         "bool", true)
  lC:addConfigValue("global.functions", "hydraulicIsEnabled",    "bool", true)
  lC:addConfigValue("global.functions", "snapIsEnabled",         "bool", true)
  lC:addConfigValue("global.functions", "parkingBrakeIsEnabled", "bool", true)

  -- globals
  lC:addConfigValue("global.misc", "showKeysInHelpMenu", "bool",   true)
  lC:addConfigValue("global.misc", "soundIsOn", "bool",            true)

  -- snap
  lC:addConfigValue("snap", "snapToAngle", "float", 10.0)
  lC:addConfigValue("snap", "attachmentSpikeHeight", "float", 0.75)
  lC:addConfigValue("snap", "trackSpikeHeight",      "float", 0)
  lC:addConfigValue("snap", "distanceAboveGroundVehicleMiddleLine",  "float", 0.3)
  lC:addConfigValue("snap", "distanceAboveGroundVehicleSideLine",    "float", 0.25)
  lC:addConfigValue("snap", "distanceAboveGroundAttachmentSideLine", "float", 0.20)
  lC:addConfigValue("snap.colorVehicleMiddleLine", "red",    "float", 76/255)
  lC:addConfigValue("snap.colorVehicleMiddleLine", "green",  "float", 76/255)
  lC:addConfigValue("snap.colorVehicleMiddleLine", "blue",   "float", 76/255)
  lC:addConfigValue("snap.colorVehicleSideLine", "red",      "float", 255/255)
  lC:addConfigValue("snap.colorVehicleSideLine", "green",    "float", 0/255)
  lC:addConfigValue("snap.colorVehicleSideLine", "blue",     "float", 0/255)
  lC:addConfigValue("snap.colorAttachmentSideLine", "red",   "float", 100/255)
  lC:addConfigValue("snap.colorAttachmentSideLine", "green", "float", 0/255)
  lC:addConfigValue("snap.colorAttachmentSideLine", "blue",  "float", 0/255)

  -- track
  lC:addConfigValue("track",       "distanceAboveGround", "float", 0.15)
  lC:addConfigValue("track",       "numberOfTracks",      "int",   5)
  lC:addConfigValue("track",       "hideLines",           "bool",  false)
  lC:addConfigValue("track",       "hideLinesAfter",      "int",   5)
  lC:addConfigValue("track.color", "red",                 "float", 255/255)
  lC:addConfigValue("track.color", "green",               "float", 150/255)
  lC:addConfigValue("track.color", "blue",                "float", 0/255)

  -- fuel
  lC:addConfigValue("hud.fuel", "enabled",  "bool", true)
  lC:addConfigValue("hud.fuel", "fontSize", "int",  12)

  -- dmg
  lC:addConfigValue("hud.dmg", "enabled",        "bool", true)
  lC:addConfigValue("hud.dmg", "fontSize",       "int",  12)
  lC:addConfigValue("hud.dmg", "showAmountLeft", "bool", false)

  -- track
  lC:addConfigValue("hud.track", "enabled", "bool", true)
  lC:addConfigValue("hud.track", "offsetX", "int", 0)
  lC:addConfigValue("hud.track", "offsetY", "int", 0)

  -- misc
  lC:addConfigValue("hud.misc", "enabled", "bool", true)

  -- rpm
  lC:addConfigValue("hud.rpm", "enabled", "bool", true)

  -- temp
  lC:addConfigValue("hud.temp", "enabled", "bool", true)

  -- diff
  lC:addConfigValue("hud.diff", "enabled", "bool", true)
  lC:addConfigValue("hud.diff", "offsetX", "int", 0)
  lC:addConfigValue("hud.diff", "offsetY", "int", 0)

  -- park
  lC:addConfigValue("hud.park", "enabled", "bool", true)
  lC:addConfigValue("hud.park", "offsetX", "int", 0)
  lC:addConfigValue("hud.park", "offsetY", "int", 0)

  -- HUD position for dmg/fuel
  lC:addConfigValue("hud", "dmgfuelPosition", "int", 2)
end

-- #############################################################################

function FS22_EnhancedVehicle:onLoad(savegame)
  if debug > 1 then print("-> " .. myName .. ": onLoad" .. mySelf(self)) end

  -- export functions for other mods
  self.functionEnable = FS22_EnhancedVehicle.functionEnable
  self.functionStatus = FS22_EnhancedVehicle.functionStatus
end

-- #############################################################################

function FS22_EnhancedVehicle:onPostLoad(savegame)
  if debug > 1 then print("-> " .. myName .. ": onPostLoad" .. mySelf(self)) end

  -- (server) set defaults when vehicle is "new"
  -- vData
  --   1 - frontDiffIsOn
  --   2 - backDiffIsOn
  --   3 - drive mode
  --   4 - snapAngle
  --   5 - snap.enable
  --   6 - snap on track
  --   7 - track px
  --   8 - track pz
  --   9 - track dX
  --  10 - track dZ
  --  11 - track snapx
  --  12 - track snapz
  --  13 - parking brake on
  --  14 - parking brake function enabled
  if self.isServer then
    if self.vData == nil then
      self.vData = {}
      self.vData.is   = {  true,  true, -1, 1.0,  true,  true, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, true, true }
      self.vData.want = { false, false,  1, 0.0, false, false, 0,   0,   0,   0,   0,   0,   false, false }
      self.vData.torqueRatio   = { 0.5, 0.5, 0.5 }
      self.vData.maxSpeedRatio = { 1.0, 1.0, 1.0 }
      self.vData.rot = 0.0
      self.vData.axisSidePrev = 0.0
      self.vData.snaplines = false
      self.vData.triggerCalculate = false
      self.vData.track = { isVisible = false, isCalculated = false, deltaTrack = 1, headlandMode = 1, headlandDistance = 9999, isOnField = 0 }
      for _, differential in ipairs(self.spec_motorized.differentials) do
        if differential.diffIndex1 == 1 then -- front
          self.vData.torqueRatio[1]   = differential.torqueRatio
          self.vData.maxSpeedRatio[1] = differential.maxSpeedRatio
        end
        if differential.diffIndex1 == 3 then -- back
          self.vData.torqueRatio[2]   = differential.torqueRatio
          self.vData.maxSpeedRatio[2] = differential.maxSpeedRatio
        end
        if differential.diffIndex1 == 0 and differential.diffIndex1IsWheel == false then -- front_to_back
          self.vData.torqueRatio[3]   = differential.torqueRatio
          self.vData.maxSpeedRatio[3] = differential.maxSpeedRatio
        end
      end
      if debug > 0 then print("--> setup of vData done" .. mySelf(self)) end
    end

    -- load vehicle status from savegame
    if savegame ~= nil then
      local xmlFile = savegame.xmlFile
      local key     = savegame.key ..".FS22_EnhancedVehicle.EnhancedVehicle"

      local _data
      for _, _data in pairs( { {1, 'frontDiffIsOn'}, {2, 'backDiffIsOn'}, {3, 'driveMode'}, {13, 'parkingBrakeIsOn'}, {14, 'parkingBrakeIsEnabled'} }) do
        local idx = _data[1]
        local _v
        if idx == 3 then
          _v = getXMLInt(xmlFile.handle, key.."#".. _data[2])
        else
          _v = getXMLBool(xmlFile.handle, key.."#".. _data[2])
        end
        if _v ~= nil then
          if idx == 3 then
            self.vData.is[idx] = -1
            self.vData.want[idx] = _v
            if debug > 1 then print("--> found ".._data[2].."=".._v.." in savegame" .. mySelf(self)) end
          else
            if _v then
              self.vData.is[idx] = false
              self.vData.want[idx] = true
              if debug > 1 then print("--> found ".._data[2].."=true in savegame" .. mySelf(self)) end
            else
              self.vData.is[idx] = true
              self.vData.want[idx] = false
              if debug > 1 then print("--> found ".._data[2].."=false in savegame" .. mySelf(self)) end
            end
          end
        end
      end
    end
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:saveToXMLFile(xmlFile, key)
  if debug > 1 then print("-> " .. myName .. ": saveToXMLFile" .. mySelf(self)) end

  setXMLBool(xmlFile.handle, key.."#frontDiffIsOn",    self.vData.is[1])
  setXMLBool(xmlFile.handle, key.."#backDiffIsOn",     self.vData.is[2])
  setXMLInt(xmlFile.handle,  key.."#driveMode",        self.vData.is[3])
  setXMLBool(xmlFile.handle, key.."#parkingBrakeIsOn",      self.vData.is[13])
  setXMLBool(xmlFile.handle, key.."#parkingBrakeIsEnabled", self.vData.is[14])
end

-- #############################################################################

function FS22_EnhancedVehicle:onReadStream(streamId, connection)
  if debug > 1 then print("-> " .. myName .. ": onReadStream - " .. streamId .. mySelf(self)) end

  if self.vData == nil then
    self.vData      = {}
    self.vData.is   = {}
    self.vData.want = {}
    self.vData.rot  = 0.0
    self.vData.axisSidePrev = 0.0
    self.vData.snaplines = false
    self.vData.triggerCalculate = false
    self.vData.track = { isVisible = false, isCalculated = false, deltaTrack = 1, headlandMode = 1, headlandDistance = 9999, isOnField = 0 }
  end

  -- receive initial data from server
  self.vData.is[1] =  streamReadBool(streamId)    -- front diff
  self.vData.is[2] =  streamReadBool(streamId)    -- back diff
  self.vData.is[3] =  streamReadInt8(streamId)    -- drive mode
  self.vData.is[4] =  streamReadFloat32(streamId) -- snap angle
  self.vData.is[5] =  streamReadBool(streamId)    -- snap.enable
  self.vData.is[6] =  streamReadBool(streamId)    -- snap on track
  self.vData.is[7] =  streamReadFloat32(streamId) -- snap track px
  self.vData.is[8] =  streamReadFloat32(streamId) -- snap track pz
  self.vData.is[9] =  streamReadFloat32(streamId) -- snap track dX
  self.vData.is[10] = streamReadFloat32(streamId) -- snap track dZ
  self.vData.is[11] = streamReadFloat32(streamId) -- snap track snap x
  self.vData.is[12] = streamReadFloat32(streamId) -- snap track snap z
  self.vData.is[13] = streamReadBool(streamId)    -- parking brake on
  self.vData.is[14] = streamReadBool(streamId)    -- parking brake enabled

  if self.isClient then
    self.vData.want = { unpack(self.vData.is) }
  end

--  if debug then print(DebugUtil.printTableRecursively(self.vData, 0, 0, 2)) end
end

-- #############################################################################

function FS22_EnhancedVehicle:onWriteStream(streamId, connection)
  if debug > 1 then print("-> " .. myName .. ": onWriteStream - " .. streamId .. mySelf(self)) end

  -- send initial data to client
  if g_dedicatedServerInfo ~= nil then
    -- when dedicated server then send want array to client cause onUpdate never ran and thus vData "is" is "wrong"
    streamWriteBool(streamId,    self.vData.want[1])
    streamWriteBool(streamId,    self.vData.want[2])
    streamWriteInt8(streamId,    self.vData.want[3])
    streamWriteFloat32(streamId, self.vData.want[4])
    streamWriteBool(streamId,    self.vData.want[5])
    streamWriteBool(streamId,    self.vData.want[6])
    streamWriteFloat32(streamId, self.vData.want[7])
    streamWriteFloat32(streamId, self.vData.want[8])
    streamWriteFloat32(streamId, self.vData.want[9])
    streamWriteFloat32(streamId, self.vData.want[10])
    streamWriteFloat32(streamId, self.vData.want[11])
    streamWriteFloat32(streamId, self.vData.want[12])
    streamWriteBool(streamId,    self.vData.want[13])
    streamWriteBool(streamId,    self.vData.want[14])
  else
    streamWriteBool(streamId,    self.vData.is[1])
    streamWriteBool(streamId,    self.vData.is[2])
    streamWriteInt8(streamId,    self.vData.is[3])
    streamWriteFloat32(streamId, self.vData.is[4])
    streamWriteBool(streamId,    self.vData.is[5])
    streamWriteBool(streamId,    self.vData.is[6])
    streamWriteFloat32(streamId, self.vData.is[7])
    streamWriteFloat32(streamId, self.vData.is[8])
    streamWriteFloat32(streamId, self.vData.is[9])
    streamWriteFloat32(streamId, self.vData.is[10])
    streamWriteFloat32(streamId, self.vData.is[11])
    streamWriteFloat32(streamId, self.vData.is[12])
    streamWriteBool(streamId,    self.vData.is[13])
    streamWriteBool(streamId,    self.vData.is[14])
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onUpdate(dt)
  if debug > 2 then print("-> " .. myName .. ": onUpdate " .. dt .. ", S: " .. tostring(self.isServer) .. ", C: " .. tostring(self.isClient) .. mySelf(self)) end

  if FS22_EnhancedVehicle.functionSnapIsEnabled and self.isClient then
    -- delayed onPostDetach
    if self.vData.triggerCalculate and self.vData.triggerCalculateTime < g_currentMission.time then
      self.vData.triggerCalculate = false

      self.vData.track.isVisibleOld = self.vData.track.isVisible
      self.vData.track.isVisible = false
      FS22_EnhancedVehicle:enumerateImplements(self)
    end

    -- get current vehicle position, direction
    local isControlled = self.getIsControlled ~= nil and self:getIsControlled()
    local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		if isControlled and isEntered then

      -- position, direction, rotation
      self.vData.px, self.vData.py, self.vData.pz = localToWorld(self.rootNode, 0, 0, 0)
      self.vData.dx, self.vData.dy, self.vData.dz = localDirectionToWorld(self.rootNode, 0, 0, 1)
      local length = MathUtil.vector2Length(self.vData.dx, self.vData.dz);
      self.vData.dirX = self.vData.dx / length
      self.vData.dirZ = self.vData.dz / length

      -- calculate current rotation
      local rot = 180 - math.deg(math.atan2(self.vData.dx, self.vData.dz))

      -- if cabin is rotated -> direction should rotate also
      if self.spec_drivable.reverserDirection < 0 then
        rot = rot + 180
        if rot >= 360 then rot = rot - 360 end
      end
      rot = Round(rot, 1)
      if rot >= 360.0 then rot = 0 end
      self.vData.rot = rot

      -- when track assistant is active and calculated
      if self.vData.track.isVisible and self.vData.track.isCalculated then

        -- is a plow attached?
        if self.vData.impl.plow ~= nil then
          if self.vData.impl.plow.rotationMax ~= self.vData.track.plow then
            self.vData.track.plow = self.vData.impl.plow.rotationMax
            self.vData.impl.offset = -self.vData.impl.offset
            self.vData.track.offset = -self.vData.track.offset
            FS22_EnhancedVehicle:updateTrack(self, false, 0, false, 0, true, 0)
          end
        end

        -- headland management
        if self.vData.is[5] and self.vData.is[6] then
          local isOnField = FS22_EnhancedVehicle:getHeadlandInfo(self)
          if self.vData.track.isOnField <= 5 and isOnField then
            if Round(self.vData.rot, 0) == Round(self.vData.is[4], 0) then
              self.vData.track.isOnField = self.vData.track.isOnField + 1
              if debug > 1 then print("Headland: enter field") end
            end
          end
          if self.vData.track.isOnField > 5 and not isOnField then
            self.vData.track.isOnField = 0
            if debug > 1 then print("Headland: left field") end

            -- handle headland
            if self.vData.track.headlandMode <= 1 then
              if debug > 1 then print("Headland: do nothing") end
            elseif self.vData.track.headlandMode == 2 then
              if debug > 1 then print("Headland: turn around") end
              FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_SNAP_REVERSE", 0, 0, 0, 0)
            elseif self.vData.track.headlandMode == 3 then
              if debug > 1 then print("Headland: disable cruise control") end
              if self.spec_drivable ~= nil and self.spec_drivable.cruiseControl ~= nil then
                if self.spec_drivable.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_OFF then
                  self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_OFF)
                  -- update server/clients
--                  if not self.isServer then
--                    g_client:getServerConnection():sendEvent(SetCruiseControlStateEvent.new(self, Drivable.CRUISECONTROL_STATE_OFF))
--                  end
                end
              end
            end
          end
        end -- <- end headland
      end -- <- end track assistant
    end
  end

  -- (server) process changes between "is" and "want"
  if self.isServer and self.vData ~= nil then

    -- snap angle change
    if self.vData.is[4] ~= self.vData.want[4] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed snap angle to: "..self.vData.want[4]) end
      end
      self.vData.is[4] = self.vData.want[4]
    end

    -- snap.enable
    if self.vData.is[5] ~= self.vData.want[5] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if self.vData.want[5] then
          if debug > 0 then print("--> ("..self.rootNode..") changed snap enable to: ON") end
        else
          if debug > 0 then print("--> ("..self.rootNode..") changed snap enable to: OFF") end
        end
      end
      self.vData.is[5] = self.vData.want[5]
    end

    -- snap on track
    if self.vData.is[6] ~= self.vData.want[6] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if self.vData.want[6] then
          if debug > 0 then print("--> ("..self.rootNode..") changed snap on track to: ON") end
        else
          if debug > 0 then print("--> ("..self.rootNode..") changed snap on track to: OFF") end
        end
      end
      self.vData.is[6] = self.vData.want[6]
    end

    -- snap track x
    if self.vData.is[7] ~= self.vData.want[7] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed track px: "..self.vData.want[7]) end
      end
      self.vData.is[7] = self.vData.want[7]
    end

    -- snap track z
    if self.vData.is[8] ~= self.vData.want[8] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed track pz: "..self.vData.want[8]) end
      end
      self.vData.is[8] = self.vData.want[8]
    end

    -- snap track dX
    if self.vData.is[9] ~= self.vData.want[9] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed track dX: "..self.vData.want[9]) end
      end
      self.vData.is[9] = self.vData.want[9]
    end

    -- snap track dZ
    if self.vData.is[10] ~= self.vData.want[10] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed track dZ: "..self.vData.want[10]) end
      end
      self.vData.is[10] = self.vData.want[10]
    end

    -- snap track mpx
    if self.vData.is[11] ~= self.vData.want[11] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed track snap x: "..self.vData.want[11]) end
      end
      self.vData.is[11] = self.vData.want[11]
    end

    -- snap track mpz
    if self.vData.is[12] ~= self.vData.want[12] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed track snap z: "..self.vData.want[12]) end
      end
      self.vData.is[12] = self.vData.want[12]
    end

    -- front diff
    if self.vData.is[1] ~= self.vData.want[1] then
      if FS22_EnhancedVehicle.functionDiffIsEnabled then
        if self.vData.want[1] then
          updateDifferential(self.rootNode, 0, self.vData.torqueRatio[1], 1)
          if debug > 0 then print("--> ("..self.rootNode..") changed front diff to: ON") end
        else
          updateDifferential(self.rootNode, 0, self.vData.torqueRatio[1], self.vData.maxSpeedRatio[1] * 1000)
          if debug > 0 then print("--> ("..self.rootNode..") changed front diff to: OFF") end
        end
      end
      self.vData.is[1] = self.vData.want[1]
    end

    -- back diff
    if self.vData.is[2] ~= self.vData.want[2] then
      if FS22_EnhancedVehicle.functionDiffIsEnabled then
        if self.vData.want[2] then
          updateDifferential(self.rootNode, 1, self.vData.torqueRatio[2], 1)
          if debug > 0 then print("--> ("..self.rootNode..") changed back diff to: ON") end
        else
          updateDifferential(self.rootNode, 1, self.vData.torqueRatio[2], self.vData.maxSpeedRatio[2] * 1000)
          if debug > 0 then print("--> ("..self.rootNode..") changed back diff to: OFF") end
        end
      end
      self.vData.is[2] = self.vData.want[2]
    end

    -- wheel drive mode
    if self.vData.is[3] ~= self.vData.want[3] then
      if FS22_EnhancedVehicle.functionDiffIsEnabled then
        if self.vData.want[3] == 0 then
          updateDifferential(self.rootNode, 2, -0.00001, 1)
          if debug > 0 then print("--> ("..self.rootNode..") changed wheel drive mode to: 2WD") end
        elseif self.vData.want[3] == 1 then
          updateDifferential(self.rootNode, 2, self.vData.torqueRatio[3], 1)
          if debug > 0 then print("--> ("..self.rootNode..") changed wheel drive mode to: 4WD") end
        elseif self.vData.want[3] == 2 then
          updateDifferential(self.rootNode, 2, 1, 0)
          if debug > 0 then print("--> ("..self.rootNode..") changed wheel drive mode to: FWD") end
        end
      end
      self.vData.is[3] = self.vData.want[3]
    end

    -- park brake on
    if self.vData.is[13] ~= self.vData.want[13] then
      if FS22_EnhancedVehicle.functionParkingBrakeIsEnabled then
        if self.vData.want[13] then
          if debug > 0 then print("--> ("..self.rootNode..") changed park on to: ON") end
        else
          if debug > 0 then print("--> ("..self.rootNode..") changed park on to: OFF") end
        end
      end
      self.vData.is[13] = self.vData.want[13]
    end

    -- park brake enabled
    if self.vData.is[14] ~= self.vData.want[14] then
      if FS22_EnhancedVehicle.functionParkingBrakeIsEnabled then
        if self.vData.want[14] then
          if debug > 0 then print("--> ("..self.rootNode..") changed park enable to: ON") end
        else
          if debug > 0 then print("--> ("..self.rootNode..") changed park enable to: OFF") end
        end
      end
      self.vData.is[14] = self.vData.want[14]
    end

  end
end

-- #############################################################################

function FS22_EnhancedVehicle:drawVisualizationLines(_step, _segments, _x, _y, _z, _dX, _dZ, _length, _colorR, _colorG, _colorB, _addY, _spikes, _spikeHeight)
  _spikes = _spikes or false

  -- our draw one line (recursive) function
  if _step >= _segments then return end

  p1 = { x = _x, y = _y, z = _z }
  p2 = { x = p1.x + _dX * _length, y = p1.y, z = p1.z + _dZ * _length }
  p2.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p2.x, 0, p2.z) + _addY
  drawDebugLine(p1.x, p1.y, p1.z, _colorR, _colorG, _colorB, p2.x, p2.y, p2.z, _colorR, _colorG, _colorB)

  if _spikes then
    drawDebugLine(p2.x, p2.y, p2.z, _colorR, _colorG, _colorB, p2.x, p2.y + _spikeHeight, p2.z, _colorR, _colorG, _colorB)
  end

  FS22_EnhancedVehicle:drawVisualizationLines(_step + 1, _segments, p2.x, p2.y, p2.z, _dX, _dZ, _length, _colorR, _colorG, _colorB, _addY, _spikes, _spikeHeight)
end

-- #############################################################################

function FS22_EnhancedVehicle:onDraw()
  if debug > 2 then print("-> " .. myName .. ": onDraw, S: " .. tostring(self.isServer) .. ", C: " .. tostring(self.isClient) .. mySelf(self)) end

  -- only on client side and GUI is visible
  if self.isClient and not g_gui:getIsGuiVisible() and self:getIsControlled() then
    -- update current track
    local dx, dz = 0, 0
    if FS22_EnhancedVehicle.functionSnapIsEnabled and self.vData.track.isCalculated then
      -- calculate track number in direction left-right and forward-backward
      dx, dz = self.vData.px - self.vData.track.origin.px, self.vData.pz - self.vData.track.origin.pz
      -- with original track orientation
      local dotLR = dx * -self.vData.track.origin.originaldZ + dz * self.vData.track.origin.originaldX
      self.vData.track.originalTrackLR = dotLR / self.vData.track.workWidth
    end

    -- guide lines
    if FS22_EnhancedVehicle.functionSnapIsEnabled and self.vData.snaplines then

      -- for debuging headland detection trigger
--      if self.vData.hlx ~= nil and self.vData.hlz ~= nil then
--        FS22_EnhancedVehicle:drawVisualizationLines(1, 2, self.vData.hlx, self.vData.py, self.vData.hlz, 0, 0, 1, (self.vData.isOnField and 1 or 0), (self.vData.isOnField and 1 or 0), 1, 0, true, 5)
--      end

      -- should we hide lines?
      local _showLines = true
      if FS22_EnhancedVehicle.track.hideLines then
        if self.vData.is[5] and g_currentMission.time >= FS22_EnhancedVehicle.track.hideLinesAfterValue then
          _showLines = false
        end
      end

      -- draw helper line in front of vehicle
      if _showLines then
        local p1 = { x = self.vData.px, y = self.vData.py, z = self.vData.pz }
        p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleMiddleLine
        FS22_EnhancedVehicle:drawVisualizationLines(1,
          8,
          p1.x,
          p1.y,
          p1.z,
          self.vData.dirX,
          self.vData.dirZ,
          4,
          FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[1], FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[2], FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[3],
          FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleMiddleLine)
      end

      -- draw attachment helper lines
      if self.vData.impl ~= nil and self.vData.impl.workWidth > 0 and _showLines then

        -- left line beside vehicle
        local p1 = { x = self.vData.px, y = self.vData.py, z = self.vData.pz }
        p1.x = p1.x + (-self.vData.dirZ * self.vData.impl.workWidth / 2) - (-self.vData.dirZ * self.vData.impl.offset)
        p1.z = p1.z + ( self.vData.dirX * self.vData.impl.workWidth / 2) - ( self.vData.dirX * self.vData.impl.offset)
        p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine
        FS22_EnhancedVehicle:drawVisualizationLines(1,
          20,
          p1.x,
          p1.y,
          p1.z,
          self.vData.dirX,
          self.vData.dirZ,
          4,
          FS22_EnhancedVehicle.snap.colorVehicleSideLine[1], FS22_EnhancedVehicle.snap.colorVehicleSideLine[2], FS22_EnhancedVehicle.snap.colorVehicleSideLine[3],
          FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine, (FS22_EnhancedVehicle.snap.attachmentSpikeHeight > 0), FS22_EnhancedVehicle.snap.attachmentSpikeHeight)

        -- right line beside vehicle
        local p1 = { x = self.vData.px, y = self.vData.py, z = self.vData.pz }
        p1.x = p1.x - (-self.vData.dirZ * self.vData.impl.workWidth / 2) - (-self.vData.dirZ * self.vData.impl.offset)
        p1.z = p1.z - ( self.vData.dirX * self.vData.impl.workWidth / 2) - ( self.vData.dirX * self.vData.impl.offset)
        p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine
        FS22_EnhancedVehicle:drawVisualizationLines(1,
          20,
          p1.x,
          p1.y,
          p1.z,
          self.vData.dirX,
          self.vData.dirZ,
          4,
          FS22_EnhancedVehicle.snap.colorVehicleSideLine[1], FS22_EnhancedVehicle.snap.colorVehicleSideLine[2], FS22_EnhancedVehicle.snap.colorVehicleSideLine[3],
          FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine, (FS22_EnhancedVehicle.snap.attachmentSpikeHeight > 0), FS22_EnhancedVehicle.snap.attachmentSpikeHeight)

        -- draw attachment left helper line
        if self.vData.impl.left.marker ~= nil then
          p1.x, p1.y, p1.z = localToWorld(self.vData.impl.left.marker, 0, 0, 0)
          p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine
          local _dx, _, _dz = localDirectionToWorld(self.vData.impl.left.marker, 0, 0, 1)
          local _length = MathUtil.vector2Length(_dx, _dz);
          FS22_EnhancedVehicle:drawVisualizationLines(1,
            4,
            p1.x,
            p1.y,
            p1.z,
            _dx / _length,
            _dz / _length,
            4,
            FS22_EnhancedVehicle.snap.colorAttachmentSideLine[1], FS22_EnhancedVehicle.snap.colorAttachmentSideLine[2], FS22_EnhancedVehicle.snap.colorAttachmentSideLine[3],
            FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine)
        end

        -- draw attachment right helper line
        if self.vData.impl.right.marker ~= nil then
          p1.x, p1.y, p1.z = localToWorld(self.vData.impl.right.marker, 0, 0, 0)
          p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine
          local _dx, _, _dz = localDirectionToWorld(self.vData.impl.right.marker, 0, 0, 1)
          local _length = MathUtil.vector2Length(_dx, _dz);
          FS22_EnhancedVehicle:drawVisualizationLines(1,
            4,
            p1.x,
            p1.y,
            p1.z,
            _dx / _length,
            _dz / _length,
            4,
            FS22_EnhancedVehicle.snap.colorAttachmentSideLine[1], FS22_EnhancedVehicle.snap.colorAttachmentSideLine[2], FS22_EnhancedVehicle.snap.colorAttachmentSideLine[3],
            FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine)
        end
      end

      -- draw our tracks
      if self.vData.track.isVisible and self.vData.track.isCalculated and _showLines then
        -- calculate track number in direction left-right and forward-backward
        -- with current track orientation
        local dotLR = dx * -self.vData.track.origin.dZ + dz * self.vData.track.origin.dX
        local dotFB = dx * -self.vData.track.origin.dX - dz * self.vData.track.origin.dZ
        if math.abs(dotFB - self.vData.track.dotFBPrev) > 0.001 then
          if dotFB > self.vData.track.dotFBPrev then
            dir = -1
          else
            dir = 1
          end
        end
        self.vData.track.dotFBPrev = dotFB  -- we need to save this for detecting forward/backward movement

        -- we're in this track numbers on a global scale
        self.vData.track.trackLR = dotLR / self.vData.track.workWidth
        self.vData.track.trackFB = dotFB / self.vData.track.workWidth

        -- do we move in original grid orientation direction?
        self.vData.track.drivingDir = self.vData.track.trackLR - self.vData.track.originalTrackLR
        if self.vData.track.drivingDir == 0 then self.vData.track.drivingDir = 1 else self.vData.track.drivingDir = -1 end

        -- prepare for rendering
        trackFB = dir * 1.5 + self.vData.track.trackFB
        trackLRMiddle = Round(self.vData.track.trackLR, 0)
        trackLRLanes  = trackLRMiddle - math.floor(1 - FS22_EnhancedVehicle.track.numberOfTracks / 2) + 0.5
        trackLRText   = Round(self.vData.track.originalTrackLR , 0) - math.floor(1 - FS22_EnhancedVehicle.track.numberOfTracks / 2)

        -- draw middle line
        local startX = self.vData.track.origin.px + (-self.vData.track.origin.dZ * (trackLRMiddle * self.vData.track.workWidth)) - ( self.vData.track.origin.dX * (trackFB * self.vData.track.workWidth))
        local startZ = self.vData.track.origin.pz + ( self.vData.track.origin.dX * (trackLRMiddle * self.vData.track.workWidth)) - ( self.vData.track.origin.dZ * (trackFB * self.vData.track.workWidth))
        local startY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, startX, 0, startZ) + FS22_EnhancedVehicle.track.distanceAboveGround
        FS22_EnhancedVehicle:drawVisualizationLines(1,
          12,
          startX,
          startY,
          startZ,
          self.vData.track.origin.dX,
          self.vData.track.origin.dZ,
          self.vData.track.workWidth * dir,
          FS22_EnhancedVehicle.track.color[1] / 2,
          FS22_EnhancedVehicle.track.color[2] / 2,
          FS22_EnhancedVehicle.track.color[3] / 2,
          FS22_EnhancedVehicle.track.distanceAboveGround)

        -- draw offset line
        if self.vData.track.offset > 0.01 or self.vData.track.offset < -0.01 then
          startX = startX + (-self.vData.track.origin.dZ * self.vData.track.offset)
          startZ = startZ + ( self.vData.track.origin.dX * self.vData.track.offset)
          startY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, startX, 0, startZ) + FS22_EnhancedVehicle.track.distanceAboveGround
          FS22_EnhancedVehicle:drawVisualizationLines(1,
            12,
            startX,
            startY,
            startZ,
            self.vData.track.origin.dX,
            self.vData.track.origin.dZ,
            self.vData.track.workWidth * dir,
            0,
            0.75,
            0,
            FS22_EnhancedVehicle.track.distanceAboveGround)
        end

        -- prepare for track numbers
        local activeCamera = self:getActiveCamera()
        local rx, ry, rz = getWorldRotation(activeCamera.cameraNode)
        setTextColor(FS22_EnhancedVehicle.track.color[1], FS22_EnhancedVehicle.track.color[2], FS22_EnhancedVehicle.track.color[3], 1)
        setTextAlignment(RenderText.ALIGN_CENTER)

        -- draw lines
        local _s = math.floor(1 - FS22_EnhancedVehicle.track.numberOfTracks / 2)
        for i = _s, (_s + FS22_EnhancedVehicle.track.numberOfTracks), 1 do
          trackFB = dir * 0.5 + self.vData.track.trackFB
          trackTextFB = trackFB
          segments = 10

          -- middle segment of tracks -> draw longer lines
          if i == 0 or i == 1 then
            trackFB = trackFB + 1.0 * dir
            segments = 12
          end

          -- move track text "backwards"
          if i == 0 then
            trackTextFB = trackTextFB + 1.0 * dir
          end

          -- start coordinates of line
          local startX = self.vData.track.origin.px + (-self.vData.track.origin.dZ * (trackLRLanes * self.vData.track.workWidth)) - ( self.vData.track.origin.dX * (trackFB * self.vData.track.workWidth))
          local startZ = self.vData.track.origin.pz + ( self.vData.track.origin.dX * (trackLRLanes * self.vData.track.workWidth)) - ( self.vData.track.origin.dZ * (trackFB * self.vData.track.workWidth))
          local startY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, startX, 0, startZ) + FS22_EnhancedVehicle.track.distanceAboveGround

          -- draw the line
          FS22_EnhancedVehicle:drawVisualizationLines(1,
            segments,
            startX,
            startY,
            startZ,
            self.vData.track.origin.dX,
            self.vData.track.origin.dZ,
            self.vData.track.workWidth * dir,
            FS22_EnhancedVehicle.track.color[1],
            FS22_EnhancedVehicle.track.color[2],
            FS22_EnhancedVehicle.track.color[3],
            FS22_EnhancedVehicle.track.distanceAboveGround, (FS22_EnhancedVehicle.snap.trackSpikeHeight > 0), FS22_EnhancedVehicle.snap.trackSpikeHeight)

          -- coordinates for track number text
          local textX = self.vData.track.origin.px + (-self.vData.track.origin.originaldZ * (trackLRText * self.vData.track.workWidth)) - ( self.vData.track.origin.dX * (trackTextFB * self.vData.track.workWidth))
          local textZ = self.vData.track.origin.pz + ( self.vData.track.origin.originaldX * (trackLRText * self.vData.track.workWidth)) - ( self.vData.track.origin.dZ * (trackTextFB * self.vData.track.workWidth))
          local textY = 0.1 + getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, textX, 0, textZ) + FS22_EnhancedVehicle.track.distanceAboveGround

          -- render track number
          if i < _s + FS22_EnhancedVehicle.track.numberOfTracks then
            setTextBold(false)
            setTextColor(FS22_EnhancedVehicle.track.color[1], FS22_EnhancedVehicle.track.color[2], FS22_EnhancedVehicle.track.color[3], 1)
            local _curTrack = math.floor(trackLRText)
            if Round(self.vData.track.originalTrackLR, 0) + self.vData.track.deltaTrack == _curTrack then
              setTextBold(true)
              if self.vData.is[5] then
                setTextColor(0, 0.7, 0, 1)
              else
                setTextColor(1, 1, 1, 1)
              end
            end
            renderText3D(textX, textY, textZ, rx, ry, rz, FS22_EnhancedVehicle.fS * Between(self.vData.track.workWidth * 5, 40, 90), tostring(_curTrack))
          end

          -- advance to next lane
          trackLRLanes = trackLRLanes - 1
          trackLRText = trackLRText - 1
        end -- <- end of loop for lines
      end -- <- end of draw tracks
    end -- <- end of snap enabled and lines enabled

    -- unfortunately, have to call the draw HUD this method
    FS22_EnhancedVehicle.ui_hud:setVehicle(self)
    FS22_EnhancedVehicle.ui_hud:drawHUD()

    -- reset text stuff to "defaults"
    setTextColor(1,1,1,1)
    setTextAlignment(RenderText.ALIGN_LEFT)
    setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
    setTextBold(false)
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onEnterVehicle()
  if debug > 1 then print("-> " .. myName .. ": onEnterVehicle" .. mySelf(self)) end

  -- update work width for snap lines
  if self.vData ~= nil and self.vData.snaplines then
    FS22_EnhancedVehicle:enumerateImplements(self)
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onLeaveVehicle()
  if debug > 1 then print("-> " .. myName .. ": onLeaveVehicle" .. mySelf(self)) end

  -- disable snap if you leave a vehicle
  if self.vData.is[5] then
    self.vData.want[5] = false
    self.vData.want[6] = false
    if self.isClient and not self.isServer then
      self.vData.is[5] = self.vData.want[5]
      self.vData.is[6] = self.vData.want[6]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  end

  -- update work width for snap lines
  if self.vData.snaplines then
    FS22_EnhancedVehicle:enumerateImplements(self)
  end

  -- hide some HUD elements
  FS22_EnhancedVehicle.ui_hud:hideSomething(self)
end

-- #############################################################################

function FS22_EnhancedVehicle:onPostAttachImplement(implementIndex)
  if debug > 1 then print("-> " .. myName .. ": onPostAttachImplement" .. mySelf(self)) end

  -- reset virtual track
  if self.vData ~= nil then
    if self.vData.track ~= nil then
      self.vData.track.forceFake = nil
    end
  end

  -- update work width for snap lines
  if self.vData ~= nil and self.vData.snaplines then
    FS22_EnhancedVehicle:enumerateImplements(self)

    -- restore old state
    if self.vData.track.isVisibleOld ~= nil and not self.vData.track.isVisible then
      self.vData.track.isVisible = self.vData.track.isVisibleOld
    end
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onPostDetachImplement(implementIndex)
  if debug > 1 then print("-> " .. myName .. ": onPostDetachImplement" .. mySelf(self)) end

  self.vData.triggerCalculate = false
  if self.vData.snaplines then
    self.vData.triggerCalculate = true
    self.vData.triggerCalculateTime = g_currentMission.time + 1*1000
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onRegisterActionEvents(isSelected, isOnActiveVehicle)
  if debug > 1 then print("-> " .. myName .. ": onRegisterActionEvents " .. tostring(isSelected) .. ", " .. tostring(isOnActiveVehicle) .. ", S: " .. tostring(self.isServer) .. ", C: " .. tostring(self.isClient) .. mySelf(self)) end

  -- continue on client side only
  if not self.isClient then -- or not self:getIsActiveForInput(true, true)
    return
  end

  -- only in active vehicle and when we control it
  if isOnActiveVehicle and self:getIsControlled() then

    -- assemble list of actions to attach
    local actionList = FS22_EnhancedVehicle.actions.global
    for _, v in ipairs(FS22_EnhancedVehicle.actions.snap) do
      table.insert(actionList, v)
    end
    for _, v in ipairs(FS22_EnhancedVehicle.actions.diff) do
      table.insert(actionList, v)
    end
    for _, v in ipairs(FS22_EnhancedVehicle.actions.hydraulic) do
      table.insert(actionList, v)
    end
    for _, v in ipairs(FS22_EnhancedVehicle.actions.park) do
      table.insert(actionList, v)
    end

    -- attach our actions
    for _ ,actionName in pairs(actionList) do
      if actionName == "FS22_EnhancedVehicle_SNAP_TRACKP" or actionName == "FS22_EnhancedVehicle_SNAP_TRACKW" or actionName == "FS22_EnhancedVehicle_SNAP_TRACKO" then
        _, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, FS22_EnhancedVehicle.onActionCall, false, true, true, true)
        _, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, FS22_EnhancedVehicle.onActionCallUp, true, false, false, true)
      else
        _, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, FS22_EnhancedVehicle.onActionCall, false, true, false, true)
      end
      -- help menu priorization
      if g_inputBinding ~= nil and g_inputBinding.events ~= nil and g_inputBinding.events[eventName] ~= nil then
        if actionName == "FS22_EnhancedVehicle_MENU" or
           actionName == "FS22_EnhancedVehicle_PARK" or
           actionName == "FS22_EnhancedVehicle_SNAP_ONOFF" or
           actionName == "FS22_EnhancedVehicle_SNAP_REVERSE" or
           actionName == "FS22_EnhancedVehicle_SNAP_LINES" then
          g_inputBinding.events[eventName].displayPriority = GS_PRIO_VERY_LOW
        else
          g_inputBinding.events[eventName].displayIsVisible = false
          g_inputBinding.events[eventName].displayPriority = GS_PRIO_VERY_LOW
        end
      end
    end
  end

--GS_PRIO_VERY_HIGH = 1
--GS_PRIO_HIGH = 2
--GS_PRIO_NORMAL = 3
--GS_PRIO_LOW = 4
--GS_PRIO_VERY_LOW = 5
end

-- #############################################################################

function FS22_EnhancedVehicle:onActionCallUp(actionName, keyStatus, arg4, arg5, arg6)
  if debug > 1 then print("-> " .. myName .. ": onActionCallUp " .. actionName .. ", keyStatus: " .. keyStatus .. mySelf(self)) end

  -- reset key press delay
  FS22_EnhancedVehicle.nextActionTime  = 0
  FS22_EnhancedVehicle.deltaActionTime = 500
end

-- #############################################################################

function FS22_EnhancedVehicle:onActionCall(actionName, keyStatus, arg4, arg5, arg6)
  if debug > 1 then print("-> " .. myName .. ": onActionCall " .. actionName .. ", keyStatus: " .. keyStatus .. mySelf(self)) end
  if debug > 2 then
    print(arg4)
    print(arg5)
    print(arg6)
  end

  local _snap = false
  -- disable steering angle snap if user interacts
  if actionName == "AXIS_MOVE_SIDE_VEHICLE" and math.abs( keyStatus ) > 0.05 then
    if self.vData.is[5] then
      if FS22_EnhancedVehicle.sounds["snap_off"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
        playSample(FS22_EnhancedVehicle.sounds["snap_off"], 1, 0.1, 0, 0, 0)
      end

      self.vData.want[5] = false
      self.vData.want[6] = false
      _snap = true
    end
  elseif actionName == "FS22_EnhancedVehicle_MENU" then
    -- configuration dialog
    if not self.isClient then
      return
    end

    if self == g_currentMission.controlledVehicle and not g_currentMission.isSynchronizingWithPlayers then
      if not g_gui:getIsGuiVisible() then
        FS22_EnhancedVehicle.ui_menu:setVehicle(self)
        g_gui:showDialog("FS22_EnhancedVehicle_UI")
      end
    end
  elseif FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_FD" then
    -- front diff
    if FS22_EnhancedVehicle.sounds["diff_lock"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["diff_lock"], 1, 0.5, 0, 0, 0)
    end
    self.vData.want[1] = not self.vData.want[1]
    if self.isClient and not self.isServer then
      self.vData.is[1] = self.vData.want[1]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  elseif FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_RD" then
    -- back diff
    if FS22_EnhancedVehicle.sounds["diff_lock"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["diff_lock"], 1, 0.5, 0, 0, 0)
    end
    self.vData.want[2] = not self.vData.want[2]
    if self.isClient and not self.isServer then
      self.vData.is[2] = self.vData.want[2]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  elseif FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_BD" then
    -- both diffs
    if FS22_EnhancedVehicle.sounds["diff_lock"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["diff_lock"], 1, 0.5, 0, 0, 0)
    end
    self.vData.want[1] = not self.vData.want[2]
    self.vData.want[2] = not self.vData.want[2]
    if self.isClient and not self.isServer then
      self.vData.is[1] = self.vData.want[2]
      self.vData.is[2] = self.vData.want[2]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  elseif FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_DM" then
    -- wheel drive mode
    if FS22_EnhancedVehicle.sounds["diff_lock"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["diff_lock"], 1, 0.5, 0, 0, 0)
    end
    self.vData.want[3] = self.vData.want[3] + 1
    if self.vData.want[3] > 1 then
      self.vData.want[3] = 0
    end
    if self.isClient and not self.isServer then
      self.vData.is[3] = self.vData.want[3]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  elseif FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_REAR_UPDOWN" then
    -- rear hydraulic up/down
    FS22_EnhancedVehicle:enumerateAttachments(self)

    -- first the joints itsself
    local _updown = nil
    for _, _v in pairs(joints_back) do
      if _updown == nil then
        _updown = not _v[1].spec_attacherJoints.attacherJoints[_v[2]].moveDown
      end
      _v[1].spec_attacherJoints.setJointMoveDown(_v[1], _v[2], _updown)
      if debug > 1 then print("--> rear up/down: ".._v[1].rootNode.."/".._v[2].."/"..tostring(_updown) ) end
    end

    -- then the attached devices
    for _, object in pairs(implements_back) do
      if object.spec_attachable ~= nil then
        object.spec_attachable.setLoweredAll(object, _updown)
        if debug > 1 then print("--> rear up/down: "..object.rootNode.."/"..tostring(_updown) ) end
      end
    end
  elseif FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_FRONT_UPDOWN" then
    -- front hydraulic up/down
    FS22_EnhancedVehicle:enumerateAttachments(self)

    -- first the joints itsself
    local _updown = nil
    for _, _v in pairs(joints_front) do
      if _updown == nil then
        _updown = not _v[1].spec_attacherJoints.attacherJoints[_v[2]].moveDown
      end
      _v[1].spec_attacherJoints.setJointMoveDown(_v[1], _v[2], _updown)
      if debug > 1 then print("--> front up/down: ".._v[1].rootNode.."/".._v[2].."/"..tostring(_updown) ) end
    end

    -- then the attached devices
    for _, object in pairs(implements_front) do
      if object.spec_attachable ~= nil then
        object.spec_attachable.setLoweredAll(object, _updown)
        if debug > 1 then print("--> front up/down: "..object.rootNode.."/"..tostring(_updown) ) end
      end
    end
  elseif FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_REAR_ONOFF" then
    -- rear hydraulic on/off
    FS22_EnhancedVehicle:enumerateAttachments(self)

    for _, object in pairs(implements_back) do
      -- can it be turned off and on again
      if object.spec_turnOnVehicle ~= nil then
        -- new onoff status
        local _onoff = nil
        if _onoff == nil then
          _onoff = not object.spec_turnOnVehicle.isTurnedOn
        end
        if _onoff and object.spec_turnOnVehicle.requiresMotorTurnOn and self.spec_motorized and not self.spec_motorized:getIsOperating() then
          _onoff = false
        end

        -- set new onoff status
        object.spec_turnOnVehicle.setIsTurnedOn(object, _onoff)
        if debug > 1 then print("--> rear on/off: "..object.rootNode.."/"..tostring(_onoff)) end
      end
    end
  elseif FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_FRONT_ONOFF" then
    -- front hydraulic on/off
    FS22_EnhancedVehicle:enumerateAttachments(self)

    for _, object in pairs(implements_front) do
      -- can it be turned off and on again
      if object.spec_turnOnVehicle ~= nil then
        -- new onoff status
        local _onoff = nil
        if _onoff == nil then
          _onoff = not object.spec_turnOnVehicle.isTurnedOn
        end
        if _onoff and object.spec_turnOnVehicle.requiresMotorTurnOn and self.spec_motorized and not self.spec_motorized:getIsOperating() then
          _onoff = false
        end

        -- set new onoff status
        object.spec_turnOnVehicle.setIsTurnedOn(object, _onoff)

        if debug > 1 then print("--> front on/off: "..object.rootNode.."/"..tostring(_onoff)) end
      end
    end
  elseif actionName == "FS22_EnhancedVehicle_SNAP_LINES" then
    -- toggle snaplines on/off
    self.vData.snaplines = not self.vData.snaplines

    if self.vData.snaplines then
      -- calculate work width
      FS22_EnhancedVehicle:enumerateImplements(self)

      -- auto-hide lines
      if FS22_EnhancedVehicle.track.hideLines then
        FS22_EnhancedVehicle.track.hideLinesAfterValue = g_currentMission.time + 1000 * FS22_EnhancedVehicle.track.hideLinesAfter
      end
    end
  elseif FS22_EnhancedVehicle.functionParkingBrakeIsEnabled and actionName == "FS22_EnhancedVehicle_PARK_ONOFF" then
    if FS22_EnhancedVehicle.sounds["brake"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["brake"], 1, 0.5, 0, 0, 0)
    end
    -- parking brake enable/disable
    self.vData.want[14] = not self.vData.want[14]
    if self.isClient and not self.isServer then
      self.vData.is[14] = self.vData.want[14]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  elseif FS22_EnhancedVehicle.functionParkingBrakeIsEnabled and actionName == "FS22_EnhancedVehicle_PARK" and self.vData.is[14] then
    -- parking brake on/off
    if self.vData.is[13] and FS22_EnhancedVehicle.sounds["brakeOff"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["brakeOff"], 1, 0.1, 0, 0, 0)
    end
    if not self.vData.is[13] and FS22_EnhancedVehicle.sounds["brakeOn"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["brakeOn"], 1, 0.1, 0, 0, 0)
    end
    self.vData.want[13] = not self.vData.want[13]
    if self.isClient and not self.isServer then
      self.vData.is[13] = self.vData.want[13]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  end

  -- snap/track assisstant
  if FS22_EnhancedVehicle.functionSnapIsEnabled then

    -- steering angle snap on/off
    if actionName == "FS22_EnhancedVehicle_SNAP_ONOFF" then
      if not self.vData.is[5] then
        if FS22_EnhancedVehicle.sounds["snap_on"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
          playSample(FS22_EnhancedVehicle.sounds["snap_on"], 1, 0.1, 0, 0, 0)
        end
        self.vData.want[5] = true

        -- auto-hide lines
        if FS22_EnhancedVehicle.track.hideLines then
          FS22_EnhancedVehicle.track.hideLinesAfterValue = g_currentMission.time + 1000 * FS22_EnhancedVehicle.track.hideLinesAfter
        end

        -- calculate snap angle
        local snapToAngle = FS22_EnhancedVehicle.snap.snapToAngle
        if snapToAngle == 0 or snapToAngle == 1 or snapToAngle < 0 or snapToAngle >= 360 then
          snapToAngle = self.vData.rot
        end
        self.vData.want[4] = Round(closestAngle(self.vData.rot, snapToAngle), 0)
        if self.vData.want[4] == 360 then self.vData.want[4] = 0 end

        -- if track is enabled -> set angle to track angle
        if self.vData.track.isVisible and self.vData.track.isCalculated then
          self.vData.want[6] = true

          -- ToDo: optimize this
          local lx,_,lz = localDirectionToWorld(self.rootNode, 0, 0, 1)
          local rot1 = 180 - math.deg(math.atan2(lx, lz))
          if rot1 >= 360 then rot1 = rot1 - 360 end

          -- if cabin is rotated -> direction should rotate also
          if self.spec_drivable.reverserDirection < 0 then
            rot1 = rot1 + 180
            if rot1 >= 360 then rot1 = rot1 - 360 end
          end

          local rot2 = 180 - math.deg(math.atan2(self.vData.track.origin.dX, self.vData.track.origin.dZ))
          if rot2 >= 360 then rot2 = rot2 - 360 end
          local diffdeg = rot1 - rot2
          if diffdeg > 180 then diffdeg = diffdeg - 360 end
          if diffdeg < -180 then diffdeg = diffdeg + 360 end

          -- when facing "backwards" -> flip grid
          if diffdeg < -90 or diffdeg > 90 then
            rot2 = AngleFix(rot2 + 180)
          end
          FS22_EnhancedVehicle:updateTrack(self, true, rot2, false, 0, true, 0, 0)
          self.vData.want[4] = rot2

          -- update headland
          self.vData.track.isOnField = FS22_EnhancedVehicle:getHeadlandInfo(self) and 10 or 0
        end
      else
        if FS22_EnhancedVehicle.sounds["snap_off"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
          playSample(FS22_EnhancedVehicle.sounds["snap_off"], 1, 0.1, 0, 0, 0)
        end
        self.vData.want[5] = false
        self.vData.want[6] = false
      end
      _snap = true
    elseif actionName == "FS22_EnhancedVehicle_SNAP_REVERSE" then
      -- reverse snap
      if FS22_EnhancedVehicle.sounds["snap_on"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
        playSample(FS22_EnhancedVehicle.sounds["snap_on"], 1, 0.1, 0, 0, 0)
      end

      -- turn snap on
      self.vData.want[5] = true

      self.vData.want[4] = Round(self.vData.is[4] + 180, 0)
      if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
      -- if track is enabled -> also rotate track
      if self.vData.track.isVisible and self.vData.track.isCalculated then
        self.vData.want[6] = true
        FS22_EnhancedVehicle:updateTrack(self, true, Angle2ModAngle(self.vData.is[9], self.vData.is[10], 180), false, 0, true, self.vData.track.deltaTrack, 0)

        -- update headland
        self.vData.track.isOnField = FS22_EnhancedVehicle:getHeadlandInfo(self) and 10 or 0
      end
      _snap = true
    elseif actionName == "FS22_EnhancedVehicle_SNAP_ANGLE1" then
      -- 1°
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.is[4] + 1 * (keyStatus >= 0 and 1 or -1), 0)
        if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
        if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
        -- if track is enabled -> also rotate track
        if self.vData.track.isVisible and self.vData.track.isCalculated then
          FS22_EnhancedVehicle:updateTrack(self, true, Angle2ModAngle(self.vData.is[9], self.vData.is[10], 1 * (keyStatus >= 0 and 1 or -1)), true, 0, true, 0, 0)
        end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_ANGLE2" then
    -- 45°
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.is[4] + 45 * (keyStatus >= 0 and 1 or -1), 0)
        if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
        if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
        -- if track is enabled -> also rotate track
        if self.vData.track.isVisible and self.vData.track.isCalculated then
          FS22_EnhancedVehicle:updateTrack(self, true, Angle2ModAngle(self.vData.is[9], self.vData.is[10], 45 * (keyStatus >= 0 and 1 or -1)), true, 0, true, 0, 0)
        end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_ANGLE3" then
      -- 90°
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.is[4] + 90 * (keyStatus >= 0 and 1 or -1), 0)
        if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
        if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
        -- if track is enabled -> also rotate track
        if self.vData.track.isVisible and self.vData.track.isCalculated then
          FS22_EnhancedVehicle:updateTrack(self, true, Angle2ModAngle(self.vData.is[9], self.vData.is[10], 90 * (keyStatus >= 0 and 1 or -1)), true, 0, true, 0, 0)
        end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_TRACK" then
      -- delta track
      if self.vData.track.isVisible and self.vData.track.isCalculated then
        self.vData.track.deltaTrack = Between(self.vData.track.deltaTrack + (keyStatus >= 0 and 1 or -1), -5, 5)
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_TRACKP" then
    -- track position
      if self.vData.track.isVisible and self.vData.track.isCalculated then
        if g_currentMission.time > FS22_EnhancedVehicle.nextActionTime then
          FS22_EnhancedVehicle.nextActionTime = g_currentMission.time + FS22_EnhancedVehicle.deltaActionTime
          if FS22_EnhancedVehicle.deltaActionTime >= FS22_EnhancedVehicle.minActionTime then FS22_EnhancedVehicle.deltaActionTime = FS22_EnhancedVehicle.deltaActionTime * 0.5 end
          FS22_EnhancedVehicle:updateTrack(self, false, -1, false, 0.1 * (keyStatus >= 0 and 1 or -1), true, 0, 0)
        end
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_TRACKW" then
    -- track width
      if self.vData.track.isVisible and self.vData.track.isCalculated then
        if g_currentMission.time > FS22_EnhancedVehicle.nextActionTime then
          FS22_EnhancedVehicle.nextActionTime = g_currentMission.time + FS22_EnhancedVehicle.deltaActionTime
          if FS22_EnhancedVehicle.deltaActionTime >= FS22_EnhancedVehicle.minActionTime then FS22_EnhancedVehicle.deltaActionTime = FS22_EnhancedVehicle.deltaActionTime * 0.5 end
          FS22_EnhancedVehicle:updateTrack(self, false, -1, false, 0, false, 0, 0, 0.1 * (keyStatus >= 0 and 1 or -1))
        end
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_TRACKO" then
    -- track offset
      if self.vData.track.isVisible and self.vData.track.isCalculated then
        if g_currentMission.time > FS22_EnhancedVehicle.nextActionTime then
          FS22_EnhancedVehicle.nextActionTime = g_currentMission.time + FS22_EnhancedVehicle.deltaActionTime
          if FS22_EnhancedVehicle.deltaActionTime >= FS22_EnhancedVehicle.minActionTime then FS22_EnhancedVehicle.deltaActionTime = FS22_EnhancedVehicle.deltaActionTime * 0.5 end
          FS22_EnhancedVehicle:updateTrack(self, false, -1, false, 0, false, 0, 0.05 * (keyStatus >= 0 and 1 or -1))
        end
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_TRACKJ" then
    -- track jump
      if self.vData.is[5] and self.vData.is[6] then
        if self.vData.track.isVisible and self.vData.track.isCalculated and self.vData.is[5] and self.vData.track.drivingDir ~= nil then
          FS22_EnhancedVehicle:updateTrack(self, false, -1, false, 0, true, 1 * (keyStatus >= 0 and 1 or -1) * self.vData.track.drivingDir, 0)
        end
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_GRID_ONOFF" then
    -- track display on/off
      self.vData.track.isVisible = not self.vData.track.isVisible

      -- if we turn on track we must also switch lines on
      if self.vData.track.isVisible then
        self.vData.snaplines = true

        if not self.vData.track.isCalculated then
          if not FS22_EnhancedVehicle:calculateTrack(self) then
            self.vData.track.isVisible = false
          end
        end
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_GRID_RESET" then
      -- recalculate track
      if not FS22_EnhancedVehicle:calculateTrack(self) then
        _snap = true
      end

      -- turn on track visibility
      if not self.vData.track.isVisible then
        self.vData.track.isVisible = true
        self.vData.snaplines = true
      end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_HL_MODE" and self.vData.track.headlandMode ~= nil and self.vData.track.isCalculated then
      -- headland mode
      self.vData.track.headlandMode = self.vData.track.headlandMode + 1
      if self.vData.track.headlandMode > 3 then self.vData.track.headlandMode = 1 end
    elseif actionName == "FS22_EnhancedVehicle_SNAP_HL_DIST" and self.vData.track.headlandDistance ~= nil and self.vData.track.isCalculated then
      -- headland distance
      local _state = 0
      if self.vData.track.headlandDistance ~= 9999 then
        local _i = 1
        for _, d in pairs(FS22_EnhancedVehicle.hl_distances) do
          if self.vData.track.headlandDistance == d then
            _state = _i
          end
          _i = _i + 1
        end
      end
      _state = _state + (keyStatus >= 0 and 1 or -1)
      if _state > #FS22_EnhancedVehicle.hl_distances then _state = 0 end
      if _state < 0 then _state = #FS22_EnhancedVehicle.hl_distances end
      self.vData.track.headlandDistance = FS22_EnhancedVehicle.hl_distances[_state]
      if _state == 0 then self.vData.track.headlandDistance = 9999 end
    end
  end

  -- update client-server
  if _snap then
    if self.isClient and not self.isServer then
      self.vData.is[4] = self.vData.want[4]
      self.vData.is[5] = self.vData.want[5]
      self.vData.is[6] = self.vData.want[6]
      self.vData.is[7] = self.vData.want[7]
      self.vData.is[8] = self.vData.want[8]
      self.vData.is[9] = self.vData.want[9]
      self.vData.is[10] = self.vData.want[10]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:getHeadlandInfo(self)
  local distance = self.vData.track.headlandDistance
  if distance == 9999 and self.vData.track.workWidth ~= nil then
    distance = self.vData.track.workWidth
  end

  local isOnField = true
  -- look ahead/behind
  local x = self.vData.px + (self.vData.dirX * distance)
  local z = self.vData.pz + (self.vData.dirZ * distance)
  local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)

  local groundTypeMapId, groundTypeFirstChannel, groundTypeNumChannels = g_currentMission.fieldGroundSystem:getDensityMapData(FieldDensityMap.GROUND_TYPE)
  local _density = getDensityAtWorldPos(groundTypeMapId, x, y, z)
  local _densityType = bitAND(bitShiftRight(_density, groundTypeFirstChannel), 2^groundTypeNumChannels - 1)
  isOnField = isOnField and (_densityType ~= g_currentMission.grassValue and _densityType ~= 0)

  -- for debugging
--  self.vData.hlx = x
--  self.vData.hlz = z
--  self.vData.isOnField = isOnField

  return(isOnField)
end

-- #############################################################################
-- # this function updates the track layout
-- # updateAngle true -> update track direction
-- # updateAngleValue = -1 -> current vehicle angle is used
-- # updatePosition true -> use current vehicle position as new track origin
-- # updateSnap true -> update the snap to track position

function FS22_EnhancedVehicle:updateTrack(self, updateAngle, updateAngleValue, updatePosition, deltaPosition, updateSnap, deltaTrack, deltaOffset, deltaWorkWidth)
  if debug > 1 then print("-> " .. myName .. ": updateTrack" .. mySelf(self)) end

  -- defaults
  if updateAngle == nil then
    updateAngle = true
    updateAngleValue = -1
  end
  if updatePosition == nil then updatePosition = true end
  if deltaPosition == nil  then deltaPosition = 0 end
  if updateSnap == nil     then updateSnap = false end
  if deltaTrack == nil     then deltaTrack = 0 end
  if deltaOffset == nil    then deltaOffset = 0 end
  if deltaWorkWidth == nil then deltaWorkWidth = 0 end

  -- only if there is valid implement data
  if self.vData.impl.workWidth > 0 or self.vData.track.forceFake or self.vData.track.isCalculated then
    if self.vData.track.workWidth == nil then
      if self.vData.track.forceFake then
        self.vData.track.workWidth = 6
        self.vData.impl.left.px = 3
      else
        self.vData.track.workWidth = self.vData.impl.workWidth
      end
    end
    if self.vData.track.offset == nil then
      if self.vData.track.forceFake then
        self.vData.track.offset = 0
      else
        self.vData.track.offset = self.vData.impl.offset
      end
    end

    if self.vData.track.offset < (-self.vData.track.workWidth / 2) then self.vData.track.offset = self.vData.track.offset + (self.vData.track.workWidth) end
    if self.vData.track.offset > ( self.vData.track.workWidth / 2) then self.vData.track.offset = self.vData.track.offset - (self.vData.track.workWidth) end

    local _broadcastUpdate = false

    -- shall we update the track direction?
    if updateAngle then
      -- if no angle provided -> use current vehicle rotation
      local _rot = 0
      if updateAngleValue == -1 then
        local _length = MathUtil.vector2Length(self.vData.dx, self.vData.dz);
        local _dX = self.vData.dx / _length
        local _dZ = self.vData.dz / _length
        _rot = 180 - math.deg(math.atan2(_dX, _dZ))

        -- if cabin is rotated -> angle should rotate also
        if self.spec_drivable.reverserDirection < 0 then
          _rot = AngleFix(_rot + 180)
        end
        _rot = Round(_rot, 1)

        -- smoothen track angle to snapToAngle
        local snapToAngle = FS22_EnhancedVehicle.snap.snapToAngle
        if snapToAngle <= 1 or snapToAngle >= 360 then
          snapToAngle = _rot
        end
        _rot = Round(closestAngle(_rot, snapToAngle), 0)
      else -- use provided angle
        _rot = updateAngleValue
      end

      -- track direction vector
      self.vData.track.origin.dX =  math.sin(math.rad(_rot))
      self.vData.track.origin.dZ = -math.cos(math.rad(_rot))
      self.vData.track.origin.rot = _rot

      -- send new direction to server
      self.vData.want[9]  = self.vData.track.origin.dX
      self.vData.want[10] = self.vData.track.origin.dZ
      _broadcastUpdate = true
    end

    -- shall we update the track position?
    if updatePosition then
      -- use middle between left and right marker of implement as track origin position
      if self.vData.track.forceFake then
        self.vData.track.origin.px = self.vData.px
        self.vData.track.origin.pz = self.vData.pz
      else
        self.vData.track.origin.px = self.vData.px - (-self.vData.track.origin.dZ * self.vData.impl.left.px) + (-self.vData.track.origin.dZ * (self.vData.track.workWidth / 2))
        self.vData.track.origin.pz = self.vData.pz - ( self.vData.track.origin.dX * self.vData.impl.left.px) + ( self.vData.track.origin.dX * (self.vData.track.workWidth / 2))
      end

      -- save original orientation
      self.vData.track.origin.originaldX = self.vData.track.origin.dX
      self.vData.track.origin.originaldZ = self.vData.track.origin.dZ

      -- send new position to server
      self.vData.want[7]  = self.vData.track.origin.px
      self.vData.want[8]  = self.vData.track.origin.pz
      _broadcastUpdate = true
    end

    -- should we move the track
    if deltaPosition ~= 0 then
      self.vData.track.origin.px = self.vData.track.origin.px + (-self.vData.track.origin.dZ * deltaPosition)
      self.vData.track.origin.pz = self.vData.track.origin.pz + ( self.vData.track.origin.dX * deltaPosition)

      -- send new position to server
      self.vData.want[7]  = self.vData.track.origin.px
      self.vData.want[8]  = self.vData.track.origin.pz
      _broadcastUpdate = true
      updateSnap = true
    end

    -- should we move the offset
    if deltaOffset ~= 0 then
      self.vData.track.offset = self.vData.track.offset + deltaOffset
      updateSnap = true
    end

    -- should we change size of track
    if deltaWorkWidth ~= 0 then
      self.vData.track.workWidth = Between(self.vData.track.workWidth + deltaWorkWidth, 0.1, 100)
      updateSnap = true
    end

    -- shall we update the snap position?
    if updateSnap then
      local dx, dz = self.vData.px - self.vData.track.origin.px, self.vData.pz - self.vData.track.origin.pz

      -- calculate dot in direction left-right and forward-backward
      local dotLR = dx * -self.vData.track.origin.originaldZ + dz * self.vData.track.origin.originaldX
      local trackLR2 = Round(dotLR / self.vData.track.workWidth, 0)
      local dotLR = dx * -self.vData.track.origin.dZ + dz * self.vData.track.origin.dX
      local dotFB = dx * -self.vData.track.origin.dX - dz * self.vData.track.origin.dZ
      local trackLR = Round(dotLR / self.vData.track.workWidth, 0)

      -- do we move in original grid oriontation direction?
      local _drivingDir = trackLR - trackLR2
      if _drivingDir == 0 then _drivingDir = 1 else _drivingDir = -1 end

      -- new destination track
      trackLR2 = trackLR2 + deltaTrack

      -- snap position
      self.vData.track.origin.snapx = self.vData.track.origin.px + (-self.vData.track.origin.originaldZ * (trackLR2 * self.vData.track.workWidth)) - ( self.vData.track.origin.dX * dotFB) + (-self.vData.track.origin.dZ * self.vData.track.offset)
      self.vData.track.origin.snapz = self.vData.track.origin.pz + ( self.vData.track.origin.originaldX * (trackLR2 * self.vData.track.workWidth)) - ( self.vData.track.origin.dZ * dotFB) + ( self.vData.track.origin.dX * self.vData.track.offset)

      -- send new snap position to server
      self.vData.want[11]  = self.vData.track.origin.snapx
      self.vData.want[12]  = self.vData.track.origin.snapz
      if self.vData.is[5] then
        self.vData.want[6]   = true
      end
      _broadcastUpdate = true
    end

    -- broadcast to server/everyone
    if _broadcastUpdate then
      if self.isClient and not self.isServer then
        self.vData.is[6]  = self.vData.want[6]
        self.vData.is[7]  = self.vData.want[7]
        self.vData.is[8]  = self.vData.want[8]
        self.vData.is[9]  = self.vData.want[9]
        self.vData.is[10] = self.vData.want[10]
        self.vData.is[11] = self.vData.want[11]
        self.vData.is[12] = self.vData.want[12]
      end
      FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
    end

    self.vData.track.isCalculated = true

    if debug > 1 then print("Origin position: ("..self.vData.track.origin.px.."/"..self.vData.track.origin.pz..") / Origin direction: ("..self.vData.track.origin.dX.."/"..self.vData.track.origin.dZ..") / Snap position: ("..self.vData.track.origin.snapx.."/"..self.vData.track.origin.snapz..") / Rotation: "..self.vData.track.origin.rot.." / Offset: "..self.vData.track.offset) end
    if debug > 2 then print_r(self.vData.track) end

    return true
  end

  return false
end

-- #############################################################################
-- # this function calculates a fresh track layout

function FS22_EnhancedVehicle:calculateTrack(self)
  if debug > 1 then print("-> " .. myName .. ": calculateTrack" .. mySelf(self)) end

  -- reset/delete all tracks data
  self.vData.track.origin       = {}
  self.vData.track.isCalculated = false
  self.vData.track.dotFBPrev    = 99999999
  self.vData.track.offset       = nil
  self.vData.track.workWidth    = nil

  -- first, we need information about implements
  FS22_EnhancedVehicle:enumerateImplements(self)

  -- then we update the tracks with "current" angle and new origin
  if not FS22_EnhancedVehicle:updateTrack(self, true, -1, true, 0, true, 0) then
    if self.vData.track.forceFake == nil then
      g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNoImplement2"), 4000)
      self.vData.track.forceFake = true
      self.vData.track.isCalculated = false
      self.vData.want[6] = false
    else
      g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNoImplement"), 4000)
    end
    return false
  end

  self.vData.track.forceFake = nil
  return true
end

-- #############################################################################
-- # this function builds a table of all attachments/implements with working area(s)
-- # the table contains:
-- #  - working width of the working area
-- #  - left/right position (local) of the working area
-- #  - offset of the working area relative to the vehicle

function FS22_EnhancedVehicle:enumerateImplements(self)
  if debug > 1 then print("-> " .. myName .. ": enumerateImplements" .. mySelf(self)) end

  -- build list of attachments
  listOfObjects = {}
  FS22_EnhancedVehicle:enumerateImplements2(self)

  -- add our own vehicle
  if (self.spec_workArea ~= nil) then
    table.insert(listOfObjects, self)
  end

  -- new array and some defaults
  self.vData.impl = { workWidth = 0, offset = 0, left = { px = -99999999, marker = nil }, right = { px = 99999999, marker = nil }, plow = nil }

  -- now we go through the list and fetch relevant data
  local _width1, _width2 = 0, 0
  local _min1, _max1 = -99999999, 99999999
  local _min2, _max2 = -99999999, 99999999
  for _, obj in pairs(listOfObjects) do

    -- for objects with AImarkers
    local leftMarker, rightMarker = obj:getAIMarkers()
    if leftMarker ~= nil and rightMarker ~= nil then
      local _lx, _, _ = localToLocal(leftMarker,  obj.rootNode, 0, 0, 0)
      local _rx, _, _ = localToLocal(rightMarker, obj.rootNode, 0, 0, 0)
      if debug > 1 then print(obj.typeName..", lx: ".._lx..", rx: ".._rx) end
      if _lx > _min2 then
        _min2 = _lx
        self.vData.impl.left.marker = leftMarker
      end
      if _rx < _max2 then
        _max2 = _rx
        self.vData.impl.right.marker = rightMarker
      end

      -- working width
      _width2 = math.abs(_min2 - _max2)
      if debug > 1 then print("width 2: ".._width2) end

      -- if it is a plow -> save plow rotation
      if obj.typeName == "plow" or obj.typeName == "plowPacker" then
        self.vData.impl.plow = obj.spec_plow
        self.vData.track.plow = self.vData.impl.plow.rotationMax
      end
    else
      -- for objects without AIMarkers
      local _found = false
      for _, workArea in pairs(obj.spec_workArea.workAreas) do
        if workArea.functionName ~= nil then
          if workArea.functionName == "processRidgeMarkerArea" or workArea.functionName == "processCombineSwathArea" or workArea.functionName == "processCombineChopperArea" then
            if debug > 1 then print("skip") end
            goto continue
          end
        end
        local _x1 = localToLocal(workArea.start, obj.rootNode, 0, 0, 0)
        local _x2 = localToLocal(workArea.width, obj.rootNode, 0, 0, 0)

        if debug > 1 then print(obj.typeName..", "..workArea.type..", x1: ".._x1..", x2: ".._x2) end
        _min1 = math.max(_min1, _x1)
        _min1 = math.max(_min1, _x2)
        _max1 = math.min(_max1, _x1)
        _max1 = math.min(_max1, _x2)
        _found = true
        ::continue::
      end
      if _found then
        _width1 = _min1 + math.abs(_max1)
        if debug > 1 then print("width 1: ".._width1) end
      end
    end

    -- working width
    if _width1 > self.vData.impl.workWidth then
      self.vData.impl.workWidth = Round(_width1, 4)
      self.vData.impl.left.px = _min1
      self.vData.impl.right.px = _max1
    end
    if _width2 > self.vData.impl.workWidth then
      self.vData.impl.workWidth = Round(_width2, 4)
      self.vData.impl.left.px = _min2
      self.vData.impl.right.px = _max2
    end
    if debug > 1 then print("final width: "..self.vData.impl.workWidth) end

    -- offset
    self.vData.impl.offset = Round((self.vData.impl.left.px + self.vData.impl.right.px) * 0.5, 4)
    if self.vData.impl.offset > -0.1 and self.vData.impl.offset < 0.1 then self.vData.impl.offset = 0 end

    if debug > 1 then print("-> Type: "..obj.typeName..", Width: "..self.vData.impl.workWidth..", Offset: "..self.vData.impl.offset) end
  end

  if debug > 1 then print("--> Width: "..self.vData.impl.workWidth..", Offset: "..self.vData.impl.offset) end
  if debug > 1 then print(DebugUtil.printTableRecursively(self.vData.impl, 0, 0, 1)) end
end

-- #############################################################################

function FS22_EnhancedVehicle:enumerateImplements2(self)
  if debug > 1 then print("-> " .. myName .. ": enumerateImplements2" .. mySelf(self)) end

  local attachedImplements = nil

  -- are there attachments?
  if self.getAttachedImplements ~= nil then
    attachedImplements = self:getAttachedImplements()
  end
  if attachedImplements ~= nil then
    -- go through all attached implements
    for _, implement in pairs(attachedImplements) do
      -- if implement has a work area -> add to list
      if implement.object ~= nil and implement.object.spec_workArea ~= nil then
        table.insert(listOfObjects, implement.object)
      end

      -- recursive dive into more attachments
      if implement.object.getAttachedImplements ~= nil then
        FS22_EnhancedVehicle:enumerateImplements2(implement.object)
      end
    end
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:enumerateAttachments2(rootNode, obj)
  if debug > 1 then print("entering: "..obj.rootNode) end

  local idx, attacherJoint
  local relX, relY, relZ

  if obj.spec_attacherJoints == nil then return end

  for idx, attacherJoint in pairs(obj.spec_attacherJoints.attacherJoints) do
    -- position relative to our vehicle
    local x, y, z = getWorldTranslation(attacherJoint.jointTransform)
    relX, relY, relZ = worldToLocal(rootNode, x, y, z)
    -- when it can be moved up and down ->
    if attacherJoint.allowsLowering then
      if relZ > 0 then -- front
        table.insert(joints_front, { obj, idx })
      end
      if relZ < 0 then -- back
        table.insert(joints_back, { obj, idx })
      end
      if debug > 2 then print(obj.rootNode.."/"..idx.." x: "..tostring(x)..", y: "..tostring(y)..", z: "..tostring(z)) end
      if debug > 2 then print(obj.rootNode.."/"..idx.." x: "..tostring(relX)..", y: "..tostring(relY)..", z: "..tostring(relZ)) end
    end

    -- what is attached here?
    local implement = obj.spec_attacherJoints:getImplementByJointDescIndex(idx)
    if implement ~= nil and implement.object ~= nil then
      if relZ > 0 then -- front
        table.insert(implements_front, implement.object)
      end
      if relZ < 0 then -- back
        table.insert(implements_back, implement.object)
      end

      -- when it has joints by itsself then recursive into them
      if implement.object.spec_attacherJoints ~= nil then
        if debug > 1 then print("go into recursive:"..obj.rootNode) end
        FS22_EnhancedVehicle:enumerateAttachments2(rootNode, implement.object)
      end

    end
  end
  if debug > 1 then print("leaving: "..obj.rootNode) end
end

-- #############################################################################

function FS22_EnhancedVehicle:enumerateAttachments(obj)
  joints_front = {}
  joints_back = {}
  implements_front = {}
  implements_back = {}

  -- assemble a list of all attachments
  FS22_EnhancedVehicle:enumerateAttachments2(obj.rootNode, obj)
end

-- #############################################################################

function closestAngle(n,m)
  local q = math.floor(n/m)
  local n1 = m*q
  local n2 = m*(q+1)
  
  if math.abs(n-n1) < math.abs(n-n2) then
    return n1
  end
  return n2
end

-- #############################################################################

function Round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

-- #############################################################################

function Between(a, minA, maxA)
  if a == nil then return end
  if minA ~= nil and a <= minA then return minA end
  if maxA ~= nil and a >= maxA then return maxA end
  return a
end

-- #############################################################################
-- # make sure an angle is >= 0 and < 360

function AngleFix(a)
  while a < 0 do
    a = a + 360
  end
  while a >= 360 do
    a = a - 360
  end

  return a
end

-- #############################################################################

function AngleModAngle(a, diff)
  _a = a + diff
  if _a < 0 then _a = _a + 360 end
  if _a >= 360 then _a = _a - 360 end
  return a
end

-- #############################################################################

function Angle2ModAngle2(x, z, diff)
  local rot = 180 - math.deg(math.atan2(x, z))
  rot = rot + diff
  if rot < 0 then rot = rot + 360 end
  if rot >= 360 then rot = rot - 360 end
  local _x = math.sin(math.rad(rot))
  local _z = math.cos(math.rad(rot))
  return _x, _z
end

-- #############################################################################

function Angle2ModAngle(x, z, diff)
  local rot = 180 - math.deg(math.atan2(x, z))
  rot = rot + diff
  if rot < 0 then rot = rot + 360 end
  if rot >= 360 then rot = rot - 360 end
  return rot
end

-- #############################################################################

function mySelf(obj)
  return " (rootNode: " .. obj.rootNode .. ", typeName: " .. obj.typeName .. ", typeDesc: " .. obj.typeDesc .. ")"
end

-- #############################################################################

function FS22_EnhancedVehicle:updateVehiclePhysics( originalFunction, axisForward, axisSide, doHandbrake, dt)
  if debug > 2 then print("function Drivable.updateVehiclePhysics() "..tostring(dt)..", "..tostring(axisForward)..", "..tostring(axisSide)..", "..tostring(doHandbrake)) end

  if self.vData ~= nil and self.vData.is[5] then
    if self:getIsVehicleControlledByPlayer() and self:getIsMotorStarted() then
      -- get current position and rotation of vehicle
      local px, _, pz = localToWorld(self.rootNode, 0, 0, 0)
      local lx, _, lz = localDirectionToWorld(self.rootNode, 0, 0, 1)
      local rot = 180 - math.deg(math.atan2(lx, lz))

      -- if cabin is rotated -> direction should rotate also
      if self.spec_drivable.reverserDirection < 0 then
        rot = rot + 180
        if rot >= 360 then rot = rot - 360 end
      end
      rot = Round(rot, 1)
      if rot >= 360.0 then rot = 0 end
      self.vData.rot = rot

      -- when snap to track mode -> get dot
      dotLR = 0
      if self.vData.is[6] then
        local dx, dz = px - self.vData.is[11], pz - self.vData.is[12]
        dotLR = -(dx * -self.vData.is[10] + dz * self.vData.is[9])
        if math.abs(dotLR) < 0.05 then dotLR = 0 end -- smooth it
      end

      -- if wanted direction is different than current direction OR we're not on track
      if self.vData.rot ~= self.vData.is[4] or dotLR ~= 0 then

        -- get movingDirection (1=forward, 0=nothing, -1=reverse) but if nothing we choose forward
        local movingDirection = 0
        if g_currentMission.missionInfo.stopAndGoBraking then
          movingDirection = self.movingDirection * self.spec_drivable.reverserDirection
          if math.abs( self.lastSpeed ) < 0.000278 then
            movingDirection = 0
          end
        else
          movingDirection = Utils.getNoNil(self.nextMovingDirection * self.spec_drivable.reverserDirection)
        end
        if movingDirection == 0 then movingDirection = 1 end

        -- "steering force"
        local delta = dt/500 * movingDirection -- higher number means smaller changes results in slower steering

        -- calculate degree difference between "is" and "wanted" (from -180 to 180)
        local _w1 = self.vData.is[4]
        if _w1 > 180 then _w1 = _w1 - 360 end
        local _w2 = self.vData.rot

        -- when snap to track -> gently push the driving direction towards destination position depending on current speed
        if self.vData.is[6] then
--            _old = _w2
          _w2 = _w2 - Between(dotLR * Between(10 - self:getLastSpeed() / 8, 4, 8) * movingDirection * 1.3, -90, 90) -- higher means stronger movement force to destination
--            print("old: ".._old..", new: ".._w2..", dot: "..dotLR..", md: "..movingDirection.." / "..Between(10 - self:getLastSpeed() / 8, 4, 8))
        end
        if _w2 > 180 then _w2 = _w2 - 360 end
        if _w2 < -180 then _w2 = _w2 + 360 end

        -- calculate difference between angles
        local diffdeg = _w1 - _w2
        if diffdeg > 180 then diffdeg = diffdeg - 360 end
        if diffdeg < -180 then diffdeg = diffdeg + 360 end
--          print("delta: "..delta..", d: "..dotLR..", w1: ".._w1..", w2: ".._w2..", rot: "..self.vData.rot..", diffdeg: "..diffdeg)

        -- calculate new steering wheel "direction"
        local _d = 18
        -- if we have still more than 20° to steer -> increase steering wheel constantly until maximum
        -- if in between -20 to 20 -> adjust steering wheel according to remaining degrees
        -- if in between -2 to 2 -> set steering wheel directly
        local a = self.vData.axisSidePrev
        if (diffdeg < -_d) then
          a = a - delta * 0.5
        end
        if (diffdeg > _d) then
          a = a + delta * 0.5
        end
        if (diffdeg >= -_d) and (diffdeg <= _d) then
          local newa = diffdeg / _d * movingDirection -- linear from 1 to 0.1
          if a < newa then
--              print("1 dd: "..diffdeg.." a: "..a.." newa: "..newa..", md: "..movingDirection..", dot: "..dotLR)
            a = a + delta * 1.2 * movingDirection
          end
          if a > newa then
--              print("2 dd: "..diffdeg.." a: "..a.." newa: "..newa..", md: "..movingDirection..", dot: "..dotLR)
            a = a - delta * 1.2 * movingDirection
          end
        end
        if (diffdeg >= -2) and (diffdeg <= 2) then
          a = diffdeg / _d * movingDirection
        end
        a = Between(a, -1, 1)

        axisSide = a
--          print("dt: "..dt.." aS: "..axisSide.." aSp: "..self.vData.axisSidePrev.." delta: "..delta.." diffdeg: "..diffdeg)

        -- save for next calculation cycle
        self.vData.axisSidePrev = a
--          print(" is: "..self.vData.rot.." want: "..self.vData.is[4].." diff: "..diffdeg.. " steerangle: " .. axisSide)
      end
    end
  end

  -- call the original function to do the actual physics stuff
  local state, result = pcall( originalFunction, self, axisForward, axisSide, doHandbrake, dt)
  if not ( state ) then
    print("Ooops in updateVehiclePhysics :" .. tostring(result))
  end

  return result
end
Drivable.updateVehiclePhysics = Utils.overwrittenFunction( Drivable.updateVehiclePhysics, FS22_EnhancedVehicle.updateVehiclePhysics )

-- #############################################################################

function FS22_EnhancedVehicle:updateWheelsPhysics( originalFunction, dt, currentSpeed, acceleration, doHandbrake, stopAndGoBraking )
  if debug > 2 then print("function WheelsUtil.updateWheelsPhysics("..self.typeDesc..", "..tostring(dt)..", "..tostring(currentSpeed)..", "..tostring(acceleration)..", "..tostring(doHandbrake)..", "..tostring(stopAndGoBraking)) end

  local brakeLights = false
  if self.vData ~= nil and self.vData.is[14] then
    if self:getIsVehicleControlledByPlayer() and self:getIsMotorStarted() then
      -- parkBreakIsOn
      if self.vData.is[13] then
        brakeLights = true
        if currentSpeed >= -0.0003 and currentSpeed <= 0.0003 then
          brakeLights = false
        end
        acceleration = 0
        currentSpeed = 0
      end
    end
  end

  -- call the original function to do the actual physics stuff
  local state, result = pcall( originalFunction, self, dt, currentSpeed, acceleration, doHandbrake, stopAndGoBraking )
  if not ( state ) then
    print("Ooops in updateWheelsPhysics :" .. tostring(result))
  end

  if self:getIsVehicleControlledByPlayer() and self:getIsMotorStarted() then
    if brakeLights and type(self.setBrakeLightsVisibility) == "function" then
      self:setBrakeLightsVisibility(true)
    end
  end

  return result
end
WheelsUtil.updateWheelsPhysics = Utils.overwrittenFunction( WheelsUtil.updateWheelsPhysics, FS22_EnhancedVehicle.updateWheelsPhysics )
