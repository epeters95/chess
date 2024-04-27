class AddNotationToMoves < ActiveRecord::Migration[7.0]
  def change
    add_column :moves, :notation, :string
  end
end
