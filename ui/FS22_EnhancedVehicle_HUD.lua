--
-- Mod: FS22_EnhancedVehicle_HUD
--
-- Author: Majo76
-- email: ls22@dark-world.de
-- @Date: 26.12.2021
-- @Version: 1.0.0.0

-- Thanks to Wopster for the inspiration to implement a HUD in this way
-- but unfortunately I can't use it that exact way (for now)

local myName = "FS22_EnhancedVehicle_HUD"

FS22_EnhancedVehicle_HUD = {}
local FS22_EnhancedVehicle_HUD_mt = Class(FS22_EnhancedVehicle_HUD)

FS22_EnhancedVehicle_HUD.SIZE = {
  TRACKBOX   = { 300, 50 },
  DIFFBOX    = {  32, 64 },
  MISCBOX    = { 200, 20 },
  DMGBOX     = { 200, 40 },
  ICONTRACK  = {  18, 18 },
  ICONDIFF   = {  32, 64 },
  MARGIN     = {   8,  8 },
  MARGINDMG  = {  15,  5 },
  MARGINFUEL = {  15,  5 },
}

FS22_EnhancedVehicle_HUD.UV = {
  BGTRACK     = {   0,  0, 300, 50 },
  BGDIFF      = { 384,  0,  32, 64 },
  BGMISC      = { 544,  0, 200, 20 },
  BGDMG       = { 544, 20, 200, 44 },
  ICON_SNAP   = {   0, 64,  64, 64 },
  ICON_TRACK  = {  64, 64,  64, 64 },
  ICON_HL1    = { 128, 64,  64, 64 },
  ICON_HL2    = { 192, 64,  64, 64 },
  ICON_HL3    = { 256, 64,  64, 64 },
  ICON_HLUP   = { 320, 64,  64, 64 },
  ICON_HLDOWN = { 384, 64,  64, 64 },
  ICON_DBG    = { 416,  0,  32, 64 },
  ICON_DDM    = { 448,  0,  32, 64 },
  ICON_DFRONT = { 480,  0,  32, 64 },
  ICON_DBACK  = { 512,  0,  32, 64 },
}

FS22_EnhancedVehicle_HUD.POSITION = {
  SNAP1       = { 150, 14 },
  SNAP2       = { 150, 41 },
  TRACK       = {  55, 13 },
  WORKWIDTH   = { 245, 13 },
  HLDISTANCE  = { 245, 40 },
  ICON_SNAP   = {  55-10-18, 29 },
  ICON_TRACK  = {  55+10, 29 },
  ICON_HLMODE = { 245-24-18, 29 },
  ICON_HLDIR  = { 245+24, 29 },
  ICON_DIFF   = {   0, 0 },
  DMG         = { -15, 5 },
  FUEL        = {  15, 5 },
  MISC        = { 100, 5 },
  RPM         = { -42, 0 },
  TEMP        = {  42, 0 },
}

FS22_EnhancedVehicle_HUD.COLOR = {
  INACTIVE = { 0.7, 0.7, 0.7, 1 },
  ACTIVE   = { 0, 1, 0, 1 },
}

FS22_EnhancedVehicle_HUD.TEXT_SIZE = {
  SNAP       = 20,
  TRACK      = 12,
  WORKWIDTH  = 12,
  HLDISTANCE = 12,
  DMG        = 12,
  FUEL       = 12,
  MISC       = 13,
  RPM        = 10,
  TEMP       = 10,
}

-- #############################################################################

function FS22_EnhancedVehicle_HUD:new(speedMeterDisplay, gameInfoDisplay, modDirectory)
  if debug > 1 then print("-> " .. myName .. ": new ") end

  local self = setmetatable({}, FS22_EnhancedVehicle_HUD_mt)

  self.speedMeterDisplay = speedMeterDisplay
  self.gameInfoDisplay   = gameInfoDisplay
  self.modDirectory      = modDirectory
  self.vehicle           = nil
  self.uiFilename        = Utils.getFilename("resources/HUD.dds", modDirectory)

  -- for icons
  self.icons = {}
  self.iconIsActive = { snap = nil, track = nil, hlmode = nil, hldir = nil }

  -- for text displays
  self.snapText1            = {}
  self.snapText2            = {}
  self.trackText            = {}
  self.headlandText         = {}
  self.workWidthText        = {}
  self.headlandDistanceText = {}
  self.dmgText              = {}
  self.fuelText             = {}
  self.miscText             = {}
  self.rpmText              = {}
  self.tempText             = {}

  self.default_track_txt     = g_i18n:getText("hud_FS22_EnhancedVehicle_notrack")
  self.default_headland_txt  = g_i18n:getText("hud_FS22_EnhancedVehicle_noheadland")
  self.default_workwidth_txt = g_i18n:getText("hud_FS22_EnhancedVehicle_nowidth")
  self.default_dmg_txt       = g_i18n:getText("hud_FS22_EnhancedVehicle_header_dmg")
  self.default_fuel_txt      = g_i18n:getText("hud_FS22_EnhancedVehicle_header_fuel")

  -- hook into some original HUD functions
