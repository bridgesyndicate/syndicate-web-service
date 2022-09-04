load 'git_commit_sha.rb'
require 'json'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'securerandom'

def auth_user_by_minecraft_uuid_get_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Syndicate-commit-sha" => $my_git_commit_sha
  }

  begin
    uuid = event['pathParameters']['proxy']
    raise unless uuid.match(UUID_REGEX)
  rescue
    return { statusCode: BAD_REQUEST,
           headers: headers_list,
           body: {}.to_json
    }
  end
  user = $ddb_user_manager.get(uuid)
  if user.items.empty?
    status = NOT_FOUND
    kick_code = SecureRandom.alphanumeric
    $ddb_kick_code_manager.put(kick_code, uuid)
    ret = {
      kick_code: kick_code
    }
  else
    status = OK
    user = user.items.first # TODO: make a User model
    ret = {
      user: user
    }
  end

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json }

end
