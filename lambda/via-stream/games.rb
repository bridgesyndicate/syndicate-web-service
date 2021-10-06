load 'git_commit_sha.rb'
require 'json'
require 'lib/aws_credentials'
require 'lib/helpers'
require 'lib/sqs_client.rb'

def handler(event:, context:)
  puts event.inspect
  thing = {
    message: "foo bar"
  }
  $sqs_manager.enqueue(PLAYER_MESSAGES, thing.to_json)
end
