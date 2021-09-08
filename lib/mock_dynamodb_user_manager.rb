require 'time'
require 'ostruct'
require 'securerandom'

class MockDynamodbUserManager
  attr_accessor :client, :table_name, :succeed
  def initialize(region: nil,
                 table_name: nil,
                 endpoint: nil)

    @table_name = "syndicate_#{SYNDICATE_ENV}_users"

    @client = {
      region:      region,
      endpoint:    endpoint
    }
    @succeed = true
  end

  def get(uuid)
    if uuid.match?(/[02468]$/)
      ret = [{
               updated_at: Time.now.utc.iso8601,
               created_at: Time.now.utc.iso8601,
               minecraftUUID: uuid,
               discordID: SecureRandom.random_number(10**16)
             }]
    else
      ret = {}
    end
      MockDynamoResults.new(ret)
  end
  class ObjectNotFound
  end
end
