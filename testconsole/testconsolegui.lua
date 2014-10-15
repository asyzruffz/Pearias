lightGridSize = 9
lightSize = 16
lightShrink = 2
lightXStart = 120
lightYStart = 30

function lightPosition(light)
  return {(light[1] - 1) * lightSize + lightXStart, (light[2] - 1) * lightSize + lightYStart}
end

function lightFor(pos)
  return {math.floor((pos[1] - lightXStart) / lightSize) + 1, math.floor((pos[2] - lightYStart) / lightSize) + 1}
end

function lightWithinRange(light)
  return light[1] >= 1 and light[1] <= lightGridSize and light[2] >= 1 and light[2] <= lightGridSize
end

function lightValue(light)
  if lightWithinRange(light) then
    return self.lights[light[1]..":"..light[2]]
  else
    return false
  end
end

function setLightValue(light, val)
  if lightWithinRange then
    self.lights[light[1]..":"..light[2]] = val
  end
end

function toggleLightValue(light)
  setLightValue(light, not lightValue(light))
end

function init()
  self.lights = {}
  for x = 1, lightGridSize do
    for y = 1, lightGridSize do
      setLightValue({x, y}, true)
    end
  end
end

function update()
  for x = 1, lightGridSize do
    for y = 1, lightGridSize do
      if lightValue({x, y}) then
        local pos = lightPosition({x, y})

        console.canvasDrawRect(
            {pos[1] + lightShrink, pos[2] + lightShrink, pos[1] + lightSize - lightShrink, pos[2] + lightSize - lightShrink},
            {255, 255, 255}
          )

        local gridMin = {lightXStart, lightYStart}
        local gridMax = {lightXStart + lightSize * lightGridSize, lightYStart + lightSize * lightGridSize}

        console.canvasDrawPoly(
            {{gridMin[1], gridMin[2]}, {gridMax[1], gridMin[2]}, {gridMax[1], gridMax[2]}, {gridMin[1], gridMax[2]}},
            {255, 255, 255}
          )
      end
    end
  end

  local allGone = true
  for x = 1, lightGridSize do
    for y = 1, lightGridSize do
      if lightValue({x, y}) then
        allGone = false
      end
    end
  end

  if allGone then
    world.callScriptedEntity(console.sourceEntity(), "youwin")
    console.dismiss()
  end
end

function canvasClickEvent(position, button)
  local light = lightFor(position)
  if lightWithinRange(light) then
    if button == 1 then
      console.playSound("/sfx/interface/keypad_press.wav", 0, 1.0)
      toggleLightValue({light[1], light[2]})
      toggleLightValue({light[1] - 1, light[2]})
      toggleLightValue({light[1], light[2] - 1})
      toggleLightValue({light[1] + 1, light[2]})
      toggleLightValue({light[1], light[2] + 1})
    end
    if button == 3 then
      console.playSound("/sfx/interface/clickon_error.ogg", 0, 1.0)
      toggleLightValue({light[1], light[2]})
    end
  end
end
