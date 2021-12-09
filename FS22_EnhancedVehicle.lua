--
-- Mod: FS22_EnhancedVehicle
--
-- Author: Majo76
-- email: ls22@dark-world.de
-- @Date: 09.12.2021
-- @Version: 1.0.0.0

--[[
CHANGELOG

2021-12-09 - V0.9.9.0
+ verhicle can now auto steer into the track lane (press rStrg + End if grid mode is on)

2021-12-07 - V0.9.8.3
* reworked workwidth calculation
+ support for attachments with offset (e.g. plow)

2021-12-06 - V0.9.8.0
+ added grid to visualize lanes (on/off: strg + numpad 1 # recalculate: strg + numpad 2)

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
  FS22_EnhancedVehicle.hud.diff_overlayWidth  = 512
  FS22_EnhancedVehicle.hud.diff_overlayHeight = 1024
  FS22_EnhancedVehicle.hud.uiScale = 1
  if g_gameSettings.uiScale ~= nil then
    if debug > 2 then print("-> uiScale: "..FS22_EnhancedVehicle.uiScale) end
    FS22_EnhancedVehicle.uiScale = g_gameSettings.uiScale
  end
  FS22_EnhancedVehicle.sections = { 'fuel', 'dmg', 'misc', 'rpm', 'temp', 'diff', 'snap' }
  FS22_EnhancedVehicle.actions = {}
  FS22_EnhancedVehicle.actions.global =    { 'FS22_EnhancedVehicle_MENU' }
  FS22_EnhancedVehicle.actions.snap =      { 'FS22_EnhancedVehicle_SNAP_ONOFF',
                                             'FS22_EnhancedVehicle_SNAP_ONOFF2',
                                             'FS22_EnhancedVehicle_SNAP_REVERSE',
                                             'FS22_EnhancedVehicle_SNAP_LINES',
                                             'FS22_EnhancedVehicle_SNAP_INC1',
                                             'FS22_EnhancedVehicle_SNAP_DEC1',
                                             'FS22_EnhancedVehicle_SNAP_INC2',
                                             'FS22_EnhancedVehicle_SNAP_DEC2',
                                             'FS22_EnhancedVehicle_SNAP_INC3',
                                             'FS22_EnhancedVehicle_SNAP_DEC3',
                                             'FS22_EnhancedVehicle_SNAP_GRID_ONOFF',
                                             'FS22_EnhancedVehicle_SNAP_GRID_RESET',
                                             'AXIS_MOVE_SIDE_VEHICLE' }
  FS22_EnhancedVehicle.actions.diff  =     { 'FS22_EnhancedVehicle_FD',
                                             'FS22_EnhancedVehicle_RD',
                                             'FS22_EnhancedVehicle_BD',
                                             'FS22_EnhancedVehicle_DM' }
  FS22_EnhancedVehicle.actions.hydraulic = { 'FS22_EnhancedVehicle_AJ_REAR_UPDOWN',
                                             'FS22_EnhancedVehicle_AJ_REAR_ONOFF',
                                             'FS22_EnhancedVehicle_AJ_FRONT_UPDOWN',
                                             'FS22_EnhancedVehicle_AJ_FRONT_ONOFF' }

  -- some colors
  FS22_EnhancedVehicle.color = {
    black    = {       0,       0,       0, 1 },
    white    = {       1,       1,       1, 1 },
    red      = { 255/255,   0/255,   0/255, 1 },
    green    = {   0/255, 255/255,   0/255, 1 },
    blue     = {   0/255,   0/255, 255/255, 1 },
    yellow   = { 255/255, 255/255,   0/255, 1 },
    gray     = { 128/255, 128/255, 128/255, 1 },
    dmg      = {  86/255, 142/255,  42/255, 1 },
    fuel     = { 178/255, 214/255,  22/255, 1 },
    adblue   = {  48/255,  78/255, 249/255, 1 },
    electric = { 255/255, 255/255,   0/255, 1 },
    methane  = {   0/255, 198/255, 255/255, 1 },
  }

  -- for overlays
  FS22_EnhancedVehicle.overlay = {}

  -- prepare overlays
  if FS22_EnhancedVehicle.overlay["fuel"] == nil then
    FS22_EnhancedVehicle.overlay["fuel"] = createImageOverlay(self.modDirectory .. "resources/overlay_bg.dds")
  end
  if FS22_EnhancedVehicle.overlay["dmg"] == nil then
    FS22_EnhancedVehicle.overlay["dmg"] = createImageOverlay(self.modDirectory .. "resources/overlay_bg.dds")
  end
  if FS22_EnhancedVehicle.overlay["misc"] == nil then
    FS22_EnhancedVehicle.overlay["misc"] = createImageOverlay(self.modDirectory .. "resources/overlay_bg.dds")
  end
  if FS22_EnhancedVehicle.overlay["snap"] == nil then
    FS22_EnhancedVehicle.overlay["snap"] = createImageOverlay(self.modDirectory .. "resources/overlay_bg.dds")
  end
  if FS22_EnhancedVehicle.overlay["diff_bg"] == nil then
    FS22_EnhancedVehicle.overlay["diff_bg"] = createImageOverlay(self.modDirectory .. "resources/overlay_diff_bg.dds")
    setOverlayColor(FS22_EnhancedVehicle.overlay["diff_bg"], 0, 0, 0, 1)
  end
  if FS22_EnhancedVehicle.overlay["diff_front"] == nil then
    FS22_EnhancedVehicle.overlay["diff_front"] = createImageOverlay(self.modDirectory .. "resources/overlay_diff_front.dds")
  end
  if FS22_EnhancedVehicle.overlay["diff_back"] == nil then
    FS22_EnhancedVehicle.overlay["diff_back"] = createImageOverlay(self.modDirectory .. "resources/overlay_diff_back.dds")
  end
  if FS22_EnhancedVehicle.overlay["diff_dm"] == nil then
    FS22_EnhancedVehicle.overlay["diff_dm"] = createImageOverlay(self.modDirectory .. "resources/overlay_diff_dm.dds")
  end

  -- load sound effects
  if g_dedicatedServerInfo == nil then
    local file, id
    FS22_EnhancedVehicle.sounds = {}
    for _, id in ipairs({"diff_lock", "snap_on"}) do
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
  UI_main:delete()
end

-- #############################################################################

function FS22_EnhancedVehicle:onMissionLoaded(mission)
  if debug > 1 then print("-> " .. myName .. ": onMissionLoaded ") end

  g_gui:loadProfiles(self.modDirectory.."ui/guiProfiles.xml")
  UI_main = FS22_EnhancedVehicle_UI.new()
  g_gui:loadGui(self.modDirectory.."ui/FS22_EnhancedVehicle_UI.xml", "FS22_EnhancedVehicle_UI", UI_main)
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

function FS22_EnhancedVehicle.installSpecializations(vehicleTypeManager, specializationManager, modDirectory)
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
        if debug > 1 then print("--> attached specialization 'FS22_EnhancedVehicle' to vehicleType '" .. tostring(typeName) .. "'") end
        vehicleTypeManager:addSpecialization(typeName, "FS22_EnhancedVehicle.EnhancedVehicle")
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

  return(nil)
end

-- #############################################################################

function FS22_EnhancedVehicle:activateConfig()
  -- here we will "move" our config from the libConfig internal storage to the variables we actually use

  -- functions
  FS22_EnhancedVehicle.functionDiffIsEnabled      = lC:getConfigValue("global.functions", "diffIsEnabled")
  FS22_EnhancedVehicle.functionHydraulicIsEnabled = lC:getConfigValue("global.functions", "hydraulicIsEnabled")
  FS22_EnhancedVehicle.functionSnapIsEnabled      = lC:getConfigValue("global.functions", "snapIsEnabled")

  -- globals
  FS22_EnhancedVehicle.fontSize            = lC:getConfigValue("global.text", "fontSize")
  FS22_EnhancedVehicle.textPadding         = lC:getConfigValue("global.text", "textPadding")
  FS22_EnhancedVehicle.overlayBorder       = lC:getConfigValue("global.text", "overlayBorder")
  FS22_EnhancedVehicle.overlayTransparancy = lC:getConfigValue("global.text", "overlayTransparancy")
  FS22_EnhancedVehicle.showKeysInHelpMenu  = lC:getConfigValue("global.misc", "showKeysInHelpMenu")
  FS22_EnhancedVehicle.soundIsOn           = lC:getConfigValue("global.misc", "soundIsOn")

  -- snap
  FS22_EnhancedVehicle.snap = {}
  FS22_EnhancedVehicle.snap.snapToAngle = lC:getConfigValue("snap", "snapToAngle")
  FS22_EnhancedVehicle.snap.spikeHeight = lC:getConfigValue("snap", "spikeHeight")
  FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleMiddleLine  = lC:getConfigValue("snap", "distanceAboveGroundVehicleMiddleLine")
  FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine    = lC:getConfigValue("snap", "distanceAboveGroundVehicleSideLine")
  FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine = lC:getConfigValue("snap", "distanceAboveGroundAttachmentSideLine")

  FS22_EnhancedVehicle.snap.colorVehicleMiddleLine = {}
  FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[0] = lC:getConfigValue("snap.colorVehicleMiddleLine", "red")
  FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[1] = lC:getConfigValue("snap.colorVehicleMiddleLine", "green")
  FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[2] = lC:getConfigValue("snap.colorVehicleMiddleLine", "blue")

  FS22_EnhancedVehicle.snap.colorVehicleSideLine = {}
  FS22_EnhancedVehicle.snap.colorVehicleSideLine[0] = lC:getConfigValue("snap.colorVehicleSideLine", "red")
  FS22_EnhancedVehicle.snap.colorVehicleSideLine[1] = lC:getConfigValue("snap.colorVehicleSideLine", "green")
  FS22_EnhancedVehicle.snap.colorVehicleSideLine[2] = lC:getConfigValue("snap.colorVehicleSideLine", "blue")

  FS22_EnhancedVehicle.snap.colorAttachmentSideLine = {}
  FS22_EnhancedVehicle.snap.colorAttachmentSideLine[0] = lC:getConfigValue("snap.colorAttachmentSideLine", "red")
  FS22_EnhancedVehicle.snap.colorAttachmentSideLine[1] = lC:getConfigValue("snap.colorAttachmentSideLine", "green")
  FS22_EnhancedVehicle.snap.colorAttachmentSideLine[2] = lC:getConfigValue("snap.colorAttachmentSideLine", "blue")

  -- grid
  FS22_EnhancedVehicle.grid = {}
  FS22_EnhancedVehicle.grid.distanceAboveGround = lC:getConfigValue("grid", "distanceAboveGround")
  FS22_EnhancedVehicle.grid.numberOfLanes       = lC:getConfigValue("grid", "numberOfLanes")
  FS22_EnhancedVehicle.grid.color = {}
  FS22_EnhancedVehicle.grid.color[0]            = lC:getConfigValue("grid.color", "red")
  FS22_EnhancedVehicle.grid.color[1]            = lC:getConfigValue("grid.color", "green")
  FS22_EnhancedVehicle.grid.color[2]            = lC:getConfigValue("grid.color", "blue")

  -- HUD stuff
  for _, section in pairs(FS22_EnhancedVehicle.sections) do
    FS22_EnhancedVehicle.hud[section] = {}
    FS22_EnhancedVehicle.hud[section].enabled = lC:getConfigValue("hud."..section, "enabled")
    FS22_EnhancedVehicle.hud[section].posX    = lC:getConfigValue("hud."..section, "posX")
    FS22_EnhancedVehicle.hud[section].posY    = lC:getConfigValue("hud."..section, "posY")
  end
  FS22_EnhancedVehicle.hud.diff.zoomFactor    = lC:getConfigValue("hud.diff", "zoomFactor")
  FS22_EnhancedVehicle.hud.dmg.showAmountLeft = lC:getConfigValue("hud.dmg", "showAmountLeft")
  FS22_EnhancedVehicle.hud.snap.zoomFactor    = lC:getConfigValue("hud.snap", "zoomFactor")

  -- update HUD transparency
  setOverlayColor(FS22_EnhancedVehicle.overlay["fuel"], 0, 0, 0, FS22_EnhancedVehicle.overlayTransparancy)
  setOverlayColor(FS22_EnhancedVehicle.overlay["dmg"], 0, 0, 0, FS22_EnhancedVehicle.overlayTransparancy)
  setOverlayColor(FS22_EnhancedVehicle.overlay["misc"], 0, 0, 0, FS22_EnhancedVehicle.overlayTransparancy)
  setOverlayColor(FS22_EnhancedVehicle.overlay["snap"], 0, 0, 0, FS22_EnhancedVehicle.overlayTransparancy)
end

-- #############################################################################

function FS22_EnhancedVehicle:resetConfig(disable)
  if debug > 0 then print("-> " .. myName .. ": resetConfig ") end
  disable = false or disable

  local _x, _y

  if g_gameSettings.uiScale ~= nil then
    FS22_EnhancedVehicle.uiScale = g_gameSettings.uiScale
--    local screenWidth, screenHeight = getScreenModeInfo(getScreenMode())
    if debug > 1 then print("-> uiScale: "..FS22_EnhancedVehicle.uiScale) end
  end

  -- to make life easier
--  print(DebugUtil.printTableRecursively(g_currentMission.inGameMenu.hud.speedMeter, 0, 0, 2))
  local baseX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX
  local baseY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY

  -- start fresh
  lC:clearConfig()

  -- functions
  lC:addConfigValue("global.functions", "diffIsEnabled",      "bool", true)
  lC:addConfigValue("global.functions", "hydraulicIsEnabled", "bool", true)
  lC:addConfigValue("global.functions", "snapIsEnabled",      "bool", true)

  -- globals
  lC:addConfigValue("global.text", "fontSize", "float",            0.01)
  lC:addConfigValue("global.text", "textPadding", "float",         0.001)
  lC:addConfigValue("global.text", "overlayBorder", "float",       0.003)
  lC:addConfigValue("global.text", "overlayTransparancy", "float", 0.70)
  lC:addConfigValue("global.misc", "showKeysInHelpMenu", "bool",   true)
  lC:addConfigValue("global.misc", "soundIsOn", "bool",            true)

  -- snap
  lC:addConfigValue("snap", "snapToAngle", "float", 10.0)
  lC:addConfigValue("snap", "spikeHeight", "float", 0.75)
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

  -- grid
  lC:addConfigValue("grid",       "distanceAboveGround", "float", 0.15)
  lC:addConfigValue("grid",       "numberOfLanes",       "int", 5)
  lC:addConfigValue("grid.color", "red",                 "float", 255/255)
  lC:addConfigValue("grid.color", "green",               "float", 150/255)
  lC:addConfigValue("grid.color", "blue",                "float", 0/255)

  -- fuel
  if g_currentMission.inGameMenu.hud.speedMeter.fuelGaugeIconElement ~= nil then
    _x = baseX + (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusX / 1.4)
    _y = baseY + (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 2.0)
  end
  lC:addConfigValue("hud.fuel", "enabled", "bool", true)
  lC:addConfigValue("hud.fuel", "posX", "float",   _x or 0)
  lC:addConfigValue("hud.fuel", "posY", "float",   _y or 0)

  -- dmg
  if g_currentMission.inGameMenu.hud.speedMeter.damageGaugeIconElement ~= nil then
    _x = baseX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusX / 1.4)
    _y = baseY + (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 2.0)
  end
  lC:addConfigValue("hud.dmg", "enabled", "bool", true)
  lC:addConfigValue("hud.dmg", "posX", "float",   _x or 0)
  lC:addConfigValue("hud.dmg", "posY", "float",   _y or 0)
  lC:addConfigValue("hud.dmg", "showAmountLeft", "bool", false)

  -- snap
  lC:addConfigValue("hud.snap", "zoomFactor", "float", 2)
  if g_currentMission.inGameMenu.hud.speedMeter.damageGaugeIconElement ~= nil then
    _x = baseX
    _y = baseY + (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 2.0)
  end
  lC:addConfigValue("hud.snap", "enabled", "bool", true)
  lC:addConfigValue("hud.snap", "posX", "float",   _x or 0)
  lC:addConfigValue("hud.snap", "posY", "float",   _y or 0)

  -- misc
  if g_currentMission.inGameMenu.hud.speedMeter.operatingTimeElement ~= nil then
    _x = baseX
    _y = lC:getConfigValue("global.text", "overlayBorder") * 1
  end
  lC:addConfigValue("hud.misc", "enabled", "bool", true)
  lC:addConfigValue("hud.misc", "posX", "float",   _x or 0)
  lC:addConfigValue("hud.misc", "posY", "float",   _y or 0)

  -- rpm
  if g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX ~= nil then
    _x = baseX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusX / 1.55)
    _y = baseY
  end
  lC:addConfigValue("hud.rpm", "enabled", "bool", true)
  lC:addConfigValue("hud.rpm", "posX", "float",   _x or 0)
  lC:addConfigValue("hud.rpm", "posY", "float",   _y or 0)

  -- temp
  if g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX ~= nil then
    _x = baseX + (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusX / 1.55)
    _y = baseY
  end
  lC:addConfigValue("hud.temp", "enabled", "bool", true)
  lC:addConfigValue("hud.temp", "posX", "float",   _x or 0)
  lC:addConfigValue("hud.temp", "posY", "float",   _y or 0)

  -- diff
  lC:addConfigValue("hud.diff", "zoomFactor", "float", 18)
  if g_currentMission.inGameMenu.hud.speedMeter.fuelGaugeIconElement ~= nil then
    _x = baseX + (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusX * 3.15)
    _y = baseY - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.43)
  end
  lC:addConfigValue("hud.diff", "enabled", "bool", true)
  lC:addConfigValue("hud.diff", "posX", "float",   _x or 0)
  lC:addConfigValue("hud.diff", "posY", "float",   _y or 0)

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
  --  1 - frontDiffIsOn
  --  2 - backDiffIsOn
  --  3 - drive mode
  --  4 - snapAngle
  --  5 - snap.enable
  --  6 - snap on track
  --  7 - snap grid px
  --  8 - snap grid pz
  --  9 - snap grid dX
  --  10 - snap grid dZ
  if self.isServer then
    if self.vData == nil then
      self.vData = {}
      self.vData.is   = { true, true, -1, 1.0, true, true, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }
      self.vData.want = { false, false, 1, 0.0, false, false, 0, 0, 0, 0, 0, 0 }
      self.vData.torqueRatio   = { 0.5, 0.5, 0.5 }
      self.vData.maxSpeedRatio = { 1.0, 1.0, 1.0 }
      self.vData.rot = 0.0
      self.vData.axisSidePrev = 0.0
      self.vData.snaplines = false
      self.vData.triggerCalculate = false
      self.vData.grid = {}
      self.vData.grid.isVisible = false
      self.vData.grid.isCalculated = false
      self.vData.grid.dotFBPrev = 99999999
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
      for _, _data in pairs( { {1, 'frontDiffIsOn'}, {2, 'backDiffIsOn'}, {3, 'driveMode'} }) do
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

  setXMLBool(xmlFile.handle, key.."#frontDiffIsOn", self.vData.is[1])
  setXMLBool(xmlFile.handle, key.."#backDiffIsOn",  self.vData.is[2])
  setXMLInt(xmlFile.handle, key.."#driveMode",      self.vData.is[3])
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
    self.vData.grid = {}
    self.vData.grid.dotFBPrev = 99999999
  end

  -- receive initial data from server
  self.vData.is[1] = streamReadBool(streamId)    -- front diff
  self.vData.is[2] = streamReadBool(streamId)    -- back diff
  self.vData.is[3] = streamReadInt8(streamId)    -- drive mode
  self.vData.is[4] = streamReadFloat32(streamId) -- snap angle
  self.vData.is[5] = streamReadBool(streamId)    -- snap.enable
  self.vData.is[6] = streamReadBool(streamId)    -- snap on track
  self.vData.is[7] = streamReadFloat32(streamId) -- snap grid px
  self.vData.is[8] = streamReadFloat32(streamId) -- snap grid pz
  self.vData.is[9] = streamReadFloat32(streamId) -- snap grid dX
  self.vData.is[10] = streamReadFloat32(streamId) -- snap grid dZ
  self.vData.is[11] = streamReadFloat32(streamId) -- snap grid mpx
  self.vData.is[12] = streamReadFloat32(streamId) -- snap grid mpz

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
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onUpdate(dt)
  if debug > 2 then print("-> " .. myName .. ": onUpdate " .. dt .. ", S: " .. tostring(self.isServer) .. ", C: " .. tostring(self.isClient) .. mySelf(self)) end

  -- get current vehicle direction when it makes sense
  if FS22_EnhancedVehicle.functionSnapIsEnabled and self.isClient then
    if self.vData.triggerCalculate and self.vData.triggerCalculateTime < g_currentMission.time then
      self.vData.triggerCalculate = false
      FS22_EnhancedVehicle:calculateWorkWidth(self)
    end

    local isControlled = self.getIsControlled ~= nil and self:getIsControlled()
    local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		if isControlled and isEntered then

      -- get current rotation of vehicle
      self.vData.dx, self.vData.dy, self.vData.dz = localDirectionToWorld(self.rootNode, 0, 0, 1)
      self.vData.px, self.vData.py, self.vData.pz = localToWorld(self.rootNode, 0, 0, 0)
      local rot = 180 - math.deg(math.atan2(self.vData.dx, self.vData.dz))

      -- if cabin is rotated -> direction should rotate also
      if self.spec_drivable.reverserDirection < 0 then
        rot = rot + 180
        if rot >= 360 then rot = rot - 360 end
      end
      rot = Round(rot, 1)
      if rot >= 360.0 then rot = 0 end
      self.vData.rot = rot
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
          if debug > 0 then print("--> ("..self.rootNode..") changed snap.enable to: ON") end
        else
          if debug > 0 then print("--> ("..self.rootNode..") changed snap.enable to: OFF") end
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

    -- snap grid x
    if self.vData.is[7] ~= self.vData.want[7] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed snap grid px: "..self.vData.want[7]) end
      end
      self.vData.is[7] = self.vData.want[7]
    end

    -- snap grid z
    if self.vData.is[8] ~= self.vData.want[8] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed snap grid pz: "..self.vData.want[8]) end
      end
      self.vData.is[8] = self.vData.want[8]
    end

    -- snap grid dX
    if self.vData.is[9] ~= self.vData.want[9] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed snap grid dX: "..self.vData.want[9]) end
      end
      self.vData.is[9] = self.vData.want[9]
    end

    -- snap grid dZ
    if self.vData.is[10] ~= self.vData.want[10] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed snap grid dZ: "..self.vData.want[10]) end
      end
      self.vData.is[10] = self.vData.want[10]
    end

    -- snap grid mpx
    if self.vData.is[11] ~= self.vData.want[11] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed snap grid mpx: "..self.vData.want[11]) end
      end
      self.vData.is[11] = self.vData.want[11]
    end

    -- snap grid mpz
    if self.vData.is[12] ~= self.vData.want[12] then
      if FS22_EnhancedVehicle.functionSnapIsEnabled then
        if debug > 0 then print("--> ("..self.rootNode..") changed snap grid mpz: "..self.vData.want[12]) end
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

  end
