class Api::PlayersController < ApplicationController
  before_action :set_player, only: [:show, :update, :destroy]

  def index
    players = Player.all.map do |player| 
      {
        name: display_name(player.name),
        games: player.games.length,
        completed_games: player.games.where(status: "completed").length
      }
    end.select{ |pl| pl[:games] != 0 }

    render json: { players: players }
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
