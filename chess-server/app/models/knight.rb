class Knight < Piece
  attr_reader :letter, :char, :val
  def initialize(color, position)
    super
    @letter = "N"
    @char = "\u265e"
    @val = 3
  end
  def piece_directions
    Piece.knight_moves
  end
end