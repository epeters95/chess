class Api::BoardsController < ApplicationController

  include Util

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
      promotion_choice = move_str.split("=")[1]
      move_str[-1] = '?' unless promotion_choice.nil?

      moves = initial_board.legal_moves[initial_board.turn].filter{|mv| mv.notation.gsub("+", "") == move_str }
      if !moves.empty?
        begin
          mv = moves[0]
          unless promotion_choice.nil?
            mv.promotion_choice = promotion_map[promotion_choice]
          end
          initial_board.play_move_and_save(mv)

        rescue Exception => e
          return render json: { errors: e.message, status: :unprocessable_entity }
        end
      elsif ["1/2-1/2", "1-0", "0-1"].include? move_str
        case move_str
        when "1/2-1/2"
          initial_board.update(status_str: "Draw")
        when "1-0"
          initial_board.update(status_str: "White Wins")
        when "0-1"
          initial_board.update(status_str: "Black Wins")
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
    begin
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
    rescue Exception => e
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

