require 'swagger_helper'

RSpec.describe 'Games API', type: :request do

  g_id = Game.create(white_name: "Jimmy", black_name: "John").id

  path '/api/games' do

    get('List all completed games, or games matching search params') do
      produces 'application/json'

      parameter name: :status,   in: :path, type: :string
      parameter name: :white_id, in: :path, type: :string
      parameter name: :black_id, in: :path, type: :string
      parameter name: :name,     in: :path, type: :string

      response(200, 'successful') do
        let(:name) { 'Computer' }
        let(:status) { 'completed' }
        let(:white_id) { '1' }
        let(:black_id) { '2' }
        example 'application/json', :example_1, [
          {"id":1,"white_name":"Bobby Fischer","black_name":"Garry Kasparov","move_count":38},
          {"id":2,"white_name":"Bobby Fischer","black_name":"Mikhail Tal","move_count":28},
          {"id":3,"white_name":"Computer","black_name":"Magnus Carlsen","move_count":5}
        ]
        run_test!
      end
    end

    post('Creates a game with given player names') do
      consumes 'application/json'
      produces 'application/json'

      parameter name: :game, in: :body, schema: {
        type: :object,
        properties: {
          status: { type: :string },
          white_name: { type: :string },
          black_name: { type: :string }
        }
      }

      response(201, 'created') do

        let(:game) { { game: { white_name: 'Tester' } } }
        example 'application/json', :example_1, {
          "id": 1,
          "turn": "white",
          "turn_name": "Bobby Fischer",
          "white_name": "Bobby Fischer",
          "black_name": "",
          "status_str": "White to move - Bobby Fischer",
          "game_status": "waiting_player",
          "pieces": "{\"white\":[{\"color\":\"white\",\"position\":\"a2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"b2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"c2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"d2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"e2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"f2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"g2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"h2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"a1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"white\",\"position\":\"b1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"c1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"d1\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"white\",\"position\":\"e1\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"white\",\"position\":\"f1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"g1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"h1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}],\"black\":[{\"color\":\"black\",\"position\":\"a7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"b7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"c7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"d7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"e7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"f7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"g7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"h7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"a8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"black\",\"position\":\"b8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"c8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"d8\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"black\",\"position\":\"e8\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"black\",\"position\":\"f8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"g8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"h8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}]}",
          "legal_moves": [
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"a2\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"a2\",\"new_position\":\"a4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b2\",\"new_position\":\"b3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b2\",\"new_position\":\"b4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"c2\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"c2\",\"new_position\":\"c4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"d2\",\"new_position\":\"d3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"d2\",\"new_position\":\"d4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"e2\",\"new_position\":\"e3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"e2\",\"new_position\":\"e4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"f2\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"f2\",\"new_position\":\"f4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g2\",\"new_position\":\"g3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g2\",\"new_position\":\"g4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"h2\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"h2\",\"new_position\":\"h4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b1\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nc3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"b1\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Na3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g1\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nh3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":1,\"position\":\"g1\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nf3\",\"causes_check\":false}"
          ],
          "move_count": 0,
          "status": "waiting_player"
        }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:game) { { game: {  asdf: 'bad_input' } } }
        run_test!
      end
    end
  end

  path '/api/games/{id}' do

    get('Show game by id') do
      produces 'application/json'

      parameter name: :id, in: :path, type: :string

      response(200, 'successful') do
        let(:id) { g_id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { '0' }
        run_test!
      end
    end

    patch('Play a move on the game or update a game to be over') do
      produces 'application/json'
      consumes 'application/json'

      parameter name: :id, in: :path, type: :string
      parameter name: :move, in: :body, schema: {
        type: :object,
        properties: {
          notation: { type: :string }
        }
      }
      parameter name: :end_game, in: :body, type: :string

      response(200, 'successful') do
        let(:id) { g_id }
        let(:move) { { move: { notation: 'e4' } } }
        example 'application/json', :example_1, {
          "id": 1,
          "turn": "white",
          "turn_name": "Bobby Fischer",
          "white_name": "Bobby Fischer",
          "black_name": "",
          "status_str": "Computer made move f5. White to move.",
          "game_status": "waiting_player",
          "pieces": "{\"white\":[{\"color\":\"white\",\"position\":\"a2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"b4\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":1,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"c2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"d2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"e2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"f2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"g2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"h2\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":1,\"class_name\":\"Pawn\"},{\"color\":\"white\",\"position\":\"a1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"white\",\"position\":\"b1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"c1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"d1\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"white\",\"position\":\"e1\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"white\",\"position\":\"f1\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"white\",\"position\":\"g1\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"white\",\"position\":\"h1\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}],\"black\":[{\"color\":\"black\",\"position\":\"a7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"b7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"c7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"d7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"e7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"f5\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":1,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"g7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"h7\",\"ranged\":false,\"taken\":false,\"char\":\"♟\",\"move_count\":0,\"pawn_dir\":-1,\"class_name\":\"Pawn\"},{\"color\":\"black\",\"position\":\"a8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"},{\"color\":\"black\",\"position\":\"b8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"c8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"d8\",\"ranged\":true,\"taken\":false,\"char\":\"♛\",\"class_name\":\"Queen\"},{\"color\":\"black\",\"position\":\"e8\",\"ranged\":false,\"taken\":false,\"char\":\"♚\",\"castleable\":true,\"class_name\":\"King\"},{\"color\":\"black\",\"position\":\"f8\",\"ranged\":true,\"taken\":false,\"char\":\"♝\",\"class_name\":\"Bishop\"},{\"color\":\"black\",\"position\":\"g8\",\"ranged\":false,\"taken\":false,\"char\":\"♞\",\"class_name\":\"Knight\"},{\"color\":\"black\",\"position\":\"h8\",\"ranged\":true,\"taken\":false,\"char\":\"♜\",\"castleable\":true,\"class_name\":\"Rook\"}]}",
          "legal_moves": [
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"a2\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"a2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"a2\",\"new_position\":\"a4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"a4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b4\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":1,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"b4\",\"new_position\":\"b5\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"b5\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"c2\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"c2\",\"new_position\":\"c4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"c4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"d2\",\"new_position\":\"d3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"d2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"d2\",\"new_position\":\"d4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"d4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"e2\",\"new_position\":\"e3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"e2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"e2\",\"new_position\":\"e4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"e4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"f2\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"f2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"f2\",\"new_position\":\"f4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"f4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"g2\",\"new_position\":\"g3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"g2\",\"new_position\":\"g4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"g4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"h2\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"h2\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♟\\\",\\\"move_count\\\":0,\\\"pawn_dir\\\":1,\\\"class_name\\\":\\\"Pawn\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"h2\",\"new_position\":\"h4\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"h4\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"b1\",\"new_position\":\"c3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nc3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"b1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"b1\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Na3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c1\\\",\\\"ranged\\\":true,\\\"taken\\\":false,\\\"char\\\":\\\"♝\\\",\\\"class_name\\\":\\\"Bishop\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"c1\",\"new_position\":\"b2\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Bb2\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"c1\\\",\\\"ranged\\\":true,\\\"taken\\\":false,\\\"char\\\":\\\"♝\\\",\\\"class_name\\\":\\\"Bishop\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"c1\",\"new_position\":\"a3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Ba3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"g1\",\"new_position\":\"h3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nh3\",\"causes_check\":false}",
            "{\"piece_str\":\"{\\\"color\\\":\\\"white\\\",\\\"position\\\":\\\"g1\\\",\\\"ranged\\\":false,\\\"taken\\\":false,\\\"char\\\":\\\"♞\\\",\\\"class_name\\\":\\\"Knight\\\"}\",\"other_piece_str\":null,\"move_type\":\"move\",\"move_count\":2,\"position\":\"g1\",\"new_position\":\"f3\",\"rook_position\":null,\"promotion_choice\":null,\"notation\":\"Nf3\",\"causes_check\":false}"
          ],
          "move_count": 2,
          "status": "waiting_player"
        }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:id) { g_id }
        let(:move) { { move: { notation: 'e4', asdf: 'bad_input' } } }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { '0' }
        run_test!
      end
    end

  end

  path '/api/quote' do

    get('Show a random chess quote') do
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end

  end
end
