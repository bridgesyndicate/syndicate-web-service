require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/sqs_client.rb'

def accepted_by_one_player_from_both_teams?(accepted_list, red_list, blue_list)
  accepted_list.any? { |a| blue_list.include?(a['discord_id']) } and
    accepted_list.any? { |a| red_list.include?(a['discord_id']) }
end

def auth_game_accept_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  uuid = event['pathParameters']['proxy'].split('/')[0]
  discord_id = event['pathParameters']['proxy'].split('/')[2]

  status = ( uuid.match?(UUID_REGEX) &&
             discord_id.match?(/\d+/) ) ? OK : BAD_REQUEST

  status = BAD_REQUEST if !event['body'].nil?

  return { statusCode: status,
           headers: headers_list,
           body: {}.to_json
  } if status == BAD_REQUEST

  # add to the accepted list

  ret = $ddb_game_manager.add_accepted_by_discord_id(uuid, discord_id)

  # check to see if all players have accepted

  accepted_list = ret.attributes['game']['accepted_by_discord_ids']

  if accepted_by_one_player_from_both_teams?(accepted_list,
                      ret.attributes['game']['red_team_discord_ids'],
                      ret.attributes['game']['blue_team_discord_ids'])
    syn_logger "game #{uuid} has been accepted by both teams, sending sqs"
    game = deep_to_h(ret.attributes['game'])
    sqs_ret = $sqs_manager.enqueue(GAME, game.to_json)
    status = SERVER_ERROR unless sqs_ret.message_id.match(UUID_REGEX)
  end

  return { statusCode: status,
           headers: headers_list,
           body: ret.attributes['game'].to_json
  }

end
