class Queen < PieceObject
  attr_reader :letter, :char, :val
  def initialize(color, position)
    super
    @letter = self.class.letter
    @char = "\u265b"
    @val = 9
  end

  def piece_directions
    PieceObject.crown_moves
  end

  def self.letter
    "Q"
  end

end