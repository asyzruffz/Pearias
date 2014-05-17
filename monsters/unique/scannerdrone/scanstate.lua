scanState = {}

function scanState.toggleOn()
  self.scanBuilding = true
end

function scanState.enter()
  if self.scanBuilding then
	world.logInfo("Scanning!")
	return { occupied = false, startPoint = nil }
  else
	return nil
  end
end

function scanState.update(dt, stateData)
  -- getting starting point
  if not stateData.occupied then
	if entity.onGround() then
	  stateData.startPoint = {entity.position()[1], entity.position()[2] - 2}
	  stateData.occupied = true
	else
	  entity.fly({0,-1}, true)
	  return false
	end
  end
  
  -- area to be scanned
  local width, height = 30, 30
  
  -- getting info block by block
  local map = { structureData = {}, blockAmount = 0 }
  for i = 1, width, 1 do
	for j = 1, height, 1 do
	  local blockInfo = { foreground = {}, background = {} }
	  local blockCoordinate = vec2.add(stateData.startPoint, {i - 1,j - 1})
	  
	  blockInfo.foreground.type = world.material(blockCoordinate, "foreground")
	  blockInfo.foreground.coordinate = {i, j}
	  if not blockInfo.foreground.type or blockInfo.foreground.type == true then
		blockInfo.foreground = nil
	  else
		map.blockAmount = map.blockAmount + 1
	  end
	  
	  blockInfo.background.type = world.material(blockCoordinate, "background")
	  blockInfo.background.coordinate = {i, j}
	  if not blockInfo.background.type or blockInfo.background.type == true then
		blockInfo.background = nil
	  else
		map.blockAmount = map.blockAmount + 1
	  end
	  
	  if next(blockInfo) ~= nil then
		table.insert(map.structureData, blockInfo)
	  end
	  
	  --world.logInfo("Coordinate (%s,%s) scanned!", i, j)
	  -- <todo> add particles
	end
  end
  
  -- saved as blueprint
  if next(map.structureData) ~= nil then
	world.spawnItem("peariasblueprint", entity.position(), 1, map)
	--world.logInfo("Saved : %s", map)
  end
  
  return true
end

function scanState.leavingState()
  self.scanBuilding = false
end