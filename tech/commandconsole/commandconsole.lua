function init()
  tech.setVisible(true)
  data.state = false
  data.buttons = {"button1", "button2", "button3", "button4"}
  data.primaryFire = false
  data.primaryFireOff = false
  if data.peariasPortList == nil then
    data.peariasPortList = {}
  end

  ui.init()
  --world.logInfo("Animation State Property: %s", tech.animationStateProperty("uiRootGroups", "groups"))
end

function uninit()
  data.numberSent = nil
end

function input(args)
  local move = nil
  if args.moves["special"] == 1 and not data.specialLast then
    return "uitoggle"
  end

  ui.input(args)

  data.specialLast = args.moves["special"] == 1

  return move
end

function toggleUI()
  data.state = not data.state
  if data.state then
    data.numberSent = nil
	ui.switchToGroup("mainGroup")
  else
    data.numberSent = nil
	ui.switchToGroup(nil)
  end
  tech.setToolUsageSuppressed(data.state)
end

function update(args)
  --world.logInfo("(Checking) Avalaible Port IDs = %s", data.peariasPortList)
  --world.logInfo("Update args: %s", args)
  if args.actions["uitoggle"] == true then
    toggleUI()
  end

  ui.update(args)

  -- Carry data from an antenna to another
  local availableObjects = world.objectQuery(tech.position(), 100)
  local portId
  if availableObjects ~= nil then
	for i, objectId in pairs(availableObjects) do
      if world.entityName(objectId) == "teleportantenna" then
		portId = objectId
		--world.logInfo("Tech found Ports ID = %s", portId)
		break
	  end
	end
  end
  if portId ~= nil then
    if next(data.peariasPortList) == nil then
	  table.insert(data.peariasPortList, portId)
	  --world.logInfo("(After empty) Avalaible Port IDs = %s", data.peariasPortList)
	else
	  local shouldAdd = true
	  for i, storedPort in pairs(data.peariasPortList) do
		if portId == storedPort then
		  shouldAdd = false
		end
		if portId ~= storedPort then
		  world.callScriptedEntity(portId, "signalConnected", storedPort)
		end
		if not world.entityExists(storedPort) then
		  table.remove(data.peariasPortList, storedPort)
		  --data.peariasPortList[i] = nil
		end
	  end
	  if shouldAdd then
	    table.insert(data.peariasPortList, portId)
	    --world.logInfo("(Overwrite or add) Avalaible Port IDs = %s", data.peariasPortList)
	  end
	end
  end

  portId = nil
  return 0
end

function button1()
  local npcTable = world.npcQuery(tech.position(), 20)
  for _, npcId in pairs(npcTable) do
    world.callScriptedEntity(npcId, "shopState.operatingState")
  end

  toggleUI()
end

function button2()
  local npcTable = world.npcQuery(tech.position(), 20)
  for _, npcId in pairs(npcTable) do
    world.callScriptedEntity(npcId, "bankStatus")
  end

  toggleUI()
end

function button3()
  local npcTable = world.npcQuery(tech.position(), 20)
  for _, npcId in pairs(npcTable) do
    world.callScriptedEntity(npcId, "freeInventory")
  end

  toggleUI()
end

function button4()
  local npcTable = world.npcQuery(tech.position(), 20)
  for _, npcId in pairs(npcTable) do
    world.callScriptedEntity(npcId, "entity.say", "I can't understand that command.")
	world.callScriptedEntity(npcId, "shouldDie")
  end

  toggleUI()
end

function switchbutton()
  data.group = "counterGroup"
  ui.switchToGroup("counterGroup")
end

function up1()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent < 9999 then
    data.numberSent = data.numberSent + 1
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function down1()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent > 0 then
    data.numberSent = data.numberSent - 1
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function up2()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent < 9990 then
    data.numberSent = data.numberSent + 10
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function down2()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent > 9 then
    data.numberSent = data.numberSent - 10
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function up3()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent < 9900 then
    data.numberSent = data.numberSent + 100
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function down3()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent > 99 then
    data.numberSent = data.numberSent - 100
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function up4()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent < 9000 then
    data.numberSent = data.numberSent + 1000
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function down4()
  if data.numberSent == nil then
    data.numberSent = 0
  end
  
  if data.numberSent > 999 then
    data.numberSent = data.numberSent - 1000
  end
  
  local num1State = data.numberSent%10
  --world.logInfo("Decimal 1: %s Number: %s", num1State, data.numberSent)
  tech.setAnimationState("decimal1", tostring(num1State))
  local num2State = (data.numberSent%100 - data.numberSent%10) / 10
  --world.logInfo("Decimal 2: %s Number: %s", num2State, data.numberSent)
  tech.setAnimationState("decimal2", tostring(num2State))
  local num3State = (data.numberSent%1000 - data.numberSent%100) / 100
  --world.logInfo("Decimal 3: %s Number: %s", num3State, data.numberSent)
  tech.setAnimationState("decimal3", tostring(num3State))
  local num4State = (data.numberSent - data.numberSent%1000) / 1000
  --world.logInfo("Decimal 4: %s Number: %s", num4State, data.numberSent)
  tech.setAnimationState("decimal4", tostring(num4State))
