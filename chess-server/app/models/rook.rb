class Rook < Piece
  attr_accessor :castleable
  attr_reader :letter, :char, :val
  def initialize(color, position, castleable=true)
    super(color, position)
    @letter = "R "
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
    Piece.rook_moves
  end
end  