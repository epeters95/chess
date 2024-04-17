class Move < ApplicationRecord

  # The entirety of the board's history will be represented by rows of moves belonging to that board
  # Displaying them will be a simple matter of "replaying" them in forward/backward order
  # It may even be possible to code "views" for checking rather than using deep dup

  belongs_to :board, inverse_of: "played_moves"

  include Util

  MOVE_TYPES = [
    :move,
    :attack,
    :castle_kingside,
    :castle_queenside,
    :promotion,
    :attack_promotion
  ]

  attr_accessor :other_piece, :piece, :completed, :promotion_choice, :move_count
  attr_reader :move_type

  def init_vars(piece, move_type, new_position, other_piece=nil, rook_position=nil)
    # TODO: get piece object from JSON string
    @piece = piece

    # Refers to the piece being attacked, or the castling rook, or the promotion choice
    @other_piece = other_piece
    @move_type = move_type
    @new_position = new_position
    @rook_position = rook_position
    @notation = ""
    @completed = false
    @promotion_choice = :queen
    @move_count = nil
  end

  def get_notation(disamb=false)
    if @move_type == :castle_kingside
      "O-O"
    elsif @move_type == :castle_queenside
      "O-O-O"
    elsif @move_type == :promotion || @move_type == :attack_promotion
      "#{@piece.position}"\
      "#{"x#{@other_piece.letter}" if @move_type == :attack_promotion}"\
      "=?"#{@other_piece.letter}"
    else
      # A move or attack
      "#{@piece.letter}#{@piece.position if disamb}"\
      "#{"x#{@other_piece.letter}" if @move_type == :attack}"\
      "#{@new_position}"
    end
  end

  def deep_dup(duped_piece, duped_other_piece)
    doop = self.class.new(duped_piece, @move_type, @new_position, duped_other_piece, @rook_position)
    doop.move_count = @move_count
    doop
  end

  def get_coords
    [file_idx(@new_position), rank_idx(@new_position)]
  end

  def to_s
    @notation ||= self.get_notation
  end

end