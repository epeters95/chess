class AddPlayerIdToGames < ActiveRecord::Migration[7.0]
  def change
    add_reference :games, :player, foreign_key: true
  end
end
