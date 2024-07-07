require 'swagger_helper'

RSpec.describe 'Games API', type: :request do

  path '/api/games' do

    get('List all completed games, or games matching search params') do
      produces 'application/json'
      parameter name: :status, in: :path, type: :string
      parameter name: :white_id, in: :path, type: :string
      parameter name: :black_id, in: :path, type: :string
      parameter name: :name, in: :path, type: :string

      response('200', 'successful') do
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

      response('200', 'successful') do

        let(:game) { { game: { white_name: 'Tester' } }
        run_test!
      end

      response('422', 'unprocessable entity') do
        let(:game) { game: { white_name: nil, asdf: 'bad_input' } }
        run_test!
    end
  end

  # path '/api/games/new' do

  #   get('new game') do
  #     response('200', 'successful') do

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end

  # path '/api/games/{id}/edit' do
  #   # You'll want to customize the parameter types...
  #   parameter name: 'id', in: :path, type: :string, description: 'id'

  #   get('edit game') do
  #     response('200', 'successful') do
  #       let(:id) { '123' }

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end

  # path '/api/games/{id}' do
  #   # You'll want to customize the parameter types...
  #   parameter name: 'id', in: :path, type: :string, description: 'id'

  #   get('show game') do
  #     response('200', 'successful') do
  #       let(:id) { '123' }

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end

  #   patch('update game') do
  #     response('200', 'successful') do
  #       let(:id) { '123' }

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end

  #   put('update game') do
  #     response('200', 'successful') do
  #       let(:id) { '123' }

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end

  #   delete('delete game') do
  #     response('200', 'successful') do
  #       let(:id) { '123' }

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end

  # path '/api/quote' do

  #   get('quote game') do
  #     response('200', 'successful') do

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end
end
