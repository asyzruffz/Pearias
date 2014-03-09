shopState = {}

-- Called from command glass, open/close shop
function shopState.operatingState()
  if self.shopOpen == nil then
    self.shopOpen = false
  end
  
  if self.shopOpen then
    self.shopOpen = false
	entity.say("Shop is closed.")
	--world.logInfo("Shop is closed.")
  else
    self.shopOpen = true
	entity.say("Shop is open.")
	--world.logInfo("Shop is open.")
  end
end

function shopState.enterWith(args)
  if not self.shopOpen or self.shopOpen == nil then return nil end
  if args.interactArgs == nil then return nil end
  if args.interactArgs.sourceId == 0 then return nil end
  
  self.tradingConfig = shopState.buildTradingConfig()

  return {
    sourceId = args.interactArgs.sourceId,
    timer = entity.configParameter("shop.waitTime")
  }
end

function shopState.enteringState(stateData)
  sayToTarget("shop.dialog.start", stateData.sourceId)
end

function shopState.update(dt, stateData)
  local sourcePosition = world.entityPosition(stateData.sourceId)
  if sourcePosition == nil then
	return true 
  end

  local toSource = world.distance(sourcePosition, entity.position())
  setFacingDirection(toSource[1])
  self.tradingConfig = shopState.buildTradingConfig()

  if not self.shopOpen then
    return true
  end

  stateData.timer = stateData.timer - dt
  return stateData.timer <= 0
end

function shopState.leavingState(stateData)
  if world.entityExists(stateData.sourceId) then
    sayToTarget("shop.dialog.end", stateData.sourceId)
  end
end

function shopState.description()
	return "merchantState"
end

-- Called while building config, return amount of price given from command glass
function shopState.price(itemName)
  local price = entity.configParameter("shop.defaultSetPrice", 10)
  
  if self.gottenNumber ~= nil and self.shopOpen then
    price = self.gottenNumber
  elseif not self.shopOpen then
	self.gottenNumber = nil
  end
  
  return price
end

function shopState.buildTradingConfig()
  -- Build list of all possible items
  local level = entity.level()
  local items = {}
  for _, category in pairs(entity.configParameter("shop.categories")) do
    local levelSets = entity.configParameter("shop.items." .. category, nil)
    if levelSets ~= nil then
      -- Find the highest available level within the category
      local highestLevel, highestLevelSet = -1, nil
      for _, levelSet in pairs(levelSets) do
        if level >= levelSet[1] and levelSet[1] > highestLevel then
          highestLevel, highestLevelSet = levelSet[1], levelSet[2]
        end
      end

      if highestLevelSet ~= nil then
        for _, item in pairs(highestLevelSet) do
          table.insert(items, item)
        end
      end
    end
  end

  -- Reset the PRNG so the same seed always generates the same set of items.
  -- The uint64_t seed can get truncated when converted to a lua double, but
  -- it will at least provide a deterministic seed, even if the full range of
  -- input seeds can't be used
  local seed = tonumber(entity.seed())
  math.randomseed(seed)

  -- Shuffle the list
  for i = #items, 2, -1 do
    local j = math.random(i)
    items[i], items[j] = items[j], items[i]
  end

  local selectedItems, skippedItems = {}, {}
  local numItems = entity.configParameter("shop.numItems")
  for _, item in pairs(items) do
    if item.rarity == nil or math.random() > item.rarity then
      table.insert(selectedItems, item)

      if #selectedItems == numItems then
        break
      end
    else
      table.insert(skippedItems, item)
    end
  end

  -- May need to dip into the rare items to get enough
  for i = 1, math.min(#skippedItems, numItems - #selectedItems) do
    table.insert(selectedItems, skippedItems[i])
  end

  -- Build the trading config
  local tradingConfig = {
    config = "/interface/windowconfig/sellvendor.config",
    recipes = { }
  }

  -- In absense of a staticRandomizeParameterRange...
  if storage.priceVariance == nil then
    storage.priceVariance = entity.randomizeParameterRange("shop.priceVarianceRange")
  end

  local level = entity.level()
  for _, item in pairs(selectedItems) do
    local output = item.item

    if output.name ~= nil and string.find(output.name, "^generated") then
      if output.data then
        if output.data.level == nil then
          output.data.level = level
        end

        if output.data.seed == nil then
          output.data.seed = math.random() * seed
        end
      end
    end

    local recipe = {
      input = { { name = "money", count = item.cost * storage.priceVariance } },
      output = output
    }

    table.insert(tradingConfig.recipes, recipe)
  end

  -- Sell items in storage slot
  if storage.peariasInventory ~= nil then
	if storage.peariasInventory.slot1 ~= nil then
	  local output = storage.peariasInventory.slot1
	  output.count = 1
	  
	  local sellRecipe1 = {
		input = { { name = "money", count = shopState.price(storage.peariasInventory.slot1.name) * storage.priceVariance } },
		output = output
      }
	
	  table.insert(tradingConfig.recipes, sellRecipe1)
	else
	  if tradingConfig.recipes.sellRecipe1 ~= nil then
	    tradingConfig.recipes.sellRecipe1 = nil
	  end
	end
	if storage.peariasInventory.slot2 ~= nil then
	  local output = storage.peariasInventory.slot2
	  output.count = 1
	  
	  local sellRecipe2 = {
		input = { { name = "money", count = shopState.price(storage.peariasInventory.slot2.name) * storage.priceVariance } },
		output = output
      }
	
	  table.insert(tradingConfig.recipes, sellRecipe2)
	else
	  if tradingConfig.recipes.sellRecipe2 ~= nil then
	    tradingConfig.recipes.sellRecipe2 = nil
	  end
	end
	if storage.peariasInventory.slot3 ~= nil then
	  local output = storage.peariasInventory.slot3
	  output.count = 1
	  
	  local sellRecipe3 = {
		input = { { name = "money", count = shopState.price(storage.peariasInventory.slot1.name) * storage.priceVariance } },
		output = output
      }
	
	  table.insert(tradingConfig.recipes, sellRecipe3)
	else
	  if tradingConfig.recipes.sellRecipe3 ~= nil then
	    tradingConfig.recipes.sellRecipe3 = nil
	  end
	end
  end

  math.randomseed(os.time())

  return tradingConfig
end