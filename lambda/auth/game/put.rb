require 'json'
load 'git_commit_sha.rb'
load 'lib/dynamo_client.rb'
require 'json-schema'
require 'lib/schema/pile_post'
require 'lib/helpers'

def auth_pile_put_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "Indybooks-git-commit-sha" => $my_git_commit_sha
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

  payload = event['body']
  status = JSON::Validator.validate(PilePostSchema.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST

  if status == OK
    payload = JSON.parse(payload, object_class: OpenStruct)
    payload.pile.uuid = uuid
    payload.pile.username = get_cognito_username(event)
    ret_obj = $pile_manager.put(payload.pile)
    status = SERVER_ERROR unless ret_obj.data.class == Aws::DynamoDB::Types::PutItemOutput
  end

  return { statusCode: status,
           headers: headers_list,
           body: '{}'
  }

end
