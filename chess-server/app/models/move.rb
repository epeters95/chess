require './app/models/piece'

class Move < ApplicationRecord

  # The entirety of the board's history will be represented by rows of moves belonging to that board
  # Displaying them will be a simple matter of "replaying" them in forward/backward order
  # It may even be possible to code "views" for checking rather than using deep dup

  belongs_to :board, inverse_of: "played_moves"

  include Util

  attr_accessor :completed, :promotion_choice, :move_count
  attr_reader :move_type

  def piece
    @piece ||= get_piece_from_json(self.piece_str)
  end

  def other_piece
    @other_piece ||= get_piece_from_json(self.other_piece_str)
  end

  def get_piece_from_json(piece_str)
    if piece_str.nil? || piece_str == "null"
      return nil
    end
    json_obj = JSON.parse(piece_str)
    klass = Object.const_get(json_obj["class_name"])
    init_arg_names = klass.instance_method(:initialize).parameters.map{|pm| pm[1].to_s }
    args = init_arg_names.map{|arg| json_obj[arg] }
    klass.new(*args)
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

end