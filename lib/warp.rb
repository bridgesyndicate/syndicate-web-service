require 'json'

class Warp
  attr_accessor :minecraft_uuid, :hostname, :port

  def initialize(minecraft_uuid, hostname)
    raise 'hostname must be set' if hostname.nil? || hostname.empty?
    raise 'minecraft_uuid must be set' if minecraft_uuid.nil? || minecraft_uuid.empty?
    puts "send_player_to_host #{minecraft_uuid} #{hostname}"
    @minecraft_uuid = minecraft_uuid
    @hostname = hostname
    @port = MINECRAFT_PORT
  end

  def to_json(*args)
    {
      minecraft_uuid: minecraft_uuid,
      hostname: hostname,
      port: port
    }.to_json
  end
end
