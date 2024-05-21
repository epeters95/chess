class Api::GamesController < ApplicationController

  include Util
  
  before_action :set_game, only: [:show, :update, :destroy]

  def index
    games = Game.where(status: "completed").map do |game|
      { id: game.id,
        white_name: game.white_name,
        black_name: game.black_name,
        move_count: game.board.move_count }
    end
    render json: {games: games}, status: :ok
  end

  def show
    render json: @game, status: :ok
  end

  def create
    begin
      @game = Game.new(game_params)
      if @game.save
        # Game is ready for first move from white
        render json: {game: @game}, status: :created
      else
        render json: {errors: @game.errors}, status: :unprocessable_entity
      end
    rescue Exception => e  
      #NameError, NoMethodError, ArgumentError, SyntaxError
      render json: {errors: e.message }, status: :unprocessable_entity
    end
  end

  def update
    begin
      if @game.errors.empty?
        if @game.status != "completed"
          if params[:end_game]
            @game.update(status: "completed")
            return render json: @game, status: :ok
          end
          if @game.is_live?
            validate_move_access(@game, params)
          else

            if @game.is_computers_turn?
              # PATCH/PUT to a game on the computer's turn will initiate a computer move
              chosen_move = Computer.new(@game.board).get_move
            else
              # Else, initiate a player move specified in params
              chosen_move = Move.new(move_params)

            end
          end
          success = @game.play_move_and_evaluate(chosen_move)
          if success
            render json: @game, status: :ok
          else
            render json: {error: @game.errors}, status: :unprocessable_entity
          end
        else
          render json: {error: "Game is over"}, status: :unprocessable_entity
        end
      else
        render json: {error: "Game not found"}, status: :unprocessable_entity
      end
    rescue Exception => e
      #NameError, NoMethodError, ArgumentError, SyntaxError
      debugger
      render json: {errors: e.message }, status: :unprocessable_entity
    end
  end

  def quote
    render json: {quote: get_quote_html}, status: :ok
  end

  private
    def validate_move_access(game, params)
      if game.board.turn == "white"
        return (session[:token] || params[:token]) == game.live_game.white_token
      else
        return (session[:token] || params[:token]) == game.live_game.black_token
      end
    end

    def set_game
      @game = Game.find(params[:id])
    end

    def game_params
      params.require(:game).permit(:white_name, :black_name, :status)
    end

    def move_params
      # TODO: identify specific move params needed
      params.require(:move).permit(Move.column_names - ["created_at", "updated_at"])
    end
end
