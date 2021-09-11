require 'json'
load 'git_commit_sha.rb'
load 'lib/dynamo_client.rb'
require 'json-schema'
require 'lib/helpers'

def auth_pile_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Syndicate-git-commit-sha" => $my_git_commit_sha
  }

  begin
    uuid = event['pathParameters']['proxy'].split('/')[0]
    username = get_cognito_username(event)
    raise unless uuid.match(UUID_REGEX)
  rescue
    return { statusCode: BAD_REQUEST,
           headers: headers_list,
           body: {}.to_json
    }
  end
  pile = $pile_manager.get(uuid)
  unless pile.items.empty?
    if pile.items.first["username"] == username
      status = OK
    else
      status = FORBIDDEN
      return { statusCode: status,
               headers: headers_list,
               body: {}.to_json
      }
    end
    ret = {
      pile: pile.items.first.merge({pile_uuid: uuid})
    }
  else
    status = NOT_FOUND
    ret = {}
  end


  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }

end
