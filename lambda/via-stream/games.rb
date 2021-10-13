load 'git_commit_sha.rb'
require 'aws-sdk-dynamodbstreams'
require 'elo_rating'
require 'json'
require 'lib/aws_credentials'
require 'lib/game'
require 'lib/helpers'
require 'lib/postgres_client'
require 'lib/sqs_client'
require 'lib/dynamo_client'

def elo_change_present?(hash)
  hash[:event_name] == 'MODIFY' and
    !!hash[:dynamodb][:new_image]['game']['game_score']
end

def ddb_insert?(hash)
  hash[:event_name] == 'INSERT'
end

def ddb_task_ip_modify?(hash)
  hash[:event_name] == 'MODIFY' and
    !!hash[:dynamodb][:new_image]['game']['taskIP']
end

def compute_elo_changes(hash)
  game = Game.new(hash[:dynamodb][:new_image]['game'])
  pairs = game.get_elo_matched_winning_pairs
  pairs.each do |pair|
    match = EloRating::Match.new
    match.add_player(rating: pair.winner.start_elo, winner: true)
    match.add_player(rating: pair.loser.start_elo)
    pair.update_elo(*match.updated_ratings)
  end
end

def update_leaderboard(batch)
  PostgresClient.instance.prepare
  batch.each do |m|
    resw = $pg_conn.exec_prepared('update_winner', [ m.winner.end_elo,
                                                     m.winner.discord_id
                                                   ])
    if resw.cmd_tuples == 0
      reswi = $pg_conn.exec_prepared('new_winner', [ m.winner.discord_id,
                                                    m.winner.minecraft_uuid,
                                                    m.winner.end_elo,
                                                   ])
    end

    resl = $pg_conn.exec_prepared('update_loser', [ m.loser.end_elo,
                                                    m.loser.discord_id
                                                  ])
    if resl.cmd_tuples == 0
      resli = $pg_conn.exec_prepared('new_loser', [ m.loser.discord_id,
                                                    m.loser.minecraft_uuid,
                                                    m.loser.end_elo,
                                                   ])
    end
  end
end

def handler(event:, context:)
  Aws::DynamoDBStreams::AttributeTranslator
    .from_event(event)
    .each do |record|
    hash = record.to_h
    unless ddb_insert?(hash) or ddb_task_ip_modify?(hash)
      uuid = hash[:dynamodb][:new_image]["game"]["uuid"]
      puts "sending sqs game #{uuid} event: #{hash[:event_id]}"
      $sqs_manager.enqueue(PLAYER_MESSAGES, hash.to_json) 
      batch = compute_elo_changes(hash) if elo_change_present?(hash)
      $ddb_user_manager.batch_update(batch)
      puts "game #{uuid} saved update user records"
      update_leaderboard(batch)
      puts "game #{uuid} updated leaderboard"
    end
  end
end
