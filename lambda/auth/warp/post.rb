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
    raise unless event['body'].nil?
  rescue
    error = { error: "discord_id: #{discord_id}," +
              "game_uuid: #{game_uuid}," +
              "event_body: #{event['body']}" }
    syn_logger error.inspect
    return { statusCode: BAD_REQUEST,
             headers: headers_list,
             body: error.to_json
    }
  end

  status = OK
  reason = ''

  user = $ddb_user_manager.get_by_discord_id(discord_id)

  if user.items.empty?
    syn_logger "user #{discord_id} not found"
    status = NOT_FOUND
    reason = 'User not found'
  end

  return { statusCode: status,
           headers: headers_list,
           body: { reason: reason }.to_json } if status != OK

  minecraft_uuid = user.items.first['minecraft_uuid'] # TODO: make a User model
  syn_logger "minecraft_uuid: #{minecraft_uuid}, discord_id: #{discord_id}"

  game = $ddb_game_manager.get(game_uuid)

  if game.items.empty?
    syn_logger "game #{game_uuid} not found"
    status = NOT_FOUND
    reason = 'Game not found'
  end

  return { statusCode: status,
           headers: headers_list,
           body: {reason: reason }.to_json } if status != OK

  if game.items.first['game']['state']
    status = NOT_FOUND
    reason = 'Game is over'
  end


  return { statusCode: status,
           headers: headers_list,
           body: {reason: reason }.to_json } if status != OK

  task_ip = game.items.first['game']['task_ip']

  syn_logger "send_player_to_host discord_id #{discord_id}, game: #{game_uuid}, minecraft_uuid: #{minecraft_uuid}, task_ip: #{task_ip}"
  rabbit_client.send_players_to_host_no_cache(Array(minecraft_uuid), task_ip)
  rabbit_client.shutdown
  ret = { task_ip: task_ip }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json }
end
