class AddUploadedToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :uploaded, :boolean
  end
end
