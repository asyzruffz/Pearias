
function init(args)
  entity.setInteractive(true)
  self.spawnId = nil
  entity.setAnimationState("objectState", "active")
end

function update(dt)
  local animation = entity.animationState("objectState")
  
  if animation == "break" then
	if self.spawnId == nil then
	  local level = 1
	  self.spawnId = world.spawnNpc(spawnPosition(), "glitch", "paia", level)
	end
  elseif animation == "done" then
	entity.smash()
  end
end

function onInteraction(args)
  entity.setAnimationState("objectState", "break")
end

function hasCapability(capability)
  return false
end

function spawnPosition()
  return vec2.add(entity.position(), entity.configParameter("spawnOffset"))
end