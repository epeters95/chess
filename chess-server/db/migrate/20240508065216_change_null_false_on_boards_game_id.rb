class ChangeNullFalseOnBoardsGameId < ActiveRecord::Migration[7.0]
  def change
    change_column_null :boards, :game_id, true
  end
end
