class Game < ApplicationRecord

  has_one :board, dependent: :destroy

  after_create :init_board

  include Util

  def init_board
    self.create_board(turn: "white")
    self.board.save!  # Manually saving board persists pieces in db
    set_waiting_status
  end

  def is_computer?(color)
    name_for(color).nil?
  end

  def is_computers_turn?
    is_computer?(self.board.turn)
  end

  def name_for(color)
    color == :white ? self.white_name : self.black_name
  end

  def display_name_for(color)
    is_computer?(color) ? "Computer" : name_for(color)
  end

  def play_move_and_evaluate(move)
    # TODO: write move comparison method for the following:
    # unless self.board.legal_moves.include?(move)
    #   raise IllegalMoveError
    # end
    king_checked = self.board.play_move(move)

    status_string = "#{display_name_for(switch(self.board.turn))} made move #{move.get_notation}"
    status_string += ", check" if king_checked
    self.board.set_status(status_string, switch(self.board.turn))

    evaluate_outcomes
  end

  def evaluate_outcomes
    previous_turn = switch(self.board.turn)

    if self.board.is_insuff_material_stalemate?
      self.board.set_status("The game is a draw due to insufficient mating material.", :global)

    elsif self.board.is_checkmate?(self.board.turn)
      self.board.set_status("#{display_name_for(previous_turn)} has won by checkmate!", :global)

    elsif self.board.is_nomoves_stalemate?(self.board.turn)
      self.board.set_status("The game is a draw. #{display_name_for(self.board.turn)} has survived by stalemate!", :global)

    else
      set_waiting_status
      return
    end
    # Game Over
    self.update(status: "completed")
  end

  def set_waiting_status
    if self.is_computer?(self.board.turn)
      self.update(status: "waiting_computer")
    else
      self.update(status: "waiting_player")
    end
  end

  def to_json(options = {})
    JSON.pretty_generate(
      { board:
        {
          turn:           @board.turn,
          status_bar:     @board.status_bar,
          pieces:         @board.pieces,
          played_moves:   @board.played_moves,
          legal_moves:    @board.legal_moves[@board.turn].map{|pc, mv_arr| mv_arr.map{|mv| mv.get_notation}},
          selected_moves: @board.selected_moves,
          selected:       @board.selected,
          move_count:     @board.move_count
        }
      }, options)
  end

  class IllegalMoveError < StandardError
    def message
      "Illegal move attempted on the board"
    end
  end
end