function init(args)
  local states = stateMachine.scanScripts(entity.configParameter("scripts"), "(%a+State)%.lua")
  self.state = stateMachine.create(states)
  
  entity.setDeathParticleBurst("deathPoof")
  entity.setAnimationState("movement", "flying")
end

function shouldDie()
  if entity.health() <= 0 then return true end

  if self.hadMaster ~= nil and not self.hadMaster then
	return true
  end
  
  if self.dead then
	return true
  end

  return false
end

function main()
  local masterId = findMaster()
  if masterId ~= 0 then
    if self.despawn then
	  entity.flyTo(world.entityPosition(masterId), true)
	  if world.magnitude(entity.position(), world.entityPosition(masterId)) < 2 then
		self.dead = true
	  end
	else
	  self.hadMaster = true

      local angle = (math.pi / 2.0) + entity.dt()
      local target = vec2.add(world.entityPosition(masterId), {
		20.0 * math.cos(angle),
		8.0 * math.sin(angle)
      })

      entity.flyTo(target, true)
	end
  else
    self.hadMaster = false
    entity.fly({0,0}, true)
  end
  
  util.trackTarget(30.0, 10.0)
  self.state.update(entity.dt())
end

function damage(args)
  if args.sourceKind == "blueprint" then
	self.startBuilding = true
  end
end

function findMaster()
  local position = entity.position()
  local regionMin = { position[1] - 25.0, position[2] - 25.0 }
  local regionMax = { position[1] + 25.0, position[2] + 25.0 }

  local selfEntityId = entity.id()

  for i, entityId in ipairs(world.npcQuery(regionMin, regionMax, { callScript = "isDroneMaster", callScriptArgs = {entity.id()} })) do
	return entityId
  end

  return 0
end

function despawn()
  self.despawn = true
end