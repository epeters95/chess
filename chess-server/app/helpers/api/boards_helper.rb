module Api::BoardsHelper

  # TODO: for now this only handles one game per file
  # add extra function to split multiple games
  def get_move_list_from_pgn(pgn_text)
    text_split = pgn_text.gsub("\r", "").split("\n\n")
    moves = text_split[1].gsub("\n", " ")
    result = moves.split(/\d+\./).map do |move_str|
      move_str = move_str.gsub("+", "").strip
      next if move_str.empty?
      mvs = move_str.split(" ")
      mvs.length == 1 ? mvs[0] : mvs.take(2)
    end.flatten.compact
    result
    # Flattens [ [<black_move>, <white_move>], ...] to 1d array
  end

  def get_name_from_pgn(pgn_text, color)
    text_split = pgn_text.gsub("\r", "").split("\n\n")
    header = text_split[0]
    if color == "white"
      mat = header.scan(/\[White "([\w, .]+)"\]/)
    else
      mat = header.scan(/\[Black "([\w, .]+)"\]/)
    end
    unless mat.empty?
      return mat.flatten[0]
    end
  end


end
