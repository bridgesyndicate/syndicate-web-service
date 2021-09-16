require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/sqs_client.rb'

def auth_game_accept_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  uuid = event['pathParameters']['proxy'].split('/')[0]
  discord_id = event['pathParameters']['proxy'].split('/')[2]

  status = ( uuid.match?(UUID_REGEX) &&
             discord_id.match?(/\d+/) ) ? OK : BAD_REQUEST

  return { statusCode: status,
           headers: headers_list,
           body: {}.to_json
  } if status == BAD_REQUEST

  # add to the accepted list

  ret = $ddb_game_manager.add_accepted_by_discord_id(uuid, discord_id)

  # check to see if all players have accepted

  accept_list = ret.attributes['game']['accepted_by_discord_ids']

  if accept_list.map{|i| i['discord_id']}.uniq.size ==
     ret.attributes['game']['required_players'].to_i

    sqs_ret = $sqs_manager.enqueue(GAME, ret.attributes['game'].to_json)
    status = SERVER_ERROR unless sqs_ret.message_id.match(UUID_REGEX)
  end

  return { statusCode: status,
           headers: headers_list,
           body: ret.attributes.to_json
  }

end
