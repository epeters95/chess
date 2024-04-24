class Game < ApplicationRecord

  has_one :board, dependent: :destroy

  after_create :init_board

  include Util

  def is_computers_turn?
    is_computer?(self.board.turn)
  end

  def display_name_for(color)
    is_computer?(color) ? "Computer" : name_for(color)
  end

  def play_move_and_evaluate!(move)
    # TODO: write move comparison method for the following:
    # unless self.board.legal_moves.include?(move)
    #   raise IllegalMoveError
    # end
    self.board.play_move!(move)

    status_str = "#{display_name_for(switch(self.board.turn))} made move #{move.get_notation}"
    status_str += ", check" if self.board.is_king_checked?(self.board.turn)
    status_str += ". #{uppercase(self.board.turn)} to move."
    
    evaluate_outcomes(status_str)
  end

  def evaluate_outcomes(status_str)
    previous_turn = switch(self.board.turn)

    if self.board.is_insuff_material_stalemate?
      self.board.update(status_str: "The game is a draw due to insufficient mating material.")

    elsif self.board.is_checkmate?(self.board.turn)
      self.board.update(status_str: "#{display_name_for(previous_turn)} has won by checkmate!")

    elsif self.board.is_nomoves_stalemate?(self.board.turn)
      self.board.update(status_str: "The game is a draw. #{display_name_for(self.board.turn)} has survived by stalemate!")

    else

      self.board.update(status_str: status_str)

      # set_waiting_status
      return
    end
    # Game Over
    self.update(status: "completed")
  end

  def to_json(options = {})
    JSON.pretty_generate(
      {
        id:             self.id,
        turn:           self.board.turn,
        turn_name:      name_for(self.board.turn),
        status_str:     self.board.status_str,
        pieces:         self.board.positions_array,
        legal_moves:    self.board.legal_moves[self.board.turn],
        move_count:     self.board.move_count
      }, options)
  end

  private

  def init_board
    self.create_board(turn: "white")
    self.board.status_str = "White to move - #{display_name_for("white")}"
    self.board.save!  # Manually saving board persists pieces in db
    set_waiting_status
  end

  def is_computer?(color)
    name_for(color).to_s == "" 
  end

  def name_for(color)
    color == "white" ? self.white_name : self.black_name
  end

  def set_waiting_status
    if is_computer?(self.board.turn)
      self.update(status: "waiting_computer")
    else
      self.update(status: "waiting_player")
    end
  end

  class IllegalMoveError < StandardError
    def message
      "Illegal move attempted on the board"
    end
  end
end