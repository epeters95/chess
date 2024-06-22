class Board < ApplicationRecord

  belongs_to :game, optional: true
  has_many   :played_moves, -> { where "completed = true" }, class_name: "Move", dependent: :destroy

  after_create :init_vars_and_generate_legal_moves

  include Util

  def refresh_pieces
    @pieces = get_pieces_from_positions_array
  end

  def get_pieces_from_positions_array
    unless self.positions_array.blank?
      json_pieces = JSON.parse(self.positions_array)
      ["white", "black"].to_h do |color|
        [color, json_pieces[color].map{ |pc| Piece.from_json(pc) }]
      end
    else
      return nil
    end
  end

  def save_pieces_to_positions_array
    self.positions_array = JSON.generate({
      "white" => @pieces["white"].map {|pc| pc.to_json_obj },
      "black" => @pieces["black"].map {|pc| pc.to_json_obj }
      })
    # Currently, non-persisting board objects are used to calculate legal moves,
    # therefore the save method must be called externally to persist pieces in db
    self.positions_array
  end

  def played_moves_in_order
    self.played_moves.order(move_count: :asc)
  end

  def generate_legal_moves(ignore_check=false,color=self.turn)
    legal_moves[color] = []
    @pieces[color].each do |piece|
      piece.clear_moves
      moves = []
      skip = false

      dirs = piece.piece_directions
      dirs.each do |dir|

        if !skip
          keep_going = piece.ranged
          current_x, current_y = file_idx(piece.position), rank_idx(piece.position)
          loop do
            current_x += dir[0]
            current_y += dir[1]
            new_place = [current_x, current_y]
            break if outside?(new_place)
            new_place_n = file(new_place[0]) + rank(new_place[1])

            move_type = "move"
            other_piece = get(new_place[0], new_place[1])
            if !other_piece.nil?
              keep_going = false
              if piece.is_a?(Pawn)
                skip = true
                break
              end
              if other_piece.color != piece.color
                move_type = "attack"
              else
                break # stop looking in this direction
              end
            elsif piece.is_a?(Pawn) && rank_idx(new_place_n) == (color == "white" ? BOARD_SIZE - 1 : 0)
              move_type = "promotion"
              # set to promotion instead
            end

            other_piece_json = other_piece.nil? ? nil : other_piece.to_json
            moves << Move.new(
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
              other_piece_str:  other_piece_json,
              move_type:        move_type,
              position:         piece.position,
              new_position:     new_place_n
              )
            break unless keep_going
          end
        end
      end

      
      if piece.is_a?(Pawn)
        piece.pawn_attacks.each do |atk|
          # Regular attack
          move_type = "attack"
          target = get(atk[0], atk[1])
          atk_n = file(atk[0]) + rank(atk[1])
          # En Passant attack
          new_rank_idx = atk[1] + (color == "white" ? -1 : 1)
          target_passant = get(atk[0],new_rank_idx)

          if rank_idx(atk_n) == (color == "white" ? BOARD_SIZE - 1 : 0)
            move_type = "attack_promotion"
          end
          if !target.nil? && target.color != color
            
            moves << Move.new(
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
              other_piece_str:  target.to_json,
              move_type:        move_type,
              position:         piece.position,
              new_position:     atk_n
              )

          elsif !target_passant.nil? && target_passant.is_a?(Pawn) && 
                target_passant.color != color &&
                target_passant.passantable? &&
                rank_idx(atk_n) == (color == "white" ? 5 : 2)

            moves << Move.new(
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
              other_piece_str:  target_passant.to_json,
              move_type:        move_type,
              position:         piece.position,
              new_position:     atk_n
              )
          end
        end
      end

      if piece.is_a?(King) and piece.castleable
        get_castleable_rooks(color).each do |rook|
          if file_idx(rook.position) < file_idx(piece.position)
            # Queenside
            moves << Move.new(
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
              other_piece_str:  rook.to_json(false),
              move_type:        "castle_queenside",
              position:         piece.position,
              new_position:     file(file_idx(piece.file) - 2) + piece.rank,
              rook_position:    file(file_idx(rook.file) + 3) + rook.rank
              )
          else
            # Kingside
            moves << Move.new(
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
              other_piece_str:  rook.to_json(false),
              move_type:        "castle_kingside",
              position:         piece.position,
              new_position:     file(file_idx(piece.file) + 2) + piece.rank,
              rook_position:    file(file_idx(rook.file) - 2) + rook.rank
              )
          end
        end
      end
      # if we are calling this method to determine if there is check,
      # we do not consider if the move causes check for the checking piece
      if !ignore_check
        moves = moves.select { |move| is_not_check_after?(move) }
      end

      # Warning: increases play_move complexity!
      # TODO: Rework entire "relative pieces" concept for disambiguating position using cache
      moves.each { |move| move.set_notation }

      piece.add_moves moves
      legal_moves[color].concat moves
    end
    save_pieces_to_positions_array
  end

  def legal_moves
    if @legal_moves.nil?
      @legal_moves = {"black" => [], "white" => []}
      refresh_legal_moves
    end
    @legal_moves
  end

  def is_king_checked?(color)
    if legal_moves[switch color].empty?
      # Checking for checkmate, need moves generated
      generate_legal_moves(true, switch(color))
    end
    !legal_moves[switch color].select { |mv| mv.other_piece.is_a?(King) }.empty?
  end

  def is_insuff_material_stalemate?
    all_remaining = @pieces.values.flatten.find_all{|pc| !pc.taken }
    insufficient = false
    if all_remaining.size <= 4
      ["black", "white"].each do |color|
        my_remaining = all_remaining.find_all{|pc| pc.color == color}
        their_remaining = all_remaining.find_all{|pc| pc.color == switch(color)}

        lone_king = (my_remaining.size == 1)

        king_bishop_or_knight = (my_remaining.size == 2 &&
                [Knight, Bishop].include?(my_remaining.select { |pc| !pc.is_a? King }.first.class))

        vs_king_bishop_or_knight = (their_remaining.size == 2 &&
                [Knight, Bishop].include?(their_remaining.select { |pc| !pc.is_a? King }.first.class))

        two_opposing_knights = (their_remaining.select { |pc| pc.is_a? Knight }.size == 2)

        insufficient = true if (lone_king && vs_king_bishop_or_knight) ||
                               (lone_king && two_opposing_knights) ||
                               (king_bishop_or_knight && vs_king_bishop_or_knight)
      end
    end
    insufficient
  end

  def is_nomoves_stalemate?(color)
    legal_moves[color].empty? && !is_king_checked?(color)
  end

  def is_checkmate?(color)
    legal_moves[color].empty? && is_king_checked?(color)
  end


  # The only moves that should be passed in here are generated by the board to be legal
  # duped board will use this method then ask if checked
  def play_move(move, ignore_check=false)
    refresh_pieces
    if !move.is_a?(Move) ||
       move.piece.color != self.turn
      return nil
    end

    piece = @pieces[move.piece.color].find {|pc| pc.position == move.piece.position}
    unless move.other_piece.nil?
      other_piece = @pieces[move.other_piece.color].find {|pc| pc.position == move.other_piece.position }
    end
    move_piece(piece, move.new_position)

    if move.move_type == "attack" || move.move_type == "attack_promotion"
      @pieces[other_piece.color].delete other_piece
      other_piece.take
    end
    if move.move_type == "castle_kingside" || move.move_type == "castle_queenside"
      move_piece(other_piece, move.rook_position)
      other_piece.set_played
      other_piece.set_castleable
      piece.set_castleable
    end
    if move.move_type == "promotion" || move.move_type == "attack_promotion"
      move.promotion_choice ||= "queen"
      @pieces[move.piece.color].delete piece
      new_piece = Piece.generate(move.promotion_choice, move.piece.color, move.new_position)
      @pieces[move.piece.color] << new_piece
    end
    
    self.move_count += 1
    move.completed = true
    piece.set_played
    
    self.turn = switch(self.turn)
    return true
  end

  # This method ensures the board @legal_moves variable is populated
  def refresh_legal_moves(ignore_check=false)
    @pieces ||= get_pieces_from_positions_array

    # Generate real moves for the next turn
    generate_legal_moves(ignore_check)

    # Generate potential checks on the next turn's king
    generate_legal_moves(true, switch(self.turn))
  end

  def play_move_and_save(move, ignore_check=false)
    if !legal_moves[self.turn].include?(move)
      raise IllegalMoveError
    end
    move_result = play_move(move, ignore_check) && move.save
    if !move_result
      return false
    else
      refresh_legal_moves(ignore_check)
      save_pieces_to_positions_array
      return self.save
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

  def prompt_piece_choice
    return "queen"
  end

  def init_variables(pieces=nil)
    @pieces = pieces || place_pieces
    @legal_moves = {"black" => [], "white" => []}
    self.move_count = 1
    save_pieces_to_positions_array
  end


  protected

  def get_n(pos)
    get(file_idx(pos), rank_idx(pos))
  end

  def get(col, row)
    all_pieces = @pieces["white"] + @pieces["black"]
    found = all_pieces.select{|pc| pc.position == (file(col) + rank(row)) }
    if found.empty?
      return nil
    else
      return found.first
    end
  end

  private

  def init_vars_and_generate_legal_moves
    init_variables
    generate_legal_moves
  end

  def place_pieces
    gameboard = {"black" => [], "white" => []}
    # pawns
    color = "white"
    [1, 6].each do |r|
      BOARD_SIZE.times do |f|
        # Push each piece into the return hash using its file as the index
        piece = Piece.generate("pawn", color, file(f) + rank(r))
        gameboard[color] << piece      
      end
      color = "black"
    end
    # home
    color = "white"
    [0, 7].each do |r|
      ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"].each_with_index do |piece_type, f|
        piece = Piece.generate(piece_type, color, file(f) + rank(r))
        gameboard[color] << piece
      end
      color = "black"
    end
    gameboard
  end

  def move_piece(piece, new_pos)
    piece_to_delete = get_n(new_pos)
    @pieces[switch(piece.color)].delete(piece_to_delete)
    piece.position = new_pos
    save_pieces_to_positions_array
  end

  def deep_dup
    doop = Board.new(game_id: 0, turn: self.turn)
    doop.init_variables(deep_dup_pieces)
    doop.move_count = self.move_count
    doop
  end

  def deep_dup_pieces
    # TODO: verify previous concerns that pieces in deep_dup
    # do not contain references to current board instance
    get_pieces_from_positions_array
  end

  def is_not_check_after?(move)
    dummy_board = deep_dup
    duped_piece = dummy_board.get_n(move.piece.position)
    duped_other_piece = (move.other_piece.nil? ? nil : dummy_board.get_n(move.other_piece.position))
    dummy_board.play_move(move.deep_dup(duped_piece,duped_other_piece), true)
    return !dummy_board.is_king_checked?(self.turn)
  end

  def get_castleable_rooks(color)
    rooks = @pieces[color].select { |pc| pc.is_a?(Rook) && pc.castleable }
    legal_rooks = []
    queen_squares = [1, 2, 3]
    king_squares = [-1,-2]
    check_squares = []
    rooks.each do |rook|
      if rook.file == "a"
        # Queenside rook
        check_squares = queen_squares 
      elsif rook.file == "h"
        # Kingside rook
        check_squares = king_squares
      end
      checked_squares = check_squares.select do |i|
        file_i = file_idx(rook.position) + i
        if file(file_i).nil?
          true
        else
          check_position = file(file_i) + rook.rank.to_s

          (!get_n(check_position).nil? ||
           !legal_moves[switch color].select { |mv| !mv.piece.is_a?(Pawn) && mv.new_position == check_position }.empty? ||
           !@pieces[switch color].select { |pc| pc.is_a?(Pawn) and !pc.position.nil? && !pc.pawn_attacks.select { |atk| file(atk[0]) + rank(atk[1]) == check_position }.empty? }.empty?
           # it is necessary to check pawn attacks, as these are "through check",
           # although would not have a legal move generated to identify them
          )
        end
      end

      if checked_squares.empty?
        legal_rooks << rook
      end
    end
    legal_rooks
  end

  class IllegalMoveError < StandardError
    def message
      "Illegal move attempted on the board"
    end
  end
  
end


