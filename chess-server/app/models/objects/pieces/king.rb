class King < PieceObject
  attr_accessor :castleable
  attr_reader :letter, :char, :val
  def initialize(color, position, castleable=true)
    super(color, position)
    @letter = self.class.letter
    @char = "\u265a"
    @val = PieceObject.value_map[@letter]
    @castleable = castleable
  end
  def set_played
    super
    @castleable = false
  end
  def set_castleable
    @castleable = false
  end
  def piece_directions
    PieceObject.crown_moves
  end
  def deep_dup
    return self.class.new(@color, @position, @castleable)
  end

  def self.letter
    "K"
  end
end