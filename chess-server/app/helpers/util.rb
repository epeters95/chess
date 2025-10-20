module Util

  include Quotes

  BOARD_SIZE = 8
  
  def switch(color); (color == "white" ? "black" : "white") end


  def file(col)
    %w(a b c d e f g h)[col]
  end

  def rank(row)
    %w(1 2 3 4 5 6 7 8)[row]
  end

  def build_empty_board
    b = Array.new(BOARD_SIZE)
    BOARD_SIZE.times {|i| b[i] = Array.new(BOARD_SIZE)}
    return b
  end

  def outside?(arr)
    arr[0] > BOARD_SIZE-1 || arr[0] < 0 || arr[1] > BOARD_SIZE - 1 || arr[1] < 0
  end

  def file_idx(pos); %w(a b c d e f g h).find_index(pos[0]); end

  def rank_idx(pos); pos[1].to_i - 1; end

  def keep_in_bounds(arr)
    arr.each_with_index do |el, idx|
      el > BOARD_SIZE-1 ? arr[idx] = el - 1 : nil
      el < 0 ? arr[idx] = el + 1 : nil
    end
  end

  def get_quote_html
    get_quote.gsub("\n", '')
  end

  def get_quote
    justify_str(QUOTES.shuffle[0])
  end

  def justify_str(str)
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

  def uppercase(str)
    "#{str[0].upcase}#{str[1..]}"
  end

  def promotion_map
    {
      "Q" => "queen",
      "R" => "rook",
      "B" => "bishop",
      "N" => "knight"
    }
  end
end