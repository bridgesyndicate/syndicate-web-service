load 'git_commit_sha.rb'
require 'aws-sdk-dynamodbstreams'
require 'json'
require 'lib/aws_credentials'
require 'lib/helpers'
require 'lib/sqs_client.rb'

def handler(event:, context:)
  Aws::DynamoDBStreams::AttributeTranslator
    .from_event(event)
    .each do |record|
    $sqs_manager.enqueue(PLAYER_MESSAGES, record.to_h.to_json)
  end
end
