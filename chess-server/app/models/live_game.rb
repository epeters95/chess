class LiveGame < ApplicationRecord
  belongs_to :game, required: false

  after_create :generate_access_code

  def request_black
    token = self.class.generate_token
    self.update(black_token: token)
    token
  end

  def request_white
    token = self.class.generate_token
    self.update(white_token: token)
    token
  end

  def is_ready?
    !self.black_token.blank? && !self.white_token.blank?
  end


  private
  def generate_access_code
    alphanum = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    code = ""
    4.times { code << alphanum[rand(alphanum.size)] }
    self.update(access_code: code)
  end

  def self.generate_token
    SecureRandom::urlsafe_base64
  end
end
