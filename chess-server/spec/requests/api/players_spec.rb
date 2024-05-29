require 'rails_helper'

RSpec.describe "Api::Players", type: :request do
  describe "GET /index" do

    it 'returns an array of all players in the environment db' do
      Player.destroy_all

      player1_attr = {name: "Huey"}
      player2_attr = {name: "Dewey"}
      player3_attr = {name: "Louie"}

      Player.create(player1_attr)
      Player.create(player2_attr)
      Player.create(player3_attr)

      get '/api/players'

      expect(response.status).to eql(200)

      players = JSON.parse(response.body)["players"]
      expect(players.length).to eq(Player.all.length)

      players.each do |player|
        expect([player1_attr[:name], player2_attr[:name], player3_attr[:name]].include?(player["name"])).to eq(true)
      end
    end
  end

  # Creating games
  describe 'POST /api/games' do

    game_params = {
      game: {
        white_name: "Jimmy",
        black_name: "Bob"
      }
    }
    white_player = Player.create(name: game_params[:game][:white_name])

    it 'creates a player by name if none exists' do
      post '/api/games', params: game_params

      expect(response.status).to eql(201)

      found_black = Player.find_by_name(game_params[:game][:black_name])
      expect(found_black).to_not eq(nil)
    end

    it 'attaches player reference if name exists' do

      post '/api/games', params: game_params

      expect(response.status).to eql(201)

      found_white = Player.find_by_name(game_params[:game][:white_name])
      expect(found_white).to_not eq(nil)

      g = Game.find(JSON.parse(response.body)["game"]["id"])

      expect(g.white_id).to eq(found_white.id)

    end
  end

end
