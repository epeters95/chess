require_relative './piece_object'

class BoardObject

  # Refactor board logic operations into here

  attr_reader :pieces

  def initialize(pieces=nil, turn="white", move_count=1)

    @pieces = pieces || place_pieces
    @turn = turn
    @move_count = move_count
    @legal_moves = {"black" => [], "white" => []}

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
    return to_enum(:all_moves_enum, color, filter).to_a unless block_given?

    #   with_move.call(move)

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
            move = Move.new(
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
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
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
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
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
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
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
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
              board_id:         self.id,
              move_count:       self.move_count.to_i,
              piece_str:        piece.to_json,
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
      @legal_moves[color].concat moves
    end
  end



  def generate_legal_moves(ignore_check=false,color=@turn)
    @legal_moves[color] = []
    
    # move_filter = nil
    # # if !ignore_check
    # #   move_filter = ->(mv) { is_not_check_after?(mv) }
    # # end

    # generated_moves = all_moves_enum(color) do |move|

    #   board_dup = deep_dup
    #   board_dup.play_move(move)

    #   board_dup.pieces.each do |piece|

    #     # filter pieces on condition

    #   end
    #   # TODO: Rework entire "relative pieces" concept for disambiguating position using cache
    #   move.set_notation
    #   move
    # end
    # save_pieces_to_positions_array
  end


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

def deep_dup
  self.class.new(deep_dup_pieces, @turn, @move_count)
end

def deep_dup_pieces
  @pieces.map { |piece| piece.deep_dup }
end
