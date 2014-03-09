synchronizeState = {}

function synchronizeState.initiateSaving(memory)
  if memory == nil then return false end
  
  self.state.pickState({ speakPartnerId = targetId, speakConversation = conversation })
  return true
end

function synchronizeState.enterWith(event)
  
  storage.peariasOwnerUuid = event.ownerUuid
  storage.peariasExp = event.experience
  storage.peariasLevel = event.level
  storage.peariasInventory = event.inventory
  
  return {
  ownerUuid = event.ownerUuid,
  experience = event.experience,
  level = event.level,
  inventory = event.inventory }
end

function synchronizeState.update(dt, stateData)
  
  storage.peariasOwnerUuid = stateData.ownerUuid
  storage.peariasExp = stateData.experience
  storage.peariasLevel = stateData.level
  storage.peariasInventory = stateData.inventory
  entity.say(":data synchronized:")
  return true
  
end