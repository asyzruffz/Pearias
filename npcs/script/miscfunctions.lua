
--------------------------------------------------------------------------------
-- Create a clone of Pearias
function clone()
  local spawnPosition = {entity.position()[1] + 0, entity.position()[2] + 3}
  local species = entity.species(entity.id())
  local name = "paia"
  local level = entity.level()
  local seed = entity.seed()
  world.logInfo("-- The seed in clone is now %s. <= If it's not 'number' tell me this error. --", type(seed))

  entity.say("Hey, we meet again!")
  world.spawnNpc(spawnPosition, species, name, level, tonumber(seed))
end

--------------------------------------------------------------------------------
-- Without any parameter, flashlight is automatically held in dark
-- Parameters:  switch: (optional)true to turn on, false to turn off
-- 				colour: (optional) valid colour is "red", "green" or "yellow"
-- Return true if flashlight is held and false if not
function flashlightOn(switch, colour)
  local flashlight = nil

  if switch then
    flashlight = true
  elseif not switch then
    flashlight = false
  else
    flashlight = nil
  end

  local choosenFlashlight
  if colour ~= nil then
    if colour == "red" then
	  choosenFlashlight = "redflashlight"
	elseif colour == "green" then
	  choosenFlashlight = "greenflashlight"
	elseif colour == "yellow" then
	  choosenFlashlight = "yellowflashlight"
	else
	  choosenFlashlight = "flashlight"
	end
  else
    choosenFlashlight = "flashlight"
  end

  local dark = world.lightLevel({entity.position()[1] - 0.5, entity.position()[2] + 5}) < 0.2
  if dark or flashlight then
    entity.setItemSlot("alt", choosenFlashlight)
	flashlight = true
  elseif not dark or not flashlight then
    entity.setItemSlot("alt", nil)
	flashlight = false
  end
  
  return flashlight
end

--------------------------------------------------------------------------------
-- Return a string of current planet clock
-- accurateToSecond: (optional)(bool)
function inGameClock(accurateToSecond)
  local timeOfDay = world.timeOfDay()
  local hour = timeOfDay*24
  local minute = (hour%1)*60
  local second = (minute%1)*60
  -- ^ this will make 00:01 to 12.00 day, 12:01 to 00:00 night

  --but here to adjust sunrise time
  local sunriseAdjust = entity.configParameter("sunriseAdjust", 0)
  if hour < 24 then
    hour = hour + sunriseAdjust
  end
  if hour >= 24 then
	hour = hour - 24
  end

  hour = string.format("%02d",hour)
  minute = string.format("%02d",minute)
  second = string.format("%02d",second)
  
  local currentTime
  if accurateToSecond then
    currentTime = hour .. ":" .. minute .. " " .. second .. "second"
  else
	currentTime = hour .. ":" .. minute
  end
  return currentTime
end

--------------------------------------------------------------------------------
-- Return a string of current temperature
function currentTemperature()
  local position = world.entityPosition(entity.id())
  local temperature = world.temperature(position)
  return string.format("%.2f",temperature)
end

--------------------------------------------------------------------------------
-- Check if entity's health is below specified percentage
function isHurt(entityId)
  local currentHp = world.entityHealth(entityId)[1]
  local maxHp = world.entityHealth(entityId)[2]
  local percentageHp = currentHp * 100 / maxHp
  local healRequirement = entity.configParameter("heal.healRequirement", 20)
  
  if percentageHp > healRequirement then
	return false
  else
	return true
  end
end

--------------------------------------------------------------------------------
-- Level up if exp points is enough to level up
function levelUp()
  if storage.peariasExp == nil then
    storage.peariasExp = 0
	return false
  end
  if storage.peariasLevel == nil then
   storage.peariasLevel = 1
   return false
  end
  
  local expPerLevel = entity.configParameter("expPerLevel", 100)
  
  if storage.peariasExp >= expPerLevel then
    storage.peariasExp = storage.peariasExp - expPerLevel
	storage.peariasLevel = storage.peariasLevel + 1
    entity.say("Level up!")
    return true
  else
    return false
  end
end

--------------------------------------------------------------------------------
-- Return current level
function currentLevel()
  if storage.peariasLevel == nil then return 1 end
  return storage.peariasLevel
end

--------------------------------------------------------------------------------
-- Return amount of current experience point
function expPoint()
  if storage.peariasExp == nil then
    storage.peariasExp = 0
  end

  return storage.peariasExp
end

--------------------------------------------------------------------------------
-- Add 'amount' of exp point
function gainExp(amount)
  if storage.peariasExp == nil then
    storage.peariasExp = 0
  end
  if amount ~= nil then
    storage.peariasExp = storage.peariasExp + amount
  end
  levelUp()
  return amount ~= nil
end

--------------------------------------------------------------------------------
-- Return amount of experience point needed to level up
function neededExp()
  return entity.configParameter("expPerLevel", 100) - expPoint()
