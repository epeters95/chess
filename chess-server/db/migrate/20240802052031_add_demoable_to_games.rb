class AddDemoableToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :demoable, :boolean
  end
end
