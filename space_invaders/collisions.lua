local collisions = {}

function collisions.check_rectangles_overlap( a, b )
    local overlap = false
    if not( a.x + a.width < b.x or b.x + b.width < a.x or
            a.y + a.height < b.y or b.y + b.height < a.y ) then
        overlap = true
    end
    return overlap
end

function collisions.invaders_walls_collision( invaders, walls )
    local overlap, wall
    if invaders.current_speed_x > 0 then
        wall, wall_type = walls.current_level_walls['right'], 'right'
    else
        wall, wall_type = walls.current_level_walls['left'], 'left'
    end
    
    local a = { x = wall.position_x,
                y = wall.position_y,
                width = wall.width,
                height = wall.height }
    for _, invader_row in pairs( invaders.current_level_invaders ) do
        for _, invader in pairs( invader_row ) do
            local b = { x = invader.position_x,
                        y = invader.position_y,
                        width = invader.width,
                        height = invader.height }
            overlap = collisions.check_rectangles_overlap( a, b )
            if overlap then
                if wall_type == invaders.allow_overlap_direction then
                    invaders.current_speed_x = -invaders.current_speed_x 
                    if invaders.allow_overlap_direction == 'right' then
                        invaders.allow_overlap_direction = 'left'
                    else
                        invaders.allow_overlap_direction = 'right'
                    end
                    invaders.descend_by_row()
                end
            end
        end
    end
end

function collisions.invaders_bullets_collision( invaders, bullets )
    local overlap
    
    for b_i, bullet in pairs( bullets.current_level_bullets) do
        local a = { x = bullet.position_x,
                    y = bullet.position_y,
                    width = bullet.width,
                    height = bullet.height }
        
        for i_i, invader_row in pairs( invaders.current_level_invaders ) do
            for i_j, invader in pairs( invader_row ) do
                local b = { x = invader.position_x,
                            y = invader.position_y,
                            width = invader.width,
                            height = invader.height }
                overlap = collisions.check_rectangles_overlap( a, b )
                if overlap then
                    invaders.destroy_invader( i_i, i_j )
                    bullets.destroy_bullet( b_i )
                end
            end
        end
    end
end

function collisions.bullets_walls_collision( bullets, walls )
    local overlap
    local wall = walls.current_level_walls['top']
    
    local a = { x = wall.position_x,
                y = wall.position_y,
                width = wall.width,
                height = wall.height }
    
    for b_i, bullet in pairs( bullets.current_level_bullets) do
        local b = { x = bullet.position_x,
                    y = bullet.position_y,
                    width = bullet.width,
                    height = bullet.height }
    
        overlap = collisions.check_rectangles_overlap( a, b )
        if overlap then
            bullets.destroy_bullet( b_i )
        end
    end
end

function collisions.resolve_collisions( invaders, walls, bullets )
    collisions.invaders_walls_collision( invaders, walls )
    collisions.invaders_bullets_collision( invaders, bullets )
    collisions.bullets_walls_collision( bullets, walls )
end

return collisions