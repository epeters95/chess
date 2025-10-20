class Pawn < PieceObject
  attr_reader :letter, :char, :val
  attr_accessor :move_count

  def initialize(color, position)
    super
    @letter = self.class.letter
    @char = "\u265f"
    @val = PieceObject.value_map[@letter]
    @move_count = 0
  end

  def passantable?
    @move_count == 1
  end

  def set_played
    super
    @move_count += 1
  end

  def pawn_dir
    @pawn_dir ||= (@color == "white" ? 1 : -1)
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

  def pawn_attacks
    attacks = []
    pawn_attack_dirs.each do |dir|
      new_place = [file_idx(@position) + dir[0], rank_idx(@position) + dir[1]]
      next if outside?(new_place)
      attacks << new_place
    end
    attacks
  end

  def deep_dup
    dupe = self.class.new(@color, @position)
    dupe.move_count = @move_count
    dupe
  end

  def self.letter
    "p"
  end

end