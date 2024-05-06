require 'rails_helper'

RSpec.describe Game, type: :model do

  describe 'creating a game' do

    params = {
      white_name: "Whitey",
      black_name: "Blacky"
    }

    it 'creates a game with expected fields' do

      g = Game.create(params)

      expect(g.white_name).to eq(params[:white_name])
      expect(g.black_name).to eq(params[:black_name])
    end

  end

  describe 'updating a game' do

    params = {
      white_name: "Whitey",
      black_name: "Blacky"
    }

    params2 = {
      white_name: "Whitey2",
      black_name: "Blacky2"
    }

    it 'updates a game with expected fields' do

      g = Game.create(params)

      g.update({black_name: params2[:black_name], white_name: params2[:white_name]})

      expect(g.white_name).to eq(params2[:white_name])
      expect(g.black_name).to eq(params2[:black_name])
    end

  end

end
