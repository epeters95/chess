class LiveGame < ApplicationRecord
  belongs_to :game

  after_create :generate_access_code

  private
  def generate_access_code
    alphanum = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    code = ""
    4.times { code << alphanum[rand(alphanum.size)] }
    self.update(access_code: code)
  end
end
