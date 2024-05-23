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

end
