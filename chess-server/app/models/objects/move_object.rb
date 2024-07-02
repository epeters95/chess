class MoveObject

  include Util

  attr_reader :move_type, :move_count, :position, :new_position, :rook_position, :notation
  attr_accessor :piece, :other_piece, :completed, :relatives, :promotion_choice, :causes_check

  def initialize(piece,
                 other_piece,
                 move_type,
                 move_count,
                 position,
                 new_position,
                 rook_position=nil,
                 promotion_choice=nil,
                 notation=nil,
                 causes_check=false)
    @piece = piece
    @other_piece = other_piece
    @move_type = move_type
    @move_count = move_count
    @position = position
    @new_position = new_position
    @rook_position = rook_position
    @promotion_choice = promotion_choice
    @notation = notation
    @completed = false
    @relatives = []
    @causes_check = causes_check
  end

  def ==(other_move)
    @position == other_move.position &&
    @new_position == other_move.new_position &&
    @rook_position == other_move.rook_position &&
    @move_type == other_move.move_type
  end

  def deep_dup(duped_piece=@piece.deep_dup,
               duped_other_piece=(@other_piece.nil? ? nil : @other_piece.deep_dup))
    self.class.new(duped_piece,
                   duped_other_piece,
                   @move_type,
                   @move_count,
                   @position,
                   @new_position,
                   @rook_position,
                   @promotion_choice,
                   @notation,
                   @causes_check)
  end

  def set_notation
    @notation = get_notation
  end

  def target_key
    "#{@piece.letter}#{@new_position}"
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
        @notation += "=#{PieceObject.promotion_get_letter(@promotion_choice)}"
      end
      if @causes_check
        @notation += "+"
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

  def to_json(options = {})
    exclude_piece_moves = true
    other_piece_json = @other_piece.nil? ? nil : @other_piece.to_json
    hsh = {
      piece_str:        @piece.to_json,
      other_piece_str:  other_piece_json,
      move_type:        @move_type,
      move_count:       @move_count,
      position:         @position,
      new_position:     @new_position,
      rook_position:    @rook_position,
      promotion_choice: @promotion_choice,
      notation:         @notation,
      causes_check:     @causes_check
    }
    JSON.generate(hsh, options)
  end

  def self.from_json(json_obj)
    args = json_obj.symbolize_keys

    piece = PieceObject.from_json_str(args[:piece_str], true)
    other_piece = PieceObject.from_json_str(args[:other_piece_str], true)
    move_obj = self.new(piece,
                        other_piece,
                        args[:move_type],
                        args[:move_count],
                        args[:position],
                        args[:new_position],
                        args[:rook_position],
                        args[:promotion_choice],
                        args[:notation])
    move_obj
  end

end