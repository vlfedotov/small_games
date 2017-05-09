local bullets = {}

bullets.current_speed_y = -200
bullets.width = 2
bullets.height = 10

bullets.current_level_bullets = {}

function bullets.destroy_bullet( bullet_i )
    bullets.current_level_bullets[bullet_i] = nil
end

function bullets.clear_current_level()
    for i in pairs( bullets.current_level_bullets ) do
        bullets.current_level_bullets[i] = nil
    end
end

function bullets.new_bullet(position_x, position_y)
    return { position_x = position_x,
             position_y = position_y,
             width = bullets.width,
             height = bullets.height }
end

function bullets.fire( player )
    local position_x = player.position.x + player.width / 2
    local position_y = player.position.y
    local new_bullet = bullets.new_bullet( position_x, position_y )
    table.insert(bullets.current_level_bullets, new_bullet)
end

function bullets.draw_bullet( bullet )
    love.graphics.rectangle( 'fill',
                             bullet.position_x,
                             bullet.position_y,
                             bullet.width,
                             bullet.height
                        )
end

function bullets.draw()
    for _, bullet in pairs(bullets.current_level_bullets) do
        bullets.draw_bullet( bullet )
    end
end

function bullets.update_bullet( dt, bullet )
    bullet.position_y = bullet.position_y + bullets.current_speed_y * dt
end

function bullets.update( dt )
    for _, bullet in pairs(bullets.current_level_bullets) do
        bullets.update_bullet( dt, bullet )
    end
end

return bullets