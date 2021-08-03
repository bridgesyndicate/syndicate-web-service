require 'json'
require 'ostruct'

load 'git_commit_sha.rb'
require 'json-schema'
require 'lib/dynamo_client.rb'
require 'lib/schema/game_post'
require 'lib/helpers'

def game_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Indybooks-git-commit-sha" => $my_git_commit_sha
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
  
  if status == OK
    game = OpenStruct.new
    game.game_data = JSON.parse(payload, object_class: OpenStruct)
    game.uuid = uuid
    ret_obj = $ddb_game_manager.put(game)
    status = SERVER_ERROR unless ret_obj.data.class == Aws::DynamoDB::Types::PutItemOutput
  end

  ret = {
    "status": status,
    "uuid": uuid
  }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
