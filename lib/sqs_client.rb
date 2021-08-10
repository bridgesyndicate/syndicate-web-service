require 'lib/mock_sqs_manager'
require 'lib/sqs_manager'

if SYNDICATE_ENV == 'test' or SYNDICATE_ENV == 'development'
  $sqs_manager    =  MockSqsManager.new()
else
  $sqs_manager     = SqsManager.new()
end
