class ChangeNullFalseOnMovesBoardId < ActiveRecord::Migration[7.0]
  def change
    change_column_null :moves, :board_id, true
  end
end
