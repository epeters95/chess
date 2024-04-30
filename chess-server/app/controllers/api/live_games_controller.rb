class Api::LiveGamesController < ApplicationController

  def create
    # TODO: allow for multi-stage creation

    @livegame = LiveGame.create
    if @livegame.errors.empty?
      render json: { access_code: @livegame.access_code }, status: :ok
    else
      render json: { errors: @livegame.errors }, status: :unprocessable_entity
    end
  end

  def update
    p_name = params[:playerName]
    p_team = params[:playerTeam]

    @livegame = LiveGame.find_by(access_code: params[:access_code])
    if @livegame.errors.empty?
      if p_team == "white"
        token = @livegame.request_white
      else
        token = @livegame.request_black
      end
      render json: { token: token }, status: :ok
    else
      render json: { errors: "Not found" }, status: :not_found
    end
  end


  private
  def livegame_params
    params.require(:live_game).permit(:access_code)
  end
end
