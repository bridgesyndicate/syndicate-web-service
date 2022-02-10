load 'git_commit_sha.rb'
require 'aws-sdk-dynamodbstreams'
require 'elo_rating'
require 'json'
require 'lib/helpers'
require 'lib/aws_credentials'
require 'lib/game_stream'
require 'lib/sqs_client'
require 'lib/rabbit_client_factory'
require 'lib/dynamo_client'

def handler(event:, context:)
  syn_logger event.class
  syn_logger event
  syn_logger event.inspect
  Aws::DynamoDBStreams::AttributeTranslator
    .from_event(event)
    .each do |record|
    game_stream = GameStream.new(record)
    unless game_stream.ddb_insert?
      if game_stream.ddb_task_ip_modify?
        syn_logger "sending new game sqs for #{game_stream.uuid} event: #{game_stream.event_id}"
        $sqs_manager.enqueue(PLAYER_MESSAGES, game_stream.to_json)
      elsif game_stream.game_ended_with_score?
        syn_logger "sending game end sqs for #{game_stream.uuid} event: #{game_stream.event_id}"
        game_stream.compute_elo_changes
        $sqs_manager.enqueue(PLAYER_MESSAGES, game_stream.to_json)
        $ddb_user_manager.batch_update(game_stream.batch)
        syn_logger "game #{game_stream.uuid} saved update user records"
        game_stream.update_leaderboard
        syn_logger "game #{game_stream.uuid} updated leaderboard"
        rabbit_client = RabbitClientFactory.produce
        rabbit_client.clear_warp_cache_for_players(game_stream.player_uuids)
      end
    end
  end
end
