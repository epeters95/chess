class Rook < PieceObject
  attr_accessor :castleable
  attr_reader :letter, :char, :val
  def initialize(color, position, castleable=true)
    super(color, position)
    @letter = self.class.letter
    @char = "\u265c"
    @castleable = castleable
    @val = 5
  end

  def deep_dup
    return self.class.new(@color, @position, @castleable)
  end

  def set_castleable
    @castleable = false
  end

  def set_played
    super
    @castleable = false
  end

  def piece_directions
    PieceObject.rook_moves
  end

  def self.letter
    "R"
  end
end  