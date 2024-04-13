class CreateBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :boards do |t|
      t.string     :turn
      t.string     :status_str, default: ""
      t.integer    :move_count, default: 0
      t.text       :positions_array
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
