class CreateLiveGames < ActiveRecord::Migration[7.0]
  def change
    create_table :live_games do |t|

      t.string      :white_token, default: ""
      t.string      :black_token, default: ""
      t.string      :access_code, default: ""

      t.references  :game, foreign_key: true

      t.timestamps
    end
  end
end
