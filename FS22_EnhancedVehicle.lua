--
-- Mod: FS22_EnhancedVehicle
--
-- Author: Majo76
-- email: ls22@dark-world.de
-- @Date: 27.11.2021
-- @Version: 1.0.0.0

--[[
CHANGELOG

2021-11-26 - V1.0.0.0
* first release for FS22
* !!! WARNING !!! This version of EV has different default key bindings compared to FS19 !!!
* adjusted this and that for FS22 engine changes
+ added basic "keep current direction" feature
+ added fuel support for "electric" and "methane"
- removed all shuttle control related stuff
- removed all "feinstaub" related stuff

license: https://creativecommons.org/licenses/by-nc-sa/4.0/
]]--

local myName = "FS22_EnhancedVehicle"

FS22_EnhancedVehicle = {}
local FS22_EnhancedVehicle_mt = Class(FS22_EnhancedVehicle)

-- #############################################################################

function FS22_EnhancedVehicle:new(modDirectory, modName)
  if debug > 1 then print("-> " .. myName .. ": new ") end

  local self = {}

  setmetatable(self, FS22_EnhancedVehicle_mt)

  self.modDirectory  = modDirectory
  self.modName = modName

  local modDesc = loadXMLFile("modDesc", modDirectory .. "modDesc.xml");
  self.version = getXMLString(modDesc, "modDesc.version");

  -- for debugging purpose
  FS22_dbg = false
  FS22_dbg1 = 0
  FS22_dbg2 = 0
  FS22_dbg3 = 0

  -- some global stuff - DONT touch
  FS22_EnhancedVehicle.diff_overlayWidth  = 512
  FS22_EnhancedVehicle.diff_overlayHeight = 1024
  FS22_EnhancedVehicle.dir_overlayWidth  = 64
  FS22_EnhancedVehicle.dir_overlayHeight = 256
  FS22_EnhancedVehicle.uiScale = 1
  if g_gameSettings.uiScale ~= nil then
    if debug > 2 then print("-> uiScale: "..FS22_EnhancedVehicle.uiScale) end
    FS22_EnhancedVehicle.uiScale = g_gameSettings.uiScale
  end
  FS22_EnhancedVehicle.sections = { 'fuel', 'dmg', 'misc', 'rpm', 'temp', 'diff', 'snap' }
  FS22_EnhancedVehicle.actions = {}
  FS22_EnhancedVehicle.actions.global =    { 'FS22_EnhancedVehicle_RESET',
                                             'FS22_EnhancedVehicle_RELOAD',
                                             'FS22_EnhancedVehicle_TOGGLE_DISPLAY',
                                             'FS22_EnhancedVehicle_SNAP_ONOFF',
                                             'FS22_EnhancedVehicle_SNAP_ONOFF2',
                                             'FS22_EnhancedVehicle_SNAP_REVERSE',
                                             'FS22_EnhancedVehicle_SNAP_INC1',
                                             'FS22_EnhancedVehicle_SNAP_DEC1',
                                             'FS22_EnhancedVehicle_SNAP_INC2',
                                             'FS22_EnhancedVehicle_SNAP_DEC2',
                                             'FS22_EnhancedVehicle_SNAP_INC3',
                                             'FS22_EnhancedVehicle_SNAP_DEC3',
                                             'AXIS_MOVE_SIDE_VEHICLE' }
  FS22_EnhancedVehicle.actions.diff  =     { 'FS22_EnhancedVehicle_FD',
                                             'FS22_EnhancedVehicle_RD',
                                             'FS22_EnhancedVehicle_BD',
                                             'FS22_EnhancedVehicle_DM' }
  FS22_EnhancedVehicle.actions.hydraulic = { 'FS22_EnhancedVehicle_AJ_REAR_UPDOWN',
                                             'FS22_EnhancedVehicle_AJ_REAR_ONOFF',
                                             'FS22_EnhancedVehicle_AJ_FRONT_UPDOWN',
                                             'FS22_EnhancedVehicle_AJ_FRONT_ONOFF' }

  if FS22_dbg then
    for _, v in pairs({ 'FS22_DBG1_UP', 'FS22_DBG1_DOWN', 'FS22_DBG2_UP', 'FS22_DBG2_DOWN', 'FS22_DBG3_UP', 'FS22_DBG3_DOWN' }) do
      table.insert(FS22_EnhancedVehicle.actions, v)
    end
  end

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
    FS22_EnhancedVehicle.overlay["fuel"] = createImageOverlay(self.modDirectory .. "media/overlay_bg.dds")
  end
  if FS22_EnhancedVehicle.overlay["dmg"] == nil then
    FS22_EnhancedVehicle.overlay["dmg"] = createImageOverlay(self.modDirectory .. "media/overlay_bg.dds")
  end
  if FS22_EnhancedVehicle.overlay["misc"] == nil then
    FS22_EnhancedVehicle.overlay["misc"] = createImageOverlay(self.modDirectory .. "media/overlay_bg.dds")
  end
  if FS22_EnhancedVehicle.overlay["diff_bg"] == nil then
    FS22_EnhancedVehicle.overlay["diff_bg"] = createImageOverlay(self.modDirectory .. "media/overlay_diff_bg.dds")
    setOverlayColor(FS22_EnhancedVehicle.overlay["diff_bg"], 0, 0, 0, 1)
  end
  if FS22_EnhancedVehicle.overlay["diff_front"] == nil then
    FS22_EnhancedVehicle.overlay["diff_front"] = createImageOverlay(self.modDirectory .. "media/overlay_diff_front.dds")
  end
  if FS22_EnhancedVehicle.overlay["diff_back"] == nil then
    FS22_EnhancedVehicle.overlay["diff_back"] = createImageOverlay(self.modDirectory .. "media/overlay_diff_back.dds")
  end
  if FS22_EnhancedVehicle.overlay["diff_dm"] == nil then
    FS22_EnhancedVehicle.overlay["diff_dm"] = createImageOverlay(self.modDirectory .. "media/overlay_diff_dm.dds")
  end

  -- load sound effects
  if g_dedicatedServerInfo == nil then
    local file, id
    FS22_EnhancedVehicle.sounds = {}
    for _, id in ipairs({"diff_lock", "snap_on"}) do
      FS22_EnhancedVehicle.sounds[id] = createSample(id)
      file = self.modDirectory.."media/"..id..".ogg"
      loadSample(FS22_EnhancedVehicle.sounds[id], file, false)
    end
  end

  return self