end

-- #############################################################################

function FS22_EnhancedVehicle:drawVisualizationLines(_step, _segments, _x, _y, _z, _dX, _dZ, _length, _colorR, _colorG, _colorB, _addY, _spikes)
  _spikes = _spikes or false

  -- our draw one line (recursive) function
  if _step >= _segments then return end

  local p1 = { x = _x, y = _y, z = _z }
  local p2 = { x = p1.x + _dX * _length, y = p1.y, z = p1.z + _dZ * _length }
  p2.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p2.x, 0, p2.z) + _addY
  drawDebugLine(p1.x, p1.y, p1.z, _colorR, _colorG, _colorB, p2.x, p2.y, p2.z, _colorR, _colorG, _colorB)

  if _spikes then
    drawDebugLine(p2.x, p2.y, p2.z, _colorR, _colorG, _colorB, p2.x, p2.y + FS22_EnhancedVehicle.snap.spikeHeight, p2.z, _colorR, _colorG, _colorB)
  end

  FS22_EnhancedVehicle:drawVisualizationLines(_step + 1, _segments, p2.x, p2.y, p2.z, _dX, _dZ, _length, _colorR, _colorG, _colorB, _addY, _spikes)
end

-- #############################################################################

function FS22_EnhancedVehicle:onDraw()
  if debug > 2 then print("-> " .. myName .. ": onDraw, S: " .. tostring(self.isServer) .. ", C: " .. tostring(self.isClient) .. mySelf(self)) end

  -- only on client side and GUI is visible
  if self.isClient and not g_gui:getIsGuiVisible() and self:getIsControlled() then

    local fS = FS22_EnhancedVehicle.fontSize * FS22_EnhancedVehicle.uiScale
    local tP = FS22_EnhancedVehicle.textPadding * FS22_EnhancedVehicle.uiScale

    -- snap helper lines
    if FS22_EnhancedVehicle.functionSnapIsEnabled and self.vData.snaplines then
      local length = MathUtil.vector2Length(self.vData.dx, self.vData.dz);
      local dX = self.vData.dx / length
      local dZ = self.vData.dz / length

      -- draw helper line in front of vehicle
      local p1 = { x = self.vData.px, y = self.vData.py, z = self.vData.pz }
      p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleMiddleLine
      FS22_EnhancedVehicle:drawVisualizationLines(1,
        10,
        p1.x,
        p1.y,
        p1.z,
        dX,
        dZ,
        4,
        FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[0],
        FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[1],
        FS22_EnhancedVehicle.snap.colorVehicleMiddleLine[2],
        FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleMiddleLine)

      -- draw attachment helper lines
      if self.vData.workWidth ~= nil then
        _maxwidth = -999999
        for i,_ in pairs(self.vData.workWidth) do
          if self.vData.workWidth[i] > 0 and self.vData.leftMarker[i] ~= nil and self.vData.rightMarker[i] ~= nil then
            -- update work width with live data (e.g. unfolding a device)
            local leftx  = localToLocal(self.vData.leftMarker[i],  self.vData.node[i], 0, 0, 0)
            local rightx = localToLocal(self.vData.rightMarker[i], self.vData.node[i], 0, 0, 0)
            self.vData.workWidth[i] = math.abs(leftx - rightx)
            self.vData.offset[i] = (leftx + rightx) * 0.5

            -- is it a asymmetric attachment?
            local _o = math.abs(leftx) - math.abs(rightx)
            if _o < -0.1 or _o > 0.1 then
              local leftx  = localToLocal(self.vData.leftMarker[i],  self.rootNode, 0, 0, 0)
              local rightx = localToLocal(self.vData.rightMarker[i], self.rootNode, 0, 0, 0)
              self.vData.offset[i] = (leftx + rightx) * 0.5
            end

            -- is this attachment wider than the previous?
            if self.vData.workWidth[i] > _maxwidth then
              _maxwidth = self.vData.workWidth[i]
              self.vData.grid.offset = self.vData.offset[i]
            end

            -- left line beside vehicle
            local p1 = { x = self.vData.px, y = self.vData.py, z = self.vData.pz }
            p1.x = p1.x + (-dZ * self.vData.workWidth[i] / 2) - (-dZ * self.vData.offset[i])
            p1.z = p1.z + ( dX * self.vData.workWidth[i] / 2) - ( dX * self.vData.offset[i])
            p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine
            FS22_EnhancedVehicle:drawVisualizationLines(1,
              20,
              p1.x,
              p1.y,
              p1.z,
              dX,
              dZ,
              4,
              FS22_EnhancedVehicle.snap.colorVehicleSideLine[0],
              FS22_EnhancedVehicle.snap.colorVehicleSideLine[1],
              FS22_EnhancedVehicle.snap.colorVehicleSideLine[2],
              FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine, true)

            -- right line beside vehicle
            local p1 = { x = self.vData.px, y = self.vData.py, z = self.vData.pz }
            p1.x = p1.x - (-dZ * self.vData.workWidth[i] / 2) - (-dZ * self.vData.offset[i])
            p1.z = p1.z - ( dX * self.vData.workWidth[i] / 2) - ( dX * self.vData.offset[i])
            p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine
            FS22_EnhancedVehicle:drawVisualizationLines(1,
              20,
              p1.x,
              p1.y,
              p1.z,
              dX,
              dZ,
              4,
              FS22_EnhancedVehicle.snap.colorVehicleSideLine[0],
              FS22_EnhancedVehicle.snap.colorVehicleSideLine[1],
              FS22_EnhancedVehicle.snap.colorVehicleSideLine[2],
              FS22_EnhancedVehicle.snap.distanceAboveGroundVehicleSideLine, true)

            -- draw attachment left helper line
            p1.x, p1.y, p1.z = localToWorld(self.vData.leftMarker[i], 0, 0, 0)
            p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine
            local dx, dy, dz = localDirectionToWorld(self.vData.leftMarker[i], 0, 0, 1)
            length = MathUtil.vector2Length(dx, dz);
            adX = dx / length
            adZ = dz / length
            FS22_EnhancedVehicle:drawVisualizationLines(1,
              4,
              p1.x,
              p1.y,
              p1.z,
              adX,
              adZ,
              4,
              FS22_EnhancedVehicle.snap.colorAttachmentSideLine[0],
              FS22_EnhancedVehicle.snap.colorAttachmentSideLine[1],
              FS22_EnhancedVehicle.snap.colorAttachmentSideLine[2],
              FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine)

            -- draw attachment right helper line
            p1.x, p1.y, p1.z = localToWorld(self.vData.rightMarker[i], 0, 0, 0)
            p1.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p1.x, 0, p1.z) + FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine
            local dx, dy, dz = localDirectionToWorld(self.vData.rightMarker[i], 0, 0, 1)
            length = MathUtil.vector2Length(dx, dz);
            adX = dx / length
            adZ = dz / length
            FS22_EnhancedVehicle:drawVisualizationLines(1,
              4,
              p1.x,
              p1.y,
              p1.z,
              adX,
              adZ,
              4,
              FS22_EnhancedVehicle.snap.colorAttachmentSideLine[0],
              FS22_EnhancedVehicle.snap.colorAttachmentSideLine[1],
              FS22_EnhancedVehicle.snap.colorAttachmentSideLine[2],
              FS22_EnhancedVehicle.snap.distanceAboveGroundAttachmentSideLine)
          end
        end
      end

      -- draw our helping grid
      if self.vData.grid.isVisible and self.vData.grid.isCalculated then
        -- calculate lane number in direction left-right and forward-backward
        local dx, dz = self.vData.px - self.vData.is[7], self.vData.pz - self.vData.is[8]
        local dotLR = dx * -self.vData.is[10] + dz * self.vData.is[9]
        local dotFB = dx * -self.vData.is[9] - dz * self.vData.is[10]
        if math.abs(dotFB - self.vData.grid.dotFBPrev) > 0.01 then
          if dotFB < self.vData.grid.dotFBPrev then
            dir = 1
          else
            dir = -1
          end
        end
        self.vData.grid.dotFBPrev = dotFB  -- we need to save this for detecting forward/backward movement

        self.vData.grid.laneLR = dotLR / self.vData.grid.workWidth
        self.vData.grid.laneFB = dotFB / self.vData.grid.workWidth

        -- prepare for track numbers
        local activeCamera = self:getActiveCamera()
        local rx, ry, rz = getWorldRotation(activeCamera.cameraNode)
        setTextBold(true)
        setTextColor(FS22_EnhancedVehicle.grid.color[0], FS22_EnhancedVehicle.grid.color[1], FS22_EnhancedVehicle.grid.color[2], 1)
        setTextAlignment(RenderText.ALIGN_CENTER)

        -- draw lines from left to right
        local _s = math.floor(1 - FS22_EnhancedVehicle.grid.numberOfLanes / 2)
        for i = _s, (_s + FS22_EnhancedVehicle.grid.numberOfLanes), 1 do
          j = i + math.floor(self.vData.grid.laneLR)
          k = dir * 1 + self.vData.grid.laneFB
          segments = 10
          if i == 0 or i == 1 then
            k = k + 2 * dir
            segments = 12
          end
          local startX = self.vData.is[7] + (-self.vData.is[10] * (j * self.vData.grid.workWidth)) - (self.vData.is[9] * (k * self.vData.grid.workWidth))
          local startZ = self.vData.is[8] + ( self.vData.is[9] * (j * self.vData.grid.workWidth)) - (self.vData.is[10] * (k * self.vData.grid.workWidth))
          local startY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, startX, 0, startZ) + FS22_EnhancedVehicle.grid.distanceAboveGround
          FS22_EnhancedVehicle:drawVisualizationLines(1,
            segments,
            startX,
            startY,
            startZ,
            self.vData.is[9],
            self.vData.is[10],
            self.vData.grid.workWidth * dir,
            FS22_EnhancedVehicle.grid.color[0],
            FS22_EnhancedVehicle.grid.color[1],
            FS22_EnhancedVehicle.grid.color[2],
            FS22_EnhancedVehicle.grid.distanceAboveGround)

          -- render lane number
          renderText3D(startX + (-self.vData.is[10] * 0.2), startY + 0.1, startZ + (self.vData.is[9] * 0.2), rx, ry, rz, fS * 20, tostring(math.floor(j+1)))

          -- middle line
          if (i == 0) then
            if self.vData.grid.offset < (-self.vData.grid.workWidth / 2) then self.vData.grid.offset = self.vData.grid.offset + (self.vData.grid.workWidth) end
            if self.vData.grid.offset > ( self.vData.grid.workWidth / 2) then self.vData.grid.offset = self.vData.grid.offset - (self.vData.grid.workWidth) end

            local startX = self.vData.is[7] + (-self.vData.is[10] * ((j + .5) * self.vData.grid.workWidth)) - (self.vData.is[9] * (k * self.vData.grid.workWidth)) + (-self.vData.is[10] * self.vData.grid.offset * dir)
            local startZ = self.vData.is[8] + ( self.vData.is[9] * ((j + .5) * self.vData.grid.workWidth)) - (self.vData.is[10] * (k * self.vData.grid.workWidth)) + ( self.vData.is[9] * self.vData.grid.offset * dir)
            local startY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, startX, 0, startZ) + FS22_EnhancedVehicle.grid.distanceAboveGround
            if not self.vData.is[6] and self.vData.is[5] then
              self.vData.want[6]  = true
              self.vData.want[11]  = startX
              self.vData.want[12]  = startZ
              if self.isClient and not self.isServer then
                self.vData.is[6] = self.vData.want[6]
                self.vData.is[11] = self.vData.want[11]
                self.vData.is[12] = self.vData.want[12]
              end
              FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
              if debug > 1 then print("turn on snap on track, x: "..startX..", y: "..startY..", z: "..startZ) end
            end

            FS22_EnhancedVehicle:drawVisualizationLines(1,
              segments,
              startX,
              startY,
              startZ,
              self.vData.is[9],
              self.vData.is[10],
              self.vData.grid.workWidth * dir,
              FS22_EnhancedVehicle.grid.color[0] / 2,
              FS22_EnhancedVehicle.grid.color[1] / 2,
              FS22_EnhancedVehicle.grid.color[2] / 2,
              FS22_EnhancedVehicle.grid.distanceAboveGround)
          end
        end
      end
    end

    -- ### do the fuel stuff ###
    if self.spec_fillUnit ~= nil and FS22_EnhancedVehicle.hud.fuel.enabled then
      -- get values
      fuel_diesel_current   = -1
      fuel_adblue_current   = -1
      fuel_electric_current = -1
      fuel_methane_current  = -1

      for _, fillUnit in ipairs(self.spec_fillUnit.fillUnits) do
        if fillUnit.fillType == FillType.DIESEL then -- Diesel
          fuel_diesel_max = fillUnit.capacity
          fuel_diesel_current = fillUnit.fillLevel
        end
        if fillUnit.fillType == FillType.DEF then -- AdBlue
          fuel_adblue_max = fillUnit.capacity
          fuel_adblue_current = fillUnit.fillLevel
        end
        if fillUnit.fillType == FillType.ELECTRICCHARGE then -- Electric
          fuel_electric_max = fillUnit.capacity
          fuel_electric_current = fillUnit.fillLevel
        end
        if fillUnit.fillType == FillType.METHANE then -- Methan
          fuel_methane_max = fillUnit.capacity
          fuel_methane_current = fillUnit.fillLevel
        end
      end

      -- prepare text
      h = 0
      fuel_txt_usage = ""
      fuel_txt_diesel = ""
      fuel_txt_adblue = ""
      fuel_txt_electric = ""
      fuel_txt_methane = ""
      if fuel_diesel_current >= 0 then
        fuel_txt_diesel = string.format("%.1f l/%.1f l", fuel_diesel_current, fuel_diesel_max)
        h = h + fS + tP
      end
      if fuel_adblue_current >= 0 then
        fuel_txt_adblue = string.format("%.1f l/%.1f l", fuel_adblue_current, fuel_adblue_max)
        h = h + fS + tP
      end
      if fuel_electric_current >= 0 then
        fuel_txt_electric = string.format("%.1f kWh/%.1f kWh", fuel_electric_current, fuel_electric_max)
        h = h + fS + tP
      end
      if fuel_methane_current >= 0 then
        fuel_txt_methane = string.format("%.1f l/%.1f l", fuel_methane_current, fuel_methane_max)
        h = h + fS + tP
      end
      if self.spec_motorized.isMotorStarted == true and self.isServer then
        if fuel_electric_current >= 0 then
          fuel_txt_usage = string.format("%.1f kW/h", self.spec_motorized.lastFuelUsage)
        else
          fuel_txt_usage = string.format("%.1f l/h", self.spec_motorized.lastFuelUsage)
        end
        h = h + fS + tP
      end

      -- render overlay
      w = getTextWidth(fS, fuel_txt_diesel)
      tmp = getTextWidth(fS, fuel_txt_adblue)
      if  tmp > w then w = tmp end
      tmp = getTextWidth(fS, fuel_txt_electric)
      if  tmp > w then w = tmp end
      tmp = getTextWidth(fS, fuel_txt_methane)
      if  tmp > w then w = tmp end
      tmp = getTextWidth(fS, fuel_txt_usage)
      if  tmp > w then w = tmp end
      renderOverlay(FS22_EnhancedVehicle.overlay["fuel"], FS22_EnhancedVehicle.hud.fuel.posX - FS22_EnhancedVehicle.overlayBorder, FS22_EnhancedVehicle.hud.fuel.posY - FS22_EnhancedVehicle.overlayBorder, w + (FS22_EnhancedVehicle.overlayBorder*2), h + (FS22_EnhancedVehicle.overlayBorder*2))

      -- render text
      tmpY = FS22_EnhancedVehicle.hud.fuel.posY
      setTextAlignment(RenderText.ALIGN_LEFT)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextBold(false)
      if fuel_txt_diesel ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.fuel))
        renderText(FS22_EnhancedVehicle.hud.fuel.posX, tmpY, fS, fuel_txt_diesel)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_adblue ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.adblue))
        renderText(FS22_EnhancedVehicle.hud.fuel.posX, tmpY, fS, fuel_txt_adblue)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_electric ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.electric))
        renderText(FS22_EnhancedVehicle.hud.fuel.posX, tmpY, fS, fuel_txt_electric)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_methane ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.methane))
        renderText(FS22_EnhancedVehicle.hud.fuel.posX, tmpY, fS, fuel_txt_methane)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_usage ~= "" then
        setTextColor(1,1,1,1)
        renderText(FS22_EnhancedVehicle.hud.fuel.posX, tmpY, fS, fuel_txt_usage)
      end
      setTextColor(1,1,1,1)
    end

    -- ### do the damage stuff ###
    if self.spec_wearable ~= nil and FS22_EnhancedVehicle.hud.dmg.enabled then
      -- prepare text
      h = 0
      dmg_txt = ""
      if self.spec_wearable ~= nil then
        dmg_txt = string.format("%s: %.1f%% | %.1f%%", self.typeDesc, (self.spec_wearable:getDamageAmount() * 100), (self.spec_wearable:getWearTotalAmount() * 100))
        
        if FS22_EnhancedVehicle.hud.dmg.showAmountLeft then
          dmg_txt = string.format("%s: %.1f%% | %.1f%%", self.typeDesc, (100 - (self.spec_wearable:getDamageAmount() * 100)), (100 - (self.spec_wearable:getWearTotalAmount() * 100)))
        end
        
        h = h + fS + tP
      end

      dmg_txt2 = ""
      if self.spec_attacherJoints ~= nil then
        getDmg(self.spec_attacherJoints)
      end

      -- render overlay
      w = getTextWidth(fS, dmg_txt)
      tmp = getTextWidth(fS, dmg_txt2) + 0.005
      if tmp > w then
        w = tmp
      end
      renderOverlay(FS22_EnhancedVehicle.overlay["dmg"], FS22_EnhancedVehicle.hud.dmg.posX - FS22_EnhancedVehicle.overlayBorder - w, FS22_EnhancedVehicle.hud.dmg.posY - FS22_EnhancedVehicle.overlayBorder, w + (FS22_EnhancedVehicle.overlayBorder * 2), h + (FS22_EnhancedVehicle.overlayBorder * 2))

      -- render text
      setTextColor(1,1,1,1)
      setTextAlignment(RenderText.ALIGN_RIGHT)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextColor(unpack(FS22_EnhancedVehicle.color.dmg))
      setTextBold(false)
      renderText(FS22_EnhancedVehicle.hud.dmg.posX, FS22_EnhancedVehicle.hud.dmg.posY, fS, dmg_txt)
      setTextColor(1,1,1,1)
      renderText(FS22_EnhancedVehicle.hud.dmg.posX, FS22_EnhancedVehicle.hud.dmg.posY + fS + tP, fS, dmg_txt2)
    end

    -- ### do the snap stuff ###
    if FS22_EnhancedVehicle.functionSnapIsEnabled and FS22_EnhancedVehicle.hud.snap.enabled and self.vData.rot ~= nil then
      -- prepare text
      snap_txt2 = ''
      if self.vData.is[5] then
        snap_txt = string.format("%.1f°", self.vData.is[4])
        if (Round(self.vData.rot, 0) ~= Round(self.vData.is[4], 0)) then
          snap_txt2 = string.format("%.1f°", self.vData.rot)
        end
      else
        snap_txt = string.format("%.1f°", self.vData.rot)
      end

      -- render overlay
      w = getTextWidth(fS * FS22_EnhancedVehicle.hud.snap.zoomFactor, "000.0°")
      h = getTextHeight(fS * FS22_EnhancedVehicle.hud.snap.zoomFactor, snap_txt)
      if snap_txt2 ~= '' then h = h * 2 end
      tmp = w + (FS22_EnhancedVehicle.overlayBorder * 2)
      tmp = tmp / 2
      renderOverlay(FS22_EnhancedVehicle.overlay["snap"],
        FS22_EnhancedVehicle.hud.snap.posX - tmp,
        FS22_EnhancedVehicle.hud.snap.posY - FS22_EnhancedVehicle.overlayBorder,
        tmp * 2,
        h + (FS22_EnhancedVehicle.overlayBorder*2))

      -- render text
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextBold(true)

      if self.vData.is[5] then
        setTextColor(1,0,0,1)
      else
        setTextColor(0,1,0,1)
      end
      renderText(FS22_EnhancedVehicle.hud.snap.posX, FS22_EnhancedVehicle.hud.snap.posY, fS * FS22_EnhancedVehicle.hud.snap.zoomFactor, snap_txt)

      if (snap_txt2 ~= "") then
        setTextColor(1,1,1,1)
        renderText(FS22_EnhancedVehicle.hud.snap.posX, FS22_EnhancedVehicle.hud.snap.posY + fS * FS22_EnhancedVehicle.hud.snap.zoomFactor, fS * FS22_EnhancedVehicle.hud.snap.zoomFactor, snap_txt2)
      end
    end

    -- ### do the misc stuff ###
    if self.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.misc.enabled then
      -- prepare text
      misc_txt = string.format("%.1f", self:getTotalMass(true)) .. "t (total: " .. string.format("%.1f", self:getTotalMass()) .. " t)"

      -- render overlay
      w = getTextWidth(fS, misc_txt)
      h = getTextHeight(fS, misc_txt)
      renderOverlay(FS22_EnhancedVehicle.overlay["misc"], FS22_EnhancedVehicle.hud.misc.posX - FS22_EnhancedVehicle.overlayBorder - (w/2), FS22_EnhancedVehicle.hud.misc.posY - FS22_EnhancedVehicle.overlayBorder, w + (FS22_EnhancedVehicle.overlayBorder * 2), h + (FS22_EnhancedVehicle.overlayBorder * 2))

      -- render text
      setTextColor(1,1,1,1)
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextBold(false)
      renderText(FS22_EnhancedVehicle.hud.misc.posX, FS22_EnhancedVehicle.hud.misc.posY, fS, misc_txt)
    end

    -- ### do the rpm stuff ###
    if self.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.rpm.enabled then
      -- prepare text
      rpm_txt = "--\nrpm"
      if self.spec_motorized.isMotorStarted == true then
        rpm_txt = string.format("%i\nrpm", self.spec_motorized:getMotorRpmReal()) --.motor.lastMotorRpm)
      end

      -- render text
      setTextColor(1,1,1,1)
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
      setTextBold(true)
      renderText(FS22_EnhancedVehicle.hud.rpm.posX, FS22_EnhancedVehicle.hud.rpm.posY, fS, rpm_txt)
    end

    -- ### do the temperature stuff ###
    if self.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.temp.enabled and self.isServer then
      -- prepare text
      temp_txt = "--\n°C"
      if self.spec_motorized.isMotorStarted == true then
        temp_txt = string.format("%i\n°C", self.spec_motorized.motorTemperature.value)
      end

      -- render text
      setTextColor(1,1,1,1)
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
      setTextBold(true)
      renderText(FS22_EnhancedVehicle.hud.temp.posX, FS22_EnhancedVehicle.hud.temp.posY, fS, temp_txt)
    end

    -- ### do the differential stuff ###
    if FS22_EnhancedVehicle.functionDiffIsEnabled and self.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.diff.enabled then
      -- prepare text
      _txt = {}
      _txt.color = { "green", "green", "gray" }
      if self.vData ~= nil then
        if self.vData.is[1] then
          _txt.color[1] = "red"
        end
        if self.vData.is[2] then
          _txt.color[2] = "red"
        end
        if self.vData.is[3] == 0 then
          _txt.color[3] = "gray"
        end
        if self.vData.is[3] == 1 then
          _txt.color[3] = "yellow"
        end
        if self.vData.is[3] == 2 then
          _txt.color[3] = "gray"
        end
      end

      -- render overlay
      w, h = getNormalizedScreenValues(FS22_EnhancedVehicle.hud.diff_overlayWidth / FS22_EnhancedVehicle.hud.diff.zoomFactor * FS22_EnhancedVehicle.uiScale, FS22_EnhancedVehicle.hud.diff_overlayHeight / FS22_EnhancedVehicle.hud.diff.zoomFactor * FS22_EnhancedVehicle.uiScale)
      setOverlayColor(FS22_EnhancedVehicle.overlay["diff_front"], unpack(FS22_EnhancedVehicle.color[_txt.color[1]]))
      setOverlayColor(FS22_EnhancedVehicle.overlay["diff_back"],  unpack(FS22_EnhancedVehicle.color[_txt.color[2]]))
      setOverlayColor(FS22_EnhancedVehicle.overlay["diff_dm"],    unpack(FS22_EnhancedVehicle.color[_txt.color[3]]))

      renderOverlay(FS22_EnhancedVehicle.overlay["diff_bg"],    FS22_EnhancedVehicle.hud.diff.posX, FS22_EnhancedVehicle.hud.diff.posY, w, h)
      renderOverlay(FS22_EnhancedVehicle.overlay["diff_front"], FS22_EnhancedVehicle.hud.diff.posX, FS22_EnhancedVehicle.hud.diff.posY, w, h)
      renderOverlay(FS22_EnhancedVehicle.overlay["diff_back"],  FS22_EnhancedVehicle.hud.diff.posX, FS22_EnhancedVehicle.hud.diff.posY, w, h)
      renderOverlay(FS22_EnhancedVehicle.overlay["diff_dm"],    FS22_EnhancedVehicle.hud.diff.posX, FS22_EnhancedVehicle.hud.diff.posY, w, h)
    end

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
    FS22_EnhancedVehicle:calculateWorkWidth(self)
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
    FS22_EnhancedVehicle:calculateWorkWidth(self)
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onPostAttachImplement(implementIndex)
  if debug > 1 then print("-> " .. myName .. ": onPostAttachImplement" .. mySelf(self)) end

  -- update work width for snap lines
  if self.vData ~= nil and self.vData.snaplines then
    FS22_EnhancedVehicle:calculateWorkWidth(self)
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
  if not self.isClient then
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

    -- attach our actions
    for _ ,actionName in pairs(actionList) do
      local _, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, FS22_EnhancedVehicle.onActionCall, false, true, false, true)
      -- help menu priorization
      if g_inputBinding ~= nil and g_inputBinding.events ~= nil and g_inputBinding.events[eventName] ~= nil then
        g_inputBinding.events[eventName].displayPriority = 98
        if actionName == "FS22_EnhancedVehicle_DM" then g_inputBinding.events[eventName].displayPriority = 99 end
        -- don't show certain/all keys in help menu
        if utf8Substr(actionName, 0, 29) == "FS22_EnhancedVehicle_SNAP_INC" or utf8Substr(actionName, 0, 29) == "FS22_EnhancedVehicle_SNAP_DEC" or not FS22_EnhancedVehicle.showKeysInHelpMenu then
          g_inputBinding.events[eventName].displayIsVisible = false
        end
      end
    end
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onActionCall(actionName, keyStatus, arg4, arg5, arg6)
  if debug > 1 then print("-> " .. myName .. ": onActionCall " .. actionName .. ", keyStatus: " .. keyStatus .. mySelf(self)) end
  if debug > 2 then
    print(arg4)
    print(arg5)
    print(arg6)
  end

  -- front diff
  if FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_FD" then
    if FS22_EnhancedVehicle.sounds["diff_lock"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["diff_lock"], 1, 0.5, 0, 0, 0)
    end
    self.vData.want[1] = not self.vData.want[1]
    if self.isClient and not self.isServer then
      self.vData.is[1] = self.vData.want[1]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  end

  -- back diff
  if FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_RD" then
    if FS22_EnhancedVehicle.sounds["diff_lock"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["diff_lock"], 1, 0.5, 0, 0, 0)
    end
    self.vData.want[2] = not self.vData.want[2]
    if self.isClient and not self.isServer then
      self.vData.is[2] = self.vData.want[2]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  end

  -- both diffs
  if FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_BD" then
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
  end

  -- wheel drive mode
  if FS22_EnhancedVehicle.functionDiffIsEnabled and actionName == "FS22_EnhancedVehicle_DM" then
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
  end

  -- rear hydraulic up/down
  if FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_REAR_UPDOWN" then
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
  end

  -- front hydraulic up/down
  if FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_FRONT_UPDOWN" then
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
  end

  -- rear hydraulic on/off
  if FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_REAR_ONOFF" then
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
  end

  -- front hydraulic on/off
  if FS22_EnhancedVehicle.functionHydraulicIsEnabled and actionName == "FS22_EnhancedVehicle_AJ_FRONT_ONOFF" then
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
  end

  -- toggle snaplines on/off
  if actionName == "FS22_EnhancedVehicle_SNAP_LINES" then
    self.vData.snaplines = not self.vData.snaplines

    -- calculate work width
    if self.vData.snaplines then
      FS22_EnhancedVehicle:calculateWorkWidth(self)
    end
  end

  -- steering angle snap on/off
  local _snap = false
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_ONOFF" then
    if not self.vData.is[5] then
      if FS22_EnhancedVehicle.sounds["snap_on"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
        playSample(FS22_EnhancedVehicle.sounds["snap_on"], 1, 0.1, 0, 0, 0)
      end
      self.vData.want[5] = true
      
      -- calculate snap angle
      local snapToAngle = FS22_EnhancedVehicle.snap.snapToAngle
      if snapToAngle == 0 or snapToAngle == 1 or snapToAngle < 0 or snapToAngle >= 360 then
        snapToAngle = self.vData.rot
      end
      self.vData.want[4] = Round(closestAngle(self.vData.rot, snapToAngle), 0)
      if self.vData.want[4] == 360 then self.vData.want[4] = 0 end

      -- if grid is enabled -> set angle to grid angle
      if self.vData.grid.isVisible and self.vData.grid.isCalculated then
        -- ToDo: optimize this
        local lx,_,lz = localDirectionToWorld(self.rootNode, 0, 0, 1)
        local rot = 180 - math.deg(math.atan2(lx, lz))
        local _w1 = self.vData.grid.rot
        if _w1 > 180 then _w1 = _w1 - 360 end
        local _w2 = rot
        if _w2 > 180 then _w2 = _w2 - 360 end
        if _w2 < -180 then _w2 = _w2 + 360 end
        local diffdeg = _w1 - _w2
        if diffdeg > 180 then diffdeg = diffdeg - 360 end
        if diffdeg < -180 then diffdeg = diffdeg + 360 end

        -- flip grid
        if diffdeg < -90 or diffdeg > 90 then
          self.vData.grid.rot = self.vData.grid.rot + 180
          if self.vData.grid.rot >= 360 then
            self.vData.grid.rot = self.vData.grid.rot - 360
          end
          self.vData.want[9] = -self.vData.is[9]
          self.vData.want[10] = -self.vData.is[10]
        end

        -- our new snap angle
        self.vData.want[4] = self.vData.grid.rot
        self.vData.want[6] = false
      end
    else
      self.vData.want[5] = false
    end
    _snap = true
  end

  -- just turn snap on/off
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_ONOFF2" then
    if not self.vData.is[5] then
      if FS22_EnhancedVehicle.sounds["snap_on"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
        playSample(FS22_EnhancedVehicle.sounds["snap_on"], 1, 0.1, 0, 0, 0)
      end
    end
    self.vData.want[5] = not self.vData.want[5]
    _snap = true
  end

  -- steering angle snap inc/dec
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_REVERSE" then
    if FS22_EnhancedVehicle.sounds["snap_on"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
      playSample(FS22_EnhancedVehicle.sounds["snap_on"], 1, 0.1, 0, 0, 0)
    end

    -- reverse snap angle
    self.vData.want[4] = Round(self.vData.want[4] + 180, 0)
    if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end

    -- if grid is enabled -> also rotate grid
    if self.vData.grid.isVisible and self.vData.grid.isCalculated then
      self.vData.want[9]  = -self.vData.is[9]
      self.vData.want[10] = -self.vData.is[10]
      self.vData.grid.rot = self.vData.want[4]
    end

    -- turn snap on
    self.vData.want[5] = true
    _snap = true
  end

  -- only if grid is invisible
  if not self.vData.grid.isVisible then
    if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_INC1" then
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.want[4] + 1, 0)
        if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    end
    if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_DEC1" then
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.want[4] - 1, 0)
        if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    end
    if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_INC3" then
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.want[4] + 90.0, 0)
        if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    end
    if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_DEC3" then
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.want[4] - 90.0, 0)
        if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    end
    if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_INC2" then
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.want[4] + 45.0, 1)
        if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    end
    if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_DEC2" then
      if self.vData.is[5] then
        self.vData.want[4] = Round(self.vData.want[4] - 45.0, 1)
        if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
        _snap = true
      else
        g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNotEnabled"), 4000)
      end
    end
  end

  -- disable steering angle snap if user interacts
  if actionName == "AXIS_MOVE_SIDE_VEHICLE" and math.abs( keyStatus ) > 0.05 then
    if self.vData.is[5] then
      self.vData.want[5] = false
      self.vData.want[6] = false
      _snap = true
    end
  end

  -- helping grid on/off
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_GRID_ONOFF" then
    self.vData.grid.isVisible = not self.vData.grid.isVisible

    -- if we turn on grid we must also switch lines on
    if self.vData.grid.isVisible then
      self.vData.snaplines = true

      -- turn off snap
      self.vData.want[5] = false
      self.vData.want[6] = false
      _snap = true
    end

    if not self.vData.grid.isCalculated then
      FS22_EnhancedVehicle:calculateGrid(self)
      _snap = true
    end
  end

  -- recalculate grid
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_GRID_RESET" then
    if not FS22_EnhancedVehicle:calculateGrid(self) then
      g_currentMission:showBlinkingWarning(g_i18n:getText("global_FS22_EnhancedVehicle_snapNoImplement"), 4000)
    else
      -- reset guide line
      self.vData.want[6] = false
      _snap = true
    end

    -- turn on grid visibility
    if not self.vData.grid.isVisible then
      self.vData.grid.isVisible = true
      self.vData.snaplines = true
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

  -- configuration dialog
  if actionName == "FS22_EnhancedVehicle_MENU" then
    if not self.isClient then
      return
    end

    if self == g_currentMission.controlledVehicle and not g_currentMission.isSynchronizingWithPlayers then
      if not g_gui:getIsGuiVisible() then
        g_gui:showDialog("FS22_EnhancedVehicle_UI")
      end
    end
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:calculateGrid(self)
  if debug > 1 then print("-> " .. myName .. ": calculateGrid" .. mySelf(self)) end

  if self.vData.grid == nil then
    self.vData.grid = {}
    self.vData.grid.isVisible = false
    self.vData.grid.isCalculated = false
  end

  -- we need the working width
  FS22_EnhancedVehicle:calculateWorkWidth(self)

  -- search widest attachment
  _width = 0
  _offset = 0
  for i,_ in pairs(self.vData.workWidth) do
    if self.vData.workWidth[i] > _width then
      _width = self.vData.workWidth[i]
      _offset = self.vData.offset[i]
      _leftMarker = self.vData.leftMarker[i]
    end
  end

  if _width > 0 then
    self.vData.grid.workWidth = _width
    self.vData.grid.offset = _offset

    -- copy current vehicle position and direction as base for our grid
    local length = MathUtil.vector2Length(self.vData.dx, self.vData.dz);
    local dX = self.vData.dx / length
    local dZ = self.vData.dz / length

    -- smoothen grid angle to snapToAngle
    local rot = 180 - math.deg(math.atan2(dX, dZ))
    -- if cabin is rotated -> direction should rotate also
    if self.spec_drivable.reverserDirection < 0 then
      rot = rot + 180
      if rot >= 360 then rot = rot - 360 end
    end
    rot = Round(rot, 1)
    local snapToAngle = FS22_EnhancedVehicle.snap.snapToAngle
    if snapToAngle == 0 or snapToAngle == 1 or snapToAngle < 0 or snapToAngle >= 360 then
      snapToAngle = rot
    end
    rot = Round(closestAngle(rot, snapToAngle), 0)
    dX = math.sin(math.rad(rot))
    dZ = -math.cos(math.rad(rot))

    -- grid start position
    self.vData.want[7] = self.vData.px + -dZ * (self.vData.grid.workWidth / 2) - (-dZ * _offset)
    self.vData.want[8] = self.vData.pz + dX * (self.vData.grid.workWidth / 2) - (dX * _offset)

    self.vData.want[9] = dX
    self.vData.want[10] = dZ
    self.vData.grid.rot = rot

    self.vData.grid.dotFBPrev = 999999

    self.vData.grid.isCalculated = true

    if debug > 1 then print("p: ("..self.vData.want[7].."/"..self.vData.want[8]..") dXZ: ("..dX.."/"..dZ..") w: "..self.vData.grid.workWidth..", rot: "..self.vData.grid.rot) end
  else
    return false
  end

  return true
