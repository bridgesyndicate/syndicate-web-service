load 'git_commit_sha.rb'
require 'json'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'securerandom'

def auth_user_by_discord_id_get_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Syndicate-commit-sha" => $my_git_commit_sha
  }

  begin
    discord_id = event['pathParameters']['proxy']
    raise unless discord_id.match(/\d+/)
  rescue
    return { statusCode: BAD_REQUEST,
           headers: headers_list,
           body: {}.to_json
    }
  end

  status = OK

  user = $ddb_user_manager.get_by_discord_id(discord_id)
  if user.items.empty?
    status = NOT_FOUND
  else
    user = user.items.first # TODO: make a User model
  end

  return { statusCode: status,
           headers: headers_list,
           body: user.to_json }

end
