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
        wins_id: player.wins,
        losses_id:player.losses,
        draws_id: player.draws,
        checkmates_id: player.checkmate_games.size,
        resignations_id: player.resigned_games.size,
        highest_elo_win: player.highest_elo_win
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
