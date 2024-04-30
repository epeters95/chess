class Api::LiveGamesController < ApplicationController

  def create
    # TODO: allow for multi-stage creation

    @livegame = LiveGame.create
    if @livegame.errors.empty?
      render json: { id: @livegame.id, access_code: @livegame.access_code }, status: :ok
    else
      render json: { errors: @livegame.errors }, status: :unprocessable_entity
    end
  end

  def show
    if params[:access_code]
      @livegame = LiveGame.find_by(access_code: params[:access_code])
    end
    if @livegame.nil? && params[:id]
      @livegame = LiveGame.find(params[:id])
    end
    unless @livegame.nil?
      render json: { id: @livegame.id, access_code: @livegame.access_code, live_game: @livegame } 
    else
      render json: { errors: "Not found" }, status: :not_found
    end
  end

  def update
    p_name = params[:player_name]
    p_team = params[:player_team]

    debugger

    whitename = ( p_team == "white" ? p_name : "" )
    blackname = ( p_team == "black" ? p_name : "" )

    @livegame = LiveGame.find_by(access_code: params.require(:live_game).permit(:access_code)[:access_code])
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
      render json: { id: @livegame.id, token: token }, status: :ok
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
