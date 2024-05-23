namespace :api do
  desc "Converts old way of storing move position to new for all move objects"

  task set_move_position_from_piece_str: [:environment] do |t|

    Move.all.each do |move|

      if move.position.blank? #.nil? ||  == ""
        move.update(position: move.piece.position)
      end

    end
  end
end