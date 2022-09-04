load 'git_commit_sha.rb'
require 'json-schema' # this avoids a "superclass mismatch for class BigDecimal"
require 'lib/helpers'
require 'lib/dynamo_client.rb'

def auth_ban_delete_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  begin
    minecraft_uuid = event['pathParameters']['proxy']
    raise unless minecraft_uuid.match(UUID_REGEX)
  rescue
    return { statusCode: BAD_REQUEST,
           headers: headers_list,
           body: {}.to_json
    }
  end

  ret = $ddb_user_manager.unban(minecraft_uuid)

  return { statusCode: OK,
           headers: headers_list,
           body: ret.attributes.to_json }
end
