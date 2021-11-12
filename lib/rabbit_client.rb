require 'bunny'
require 'warp'

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

  def send_player_to_host(warp_list)
    @channel = connection.create_channel
    exchange = channel.fanout(DEFAULT_QUEUE)
    message = { warp_list: warp_list }.to_json
    exchange.publish(message)
  end

  def shutdown
    puts "Shutting down rabbit #{connection}"
    # it seems Lambda runs share state when using the
    # global, "$rabbit_client"
    # e.g.     "this connection is not open. Was Bunny::Session#start invoked? Is automatic recovery enabled?"
    # and "read would block", "Function<OpenSSL::SSL::SSLErrorWaitReadable>"
    channel.close if channel
    connection.close if connection
  end
end
