require 'rails_helper'

RSpec.describe "Api::Games", type: :request do
  player_params = {
    game: {
      white_name: "Jimmy",
      black_name: "Bob"
    }
  }
  player_params2 = {
    game: {
      white_name: "Johnny",
      black_name: "Bill"
    }
  }
  computer_params = {
    game: {
      white_name: nil,
      black_name: nil
    }
  }
  json_fields = ["id", "turn", "pieces", "legal_moves", "move_count"]


  # Create
  describe 'POST /api/games' do

    it 'creates a game with expected fields' do

      post '/api/games', params: player_params

      expect(response.status).to eql(201)
      json_fields.each do |field|
        expect(JSON.parse(response.body)["game"][field]).not_to eq(nil)
      end

      # Expect correct number of moves generated
      expect(JSON.parse(response.body)["game"]["legal_moves"].size).to eq(20)

    end

  end

  # Update
  describe 'PATCH /api/games/:id' do

    it "initiates a computer move when it is the computer's turn" do

      post '/api/games', params: computer_params
      expect(response.status).to eql(201)

      id = JSON.parse(response.body)["game"]["id"]

      patch '/api/games/' + id.to_s

      expect(response.status).to eql(200)

      # Expect all fields
      json_fields.each do |field|
        expect(JSON.parse(response.body)[field]).not_to eq(nil)
      end
      expect(JSON.parse(response.body)["move_count"]).to eql(1)

      # Expect correct turn
      expect(JSON.parse(response.body)["turn"]).to eq("black")

      # Expect black initial moves
      expect(JSON.parse(response.body)["legal_moves"].size).to eq(20)

    end

    it "sets a game status to completed when param end_game=true" do

      post '/api/games', params: player_params
      expect(response.status).to eql(201)

      id = JSON.parse(response.body)["game"]["id"]

      patch '/api/games/' + id.to_s, params: {"end_game": true}

      expect(response.status).to eql(200)

      get '/api/games/' + id.to_s
      expect(JSON.parse(response.body)["status"]).to eql("completed")
    end
  end

  # Index
  describe 'GET /api/games/' do

    it "returns for #index an array of all games in the environment db" do

      post '/api/games', params: player_params
      id = JSON.parse(response.body)["game"]["id"]
      patch '/api/games/' + id.to_s, params: {"end_game": true}

      post '/api/games', params: player_params2
      id = JSON.parse(response.body)["game"]["id"]
      patch '/api/games/' + id.to_s, params: {"end_game": true}

      get '/api/games'

      expect(response.status).to eql(200)

      expect(JSON.parse(response.body)["games"].length === 2)

      JSON.parse(response.body)["games"].each do |body_obj|
        expect(body_obj["id"]).not_to eq(nil)
        expect(body_obj["white_name"]).not_to eq(nil)
        expect(body_obj["black_name"]).not_to eq(nil)
        expect(body_obj["move_count"]).not_to eq(nil)
      end

    end
  end

end
