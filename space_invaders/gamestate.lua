local gamestate = {}

gamestate.state = 'start_game'
gamestate.state_choice = {
                          'start_game', 
                          'game',
                          'miniboss',
                          'game_paussed',
                          'lose_life',
                          'win_round',
                          'win_game',
                          'lose_game',
                          'end_game'
                          }


return gamestate