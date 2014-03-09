danceState = {}

function danceState.enter()
  -- enter state with time range
  if isTimeFor("dance.timeRange") then
    return {
    timer = entity.configParameter("dance.dancePeriod", 5),
	swingTimer = 0,
	sitUpTimer = 0,
	sideStepTimer = 1
	}
  else
    return nil
  end
end

function danceState.update(dt, stateData)
  --save starting position
  if self.dancingPosition == nil then
    self.dancingPosition = entity.position()
  end
  
  --function for swinging flashlight
  local swingFlashlight = function()
    flashlightOn(true, "red") --<== "red", "green" or "yellow"
    stateData.swingTimer = stateData.swingTimer - dt
    if stateData.swingTimer <= 0 then
      local swingPosition = math.random(-3, 3)
      if swingPosition <= 1 and swingPosition > 0 then
        entity.setAimPosition({entity.position()[1] + 5,  entity.position()[2] + 5})
      elseif swingPosition <= 2 and swingPosition > 1 then
        entity.setAimPosition({entity.position()[1] + 5,  entity.position()[2]})
      elseif swingPosition <= 3 and swingPosition > 2 then
        entity.setAimPosition({entity.position()[1] + 5,  entity.position()[2] - 5})
      elseif swingPosition >= -1 and swingPosition < 0 then
        entity.setAimPosition({entity.position()[1] - 5,  entity.position()[2] + 5})
      elseif swingPosition >= -2 and swingPosition < -1 then
        entity.setAimPosition({entity.position()[1] - 5,  entity.position()[2]})
      elseif swingPosition >= -3 and swingPosition < -2 then
        entity.setAimPosition({entity.position()[1] - 5,  entity.position()[2] - 5})
      else
        entity.setAimPosition({entity.position()[1] + 0,  entity.position()[2] + 5})
      end
      swingPosition = nil
      stateData.swingTimer = 0.2
      self.swinging = false
      return true
    else
      return false
    end
  end
  
  --function for ocassionally crouching
  local sitUp = function()
    stateData.sitUpTimer = stateData.sitUpTimer - dt
    if stateData.sitUpTimer <= 0 then
      entity.setCrouching(true)
      stateData.sitUpTimer = 0.1
      return true
    else
      entity.setCrouching(false)
      self.sitUpping = false
      return false
    end
  end
  
  --function for random side movement
  local sideStep = function()
    if stateData.sideStepTimer <= 0 then
	  self.doneStep = true
	  self.sideStepping = false
	  stateData.sideStepTimer = 1
	else
      stateData.sideStepTimer = stateData.sideStepTimer - dt
	  local length = 2
	  local step = math.random(0, 2) - 1
      
	  if entity.position ~= self.dancingPosition and self.doneStep then
	    moveTo(self.dancingPosition, dt, { run = true })
		if entity.position == self.dancingPosition then
		  self.doneStep = false
		end
	  else
	    move({length * step, 0}, dt, { run = true })
	  end
    end
  end
  
  -- here is where all the above functions are called randomly
  if stateData.timer <= 0 then
    entity.say("Yeah!")
	return true, entity.configParameter("dance.cooldown")
  else
    stateData.timer = stateData.timer - dt
    if self.danceShout == nil then
	  entity.say("Let's dance!")
	  self.danceShout = true
	  --freeInventory()
	end
    local chance = math.random(60)
	if chance <= 20  or self.swinging then
      self.swinging = true
      swingFlashlight()
    elseif (chance <= 40 and chance > 20) or self.sitUpping then
      self.sitUpping = true
      sitUp()
    elseif (chance <= 60 and chance > 40) or self.sideStepping then
      self.sideStepping = true
      sideStep()
    end
    return false
  end
end

function danceState.leavingState()
  flashlightOn(false)
  self.danceShout = nil
  self.swinging = false
  self.sitUpping = false
  self.sideStepping = false
  entity.setCrouching(false)
end