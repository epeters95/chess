require 'rails_helper'

RSpec.describe "LiveGames", type: :request do
  test_params = {
    access_code: "JOOP"
  }
  livegame_fields = ["id", "access_code", "is_ready", "live_game"]
  livegame_fields_created = ["id", "token", "game", "is_ready"]


  # Create
  describe 'POST /api/live_games' do

    it 'creates a live game with expected fields' do

      post '/api/live_games'

      expect(response.status).to eql(201)

      expect(JSON.parse(response.body)["id"]).not_to eq(nil)
      expect(JSON.parse(response.body)["access_code"]).not_to eq(nil)

    end

  end

  # Show
  describe 'GET /api/live_games/:id' do

    it 'returns an existing game from an id' do

      post '/api/live_games'

      id = JSON.parse(response.body)["id"]
      access_code = JSON.parse(response.body)["access_code"]

      get '/api/live_games/?access_code=' + access_code.to_s

      expect(response.status).to eql(200)

      expect(JSON.parse(response.body)["id"]).to eql(id)

      livegame_fields.each do |field|
        expect(JSON.parse(response.body)[field]).not_to eq(nil)
      end

      expect(JSON.parse(response.body)["game"]).to eql(nil)

    end
  end

  # Update
  describe 'PATCH /api/live_games/:id' do

    it "updates a live game with a player's chosen name" do


      post '/api/live_games'

      access_code = JSON.parse(response.body)["access_code"]
      id = JSON.parse(response.body)["id"]

      requestBody = {
        "player_name": "Boofy",
        "player_team": "white",
        "access_code": access_code
      }

      patch '/api/live_games/' + id.to_s, params: requestBody

      expect(response.status).to eql(200)

      livegame_fields_created.each do |field|
        
        expect(JSON.parse(response.body)[field]).not_to eq(nil)

      end
    end

  end
end
