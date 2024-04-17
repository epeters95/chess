class Board < ApplicationRecord

  belongs_to :game, optional: true
  has_many   :played_moves, class_name: "Move"

  after_create :init_vars, :generate_legal_moves

  include Util
  attr_reader :legal_moves, :played_moves
  attr_accessor :status_bar, :selected_moves, :selected

  def init_vars(files=nil, pieces=nil)
    @files = files || build_empty_board
    @pieces = pieces || place_pieces
    @status_bar = {white: "", black: "", global: ""}
    @played_moves = []
    @legal_moves = {black: {}, white: {}}
    self.move_count = 0
    set_pieces_to_positions_array(@pieces)
  end

  def get_pieces
    @pieces || get_pieces_from_positions_array
  end

  def get_files
    @files || get_files_from_positions_array
  end

  def switch_turn!
    self.turn = switch self.turn
    self.save!
  end

  def get_pieces_from_positions_array
    # if @pieces.nil?
    #   # TODO: get pieces from positions array
    # end
  end

  def get_files_from_positions_array
    # if @files.nil?
    #   # TODO: get files from positions array
    # end
  end

  def set_pieces_to_positions_array(pieces_hash)
    self.positions_array = JSON.generate(pieces_hash)
    # self.save!
    # Currently, non-persisting board objects are used to calculate legal moves,
    # therefore the save method must be called externally to persist pieces in db
  end

  def generate_legal_moves(ignore_check=false,color=self.turn.to_sym)
    @legal_moves[color] = {}
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

            move_type = :move
            other_piece = self.get(new_place[0], new_place[1])
            if !other_piece.nil?
              keep_going = false
              if piece.is_a?(Pawn)
                skip = true
                break
              end
              if other_piece.color != piece.color
                move_type = :attack
              else
                break # stop looking in this direction
              end
            elsif piece.is_a?(Pawn) && rank_idx(new_place_n) == (color == :white ? BOARD_SIZE - 1 : 0)
              move_type = :promotion
              # set to promotion instead
            end

            moves << Move.new(
              board_id:         self.id,
              piece_str:        piece.to_json,
              other_piece_str:  other_piece.to_json,
              move_type:        move_type.to_s,
              new_position:     new_place_n
              )
            break unless keep_going
          end
        end
      end

      
      if piece.is_a?(Pawn)
        self.get_pawn_attacks(piece).each do |atk|
          # Regular attack
          move_type = :attack
          target = self.get(atk[0], atk[1])
          atk_n = file(atk[0]) + rank(atk[1])
          # En Passant attack
          new_rank_idx = atk[1] + (color == :white ? -1 : 1)
          target_passant = self.get(atk[0],new_rank_idx)

          if rank_idx(atk_n) == (color == :white ? BOARD_SIZE - 1 : 0)
            move_type = :attack_promotion
          end
          if !target.nil? && target.color != color
            
            moves << Move.new(
              board_id:         self.id,
              piece_str:        piece.to_json,
              other_piece_str:  target.to_json,
              move_type:        move_type.to_s,
              new_position:     atk_n
              )

          elsif !target_passant.nil? && target_passant.is_a?(Pawn) && 
                target_passant.color != color &&
                target_passant.played_moves.size == 1 &&
                self.move_count == target_passant.played_moves.last.move_count &&
                rank_idx(atk_n) == (color == :white ? 5 : 2)

            moves << Move.new(
              board_id:         self.id,
              piece_str:        piece.to_json,
              other_piece_str:  target_passant.to_json,
              move_type:        move_type.to_s,
              new_position:     atk_n
              )
          end
        end
      end

      if piece.is_a?(King) and piece.castleable
        self.get_castleable_rooks(color).each do |rook|
          if file_idx(rook.position) < file_idx(piece.position)
            # Queenside
            moves << Move.new(
              board_id:         self.id,
              piece_str:        piece.to_json,
              other_piece_str:  rook.to_json,
              move_type:        "castle_queenside",
              new_position:     file(file_idx(piece.file) - 2) + piece.rank,
              rook_position:    file(file_idx(rook.file) + 3) + rook.rank
              )
          else
            # Kingside
            moves << Move.new(
              board_id:         self.id,
              piece_str:        piece.to_json,
              other_piece_str:  rook.to_json,
              move_type:        "castle_kingside",
              new_position:     file(file_idx(piece.file) + 2) + piece.rank,
              rook_position:    file(file_idx(rook.file) - 2) + rook.rank
              )
          end
        end
      end
      # if we are calling this method to determine if there is check,
      # we do not consider if the move causes check for the checking piece
      if !ignore_check
        moves = moves.select { |move| self.is_legal?(move) }
      end
      piece.add_moves moves
      @legal_moves[color][piece.object_id.to_s] = moves
    end
    @legal_moves
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

          (!self.get_n(check_position).nil? ||
           !@legal_moves[switch color].values.flatten.select { |mv| !mv.piece.is_a?(Pawn) && mv.new_position == check_position }.empty? ||
           !@pieces[switch color].select { |pc| pc.is_a?(Pawn) and !pc.position.nil? && !self.get_pawn_attacks(pc).select { |atk| file(atk[0]) + rank(atk[1]) == check_position }.empty? }.empty?
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

  # TODO: rework to get the piece from the move
  def is_legal?(move)
    dummy_board = self.deep_dup
    duped_piece = dummy_board.get_n(move.piece.position)
    duped_other_piece = (move.other_piece.nil? ? nil : dummy_board.get_n(move.other_piece.position))
    dummy_board.play_move(move.deep_dup(duped_piece,duped_other_piece), true)
    return !dummy_board.is_king_checked?(self.turn)
  end

  def is_king_checked?(color)
    if @legal_moves[switch color].empty?
      # Checking for checkmate, need moves generated
      generate_legal_moves(true, switch(color))
    end
    !@legal_moves[switch color].values.flatten.select { |mv| mv.other_piece.is_a?(King) }.empty?
  end

  def is_insuff_material_stalemate?
    all_remaining = @pieces.values.flatten.find_all{|pc| !pc.taken }
    insufficient = false
    if all_remaining.size <= 4
      dbg = "REMAINING: \n" + all_remaining.map{|r| "#{r.color} #{r.notation} #{r.position}, taken=#{r.taken}\n" }.join("") + "****\n"
      self.set_status(dbg, :global)
      [:black, :white].each do |color|
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
    self.legal_moves[color].values.flatten.empty? && !self.is_king_checked?(color)
  end


  def is_checkmate?(color)
    self.legal_moves[color].values.flatten.empty? && self.is_king_checked?(color)
  end

  def get_pawn_attacks(pawn)
    attacks = []
    pawn.pawn_attack_dirs.each do |dir|
      new_place = [file_idx(pawn.position) + dir[0], rank_idx(pawn.position) + dir[1]]
      next if outside?(new_place)
      attacks << new_place
    end
    attacks
  end

  # The only moves that should be passed in here are generated by the board to be legal
  # duped board will use this method then ask if checked
  def play_move(move, ignore_check=false)
    if !move.is_a?(Move) || move.piece.color != self.turn
      puts "Error: invalid move"
      return nil
    end

    target = move.other_piece
    self.move_piece(move.piece, move.new_position)

    if !target.nil? and target.position != move.new_position
      # En Passant
      @files[file_idx(target.position)][rank_idx(target.position)] = nil
    end

    if move.move_type == :attack || move.move_type == :attack_promotion
      # TODO: verify if this fix still needed...
      @legal_moves[switch self.turn][target.object_id.to_s] = [] unless @legal_moves[switch self.turn][target.object_id.to_s].nil?
      @pieces[target.color].delete target
      target.take
    end
    if move.move_type == :castle_kingside || move.move_type == :castle_queenside
      move_piece(move.other_piece, move.rook_position)
      move.other_piece.set_played(move)
      move.other_piece.set_castleable
      move.piece.set_castleable
    end
    if move.move_type == :promotion || move.move_type == :attack_promotion
      @pieces[move.piece.color].delete move.piece
      piece = Piece.generate(move.promotion_choice, move.piece.color, move.new_position)
      @files[file_idx(move.new_position)][rank_idx(move.new_position)] = piece
      @pieces[move.piece.color] << piece
    end
    
    self.move_count += 1
    move.completed = true
    move.piece.set_played(move)
    move.move_count = self.move_count

    @played_moves << move.get_notation
    

    
    self.turn = switch self.turn
    self.set_status("> #{self.turn.upcase} TO MOVE", :global)
    # Generate new moves for the next turn
    self.generate_legal_moves(ignore_check)
    self.generate_legal_moves(true, switch(self.turn))
    result = self.is_king_checked?(self.turn)

    return result
  end

  def play_move!(move, ignore_check=false)
    play_move(move, ignore_check)
    self.save!
  end

  def deep_dup
    dup_files = deep_dup_files
    dup_pieces = deep_dup_pieces_from_files(@files)
    # TODO: replace with non-ActiveRecord skeleton object
    doop = Board.new(game_id: 0, turn: self.turn)
    doop.init_vars(dup_files, dup_pieces)
    # TODO: ensure pieces dup no longer necessary with serialization
    doop.move_count = self.move_count
    doop
  end

  def deep_dup_pieces
    dummy_pieces = {
      black: @pieces[:black].map {|piece| piece.deep_dup },
      white: @pieces[:white].map {|piece| piece.deep_dup }
    }
    dummy_pieces
  end

  def deep_dup_pieces_from_files(files)
    dummy_pieces = {
      black: files.flatten.compact.select { |piece| piece.color == :black },
      white: files.flatten.compact.select { |piece| piece.color == :white }
    }
    dummy_pieces
  end

  def deep_dup_files
    duped_files = build_empty_board

    @files.each_with_index do |file, f|
      file.each_with_index do |piece, r|
        if !piece.nil?
          duped_files[f][r] = piece.deep_dup

        end
      end
    end
    duped_files
  end

  def place_pieces
    gameboard = {black: [], white: []}
    # pawns
    color = :white
    [1, 6].each do |r|
      BOARD_SIZE.times do |f|
        # Push each piece into the return hash using its file as the index
        # Also, place it where it goes on the board
        piece = Piece.generate(:pawn, color, file(f) + rank(r))
        gameboard[color] << piece
        @files[f][r] = piece
      
      end
      color = :black
    end
    # home
    color = :white
    [0, 7].each do |r|
      [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook].each_with_index do |piece_type, f|
        piece = Piece.generate(piece_type, color, file(f) + rank(r))
        gameboard[color] << piece
        @files[f][r] = piece
      end
      color = :black
    end
    gameboard
  end

  def set_status(str, color)
    if color == :global
      @status_bar[color] = "#{str}"
    else
      @status_bar[color] = "#{color.to_s}: #{str}"
    end
  end

  def move_piece(piece, new_pos)
    old_pos = piece.position
    @files[file_idx(new_pos)][rank_idx(new_pos)] = piece
    @files[file_idx(old_pos)][rank_idx(old_pos)] = nil
    piece.position = new_pos
  end

  def prompt_piece_choice
    return :queen
  end

  protected

  def get_n(pos)
    self.get(file_idx(pos), rank_idx(pos))
  end

  def get(col, row)
    @files[col][row]
  end

  
end


