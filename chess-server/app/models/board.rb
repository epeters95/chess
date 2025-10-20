class Board < ApplicationRecord

  belongs_to :game, optional: true

  has_many   :played_moves,
             -> { where("completed = true").order(:id) },
             class_name: "Move",
             dependent: :destroy

  after_create :init_board_and_save
  after_find  :build_object

  include Util

  def init_board
    @board_object = BoardObject.new
    @pieces = @board_object.pieces
    set_pieces_to_positions_array
  end

  def init_board_and_save
    init_board
    self.save!
  end

  def build_object
    # From existing positions array, create the representative BoardObject
    begin
      if @board_object.nil?
        @pieces = get_pieces_from_positions_array
        @board_object = BoardObject.new(@pieces, self.turn, self.move_count)
      end
      true

    rescue Exception => e
      self.errors.add "Building BoardObject from positions_array failed"
      false
    end
  end


  def get_pieces_from_positions_array
    unless self.positions_array.blank?
      json_pieces = JSON.parse(self.positions_array)
      ["white", "black"].to_h do |color|
        [color, json_pieces[color].map{ |pc| PieceObject.from_json(pc) }]
      end
    else
      return nil
    end
  end

  def set_pieces_to_positions_array
    white_pcs = @pieces["white"].map {|pc| pc.to_json_obj }
    black_pcs = @pieces["black"].map {|pc| pc.to_json_obj }
    self.positions_array = JSON.generate({
      "white" => white_pcs,
      "black" => black_pcs
      })
    # Currently, non-persisting board objects are used to calculate legal moves,
    # therefore the save method must be called externally to persist pieces in db
    self.positions_array
  end

  def played_moves_in_order
    self.played_moves.order(move_count: :asc)
  end

  def legal_moves
    @board_object.legal_moves
  end

  def is_king_checked?(color)
    @board_object.check[color]
  end


  def replay_move(move_object)
    if @board_object.play_move(move_object)
      set_pieces_to_positions_array
      self.turn = switch(self.turn)
      return true
    end
    false
  end

  # Executes the given move object on the board object
  # If successful, switches turn and saves Board and Move states

  def play_move(move_object)
    if !move_object.piece.get_moves.include?(move_object)
      raise BoardObject::IllegalMoveError
    end
    if @board_object.play_move_and_generate(move_object)
      set_pieces_to_positions_array
      self.turn = switch(self.turn)
      return true
    end
    false
  end

  def play_move_and_save(move_object)

    if play_move(move_object)
      self.save

      other_piece_json = move_object.other_piece.nil? ? nil : move_object.other_piece.to_json

      result = Move.create(
        board_id:        self.id,
        completed:       true,
        piece_str:       move_object.piece.to_json,
        other_piece_str: other_piece_json,
        move_type:       move_object.move_type,
        move_count:      move_object.move_count,
        new_position:    move_object.new_position,
        rook_position:   move_object.rook_position,
        promotion_choice:move_object.promotion_choice,
        position:        move_object.position,
        notation:        move_object.notation)

      return result && self.update(move_count: self.move_count + 1)
    else
      return false
    end
  end

  def get_move_by_notation(notation, move_count=nil)
    moves = legal_moves[self.turn].filter do |move|
      move_count_cond = move_count.nil? ? true : move_count == move.move_count
      move_count_cond && (notation == move.notation)
    end
    unless moves.empty?
      return moves[0]
    end
  end

  def is_insuff_material_stalemate?
    @board_object.is_insuff_material_stalemate?
  end

  def is_checkmate?(color)
    @board_object.is_checkmate?(color)
  end

  def is_nomoves_stalemate?(color)
    @board_object.is_nomoves_stalemate?(color)
  end

  # Played move history in comma-separated UCI for Stockfish Python
  def move_history_str
    self.played_moves.map {|mv| mv.uci_notation }.join(',')
  end
end


