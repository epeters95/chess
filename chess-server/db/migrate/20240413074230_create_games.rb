class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :white_name
      t.string :black_name

      t.timestamps
    end
  end
end
