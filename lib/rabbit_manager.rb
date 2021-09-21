require 'bunny'

class RabbitClient
  attr_accessor :connection

  def initialize()
    if ENV['RABBIT_URI']
      @connection = Bunny.new(ENV['RABBIT_URI'])
    else
      @connection = Bunny.new(automatically_recover: false,
                              hostname: '127.0.0.1')
    end
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
