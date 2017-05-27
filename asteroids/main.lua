local vector = require 'hump/vector'

local ship = require 'ship'
local stars = require 'stars'
local asteroids = require 'asteroids'
local bullets = require 'bullets'
local collisions = require 'collisions'
local bonuses = require 'bonuses'

local utils = require 'utils'


local score = {
  font = love.graphics.newFont(25),
  -- score for taking bonus
  bonus = 10,
  position = vector(300, 15),
  -- score for destroying asteroid
  -- less vertices asteroid consists of - more score point player will get
  -- formula: asteroid_bench - #asteroid.vertices
  asteroid_bench = 30,
}

local debug = {
  is_enabled = false,
  font = love.graphics.newFont(12),
  start_position = vector(15, 500),
  -- height between debug lines
  height_diff = 15
}

-- ship_life block and methods use it are all responsible for presentation
-- and animation of player's lives
-- when ship die, big text with lives left is shown in the middle of the screen
-- then text is decreasing and flies towards top left corner
local ship_life = {
  -- since text is not static we should store default values of it to be able to recover them
  DEFAULT_FONT_SIZE = 15,
  DEFAULT_FONT_POSITION = vector(0, 15),
  DEFAULT_FONT = love.graphics.newFont(15),
  DEFAULT_BIG_FONT_SIZE = 100,
  DEFAULT_BIG_FONT_ALPHA = 255,
  DEFAULT_BIG_FONT_POSITION = vector(350, 250),
  BIG_FONT_DURATION = 1,
  DECREASING_DURATION = 2,
  DECREASING_SPEED = 1,
  
  is_big_font = false,
  is_decreasing_font = false,
}
ship_life.DEFAULT_DISTANCE_TO_DEFAULT = ship_life.DEFAULT_FONT_POSITION - ship_life.DEFAULT_BIG_FONT_POSITION


local the_end_sign = {
  font = love.graphics.newFont(35),
  text = 'THE END'
}


local game_state = {
  state = 'game',
  -- how long the pre-end-game-phase will last in seconds
  FADING_DURATION = 5,
  fading_alpha = 0,
  end_game_created
}
game_state.FADING_SPEED = 255 / game_state.FADING_DURATION


function love.load()
  love.keyboard.setKeyRepeat( true )

  score.score = 0
  stars.construct_level()
  -- starting number of asteroids
  asteroids:construct_level( 5 )

  ship:reset_position( ship_life )

  math.randomseed( os.time() )
end


function love.keypressed( key )
  if game_state.state == 'game' then
    if key == 'up' then
      -- engine is on
      ship.is_moving = true
    end
    if key == 'left' then
      ship.rotate_angle = -90
    elseif key == 'right' then
      ship.rotate_angle = 90
    end
  end
end


function love.keyreleased( key )
  if game_state.state == 'game' then
    if key == 'up' then
      ship.is_moving = false
    end
    if key == 'left' or key == 'right' then
      ship.rotate_angle = 0
    end
    if key == 'space' then
      ship:fire()
    end
  end
  if key == 'd' then
    debug.is_enabled = not debug.is_enabled
  end
end


local function draw_score()
  local font = love.graphics.getFont()
  local r,g,b,a = love.graphics.getColor()
  love.graphics.setFont(score.font)
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.printf(tostring(score.score),
                       score.position.x,
                       score.position.y,
                       200, 'center')

  love.graphics.setFont(font)
  love.graphics.setColor(r, g, b, a)
end


local function draw_ship_life()
  local font = love.graphics.getFont()
  love.graphics.setFont(ship_life.DEFAULT_FONT)

  love.graphics.printf(
        tostring(ship.lives),
        ship_life.DEFAULT_FONT_POSITION.x,
        ship_life.DEFAULT_FONT_POSITION.y,
        100, 'center')

  love.graphics.setFont(font)
end


local function draw_big_ship_life()
  local font = love.graphics.getFont()
  local r,g,b,a = love.graphics.getColor()
  love.graphics.setColor(255, 255, 255, ship_life.big_font_alpha)
  love.graphics.setFont(ship_life.big_font)

  love.graphics.printf(
        tostring(ship.lives),
        ship_life.big_font_position.x,
        ship_life.big_font_position.y,
        100, 'center')

  love.graphics.setFont(font)
  love.graphics.setColor(r, g, b, a)
