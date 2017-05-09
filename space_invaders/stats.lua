
local stats = {}

stats.start_debug_position_y = 450
stats.start_score_position_y = 30
stats.start_score_position_x = 700
stats.distance_y = 15

stats.score = 0

function stats.draw_debug( invaders, bullets, platform, debug )
    local love_stats = love.graphics.getStats()
    local str = string.format("Texture memory: %.2f MB", love_stats.texturememory / 1024 / 1024)
    love.graphics.printf(str, 50, stats.start_debug_position_y, 200, 'left')
    love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), 50, 
        stats.start_debug_position_y + stats.distance_y * 1, 200, 'left')
    love.graphics.printf('Images loaded: ' .. tostring(love_stats.images), 50, 
        stats.start_debug_position_y + stats.distance_y * 2, 200, 'left')
    local invaders_rows = 0
    for _, invader_row in pairs( invaders.current_level_invaders ) do
        invaders_rows = invaders_rows + 1
    end
    love.graphics.printf("Armada's rows: " .. tostring(invaders_rows), 50, 
        stats.start_debug_position_y + stats.distance_y * 3, 200, 'left')
    local invaders_count = ''
    for _, invader_row in pairs( invaders.current_level_invaders ) do
        local invaders_row_count = 0
        for _, invader in pairs( invader_row ) do
            invaders_row_count = invaders_row_count + 1
        end
        invaders_count = invaders_count .. ' ' .. tostring(invaders_row_count)
    end
    love.graphics.printf('Invaders in rows: ' .. tostring(invaders_count), 50,
        stats.start_debug_position_y + stats.distance_y * 4, 200, 'left')
    love.graphics.printf("Armada's speed " .. tostring(math.abs(invaders.current_speed_x)), 50, 
        stats.start_debug_position_y + stats.distance_y * 5, 200, 'left')
    local bullets_count = 0
    for _, bullet in pairs( bullets.current_level_bullets) do
        bullets_count = bullets_count + 1
    end
    love.graphics.printf("Bullets: " .. tostring(bullets_count), 50, 
        stats.start_debug_position_y + stats.distance_y * 6, 200, 'left')
    love.graphics.printf("Time to miniboss: " .. tostring(invaders.time_to_miniboss), 50, 
        stats.start_debug_position_y + stats.distance_y * 7, 200, 'left')
    --love.graphics.printf("Time to bonus: " .. tostring(invaders.time_to_bonus), 50, 
    --    stats.start_debug_position_y + stats.distance_y * 8, 200, 'left')
end
        
function stats.draw_score( platform )
    love.graphics.printf("Score: " .. tostring(stats.score), stats.start_score_position_x, 
        stats.start_score_position_y + stats.distance_y * 0, 200, 'left')
    love.graphics.printf("Tanks: " .. tostring(platform.lives), stats.start_score_position_x, 
        stats.start_score_position_y + stats.distance_y * 1, 200, 'left')
end

function stats.draw( invaders, bullets, platform, debug )
    if debug then
        stats.draw_debug( invaders, bullets, platform, debug )
    end
    stats.draw_score( platform )  
end


return stats
