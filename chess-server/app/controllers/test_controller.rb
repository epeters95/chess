class TestController < ApplicationController
  include ActionController::MimeResponds

  def index
    respond_to do |format|
      format.html { render body: Rails.root.join("public/display.html").read }
    end
  end

  def games_index
    respond_to do |format|
      format.html { render body: Rails.root.join("public/games_index.html").read }
    end
  end
end