end

-- #############################################################################

function FS22_EnhancedVehicle:delete()
  if debug > 1 then print("-> " .. myName .. ": delete ") end
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

  for _,n in pairs( { "onLoad", "onPostLoad", "saveToXMLFile", "onUpdate", "onDraw", "onReadStream", "onWriteStream", "onRegisterActionEvents", "onEnterVehicle", "onLeaveVehicle" } ) do
    SpecializationUtil.registerEventListener(vehicleType, n, FS22_EnhancedVehicle)
  end
end

-- #############################################################################
-- ### function for others mods to enable/disable EnhancedVehicle functions
-- ###   name: differential, hydraulic, snap
-- ###  state: true or false

function FS22_EnhancedVehicle:functionEnable(name, state)
  if name == "differential" then
    lC:setConfigValue("global.functions", "differentialIsEnabled", state)
    FS22_EnhancedVehicle.functionDifferentialIsEnabled = state
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
    return(lC:getConfigValue("global.functions", "differentialIsEnabled"))
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
  FS22_EnhancedVehicle.functionDifferentialIsEnabled = lC:getConfigValue("global.functions", "differentialIsEnabled")
  FS22_EnhancedVehicle.functionHydraulicIsEnabled    = lC:getConfigValue("global.functions", "hydraulicIsEnabled")
  FS22_EnhancedVehicle.functionSnapIsEnabled         = lC:getConfigValue("global.functions", "snapIsEnabled")

  -- globals
  FS22_EnhancedVehicle.fontSize            = lC:getConfigValue("global.text", "fontSize")
  FS22_EnhancedVehicle.textPadding         = lC:getConfigValue("global.text", "textPadding")
  FS22_EnhancedVehicle.overlayBorder       = lC:getConfigValue("global.text", "overlayBorder")
  FS22_EnhancedVehicle.overlayTransparancy = lC:getConfigValue("global.text", "overlayTransparancy")
  FS22_EnhancedVehicle.showKeysInHelpMenu  = lC:getConfigValue("global.misc", "showKeysInHelpMenu")
  FS22_EnhancedVehicle.soundIsOn           = lC:getConfigValue("global.misc", "soundIsOn")

  -- HUD stuff
  for _, section in pairs(FS22_EnhancedVehicle.sections) do
    FS22_EnhancedVehicle[section] = {}
    FS22_EnhancedVehicle[section].enabled = lC:getConfigValue("hud."..section, "enabled")
    FS22_EnhancedVehicle[section].posX    = lC:getConfigValue("hud."..section, "posX")
    FS22_EnhancedVehicle[section].posY    = lC:getConfigValue("hud."..section, "posY")
  end
  FS22_EnhancedVehicle.diff.zoomFactor    = lC:getConfigValue("hud.diff", "zoomFactor")

  -- update HUD transparency
  setOverlayColor(FS22_EnhancedVehicle.overlay["fuel"], 0, 0, 0, FS22_EnhancedVehicle.overlayTransparancy)
  setOverlayColor(FS22_EnhancedVehicle.overlay["dmg"], 0, 0, 0, FS22_EnhancedVehicle.overlayTransparancy)
  setOverlayColor(FS22_EnhancedVehicle.overlay["misc"], 0, 0, 0, FS22_EnhancedVehicle.overlayTransparancy)
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
  lC:addConfigValue("global.functions", "differentialIsEnabled", "bool", true)
  lC:addConfigValue("global.functions", "hydraulicIsEnabled",    "bool", true)
  lC:addConfigValue("global.functions", "snapIsEnabled",         "bool", true)

  -- globals
  lC:addConfigValue("global.text", "fontSize", "float",            0.01)
  lC:addConfigValue("global.text", "textPadding", "float",         0.001)
  lC:addConfigValue("global.text", "overlayBorder", "float",       0.003)
  lC:addConfigValue("global.text", "overlayTransparancy", "float", 0.70)
  lC:addConfigValue("global.misc", "showKeysInHelpMenu", "bool",   true)
  lC:addConfigValue("global.misc", "soundIsOn", "bool",            true)

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

  -- snap
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
  if self.isServer then
    if self.vData == nil then
      self.vData = {}
      self.vData.is   = { true, true, -1, 1.0, true }
      self.vData.want = { false, false, 1, 0.0, false }
      self.vData.torqueRatio   = { 0.5, 0.5, 0.5 }
      self.vData.maxSpeedRatio = { 1.0, 1.0, 1.0 }
      self.vData.rot = 0.0
      self.vData.axisSidePrev = 0.0
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
      local key     = savegame.key ..".FS22_EnhancedVehicle"

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

