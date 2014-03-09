followState = {}

function followState.inRange()
  local maxRange = entity.configParameter("follow.teleportDistance", 20)

  if storage.peariasOwnerUuid == nil or self.ownerEntityId == nil then
	return true
  elseif world.entityExists(self.ownerEntityId) then
	ownerPosition = world.entityPosition(self.ownerEntityId)
	return world.magnitude(entity.position(), ownerPosition) < maxRange
  end
  return false
end

function followState.enter()
  if followState.inRange() then
	-- Getting owner uuid
	if storage.peariasOwnerUuid == nil then
      if self.savingSuccess then
		self.savingSuccess = false
		return nil
	  end
	  local playerUuids = world.playerQuery(entity.position(), 10)
      for _, playerId in pairs(playerUuids) do
		storage.peariasOwnerUuid = world.entityUuid(playerId)
		entity.say("Pleasure to serve you, " .. world.entityName(playerId) .. ".")
		break
	  end
	else
	  sayToTarget("follow.dialog.continue")
	end
  else
    return nil
  end

  -- Recognise own master
  if self.ownerEntityId ~= nil then
    local playerIds = world.playerQuery(entity.position(), 50)
	local isMaster = true
    for _, playerId in pairs(playerIds) do
	  if playerId ~= self.ownerEntityId then
		entity.say("You are not my master, " .. world.entityName(playerId) .. ".")
		isMaster = false
	  end
	end
	if not isMaster then
	  entity.say("My master is " .. world.entityName(self.ownerEntityId) .. ".")
	end
  end

  -- Translate owner uuid to entity id
  if self.ownerEntityId == nil then
    local playerIds = world.playerQuery(entity.position(), 50)
    for _, playerId in pairs(playerIds) do
      if world.entityUuid(playerId) == storage.peariasOwnerUuid then
        self.ownerEntityId = playerId
        break
      end
    end
  end

  -- Owner is nowhere around
  if self.ownerEntityId == nil then return nil end

  return { 
  ownerId = self.ownerEntityId,
  searchTimer = 0,
  randomTimer = entity.configParameter("follow.randomInfoInterval"),
  running = false }
end

function followState.update(dt, stateData)
  if stateData.ownerId == nil then return true end
  
  -- go into antenna when owner teleport away
  if not world.entityExists(stateData.ownerId) then
    if followState.teleport(dt) then
	  world.logInfo("I have arrived!")
	  return true
	elseif followState.teleport(dt) == nil then
	  world.logInfo("I can't find any Teleport Antenna!")
	  return true
	else
	  return false
	end
  end

  local closeDistance = entity.configParameter("follow.closeDistance", 2)
  local runDistance = entity.configParameter("follow.runDistance", 10)
  local teleportDistance = entity.configParameter("follow.teleportDistance", 20)

  local position = entity.position()
  local ownerPosition = world.entityPosition(stateData.ownerId)
  local toOwner = world.distance(ownerPosition, position)
  local distance = world.magnitude(toOwner)

  -- Open flashlight in dark
  flashlightOn()

  -- Chat with other Pearias in the way
  if speakState ~= nil then
    local speakDistance = entity.configParameter("speak.speakDistance", nil)
    if speakDistance ~= nil then
      if speakState.initiateChat(position, vec2.add({ speakDistance * entity.facingDirection(), 0 }, position)) then
        return true
      end
    end
  end

  -- Heal if owner's health is under certain percent
  if healState ~= nil then
    if self.healCooldown ~= nil then
	  self.healCooldown = self.healCooldown - dt
	end
	if healState.enter() ~= nil then
	  return true
	end
  end

  -- Keep the owner in sight
  local entityInSight = entity.entityInSight(stateData.ownerId)
  if entityInSight then
    stateData.searchTimer = 0

    ownerPosition = world.entityPosition(stateData.ownerId)
    if ownerPosition == nil then
      return true
    end
  else
    if not world.entityExists(stateData.ownerId) then
      return true
    end

    stateData.searchTimer = stateData.searchTimer + dt
    if stateData.searchTimer >= entity.configParameter("follow.searchTime") then
      entity.say("I'll wait here then.")
	  return true
    end
  end

  -- Random info spoken
  local rollDice = math.random (4)
  stateData.randomTimer = stateData.randomTimer - dt
  if isTimeFor("follow.infoTimeRange") and stateData.randomTimer <= 0 then
    entity.say(randomRemark(rollDice))
	stateData.randomTimer = entity.configParameter("follow.randomInfoInterval")
  end

  -- Take item into inventory
  storeItem()

  -- Prefer to stand beside instead of behind owner
  local movementOwnerPosition = nil
  local moveToSide
  stateData.running = true
  if moveToSide ~= nil then
    movementOwnerPosition = {
      ownerPosition[1] + moveToSide * closeDistance,
      ownerPosition[2]
    }

    if distance >= runDistance and moveToSide == util.toDirection(-toOwner[1]) then
      moveToSide = nil
    end
  else
    if entityInSight then
      entity.setFacingDirection(toOwner[1])
      entity.setAimPosition(ownerPosition)

      if distance < closeDistance then
        moveToSide = util.toDirection(-toOwner[1])
		-- Make sure we're not standing on a platform just above the owner
        if toOwner[2] < -1.5 then
          entity.moveDown()
        end
        return false
      end
    end

    -- Get close enough to the owner
    movementOwnerPosition = ownerPosition
    stateData.running = distance > runDistance
  end
  
  moveTo(movementOwnerPosition, dt, { run = stateData.running })

  return false
end

function followState.teleport(dt)
  local position = entity.position()
  local availableObjects = world.objectQuery(position, 100)
  
  local portId
  if availableObjects ~= nil then
	for i, objectId in pairs(availableObjects) do
      if world.entityName(objectId) == "teleportantenna" then
		portId = objectId
		--world.logInfo("Ports ID = %s", portId)
		break
	  end
	end
	
	if portId ~= nil then
	  local portPosition = world.entityPosition(portId)
	  local distanceToPort = world.magnitude(position, portPosition)
	  --world.logInfo("Ports position = %s, Distance = %s", portPosition, distanceToPort)
	  moveTo(portPosition, dt, { run = true })
	
	  if distanceToPort <= 8 and world.callScriptedEntity(portId, "antennaEmpty") then
		world.spawnLiquid(entity.position(), 3, 100)
		--world.logInfo("I suicide by spawning lava!")
	  end

	  return distanceToPort <= 1
	end
  end
  return nil
end

function followState.leavingState()

end

--   world.callScriptedEntity(portId, "killMe")
--   world.callScriptedEntity(objectId, "antennaEmpty")