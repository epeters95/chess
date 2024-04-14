class Game < ApplicationRecord

  has_one :board

  after_commit :init_board

  include Util
  include Quotes

  CHESSTR_1 = "\nCHESS"
  CHESSTR_2 = "\tv0.99"

  def init_board

    @team = :white
    @board = Board.new(@team)
    @board.generate_legal_moves

    @ai = Ai.new(@board, switch(@team))
    puts "Loading..."
    # system 'cls'
    # puts "#{CHESSTR_1.yellow}#{CHESSTR_2.cyan}"
    # puts
    # puts justify_quote_str(QUOTES.shuffle[0]).red
    # puts
    # puts "PRESS ANY KEY".grey
    # c = STDIN.getch
    # play
  end

  def justify_quote_str(str)
    result = ""
    truncate_len = 60
    str.split("\n").each do |line|
      if line.size > truncate_len
        words = line.split(" ")
        until words.empty?
          total = 0
          while total < truncate_len && !words.empty?
            word = words.shift + " "
            result += word
            total += word.length
          end
          result += "\n"
        end
      else
        result += line + "\n"
      end
    end
    result
  end

  def prompt_promotion_choice
    puts "Choose your promoted piece: q) Queen, r) Rook, n) Knight, b) Bishop"
    # loop do
    #   ch = STDIN.getch.chr.downcase
    #   case ch
    #   when 'q'
    #     return :queen
    #   when 'r'
    #     return :rook
    #   when 'n'
    #     return :knight
    #   when 'b'
    #     return :bishop
    #   end
    # end
    # TODO: add promotion choice endpoint or modify move#create flow
    return :queen
  end

  def play
    ch = ''
    i = (@team == :black ? -1 : 1)
    restart = false

    while true && !restart
      
      if @board.is_insuff_material_stalemate?
        @board.set_status("The outcome of this draw is a game due to insufficient mating material.", :global)
        restart = true
        draw
      elsif @board.is_checkmate?(@team)
        @board.set_status("You have been checkmated by your opponent. You LOSE this game.", :global)
        restart = true
        draw
      elsif @board.is_nomoves_stalemate?(@team)
        @board.set_status("It looks like you have survived by stalemate!", :global)
        restart = true
        draw
      elsif @board.turn == @team
        if @board.legal_moves[@team].size == 1
          @board.selected_moves = @board.legal_moves[@team].values.flatten
          @board.selected = @board.selected_moves[0].piece
        end
        ch =  STDIN.getch.chr.downcase
        case ch
        when 'q'
          break
        when 'm'
          restart = true
          break
        when 'a'
          @board.move_cursor_left
        when 'd'
          @board.move_cursor_right
        when 'w'
          @board.move_cursor_up
        when 's'
          @board.move_cursor_down
        when "\r"
          move = @board.get_selected_move
          unless move.nil?
            if move.move_type == :promotion || move.move_type == :attack_promotion
              move.promotion_choice = prompt_promotion_choice
            end
            result = @board.play_move(move)
            status_string = "made move #{move.get_notation}"
            status_string += ", check" if result
            @board.set_status(status_string, switch(@board.turn))
          end
        end
      else
        if @board.is_checkmate?(@board.turn)
          @board.set_status("Congratulations, you have forced checkmate!", :global)
          restart = true
          draw
        elsif @board.is_nomoves_stalemate?(@board.turn)
          @board.set_status("The result of this match is a stalemate.", :global)
          restart = true
          draw
        else
          move = @ai.get_move
          result = @board.play_move move
          status_string = "made move #{move.get_notation}"
          status_string += ", check" if result
          @board.set_status(status_string, switch(@board.turn))
        end
      end
      draw
    end
  end


  def draw
    row, col, i = 7, 0, 1
    if @team == :black
      row, col, i = 0, 7, -1
    end
    
    8.times do
      draw_row(col, row, i)
      row -= i
    end
  end

  def draw_row(col, row, i)
    8.times do
      @board.draw_piece(col, row)
      col += i
    end
  end

  def to_json(options = {})
    JSON.pretty_generate(
      { board:
        {
          turn:           @board.turn,
          status_bar:     @board.status_bar,
          pieces:         @board.pieces,
          played_moves:   @board.played_moves,
          legal_moves:    @board.legal_moves[@board.turn].map{|pc, mv_arr| mv_arr.map{|mv| mv.get_notation}},
          selected_moves: @board.selected_moves,
          selected:       @board.selected,
          move_count:     @board.move_count
        }
      }, options)
  end
end