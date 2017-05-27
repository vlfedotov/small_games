require 'socket'
local vector = require 'hump/vector'

local bullets = require 'bullets'


local bonus_sound = love.audio.newSource("sounds/sfx_sounds_powerup8.wav", "static")


local bonuses = {}
bonuses.current_level_bonuses = {}
bonuses.circle_fire_n_points = 15
bonuses.speed = 15
bonuses.radius = 5
bonuses.prize_probability = 0.1 -- from 0.0 to 1.0
bonuses.current_bonus_texts = {}
bonuses.bonus_duration = 5
bonuses.bonus_text_speed = 20
bonuses.bonus_text_alpha_speed = 0.5
bonuses.bonus_text_duration = 2

bonuses.prizes = {
  'circle_fire',
  'plus_one_life',
  'temp_slow_enemies',
  'temp_triple_fire',
  'god_mode'
}

bonuses.prize_titles = {
  circle_fire='CIRCLE OF FIRE',
  plus_one_life='ONE LIFE UP',
  temp_slow_enemies='SLOW ASTEROIDS',
  temp_triple_fire='TRIPLE FIRE',
  god_mode='GOD MODE'
}


function bonuses.temp_triple_fire( ship )
  ship:change_fire_mode{ fire_mode = 'triple', seconds = bonuses.bonus_duration }
end


function bonuses.god_mode( ship )
  ship.god_mode = true
  ship.god_mode_created = socket.gettime()
  ship.god_mode_duration = bonuses.bonus_duration
end


function bonuses.plus_one_life( ship )
  ship.lives = ship.lives + 1
end


function bonuses.circle_fire( ship )
  local point = vector(0, 10)
  for i = 1, bonuses.circle_fire_n_points do
    local position = point:rotated( (360 / bonuses.circle_fire_n_points) * (i - 1) / 180 * math.pi )
    local direction_vector = position:clone()
    direction_vector:normalizeInplace()
    position = position + ship.position
    bullets:create_bullet{ position_vector = position, direction_vector = direction_vector }
  end
end


function bonuses.temp_slow_enemies( ship, asteroids )
  asteroids:change_speed{ change_coef = 0.5, seconds = bonuses.bonus_duration }
end


function bonuses:create_bonus_text( text, ship )
  local bonus_text = {
    position = ship.position:clone(),
    text = text,
    start_time = os.time(),
    alpha = 0.8,
  }
  table.insert(self.current_bonus_texts, bonus_text)
end


function bonuses:create_bonus( params )
  if math.random() > (1 - bonuses.prize_probability) then
    prize_number = math.random(1, #bonuses.prizes)
    bonus = {
      position = vector(params.x, params.y),
      direction_vector = vector(math.random(), math.random()):normalizeInplace() * bonuses.speed,
      size = bonuses.radius * 2,
      prize = bonuses.prizes[prize_number]
    }

    function bonus:apply_bonus( ship, asteroids )
      bonus_sound:stop()
      bonus_sound:play()
      bonuses[bonus.prize]( ship, asteroids )
      bonuses:create_bonus_text( bonuses.prize_titles[bonus.prize], ship )
    end

    function bonus:destroy_bonus( bonus_i )
      bonuses.current_level_bonuses[bonus_i] = nil
    end

    table.insert(bonuses.current_level_bonuses, bonus)
  end
end


function bonuses:draw_bonus( single_bonus, game_state )
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(35, 205, 35, 255 - game_state.fading_alpha)
  love.graphics.circle('fill', single_bonus.position.x, single_bonus.position.y, bonuses.radius)
  love.graphics.setColor(r, g, b, a)
end


function bonuses:draw_bonus_text( single_bonus_text )
  local colored_text = {
    {255, 255, 255, 255 * single_bonus_text.alpha},
    single_bonus_text.text
  }
  love.graphics.printf(colored_text, single_bonus_text.position.x,
                       single_bonus_text.position.y, 200, 'left')
end


function bonuses:draw( game_state )
  for _, single_bonus in pairs(bonuses.current_level_bonuses) do
    bonuses:draw_bonus( single_bonus, game_state )
  end
  for _, single_bonus_text in pairs(bonuses.current_bonus_texts) do
    bonuses:draw_bonus_text( single_bonus_text )
  end
end


function bonuses:update_bonus( single_bonus, dt )
  single_bonus.position = single_bonus.position + single_bonus.direction_vector * dt
end


function bonuses:update_bonus_text( single_bonus_text, dt )
  single_bonus_text.position.y = single_bonus_text.position.y - bonuses.bonus_text_speed * dt
  single_bonus_text.alpha = single_bonus_text.alpha - bonuses.bonus_text_alpha_speed * dt
end


function bonuses:update( dt )
  for _, single_bonus in pairs(bonuses.current_level_bonuses) do
    bonuses:update_bonus( single_bonus, dt )
  end
  for i, single_bonus_text in pairs(bonuses.current_bonus_texts) do
    if os.time() - single_bonus_text.start_time >= bonuses.bonus_text_duration then
      bonuses.current_bonus_texts[i] = nil
    else
      bonuses:update_bonus_text( single_bonus_text, dt )
    end
  end
end


return bonuses
