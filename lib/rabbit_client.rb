require 'bunny'
require 'lib/warp'

class RabbitClient
  attr_accessor :connection, :channel

  LOBBY_NAME = 'lobby'.freeze

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

  def clear_warp_cache_for_players(minecraft_uuids)
    warp(minecraft_uuids
           .map {|uuid| Warp.new(uuid, LOBBY_NAME)}
        )
  end

  def send_players_to_host_no_cache(minecraft_uuids, hostname)
    warp(minecraft_uuids
           .map {|uuid| Warp.new(uuid, hostname, false)}
        )
  end

  def send_players_to_host_cached(minecraft_uuids, hostname)
      warp(minecraft_uuids
             .map {|uuid| Warp.new(uuid, hostname, true)}
          )
  end

  def warp(warp_list)
    @channel = connection.create_channel
    exchange = channel.fanout(DEFAULT_QUEUE)
    message = { warp_list: warp_list }.to_json
    puts message
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
