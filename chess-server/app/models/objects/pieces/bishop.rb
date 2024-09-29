class Bishop < PieceObject
  attr_reader :letter, :char, :val
  def initialize(color, position)
    super
    @letter = self.class.letter
    @char = "\u265d"
    @val = PieceObject.value_map[@letter]
  end
  def piece_directions
    PieceObject.bishop_moves
  end

  def self.letter
    "B"
  end
end