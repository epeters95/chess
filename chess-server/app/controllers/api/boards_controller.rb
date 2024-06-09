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
    pgn_text = create_board_params[:pgn_text].tempfile.read
    move_list = get_move_list_from_pgn(pgn_text)
    white_name = get_name_from_pgn(pgn_text, "white")
    black_name = get_name_from_pgn(pgn_text, "black")

    game = Game.create(white_name: "PGN white", black_name: "PGN black", status: "completed")
    initial_board = game.board

    move_list.each do |move_str|
      moves = initial_board.legal_moves[initial_board.turn].filter{|mv| mv.notation == move_str}
      unless moves.empty?
        begin
          mv = moves[0]
          mv.board_id = initial_board.id
          initial_board.play_move_and_save(mv)

        rescue IllegalMoveError => e
          return render json: { errors: e.message, status: :unprocessable_entity }
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
