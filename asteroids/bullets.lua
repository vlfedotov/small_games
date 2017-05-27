local vector = require 'hump/vector'


local bullets = {}
bullets.current_level_bullets = {}
bullets.default_speed = 300
bullets.max_len_2_until_destroy = 400 * 400
bullets.bullet_length = 5


function bullets:destroy_bullet( i )
  bullets.current_level_bullets[i] = nil
end


function bullets:create_bullet( args )
  local bullet = {
    initial_position = args.position_vector:clone(),
    position = args.position_vector,
    direction = args.direction_vector,
    speed = bullets.default_speed
  }
  --for k, v in pairs(bullet) do
  --    print(k, v)
  --end
  table.insert(self.current_level_bullets, bullet)
  --print(bullets:get_bullets_count())
end


function bullets:draw_bullet( single_bullet )
  love.graphics.line(
    single_bullet.position.x,
    single_bullet.position.y,
    single_bullet.position.x - single_bullet.direction.x * 5,
    single_bullet.position.y - single_bullet.direction.y * 10
  )
  --    love.graphics.circle( 'fill', bullet.position.x, bullet.position.y, 2 )
end


function bullets:draw()
  for i, bullet in pairs( self.current_level_bullets ) do
    self:draw_bullet( bullet )
  end
end


function bullets:update_bullet( single_bullet, dt )
  single_bullet.position.x = (single_bullet.position.x + single_bullet.direction.x * single_bullet.speed * dt)
  single_bullet.position.y = (single_bullet.position.y + single_bullet.direction.y * single_bullet.speed * dt)
end


function bullets:update( dt )
  for i, bullet in pairs( self.current_level_bullets ) do
    local bullet_length = bullet.position - bullet.initial_position
    if bullet_length:len2() > self.max_len_2_until_destroy then
      self.current_level_bullets[i] = nil
    end

    bullets:update_bullet( bullet, dt )
  end
end


return bullets
