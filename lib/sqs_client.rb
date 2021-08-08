require 'lib/mock_sqs_game_manager'
require 'lib/sqs_game_manager'

if SYNDICATE_ENV == 'test' or SYNDICATE_ENV == 'development'
  $sqs_game_manager    =  MockSqsGameManager.new()
else
  $sqs_game_manager     = SqsGameManager.new()
end
