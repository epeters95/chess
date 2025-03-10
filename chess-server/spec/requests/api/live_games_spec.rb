require 'swagger_helper'
require 'rails_helper'

RSpec.describe 'Live Games API', type: :request do

  # Rspec tests

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

      expect(JSON.parse(response.body)["id"]).to eq(id)

      livegame_fields.each do |field|
        expect(JSON.parse(response.body)[field]).not_to eq(nil)
      end

      expect(JSON.parse(response.body)["game"]).to eq(nil)

    end

    it 'acknowledges if request token matches' do

      post '/api/live_games'

      id = JSON.parse(response.body)["id"]
      access_code = JSON.parse(response.body)["access_code"]

      lg = LiveGame.find(id)
      expect(lg).to_not eq(nil)

      token = lg.request_white

      get '/api/live_games/?access_code=' + access_code.to_s + '&token=' + token

      expect(response.status).to eql(200)
      expect(JSON.parse(response.body)["token"]).to eq("white")

      token = lg.request_black

      get '/api/live_games/?access_code=' + access_code.to_s + '&token=' + token

      expect(response.status).to eql(200)
      expect(JSON.parse(response.body)["token"]).to eq("black")

    end
  end

  # Update
  describe 'PATCH /api/live_games/:id' do

    it "updates a live game with a player's chosen name" do


      post '/api/live_games'

      access_code = JSON.parse(response.body)["access_code"]
      id = JSON.parse(response.body)["id"]

      requestBody = {
        "player_name": "Bill",
        "player_team": "white",
        "access_code": access_code
      }

      patch '/api/live_games/' + id.to_s, params: requestBody

      expect(response.status).to eq(200)

      livegame_fields_created.each do |field|
        
        expect(JSON.parse(response.body)[field]).not_to eq(nil)

      end
    end

    it "does not update a live game's team twice" do
      
      post '/api/live_games'

      access_code = JSON.parse(response.body)["access_code"]
      id = JSON.parse(response.body)["id"]

      requestBody = {
        "player_name": "John",
        "player_team": "white",
        "access_code": access_code
      }

      patch '/api/live_games/' + id.to_s, params: requestBody

      expect(response.status).to eq(200)

      patch '/api/live_games/' + id.to_s, params: requestBody

      expect(response.status).to eq(422)

      requestBody = {
        "player_name": "Jim",
        "player_team": "black",
        "access_code": access_code
      }

      patch '/api/live_games/' + id.to_s, params: requestBody

      expect(response.status).to eq(200)

      patch '/api/live_games/' + id.to_s, params: requestBody

      expect(response.status).to eq(422)

    end

  end

  # Swagger spec descriptions

  test_code = '1234'
  test_token = '12345678'

  path '/api/live_games' do

    post('Creates a live game') do

      produces 'application/json'

      response(200, 'successful') do
        let(:id) { }
        example 'application/json', :example_1, {"id":51,"access_code":"CJ2L"}
        run_test!
      end

      # response(422, 'unprocessable entity') do
      #   let(:live_game) { { game: { white_name: nil, asdf: 'bad_input' } } }
      #   run_test!
      # end
    end

  path '/api/live_games/{id}'

    get('Show live game by id, access_code, token, and color') do
      produces 'application/json'

      parameter name: :id, in: :path, type: :string

      parameter name: :access_code, in: :path, type: :string
      parameter name: :color, in: :path, type: :string
      parameter name: :token, in: :path, type: :string

      response(200, 'successful') do
        let(:live_game) { {id: '1', access_code: test_code, color: 'white', token: test_token } }
        example 'application/json', :example_1, {"id":51,"access_code":"CJ2L","is_ready":false,"game":{"id":219,"turn":"white","turn_name":"Gukesh","white_name":"Gukesh","black_name":"","status_str":"White to move - Gukesh","game_status":"waiting_player","pieces":"{\"white\":[{\"color\":\"white\",\"position\":\"a2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"b2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"c2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"d2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"e2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"f2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"g2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"h2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"a1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"white\",\"position\":\"b1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"c1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"d1\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"white\",\"position\":\"e1\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"white\",\"position\":\"f1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"g1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"h1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}],\"black\":[{\"color\":\"black\",\"position\":\"a7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"b7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"c7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"d7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"e7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"f7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"g7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"h7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"a8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"black\",\"position\":\"b8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"c8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"d8\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"black\",\"position\":\"e8\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"black\",\"position\":\"f8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"g8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"h8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}]}","legal_moves":["{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"a2\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"a2\",\"new_position\":\"a4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b2\",\"new_position\":\"b3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b2\",\"new_position\":\"b4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"c2\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"c2\",\"new_position\":\"c4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"d2\",\"new_position\":\"d3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"d2\",\"new_position\":\"d4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"e2\",\"new_position\":\"e3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"e2\",\"new_position\":\"e4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"f2\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"f2\",\"new_position\":\"f4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g2\",\"new_position\":\"g3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g2\",\"new_position\":\"g4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"h2\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"h2\",\"new_position\":\"h4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b1\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nc3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b1\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Na3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g1\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nh3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g1\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nf3\",\"causes_check\":false}"],"move_count":0,"status":"waiting_player"},"live_game":{"id":51,"white_token":"[FILTERED]","black_token":"","access_code":"CJ2L","game_id":219,"created_at":"2024-11-22T01:51:03.618Z","updated_at":"2024-11-22T01:51:09.099Z"},"color":"white"}
        run_test!
      end


      response(404, 'not found') do
        let(:live_game) { {id: '1', access_code: 'undefined', color: 'white' } }
        run_test!
      end
    end

    patch('Update a live game with name and team') do
      produces 'application/json'

      parameter name: :id, in: :path, type: :string

      parameter name: :player_name, in: :body, type: :string
      parameter name: :access_code, in: :body, type: :string
      parameter name: :player_team, in: :body, type: :string

      response(200, 'successful') do
        let(:live_game) { {id: '1', player_name: "Jimmy", player_team: "white", access_code: test_code } }
        example 'application/json', :example_1, {"id":51,"token":"[FILTERED]","access_code":"CJ2L","color":"white","game":{"id":219,"turn":"white","turn_name":"Gukesh","white_name":"Gukesh","black_name":"","status_str":"White to move - Gukesh","game_status":"waiting_player","pieces":"{\"white\":[{\"color\":\"white\",\"position\":\"a2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"b2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"c2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"d2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"e2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"f2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"g2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"h2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"a1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"white\",\"position\":\"b1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"c1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"d1\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"white\",\"position\":\"e1\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"white\",\"position\":\"f1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"g1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"h1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}],\"black\":[{\"color\":\"black\",\"position\":\"a7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"b7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"c7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"d7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"e7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"f7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"g7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"h7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"a8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"black\",\"position\":\"b8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"c8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"d8\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"black\",\"position\":\"e8\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"black\",\"position\":\"f8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"g8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"h8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}]}","legal_moves":["{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"a2\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"a2\",\"new_position\":\"a4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b2\",\"new_position\":\"b3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b2\",\"new_position\":\"b4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"c2\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"c2\",\"new_position\":\"c4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"d2\",\"new_position\":\"d3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"d2\",\"new_position\":\"d4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"e2\",\"new_position\":\"e3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"e2\",\"new_position\":\"e4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"f2\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"f2\",\"new_position\":\"f4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g2\",\"new_position\":\"g3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g2\",\"new_position\":\"g4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"h2\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"h2\",\"new_position\":\"h4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b1\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nc3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b1\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Na3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g1\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nh3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g1\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nf3\",\"causes_check\":false}"],"move_count":0,"status":"waiting_player"},"is_ready":false}
        example 'application/json', :example_2, {"id":51,"token":"[FILTERED]","access_code":"CJ2L","color":"black","game":{"id":219,"turn":"white","turn_name":"Gukesh","white_name":"Gukesh","black_name":"Hikaru","status_str":"White to move - Gukesh","game_status":"ready","pieces":"{\"white\":[{\"color\":\"white\",\"position\":\"a2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"b2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"c2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"d2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"e2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"f2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"g2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"h2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"a1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"white\",\"position\":\"b1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"c1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"d1\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"white\",\"position\":\"e1\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"white\",\"position\":\"f1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"g1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"h1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}],\"black\":[{\"color\":\"black\",\"position\":\"a7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"b7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"c7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"d7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"e7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"f7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"g7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"h7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"a8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"black\",\"position\":\"b8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"c8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"d8\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"black\",\"position\":\"e8\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"black\",\"position\":\"f8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"g8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"h8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}]}","legal_moves":["{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"a2\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"a2\",\"new_position\":\"a4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b2\",\"new_position\":\"b3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b2\",\"new_position\":\"b4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"c2\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"c2\",\"new_position\":\"c4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"d2\",\"new_position\":\"d3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"d2\",\"new_position\":\"d4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"e2\",\"new_position\":\"e3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"e2\",\"new_position\":\"e4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"f2\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"f2\",\"new_position\":\"f4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g2\",\"new_position\":\"g3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g2\",\"new_position\":\"g4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"h2\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"h2\",\"new_position\":\"h4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h4\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b1\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nc3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"b1\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Na3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g1\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nh3\",\"causes_check\":false}","{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":0,\"position\":\"g1\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nf3\",\"causes_check\":false}"],"move_count":0,"status":"ready"},"is_ready":true}
        run_test!
      end

      response(404, 'not found') do
        let(:live_game) { {id: '1', player_name: "Jimmy", player_team: "white", access_code: 'undefined' } }
        run_test!
      end

      # response(422, 'unprocessable entity') do
      #   let(:live_game) { {id: '1', access_code: 'undefined', color: 'white' } }
      #   run_test!
      # end
    end

  end

end