function FS22_EnhancedVehicle:onUpdate(dt)
  if debug > 2 then print("-> " .. myName .. ": onUpdate " .. dt .. ", S: " .. tostring(self.isServer) .. ", C: " .. tostring(self.isClient) .. mySelf(self)) end

  -- get current vehicle direction when it makes sense
  if FS22_EnhancedVehicle.functionSnapIsEnabled and self.isClient then
    local isControlled = self.getIsControlled ~= nil and self:getIsControlled()
    local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		if isControlled and isEntered then

      -- get current rotation of vehicle
      local lx,_,lz = localDirectionToWorld(self.rootNode, 0, 0, 1)
      local rot = 180 - math.deg(math.atan2(lx, lz))

      -- if cabin is rotated -> direction should rotate also
      if self.spec_drivable.reverserDirection < 0 then
        rot = rot + 180
        if rot >= 360 then rot = rot - 360 end
      end
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

    -- front diff
    if self.vData.is[1] ~= self.vData.want[1] then
      if FS22_EnhancedVehicle.functionDifferentialIsEnabled then
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
      if FS22_EnhancedVehicle.functionDifferentialIsEnabled then
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
      if FS22_EnhancedVehicle.functionDifferentialIsEnabled then
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

function FS22_EnhancedVehicle:onDraw()
  if debug > 2 then print("-> " .. myName .. ": onDraw, S: " .. tostring(self.isServer) .. ", C: " .. tostring(self.isClient) .. mySelf(self)) end

  -- only on client side and GUI is visible
  if self.isClient and not g_gui:getIsGuiVisible() and self:getIsControlled() then

    local fS = FS22_EnhancedVehicle.fontSize * FS22_EnhancedVehicle.uiScale
    local tP = FS22_EnhancedVehicle.textPadding * FS22_EnhancedVehicle.uiScale

    -- render debug stuff
    if FS22_dbg then
      setTextColor(1,0,0,1)
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_MIDDLE)
      setTextBold(true)
      renderText(0.5, 0.5, 0.025, "dbg1: "..FS22_dbg1..", dbg2: "..FS22_dbg2..", dbg3: "..FS22_dbg3)

      -- render some help points into speedMeter
      setTextColor(1,0,0,1)
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_MIDDLE)
      setTextBold(false)
      renderText(g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX, g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY, 0.01, "O")
      renderText(g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX + g_currentMission.inGameMenu.hud.speedMeter.fuelGaugeRadiusX, g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY + g_currentMission.inGameMenu.hud.speedMeter.fuelGaugeRadiusY, 0.01, "O")
      renderText(g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - g_currentMission.inGameMenu.hud.speedMeter.damageGaugeRadiusX, g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY + g_currentMission.inGameMenu.hud.speedMeter.damageGaugeRadiusY, 0.01, "O")
    end

    -- ### do the fuel stuff ###
    if self.spec_fillUnit ~= nil and FS22_EnhancedVehicle.fuel.enabled then
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
      renderOverlay(FS22_EnhancedVehicle.overlay["fuel"], FS22_EnhancedVehicle.fuel.posX - FS22_EnhancedVehicle.overlayBorder, FS22_EnhancedVehicle.fuel.posY - FS22_EnhancedVehicle.overlayBorder, w + (FS22_EnhancedVehicle.overlayBorder*2), h + (FS22_EnhancedVehicle.overlayBorder*2))

      -- render text
      tmpY = FS22_EnhancedVehicle.fuel.posY
      setTextAlignment(RenderText.ALIGN_LEFT)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextBold(false)
      if fuel_txt_diesel ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.fuel))
        renderText(FS22_EnhancedVehicle.fuel.posX, tmpY, fS, fuel_txt_diesel)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_adblue ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.adblue))
        renderText(FS22_EnhancedVehicle.fuel.posX, tmpY, fS, fuel_txt_adblue)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_electric ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.electric))
        renderText(FS22_EnhancedVehicle.fuel.posX, tmpY, fS, fuel_txt_electric)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_methane ~= "" then
        setTextColor(unpack(FS22_EnhancedVehicle.color.methane))
        renderText(FS22_EnhancedVehicle.fuel.posX, tmpY, fS, fuel_txt_methane)
        tmpY = tmpY + fS + tP
      end
      if fuel_txt_usage ~= "" then
        setTextColor(1,1,1,1)
        renderText(FS22_EnhancedVehicle.fuel.posX, tmpY, fS, fuel_txt_usage)
      end
      setTextColor(1,1,1,1)
    end

    -- ### do the damage stuff ###
    if self.spec_wearable ~= nil and FS22_EnhancedVehicle.dmg.enabled then
      -- prepare text
      h = 0
      dmg_txt = ""
      if self.spec_wearable ~= nil then
        dmg_txt = string.format("%s: %.1f%% | %.1f%%", self.typeDesc, (self.spec_wearable:getDamageAmount() * 100), (self.spec_wearable:getWearTotalAmount() * 100))
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
      renderOverlay(FS22_EnhancedVehicle.overlay["dmg"], FS22_EnhancedVehicle.dmg.posX - FS22_EnhancedVehicle.overlayBorder - w, FS22_EnhancedVehicle.dmg.posY - FS22_EnhancedVehicle.overlayBorder, w + (FS22_EnhancedVehicle.overlayBorder * 2), h + (FS22_EnhancedVehicle.overlayBorder * 2))

      -- render text
      setTextColor(1,1,1,1)
      setTextAlignment(RenderText.ALIGN_RIGHT)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextColor(unpack(FS22_EnhancedVehicle.color.dmg))
      setTextBold(false)
      renderText(FS22_EnhancedVehicle.dmg.posX, FS22_EnhancedVehicle.dmg.posY, fS, dmg_txt)
      setTextColor(1,1,1,1)
      renderText(FS22_EnhancedVehicle.dmg.posX, FS22_EnhancedVehicle.dmg.posY + fS + tP, fS, dmg_txt2)
    end

    -- ### do the snap stuff ###
    if FS22_EnhancedVehicle.functionSnapIsEnabled and self.vData.rot ~= nil then
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

      -- render text
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextBold(false)

      if self.vData.is[5] then
        setTextColor(1,0,0,1)
      else
        setTextColor(0,1,0,1)
      end
      renderText(FS22_EnhancedVehicle.snap.posX, FS22_EnhancedVehicle.snap.posY, fS*1.5, snap_txt)

      if (snap_txt2 ~= "") then
        setTextColor(1,1,1,1)
        renderText(FS22_EnhancedVehicle.snap.posX, FS22_EnhancedVehicle.snap.posY + fS*1.5, fS*1.5, snap_txt2)
      end
    end

    -- ### do the misc stuff ###
    if self.spec_motorized ~= nil and FS22_EnhancedVehicle.misc.enabled then
      -- prepare text
      misc_txt = string.format("%.1f", self:getTotalMass(true)) .. "t (total: " .. string.format("%.1f", self:getTotalMass()) .. " t)"

      -- render overlay
      w = getTextWidth(fS, misc_txt)
      h = getTextHeight(fS, misc_txt)
      renderOverlay(FS22_EnhancedVehicle.overlay["misc"], FS22_EnhancedVehicle.misc.posX - FS22_EnhancedVehicle.overlayBorder - (w/2), FS22_EnhancedVehicle.misc.posY - FS22_EnhancedVehicle.overlayBorder, w + (FS22_EnhancedVehicle.overlayBorder * 2), h + (FS22_EnhancedVehicle.overlayBorder * 2))

      -- render text
      setTextColor(1,1,1,1)
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
      setTextBold(false)
      renderText(FS22_EnhancedVehicle.misc.posX, FS22_EnhancedVehicle.misc.posY, fS, misc_txt)
    end

    -- ### do the rpm stuff ###
    if self.spec_motorized ~= nil and FS22_EnhancedVehicle.rpm.enabled then
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
      renderText(FS22_EnhancedVehicle.rpm.posX, FS22_EnhancedVehicle.rpm.posY, fS, rpm_txt)
    end

    -- ### do the temperature stuff ###
    if self.spec_motorized ~= nil and FS22_EnhancedVehicle.temp.enabled and self.isServer then
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
      renderText(FS22_EnhancedVehicle.temp.posX, FS22_EnhancedVehicle.temp.posY, fS, temp_txt)
    end

    -- ### do the differential stuff ###
    if FS22_EnhancedVehicle.functionDifferentialIsEnabled and self.spec_motorized ~= nil and FS22_EnhancedVehicle.diff.enabled then
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
      w, h = getNormalizedScreenValues(FS22_EnhancedVehicle.diff_overlayWidth / FS22_EnhancedVehicle.diff.zoomFactor * FS22_EnhancedVehicle.uiScale, FS22_EnhancedVehicle.diff_overlayHeight / FS22_EnhancedVehicle.diff.zoomFactor * FS22_EnhancedVehicle.uiScale)
      setOverlayColor(FS22_EnhancedVehicle.overlay["diff_front"], unpack(FS22_EnhancedVehicle.color[_txt.color[1]]))
      setOverlayColor(FS22_EnhancedVehicle.overlay["diff_back"],  unpack(FS22_EnhancedVehicle.color[_txt.color[2]]))
      setOverlayColor(FS22_EnhancedVehicle.overlay["diff_dm"],    unpack(FS22_EnhancedVehicle.color[_txt.color[3]]))

      renderOverlay(FS22_EnhancedVehicle.overlay["diff_bg"],    FS22_EnhancedVehicle.diff.posX, FS22_EnhancedVehicle.diff.posY, w, h)
      renderOverlay(FS22_EnhancedVehicle.overlay["diff_front"], FS22_EnhancedVehicle.diff.posX, FS22_EnhancedVehicle.diff.posY, w, h)
      renderOverlay(FS22_EnhancedVehicle.overlay["diff_back"],  FS22_EnhancedVehicle.diff.posX, FS22_EnhancedVehicle.diff.posY, w, h)
      renderOverlay(FS22_EnhancedVehicle.overlay["diff_dm"],    FS22_EnhancedVehicle.diff.posX, FS22_EnhancedVehicle.diff.posY, w, h)
    end

    -- reset text stuff to "defaults"
    setTextColor(1,1,1,1)
    setTextAlignment(RenderText.ALIGN_LEFT)
    setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
    setTextBold(false)
  end

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
  end

  -- receive initial data from server
  self.vData.is[1] = streamReadBool(streamId)    -- front diff
  self.vData.is[2] = streamReadBool(streamId)    -- back diff
  self.vData.is[3] = streamReadInt8(streamId)    -- drive mode
  self.vData.is[4] = streamReadFloat32(streamId) -- snap angle
  self.vData.is[5] = streamReadBool(streamId)    -- snap.enable

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
    streamWriteBool(streamId, self.vData.want[1])
    streamWriteBool(streamId, self.vData.want[2])
    streamWriteInt8(streamId, self.vData.want[3])
    streamWriteFloat32(streamId, self.vData.want[4])
    streamWriteBool(streamId, self.vData.want[5])
  else
    streamWriteBool(streamId, self.vData.is[1])
    streamWriteBool(streamId, self.vData.is[2])
    streamWriteInt8(streamId, self.vData.is[3])
    streamWriteFloat32(streamId, self.vData.is[4])
    streamWriteBool(streamId, self.vData.is[5])
  end
