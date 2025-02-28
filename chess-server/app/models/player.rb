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

  def draw_games
    Game.where(status: "completed", outcome: "draw", winner_id: self.id).or(
      Game.where(status: "completed", outcome: "draw", loser_id: self.id))
  end

  def loss_games
    Game.where(status: "completed", outcome: "checkmate", loser_id: self.id)
  end

  def win_games
    Game.where(status: "completed", outcome: "checkmate", winner_id: self.id)
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
