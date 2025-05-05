class TestController < ApplicationController

  require 'engine_interface'

  def status
    render json: { message: "Latest service is live!" }, status: :ok
  end

  def status_interface
    interface = EngineInterface.new(ChessServer::Application.engine_interface_hostname,
                                        ChessServer::Application.engine_interface_port)
    response = interface.send_request('/status')
    if response
      render json: { message: "Chess Engine is live!" }, status: :ok
    else
      render json: { message: "Failed to communicate with Chess Engine service" }, status: :not_found
    end
  end
  
end