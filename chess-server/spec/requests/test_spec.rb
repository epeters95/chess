require 'swagger_helper'

RSpec.describe 'test', type: :request do

  path '/status' do

    get('status test') do
      response(200, 'successful') do

        example 'application/json', :example_1, {
           message: "Latest test service is live!"
        }
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

        example 'application/json', :example_1, {
           message: "Failed to test Chess Engine service!"
        }
        run_test!
      end
    end
  end
end
