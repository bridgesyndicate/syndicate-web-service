require 'bunny'

class MockRabbitClient
  attr_accessor :connection

  def initialize()
    @connection = {}
  end

  def send_player_to_host(minecraft_uuid, container_name, ip_address)
    {}
  end
end
