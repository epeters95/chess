class AddPositionToMoves < ActiveRecord::Migration[7.0]
  def change
    add_column :moves, :position, :string

    # populate the "position" field with piece's position
    Rake::Task['api:set_move_position_from_piece_str'].invoke

    # Enforce no null values
    change_column_default :moves, :position, ''
    change_column_null :moves, :position, true

  end
end
