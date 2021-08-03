require 'json'
load 'git_commit_sha.rb'
load 'lib/dynamo_client.rb'
require 'lib/helpers'

def auth_pile_delete_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Indybooks-git-commit-sha" => $my_git_commit_sha
  }

  status = OK

  begin
    uuid = event['pathParameters']['proxy'].split('/')[0]
    raise unless uuid.match(UUID_REGEX)
  rescue
    return { statusCode: BAD_REQUEST,
             headers: headers_list,
             body: {}.to_json
    }
  end

  ret_obj = $pile_manager.delete(uuid)
  status = SERVER_ERROR unless ret_obj.data.class == Aws::DynamoDB::Types::DeleteItemOutput

  ret = {}

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json
  }
end
