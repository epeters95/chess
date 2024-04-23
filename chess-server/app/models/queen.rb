class Queen < Piece
  attr_reader :letter, :char, :val
  def initialize(color, position)
    super
    @letter = "Q "
    @char = "\u265b"
    @val = 9
  end

  def piece_directions
    Piece.crown_moves
  end

end