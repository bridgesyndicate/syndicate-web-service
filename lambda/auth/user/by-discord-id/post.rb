require 'json'
require 'json-schema'
load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/schema/user/by-discord-id/post'

def auth_user_by_discord_id_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  payload = event['body']
  status = JSON::Validator.validate(UserByDiscordIdPost.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST
  return { statusCode: status,
           headers: headers_list,
           body: { reason: "Payload json does not validate against schema."}.to_json
  } if status != OK

  users = JSON.parse(payload, object_class: OpenStruct)

  ret = $ddb_user_manager.batch_get_by_discord_ids(users)

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
