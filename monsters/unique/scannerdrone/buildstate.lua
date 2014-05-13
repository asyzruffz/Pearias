buildState = {}

function buildState.getBlueprint()
  local playerIds = world.playerQuery(entity.position(), 50)
  for _, playerId in pairs(playerIds) do
	if world.entityHandItem(playerId, "primary") == "peariasblueprint" then
	  self.blueprint = world.entityHandItemDescriptor(playerId, "primary")
	  --world.logInfo("Primary hand : %s", self.blueprint)
	  return true
	elseif world.entityHandItem(playerId, "alt") == "peariasblueprint" then
	  self.blueprint = world.entityHandItemDescriptor(playerId, "alt")
	  --world.logInfo("Alt hand : %s", self.blueprint)
	  return true
	else
	  return false
	end
  end
end

function buildState.enter()
  if buildState.getBlueprint() and self.startBuilding then
	world.logInfo("Originally : %s", self.blueprint)
	return { occupied = false, startPoint = nil, oldBalance = -1 }
  else
	return nil
  end
end

function buildState.update(dt, stateData)
  -- getting starting point
  if not stateData.occupied then
	if entity.onGround() then
	  stateData.startPoint = {entity.position()[1], entity.position()[2] - 3}
	  stateData.occupied = true
	else
	  entity.fly({0,-1}, true)
	  return false
	end
  end
  
  -- building block by block
  for block, info in ipairs(self.blueprint.data.structureData) do
	-- building background block
	if info.background ~= nil then
	  if world.placeMaterial({stateData.startPoint[1] + info.background.coordinate[1] - 1, stateData.startPoint[2] + info.background.coordinate[2] - 1}, "background", info.background.type, nil, true) then
		world.logInfo("Built at background %s",info.background.coordinate)
		info.background = nil
		
		-- remove any unnecessary foreground block
		if info.foreground == nil and
			world.material({stateData.startPoint[1] + info.foreground.coordinate[1] - 1, stateData.startPoint[2] + info.foreground.coordinate[2] - 1}, "foreground") ~= nil then
		  world.spawnProjectile("buildingfexplosion", {stateData.startPoint[1] + info.foreground.coordinate[1] - 1, stateData.startPoint[2] + info.foreground.coordinate[2] - 1}, entity.id(), {0,0}, false)
		end
	  
	  elseif world.material({stateData.startPoint[1] + info.background.coordinate[1] - 1, stateData.startPoint[2] + info.background.coordinate[2] - 1}, "background") ~= nil then
	  	world.spawnProjectile("buildingbexplosion", {stateData.startPoint[1] + info.background.coordinate[1] - 1, stateData.startPoint[2] + info.background.coordinate[2] - 1}, entity.id(), {0,0}, false)
	  else
		--world.logInfo("Failed at background %s",info.background.coordinate)
	  end
	end
	
	-- building foreground block
	if info.foreground ~= nil then
	  if world.placeMaterial({stateData.startPoint[1] + info.foreground.coordinate[1] - 1, stateData.startPoint[2] + info.foreground.coordinate[2] - 1}, "foreground", info.foreground.type, nil, true) then
		world.logInfo("Built at foreground %s",info.foreground.coordinate)
		info.foreground = nil
	  elseif world.material({stateData.startPoint[1] + info.foreground.coordinate[1] - 1, stateData.startPoint[2] + info.foreground.coordinate[2] - 1}, "foreground") ~= nil then
	  	world.spawnProjectile("buildingfexplosion", {stateData.startPoint[1] + info.foreground.coordinate[1] - 1, stateData.startPoint[2] + info.foreground.coordinate[2] - 1}, entity.id(), {0,0}, false)
	  else
		--world.logInfo("Failed at foreground %s",info.foreground.coordinate)
	  end
	end
	
	-- remove those built block from data so the same place wont be built again
	if next(info) == nil then
	  table.remove(self.blueprint.data.structureData, block)
	end
  end
  
  --[[ destroy obstructing blocks
  for block, info in ipairs(self.blueprint.data.structureData) do
	if info.foreground ~= nil then
	  --world.logInfo("Failed at %s, while %s",{stateData.startPoint[1] + info.foreground.coordinate[1] - 1, stateData.startPoint[2] + info.foreground.coordinate[2] - 1}, entity.position())
	  --world.damageTiles({stateData.startPoint[1] + info.foreground.coordinate[1] - 1, stateData.startPoint[2] + info.foreground.coordinate[2] - 1}, "foreground", stateData.startPoint, "crushing", 1000)
	end
	if info.background ~= nil then
	  --world.damageTiles({stateData.startPoint[1] + info.background.coordinate[1] - 1, stateData.startPoint[2] + info.background.coordinate[2] - 1}, "background", stateData.startPoint, "crushing", 1000)
	end
  end ]]
  
  -- try again if failed
  if next(self.blueprint.data.structureData) == nil then
	world.logInfo("Finished building")
	return true
  else
	world.logInfo("Still has %s place to be built.", #self.blueprint.data.structureData)
	world.logInfo("%s", self.blueprint.data.structureData)
	
	local balance = #self.blueprint.data.structureData
	if balance == stateData.oldBalance then
	  world.logInfo("Stopped building with %s place left.", #self.blueprint.data.structureData)
	  return true
	else
	  stateData.oldBalance = balance
	  return false
	end
  end
end

function buildState.leavingState()
  self.blueprint = nil
  self.startBuilding = false
end