--  SpeedMeterDisplay.storeScaledValues = Utils.appendedFunction(SpeedMeterDisplay.storeScaledValues, FS22_EnhancedVehicle_HUD.speedMeterDisplay_storeScaledValues)
--  SpeedMeterDisplay.draw              = Utils.appendedFunction(SpeedMeterDisplay.draw, FS22_EnhancedVehicle_HUD.speedMeterDisplay_draw)

  return self
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:delete()
  if debug > 1 then print("-> " .. myName .. ": delete ") end

  if self.trackBox ~= nil then
    self.trackBox:delete()
  end

  if self.diffBox ~= nil then
    self.diffBox:delete()
  end
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:load()
  if debug > 1 then print("-> " .. myName .. ": load ") end

  self:createElements()
  self:setVehicle(nil)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:createElements()
  if debug > 1 then print("-> " .. myName .. ": createElements ") end

  -- get position & size of speedmeter gauge element
  local baseX, baseY = self.speedMeterDisplay.gaugeBackgroundElement:getPosition()
  local width = self.speedMeterDisplay.gaugeBackgroundElement:getWidth()
  local height = self.speedMeterDisplay.gaugeBackgroundElement:getHeight()

  -- create our track box
  self:createTrackBox(baseX + width / 2, baseY + height)

  -- create our diff box
  self:createDiffBox(baseX + width / 2, baseY + height)

  -- create our misc box
  self:createMiscBox(baseX + width / 2, baseY)

  -- get position & size of gameinfodisplay element
  local baseX, baseY = self.gameInfoDisplay:getPosition()
  self.marginWidth, self.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.MARGIN)

  -- create our damage box
  self:createDamageBox(1, baseY - self.marginHeight)

  -- create our damage box
  self:createFuelBox(1, baseY - self.marginHeight)

  -- update some positions
  self:storeScaledValues()
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:createTrackBox(x, y)
  if debug > 1 then print("-> " .. myName .. ": createTrackBox ") end

  -- prepare
  local iconWidth, iconHeight = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.ICONTRACK)
  local boxWidth, boxHeight = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.TRACKBOX)
  x = x - boxWidth / 2

  -- add background overlay box
  local boxOverlay = Overlay.new(self.uiFilename, x, y, boxWidth, boxHeight)
  local boxElement = HUDElement.new(boxOverlay)
  self.trackBox = boxElement
  self.trackBox:setUVs(GuiUtils.getUVs(FS22_EnhancedVehicle_HUD.UV.BGTRACK))
  self.trackBox:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
  self.trackBox:setVisible(false)
  self.speedMeterDisplay:addChild(boxElement)

  -- add snap icon
  local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.ICON_SNAP)
  self.icons.snap = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_SNAP)
  self.icons.snap:setVisible(true)
  self.trackBox:addChild(self.icons.snap)

  -- add track icon
  local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.ICON_TRACK)
  self.icons.track = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_TRACK)
  self.icons.track:setVisible(true)
  self.trackBox:addChild(self.icons.track)

  -- add headland mode icons
  local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.ICON_HLMODE)
  self.icons.hl1 = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_HL1)
  self.icons.hl1:setVisible(false)
  self.trackBox:addChild(self.icons.hl1)
  self.icons.hl2 = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_HL2)
  self.icons.hl2:setVisible(false)
  self.trackBox:addChild(self.icons.hl2)
  self.icons.hl3 = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_HL3)
  self.icons.hl3:setVisible(false)
  self.trackBox:addChild(self.icons.hl3)

  -- add headland direction icons
  local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.ICON_HLDIR)
  self.icons.hlup = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_HLUP)
  self.icons.hlup:setVisible(false)
  self.icons.hlup:setColor(unpack(FS22_EnhancedVehicle_HUD.COLOR.INACTIVE))
  self.trackBox:addChild(self.icons.hlup)
  self.icons.hldown = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_HLDOWN)
  self.icons.hldown:setVisible(false)
  self.icons.hldown:setColor(unpack(FS22_EnhancedVehicle_HUD.COLOR.INACTIVE))
  self.trackBox:addChild(self.icons.hldown)

