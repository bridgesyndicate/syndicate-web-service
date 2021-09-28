load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/helpers'
require 'lib/rabbit_client'

def handler(event:, context:)

  puts event['body']

  # Warp folks back to the lobby as this game is over on update
  minecraft_uuids = JSON.parse(puts event['body'])
  minecraft_uuids.each do |id|
    $rabbit_client.send_player_to_host(id, 'lobby', '')
  end
end
