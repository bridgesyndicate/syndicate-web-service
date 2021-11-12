require 'bunny'

class MockRabbitClient
  attr_accessor :connection

  def initialize()
    @connection = {}
  end

  def send_player_to_host(warp_list)
    { warp_list: warp_list }.to_json
  end

  def shutdown
  end
end
