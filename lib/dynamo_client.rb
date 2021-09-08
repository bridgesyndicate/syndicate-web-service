require 'lib/mock_dynamodb_game_manager'
require 'lib/mock_dynamodb_user_manager'
require 'lib/mock_dynamodb_helpers'
require 'lib/dynamodb_game_manager'
require 'lib/dynamodb_user_manager'
require 'lib/helpers'

$ddb_game_manager    =  SYNDICATE_ENV == 'test' ? MockDynamodbGameManager.new() : DynamodbGameManager.new()
$ddb_user_manager    =  SYNDICATE_ENV == 'test' ? MockDynamodbUserManager.new() : DynamodbUserManager.new()
