require './app/models/piece'

class Move < ApplicationRecord

  # The entirety of the board's history will be represented by rows of moves belonging to that board
  # Displaying them will be a simple matter of "replaying" them in forward/backward order
  # It may even be possible to code "views" for checking rather than using deep dup

  belongs_to :board, inverse_of: "played_moves"

  include Util

  attr_accessor :completed, :promotion_choice, :move_count

  def piece
    @piece ||= Piece.from_json_str(self.piece_str)
  end

  def other_piece
    @other_piece ||= Piece.from_json_str(self.other_piece_str)
  end

  def get_notation(disamb=false)
    if self.move_type == "castle_kingside"
      "O-O"
    elsif self.move_type == "castle_queenside"
      "O-O-O"
    elsif self.move_type == "promotion" || self.move_type == "attack_promotion"
      "#{self.piece.position}"\
      "#{"x#{self.other_piece.letter}" if self.move_type == "attack_promotion"}"\
      "=?"#{@other_piece.letter}"
    else
      # A move or attack
      "#{self.piece.letter}#{self.piece.position if disamb}"\
      "#{"x#{self.other_piece.letter}" if self.move_type == "attack"}"\
      "#{self.new_position}"
    end
  end

  def deep_dup(duped_piece, duped_other_piece)
    doop = self.class.new(
      piece_str:       duped_piece.to_json,
      other_piece_str: duped_other_piece.to_json,
      move_type:       self.move_type.to_s,
      new_position:    self.new_position,
      rook_position:   self.rook_position,
      move_count:      self.move_count
      )
    doop
  end

  def get_coords
    [file_idx(self.new_position), rank_idx(self.new_position)]
  end

  def to_s
    @notation ||= self.get_notation
  end

  def to_json(options = {})
    if self.move_type == nil || self.move_type == ""
      debugger
    end
    exclude_piece_moves = true
    other_piece_json = @other_piece.nil? ? nil : @other_piece.to_json(exclude_piece_moves)
    hsh = {
      board_id: self.board_id,
      piece_str: @piece.to_json(exclude_piece_moves),
      other_piece_str: other_piece_json,
      move_type: self.move_type.to_s,
      new_position: self.new_position,
      rook_position: self.rook_position,
      move_count: self.move_count
    }
    JSON.generate(hsh, options)
  end

  def self.from_json(json_obj)
    exclude_piece_moves = true
    move_obj = self.new(json_obj.symbolize_keys)
    move_obj
  end
end