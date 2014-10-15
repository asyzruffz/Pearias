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
  world.debugLine(stateData.startPoint, {stateData.startPoint[1] + width, stateData.startPoint[2]}, "red")
  world.debugLine({stateData.startPoint[1], stateData.startPoint[2] + height}, {stateData.startPoint[1] + width, stateData.startPoint[2] + height}, "red")
  world.debugLine(stateData.startPoint, {stateData.startPoint[1], stateData.startPoint[2] + height}, "red")
  world.debugLine({stateData.startPoint[1] + width, stateData.startPoint[2]}, {stateData.startPoint[1] + width, stateData.startPoint[2] + height}, "red")
  
  -- getting info block by block
  local map = { structureData = {}, emptyData = {}, blockAmount = 0 }
  local voidSpace = {}
  for i = 1, width, 1 do
	for j = 1, height, 1 do
	  local blockInfo = { foreground = {}, background = {} }
	  
	  blockInfo.foreground.type = world.material({stateData.startPoint[1] + i, stateData.startPoint[2] + j}, "foreground")
	  blockInfo.foreground.coordinate = {i, j}
	  if blockInfo.foreground.type == false or blockInfo.foreground.type == nil or blockInfo.foreground.type == true then
		blockInfo.foreground = nil
	  else
		map.blockAmount = map.blockAmount + 1
	  end
	  
	  blockInfo.background.type = world.material({stateData.startPoint[1] + i, stateData.startPoint[2] + j}, "background")
	  blockInfo.background.coordinate = {i, j}
	  if blockInfo.background.type == false or blockInfo.background.type == nil or blockInfo.background.type == true then
		blockInfo.background = nil
	  else
		map.blockAmount = map.blockAmount + 1
	  end
	  
	  if next(blockInfo) ~= nil then
		table.insert(map.structureData, blockInfo)
	  elseif blockInfo.background == nil and blockInfo.foreground == nil then
		table.insert(voidSpace, {i,j})
	  end
	  
	  --world.logInfo("Coordinate (%s,%s) scanned!", i, j)
	  -- <todo> add particles
	end
  end
  
  --those empty space outlining the blocks
  world.logInfo("%s blanks before : %s", #voidSpace, voidSpace)
  for emptyBlock, emptyCoordinate in ipairs(voidSpace) do
	local flatBlank = true
	for block, info in ipairs(map.structureData) do
	  if info.background ~= nil then
		if world.magnitude(emptyCoordinate, info.background.coordinate) < 2 then
		  flatBlank = false
		  table.insert(map.emptyData, emptyCoordinate)
		  world.logInfo("%s is near background %s.", emptyCoordinate, info.background.coordinate)
		  break
		end
	  elseif info.foreground ~= nil then
		if world.magnitude(emptyCoordinate, info.foreground.coordinate) < 2 then
		  flatBlank = false
		  table.insert(map.emptyData, emptyCoordinate)
		  world.logInfo("%s is near foreground %s.", emptyCoordinate, info.foreground.coordinate)
		  break
		end
	  end
	end
	
	if flatBlank then
	  world.logInfo("%s is removed.", emptyCoordinate)
	end
  end
  world.logInfo("%s blanks after : %s", #map.emptyData, map.emptyData)
  
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