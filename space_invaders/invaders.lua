require 'utils'

local invaders = {}

invaders.rows = 5
invaders.columns = 9

invaders.top_left_position_x = 50
invaders.top_left_position_y = 50

invaders.invader_width = 40
invaders.invader_height = 40

invaders.horizontal_distance = 20
invaders.vertical_distance = 30

invaders.current_speed_x = 50
invaders.allow_overlap_direction = 'right'
invaders.speed_x_increase_on_destroying = 10

invaders.current_level_invaders = {}

local initial_speed_x = 50
local initial_direction = 'right'

invaders.images = {love.graphics.newImage('images/bad_1.png'),
                   love.graphics.newImage('images/bad_2.png'),
                   love.graphics.newImage('images/bad_3.png')
            }
invaders.image_miniboss = love.graphics.newImage('images/Small_bad.png')
invaders.miniboss = nil

invaders.time_to_miniboss = 15

function invaders.create_miniboss()
    invaders.miniboss = {position_x = 0,
                         position_y = 0,
                         width = invaders.invader_width,
                         height = invaders.invader_height,
                         current_speed_x = 300,
                         allow_overlap_direction = 'right'}

end

function invaders.destroy_miniboss( bullets )
    invaders.miniboss = nil
    invaders.time_to_miniboss = 15
    bullets.clear_current_level()
end

function invaders.miniboss_descend_by_row( bottom_wall, gamestate )
    invaders.miniboss.position_y = invaders.miniboss.position_y + invaders.vertical_distance
    if invaders.miniboss.position_y + invaders.miniboss.height >= bottom_wall.position_y then
        gamestate.state = 'lose_life'
    end
end

local scaleX, scaleY = getImageScaleForNewDimensions( invaders.images[1], invaders.invader_width,
    invaders.invader_height )

function invaders.destroy_invader( row, invader )
    invaders.current_level_invaders[row][invader] = nil
    local invaders_row_count = 0
    for _, invader in pairs( invaders.current_level_invaders[row] ) do
        invaders_row_count = invaders_row_count + 1
    end
    if invaders_row_count == 0 then
        invaders.current_level_invaders[row] = nil
    end
    if invaders.allow_overlap_direction == 'right' then
        invaders.current_speed_x = invaders.current_speed_x + invaders.speed_x_increase_on_destroying
    else
        invaders.current_speed_x = invaders.current_speed_x - invaders.speed_x_increase_on_destroying
    end
    invaders.time_to_miniboss = invaders.time_to_miniboss - 1
 end

function invaders.descend_by_row_invader( single_invader, bottom_wall, gamestate )
    single_invader.position_y = single_invader.position_y + invaders.vertical_distance / 2
    if single_invader.position_y + invaders.invader_height >= bottom_wall.position_y then
        gamestate.state = 'lose_life'
    end
end

function invaders.descend_by_row( bottom_wall, gamestate )
    for _, invader_row in pairs( invaders.current_level_invaders ) do
        for _, invader in pairs( invader_row ) do
            invaders.descend_by_row_invader( invader, bottom_wall, gamestate )
        end
    end
end

function invaders.new_invader(position_x, position_y, invader_image_no )
    local invader_image
    if not invaders.images[invader_image_no] then
        invader_image = invaders.images[math.random(1, #invaders.images)]
    else
        invader_image = invaders.images[invader_image_no]
    end
    return ({position_x = position_x,
             position_y = position_y,
             width = invaders.invader_width,
             height = invaders.invader_height,
             image = invader_image})
end

function invaders.new_row( row_index, invader_image_no )
    local row = {}
    for col_index=1, invaders.columns - (row_index % 2) do
        local new_invader_position_x = invaders.top_left_position_x + invaders.invader_width * (row_index % 2) 
            + (col_index - 1) * (invaders.invader_width + invaders.horizontal_distance)
        local new_invader_position_y = invaders.top_left_position_y
            + (row_index - 1) * (invaders.invader_height + invaders.vertical_distance)
        local new_invader = invaders.new_invader( new_invader_position_x, 
                                                  new_invader_position_y, invader_image_no )
        table.insert( row, new_invader )
    end
    return row
end

function invaders.construct_level( invader_image_no )
    invaders.no_more_invaders = false
    invaders.allow_overlap_direction = initial_direction
    invaders.current_speed_x = initial_speed_x
    for row_index=1, invaders.rows do
        local invaders_row = invaders.new_row( row_index, invader_image_no )
        table.insert( invaders.current_level_invaders, invaders_row )
    end
    invaders.allow_decrease_player_lives = true
end

function invaders.clear_current_level()
    for i in pairs( invaders.current_level_invaders ) do
        invaders.current_level_invaders[i] = nil
    end
end

function invaders.draw_invader( single_invader, is_miniboss )
    love.graphics.draw(single_invader.image,
                       single_invader.position_x,
                       single_invader.position_y, rotation, scaleX, scaleY )
    if is_miniboss then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255, 255, 255, 35)
        love.graphics.circle('fill', 
                             single_invader.position_x + single_invader.width / 2,
                             single_invader.position_y + single_invader.height / 2,
                             single_invader.width / 1.75, 50)    
        love.graphics.setColor( r, g, b, a )
    end
end

function invaders.draw( is_miniboss )
    for _, invader_row in pairs( invaders.current_level_invaders ) do
        for _, invader in pairs( invader_row ) do
            invaders.draw_invader( invader, is_miniboss )
        end
    end
end

function invaders.update_invader( dt, single_invader )
    single_invader.position_x = single_invader.position_x + invaders.current_speed_x * dt
end

function invaders.draw_miniboss()
    if not invaders.miniboss then
        return 0
    end
    
    love.graphics.draw(invaders.image_miniboss,
                       invaders.miniboss.position_x,
                       invaders.miniboss.position_y, rotation, scaleX, scaleY )
end

function invaders.update_miniboss( dt )
    if not invaders.miniboss then
        return 0
    end
    
    invaders.miniboss.position_x = invaders.miniboss.position_x + invaders.miniboss.current_speed_x * dt
end

function invaders.update( dt )
    local invaders_rows = 0
    for _, invader_row in pairs( invaders.current_level_invaders ) do
        invaders_rows = invaders_rows + 1
    end
    if invaders_rows == 0 then
        invaders.no_more_invaders = true
    else
        for _, invader_row in pairs( invaders.current_level_invaders ) do
            for _, invader in pairs( invader_row ) do
                invaders.update_invader( dt, invader )
            end
        end
    end
end

return invaders