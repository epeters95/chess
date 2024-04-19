require 'rails_helper'

RSpec.describe "Games", type: :request do
  game_params = {
    game: {
      white_name: "Jimmy",
      black_name: nil
    }
  }
  describe 'POST /api/game' do


    it 'creates a game' do

      post '/api/games', params: game_params
      expect(response.status).to eql(201)
      expect(JSON.parse(response.body)["id"]).not_to eq(nil)
      expect(JSON.parse(response.body)["moves"]).not_to eq(nil)
      expect(JSON.parse(response.body)["moves"]["black"].size).to eq(0)
      expect(JSON.parse(response.body)["moves"]["white"].size).to eq(16)

    end

  end
  describe 'GET /api/game' do

    it 'returns a json response containing a game' do

      post '/api/games', params: game_params

      id = JSON.parse(response.body)["id"]

      get '/api/games/' + id.to_s
      

      expect(response.status).to eql(200)

    end

  end
end
