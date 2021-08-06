require 'lib/mock_dynamodb_game_manager'
require 'lib/mock_dynamodb_helpers'
require 'lib/dynamodb_game_manager'
require 'lib/helpers'

if SYNDICATE_ENV == 'test'
  $ddb_game_manager    =  MockDynamodbGameManager.new()
else
  $ddb_game_manager     = DynamodbGameManager.new()
end
