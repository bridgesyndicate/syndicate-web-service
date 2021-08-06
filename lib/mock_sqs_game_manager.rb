require 'securerandom'

class MockSqsGameManager
  attr_accessor :client, :table_name
  def initialize()

    @table_name = "syndicate_#{SYNDICATE_ENV}_games"

    @client = Aws::SQS::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials,
                                        )
  end

  def enqueue(message)
    ret = Aws::SQS::Types::SendMessageResult.new({
                                                   message_id: SecureRandom.uuid
                                                 })
  end
end
