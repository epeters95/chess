class Computer

  include Util

  attr_reader :color
  def initialize(board)
    @board = board
    @color = board.turn
  end

  def get_move # returns array of [ [piece, [row, col]], ... ]
    best_moves = []
    under_attack = nil
    attacker = nil
    # 1. Detect threats
    legal_moves = @board.legal_moves
    pieces = @board.get_pieces_from_positions_array

    pieces[switch @color].each do |piece|
      legal_moves[switch @color].find_all{|mv| mv.piece.position == piece.position && !mv.other_piece.nil? }.each do |attack|
        # Get greatest threat
        target = attack.other_piece
        under_attack ||= target
        attacker ||= piece
        if (under_attack.val < target.val)
          under_attack = target
          attacker = piece
        end
      end
    end
    # Identify counter to threat
    pieces[@color].shuffle.each do |my_piece|
      # TODO: implement blocking
      my_moves = legal_moves[@color].find_all{|mv| mv.piece.position == my_piece.position }
      atks = my_moves.select { |mv| !mv.other_piece.nil? }
      mvs = my_moves.select { |mv| mv.other_piece.nil? }
      if !atks.empty?
        if attacker
          threat_atks = atks.select { |atk| atk.new_position == attacker.position }
          if !threat_atks.empty?
          # First priority
            return threat_atks[0]
          end
        else
          # Other attacks, next priority
          best_moves.concat(atks)
          return atks[0] if my_piece == under_attack
        end
      elsif !mvs.empty?
        moves = mvs.shuffle
        best_moves.concat(moves)
        return moves[0] if my_piece == under_attack
      end
    end
    thing = best_moves.shuffle[0]
    if thing.nil?
      thing = @board.legal_moves[@color].first
    end
    if thing.move_type == "promotion" || thing.move_type == "attack_promotion"
      thing["promotion_choice"] = "queen"
    end
    return thing
  end

end