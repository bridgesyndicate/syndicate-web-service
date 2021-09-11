require 'time'
require 'ostruct'

class MockDynamodbKickCodeManager
  attr_accessor :client, :table_name, :succeed
  def initialize(region: nil,
                 table_name: nil,
                 endpoint: nil)

    @table_name = "syndicate_#{SYNDICATE_ENV}_kick_codes"

    @client = {
      region:      region,
      endpoint:    endpoint
    }
    @succeed = true
  end

  def put(kick_code, uuid)
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
  class ObjectNotFound
  end
end
