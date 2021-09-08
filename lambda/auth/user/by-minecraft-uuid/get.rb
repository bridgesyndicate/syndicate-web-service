require 'json'
load 'git_commit_sha.rb'
load 'lib/dynamo_client.rb'
require 'json-schema'
require 'lib/helpers'
require 'securerandom'

def auth_user_by_minecraft_uuid_get_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Indybooks-git-commit-sha" => $my_git_commit_sha
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
    ret = {
      kickCode: SecureRandom.alphanumeric
    }
  else
    status = OK
    user = user.items.first
    user.transform_values! do |value|
      value.class == BigDecimal ? value.to_f : value
    end
    ret = {
      user: user
    }
  end

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json }

end
