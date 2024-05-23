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

  def index
    render json: { players: Player.all.map do |player| 
      { name: display_name(player.name),
        games: player.games.length, #player.games.map{|g| {g.opponent, g.status ...}}
        completed_games: player.games.where(status: "completed").length
      }
    end }
  end

  private
  def set_player
    @player = Player.find(params[:player_id])
  end

  def display_name(name)
    return 'Computer' if name == ''
    name
  end
end
