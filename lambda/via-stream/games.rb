load 'git_commit_sha.rb'
require 'aws-sdk-dynamodbstreams'
require 'json'
require 'lib/aws_credentials'
require 'lib/game'
require 'lib/helpers'
require 'lib/sqs_client.rb'

def elo_change_present(hash)
  hash[:event_name] == 'MODIFY' and
    !!hash[:dynamodb][:new_image]['game']['game_score']
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
    binding.pry;1
end

def handler(event:, context:)
  puts event.class
  Aws::DynamoDBStreams::AttributeTranslator
    .from_event(event)
    .each do |record|
    hash = record.to_h
    $sqs_manager.enqueue(PLAYER_MESSAGES, hash.to_json)
    results = compute_elo_changes(hash) if elo_change_present(hash)
    # update each user record
    # update each user in the leaderboard table
  end
end
