class Computer

  include Util
  require EngineInterface

  attr_reader :color
  def initialize(board)
    @board = board
    @color = board.turn
  end

  # TODO: replace with Stockfish or similar chess engine
  # Either API call or simple implementation of algorithm
  # (Current move logic is a placeholder)
  def get_move  
    # url = "www.example.com"  
    # interface = EngineInterface.new(url)
    # move = interface.send_request()
    calculate_move
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