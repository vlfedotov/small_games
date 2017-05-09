local vector = require 'hump/vector'

local player = {}

player.position = vector( 500, 550 )
player.speed_x = 300

player.width = 50
player.height = 50

function player.update( dt )
    if love.keyboard.isDown( "right" ) and 
            player.position.x < ( love.graphics.getWidth() - player.width ) then
        player.position.x = player.position.x + ( player.speed_x * dt )
    end
    if love.keyboard.isDown( "left" )  and player.position.x > 0 then
        player.position.x = player.position.x - ( player.speed_x * dt )
    end
end

function player.draw()
    love.graphics.rectangle(
                       "fill",
                       player.position.x,
                       player.position.y,
                       player.width,
                       player.height
                 )
end

return player