end



local function draw_debug()
  local font = love.graphics.getFont()
  local r,g,b,a = love.graphics.getColor()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(debug.font)

  love.graphics.printf('bullets: ' .. tostring(utils.get_table_length(bullets.current_level_bullets)),
                       debug.start_position.x, debug.start_position.y + debug.height_diff * 0,
                       200, 'left')
  love.graphics.printf('asteroids: ' .. tostring(utils.get_table_length(asteroids.current_level_asteroids)),
                       debug.start_position.x, debug.start_position.y + debug.height_diff * 1,
                       200, 'left')
  love.graphics.printf('asteroid explosions: ' .. tostring(utils.get_table_length(asteroids.current_level_explosions)),
                       debug.start_position.x, debug.start_position.y + debug.height_diff * 2,
                       200, 'left')
  love.graphics.printf('bonuses: ' .. tostring(utils.get_table_length(bonuses.current_level_bonuses)),
                       debug.start_position.x, debug.start_position.y + debug.height_diff * 3,
                       200, 'left')
  love.graphics.printf('bonuses: ' .. tostring(utils.get_table_length(bonuses.current_bonus_texts)),
                       debug.start_position.x, debug.start_position.y + debug.height_diff * 4,
                       200, 'left')

  love.graphics.setColor(r, g, b, a)
  love.graphics.setFont(font)
end


local function draw_the_end()
  local font = love.graphics.getFont()
  local r,g,b,a = love.graphics.getColor()
  love.graphics.setColor(255, 255, 255, game_state.fading_alpha)
  love.graphics.setFont(the_end_font)

  love.graphics.printf('THE END', 400, 300, 200, 'center')

  love.graphics.setColor(r, g, b, a)
  love.graphics.setFont(font)
end


function love.draw()
  stars.draw()
  draw_score()

  if ship_life.is_big_font then
    local reset_time_lapsed = os.time() - ship_life.reset_created
    if reset_time_lapsed > ship_life.BIG_FONT_DURATION then
      -- ship_life.is_big_font = false
      ship_life.is_decreasing_font = true
    end
    if reset_time_lapsed > ship_life.BIG_FONT_DURATION + ship_life.DECREASING_DURATION then
      ship_life.is_big_font = false
      ship_life.is_decreasing_font = false
    end
    draw_big_ship_life()
  end

  draw_ship_life()

  if game_state.state ~= 'end_game' then
    ship:draw( game_state )
    asteroids.draw()
    bullets:draw()
    bonuses:draw( game_state )
  end
  if game_state.state ~= 'game' then
    love.graphics.setColor(255, 255, 255, 255 - game_state.fading_alpha)
    draw_the_end()
  end
  if debug.is_enabled then
    draw_debug()
  end
end


function love.update( dt )
  if ship_life.is_decreasing_font then
    if ship_life.big_font_size > ship_life.DEFAULT_FONT_SIZE then
      ship_life.big_font_size = ship_life.big_font_size - 100 * dt
      ship_life.big_font = love.graphics.newFont(ship_life.big_font_size)
    end
    if ship_life.big_font_position.x > ship_life.DEFAULT_FONT_POSITION.x then
      ship_life.big_font_position = ship_life.big_font_position +
              ship_life.DEFAULT_DISTANCE_TO_DEFAULT * ship_life.DECREASING_SPEED * dt
    end
    ship_life.big_font_alpha = ship_life.big_font_alpha * (1 - dt)
  end

  if game_state.state == 'game' and ship.lives <= 0 then
    game_state.state = 'fading_game'
    game_state.end_game_created = os.time()
  end

  if game_state.state == 'fading_game' then
    if os.time() - game_state.end_game_created > game_state.FADING_DURATION then
      game_state.state = 'end_game'
    end

    game_state.fading_alpha = game_state.fading_alpha + game_state.FADING_SPEED * dt
  end

  if game_state.state ~= 'end_game' then
    ship:update( dt, stars )
    bullets:update( dt )
    stars:update( dt, game_state )
    asteroids:update( dt )
    bonuses:update( dt )
    collisions.resolve_collisions( ship, bullets, asteroids, bonuses, score, ship_life )
  end
end
