require 'bunny'

class RabbitClient
  attr_accessor :connection

  def initialize()
    @connection = Bunny.new(automatically_recover: false,
                            hostname: ENV['RABBIT_HOST'] || '127.0.0.1')
    connection.start
  end

  def send_player_to_host(minecraft_uuid, container_name, ip_address)
    channel = connection.create_channel
    exchange = channel.fanout(DEFAULT_QUEUE)
    message = {
      player: minecraft_uuid,
      hostname: container_name,
      host: ip_address,
      port: 25565
    }.to_json
    exchange.publish(message)
  end
end