end

-- #############################################################################

function FS22_EnhancedVehicle:calculateWorkWidth(self)
  if debug > 1 then print("-> " .. myName .. ": calculateWorkWidth" .. mySelf(self)) end

  self.vData.workWidth = {}
  self.vData.leftMarker = {}
  self.vData.rightMarker = {}
  self.vData.offset = {}
  self.vData.node = {}

  local attachedImplements
  local i = 0
  if self.getAttachedImplements ~= nil then
    attachedImplements = self:getAttachedImplements()
  end
  if attachedImplements ~= nil then
    -- go through all attached implements
    for _, implement in pairs(attachedImplements) do
      if implement.object ~= nil and implement.object.spec_workArea ~= nil then
        self.vData.workWidth[i]   = 0
        self.vData.leftMarker[i]  = nil
        self.vData.rightMarker[i] = nil
        self.vData.offset[i]      = nil
        self.vData.node[i]        = nil

  --print(DebugUtil.printTableRecursively(implement.object, 0, 0, 1))

--[[
        -- go through all workAreas of this implement
        for _, workArea in pairs(implement.object.spec_workArea.workAreas) do
          -- only areas with a function
          if workArea.functionName ~= nil then
            -- calculate min/max values from width+height nodes
            _min = 99999999
            _max = -99999999
            x0 = localToLocal(workArea.start, self.rootNode, 0, 0, 0)
            x1 = localToLocal(workArea.width, self.rootNode, 0, 0, 0)
            x2 = localToLocal(workArea.height, self.rootNode, 0, 0, 0)
            if x1 < _min then _min = x1 end
            if x2 > _max then _max = x2 end
            self.vData.offset[i] = (_min + _max) * 0.5
            _width = _max + math.abs(_min)

            if debug > 1 then print("x0: "..x0..", x1: "..x1..", x2: "..x2..", min: ".._min..", max: ".._max..", width: ".._width) end
          end
        end -- end of workAreas
]]--

        -- distance between getAIMarkers
        self.vData.leftMarker[i], self.vData.rightMarker[i] = implement.object:getAIMarkers()
        self.vData.node[i] = implement.object.rootNode
        if self.vData.leftMarker[i] ~= nil and self.vData.rightMarker[i] ~= nil then
          local leftx  = localToLocal(self.vData.leftMarker[i],  implement.object.rootNode, 0, 0, 0)
          local rightx = localToLocal(self.vData.rightMarker[i], implement.object.rootNode, 0, 0, 0)
          self.vData.workWidth[i] = math.abs(leftx - rightx)
          self.vData.offset[i] = (leftx + rightx) * 0.5
          local _o = math.abs(leftx) - math.abs(rightx)
          -- is it a asymetric attachment?
          if _o < -0.1 or _o > 0.1 then
            local leftx  = localToLocal(self.vData.leftMarker[i],  self.rootNode, 0, 0, 0)
            local rightx = localToLocal(self.vData.rightMarker[i], self.rootNode, 0, 0, 0)
            self.vData.offset[i] = (leftx + rightx) * 0.5
          end
        end

        if debug > 1 then print("i: "..i.." / type: "..implement.object.typeName.." / width: "..self.vData.workWidth[i].." / offset: "..self.vData.offset[i]) end
        i =  i + 1
      end
    end
  end

  -- and for our own vehicle
  if (self.spec_workArea ~= nil) then
    self.vData.workWidth[i]   = 0
    self.vData.leftMarker[i]  = nil
    self.vData.rightMarker[i] = nil
    self.vData.offset[i]      = nil
    self.vData.node[i]        = nil

    self.vData.leftMarker[i], self.vData.rightMarker[i] = self:getAIMarkers()
    self.vData.node[i] = self.rootNode
    if self.vData.leftMarker[i] ~= nil and self.vData.rightMarker[i] ~= nil then
      local leftx  = localToLocal(self.vData.leftMarker[i],  self.rootNode, 0, 0, 0)
      local rightx = localToLocal(self.vData.rightMarker[i], self.rootNode, 0, 0, 0)
      self.vData.offset[i] = (leftx + rightx) * 0.5
      self.vData.workWidth[i] = math.abs(leftx - rightx)
    end

    if debug > 1 then print("i: "..i.." / type: "..self.typeName.." / width: "..self.vData.workWidth[i]) end
    i =  i + 1
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

