class Bishop < Piece
  attr_reader :letter, :char, :val
  def initialize(color, position)
    super
    @letter = "B "
    @char = "\u265d"
    @val = 3
  end
  def piece_directions
    Piece.bishop_moves
  end
end