end

--------------------------------------------------------------------------------
-- Called when it has something more important to do than following around
function stopFollowing()  -- (not used)
  if self.changingState == nil then
    self.changingState = false
  end
  return self.changingState
end

--------------------------------------------------------------------------------
-- Called when it respawn, carry the previous data
function loadData(memory)
  if memory == nil then
    self.savingSuccess = false
	return self.savingSuccess
  end
  
  storage.peariasOwnerUuid = memory.ownerUuid
  storage.peariasExp = memory.experience
  storage.peariasLevel = memory.level or entity.level()
  storage.peariasInventory = memory.inventory
  
  self.savingSuccess = true
  entity.say(":data synchronized:")
  return self.savingSuccess
end

--------------------------------------------------------------------------------
-- Called when a memory chip is taken into another Pearias inventory
function overwriteMemory(dna)
  world.spawnLiquid(entity.position(), 3, 100)
  --world.logInfo("DNA is = %s. Type = %s.", dna.dataMemory, type(dna.dataMemory))
  local newSpawnId = world.spawnNpc(entity.toAbsolutePosition({ 0.0, 3.0 }), dna.dataMemory.species, dna.dataMemory.npcType, (dna.dataMemory.level or entity.level()), tonumber(dna.dataMemory.seed))
  world.callScriptedEntity(newSpawnId, "loadData", dna.dataMemory)
end

--------------------------------------------------------------------------------
-- Check if Pearias has owner/master
function hasOwner()
  return self.ownerEntityId ~= nil
end

--------------------------------------------------------------------------------
-- Take money and items into inventory
function storeItem()
  if storage.peariasInventory == nil then
    storage.peariasInventory = {}
  end
  
  local itemsScanned = world.itemDropQuery(entity.position(), 6)
  local temporary
  if itemsScanned ~= nil then
	for _, item in pairs(itemsScanned) do
	  -- Check if money, goes to bank
	  if world.entityName(item) == "money" or world.entityName(item) == "goldcoin" then
	    if storage.peariasInventory.bank ~= nil then
		  temporary = world.takeItemDrop(item, entity.id())
		  if temporary ~= nil then
			storage.peariasInventory.bank.count = storage.peariasInventory.bank.count + temporary.count
			entity.say(temporary.count .. " " .. temporary.name .. " into bank. Total = " .. storage.peariasInventory.bank.count)
			gainExp(temporary.count)
			world.logInfo("Bank = %s", storage.peariasInventory.bank)
			temporary = nil
		  end
		else
		  storage.peariasInventory.bank = world.takeItemDrop(item, entity.id())
		  if storage.peariasInventory.bank ~= nil then
			entity.say(storage.peariasInventory.bank.count .. " " .. storage.peariasInventory.bank.name .. " into bank.")
			gainExp(storage.peariasInventory.bank.count)
			world.logInfo("Bank = %s", storage.peariasInventory.bank)
		  end
		end
	  -- Else, to the inventory
	  else
		-- If there's the same item already, try stacking simple items
		if storage.peariasInventory.slot1 ~= nil and world.entityName(item) == storage.peariasInventory.slot1.name then
	      if next(storage.peariasInventory.slot1.data) == nil then
			temporary = world.takeItemDrop(item, entity.id())
			if temporary ~= nil then
			  storage.peariasInventory.slot1.count = storage.peariasInventory.slot1.count + temporary.count
			  entity.say(temporary.count .. " " .. temporary.name .. " into slot 1.")
			  temporary = nil
			end
		  end
		elseif storage.peariasInventory.slot2 ~= nil and world.entityName(item) == storage.peariasInventory.slot2.name then
	      if next(storage.peariasInventory.slot2.data) == nil then
			temporary = world.takeItemDrop(item, entity.id())
			if temporary ~= nil then
			  storage.peariasInventory.slot2.count = storage.peariasInventory.slot2.count + temporary.count
			  entity.say(temporary.count .. " " .. temporary.name .. " into slot 2.")
			  temporary = nil
			end
		  end
		elseif storage.peariasInventory.slot3 ~= nil and world.entityName(item) == storage.peariasInventory.slot3.name then
	      if next(storage.peariasInventory.slot2.data) == nil then
			temporary = world.takeItemDrop(item, entity.id())
			if temporary ~= nil then
			  storage.peariasInventory.slot2.count = storage.peariasInventory.slot3.count + temporary.count
			  entity.say(temporary.count .. " " .. temporary.name .. " into slot 3.")
			  temporary = nil
			end
		  end
		end
		
		-- If slot still empty
		if world.entityName(item) == "peariasmemory" then
		  local dna = world.takeItemDrop(item, entity.id())
		  if dna ~= nil  then
		    overwriteMemory(dna.data)
		  end
		elseif storage.peariasInventory.slot1 == nil then
		  storage.peariasInventory.slot1 = world.takeItemDrop(item, entity.id())
		  if storage.peariasInventory.slot1 ~= nil then
			entity.say(storage.peariasInventory.slot1.count .. " " .. storage.peariasInventory.slot1.name .. " into slot 1.")
			world.logInfo("Slot 1 = %s", storage.peariasInventory.slot1)
		  end
		elseif storage.peariasInventory.slot2 == nil then
		  storage.peariasInventory.slot2 = world.takeItemDrop(item, entity.id())
		  if storage.peariasInventory.slot2 ~= nil then
			entity.say(storage.peariasInventory.slot2.count .. " " .. storage.peariasInventory.slot2.name .. " into slot 2.")
			world.logInfo("Slot 2 = %s", storage.peariasInventory.slot2)
		  end
		elseif storage.peariasInventory.slot3 == nil then
		  storage.peariasInventory.slot3 = world.takeItemDrop(item, entity.id())
		  if storage.peariasInventory.slot3 ~= nil then
			entity.say(storage.peariasInventory.slot3.count .. " " .. storage.peariasInventory.slot3.name .. " into slot 3.")
			world.logInfo("Slot 3 = %s", storage.peariasInventory.slot3)
		  end
		else
	      -- Inventory full
		end
	  end
	end
  end
