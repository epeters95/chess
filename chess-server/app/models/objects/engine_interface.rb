require 'net/http'
require 'uri'

class EngineInterface

  def initialize(hostname="127.0.0.1", port=5000)
    @hostname = hostname
    @port = port
    @level = 20
    @move_history = ""
  end
  
  def send_request(path, data)
    headers = {'content-type': 'application/json'}
    http = Net::HTTP.new(@hostname, @port)
    res = http.post(
      path,
      data,
      headers
    )
    if res.is_a?(Net::HTTPSuccess)
      res.body
    else
      nil
    end
  end

  def get_move(move_history, level, elo_rating=nil)
    move_history = move_history
    level = level
    data = "{\"move_history\": \"#{move_history}\", \"level\": \"#{level}\""

    if !elo_rating.nil?
      data += ", \"elo_rating\": #{elo_rating}}"
    else
      data += "}"
    end


    resp = send_request("/choose_move", data)
    unless resp.nil?
      JSON.parse(resp)["move"]
    else
      nil
    end
  end

  def get_eval(move_history)
    @move_history = move_history
    data = "{\"move_history\": \"#{@move_history}\"}"
    resp = send_request("/get_eval", data)
    unless resp.nil?
      JSON.parse(resp)["adv_white"]
    else
      nil
    end
  end

  def get_eval_list(move_history)
    @move_history = move_history
    data = "{\"move_history\": \"#{@move_history}\"}"
    resp = send_request("/get_eval_list", data)
    unless resp.nil?
      JSON.parse(resp)["move_evals"]
    else
      nil
    end
  end

end