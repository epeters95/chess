class Api::GamesController < ApplicationController
  before_action :init_games_hash

  def index
    render json: {}, status: :ok
  end

  def create
    game = Game.new(:white)
    @games[game.object_id] = game
    render json: game, status: :ok
  end

  def init_games_hash
    @games = {}
    # for a quick demo we could just store/lookup this as a ruby object from the session...
    # however, there's no point in using session to persist objects since that is tied to a browser and this will be used as an api.
    # hence, active_record and db storage is necessary to enable game logic via REST.

    # WARNING: do not allow includes to happen twice via changes + refresh, causes strange multi-include errors
  end

end
