load 'git_commit_sha.rb'
require 'json'
require 'json-schema'
require 'lib/helpers'
require 'lib/schema/ban_schema'
require 'lib/dynamo_client'

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

  syn_logger "ban: #{minecraft_uuid}"

  ret = $ddb_user_manager.ban(minecraft_uuid)

  # return { statusCode: NOT_FOUND,
  #          headers: headers_list,
  #          body: {}.to_json } unless auto_scaler.accept_candidate?

  # syn_logger 'accepting candidate'


  return { 
    statusCode: status,
    headers: headers_list,
    body: ret.to_json
  }
end