end

-- #############################################################################

function FS22_EnhancedVehicle:onEnterVehicle()
  if debug > 1 then print("-> " .. myName .. ": onEnterVehicle" .. mySelf(self)) end

--  print(DebugUtil.printTableRecursively(self, 0, 0, 2))
end

-- #############################################################################

function FS22_EnhancedVehicle:onLeaveVehicle()
  if debug > 1 then print("-> " .. myName .. ": onLeaveVehicle" .. mySelf(self)) end

  -- disable snap if you leave a vehicle
  if self.vData.is[5] then
    self.vData.want[5] = false
    if self.isClient and not self.isServer then
      self.vData.is[5] = self.vData.want[5]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  end

--  print(DebugUtil.printTableRecursively(self, 0, 0, 2))
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
    if FS22_EnhancedVehicle.functionDifferentialIsEnabled then
      for _, v in ipairs(FS22_EnhancedVehicle.actions.diff) do
        table.insert(actionList, v)
      end
    end
    if FS22_EnhancedVehicle.functionHydraulicIsEnabled then
      for _, v in ipairs(FS22_EnhancedVehicle.actions.hydraulic) do
        table.insert(actionList, v)
      end
    end

    -- attach our actions
    for _ ,actionName in pairs(actionList) do
      local _, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, FS22_EnhancedVehicle.onActionCall, false, true, false, true)
      -- help menu priorization
      if g_inputBinding ~= nil and g_inputBinding.events ~= nil and g_inputBinding.events[eventName] ~= nil then
        g_inputBinding.events[eventName].displayPriority = 98
        if actionName == "FS22_EnhancedVehicle_DM" then g_inputBinding.events[eventName].displayPriority = 99 end
        -- don't show certain/all keys in help menu
        if actionName == "FS22_EnhancedVehicle_RESET" or actionName == "FS22_EnhancedVehicle_RELOAD" or utf8Substr(actionName, 0, 29) == "FS22_EnhancedVehicle_SNAP_INC" or utf8Substr(actionName, 0, 29) == "FS22_EnhancedVehicle_SNAP_DEC" or not FS22_EnhancedVehicle.showKeysInHelpMenu then
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
  if FS22_EnhancedVehicle.functionDifferentialIsEnabled and actionName == "FS22_EnhancedVehicle_FD" then
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
  if FS22_EnhancedVehicle.functionDifferentialIsEnabled and actionName == "FS22_EnhancedVehicle_RD" then
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
  if FS22_EnhancedVehicle.functionDifferentialIsEnabled and actionName == "FS22_EnhancedVehicle_BD" then
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
  if FS22_EnhancedVehicle.functionDifferentialIsEnabled and actionName == "FS22_EnhancedVehicle_DM" then
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

  -- toggle dmg/fuel display
  if actionName == "FS22_EnhancedVehicle_TOGGLE_DISPLAY" then
    if (FS22_EnhancedVehicle.fuel.enabled) then
      FS22_EnhancedVehicle.fuel.enabled = false
      FS22_EnhancedVehicle.dmg.enabled = false
    else
      FS22_EnhancedVehicle.fuel.enabled = true
      FS22_EnhancedVehicle.dmg.enabled = true
    end
    lC:writeConfig()
  end

  local _snap = false
  -- steering angle snap on/off
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_ONOFF" then
    if not self.vData.is[5] then
      if FS22_EnhancedVehicle.sounds["snap_on"] ~= nil and FS22_EnhancedVehicle.soundIsOn and g_dedicatedServerInfo == nil then
        playSample(FS22_EnhancedVehicle.sounds["snap_on"], 1, 0.1, 0, 0, 0)
      end
      self.vData.want[5] = true
      self.vData.want[4] = Round(self.vData.rot, 0)
    else
      self.vData.want[5] = false
    end
    _snap = true
  end
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
    self.vData.want[4] = Round(self.vData.want[4] + 180, 0)
    if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
    self.vData.want[5] = true
    _snap = true
  end
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_INC1" then
    self.vData.want[4] = Round(self.vData.want[4] + 1, 0)
    if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
    _snap = true
  end
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_DEC1" then
    self.vData.want[4] = Round(self.vData.want[4] - 1, 0)
    if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
    _snap = true
  end
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_INC3" then
    self.vData.want[4] = Round(self.vData.want[4] + 45.0, 0)
    if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
    _snap = true
  end
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_DEC3" then
    self.vData.want[4] = Round(self.vData.want[4] - 45.0, 0)
    if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
    _snap = true
  end
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_INC2" then
    self.vData.want[4] = Round(self.vData.want[4] + 22.5, 1)
    if self.vData.want[4] >= 360 then self.vData.want[4] = self.vData.want[4] - 360 end
    _snap = true
  end
  if FS22_EnhancedVehicle.functionSnapIsEnabled and actionName == "FS22_EnhancedVehicle_SNAP_DEC2" then
    self.vData.want[4] = Round(self.vData.want[4] - 22.5, 1)
    if self.vData.want[4] < 0 then self.vData.want[4] = self.vData.want[4] + 360 end
    _snap = true
  end

  -- disable steering angle snap if user interacts
  if actionName == "AXIS_MOVE_SIDE_VEHICLE" and math.abs( keyStatus ) > 0.05 then
    if self.vData.is[5] then
      self.vData.want[5] = false
      _snap = true
    end
  end

  if _snap then
    if self.isClient and not self.isServer then
      self.vData.is[4] = self.vData.want[4]
      self.vData.is[5] = self.vData.want[5]
    end
    FS22_EnhancedVehicle_Event.sendEvent(self, unpack(self.vData.want))
  end

  -- reset config
  if actionName == "FS22_EnhancedVehicle_RESET" then
    FS22_EnhancedVehicle:resetConfig()
    lC:writeConfig()
    FS22_EnhancedVehicle:activateConfig()
  end

  -- reload config
  if actionName == "FS22_EnhancedVehicle_RELOAD" then
    lC:readConfig()
    FS22_EnhancedVehicle:activateConfig()
  end

  -- debug stuff
  if FS22_dbg then
    -- debug1
    if actionName == "FS22_DBG1_UP" then
      FS22_dbg1 = FS22_dbg1 + 0.01
      updateDifferential(self.rootNode, 2, FS22_dbg1, FS22_dbg2)
    end
    if actionName == "FS22_DBG1_DOWN" then
      FS22_dbg1 = FS22_dbg1 - 0.01
      updateDifferential(self.rootNode, 2, FS22_dbg1, FS22_dbg2)
    end
    -- debug2
    if actionName == "FS22_DBG2_UP" then
      FS22_dbg2 = FS22_dbg2 + 0.01
      updateDifferential(self.rootNode, 2, FS22_dbg1, FS22_dbg2)
    end
    if actionName == "FS22_DBG2_DOWN" then
      FS22_dbg2 = FS22_dbg2 - 0.01
      updateDifferential(self.rootNode, 2, FS22_dbg1, FS22_dbg2)
    end
    -- debug3
    if actionName == "FS22_DBG3_UP" then
      FS22_dbg3 = FS22_dbg3 + 0.01
    end
    if actionName == "FS22_DBG3_DOWN" then
      FS22_dbg3 = FS22_dbg3 - 0.01
    end
  end

