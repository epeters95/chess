require 'net/http'
require 'uri'

class EngineInterface

  def initialize(api_url)
    @api_url = URI.parse(api_url)
    @level = 20
    @move_history = ""
  end
  
  def send_request
    data = '{"move_history": "' + @move_history + '", "level": "' + @level + '"}'
    headers = {'content-type': 'application/json'}
    res = Net::HTTP.post(
      @api_url,
      data,
      {'content-type': 'application/json'}
    )
    if res.is_a?(Net::HTTPSuccess)
      res.body
    else
      nil
    end
  end

  def get_move(move_history, level)
    @move_history = move_history
    @level = level
    resp = send_request
    unless resp.nil?
      resp["move"]
    else
      nil
    end
  end

end