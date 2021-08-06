require 'lib/mock_sqs_game_manager'
require 'lib/sqs_game_manager'
require 'bundler'

Bundler.require

if SYNDICATE_ENV == 'test'
  $sqs_game_manager    =  MockSqsGameManager.new()
else
  $sqs_game_manager     = SqsGameManager.new()
end
