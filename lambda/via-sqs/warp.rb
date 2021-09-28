load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/helpers'
require 'lib/rabbit_client'

def handler(event:, context:)

  # Warp folks back to the lobby as this game is over on update
  minecraft_uuids = event['body']
  minecraft_uuids.each do |id|
    $rabbit_client.send_player_to_host(id, 'lobby', '')
  end
end
