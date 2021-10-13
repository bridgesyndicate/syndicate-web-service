require 'bunny'

class RabbitClient
  attr_accessor :connection, :channel

  def initialize()
    if ENV['RABBIT_URI']
      props = AMQ::Settings.parse_amqp_url(ENV['RABBIT_URI'])
      props.merge!(user: 'AmazonMqUsername', pass: 'AmazonMqPassword',
                   ssl: true, automatic_recovery: true)
      @connection = Bunny.new(props)
    else
      @connection = Bunny.new
    end
    connection.start
  end

  def send_player_to_host(minecraft_uuid, container_name, ip_address)
    @channel = connection.create_channel
    exchange = channel.fanout(DEFAULT_QUEUE)
    message = {
      player: minecraft_uuid,
      hostname: container_name,
      host: ip_address,
      port: MINECRAFT_PORT
    }.to_json
    exchange.publish(message)
  end

  def shutdown
    puts "Shutting down rabbit #{connection.inspect}"
    # it seems Lambda runs share state when using the
    # global, "$rabbit_client"
    # e.g.     "this connection is not open. Was Bunny::Session#start invoked? Is automatic recovery enabled?"
    # and "read would block", "Function<OpenSSL::SSL::SSLErrorWaitReadable>"
    channel.close
    connection.close
  end
end
