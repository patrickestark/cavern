-- Stores all pickups in the map
pickups = {}

-- Spawns a pickup, name is used to identify the type of pickup
function spawnPickup(name, x, y)

  -- If we already collected the pickup, don't spawn it
  if gameState.pickups[name] then
    return nil
  end

  local pickup = {}
  pickup.name = name
  pickup.dead = false
  pickup.float = true
  pickup.radius = 40
  
  -- used for floating
  pickup.state = 0
  pickup.tween = nil
  pickup.startY = y
  pickup.y = y
  
  pickup.physics = world:newCircleCollider(x, y, pickup.radius)

  pickup.sprite = sprites.pickups.item
  
  if name == "health1" or name == "health2" then
    pickup.sprite = sprites.pickups.health
  end

  -- Set the pickup's collision class
  pickup.physics:setCollisionClass('Pickup')

  -- Needed so we can reference the pickup table given its physics
  pickup.physics.parent = pickup

  table.insert(pickups, pickup)

end

-- Update all pickups currently in the map
function pickups:update(dt)

  for i, p in ipairs(pickups) do

    -- float functionality goes here
    if p.state == 0 then
      local destY = p.y + 20
      p.tween = flux.to(p, 2.5, {y = destY}):ease("quadinout")
      p.state = 1
    elseif p.state == 1 then
      if p.y == p.startY + 20 then
        local destY = p.y - 40
        p.tween = flux.to(p, 2.5, {y = destY}):ease("quadinout")
        p.state = 2
      end
    elseif p.state == 2 then
      if p.y == p.startY - 20 then
        local destY = p.y + 40
        p.tween = flux.to(p, 2.5, {y = destY}):ease("quadinout")
        p.state = 1
      end
    end
    
    p.physics:setY(p.y)

    -- colliding with the player
    if p.physics:enter('Player') then
      -- sets the appropriate pickup value
      gameState.pickups[p.name] = true
      p.physics:destroy()
      p.dead = true

      if p.name == "blaster" then
        player.weapon = 1
        textBox:start("blaster")
      elseif p.name == "rocket" then
        player.weapon = 2
        textBox:start("rocket")
      elseif p.name == "harpoon" then
        player.weapon = 3
        textBox:start("harpoon")
      elseif p.name == "aquaPack" then
        textBox:start("aquaPack")
      elseif p.name == "health1" or p.name == "health2" then
        gameState.player.maxHealth = gameState.player.maxHealth + 5
        player.health = gameState.player.maxHealth
        textBox:start("health")
      end
    end

  end

  -- Iterate through all pickups in reverse to remove dead pickups from table
  for i=#pickups,1,-1 do
    if pickups[i].dead then
      table.remove(pickups, i)
    end
  end

end

-- Draw all pickups
function pickups:draw()
  for _,p in ipairs(self) do
    local px, py = p.physics:getPosition()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(p.sprite, px, py, nil, 1, 1, p.sprite:getWidth()/2, p.sprite:getHeight()/2)
  end
end
