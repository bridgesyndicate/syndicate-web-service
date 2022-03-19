load 'git_commit_sha.rb'
require 'lib/helpers'
require 'lib/ecs_client'
require 'lib/cloudwatch_client'

def handler(event:, context:)
  puts "git sha is: #{$my_git_commit_sha}"
  desired_count = ECSClient.get_desired_count_for_bridge_service
  CloudwatchClient.put_game_container_desired_count(desired_count)
  syn_logger "running at #{Time.now}"
end
