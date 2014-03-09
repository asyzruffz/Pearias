function init(args)
  entity.setAnimationState("antennaState", "idle")
  entity.setInteractive(true)
  if storage.peariasOtherPort == nil then
	storage.peariasOtherPort = {}
  end
end

function main()
  local itemIds = world.itemDropQuery(entity.position(), 20)
  if itemIds ~= nil then
	for _, itemId in pairs(itemIds) do
	  if world.entityName(itemId) == "peariasmemory" then
	    if storage.peariasStored == nil then
		  storage.peariasStored = world.takeItemDrop(itemId, entity.id())
		  --world.logInfo("Stored = %s", storage.peariasStored)
		  break
		end
	  end
	end
  end
  
  if storage.peariasOtherPort ~= nil then
    for _, storedPort in pairs(storage.peariasOtherPort) do
	  signalConnected(storedPort)
	end
  end
  
  if storage.peariasStored ~= nil then
    entity.setAnimationState("antennaState", "active")
  else
    entity.setAnimationState("antennaState", "idle")
  end
end

function onInteraction(args)
  --world.logInfo("Antenna interacted at %s! Contained = %s", args.sourcePosition, storage.peariasStored)
  if storage.peariasStored ~= nil then
    world.spawnItem(storage.peariasStored.name, entity.position(), 1, storage.peariasStored.data)
	--world.logInfo("Pearias memory spawned!")
	storage.peariasStored = nil
  end
end

function die()
  if storage.peariasStored ~= nil then
    world.spawnItem(storage.peariasStored.name, entity.position(), 1, storage.peariasStored.data)
	--world.logInfo("Pearias memory spawned!")
	storage.peariasStored = nil
  end
end

function antennaEmpty()
  return storage.peariasStored == nil
end

function signalConnected(anotherPortId)
  if next(storage.peariasOtherPort) == nil then
	table.insert(storage.peariasOtherPort, anotherPortId)
  else
	local shouldAdd = true
	for i, storedPort in pairs(storage.peariasOtherPort) do
	  if anotherPortId == storedPort then
		shouldAdd = false
	  end
	  if not world.entityExists(storedPort) then
		table.remove(storage.peariasOtherPort, storedPort)
		--storage.peariasOtherPort[i] = nil
	  end
	end
	if shouldAdd then
	  table.insert(storage.peariasOtherPort, anotherPortId)
	end
  end
  --world.logInfo("Port %s saves these ports %s", entity.id(), storage.peariasOtherPort)
  
  if world.callScriptedEntity(anotherPortId, "antennaEmpty") then
    --world.logInfo("Port %s says that port %s is empty.", entity.id(), anotherPortId)
	entity.setAnimationState("signalState", "active")
  elseif world.callScriptedEntity(anotherPortId, "antennaEmpty") == false then
    world.logInfo("Port %s can sense a Pearias at port %s.", entity.id(), anotherPortId)
	entity.setAnimationState("signalState", "active")
	
	local receivedPearias = world.callScriptedEntity(anotherPortId, "getPeariasData")
	if receivedPearias ~= nil then
	  local newSpawnId = world.spawnNpc(entity.toAbsolutePosition({ 0.0, 3.0 }), receivedPearias.data.dataMemory.species, receivedPearias.data.dataMemory.npcType, (receivedPearias.data.dataMemory.level or entity.level()), tonumber(receivedPearias.data.dataMemory.seed))
	  world.callScriptedEntity(newSpawnId, "loadData", receivedPearias.data.dataMemory)
	end
  else
    --world.logInfo("Port %s can't sense anything at port %s.", entity.id(), anotherPortId)
	entity.setAnimationState("signalState", "idle")
  end
end

function getPeariasData()
  if storage.peariasStored == nil then
    return nil
  else
    local tempPearias = storage.peariasStored
	storage.peariasStored = nil
	return tempPearias
  end
end