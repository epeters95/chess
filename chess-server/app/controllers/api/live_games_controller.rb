class Api::LiveGamesController < ApplicationController

  def create
    @livegame = LiveGame.create
    if @livegame.errors.empty?
      render json: { id: @livegame.id, access_code: @livegame.access_code }, status: :created
    else
      render json: { errors: @livegame.errors }, status: :unprocessable_entity
    end
  end

  def show
    if params[:access_code] != "undefined"
      @livegame = LiveGame.find_by(access_code: params[:access_code])
    end
    if @livegame.nil? && params[:id]
      @livegame = LiveGame.find(params[:id])
    end
    unless @livegame.nil?
      return_obj = {
        id:          @livegame.id,
        access_code: @livegame.access_code,
        is_ready:    @livegame.is_ready?,
        game:        @livegame.game,
        live_game:   @livegame
      }
      if params[:token]

        # Acknowledge if the token provided is legitimate

        if @livegame.white_token == params[:token]
          return_obj[:token] = "white"
        elsif @livegame.black_token == params[:token]
          return_obj[:token] = "black"
        end
        # Note: still allows #show method to be used publicly without token
      end

      render json: return_obj 
    else
      render json: { errors: "Not found" }, status: :not_found
    end
  end

  def update
    p_name = params[:player_name]
    p_team = params[:player_team]
    access_code = params[:access_code]

    whitename = ( p_team == "white" ? p_name : "No name" )
    blackname = ( p_team == "black" ? p_name : "No name" )

    @livegame = LiveGame.find_by(access_code: access_code)
    if @livegame.nil?
      return render json: { errors: "Not found" }, status: :not_found
    end

    # First player to select team
    if @livegame.game.nil?
      @livegame.game = Game.new({
        white_name: whitename,
        black_name: blackname
      })
      token = (p_team == "white" ? @livegame.request_white : @livegame.request_black)

    # Second player must choose empty team
    else
      if p_team == "white"
        @livegame.game.update(white_name: p_name, status: "ready")
      elsif p_team == "black"
        @livegame.game.update(black_name: p_name, status: "ready")
      end
      if (p_team == "white" && @livegame.white_token != "") || (p_team == "black" && @livegame.black_token != "")

        return render json: { errors: "Team already taken"}, status: :unprocessable_entity
      else
        token = (p_team == "white" ? @livegame.request_white : @livegame.request_black)
      end
    end

    if @livegame.errors.empty?
      Player.find_or_create_by_name(@livegame.game.black_name)
      Player.find_or_create_by_name(@livegame.game.white_name)
      render json: {
        id:          @livegame.id,
        token:       token,
        access_code: access_code,
        color:       p_team,
        game:        @livegame.game,
        is_ready:    @livegame.is_ready?
      }, status: :ok
    else
      render json: { errors: @livegame.errors }, status: :unprocessable_entity
    end
  end


  private
  def livegame_params
    params.require(:live_game).permit(:access_code)
  end

  def game_params
    params.require(:game).permit(:white_name, :black_name, :status)
  end
end
