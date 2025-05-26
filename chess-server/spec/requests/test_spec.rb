require 'swagger_helper'

RSpec.describe 'test', type: :request do

  path '/status' do

    get('status test') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/status_interface' do

    get('status_interface test') do
      response(200, 'successful') do

        example 'application/json', :example_1, {
           message: "Chess Engine test is live!"
        }
        run_test!
      end

      response(404, 'not_found') do

        let(:message) { "Failed to test Chess Engine service" }
        run_test!
      end
    end
  end
end
