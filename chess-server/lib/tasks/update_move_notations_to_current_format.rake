namespace :api do
  desc "Updates all move objects for the specified game/board by re-running get_notation to overwrite the notation column"

  task :update_move_notations_to_current_format, [:game_id] => [:environment] do |t, args|

    args.with_defaults(:game_id => nil)
    game_id = args[:game_id].to_i

    if game_id == 0
      # Update all games if 0 given for id

      Game.all.each do |game|

        next unless game.board

        game.board.played_moves.each do |move|
          move.update(notation: move.get_notation)
        end

      end

    elsif !game_id.nil?

      game = Game.find(game_id)
      if game
        game.board.played_moves.each do |move|
          move.update(notation: move.get_notation)
        end
      end
    end

  end
end