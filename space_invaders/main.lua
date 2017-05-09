local player     = require 'player'
local invaders   = require 'invaders'
local walls      = require 'walls'
local collisions = require 'collisions'
local bullets    = require 'bullets'

function love.load()
    math.randomseed( os.time() )
    invaders.construct_level()
    walls.construct_level()
end

function love.keyreleased( key )
    if key == 'space' then
        bullets.fire( player )
    end
end

function love.draw()
    player.draw()
    invaders.draw()
    --walls.draw()
    bullets.draw()
end

function love.update( dt )
    player.update( dt )
    invaders.update( dt )
    collisions.resolve_collisions( invaders, walls, bullets )
    bullets.update( dt )
end
