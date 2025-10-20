class Api::ErrorsController < ApplicationController
  def not_found
    render json: {
      status: 404,
      error: :not_found,
      message: 'Resource not found'
    }, status: 404
  end

  def unauthorized
    render json: {
      status: 401,
      error: :unauthorized,
      message: 'Request lacks valid authentication credentials'
    }, status: 401
  end

  def not_modified
    render json: {
      status: 304,
      error: :not_modified,
      message: 'Requested resource hasn\'t changed since last access'
    }, status: 304
  end

  def server_error
    render json: {
      status: 500,
      error: :internal_server_error,
      message: 'There was a problem with the server'
    }, status: 500
  end
end