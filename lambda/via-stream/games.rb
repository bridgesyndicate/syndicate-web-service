load 'git_commit_sha.rb'
require 'lib/helpers'
require 'aws-sdk-dynamodbstreams'
require 'elo_rating'
require 'json'
require 'lib/aws_credentials'
require 'lib/game_stream'
require 'lib/sqs_client'
require 'lib/dynamo_client'

def handler(event:, context:)
  puts event.inspect
  Aws::DynamoDBStreams::AttributeTranslator
    .from_event(event)
    .each do |record|
    game_stream = GameStream.new(record)
    unless game_stream.ddb_insert?
      if game_stream.ddb_task_ip_modify?
        puts "sending new game sqs for #{game_stream.uuid} event: #{game_stream.event_id}"
        $sqs_manager.enqueue(PLAYER_MESSAGES, game_stream.to_json)
      elsif game_stream.game_ended_with_score?
        puts "sending game end sqs for #{game_stream.uuid} event: #{game_stream.event_id}"
        game_stream.compute_elo_changes
        $sqs_manager.enqueue(PLAYER_MESSAGES, game_stream.to_json)
        $ddb_user_manager.batch_update(game_stream.batch)
        puts "game #{game_stream.uuid} saved update user records"
        game_stream.update_leaderboard
        puts "game #{game_stream.uuid} updated leaderboard"
      end
    end
  end
end
