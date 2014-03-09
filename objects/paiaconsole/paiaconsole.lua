
function goodReception()
  local ll = entity.toAbsolutePosition({ -4.0, 3.0 })
  local tr = entity.toAbsolutePosition({ 4.0, 5.0 })
  
  local bounds = {0, 0, 0, 0}
  bounds[1] = ll[1]
  bounds[2] = ll[2]
  bounds[3] = tr[1]
  bounds[4] = tr[2]
  
  return not world.rectCollision(bounds, true)
end

function init(args)
  entity.setInteractive(true)
  if not goodReception() then
    entity.setAnimationState("beaconState", "idle")
  else
    entity.setAnimationState("beaconState", "active")
  end
end

function onInteraction(args)
  local level = 1
  
  if not goodReception() then
    entity.setAnimationState("beaconState", "idle")
	return { "ShowPopup", { message = "I should find a bigger space for it." } }
  else
    entity.setAnimationState("beaconState", "active")
	entity.smash()
    world.spawnNpc(entity.toAbsolutePosition({ 0.0, 3.0 }), "glitch", "paia", level)
  end
end

function hasCapability(capability)
  return false
end
