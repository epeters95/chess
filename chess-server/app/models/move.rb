require './app/models/piece'

class Move < ApplicationRecord

  # The entirety of the board's history will be represented by rows of moves belonging to that board

  belongs_to :board, inverse_of: "played_moves"

  after_save :set_notation

  include Util

  def piece
    @piece ||= Piece.from_json_str(self.piece_str)
  end

  def other_piece
    @other_piece ||= Piece.from_json_str(self.other_piece_str)
  end

  def get_notation
    if piece.nil?
      return "nil"
    end
    if self.move_type == "castle_kingside"
      "O-O"
    elsif self.move_type == "castle_queenside"
      "O-O-O"
    else
      # move_type is "move", "attack", "promotion", "attack_promotion"
      notation = ""
      unless piece.is_a? Pawn
        notation = piece.letter
        notation += disambiguated_position
      end
      if self.move_type == "attack" || self.move_type == "attack_promotion"
        if piece.is_a? Pawn
          notation += self.piece.file
        end
        notation += "x"
      end
      notation += "#{self.new_position}"
      if self.move_type == "promotion" || self.move_type == "attack_promotion"
        notation += "=#{self.promotion_choice}"
      end
      notation
    end
  end

  def disambiguated_position
    show_file = false
    show_rank = false
    get_piece_relatives.each do |pc|
      if self.piece.file == pc.file
        show_file = true
      end
      if self.piece.rank == pc.rank
        show_rank = true
      end
    end
    "#{show_file ? self.piece.file : '' }#{show_rank ? self.piece.rank : '' }"

  end

  def deep_dup(duped_piece, duped_other_piece)
    doop = self.class.new(
      position:         self.position,
      piece_str:        duped_piece.to_json,
      other_piece_str:  duped_other_piece.to_json,
      move_type:        self.move_type,
      new_position:     self.new_position,
      rook_position:    self.rook_position,
      move_count:       self.move_count,
      promotion_choice: self.promotion_choice
      )
    doop
  end

  def to_s
    @notation ||= self.get_notation
  end

  def ==(other_move)
    self.position == other_move.position &&
    self.new_position == other_move.new_position &&
    self.rook_position == other_move.rook_position &&
    self.move_type == other_move.move_type
  end

  def turn
    self.move_count % 2 == 1 ? "white" : "black"
  end

  def to_json(options = {})
    exclude_piece_moves = true
    other_piece_json = @other_piece.nil? ? nil : @other_piece.to_json(exclude_piece_moves)
    hsh = {
      board_id:         self.board_id,
      piece_str:        @piece.to_json(exclude_piece_moves),
      other_piece_str:  other_piece_json,
      move_type:        self.move_type,
      position:         self.position,
      new_position:     self.new_position,
      rook_position:    self.rook_position,
      move_count:       self.move_count,
      notation:         get_notation,
      promotion_choice: self.promotion_choice
    }
    JSON.generate(hsh, options)
  end

  def self.from_json(json_obj)
    args = json_obj.symbolize_keys
    args.delete(:notation)
    move_obj = self.new(args)
    move_obj
  end

  private

  def set_notation
    self.notation = get_notation
  end

  # (Called from get_notation) quickly grabs all same-team pieces of matching type
  # Reference to these pieces is needed when adding position to disambiguate 
  def get_piece_relatives
    if self.board_id
      self_board = Board.find(self.board_id)
      self_pieces = self_board.get_pieces_from_positions_array
      if self_board && self_pieces
        piece_relatives = self_pieces[piece.color].select {|pc| pc.class == piece.class }
        # variable number of pieces - E.g. White has Qe4, Qh4, Qh1, all x e1
        # notation = Qe4xe1

        # However, only needed with the same target. Filter by target:
        piece_relatives = piece_relatives.select do |pc|
          true unless pc.get_moves.select{|mv| mv.new_position == self.new_position }.empty?
        end

        return piece_relatives
      end
    end
    []
  end

end