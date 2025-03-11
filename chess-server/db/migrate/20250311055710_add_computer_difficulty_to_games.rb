class AddComputerDifficultyToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :computer_difficulty, :integer
  end
end
