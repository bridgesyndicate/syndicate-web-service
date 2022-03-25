load 'git_commit_sha.rb'
require 'json'
require 'json-schema'
require 'lib/helpers'
require 'lib/schema/scale_in'
require 'lib/appconfig_client'
require 'lib/ecs_client'
require 'lib/cloudwatch_client'
require 'lib/postgres_client'
require 'lib/auto_scaler'

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

  tasks = ECSClient
    .list_tasks
    .task_arns

  delay = CloudwatchClient.get_container_metadata_delay
  config = AppconfigClient.get_configuration
  auto_scaler = AutoScaler.new(tasks, delay, config)
  auto_scaler.set_sql_client(PostgresClient.instance)

  return { statusCode: NOT_FOUND,
           headers: headers_list,
           body: {}.to_json } unless auto_scaler.accept_candidate?

  auto_scaler.insert_candidate(task_arn)
  status = auto_scaler.first_candidate?(task_arn) ? OK : NOT_FOUND

  return { statusCode: status,
           headers: headers_list,
           body: {}.to_json }
end
