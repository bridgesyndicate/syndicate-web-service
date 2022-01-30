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
           .map {|uuid| Warp.new(uuid, LOBBY_NAME, false)}
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
    message = { warp_list: warp_list }.to_json
  end

  def shutdown
  end
end
