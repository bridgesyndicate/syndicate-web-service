require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'

require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/ec2_client.rb'
require 'lib/ecs_client.rb'
require 'lib/helpers'
require 'lib/schema/game_container_metadata_put'
require 'lib/sqs_client.rb'

def auth_game_container_metadata_put_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

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
  task_arn = payload.taskArn

  ret_obj = $ddb_game_manager.update_arn(game_uuid, task_arn)

  if ret_obj == DynamodbGameManager::ObjectNotFound
    status = NOT_FOUND
  elsif ret_obj.data.class != Aws::DynamoDB::Types::UpdateItemOutput
    status = SERVER_ERROR
  end

  if status == OK
    eni = $ecs_client.get_iface_for_task_arn(task_arn)
    public_ip = $ec2_client.get_public_ip_for_iface(eni)
    queue = "#{PLAYER_MESSAGES}-#{SYNDICATE_ENV}"
    player_message = {
      game_uuid: game_uuid,
      public_ip: public_ip
    }
    $sqs_manager.enqueue(queue, JSON.generate(player_message))
  end

  ret = {
    "status": status,
  }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
