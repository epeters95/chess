class Computer

  include Util

  attr_reader :color
  def initialize(board, difficulty="easy")
    @board = board
    @color = board.turn
    @difficulty = difficulty
  end

  def get_move  
    interface = EngineInterface.new("chess-engine-interface", 10000)
    level = 1
    case @difficulty
    when "easy"
      level = 1
    when "medium"
      level = 4
    when "hard"
      level = 10
    when "insane"
      level = 20
    end

    # Map moves to UCI longform notation
    move_history = @board.played_moves.map {|mv| mv.uci_notation }.join(',')

    move_uci = interface.get_move(move_history, level)

    # Identify legal move from UCI notation
    move = get_legal_move_from_uci(move_uci)

    move
    # calculate_move
  end

  def get_legal_move_from_uci(move_uci)
    first_pos  = move_uci[0..1]
    second_pos = move_uci[2..3]
    promotion  = move_uci[4]

    piece_moves = @board.legal_moves[@color].select{ |mv| mv.piece.position == first_pos }
    pieces = @board.get_pieces_from_positions_array[@color]
    move = piece_moves.find { |mv| mv.new_position == second_pos }

    # Promotions
    if !promotion.nil? && !move.nil? && move.move_type.include?("promotion")
      move.promotion_choice = promotion_map[promotion.upcase]
    end

    move
  end

  def calculate_move
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
    
    # 2. Identify counter to threat
    pieces[@color].shuffle.each do |my_piece|
      
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

    # 3. If 'good' move found, return it otherwise choose random move

    move = best_moves.shuffle[0]
    if move.nil?
      move = @board.legal_moves[@color].first
    end
    if move.move_type == "promotion" || move.move_type == "attack_promotion"
      move["promotion_choice"] = "queen"
    end

    move
  end

end