end

function send()
  local npcTable = world.npcQuery(tech.position(), 20)
  for _, npcId in pairs(npcTable) do
    world.callScriptedEntity(npcId, "giveAmount", data.numberSent)
  end

  toggleUI()
end

--------------------------------------------------------------------------------------
-- UI Library -- DO NOT CHANGE THIS LINE OR ANY LINE BELOW IT -- 0.1b ---------------
--------------------------------------------------------------------------------------

ui = {
  groups = {},
  rootGroups = {},
  components = {}
}

-- Initialize UI - MUST CALL IN TECH INIT()
function ui.init()
  local rootGroups = tech.animationStateProperty("uiRootGroups", "groups")
  --world.logInfo("Root Groups: %s", rootGroups)
  ui.loadGroups(rootGroups)
  ui.switchToGroup(nil)
  --world.logInfo("UI Groups: ")
  --printTable(ui.groups, 0)
end

-- Update UI input - MUST CALL IN TECH INPUT() WITH INPUT ARGS
function ui.input(args)
  if args.moves["primaryFire"] == true then
    ui.mouseDown = true
  else
    if ui.mouseDown == true then
      ui.mouseOff = true
    else
      ui.mouseOff = false
    end
    ui.mouseDown = false
  end
end

-- Update UI - MUST CALL IN TECH UPDATE() WITH UPDATE ARGS
function ui.update(args)
  local mousePos = world.distance(args.aimPosition, tech.position())
  for compName, comp in pairs(ui.components) do
    if comp.visible == true then
      comp:update(mousePos)
    end
  end
end

-- Get a group by name
function ui.getGroup(groupName)
  return ui.groups[groupName]
end

-- Get a component by name
function ui.getComponent(componentName)
  return ui.components[componentName]
end

-- Sets only this group to be visible
function ui.switchToGroup(groupName)
  for _,group in pairs(ui.rootGroups) do
    group:setVisible(false)
  end
  if groupName ~= nil then
    ui.groups[groupName]:setVisible(true)
  end
end

