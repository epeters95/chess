require 'net/http'
require 'uri'

class EngineInterface

  def initialize(api_url)
    @api_url = URI.parse(api_url)
  end
  
  def send_request
    res = Net::HTTP.post_form.new(@api_url, 'move_history' => '', 'move' => '', 'game_id' => 1)
    if res.is_a?(Net::HTTPSuccess)
      return res.body
    end
  end

end