load 'git_commit_sha.rb'
require 'aws-sdk-dynamodbstreams'
require 'json'
require 'lib/aws_credentials'
require 'lib/helpers'
require 'lib/sqs_client.rb'

def handler(event:, context:)
  puts event.class
  Aws::DynamoDBStreams::AttributeTranslator
    .from_event(event)
    .each do |record|
    $sqs_manager.enqueue(PLAYER_MESSAGES, record.to_h.to_json)
    # compute elo changes
    # update each user record
    # update each user in the leaderboard table
  end
end
