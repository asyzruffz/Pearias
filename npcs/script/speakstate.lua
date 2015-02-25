speakState = {}

-- Will only initiate chat when in follow state (called there)
function speakState.initiateChat(startPoint, endPoint)
  -- finding chat partner
  local chatTargetIds = world.npcLineQuery(startPoint, endPoint)
  if #chatTargetIds > 1 then
    local selfId = entity.id()
    local targetId
    if chatTargetIds[1] == selfId then
      targetId = chatTargetIds[2]
    else
      targetId = chatTargetIds[1]
    end

    local conversation = entity.randomizeParameter("speak.conversations")

    local distance = world.magnitude(world.distance(startPoint, endPoint))
    if sendNotification("speak", { targetId = targetId, conversation = conversation }, distance) then
	  self.state.pickState({ speakPartnerId = targetId, speakConversation = conversation })
      return true
    end
  end
end

function speakState.enterWith(event)
  local partnerId = event.speakPartnerId
  local conversation = event.speakConversation
  local conversationEntryIndex = 0

  if partnerId == nil then
    if event.notification == nil or
       event.notification.name ~= "speak" or
       event.notification.args.targetId ~= entity.id() or
       self.state.stateDesc() == "speakState" then
      return nil
    end

    partnerId = event.notification.sourceEntityId
    conversation = event.notification.args.conversation
    conversationEntryIndex = 1
  end

  --self.stopSpeaking = false
  return {
    partnerId = partnerId,
    timer = 0,
	ignoreTimer = 0,
    conversation = conversation,
    conversationIndex = 1,
    conversationEntryIndex = conversationEntryIndex
  }
end

function speakState.update(dt, stateData)
  local partnerPosition = world.entityPosition(stateData.partnerId)
  if partnerPosition == nil then
    return true
  end
  
  self.stopSpeaking = false

  local toPartner = world.distance(partnerPosition, mcontroller.position())
  local direction = util.toDirection(toPartner[1])

  local distance = world.magnitude(toPartner)
  local distanceRange = entity.configParameter("speak.distanceRange")
  if distance < distanceRange[1] then
    move({ -direction, 0 }, dt)
  elseif distance > distanceRange[2] then
    move( { direction, 0 }, dt)
	stateData.ignoreTimer = stateData.ignoreTimer + dt
    if stateData.ignoreTimer >= entity.configParameter("speak.ignoreTime") then
      entity.say("Let's chat later.")
	  return true, entity.configParameter("speak.cooldown", nil)
    end
  else
    setFacingDirection(direction)

    stateData.timer = stateData.timer - dt
    if stateData.timer <= 0 then
      local conversationEntry = stateData.conversation[stateData.conversationIndex]
      if conversationEntry == nil then
        return true, entity.configParameter("speak.cooldown", nil)
      else
        stateData.conversationIndex = stateData.conversationIndex + 1
      end

      -- conversationEntry[1] is the time, [2] is first guy's speech, etc
      stateData.timer = conversationEntry[1]
      local speech = conversationEntry[2 + stateData.conversationEntryIndex]

      entity.say(speech)
    end
  end

  --[[if world.callScriptedEntity(stateData.partnerId, "speakState.stopSpeaking") then
    stateData.ignoreTimer = stateData.ignoreTimer + dt
	if stateData.ignoreTimer >= entity.configParameter("speak.ignoreTime") then
	  if speakState.initiateChat(position, vec2.add({ speakDistance * entity.facingDirection(), 0 }, position)) then
		if not world.callScriptedEntity(stateData.partnerId, "speakState.stopSpeaking") then
	      entity.say("Did you just ignore me?")
	      return true, entity.configParameter("speak.cooldown", 30)
		end
	  end
	end
  end ]]
  
  return false
end

function speakState.stopSpeaking()
  return self.stopSpeaking
end

function speakState.leavingState()
  self.stopSpeaking = true
  entity.emote("neutral")
end