peariasMemory = {}

-- Give exp when it kills monster (not used)
function peariasMemory.onMonsterKilled()
  if peariasMemory.isOwned() then
	gainExp(30)
  end
end

function peariasMemory.onDie()
  if not peariasMemory.isOwned() then return false end
  
  local dataMemory = {}
  
  dataMemory.ownerUuid = storage.peariasOwnerUuid
  dataMemory.experience = storage.peariasExp
  dataMemory.level = storage.peariasLevel
  dataMemory.inventory = storage.peariasInventory

  dataMemory.seed = tostring(entity.seed())
  dataMemory.species = "glitch"
  dataMemory.npcType = "paia"
  
  -- Spawn a memory chip that will re-create this Pearias
  world.spawnItem("peariasmemory", entity.toAbsolutePosition({ 0, 2 }), 1, {
    projectileConfig = {
      speed = 70,
      level = 7,
      actionOnReap = {
        {
          action = "spawnmonster",
          offset = { 0, 2 },
          type = "datacreature",
          arguments = dataMemory
        }
      }
	},
	dataMemory = dataMemory
  } )
  
  return true
end

function peariasMemory.isOwned()
  return storage.peariasOwnerUuid ~= nil
end