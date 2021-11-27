--
-- Mod: FS22_EnhancedVehicle_Loader
--
-- Author: Majo76
-- email: ls22@dark-world.de
-- @Date: 27.11.2021
-- @Version: 1.0.0.0

-- #############################################################################

debug = 0 -- 0=0ff, 1=some, 2=everything, 3=madness

local directory = g_currentModDirectory
local modName = g_currentModName

source(Utils.getFilename("FS22_EnhancedVehicle.lua", directory))
source(Utils.getFilename("FS22_EnhancedVehicle_Event.lua", directory))

-- include our libUtils
source(Utils.getFilename("libUtils.lua", g_currentModDirectory))
lU = libUtils()
lU:setDebug(0)

-- include our new libConfig XML management
source(Utils.getFilename("libConfig.lua", g_currentModDirectory))
lC = libConfig("FS22_EnhancedVehicle", 1, 0)
lC:setDebug(0)

local EnhancedVehicle

-- #############################################################################

function EV_init()
  if debug > 1 then print("EV_init()") end
  
  -- hook into early load
  Mission00.load = Utils.prependedFunction(Mission00.load, EV_load)

  -- hook into late unload
  FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, EV_unload)

  -- hook into validateTypes
  TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, EV_validateTypes)
end

-- #############################################################################

function EV_load()
  if debug > 1 then print("EV_load()") end
  
  -- create our EV class
  assert(g_EnhancedVehicle == nil)
  EnhancedVehicle = FS22_EnhancedVehicle:new(directory, modName)
  getfenv(0)["g_EnhancedVehicle"] = EnhancedVehicle

  addModEventListener(EnhancedVehicle);
end

-- #############################################################################

function EV_unload()
  if debug > 1 then print("EV_unload()") end

  removeModEventListener(EnhancedVehicle)
  
  EnhancedVehicle:delete()
  EnhancedVehicle = nil
  getfenv(0)["g_EnhancedVehicle"] = nil
end

-- #############################################################################

function EV_validateTypes(types)
  if debug > 1 then print("EV_validateTypes()") end
    
  -- attach only to vehicles
  if (types.typeName == 'vehicle') then
    FS22_EnhancedVehicle.installSpecializations(g_vehicleTypeManager, g_specializationManager, directory)
  end
end

-- #############################################################################

EV_init()
