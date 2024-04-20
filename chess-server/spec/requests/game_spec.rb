require 'rails_helper'

RSpec.describe "Games", type: :request do
  player_params = {
    game: {
      white_name: "Jimmy",
      black_name: "Bob"
    }
  }
  computer_params = {
    game: {
      white_name: nil,
      black_name: nil
    }
  }
  json_fields = ["id", "turn", "pieces", "legal_moves", "move_count"]

  describe 'POST /api/game' do

    it 'creates a game with expected fields' do

      post '/api/games', params: player_params

      expect(response.status).to eql(201)
      json_fields.each do |field|
        expect(JSON.parse(response.body)[field]).not_to eq(nil)
      end

      # Expect correct number of moves generated
      expect(JSON.parse(response.body)["legal_moves"].size).to eq(20)

      #

    end

  end
  describe 'GET /api/game' do

    it 'returns an existing game from an id' do

      post '/api/games', params: player_params

      id = JSON.parse(response.body)["id"]

      get '/api/games/' + id.to_s

      expect(response.status).to eql(200)

      # Expect all fields
      json_fields.each do |field|
        expect(JSON.parse(response.body)[field]).not_to eq(nil)
      end

    end
  end

  describe 'PATCH /api/game' do

    it "initiates a computer move when it is the computer's turn" do

      post '/api/games', params: computer_params
      expect(response.status).to eql(201)

      id = JSON.parse(response.body)["id"]

      patch '/api/games/' + id.to_s

      expect(response.status).to eql(200)

      # Expect all fields
      json_fields.each do |field|
        expect(JSON.parse(response.body)[field]).not_to eq(nil)
      end
      expect(JSON.parse(response.body)["move_count"]).to eql(2)

      # Expect correct turn
      expect(JSON.parse(response.body)["turn"]).to eq("black")

      # Expect black initial moves
      expect(JSON.parse(response.body)["legal_moves"].size).to eq(20)

    end
  end
end
