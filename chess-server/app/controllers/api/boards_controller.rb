class Api::BoardsController < ApplicationController
  before_action :set_board, only: [:show, :update, :destroy]

  def show
    begin
      result = { board: @board}
      if params[:with_history] == true || params[:with_history] == "true"
        result.merge get_moves_pieces_history
      end
      render json: result, status: :ok
    rescue Exception => e
      render json: {errors: e.message }, status: :unprocessable_entity
    end
  end


  private

  def get_moves_pieces_history
    initial_board = Board.new(game_id: 0, turn: "white")
    initial_board.init_vars

    pieces_history = [initial_board.positions_array]
    moves = []
    @board.played_moves_in_order.each do |move|
      initial_board.play_move(move)
      pieces_history << initial_board.positions_array
      moves << move
    end
    { pieces_history: pieces_history, moves:  moves }
  end

  def set_board
    @board = Board.find(params[:id])
  end

end
