load 'git_commit_sha.rb'
require 'json-schema'
require 'lib/helpers'
require 'lib/schema/ban_schema'
require 'lib/dynamo_client'
require 'lib/rabbit_client_factory'

def auth_ban_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  payload = event['body']
  status = JSON::Validator.validate(BanSchema.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST
  return { statusCode: status,
           headers: headers_list,
           body: { reason: "Payload json does not validate against schema."}.to_json
  } if status != OK

  minecraft_uuid = JSON.parse(payload, symbolize_names: true)[:minecraft_uuid]

  syn_logger "attempting to ban: #{minecraft_uuid}"

  ret = $ddb_user_manager.ban(minecraft_uuid)

  rabbit_client = RabbitClientFactory.produce
  task_ip = "0.0.0.0" # warp the player to hell to disconnect them
  rabbit_client.send_players_to_host_no_cache(Array(minecraft_uuid), task_ip)
  rabbit_client.shutdown

  return { 
    statusCode: status,
    headers: headers_list,
    body: ret.to_json
  }
end
