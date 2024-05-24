class Api::GamesController < ApplicationController

  include Util
  
  before_action :set_game, only: [:show, :update, :destroy]

  def index
    given_params = search_params
    # Includes [:status, :white_id, :black_id, :name]
    # However, handle :name separately to cover => :white_name, :black_name
    given_params.delete(:name)
    
    query_obj = {}
    given_params..each do |s_param|
      if params[s_param]
        query_obj[s_param] = params[s_param]
      end
    end
    games = Game.all
    # Join searches of name across both color categories (initial db design)
    if params[:name]
      games = games.where(black_name: params[:name]).or(games.where(white_name: params[:name]))
      unless query_obj.empty?
        games = games.where(query_obj)
      end
    else
      if query_obj.empty?
        query_obj = {status: "completed"}
      end
      games = games.where(query_obj)
    end
    
    games = games.map do |game|
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
          chosen_move = Move.new(move_params)
          if @game.is_live?
            validate_move_access(@game, params)
          else

            if @game.is_computers_turn?
              # PATCH/PUT to a game on the computer's turn will initiate a computer move
              chosen_move = Computer.new(@game.board).get_move
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

    def search_params
      params.permit(:status, :white_id, :black_id, :name)
      # TODO: allow separate white and black player search
    end
end
