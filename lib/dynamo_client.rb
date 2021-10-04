require 'lib/dynamodb_game_manager'
require 'lib/dynamodb_kick_code_manager'
require 'lib/dynamodb_user_manager'
require 'lib/helpers'
require 'lib/mock_dynamodb_game_manager'
require 'lib/mock_dynamodb_helpers'
require 'lib/mock_dynamodb_kick_code_manager'

$ddb_game_manager    =  SYNDICATE_ENV == 'test' ? MockDynamodbGameManager.new() : DynamodbGameManager.new()
$ddb_kick_code_manager = SYNDICATE_ENV == 'test' ? MockDynamodbKickCodeManager.new() : DynamodbKickCodeManager.new()
$ddb_user_manager = DynamodbUserManager.new()
