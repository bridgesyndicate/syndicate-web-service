require 'json'
require 'ostruct'
load 'git_commit_sha.rb'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/object_not_found'

def auth_register_by_kick_code_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  kick_code = event['pathParameters']['proxy'].split('/')[0]
  discord_id = event['pathParameters']['proxy'].split('/')[2]

  status = ( kick_code.match?(KICK_CODE_REGEX) &&
        discord_id.match?(/\d+/) ) ? OK : BAD_REQUEST

  return { statusCode: status,
           headers: headers_list,
           body: {}.to_json
  } if status == BAD_REQUEST

  kick = $ddb_kick_code_manager.use_once(kick_code)

  return { statusCode: NOT_FOUND,
           headers: headers_list,
           body: { reason: 'Kickcode not found.' }.to_json
  } if kick == ObjectNotFound

  kick_record = kick.attributes

  minecraft_uuid = kick_record['minecraft_uuid']
  kick_code_created_at = kick_record['created_at']

  existing_user = $ddb_user_manager.get(minecraft_uuid)

  return { statusCode: NOT_FOUND,
           headers: headers_list,
           body: { reason: 'Duplicate user record.' }.to_json
  } unless existing_user.items.empty?

  ret = $ddb_user_manager.put(minecraft_uuid,
                        discord_id,
                        kick_code,
                        kick_code_created_at)

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
