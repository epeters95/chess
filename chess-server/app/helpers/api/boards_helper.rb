module Api::BoardsHelper
  def get_move_list_from_pgn(pgn_text)
    text_split = pgn_text.split("\n\n")
    header = text_split[0]
    moves = text_split[1]
    moves.split(/\d\. /).map do |move_str|
      next if move_str.empty?
      move_str.split(" ")
    end.flatten
    # Flattens [ [<black_move>, <white_move>], ...] to 1d array
  end
end