function getDmg(start)
  if start.spec_attacherJoints.attachedImplements ~= nil then
    for _, implement in pairs(start.spec_attacherJoints.attachedImplements) do
      local tA = 0
      local tL = 0
      if implement.object.spec_wearable ~= nil then
        tA = implement.object.spec_wearable:getDamageAmount()
        tL = implement.object.spec_wearable:getWearTotalAmount()
      end
            
      if FS22_EnhancedVehicle.hud.dmg.showAmountLeft then
        dmg_txt2 = string.format("%s: %.1f%% | %.1f%%", implement.object.typeDesc, (100 - (tA * 100)), (100 - (tL * 100))) .. "\n" .. dmg_txt2
      else
        dmg_txt2 = string.format("%s: %.1f%% | %.1f%%", implement.object.typeDesc, (tA * 100), (tL * 100)) .. "\n" .. dmg_txt2
      end
      
      h = h + (FS22_EnhancedVehicle.fontSize + FS22_EnhancedVehicle.textPadding) * FS22_EnhancedVehicle.uiScale
      if implement.object.spec_attacherJoints ~= nil then
        getDmg(implement.object)
      end
    end
  end
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

function mySelf(obj)
  return " (rootNode: " .. obj.rootNode .. ", typeName: " .. obj.typeName .. ", typeDesc: " .. obj.typeDesc .. ")"
