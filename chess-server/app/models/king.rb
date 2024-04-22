class King < Piece
  attr_accessor :castleable
  attr_reader :letter, :char, :val
  def initialize(color, position, castleable=true, played_moves=[])
    super(color, position)
    @letter = "K "
    @char = "\u265a"
    @val = 77
    @castleable = castleable
  end
  def set_played(move)
    super
    @castleable = false
  end
  def set_castleable
    @castleable = false
  end
  def piece_directions
    Piece.crown_moves
  end
  def deep_dup
    return self.class.new(@color, @position, @castleable)
  end
end