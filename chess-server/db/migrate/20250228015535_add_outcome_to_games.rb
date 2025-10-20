class AddOutcomeToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :outcome, :string
    add_reference :games, :winner
    add_reference :games, :loser
  end
end
