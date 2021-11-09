load 'git_commit_sha.rb'
require 'json'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/rabbit_client_factory'

def auth_warp_post_handler(event:, context:)

  rabbit_client = RabbitClientFactory.produce

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Syndicate-commit-sha" => $my_git_commit_sha
  }

  begin
    discord_id = event['pathParameters']['proxy'].split('/')[0]
    game_uuid = event['pathParameters']['proxy'].split('/')[2]
    raise unless discord_id.match(/\d+/)
    raise unless game_uuid.match(UUID_REGEX)
  rescue
    return { statusCode: BAD_REQUEST,
             headers: headers_list,
             body: {}.to_json
    }
  end

  status = OK

  user = $ddb_user_manager.get_by_discord_id(discord_id)
  if user.items.empty?
    status = NOT_FOUND
  else
    minecraft_uuid = user.items.first['minecraft_uuid'] # TODO: make a User model
  end

  game = $ddb_game_manager.get(game_uuid)

  if game.items.empty?
    status = NOT_FOUND
  else
    task_ip = game.items.first['game']['task_ip']
  end

  puts "auth/warp/post rabbit send_player_to_host #{minecraft_uuid} #{task_ip}"
  rabbit_client.send_player_to_host(minecraft_uuid, task_ip, task_ip)

  return { statusCode: status,
           headers: headers_list,
           body: task_ip.to_json }

end