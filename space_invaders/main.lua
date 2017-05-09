local player     = require 'player'
local invaders   = require 'invaders'
local walls      = require 'walls'
local collisions = require 'collisions'
local bullets    = require 'bullets'
local stats      = require 'stats'
local gamestate  = require 'gamestate'

local current_level = 1
local debug = false

function love.load()
    math.randomseed( os.time() )
    invaders.construct_level( current_level )
    walls.construct_level()
end

function love.keyreleased( key, code )
    if gamestate.state == 'start_game' then
        if key == 'return' then
            gamestate.state = 'game'
        elseif key == 'escape' then
            love.event.quit()
        end
    elseif gamestate.state == 'game' or gamestate.state == 'miniboss' then
        if key == 'escape' then
            gamestate.state = 'game_paussed'
        elseif key == 's' then
            debug = not debug
        elseif key == 'space' then
            bullets.fire( player )
        end
    elseif gamestate.state == 'game_paussed' then
        if key == 'return' then
            if invaders.miniboss then
                gamestate.state = 'miniboss'
            else
                gamestate.state = 'game'
            end
        elseif key == 'escape' then
            love.event.quit()
        end
    elseif gamestate.state == 'win_round' then
        if key == 'return' then
            current_level = current_level + 1
            bullets.clear_current_level()
            invaders.construct_level( current_level )
            gamestate.state = 'game'
        end
    elseif gamestate.state == 'lose_life' then
        if key == 'return' then
            invaders.destroy_miniboss( bullets )
            player.lives = player.lives - 1
            invaders.clear_current_level()
            invaders.construct_level( current_level )
            gamestate.state = 'game'
        end
    elseif gamestate.state == 'end_game' then
        if key == 'return' then
            invaders.destroy_miniboss( bullets )
            player.lives = 5
            stats.score = 0
            invaders.clear_current_level()
            current_level = 1
            invaders.construct_level( current_level )
            gamestate.state = 'game'
        elseif key == 'escape' then
            love.event.quit()
        end
    end
end

function love.draw()
    if gamestate.state == 'start_game' then
        love.graphics.printf('WELCOME\n to Space Invaders 3000', 300, 300, 300, 'center')
    elseif gamestate.state == 'game' then
        player.draw()
--        walls.draw()
        invaders.draw()
        bullets.draw()
        stats.draw( invaders, bullets, player, debug )
    elseif gamestate.state == 'miniboss' then
        player.draw()
--        walls.draw()
        invaders.draw_miniboss()
        invaders.draw( true )
        bullets.draw()
        stats.draw( invaders, bullets, player, debug )
    elseif gamestate.state == 'game_paussed' then
        love.graphics.printf('PAUSE', 300, 300, 200, 'center')
    elseif gamestate.state == 'lose_life' then
        if player.lives >= 1 then
            love.graphics.printf('Sorry, minus one life', 300, 300, 200, 'center')
        else
            gamestate.state = 'end_game'
        end
    elseif gamestate.state == 'win_round' then
        love.graphics.printf('Congrats', 300, 300, 200, 'center')
    elseif gamestate.state == 'end_game' then
        love.graphics.printf('The End', 300, 300, 200, 'center')
    end
end

function love.update( dt )
    if gamestate.state == 'game' then
        player.update( dt )
        collisions.resolve_collisions( walls, invaders, bullets, stats, gamestate )
        invaders.update( dt )
        bullets.update( dt )
        if invaders.time_to_miniboss <= 0 then
            bullets.clear_current_level()
            invaders.create_miniboss()
            gamestate.state = 'miniboss'
        end
        if invaders.no_more_invaders then
            gamestate.state = 'win_round'
        end
    elseif gamestate.state == 'miniboss' then
        player.update( dt )
        collisions.resolve_collisions( walls, invaders, bullets, stats, gamestate )
        invaders.update_miniboss( dt )
        bullets.update( dt )
    end
end