end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:createDiffBox(x, y)
  if debug > 1 then print("-> " .. myName .. ": createDiffBox ") end

  -- prepare
  local marginWidth, marginHeight = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.MARGIN)
  local iconWidth, iconHeight = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.ICONDIFF)
  local boxWidth, boxHeight = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.TRACKBOX)
  x = x - boxWidth / 2
  local boxWidth, boxHeight = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.DIFFBOX)
  y = y - boxHeight - marginHeight

  -- add background overlay box
  local boxOverlay = Overlay.new(self.uiFilename, x, y, boxWidth, boxHeight)
  local boxElement = HUDElement.new(boxOverlay)
  self.diffBox = boxElement
  self.diffBox:setUVs(GuiUtils.getUVs(FS22_EnhancedVehicle_HUD.UV.BGDIFF))
  self.diffBox:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
  self.diffBox:setVisible(false)
  self.speedMeterDisplay:addChild(boxElement)

  -- add diff icons
  local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.ICON_DIFF)
  self.icons.diff_bg = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_DBG)
  self.icons.diff_bg:setVisible(true)
  self.icons.diff_bg:setColor(0, 0, 0, 1)
  self.diffBox:addChild(self.icons.diff_bg)
  self.icons.diff_dm = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_DDM)
  self.icons.diff_dm:setVisible(true)
  self.diffBox:addChild(self.icons.diff_dm)
  self.icons.diff_front = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_DFRONT)
  self.icons.diff_front:setVisible(true)
  self.diffBox:addChild(self.icons.diff_front)
  self.icons.diff_back = self:createIcon(x + iconPosX, y + iconPosY, iconWidth, iconHeight, FS22_EnhancedVehicle_HUD.UV.ICON_DBACK)
  self.icons.diff_back:setVisible(true)
  self.diffBox:addChild(self.icons.diff_back)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:createMiscBox(x, y)
  if debug > 1 then print("-> " .. myName .. ": createMiscBox ") end

  -- prepare
  local boxWidth, boxHeight = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.MISCBOX)
  x = x - boxWidth / 2
  y = y - boxHeight

  -- add background overlay box
  local boxOverlay = Overlay.new(self.uiFilename, x, y, boxWidth, boxHeight)
  local boxElement = HUDElement.new(boxOverlay)
  self.miscBox = boxElement
  self.miscBox:setUVs(GuiUtils.getUVs(FS22_EnhancedVehicle_HUD.UV.BGMISC))
  self.miscBox:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
  self.miscBox:setVisible(false)
  self.speedMeterDisplay:addChild(boxElement)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:createDamageBox(x, y)
  if debug > 1 then print("-> " .. myName .. ": createDamageBox ") end

  -- add background overlay box
  local boxOverlay = Overlay.new(self.uiFilename, x, y, 1, 1)
  local boxElement = HUDElement.new(boxOverlay)
  self.dmgBox = boxElement
  self.dmgBox:setUVs(GuiUtils.getUVs(FS22_EnhancedVehicle_HUD.UV.BGDMG))
  self.dmgBox:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
  self.dmgBox:setVisible(false)
  self.gameInfoDisplay:addChild(boxElement)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:createFuelBox(x, y)
  if debug > 1 then print("-> " .. myName .. ": createFuelBox ") end

  -- add background overlay box
  local boxOverlay = Overlay.new(self.uiFilename, x, y, 1, 1)
  local boxElement = HUDElement.new(boxOverlay)
  self.fuelBox = boxElement
  self.fuelBox:setUVs(GuiUtils.getUVs(FS22_EnhancedVehicle_HUD.UV.BGDMG))
  self.fuelBox:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
  self.fuelBox:setVisible(false)
  self.gameInfoDisplay:addChild(boxElement)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:createIcon(baseX, baseY, width, height, uvs)
  if debug > 2 then print("-> " .. myName .. ": createIcon ") end

  local iconOverlay = Overlay.new(self.uiFilename, baseX, baseY, width, height)
  iconOverlay:setUVs(GuiUtils.getUVs(uvs))
  local element = HUDElement.new(iconOverlay)

  element:setVisible(false)

  return element
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:storeScaledValues()
  if debug > 2 then print("-> " .. myName .. ": storeScaledValues ") end

  -- overwrite from config file
  FS22_EnhancedVehicle_HUD.TEXT_SIZE.DMG  = FS22_EnhancedVehicle.hud.dmg.fontSize
  FS22_EnhancedVehicle_HUD.TEXT_SIZE.FUEL = FS22_EnhancedVehicle.hud.fuel.fontSize

  local baseX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX
  local baseY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
  local width = self.speedMeterDisplay.gaugeBackgroundElement:getWidth()
  local height = self.speedMeterDisplay.gaugeBackgroundElement:getHeight()

  if self.trackBox ~= nil then
    -- some globals
