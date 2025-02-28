namespace :api do
  desc "Updates all game objects with completed boards to show outcomes, winner and loser ids"

  task update_game_outcomes_to_new_format: [:environment] do |t|

    compl_games = Game.joins(:board).where(status: "completed")
    draws_insuff = compl_games.where("boards.status_str = ?", "The game is a draw due to insufficient mating material.")
    
    draws_insuff.each do |gm|
      gm.update(winner_id: gm.white_id,
                loser_id: gm.black_id,
                outcome: "draw")
    end

    draws = compl_games.where("boards.status_str LIKE 'The game is a draw. % has survived by stalemate!'")
    
    draws.each do |gm|
      gm.update(winner_id: gm.black_id,
                loser_id: gm.white_id,
                outcome: "draw")
    end

    winlosses = compl_games.where("boards.status_str LIKE '% has won by checkmate!'")

    winlosses.each do |gm|
      bl_name = (gm.black_name == "" ? "Computer" : gm.black_name)
      wh_name = (gm.white_name == "" ? "Computer" : gm.white_name)
      
      if gm.board.status_str == "#{bl_name} has won by checkmate!"

        gm.update(winner_id: gm.black_id,
                  loser_id: gm.white_id,
                  outcome: "checkmate")
      
      elsif gm.board.status_str == "#{wh_name} has won by checkmate!"
        
        gm.update(winner_id: gm.white_id,
                  loser_id: gm.black_id,
                  outcome: "checkmate")
      end
    end

  end
end