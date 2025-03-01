class AddEvaluationToMoves < ActiveRecord::Migration[7.0]
  def change
    add_column :moves, :evaluation, :float
  end
end
