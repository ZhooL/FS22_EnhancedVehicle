--
-- Mod: FS22_EnhancedVehicle_Event
--
-- Author: Majo76
-- email: ls22@dark-world.de
-- @Date: 07.12.2021
-- @Version: 1.0.0.0

local myName = "FS22_EnhancedVehicle_Event"

-- #############################################################################

FS22_EnhancedVehicle_Event = {}
local FS22_EnhancedVehicle_Event_mt = Class(FS22_EnhancedVehicle_Event, Event)

InitEventClass(FS22_EnhancedVehicle_Event, "FS22_EnhancedVehicle_Event")

-- #############################################################################

function FS22_EnhancedVehicle_Event.emptyNew()
  if debug > 2 then print("-> " .. myName .. ": emptyNew()") end

  local self = Event.new(FS22_EnhancedVehicle_Event_mt)

  return self
end

-- #############################################################################

function FS22_EnhancedVehicle_Event.new(vehicle, b1, b2, i1, f1, b3, b4, f2, f3, f4, f5, f6, f7)
  local args = { b1, b2, i1, f1, b3, b4, f2, f3, f4, f5, f6, f7 }
  if debug > 2 then print("-> " .. myName .. ": new(): " .. lU:args_to_txt(unpack(args))) end

  local self = FS22_EnhancedVehicle_Event.emptyNew()
  self.vehicle = vehicle
  self.vehicle.vData.want = { unpack(args) }

  return self
end

-- #############################################################################

function FS22_EnhancedVehicle_Event:readStream(streamId, connection)
  if debug > 1 then print("-> " .. myName .. ": readStream() - " .. streamId) end

  self.vehicle               = NetworkUtil.readNodeObject(streamId);
  self.vehicle.vData.want[1] = streamReadBool(streamId);
  self.vehicle.vData.want[2] = streamReadBool(streamId);
  self.vehicle.vData.want[3] = streamReadInt8(streamId);
  self.vehicle.vData.want[4] = streamReadFloat32(streamId);
  self.vehicle.vData.want[5] = streamReadBool(streamId);
  self.vehicle.vData.want[6] = streamReadBool(streamId);
  self.vehicle.vData.want[7] = streamReadFloat32(streamId);
  self.vehicle.vData.want[8] = streamReadFloat32(streamId);
  self.vehicle.vData.want[9] = streamReadFloat32(streamId);
  self.vehicle.vData.want[10] = streamReadFloat32(streamId);
  self.vehicle.vData.want[11] = streamReadFloat32(streamId);
  self.vehicle.vData.want[12] = streamReadFloat32(streamId);

  self:run(connection)
end

-- #############################################################################

function FS22_EnhancedVehicle_Event:writeStream(streamId, connection)
  if debug > 1 then print("-> " .. myName .. ": writeStream() - " .. streamId) end

  NetworkUtil.writeNodeObject(streamId, self.vehicle);
  streamWriteBool(streamId,    self.vehicle.vData.want[1])
  streamWriteBool(streamId,    self.vehicle.vData.want[2])
  streamWriteInt8(streamId,    self.vehicle.vData.want[3])
  streamWriteFloat32(streamId, self.vehicle.vData.want[4])
  streamWriteBool(streamId,    self.vehicle.vData.want[5])
  streamWriteBool(streamId,    self.vehicle.vData.want[6])
  streamWriteFloat32(streamId, self.vehicle.vData.want[7])
  streamWriteFloat32(streamId, self.vehicle.vData.want[8])
  streamWriteFloat32(streamId, self.vehicle.vData.want[9])
  streamWriteFloat32(streamId, self.vehicle.vData.want[10])
  streamWriteFloat32(streamId, self.vehicle.vData.want[11])
  streamWriteFloat32(streamId, self.vehicle.vData.want[12])
end

-- #############################################################################

function FS22_EnhancedVehicle_Event:run(connection)
  if debug > 1 then print("-> " .. myName .. ": run()") end

  if g_server == nil then
    self.vehicle.vData.is = { unpack(self.vehicle.vData.want) }
  end

  if debug > 1 then print("--> " .. self.vehicle.rootNode .. " - (" .. lU:args_to_txt(unpack(self.vehicle.vData.is)).."|"..lU:args_to_txt(unpack(self.vehicle.vData.want))..")") end

  if not connection:getIsServer() then
    g_server:broadcastEvent(FS22_EnhancedVehicle_Event.new(self.vehicle, unpack(self.vehicle.vData.want)), nil, connection)
  end
end

-- #############################################################################

function FS22_EnhancedVehicle_Event.sendEvent(vehicle, b1, b2, i1, f1, b3, b4, f2, f3, f4, f5, f6, f7)
  local args = { b1, b2, i1, f1, b3, b4, f2, f3, f4, f5, f6, f7 }
  if debug > 1 then print("-> " .. myName .. ": sendEvent(): " .. lU:args_to_txt(unpack(args))) end
  
  if g_server ~= nil then
    if debug > 1 then print("--> g_server:broadcastEvent()") end
    g_server:broadcastEvent(FS22_EnhancedVehicle_Event.new(vehicle, unpack(args)), nil, nil, vehicle)
  else
    if debug > 1 then print("--> g_client:getServerConnection():sendEvent()") end
    g_client:getServerConnection():sendEvent(FS22_EnhancedVehicle_Event.new(vehicle, unpack(args)))
  end
end
