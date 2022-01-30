require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'

require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/schema/game_container_metadata_put'
require 'lib/object_not_found'
require 'lib/rabbit_client_factory'

def auth_game_container_metadata_put_handler(event:, context:)

  rabbit_client = RabbitClientFactory.produce

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
  container_ip = payload.taskArn # was the arn we would use to lookup IP

  ret_obj = $ddb_game_manager.update_task_ip(game_uuid, container_ip)

  if ret_obj == ObjectNotFound
    status = NOT_FOUND
  elsif ret_obj.data.class != Aws::DynamoDB::Types::UpdateItemOutput
    status = SERVER_ERROR
  end

  if status == OK
    rabbit_client.send_players_to_host_cached(
                                      (ret_obj.attributes['game']['blue_team_minecraft_uuids'] +
                                       ret_obj.attributes['game']['red_team_minecraft_uuids']),
                                      container_ip)
  end

  ret = {
    status: status,
    ip: container_ip
  }
  syn_logger "returning status #{status}"
  rabbit_client.shutdown
  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
