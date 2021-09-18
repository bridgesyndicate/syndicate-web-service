require 'lib/rabbit_manager.rb'
require 'lib/mock_rabbit_manager.rb'

DEFAULT_QUEUE = 'default'

$rabbit_client =  SYNDICATE_ENV == 'test' ? MockRabbitClient.new() : RabbitClient.new()
