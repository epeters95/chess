class Api::BoardsController < ApplicationController
  before_action :set_game_board, only: [:show, :update, :destroy]

  def show
    begin
      result = { board: @board, game: @game, pieces: @board.positions_array}
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

    game = Game.create(white_name: white_name, black_name: black_name, status: "completed")
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

  def get_moves_pieces_history
    d_board = Board.new
    d_board.init_board
    pieces_history = [d_board.positions_array]
    moves = [nil]
    @board.played_moves_in_order.to_a.each do |move|
      mv = move.move_object.deep_dup
      if d_board.replay_move(mv)
        pieces_history << d_board.positions_array.dup
        moves << mv
      else
        puts "Move replay failed on board #{@board.id}"
        break
      end
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
