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

end