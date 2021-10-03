require 'time'
require 'ostruct'

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

  def put(minecraft_uuid, discord_id, kick_code, kick_code_created_at)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
    item = {
      'updated_at' => Time.now.utc.iso8601,
      'created_at' => Time.now.utc.iso8601,
      'minecraft_uuid' => minecraft_uuid,
      'discord_id' => discord_id,
      'kick_code' => kick_code,
      'kick_code_created_at' => kick_code_created_at
    }
    item
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

  def ensure_verified(discord_ids)
    discord_ids.map do |id|
      if id.match?(/[02468]$/)
        ret = [{
                 'minecraft_uuid' =>  get_one_srandom_minecraft_uuid,
                 'created_at' => Time.now.utc.iso8601,
                 'discord_id' => id
               }]
        MockDynamoResults.new(ret)
      else
        MockDynamoResults.new({})
      end
    end
  end
end
