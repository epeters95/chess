class Game < ApplicationRecord

  has_one :board, dependent: :destroy
  has_one :live_game
  has_one :white_player, class_name: "Player", foreign_key: "white_id"
  has_one :black_player, class_name: "Player", foreign_key: "black_id"

  after_create :init_board

  include Util

  OUTCOMES = ["checkmate", "resignation", "draw"]

  def is_computers_turn?
    is_computer?(self.board.turn)
  end

  def display_name_for(color)
    is_computer?(color) ? "Computer" : name_for(color)
  end

  def play_move_and_evaluate(move_object)
    result = self.board.play_move_and_save(move_object)

    status_str = "#{display_name_for(switch(self.board.turn))} made move #{move_object.notation}"
    status_str += ". #{uppercase(self.board.turn)} to move."
    
    if !result
      self.errors.add self.board.errors
    else
      evaluate_outcomes(status_str)
    end
    return result
  end

  def set_outcome(outcome_str, winner_id, loser_id)
    if OUTCOMES.include?(outcome_str)
      self.update(outcome:   outcome_str,
                  winner_id: winner_id,
                  loser_id:  loser_id)
    else
      false
    end
  end

  def evaluate_outcomes(status_str)
    previous_turn = switch(self.board.turn)

    if self.board.is_insuff_material_stalemate?
      self.board.update(status_str: "The game is a draw due to insufficient mating material.")
      self.set_outcome("draw", self.white_id, self.black_id)

    elsif self.board.is_checkmate?(self.board.turn)
      
      # Append notation to indicate checkmate (hotfix)
      last_move = self.board.played_moves_in_order.last
      last_move.update(notation: "#{last_move.notation}#")

      self.board.update(status_str: "#{display_name_for(previous_turn)} has won by checkmate!")

      win_id = (self.board.turn == "black" ? self.white_id : self.black_id)
      los_id =  (self.board.turn == "white" ? self.white_id : self.black_id)

      self.set_outcome("checkmate", win_id, los_id)


    elsif self.board.is_nomoves_stalemate?(self.board.turn)
      self.board.update(status_str: "The game is a draw. #{display_name_for(self.board.turn)} has survived by stalemate!")
      self.set_outcome("draw", self.black_id, self.white_id)

    else

      self.board.update(status_str: status_str)

      return
    end
    # Game Over
    self.update(status: "completed")
  end

  def as_json(options = {})

    mvs = self.board.legal_moves[self.board.turn].map{|mv| mv.to_json }
    {
      id:             self.id,
      turn:           self.board.turn,
      turn_name:      name_for(self.board.turn),
      white_name:     self.white_name,
      black_name:     self.black_name,
      status_str:     self.board.status_str,
      game_status:    self.status,
      pieces:         self.board.positions_array,
      legal_moves:    mvs,
      move_count:     self.board.move_count,
      status:         self.status
    }
  end

  def to_json(options = {})
    JSON.pretty_generate(as_json, options)
  end

  def is_live?
    !self.live_game.nil?
  end

  def self.unique_player_names
    self.distinct(:white_name).pluck(:white_name).concat(
      self.distinct(:black_name).pluck(:black_name)
      ).uniq.sort
  end

  private

  def init_board
    @board = self.create_board(turn: "white")
    @board.update!(status_str: "White to move - #{display_name_for("white")}")

    # Manually saving board persists pieces in db

    # Game has already been played, created from PGN upload
    if self.status != "completed"
      set_waiting_status
    end
  end

  def is_computer?(color)
    name_for(color).to_s == "" 
  end

  def name_for(color)
    color == "white" ? self.white_name : self.black_name
  end

  def set_waiting_status
    if is_computer?(@board.turn)
      self.update(status: "waiting_computer")
    else
      self.update(status: "waiting_player")
    end
  end
end