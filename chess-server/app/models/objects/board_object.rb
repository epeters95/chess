require_relative './piece_object'

class BoardObject

  # Refactor board logic operations into here

  attr_reader :pieces

  def initialize(pieces=nil, turn="white", move_count=1)

    @pieces = pieces || place_pieces
    @turn = turn
    @move_count = move_count
    @legal_moves = {"black" => [], "white" => []}
    @check = {"white": false, "black": false}

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

  def all_moves_enum(color=@turn, filter_moves_lambda=nil)

    filter = filter_moves_lambda || ->(mv) { true }
    return to_enum(:all_moves_enum, color, filter) unless block_given?

    @pieces[color].each do |piece|
      piece.clear_moves
      piece_json = piece.to_json
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
            move = Move.new(
              move_count:       @move_count,
              piece_str:        piece_json,
              other_piece_str:  other_piece_json,
              move_type:        move_type,
              position:         piece.position,
              new_position:     new_place_n
              )
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
            
            move = Move.new(
              move_count:       @move_count,
              piece_str:        piece_json,
              other_piece_str:  target.to_json,
              move_type:        move_type,
              position:         piece.position,
              new_position:     atk_n
              )
            (moves << move and yield move) if filter.call(move)

          elsif !target_passant.nil? && target_passant.is_a?(Pawn) && 
                target_passant.color != color &&
                target_passant.passantable? &&
                rank_idx(atk_n) == (color == "white" ? 5 : 2)

            move = Move.new(
              move_count:       @move_count,
              piece_str:        piece_json,
              other_piece_str:  target_passant.to_json,
              move_type:        move_type,
              position:         piece.position,
              new_position:     atk_n
              )
            (moves << move and yield move) if filter.call(move)
          end
        end
      end

      if piece.is_a?(King) and piece.castleable
        get_castleable_rooks(color).each do |rook|
          if file_idx(rook.position) < file_idx(piece.position)
            # Queenside
            move = Move.new(
              move_count:       @move_count,
              piece_str:        piece_json,
              other_piece_str:  rook.to_json(false),
              move_type:        "castle_queenside",
              position:         piece.position,
              new_position:     file(file_idx(piece.file) - 2) + piece.rank,
              rook_position:    file(file_idx(rook.file) + 3) + rook.rank
              )
            (moves << move and yield move) if filter.call(move)
          else
            # Kingside
            move = Move.new(
              move_count:       @move_count,
              piece_str:        piece_json,
              other_piece_str:  rook.to_json(false),
              move_type:        "castle_kingside",
              position:         piece.position,
              new_position:     file(file_idx(piece.file) + 2) + piece.rank,
              rook_position:    file(file_idx(rook.file) - 2) + rook.rank
              )
            (moves << move and yield move) if filter.call(move)
          end
        end
      end
      piece.add_moves moves
    end
  end



  def generate_legal_moves(color=@turn)

    @legal_moves[color] = []
    
    # Filter out moves that cause check on a duplicate board

    moves = all_moves_enum(color).filter do |move|

      board_dup = deep_dup
      board_dup.play_move(move)

      causes_check = ->(mv) { mv.other_piece.is_a?(King) }

      # Store the state of the opposing king in check
      @check[switch(color)] = causes_check.call(move)
      
      checking_moves = board_dup.all_moves_enum(board_dup.turn, causes_check)

      # move.set_notation

      checking_moves.empty?
    end

    @legal_moves[color].concat moves

  end


  def play_move(move, ignore_check=false)
    if !move.is_a?(Move) ||
       move.piece.color != @turn
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
      new_piece = PieceObject.generate(move.promotion_choice, move.piece.color, move.new_position)
      @pieces[move.piece.color] << new_piece
    end
    
    @move_count += 1
    move.completed = true
    piece.set_played
    
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

  def deep_dup
    self.class.new(deep_dup_pieces, @turn, @move_count)
  end

  def deep_dup_pieces
    @pieces.map { |piece| piece.deep_dup }
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

end