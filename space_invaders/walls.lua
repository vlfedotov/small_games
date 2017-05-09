local walls = {}

walls.wall_thickness = 1
walls.bottom_height_gap = 1/5 * love.graphics.getHeight()

walls.current_level_walls = {}

function walls.new_wall( position_x, position_y, width, height )
    return { position_x = position_x,
             position_y = position_y,
             width = width,
             height = height }
end

function walls.construct_level()
    local left_wall = walls.new_wall( 0,
                                      0,
                                      walls.wall_thickness,
                                      love.graphics.getHeight() - walls.bottom_height_gap
                                )
    local right_wall = walls.new_wall( love.graphics.getWidth() - walls.wall_thickness,
                                       0,
                                       walls.wall_thickness,
                                       love.graphics.getHeight() - walls.bottom_height_gap
                                )
    local top_wall = walls.new_wall( 0,
                                     0,
                                     love.graphics.getWidth(),
                                     walls.wall_thickness
                                )
    local bottom_wall = walls.new_wall( 0, 
                                        love.graphics.getHeight() - walls.bottom_height_gap - walls.wall_thickness,
                                        love.graphics.getWidth(),
                                        walls.wall_thickness
                                )
    walls.current_level_walls["left"] = left_wall
    walls.current_level_walls["right"] = right_wall
    walls.current_level_walls["top"] = top_wall
    walls.current_level_walls["bottom"] = bottom_wall
end

function walls.draw_wall(wall)
    love.graphics.rectangle( 'line',
                             wall.position_x,
                             wall.position_y,
                             wall.width,
                             wall.height
                        )
end

function walls.draw()
    for _, wall in pairs( walls.current_level_walls ) do
        walls.draw_wall( wall )
    end
end


return walls
