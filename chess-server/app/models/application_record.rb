require_relative './objects/board_object'
require_relative './objects/piece_object'
require_relative './objects/move_object'
require_relative './objects/engine_interface.rb'
require_relative './objects/pieces/bishop.rb'
require_relative './objects/pieces/king.rb'
require_relative './objects/pieces/knight.rb'
require_relative './objects/pieces/pawn.rb'
require_relative './objects/pieces/queen.rb'
require_relative './objects/pieces/rook.rb'

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
