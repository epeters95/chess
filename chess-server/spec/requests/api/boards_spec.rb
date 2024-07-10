require 'swagger_helper'

RSpec.describe 'Boards API', type: :request do
  path '/api/boards/{id}' do

    get('Show board by id') do
      produces 'application/json'

      parameter name: :id, in: :path, type: :string

      response(200, 'successful') do
        let(:id) { '1' }
        run_test!
      end
    end

  end
end
