--
-- Mod: FS22_EnhancedVehicle_Register
--
-- Author: Majo76
-- email: ls22@dark-world.de
-- @Date: 25.11.2021
-- @Version: 1.0.0.0

-- #############################################################################

source(Utils.getFilename("FS22_EnhancedVehicle.lua", g_currentModDirectory))
source(Utils.getFilename("FS22_EnhancedVehicle_Event.lua", g_currentModDirectory))

-- include our libUtils
source(Utils.getFilename("libUtils.lua", g_currentModDirectory))
lU = libUtils()
lU:setDebug(0)

-- include our new libConfig XML management
source(Utils.getFilename("libConfig.lua", g_currentModDirectory))
lC = libConfig("FS22_EnhancedVehicle", 1, 0)
lC:setDebug(0)

FS22_EnhancedVehicle_Register = {}
FS22_EnhancedVehicle_Register.modDirectory = g_currentModDirectory;

local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
FS22_EnhancedVehicle_Register.version = getXMLString(modDesc, "modDesc.version");

if g_specializationManager:getSpecializationByName("FS22_EnhancedVehicle") == nil then
  if FS22_EnhancedVehicle == nil then
    print("ERROR: unable to add specialization 'FS22_EnhancedVehicle'")
  else
    for typeName, typeDef in pairs(g_vehicleTypeManager.types) do
      if SpecializationUtil.hasSpecialization(Drivable,  typeDef.specializations) and 
         SpecializationUtil.hasSpecialization(Enterable, typeDef.specializations) and 
         SpecializationUtil.hasSpecialization(Motorized, typeDef.specializations) and
         not SpecializationUtil.hasSpecialization(Locomotive,     typeDef.specializations) and
         not SpecializationUtil.hasSpecialization(ConveyorBelt,   typeDef.specializations) and
         not SpecializationUtil.hasSpecialization(AIConveyorBelt, typeDef.specializations)
      then
        if debug > 1 then print("INFO: attached specialization 'FS22_EnhancedVehicle' to vehicleType '" .. tostring(typeName) .. "'") end
        typeDef.specializationsByName["FS22_EnhancedVehicle"] = FS22_EnhancedVehicle
        table.insert(typeDef.specializationNames, "FS22_EnhancedVehicle")
        table.insert(typeDef.specializations, FS22_EnhancedVehicle)
      end
    end
  end
end

-- #############################################################################

function FS22_EnhancedVehicle_Register:loadMap()
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

function FS22_EnhancedVehicle_Register:deleteMap()
  print("--> unloaded FS22_EnhancedVehicle version " .. self.version .. " (by Majo76) <--");
end

-- #############################################################################

function FS22_EnhancedVehicle_Register:keyEvent(unicode, sym, modifier, isDown)
end

-- #############################################################################

function FS22_EnhancedVehicle_Register:mouseEvent(posX, posY, isDown, isUp, button)
end

-- #############################################################################

function FS22_EnhancedVehicle_Register:update(dt)
end

-- #############################################################################

addModEventListener(FS22_EnhancedVehicle_Register);
