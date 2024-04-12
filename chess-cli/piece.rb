class Piece
  VALS = {knight: 3, king: 77, queen: 9, pawn: 1, rook: 5, bishop: 3}

  def self.knight_moves; [[1,2],[1,-2],[-1,2],[-1,-2],[2,1],[-2,1],[2,-1],[-2,-1]]; end
  def self.rook_moves;   [[0,1],[1,0],[0,-1],[-1,0]]; end
  def self.bishop_moves; [[1,1],[1,-1],[-1,1],[-1,-1]]; end
  def self.crown_moves;  [[1,1],[1,-1],[-1,1],[-1,-1],[0,1],[1,0],[0,-1],[-1,0]]; end

  @@all = []

  attr_accessor :color, :position, :val
  attr_reader :char, :ranged, :played_moves, :taken
  def initialize(color, position, played_moves=[])
    @color = color
    @position = position
    @played_moves = played_moves
    @current_legal_moves = []
    @ranged = (self.is_a?(Rook) || self.is_a?(Bishop) || self.is_a?(Queen))
    @taken = false
    @char = "?"
    @val = 0
    @@all << self
  end

  def clear_moves
    @current_legal_moves = []
  end

  def get_moves
    @current_legal_moves
  end

  def add_moves(moves)
    @current_legal_moves.concat moves
  end

  def self.generate(piece_type, color, pos)
    case piece_type
    when :pawn
      pc = Pawn.new(color, pos)
    when :knight
      pc = Knight.new(color, pos)
    when :bishop
      pc = Bishop.new(color, pos)
    when :rook
      pc = Rook.new(color, pos)
    when :queen
      pc = Queen.new(color, pos)
    when :king
      pc = King.new(color, pos)
    end
    pc
  end

  def deep_dup
    return self.class.new(@color, @position, @played_moves.map{|mv| mv.deep_dup(mv.piece, mv.other_piece)})
  end

  def take
    @taken = true
    @position = nil
  end

  def set_played(move)
    @played_moves << move
    @current_legal_moves = []
  end

  def piece_directions
    # subclasses define     
    []
  end
  

  # Utilities
  def file
    @position[0]
  end

  def rank
    @position[1]
  end

  def notation
    @char
  end

  def to_s
    notation
  end
end


class Pawn < Piece
  attr_reader :letter, :char, :val
  def initialize(color, position, played_moves=[])
    super
    @letter = "p "
    @char = "\u265f "
    @val = 1
    @moved = false
  end

  def pawn_dir
    @pawn_dir ||= (@color == :white ? 1 : -1)
  end

  def pawn_attack_dirs
    [[-1, pawn_dir], [1, pawn_dir]]
  end
  
  def pawn_moves
    mvs = [[0, 1*pawn_dir]]
    mvs << [0, 2*pawn_dir] if rank_idx(@position) == (3.5 - 2.5*pawn_dir)
    mvs
  end

  def piece_directions
    pawn_moves
  end

end

class Bishop < Piece
  attr_reader :letter, :char, :val
  def initialize(color, position, played_moves=[])
    super
    @letter = "B "
    @char = "\u265d "
    @val = 3
  end
  def piece_directions
    Piece.bishop_moves
  end
end

class Knight < Piece
  attr_reader :letter, :char, :val
  def initialize(color, position, played_moves=[])
    super
    @letter = "N "
    @char = "\u265e "
    @val = 3
  end
  def piece_directions
    Piece.knight_moves
  end
end

class Rook < Piece
  attr_accessor :castleable
  attr_reader :letter, :char, :val
  def initialize(color, position, castleable=true, played_moves=[])
    super(color, position)
    @letter = "R "
    @char = "\u265c "
    @castleable = castleable
    @val = 5
  end

  def deep_dup
    return self.class.new(@color, @position, @castleable)
  end

  def set_castleable
    @castleable = false
  end

  def set_played(move)
    super
    @castleable = false
  end

  def piece_directions
    Piece.rook_moves
  end
end  

class Queen < Piece
  attr_reader :letter, :char, :val
  def initialize(color, position, played_moves=[])
    super
    @letter = "Q "
    @char = "\u265b "
    @val = 9
  end

  def piece_directions
    Piece.crown_moves
  end

end

class King < Piece
  attr_accessor :castleable
  attr_reader :letter, :char, :val
  def initialize(color, position, castleable=true, played_moves=[])
    super(color, position)
    @letter = "K "
    @char = "\u265a "
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

