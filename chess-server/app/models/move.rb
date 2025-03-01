

class Move < ApplicationRecord

  # The entirety of the board's history will be represented by rows of moves belonging to that board

  belongs_to :board, inverse_of: "played_moves"

  after_create :build_object
  after_find  :build_object # Ready to go for played moves, history 

  include Util

  def build_object
    @move_object = MoveObject.new(piece,
                                  other_piece,
                                  self.move_type,
                                  self.move_count,
                                  self.position,
                                  self.new_position,
                                  self.rook_position,
                                  self.promotion_choice,
                                  self.notation,
                                  self.evaluation)
  end

  def move_object
    @move_object
  end

  def piece
    @piece ||= PieceObject.from_json_str(self.piece_str)
  end

  def other_piece
    @other_piece ||= PieceObject.from_json_str(self.other_piece_str)
  end

  def to_json(options = {})
    @move_object.to_json(options)
  end

  def uci_notation
    @move_object.get_uci_notation
  end

  # def notation_cached
  #   Rails.cache.fetch("#{cache_key_with_version}/notation", expires_in: 12.hours) do
  #     set_notation
  #   end
  # end

end