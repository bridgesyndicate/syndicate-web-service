require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/schema/game_post'
require 'lib/sqs_client.rb'

def game_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  uuid = SecureRandom.uuid
  payload = event['body']
  status = JSON::Validator.validate(GamePostSchema.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST
  return { statusCode: status,
           headers: headers_list,
           body: {}.to_json
  } if status == BAD_REQUEST
  

  game = OpenStruct.new
  game.game_data = JSON.parse(payload, object_class: OpenStruct)
  game.uuid = uuid
  ret_obj = $ddb_game_manager.put(game)
  status = SERVER_ERROR unless ret_obj.data.class == Aws::DynamoDB::Types::PutItemOutput
  game.game_data.uuid = uuid

  sqs_ret = $sqs_game_manager.enqueue(game.game_data.to_h.to_json)
  status = SERVER_ERROR unless sqs_ret.message_id.match(/\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b/)

  ret = {
    "status": status,
    "uuid": uuid
  }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
