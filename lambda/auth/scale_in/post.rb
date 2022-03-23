load 'git_commit_sha.rb'
require 'json'
require 'json-schema'
require 'lib/helpers'
require 'lib/schema/scale_in'

def auth_scale_in_post_handler(event:, context:)

  headers_list = {
    "Access-Control-Allow-Origin" => "*",
    "X-git-commit-sha" => $my_git_commit_sha
  }

  payload = event['body']
  status = JSON::Validator.validate(ScaleInSchema.schema, payload,
                                    :strict => true
                                   ) ? OK : BAD_REQUEST
  return { statusCode: status,
           headers: headers_list,
           body: { reason: "Payload json does not validate against schema."}.to_json
  } if status != OK

  task_arn = JSON.parse(payload, object_class: OpenStruct)['task_arn']

  status = task_arn[task_arn.size-1].to_i % 2 == 0 ? OK : NOT_FOUND

  ret = {}

  return { statusCode: status,
           headers: headers_list,
           body: ret.to_json }
end
