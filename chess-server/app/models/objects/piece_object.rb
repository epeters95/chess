class PieceObject

  # Pieces will be represented with a notation illustrated in to_json

  include Util

  def self.knight_moves; [[1,2],[1,-2],[-1,2],[-1,-2],[2,1],[-2,1],[2,-1],[-2,-1]]; end
  def self.rook_moves;   [[0,1],[1,0],[0,-1],[-1,0]]; end
  def self.bishop_moves; [[1,1],[1,-1],[-1,1],[-1,-1]]; end
  def self.crown_moves;  [[1,1],[1,-1],[-1,1],[-1,-1],[0,1],[1,0],[0,-1],[-1,0]]; end

  attr_accessor :color, :position, :val
  attr_reader :char, :ranged, :taken

  def initialize(color, position)
    @color = color
    @position = position
    @current_legal_moves = []
    @ranged = (self.is_a?(Rook) || self.is_a?(Bishop) || self.is_a?(Queen))
    @taken = false
    @char = "?"
    @val = 0
  end

  def clear_moves
    @current_legal_moves = []
  end

  def get_moves
    @current_legal_moves
  end

  def add_moves(moves)
    @current_legal_moves.concat moves
  end

  def self.generate(piece_type, color, pos)
    case piece_type
    when "pawn"
      pc = Pawn.new(color, pos)
    when "knight"
      pc = Knight.new(color, pos)
    when "bishop"
      pc = Bishop.new(color, pos)
    when "rook"
      pc = Rook.new(color, pos)
    when "queen"
      pc = Queen.new(color, pos)
    when "king"
      pc = King.new(color, pos)
    end
    pc
  end

  def deep_dup
    self.class.new(@color, @position)
  end

  def take
    @taken = true
    @position = nil
  end

  def set_played
    @current_legal_moves = []
  end

  def piece_directions
    # subclasses define     
    []
  end
  

  # Utilities
  def file
    @position[0]
  end

  def rank
    @position[1]
  end

  def notation
    @char
  end

  def to_s
    notation
  end

  def to_json(exclude_moves=true, options = {})
    merged_hash = to_json_obj(exclude_moves)
    JSON.generate(merged_hash, options)
  end

  def to_json_obj(exclude_moves=true)
    exclude_vars = [:@val, :@letter]
    exclude_vars << [:@current_legal_moves, :notation] if exclude_moves
    vars = instance_variables.excluding exclude_vars
    merged_hash = vars.to_h do |iv|
      [iv.to_s.delete('@'), instance_variable_get(iv)]
    end.merge(
      {
        piece_directions: piece_directions,
        class_name: self.class.name
      }
    )
    merged_hash
  end

  def self.from_json_str(piece_str, exclude_moves=false)
    if piece_str.nil? || piece_str == "null"
      return nil
    end
    self.from_json(JSON.parse(piece_str), exclude_moves)
  end

  def self.from_json(json_obj, exclude_moves=false)
    klass = Object.const_get(json_obj["class_name"])
    init_arg_names = klass.instance_method(:initialize).parameters.map{|pm| pm[1].to_s }
    args = init_arg_names.map{|arg| json_obj[arg] }
    piece_obj = klass.new(*args)
    if json_obj["current_legal_moves"]
      piece_obj.add_moves(json_obj["current_legal_moves"].map{|lm| Move.from_json(lm)})
    end
    piece_obj
  end
end
