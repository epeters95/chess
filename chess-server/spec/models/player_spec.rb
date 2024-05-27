require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'creating a game' do


    params = {
      white_name: "Whitey",
      black_name: "Blacky"
    }

    it 'creates a player by name if none exists' do
      g = Game.create(params)

      found_white = Player.find_by_name(params[:white_name])
      found_black = Player.find_by_name(params[:black_name])
      expect(found_white).to_not eq(nil)
      expect(found_black).to_not eq(nil)
    end

    it 'attaches player reference if name exists' do

      new_player = Player.create(name: params[:white_name])

      g = Game.create(params)

      found_white = Player.find_by_name(params[:white_name])
      expect(found_white).to_not eq(nil)

      expect(g.white_id).to eq(new_player.id)

    end

  end
end
