class Player < ApplicationRecord
  # has_many :games, through: :games_players

  validates :name, uniqueness: true

  def is_active_token?(token)
    self.active_token == token
  end
  
  def self.find_by_credentials(name, token)
    player = Player.find_by_name(name)
    return nil if player.nil?
    player.is_active_token?(token) ? player : nil
  end

  def games
    Game.where(black_id: self.id).or(Game.where(white_id: self.id))
  end

  def self.find_or_create_by_name(name)
    found = self.find_by_name(name)
    unless found
      found = self.create(name: name)
    end
    found
  end

  # TODO: convert to migrations and add game.outcome, winner_id, loser_id

  def draw_games
    compl_games = self.games.joins(:board).where(status: "completed")
    draws = compl_games.where("boards.status_str = ?", "The game is a draw due to insufficient mating material.").or(
            compl_games.where("boards.status_str LIKE 'The game is a draw. % has survived by stalemate!'"))
  end

  def loss_games
    compl_games = self.games.joins(:board).where(status: "completed").where("boards.status_str LIKE '% has won by checkmate!'")
    losses = compl_games.where("boards.turn = 'black'").where("black_id = ?", self.id).or(
             compl_games.where("boards.turn = 'white'").where("white_id = ?", self.id))
  end

  def win_games
    compl_games = self.games.joins(:board).where(status: "completed").where("boards.status_str LIKE '% has won by checkmate!'")
    wins = compl_games.where("boards.turn = 'black'").where("white_id = ?", self.id).or(
           compl_games.where("boards.turn = 'white'").where("black_id = ?", self.id))
  end

  def draws
    draw_games.size
  end

  def losses
    loss_games.size
  end

  def wins
    win_games.size
  end


end
