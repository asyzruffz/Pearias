healState = {}

function healState.enter()
  if not hasOwner() then return nil end
  if not world.entityExists(self.ownerEntityId) then return nil end
  -- if world.info() == nil then return nil end  -- don't heal on ship

  local currentHp = world.entityHealth(self.ownerEntityId)[1]
  local maxHp = world.entityHealth(self.ownerEntityId)[2]
  local percentageHp = currentHp * 100 / maxHp
  local healRequirement = entity.configParameter("heal.healRequirement", 20)

  if self.healCooldown == nil then
    self.healCooldown = 0
  end

  if percentageHp > healRequirement then
	return nil, 10
  elseif self.healCooldown > 0 then
    return nil
  else
    self.changingState = true
	entity.say("You're hurt. Let me heal you.")
	return {
	ownerId = self.ownerEntityId,
	timer = entity.configParameter("heal.cooldown"),
	searchTimer = 0,
	percentageHp = percentageHp,
	healed = false }
  end
end

function healState.update(dt, stateData)
  if not world.entityExists(stateData.ownerId) then return true end
  local distance = world.magnitude(mcontroller.position(), world.entityPosition(stateData.ownerId))
  local healRequirement = entity.configParameter("heal.healRequirement", 20)

  -- Keep the owner in sight
  local entityInSight = entity.entityInSight(stateData.ownerId)
  if entityInSight then
    stateData.searchTimer = 0

    local ownerPosition = world.entityPosition(stateData.ownerId)
    if ownerPosition == nil then
      return true
    end
  else
    if not world.entityExists(stateData.ownerId) then
      return true
    end

    stateData.searchTimer = stateData.searchTimer + dt
    if stateData.searchTimer >= entity.configParameter("follow.searchTime", 10) then
      entity.say("I can't get to you.")
	  return true
    end
  end

  -- don't need to heal twice
  if stateData.percentageHp > healRequirement then
	entity.say("Oh, you're already healed.")
	return true
  end

  if distance > 1 then
    moveTo(world.entityPosition(stateData.ownerId), dt, { run = stateData.running })
	return false
  else
    world.spawnProjectile("healingstatusprojectile", mcontroller.position(), entity.id(), {0, 0}, true)
	gainExp(entity.configParameter("heal.expGained", 5))
	self.healCooldown = entity.configParameter("heal.cooldown") + 3
	return true, entity.configParameter("heal.cooldown")
  end
end

function healState.leavingState()
  self.changingState = false
end