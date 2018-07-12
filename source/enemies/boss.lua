local function bossInit(enemy, x, y, arg)

  -- Initialize physics
  enemy.physics = world:newBSGRectangleCollider(x, y, 256, 256, 82)
  enemy.physics:setCollisionClass('Enemy')
  enemy.physics:setType('static')
  enemy.physics:setFixedRotation(true)
  -- We need this to access the table itself given the physics
  enemy.physics.parent = enemy

  -- Properties
  enemy.health = 300
  enemy.hitPower = 12
  enemy.moveForce = 11000
  enemy.maxSpeed = 400
  enemy.barY = 1000 -- Putting the health bar above the screen
  
  -- Shake logic
  local ex, ey = enemy.physics:getPosition()
  enemy.baseY = ey -- Default Y position (since the boss will move)
  
  -- How far the boss deviates from the Y position
  enemy.shortDist = 10
  enemy.longDist = 16
  enemy.distY = enemy.shortDist
  
  -- Shake direction and speed
  enemy.shakeDir = 1 -- 1 for down, -1 for up
  enemy.fastShake = 180
  enemy.slowShake = 8
  enemy.shakeSpeed = enemy.slowShake

  -- Sprite info
  enemy.sprite = sprites.enemies.bossBody

  -- Eyes
  enemy.eye = spawnEye(ex, ey, 0, 1, sprites.enemies.bigBossEye)
  
  -- State
  enemy.state = 1
  enemy.stateTimer = 1
  enemy.stateCounter = 0

  function enemy:update(dt)
    
    self.stateTimer = updateTimer(self.stateTimer, dt)

    local ex, ey = self.physics:getPosition()
    self.eye:update(dt, ex, ey, toPlayerRotate(ex, ey))
    
    -- Breathing/Shaking
    -- The boss bobs up and down either slowly or quickly
    self.physics:setY(ey + (self.shakeDir * self.shakeSpeed * dt))
    
    -- If the boss moves too far past its base position,
    -- change the direction
    if math.abs(self.baseY - self.physics:getY()) > self.distY then
      self.shakeDir = self.shakeDir * -1
    end

    -- State 0: Boss Intro (eyes opening)
    if self.state == 0 then
      
    end
    
    -- State 1: Lasers
    if self.state == 1 then
      
      -- When the timer is up
      if self.stateTimer <= 0 then
        
        -- ...and the counter is even, spawn a reverse blast
        -- indicating that a laser is about to be shot
        if self.stateCounter % 2 == 0 then
          spawnBlast(ex, ey, 1400, {1, 0, 0}, 1.5, true)
          self.stateTimer = 1.5
        else
          -- ...otherwise, shoot a laser
          spawnEnemyProj(ex, ey, toPlayerVector(ex, ey), "bossLaser")
          spawnBlast(ex, ey, 2200, {1, 0, 0}, 0.75)
          self.stateTimer = 3
        end
        
        -- increase the counter
        self.stateCounter = self.stateCounter + 1
        
        -- After shooting 3 lasers, move to a different state
        if self.stateCounter == 2 then -- CHANGE TO 6
          self.state = self.state + 1
          self.stateCounter = 0
          self.stateTimer = 2
        end
        
      end
      
    end
    
    -- State 2: Shake to spawn flyers
    if self.state == 2 then
      
      -- Start shaking
      if self.stateTimer == 0 and self.stateCounter == 0 then
        
        self.shakeSpeed = self.fastShake
        self.distY = self.shortDist
        self.stateTimer = 0.5
        self.stateCounter = self.stateCounter + 1
        
      end
      
      -- Spawn a flyer
      if self.stateTimer == 0 and self.stateCounter > 0 then
        
        self.stateTimer = 0.75
        self.stateCounter = self.stateCounter + 1
        
        -- Spawn flyers, randomly on each side of the boss
        local x = 448 + math.random(0, 640) -- left side
        if math.random() > 0.5 then
          x = x + 1024 -- move to the right side
        end
        
        spawnEnemy(x, 290, "bat", true)
        
      end
      
      if self.stateCounter > 4 then
        self.state = 3
      end
      
    end
    
    
    if self.state == 3 then
      self.shakeSpeed = self.slowShake
      self.distY = self.shortDist
    end

    -- REMOVE THIS AFTER BOSS IS DONE!!!
    blackScreen.alpha = 0
  end

  function enemy:draw()
    local sprX, sprY = self.physics.body:getPosition()

    -- Draw the body of the boss
    sprW = self.sprite:getWidth()
    sprH = self.sprite:getHeight()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.sprite, sprX, sprY, nil, 1, 1, sprW/2, sprH/1.4)
  end

  return enemy

end

return bossInit
