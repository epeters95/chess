require 'rails_helper'

RSpec.describe "Players", type: :request do
  describe "GET /index" do

    player1_attr = {name: "Huey"}
    player2_attr = {name: "Dewey"}
    player3_attr = {name: "Louie"}

    Player.create(player1_attr)
    Player.create(player2_attr)
    Player.create(player3_attr)

    it 'returns an array of all players in the environment db' do

      id = JSON.parse(response.body)["id"]
      access_code = JSON.parse(response.body)["access_code"]

      get '/api/players'

      expect(response.status).to eql(200)
      expect(JSON.parse(response.body)).length == Player.all.length)

      JSON.parse(response.body).each do |player_name|
        expect([player1_attr.name, player2_attr.name, player3_attr.name].include?(player_name)).to eq(true)
      end
    end
  end
end
