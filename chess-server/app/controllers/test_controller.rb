class TestController < ApplicationController

  def status
    render json: { message: "Latest service is live!" }, status: 200
  end
  
end