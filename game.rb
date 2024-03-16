require 'io/console'
require 'highline'
require 'colorize'
require './board'
require './ai'
require './util'
require './quotes'
require 'pry'
require 'pry-nav'
include HighLine::SystemExtensions

class Game
  CHESSTR_1 = "\nCHESS"
  CHESSTR_2 = "\tv0.99"

  def initialize(debug_mode=false)
    @mode = :cursor # :notate
    @debug = debug_mode
    system 'cls'
    puts "#{CHESSTR_1.yellow}#{CHESSTR_2.cyan}"
    puts
    puts justify_quote_str(QUOTES.shuffle[0]).red
    puts
    puts "PRESS ANY KEY".grey
    c = STDIN.getch
    play
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
    loop do
      ch = STDIN.getch.chr.downcase
      case ch
      when 'q'
        return :queen
      when 'r'
        return :rook
      when 'n'
        return :knight
      when 'b'
        return :bishop
      end
    end
  end

  def play
    prompt_teams
    @board = Board.new(@team)
    @board.generate_legal_moves

    @ai = Ai.new(@board, switch(@team))
    puts "Loading..."

    ch = ''
    i = (@team == :black ? -1 : 1)
    restart = false

    while true && !restart
      # Insufficient material stalemate
      all_remaining = @board.pieces.values.flatten.find_all{|pc| !pc.taken }
      insufficient = false
      if all_remaining.size <= 4
        dbg = "REMAINING: \n" + all_remaining.map{|r| "#{r.color} #{r.notation} #{r.position}, taken=#{r.taken}\n" }.join("") + "****\n"
        @board.set_status(dbg, :global)
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

      if insufficient
        @board.set_status("The outcome of this draw is a game due to insufficient mating material.", :global)
        restart = true
        draw
      elsif @board.turn == @team
        if @board.legal_moves[@team].values.flatten.empty?
          if @board.is_king_checked?(@team)
            @board.set_status("You have been checkmated by your opponent. You LOSE this game.", :global)
          else
            @board.set_status("It looks like you have survived by stalemate!", :global)
          end
          restart = true
          draw
        else
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
            @board.move_cursor [-1 * i, 0]
          when 'd'
            @board.move_cursor [i, 0]
          when 'w'
            @board.move_cursor [0, i]
          when 's'
            @board.move_cursor [0, -1 * i]
          when "\r"
            move = @board.select_square
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
        end
      else
        move = @ai.get_move
        if move.nil?
          restart = true
          if @board.is_king_checked?(@board.turn)
            @board.set_status("Congratulations, you have forced checkmate!", :global)
          else
            @board.set_status("The result of this match is a stalemate.", :global)
          end
          draw
        else
          result = @board.play_move move
          status_string = "made move #{move.get_notation}"
          status_string += ", check" if result
          @board.set_status(status_string, switch(@board.turn))
        end
      end
      draw
    end
    
    if restart
      ch = STDIN.getch.chr.downcase
    end
  end


  def draw
    system 'cls'
    row, col, i = 7, 0, 1
    if @team == :black
      row, col, i = 0, 7, -1
    end
    
    8.times do
      draw_row(col, row, i)
      row -= i
      puts
    end

    puts
    puts @board.status_bar[:white]
    puts @board.status_bar[:black]
    puts @board.status_bar[:global]
    if @debug
      puts "********* DEBUG MODE **********"
      puts @board.debug_str
    end
    # puts @board.move_list
  end

  def prompt_teams
    # ch = ''
    # until ['y', 'n'].include? ch.downcase
    #   system 'cls'
    #   puts "Use Notation entry method? (Y or N)"
    #   ch = STDIN.getch.chr
    #   @mode = :notate if ch.downcase == 'y'
    # end
    ch = ''
    until ['w', 'b', 'r'].include? ch.downcase
      system 'cls'
      puts "White, Black, or Random? (w, b, r): "
      ch = STDIN.getch.chr.downcase
      if ch == 'w'
        @team = :white
      elsif ch == 'b'
        @team = :black
      elsif ch == 'r'
        @team = (rand.round == 1 ? :white : :black)
      end
    end
  end

  def draw_row(col, row, i)
    8.times do
      @board.draw_piece(col, row)
      col += i
    end
  end
end

Game.new()
