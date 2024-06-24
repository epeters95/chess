class Bishop < PieceObject
  attr_reader :letter, :char, :val
  def initialize(color, position)
    super
    @letter = "B"
    @char = "\u265d"
    @val = 3
  end
  def piece_directions
    PieceObject.bishop_moves
  end
end