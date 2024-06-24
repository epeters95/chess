class Knight < PieceObject
  attr_reader :letter, :char, :val
  def initialize(color, position)
    super
    @letter = "N"
    @char = "\u265e"
    @val = 3
  end
  def piece_directions
    PieceObject.knight_moves
  end
end