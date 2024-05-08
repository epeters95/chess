class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|

      t.string :name
      t.string :active_token

      t.timestamps
    end
    add_index :players, :name, unique: true
  end
end