--    local boxPosX, boxPosY = self.trackBox:getPosition()
    local boxWidth, boxHeight = self.trackBox:getWidth(), self.trackBox:getHeight()
    local boxPosX = baseX - boxWidth / 2
    local boxPosY = baseY + height / 2

    -- snap text
    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.SNAP1)
    self.snapText1.posX = boxPosX + textX
    self.snapText1.posY = boxPosY + textY
    self.snapText1.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.SNAP)

    -- additional snap text
    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.SNAP2)
    self.snapText2.posX = boxPosX + textX
    self.snapText2.posY = boxPosY + textY
    self.snapText2.size = self.snapText1.size

    -- track text
    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.TRACK)
    self.trackText.posX = boxPosX + textX
    self.trackText.posY = boxPosY + textY
    self.trackText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.TRACK)

    -- workwidth text
    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.WORKWIDTH)
    self.workWidthText.posX = boxPosX + textX
    self.workWidthText.posY = boxPosY + textY
    self.workWidthText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.WORKWIDTH)

    -- headland distance text
    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.HLDISTANCE)
    self.headlandDistanceText.posX = boxPosX + textX
    self.headlandDistanceText.posY = boxPosY + textY
    self.headlandDistanceText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.HLDISTANCE)

    -- for dmg and fuel display
    local addPosX = boxPosX + boxWidth / 2
    local addPosY = boxPosY
    if FS22_EnhancedVehicle.functionSnapIsEnabled and FS22_EnhancedVehicle.hud.track.enabled then
      addPosY = addPosY + boxHeight
    end

    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.DMG)
    self.dmgText.posX = addPosX + textX
    self.dmgText.posY = addPosY + textY
    self.dmgText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.DMG)

    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.FUEL)
    self.fuelText.posX = addPosX + textX
    self.fuelText.posY = addPosY + textY
    self.fuelText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.FUEL)
  end

  if self.dmgBox ~= nil and FS22_EnhancedVehicle.hud.dmgfuelPosition == 2 then
    local baseX, baseY = self.gameInfoDisplay:getPosition()
    self.dmgText.posX = 1
    self.dmgText.posY = baseY - self.marginHeight
    self.dmgText.marginWidth, self.dmgText.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.MARGINDMG)
    self.dmgText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.DMG)
  end

  if self.fuelBox ~= nil and FS22_EnhancedVehicle.hud.dmgfuelPosition == 2 then
    local baseX, baseY = self.gameInfoDisplay:getPosition()
    self.fuelText.posX = 1
    self.fuelText.posY = baseY - self.marginHeight
    self.fuelText.marginWidth, self.fuelText.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.SIZE.MARGINFUEL)
    self.fuelText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.FUEL)
  end

  if self.miscBox ~= nil then
    -- some globals
    local boxWidth, boxHeight = self.miscBox:getWidth(), self.miscBox:getHeight()
    local boxPosX = baseX - boxWidth / 2
    local boxPosY = baseY - height / 2 - boxHeight

    -- misc text
    local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.MISC)
    self.miscText.posX = boxPosX + textX
    self.miscText.posY = boxPosY + textY
    self.miscText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.MISC)
  end

  -- rpm & temp
  local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.RPM)
  self.rpmText.posX = baseX + textX
  self.rpmText.posY = baseY + textY
  self.rpmText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.RPM)

  local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(FS22_EnhancedVehicle_HUD.POSITION.TEMP)
  self.tempText.posX = baseX + textX
  self.tempText.posY = baseY + textY
  self.tempText.size = self.speedMeterDisplay:scalePixelToScreenHeight(FS22_EnhancedVehicle_HUD.TEXT_SIZE.TEMP)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:setVehicle(vehicle)
  if debug > 2 then print("-> " .. myName .. ": setVehicle ") end

  self.vehicle = vehicle
  if self.trackBox ~= nil then
    self.trackBox:setVisible(vehicle ~= nil)
  end
  if self.diffBox ~= nil then
    self.diffBox:setVisible(vehicle ~= nil)
  end
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:hideSomething()
  if debug > 2 then print("-> " .. myName .. ": hideSomething ") end

  self.dmgBox:setVisible(false)
  self.fuelBox:setVisible(false)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD:drawHUD()
  if debug > 2 then print("-> " .. myName .. ": drawHUD ") end

  -- jump out if we're not ready
  if self.vehicle == nil or not self.speedMeterDisplay.isVehicleDrawSafe or g_dedicatedServerInfo ~= nil or not self.vehicle:getIsControlled() then return end

  if not FS22_EnhancedVehicle.functionSnapIsEnabled then
    self.trackBox:setVisible(false)
  else
    self.trackBox:setVisible(FS22_EnhancedVehicle.hud.track.enabled == true)
  end

  if not FS22_EnhancedVehicle.functionDiffIsEnabled then
    self.diffBox:setVisible(false)
  else
    self.diffBox:setVisible(FS22_EnhancedVehicle.hud.diff.enabled == true)
  end

  self.dmgBox:setVisible(FS22_EnhancedVehicle.hud.dmg.enabled == true and FS22_EnhancedVehicle.hud.dmgfuelPosition == 2)
  self.fuelBox:setVisible(FS22_EnhancedVehicle.hud.fuel.enabled == true and FS22_EnhancedVehicle.hud.dmgfuelPosition == 2)
  self.miscBox:setVisible(FS22_EnhancedVehicle.hud.misc.enabled == true)

  -- draw our track HUD
  if self.trackBox:getVisible() then
    -- snap icon
    if self.iconIsActive.snap ~= self.vehicle.vData.is[5] then
      self.iconIsActive.snap = self.vehicle.vData.is[5]
      local color = self.iconIsActive.snap and FS22_EnhancedVehicle_HUD.COLOR.ACTIVE or FS22_EnhancedVehicle_HUD.COLOR.INACTIVE
      self.icons.snap:setColor(unpack(color))
    end

    -- track icon
    if self.iconIsActive.track ~= self.vehicle.vData.is[6] then
      self.iconIsActive.track = self.vehicle.vData.is[6]
      local color = self.iconIsActive.track and FS22_EnhancedVehicle_HUD.COLOR.ACTIVE or FS22_EnhancedVehicle_HUD.COLOR.INACTIVE
      self.icons.track:setColor(unpack(color))
    end

    -- without usable track data -> hide icons
    if not self.vehicle.vData.track.isCalculated then
      self.icons.hl1:setVisible(false)
      self.icons.hl2:setVisible(false)
      self.icons.hl3:setVisible(false)
      self.icons.hlup:setVisible(false)
      self.icons.hldown:setVisible(false)
    else
      -- headland mode icon
      local color = self.iconIsActive.track and FS22_EnhancedVehicle_HUD.COLOR.ACTIVE or FS22_EnhancedVehicle_HUD.COLOR.INACTIVE
      local _b1, _b2, _b3 = false, false, false
      if self.vehicle.vData.track.headlandMode == 1 then
        _b1 = true
      elseif self.vehicle.vData.track.headlandMode == 2 then
        _b2 = true
      elseif self.vehicle.vData.track.headlandMode == 3 then
        _b3 = true
      end
      self.icons.hl1:setVisible(_b1)
      self.icons.hl2:setVisible(_b2)
      self.icons.hl3:setVisible(_b3)

      -- headland distance icon
      local distance = self.vehicle.vData.track.headlandDistance
      if distance == 9999 and self.vehicle.vData.track.workWidth ~= nil then
        distance = self.vehicle.vData.track.workWidth
      end
      if distance >= 0 then
        self.icons.hlup:setVisible(true)
        self.icons.hldown:setVisible(false)
      else
        self.icons.hlup:setVisible(false)
        self.icons.hldown:setVisible(true)
      end
    end

    -- snap degree display
    if self.vehicle.vData.rot ~= nil then
      -- prepare text
      snap_txt2 = ''
      if self.vehicle.vData.is[5] then
        snap_txt = string.format("%.1f°", self.vehicle.vData.is[4])
        if (Round(self.vehicle.vData.rot, 0) ~= Round(self.vehicle.vData.is[4], 0)) then
          snap_txt2 = string.format("%.1f°", self.vehicle.vData.rot)
        end
      else
        snap_txt = string.format("%.1f°", self.vehicle.vData.rot)
      end

      -- render text
      setTextAlignment(RenderText.ALIGN_CENTER)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_MIDDLE)
      setTextBold(true)

      local color = self.vehicle.vData.is[5] and FS22_EnhancedVehicle_HUD.COLOR.ACTIVE or FS22_EnhancedVehicle_HUD.COLOR.INACTIVE
      setTextColor(unpack(color))

      renderText(self.snapText1.posX, self.snapText1.posY, self.snapText1.size, snap_txt)

      if (snap_txt2 ~= "") then
        setTextColor(1,1,1,1)
        renderText(self.snapText2.posX, self.snapText2.posY, self.snapText2.size, snap_txt2)
      end
    end

    -- track display
    -- prepare text
    local track_txt     = self.default_track_txt
    local headland_txt  = self.default_headland_txt
    local workwidth_txt = self.default_workwidth_txt

    if self.vehicle.vData.track.isCalculated then
      _prefix = "+"
      if self.vehicle.vData.track.deltaTrack == 0 then _prefix = "+/-" end
      if self.vehicle.vData.track.deltaTrack < 0 then _prefix = "" end
      local _curTrack = Round(self.vehicle.vData.track.originalTrackLR, 0)
      track_txt = string.format("#%i → %s%i → %i", _curTrack, _prefix, self.vehicle.vData.track.deltaTrack, (_curTrack + self.vehicle.vData.track.deltaTrack))
      workwidth_txt = string.format("|← %.1fm →|", Round(self.vehicle.vData.track.workWidth, 1))
      local _tmp = self.vehicle.vData.track.headlandDistance
      if _tmp == 9999 then _tmp = Round(self.vehicle.vData.track.workWidth, 1) end
      headland_txt = string.format("%.1fm", math.abs(_tmp))
    elseif self.vehicle.vData.impl ~= nil then
      if self.vehicle.vData.impl.workWidth > 0 then
        workwidth_txt = string.format("|← %.1fm →|", Round(self.vehicle.vData.impl.workWidth, 1))
      end
    end

    -- render text
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_MIDDLE)
    setTextBold(false)

    local color = (self.vehicle.vData.is[5] and self.vehicle.vData.is[6]) and FS22_EnhancedVehicle_HUD.COLOR.ACTIVE or FS22_EnhancedVehicle_HUD.COLOR.INACTIVE
    self.icons.hl1:setColor(unpack(color))
    self.icons.hl2:setColor(unpack(color))
    self.icons.hl3:setColor(unpack(color))

    -- track number
    setTextColor(unpack(color))
    renderText(self.trackText.posX, self.trackText.posY, self.trackText.size, track_txt)

    -- working width
    setTextColor(unpack(FS22_EnhancedVehicle_HUD.COLOR.INACTIVE))
    renderText(self.workWidthText.posX, self.workWidthText.posY, self.workWidthText.size, workwidth_txt)

    -- headland distance
    renderText(self.headlandDistanceText.posX, self.headlandDistanceText.posY, self.headlandDistanceText.size, headland_txt)
  end -- <- end of draw track box

  -- draw our diff HUD
  if self.diffBox:getVisible() then
    if self.vehicle.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.diff.enabled then
      -- prepare
      local _txt = {}
      _txt.color = { "green", "green", "gray" }
      if self.vehicle.vData ~= nil then
        if self.vehicle.vData.is[1] then
          _txt.color[1] = "red"
        end
        if self.vehicle.vData.is[2] then
          _txt.color[2] = "red"
        end
        if self.vehicle.vData.is[3] == 0 then
          _txt.color[3] = "gray"
        end
        if self.vehicle.vData.is[3] == 1 then
          _txt.color[3] = "yellow"
        end
        if self.vehicle.vData.is[3] == 2 then
          _txt.color[3] = "gray"
        end
      end

      self.icons.diff_front:setColor(unpack(FS22_EnhancedVehicle.color[_txt.color[1]]))
      self.icons.diff_back:setColor(unpack(FS22_EnhancedVehicle.color[_txt.color[2]]))
      self.icons.diff_dm:setColor(unpack(FS22_EnhancedVehicle.color[_txt.color[3]]))
    end
  end

  -- move our elements down if game displays side notifications
  local deltaY = 0
  if g_currentMission.hud.sideNotifications ~= nil then
    if #g_currentMission.hud.sideNotifications.notificationQueue > 0 then
      deltaY = g_currentMission.hud.sideNotifications:getHeight()
    end
  end

  -- damage display
  if self.vehicle.spec_wearable ~= nil and FS22_EnhancedVehicle.hud.dmg.enabled then
    -- prepare text
    dmg_txt = { }

    -- add own vehicle dmg
    if self.vehicle.spec_wearable ~= nil then
      if not FS22_EnhancedVehicle.hud.dmg.showAmountLeft then
        table.insert(dmg_txt, { string.format("%s: %.1f%% | %.1f%%", self.vehicle.typeDesc, (self.vehicle.spec_wearable:getDamageAmount() * 100), (self.vehicle.spec_wearable:getWearTotalAmount() * 100)), 1 })
      else
        table.insert(dmg_txt, { string.format("%s: %.1f%% | %.1f%%", self.vehicle.typeDesc, (100 - (self.vehicle.spec_wearable:getDamageAmount() * 100)), (100 - (self.vehicle.spec_wearable:getWearTotalAmount() * 100))), 1 })
      end
    end

    if self.vehicle.spec_attacherJoints ~= nil then
      getDmg(self.vehicle.spec_attacherJoints)
    end

    -- prepare rendering
    setTextAlignment(RenderText.ALIGN_RIGHT)
    setTextBold(false)

    if FS22_EnhancedVehicle.hud.dmgfuelPosition <= 1 then
      -- classic display
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)

      local y = self.dmgText.posY
      for _, txt in pairs(dmg_txt) do
        if txt[2] == 2 then
          setTextColor(1,1,1,1)
        else
          setTextColor(unpack(FS22_EnhancedVehicle.color.dmg))
        end
        renderText(self.dmgText.posX, y, self.dmgText.size, txt[1])
        y = y + self.dmgText.size
      end
    elseif FS22_EnhancedVehicle.hud.dmgfuelPosition == 2 then
      -- top-right display
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)

      local x = self.dmgText.posX - self.dmgText.marginHeight
      local y = self.dmgText.posY - self.dmgText.marginHeight - deltaY
      local _w, _h = 0, self.dmgText.marginHeight * 2
      table.insert(dmg_txt, 1, { self.default_dmg_txt, 0 })
      for _, txt in pairs(dmg_txt) do
        if txt[2] == 0 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.lgray))
          setTextBold(true)
        elseif txt[2] == 2 then
          setTextColor(1,1,1,1)
        else
          setTextColor(unpack(FS22_EnhancedVehicle.color.dmg))
        end
        renderText(x, y, self.dmgText.size, txt[1])
        if txt[2] == 0 then
          setTextBold(false)
          y = y - self.dmgText.marginHeight
          _h = _h + self.dmgText.marginHeight
        end
        y = y - self.dmgText.size
        _h = _h + self.dmgText.size
        local tmp = getTextWidth(self.dmgText.size, txt[1])
        if tmp > _w then _w = tmp end
      end

      -- update overlay background
      self.dmgBox.overlay:setPosition(x - _w - self.dmgText.marginWidth, y - self.dmgText.marginHeight)
      self.dmgBox.overlay:setDimension(_w + self.dmgText.marginHeight + self.dmgText.marginWidth, _h)
      deltaY = deltaY + _h + self.marginHeight
    end
  end -- <- end of render damage

  -- fuel display
  if self.vehicle.spec_fillUnit ~= nil and FS22_EnhancedVehicle.hud.fuel.enabled then
    -- get values
    fuel_diesel_current   = -1
    fuel_adblue_current   = -1
    fuel_electric_current = -1
    fuel_methane_current  = -1

    for _, fillUnit in ipairs(self.vehicle.spec_fillUnit.fillUnits) do
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
    fuel_txt = { }
    if fuel_diesel_current >= 0 then
      table.insert(fuel_txt, { string.format("%.1f l/%.1f l", fuel_diesel_current, fuel_diesel_max), 1 })
    end
    if fuel_adblue_current >= 0 then
      table.insert(fuel_txt, { string.format("%.1f l/%.1f l", fuel_adblue_current, fuel_adblue_max), 2 })
    end
    if fuel_electric_current >= 0 then
      table.insert(fuel_txt, { string.format("%.1f kWh/%.1f kWh", fuel_electric_current, fuel_electric_max), 3 })
    end
    if fuel_methane_current >= 0 then
      table.insert(fuel_txt, { string.format("%.1f l/%.1f l", fuel_methane_current, fuel_methane_max), 4 })
    end
    if self.vehicle.spec_motorized.isMotorStarted == true and self.vehicle.isServer then
      if fuel_electric_current >= 0 then
        table.insert(fuel_txt, { string.format("%.1f kW/h", self.vehicle.spec_motorized.lastFuelUsage), 5 })
      else
        table.insert(fuel_txt, { string.format("%.1f l/h", self.vehicle.spec_motorized.lastFuelUsage), 5 })
      end
    end

    -- prepare rendering
    setTextBold(false)

    if FS22_EnhancedVehicle.hud.dmgfuelPosition <= 1 then
      -- classic
      setTextAlignment(RenderText.ALIGN_LEFT)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)

      local y = self.fuelText.posY
      for _, txt in pairs(fuel_txt) do
        if txt[2] == 1 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.fuel))
        elseif txt[2] == 2 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.adblue))
        elseif txt[2] == 3 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.electric))
        elseif txt[2] == 4 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.methane))
        else
          setTextColor(1,1,1,1)
        end
        renderText(self.fuelText.posX, y, self.fuelText.size, txt[1])
        y = y + self.fuelText.size
      end
    elseif FS22_EnhancedVehicle.hud.dmgfuelPosition == 2 then
      -- top-right display
      setTextAlignment(RenderText.ALIGN_RIGHT)
      setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)

      local x = self.fuelText.posX - self.fuelText.marginHeight
      local y = self.fuelText.posY - self.fuelText.marginHeight - deltaY
      local _w, _h = 0, self.fuelText.marginHeight * 2
      table.insert(fuel_txt, 1, { self.default_fuel_txt, 0 })
      for _, txt in pairs(fuel_txt) do
        if txt[2] == 0 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.lgray))
          setTextBold(true)
        elseif txt[2] == 1 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.fuel))
        elseif txt[2] == 2 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.adblue))
        elseif txt[2] == 3 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.electric))
        elseif txt[2] == 4 then
          setTextColor(unpack(FS22_EnhancedVehicle.color.methane))
        else
          setTextColor(1,1,1,1)
        end
        renderText(x, y, self.fuelText.size, txt[1])
        if txt[2] == 0 then
          setTextBold(false)
          y = y - self.fuelText.marginHeight
          _h = _h + self.fuelText.marginHeight
        end
        y = y - self.fuelText.size
        _h = _h + self.fuelText.size
        local tmp = getTextWidth(self.fuelText.size, txt[1])
        if tmp > _w then _w = tmp end
      end

      -- update overlay background
      self.fuelBox.overlay:setPosition(x - _w - self.fuelText.marginWidth, y - self.fuelText.marginHeight)
      self.fuelBox.overlay:setDimension(_w + self.fuelText.marginHeight + self.fuelText.marginWidth, _h)
    end
  end -- <- end of render fuel

  -- misc display
  if self.vehicle.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.misc.enabled then
    -- prepare text
    local misc_txt = string.format("%.1f", self.vehicle:getTotalMass(true)) .. "t (total: " .. string.format("%.1f", self.vehicle:getTotalMass()) .. " t)"

    -- render text
    setTextColor(1,1,1,1)
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BOTTOM)
    setTextBold(false)
    renderText(self.miscText.posX, self.miscText.posY, self.miscText.size, misc_txt)
  end

  -- rpm display
  if self.vehicle.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.rpm.enabled then
    -- prepare text
    local rpm_txt = "--\nrpm"
    if self.vehicle.spec_motorized.isMotorStarted == true then
      rpm_txt = string.format("%i\nrpm", self.vehicle.spec_motorized:getMotorRpmReal())
    end

    -- render text
    setTextColor(1,1,1,1)
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
    setTextBold(true)
    renderText(self.rpmText.posX, self.rpmText.posY, self.rpmText.size, rpm_txt)
  end

  -- temperature display
  if self.vehicle.spec_motorized ~= nil and FS22_EnhancedVehicle.hud.temp.enabled and self.vehicle.isServer then
    -- prepare text
    local temp_txt = "--\n°C"
    if self.vehicle.spec_motorized.isMotorStarted == true then
      temp_txt = string.format("%i\n°C", self.vehicle.spec_motorized.motorTemperature.value)
    end

    -- render text
    setTextColor(1,1,1,1)
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
    setTextBold(true)
    renderText(self.tempText.posX, self.tempText.posY, self.tempText.size, temp_txt)
  end

  -- reset text stuff to "defaults"
  setTextColor(1,1,1,1)
  setTextAlignment(RenderText.ALIGN_LEFT)
  setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
  setTextBold(false)
end

-- #############################################################################

function FS22_EnhancedVehicle_HUD.speedMeterDisplay_storeScaledValues(speedMeterDisplay)
  FS22_EnhancedVehicle.ui_hud:storeScaledValues()
end

function FS22_EnhancedVehicle_HUD.speedMeterDisplay_draw(speedMeterDisplay)
  FS22_EnhancedVehicle.ui_hud:drawHUD()
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
        table.insert(dmg_txt, { string.format("%s: %.1f%% | %.1f%%", implement.object.typeDesc, (100 - (tA * 100)), (100 - (tL * 100))), 2 })
      else
        table.insert(dmg_txt, { string.format("%s: %.1f%% | %.1f%%", implement.object.typeDesc, (tA * 100), (tL * 100)), 2 })
      end

      if implement.object.spec_attacherJoints ~= nil then
        getDmg(implement.object)
      end
    end
  end
end
