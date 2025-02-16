require 'net/http'
require 'uri'

class EngineInterface

  def initialize(hostname, port, path)
    @hostname = hostname
    @port = port
    @path = path
    @level = 20
    @move_history = ""
  end
  
  def send_request
    data = "{\"move_history\": \"#{@move_history}\", \"level\": \"#{@level}\"}"
    headers = {'content-type': 'application/json'}
    http = Net::HTTP.new(@hostname, @port)
    res = http.post(
      @path,
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
      JSON.parse(resp)["move"]
    else
      nil
    end
  end

end