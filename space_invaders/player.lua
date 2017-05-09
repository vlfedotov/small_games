require 'utils'

local player = {}

player.position_x = 500
player.position_y = 550
player.speed_x = 300

player.width = 50
player.height = 50

player.image = love.graphics.newImage('images/Hero.png')

player.lives = 5


local scaleX, scaleY = getImageScaleForNewDimensions( player.image, player.width, player.height )

function player.update( dt )
    if love.keyboard.isDown( "right" ) and 
            player.position_x < ( love.graphics.getWidth() - player.width ) then
        player.position_x = player.position_x + ( player.speed_x * dt )
    end
    if love.keyboard.isDown( "left" )  and player.position_x > 0 then
        player.position_x = player.position_x - ( player.speed_x * dt )
    end
end

function player.draw()
    love.graphics.draw(player.image,
                       player.position_x,
                       player.position_y, rotation, scaleX, scaleY )
end

return player