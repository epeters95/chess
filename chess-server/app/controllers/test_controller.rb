class TestController < ApplicationController

  def status
    render json: { message: "Service is live!" }, status: 200
  end
  
end