require 'lib/mock_dynamodb_game_manager'
require 'lib/mock_dynamodb_helpers'
require 'lib/dynamodb_game_manager'
require 'lib/helpers'

require 'bundler'

Bundler.require

options = {
  region: ENV['AWS_REGION'],
}

if SYNDICATE_ENV == 'development'
  raise "Oh gosh I can't talk to the db because" +
          "AWS_ACCESS_KEY_ID = #{ENV['AWS_ACCESS_KEY_ID']}, " +
          "AWS_SECRET_ACCESS_KEY = #{ENV['AWS_SECRET_ACCESS_KEY']}, " +
          "AWS_ACCESS_KEY_ID = #{ENV['AWS_ACCESS_KEY_ID']}, " +
          "AWS_SECRET_ACCESS_KEY = #{ENV['AWS_SECRET_ACCESS_KEY']}" if ENV['AWS_ACCESS_KEY_ID'].nil? ||
                                                                       ENV['AWS_SECRET_ACCESS_KEY'].nil? ||
                                                                       ENV['AWS_ACCESS_KEY_ID'].empty? ||
                                                                       ENV['AWS_SECRET_ACCESS_KEY'].empty?
  options[:endpoint] = 'http://localhost:8000'
end

game_options = options.clone

if SYNDICATE_ENV == 'test'
  $ddb_game_manager    =  MockDynamodbGameManager.new(**game_options)
else
  $ddb_game_manager     = DynamodbGameManager.new(**game_options)
end
