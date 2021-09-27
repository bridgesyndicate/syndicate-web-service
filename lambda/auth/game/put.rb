load 'git_commit_sha.rb'
require 'json'
require 'json-schema'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/schema/game_put'
require 'lib/rabbit_client'
require 'ostruct'

def auth_game_put_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }


  payload = event['body']
  status = JSON::Validator.validate(GamePutSchema.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST

  puts JSON::Validator.fully_validate(GamePutSchema.schema, payload,
                                    :strict => true
                                ) if status == BAD_REQUEST && SYNDICATE_ENV == 'development'
  return { statusCode: status,
           headers: headers_list,
           body: {}.to_json
  } if status == BAD_REQUEST

  game = JSON.parse(payload, object_class: OpenStruct)
  game_uuid = game.uuid

  ret_obj = $ddb_game_manager.update_game(game_uuid, game)

  if ret_obj == DynamodbGameManager::ObjectNotFound
    status = NOT_FOUND
  elsif ret_obj.data.class != Aws::DynamoDB::Types::UpdateItemOutput
    status = SERVER_ERROR
  end

  ret = {
    "status": status,
    "uuid": game_uuid
  }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
