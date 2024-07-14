require 'swagger_helper'

RSpec.describe 'Live Games API', type: :request do

  test_code = '1234'
  test_token = '12345678'

  path '/api/live_games' do

    post('Creates a live game') do

      produces 'application/json'

      response(200, 'successful') do
        let(:id) { }
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