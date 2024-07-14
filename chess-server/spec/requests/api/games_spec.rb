require 'swagger_helper'

RSpec.describe 'Games API', type: :request do

  path '/api/games' do

    get('List all completed games, or games matching search params') do
      produces 'application/json'

      parameter name: :status,   in: :path, type: :string
      parameter name: :white_id, in: :path, type: :string
      parameter name: :black_id, in: :path, type: :string
      parameter name: :name,     in: :path, type: :string

      response(200, 'successful') do
        let(:games) { { name: 'Computer', status: 'completed' } }
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

      response(200, 'successful') do

        let(:game) { { game: { white_name: 'Tester' } } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:game) { { game: { white_name: nil, asdf: 'bad_input' } } }
        run_test!
      end
    end
  end

  path '/api/games/{id}' do

    get('Show game by id') do
      produces 'application/json'

      parameter name: :id, in: :path, type: :string

      response(200, 'successful') do
        let(:id) { '1' }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { '0' }
        run_test!
      end
    end

    patch('Update game') do
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
        let(:id) { '1' }
        let(:move) { { move: { notation: 'e4' } } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:id) { '1' }
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
