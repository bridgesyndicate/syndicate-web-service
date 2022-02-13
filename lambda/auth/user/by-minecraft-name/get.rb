load 'git_commit_sha.rb'
require 'json'
require 'uuid'
require 'lib/aws_credentials'
require 'lib/dynamo_client.rb'
require 'lib/helpers'
require 'lib/mojang_client'

def auth_user_by_minecraft_name_get_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Syndicate-commit-sha" => $my_git_commit_sha
  }

  status = OK

  begin
    minecraft_name = event['pathParameters']['proxy']
    raise if minecraft_name.match(/\W/)
  rescue
    return { statusCode: BAD_REQUEST,
           headers: headers_list,
           body: {}.to_json
    }
  end

  begin
    response = MojangClient.resolve(minecraft_name)
  rescue MojangClient::NotFoundError => e
    status = NOT_FOUND
  end

  return { statusCode: NOT_FOUND,
           headers: headers_list,
           body: { reason: e.message }.to_json
  } if status != OK

  minecraft_uuid = UUID.parse(JSON.parse(response.body)['id']).to_s

  user = $ddb_user_manager.get(minecraft_uuid)

  if user.items.empty?
    status = NOT_FOUND
    ret = { reason: 'Syndicate cannot find this username' }
  else
    user = user.items.first
    ret = {
      user: user
    }
  end

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json }

end
