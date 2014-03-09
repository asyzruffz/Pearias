function init(args)
  self.dead = false

  -- Data doesn't attack people
  entity.setDamageOnTouch(false)
  entity.setAggressive(false)
  self.dataSpawn = false
  
end

function main()
  local receivedMemory = {}
  
  receivedMemory.ownerUuid = entity.configParameter("ownerUuid", nil)
  receivedMemory.experience = entity.configParameter("experience", nil)
  receivedMemory.level = entity.configParameter("level", 1)
  receivedMemory.inventory = entity.configParameter("inventory", nil)
  receivedMemory.species = entity.configParameter("species", "glitch")
  receivedMemory.npctype = entity.configParameter("npcType", "paia")
  receivedMemory.seed = entity.configParameter("seed", nil)

  if not self.dataSpawn then
    local newSpawnId = world.spawnNpc(entity.toAbsolutePosition({ 0.0, 3.0 }), receivedMemory.species, receivedMemory.npctype, receivedMemory.level, tonumber(receivedMemory.seed))
	world.callScriptedEntity(newSpawnId, "loadData", receivedMemory)
    self.dataSpawn = true
  end
  
  kill()
end

function damage(args)
  self.dead = true
end

function kill()
  self.dead = true
end

function shouldDie()
  return self.dead
end