end

-- #############################################################################

function FS22_EnhancedVehicle:updateVehiclePhysics( originalFunction, axisForward, axisSide, doHandbrake, dt)
  if debug > 2 then print("function Drivable.updateVehiclePhysics() "..tostring(dt)..", "..tostring(axisForward)..", "..tostring(axisSide)..", "..tostring(doHandbrake)) end

  if FS22_EnhancedVehicle.functionSnapIsEnabled then
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

        -- get dot
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
            _w2 = _w2 - Between(dotLR * Between(10 - self:getLastSpeed() / 8, 4, 8) * movingDirection, -60, 60) -- higher means stronger movement force to destination
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
          -- if we have still more than 20° to steer -> increase steering wheel constantly until maximum
          -- if in between -20 to 20 -> adjust steering wheel according to remaining degrees
          -- if in between -2 to 2 -> set steering wheel directly
          local a = self.vData.axisSidePrev
          if (diffdeg < -20) then
            a = a - delta * 0.5
          end
          if (diffdeg > 20) then
            a = a + delta * 0.5
          end
          if (diffdeg >= -20) and (diffdeg <= 20) then
            local newa = diffdeg / 20 * movingDirection -- linear from 1 to 0.1
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
            a = diffdeg / 20 * movingDirection --* delta
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
  end

  -- call the original function to do the actual physics stuff
  local state, result = pcall( originalFunction, self, axisForward, axisSide, doHandbrake, dt)
  if not ( state ) then
    print("Ooops in updateVehiclePhysics :" .. tostring(result))
  end

  return result
end
Drivable.updateVehiclePhysics = Utils.overwrittenFunction( Drivable.updateVehiclePhysics, FS22_EnhancedVehicle.updateVehiclePhysics )
