require 'bunny'

class RabbitClient
  attr_accessor :connection

  def initialize()
    if ENV['RABBIT_URI']
      props = AMQ::Settings.parse_amqp_url(ENV['RABBIT_URI'])
      props.merge!(user: 'AmazonMqUsername', pass: 'AmazonMqPassword', ssl: true)
      @connection = Bunny.new(props)
    else
      @connection = Bunny.new
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
