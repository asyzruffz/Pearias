personalAssistState = {}

function personalAssistState.enterWith(args)
  if self.shopOpen then return nil end
  if args.interactArgs == nil then return nil end
  if args.interactArgs.sourceId == 0 then return nil end
  
  return {
    sourceId = args.interactArgs.sourceId,
    timer = entity.configParameter("personalAssist.waitTime"),
	messageCount = 0,
	sayOnce = false,
	dialogInterval = 0
  }
end

function personalAssistState.update(dt, stateData)
  local sourcePosition = world.entityPosition(stateData.sourceId)
  if sourcePosition == nil then return true end

  local toSource = world.distance(sourcePosition, entity.position())
  setFacingDirection(toSource[1])

  local sayOnce = stateData.sayOnce
  if stateData.dialogInterval >= entity.configParameter("personalAssist.dialogInterval") then
    stateData.dialogInterval = 0
    sayOnce = false
  end

  if not sayOnce and stateData.dialogInterval == 0 then
	if stateData.messageCount == 0 then
	  entity.say("My name is " .. world.entityName(entity.id()) .. ". Your ID = " .. stateData.sourceId)
	  stateData.messageCount = stateData.messageCount + 1
	elseif stateData.messageCount == 1 then
      entity.say("I'm currently at level " .. currentLevel() .. ".")
	  stateData.messageCount = stateData.messageCount + 1
	elseif stateData.messageCount == 2 then
	  entity.say("I need " .. neededExp() .. " more experience to level up.")
	  stateData.messageCount = stateData.messageCount + 1
	elseif stateData.messageCount == 3 then
	  if storage.peariasInventory.slot1 ~= nil then
	    entity.say(storage.peariasInventory.slot1.count .. " " .. storage.peariasInventory.slot1.name .. " is in slot 1.")
		world.logInfo("Slot 1 = %s", storage.peariasInventory.slot1)
	  else
	    entity.say("Slot 1 is empty.")
	  end
	  stateData.messageCount = stateData.messageCount + 1
	elseif stateData.messageCount == 4 then
	  if storage.peariasInventory.slot2 ~= nil then
	    entity.say(storage.peariasInventory.slot2.count .. " " .. storage.peariasInventory.slot2.name .. " is in slot 2.")
		world.logInfo("Slot 2 = %s", storage.peariasInventory.slot2)
	  else
	    entity.say("Slot 2 is empty.")
	  end
	  stateData.messageCount = stateData.messageCount + 1
	elseif stateData.messageCount == 5 then
	  if storage.peariasInventory.slot3 ~= nil then
	    entity.say(storage.peariasInventory.slot3.count .. " " .. storage.peariasInventory.slot3.name .. " is in slot 3.")
		world.logInfo("Slot 3 = %s", storage.peariasInventory.slot3)
	  else
	    entity.say("Slot 3 is empty.")
	  end
	  stateData.messageCount = stateData.messageCount + 1
	end
	sayOnce = true
  end
  stateData.dialogInterval = stateData.dialogInterval + dt

  -- Here modify the number of message shown
  if stateData.messageCount == 6 then
	stateData.timer = stateData.timer - dt
  end
  return stateData.timer <= 0
end
