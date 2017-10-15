local bonuses = require 'bonuses'
local vector = require 'hump/vector'

local collisions = {}

collisions.collision_time = os.time()
collisions.allow_collision_time_delay = 1


function collisions.check_overlap_vertex_circle( vertex, circle )
  local vertex_circle_vector = vertex - circle.position
  local vertex_circle_length = vertex_circle_vector:len()
  if vertex_circle_length < circle.size then
    return true
  end
  return false
end


function collisions.check_overlap_circle_circle( circle_i, circle_j )
  local circle_circle_vector = circle_i.position - circle_j.position
  local circle_circle_length = circle_circle_vector:len()
  if circle_circle_length < (circle_i.size + circle_j.size) then
    return true
  end
  return false
end


function collisions.asteroids_asteroids_collisions( asteroids )
  for i, asteroid_i in pairs(asteroids.current_level_asteroids) do
    for j, asteroid_j in pairs(asteroids.current_level_asteroids) do
      if asteroid_i ~= asteroid_j and asteroid_i.last_asteroid_overlap ~= j then
        overlap = collisions.check_overlap_circle_circle( asteroid_i, asteroid_j )
      end
      if overlap then
        asteroid_i.last_asteroid_overlap = j
        asteroid_j.last_asteroid_overlap = i
        if asteroid_i.move_vector.x * asteroid_j.move_vector.x > 0 then
          asteroid_i.move_vector.y = -asteroid_i.move_vector.y
          asteroid_j.move_vector.y = -asteroid_j.move_vector.y
        else
          asteroid_i.move_vector.x = -asteroid_i.move_vector.x
          asteroid_j.move_vector.x = -asteroid_j.move_vector.x
        end
      end
    end
  end
end


function collisions.ship_asteroids_collisions( ship, asteroids, score, ship_life )
  for _, vertex in pairs(ship.body) do
    for i, asteroid in pairs(asteroids.current_level_asteroids) do
      overlap = collisions.check_overlap_vertex_circle( vertex + ship.position, asteroid )
      if overlap then
        asteroids:destroy_asteroid( i, score )
        ship:destroy_ship( ship_life )
      end
    end
  end
end


function collisions.bullets_asteroids_collisions( bullets, asteroids, score )
  for i, bullet in pairs( bullets.current_level_bullets ) do
    for j, asteroid in pairs(asteroids.current_level_asteroids) do
      overlap = collisions.check_overlap_vertex_circle( bullet.position, asteroid )
      if overlap then
        bullets:destroy_bullet( i )
        asteroids:destroy_asteroid( j, score )
        bonuses:create_bonus{ x = asteroid.position.x, y = asteroid.position.y }
      end
    end
  end
end


function collisions.ship_bonuses_collisions( ship, bonuses, asteroids, score )
  for _, vertex in pairs(ship.body) do
    for i, bonus in pairs(bonuses.current_level_bonuses) do
      overlap = collisions.check_overlap_vertex_circle( vertex + ship.position, bonus )
      if overlap then
        ship:take_bonus( bonus, i, asteroids )
        score.score = score.score + score.bonus
      end
    end
  end
end


function collisions.resolve_collisions( ship, bullets, asteroids, bonuses, score, ship_life )
  collisions.asteroids_asteroids_collisions( asteroids )
  if not ship.god_mode then
    collisions.ship_asteroids_collisions( ship, asteroids, score, ship_life )
  end
  collisions.bullets_asteroids_collisions( bullets, asteroids, score )
  collisions.ship_bonuses_collisions( ship, bonuses, asteroids, score )
end


return collisions
