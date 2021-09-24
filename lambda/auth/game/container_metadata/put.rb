require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'

require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/schema/game_container_metadata_put'
require 'lib/rabbit_client.rb'

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
  container_ip = task_arn # used to be the arn and we would use ec2 and ecs to look up the IP

  ret_obj = $ddb_game_manager.update_task_ip(game_uuid, container_ip)

  if ret_obj == DynamodbGameManager::ObjectNotFound
    status = NOT_FOUND
  elsif ret_obj.data.class != Aws::DynamoDB::Types::UpdateItemOutput
    status = SERVER_ERROR
  end

  puts "XXXXXXXXXXXXXXXXXXXXXXXXXX"
  puts ret_obj.inspect

  if status == OK
    (ret_obj.attributes['game']['blue_team_minecraft_uuids'] +
     ret_obj.attributes['game']['red_team_minecraft_uuids']).each do |id|
      container_name = container_ip
      $rabbit_client.send_player_to_host(id, container_name, container_ip)
    end
  end

  ret = {
    status: status,
    ip: container_ip
  }

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
