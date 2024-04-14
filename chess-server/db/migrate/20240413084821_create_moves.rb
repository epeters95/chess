class CreateMoves < ActiveRecord::Migration[7.0]
  def change
    create_table :moves do |t|
      t.string      :piece_str,       null: false
      t.string      :other_piece_str
      t.string      :move_type,       null: false
      t.string      :new_position,    null: false
      t.string      :rook_position
      t.boolean     :completed,       default: false
      t.string      :promotion_choice
      t.integer     :move_count
      t.references  :board, null: false, foreign_key: true

      t.timestamps
    end
  end
end
