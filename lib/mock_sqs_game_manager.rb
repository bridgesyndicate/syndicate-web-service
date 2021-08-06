require 'time'

class MockSqsGameManager
  attr_accessor :client, :table_name
  def initialize()

    @table_name = "syndicate_#{SYNDICATE_ENV}_games"

    @client = Aws::Sqs::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials,
                                        )
  end

  def conditional_user_pile_create(p)
    if (rand > 0.5)
      MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
    else
      false
    end
  end

  def add_pile_uuid(username, uuid)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
  end

  def put(p)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
  end

  def get(username)
    if username == 'indybooks'
      n_piles = Integer(rand*10) + 1
      ret = [{
               username: username,
               updated_at: Time.now.utc.iso8601,
               created_at: Time.now.utc.iso8601,
               pile_uuid_list: n_piles.times.map { SecureRandom.uuid }
             }]
    else
      ret = {}
    end
      MockDynamoResults.new(ret)
  end
end
