class Api::BoardsController < ApplicationController
  before_action :set_game_board, only: [:show, :update, :destroy]

  def show
    begin
      result = { board: @board, game: @game.as_json, pieces: @board.positions_array}
      result.merge! get_moves_pieces_history
      render json: result, status: :ok
    rescue Exception => e
      render json: {errors: e.message }, status: :unprocessable_entity
    end
  end

  def create
    # Potentially use this endpoint to load an existing game by PGN
    pgn_text = create_board_params[:pgn_text]
    move_list = get_move_list_from_pgn(pgn_text)

    initial_board = new_board

    move_list.each do |move_str|
      moves = initial_board.legal_moves[initial_board.turn].filter{|mv| mv.get_notation == move_str}
      unless moves.empty?
        result = initial_board.play_move(moves[0])
        if !result
          return render json: { errors: "Couldn't play move", status: :unprocessable_entity }
        end
      end
    end
    render json: { board: initial_board }
  end


  private

  def new_board
    board = Board.new(game_id: 0, turn: "white")
    board.init_variables
    board
  end

  def get_moves_pieces_history
    initial_board = new_board
    pieces_history = [initial_board.positions_array]
    moves = [nil]
    @board.played_moves_in_order.each do |move|
      initial_board.play_move(move)
      pieces_history << initial_board.positions_array
      moves << move
    end
    { pieces_history: pieces_history, moves:  moves }
  end

  def set_game_board
    @game = Game.find(params[:game_id])
    @board = @game.board
  end

  def create_board_params
    params.permit(:pgn_text)
  end

end
