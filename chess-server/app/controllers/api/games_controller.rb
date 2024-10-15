class Api::GamesController < ApplicationController

  include Util

  before_action :set_game, only: [:show, :update, :destroy]

  def index
    given_params = search_params
    # Includes [:status, :white_id, :black_id, :name, :search]
    # However, handle :name separately to cover => :white_name, :black_name
    # :name param is used for an exact match (links in Players table use this param)
    given_params.delete(:name)

    query_obj = {}
    given_params.each do |key, val|
      if params[key]
        query_obj[key] = params[key]
      end
    end
    games = Game.all
    # Join searches of name across both color categories (initial db design)

    p_search = params[:search]
    p_name = params[:name]

    if p_search

      p_search = p_search.downcase

      filtered_game_ids = games.pluck(:white_name, :black_name, :id).map do |g_arr|
        white_name, black_name, id = g_arr

        names = [white_name, black_name].compact.map(&:downcase)

        any_matches = names.map{ |nm| nm.match? /^#{Regexp.quote(p_name)}/ }.any?

        if any_matches
          id.to_i
        else
          nil
        end
      end.compact

      games = Game.where(id: filtered_game_ids)

    elsif p_name
      p_name = "" if p_name == "Computer"

      games = games.where(black_name: p_name)
                   .or(games.where(white_name: p_name))
    end

    # By default, only search and show completed games
    # TODO: add checkbox on UI for incompleted
    if query_obj.empty?
      query_obj = {status: "completed"}
    end
    games = games.where(query_obj)

    games = games.map do |game|
      { id: game.id,
        white_name: game.white_name,
        black_name: game.black_name,
        move_count: game.board.move_count }
    end
    render json: {games: games}, status: :ok
  end

  def show
    if @game.nil?
      render json: { errors: "Not found" }, status: :not_found
    else
      render json: @game, status: :ok
    end
  end

  def create
    # Get existing players
    black_player = Player.find_or_create_by_name(game_params[:black_name])
    white_player = Player.find_or_create_by_name(game_params[:white_name])
    begin
      @game = Game.new(game_params)
      @game.black_id = black_player.id if black_player
      @game.white_id = white_player.id if white_player
      if @game.save
        # Game is ready for first move from white
        render json: {game: @game}, status: :created
      else
        render json: {errors: @game.errors}, status: :unprocessable_entity
      end
    rescue Exception => e
      render json: {errors: e.message }, status: :unprocessable_entity
    end
  end

  def update
    begin
      if !@game.nil? && @game.errors.empty?
        if @game.status != "completed"
          if params[:end_game]
            @game.update(status: "completed")
            return render json: @game, status: :ok
          end
          chosen_move = nil
          if @game.is_live?
            validate_move_access(@game, params)
            chosen_move = @game.board.get_move_by_notation(params[:move][:notation])
            set_promotion_choice(chosen_move)
          else

            if @game.is_computers_turn?
              # PATCH/PUT to a game on the computer's turn will initiate a computer move
              chosen_move = Computer.new(@game.board).get_move
            else
              chosen_move = @game.board.get_move_by_notation(move_params[:notation])
              set_promotion_choice(chosen_move)
            end
          end
          success = chosen_move && @game.play_move_and_evaluate(chosen_move)
          if success
            render json: @game, status: :ok
          else
            render json: {error: @game.errors}, status: :unprocessable_entity
          end
        else
          render json: {error: "Game is over"}, status: :unprocessable_entity
        end
      else
        render json: {error: "Game not found"}, status: :not_found
      end
    rescue Exception => e
      render json: {errors: e.message }, status: :unprocessable_entity
    end
  end

  def quote
    render json: {quote: get_quote_html}, status: :ok
  end

  private
    def set_promotion_choice(move)
      if move.move_type == "promotion"
        move.promotion_choice = move_params[:promotion_choice]
        move.set_notation
      end
    end


    def validate_move_access(game, params)
      if game.board.turn == "white"
        return (session[:token] || params[:token]) == game.live_game.white_token
      else
        return (session[:token] || params[:token]) == game.live_game.black_token
      end
    end

    def set_game
      @game = Game.find(params[:id])
      if @game.status != "completed"
        @game.board.build_object
      end
    end

    def game_params
      params.require(:game).permit(:white_name, :black_name, :status)
    end

    def move_params
      params.require(:move).permit(Move.column_names - ["created_at", "updated_at"])
    end

    def search_params
      params.permit(:status, :white_id, :black_id, :name, :search)
      # TODO: allow separate white and black player search
    end
end
