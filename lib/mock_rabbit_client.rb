require 'bunny'
require 'lib/warp'

class MockRabbitClient
  attr_accessor :connection

  LOBBY_NAME = 'lobby'.freeze

  def initialize()
    @connection = {}
  end

  def clear_warp_cache_for_players(minecraft_uuids)
    warp(minecraft_uuids
           .map {|uuid| Warp.new(uuid, LOBBY_NAME)}
        )
  end

  def send_players_to_host(minecraft_uuids, hostname)
    warp(minecraft_uuids
           .map {|uuid| Warp.new(uuid, hostname)}
        )
  end

  def warp(warp_list)
    message = { warp_list: warp_list }.to_json
    puts message
  end

  def shutdown
  end
end
