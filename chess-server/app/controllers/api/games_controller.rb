class Api::GamesController < ApplicationController
  include ActionController::MimeResponds
  before_action :set_game, only: [:show, :update, :destroy]

  def index
    respond_to do |format|
      format.html { render body: Rails.root.join("public/display.html").read }
    end
  end

  def show
    render json: @game, status: :ok
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      # Game is ready for first move from white
      render json: @game, status: :created
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  def update
    if @game.errors.empty?
      if @game.status != "completed"
        if @game.is_computers_turn?
          # PATCH/PUT to a game on the computer's turn will initiate a computer move
          chosen_move = Computer.new(@game.board).get_move
        else
          # Else, initiate a player move specified in params
          chosen_move = Move.new(move_params)

        end
        @game.play_move_and_evaluate!(chosen_move)
        render json: @game, status: :ok
      else
        render json: {error: "Game is over"}, status: :unprocessable_entity
      end
    else
      render json: {error: "Game not found"}, status: :unprocessable_entity
    end
  end

  private
    def set_game
      @game = Game.find(params[:id])
    end

    def game_params
      params.require(:game).permit(:white_name, :black_name, :status)
    end

    def move_params
      # TODO: identify specific move params needed
      params.require(:move).permit(Move.column_names - ["created_at", "updated_at"])
    end
end
