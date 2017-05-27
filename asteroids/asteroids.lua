local vector = require 'hump/vector'


local asteroids = {}
asteroids.current_level_asteroids = {}
asteroids.current_level_explosions = {}
asteroids.default_speed = 50
asteroids.current_speed = asteroids.default_speed
asteroids.default_n_points = 12
asteroids.default_size = 24
asteroids.initial_rotation_angle = 50
asteroids.spawn_new_asteroid_time = 5
asteroids.last_asteroid_time = os.time()
asteroids.explosion_speed = 5
asteroids.explosion_alpha_speed = 0.5
asteroids.explosion_duration = 50 / 1000

local _M = vector(
  love.graphics.getWidth() / 2,
  love.graphics.getHeight() / 2
)

local _W = love.graphics.getWidth()
local _H = love.graphics.getHeight()
local hide_screen = (_W * 0.1 + _H * 0.1) /2 -- невидимая зона за экраном, где астероиды появляются


function asteroids:change_speed( params )  -- params = {change_coef=float, seconds=int}
  local new_speed
  if params then
    new_speed = self.current_speed * params.change_coef
    self.slow_time = os.time()
    self.slow_duration = params.seconds
  else
    new_speed = self.default_speed
    self.slow_time = nil
    self.slow_duration = nil
  end
  for _, asteroid in pairs(self.current_level_asteroids) do
    asteroid.move_vector = asteroid.move_vector / asteroid.speed * new_speed
    asteroid.speed = new_speed
  end
  self.current_speed = new_speed
end


function asteroids:get_asteroid( position, direction, n_points, size )
  local asteroid = {}

  asteroid.n_points = n_points or self.default_n_points
  asteroid.size = size or self.default_size
  asteroid.position = position
  asteroid.speed = self.current_speed
  asteroid.move_vector = direction * asteroid.speed * ( math.random( 8, 12 ) / 10 )
  asteroid.rotation_angle = math.random(-10, 10) / 10 * self.initial_rotation_angle

  asteroid.vertices = {}
  local point = vector(0, 1)
  for i = 1, asteroid.n_points do
    local vertex = point:rotated( (360 / asteroid.n_points) * i / 180 * math.pi )
    vertex = vertex * size
    vertex = vertex * math.random(6, 12) / 10

    table.insert( asteroid.vertices, vertex )
  end

  return asteroid
end


function asteroids:create_asteroid( position, direction, n_points, size )
  local new_asteroid = asteroids:get_asteroid(
    position, direction,
    n_points or asteroids.default_n_points,
    size or asteroids.default_size
  )
  table.insert( self.current_level_asteroids, new_asteroid )
end


function asteroids:create_random_asteroid()
  -- получим начальную позицию
  -- сперва опеределим сбоку вылетит астероид или сверху/снизу
  local position
  if math.random() < 0.5 then
    --
    position = vector(0 - hide_screen/2, math.random(0, love.graphics.getHeight()))
  else
    position = vector(math.random(0, love.graphics.getWidth()), 0 - hide_screen/2)
  end



  local random_direction = vector(
    math.random(-10, 10) / 10,
    math.random(-10, 10) / 10
  )
  local normal_direction = random_direction / random_direction:len()

  local normal_direction_with_offset = normal_direction:rotated( math.random( 0, 20 ) / 10 )

  self:create_asteroid( position, normal_direction_with_offset )
end


function asteroids:construct_level( n_asteroids )
  for i = 1, n_asteroids do
    asteroids:create_random_asteroid()
  end
end


function asteroids:create_explosion( asteroid )
  local explosion = {}
  explosion.position = asteroid.position:clone()
  explosion.size = asteroid.size
  explosion.n_points = 12
  explosion.alpha = 0.8
  explosion.created_at = os.clock()

  explosion.vertices = {}
  local point = vector(0, 1)
  for i = 1, explosion.n_points do
    local vertex = point:rotated( (360 / explosion.n_points) * i / 180 * math.pi )
    vertex = vertex * explosion.size
    table.insert( explosion.vertices, vertex )
  end

  table.insert(self.current_level_explosions, explosion)
end


function asteroids:destroy_asteroid( i, score )
  local asteroid = asteroids.current_level_asteroids[i]
  if asteroid.n_points > 3 then
    local new_direction = asteroid.move_vector:perpendicular() / asteroid.move_vector:len()
    asteroids:create_asteroid(
      asteroid.position,
      new_direction,
      asteroid.n_points / 2,
      asteroid.size / 2
    )
    asteroids:create_asteroid(
      asteroid.position,
      -new_direction,
      asteroid.n_points / 2,
      asteroid.size / 2
    )
  end

  asteroids:create_explosion( asteroid )
  asteroids.current_level_asteroids[i] = nil

  score.score = score.score + score.asteroid_bench - asteroid.n_points
end


function asteroids.draw_body_line ( point_a, point_b )
  love.graphics.line( point_a.x, point_a.y, point_b.x, point_b.y )
end


function asteroids.draw_asteroid( asteroid )
  for i = 1, #asteroid.vertices do
    local j = i + 1
    if i == #asteroid.vertices then
      j = 1
    end
    local a = asteroid.vertices[i] + asteroid.position
    local b = asteroid.vertices[j] + asteroid.position
    asteroids.draw_body_line( a, b )
  end
end


function asteroids.draw_explosion( explosion )
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(255, 255, 255, 255 * explosion.alpha)
  for i = 1, #explosion.vertices do
    local vertex = explosion.vertices[i] + explosion.position
    love.graphics.circle('fill', vertex.x, vertex.y, 1)
  end
  love.graphics.setColor(r, g, b, a)
end


function asteroids.draw()
  for _, asteroid in pairs( asteroids.current_level_asteroids ) do
    asteroids.draw_asteroid( asteroid )
  end
  for _, explosion in pairs( asteroids.current_level_explosions ) do
    asteroids.draw_explosion ( explosion )
  end
end


local function asteroid_rotate ( asteroid, dt )
  for _, point in pairs(asteroid.vertices) do
    point:rotateInplace( asteroid.rotation_angle * dt / 180 * math.pi )
  end
end


function asteroids:update_asteroid( asteroid, dt )
  local position_x = (asteroid.position.x + asteroid.move_vector.x * dt) % (_W + hide_screen)
  local position_y = (asteroid.position.y + asteroid.move_vector.y * dt) % (_H + hide_screen)
  asteroid.position = vector(position_x, position_y)
  asteroid_rotate( asteroid, dt )
end


function asteroids:update_explosion( explosion_i, explosion, dt )
  if os.clock() - explosion.created_at >= self.explosion_duration then
    self.current_level_explosions[explosion_i] = nil
    return
  end

  explosion.alpha = explosion.alpha - asteroids.explosion_alpha_speed * dt
  for i = 1, #explosion.vertices do
    local vertex = explosion.vertices[i]
    vertex = vertex + vertex * asteroids.explosion_speed / 5 * dt
    explosion.vertices[i] = vertex
  end
end


function asteroids:spawn_asteroids()
  if os.time() - self.last_asteroid_time >= self.spawn_new_asteroid_time then
    self:create_random_asteroid()
    self.last_asteroid_time = os.time()
  end
end


function asteroids:update( dt )
  for _, asteroid in pairs(self.current_level_asteroids) do
    self:update_asteroid( asteroid, dt )
  end

  for i, explosion in pairs(self.current_level_explosions) do
    self:update_explosion( i, explosion, dt )
  end

  if self.slow_time then
    if os.time() - self.slow_time >= self.slow_duration then
      self:change_speed()
    end
  end

  asteroids:spawn_asteroids()

end


return asteroids