function ui.loadGroups(groups, parent)
  local groupsOut = {}
  --world.logInfo("Loading groups: %s", groups)
  for _,groupName in ipairs(groups) do
    --world.logInfo("Loading group: %s", groupName)
    local subGroupNames = tech.animationStateProperty(groupName, "subGroups")
    --world.logInfo("Loading subGroups: %s", subGroupNames)
    local group = Group:new({
      name = groupName,
      parent = parent
    })

    local subGroups = ui.loadGroups(subGroupNames, group)

    group.subGroups = subGroups

    local components = {}
    local componentNames = tech.animationStateProperty(groupName, "components")
    --world.logInfo("Loading components: %s", componentNames)
    for _,componentName in ipairs(componentNames) do
      --world.logInfo("Loading component: %s", componentName)
      local componentInfo = tech.animationStateProperty(componentName, "uiInfo")
      local comp = Component:new({
        name = componentName,
        parent = group,
        offset = componentInfo.offset or {0, 0},
        takesInput = componentInfo.takesInput or false,
        customPoly = componentInfo.customPoly or false,
        polygon = componentInfo.polygon or {},
        min = {100, 100},
        max = {-100, -100},
        visible = tech.animationState(componentName) ~= "invisible"
      })
      comp:reload()
      if comp.takesInput then
        comp.hoverFunction = componentInfo.hoverFunction
        comp.pressFunction = componentInfo.pressFunction
      end
      ui.components[componentName] = comp
      components[#components + 1] = comp
      --world.logInfo("Loaded component: %s", componentName)
    end

    group.components = components
    groupsOut[#groups + 1] = group
    ui.groups[groupName] = group
    if parent == nil then
      ui.rootGroups[groupName] = group
    end
    --world.logInfo("Loaded group: %s", groupName)
  end
  --world.logInfo("Loaded groups: %s", groups)
  return groupsOut
end

Group = {
  name = "default",
  parent = nil,
  subGroups = {},
  components = {}
}

function Group:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Sets visibliity of a group
function Group:setVisible(visible)
  for _,subGroup in ipairs(self.subGroups) do
    subGroup:setVisible(visible)
  end
  for _,component in ipairs(self.components) do
    component:setVisible(visible)
  end
end

Component = {
  name = "default",
  visible = false,
  parent = nil,
  takesInput = false,
  hovering = false,
  pressed = false,
  min = {0, 0},
  max = {0, 0},
  offset = {0, 0},
  customPoly = false,
  polygon = {}
}

function Component:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Sets visibility of component
function Component:setVisible(visible)
  if visible ~= self.visible then
    self.visible = visible
    if not visible then
      if self.hoverFunction ~= nil and self.hoverFunction ~= "" and self.hovering then
        _ENV[self.hoverFunction](false, self.name)
      end
      self.hovering = false
      self.pressed = false
    end
    --world.logInfo("Setting %s visible %s", self.name, visible and "normal" or "invisible")
    self:setAnimationState(visible and "normal" or "invisible")
    --world.logInfo("Animation state of %s: %s", self.name, tech.animationState(self.name))
  end
end

function Component:reload()
  local componentInfo = tech.animationStateProperty(self.name, "uiInfo")
  if componentInfo ~= nil then
    self.offset = componentInfo.offset or self.offset
    self.customPoly = componentInfo.customPoly or false
    self.polygon = componentInfo.polygon or {}
    if self.customPoly == true then
      for _,point in ipairs(self.polygon) do
        point[1] = point[1] + self.offset[1]
        if point[1] < self.min[1] then
          self.min[1] = point[1]
        end
        if point[1] > self.max[1] then
          self.max[1] = point[1]
        end
        point[2] = point[2] + self.offset[2]
        if point[2] < self.min[2] then
          self.min[2] = point[2]
        end
        if point[2] > self.max[2] then
          self.max[2] = point[2]
        end
      end
    else
      self.min[1] = self.offset[1]
      self.min[2] = self.offset[2]
      self.max[1] = self.offset[1] + componentInfo.size[1]
      self.max[2] = self.offset[2] + componentInfo.size[2]
      -- world.logInfo("%s min: %s, max: %s", self.name, self.min, self.max)
    end
  end
end

function Component:update(mousePos)
  if not self.takesInput then
    return
  end
  if self:contains(mousePos) then
    -- world.logInfo("%s contains mouse at %s", self.name, mousePos)
    if ui.mouseOff and self.pressed then
      if self.pressFunction ~= nil and self.pressFunction ~= "" then 
        _ENV[self.pressFunction](self.name)
      end
    end
    if not self.visible then
      return
    end
    if ui.mouseDown and not self.pressed then
      self:setAnimationState("pressed")
      self.pressed = true
    elseif (not self.hovering) or (not ui.mouseDown and self.pressed) then
      self:setAnimationState("hover")
      self.pressed = false
    end
    if self.hoverFunction ~= nil and self.hoverFunction ~= "" and not self.hovering then
      _ENV[self.hoverFunction](true, self.name)
    end
    self.hovering = true
  else
    if self.hovering or self.pressed then
      self:setAnimationState("normal")
      if self.hoverFunction ~= nil and self.hoverFunction ~= "" then
        _ENV[self.hoverFunction](false, self.name)
      end
    end
    self.hovering = false
    self.pressed = false
  end
end

-- Sets animation state of a component
function Component:setAnimationState(animState)
  if tech.animationState(self.name) ~= animState then
    tech.setAnimationState(self.name, animState)
    self:reload()
  end
end

function Component:contains(relativePos)
  -- world.logInfo("pointer: %s compare to min: %s, max: %s (%s)", relativePos, self.min, self.max, self.name)
  if relativePos[1] >= self.min[1] and
      relativePos[1] <= self.max[1] and
      relativePos[2] >= self.min[2] and
      relativePos[2] <= self.max[2] then
    if self.customPoly == true then
      local nvert = #self.polygon
      local i = 1
      local j = nvert
      local c = false
      while i <= nvert do
        if ( ((self.polygon[i][2] > relativePos[2]) ~= (self.polygon[j][2] > relativePos[2])) and
            (relativePos[1] < (self.polygon[j][1] - self.polygon[i][1]) * (relativePos[2] - self.polygon[i][2]) / 
            (self.polygon[j][2] - self.polygon[i][2]) + self.polygon[i][1]) ) then
          c = not c
        end
        j = i
        i = i + 1
      end
      return c
    else
      return true
    end
  end
  return false
end