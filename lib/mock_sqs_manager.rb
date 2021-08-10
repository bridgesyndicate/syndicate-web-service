require 'securerandom'

class MockSqsManager
  attr_accessor :client, :table_name
  def initialize()

    @client = Aws::SQS::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials,
                                        )
  end

  def enqueue(queue_name, message)
    ret = Aws::SQS::Types::SendMessageResult.new({
                                                   message_id: SecureRandom.uuid
                                                 })
  end
end