end

--------------------------------------------------------------------------------
-- Remove all items from inventory (not money)
function freeInventory()
  if storage.peariasInventory == nil then
    return nil
  end

  if storage.peariasInventory.slot1 == nil and storage.peariasInventory.slot2 == nil and storage.peariasInventory.slot3 == nil then
    entity.say("My inventory is empty.")
  end
  
  local position = entity.position()

  if storage.peariasInventory.slot1 ~= nil then
    if next(storage.peariasInventory.slot1.data) == nil then
	  storage.peariasInventory.slot1.data = nil
	end
    world.spawnItem(storage.peariasInventory.slot1.name, position, storage.peariasInventory.slot1.count, storage.peariasInventory.slot1.data)
	storage.peariasInventory.slot1 = nil
  end
  if storage.peariasInventory.slot2 ~= nil then
    if next(storage.peariasInventory.slot2.data) == nil then
	  storage.peariasInventory.slot2.data = nil
	end
	world.spawnItem(storage.peariasInventory.slot2.name, position, storage.peariasInventory.slot2.count, storage.peariasInventory.slot2.data)
	storage.peariasInventory.slot2 = nil
  end
  if storage.peariasInventory.slot3 ~= nil then
    if next(storage.peariasInventory.slot3.data) == nil then
	  storage.peariasInventory.slot3.data = nil
	end
	world.spawnItem(storage.peariasInventory.slot3.name, position, storage.peariasInventory.slot3.count, storage.peariasInventory.slot3.data)
	storage.peariasInventory.slot3 = nil
  end
end

--------------------------------------------------------------------------------
-- Say how many money stored
function bankStatus()
  local amount = 0
  if storage.peariasInventory.bank == nil then
    amount = 0
  else
    amount = storage.peariasInventory.bank.count
  end
  
  entity.say("I have " .. amount .. " pixels in my bank.")
end

--------------------------------------------------------------------------------
-- List of infos to say
function randomRemark(infoNumber)
  local news = {}
  local position = world.entityPosition(entity.id())
  
  news[1] = "The time is " .. inGameClock() .. "."
  news[2] = "Coordinate here is (" .. string.format("%d",position[1]) .. "," .. string.format("%d",position[2]) .. ")."
  news[3] = "The surrounding temperature is " .. currentTemperature() .. " C."
  news[4] = "Come fourth."
  
  if infoNumber >= 1 and infoNumber <= 4 then
    return news[infoNumber]
  else
    return ""
  end
end

--------------------------------------------------------------------------------
-- Receive numeral input from command glass (called from there)
function giveAmount(number)
  if number ~= nil then
    self.gottenNumber = number
  end
end

--------------------------------------------------------------------------------
-- Called when a monster has been killed, on the entity that dealt the death-blow
function monsterKilled(entityId)
  if peariasMemory ~= nil then
    peariasMemory.onMonsterKilled()
  end
end

--------------------------------------------------------------------------------
function shouldDie()
  world.spawnLiquid(entity.position(), 3, 100)
  return self.dead
end

--------------------------------------------------------------------------------
-- Called from C++ when dead
function die()
  if peariasMemory ~= nil then
    peariasMemory.onDie()
  end
end

--------------------------------------------------------------------------------
-- Helper function (not used)
function compareTables(firstTable, secondTable)
  if (next(firstTable) == nil) and (next(secondTable) == nil) then
    return true
  end
  for key,value in pairs(firstTable) do
    if firstTable[key] ~= secondTable[key] then
      return false
    end
  end
  for key,value in pairs(secondTable) do
    if firstTable[key] ~= secondTable[key] then
      return false
    end
  end
  return true
end