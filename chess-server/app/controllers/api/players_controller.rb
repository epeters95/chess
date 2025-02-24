class Api::PlayersController < ApplicationController
  before_action :set_player, only: [:show, :update, :destroy]

  def index
    players = Player.all.map do |player|
      next if player.name == ""
      {
        id: player.id,
        name: display_name(player.name),
        games: player.games.length,
        completed_games: player.games.where(status: "completed").length,
        wins: player.wins,
        losses:player.losses,
        draws: player.draws
      }
    end.compact.select{ |pl| pl[:games] != 0 }

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
