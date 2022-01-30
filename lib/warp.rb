require 'json'

class Warp
  attr_accessor :minecraft_uuid, :hostname, :port, :cached

  def initialize(minecraft_uuid, hostname, cached)
    raise 'hostname must be set' if hostname.nil? || hostname.empty?
    raise 'minecraft_uuid must be set' if minecraft_uuid.nil? || minecraft_uuid.empty?
    syn_logger "send_player_to_host #{minecraft_uuid} #{hostname}"
    @minecraft_uuid = minecraft_uuid
    @hostname = hostname
    @port = MINECRAFT_PORT
    @cached = cached
  end

  def to_json(*args)
    {
      minecraft_uuid: minecraft_uuid,
      hostname: hostname,
      port: port,
      cached: cached
    }.to_json
  end
end
