
-- god mode blinks require miliseconds
-- we get them from socket.gettime()
require 'socket'

local vector = require 'hump/vector'
local bullets = require 'bullets'


local MAX_SHIP_SPEED = 125
local EXPLOSION_BODY_SPEED = 50
local DEFAULT_FIRE_MODE = 'single'

local GOD_MODE_DURATION = 3
local GOD_MODE_BLINK_FREQUENCY = 0.25


-- pew-pew
local weapon_sound = love.audio.newSource("sounds/sfx_wpn_laser6.wav", "static")


local ship = {
        speed = 10,
        rotate_angle = 0,
        lives = 5,
        fire_mode = DEFAULT_FIRE_MODE,
      }

function ship:reset_position( ship_life )
  self.god_mode = true
  -- bonus 'god_mode' has its own duration for god_mode
  -- and ship.god_mode_duration store either of these two constants
  self.god_mode_duration = GOD_MODE_DURATION
  self.god_mode_created = socket.gettime()
  self.is_visible = true

  self.direction = vector(0, - 1)   -- normal vector, only direction
  self.position = vector(400, 300)  -- middle of the screen (800, 600)
  self.move_vector = vector(0, 0)   -- inert movement when ship's engine if off
  self.body = {
    top_point = vector(0, -15),
    center_point = vector(0, 0),
    bottom_left_point = vector(-7, 7),
    bottom_right_point = vector(7, 7),
  }

  if self.lives > 0 then
    ship_life.is_big_font = true
    ship_life.big_font_size = ship_life.DEFAULT_BIG_FONT_SIZE
    ship_life.big_font = love.graphics.newFont(ship_life.big_font_size)
    ship_life.big_font_alpha = ship_life.DEFAULT_BIG_FONT_ALPHA
    ship_life.big_font_position = ship_life.DEFAULT_BIG_FONT_POSITION:clone()
    ship_life.reset_created = os.time()
  end
end


function ship:single_fire( point )
  local position = self.body[point] + self.position
  local direction_vector = self.body.top_point:clone()
  local normal_direction_vector = direction_vector:normalizeInplace()

  bullets:create_bullet{ position_vector = position, direction_vector = normal_direction_vector }
end


function ship:fire()
  weapon_sound:stop()
  weapon_sound:play()
  if self.fire_mode == 'single' then
    ship:single_fire( 'top_point' )
  elseif self.fire_mode == 'triple' then
    for _, point in pairs({'top_point', 'bottom_left_point', 'bottom_right_point'}) do
      ship:single_fire( point )
    end
  end
end


function ship:change_fire_mode( params )
  if params then
    new_fire_mode = params.fire_mode
    self.bonus_fire_mode_time = os.clock()
    self.bonus_fire_mode_duration = params.seconds
  else
    new_fire_mode = self.default_fire_mode
    self.bonus_fire_mode_time = nil
    self.bonus_fire_mode_duration = nil
  end
  self.fire_mode = new_fire_mode
end

function ship:take_bonus( bonus, bonus_i, asteroids )
  bonus:apply_bonus( self, asteroids )
  bonus:destroy_bonus( bonus_i )
end


function ship:explode()
  self.explosion_body = {
    {self.body.top_point:clone(), self.body.bottom_left_point:clone(),
          move_vector=vector(math.random(), math.random()):normalizeInplace()},
    {self.body.bottom_left_point:clone(), self.body.center_point:clone(),
          move_vector=vector(math.random(), math.random()):normalizeInplace()},
    {self.body.center_point:clone(), self.body.bottom_right_point:clone(),
          move_vector=vector(math.random(), math.random()):normalizeInplace()},
    {self.body.bottom_right_point:clone(), self.body.top_point:clone(),
          move_vector=vector(math.random(), math.random()):normalizeInplace()},
  }
  self.explosion_body_position = self.position:clone()
  self.explosion_body_created = os.time()
end


function ship:destroy_ship( ship_life )
  self.is_moving = false
  self:explode()
  self.lives = self.lives - 1
  self:reset_position( ship_life )
end


function ship:rotate( phi, dt )
  for _, point in pairs(self.body) do
    point:rotateInplace( phi * dt / 180 * math.pi )
  end
end


function ship:draw_body_line( point_a, point_b )
  love.graphics.line( point_a.x, point_a.y, point_b.x, point_b.y )
end


function ship:draw( game_state )
  if self.explosion_body then
    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(235, 15, 15, 150 - game_state.fading_alpha )
    for _, line in pairs(self.explosion_body) do
      self:draw_body_line(line[1] + self.explosion_body_position, line[2] + self.explosion_body_position)
    end
    love.graphics.setColor(r, g, b, a)
  end

  if self.is_visible and self.lives > 0 then
    local body = self.body
    self:draw_body_line( body.top_point + self.position, body.bottom_left_point + self.position)
    self:draw_body_line( body.top_point + self.position, body.bottom_right_point + self.position)
    self:draw_body_line( body.bottom_left_point + self.position, body.center_point + self.position)
    self:draw_body_line( body.bottom_right_point + self.position, body.center_point + self.position)
  end
end


function ship:update_explosion( dt )
  for _, line in pairs(self.explosion_body) do
    line[1] = line[1] + line.move_vector * EXPLOSION_BODY_SPEED * dt
    line[2] = line[2] + line.move_vector * EXPLOSION_BODY_SPEED * dt
  end
end


function ship:move()
  local new_vector = self.move_vector + self.direction * self.speed
  local new_vector_length = new_vector:len()
  if new_vector_length > MAX_SHIP_SPEED then
    self.move_vector.x = new_vector.x / new_vector_length * MAX_SHIP_SPEED
    self.move_vector.y = new_vector.y / new_vector_length * MAX_SHIP_SPEED
  else
    self.move_vector = new_vector
  end
end


function ship:update( dt, stars )
  if self.god_mode then
    local time_passed_from_god_mode = socket.gettime() - self.god_mode_created

    if time_passed_from_god_mode / GOD_MODE_BLINK_FREQUENCY % 2 < 1 then
      self.is_visible = false
    else
      self.is_visible = true
    end
    if time_passed_from_god_mode > self.god_mode_duration then
      self.god_mode_created = nil
      self.god_mode = false
      self.is_visible = true
      self.god_mode_duration = GOD_MODE_DURATION
    end
  end

  if self.explosion_body then
    self:update_explosion( dt )
  end

  if self.is_moving then
    self:move()
    stars.move_vector = self.move_vector * (-1)
  end

  local position_x = (self.position.x + self.move_vector.x * dt) % love.graphics.getWidth()
  local position_y = (self.position.y + self.move_vector.y * dt) % love.graphics.getHeight()
  self.position = vector(position_x, position_y)

  self.direction:rotateInplace( self.rotate_angle * dt / 180 * math.pi )
  self:rotate ( self.rotate_angle, dt )

  if self.bonus_fire_mode_time then
    if os.clock() - self.bonus_fire_mode_time >= self.bonus_fire_mode_duration then
      self:change_fire_mode()
    end
  end

end


return ship
