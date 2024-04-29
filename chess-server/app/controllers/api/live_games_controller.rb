class Api::LiveGamesController < ApplicationController

  def update
    @livegame = LiveGame.find_by(access_code: params[:access_code])
  end


  private
  def livegame_params
    params.require(:live_game).permit(:access_code)
  end
end
