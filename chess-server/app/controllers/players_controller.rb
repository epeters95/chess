class Api::PlayersController < ApplicationController
  before_action :set_player, only: [:show, :update, :destroy]

  #def show
  #
  #end

  #def update
  #
  #end

  #def destroy
  #
  #end


  private
  def set_player
    @player = Player.find(params[:player_id])
  end
end
