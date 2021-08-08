require 'pry'
require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/schema/game_container_metadata_put'
require 'lib/sqs_client.rb'

def auth_game_container_metadata_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  binding.pry;1
  payload = event['body']
  status = JSON::Validator.validate(GameContainerMetadataSchema.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST
  return { statusCode: status,
           headers: headers_list,
           body: {}.to_json
  } if status == BAD_REQUEST

  payload = JSON.parse(payload, object_class: OpenStruct)
  game_uuid = payload.uuid
  taskArn = payload.taskArn
  binding.pry;1

  ret_obj = $ddb_game_manager.update_arn(game_uuid, taskArn)

  if ret_obj == DynamodbGameManager::ObjectNotFound
    status = NOT_FOUND
  elsif ret_obj.data.class != Aws::DynamoDB::Types::UpdateItemOutput
    status = SERVER_ERROR
  end

  ret = {
    "status": status,
  }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
