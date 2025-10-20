namespace :api do
  desc "Finds completed game moves with evaluation not nil and sets evaluation to nil"

  task clear_move_evaluations_on_completed_games: [:environment] do |t|
    
    Game.joins(:board).where(status: "completed").each do |game|

      game.board.played_moves.where.not(evaluation: nil).each do |move|

        move.update(evaluation: nil)

      end

    end

  end

end