class AddEloRatingToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :elo_rating, :integer
  end
end
