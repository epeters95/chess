class AddTakebackStatusToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :takeback_status, :string
  end
end
