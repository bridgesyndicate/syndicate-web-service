load 'git_commit_sha.rb'
require 'lib/helpers'
require 'lib/appconfig_client'
require 'lib/ecs_client'
require 'lib/cloudwatch_client'
require 'lib/postgres_client'
require 'lib/auto_scaler'

def handler(event:, context:)
  puts "git sha is: #{$my_git_commit_sha}"
  tasks = ECSClient
    .list_tasks
    .task_arns
  CloudwatchClient.put_game_container_task_count(tasks.size)
  delay = CloudwatchClient.get_container_metadata_delay
  config = AppconfigClient.get_configuration
  auto_scaler = AutoScaler.new(tasks, delay, config)
  auto_scaler.set_sql_client(PostgresClient.instance)
  auto_scaler.scale
  syn_logger "tasks: #{auto_scaler.tasks}"
  syn_logger "delay: #{delay}"
end
