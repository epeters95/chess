class AddBlackWhitePlayerIdsToGames < ActiveRecord::Migration[7.0]
  def change
    rename_column :games, :player_id, :black_id
    add_column :games, :white_id, :integer, default: 0, null: false
    add_index :games, :white_id
  end
end
