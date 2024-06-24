class MoveObject

  attr_accessor :piece, :other_piece, :completed, :relatives

  def initialize(piece,
                 other_piece,
                 move_type,
                 move_count,
                 new_position,
                 rook_position=nil,
                 promotion_choice=nil)
    @piece = piece
    @other_piece = other_piece
    @move_type = move_type
    @move_count = move_count
    @new_position = new_position
    @rook_position = rook_position
    @promotion_choice = promotion_choice
    @notation = ""
    @completed = false
    @relatives = []
  end

  def ==(other_move)
    @piece.position == other_move.piece.position &&
    @new_position == other_move.new_position &&
    @rook_position == other_move.rook_position &&
    @move_type == other_move.move_type
  end

  def deep_dup(duped_piece, duped_other_piece)
    self.class.new(duped_piece,
                   duped_other_piece,
                   @move_type,
                   @move_count,
                   @new_position,
                   @rook_position,
                   @promotion_choice)
  end

  def get_notation
    if @move_type == "castle_kingside"
      "O-O"
    elsif @move_type == "castle_queenside"
      "O-O-O"
    else
      # move_type is "move", "attack", "promotion", "attack_promotion"
      @notation = ""
      unless @piece.is_a? Pawn
        @notation = @piece.letter
        @notation += disambiguated_position
      end
      if @move_type == "attack" || @move_type == "attack_promotion"
        if @piece.is_a? Pawn
          @notation += @piece.file
        end
        @notation += "x"
      end
      @notation += "#{@new_position}"
      if @move_type == "promotion" || @move_type == "attack_promotion"
        @notation += "=#{@promotion_choice}"
      end
      @notation
    end
  end

  def disambiguated_position
    show_file = false
    show_rank = false
    @relatives.each do |pc|
      if @piece.file == pc.file
        show_file = true
      end
      if @piece.rank == pc.rank
        show_rank = true
      end
    end
    "#{show_file ? @piece.file : '' }#{show_rank ? @piece.rank : '' }"

  end

end