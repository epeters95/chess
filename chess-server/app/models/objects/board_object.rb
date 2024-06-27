require_relative './piece_object'

class BoardObject

  include Util

  attr_reader :pieces, :legal_moves, :turn, :check

  def initialize(pieces=nil, turn="white", move_count=1, dupe=false)

    @pieces = pieces || place_pieces
    @turn = turn
    @move_count = move_count
    @legal_moves = {"black" => [], "white" => []}
    @check = {"white" => false, "black" => false}

    generate_legal_moves unless dupe

  end

  def place_pieces
    gameboard = {"black" => [], "white" => []}
    # pawns
    color = "white"
    [1, 6].each do |r|
      BOARD_SIZE.times do |f|
        # Push each piece into the return hash using its file as the index
        piece = PieceObject.generate("pawn", color, file(f) + rank(r))
        gameboard[color] << piece      
      end
      color = "black"
    end
    # home
    color = "white"
    [0, 7].each do |r|
      ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"].each_with_index do |piece_type, f|
        piece = PieceObject.generate(piece_type, color, file(f) + rank(r))
        gameboard[color] << piece
      end
      color = "black"
    end
    gameboard
  end



  # All moves loop will iterate through all of the pieces of the given color
  # and run a given proc, passing the move as the argument.
  # The moves included are:
  #  - squares provided to the piece by its basic movement rules
  #  - squares the piece is attacking (containing an opposite color piece)
  #  - special moves (castling, promotion, en passant)

  def all_moves_enum(color=@turn,
                     filter= ->(mv) { true })

    return to_enum(:all_moves_enum, color, filter) unless block_given?

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
            
            move = MoveObject.new(piece,
                                  other_piece,
                                  move_type,
                                  @move_count,
                                  piece.position,
                                  new_place_n)

            (moves << move and yield move) if filter.call(move)

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
            
            move = MoveObject.new(piece,
                                  target,
                                  move_type,
                                  @move_count,
                                  piece.position,
                                  atk_n)

            (moves << move and yield move) if filter.call(move)

          elsif !target_passant.nil? && target_passant.is_a?(Pawn) && 
                target_passant.color != color &&
                target_passant.passantable? &&
                rank_idx(atk_n) == (color == "white" ? 5 : 2)

            move = MoveObject.new(piece,
                                  target_passant,
                                  move_type,
                                  @move_count,
                                  piece.position,
                                  atk_n)

            (moves << move and yield move) if filter.call(move)
          end
        end
      end

      if piece.is_a?(King) and piece.castleable
        get_castleable_rooks(color).each do |rook|
          if file_idx(rook.position) < file_idx(piece.position)
            
            # Queenside
            new_position = file(file_idx(piece.file) - 2) + piece.rank
            rook_position = file(file_idx(rook.file) + 3) + rook.rank

            move = MoveObject.new(piece,
                                  rook,
                                  "castle_queenside",
                                  @move_count,
                                  piece.position,
                                  new_position,
                                  rook_position)

            (moves << move and yield move) if filter.call(move)
          else

            # Kingside
            new_position = file(file_idx(piece.file) + 2) + piece.rank
            rook_position = file(file_idx(rook.file) - 2) + rook.rank
            
            move = MoveObject.new(piece,
                                  rook,
                                  "castle_kingside",
                                  @move_count,
                                  piece.position,
                                  new_position,
                                  rook_position)

            (moves << move and yield move) if filter.call(move)
          end
        end
      end
      piece.add_moves moves
    end
  end



  def generate_legal_moves(color=@turn)

    @legal_moves = {"black" => [], "white" => []} 

    # First, generate opponent attacks
    # (this is needed information for "legal" castling, etc.)

    opponent_moves = all_moves_enum(switch(color)) do |move|
      @legal_moves[switch(color)] << move
    end

    # Get all legal moves,
    # then filter out moves that cause check on a duplicate board
    # while storing pieces attacking same piece

    same_targets = {}
    # e.g. { "Ne5": [<Knight1>, <Knight2>, ...] }
    causes_check = ->(mv) { mv.other_piece.is_a?(King) }

    moves = all_moves_enum(color).filter do |move|


      board_dup = deep_dup
      board_dup.play_move(move.deep_dup)

      # Store the state of the opposing king in check
      @check[switch(color)] = causes_check.call(move)

      opp_checking_moves = board_dup.all_moves_enum(board_dup.turn, causes_check)
      checking_move = board_dup.all_moves_enum(switch(board_dup.turn), causes_check)

      unless checking_move.to_a.empty?
        move.causes_check = true
      end

      # Store move targets for later use disambiguating move notation
      same_targets[move.target_key] ||= []
      same_targets[move.target_key] << move.piece 

      opp_checking_moves.to_a.empty?
    end

    # set @relatives on move for correct move notation
    moves.each do |move|
      entries = same_targets[move.target_key].dup
      if !entries.nil? && entries.length > 1
        entries.delete(move.piece)
        move.relatives = entries
      end
      move.set_notation
    end

    @legal_moves[color].concat moves

  end

  def play_move_and_generate(move)
    if play_move(move)
      begin
        generate_legal_moves
        return true
      rescue Exception => e
        puts "Error generating moves on BoardObject"
      end
    else
      puts "Error playing move on BoardObject"
    end
    false
  end


  def play_move(move)

    # This method does not check legality of move, since it is used by dupes.

    if !move.is_a?(MoveObject) ||
       move.piece.color != @turn
      return false
    end

    piece = @pieces[move.piece.color].find {|pc| pc.position == move.position}

    unless move.other_piece.nil?
      other_piece = @pieces[move.other_piece.color].find {|pc| pc.position == move.new_position }
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
      new_piece = PieceObject.generate(move.promotion_choice, move.piece.color, move.new_position)
      @pieces[move.piece.color] << new_piece
    end
    
    @move_count += 1
    piece.set_played
    @check[@turn] = false

    if (move.causes_check)
      @check[switch(@turn)] = true
    end
    
    @turn = switch(@turn)
    return true
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
           !@legal_moves[switch color].select { |mv| !mv.piece.is_a?(Pawn) && mv.new_position == check_position }.empty? ||
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

  def move_piece(piece, new_pos)
    piece_to_delete = get_n(new_pos)
    @pieces[switch(piece.color)].delete(piece_to_delete)
    piece.position = new_pos
  end

  def deep_dup
    self.class.new(deep_dup_pieces, @turn, @move_count, true)
  end

  def deep_dup_pieces
    dupe = {}
    ["black", "white"].each do |color|
      dupe[color] = @pieces[color].map do |piece|
        piece.deep_dup
      end
    end
    dupe
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
    @legal_moves[color].empty? && !@check[color]
  end

  def is_checkmate?(color)
    @legal_moves[color].empty? && @check[color]
  end

  class IllegalMoveError < StandardError
    def message
      "Illegal move attempted on the board"
    end
  end

end