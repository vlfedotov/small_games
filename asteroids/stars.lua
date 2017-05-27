local vector = require 'hump/vector'


local stars = {}
stars.current_level_stars = {}

stars.move_vector = vector(0, 0)
stars.max_stars = 100
stars.fading_speed = 0.25


function stars.random_star()
  local star = vector(
    math.random(1, love.graphics.getWidth()),
    math.random(1, love.graphics.getHeight())
  )
  return star
end


function stars.construct_level()
  for i = 1, stars.max_stars do
    local new_star = stars.random_star()
    table.insert( stars.current_level_stars, new_star )
  end
end


function stars.draw_star( star )
  love.graphics.circle( 'fill', star.x, star.y, 1 )
end


function stars.draw()
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor( 255, 255, 255, 50 )
  for _, star in pairs( stars.current_level_stars ) do
    stars.draw_star( star )
  end
  love.graphics.setColor( r, g, b, a )
end


function stars:update_star( dt, star )
  star.x = (star.x + self.move_vector.x * dt) % love.graphics.getWidth()
  star.y = (star.y + self.move_vector.y * dt) % love.graphics.getHeight()
end


function stars:update( dt, game_state )
  if game_state.state ~= 'game' and self.move_vector:len() > 0 then
    self.move_vector = self.move_vector * (1 - dt * self.fading_speed)
  end
  for i, star in ipairs( self.current_level_stars ) do
    stars:update_star( dt, star )
  end
end


return stars
