bump = require "bump"
world = bump.newWorld()

player = {
  x = 0,
  y = 0,
  width = 32,
  height = 64,
  gravity = 500,
  runSpeed = 600,
  xVelocity = 0,
  yVelocity = 0,
  terminalVelocity = 800,
  jumpVelocity = -400,
  onGround = false,
}

function player.setPosition(x, y)
  player.x, player.y = x, y
end

function player.update(dt)
  player.move(dt)
  player.applyGravity(dt)
  player.collide(dt)
end

function player.move(dt)
  if love.keyboard.isDown("d") then
    player.xVelocity = player.runSpeed
  elseif love.keyboard.isDown("a") then
    player.xVelocity = -player.runSpeed
  else
    player.xVelocity = 0
  end
end

function player.applyGravity(dt)
  if player.yVelocity < player.terminalVelocity then
    player.yVelocity = player.yVelocity + player.gravity * dt
  else
    player.yVelocity = player.terminalVelocity
  end
end

function player.collide(dt)
  local futureX = player.x + player.xVelocity * dt
  local futureY = player.y + player.yVelocity * dt
  local nextX, nextY, cols, len = world:move(player, futureX, futureY)

  player.onGround = false
  for i = 1, len do
    local col = cols[i]
    if col.normal.y == -1 or col.normal.y == 1 then
      player.yVelocity = 0
    end
    if col.normal.y == -1 then
      player.onGround = true
    end

    ---added code
    if col.normal.x ~= 0 and player.yVelocity < 0 then
      player.yVelocity = player.yVelocity + 150 * dt
    end
  end

  player.x = nextX
  player.y = nextY
end

function player.draw()
  love.graphics.setColor(255, 255, 0)
  love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end

function player.jump(key)
  if key == "w" and player.onGround then
    player.yVelocity = player.jumpVelocity
  end
end

local level = require "level_1"

function loadObjects(level)
  local objects = level.layers[1].objects
  for i = 1, #objects do
    local obj = objects[i]
    world:add(obj, obj.x, obj.y, obj.width, obj.height)
  end
end

function drawObjects(level)
  local objects = level.layers[1].objects
  love.graphics.setColor(255, 20, 200)
  for i = 1, #objects do
    local obj = objects[i]
    love.graphics.rectangle('line', obj.x, obj.y, obj.width, obj.height)
  end
end

-- main

function love.load()
  player.setPosition(love.graphics.getWidth()/2, 0)
  world:add(player, player.x, player.y, player.width, player.height)
  loadObjects(level)
end

function love.update(dt)
  player.update(dt)
end

function love.draw()
  player.draw()
  drawObjects(level)
end

function love.keypressed(key)
  player.jump(key)
end
