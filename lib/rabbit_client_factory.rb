require 'lib/rabbit_client'
require 'lib/mock_rabbit_client'

DEFAULT_QUEUE = 'default'


class RabbitClientFactory
  def self.produce
    SYNDICATE_ENV == 'test' ? MockRabbitClient.new : RabbitClient.new
  end
end