end

-- #############################################################################

function FS22_EnhancedVehicle:enumerateAttachments2(rootNode, obj)
  if debug > 1 then print("entering: "..obj.rootNode) end

  local idx, attacherJoint
  local relX, relY, relZ

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
      dmg_txt2 = string.format("%s: %.1f%% | %.1f%%", implement.object.typeDesc, (tA * 100), (tL * 100)) .. "\n" .. dmg_txt2
      h = h + (FS22_EnhancedVehicle.fontSize + FS22_EnhancedVehicle.textPadding) * FS22_EnhancedVehicle.uiScale
      if implement.object.spec_attacherJoints ~= nil then
        getDmg(implement.object)
      end
    end
  end
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
        -- get current rotation of vehicle
        local lx,_,lz = localDirectionToWorld(self.rootNode, 0, 0, 1)
        local rot = 180 - math.deg(math.atan2(lx, lz))

        -- if cabin is rotated -> direction should rotate also
        if self.spec_drivable.reverserDirection < 0 then
          rot = rot + 180
          if rot >= 360 then rot = rot - 360 end
        end
        rot = Round(rot, 1)
        self.vData.rot = rot

        -- if wanted direction is different than current direction
        if self.vData.rot ~= self.vData.is[4] then

          -- calculate degree difference between "is" and "wanted" (from -180 to 180)
          local _w1 = self.vData.is[4]
          if _w1 > 180 then _w1 = _w1 - 360 end
          local _w2 = self.vData.rot
          if _w2 > 180 then _w2 = _w2 - 360 end
          local diffdeg = _w1 - _w2
          if diffdeg > 180 then diffdeg = diffdeg - 360 end
          if diffdeg < -180 then diffdeg = diffdeg + 360 end

          -- get movingDirection (1=forward, 0=nothing, -1=reverse)
          local movingDirection = 0
          if g_currentMission.missionInfo.stopAndGoBraking then
            movingDirection = self.movingDirection * self.spec_drivable.reverserDirection
            if math.abs( self.lastSpeed ) < 0.000278 then
              movingDirection = 0
            end
          else
            movingDirection = Utils.getNoNil(self.nextMovingDirection * self.spec_drivable.reverserDirection)
          end

          -- "steering force"
          local delta = (0.75 / dt) * movingDirection

          -- calculate new steering wheel "direction"
          -- if we have still more than 20° to steer -> increase steering wheel constantly until maximum
          -- if in between -20 to 20 -> adjust steering wheel according to remaining degrees
          local a = self.vData.axisSidePrev
          if (diffdeg < -20) then
            a = a - delta
          end
          if (diffdeg > 20) then
            a = a + delta
          end
          if (diffdeg >= -20) and (diffdeg <= 20) then
            local newa = diffdeg / 20 * movingDirection
--            print("20 dd: "..diffdeg.." a: "..a.." newa: "..newa)
            if a < newa then a = a + delta * 1.4 * movingDirection end
            if a > newa then a = a - delta * 1.4 * movingDirection end
          end
          if (diffdeg >= -2) and (diffdeg <= 2) then
            a = diffdeg / 20 * movingDirection
--            print("2 dd: "..diffdeg.." a: "..a)
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
