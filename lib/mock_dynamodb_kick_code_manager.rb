require 'time'
require 'ostruct'
require 'lib/object_not_found'

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

  def use_once(kick_code)
    if kick_code.match?(/[02468]$/)
      ret = [{
               'updated_at' => Time.now.utc.iso8601,
               'kick_code' => kick_code,
               'minecraft_uuid' => SecureRandom.uuid
             }]
    else
      return ObjectNotFound
    end
      MockDynamoResults.new(ret)
  end
end
