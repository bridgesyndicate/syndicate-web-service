require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/schema/game_post'
require 'lib/sqs_client.rb'

def auth_game_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  payload = event['body']
  status = JSON::Validator.validate(GamePostSchema.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST
  return { statusCode: status,
           headers: headers_list,
           body: { reason: "Payload json does not validate against schema."}.to_json
  } if status != OK

  game = JSON.parse(payload, object_class: OpenStruct)

  # ensure all the discord_ids are verified (have user records)

  required_users = (game['blue_team_discord_ids'] + game['red_team_discord_ids']).uniq
  ensure_verified_ret = $ddb_user_manager.ensure_verified(required_users)
  verified_count = ensure_verified_ret.map { |r|
    r.items.size}.inject(0) { |sum,x|
    sum + x }

  status = NOT_FOUND unless verified_count == required_users.size

  return { statusCode: status,
           headers: headers_list,
           body: { reason: "All discord users must be verified." }.to_json
  } if status != OK

  lut = ensure_verified_ret.map {|i| i.items.first}.map{|x|
    { x['discord_id'].to_i => x['minecraft_uuid'] } }.reduce({}, :merge)
  game['blue_team_minecraft_uuids'] = game['blue_team_discord_ids'].map{ |id|
    lut[id] }
  game['red_team_minecraft_uuids'] = game['red_team_discord_ids'].map{ |id|
    lut[id] }
  ret_obj = $ddb_game_manager.put(game)
  status = SERVER_ERROR unless ret_obj.data.class == Aws::DynamoDB::Types::PutItemOutput

  ret = { game: game.to_h }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
